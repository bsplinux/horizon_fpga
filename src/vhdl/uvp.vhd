library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity uvp is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        uvp_error        : out std_logic;
        AC_IN_PH1_UV     : out std_logic;
        AC_IN_PH2_UV     : out std_logic;
        AC_IN_PH3_UV     : out std_logic;
        DC_IN_UV         : out std_logic
    );
end entity uvp;

architecture RTL of uvp is

    constant LIMIT_90  : integer := 900; --  90[V] /  0.1 [V/UNIT] =900 [UNITS]
    constant LIMIT_95  : integer := 950; --  95[V] /  0.1 [V/UNIT] = 950 [UNITS]
    constant LIMIT_17   : integer := 340 ; --   17[V] / 0.05 [V/UNIT] =  340 [UNITS]
    constant LIMIT_18   : integer := 360 ; --   18[V] / 0.05 [V/UNIT] =  360 [UNITS]

    constant MSEC_500 : integer :=  50_000_000;
    signal p1_error : std_logic;
    signal p2_error : std_logic;
    signal p3_error : std_logic;
    signal dc_error : std_logic;

    type integer_array_t is array(natural range <>) of integer;
    type signed16_array_t is array(natural range <>) of signed(15 downto 0);
    constant low_limits : integer_array_t(1 to 4)           := (LIMIT_90, LIMIT_90, LIMIT_90, LIMIT_17);
    constant high_limits: integer_array_t(low_limits'range) := (LIMIT_95, LIMIT_95, LIMIT_95, LIMIT_18);
    
    signal uvp_sig: std_logic_vector(low_limits'range);
    signal uvp_en: std_logic_vector(low_limits'range);
    signal inputs_vec : signed16_array_t (low_limits'range);
    type state_t is (idle, uvp_detect, uvp_err, uvp_imediate_err);

begin
    inputs_vec( 1) <= signed(registers(SPI_RMS_Vsns_PH1     )(SPI_RMS_Vsns_PH1_d));
    inputs_vec( 2) <= signed(registers(SPI_RMS_Vsns_PH2     )(SPI_RMS_Vsns_PH2_d));
    inputs_vec( 3) <= signed(registers(SPI_RMS_Vsns_PH3     )(SPI_RMS_Vsns_PH3_d));
    inputs_vec( 4) <= signed(registers(SPI_28V_IN_sns       )(SPI_28V_IN_sns_d  ));
    
    uvp_en( 1) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN);
    uvp_en( 2) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN);
    uvp_en( 3) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN);
    uvp_en( 4) <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN);
    
    ovp_gen: for i in low_limits'range generate
        signal uvp_bit : std_logic;
    begin
        uvp_pr: process(clk)
            variable state: state_t;
            variable cnt : integer range 0 to MSEC_500 + 1;
        begin
            if rising_edge(clk) then
                if sync_rst then
                    uvp_bit <= '0';    
                    state := idle;
                    cnt := 0;
                else
                    -- next state logic
                    case state is 
                        when idle =>
                            if inputs_vec(i) < low_limits(i) then
                                state := uvp_imediate_err;
                            elsif inputs_vec(i) < high_limits(i) then
                                state := uvp_detect;
                            end if;
                        when uvp_detect =>
                            if inputs_vec(i) < low_limits(i) then
                                state := uvp_imediate_err;
                            elsif inputs_vec(i) < high_limits(i) and cnt >= MSEC_500 then
                                state := uvp_err;
                            elsif inputs_vec(i) >= high_limits(i) then
                                state := idle;
                            end if;
                        when uvp_err =>
                            if inputs_vec(i) < low_limits(i) then
                                state := uvp_imediate_err;
                            elsif inputs_vec(i) >= high_limits(i) then
                                state := idle;
                            end if;
                        when uvp_imediate_err =>
                            if inputs_vec(i) >= high_limits(i) then
                                state := idle;
                            end if;
                    end case;
                    
                    -- ouput logic
                    uvp_bit <= '0';
                    case state is 
                        when idle =>
                            cnt := 0;
                        when uvp_detect =>
                            cnt := cnt + 1;
                        when uvp_err =>
                            uvp_bit <= '1';
                        when uvp_imediate_err =>
                            uvp_bit <= '1';
                    end case;
                    
                    if uvp_en(i) = '0' then
                        uvp_bit <= '0';
                    end if;
                end if;
            end if;
        end process;
        uvp_sig(i) <= uvp_bit;
    end generate ovp_gen;

    process(clk)
    begin
        if rising_edge(clk) then
            uvp_error <= and uvp_sig;
            
            AC_IN_PH1_UV <= uvp_sig(1);
            AC_IN_PH2_UV <= uvp_sig(2);
            AC_IN_PH3_UV <= uvp_sig(3);
            DC_IN_UV     <= uvp_sig(4);
        end if;
    end process;

end architecture RTL;
