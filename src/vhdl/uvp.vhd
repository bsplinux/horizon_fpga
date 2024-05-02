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
        uvp_error        : out std_logic
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
                v := to_integer(unsigned(registers(VSNS_PH1)(VSNS_PH_V)));
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
                v := to_integer(unsigned(registers(VSNS_PH2)(VSNS_PH_V)));
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
                v := to_integer(unsigned(registers(VSNS_PH3)(VSNS_PH_V)));
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
            end if;
        end if;
    end process;
    
    dc_error <= '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            uvp_error <= p1_error or p2_error or p3_error or dc_error;
        end if;
    end process;
    
end architecture RTL;
