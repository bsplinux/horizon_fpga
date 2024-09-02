library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity logic_status is
    port(
        clk               : in  std_logic;
        sync_rst          : in  std_logic;
        registers         : in  reg_array_t;
        --regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        --internal_regs    : out reg_array_t;
        --internal_regs_we : out reg_slv_array_t;
        P_IN_STATUS_FPGA  : out std_logic;
        P_OUT_STATUS_FPGA : out std_logic;
        stat_115_ac_in    : out std_logic;
        stat_28_dc_in     : out std_logic;
        stat_115_ac_out   : out std_logic;
        stat_dc1_out      : out std_logic;
        stat_dc2_out      : out std_logic;
        stat_dc5_out      : out std_logic;
        stat_dc6_out      : out std_logic;
        stat_dc7_out      : out std_logic;
        stat_dc8_out      : out std_logic;
        stat_dc9_out      : out std_logic;
        stat_dc10_out     : out std_logic;
        PSU_Status        : out std_logic_vector(PSU_Status_range);
        PSU_Status_mask   : out std_logic_vector(PSU_Status_range)
    );
end entity logic_status;

architecture RTL of logic_status is

begin
    
    process(clk) 
    begin
        if rising_edge(clk) then
            if sync_rst then
                stat_115_ac_in   <= '0';
                stat_28_dc_in    <= '0';
                stat_115_ac_out  <= '0';
                stat_dc1_out  <= '0';
                stat_dc2_out  <= '0';
                stat_dc5_out  <= '0';
                stat_dc6_out  <= '0';
                stat_dc7_out  <= '0';
                stat_dc8_out  <= '0';
                stat_dc9_out  <= '0';
                stat_dc10_out <= '0';
                P_IN_STATUS_FPGA <= '0';
                P_OUT_STATUS_FPGA <= '0';
            else
                stat_115_ac_in   <= '0';
                stat_28_dc_in    <= '0';
                stat_115_ac_out  <= '0';
                stat_dc1_out  <= '0';
                stat_dc2_out  <= '0';
                stat_dc5_out  <= '0';
                stat_dc6_out  <= '0';
                stat_dc7_out  <= '0';
                stat_dc8_out  <= '0';
                stat_dc9_out  <= '0';
                stat_dc10_out <= '0';

                if ((unsigned(registers(VSNS_PH1)(VSNS_PH1_PH_V)) > 108) and (unsigned(registers(VSNS_PH1)(VSNS_PH1_PH_V)) < 118)) and
                   ((unsigned(registers(VSNS_PH2)(VSNS_PH2_PH_V)) > 108) and (unsigned(registers(VSNS_PH2)(VSNS_PH2_PH_V)) < 118)) and
                   ((unsigned(registers(VSNS_PH3)(VSNS_PH3_PH_V)) > 108) and (unsigned(registers(VSNS_PH3)(VSNS_PH3_PH_V)) < 118))  then
                   stat_115_ac_in   <= '1';
                end if;
                
                --28 dc_in waiting for limits factor 22-30 volts
                
                -- 115 v ac waiting for method to sample
                
                -- dc1 34.92v - 37.08v => 2494-2648 digital value
                
                -- dc2 30.0425v - 30.9575v => 1057-1090 digital value
                
                -- dc5 27.16v - 28.84v => 1940-2060 digital value

                -- dc6 27.16v - 28.84v => 1940-2060 digital value
                
                -- dc7 27.16v - 28.84v => 1940-2060 digital value
                
                -- dc8 27.16v - 28.84v => 1058-1090 digital value
                
                -- dc9 27.16v - 28.84v => 1940-2060 digital value
                
                -- dc10 27.16v - 28.84v => 1940-2060 digital value
                
                P_IN_STATUS_FPGA <= stat_115_ac_in and stat_28_dc_in;
                P_OUT_STATUS_FPGA <= stat_115_ac_out and stat_dc1_out and stat_dc2_out and stat_dc5_out and 
                                    stat_dc6_out and stat_dc7_out and stat_dc8_out and stat_dc9_out and stat_dc10_out;
            end if;
        end if;
    end process;
    
end architecture RTL;
