------------------------------------------------------------------------------------------
-- Registers VHDL package created from yaml definition of registers at 27-06-2024 15:20 --
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
      TIMESTAMP_L         ,
      TIMESTAMP_H         ,
      IO_IN               ,
      IO_OUT0             ,
      IO_OUT1             ,
      SN_ETI              ,
      LOG_MESSAGE_ID      ,
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
      LOG_FAN_SPEED       ,
      LOG_FAN1_SPEED      ,
      LOG_FAN2_SPEED      ,
      LOG_FAN3_SPEED      ,
      LOG_VOLUME_SIZE_L   ,
      LOG_VOLUME_SIZE_H   ,
      LOG_LOGFILE_SIZE_L  ,
      LOG_LOGFILE_SIZE_H  ,
      LOG_T1              ,
      LOG_T2              ,
      LOG_T3              ,
      LOG_T4              ,
      LOG_T5              ,
      LOG_T6              ,
      LOG_T7              ,
      LOG_T8              ,
      LOG_T9              ,
      LOG_ETM             ,
      LOG_MAJOR           ,
      LOG_MINOR           ,
      LOG_BUILD           ,
      LOG_HOTFIX          ,
      LOG_SN              ,
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
      SPIS_CONTROL        ,
      SPIS_STATUS         ,
      SPI_RAW0_BA         ,
      SPI_RAW0_DC         ,
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
      SPI_Vsns_PH_A_RLY   ,
      SPI_Vsns_PH_B_RLY   ,
      SPI_Vsns_PH_C_RLY   ,
      SPI_Vsns_PH3        ,
      SPI_Vsns_PH2        ,
      SPI_Vsns_PH1        ,
      SPI_OUT4_sns        ,
      SPI_RMS_OUT4_Isns   ,
      SPI_RMS_DC_PWR_I_sns,
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
      NO_REG
  );
  constant NUM_REGS:  natural := 134;
  constant REGS_SPACE_SIZE : natural := 133;

  type regs_a_t is array(REGS_SPACE_SIZE - 1 downto 0) of regs_names_t;
  constant regs_a: regs_a_t := (
        0 => REGS_VERSION        ,
        1 => FPGA_VERSION        ,
        2 => COMPILE_TIME        ,
        3 => BITSTREAM_TIME      ,
        4 => GENERAL_CONTROL     ,
        5 => GENERAL_STATUS      ,
        6 => TIMESTAMP_L         ,
        7 => TIMESTAMP_H         ,
        8 => IO_IN               ,
        9 => IO_OUT0             ,
       10 => IO_OUT1             ,
       11 => SN_ETI              ,
       12 => LOG_MESSAGE_ID      ,
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
       46 => LOG_FAN_SPEED       ,
       47 => LOG_FAN1_SPEED      ,
       48 => LOG_FAN2_SPEED      ,
       49 => LOG_FAN3_SPEED      ,
       50 => LOG_VOLUME_SIZE_L   ,
       51 => LOG_VOLUME_SIZE_H   ,
       52 => LOG_LOGFILE_SIZE_L  ,
       53 => LOG_LOGFILE_SIZE_H  ,
       54 => LOG_T1              ,
       55 => LOG_T2              ,
       56 => LOG_T3              ,
       57 => LOG_T4              ,
       58 => LOG_T5              ,
       59 => LOG_T6              ,
       60 => LOG_T7              ,
       61 => LOG_T8              ,
       62 => LOG_T9              ,
       63 => LOG_ETM             ,
       64 => LOG_MAJOR           ,
       65 => LOG_MINOR           ,
       66 => LOG_BUILD           ,
       67 => LOG_HOTFIX          ,
       68 => LOG_SN              ,
       69 => LOG_PSU_STATUS_L    ,
       70 => LOG_PSU_STATUS_H    ,
       71 => LOG_LAMP_IND        ,
       72 => PWM_CTL             ,
       73 => PWM1_LOW            ,
       74 => PWM1_HIGH           ,
       75 => PWM2_LOW            ,
       76 => PWM2_HIGH           ,
       77 => PWM3_LOW            ,
       78 => PWM3_HIGH           ,
       79 => UARTS_CONTROL       ,
       80 => UARTS_STATUS        ,
       81 => UART_RAW0_L         ,
       82 => UART_RAW0_H         ,
       83 => UART_RAW1_L         ,
       84 => UART_RAW1_H         ,
       85 => UART_RAW2_L         ,
       86 => UART_RAW2_H         ,
       87 => UART_RAW3_L         ,
       88 => UART_RAW3_H         ,
       89 => UART_RAW4_L         ,
       90 => UART_RAW4_H         ,
       91 => UART_RAW5_L         ,
       92 => UART_RAW5_H         ,
       93 => UART_RAW6_L         ,
       94 => UART_RAW6_H         ,
       95 => UART_RAW7_L         ,
       96 => UART_RAW7_H         ,
       97 => UART_RAW8_L         ,
       98 => UART_RAW8_H         ,
       99 => SPIS_CONTROL        ,
      100 => SPIS_STATUS         ,
      101 => SPI_RAW0_BA         ,
      102 => SPI_RAW0_DC         ,
      103 => SPI_RAW1_BA         ,
      104 => SPI_RAW1_DC         ,
      105 => SPI_RAW2_BA         ,
      106 => SPI_RAW2_DC         ,
      107 => SPI_RAW2_FE         ,
      108 => SPI_RAW2_HG         ,
      109 => SPI_OUT4_Isns       ,
      110 => SPI_DC_PWR_I_sns    ,
      111 => SPI_PH1_I_sns       ,
      112 => SPI_PH2_I_sns       ,
      113 => SPI_PH3_I_sns       ,
      114 => SPI_Vsns_PH_A_RLY   ,
      115 => SPI_Vsns_PH_B_RLY   ,
      116 => SPI_Vsns_PH_C_RLY   ,
      117 => SPI_Vsns_PH3        ,
      118 => SPI_Vsns_PH2        ,
      119 => SPI_Vsns_PH1        ,
      120 => SPI_OUT4_sns        ,
      121 => SPI_RMS_OUT4_Isns   ,
      122 => SPI_RMS_DC_PWR_I_sns,
      123 => SPI_RMS_PH1_I_sns   ,
      124 => SPI_RMS_PH2_I_sns   ,
      125 => SPI_RMS_PH3_I_sns   ,
      126 => SPI_RMS_Vsns_PH_A_RLY,
      127 => SPI_RMS_Vsns_PH_B_RLY,
      128 => SPI_RMS_Vsns_PH_C_RLY,
      129 => SPI_RMS_Vsns_PH3    ,
      130 => SPI_RMS_Vsns_PH2    ,
      131 => SPI_RMS_Vsns_PH1    ,
      132 => SPI_RMS_OUT4_sns    ,
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
  constant GENERAL_CONTROL_ECTCU_INH      : integer :=  6;
  constant GENERAL_CONTROL_CCTCU_INH      : integer :=  7;
  constant GENERAL_CONTROL_UVP_EN_PH1     : integer :=  8;
  constant GENERAL_CONTROL_UVP_EN_PH2     : integer :=  9;
  constant GENERAL_CONTROL_UVP_EN_PH3     : integer := 10;
  constant GENERAL_CONTROL_UVP_EN_DC      : integer := 11;
  -- fields for GENERAL_STATUS
  constant GENERAL_STATUS_REGS_LOCKED     : integer :=  0;
  constant GENERAL_STATUS_STOP_LOG        : integer :=  1;
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
  constant IO_OUT0_RELAY_1PH_FPGA         : integer := 11;
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
  constant IO_OUT1_RS485_DE_3             : integer :=  5;
  constant IO_OUT1_RS485_DE_4             : integer :=  6;
  constant IO_OUT1_RS485_DE_5             : integer :=  7;
  constant IO_OUT1_RS485_DE_6             : integer :=  8;
  -- fields for SN_ETI
  subtype  SN_ETI_SN                      is integer range  7 downto  0;
  constant SN_ETI_SET_SN                  : integer :=  8;
  constant SN_ETI_RESET_ETI               : integer :=  9;
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
  subtype  SPI_OUT4_Isns_L_D_RANGE        is integer range 11 downto  0;
  subtype  SPI_OUT4_Isns_L_ID_RANGE       is integer range 15 downto 12;
  subtype  SPI_OUT4_Isns_H_D_RANGE        is integer range 27 downto 16;
  subtype  SPI_OUT4_Isns_H_ID_RANGE       is integer range 31 downto 28;
  -- fields for SPI_DC_PWR_I_sns
  subtype  SPI_DC_PWR_I_sns_L_D_RANGE     is integer range 11 downto  0;
  subtype  SPI_DC_PWR_I_sns_L_ID_RANGE    is integer range 15 downto 12;
  subtype  SPI_DC_PWR_I_sns_H_D_RANGE     is integer range 27 downto 16;
  subtype  SPI_DC_PWR_I_sns_H_ID_RANGE    is integer range 31 downto 28;
  -- fields for SPI_PH1_I_sns
  subtype  SPI_PH1_I_sns_L_D_RANGE        is integer range 11 downto  0;
  subtype  SPI_PH1_I_sns_L_ID_RANGE       is integer range 15 downto 12;
  subtype  SPI_PH1_I_sns_H_D_RANGE        is integer range 27 downto 16;
  subtype  SPI_PH1_I_sns_H_ID_RANGE       is integer range 31 downto 28;
  -- fields for SPI_PH2_I_sns
  subtype  SPI_PH2_I_sns_L_D_RANGE        is integer range 11 downto  0;
  subtype  SPI_PH2_I_sns_L_ID_RANGE       is integer range 15 downto 12;
  subtype  SPI_PH2_I_sns_H_D_RANGE        is integer range 27 downto 16;
  subtype  SPI_PH2_I_sns_H_ID_RANGE       is integer range 31 downto 28;
  -- fields for SPI_PH3_I_sns
  subtype  SPI_PH3_I_sns_L_D_RANGE        is integer range 11 downto  0;
  subtype  SPI_PH3_I_sns_L_ID_RANGE       is integer range 15 downto 12;
  subtype  SPI_PH3_I_sns_H_D_RANGE        is integer range 27 downto 16;
  subtype  SPI_PH3_I_sns_H_ID_RANGE       is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH_A_RLY
  subtype  SPI_Vsns_PH_A_RLY_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_Vsns_PH_A_RLY_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_Vsns_PH_A_RLY_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_Vsns_PH_A_RLY_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH_B_RLY
  subtype  SPI_Vsns_PH_B_RLY_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_Vsns_PH_B_RLY_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_Vsns_PH_B_RLY_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_Vsns_PH_B_RLY_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH_C_RLY
  subtype  SPI_Vsns_PH_C_RLY_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_Vsns_PH_C_RLY_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_Vsns_PH_C_RLY_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_Vsns_PH_C_RLY_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH3
  subtype  SPI_Vsns_PH3_L_D_RANGE         is integer range 11 downto  0;
  subtype  SPI_Vsns_PH3_L_ID_RANGE        is integer range 15 downto 12;
  subtype  SPI_Vsns_PH3_H_D_RANGE         is integer range 27 downto 16;
  subtype  SPI_Vsns_PH3_H_ID_RANGE        is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH2
  subtype  SPI_Vsns_PH2_L_D_RANGE         is integer range 11 downto  0;
  subtype  SPI_Vsns_PH2_L_ID_RANGE        is integer range 15 downto 12;
  subtype  SPI_Vsns_PH2_H_D_RANGE         is integer range 27 downto 16;
  subtype  SPI_Vsns_PH2_H_ID_RANGE        is integer range 31 downto 28;
  -- fields for SPI_Vsns_PH1
  subtype  SPI_Vsns_PH1_L_D_RANGE         is integer range 11 downto  0;
  subtype  SPI_Vsns_PH1_L_ID_RANGE        is integer range 15 downto 12;
  subtype  SPI_Vsns_PH1_H_D_RANGE         is integer range 27 downto 16;
  subtype  SPI_Vsns_PH1_H_ID_RANGE        is integer range 31 downto 28;
  -- fields for SPI_OUT4_sns
  subtype  SPI_OUT4_sns_L_D_RANGE         is integer range 11 downto  0;
  subtype  SPI_OUT4_sns_L_ID_RANGE        is integer range 15 downto 12;
  subtype  SPI_OUT4_sns_H_D_RANGE         is integer range 27 downto 16;
  subtype  SPI_OUT4_sns_H_ID_RANGE        is integer range 31 downto 28;
  -- fields for SPI_RMS_OUT4_Isns
  subtype  SPI_RMS_OUT4_Isns_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_RMS_OUT4_Isns_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_RMS_OUT4_Isns_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_RMS_OUT4_Isns_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_RMS_DC_PWR_I_sns
  subtype  SPI_RMS_DC_PWR_I_sns_L_D_RANGE is integer range 11 downto  0;
  subtype  SPI_RMS_DC_PWR_I_sns_L_ID_RANGE is integer range 15 downto 12;
  subtype  SPI_RMS_DC_PWR_I_sns_H_D_RANGE is integer range 27 downto 16;
  subtype  SPI_RMS_DC_PWR_I_sns_H_ID_RANGE is integer range 31 downto 28;
  -- fields for SPI_RMS_PH1_I_sns
  subtype  SPI_RMS_PH1_I_sns_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_RMS_PH1_I_sns_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_RMS_PH1_I_sns_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_RMS_PH1_I_sns_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_RMS_PH2_I_sns
  subtype  SPI_RMS_PH2_I_sns_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_RMS_PH2_I_sns_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_RMS_PH2_I_sns_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_RMS_PH2_I_sns_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_RMS_PH3_I_sns
  subtype  SPI_RMS_PH3_I_sns_L_D_RANGE    is integer range 11 downto  0;
  subtype  SPI_RMS_PH3_I_sns_L_ID_RANGE   is integer range 15 downto 12;
  subtype  SPI_RMS_PH3_I_sns_H_D_RANGE    is integer range 27 downto 16;
  subtype  SPI_RMS_PH3_I_sns_H_ID_RANGE   is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH_A_RLY
  subtype  SPI_RMS_Vsns_PH_A_RLY_L_D_RANGE is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH_A_RLY_L_ID_RANGE is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH_A_RLY_H_D_RANGE is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH_A_RLY_H_ID_RANGE is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH_B_RLY
  subtype  SPI_RMS_Vsns_PH_B_RLY_L_D_RANGE is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH_B_RLY_L_ID_RANGE is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH_B_RLY_H_D_RANGE is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH_B_RLY_H_ID_RANGE is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH_C_RLY
  subtype  SPI_RMS_Vsns_PH_C_RLY_L_D_RANGE is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH_C_RLY_L_ID_RANGE is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH_C_RLY_H_D_RANGE is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH_C_RLY_H_ID_RANGE is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH3
  subtype  SPI_RMS_Vsns_PH3_L_D_RANGE     is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH3_L_ID_RANGE    is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH3_H_D_RANGE     is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH3_H_ID_RANGE    is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH2
  subtype  SPI_RMS_Vsns_PH2_L_D_RANGE     is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH2_L_ID_RANGE    is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH2_H_D_RANGE     is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH2_H_ID_RANGE    is integer range 31 downto 28;
  -- fields for SPI_RMS_Vsns_PH1
  subtype  SPI_RMS_Vsns_PH1_L_D_RANGE     is integer range 11 downto  0;
  subtype  SPI_RMS_Vsns_PH1_L_ID_RANGE    is integer range 15 downto 12;
  subtype  SPI_RMS_Vsns_PH1_H_D_RANGE     is integer range 27 downto 16;
  subtype  SPI_RMS_Vsns_PH1_H_ID_RANGE    is integer range 31 downto 28;
  -- fields for SPI_RMS_OUT4_sns
  subtype  SPI_RMS_OUT4_sns_L_D_RANGE     is integer range 11 downto  0;
  subtype  SPI_RMS_OUT4_sns_L_ID_RANGE    is integer range 15 downto 12;
  subtype  SPI_RMS_OUT4_sns_H_D_RANGE     is integer range 27 downto 16;
  subtype  SPI_RMS_OUT4_sns_H_ID_RANGE    is integer range 31 downto 28;

  ----------------------------------------------------------------------------------
  -- Register Reset value (defalut is 0)                                            
  ----------------------------------------------------------------------------------
  constant REGISTERS_INIT : reg_array_t := (
    REGS_VERSION         => X"00010004",
    GENERAL_CONTROL      => X"00000F00",
    UARTS_CONTROL        => X"0000001F",
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
    GENERAL_CONTROL      => X"00000FFF",
    GENERAL_STATUS       => X"00000003",
    TIMESTAMP_L          => X"FFFFFFFF",
    TIMESTAMP_H          => X"FFFFFFFF",
    IO_IN                => X"000FFFFF",
    IO_OUT0              => X"03FFFFFF",
    IO_OUT1              => X"000001FF",
    SN_ETI               => X"000003FF",
    LOG_MESSAGE_ID       => X"FFFFFFFF",
    LOG_VDC_IN           => X"FFFFFFFF",
    LOG_VAC_IN_PH_A      => X"FFFFFFFF",
    LOG_VAC_IN_PH_B      => X"FFFFFFFF",
    LOG_VAC_IN_PH_C      => X"FFFFFFFF",
    LOG_I_DC_IN          => X"FFFFFFFF",
    LOG_I_AC_IN_PH_A     => X"FFFFFFFF",
    LOG_I_AC_IN_PH_B     => X"FFFFFFFF",
    LOG_I_AC_IN_PH_C     => X"FFFFFFFF",
    LOG_V_OUT_1          => X"FFFFFFFF",
    LOG_V_OUT_2          => X"FFFFFFFF",
    LOG_V_OUT_3_PH1      => X"FFFFFFFF",
    LOG_V_OUT_3_PH2      => X"FFFFFFFF",
    LOG_V_OUT_3_PH3      => X"FFFFFFFF",
    LOG_V_OUT_4          => X"FFFFFFFF",
    LOG_V_OUT_5          => X"FFFFFFFF",
    LOG_V_OUT_6          => X"FFFFFFFF",
    LOG_V_OUT_7          => X"FFFFFFFF",
    LOG_V_OUT_8          => X"FFFFFFFF",
    LOG_V_OUT_9          => X"FFFFFFFF",
    LOG_V_OUT_10         => X"FFFFFFFF",
    LOG_I_OUT_1          => X"FFFFFFFF",
    LOG_I_OUT_2          => X"FFFFFFFF",
    LOG_I_OUT_3_PH1      => X"FFFFFFFF",
    LOG_I_OUT_3_PH2      => X"FFFFFFFF",
    LOG_I_OUT_3_PH3      => X"FFFFFFFF",
    LOG_I_OUT_4          => X"FFFFFFFF",
    LOG_I_OUT_5          => X"FFFFFFFF",
    LOG_I_OUT_6          => X"FFFFFFFF",
    LOG_I_OUT_7          => X"FFFFFFFF",
    LOG_I_OUT_8          => X"FFFFFFFF",
    LOG_I_OUT_9          => X"FFFFFFFF",
    LOG_I_OUT_10         => X"FFFFFFFF",
    LOG_AC_POWER         => X"FFFFFFFF",
    LOG_FAN_SPEED        => X"FFFFFFFF",
    LOG_FAN1_SPEED       => X"FFFFFFFF",
    LOG_FAN2_SPEED       => X"FFFFFFFF",
    LOG_FAN3_SPEED       => X"FFFFFFFF",
    LOG_VOLUME_SIZE_L    => X"FFFFFFFF",
    LOG_VOLUME_SIZE_H    => X"FFFFFFFF",
    LOG_LOGFILE_SIZE_L   => X"FFFFFFFF",
    LOG_LOGFILE_SIZE_H   => X"FFFFFFFF",
    LOG_T1               => X"FFFFFFFF",
    LOG_T2               => X"FFFFFFFF",
    LOG_T3               => X"FFFFFFFF",
    LOG_T4               => X"FFFFFFFF",
    LOG_T5               => X"FFFFFFFF",
    LOG_T6               => X"FFFFFFFF",
    LOG_T7               => X"FFFFFFFF",
    LOG_T8               => X"FFFFFFFF",
    LOG_T9               => X"FFFFFFFF",
    LOG_ETM              => X"FFFFFFFF",
    LOG_MAJOR            => X"FFFFFFFF",
    LOG_MINOR            => X"FFFFFFFF",
    LOG_BUILD            => X"FFFFFFFF",
    LOG_HOTFIX           => X"FFFFFFFF",
    LOG_SN               => X"FFFFFFFF",
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
    UART_RAW8_H          => X"FFFFFFFF",
    SPIS_CONTROL         => X"0000003F",
    SPIS_STATUS          => X"0000003F",
    SPI_RAW0_BA          => X"FFFFFFFF",
    SPI_RAW0_DC          => X"FFFFFFFF",
    SPI_RAW2_BA          => X"FFFFFFFF",
    SPI_RAW2_DC          => X"FFFFFFFF",
    SPI_RAW2_FE          => X"FFFFFFFF",
    SPI_RAW2_HG          => X"FFFFFFFF",
    SPI_OUT4_Isns        => X"FFFFFFFF",
    SPI_DC_PWR_I_sns     => X"FFFFFFFF",
    SPI_PH1_I_sns        => X"FFFFFFFF",
    SPI_PH2_I_sns        => X"FFFFFFFF",
    SPI_PH3_I_sns        => X"FFFFFFFF",
    SPI_Vsns_PH_A_RLY    => X"FFFFFFFF",
    SPI_Vsns_PH_B_RLY    => X"FFFFFFFF",
    SPI_Vsns_PH_C_RLY    => X"FFFFFFFF",
    SPI_Vsns_PH3         => X"FFFFFFFF",
    SPI_Vsns_PH2         => X"FFFFFFFF",
    SPI_Vsns_PH1         => X"FFFFFFFF",
    SPI_OUT4_sns         => X"FFFFFFFF",
    SPI_RMS_OUT4_Isns    => X"FFFFFFFF",
    SPI_RMS_DC_PWR_I_sns => X"FFFFFFFF",
    SPI_RMS_PH1_I_sns    => X"FFFFFFFF",
    SPI_RMS_PH2_I_sns    => X"FFFFFFFF",
    SPI_RMS_PH3_I_sns    => X"FFFFFFFF",
    SPI_RMS_Vsns_PH_A_RLY => X"FFFFFFFF",
    SPI_RMS_Vsns_PH_B_RLY => X"FFFFFFFF",
    SPI_RMS_Vsns_PH_C_RLY => X"FFFFFFFF",
    SPI_RMS_Vsns_PH3     => X"FFFFFFFF",
    SPI_RMS_Vsns_PH2     => X"FFFFFFFF",
    SPI_RMS_Vsns_PH1     => X"FFFFFFFF",
    SPI_RMS_OUT4_sns     => X"FFFFFFFF",
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
    LOG_MESSAGE_ID       => '1',
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
    LOG_FAN_SPEED        => '1',
    LOG_FAN1_SPEED       => '1',
    LOG_FAN2_SPEED       => '1',
    LOG_FAN3_SPEED       => '1',
    LOG_VOLUME_SIZE_L    => '1',
    LOG_VOLUME_SIZE_H    => '1',
    LOG_LOGFILE_SIZE_L   => '1',
    LOG_LOGFILE_SIZE_H   => '1',
    LOG_T1               => '1',
    LOG_T2               => '1',
    LOG_T3               => '1',
    LOG_T4               => '1',
    LOG_T5               => '1',
    LOG_T6               => '1',
    LOG_T7               => '1',
    LOG_T8               => '1',
    LOG_T9               => '1',
    LOG_ETM              => '1',
    LOG_MAJOR            => '1',
    LOG_MINOR            => '1',
    LOG_BUILD            => '1',
    LOG_HOTFIX           => '1',
    LOG_SN               => '1',
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
    SPIS_STATUS          => '1',
    SPI_RAW0_BA          => '1',
    SPI_RAW0_DC          => '1',
    SPI_RAW2_BA          => '1',
    SPI_RAW2_DC          => '1',
    SPI_RAW2_FE          => '1',
    SPI_RAW2_HG          => '1',
    SPI_OUT4_Isns        => '1',
    SPI_DC_PWR_I_sns     => '1',
    SPI_PH1_I_sns        => '1',
    SPI_PH2_I_sns        => '1',
    SPI_PH3_I_sns        => '1',
    SPI_Vsns_PH_A_RLY    => '1',
    SPI_Vsns_PH_B_RLY    => '1',
    SPI_Vsns_PH_C_RLY    => '1',
    SPI_Vsns_PH3         => '1',
    SPI_Vsns_PH2         => '1',
    SPI_Vsns_PH1         => '1',
    SPI_OUT4_sns         => '1',
    SPI_RMS_OUT4_Isns    => '1',
    SPI_RMS_DC_PWR_I_sns => '1',
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
    others               => '0'
  );

  ----------------------------------------------------------------------------------
  -- Registers writeable by CPU                                                     
  ----------------------------------------------------------------------------------
  constant CPU_WRITEABLE_REGS : reg_slv_array_t := (
    GENERAL_CONTROL      => '1',
    IO_OUT0              => '1',
    IO_OUT1              => '1',
    SN_ETI               => '1',
    LOG_ETM              => '1',
    LOG_SN               => '1',
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
