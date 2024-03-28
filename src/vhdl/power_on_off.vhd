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
        free_running_1ms : in  std_logic
    );
end entity power_on_off;

architecture RTL of power_on_off is
    -- for simulation all next constants are set to 1, for synthesis each with its real value
    -- note that for simulation the 1ms tick is actually 1us
    constant MSEC_5    : integer := set_const(1,5,sim_on);
    constant MSEC_10   : integer := set_const(1,10,sim_on); -- in miliseconds
    constant MSEC_20   : integer := set_const(2,20,sim_on); -- in miliseconds
    constant MSEC_50   : integer := set_const(5,50,sim_on); -- in miliseconds
    constant MSEC_51   : integer := set_const(6,51,sim_on); -- in miliseconds
    constant SEC_2_5   : integer := set_const(2,2500,sim_on); -- in miliseconds
    constant SEC_6_DEB : integer := set_const(6,6000 - MSEC_50,sim_on); -- 6 sec minus the debauns value
    constant SEC_10    : integer := set_const(1,10000,sim_on);
    constant SEC_20    : integer := set_const(2,20000,sim_on);
    type main_sm_t is (idle, start_pwron, wt4_pg_buck, pwron_psus, wt4_all_on, err_n_all_on, e_shutdown, power_on, poweron_low, reset, power_down, wt_pwron0);    
    signal debug_state : main_sm_t;
    signal power_on_debaunced : std_logic;
    signal relay_1p_on_request : std_logic;
    signal relay_1p_pg : std_logic;
    signal relay_3p_pg : std_logic;
    signal all_fans_on : std_logic; -- TODO drive this from somewere
    signal all_inputs_good : std_logic; -- TODO drive this from somewere  
    signal keep_fans_on : std_logic; -- from main sm to fans control can be active althugh state could be idle or others. 
begin
    
   main_sm_pr: process(clk)
       variable state : main_sm_t := idle;
       variable cnt : integer range 0 to SEC_20 := 0;
       constant HIGH_RES_1MSEC: integer := 100_000; -- conting 10 ns a clock
       variable high_res_cnt: integer range 0 to HIGH_RES_1MSEC := 0;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;   
                debug_state <= idle;         
                power_2_ios.EN_PFC_FB          <= '0';
                power_2_ios.FAN_EN1_FPGA       <= '0';
                power_2_ios.FAN_EN2_FPGA       <= '0';
                power_2_ios.FAN_EN3_FPGA       <= '0';
                power_2_ios.EN_PSU_1_FB        <= '0';
                power_2_ios.EN_PSU_2_FB        <= '0';
                power_2_ios.EN_PSU_5_FB        <= '0';
                power_2_ios.EN_PSU_6_FB        <= '0';
                power_2_ios.EN_PSU_7_FB        <= '0';
                power_2_ios.EN_PSU_8_FB        <= '0';
                power_2_ios.EN_PSU_9_FB        <= '0';
                power_2_ios.EN_PSU_10_FB       <= '0';
                power_2_ios.RESET_OUT_FPGA     <= '1';
                power_2_ios.SHUTDOWN_OUT_FPGA  <= '0';
                power_2_ios.ECTCU_INH_FPGA     <= '0';
                power_2_ios.CCTCU_INH_FPGA     <= '0';
                relay_1p_on_request            <= '0';
                power_2_ios.RELAY_3PH_FPGA     <= '0';
                power_2_ios.ESHUTDOWN_OUT_FPGA <= '0';
                cnt := 0;
                high_res_cnt := 0;
            else
                -- next state logic
                case state is 
                    when idle =>
                        -- TODO we may need to wait 6 sec for input to be stable
                        if power_on_debaunced then
                            state := start_pwron;
                        end if;
                    when start_pwron =>
                        state := wt4_pg_buck;
                    when wt4_pg_buck =>
                        if registers(IO_IN)(IO_IN_PG_BUCK_FB) and all_fans_on then
                            state := pwron_psus;
                        end if;
                    when pwron_psus =>
                        state := wt4_all_on;
                    when wt4_all_on =>
                        if all_inputs_good then
                           state := power_on;
                        elsif cnt = SEC_2_5 then
                            state := err_n_all_on;
                        end if;
                    when err_n_all_on =>
                        if power_on_debaunced = '0' then
                            state := idle;
                        end if;
                    when e_shutdown =>
                        null;
                    when power_on =>
                        if all_inputs_good = '0' then
                            state := e_shutdown;
                        elsif power_on_debaunced = '0' then
                            state := poweron_low;
                        end if;
                    when poweron_low =>
                        if power_on_debaunced = '1' and cnt < SEC_6_DEB then
                            state := reset;
                            cnt := 0;
                        elsif cnt > SEC_6_DEB then
                            state := power_down;
                            cnt := 0;
                        end if;
                    when reset =>
                        if cnt = MSEC_5 then 
                            state := power_on;
                        end if;
                    when power_down =>
                        -- todo fix this it must wait for  before idle 
                        if cnt = SEC_20 then 
                            if power_on_debaunced = '0' then
                                state := idle;
                            else
                                state := wt_pwron0;
                            end if;
                        end if;
                    when wt_pwron0 =>
                        if power_on_debaunced = '0' then
                            state := idle;
                        end if;
                end case;
                
                -- output logic
                power_2_ios.RESET_OUT_FPGA <= '1';
                power_2_ios.SHUTDOWN_OUT_FPGA <= '1';
                case state is 
                    when idle =>
                        cnt := 0;
                        high_res_cnt := 0;
                        power_2_ios.EN_PFC_FB      <= '0';
                        power_2_ios.FAN_EN1_FPGA   <= '0';
                        power_2_ios.FAN_EN2_FPGA   <= '0';
                        power_2_ios.FAN_EN3_FPGA   <= '0';
                        power_2_ios.EN_PSU_1_FB    <= '0';
                        power_2_ios.EN_PSU_2_FB    <= '0';
                        power_2_ios.EN_PSU_5_FB    <= '0';
                        power_2_ios.EN_PSU_6_FB    <= '0';
                        power_2_ios.EN_PSU_7_FB    <= '0';
                        power_2_ios.EN_PSU_8_FB    <= '0';
                        power_2_ios.EN_PSU_9_FB    <= '0';
                        power_2_ios.EN_PSU_10_FB   <= '0';
                        power_2_ios.ECTCU_INH_FPGA <= '0';
                        power_2_ios.CCTCU_INH_FPGA <= '0';
                        relay_1p_on_request        <= '0';
                        power_2_ios.RELAY_3PH_FPGA <= '0';
                    when start_pwron => 
                        power_2_ios.EN_PFC_FB      <= '1';
                        power_2_ios.FAN_EN1_FPGA   <= '1';
                        power_2_ios.FAN_EN2_FPGA   <= '1';
                        power_2_ios.FAN_EN3_FPGA   <= '1';
                    when wt4_pg_buck =>
                        null;
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
                    when wt4_all_on =>
                        high_res_cnt := 0;
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when err_n_all_on =>
                        power_2_ios.EN_PFC_FB      <= '0';
                        power_2_ios.FAN_EN1_FPGA   <= '0';
                        power_2_ios.FAN_EN2_FPGA   <= '0';
                        power_2_ios.FAN_EN3_FPGA   <= '0';
                        power_2_ios.EN_PSU_1_FB    <= '0';
                        power_2_ios.EN_PSU_2_FB    <= '0';
                        power_2_ios.EN_PSU_5_FB    <= '0';
                        power_2_ios.EN_PSU_6_FB    <= '0';
                        power_2_ios.EN_PSU_7_FB    <= '0';
                        power_2_ios.EN_PSU_8_FB    <= '0';
                        power_2_ios.EN_PSU_9_FB    <= '0';
                        power_2_ios.EN_PSU_10_FB   <= '0';
                        power_2_ios.ECTCU_INH_FPGA <= '0';
                        power_2_ios.CCTCU_INH_FPGA <= '0';
                        relay_1p_on_request        <= '0';
                        power_2_ios.RELAY_3PH_FPGA <= '0';
                    when e_shutdown =>
                        power_2_ios.ESHUTDOWN_OUT_FPGA <= '1';
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when power_on =>
                        -- TODO report to log as well
                        cnt := 0;
                        if high_res_cnt = HIGH_RES_1MSEC then
                            power_2_ios.ECTCU_INH_FPGA <= '1';
                            power_2_ios.CCTCU_INH_FPGA <= '1';
                        end if;
                        if high_res_cnt < HIGH_RES_1MSEC then
                            high_res_cnt := high_res_cnt + 1;
                        end if;
                    when poweron_low =>
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when reset =>
                        power_2_ios.RESET_OUT_FPGA <= '0';
                        -- TODO report to log as well
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when power_down =>
                        power_2_ios.SHUTDOWN_OUT_FPGA <= '0';
                        if cnt > SEC_10 then
                            power_2_ios.EN_PSU_1_FB    <= '0';
                            power_2_ios.EN_PSU_2_FB    <= '0';
                            power_2_ios.EN_PSU_5_FB    <= '0';
                            power_2_ios.EN_PSU_6_FB    <= '0';
                            power_2_ios.EN_PSU_7_FB    <= '0';
                            power_2_ios.EN_PSU_8_FB    <= '0';
                            power_2_ios.EN_PSU_9_FB    <= '0';
                            power_2_ios.EN_PSU_10_FB   <= '0';
                            power_2_ios.ECTCU_INH_FPGA <= '0';
                            power_2_ios.CCTCU_INH_FPGA <= '0';
                            relay_1p_on_request        <= '0';
                            power_2_ios.RELAY_3PH_FPGA <= '0';
                        end if;
                        -- TODO report to log as well
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when wt_pwron0 =>
                        null;
                end case;
                debug_state <= state;
            end if;
        end if;
    end process;
    
    process(clk)
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
    
    -- TODO
    --process to take care of
    --power_2_ios.RELAY_1PH_FPGA
    --based on relay_1p_on_request
    --end process;

end architecture RTL;
