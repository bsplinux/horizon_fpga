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
        stat_115_a_in     : out std_logic;
        stat_115_b_in     : out std_logic;
        stat_115_c_in     : out std_logic;
        stat_28_dc_in     : out std_logic;
        stat_115_ac_out   : out std_logic;
        stat_115_a_out    : out std_logic;
        stat_115_b_out    : out std_logic;
        stat_115_c_out    : out std_logic;
        stat_v_out4_out   : out std_logic;
        stat_dc1_out      : out std_logic;
        stat_dc2_out      : out std_logic;
        stat_dc5_out      : out std_logic;
        stat_dc6_out      : out std_logic;
        stat_dc7_out      : out std_logic;
        stat_dc8_out      : out std_logic;
        stat_dc9_out      : out std_logic;
        stat_dc10_out     : out std_logic
    );
end entity logic_status;

architecture RTL of logic_status is
    signal v115_in_a, v115_in_b, v115_in_c, v28_in : signed(15 downto 0);
    signal v115_out_a, v115_out_b, v115_out_c, v_out4 : signed(15 downto 0);
    signal dcdc1, dcdc2, dcdc5, dcdc6, dcdc7, dcdc8, dcdc9, dcdc10 : signed(15 downto 0);
    
    constant LIMIT_118 : integer := 1180; -- 118[V] / 0.1 [V/UNIT] = 1180 [UNITS]
    constant LIMIT_108 : integer := 1080; -- 108[V] / 0.1 [V/UNIT] = 1080 [UNITS]
    constant LIMIT_22  : integer := 440 ; -- 22[V] / 0.05 [V/UNIT] = 440 [UNITS]
    constant LIMIT_30  : integer := 600 ; -- 30[V] / 0.05 [V/UNIT] = 440 [UNITS]
    constant LIMIT_34  : integer := 698 ; -- 34.92[V] / 0.05 [V/UNIT] = 698.4 [UNITS]
    constant LIMIT_37  : integer := 742 ; -- 37.08[V] / 0.05 [V/UNIT] = 741.6 [UNITS]
    constant LIMIT_30_4: integer := 601 ; -- 30.0425[V] / 0.05 [V/UNIT] = 600.85 [UNITS]
    constant LIMIT_31  : integer := 619 ; -- 30.9575[V] / 0.05 [V/UNIT] = 619.15 [UNITS]
    constant LIMIT_27  : integer := 543 ; -- 27.16[V] / 0.05 [V/UNIT] = 543.2 [UNITS]
    constant LIMIT_28  : integer := 577 ; -- 28.84[V] / 0.05 [V/UNIT] = 576.8 [UNITS]
begin
    v115_in_a  <= signed(registers(SPI_RMS_Vsns_PH1     )(15 downto 0));
    v115_in_b  <= signed(registers(SPI_RMS_Vsns_PH2     )(15 downto 0));
    v115_in_c  <= signed(registers(SPI_RMS_Vsns_PH3     )(15 downto 0));
    v28_in     <= signed(registers(SPI_RMS_28V_IN_sns   )(15 downto 0));
    v115_out_a <= signed(registers(SPI_RMS_Vsns_PH_A_RLY)(15 downto 0));
    v115_out_b <= signed(registers(SPI_RMS_Vsns_PH_A_RLY)(15 downto 0));
    v115_out_c <= signed(registers(SPI_RMS_Vsns_PH_A_RLY)(15 downto 0));
    v_out4     <= signed(registers(SPI_RMS_OUT4_sns     )(15 downto 0));
    dcdc1      <= signed(registers(UART_V_OUT_1         )(15 downto 0));
    dcdc2      <= signed(registers(UART_V_OUT_2         )(15 downto 0));
    dcdc5      <= signed(registers(UART_V_OUT_5         )(15 downto 0));
    dcdc6      <= signed(registers(UART_V_OUT_6         )(15 downto 0));
    dcdc7      <= signed(registers(UART_V_OUT_7         )(15 downto 0));
    dcdc8      <= signed(registers(UART_V_OUT_8         )(15 downto 0));
    dcdc9      <= signed(registers(UART_V_OUT_9         )(15 downto 0));
    dcdc10     <= signed(registers(UART_V_OUT_10        )(15 downto 0));
    
    process(clk) 
    begin
        if rising_edge(clk) then
            if sync_rst then
                stat_115_ac_in  <= '0';
                stat_115_a_in   <= '0';
                stat_115_b_in   <= '0';
                stat_115_c_in   <= '0';
                stat_28_dc_in   <= '0';
                stat_115_ac_out <= '0';
                stat_115_a_out  <= '0';
                stat_115_b_out  <= '0';
                stat_115_c_out  <= '0';
                stat_v_out4_out <= '0';
                stat_dc1_out    <= '0';
                stat_dc2_out    <= '0';
                stat_dc5_out    <= '0';
                stat_dc6_out    <= '0';
                stat_dc7_out    <= '0';
                stat_dc8_out    <= '0';
                stat_dc9_out    <= '0';
                stat_dc10_out   <= '0';
                P_IN_STATUS_FPGA  <= '0';
                P_OUT_STATUS_FPGA <= '0';
            else
                stat_115_a_in    <= '1';
                stat_115_b_in    <= '1';
                stat_115_c_in    <= '1';
                stat_28_dc_in    <= '1';
                
                stat_115_a_out  <= '1';
                stat_115_b_out  <= '1';
                stat_115_c_out  <= '1';
                stat_v_out4_out <= '1';
                
                stat_dc1_out  <= '1';
                stat_dc2_out  <= '1';
                stat_dc5_out  <= '1';
                stat_dc6_out  <= '1';
                stat_dc7_out  <= '1';
                stat_dc8_out  <= '1';
                stat_dc9_out  <= '1';
                stat_dc10_out <= '1';

                stat_115_ac_in <= stat_115_a_in and stat_115_b_in and stat_115_c_in;
                
                if (v115_in_a > LIMIT_118) or (v115_in_a < LIMIT_108) then
                    stat_115_a_in <= '0';
                end if;
                if (v115_in_b > LIMIT_118) or (v115_in_b < LIMIT_108) then
                    stat_115_b_in <= '0';
                end if;
                if (v115_in_c > LIMIT_118) or (v115_in_c < LIMIT_108) then
                    stat_115_c_in <= '0';
                end if;
                
                if (v28_in > LIMIT_30) or (v28_in < LIMIT_22) then
                    stat_28_dc_in <= '0';
                end if;
                
                stat_115_ac_out <= stat_115_a_out and stat_115_b_out and stat_115_c_out;
                if (v115_out_a > LIMIT_118) or (v115_out_a < LIMIT_108) then
                    stat_115_a_out <= '0';
                end if;
                if (v115_out_b > LIMIT_118) or (v115_out_b < LIMIT_108) then
                    stat_115_b_out <= '0';
                end if;
                if (v115_out_c > LIMIT_118) or (v115_out_c < LIMIT_108) then
                    stat_115_c_out <= '0';
                end if;

                if (v_out4 > LIMIT_118) or (v_out4 < LIMIT_108) then
                    stat_v_out4_out <= '0';
                end if;
                
                if (dcdc1 > LIMIT_37) or (dcdc1 < LIMIT_34) then
                    stat_dc1_out <= '0';
                end if;
                
                if (dcdc2 > LIMIT_31) or (dcdc2 < LIMIT_30_4) then
                    stat_dc2_out <= '0';
                end if;
                
                if (dcdc5 > LIMIT_28) or (dcdc5 < LIMIT_27) then
                    stat_dc5_out <= '0';
                end if;
                
                if (dcdc6 > LIMIT_28) or (dcdc6 < LIMIT_27) then
                    stat_dc6_out <= '0';
                end if;
                
                if (dcdc7 > LIMIT_28) or (dcdc7 < LIMIT_27) then
                    stat_dc7_out <= '0';
                end if;
                
                if (dcdc8 > LIMIT_28) or (dcdc8 < LIMIT_27) then
                    stat_dc8_out <= '0';
                end if;
                
                if (dcdc9 > LIMIT_28) or (dcdc9 < LIMIT_27) then
                    stat_dc9_out <= '0';
                end if;
                
                if (dcdc10 > LIMIT_28) or (dcdc10 < LIMIT_27) then
                    stat_dc10_out <= '0';
                end if;
                
                P_IN_STATUS_FPGA <= stat_115_ac_in and stat_28_dc_in;
                P_OUT_STATUS_FPGA <= stat_115_ac_out and stat_v_out4_out and stat_dc1_out and stat_dc2_out and stat_dc5_out and 
                                    stat_dc6_out and stat_dc7_out and stat_dc8_out and stat_dc9_out and stat_dc10_out;
            end if;
        end if;
    end process;
    
end architecture RTL;
