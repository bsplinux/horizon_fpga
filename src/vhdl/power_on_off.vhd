library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity power_on_off is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        regs_updating    : in  reg_slv_array_t;
        regs_reading     : in  reg_slv_array_t;
        internal_regs    : out reg_array_t;
        internal_regs_we : out reg_slv_array_t;
        power_2_ios      : out power_2_ios_t;
        free_running_1ms : in  std_logic;
        -- fans
        fans_en          : out std_logic;
        fans_ok          : in  std_logic;
        zero_cross       : in  std_logic;
        uvp_error        : in  std_logic;
        PSU_Status       : out std_logic_vector(PSU_Status_range);
        PSU_Status_mask  : out std_logic_vector(PSU_Status_range)
    );
end entity power_on_off;

architecture RTL of power_on_off is
    -- for simulation all next constants are set to 1, for synthesis each with its real value
    -- note that for simulation the 1ms tick is actually 1us
    constant MSEC_5    : integer := set_const(5,5,sim_on);
    constant MSEC_10   : integer := set_const(10,10,sim_on); -- in miliseconds
    constant MSEC_20   : integer := set_const(20,20,sim_on); -- in miliseconds
    constant MSEC_50   : integer := set_const(50,50,sim_on); -- in miliseconds
    constant MSEC_51   : integer := set_const(51,51,sim_on); -- in miliseconds
    constant SEC_1     : integer := set_const(100,1000,sim_on); -- in miliseconds
    constant SEC_6_DEB : integer := set_const(600,6000 - MSEC_50,sim_on); -- 6 sec minus the debauns value (0.6 sec for sim)
    constant SEC_10    : integer := set_const(1000,10000,sim_on); -- 10 sec (1 sec for sim)
    constant SEC_20    : integer := set_const(2000,20000,sim_on); -- 20 sec (2 sec for sim)
    constant SEC_26    : integer := set_const(2600,26000,sim_on); -- 26 sec (2.6 for sim)
    constant MIN_10    : integer := set_const(6000,600000,sim_on);-- 10 min (6 sec for sim)
    constant HIGH_RES_1MSEC: integer := set_const(10,100_000,sim_on); -- counting 10 ns a clock for syn and 10us for sim 
    type main_sm_t is (idle, start_pwron, wt4_pg_buck, pwron_psus, wt4_all_on, e_shutdown, e_shutdowning, e_shtdwn_wt_ok ,power_on, poweron_low, reset, power_down, wt_pwron0, wt_pwron1);    
    signal debug_state : main_sm_t;
    signal power_on_debaunced : std_logic;
    signal poweron_after26secs : std_logic;
    signal relay_1p_on_request : std_logic;
    signal relay_1p_pg : std_logic;
    signal relay_3p_pg : std_logic;
    signal input_ovp : std_logic;
    signal output_ovp : std_logic;
    signal fans_on : std_logic; -- TODO drive fans from somewere
    signal all_inputs_good : std_logic; -- TODO drive this from somewere  
    signal all_in_range : std_logic; -- TODO drive this from somewere  
    signal keep_fans_on_10min : std_logic; -- from main sm to fans control can be active althugh state could be idle or others. 
    signal turn_on_tcu, turn_off_tcu : std_logic;
    signal temperature_ok : std_logic;
    signal power_on_ok : std_logic;
    signal during_power_down : std_logic;
begin
    internal_regs <= (others => X"00000000");
    internal_regs_we <= (others => '0');
        
    main_sm_pr: process(clk)
       variable state : main_sm_t := idle;
       variable cnt : integer range 0 to SEC_20 := 0;
       variable all_in_range_s : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;   
                debug_state <= idle;         
                power_2_ios.EN_PFC_FB          <= '0';
                power_2_ios.EN_PSU_1_FB        <= '0';
                power_2_ios.EN_PSU_2_FB        <= '0';
                power_2_ios.EN_PSU_5_FB        <= '0';
                power_2_ios.EN_PSU_6_FB        <= '0';
                power_2_ios.EN_PSU_7_FB        <= '0';
                power_2_ios.EN_PSU_8_FB        <= '0';
                power_2_ios.EN_PSU_9_FB        <= '0';
                power_2_ios.EN_PSU_10_FB       <= '0';
                power_2_ios.RESET_OUT_FPGA     <= '1';
                power_2_ios.SHUTDOWN_OUT_FPGA  <= '1';
                relay_1p_on_request            <= '0';
                power_2_ios.RELAY_3PH_FPGA     <= '0';
                power_2_ios.ESHUTDOWN_OUT_FPGA <= '1';
                cnt := 0;
                fans_on <= '0';
                turn_on_tcu <= '0';
                turn_off_tcu <= '0';
                all_in_range_s := '0';
                keep_fans_on_10min <= '0';
                power_on_ok <= '0';
                during_power_down <= '0';
            else
                -- next state logic
                case state is 
                    when idle =>
                        if power_on_debaunced and temperature_ok and all_in_range then
                            state := start_pwron;
                        end if;
                    when start_pwron =>
                        state := wt4_pg_buck;
                    when wt4_pg_buck =>
                        if cnt = SEC_10  or all_in_range = '0' then
                            state := e_shutdown;
                        elsif registers(IO_IN)(IO_IN_PG_BUCK_FB) and fans_ok then
                            state := pwron_psus;
                        end if;
                    when pwron_psus =>
                        if cnt = SEC_10 or all_in_range = '0' then
                            state := e_shutdown;
                        else
                            state := wt4_all_on;
                        end if;
                    when wt4_all_on =>
                        if all_inputs_good then
                           state := power_on;
                        elsif cnt = SEC_10 or all_in_range = '0' then
                            state := e_shutdown;
                        end if;
                    when e_shutdown =>
                        state := e_shutdowning;
                    when e_shutdowning =>
                        if cnt = MSEC_50 + 1 then
                            cnt := 0;
                            if all_in_range_s = '0' then 
                                state := e_shtdwn_wt_ok;
                            else -- e shutdown doe to power good / fan falure then wait for poweron down then up
                                state := wt_pwron0;
                            end if;
                        end if;
                    when e_shtdwn_wt_ok => 
                        if cnt = SEC_1 - MSEC_50 then
                            state := idle;
                        end if;
                    when power_on =>
                        if all_inputs_good = '0' or all_in_range = '0' then
                            state := e_shutdown;
                        elsif not temperature_ok then
                            state := power_down;
                        elsif power_on_debaunced = '0' then
                            state := poweron_low;
                        end if;
                    when poweron_low =>
                        if all_inputs_good = '0' or all_in_range = '0' then
                            state := e_shutdown;
                        elsif power_on_debaunced = '1' and cnt < SEC_6_DEB then
                            state := reset;
                            cnt := 0;
                        elsif cnt > SEC_6_DEB then
                            state := power_down;
                            cnt := 0;
                        end if;
                    when reset =>
                        if all_inputs_good = '0' or all_in_range = '0' then
                            state := e_shutdown;
                        elsif cnt = MSEC_5 then 
                            state := power_on;
                        end if;
                    when power_down =>
                        if all_in_range = '0' then
                            state := e_shutdown;
                        elsif cnt = SEC_20 then 
                            state := idle;
                        end if;
                    when wt_pwron0 =>
                        if power_on_debaunced = '0' then
                            state := wt_pwron1;
                        end if;
                    when wt_pwron1 =>
                        if cnt = SEC_6_DEB then
                            state := idle;
                        end if;
                end case;
                -- state override using poweron_after26secs
                if poweron_after26secs then
                    state := idle;
                end if;
                
                -- output logic
                power_2_ios.RESET_OUT_FPGA <= '1';
                power_2_ios.SHUTDOWN_OUT_FPGA <= '1';
                power_2_ios.ESHUTDOWN_OUT_FPGA <= '1';
                turn_on_tcu <= '0';
                turn_off_tcu <= '0';
                keep_fans_on_10min <= '0';
                power_on_ok <= '0';
                during_power_down <= '0';
                case state is 
                    when idle =>
                        cnt := 0;
                        power_2_ios.EN_PFC_FB      <= '0';
                        power_2_ios.EN_PSU_1_FB    <= '0';
                        power_2_ios.EN_PSU_2_FB    <= '0';
                        power_2_ios.EN_PSU_5_FB    <= '0';
                        power_2_ios.EN_PSU_6_FB    <= '0';
                        power_2_ios.EN_PSU_7_FB    <= '0';
                        power_2_ios.EN_PSU_8_FB    <= '0';
                        power_2_ios.EN_PSU_9_FB    <= '0';
                        power_2_ios.EN_PSU_10_FB   <= '0';
                        relay_1p_on_request        <= '0';
                        power_2_ios.RELAY_3PH_FPGA <= '0';
                        fans_on <= '0';
                        turn_off_tcu <= '1';
                    when start_pwron => 
                        power_2_ios.EN_PFC_FB      <= '1';
                        fans_on <= '1';
                        cnt := 0;
                    when wt4_pg_buck =>
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when pwron_psus =>
                        power_2_ios.EN_PSU_1_FB    <= '1';
                        power_2_ios.EN_PSU_2_FB    <= '1';
                        power_2_ios.EN_PSU_5_FB    <= '1';
                        power_2_ios.EN_PSU_6_FB    <= '1';
                        power_2_ios.EN_PSU_7_FB    <= '1';
                        power_2_ios.EN_PSU_8_FB    <= '1';
                        power_2_ios.EN_PSU_9_FB    <= '1';
                        power_2_ios.EN_PSU_10_FB   <= '1';
                        relay_1p_on_request        <= '1';
                        power_2_ios.RELAY_3PH_FPGA <= '1';
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when wt4_all_on =>
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when e_shutdown =>
                        power_2_ios.ESHUTDOWN_OUT_FPGA <= '0';
                        power_2_ios.EN_PSU_1_FB <= '0';
                        power_2_ios.EN_PSU_9_FB <= '0';
                        relay_1p_on_request        <= '0';
                        power_2_ios.RELAY_3PH_FPGA <= '0';
                        cnt := 0;
                        all_in_range_s := all_in_range;
                        keep_fans_on_10min <= '1';
                        fans_on <= '0';
                    when e_shutdowning =>
                        power_2_ios.ESHUTDOWN_OUT_FPGA <= '0';
                        if cnt  = MSEC_10 then
                            power_2_ios.EN_PSU_2_FB <= '0';
                            power_2_ios.EN_PSU_6_FB <= '0';
                            power_2_ios.EN_PSU_8_FB <= '0';
                            power_2_ios.EN_PSU_10_FB <= '0';
                        end if;
                        if cnt = MSEC_20 then
                            power_2_ios.EN_PSU_7_FB <= '0';
                        end if;
                        if cnt = MSEC_50 then
                            power_2_ios.EN_PSU_5_FB <= '0';
                            power_2_ios.EN_PFC_FB   <= '0';
                        end if;
                        if cnt = MSEC_51 then
                            turn_off_tcu <= '1';
                        end if;
                        
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when e_shtdwn_wt_ok => 
                        if all_in_range = '0' then
                            cnt := 0;
                        elsif free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when power_on =>
                        power_on_ok <= '1';
                        cnt := 0;
                        turn_on_tcu <= '1';
                    when poweron_low =>
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when reset =>
                        power_2_ios.RESET_OUT_FPGA <= '0';
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when power_down =>
                        during_power_down <= '1';
                        if cnt < SEC_10 then
                            power_2_ios.SHUTDOWN_OUT_FPGA <= '0';
                        else
                            power_2_ios.EN_PFC_FB      <= '0';
                            fans_on <= '0';
                            keep_fans_on_10min <= '1';
                            power_2_ios.EN_PSU_1_FB    <= '0';
                            power_2_ios.EN_PSU_2_FB    <= '0';
                            power_2_ios.EN_PSU_5_FB    <= '0';
                            power_2_ios.EN_PSU_6_FB    <= '0';
                            power_2_ios.EN_PSU_7_FB    <= '0';
                            power_2_ios.EN_PSU_8_FB    <= '0';
                            power_2_ios.EN_PSU_9_FB    <= '0';
                            power_2_ios.EN_PSU_10_FB   <= '0';
                            relay_1p_on_request        <= '0';
                            power_2_ios.RELAY_3PH_FPGA <= '0';
                            turn_off_tcu <= '1';
                        end if;
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when wt_pwron0 =>
                        cnt := 0;
                    when wt_pwron1 =>
                        if power_on_debaunced = '0' then
                            cnt := 0;
                        elsif free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                end case;
                debug_state <= state;
            end if;
        end if;
    end process;
    
    poweron_debaunce_pr: process(clk)
        variable cnt : integer range 0 to MSEC_50 := 0;
    begin
        if rising_edge(clk) then
            if sync_rst then
                power_on_debaunced <= '0';
                cnt := 0;
            else
                if power_on_debaunced = registers(IO_IN)(IO_IN_POWERON_FPGA) then
                    cnt := 0;
                elsif cnt = MSEC_50 then
                    power_on_debaunced <= registers(IO_IN)(IO_IN_POWERON_FPGA);
                    cnt := 0;
                else
                    if free_running_1ms then
                         cnt := cnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    poweron_force_pr: process(clk)
        variable cnt: integer range 0 to SEC_26 := 0;
    begin
        if rising_edge(clk) then
            if sync_rst then
                poweron_after26secs <= '0';
                cnt := 0;
            else
                poweron_after26secs <= '0';
                if cnt = SEC_26 - MSEC_50 then
                    if power_on_debaunced = '1' then
                        poweron_after26secs <= '1';
                        cnt := 0;
                    end if;
                elsif power_on_debaunced = '0' then
                    if free_running_1ms then
                        cnt := cnt + 1;
                    end if;
                else
                    cnt := 0;
                end if;
            end if;
        end if;
    end process;
    
    -- TODO
    --process to take care of
    --power_2_ios.RELAY_1PH_FPGA
    --based on relay_1p_on_request
    --end process;
    -- for now naive implementation
    temperature_ok <= '1';
    input_ovp <= '0';--registers(IO_IN)(IO_IN_FAN_HALL1_FPGA);-- SIMULATING out of range
    output_ovp <= '0';
    relay_1p_pg <= '1';
    relay_3p_pg <= '1';
        
    zero_cross_pr: process(clk)
        
    begin
        if rising_edge(clk) then
            if sync_rst then
                power_2_ios.RELAY_1PH_FPGA <= '0';
            else
                if relay_1p_on_request = '0' then
                    power_2_ios.RELAY_1PH_FPGA <= '0';
                else
                    if zero_cross then
                        power_2_ios.RELAY_1PH_FPGA <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    all_in_ragne_pr: process(clk)
    begin
        if rising_edge(clk) then
            all_in_range <= not input_ovp and not uvp_error and not output_ovp;
        end if;
    end process;
    
    -- on off either from SM after edge detector + 1 ms delay
    -- or from command from UDP
    tcu_on_off_pr: process(clk)
        variable high_res_cnt: integer range 0 to HIGH_RES_1MSEC := 0;
        variable wait_for_on : std_logic;
        variable reg_ectcu, reg_cctcu : std_logic;
        variable on_tcu_s, off_tcu_s : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst then
                power_2_ios.ECTCU_INH_FPGA <= '0';
                power_2_ios.CCTCU_INH_FPGA <= '0';
                wait_for_on := '0';
                high_res_cnt := 0;
                reg_ectcu := '0';
                reg_cctcu := '0';
                on_tcu_s := '0';
                off_tcu_s := '0';
            else
                if turn_off_tcu = '1' and off_tcu_s = '0' then
                    wait_for_on := '0';
                    power_2_ios.ECTCU_INH_FPGA <= '0';
                    power_2_ios.CCTCU_INH_FPGA <= '0';
                elsif wait_for_on = '0' and turn_on_tcu = '1' and on_tcu_s = '0' then
                    wait_for_on := '1';
                    high_res_cnt := 0;
                elsif wait_for_on = '1' then
                    if high_res_cnt = HIGH_RES_1MSEC then
                        power_2_ios.ECTCU_INH_FPGA <= '1';
                        power_2_ios.CCTCU_INH_FPGA <= '1';
                        wait_for_on := '0';
                    elsif high_res_cnt < HIGH_RES_1MSEC then
                        high_res_cnt := high_res_cnt + 1;
                    end if;
                end if;
                on_tcu_s := turn_on_tcu;
                off_tcu_s := turn_off_tcu;
                
                -- command from UDP overrides the SM
                if reg_ectcu /= registers(GENERAL_CONTROL)(CONTROL_ECTCU_INH) then
                    power_2_ios.ECTCU_INH_FPGA <= registers(GENERAL_CONTROL)(CONTROL_ECTCU_INH);
                end if;
                if reg_cctcu /= registers(GENERAL_CONTROL)(CONTROL_CCTCU_INH) then
                    power_2_ios.CCTCU_INH_FPGA <= registers(GENERAL_CONTROL)(CONTROL_CCTCU_INH);
                end if;
                reg_ectcu := registers(GENERAL_CONTROL)(CONTROL_ECTCU_INH);
                reg_cctcu := registers(GENERAL_CONTROL)(CONTROL_CCTCU_INH);
            end if;
        end if;
    end process;
    
    all_i_good_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                all_inputs_good <= '0';
            else
                all_inputs_good <= '0';
                if registers(IO_IN)(IO_IN_PG_BUCK_FB  ) and fans_ok and
                               registers(IO_IN)(IO_IN_PG_PSU_1_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_2_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_5_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_6_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_7_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_8_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_9_FB ) and
                               registers(IO_IN)(IO_IN_PG_PSU_10_FB) and
                               relay_1p_pg and relay_3p_pg then
                    all_inputs_good <= '1';
                end if;                   
            end if;
        end if;
    end process;

    fans_en_pr: process(clk)
        variable keep_fans_on_10min_s : std_logic;
        variable cnt : integer range 0 to MIN_10 := 0;
    begin
        if rising_edge(clk) then
            if sync_rst then
                fans_en <= '0'; 
                keep_fans_on_10min_s := '0';     
                cnt := 0;  
                power_2_ios.FAN_EN1_FPGA <= '0';        
                power_2_ios.FAN_EN2_FPGA <= '0';        
                power_2_ios.FAN_EN3_FPGA <= '0';        
            else
                power_2_ios.FAN_EN1_FPGA <= fans_en;        
                power_2_ios.FAN_EN2_FPGA <= fans_en;        
                power_2_ios.FAN_EN3_FPGA <= fans_en;        
                fans_en <= fans_on;
                if cnt = MIN_10 then
                    cnt := 0;
                elsif cnt > 0 then
                    fans_en <= '1';
                    if free_running_1ms then
                        cnt := cnt + 1;
                    end if;
                end if;
                
                if not keep_fans_on_10min_s and keep_fans_on_10min then
                    cnt := 1;
                end if;
                
                keep_fans_on_10min_s := keep_fans_on_10min;
            end if;
        end if;
    end process;
    power_2_ios.SPARE_OUT_FPGA <= '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            PSU_Status <= (others => '0');
            PSU_Status(psu_status_Power_Out_Status)    <= power_on_ok;
            PSU_Status(psu_status_CC_TCU_Inhibit)      <= power_2_ios.CCTCU_INH_FPGA;
            PSU_Status(psu_status_EC_TCU_Inhibit)      <= power_2_ios.ECTCU_INH_FPGA;
            PSU_Status(psu_status_Reset)               <= not power_2_ios.RESET_OUT_FPGA;
            PSU_Status(psu_status_Shutdown)            <= not power_2_ios.SHUTDOWN_OUT_FPGA;
            PSU_Status(psu_status_Emergency_Shutdown)  <= not power_2_ios.ESHUTDOWN_OUT_FPGA;
            PSU_Status(psu_status_System_Off)          <= during_power_down;
            PSU_Status(psu_status_ON_OFF_Switch_State) <= power_on_debaunced;
        end if;
    end process;

    PSU_Status_mask <= (
        psu_status_Power_Out_Status    => '1',
        psu_status_CC_TCU_Inhibit      => '1',
        psu_status_EC_TCU_Inhibit      => '1',
        psu_status_Reset               => '1',
        psu_status_Shutdown            => '1',
        psu_status_Emergency_Shutdown  => '1',
        psu_status_System_Off          => '1',
        psu_status_ON_OFF_Switch_State => '1',
        others                         => '0'
    );
    
end architecture RTL;
