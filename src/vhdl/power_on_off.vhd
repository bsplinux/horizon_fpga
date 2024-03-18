library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
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
    type main_sm_t is (idle, start_pwron, wt4_pg_buck, pwron_psus, wt4_all_on, err_n_all_on, go2, go3, power_on, power_dwon, reset);    

begin
    
   main_sm_pr: process(clk)
       variable state : main_sm_t := idle;
       variable cnt : integer range 0 to 1000000 := 0;
       constant SEC_2_5 : integer := 2500 - 1; -- in miliseconds
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;            
                power_2_ios.EN_PFC_FB    <= '0';
                power_2_ios.FAN_EN1_FPGA <= '0';
                power_2_ios.FAN_EN2_FPGA <= '0';
                power_2_ios.FAN_EN3_FPGA <= '0';
                power_2_ios.EN_PSU_1_FB  <= '0';
                power_2_ios.EN_PSU_2_FB  <= '0';
                power_2_ios.EN_PSU_5_FB  <= '0';
                power_2_ios.EN_PSU_6_FB  <= '0';
                power_2_ios.EN_PSU_7_FB  <= '0';
                power_2_ios.EN_PSU_8_FB  <= '0';
                power_2_ios.EN_PSU_9_FB  <= '0';
                power_2_ios.EN_PSU_10_FB <= '0';
                cnt := 0;
            else
                -- next state logic
                case state is 
                    when idle =>
                        -- TODO we may need to wait 6 sec for input to be stable
                        if registers(IO_IN)(IO_IN_POWERON_FPGA) then
                            state := start_pwron;
                        end if;
                    when start_pwron =>
                        state := wt4_pg_buck;
                    when wt4_pg_buck =>
                        if registers(IO_IN)(IO_IN_PG_BUCK_FB) then
                            state := pwron_psus;
                        end if;
                    when pwron_psus =>
                        state := wt4_all_on;
                    when wt4_all_on =>
                        if registers(IO_IN)(IO_IN_PG_PSU_1_FB) = '1' and registers(IO_IN)(IO_IN_PG_PSU_2_FB) = '1' and
                           registers(IO_IN)(IO_IN_PG_PSU_5_FB) = '1' and registers(IO_IN)(IO_IN_PG_PSU_6_FB) = '1' and
                           registers(IO_IN)(IO_IN_PG_PSU_7_FB) = '1' and registers(IO_IN)(IO_IN_PG_PSU_8_FB) = '1' and
                           registers(IO_IN)(IO_IN_PG_PSU_9_FB) = '1' and registers(IO_IN)(IO_IN_PG_PSU_10_FB) = '1' --and
                           -- relays should be on as well outputs 3 and 4
                           then
                           
                           state := power_on;
                        elsif cnt = SEC_2_5 then
                            state := err_n_all_on;
                        end if;
                        if free_running_1ms then
                            cnt := cnt + 1;
                        end if;
                    when err_n_all_on =>
                        state := idle;
                    when go2 =>
                        null;
                    when go3 =>
                        null;
                    when power_on =>
                        null;
                    when power_dwon =>
                        null;
                    when reset =>
                        null;
                end case;
                
                -- output logic
                case state is 
                    when idle =>
                        cnt := 0;
                        power_2_ios.EN_PFC_FB    <= '0';
                        power_2_ios.FAN_EN1_FPGA <= '0';
                        power_2_ios.FAN_EN2_FPGA <= '0';
                        power_2_ios.FAN_EN3_FPGA <= '0';
                        power_2_ios.EN_PSU_1_FB  <= '0';
                        power_2_ios.EN_PSU_2_FB  <= '0';
                        power_2_ios.EN_PSU_5_FB  <= '0';
                        power_2_ios.EN_PSU_6_FB  <= '0';
                        power_2_ios.EN_PSU_7_FB  <= '0';
                        power_2_ios.EN_PSU_8_FB  <= '0';
                        power_2_ios.EN_PSU_9_FB  <= '0';
                        power_2_ios.EN_PSU_10_FB <= '0';
                    when start_pwron => 
                        power_2_ios.EN_PFC_FB    <= '1';
                        power_2_ios.FAN_EN1_FPGA <= '1';
                        power_2_ios.FAN_EN2_FPGA <= '1';
                        power_2_ios.FAN_EN3_FPGA <= '1';
                    when wt4_pg_buck =>
                        null;
                    when pwron_psus =>
                        power_2_ios.EN_PSU_1_FB  <= '1';
                        power_2_ios.EN_PSU_2_FB  <= '1';
                        power_2_ios.EN_PSU_5_FB  <= '1';
                        power_2_ios.EN_PSU_6_FB  <= '1';
                        power_2_ios.EN_PSU_7_FB  <= '1';
                        power_2_ios.EN_PSU_8_FB  <= '1';
                        power_2_ios.EN_PSU_9_FB  <= '1';
                        power_2_ios.EN_PSU_10_FB <= '1';
                    when wt4_all_on =>
                        null;
                    when err_n_all_on =>
                        null;
                    when go2 =>
                        null;
                    when go3 =>
                        null;
                    when power_on =>
                        null;
                    when power_dwon =>
                        null;
                    when reset =>
                        null;
                end case;
            end if;
        end if;
    end process;

end architecture RTL;
