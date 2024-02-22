library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity update_log is
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        registers        : in  reg_array_t;
        regs_updating    : in  reg_slv_array_t;
        regs_reading     : in  reg_slv_array_t;
        internal_regs    : out reg_array_t;
        internal_regs_we : out reg_slv_array_t;
        ps_intr          : out std_logic;
        log_regs         : in  log_reg_array_t;
        ios_2_app        : in  ios_2_app_t;
        app_2_ios        : out app_2_ios_t
    );
end entity update_log;

architecture RTL of update_log is
    signal ms_pulse : std_logic;
    signal regs_locked : std_logic;
    signal regs_released : std_logic;
    --signal update_log : std_logic;
begin
    update_log_regs_pr: process(all)
    begin
        internal_regs_we <= (others => '1');
        internal_regs <= (others => X"00000000");
        
        internal_regs_we(GENERAL_STATUS) <= '1';
        internal_regs(GENERAL_STATUS)(STATUS_REGS_LOCKED) <= regs_locked;
        
        for i in log_regs_range loop
            internal_regs_we(i) <= not regs_locked;
            internal_regs(i) <= log_regs(i);
        end loop;
        
    end process;
    
    log_update_pr: process(clk)
        --variable regs_locked_s : std_logic; 
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                regs_locked <= '0';
                regs_released <= '0';
                --regs_locked_s := '0';
                --update_log <= '0';
            else
                regs_released <= '0';
                --update_log <= '0';
                if regs_reading(LOG_MESSAGE_ID) then
                    regs_locked <= '1';
                elsif regs_reading(LOG_LAMP_IND) = '1' or
                      (registers(GENERAL_CONTROL)(CONTROL_RLEASE_REGS) = '1' and regs_updating(GENERAL_CONTROL) = '1') then
                    regs_locked <= '0';
                end if;
                --if regs_locked = '0' and regs_locked_s = '1' then
                --    update_log <= '1';
                --end if;
                
                --regs_locked_s := regs_locked;
            end if;
        end if;
    end process;
            
    ms_intr_pr: process(clk)
        constant CLKS_IN_US : integer := 100;
        constant CLKS_IN_MS : integer := CLKS_IN_US * 1000;
        variable ms_cnt : integer range 0 to CLKS_IN_MS := 1;
        variable pulse_cnt : integer range 0 to 16 := 1;
        variable ms_tick : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                ms_cnt := 1;
                pulse_cnt := 0;
                ms_tick := '0';
                ms_pulse <= '0';
                ps_intr <= '0';
            else
                ms_tick := '0';
                ms_pulse <= '0';
                ps_intr <= '0';
                ms_cnt := ms_cnt - 1;
                if ms_cnt = 0 then
                    ms_cnt := CLKS_IN_MS;
                    ms_tick := '1';
                end if;
                
                if ms_tick = '1' then
                    pulse_cnt := 16;
                end if;
                if pulse_cnt > 0 then
                    pulse_cnt := pulse_cnt - 1;
                    ms_pulse <= '1';
                end if;
                if registers(GENERAL_CONTROL)(CONTROL_EN_1MS_INTR) = '1' then
                    ps_intr <= ms_pulse;
                end if;
            end if;
        end if;
    end process;
    

end architecture RTL;
