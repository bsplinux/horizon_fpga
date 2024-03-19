library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

--Library UNISIM;
--use UNISIM.vcomponents.all;

entity app is
    generic(HLS_EN : boolean);
    port(
        clk              : in  std_logic;
        sync_rst         : in  std_logic;
        sw_reset         : out std_logic;
        registers        : in  reg_array_t;
        regs_updating    : in  reg_slv_array_t;
        regs_reading     : in  reg_slv_array_t;
        internal_regs    : out reg_array_t;
        internal_regs_we : out reg_slv_array_t;
        ios_2_app        : in  ios_2_app_t;
        app_2_ios        : out app_2_ios_t;
        ps_intr          : out std_logic_vector(PS_INTR_range);
        HLS_to_BD        : out HLS_axim_to_interconnect_t;
        BD_to_HLS        : in  HLS_axim_from_interconnect_t
        
    );
end entity app;

architecture RTL of app is
    signal timer                       : std_logic_vector(63 downto 0) := (others => '0');
    signal internal_regs_update_log    : reg_array_t;
    signal internal_regs_we_update_log : reg_slv_array_t;
    signal internal_regs_rs485         : reg_array_t;
    signal internal_regs_we_rs485      : reg_slv_array_t;
    signal internal_regs_ios           : reg_array_t;
    signal internal_regs_we_ios        : reg_slv_array_t;
    signal internal_regs_power         : reg_array_t;
    signal internal_regs_we_power      : reg_slv_array_t;
    signal log_regs                    : log_reg_array_t;
    signal ETI                         : std_logic_vector(31 downto 0);
    signal SN                          : std_logic_vector(7 downto 0);
    signal fan_pwm                     : std_logic_vector(1 to 3);
    signal free_running_1ms            : std_logic;
    signal stop_log_to_cpu             : std_logic;
    signal stop_log                    : std_logic;
    signal log_ps_intr                 : std_logic_vector(PS_INTR_range);
    signal power_2_ios                 : power_2_ios_t;
    signal de                          : std_logic_vector(8 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                internal_regs    <= (others => X"00000000");
                internal_regs_we <= (others => '0');
            else

                internal_regs    <= (others => X"00000000");
                internal_regs_we <= (others => '0');

                -- general status
                internal_regs_we(GENERAL_STATUS) <= '1';
                internal_regs(GENERAL_STATUS)(STATUS_REGS_LOCKED) <= internal_regs_update_log(GENERAL_STATUS)(STATUS_REGS_LOCKED);
                internal_regs(GENERAL_STATUS)(STATUS_STOP_LOG)    <= stop_log_to_cpu;
                -- timestamp
                internal_regs_we(TIMESTAMP_L) <= '1';
                internal_regs(TIMESTAMP_L)    <= timer(31 downto 0);
                internal_regs_we(TIMESTAMP_H) <= '1';
                internal_regs(TIMESTAMP_H)    <= timer(63 downto 32);
                
                internal_regs_we(IO_IN) <= internal_regs_we_ios(IO_IN);
                internal_regs(IO_IN) <= internal_regs_ios(IO_IN);
                
                for i in log_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_update_log(i);
                    internal_regs(i) <= internal_regs_update_log(i);
                end loop;
                    
                for i in rs485_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_rs485(i);
                    internal_regs(i) <= internal_regs_rs485(i);
                end loop;
                    
            end if;
        end if;
    end process;

    timer_pr : process(clk)
    begin
        if rising_edge(clk) then
            timer <= timer + 1;
        end if;
    end process;
    
    sw_rst_pr : process(clk)
        variable sw_rst_save : std_logic;
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                sw_reset    <= '0';
                sw_rst_save := '0';
            else
                sw_reset    <= registers(GENERAL_CONTROL)(CONTROL_SW_RESET) and not sw_rst_save;
                sw_rst_save := registers(GENERAL_CONTROL)(CONTROL_SW_RESET);
            end if;
        end if;
    end process;
    
    
    update_log_i: entity work.update_log
        port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        regs_updating    => regs_updating,
        regs_reading     => regs_reading,
        internal_regs    => internal_regs_update_log,
        internal_regs_we => internal_regs_we_update_log,
        ps_intr          => log_ps_intr,
        log_regs         => log_regs,
        stop_log         => stop_log, -- TODO connect this to the actual condition that requests to stop log
        stop_log_to_cpu  => stop_log_to_cpu,
        free_running_1ms => free_running_1ms
    );
    ps_intr(PS_INTR_MS)       <= log_ps_intr(PS_INTR_MS)      ;
    ps_intr(PS_INTR_STOP_LOG) <= log_ps_intr(PS_INTR_STOP_LOG);
    
    ----------------------
    -- misc fields -------
    ----------------------
    
    -- ETI (counting hours)
        -- the cpu is in charge of updating ETI in flash but reset ETI comes from registers
    -- SN (serial no.)
    process(clk)
    begin
        if rising_edge(clk) then
            ps_intr(PS_INTR_UPDATE_FLASH) <= '0';
            
            if registers(SN_ETI)(SN_ETI_RESET_ETI) = '1' and regs_updating(SN_ETI) = '1' then
                ETI <= (others => '0');
                ps_intr(PS_INTR_UPDATE_FLASH) <= '1'; 
            else
                ETI <= registers(LOG_ETM);
            end if;
            if registers(SN_ETI)(SN_ETI_SET_SN) = '1' and regs_updating(SN_ETI) = '1' then
                SN <= registers(SN_ETI)(SN'range);
                ps_intr(PS_INTR_UPDATE_FLASH) <= '1'; 
            else
                SN <= registers(LOG_SN)(SN'range);
            end if;
        end if;
    end process;

    process(all)
    begin
        log_regs <= (others => X"00000000");
        log_regs(LOG_ETM) <= ETI;
        log_regs(LOG_SN)(SN'range) <= SN;
    end process;
    
    --FANs
    fans_i: entity work.fans
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        fan_pwm   => fan_pwm
    );
    
    -- rs485
    rs485_i: entity work.rs485_if
    generic map(HLS_EN => HLS_EN)
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        regs_updating    => regs_updating,
        --regs_reading     => regs_reading,
        internal_regs    => internal_regs_rs485,
        internal_regs_we => internal_regs_we_rs485,
        HLS_to_BD        => HLS_to_BD,
        BD_to_HLS        => BD_to_HLS,
        one_ms_interrupt => free_running_1ms,
        de               => de
    );
    
    ios_i: entity work.app_ios
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        regs_updating    => regs_updating,
        regs_reading     => regs_reading,
        internal_regs    => internal_regs_ios,
        internal_regs_we => internal_regs_we_ios,
        ios_2_app        => ios_2_app,
        app_2_ios        => app_2_ios,
        power_2_ios      => power_2_ios,
        fan_pwm          => fan_pwm,
        de               => de
    );
    
    power_i: entity work.power_on_off
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        regs_updating    => regs_updating,
        regs_reading     => regs_reading,
        internal_regs    => internal_regs_power,
        internal_regs_we => internal_regs_we_power,
        power_2_ios      => power_2_ios,
        free_running_1ms => free_running_1ms
    );
    
end architecture RTL;
