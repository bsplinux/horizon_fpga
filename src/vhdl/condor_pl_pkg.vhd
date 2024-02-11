library ieee;
use ieee.std_logic_1164.all;

use work.regs_pkg.all;

package condor_pl_pkg is
    constant UART_A_SIZE        : integer := 12;
    constant AXI_A_SIZE         : integer := 12;
    
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
  
    function ios_2_app_vec(x: ios_2_app_t) return std_logic_vector;
end package condor_pl_pkg;

package body condor_pl_pkg is
    function ios_2_app_vec(x: ios_2_app_t) return std_logic_vector is
        variable o : std_logic_vector(IO_IN_range);
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
