library ieee;
use ieee.std_logic_1164.all;

use work.regs_pkg.all;

package condor_pl_pkg is
    constant FPGA_VERSION_CONST : std_logic_vector(full_reg_range) := X"00010008"; -- version (major,minor)
    
    constant UART_A_SIZE        : integer := 12;
    constant AXI_A_SIZE         : integer := 12;
    constant NUM_UARTS          : integer := 9;
    subtype UARTS_RANGE         is integer range NUM_UARTS - 1 downto 0;
    
    subtype log_regs_range is regs_names_t range LOG_MESSAGE_ID to LOG_LAMP_IND;
    type log_reg_array_t is array (log_regs_range) of std_logic_vector(full_reg_range);

    subtype rs485_regs_range is regs_names_t range UARTS_CONTROL to UART_T9;
    subtype spi_regs_range is regs_names_t range SPIS_CONTROL to SPI_RMS_OUT4_sns;
    
    type ios_2_app_t is record
        POWERON_FPGA     : std_logic;      
        FAN_PG1_FPGA     : std_logic;      
        FAN_HALL1_FPGA   : std_logic;     
        FAN_PG3_FPGA     : std_logic;      
        FAN_HALL3_FPGA   : std_logic;     
        FAN_PG2_FPGA     : std_logic;      
        FAN_HALL2_FPGA   : std_logic;     
        PG_BUCK_FB       : std_logic;      
        PG_PSU_1_FB      : std_logic;      
        PG_PSU_2_FB      : std_logic;      
        PG_PSU_5_FB      : std_logic;      
        PG_PSU_6_FB      : std_logic;      
        PG_PSU_7_FB      : std_logic;      
        PG_PSU_8_FB      : std_logic;      
        PG_PSU_9_FB      : std_logic;      
        PG_PSU_10_FB     : std_logic;      
        lamp_status_fpga : std_logic;  
        PH_A_ON_fpga     : std_logic;   
        PH_B_ON_fpga     : std_logic;   
        PH_C_ON_fpga     : std_logic;
    end record ios_2_app_t;
    
    type app_2_ios_t is record
        FAN_EN1_FPGA      : std_logic; 
        FAN_CTRL1_FPGA    : std_logic; 
        P_IN_STATUS_FPGA  : std_logic; 
        POD_STATUS_FPGA   : std_logic; 
        ECTCU_INH_FPGA    : std_logic; 
        P_OUT_STATUS_FPGA : std_logic; 
        CCTCU_INH_FPGA    : std_logic; 
        SHUTDOWN_OUT_FPGA : std_logic; 
        RESET_OUT_FPGA    : std_logic; 
        SPARE_OUT_FPGA    : std_logic; 
        ESHUTDOWN_OUT_FPGA: std_logic; 
        RELAY_1PH_FPGA    : std_logic; 
        RELAY_3PH_FPGA    : std_logic; 
        FAN_EN3_FPGA      : std_logic; 
        FAN_CTRL3_FPGA    : std_logic; 
        FAN_EN2_FPGA      : std_logic; 
        FAN_CTRL2_FPGA    : std_logic; 
        EN_PFC_FB         : std_logic; 
        EN_PSU_1_FB       : std_logic; 
        EN_PSU_2_FB       : std_logic; 
        EN_PSU_5_FB       : std_logic; 
        EN_PSU_6_FB       : std_logic; 
        EN_PSU_7_FB       : std_logic; 
        EN_PSU_8_FB       : std_logic; 
        EN_PSU_9_FB       : std_logic; 
        EN_PSU_10_FB      : std_logic; 
        RS485_DE_7        : std_logic; 
        RS485_DE_8        : std_logic; 
        RS485_DE_9        : std_logic; 
        RS485_DE_1        : std_logic; 
        RS485_DE_2        : std_logic; 
        RS485_DE_3        : std_logic; 
        RS485_DE_4        : std_logic; 
        RS485_DE_5        : std_logic; 
        RS485_DE_6        : std_logic;
    end record app_2_ios_t;
    
    type power_2_ios_t is record
        FAN_EN1_FPGA      : std_logic; 
        FAN_EN2_FPGA      : std_logic; 
        FAN_EN3_FPGA      : std_logic; 
        FAN_CTRL1_FPGA    : std_logic;
        FAN_CTRL2_FPGA    : std_logic;
        FAN_CTRL3_FPGA    : std_logic;
        P_IN_STATUS_FPGA  : std_logic; 
        ECTCU_INH_FPGA    : std_logic; 
        P_OUT_STATUS_FPGA : std_logic; 
        CCTCU_INH_FPGA    : std_logic; 
        SHUTDOWN_OUT_FPGA : std_logic; 
        RESET_OUT_FPGA    : std_logic; 
        SPARE_OUT_FPGA    : std_logic; 
        ESHUTDOWN_OUT_FPGA: std_logic; 
        RELAY_1PH_FPGA    : std_logic; 
        RELAY_3PH_FPGA    : std_logic; 
        EN_PFC_FB         : std_logic; 
        EN_PSU_1_FB       : std_logic; 
        EN_PSU_2_FB       : std_logic; 
        EN_PSU_5_FB       : std_logic; 
        EN_PSU_6_FB       : std_logic; 
        EN_PSU_7_FB       : std_logic; 
        EN_PSU_8_FB       : std_logic; 
        EN_PSU_9_FB       : std_logic; 
        EN_PSU_10_FB      : std_logic; 
    end record power_2_ios_t;
  
    constant psu_status_DC_IN_Status                : integer :=  0;
    constant psu_status_AC_IN_Status                : integer :=  1;
    constant psu_status_Power_Out_Status            : integer :=  2;
    constant psu_status_MIU_COM_Status              : integer :=  3;
    constant psu_status_OUT1_OC                     : integer :=  4;
    constant psu_status_OUT2_OC                     : integer :=  5;
    constant psu_status_OUT3_OC                     : integer :=  6;
    constant psu_status_OUT4_OC                     : integer :=  7;
    constant psu_status_OUT5_OC                     : integer :=  8;
    constant psu_status_OUT6_OC                     : integer :=  9;
    constant psu_status_OUT7_OC                     : integer :=  0;
    constant psu_status_OUT8_OC                     : integer := 11;
    constant psu_status_OUT9_OC                     : integer := 12;
    constant psu_status_OUT10_OC                    : integer := 13;
    constant psu_status_DC_IN_OV                    : integer := 14;
    constant psu_status_AC_IN_PH1_OV                : integer := 15;
    constant psu_status_AC_IN_PH2_OV                : integer := 16;
    constant psu_status_AC_IN_PH3_OV                : integer := 17;
    constant psu_status_OUT1_OV                     : integer := 18;
    constant psu_status_OUT2_OV                     : integer := 19;
    constant psu_status_OUT3_OV                     : integer := 20;
    constant psu_status_OUT4_OV                     : integer := 21;
    constant psu_status_OUT5_OV                     : integer := 22;
    constant psu_status_OUT6_OV                     : integer := 23;
    constant psu_status_OUT7_OV                     : integer := 24;
    constant psu_status_OUT8_OV                     : integer := 25;
    constant psu_status_OUT9_OV                     : integer := 26;
    constant psu_status_OUT10_OV                    : integer := 27;
    constant psu_status_DC_IN_UV                    : integer := 28;
    constant psu_status_AC_IN_PH1_UV                : integer := 29;
    constant psu_status_AC_IN_PH2_UV                : integer := 30;
    constant psu_status_AC_IN_PH3_UV                : integer := 31;
    constant psu_status_AC_IN_PH1_Status            : integer := 32;
    constant psu_status_AC_IN_PH2_Status            : integer := 33;
    constant psu_status_AC_IN_PH3_Status            : integer := 34;
    constant psu_status_ACI_IN_Neutral_Status       : integer := 35;
    constant psu_status_Is_Logfile_Running          : integer := 36;
    constant psu_status_Is_Logfile_Erase_In_Process : integer := 37;
    constant psu_status_Fan1_Speed_Status           : integer := 38;
    constant psu_status_Fan2_Speed_Status           : integer := 39;
    constant psu_status_Fan3_Speed_Status           : integer := 40;
    constant psu_status_T1_OVER_TEMP_Status         : integer := 41;
    constant psu_status_T2_OVER_TEMP_Status         : integer := 42;
    constant psu_status_T3_OVER_TEMP_Status         : integer := 43;
    constant psu_status_T4_OVER_TEMP_Status         : integer := 44;
    constant psu_status_T5_OVER_TEMP_Status         : integer := 45;
    constant psu_status_T6_OVER_TEMP_Status         : integer := 46;
    constant psu_status_T7_OVER_TEMP_Status         : integer := 47;
    constant psu_status_T8_OVER_TEMP_Status         : integer := 48;
    constant psu_status_T9_OVER_TEMP_Status         : integer := 49;
    constant psu_status_CC_TCU_Inhibit              : integer := 50;
    constant psu_status_EC_TCU_Inhibit              : integer := 51;
    constant psu_status_Reset                       : integer := 52;
    constant psu_status_Shutdown                    : integer := 53;
    constant psu_status_Emergency_Shutdown          : integer := 54;
    constant psu_status_System_Off                  : integer := 55;
    constant psu_status_ON_OFF_Switch_State         : integer := 56;
    constant psu_status_Capacitor1_end_of_life      : integer := 57;
    constant psu_status_Capacitor2_end_of_life      : integer := 58;
    constant psu_status_Capacitor3_end_of_life      : integer := 59;
    constant psu_status_Capacitor4_end_of_life      : integer := 60;
    constant psu_status_Capacitor5_end_of_life      : integer := 61;
    constant psu_status_Capacitor6_end_of_life      : integer := 62;
    constant psu_status_Capacitor7_end_of_life      : integer := 63;

    subtype PSU_Status_range is integer range 63 downto 0;
    
    constant limit_uvp                              : integer := 0;
    constant limit_uvp_ph1                          : integer := 1;
    constant limit_uvp_ph2                          : integer := 2;
    constant limit_uvp_ph3                          : integer := 3;
    constant limit_uvp_dc                           : integer := 4;
    constant limit_stat_p_in                        : integer := 5;
    constant limit_stat_p_out                       : integer := 5;
    constant limit_stat_115_ac_in                   : integer := 5;
    constant limit_stat_28_dc_in                    : integer := 5;
    constant limit_stat_115_ac_out                  : integer := 5;
    constant limit_stat_dc1_out                     : integer := 5;
    constant limit_stat_dc2_out                     : integer := 5;
    constant limit_stat_dc5_out                     : integer := 5;
    constant limit_stat_dc6_out                     : integer := 5;
    constant limit_stat_dc7_out                     : integer := 5;
    constant limit_stat_dc8_out                     : integer := 5;
    constant limit_stat_dc9_out                     : integer := 5;
    constant limit_stat_dc10_out                    : integer := 5;
    constant limit_dummy                            : integer := 6;
    subtype limits_range is integer range limit_dummy - 1 downto 0;

    -- ps interrupts index
    constant PS_INTR_MS                             : integer := 0;
    constant PS_INTR_UPDATE_FLASH                   : integer := 1;
    constant PS_INTR_STOP_LOG                       : integer := 2;
    subtype  PS_INTR_range                          is integer range PS_INTR_STOP_LOG downto PS_INTR_MS;

    type HLS_axim_to_interconnect_t is record
        awaddr      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        awlen       : STD_LOGIC_VECTOR(7 DOWNTO 0);
        awsize      : STD_LOGIC_VECTOR(2 DOWNTO 0);
        awburst     : STD_LOGIC_VECTOR(1 DOWNTO 0);
        awlock      : STD_LOGIC_VECTOR(1 DOWNTO 0);
        awregion    : STD_LOGIC_VECTOR(3 DOWNTO 0);
        awcache     : STD_LOGIC_VECTOR(3 DOWNTO 0);
        awprot      : STD_LOGIC_VECTOR(2 DOWNTO 0);
        awqos       : STD_LOGIC_VECTOR(3 DOWNTO 0);
        awvalid     : STD_LOGIC;
        wdata       : STD_LOGIC_VECTOR(31 DOWNTO 0);
        wstrb       : STD_LOGIC_VECTOR(3 DOWNTO 0);
        wlast       : STD_LOGIC;
        wvalid      : STD_LOGIC;
        bready      : STD_LOGIC;
        araddr      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        arlen       : STD_LOGIC_VECTOR(7 DOWNTO 0);
        arsize      : STD_LOGIC_VECTOR(2 DOWNTO 0);
        arburst     : STD_LOGIC_VECTOR(1 DOWNTO 0);
        arlock      : STD_LOGIC_VECTOR(1 DOWNTO 0);
        arregion    : STD_LOGIC_VECTOR(3 DOWNTO 0);
        arcache     : STD_LOGIC_VECTOR(3 DOWNTO 0);
        arprot      : STD_LOGIC_VECTOR(2 DOWNTO 0);
        arqos       : STD_LOGIC_VECTOR(3 DOWNTO 0);
        arvalid     : STD_LOGIC;
        rready      : STD_LOGIC;
        --arid        : STD_LOGIC_VECTOR(0 to 0);
        --awid        : STD_LOGIC_VECTOR(0 to 0);
        aruser      : std_logic_vector(15 downto 0);
        awuser      : std_logic_vector(15 downto 0);
    end record HLS_axim_to_interconnect_t;
    type HLS_axim_to_interconnect_array_t is array (natural range <>) of HLS_axim_to_interconnect_t;
    
    type HLS_axim_from_interconnect_t is record
        awready     : STD_LOGIC;
        wready      : STD_LOGIC;
        bresp       : STD_LOGIC_VECTOR(1 DOWNTO 0);
        bvalid      : STD_LOGIC;
        arready     : STD_LOGIC;
        rdata       : STD_LOGIC_VECTOR(31 DOWNTO 0);
        rresp       : STD_LOGIC_VECTOR(1 DOWNTO 0);
        rlast       : STD_LOGIC;
        rvalid      : STD_LOGIC;
        --bid         : STD_LOGIC_VECTOR(5 downto 0);
        --rid         : STD_LOGIC_VECTOR(5 downto 0);
    end record HLS_axim_from_interconnect_t;
    type HLS_axim_from_interconnect_array_t is array (natural range <>) of HLS_axim_from_interconnect_t;


    function ios_2_app_vec(x: ios_2_app_t) return std_logic_vector;
end package condor_pl_pkg;

package body condor_pl_pkg is
    function ios_2_app_vec(x: ios_2_app_t) return std_logic_vector is
        --variable o : std_logic_vector(IO_IN_range);
        variable o : std_logic_vector(IO_IN_PH_C_ON_fpga downto IO_IN_POWERON_FPGA);
    begin
        o( 0) := x.POWERON_FPGA    ; 
        o( 1) := x.FAN_PG1_FPGA    ; 
        o( 2) := x.FAN_HALL1_FPGA  ; 
        o( 3) := x.FAN_PG3_FPGA    ; 
        o( 4) := x.FAN_HALL3_FPGA  ; 
        o( 5) := x.FAN_PG2_FPGA    ; 
        o( 6) := x.FAN_HALL2_FPGA  ; 
        o( 7) := x.PG_BUCK_FB      ; 
        o( 8) := x.PG_PSU_1_FB     ; 
        o( 9) := x.PG_PSU_2_FB     ; 
        o(10) := x.PG_PSU_5_FB     ; 
        o(11) := x.PG_PSU_6_FB     ; 
        o(12) := x.PG_PSU_7_FB     ; 
        o(13) := x.PG_PSU_8_FB     ; 
        o(14) := x.PG_PSU_9_FB     ; 
        o(15) := x.PG_PSU_10_FB    ; 
        o(16) := x.lamp_status_fpga; 
        o(17) := x.PH_A_ON_fpga    ; 
        o(18) := x.PH_B_ON_fpga    ; 
        o(19) := x.PH_C_ON_fpga    ; 
        return o;        
    end;
    
        
end package body condor_pl_pkg;
