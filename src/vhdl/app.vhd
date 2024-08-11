library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

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
        HLS_to_BD        : out HLS_axim_to_interconnect_array_t(1 downto 0);
        BD_to_HLS        : in  HLS_axim_from_interconnect_array_t(1 downto 0);
        one_ms_tick      : out std_logic
        
    );
end entity app;

architecture RTL of app is
    signal timer                       : std_logic_vector(63 downto 0) := (others => '0');
    signal internal_regs_update_log    : reg_array_t;
    signal internal_regs_we_update_log : reg_slv_array_t;
    signal internal_regs_rs485         : reg_array_t;
    signal internal_regs_we_rs485      : reg_slv_array_t;
    signal internal_regs_spis          : reg_array_t;
    signal internal_regs_we_spis       : reg_slv_array_t;
    signal internal_regs_ios           : reg_array_t;
    signal internal_regs_we_ios        : reg_slv_array_t;
    signal internal_regs_power         : reg_array_t;
    signal internal_regs_we_power      : reg_slv_array_t;
    signal log_regs                    : log_reg_array_t;
    signal log_regs_uart               : log_reg_array_t;
    signal log_regs_spi                : log_reg_array_t;
    signal ETI                         : std_logic_vector(31 downto 0);
    signal SN                          : std_logic_vector(7 downto 0);
    signal fan_pwm                     : std_logic_vector(1 to 3);
    signal free_running_1ms            : std_logic;
    signal stop_log_to_cpu             : std_logic;
    signal stop_log                    : std_logic;
    signal log_ps_intr                 : std_logic_vector(PS_INTR_range);
    signal power_2_ios                 : power_2_ios_t;
    signal de                          : std_logic_vector(8 downto 0);
    signal fans_en, fans_ok            : std_logic;
    signal zero_cross                  : std_logic;
    signal uvp_error                   : std_logic;
    signal lamp_stat                   : std_logic;
    signal PSU_status                  : std_logic_vector(PSU_Status_range);
    signal PSU_status_uvp              : std_logic_vector(PSU_Status_range);
    signal PSU_status_uvp_mask         : std_logic_vector(PSU_Status_range);
    signal PSU_status_pwr_on           : std_logic_vector(PSU_Status_range);
    signal PSU_status_pwr_on_mask      : std_logic_vector(PSU_Status_range);
    signal lamp_temp                   : std_logic;
begin
    one_ms_tick <= free_running_1ms;
    
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
                internal_regs(GENERAL_STATUS)(GENERAL_STATUS_REGS_LOCKED) <= internal_regs_update_log(GENERAL_STATUS)(GENERAL_STATUS_REGS_LOCKED);
                internal_regs(GENERAL_STATUS)(GENERAL_STATUS_STOP_LOG)    <= stop_log_to_cpu;
                -- timestamp
                internal_regs_we(TIMESTAMP_L) <= '1';
                internal_regs(TIMESTAMP_L)    <= timer(31 downto 0);
                internal_regs_we(TIMESTAMP_H) <= '1';
                internal_regs(TIMESTAMP_H)    <= timer(63 downto 32);
                
                internal_regs_we(IO_IN) <= internal_regs_we_ios(IO_IN);
                internal_regs(IO_IN) <= internal_regs_ios(IO_IN);
                
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_IO_DEBUG_EN) = '0' then
                    internal_regs_we(IO_OUT0) <= '1';
                    internal_regs_we(IO_OUT1) <= '1';
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_EN1_FPGA      ) <= app_2_IOs.FAN_EN1_FPGA      ; 
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_CTRL1_FPGA    ) <= app_2_IOs.FAN_CTRL1_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_P_IN_STATUS_FPGA  ) <= app_2_IOs.P_IN_STATUS_FPGA  ; 
                    internal_regs(IO_OUT0)(IO_OUT0_POD_STATUS_FPGA   ) <= app_2_IOs.POD_STATUS_FPGA   ; 
                    internal_regs(IO_OUT0)(IO_OUT0_ECTCU_INH_FPGA    ) <= app_2_IOs.ECTCU_INH_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_P_OUT_STATUS_FPGA ) <= app_2_IOs.P_OUT_STATUS_FPGA ; 
                    internal_regs(IO_OUT0)(IO_OUT0_CCTCU_INH_FPGA    ) <= app_2_IOs.CCTCU_INH_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_SHUTDOWN_OUT_FPGA ) <= app_2_IOs.SHUTDOWN_OUT_FPGA ; 
                    internal_regs(IO_OUT0)(IO_OUT0_RESET_OUT_FPGA    ) <= app_2_IOs.RESET_OUT_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_SPARE_OUT_FPGA    ) <= app_2_IOs.SPARE_OUT_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_ESHUTDOWN_OUT_FPGA) <= app_2_IOs.ESHUTDOWN_OUT_FPGA; 
                    internal_regs(IO_OUT0)(IO_OUT0_RELAY_1PH_FPGA    ) <= app_2_IOs.RELAY_1PH_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_RELAY_3PH_FPGA    ) <= app_2_IOs.RELAY_3PH_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_EN3_FPGA      ) <= app_2_IOs.FAN_EN3_FPGA      ; 
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_CTRL3_FPGA    ) <= app_2_IOs.FAN_CTRL3_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_EN2_FPGA      ) <= app_2_IOs.FAN_EN2_FPGA      ; 
                    internal_regs(IO_OUT0)(IO_OUT0_FAN_CTRL2_FPGA    ) <= app_2_IOs.FAN_CTRL2_FPGA    ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PFC_FB         ) <= app_2_IOs.EN_PFC_FB         ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_1_FB       ) <= app_2_IOs.EN_PSU_1_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_2_FB       ) <= app_2_IOs.EN_PSU_2_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_5_FB       ) <= app_2_IOs.EN_PSU_5_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_6_FB       ) <= app_2_IOs.EN_PSU_6_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_7_FB       ) <= app_2_IOs.EN_PSU_7_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_8_FB       ) <= app_2_IOs.EN_PSU_8_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_9_FB       ) <= app_2_IOs.EN_PSU_9_FB       ; 
                    internal_regs(IO_OUT0)(IO_OUT0_EN_PSU_10_FB      ) <= app_2_IOs.EN_PSU_10_FB      ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_7        ) <= app_2_IOs.RS485_DE_7        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_8        ) <= app_2_IOs.RS485_DE_8        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_9        ) <= app_2_IOs.RS485_DE_9        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_1        ) <= app_2_IOs.RS485_DE_1        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_2        ) <= app_2_IOs.RS485_DE_2        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_3        ) <= app_2_IOs.RS485_DE_3        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_4        ) <= app_2_IOs.RS485_DE_4        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_5        ) <= app_2_IOs.RS485_DE_5        ; 
                    internal_regs(IO_OUT1)(IO_OUT1_RS485_DE_6        ) <= app_2_IOs.RS485_DE_6        ;            
                end if;
                
                for i in log_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_update_log(i);
                    internal_regs(i) <= internal_regs_update_log(i);
                end loop;
                    
                for i in rs485_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_rs485(i);
                    internal_regs(i) <= internal_regs_rs485(i);
                end loop;
                    
                for i in spi_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_spis(i);
                    internal_regs(i) <= internal_regs_spis(i);
                end loop;

            end if;
        end if;
    end process;

    PSU_status <=  (PSU_status_uvp and PSU_status_uvp_mask) or
                   (PSU_status_pwr_on and PSU_status_pwr_on_mask);   
    
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
                sw_reset    <= registers(GENERAL_CONTROL)(GENERAL_CONTROL_SW_RESET) and not sw_rst_save;
                sw_rst_save := registers(GENERAL_CONTROL)(GENERAL_CONTROL_SW_RESET);
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
        stop_log         => stop_log,
        stop_log_to_cpu  => stop_log_to_cpu,
        free_running_1ms => free_running_1ms
    );
    ps_intr(PS_INTR_MS)       <= log_ps_intr(PS_INTR_MS)      ;
    ps_intr(PS_INTR_STOP_LOG) <= log_ps_intr(PS_INTR_STOP_LOG);
    stop_log <= '0';  -- TODO connect this to the actual condition that requests to stop log
    
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

    process(clk)
    begin
        if rising_edge(clk) then
            log_regs <= (others => X"00000000");
            
            log_regs(LOG_ETM) <= ETI;
            log_regs(LOG_SN)(SN'range) <= SN;
            
            log_regs(LOG_V_OUT_1 ) <= log_regs_uart(LOG_V_OUT_1 );
            log_regs(LOG_V_OUT_2 ) <= log_regs_uart(LOG_V_OUT_2 );
            log_regs(LOG_V_OUT_5 ) <= log_regs_uart(LOG_V_OUT_5 );
            log_regs(LOG_V_OUT_6 ) <= log_regs_uart(LOG_V_OUT_6 );
            log_regs(LOG_V_OUT_7 ) <= log_regs_uart(LOG_V_OUT_7 );
            log_regs(LOG_V_OUT_8 ) <= log_regs_uart(LOG_V_OUT_8 );
            log_regs(LOG_V_OUT_9 ) <= log_regs_uart(LOG_V_OUT_9 );
            log_regs(LOG_V_OUT_10) <= log_regs_uart(LOG_V_OUT_10);
            log_regs(LOG_I_OUT_1 ) <= log_regs_uart(LOG_I_OUT_1 );
            log_regs(LOG_I_OUT_2 ) <= log_regs_uart(LOG_I_OUT_2 );
            log_regs(LOG_I_OUT_5 ) <= log_regs_uart(LOG_I_OUT_5 );
            log_regs(LOG_I_OUT_6 ) <= log_regs_uart(LOG_I_OUT_6 );
            log_regs(LOG_I_OUT_7 ) <= log_regs_uart(LOG_I_OUT_7 );
            log_regs(LOG_I_OUT_8 ) <= log_regs_uart(LOG_I_OUT_8 );
            log_regs(LOG_I_OUT_9 ) <= log_regs_uart(LOG_I_OUT_9 );
            log_regs(LOG_I_OUT_10) <= log_regs_uart(LOG_I_OUT_10);
            log_regs(LOG_T1      ) <= log_regs_uart(LOG_T1      );
            log_regs(LOG_T2      ) <= log_regs_uart(LOG_T2      );
            log_regs(LOG_T3      ) <= log_regs_uart(LOG_T3      );
            log_regs(LOG_T4      ) <= log_regs_uart(LOG_T4      );
            log_regs(LOG_T5      ) <= log_regs_uart(LOG_T5      );
            log_regs(LOG_T6      ) <= log_regs_uart(LOG_T6      );
            log_regs(LOG_T7      ) <= log_regs_uart(LOG_T7      );
            log_regs(LOG_T8      ) <= log_regs_uart(LOG_T8      );
            log_regs(LOG_T9      ) <= log_regs_uart(LOG_T9      );       

            log_regs(LOG_I_OUT_4     ) <= log_regs_spi(LOG_I_OUT_4     );     
            log_regs(LOG_I_DC_IN     ) <= log_regs_spi(LOG_I_DC_IN     );     
            log_regs(LOG_I_AC_IN_PH_A) <= log_regs_spi(LOG_I_AC_IN_PH_A);     
            log_regs(LOG_I_AC_IN_PH_B) <= log_regs_spi(LOG_I_AC_IN_PH_B);     
            log_regs(LOG_I_AC_IN_PH_C) <= log_regs_spi(LOG_I_AC_IN_PH_C);     
            log_regs(LOG_V_OUT_4     ) <= log_regs_spi(LOG_V_OUT_4     );     
            log_regs(LOG_VAC_IN_PH_A ) <= log_regs_spi(LOG_VAC_IN_PH_A );     
            log_regs(LOG_VAC_IN_PH_B ) <= log_regs_spi(LOG_VAC_IN_PH_B );     
            log_regs(LOG_VAC_IN_PH_C ) <= log_regs_spi(LOG_VAC_IN_PH_C );     
            log_regs(LOG_V_OUT_3_ph3 ) <= log_regs_spi(LOG_V_OUT_3_ph3 );     
            log_regs(LOG_V_OUT_3_ph2 ) <= log_regs_spi(LOG_V_OUT_3_ph2 );     
            log_regs(LOG_V_OUT_3_ph1 ) <= log_regs_spi(LOG_V_OUT_3_ph1 );     
            log_regs(LOG_AC_POWER    ) <= log_regs_spi(LOG_AC_POWER    );     
            log_regs(LOG_I_OUT_3_ph1 ) <= log_regs_spi(LOG_I_OUT_3_ph1 );     
            log_regs(LOG_I_OUT_3_ph2 ) <= log_regs_spi(LOG_I_OUT_3_ph2 );     
            log_regs(LOG_I_OUT_3_ph3 ) <= log_regs_spi(LOG_I_OUT_3_ph3 );
            
            log_regs(LOG_PSU_STATUS_L) <= psu_status(31 downto 0);
            log_regs(LOG_PSU_STATUS_H) <= psu_status(63 downto 32);
        end if;
    end process;
    
    --FANs
    fans_i: entity work.fans
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        fans_en   => fans_en,
        fans_ok   => fans_ok,
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
        HLS_to_BD        => HLS_to_BD(0),
        BD_to_HLS        => BD_to_HLS(0),
        one_ms_interrupt => free_running_1ms,
        de               => de,
        log_regs         => log_regs_uart
    );
    
    spis_i: entity work.spis_if
    generic map(HLS_EN => HLS_EN)
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        regs_updating    => regs_updating,
        --regs_reading     => regs_reading,
        internal_regs    => internal_regs_spis,
        internal_regs_we => internal_regs_we_spis,
        HLS_to_BD        => HLS_to_BD(1),
        BD_to_HLS        => BD_to_HLS(1),
        z_cross          => zero_cross,
        log_regs         => log_regs_spi
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
        de               => de,
        lamp_stat        => lamp_temp--lamp_stat
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
        free_running_1ms => free_running_1ms,
        fans_en          => fans_en,
        fans_ok          => fans_ok,
        zero_cross       => zero_cross,
        uvp_error        => uvp_error,
        PSU_Status      => PSU_Status_pwr_on,
        PSU_Status_mask => PSU_Status_pwr_on_mask,
        lamp_temp       => lamp_temp
    );
    
    uvp_i: entity work.uvp
    port map(
        clk             => clk,
        sync_rst        => sync_rst,
        registers       => registers,
        uvp_error       => uvp_error,
        PSU_Status      => PSU_Status_uvp,
        PSU_Status_mask => PSU_Status_uvp_mask
    );
    
    lamp_i: entity work.lamp
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        lamp_stat => lamp_stat
    );
    
    
end architecture RTL;
