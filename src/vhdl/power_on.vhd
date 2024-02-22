library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity power_on is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        regs_updating    : in  reg_slv_array_t;
        regs_reading     : in  reg_slv_array_t;
        internal_regs    : out reg_array_t;
        internal_regs_we : out reg_slv_array_t;
        ps_intr          : out std_logic;
        app_2_ios        : out app_2_ios_t
    );
end entity power_on;

architecture RTL of power_on is
    type state_t is (idle, start_power_on, wt_buck, wt4all, power_ok, down_stage1, down_stage_2);
begin
    sm_pr: process(clk)
        variable state : state_t := idle;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
            else
                -- next state logic
                case state is 
                    when idle =>
                        if registers(IO_IN)(IO_IN_POWERON_FPGA) = '1' then
                            state := start_power_on;
                        end if;
                    when start_power_on =>
                        null;
                    when wt_buck =>
                        null;
                    when wt4all =>
                        null;
                    when power_ok =>
                        null;
                    when down_stage1 =>
                        null;
                    when down_stage_2 =>
                        null;
                end case;
                
                -- output logic

                case state is 
                    when idle =>
                        null;
                    when start_power_on =>
                        null;
                    when wt_buck =>
                        null;
                    when wt4all =>
                        null;
                    when power_ok =>
                        null;
                    when down_stage1 =>
                        null;
                    when down_stage_2 =>
                        null;
                end case;
                
            end if;
        end if;
    end process;
    
end architecture RTL;
