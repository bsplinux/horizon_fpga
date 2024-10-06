------------------------------------------------------------------------------------------
-- Registers VHDL package created from yaml definition of registers at 06-10-2024 13:43 --
--   python function: regs2vhdl.py                                                      --
--   yaml file name: ../yaml/condor_regs.yaml                                           --
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package regs_pkg is

  constant REG_WIDTH : integer := 32;
  subtype full_reg_range is integer range REG_WIDTH - 1 downto 0;

  type regs_names_t is (
      REGS_VERSION        ,
      FPGA_VERSION        ,
      COMPILE_TIME        ,
      BITSTREAM_TIME      ,
      GENERAL_CONTROL     ,
      GENERAL_STATUS      ,
      PSU_CONTROL         ,
      CPU_STATUS          ,
      TIMESTAMP_L         ,
      TIMESTAMP_H         ,
      IO_IN               ,
      IO_OUT0             ,
      IO_OUT1             ,
      LOG_VDC_IN          ,
      LOG_VAC_IN_PH_A     ,
      LOG_VAC_IN_PH_B     ,
      LOG_VAC_IN_PH_C     ,
      LOG_I_DC_IN         ,
      LOG_I_AC_IN_PH_A    ,
      LOG_I_AC_IN_PH_B    ,
      LOG_I_AC_IN_PH_C    ,
      LOG_V_OUT_1         ,
      LOG_V_OUT_2         ,
      LOG_V_OUT_3_PH1     ,
      LOG_V_OUT_3_PH2     ,
      LOG_V_OUT_3_PH3     ,
      LOG_V_OUT_4         ,
      LOG_V_OUT_5         ,
      LOG_V_OUT_6         ,
      LOG_V_OUT_7         ,
      LOG_V_OUT_8         ,
      LOG_V_OUT_9         ,
      LOG_V_OUT_10        ,
      LOG_I_OUT_1         ,
      LOG_I_OUT_2         ,
      LOG_I_OUT_3_PH1     ,
      LOG_I_OUT_3_PH2     ,
      LOG_I_OUT_3_PH3     ,
      LOG_I_OUT_4         ,
      LOG_I_OUT_5         ,
      LOG_I_OUT_6         ,
      LOG_I_OUT_7         ,
      LOG_I_OUT_8         ,
      LOG_I_OUT_9         ,
      LOG_I_OUT_10        ,
      LOG_AC_POWER        ,
      LOG_FAN1_SPEED      ,
      LOG_FAN2_SPEED      ,
      LOG_FAN3_SPEED      ,
      LOG_T1              ,
      LOG_T2              ,
      LOG_T3              ,
      LOG_T4              ,
      LOG_T5              ,
      LOG_T6              ,
      LOG_T7              ,
      LOG_T8              ,
      LOG_T9              ,
      LOG_PSU_STATUS_L    ,
      LOG_PSU_STATUS_H    ,
      LOG_LAMP_IND        ,
      PWM_CTL             ,
      PWM1_LOW            ,
      PWM1_HIGH           ,
      PWM2_LOW            ,
      PWM2_HIGH           ,
      PWM3_LOW            ,
      PWM3_HIGH           ,
      UARTS_CONTROL       ,
      UARTS_STATUS        ,
      UART_RAW0_L         ,
      UART_RAW0_H         ,
      UART_RAW1_L         ,
      UART_RAW1_H         ,
      UART_RAW2_L         ,
      UART_RAW2_H         ,
      UART_RAW3_L         ,
      UART_RAW3_H         ,
      UART_RAW4_L         ,
      UART_RAW4_H         ,
      UART_RAW5_L         ,
      UART_RAW5_H         ,
      UART_RAW6_L         ,
      UART_RAW6_H         ,
      UART_RAW7_L         ,
      UART_RAW7_H         ,
      UART_RAW8_L         ,
      UART_RAW8_H         ,
      UART_V_OUT_1        ,
      UART_V_OUT_2        ,
      UART_V_OUT_5        ,
      UART_V_OUT_6        ,
      UART_V_OUT_7        ,
      UART_V_OUT_8        ,
      UART_V_OUT_9        ,
      UART_V_OUT_10       ,
      UART_I_OUT_1        ,
      UART_I_OUT_2        ,
      UART_I_OUT_5        ,
      UART_I_OUT_6        ,
      UART_I_OUT_7        ,
      UART_I_OUT_8        ,
      UART_I_OUT_9        ,
      UART_I_OUT_10       ,
      UART_T1             ,
      UART_T2             ,
      UART_T3             ,
      UART_T4             ,
      UART_T5             ,
      UART_T6             ,
      UART_T7             ,
      UART_T8             ,
      UART_T9             ,
      UART_MAIN_I_PH1     ,
      UART_MAIN_I_PH2     ,
      UART_MAIN_I_PH3     ,
      SPIS_CONTROL        ,
      SPIS_STATUS         ,
      SPI_RAW0_BA         ,
      SPI_RAW0_DC         ,
      SPI_RAW0_0E         ,
      SPI_RAW1_BA         ,
      SPI_RAW1_DC         ,
      SPI_RAW2_BA         ,
      SPI_RAW2_DC         ,
      SPI_RAW2_FE         ,
      SPI_RAW2_HG         ,
      SPI_OUT4_Isns       ,
      SPI_DC_PWR_I_sns    ,
      SPI_PH1_I_sns       ,
      SPI_PH2_I_sns       ,
      SPI_PH3_I_sns       ,
      SPI_28V_IN_sns      ,
      SPI_Vsns_PH_A_RLY   ,
      SPI_Vsns_PH_B_RLY   ,
      SPI_Vsns_PH_C_RLY   ,
      SPI_Vsns_PH3        ,
      SPI_Vsns_PH2        ,
      SPI_Vsns_PH1        ,
      SPI_OUT4_sns        ,
      SPI_RMS_OUT4_Isns   ,
      SPI_RMS_PH1_I_sns   ,
      SPI_RMS_PH2_I_sns   ,
      SPI_RMS_PH3_I_sns   ,
      SPI_RMS_Vsns_PH_A_RLY,
      SPI_RMS_Vsns_PH_B_RLY,
      SPI_RMS_Vsns_PH_C_RLY,
      SPI_RMS_Vsns_PH3    ,
      SPI_RMS_Vsns_PH2    ,
      SPI_RMS_Vsns_PH1    ,
      SPI_RMS_OUT4_sns    ,
      LIMITS0             ,
      LIMITS1             ,
      PSU_STAT_LIVE_L     ,
      PSU_STAT_LIVE_H     ,
      NO_REG
  );
  constant NUM_REGS:  natural := 156;
  constant REGS_SPACE_SIZE : natural := 155;

  type regs_a_t is array(REGS_SPACE_SIZE - 1 downto 0) of regs_names_t;
  constant regs_a: regs_a_t := (
        0 => REGS_VERSION        ,
        1 => FPGA_VERSION        ,
        2 => COMPILE_TIME        ,
        3 => BITSTREAM_TIME      ,
        4 => GENERAL_CONTROL     ,
        5 => GENERAL_STATUS      ,
        6 => PSU_CONTROL         ,
        7 => CPU_STATUS          ,
        8 => TIMESTAMP_L         ,
        9 => TIMESTAMP_H         ,
       10 => IO_IN               ,
       11 => IO_OUT0             ,
       12 => IO_OUT1             ,
       13 => LOG_VDC_IN          ,
       14 => LOG_VAC_IN_PH_A     ,
       15 => LOG_VAC_IN_PH_B     ,
       16 => LOG_VAC_IN_PH_C     ,
       17 => LOG_I_DC_IN         ,
       18 => LOG_I_AC_IN_PH_A    ,
       19 => LOG_I_AC_IN_PH_B    ,
       20 => LOG_I_AC_IN_PH_C    ,
       21 => LOG_V_OUT_1         ,
       22 => LOG_V_OUT_2         ,
       23 => LOG_V_OUT_3_PH1     ,
       24 => LOG_V_OUT_3_PH2     ,
       25 => LOG_V_OUT_3_PH3     ,
       26 => LOG_V_OUT_4         ,
       27 => LOG_V_OUT_5         ,
       28 => LOG_V_OUT_6         ,
       29 => LOG_V_OUT_7         ,
       30 => LOG_V_OUT_8         ,
       31 => LOG_V_OUT_9         ,
       32 => LOG_V_OUT_10        ,
       33 => LOG_I_OUT_1         ,
       34 => LOG_I_OUT_2         ,
       35 => LOG_I_OUT_3_PH1     ,
       36 => LOG_I_OUT_3_PH2     ,
       37 => LOG_I_OUT_3_PH3     ,
       38 => LOG_I_OUT_4         ,
       39 => LOG_I_OUT_5         ,
       40 => LOG_I_OUT_6         ,
       41 => LOG_I_OUT_7         ,
       42 => LOG_I_OUT_8         ,
       43 => LOG_I_OUT_9         ,
       44 => LOG_I_OUT_10        ,
       45 => LOG_AC_POWER        ,
       46 => LOG_FAN1_SPEED      ,
       47 => LOG_FAN2_SPEED      ,
       48 => LOG_FAN3_SPEED      ,
       49 => LOG_T1              ,
       50 => LOG_T2              ,
       51 => LOG_T3              ,
       52 => LOG_T4              ,
       53 => LOG_T5              ,
       54 => LOG_T6              ,
       55 => LOG_T7              ,
       56 => LOG_T8              ,
       57 => LOG_T9              ,
       58 => LOG_PSU_STATUS_L    ,
       59 => LOG_PSU_STATUS_H    ,
       60 => LOG_LAMP_IND        ,
       61 => PWM_CTL             ,
       62 => PWM1_LOW            ,
       63 => PWM1_HIGH           ,
       64 => PWM2_LOW            ,
       65 => PWM2_HIGH           ,
       66 => PWM3_LOW            ,
       67 => PWM3_HIGH           ,
       68 => UARTS_CONTROL       ,
       69 => UARTS_STATUS        ,
       70 => UART_RAW0_L         ,
       71 => UART_RAW0_H         ,
       72 => UART_RAW1_L         ,
       73 => UART_RAW1_H         ,
       74 => UART_RAW2_L         ,
       75 => UART_RAW2_H         ,
       76 => UART_RAW3_L         ,
       77 => UART_RAW3_H         ,
       78 => UART_RAW4_L         ,
       79 => UART_RAW4_H         ,
       80 => UART_RAW5_L         ,
       81 => UART_RAW5_H         ,
       82 => UART_RAW6_L         ,
       83 => UART_RAW6_H         ,
       84 => UART_RAW7_L         ,
       85 => UART_RAW7_H         ,
       86 => UART_RAW8_L         ,
       87 => UART_RAW8_H         ,
       88 => UART_V_OUT_1        ,
       89 => UART_V_OUT_2        ,
       90 => UART_V_OUT_5        ,
       91 => UART_V_OUT_6        ,
       92 => UART_V_OUT_7        ,
       93 => UART_V_OUT_8        ,
       94 => UART_V_OUT_9        ,
       95 => UART_V_OUT_10       ,
       96 => UART_I_OUT_1        ,
       97 => UART_I_OUT_2        ,
       98 => UART_I_OUT_5        ,
       99 => UART_I_OUT_6        ,
      100 => UART_I_OUT_7        ,
      101 => UART_I_OUT_8        ,
      102 => UART_I_OUT_9        ,
      103 => UART_I_OUT_10       ,
      104 => UART_T1             ,
      105 => UART_T2             ,
      106 => UART_T3             ,
      107 => UART_T4             ,
      108 => UART_T5             ,
      109 => UART_T6             ,
      110 => UART_T7             ,
      111 => UART_T8             ,
      112 => UART_T9             ,
      113 => UART_MAIN_I_PH1     ,
      114 => UART_MAIN_I_PH2     ,
      115 => UART_MAIN_I_PH3     ,
      116 => SPIS_CONTROL        ,
      117 => SPIS_STATUS         ,
      118 => SPI_RAW0_BA         ,
      119 => SPI_RAW0_DC         ,
      120 => SPI_RAW0_0E         ,
      121 => SPI_RAW1_BA         ,
      122 => SPI_RAW1_DC         ,
      123 => SPI_RAW2_BA         ,
      124 => SPI_RAW2_DC         ,
      125 => SPI_RAW2_FE         ,
      126 => SPI_RAW2_HG         ,
      127 => SPI_OUT4_Isns       ,
      128 => SPI_DC_PWR_I_sns    ,
      129 => SPI_PH1_I_sns       ,
      130 => SPI_PH2_I_sns       ,
      131 => SPI_PH3_I_sns       ,
      132 => SPI_28V_IN_sns      ,
      133 => SPI_Vsns_PH_A_RLY   ,
      134 => SPI_Vsns_PH_B_RLY   ,
      135 => SPI_Vsns_PH_C_RLY   ,
      136 => SPI_Vsns_PH3        ,
      137 => SPI_Vsns_PH2        ,
      138 => SPI_Vsns_PH1        ,
      139 => SPI_OUT4_sns        ,
      140 => SPI_RMS_OUT4_Isns   ,
      141 => SPI_RMS_PH1_I_sns   ,
      142 => SPI_RMS_PH2_I_sns   ,
      143 => SPI_RMS_PH3_I_sns   ,
      144 => SPI_RMS_Vsns_PH_A_RLY,
      145 => SPI_RMS_Vsns_PH_B_RLY,
      146 => SPI_RMS_Vsns_PH_C_RLY,
      147 => SPI_RMS_Vsns_PH3    ,
      148 => SPI_RMS_Vsns_PH2    ,
      149 => SPI_RMS_Vsns_PH1    ,
      150 => SPI_RMS_OUT4_sns    ,
      151 => LIMITS0             ,
      152 => LIMITS1             ,
      153 => PSU_STAT_LIVE_L     ,
      154 => PSU_STAT_LIVE_H     ,
      others => NO_REG
  );

  type reg_array_t is array (regs_names_t) of std_logic_vector(full_reg_range);
  type reg_arrays_t is array (natural range <>) of reg_array_t;
  type reg_slv_array_t is array (regs_names_t) of std_logic;
  type reg_slv_arrays_t is array (natural range <>) of reg_slv_array_t;

  ----------------------------------------------------------------------------------
  -- bit fields in registers (using named ranges for vectors and constants for bits)
  ----------------------------------------------------------------------------------
  -- fields for REGS_VERSION
  subtype  REGS_VERSION_REV_MINOR         is integer range 15 downto  0;
  subtype  REGS_VERSION_REV_MAJOR         is integer range 31 downto 16;
  -- fields for FPGA_VERSION
  subtype  FPGA_VERSION_REV_MINOR         is integer range 15 downto  0;
  subtype  FPGA_VERSION_REV_MAJOR         is integer range 31 downto 16;
  -- fields for COMPILE_TIME
  subtype  COMPILE_TIME_HOUR              is integer range  7 downto  0;
  subtype  COMPILE_TIME_YEAR              is integer range 15 downto  8;
  subtype  COMPILE_TIME_MONTH             is integer range 23 downto 16;
  subtype  COMPILE_TIME_DAY               is integer range 31 downto 24;
  -- fields for GENERAL_CONTROL
  constant GENERAL_CONTROL_SW_RESET       : integer :=  0;
  constant GENERAL_CONTROL_IO_DEBUG_EN    : integer :=  1;
  constant GENERAL_CONTROL_EN_1MS_INTR    : integer :=  2;
  constant GENERAL_CONTROL_RLEASE_REGS    : integer :=  3;
  constant GENERAL_CONTROL_STOP_LOG_ACK   : integer :=  4;
  constant GENERAL_CONTROL_ALIVE_ERROR    : integer :=  5;
  constant GENERAL_CONTROL_UVP_EN_PH1     : integer :=  6;
  constant GENERAL_CONTROL_UVP_EN_PH2     : integer :=  7;
  constant GENERAL_CONTROL_UVP_EN_PH3     : integer :=  8;
  constant GENERAL_CONTROL_UVP_EN_DC      : integer :=  9;
  constant GENERAL_CONTROL_FAN_CHECK      : integer := 10;
  constant GENERAL_CONTROL_RELAY_CHECK    : integer := 11;
  constant GENERAL_CONTROL_OVP_IN_EN      : integer := 12;
  constant GENERAL_CONTROL_OVP_OUT_EN     : integer := 13;
  constant GENERAL_CONTROL_UVP_EN         : integer := 14;
  constant GENERAL_CONTROL_OTP_EN         : integer := 15;
  -- fields for GENERAL_STATUS
  constant GENERAL_STATUS_REGS_LOCKED     : integer :=  0;
  constant GENERAL_STATUS_STOP_LOG        : integer :=  1;
  subtype  GENERAL_STATUS_LAMP_STATE      is integer range  3 downto  2;
  constant GENERAL_STATUS_power_on_debaunced : integer :=  4;
  constant GENERAL_STATUS_during_power_down : integer :=  5;
  constant GENERAL_STATUS_power_is_on     : integer :=  6;
  -- fields for PSU_CONTROL
  constant PSU_CONTROL_release_psu        : integer :=  0;
  -- fields for CPU_STATUS
  constant CPU_STATUS_MIU_COM_Status      : integer :=  0;
  constant CPU_STATUS_Is_Logfile_Running  : integer :=  1;
  constant CPU_STATUS_Is_Logfile_Erase_In_Process : integer :=  2;
  constant CPU_STATUS_ECTCU_INH           : integer :=  3;
  constant CPU_STATUS_CCTCU_INH           : integer :=  4;
  -- fields for IO_IN
  constant IO_IN_POWERON_FPGA             : integer :=  0;
  constant IO_IN_FAN_PG1_FPGA             : integer :=  1;
  constant IO_IN_FAN_HALL1_FPGA           : integer :=  2;
  constant IO_IN_FAN_PG3_FPGA             : integer :=  3;
  constant IO_IN_FAN_HALL3_FPGA           : integer :=  4;
  constant IO_IN_FAN_PG2_FPGA             : integer :=  5;
  constant IO_IN_FAN_HALL2_FPGA           : integer :=  6;
  constant IO_IN_PG_BUCK_FB               : integer :=  7;
  constant IO_IN_PG_PSU_1_FB              : integer :=  8;
  constant IO_IN_PG_PSU_2_FB              : integer :=  9;
  constant IO_IN_PG_PSU_5_FB              : integer := 10;
  constant IO_IN_PG_PSU_6_FB              : integer := 11;
  constant IO_IN_PG_PSU_7_FB              : integer := 12;
  constant IO_IN_PG_PSU_8_FB              : integer := 13;
  constant IO_IN_PG_PSU_9_FB              : integer := 14;
  constant IO_IN_PG_PSU_10_FB             : integer := 15;
  constant IO_IN_lamp_status_fpga         : integer := 16;
  constant IO_IN_PH_A_ON_fpga             : integer := 17;
  constant IO_IN_PH_B_ON_fpga             : integer := 18;
  constant IO_IN_PH_C_ON_fpga             : integer := 19;
  -- fields for IO_OUT0
  constant IO_OUT0_FAN_EN1_FPGA           : integer :=  0;
  constant IO_OUT0_FAN_CTRL1_FPGA         : integer :=  1;
  constant IO_OUT0_P_IN_STATUS_FPGA       : integer :=  2;
  constant IO_OUT0_POD_STATUS_FPGA        : integer :=  3;
  constant IO_OUT0_ECTCU_INH_FPGA         : integer :=  4;
  constant IO_OUT0_P_OUT_STATUS_FPGA      : integer :=  5;
  constant IO_OUT0_CCTCU_INH_FPGA         : integer :=  6;
  constant IO_OUT0_SHUTDOWN_OUT_FPGA      : integer :=  7;
  constant IO_OUT0_RESET_OUT_FPGA         : integer :=  8;
  constant IO_OUT0_SPARE_OUT_FPGA         : integer :=  9;
  constant IO_OUT0_ESHUTDOWN_OUT_FPGA     : integer := 10;
  constant IO_OUT0_RELAY_3PH_FPGA         : integer := 12;
  constant IO_OUT0_FAN_EN3_FPGA           : integer := 13;
  constant IO_OUT0_FAN_CTRL3_FPGA         : integer := 14;
  constant IO_OUT0_FAN_EN2_FPGA           : integer := 15;
  constant IO_OUT0_FAN_CTRL2_FPGA         : integer := 16;
  constant IO_OUT0_EN_PFC_FB              : integer := 17;
  constant IO_OUT0_EN_PSU_1_FB            : integer := 18;
  constant IO_OUT0_EN_PSU_2_FB            : integer := 19;
  constant IO_OUT0_EN_PSU_5_FB            : integer := 20;
  constant IO_OUT0_EN_PSU_6_FB            : integer := 21;
  constant IO_OUT0_EN_PSU_7_FB            : integer := 22;
  constant IO_OUT0_EN_PSU_8_FB            : integer := 23;
  constant IO_OUT0_EN_PSU_9_FB            : integer := 24;
  constant IO_OUT0_EN_PSU_10_FB           : integer := 25;
  -- fields for IO_OUT1
  constant IO_OUT1_RS485_DE_7             : integer :=  0;
  constant IO_OUT1_RS485_DE_8             : integer :=  1;
  constant IO_OUT1_RS485_DE_9             : integer :=  2;
  constant IO_OUT1_RS485_DE_1             : integer :=  3;
  constant IO_OUT1_RS485_DE_2             : integer :=  4;
  constant IO_OUT1_RS485_DE_10            : integer :=  5;
  constant IO_OUT1_RS485_DE_Buck          : integer :=  6;
  constant IO_OUT1_RS485_DE_5             : integer :=  7;
  constant IO_OUT1_RS485_DE_6             : integer :=  8;
  -- fields for LOG_VDC_IN
  subtype  LOG_VDC_IN_d                   is integer range 15 downto  0;
  -- fields for LOG_VAC_IN_PH_A
  subtype  LOG_VAC_IN_PH_A_d              is integer range 15 downto  0;
  -- fields for LOG_VAC_IN_PH_B
  subtype  LOG_VAC_IN_PH_B_d              is integer range 15 downto  0;
  -- fields for LOG_VAC_IN_PH_C
  subtype  LOG_VAC_IN_PH_C_d              is integer range 15 downto  0;
  -- fields for LOG_I_DC_IN
  subtype  LOG_I_DC_IN_d                  is integer range 15 downto  0;
  -- fields for LOG_I_AC_IN_PH_A
  subtype  LOG_I_AC_IN_PH_A_d             is integer range 15 downto  0;
  -- fields for LOG_I_AC_IN_PH_B
  subtype  LOG_I_AC_IN_PH_B_d             is integer range 15 downto  0;
  -- fields for LOG_I_AC_IN_PH_C
  subtype  LOG_I_AC_IN_PH_C_d             is integer range 15 downto  0;
  -- fields for LOG_V_OUT_1
  subtype  LOG_V_OUT_1_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_2
  subtype  LOG_V_OUT_2_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_3_PH1
  subtype  LOG_V_OUT_3_PH1_d              is integer range 15 downto  0;
  -- fields for LOG_V_OUT_3_PH2
  subtype  LOG_V_OUT_3_PH2_d              is integer range 15 downto  0;
  -- fields for LOG_V_OUT_3_PH3
  subtype  LOG_V_OUT_3_PH3_d              is integer range 15 downto  0;
  -- fields for LOG_V_OUT_4
  subtype  LOG_V_OUT_4_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_5
  subtype  LOG_V_OUT_5_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_6
  subtype  LOG_V_OUT_6_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_7
  subtype  LOG_V_OUT_7_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_8
  subtype  LOG_V_OUT_8_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_9
  subtype  LOG_V_OUT_9_d                  is integer range 15 downto  0;
  -- fields for LOG_V_OUT_10
  subtype  LOG_V_OUT_10_d                 is integer range 15 downto  0;
  -- fields for LOG_I_OUT_1
  subtype  LOG_I_OUT_1_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_2
  subtype  LOG_I_OUT_2_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_3_PH1
  subtype  LOG_I_OUT_3_PH1_d              is integer range 15 downto  0;
  -- fields for LOG_I_OUT_3_PH2
  subtype  LOG_I_OUT_3_PH2_d              is integer range 15 downto  0;
  -- fields for LOG_I_OUT_3_PH3
  subtype  LOG_I_OUT_3_PH3_d              is integer range 15 downto  0;
  -- fields for LOG_I_OUT_4
  subtype  LOG_I_OUT_4_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_5
  subtype  LOG_I_OUT_5_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_6
  subtype  LOG_I_OUT_6_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_7
  subtype  LOG_I_OUT_7_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_8
  subtype  LOG_I_OUT_8_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_9
  subtype  LOG_I_OUT_9_d                  is integer range 15 downto  0;
  -- fields for LOG_I_OUT_10
  subtype  LOG_I_OUT_10_d                 is integer range 15 downto  0;
  -- fields for LOG_AC_POWER
  subtype  LOG_AC_POWER_d                 is integer range 15 downto  0;
  -- fields for LOG_FAN1_SPEED
  subtype  LOG_FAN1_SPEED_d               is integer range 15 downto  0;
  -- fields for LOG_FAN2_SPEED
  subtype  LOG_FAN2_SPEED_d               is integer range 15 downto  0;
  -- fields for LOG_FAN3_SPEED
  subtype  LOG_FAN3_SPEED_d               is integer range 15 downto  0;
  -- fields for LOG_T1
  subtype  LOG_T1_d                       is integer range  7 downto  0;
  -- fields for LOG_T2
  subtype  LOG_T2_d                       is integer range  7 downto  0;
  -- fields for LOG_T3
  subtype  LOG_T3_d                       is integer range  7 downto  0;
  -- fields for LOG_T4
  subtype  LOG_T4_d                       is integer range  7 downto  0;
  -- fields for LOG_T5
  subtype  LOG_T5_d                       is integer range  7 downto  0;
  -- fields for LOG_T6
  subtype  LOG_T6_d                       is integer range  7 downto  0;
  -- fields for LOG_T7
  subtype  LOG_T7_d                       is integer range  7 downto  0;
  -- fields for LOG_T8
  subtype  LOG_T8_d                       is integer range  7 downto  0;
  -- fields for LOG_T9
  subtype  LOG_T9_d                       is integer range  7 downto  0;
  -- fields for LOG_PSU_STATUS_L
  constant LOG_PSU_STATUS_L_DC_IN_Status  : integer :=  0;
  constant LOG_PSU_STATUS_L_AC_IN_Status  : integer :=  1;
  constant LOG_PSU_STATUS_L_Power_Out_Status : integer :=  2;
  constant LOG_PSU_STATUS_L_MIU_COM_Status : integer :=  3;
  constant LOG_PSU_STATUS_L_OUT1_OC       : integer :=  4;
  constant LOG_PSU_STATUS_L_OUT2_OC       : integer :=  5;
  constant LOG_PSU_STATUS_L_OUT3_OC       : integer :=  6;
  constant LOG_PSU_STATUS_L_OUT4_OC       : integer :=  7;
  constant LOG_PSU_STATUS_L_OUT5_OC       : integer :=  8;
  constant LOG_PSU_STATUS_L_OUT6_OC       : integer :=  9;
  constant LOG_PSU_STATUS_L_OUT7_OC       : integer := 10;
  constant LOG_PSU_STATUS_L_OUT8_OC       : integer := 11;
  constant LOG_PSU_STATUS_L_OUT9_OC       : integer := 12;
  constant LOG_PSU_STATUS_L_OUT10_OC      : integer := 13;
  constant LOG_PSU_STATUS_L_DC_IN_OV      : integer := 14;
  constant LOG_PSU_STATUS_L_AC_IN_PH1_OV  : integer := 15;
  constant LOG_PSU_STATUS_L_AC_IN_PH2_OV  : integer := 16;
  constant LOG_PSU_STATUS_L_AC_IN_PH3_OV  : integer := 17;
  constant LOG_PSU_STATUS_L_OUT1_OV       : integer := 18;
  constant LOG_PSU_STATUS_L_OUT2_OV       : integer := 19;
  constant LOG_PSU_STATUS_L_OUT3_OV       : integer := 20;
  constant LOG_PSU_STATUS_L_OUT4_OV       : integer := 21;
  constant LOG_PSU_STATUS_L_OUT5_OV       : integer := 22;
  constant LOG_PSU_STATUS_L_OUT6_OV       : integer := 23;
  constant LOG_PSU_STATUS_L_OUT7_OV       : integer := 24;
  constant LOG_PSU_STATUS_L_OUT8_OV       : integer := 25;
  constant LOG_PSU_STATUS_L_OUT9_OV       : integer := 26;
  constant LOG_PSU_STATUS_L_OUT10_OV      : integer := 27;
  constant LOG_PSU_STATUS_L_DC_IN_UV      : integer := 28;
  constant LOG_PSU_STATUS_L_AC_IN_PH1_UV  : integer := 29;
  constant LOG_PSU_STATUS_L_AC_IN_PH2_UV  : integer := 30;
  constant LOG_PSU_STATUS_L_AC_IN_PH3_UV  : integer := 31;
  -- fields for LOG_PSU_STATUS_H
  constant LOG_PSU_STATUS_H_AC_IN_PH1_Status : integer :=  0;
  constant LOG_PSU_STATUS_H_AC_IN_PH2_Status : integer :=  1;
  constant LOG_PSU_STATUS_H_AC_IN_PH3_Status : integer :=  2;
  constant LOG_PSU_STATUS_H_AC_IN_Neutral_Status : integer :=  3;
  constant LOG_PSU_STATUS_H_Is_Logfile_Running : integer :=  4;
  constant LOG_PSU_STATUS_H_Is_Logfile_Erase_In_Process : integer :=  5;
  constant LOG_PSU_STATUS_H_Fan1_Speed_Status : integer :=  6;
  constant LOG_PSU_STATUS_H_Fan2_Speed_Status : integer :=  7;
  constant LOG_PSU_STATUS_H_Fan3_Speed_Status : integer :=  8;
  constant LOG_PSU_STATUS_H_T1_OVER_TEMP_Status : integer :=  9;
  constant LOG_PSU_STATUS_H_T2_OVER_TEMP_Status : integer := 10;
  constant LOG_PSU_STATUS_H_T3_OVER_TEMP_Status : integer := 11;
  constant LOG_PSU_STATUS_H_T4_OVER_TEMP_Status : integer := 12;
  constant LOG_PSU_STATUS_H_T5_OVER_TEMP_Status : integer := 13;
  constant LOG_PSU_STATUS_H_T6_OVER_TEMP_Status : integer := 14;
  constant LOG_PSU_STATUS_H_T7_OVER_TEMP_Status : integer := 15;
  constant LOG_PSU_STATUS_H_T8_OVER_TEMP_Status : integer := 16;
  constant LOG_PSU_STATUS_H_T9_OVER_TEMP_Status : integer := 17;
  constant LOG_PSU_STATUS_H_CC_TCU_Inhibit : integer := 18;
  constant LOG_PSU_STATUS_H_EC_TCU_Inhibit : integer := 19;
  constant LOG_PSU_STATUS_H_Reset         : integer := 20;
  constant LOG_PSU_STATUS_H_Shutdown      : integer := 21;
  constant LOG_PSU_STATUS_H_Emergency_Shutdown : integer := 22;
  constant LOG_PSU_STATUS_H_System_Off    : integer := 23;
  constant LOG_PSU_STATUS_H_ON_OFF_Switch_State : integer := 24;
  constant LOG_PSU_STATUS_H_Capacitor1_end_of_life : integer := 25;
  constant LOG_PSU_STATUS_H_Capacitor2_end_of_life : integer := 26;
  constant LOG_PSU_STATUS_H_Capacitor3_end_of_life : integer := 27;
  constant LOG_PSU_STATUS_H_Capacitor4_end_of_life : integer := 28;
  constant LOG_PSU_STATUS_H_Capacitor5_end_of_life : integer := 29;
  constant LOG_PSU_STATUS_H_Capacitor6_end_of_life : integer := 30;
  constant LOG_PSU_STATUS_H_Capacitor7_end_of_life : integer := 31;
  -- fields for PWM_CTL
  constant PWM_CTL_PWM1_ACTIVE            : integer :=  0;
  constant PWM_CTL_PWM1_START_HIGH        : integer :=  1;
  constant PWM_CTL_PWM2_ACTIVE            : integer :=  2;
  constant PWM_CTL_PWM2_START_HIGH        : integer :=  3;
  constant PWM_CTL_PWM3_ACTIVE            : integer :=  4;
  constant PWM_CTL_PWM3_START_HIGH        : integer :=  5;
  -- fields for UARTS_CONTROL
  subtype  UARTS_CONTROL_EN_RANGE         is integer range  8 downto  0;
  constant UARTS_CONTROL_RST              : integer :=  9;
  constant UARTS_CONTROL_MS1_ERR_CLR      : integer := 10;
  -- fields for UARTS_STATUS
  constant UARTS_STATUS_BUSY              : integer :=  0;
  constant UARTS_STATUS_MS1_ERR           : integer :=  1;
  -- fields for UART_RAW0_L
  subtype  UART_RAW0_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW0_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW0_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW0_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW0_H
  subtype  UART_RAW0_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW0_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW0_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW0_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW0_H_VINP               : integer := 28;
  constant UART_RAW0_H_OTP                : integer := 29;
  constant UART_RAW0_H_OCP                : integer := 30;
  constant UART_RAW0_H_OVP                : integer := 31;
  -- fields for UART_RAW1_L
  subtype  UART_RAW1_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW1_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW1_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW1_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW1_H
  subtype  UART_RAW1_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW1_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW1_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW1_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW1_H_VINP               : integer := 28;
  constant UART_RAW1_H_OTP                : integer := 29;
  constant UART_RAW1_H_OCP                : integer := 30;
  constant UART_RAW1_H_OVP                : integer := 31;
  -- fields for UART_RAW2_L
  subtype  UART_RAW2_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW2_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW2_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW2_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW2_H
  subtype  UART_RAW2_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW2_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW2_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW2_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW2_H_VINP               : integer := 28;
  constant UART_RAW2_H_OTP                : integer := 29;
  constant UART_RAW2_H_OCP                : integer := 30;
  constant UART_RAW2_H_OVP                : integer := 31;
  -- fields for UART_RAW3_L
  subtype  UART_RAW3_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW3_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW3_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW3_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW3_H
  subtype  UART_RAW3_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW3_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW3_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW3_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW3_H_VINP               : integer := 28;
  constant UART_RAW3_H_OTP                : integer := 29;
  constant UART_RAW3_H_OCP                : integer := 30;
  constant UART_RAW3_H_OVP                : integer := 31;
  -- fields for UART_RAW4_L
  subtype  UART_RAW4_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW4_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW4_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW4_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW4_H
  subtype  UART_RAW4_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW4_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW4_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW4_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW4_H_VINP               : integer := 28;
  constant UART_RAW4_H_OTP                : integer := 29;
  constant UART_RAW4_H_OCP                : integer := 30;
  constant UART_RAW4_H_OVP                : integer := 31;
  -- fields for UART_RAW5_L
  subtype  UART_RAW5_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW5_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW5_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW5_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW5_H
  subtype  UART_RAW5_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW5_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW5_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW5_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW5_H_VINP               : integer := 28;
  constant UART_RAW5_H_OTP                : integer := 29;
  constant UART_RAW5_H_OCP                : integer := 30;
  constant UART_RAW5_H_OVP                : integer := 31;
  -- fields for UART_RAW6_L
  subtype  UART_RAW6_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW6_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW6_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW6_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW6_H
  subtype  UART_RAW6_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW6_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW6_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW6_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW6_H_VINP               : integer := 28;
  constant UART_RAW6_H_OTP                : integer := 29;
  constant UART_RAW6_H_OCP                : integer := 30;
  constant UART_RAW6_H_OVP                : integer := 31;
  -- fields for UART_RAW7_L
  subtype  UART_RAW7_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW7_L_VIN_H              is integer range 15 downto 12;
  subtype  UART_RAW7_L_VIN_L              is integer range 23 downto 16;
  subtype  UART_RAW7_L_VOUT_L             is integer range 31 downto 24;
  -- fields for UART_RAW7_H
  subtype  UART_RAW7_H_VOUT_H             is integer range  3 downto  0;
  subtype  UART_RAW7_H_IIN_H              is integer range  7 downto  4;
  subtype  UART_RAW7_H_IIN_L              is integer range 15 downto  8;
  subtype  UART_RAW7_H_IOUT               is integer range 27 downto 16;
  constant UART_RAW7_H_VINP               : integer := 28;
  constant UART_RAW7_H_OTP                : integer := 29;
  constant UART_RAW7_H_OCP                : integer := 30;
  constant UART_RAW7_H_OVP                : integer := 31;
  -- fields for UART_RAW8_L
  subtype  UART_RAW8_L_TEMP               is integer range  7 downto  0;
  subtype  UART_RAW8_L_IPHA_H             is integer range 15 downto 12;
  subtype  UART_RAW8_L_IPHA_L             is integer range 23 downto 16;
  subtype  UART_RAW8_L_IPHB_L             is integer range 31 downto 24;
  -- fields for UART_RAW8_H
  subtype  UART_RAW8_H_IPHB_H             is integer range  3 downto  0;
  subtype  UART_RAW8_H_IPHC_H             is integer range  7 downto  4;
  subtype  UART_RAW8_H_IPHC_L             is integer range 15 downto  8;
  constant UART_RAW8_H_CAP_EOL            : integer := 16;
  constant UART_RAW8_H_VINP               : integer := 20;
  constant UART_RAW8_H_OTP                : integer := 21;
  constant UART_RAW8_H_OCP                : integer := 22;
  constant UART_RAW8_H_OVP                : integer := 23;
  -- fields for UART_V_OUT_1
  subtype  UART_V_OUT_1_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_2
  subtype  UART_V_OUT_2_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_5
  subtype  UART_V_OUT_5_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_6
  subtype  UART_V_OUT_6_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_7
  subtype  UART_V_OUT_7_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_8
  subtype  UART_V_OUT_8_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_9
  subtype  UART_V_OUT_9_d                 is integer range 15 downto  0;
  -- fields for UART_V_OUT_10
  subtype  UART_V_OUT_10_d                is integer range 15 downto  0;
  -- fields for UART_I_OUT_1
  subtype  UART_I_OUT_1_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_2
  subtype  UART_I_OUT_2_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_5
  subtype  UART_I_OUT_5_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_6
  subtype  UART_I_OUT_6_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_7
  subtype  UART_I_OUT_7_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_8
  subtype  UART_I_OUT_8_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_9
  subtype  UART_I_OUT_9_d                 is integer range 15 downto  0;
  -- fields for UART_I_OUT_10
  subtype  UART_I_OUT_10_d                is integer range 15 downto  0;
  -- fields for UART_T1
  subtype  UART_T1_T                      is integer range  7 downto  0;
  constant UART_T1_VINP                   : integer :=  8;
  constant UART_T1_OTP                    : integer :=  9;
  constant UART_T1_OCP                    : integer := 10;
  constant UART_T1_OVP                    : integer := 11;
  -- fields for UART_T2
  subtype  UART_T2_T                      is integer range  7 downto  0;
  constant UART_T2_VINP                   : integer :=  8;
  constant UART_T2_OTP                    : integer :=  9;
  constant UART_T2_OCP                    : integer := 10;
  constant UART_T2_OVP                    : integer := 11;
  -- fields for UART_T3
  subtype  UART_T3_T                      is integer range  7 downto  0;
  constant UART_T3_VINP                   : integer :=  8;
  constant UART_T3_OTP                    : integer :=  9;
  constant UART_T3_OCP                    : integer := 10;
  constant UART_T3_OVP                    : integer := 11;
  -- fields for UART_T4
  subtype  UART_T4_T                      is integer range  7 downto  0;
  constant UART_T4_VINP                   : integer :=  8;
  constant UART_T4_OTP                    : integer :=  9;
  constant UART_T4_OCP                    : integer := 10;
  constant UART_T4_OVP                    : integer := 11;
  -- fields for UART_T5
  subtype  UART_T5_T                      is integer range  7 downto  0;
  constant UART_T5_VINP                   : integer :=  8;
  constant UART_T5_OTP                    : integer :=  9;
  constant UART_T5_OCP                    : integer := 10;
  constant UART_T5_OVP                    : integer := 11;
  -- fields for UART_T6
  subtype  UART_T6_T                      is integer range  7 downto  0;
  constant UART_T6_VINP                   : integer :=  8;
  constant UART_T6_OTP                    : integer :=  9;
  constant UART_T6_OCP                    : integer := 10;
  constant UART_T6_OVP                    : integer := 11;
  -- fields for UART_T7
  subtype  UART_T7_T                      is integer range  7 downto  0;
  constant UART_T7_VINP                   : integer :=  8;
  constant UART_T7_OTP                    : integer :=  9;
  constant UART_T7_OCP                    : integer := 10;
  constant UART_T7_OVP                    : integer := 11;
  -- fields for UART_T8
  subtype  UART_T8_T                      is integer range  7 downto  0;
  constant UART_T8_VINP                   : integer :=  8;
  constant UART_T8_OTP                    : integer :=  9;
  constant UART_T8_OCP                    : integer := 10;
  constant UART_T8_OVP                    : integer := 11;
  -- fields for UART_T9
  subtype  UART_T9_T                      is integer range  7 downto  0;
  constant UART_T9_VINP                   : integer :=  8;
  constant UART_T9_OTP                    : integer :=  9;
  constant UART_T9_OCP                    : integer := 10;
  constant UART_T9_OVP                    : integer := 11;
  -- fields for UART_MAIN_I_PH1
  subtype  UART_MAIN_I_PH1_d              is integer range 15 downto  0;
  -- fields for UART_MAIN_I_PH2
  subtype  UART_MAIN_I_PH2_d              is integer range 15 downto  0;
  -- fields for UART_MAIN_I_PH3
  subtype  UART_MAIN_I_PH3_d              is integer range 15 downto  0;
  -- fields for SPIS_CONTROL
  subtype  SPIS_CONTROL_EN_RANGE          is integer range  2 downto  0;
  constant SPIS_CONTROL_RST               : integer :=  3;
  constant SPIS_CONTROL_US100_ERR_CLR     : integer :=  4;
  constant SPIS_CONTROL_Z_CROSS_ERR_CLR   : integer :=  5;
  -- fields for SPIS_STATUS
  constant SPIS_STATUS_BUSY               : integer :=  0;
  constant SPIS_STATUS_US100_ERR          : integer :=  1;
  constant SPIS_STATUS_SPI0_OK            : integer :=  2;
  constant SPIS_STATUS_SPI1_OK            : integer :=  3;
  constant SPIS_STATUS_SPI2_OK            : integer :=  4;
  constant SPIS_STATUS_Z_CROSS_ERR        : integer :=  5;
  -- fields for SPI_RAW0_BA
  subtype  SPI_RAW0_BA_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW0_BA_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW0_BA_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW0_BA_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW0_DC
  subtype  SPI_RAW0_DC_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW0_DC_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW0_DC_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW0_DC_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW0_0E
  subtype  SPI_RAW0_0E_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW0_0E_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW0_0E_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW0_0E_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW2_BA
  subtype  SPI_RAW2_BA_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW2_BA_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW2_BA_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW2_BA_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW2_DC
  subtype  SPI_RAW2_DC_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW2_DC_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW2_DC_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW2_DC_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW2_FE
  subtype  SPI_RAW2_FE_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW2_FE_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW2_FE_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW2_FE_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_RAW2_HG
  subtype  SPI_RAW2_HG_L_D_RANGE          is integer range 11 downto  0;
  subtype  SPI_RAW2_HG_L_ID_RANGE         is integer range 15 downto 12;
  subtype  SPI_RAW2_HG_H_D_RANGE          is integer range 27 downto 16;
  subtype  SPI_RAW2_HG_H_ID_RANGE         is integer range 31 downto 28;
  -- fields for SPI_OUT4_Isns
  subtype  SPI_OUT4_Isns_d                is integer range 15 downto  0;
  -- fields for SPI_DC_PWR_I_sns
  subtype  SPI_DC_PWR_I_sns_d             is integer range 15 downto  0;
  -- fields for SPI_PH1_I_sns
  subtype  SPI_PH1_I_sns_d                is integer range 15 downto  0;
  -- fields for SPI_PH2_I_sns
  subtype  SPI_PH2_I_sns_d                is integer range 15 downto  0;
  -- fields for SPI_PH3_I_sns
  subtype  SPI_PH3_I_sns_d                is integer range 15 downto  0;
  -- fields for SPI_28V_IN_sns
  subtype  SPI_28V_IN_sns_d               is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH_A_RLY
  subtype  SPI_Vsns_PH_A_RLY_d            is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH_B_RLY
  subtype  SPI_Vsns_PH_B_RLY_d            is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH_C_RLY
  subtype  SPI_Vsns_PH_C_RLY_d            is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH3
  subtype  SPI_Vsns_PH3_d                 is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH2
  subtype  SPI_Vsns_PH2_d                 is integer range 15 downto  0;
  -- fields for SPI_Vsns_PH1
  subtype  SPI_Vsns_PH1_d                 is integer range 15 downto  0;
  -- fields for SPI_OUT4_sns
  subtype  SPI_OUT4_sns_d                 is integer range 15 downto  0;
  -- fields for SPI_RMS_OUT4_Isns
  subtype  SPI_RMS_OUT4_Isns_d            is integer range 15 downto  0;
  -- fields for SPI_RMS_PH1_I_sns
  subtype  SPI_RMS_PH1_I_sns_d            is integer range 15 downto  0;
  -- fields for SPI_RMS_PH2_I_sns
  subtype  SPI_RMS_PH2_I_sns_d            is integer range 15 downto  0;
  -- fields for SPI_RMS_PH3_I_sns
  subtype  SPI_RMS_PH3_I_sns_d            is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH_A_RLY
  subtype  SPI_RMS_Vsns_PH_A_RLY_d        is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH_B_RLY
  subtype  SPI_RMS_Vsns_PH_B_RLY_d        is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH_C_RLY
  subtype  SPI_RMS_Vsns_PH_C_RLY_d        is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH3
  subtype  SPI_RMS_Vsns_PH3_d             is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH2
  subtype  SPI_RMS_Vsns_PH2_d             is integer range 15 downto  0;
  -- fields for SPI_RMS_Vsns_PH1
  subtype  SPI_RMS_Vsns_PH1_d             is integer range 15 downto  0;
  -- fields for SPI_RMS_OUT4_sns
  subtype  SPI_RMS_OUT4_sns_d             is integer range 15 downto  0;
  -- fields for LIMITS0
  constant LIMITS0_uvp                    : integer :=  0;
  constant LIMITS0_uvp_ph1                : integer :=  1;
  constant LIMITS0_uvp_ph2                : integer :=  2;
  constant LIMITS0_uvp_ph3                : integer :=  3;
  constant LIMITS0_uvp_dc                 : integer :=  4;
  constant LIMITS0_stat_p_in              : integer :=  5;
  constant LIMITS0_stat_p_out             : integer :=  6;
  constant LIMITS0_stat_115_ac_in         : integer :=  7;
  constant LIMITS0_stat_115_a_in          : integer :=  8;
  constant LIMITS0_stat_115_b_in          : integer :=  9;
  constant LIMITS0_stat_115_c_in          : integer := 10;
  constant LIMITS0_stat_28_dc_in          : integer := 11;
  constant LIMITS0_stat_115_ac_out        : integer := 12;
  constant LIMITS0_stat_115_a_out         : integer := 13;
  constant LIMITS0_stat_115_b_out         : integer := 14;
  constant LIMITS0_stat_115_c_out         : integer := 15;
  constant LIMITS0_stat_v_out4_out        : integer := 16;
  constant LIMITS0_stat_dc1_out           : integer := 17;
  constant LIMITS0_stat_dc2_out           : integer := 18;
  constant LIMITS0_stat_dc5_out           : integer := 19;
  constant LIMITS0_stat_dc6_out           : integer := 20;
  constant LIMITS0_stat_dc7_out           : integer := 21;
  constant LIMITS0_stat_dc8_out           : integer := 22;
  constant LIMITS0_stat_dc9_out           : integer := 23;
  constant LIMITS0_stat_dc10_out          : integer := 24;
  constant LIMITS0_relay_3p               : integer := 25;
  constant LIMITS0_relay_3p_a             : integer := 26;
  constant LIMITS0_relay_3p_b             : integer := 27;
  constant LIMITS0_relay_3p_c             : integer := 28;
  constant LIMITS0_lamp_28vdc             : integer := 29;
  constant LIMITS0_lamp_115vac            : integer := 30;
  constant LIMITS0_ovp_error              : integer := 31;
  -- fields for LIMITS1
  constant LIMITS1_ovp_Vsns_PH_A_RLY      : integer :=  0;
  constant LIMITS1_ovp_Vsns_PH_B_RLY      : integer :=  1;
  constant LIMITS1_ovp_Vsns_PH_C_RLY      : integer :=  2;
  constant LIMITS1_ovp_Vsns_PH1           : integer :=  3;
  constant LIMITS1_ovp_Vsns_PH2           : integer :=  4;
  constant LIMITS1_ovp_Vsns_PH3           : integer :=  5;
  constant LIMITS1_ovp_OUT4_sns           : integer :=  6;
  constant LIMITS1_ovp_Vsns_28V_IN        : integer :=  7;
  constant LIMITS1_ovp_VOUT_1             : integer :=  8;
  constant LIMITS1_ovp_VOUT_2             : integer :=  9;
  constant LIMITS1_ovp_VOUT_5             : integer := 10;
  constant LIMITS1_ovp_VOUT_6             : integer := 11;
  constant LIMITS1_ovp_VOUT_7             : integer := 12;
  constant LIMITS1_ovp_VOUT_8             : integer := 13;
  constant LIMITS1_ovp_VOUT_9             : integer := 14;
  constant LIMITS1_ovp_VOUT_10            : integer := 15;
  constant LIMITS1_otp                    : integer := 16;
  constant LIMITS1_otp_t1                 : integer := 17;
  constant LIMITS1_otp_t2                 : integer := 18;
  constant LIMITS1_otp_t3                 : integer := 19;
  constant LIMITS1_otp_t4                 : integer := 20;
  constant LIMITS1_otp_t5                 : integer := 21;
  constant LIMITS1_otp_t6                 : integer := 22;
  constant LIMITS1_otp_t7                 : integer := 23;
  constant LIMITS1_otp_t8                 : integer := 24;
  constant LIMITS1_otp_t9                 : integer := 25;
  constant LIMITS1_fans                   : integer := 26;
  constant LIMITS1_fan1                   : integer := 27;
  constant LIMITS1_fan2                   : integer := 28;
  constant LIMITS1_fan3                   : integer := 29;
  -- fields for PSU_STAT_LIVE_L
  constant PSU_STAT_LIVE_L_DC_IN_Status   : integer :=  0;
  constant PSU_STAT_LIVE_L_AC_IN_Status   : integer :=  1;
  constant PSU_STAT_LIVE_L_Power_Out_Status : integer :=  2;
  constant PSU_STAT_LIVE_L_MIU_COM_Status : integer :=  3;
  constant PSU_STAT_LIVE_L_OUT1_OC        : integer :=  4;
  constant PSU_STAT_LIVE_L_OUT2_OC        : integer :=  5;
  constant PSU_STAT_LIVE_L_OUT3_OC        : integer :=  6;
  constant PSU_STAT_LIVE_L_OUT4_OC        : integer :=  7;
  constant PSU_STAT_LIVE_L_OUT5_OC        : integer :=  8;
  constant PSU_STAT_LIVE_L_OUT6_OC        : integer :=  9;
  constant PSU_STAT_LIVE_L_OUT7_OC        : integer := 10;
  constant PSU_STAT_LIVE_L_OUT8_OC        : integer := 11;
  constant PSU_STAT_LIVE_L_OUT9_OC        : integer := 12;
  constant PSU_STAT_LIVE_L_OUT10_OC       : integer := 13;
  constant PSU_STAT_LIVE_L_DC_IN_OV       : integer := 14;
  constant PSU_STAT_LIVE_L_AC_IN_PH1_OV   : integer := 15;
  constant PSU_STAT_LIVE_L_AC_IN_PH2_OV   : integer := 16;
  constant PSU_STAT_LIVE_L_AC_IN_PH3_OV   : integer := 17;
  constant PSU_STAT_LIVE_L_OUT1_OV        : integer := 18;
  constant PSU_STAT_LIVE_L_OUT2_OV        : integer := 19;
  constant PSU_STAT_LIVE_L_OUT3_OV        : integer := 20;
  constant PSU_STAT_LIVE_L_OUT4_OV        : integer := 21;
  constant PSU_STAT_LIVE_L_OUT5_OV        : integer := 22;
  constant PSU_STAT_LIVE_L_OUT6_OV        : integer := 23;
  constant PSU_STAT_LIVE_L_OUT7_OV        : integer := 24;
  constant PSU_STAT_LIVE_L_OUT8_OV        : integer := 25;
  constant PSU_STAT_LIVE_L_OUT9_OV        : integer := 26;
  constant PSU_STAT_LIVE_L_OUT10_OV       : integer := 27;
  constant PSU_STAT_LIVE_L_DC_IN_UV       : integer := 28;
  constant PSU_STAT_LIVE_L_AC_IN_PH1_UV   : integer := 29;
  constant PSU_STAT_LIVE_L_AC_IN_PH2_UV   : integer := 30;
  constant PSU_STAT_LIVE_L_AC_IN_PH3_UV   : integer := 31;
  -- fields for PSU_STAT_LIVE_H
  constant PSU_STAT_LIVE_H_AC_IN_PH1_Status : integer :=  0;
  constant PSU_STAT_LIVE_H_AC_IN_PH2_Status : integer :=  1;
  constant PSU_STAT_LIVE_H_AC_IN_PH3_Status : integer :=  2;
  constant PSU_STAT_LIVE_H_AC_IN_Neutral_Status : integer :=  3;
  constant PSU_STAT_LIVE_H_Is_Logfile_Running : integer :=  4;
  constant PSU_STAT_LIVE_H_Is_Logfile_Erase_In_Process : integer :=  5;
  constant PSU_STAT_LIVE_H_Fan1_Speed_Status : integer :=  6;
  constant PSU_STAT_LIVE_H_Fan2_Speed_Status : integer :=  7;
  constant PSU_STAT_LIVE_H_Fan3_Speed_Status : integer :=  8;
  constant PSU_STAT_LIVE_H_T1_OVER_TEMP_Status : integer :=  9;
  constant PSU_STAT_LIVE_H_T2_OVER_TEMP_Status : integer := 10;
  constant PSU_STAT_LIVE_H_T3_OVER_TEMP_Status : integer := 11;
  constant PSU_STAT_LIVE_H_T4_OVER_TEMP_Status : integer := 12;
  constant PSU_STAT_LIVE_H_T5_OVER_TEMP_Status : integer := 13;
  constant PSU_STAT_LIVE_H_T6_OVER_TEMP_Status : integer := 14;
  constant PSU_STAT_LIVE_H_T7_OVER_TEMP_Status : integer := 15;
  constant PSU_STAT_LIVE_H_T8_OVER_TEMP_Status : integer := 16;
  constant PSU_STAT_LIVE_H_T9_OVER_TEMP_Status : integer := 17;
  constant PSU_STAT_LIVE_H_CC_TCU_Inhibit : integer := 18;
  constant PSU_STAT_LIVE_H_EC_TCU_Inhibit : integer := 19;
  constant PSU_STAT_LIVE_H_Reset          : integer := 20;
  constant PSU_STAT_LIVE_H_Shutdown       : integer := 21;
  constant PSU_STAT_LIVE_H_Emergency_Shutdown : integer := 22;
  constant PSU_STAT_LIVE_H_System_Off     : integer := 23;
  constant PSU_STAT_LIVE_H_ON_OFF_Switch_State : integer := 24;
  constant PSU_STAT_LIVE_H_Capacitor1_end_of_life : integer := 25;
  constant PSU_STAT_LIVE_H_Capacitor2_end_of_life : integer := 26;
  constant PSU_STAT_LIVE_H_Capacitor3_end_of_life : integer := 27;
  constant PSU_STAT_LIVE_H_Capacitor4_end_of_life : integer := 28;
  constant PSU_STAT_LIVE_H_Capacitor5_end_of_life : integer := 29;
  constant PSU_STAT_LIVE_H_Capacitor6_end_of_life : integer := 30;
  constant PSU_STAT_LIVE_H_Capacitor7_end_of_life : integer := 31;

  ----------------------------------------------------------------------------------
  -- Register Reset value (defalut is 0)                                            
  ----------------------------------------------------------------------------------
  constant REGISTERS_INIT : reg_array_t := (
    REGS_VERSION         => X"00010005",
    GENERAL_CONTROL      => X"00000F00",
    others               => X"00000000"
  );

  ----------------------------------------------------------------------------------
  -- Readable registers, in this mechanizm, for now, all registers are readable     
  ----------------------------------------------------------------------------------
  constant READABLE_REGISTERS : reg_slv_array_t := (
    NO_REG => '0',
    others => '1'
  );

  ----------------------------------------------------------------------------------
  -- writeable bits                                                                 
  ----------------------------------------------------------------------------------
  constant WRITEABLE_REGS : reg_array_t := (
    BITSTREAM_TIME       => X"FFFFFFFF",
    GENERAL_CONTROL      => X"0000FFFF",
    GENERAL_STATUS       => X"0000007F",
    PSU_CONTROL          => X"00000001",
    CPU_STATUS           => X"0000001F",
    TIMESTAMP_L          => X"FFFFFFFF",
    TIMESTAMP_H          => X"FFFFFFFF",
    IO_IN                => X"000FFFFF",
    IO_OUT0              => X"03FFF7FF",
    IO_OUT1              => X"000001FF",
    LOG_VDC_IN           => X"0000FFFF",
    LOG_VAC_IN_PH_A      => X"0000FFFF",
    LOG_VAC_IN_PH_B      => X"0000FFFF",
    LOG_VAC_IN_PH_C      => X"0000FFFF",
    LOG_I_DC_IN          => X"0000FFFF",
    LOG_I_AC_IN_PH_A     => X"0000FFFF",
    LOG_I_AC_IN_PH_B     => X"0000FFFF",
    LOG_I_AC_IN_PH_C     => X"0000FFFF",
    LOG_V_OUT_1          => X"0000FFFF",
    LOG_V_OUT_2          => X"0000FFFF",
    LOG_V_OUT_3_PH1      => X"0000FFFF",
    LOG_V_OUT_3_PH2      => X"0000FFFF",
    LOG_V_OUT_3_PH3      => X"0000FFFF",
    LOG_V_OUT_4          => X"0000FFFF",
    LOG_V_OUT_5          => X"0000FFFF",
    LOG_V_OUT_6          => X"0000FFFF",
    LOG_V_OUT_7          => X"0000FFFF",
    LOG_V_OUT_8          => X"0000FFFF",
    LOG_V_OUT_9          => X"0000FFFF",
    LOG_V_OUT_10         => X"0000FFFF",
    LOG_I_OUT_1          => X"0000FFFF",
    LOG_I_OUT_2          => X"0000FFFF",
    LOG_I_OUT_3_PH1      => X"0000FFFF",
    LOG_I_OUT_3_PH2      => X"0000FFFF",
    LOG_I_OUT_3_PH3      => X"0000FFFF",
    LOG_I_OUT_4          => X"0000FFFF",
    LOG_I_OUT_5          => X"0000FFFF",
    LOG_I_OUT_6          => X"0000FFFF",
    LOG_I_OUT_7          => X"0000FFFF",
    LOG_I_OUT_8          => X"0000FFFF",
    LOG_I_OUT_9          => X"0000FFFF",
    LOG_I_OUT_10         => X"0000FFFF",
    LOG_AC_POWER         => X"0000FFFF",
    LOG_FAN1_SPEED       => X"0000FFFF",
    LOG_FAN2_SPEED       => X"0000FFFF",
    LOG_FAN3_SPEED       => X"0000FFFF",
    LOG_T1               => X"000000FF",
    LOG_T2               => X"000000FF",
    LOG_T3               => X"000000FF",
    LOG_T4               => X"000000FF",
    LOG_T5               => X"000000FF",
    LOG_T6               => X"000000FF",
    LOG_T7               => X"000000FF",
    LOG_T8               => X"000000FF",
    LOG_T9               => X"000000FF",
    LOG_PSU_STATUS_L     => X"FFFFFFFF",
    LOG_PSU_STATUS_H     => X"FFFFFFFF",
    LOG_LAMP_IND         => X"FFFFFFFF",
    PWM_CTL              => X"0000003F",
    PWM1_LOW             => X"FFFFFFFF",
    PWM1_HIGH            => X"FFFFFFFF",
    PWM2_LOW             => X"FFFFFFFF",
    PWM2_HIGH            => X"FFFFFFFF",
    PWM3_LOW             => X"FFFFFFFF",
    PWM3_HIGH            => X"FFFFFFFF",
    UARTS_CONTROL        => X"000007FF",
    UARTS_STATUS         => X"00000003",
    UART_RAW0_L          => X"FFFFFFFF",
    UART_RAW0_H          => X"FFFFFFFF",
    UART_RAW1_L          => X"FFFFFFFF",
    UART_RAW1_H          => X"FFFFFFFF",
    UART_RAW2_L          => X"FFFFFFFF",
    UART_RAW2_H          => X"FFFFFFFF",
    UART_RAW3_L          => X"FFFFFFFF",
    UART_RAW3_H          => X"FFFFFFFF",
    UART_RAW4_L          => X"FFFFFFFF",
    UART_RAW4_H          => X"FFFFFFFF",
    UART_RAW5_L          => X"FFFFFFFF",
    UART_RAW5_H          => X"FFFFFFFF",
    UART_RAW6_L          => X"FFFFFFFF",
    UART_RAW6_H          => X"FFFFFFFF",
    UART_RAW7_L          => X"FFFFFFFF",
    UART_RAW7_H          => X"FFFFFFFF",
    UART_RAW8_L          => X"FFFFFFFF",
    UART_RAW8_H          => X"00FFFFFF",
    UART_V_OUT_1         => X"0000FFFF",
    UART_V_OUT_2         => X"0000FFFF",
    UART_V_OUT_5         => X"0000FFFF",
    UART_V_OUT_6         => X"0000FFFF",
    UART_V_OUT_7         => X"0000FFFF",
    UART_V_OUT_8         => X"0000FFFF",
    UART_V_OUT_9         => X"0000FFFF",
    UART_V_OUT_10        => X"0000FFFF",
    UART_I_OUT_1         => X"0000FFFF",
    UART_I_OUT_2         => X"0000FFFF",
    UART_I_OUT_5         => X"0000FFFF",
    UART_I_OUT_6         => X"0000FFFF",
    UART_I_OUT_7         => X"0000FFFF",
    UART_I_OUT_8         => X"0000FFFF",
    UART_I_OUT_9         => X"0000FFFF",
    UART_I_OUT_10        => X"0000FFFF",
    UART_T1              => X"00000FFF",
    UART_T2              => X"00000FFF",
    UART_T3              => X"00000FFF",
    UART_T4              => X"00000FFF",
    UART_T5              => X"00000FFF",
    UART_T6              => X"00000FFF",
    UART_T7              => X"00000FFF",
    UART_T8              => X"00000FFF",
    UART_T9              => X"00000FFF",
    UART_MAIN_I_PH1      => X"0000FFFF",
    UART_MAIN_I_PH2      => X"0000FFFF",
    UART_MAIN_I_PH3      => X"0000FFFF",
    SPIS_CONTROL         => X"0000003F",
    SPIS_STATUS          => X"0000003F",
    SPI_RAW0_BA          => X"FFFFFFFF",
    SPI_RAW0_DC          => X"FFFFFFFF",
    SPI_RAW0_0E          => X"FFFFFFFF",
    SPI_RAW2_BA          => X"FFFFFFFF",
    SPI_RAW2_DC          => X"FFFFFFFF",
    SPI_RAW2_FE          => X"FFFFFFFF",
    SPI_RAW2_HG          => X"FFFFFFFF",
    SPI_OUT4_Isns        => X"0000FFFF",
    SPI_DC_PWR_I_sns     => X"0000FFFF",
    SPI_PH1_I_sns        => X"0000FFFF",
    SPI_PH2_I_sns        => X"0000FFFF",
    SPI_PH3_I_sns        => X"0000FFFF",
    SPI_28V_IN_sns       => X"0000FFFF",
    SPI_Vsns_PH_A_RLY    => X"0000FFFF",
    SPI_Vsns_PH_B_RLY    => X"0000FFFF",
    SPI_Vsns_PH_C_RLY    => X"0000FFFF",
    SPI_Vsns_PH3         => X"0000FFFF",
    SPI_Vsns_PH2         => X"0000FFFF",
    SPI_Vsns_PH1         => X"0000FFFF",
    SPI_OUT4_sns         => X"0000FFFF",
    SPI_RMS_OUT4_Isns    => X"0000FFFF",
    SPI_RMS_PH1_I_sns    => X"0000FFFF",
    SPI_RMS_PH2_I_sns    => X"0000FFFF",
    SPI_RMS_PH3_I_sns    => X"0000FFFF",
    SPI_RMS_Vsns_PH_A_RLY => X"0000FFFF",
    SPI_RMS_Vsns_PH_B_RLY => X"0000FFFF",
    SPI_RMS_Vsns_PH_C_RLY => X"0000FFFF",
    SPI_RMS_Vsns_PH3     => X"0000FFFF",
    SPI_RMS_Vsns_PH2     => X"0000FFFF",
    SPI_RMS_Vsns_PH1     => X"0000FFFF",
    SPI_RMS_OUT4_sns     => X"0000FFFF",
    LIMITS0              => X"FFFFFFFF",
    LIMITS1              => X"3FFFFFFF",
    PSU_STAT_LIVE_L      => X"FFFFFFFF",
    PSU_STAT_LIVE_H      => X"FFFFFFFF",
    others               => X"00000000"
  );

  ----------------------------------------------------------------------------------
  -- Registers writeable by FPGA internaly (as a list not by address)               
  ----------------------------------------------------------------------------------
  constant INTERNALY_WRITEABLE_REGS : reg_slv_array_t := (
    BITSTREAM_TIME       => '1',
    GENERAL_STATUS       => '1',
    TIMESTAMP_L          => '1',
    TIMESTAMP_H          => '1',
    IO_IN                => '1',
    IO_OUT0              => '1',
    IO_OUT1              => '1',
    LOG_VDC_IN           => '1',
    LOG_VAC_IN_PH_A      => '1',
    LOG_VAC_IN_PH_B      => '1',
    LOG_VAC_IN_PH_C      => '1',
    LOG_I_DC_IN          => '1',
    LOG_I_AC_IN_PH_A     => '1',
    LOG_I_AC_IN_PH_B     => '1',
    LOG_I_AC_IN_PH_C     => '1',
    LOG_V_OUT_1          => '1',
    LOG_V_OUT_2          => '1',
    LOG_V_OUT_3_PH1      => '1',
    LOG_V_OUT_3_PH2      => '1',
    LOG_V_OUT_3_PH3      => '1',
    LOG_V_OUT_4          => '1',
    LOG_V_OUT_5          => '1',
    LOG_V_OUT_6          => '1',
    LOG_V_OUT_7          => '1',
    LOG_V_OUT_8          => '1',
    LOG_V_OUT_9          => '1',
    LOG_V_OUT_10         => '1',
    LOG_I_OUT_1          => '1',
    LOG_I_OUT_2          => '1',
    LOG_I_OUT_3_PH1      => '1',
    LOG_I_OUT_3_PH2      => '1',
    LOG_I_OUT_3_PH3      => '1',
    LOG_I_OUT_4          => '1',
    LOG_I_OUT_5          => '1',
    LOG_I_OUT_6          => '1',
    LOG_I_OUT_7          => '1',
    LOG_I_OUT_8          => '1',
    LOG_I_OUT_9          => '1',
    LOG_I_OUT_10         => '1',
    LOG_AC_POWER         => '1',
    LOG_FAN1_SPEED       => '1',
    LOG_FAN2_SPEED       => '1',
    LOG_FAN3_SPEED       => '1',
    LOG_T1               => '1',
    LOG_T2               => '1',
    LOG_T3               => '1',
    LOG_T4               => '1',
    LOG_T5               => '1',
    LOG_T6               => '1',
    LOG_T7               => '1',
    LOG_T8               => '1',
    LOG_T9               => '1',
    LOG_PSU_STATUS_L     => '1',
    LOG_PSU_STATUS_H     => '1',
    LOG_LAMP_IND         => '1',
    UARTS_STATUS         => '1',
    UART_RAW0_L          => '1',
    UART_RAW0_H          => '1',
    UART_RAW1_L          => '1',
    UART_RAW1_H          => '1',
    UART_RAW2_L          => '1',
    UART_RAW2_H          => '1',
    UART_RAW3_L          => '1',
    UART_RAW3_H          => '1',
    UART_RAW4_L          => '1',
    UART_RAW4_H          => '1',
    UART_RAW5_L          => '1',
    UART_RAW5_H          => '1',
    UART_RAW6_L          => '1',
    UART_RAW6_H          => '1',
    UART_RAW7_L          => '1',
    UART_RAW7_H          => '1',
    UART_RAW8_L          => '1',
    UART_RAW8_H          => '1',
    UART_V_OUT_1         => '1',
    UART_V_OUT_2         => '1',
    UART_V_OUT_5         => '1',
    UART_V_OUT_6         => '1',
    UART_V_OUT_7         => '1',
    UART_V_OUT_8         => '1',
    UART_V_OUT_9         => '1',
    UART_V_OUT_10        => '1',
    UART_I_OUT_1         => '1',
    UART_I_OUT_2         => '1',
    UART_I_OUT_5         => '1',
    UART_I_OUT_6         => '1',
    UART_I_OUT_7         => '1',
    UART_I_OUT_8         => '1',
    UART_I_OUT_9         => '1',
    UART_I_OUT_10        => '1',
    UART_T1              => '1',
    UART_T2              => '1',
    UART_T3              => '1',
    UART_T4              => '1',
    UART_T5              => '1',
    UART_T6              => '1',
    UART_T7              => '1',
    UART_T8              => '1',
    UART_T9              => '1',
    UART_MAIN_I_PH1      => '1',
    UART_MAIN_I_PH2      => '1',
    UART_MAIN_I_PH3      => '1',
    SPIS_STATUS          => '1',
    SPI_RAW0_BA          => '1',
    SPI_RAW0_DC          => '1',
    SPI_RAW0_0E          => '1',
    SPI_RAW2_BA          => '1',
    SPI_RAW2_DC          => '1',
    SPI_RAW2_FE          => '1',
    SPI_RAW2_HG          => '1',
    SPI_OUT4_Isns        => '1',
    SPI_DC_PWR_I_sns     => '1',
    SPI_PH1_I_sns        => '1',
    SPI_PH2_I_sns        => '1',
    SPI_PH3_I_sns        => '1',
    SPI_28V_IN_sns       => '1',
    SPI_Vsns_PH_A_RLY    => '1',
    SPI_Vsns_PH_B_RLY    => '1',
    SPI_Vsns_PH_C_RLY    => '1',
    SPI_Vsns_PH3         => '1',
    SPI_Vsns_PH2         => '1',
    SPI_Vsns_PH1         => '1',
    SPI_OUT4_sns         => '1',
    SPI_RMS_OUT4_Isns    => '1',
    SPI_RMS_PH1_I_sns    => '1',
    SPI_RMS_PH2_I_sns    => '1',
    SPI_RMS_PH3_I_sns    => '1',
    SPI_RMS_Vsns_PH_A_RLY => '1',
    SPI_RMS_Vsns_PH_B_RLY => '1',
    SPI_RMS_Vsns_PH_C_RLY => '1',
    SPI_RMS_Vsns_PH3     => '1',
    SPI_RMS_Vsns_PH2     => '1',
    SPI_RMS_Vsns_PH1     => '1',
    SPI_RMS_OUT4_sns     => '1',
    LIMITS0              => '1',
    LIMITS1              => '1',
    PSU_STAT_LIVE_L      => '1',
    PSU_STAT_LIVE_H      => '1',
    others               => '0'
  );

  ----------------------------------------------------------------------------------
  -- Registers writeable by CPU                                                     
  ----------------------------------------------------------------------------------
  constant CPU_WRITEABLE_REGS : reg_slv_array_t := (
    GENERAL_CONTROL      => '1',
    PSU_CONTROL          => '1',
    CPU_STATUS           => '1',
    IO_OUT0              => '1',
    IO_OUT1              => '1',
    PWM_CTL              => '1',
    PWM1_LOW             => '1',
    PWM1_HIGH            => '1',
    PWM2_LOW             => '1',
    PWM2_HIGH            => '1',
    PWM3_LOW             => '1',
    PWM3_HIGH            => '1',
    UARTS_CONTROL        => '1',
    SPIS_CONTROL         => '1',
    others               => '0'
  );

  --------------------------------------------------------------------------------------------------------
  -- Functions
  --------------------------------------------------------------------------------------------------------
  function "and" (left, right: reg_slv_array_t) return reg_slv_array_t;
  function "or" (left, right: reg_slv_array_t) return reg_slv_array_t;
  function "and" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t;
  function "or" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t;

end;

package body regs_pkg is
       function "and" (left, right: reg_slv_array_t) return reg_slv_array_t is
           variable o : reg_slv_array_t;
       begin
           for i in reg_slv_array_t'range loop
               o(i) := left(i) and right(i);
           end loop;
           return o;
       end;
       
       function "or" (left, right: reg_slv_array_t) return reg_slv_array_t is
           variable o : reg_slv_array_t;
       begin
           for i in reg_slv_array_t'range loop
               o(i) := left(i) or right(i);
           end loop;
           return o;
       end;
       
       function "and" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t is
           variable o : reg_slv_arrays_t(right'range);
       begin
           for i in right'range loop
               o(i) := left(i) and right(i);
           end loop;
           return o;
       end;
       
       function "or" (left, right: reg_slv_arrays_t) return reg_slv_arrays_t is
           variable o : reg_slv_arrays_t(right'range);
       begin
           for i in right'range loop
               o(i) := left(i) or right(i);
           end loop;
           return o;
       end;
end;
