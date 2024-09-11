library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
--use work.sim_pkg.all;
use work.regs_pkg.all;

entity app_ios is
    port(
        clk               : in  std_logic;
        sync_rst          : in  std_logic;
        registers         : in  reg_array_t;
        regs_updating     : in  reg_slv_array_t;
        regs_reading      : in  reg_slv_array_t;
        internal_regs     : out reg_array_t;
        internal_regs_we  : out reg_slv_array_t;
        ios_2_app         : in  ios_2_app_t;
        app_2_ios         : out app_2_ios_t;
        power_2_ios       : in  power_2_ios_t;
        fan_pwm           : in  std_logic_vector(1 to 3);
        de                : in  std_logic_vector(8 downto 0);
        lamp_stat         : in  std_logic;
        P_IN_STATUS_FPGA  : in  std_logic;
        P_OUT_STATUS_FPGA : in  std_logic
    );
end entity app_ios;

architecture RTL of app_ios is
    --signal IO_IN_s   : std_logic_vector(IO_IN_range);
    signal IO_IN_s   : std_logic_vector(IO_IN_PH_C_ON_fpga downto IO_IN_POWERON_FPGA);
    
begin
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
            if sync_rst then
                app_2_IOs.FAN_EN1_FPGA       <= '0';
                app_2_IOs.FAN_CTRL1_FPGA     <= '0';
                app_2_IOs.P_IN_STATUS_FPGA   <= '0';
                app_2_IOs.POD_STATUS_FPGA    <= '0';
                app_2_IOs.ECTCU_INH_FPGA     <= '0';
                app_2_IOs.P_OUT_STATUS_FPGA  <= '0';
                app_2_IOs.CCTCU_INH_FPGA     <= '0';
                app_2_IOs.SHUTDOWN_OUT_FPGA  <= '1'; -- normally high
                app_2_IOs.RESET_OUT_FPGA     <= '1'; -- normally high
                app_2_IOs.SPARE_OUT_FPGA     <= '0';
                app_2_IOs.ESHUTDOWN_OUT_FPGA <= '1'; -- normally high
                app_2_IOs.RELAY_3PH_FPGA     <= '0';
                app_2_IOs.FAN_EN3_FPGA       <= '0';
                app_2_IOs.FAN_CTRL3_FPGA     <= '0';
                app_2_IOs.FAN_EN2_FPGA       <= '0';
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
            else
                if registers(GENERAL_CONTROL)(GENERAL_CONTROL_IO_DEBUG_EN) = '1' then
                    app_2_IOs.FAN_EN1_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN1_FPGA      );
                    app_2_IOs.FAN_CTRL1_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL1_FPGA    ) when registers(PWM_CTL)(PWM_CTL_PWM1_ACTIVE) = '0' else fan_pwm(1);
                    app_2_IOs.P_IN_STATUS_FPGA   <= registers(IO_OUT0)(IO_OUT0_P_IN_STATUS_FPGA  );
                    app_2_IOs.POD_STATUS_FPGA    <= registers(IO_OUT0)(IO_OUT0_POD_STATUS_FPGA   );
                    app_2_IOs.ECTCU_INH_FPGA     <= registers(IO_OUT0)(IO_OUT0_ECTCU_INH_FPGA    );
                    app_2_IOs.P_OUT_STATUS_FPGA  <= registers(IO_OUT0)(IO_OUT0_P_OUT_STATUS_FPGA );
                    app_2_IOs.CCTCU_INH_FPGA     <= registers(IO_OUT0)(IO_OUT0_CCTCU_INH_FPGA    );
                    app_2_IOs.SHUTDOWN_OUT_FPGA  <= registers(IO_OUT0)(IO_OUT0_SHUTDOWN_OUT_FPGA );
                    app_2_IOs.RESET_OUT_FPGA     <= registers(IO_OUT0)(IO_OUT0_RESET_OUT_FPGA    );
                    app_2_IOs.SPARE_OUT_FPGA     <= registers(IO_OUT0)(IO_OUT0_SPARE_OUT_FPGA    );
                    app_2_IOs.ESHUTDOWN_OUT_FPGA <= registers(IO_OUT0)(IO_OUT0_ESHUTDOWN_OUT_FPGA);
                    app_2_IOs.RELAY_3PH_FPGA     <= registers(IO_OUT0)(IO_OUT0_RELAY_3PH_FPGA    );
                    app_2_IOs.FAN_EN3_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN3_FPGA      );
                    app_2_IOs.FAN_CTRL3_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL3_FPGA    ) when registers(PWM_CTL)(PWM_CTL_PWM3_ACTIVE) = '0' else fan_pwm(3);
                    app_2_IOs.FAN_EN2_FPGA       <= registers(IO_OUT0)(IO_OUT0_FAN_EN2_FPGA      );
                    app_2_IOs.FAN_CTRL2_FPGA     <= registers(IO_OUT0)(IO_OUT0_FAN_CTRL2_FPGA    ) when registers(PWM_CTL)(PWM_CTL_PWM2_ACTIVE) = '0' else fan_pwm(2);
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
                    app_2_IOs.FAN_EN1_FPGA       <= power_2_ios.FAN_EN1_FPGA      ;
                    app_2_IOs.FAN_CTRL1_FPGA     <= fan_pwm(1);   
                    app_2_IOs.P_IN_STATUS_FPGA   <= P_IN_STATUS_FPGA  ;
                    app_2_IOs.POD_STATUS_FPGA    <= lamp_stat;
                    app_2_IOs.ECTCU_INH_FPGA     <= power_2_ios.ECTCU_INH_FPGA    ;
                    app_2_IOs.P_OUT_STATUS_FPGA  <= P_OUT_STATUS_FPGA ;
                    app_2_IOs.CCTCU_INH_FPGA     <= power_2_ios.CCTCU_INH_FPGA    ;
                    app_2_IOs.SHUTDOWN_OUT_FPGA  <= power_2_ios.SHUTDOWN_OUT_FPGA ;
                    app_2_IOs.RESET_OUT_FPGA     <= power_2_ios.RESET_OUT_FPGA    ;
                    app_2_IOs.SPARE_OUT_FPGA     <= power_2_ios.SPARE_OUT_FPGA    ;
                    app_2_IOs.ESHUTDOWN_OUT_FPGA <= power_2_ios.ESHUTDOWN_OUT_FPGA;
                    app_2_IOs.RELAY_3PH_FPGA     <= power_2_ios.RELAY_3PH_FPGA    ;
                    app_2_IOs.FAN_EN3_FPGA       <= power_2_ios.FAN_EN3_FPGA      ;
                    app_2_IOs.FAN_CTRL3_FPGA     <= fan_pwm(3);    
                    app_2_IOs.FAN_EN2_FPGA       <= power_2_ios.FAN_EN2_FPGA      ;
                    app_2_IOs.FAN_CTRL2_FPGA     <= fan_pwm(2);   
                    app_2_IOs.EN_PFC_FB          <= power_2_ios.EN_PFC_FB         ;
                    app_2_IOs.EN_PSU_1_FB        <= power_2_ios.EN_PSU_1_FB       ;
                    app_2_IOs.EN_PSU_2_FB        <= power_2_ios.EN_PSU_2_FB       ;
                    app_2_IOs.EN_PSU_5_FB        <= power_2_ios.EN_PSU_5_FB       ;
                    app_2_IOs.EN_PSU_6_FB        <= power_2_ios.EN_PSU_6_FB       ;
                    app_2_IOs.EN_PSU_7_FB        <= power_2_ios.EN_PSU_7_FB       ;
                    app_2_IOs.EN_PSU_8_FB        <= power_2_ios.EN_PSU_8_FB       ;
                    app_2_IOs.EN_PSU_9_FB        <= power_2_ios.EN_PSU_9_FB       ;
                    app_2_IOs.EN_PSU_10_FB       <= power_2_ios.EN_PSU_10_FB      ;
                    app_2_IOs.RS485_DE_1         <= de(0); 
                    app_2_IOs.RS485_DE_2         <= de(1); 
                    app_2_IOs.RS485_DE_3         <= de(2); 
                    app_2_IOs.RS485_DE_4         <= de(3); 
                    app_2_IOs.RS485_DE_5         <= de(4); 
                    app_2_IOs.RS485_DE_6         <= de(5);             
                    app_2_IOs.RS485_DE_7         <= de(6); 
                    app_2_IOs.RS485_DE_8         <= de(7); 
                    app_2_IOs.RS485_DE_9         <= de(8); 
                end if;
            end if;
        end if;
    end process;

    process(all)
    begin
        --if registers(GENERAL_CONTROL)(CONTROL_IO_DEBUG_EN) = '1' then
            internal_regs_we(IO_IN) <= '1';
            --internal_regs(IO_IN)(IO_IN_range) <= IO_IN_s;
            internal_regs(IO_IN)(IO_IN_PH_C_ON_fpga downto IO_IN_POWERON_FPGA) <= IO_IN_s;
        --end if;
    end process;

end architecture RTL;
