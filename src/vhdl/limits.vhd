library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.condor_pl_pkg.all;
use work.sim_pkg.all;
use work.regs_pkg.all;

entity limits is
    port(
        clk               : in  std_logic;
        sync_rst          : in  std_logic;
        registers         : in  reg_array_t;
        limits_stat       : out std_logic_vector(limits_range);
        lamp_state        : out std_logic_vector(1 downto 0);
        lamp_out          : out std_logic;
        P_IN_STATUS_FPGA  : out std_logic;
        P_OUT_STATUS_FPGA : out std_logic;
        psu_status        : out std_logic_vector(PSU_Status_range);
        zc_error          : in  std_logic;
        fans_ok           : in  std_logic;
        fan1_ok           : in  std_logic;
        fan2_ok           : in  std_logic;
        fan3_ok           : in  std_logic
    );
end entity limits;

architecture RTL of limits is
    signal uvp_error         : std_logic;
    signal stat_115_ac_in    : std_logic;
    signal stat_28_dc_in     : std_logic;
    signal stat_115_ac_out   : std_logic;
    signal stat_dc1_out      : std_logic;
    signal stat_dc2_out      : std_logic;
    signal stat_dc5_out      : std_logic;
    signal stat_dc6_out      : std_logic;
    signal stat_dc7_out      : std_logic;
    signal stat_dc8_out      : std_logic;
    signal stat_dc9_out      : std_logic;
    signal stat_dc10_out     : std_logic;
    signal stat_115_a_in     : std_logic;
    signal stat_115_b_in     : std_logic;
    signal stat_115_c_in     : std_logic;
    signal stat_115_a_out    : std_logic;
    signal stat_115_b_out    : std_logic;
    signal stat_115_c_out    : std_logic;
    signal stat_v_out4_out   : std_logic;
    signal relays_ok         : std_logic;
    signal relay1_ok         : std_logic;
    signal relay2_ok         : std_logic;
    signal relay3_ok         : std_logic;
    signal lamp_28vdc        : std_logic;
    signal lamp_115vac       : std_logic;
    signal AC_IN_PH1_UV      : std_logic;
    signal AC_IN_PH2_UV      : std_logic;
    signal AC_IN_PH3_UV      : std_logic;
    signal DC_IN_UV          : std_logic;
    signal ovp_error         : std_logic;
    signal ovp_Vsns_PH_A_RLY : std_logic;
    signal ovp_Vsns_PH_B_RLY : std_logic;
    signal ovp_Vsns_PH_C_RLY : std_logic;
    signal ovp_Vsns_PH1      : std_logic;
    signal ovp_Vsns_PH2      : std_logic;
    signal ovp_Vsns_PH3      : std_logic;
    signal ovp_OUT4_sns      : std_logic;
    signal ovp_Vsns_28V_IN   : std_logic;
    signal ovp_VOUT_1        : std_logic;
    signal ovp_VOUT_2        : std_logic;
    signal ovp_VOUT_5        : std_logic;
    signal ovp_VOUT_6        : std_logic;
    signal ovp_VOUT_7        : std_logic;
    signal ovp_VOUT_8        : std_logic;
    signal ovp_VOUT_9        : std_logic;
    signal ovp_VOUT_10       : std_logic;
    signal otp_error         : std_logic;
    signal otp_t1            : std_logic;
    signal otp_t2            : std_logic;
    signal otp_t3            : std_logic;
    signal otp_t4            : std_logic;
    signal otp_t5            : std_logic;
    signal otp_t6            : std_logic;
    signal otp_t7            : std_logic;
    signal otp_t8            : std_logic;
    signal otp_t9            : std_logic;
    
begin
    -- over voltage
    ovp_i: entity work.ovp
    port map(
        clk               => clk,
        sync_rst          => sync_rst,
        registers         => registers,
        ovp_error         => ovp_error,
        ovp_Vsns_PH_A_RLY => ovp_Vsns_PH_A_RLY,
        ovp_Vsns_PH_B_RLY => ovp_Vsns_PH_B_RLY,
        ovp_Vsns_PH_C_RLY => ovp_Vsns_PH_C_RLY,
        ovp_Vsns_PH1      => ovp_Vsns_PH1,
        ovp_Vsns_PH2      => ovp_Vsns_PH2,
        ovp_Vsns_PH3      => ovp_Vsns_PH3,
        ovp_OUT4_sns      => ovp_OUT4_sns,
        ovp_Vsns_28V_IN   => ovp_Vsns_28V_IN,
        ovp_VOUT_1        => ovp_VOUT_1,
        ovp_VOUT_2        => ovp_VOUT_2,
        ovp_VOUT_5        => ovp_VOUT_5,
        ovp_VOUT_6        => ovp_VOUT_6,
        ovp_VOUT_7        => ovp_VOUT_7,
        ovp_VOUT_8        => ovp_VOUT_8,
        ovp_VOUT_9        => ovp_VOUT_9,
        ovp_VOUT_10       => ovp_VOUT_10
    );
        
    -- over temperatue
    otp_i: entity work.otp
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        otp_error => otp_error,
        otp_t1    => otp_t1,
        otp_t2    => otp_t2,
        otp_t3    => otp_t3,
        otp_t4    => otp_t4,
        otp_t5    => otp_t5,
        otp_t6    => otp_t6,
        otp_t7    => otp_t7,
        otp_t8    => otp_t8,
        otp_t9    => otp_t9
    );
    
    -- power in/out status for logic statuses
    logic_status_i: entity work.logic_status
    port map(
        clk               => clk,
        sync_rst          => sync_rst,
        registers         => registers,
        P_IN_STATUS_FPGA  => P_IN_STATUS_FPGA,
        P_OUT_STATUS_FPGA => P_OUT_STATUS_FPGA,
        stat_115_ac_in    => stat_115_ac_in,
        stat_115_a_in     => stat_115_a_in,
        stat_115_b_in     => stat_115_b_in,
        stat_115_c_in     => stat_115_c_in,
        stat_28_dc_in     => stat_28_dc_in,
        stat_115_ac_out   => stat_115_ac_out,
        stat_115_a_out    => stat_115_a_out,
        stat_115_b_out    => stat_115_b_out,
        stat_115_c_out    => stat_115_c_out,
        stat_v_out4_out   => stat_v_out4_out,
        stat_dc1_out      => stat_dc1_out,
        stat_dc2_out      => stat_dc2_out,
        stat_dc5_out      => stat_dc5_out,
        stat_dc6_out      => stat_dc6_out,
        stat_dc7_out      => stat_dc7_out,
        stat_dc8_out      => stat_dc8_out,
        stat_dc9_out      => stat_dc9_out,
        stat_dc10_out     => stat_dc10_out
    );

    uvp_i: entity work.uvp
    port map(
        clk             => clk,
        sync_rst        => sync_rst,
        registers       => registers,
        uvp_error       => uvp_error,
        AC_IN_PH1_UV    => AC_IN_PH1_UV,
        AC_IN_PH2_UV    => AC_IN_PH2_UV,
        AC_IN_PH3_UV    => AC_IN_PH3_UV,
        DC_IN_UV        => DC_IN_UV    
    );
    
    limits_stat(limit_uvp              ) <= uvp_error            ;
    limits_stat(limit_uvp_ph1          ) <= AC_IN_PH1_UV         ;
    limits_stat(limit_uvp_ph2          ) <= AC_IN_PH2_UV         ;
    limits_stat(limit_uvp_ph3          ) <= AC_IN_PH3_UV         ;
    limits_stat(limit_uvp_dc           ) <= DC_IN_UV             ;
    limits_stat(limit_stat_p_in        ) <= P_IN_STATUS_FPGA     ;
    limits_stat(limit_stat_p_out       ) <= P_OUT_STATUS_FPGA    ;
    limits_stat(limit_stat_115_ac_in   ) <= stat_115_ac_in       ;
    limits_stat(limit_stat_115_a_in    ) <= stat_115_a_in        ;
    limits_stat(limit_stat_115_b_in    ) <= stat_115_b_in        ;
    limits_stat(limit_stat_115_c_in    ) <= stat_115_c_in        ;
    limits_stat(limit_stat_28_dc_in    ) <= stat_28_dc_in        ;
    limits_stat(limit_stat_115_ac_out  ) <= stat_115_ac_out      ;
    limits_stat(limit_stat_115_a_out   ) <= stat_115_a_out       ;
    limits_stat(limit_stat_115_b_out   ) <= stat_115_b_out       ;
    limits_stat(limit_stat_115_c_out   ) <= stat_115_c_out       ;
    limits_stat(limit_stat_v_out4_out  ) <= stat_v_out4_out      ;
    limits_stat(limit_stat_dc1_out     ) <= stat_dc1_out         ;
    limits_stat(limit_stat_dc2_out     ) <= stat_dc2_out         ;
    limits_stat(limit_stat_dc5_out     ) <= stat_dc5_out         ;
    limits_stat(limit_stat_dc6_out     ) <= stat_dc6_out         ;
    limits_stat(limit_stat_dc7_out     ) <= stat_dc7_out         ;
    limits_stat(limit_stat_dc8_out     ) <= stat_dc8_out         ;
    limits_stat(limit_stat_dc9_out     ) <= stat_dc9_out         ;
    limits_stat(limit_stat_dc10_out    ) <= stat_dc10_out        ;
    limits_stat(limit_relay_3p         ) <= relays_ok            ;   
    limits_stat(limit_relay_3p_a       ) <= relay1_ok            ;   
    limits_stat(limit_relay_3p_b       ) <= relay2_ok            ;   
    limits_stat(limit_relay_3p_c       ) <= relay3_ok            ;   
    limits_stat(limit_lamp_28vdc       ) <= lamp_28vdc           ;
    limits_stat(limit_lamp_115vac      ) <= lamp_115vac          ;
    limits_stat(limit_ovp_error        ) <= ovp_error            ; 
    limits_stat(limit_ovp_Vsns_PH_A_RLY) <= ovp_Vsns_PH_A_RLY    ;
    limits_stat(limit_ovp_Vsns_PH_B_RLY) <= ovp_Vsns_PH_B_RLY    ;
    limits_stat(limit_ovp_Vsns_PH_C_RLY) <= ovp_Vsns_PH_C_RLY    ;
    limits_stat(limit_ovp_Vsns_PH1     ) <= ovp_Vsns_PH1         ;
    limits_stat(limit_ovp_Vsns_PH2     ) <= ovp_Vsns_PH2         ;
    limits_stat(limit_ovp_Vsns_PH3     ) <= ovp_Vsns_PH3         ;
    limits_stat(limit_ovp_OUT4_sns     ) <= ovp_OUT4_sns         ;
    limits_stat(limit_ovp_Vsns_28V_IN  ) <= ovp_Vsns_28V_IN      ;
    limits_stat(limit_ovp_VOUT_1       ) <= ovp_VOUT_1           ;
    limits_stat(limit_ovp_VOUT_2       ) <= ovp_VOUT_2           ;
    limits_stat(limit_ovp_VOUT_5       ) <= ovp_VOUT_5           ;
    limits_stat(limit_ovp_VOUT_6       ) <= ovp_VOUT_6           ;
    limits_stat(limit_ovp_VOUT_7       ) <= ovp_VOUT_7           ;
    limits_stat(limit_ovp_VOUT_8       ) <= ovp_VOUT_8           ;
    limits_stat(limit_ovp_VOUT_9       ) <= ovp_VOUT_9           ;
    limits_stat(limit_ovp_VOUT_10      ) <= ovp_VOUT_10          ;
    limits_stat(limit_otp              ) <= otp_error            ;    
    limits_stat(limit_otp_t1           ) <= otp_t1               ;
    limits_stat(limit_otp_t2           ) <= otp_t2               ;
    limits_stat(limit_otp_t3           ) <= otp_t3               ;
    limits_stat(limit_otp_t4           ) <= otp_t4               ;
    limits_stat(limit_otp_t5           ) <= otp_t5               ;
    limits_stat(limit_otp_t6           ) <= otp_t6               ;
    limits_stat(limit_otp_t7           ) <= otp_t7               ;
    limits_stat(limit_otp_t8           ) <= otp_t8               ;
    limits_stat(limit_otp_t9           ) <= otp_t9               ;
    limits_stat(limit_fans             ) <= not fans_ok          ;
    limits_stat(limit_fan1             ) <= not fan1_ok          ;
    limits_stat(limit_fan2             ) <= not fan2_ok          ;
    limits_stat(limit_fan3             ) <= not fan3_ok          ;
 
    lamp_i: entity work.lamp
    port map(
        clk              => clk,
        sync_rst         => sync_rst,
        registers        => registers,
        stat_28vdc_good  => lamp_28vdc,
        stat_115vac_good => lamp_115vac,
        lamp_state       => lamp_state,
        lamp_out         => lamp_out
    );
    
    relay_limits_i: entity work.relay_limits
    port map(
        clk       => clk,
        sync_rst  => sync_rst,
        registers => registers,
        relays_ok  => relays_ok,
        relay1_ok  => relay1_ok,
        relay2_ok  => relay2_ok,
        relay3_ok  => relay3_ok
    );
    
    psu_status_pr: process(clk)
    begin
        if rising_edge(clk) then
            psu_status(psu_status_DC_IN_Status               ) <= limits_stat(limit_stat_28_dc_in);
            psu_status(psu_status_AC_IN_Status               ) <= limits_stat(limit_stat_115_ac_in);
            psu_status(psu_status_Power_Out_Status           ) <= limits_stat(limit_stat_115_ac_out) or limits_stat(limit_stat_v_out4_out);
            psu_status(psu_status_MIU_COM_Status             ) <= registers(CPU_STATUS)(CPU_STATUS_MIU_COM_Status);
            psu_status(psu_status_OUT1_OC                    ) <= registers(UART_T1)(UART_T1_OCP);
            psu_status(psu_status_OUT2_OC                    ) <= registers(UART_T2)(UART_T2_OCP);
            psu_status(psu_status_OUT3_OC                    ) <= '0'; -- no info keep 0
            psu_status(psu_status_OUT4_OC                    ) <= '0'; -- no info keep 0
            psu_status(psu_status_OUT5_OC                    ) <= registers(UART_T5)(UART_T5_OCP);
            psu_status(psu_status_OUT6_OC                    ) <= registers(UART_T6)(UART_T6_OCP);
            psu_status(psu_status_OUT7_OC                    ) <= registers(UART_T7)(UART_T7_OCP);
            psu_status(psu_status_OUT8_OC                    ) <= registers(UART_T8)(UART_T8_OCP);
            psu_status(psu_status_OUT9_OC                    ) <= registers(UART_T9)(UART_T9_OCP);
            psu_status(psu_status_OUT10_OC                   ) <= registers(UART_T4)(UART_T4_OCP);-- T4 -> OUT10
            psu_status(psu_status_DC_IN_OV                   ) <= limits_stat(limit_ovp_Vsns_28V_IN);
            psu_status(psu_status_AC_IN_PH1_OV               ) <= limits_stat(limit_ovp_Vsns_PH1);
            psu_status(psu_status_AC_IN_PH2_OV               ) <= limits_stat(limit_ovp_Vsns_PH2);
            psu_status(psu_status_AC_IN_PH3_OV               ) <= limits_stat(limit_ovp_Vsns_PH3);
            psu_status(psu_status_OUT1_OV                    ) <= registers(UART_T1)(UART_T1_OVP);
            psu_status(psu_status_OUT2_OV                    ) <= registers(UART_T2)(UART_T2_OVP);
            psu_status(psu_status_OUT3_OV                    ) <= limits_stat(limit_ovp_Vsns_PH_A_RLY) and limits_stat(limit_ovp_Vsns_PH_B_RLY) and limits_stat(limit_ovp_Vsns_PH_C_RLY); 
            psu_status(psu_status_OUT4_OV                    ) <= limits_stat(limit_ovp_OUT4_sns); 
            psu_status(psu_status_OUT5_OV                    ) <= registers(UART_T5)(UART_T5_OVP);               
            psu_status(psu_status_OUT6_OV                    ) <= registers(UART_T6)(UART_T6_OVP);               
            psu_status(psu_status_OUT7_OV                    ) <= registers(UART_T7)(UART_T7_OVP);               
            psu_status(psu_status_OUT8_OV                    ) <= registers(UART_T8)(UART_T8_OVP);               
            psu_status(psu_status_OUT9_OV                    ) <= registers(UART_T9)(UART_T9_OVP);              
            psu_status(psu_status_OUT10_OV                   ) <= registers(UART_T4)(UART_T4_OVP);-- T4 -> OUT10
            psu_status(psu_status_DC_IN_UV                   ) <= limits_stat(limit_uvp_dc      );
            psu_status(psu_status_AC_IN_PH1_UV               ) <= limits_stat(limit_uvp_ph1     );
            psu_status(psu_status_AC_IN_PH2_UV               ) <= limits_stat(limit_uvp_ph2     );
            psu_status(psu_status_AC_IN_PH3_UV               ) <= limits_stat(limit_uvp_ph3     );
            psu_status(psu_status_AC_IN_PH1_Status           ) <= zc_error;
            psu_status(psu_status_AC_IN_PH2_Status           ) <= zc_error;
            psu_status(psu_status_AC_IN_PH3_Status           ) <= zc_error;
            psu_status(psu_status_ACI_IN_Neutral_Status      ) <= '0'; -- no info keep 0
            psu_status(psu_status_Is_Logfile_Running         ) <= registers(CPU_STATUS)(CPU_STATUS_Is_Logfile_Running);
            psu_status(psu_status_Is_Logfile_Erase_In_Process) <= registers(CPU_STATUS)(CPU_STATUS_Is_Logfile_Erase_In_Process);
            psu_status(psu_status_Fan1_Speed_Status          ) <= limits_stat(limit_fan1);
            psu_status(psu_status_Fan2_Speed_Status          ) <= limits_stat(limit_fan2);
            psu_status(psu_status_Fan3_Speed_Status          ) <= limits_stat(limit_fan3);
            psu_status(psu_status_T1_OVER_TEMP_Status        ) <= registers(UART_T1)(UART_T1_OTP);                
            psu_status(psu_status_T2_OVER_TEMP_Status        ) <= registers(UART_T2)(UART_T2_OTP);                
            psu_status(psu_status_T3_OVER_TEMP_Status        ) <= registers(UART_T2)(UART_T3_OTP);                          
            psu_status(psu_status_T4_OVER_TEMP_Status        ) <= registers(UART_T2)(UART_T4_OTP);                      
            psu_status(psu_status_T5_OVER_TEMP_Status        ) <= registers(UART_T5)(UART_T5_OTP);                
            psu_status(psu_status_T6_OVER_TEMP_Status        ) <= registers(UART_T6)(UART_T6_OTP);                
            psu_status(psu_status_T7_OVER_TEMP_Status        ) <= registers(UART_T7)(UART_T7_OTP);                
            psu_status(psu_status_T8_OVER_TEMP_Status        ) <= registers(UART_T8)(UART_T8_OTP);                
            psu_status(psu_status_T9_OVER_TEMP_Status        ) <= registers(UART_T9)(UART_T9_OTP);                
            psu_status(psu_status_CC_TCU_Inhibit             ) <= registers(IO_OUT0)(IO_OUT0_CCTCU_INH_FPGA);  
            psu_status(psu_status_EC_TCU_Inhibit             ) <= registers(IO_OUT0)(IO_OUT0_ECTCU_INH_FPGA);
            psu_status(psu_status_Reset                      ) <= not registers(IO_OUT0)(IO_OUT0_RESET_OUT_FPGA);
            psu_status(psu_status_Shutdown                   ) <= not registers(IO_OUT0)(IO_OUT0_SHUTDOWN_OUT_FPGA);
            psu_status(psu_status_Emergency_Shutdown         ) <= not registers(IO_OUT0)(IO_OUT0_ESHUTDOWN_OUT_FPGA);
            psu_status(psu_status_System_Off                 ) <= registers(GENERAL_STATUS)(GENERAL_STATUS_during_power_down) ;
            psu_status(psu_status_ON_OFF_Switch_State        ) <= registers(GENERAL_STATUS)(GENERAL_STATUS_power_on_debaunced);  
            psu_status(psu_status_Capacitor1_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor2_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor3_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor4_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor5_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor6_end_of_life     ) <= '0'; -- no info keep 0 
            psu_status(psu_status_Capacitor7_end_of_life     ) <= '0'; -- no info keep 0 
        end if;
    end process;
    
end architecture RTL;
