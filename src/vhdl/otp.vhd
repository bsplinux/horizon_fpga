library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity otp is
    port(
        clk       : in  std_logic;
        sync_rst  : in  std_logic;
        registers : in  reg_array_t;
        otp_error : out std_logic;
        otp_t1    : out std_logic;
        otp_t2    : out std_logic;
        otp_t3    : out std_logic;
        otp_t4    : out std_logic;
        otp_t5    : out std_logic;
        otp_t6    : out std_logic;
        otp_t7    : out std_logic;
        otp_t8    : out std_logic;
        otp_t9    : out std_logic
     );
end entity otp;

architecture RTL of otp is

    constant LIMIT_110  : integer := 110; 
    constant LIMIT_90   : integer := 90; 
    constant LIMIT_100  : integer := 100; 
    constant LIMIT_80   : integer := 80; 

    type integer_array_t is array(natural range <>) of integer;
    type signed8_array_t is array(natural range <>) of signed(7 downto 0);
    constant limits_h: integer_array_t(1 to 9)         := (LIMIT_110, LIMIT_110, LIMIT_110, LIMIT_100, LIMIT_110, LIMIT_110, LIMIT_110, LIMIT_110, LIMIT_110);
    constant limits_l: integer_array_t(limits_h'range) := ( LIMIT_90,  LIMIT_90,  LIMIT_90,  LIMIT_80,  LIMIT_90,  LIMIT_90,  LIMIT_90,  LIMIT_90,  LIMIT_90);
    
    signal otp_sig: std_logic_vector(limits_l'range);
    signal otp_en: std_logic_vector(limits_l'range);
    signal inputs_vec : signed8_array_t (limits_l'range);
    type state_t is (idle, otp_detect);
begin

    inputs_vec( 1) <= signed(registers(UART_T1)(UART_T1_T));
    inputs_vec( 2) <= signed(registers(UART_T2)(UART_T2_T));
    inputs_vec( 3) <= signed(registers(UART_T3)(UART_T3_T));
    inputs_vec( 4) <= signed(registers(UART_T4)(UART_T4_T));
    inputs_vec( 5) <= signed(registers(UART_T5)(UART_T5_T));
    inputs_vec( 6) <= signed(registers(UART_T6)(UART_T6_T));
    inputs_vec( 7) <= signed(registers(UART_T7)(UART_T7_T));
    inputs_vec( 8) <= signed(registers(UART_T8)(UART_T8_T));
    inputs_vec( 9) <= signed(registers(UART_T9)(UART_T9_T));
    
    otp_en( 1) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 2) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 3) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 4) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 5) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 6) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 7) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 8) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    otp_en( 9) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_OTP_EN);
    
    
    ovp_gen: for i in limits_l'range generate
        signal otp_bit : std_logic;
    begin
        ovp_pr: process(clk)
            variable state: state_t;
        begin
            if rising_edge(clk) then
                if sync_rst then
                    otp_bit <= '0';    
                    state := idle;
                else
                    -- next state logic
                    case state is 
                        when idle =>
                            if inputs_vec(i) > limits_h(i) then
                                state := otp_detect;
                            end if;
                        when otp_detect =>
                            if inputs_vec(i) < limits_l(i) then
                                state := idle;
                            end if;
                    end case;
                    
                    -- ouput logic
                    otp_bit <= '0';
                    case state is 
                        when idle =>
                            null;
                        when otp_detect =>
                            otp_bit <= '1';
                    end case;
                    
                    if otp_en(i) = '0' then
                        otp_bit <= '0';
                    end if;
                end if;
            end if;
        end process;
        otp_sig(i) <= otp_bit;
    end generate ovp_gen;
    
    otp_error <= and otp_sig;
    otp_t1 <= otp_sig( 1);
    otp_t2 <= otp_sig( 2);
    otp_t3 <= otp_sig( 3);
    otp_t4 <= otp_sig( 4);
    otp_t5 <= otp_sig( 5);
    otp_t6 <= otp_sig( 6);
    otp_t7 <= otp_sig( 7);
    otp_t8 <= otp_sig( 8);
    otp_t9 <= otp_sig( 9);
    
end architecture RTL;
