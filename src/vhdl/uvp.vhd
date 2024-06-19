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
        --regs_updating    : in  reg_slv_array_t;
        --regs_reading     : in  reg_slv_array_t;
        --internal_regs    : out reg_array_t;
        --internal_regs_we : out reg_slv_array_t;
        uvp_error        : out std_logic;
        PSU_Status       : out std_logic_vector(PSU_Status_range);
        PSU_Status_mask  : out std_logic_vector(PSU_Status_range)
    );
end entity uvp;

architecture RTL of uvp is

    type uvp_sm is (idle, wt_1sec_ok, stable, warrning, error);
    constant MSEC_1000: integer := 100_000_000;
    constant MSEC_500 : integer :=  50_000_000;
    signal p1_error : std_logic;
    signal p2_error : std_logic;
    signal p3_error : std_logic;
    signal dc_error : std_logic;
begin

    uvp_115_p1_sm_pr: process(clk)
        variable state : uvp_sm;
        variable v : integer range 0 to 2**12 - 1;
        variable cnt : integer range 0 to MSEC_1000;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
                v := 0;
                cnt := 0;
                p1_error <= '1';
            else
                v := 0; --FIXME to_integer(unsigned(registers(VSNS_PH1)(VSNS_PH1_PH_V)));
                -- next state logic
                case state is 
                    when idle =>
                        if v >= 95 then
                            state := wt_1sec_ok;
                        end if;
                    when wt_1sec_ok =>
                        if v < 95 then
                            state := idle;
                        elsif cnt >= MSEC_1000 then
                            state := stable;
                        end if;
                    when stable =>
                        if v < 90 then
                            state := error;
                        elsif v < 95 then
                            state := warrning;
                        end if;
                    when warrning =>
                        if v < 90 then
                            state := error;
                        elsif v >= 95 then
                            state := stable;
                        elsif cnt >= MSEC_500 then
                            state := error;
                        end if;
                    when error =>
                        state := idle;
                end case;
                
                -- output logic
                p1_error <= '1';
                case state is 
                    when idle =>
                        cnt := 0;
                    when wt_1sec_ok =>
                        cnt := cnt + 1;
                    when stable =>
                        p1_error <= '0';
                        cnt := 0;
                    when warrning =>
                        p1_error <= '0';
                        cnt := cnt + 1;
                    when error =>
                        cnt := 0;
                end case;
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN_PH1) = '0' then
                    p1_error <= '0';
                end if;
            end if;
        end if;
    end process;
    
    uvp_115_p2_sm_pr: process(clk)
        variable state : uvp_sm;
        variable v : integer range 0 to 2**12 - 1;
        variable cnt : integer range 0 to MSEC_1000;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
                v := 0;
                cnt := 0;
                p2_error <= '1';
            else
                v := 0; -- FIXME to_integer(unsigned(registers(VSNS_PH2)(VSNS_PH2_PH_V)));
                -- next state logic
                case state is 
                    when idle =>
                        if v >= 95 then
                            state := wt_1sec_ok;
                        end if;
                    when wt_1sec_ok =>
                        if v < 95 then
                            state := idle;
                        elsif cnt >= MSEC_1000 then
                            state := stable;
                        end if;
                    when stable =>
                        if v < 90 then
                            state := error;
                        elsif v < 95 then
                            state := warrning;
                        end if;
                    when warrning =>
                        if v < 90 then
                            state := error;
                        elsif v >= 95 then
                            state := stable;
                        elsif cnt >= MSEC_500 then
                            state := error;
                        end if;
                    when error =>
                        state := idle;
                end case;
                
                -- output logic
                p2_error <= '1';
                case state is 
                    when idle =>
                        cnt := 0;
                    when wt_1sec_ok =>
                        cnt := cnt + 1;
                    when stable =>
                        p2_error <= '0';
                        cnt := 0;
                    when warrning =>
                        p2_error <= '0';
                        cnt := cnt + 1;
                    when error =>
                        cnt := 0;
                end case;
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN_PH2) = '0' then
                    p2_error <= '0';
                end if;
            end if;
        end if;
    end process;
    
    uvp_115_p3_sm_pr: process(clk)
        variable state : uvp_sm;
        variable v : integer range 0 to 2**12 - 1;
        variable cnt : integer range 0 to MSEC_1000;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
                v := 0;
                cnt := 0;
                p3_error <= '1';
            else
                v := 0; -- FIXME to_integer(unsigned(registers(VSNS_PH3)(VSNS_PH3_PH_V)));
                -- next state logic
                case state is 
                    when idle =>
                        if v >= 95 then
                            state := wt_1sec_ok;
                        end if;
                    when wt_1sec_ok =>
                        if v < 95 then
                            state := idle;
                        elsif cnt >= MSEC_1000 then
                            state := stable;
                        end if;
                    when stable =>
                        if v < 90 then
                            state := error;
                        elsif v < 95 then
                            state := warrning;
                        end if;
                    when warrning =>
                        if v < 90 then
                            state := error;
                        elsif v >= 95 then
                            state := stable;
                        elsif cnt >= MSEC_500 then
                            state := error;
                        end if;
                    when error =>
                        state := idle;
                end case;
                
                -- output logic
                p3_error <= '1';
                case state is 
                    when idle =>
                        cnt := 0;
                    when wt_1sec_ok =>
                        cnt := cnt + 1;
                    when stable =>
                        p3_error <= '0';
                        cnt := 0;
                    when warrning =>
                        p3_error <= '0';
                        cnt := cnt + 1;
                    when error =>
                        cnt := 0;
                end case;
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN_PH3) = '0' then
                    p3_error <= '0';
                end if;
            end if;
        end if;
    end process;
    
    uvp_28dc_sm_pr: process(clk)
        variable state : uvp_sm;
        variable v : integer range 0 to 2**12 - 1;
        variable v_sig : std_logic_vector(11 downto 0);
        variable cnt : integer range 0 to MSEC_1000;
    begin
        if rising_edge(clk) then
            if sync_rst then
                state := idle;
                v := 0;
                cnt := 0;
                dc_error <= '1';
            else
                v_sig := registers(UART_RAW0_L)(15 downto 12) & registers(UART_RAW0_L)(23 downto 16); -- input voltage of DCDC1
                v  := to_integer(unsigned(v_sig));
                -- next state logic
                case state is 
                    when idle =>
                        if v >= 18 then
                            state := wt_1sec_ok;
                        end if;
                    when wt_1sec_ok =>
                        if v < 18 then
                            state := idle;
                        elsif cnt >= MSEC_1000 then
                            state := stable;
                        end if;
                    when stable =>
                        if v < 17 then
                            state := error;
                        elsif v < 18 then
                            state := warrning;
                        end if;
                    when warrning =>
                        if v < 17 then
                            state := error;
                        elsif v >= 18 then
                            state := stable;
                        elsif cnt >= MSEC_500 then
                            state := error;
                        end if;
                    when error =>
                        state := idle;
                end case;
                
                -- output logic
                dc_error <= '1';
                case state is 
                    when idle =>
                        cnt := 0;
                    when wt_1sec_ok =>
                        cnt := cnt + 1;
                    when stable =>
                        dc_error <= '0';
                        cnt := 0;
                    when warrning =>
                        dc_error <= '0';
                        cnt := cnt + 1;
                    when error =>
                        cnt := 0;
                end case;
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_UVP_EN_DC) = '0' then
                    dc_error <= '0';
                end if;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            uvp_error <= p1_error or p2_error or p3_error or dc_error;
            
            PSU_Status <= (others => '0');
            PSU_Status(psu_status_AC_IN_PH1_UV) <= p1_error;
            PSU_Status(psu_status_AC_IN_PH2_UV) <= p2_error;
            PSU_Status(psu_status_AC_IN_PH3_UV) <= p3_error;
            PSU_Status(psu_status_DC_IN_UV)     <= dc_error;
        end if;
    end process;

    PSU_Status_mask <= (
        psu_status_AC_IN_PH1_UV => '1',
        psu_status_AC_IN_PH2_UV => '1',
        psu_status_AC_IN_PH3_UV => '1',
        psu_status_DC_IN_UV     => '1',
        others                  => '0'
    );
    
end architecture RTL;
