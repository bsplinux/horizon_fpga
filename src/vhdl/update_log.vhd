library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
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
        ps_intr          : out std_logic_vector(PS_INTR_range);
        log_regs         : in  log_reg_array_t;
        stop_log         : in  std_logic;
        stop_log_to_cpu  : out std_logic;
        free_running_1ms : out std_logic
    );
end entity update_log;

architecture RTL of update_log is
    signal ms_pulse : std_logic;
    signal regs_locked : std_logic;
    signal intr_ms, intr_stop_log : std_logic;
    signal psu_status_sticky : std_logic_vector(PSU_Status_range);
    signal psu_status : std_logic_vector(PSU_Status_range);
begin
    update_log_regs_pr: process(all)
    begin
        internal_regs_we <= (others => '1');
        internal_regs <= (others => X"00000000");
        
        internal_regs_we(GENERAL_STATUS) <= '1';
        internal_regs(GENERAL_STATUS)(GENERAL_STATUS_REGS_LOCKED) <= regs_locked;
        
        for i in log_regs_range loop
            internal_regs_we(i) <= not regs_locked;
            internal_regs(i) <= log_regs(i);
        end loop;
        -- following 4 lines override the asignment at previous loop for the psu_status;
        internal_regs_we(LOG_PSU_STATUS_L) <= '1';
        internal_regs_we(LOG_PSU_STATUS_H) <= '1';
        internal_regs(LOG_PSU_STATUS_L) <= psu_status_sticky(31 downto 0);
        internal_regs(LOG_PSU_STATUS_H) <= psu_status_sticky(63 downto 32);
        
    end process;
    
    psu_status <= log_regs(LOG_PSU_STATUS_H) & log_regs(LOG_PSU_STATUS_L);
    
    psu_status_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst then
                psu_status_sticky <= (others => '0');
            else
                psu_status_sticky <= psu_status_sticky or psu_status;
                if regs_reading(LOG_PSU_STATUS_L) then
                    psu_status_sticky(31 downto 0) <= psu_status(31 downto 0);
                end if;
                if regs_reading(LOG_PSU_STATUS_H) then
                    psu_status_sticky(63 downto 32) <= psu_status(63 downto 32);
                end if;
            end if;
        end if;
    end process;
    
    log_update_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                regs_locked <= '0';
            else
                if regs_reading(LOG_VDC_IN) then
                    regs_locked <= '1';
                elsif regs_reading(LOG_LAMP_IND) = '1' or
                      (registers(GENERAL_CONTROL)(GENERAL_CONTROL_RLEASE_REGS) = '1' and regs_updating(GENERAL_CONTROL) = '1') then
                    regs_locked <= '0';
                end if;
            end if;
        end if;
    end process;
            
    ms_intr_pr: process(clk)
        constant CLKS_IN_US : integer := 100;
        constant CLKS_IN_MS : integer := set_const(10,CLKS_IN_US * 1000,sim_on);-- 10 clocks for simulation using 100 khz clock and 1,000,000 clocks 1ms for real world using 100MHz clock
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
                intr_ms <= '0';
                free_running_1ms <= '0';
            else
                ms_tick := '0';
                ms_pulse <= '0';
                intr_ms <= '0';
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
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_EN_1MS_INTR) = '1' then
                    intr_ms <= ms_pulse;
                end if;
                free_running_1ms <= ms_tick;
            end if;
        end if;
    end process;
    
    stop_log_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                stop_log_to_cpu <= '0';
                intr_stop_log <= '0';
            else
                intr_stop_log <= '0';
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_STOP_LOG_ACK) = '1' and regs_updating(GENERAL_CONTROL) = '1' then
                    stop_log_to_cpu <= '0';
                elsif stop_log = '1' then
                    intr_stop_log <= '1';
                    stop_log_to_cpu <= '1';
                end if;
            end if;
        end if;
    end process;
    
    process (all)
    begin
        ps_intr <= (others => '0');
        ps_intr(PS_INTR_MS)       <= intr_ms;
        ps_intr(PS_INTR_STOP_LOG) <= intr_stop_log;
    end process;
    
end architecture RTL;
