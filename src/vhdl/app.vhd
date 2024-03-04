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
        ps_intr          : out std_logic_vector(PS_INTR_range)
    );
end entity app;

architecture RTL of app is
    signal timer   : std_logic_vector(63 downto 0) := (others => '0');
    signal IO_IN_s : std_logic_vector(IO_IN_range);
    signal internal_regs_update_log    : reg_array_t;
    signal internal_regs_we_update_log : reg_slv_array_t;
    signal log_regs         : log_reg_array_t;
    signal ETI : std_logic_vector(31 downto 0);
    signal SN : std_logic_vector(7 downto 0);
    signal stop_log_to_cpu : std_logic;
    signal condition_to_stop_log_to_do : std_logic;
    signal fan_pwm : std_logic_vector(2 downto 0);
    
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
                
                if registers(GENERAL_CONTROL)(CONTROL_IO_DEBUG_EN) = '1' then
                    internal_regs_we(IO_IN) <= '1';
                    internal_regs(IO_IN)(IO_IN_range) <= IO_IN_s;
                end if;
                
                for i in log_regs_range loop
                    internal_regs_we(i) <= internal_regs_we_update_log(i);
                    internal_regs(i) <= internal_regs_update_log(i);
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
    
    meta_regs: entity work.syncronizers
    generic map(
        SIZE    => IO_IN_s'length
    )
    port map(
        src     => ios_2_app_vec(ios_2_app),
        dst     => IO_IN_s,
        dst_clk => clk
    );

    process(clk)
    begin
        if rising_edge(clk) then
            if registers(GENERAL_CONTROL)(CONTROL_IO_DEBUG_EN) = '1' then
                app_2_IOs.FAN_EN1_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN1_FPGA      ) when registers(PWM_CTL)(PWM_CTL_PWM0_ACTIVE) = '0' else fan_pwm(0);
                app_2_IOs.FAN_CTRL1_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL1_FPGA    );
                app_2_IOs.P_IN_STATUS_FPGA   <= registers(IO_OUT0)(IO_OUT0_P_IN_STATUS_FPGA  );
                app_2_IOs.POD_STATUS_FPGA    <= registers(IO_OUT0)(IO_OUT0_POD_STATUS_FPGA   );
                app_2_IOs.ECTCU_INH_FPGA     <= registers(IO_OUT0)(IO_OUT0_ECTCU_INH_FPGA    );
                app_2_IOs.P_OUT_STATUS_FPGA  <= registers(IO_OUT0)(IO_OUT0_P_OUT_STATUS_FPGA );
                app_2_IOs.CCTCU_INH_FPGA     <= registers(IO_OUT0)(IO_OUT0_CCTCU_INH_FPGA    );
                app_2_IOs.SHUTDOWN_OUT_FPGA  <= registers(IO_OUT0)(IO_OUT0_SHUTDOWN_OUT_FPGA );
                app_2_IOs.RESET_OUT_FPGA     <= registers(IO_OUT0)(IO_OUT0_RESET_OUT_FPGA    );
                app_2_IOs.SPARE_OUT_FPGA     <= registers(IO_OUT0)(IO_OUT0_SPARE_OUT_FPGA    );
                app_2_IOs.ESHUTDOWN_OUT_FPGA <= registers(IO_OUT0)(IO_OUT0_ESHUTDOWN_OUT_FPGA);
                app_2_IOs.RELAY_1PH_FPGA     <= registers(IO_OUT0)(IO_OUT0_RELAY_1PH_FPGA    );
                app_2_IOs.RELAY_3PH_FPGA     <= registers(IO_OUT0)(IO_OUT0_RELAY_3PH_FPGA    );
                app_2_IOs.FAN_EN3_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN3_FPGA      ) when registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE) = '0' else fan_pwm(2);
                app_2_IOs.FAN_CTRL3_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL3_FPGA    );
                app_2_IOs.FAN_EN2_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN2_FPGA      ) when registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE) = '0' else fan_pwm(1);
                app_2_IOs.FAN_CTRL2_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL2_FPGA    );
                app_2_IOs.EN_PFC_FB          <= registers(IO_OUT0)(IO_OUT0_EN_PFC_FB         );
                app_2_IOs.EN_PSU_1_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_1_FB       );
                app_2_IOs.EN_PSU_2_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_2_FB       );
                app_2_IOs.EN_PSU_5_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_5_FB       );
                app_2_IOs.EN_PSU_6_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_6_FB       );
                app_2_IOs.EN_PSU_7_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_7_FB       );
                app_2_IOs.EN_PSU_8_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_8_FB       );
                app_2_IOs.EN_PSU_9_FB        <= registers(IO_OUT0)(IO_OUT0_EN_PSU_9_FB       );
                app_2_IOs.EN_PSU_10_FB       <= registers(IO_OUT0)(IO_OUT0_EN_PSU_10_FB      );
                app_2_IOs.RS485_DE_7         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_7        );
                app_2_IOs.RS485_DE_8         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_8        );
                app_2_IOs.RS485_DE_9         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_9        );
                app_2_IOs.RS485_DE_1         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_1        );
                app_2_IOs.RS485_DE_2         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_2        );
                app_2_IOs.RS485_DE_3         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_3        );
                app_2_IOs.RS485_DE_4         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_4        );
                app_2_IOs.RS485_DE_5         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_5        );
                app_2_IOs.RS485_DE_6         <= registers(IO_OUT1)(IO_OUT1_RS485_DE_6        );             
            else  -- here we need to add application assignment to the pins
                app_2_IOs.FAN_EN1_FPGA       <= fan_pwm(0);
                app_2_IOs.FAN_CTRL1_FPGA     <= '0';
                app_2_IOs.P_IN_STATUS_FPGA   <= '0';
                app_2_IOs.POD_STATUS_FPGA    <= '0';
                app_2_IOs.ECTCU_INH_FPGA     <= '0';
                app_2_IOs.P_OUT_STATUS_FPGA  <= '0';
                app_2_IOs.CCTCU_INH_FPGA     <= '0';
                app_2_IOs.SHUTDOWN_OUT_FPGA  <= '0';
                app_2_IOs.RESET_OUT_FPGA     <= '0';
                app_2_IOs.SPARE_OUT_FPGA     <= '0';
                app_2_IOs.ESHUTDOWN_OUT_FPGA <= '0';
                app_2_IOs.RELAY_1PH_FPGA     <= '0';
                app_2_IOs.RELAY_3PH_FPGA     <= '0';
                app_2_IOs.FAN_EN3_FPGA       <= fan_pwm(2);
                app_2_IOs.FAN_CTRL3_FPGA     <= '0';
                app_2_IOs.FAN_EN2_FPGA       <= fan_pwm(1);
                app_2_IOs.FAN_CTRL2_FPGA     <= '0';
                app_2_IOs.EN_PFC_FB          <= '0';
                app_2_IOs.EN_PSU_1_FB        <= '0';
                app_2_IOs.EN_PSU_2_FB        <= '0';
                app_2_IOs.EN_PSU_5_FB        <= '0';
                app_2_IOs.EN_PSU_6_FB        <= '0';
                app_2_IOs.EN_PSU_7_FB        <= '0';
                app_2_IOs.EN_PSU_8_FB        <= '0';
                app_2_IOs.EN_PSU_9_FB        <= '0';
                app_2_IOs.EN_PSU_10_FB       <= '0';
                app_2_IOs.RS485_DE_7         <= '0';
                app_2_IOs.RS485_DE_8         <= '0';
                app_2_IOs.RS485_DE_9         <= '0';
                app_2_IOs.RS485_DE_1         <= '0';
                app_2_IOs.RS485_DE_2         <= '0';
                app_2_IOs.RS485_DE_3         <= '0';
                app_2_IOs.RS485_DE_4         <= '0';
                app_2_IOs.RS485_DE_5         <= '0';
                app_2_IOs.RS485_DE_6         <= '0';             
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
        ps_intr          => ps_intr(PS_INTR_MS),
        log_regs         => log_regs,
        ios_2_app        => ios_2_app
    );
    
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
    
    stop_log_pr: process(clk)
    begin
        if rising_edge(clk) then
            if sync_rst = '1' then
                stop_log_to_cpu <= '0';
                ps_intr(PS_INTR_STOP_LOG) <= '0';
            else
                ps_intr(PS_INTR_STOP_LOG) <= '0';
                if registers(GENERAL_CONTROL)(CONTROL_STOP_LOG_ACK) = '1' and regs_updating(GENERAL_CONTROL) = '1' then
                    stop_log_to_cpu <= '0';
                elsif condition_to_stop_log_to_do = '1' then
                    ps_intr(PS_INTR_STOP_LOG) <= '1';
                    stop_log_to_cpu <= '1';
                end if;
            end if;
        end if;
    end process;
    -- TODO fill this with real stuff
    condition_to_stop_log_to_do <= '0';
    
    -- FAN PWM
    fan0_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM0_LOW),
        high       => registers(PWM0_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM0_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM0_ACTIVE),
        pwm        => fan_pwm(0)
    );
    
    fan1_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM1_LOW),
        high       => registers(PWM1_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM1_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE),
        pwm        => fan_pwm(1)
    );
    
    fan2_pwm: entity work.pwm
    generic map(
        SIZE => 32
    )
    port map(
        clk        => clk,
        rst        => sync_rst,
        low        => registers(PWM2_LOW),
        high       => registers(PWM2_LOW),
        start_high => registers(PWM_CTL)(PWM_CTL_PWM2_START_HIGH),
        active     => registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE),
        pwm        => fan_pwm(2)
    );
    
end architecture RTL;
