library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity ovp is
    port(
        clk               : in  std_logic;
        sync_rst          : in  std_logic;
        registers         : in  reg_array_t;
        ovp_error         : out std_logic;
        ovp_Vsns_PH_A_RLY : out std_logic;
        ovp_Vsns_PH_B_RLY : out std_logic;
        ovp_Vsns_PH_C_RLY : out std_logic;
        ovp_Vsns_PH1      : out std_logic;
        ovp_Vsns_PH2      : out std_logic;
        ovp_Vsns_PH3      : out std_logic;
        ovp_OUT4_sns      : out std_logic;
        ovp_Vsns_28V_IN   : out std_logic;
        ovp_VOUT_1        : out std_logic;
        ovp_VOUT_2        : out std_logic;
        ovp_VOUT_5        : out std_logic;
        ovp_VOUT_6        : out std_logic;
        ovp_VOUT_7        : out std_logic;
        ovp_VOUT_8        : out std_logic;
        ovp_VOUT_9        : out std_logic;
        ovp_VOUT_10       : out std_logic
     );
end entity ovp;

architecture RTL of ovp is

    constant LIMIT_125  : integer := 1250; --  125[V] /  0.1 [V/UNIT] = 1250 [UNITS]
    constant LIMIT_32   : integer := 640 ; --   32[V] / 0.05 [V/UNIT] =  640 [UNITS]
    constant LIMIT_35   : integer := 700 ; --   35[V] / 0.05 [V/UNIT] =  700 [UNITS]
    constant LIMIT_45   : integer := 900 ; --   45[V] / 0.05 [V/UNIT] =  900 [UNITS]
    constant LIMIT_31_5 : integer := 630 ; -- 31.5[V] / 0.05 [V/UNIT] =  630 [UNITS]


    constant MSEC_5000: integer := 500_000_000;
    constant MSEC_100 : integer :=  10_000_000;
    constant MSEC_2   : integer :=     200_000;
    
    type integer_array_t is array(natural range <>) of integer;
    type signed16_array_t is array(natural range <>) of signed(15 downto 0);
    constant limits: integer_array_t(1 to 16) := (LIMIT_125, LIMIT_125, LIMIT_125, LIMIT_125, LIMIT_125, LIMIT_125, LIMIT_125, LIMIT_32, LIMIT_45, LIMIT_31_5, LIMIT_35, LIMIT_35, LIMIT_35, LIMIT_35, LIMIT_35, LIMIT_35);
    constant t_time: integer_array_t(limits'range) := (MSEC_100, MSEC_100, MSEC_100, MSEC_100, MSEC_100, MSEC_100, MSEC_100, MSEC_5000, MSEC_2, MSEC_2, MSEC_2, MSEC_2, MSEC_2, MSEC_2, MSEC_2, MSEC_2);
    
    signal ovp_sig: std_logic_vector(limits'range);
    signal ovp_en: std_logic_vector(limits'range);
    signal inputs_vec : signed16_array_t (limits'range);
    type state_t is (idle, ovp_detect, ovp_er);
begin

    inputs_vec( 1) <= signed(registers(SPI_RMS_Vsns_PH_A_RLY)(15 downto 0));
    inputs_vec( 2) <= signed(registers(SPI_RMS_Vsns_PH_B_RLY)(15 downto 0));
    inputs_vec( 3) <= signed(registers(SPI_RMS_Vsns_PH_C_RLY)(15 downto 0));
    inputs_vec( 4) <= signed(registers(SPI_RMS_Vsns_PH1     )(15 downto 0));
    inputs_vec( 5) <= signed(registers(SPI_RMS_Vsns_PH2     )(15 downto 0));
    inputs_vec( 6) <= signed(registers(SPI_RMS_Vsns_PH3     )(15 downto 0));
    inputs_vec( 7) <= signed(registers(SPI_RMS_OUT4_sns     )(15 downto 0));
    inputs_vec( 8) <= signed(registers(SPI_28V_IN_sns       )(15 downto 0));
    inputs_vec( 9) <= signed(registers(UART_V_OUT_1         )(15 downto 0));
    inputs_vec(10) <= signed(registers(UART_V_OUT_2         )(15 downto 0));
    inputs_vec(11) <= signed(registers(UART_V_OUT_5         )(15 downto 0));
    inputs_vec(12) <= signed(registers(UART_V_OUT_6         )(15 downto 0));
    inputs_vec(13) <= signed(registers(UART_V_OUT_7         )(15 downto 0));
    inputs_vec(14) <= signed(registers(UART_V_OUT_8         )(15 downto 0));
    inputs_vec(15) <= signed(registers(UART_V_OUT_9         )(15 downto 0));
    inputs_vec(16) <= signed(registers(UART_V_OUT_10        )(15 downto 0));
    
    ovp_en( 1) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 2) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 3) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 4) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 5) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 6) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 7) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 8) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_IN_EN);
    ovp_en( 9) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(10) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(11) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(12) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(13) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(14) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(15) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    ovp_en(16) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OVP_OUT_EN);
    
    
    ovp_gen: for i in limits'range generate
        signal ovp_bit : std_logic;
    begin
        ovp_pr: process(clk)
            variable state: state_t;
            variable cnt : integer range 0 to t_time(i) + 1;
        begin
            if rising_edge(clk) then
                if sync_rst then
                    ovp_bit <= '0';    
                    state := idle;
                    cnt := 0;
                else
                    -- next state logic
                    case state is 
                        when idle =>
                            if inputs_vec(i) > limits(i) then
                                state := ovp_detect;
                            end if;
                        when ovp_detect =>
                            if inputs_vec(i) <= limits(i) then
                                state := idle;
                            elsif cnt >= t_time(i) then
                                state := ovp_er;
                            end if;
                        when ovp_er =>
                            if inputs_vec(i) <= limits(i) then
                                state := idle;
                            end if;
                    end case;
                    
                    -- ouput logic
                    ovp_bit <= '0';
                    case state is 
                        when idle =>
                            cnt := 0;
                        when ovp_detect =>
                            cnt := cnt + 1;
                        when ovp_er =>
                            ovp_bit <= '1';
                    end case;
                    
                    if ovp_en(i) = '0' then
                        ovp_bit <= '0';
                    end if;
                end if;
            end if;
        end process;
        ovp_sig(i) <= ovp_bit;
    end generate ovp_gen;
    
    ovp_error <= and ovp_sig;
    ovp_Vsns_PH_A_RLY <= ovp_sig( 1);
    ovp_Vsns_PH_B_RLY <= ovp_sig( 2);
    ovp_Vsns_PH_C_RLY <= ovp_sig( 3);
    ovp_Vsns_PH1      <= ovp_sig( 4);
    ovp_Vsns_PH2      <= ovp_sig( 5);
    ovp_Vsns_PH3      <= ovp_sig( 6);
    ovp_OUT4_sns      <= ovp_sig( 7);
    ovp_Vsns_28V_IN   <= ovp_sig( 8);
    ovp_VOUT_1        <= ovp_sig( 9);
    ovp_VOUT_2        <= ovp_sig(10);
    ovp_VOUT_5        <= ovp_sig(11);
    ovp_VOUT_6        <= ovp_sig(12);
    ovp_VOUT_7        <= ovp_sig(13);
    ovp_VOUT_8        <= ovp_sig(14);
    ovp_VOUT_9        <= ovp_sig(15);
    ovp_VOUT_10       <= ovp_sig(16);
    
end architecture RTL;
