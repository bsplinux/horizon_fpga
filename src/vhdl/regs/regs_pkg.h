/*
----------------------------------------------------------------------------------------
-- Registers H file created from yaml definition of registers at     03-09-2024 11:34 --
--   python function: regs2h.py                                                       --
--   yaml file name: ../yaml/condor_regs.yaml                                         --
----------------------------------------------------------------------------------------
*/

#ifndef __REGS_PKG_H__

#include <stdint.h>
#pragma pack(push,1)

typedef struct
{
    uint32_t REV_MINOR              : 16;
    uint32_t REV_MAJOR              : 16;
}fields_REGS_VERSION_t;

typedef union
{
    uint32_t raw;
    fields_REGS_VERSION_t fields;
}REGS_VERSION_t;

typedef struct
{
    uint32_t REV_MINOR              : 16;
    uint32_t REV_MAJOR              : 16;
}fields_FPGA_VERSION_t;

typedef union
{
    uint32_t raw;
    fields_FPGA_VERSION_t fields;
}FPGA_VERSION_t;

typedef struct
{
    uint32_t HOUR                   : 8;
    uint32_t YEAR                   : 8;
    uint32_t MONTH                  : 8;
    uint32_t DAY                    : 8;
}fields_COMPILE_TIME_t;

typedef union
{
    uint32_t raw;
    fields_COMPILE_TIME_t fields;
}COMPILE_TIME_t;

typedef struct
{
}fields_BITSTREAM_TIME_t;

typedef union
{
    uint32_t raw;
    fields_BITSTREAM_TIME_t fields;
}BITSTREAM_TIME_t;

typedef struct
{
    uint32_t SW_RESET               : 1;
    uint32_t IO_DEBUG_EN            : 1;
    uint32_t EN_1MS_INTR            : 1;
    uint32_t RLEASE_REGS            : 1;
    uint32_t STOP_LOG_ACK           : 1;
    uint32_t ALIVE_ERROR            : 1;
    uint32_t ECTCU_INH              : 1;
    uint32_t CCTCU_INH              : 1;
    uint32_t UVP_EN_PH1             : 1;
    uint32_t UVP_EN_PH2             : 1;
    uint32_t UVP_EN_PH3             : 1;
    uint32_t UVP_EN_DC              : 1;
    uint32_t FAN_CHECK              : 1;
}fields_GENERAL_CONTROL_t;

typedef union
{
    uint32_t raw;
    fields_GENERAL_CONTROL_t fields;
}GENERAL_CONTROL_t;

typedef struct
{
    uint32_t REGS_LOCKED            : 1;
    uint32_t STOP_LOG               : 1;
}fields_GENERAL_STATUS_t;

typedef union
{
    uint32_t raw;
    fields_GENERAL_STATUS_t fields;
}GENERAL_STATUS_t;

typedef struct
{
}fields_TIMESTAMP_L_t;

typedef union
{
    uint32_t raw;
    fields_TIMESTAMP_L_t fields;
}TIMESTAMP_L_t;

typedef struct
{
}fields_TIMESTAMP_H_t;

typedef union
{
    uint32_t raw;
    fields_TIMESTAMP_H_t fields;
}TIMESTAMP_H_t;

typedef struct
{
    uint32_t POWERON_FPGA           : 1;
    uint32_t FAN_PG1_FPGA           : 1;
    uint32_t FAN_HALL1_FPGA         : 1;
    uint32_t FAN_PG3_FPGA           : 1;
    uint32_t FAN_HALL3_FPGA         : 1;
    uint32_t FAN_PG2_FPGA           : 1;
    uint32_t FAN_HALL2_FPGA         : 1;
    uint32_t PG_BUCK_FB             : 1;
    uint32_t PG_PSU_1_FB            : 1;
    uint32_t PG_PSU_2_FB            : 1;
    uint32_t PG_PSU_5_FB            : 1;
    uint32_t PG_PSU_6_FB            : 1;
    uint32_t PG_PSU_7_FB            : 1;
    uint32_t PG_PSU_8_FB            : 1;
    uint32_t PG_PSU_9_FB            : 1;
    uint32_t PG_PSU_10_FB           : 1;
    uint32_t lamp_status_fpga       : 1;
    uint32_t PH_A_ON_fpga           : 1;
    uint32_t PH_B_ON_fpga           : 1;
    uint32_t PH_C_ON_fpga           : 1;
}fields_IO_IN_t;

typedef union
{
    uint32_t raw;
    fields_IO_IN_t fields;
}IO_IN_t;

typedef struct
{
    uint32_t FAN_EN1_FPGA           : 1;
    uint32_t FAN_CTRL1_FPGA         : 1;
    uint32_t P_IN_STATUS_FPGA       : 1;
    uint32_t POD_STATUS_FPGA        : 1;
    uint32_t ECTCU_INH_FPGA         : 1;
    uint32_t P_OUT_STATUS_FPGA      : 1;
    uint32_t CCTCU_INH_FPGA         : 1;
    uint32_t SHUTDOWN_OUT_FPGA      : 1;
    uint32_t RESET_OUT_FPGA         : 1;
    uint32_t SPARE_OUT_FPGA         : 1;
    uint32_t ESHUTDOWN_OUT_FPGA     : 1;
    uint32_t RELAY_1PH_FPGA         : 1;
    uint32_t RELAY_3PH_FPGA         : 1;
    uint32_t FAN_EN3_FPGA           : 1;
    uint32_t FAN_CTRL3_FPGA         : 1;
    uint32_t FAN_EN2_FPGA           : 1;
    uint32_t FAN_CTRL2_FPGA         : 1;
    uint32_t EN_PFC_FB              : 1;
    uint32_t EN_PSU_1_FB            : 1;
    uint32_t EN_PSU_2_FB            : 1;
    uint32_t EN_PSU_5_FB            : 1;
    uint32_t EN_PSU_6_FB            : 1;
    uint32_t EN_PSU_7_FB            : 1;
    uint32_t EN_PSU_8_FB            : 1;
    uint32_t EN_PSU_9_FB            : 1;
    uint32_t EN_PSU_10_FB           : 1;
}fields_IO_OUT0_t;

typedef union
{
    uint32_t raw;
    fields_IO_OUT0_t fields;
}IO_OUT0_t;

typedef struct
{
    uint32_t RS485_DE_7             : 1;
    uint32_t RS485_DE_8             : 1;
    uint32_t RS485_DE_9             : 1;
    uint32_t RS485_DE_1             : 1;
    uint32_t RS485_DE_2             : 1;
    uint32_t RS485_DE_3             : 1;
    uint32_t RS485_DE_4             : 1;
    uint32_t RS485_DE_5             : 1;
    uint32_t RS485_DE_6             : 1;
}fields_IO_OUT1_t;

typedef union
{
    uint32_t raw;
    fields_IO_OUT1_t fields;
}IO_OUT1_t;

typedef struct
{
    uint32_t SN                     : 8;
    uint32_t SET_SN                 : 1;
    uint32_t RESET_ETI              : 1;
}fields_SN_ETI_t;

typedef union
{
    uint32_t raw;
    fields_SN_ETI_t fields;
}SN_ETI_t;

typedef struct
{
}fields_LOG_VDC_IN_t;

typedef union
{
    uint32_t raw;
    fields_LOG_VDC_IN_t fields;
}LOG_VDC_IN_t;

typedef struct
{
}fields_LOG_VAC_IN_PH_A_t;

typedef union
{
    uint32_t raw;
    fields_LOG_VAC_IN_PH_A_t fields;
}LOG_VAC_IN_PH_A_t;

typedef struct
{
}fields_LOG_VAC_IN_PH_B_t;

typedef union
{
    uint32_t raw;
    fields_LOG_VAC_IN_PH_B_t fields;
}LOG_VAC_IN_PH_B_t;

typedef struct
{
}fields_LOG_VAC_IN_PH_C_t;

typedef union
{
    uint32_t raw;
    fields_LOG_VAC_IN_PH_C_t fields;
}LOG_VAC_IN_PH_C_t;

typedef struct
{
}fields_LOG_I_DC_IN_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_DC_IN_t fields;
}LOG_I_DC_IN_t;

typedef struct
{
}fields_LOG_I_AC_IN_PH_A_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_AC_IN_PH_A_t fields;
}LOG_I_AC_IN_PH_A_t;

typedef struct
{
}fields_LOG_I_AC_IN_PH_B_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_AC_IN_PH_B_t fields;
}LOG_I_AC_IN_PH_B_t;

typedef struct
{
}fields_LOG_I_AC_IN_PH_C_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_AC_IN_PH_C_t fields;
}LOG_I_AC_IN_PH_C_t;

typedef struct
{
}fields_LOG_V_OUT_1_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_1_t fields;
}LOG_V_OUT_1_t;

typedef struct
{
}fields_LOG_V_OUT_2_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_2_t fields;
}LOG_V_OUT_2_t;

typedef struct
{
}fields_LOG_V_OUT_3_PH1_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_3_PH1_t fields;
}LOG_V_OUT_3_PH1_t;

typedef struct
{
}fields_LOG_V_OUT_3_PH2_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_3_PH2_t fields;
}LOG_V_OUT_3_PH2_t;

typedef struct
{
}fields_LOG_V_OUT_3_PH3_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_3_PH3_t fields;
}LOG_V_OUT_3_PH3_t;

typedef struct
{
}fields_LOG_V_OUT_4_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_4_t fields;
}LOG_V_OUT_4_t;

typedef struct
{
}fields_LOG_V_OUT_5_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_5_t fields;
}LOG_V_OUT_5_t;

typedef struct
{
}fields_LOG_V_OUT_6_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_6_t fields;
}LOG_V_OUT_6_t;

typedef struct
{
}fields_LOG_V_OUT_7_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_7_t fields;
}LOG_V_OUT_7_t;

typedef struct
{
}fields_LOG_V_OUT_8_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_8_t fields;
}LOG_V_OUT_8_t;

typedef struct
{
}fields_LOG_V_OUT_9_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_9_t fields;
}LOG_V_OUT_9_t;

typedef struct
{
}fields_LOG_V_OUT_10_t;

typedef union
{
    uint32_t raw;
    fields_LOG_V_OUT_10_t fields;
}LOG_V_OUT_10_t;

typedef struct
{
}fields_LOG_I_OUT_1_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_1_t fields;
}LOG_I_OUT_1_t;

typedef struct
{
}fields_LOG_I_OUT_2_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_2_t fields;
}LOG_I_OUT_2_t;

typedef struct
{
}fields_LOG_I_OUT_3_PH1_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_3_PH1_t fields;
}LOG_I_OUT_3_PH1_t;

typedef struct
{
}fields_LOG_I_OUT_3_PH2_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_3_PH2_t fields;
}LOG_I_OUT_3_PH2_t;

typedef struct
{
}fields_LOG_I_OUT_3_PH3_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_3_PH3_t fields;
}LOG_I_OUT_3_PH3_t;

typedef struct
{
}fields_LOG_I_OUT_4_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_4_t fields;
}LOG_I_OUT_4_t;

typedef struct
{
}fields_LOG_I_OUT_5_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_5_t fields;
}LOG_I_OUT_5_t;

typedef struct
{
}fields_LOG_I_OUT_6_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_6_t fields;
}LOG_I_OUT_6_t;

typedef struct
{
}fields_LOG_I_OUT_7_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_7_t fields;
}LOG_I_OUT_7_t;

typedef struct
{
}fields_LOG_I_OUT_8_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_8_t fields;
}LOG_I_OUT_8_t;

typedef struct
{
}fields_LOG_I_OUT_9_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_9_t fields;
}LOG_I_OUT_9_t;

typedef struct
{
}fields_LOG_I_OUT_10_t;

typedef union
{
    uint32_t raw;
    fields_LOG_I_OUT_10_t fields;
}LOG_I_OUT_10_t;

typedef struct
{
}fields_LOG_AC_POWER_t;

typedef union
{
    uint32_t raw;
    fields_LOG_AC_POWER_t fields;
}LOG_AC_POWER_t;

typedef struct
{
}fields_LOG_FAN1_SPEED_t;

typedef union
{
    uint32_t raw;
    fields_LOG_FAN1_SPEED_t fields;
}LOG_FAN1_SPEED_t;

typedef struct
{
}fields_LOG_FAN2_SPEED_t;

typedef union
{
    uint32_t raw;
    fields_LOG_FAN2_SPEED_t fields;
}LOG_FAN2_SPEED_t;

typedef struct
{
}fields_LOG_FAN3_SPEED_t;

typedef union
{
    uint32_t raw;
    fields_LOG_FAN3_SPEED_t fields;
}LOG_FAN3_SPEED_t;

typedef struct
{
}fields_LOG_T1_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T1_t fields;
}LOG_T1_t;

typedef struct
{
}fields_LOG_T2_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T2_t fields;
}LOG_T2_t;

typedef struct
{
}fields_LOG_T3_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T3_t fields;
}LOG_T3_t;

typedef struct
{
}fields_LOG_T4_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T4_t fields;
}LOG_T4_t;

typedef struct
{
}fields_LOG_T5_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T5_t fields;
}LOG_T5_t;

typedef struct
{
}fields_LOG_T6_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T6_t fields;
}LOG_T6_t;

typedef struct
{
}fields_LOG_T7_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T7_t fields;
}LOG_T7_t;

typedef struct
{
}fields_LOG_T8_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T8_t fields;
}LOG_T8_t;

typedef struct
{
}fields_LOG_T9_t;

typedef union
{
    uint32_t raw;
    fields_LOG_T9_t fields;
}LOG_T9_t;

typedef struct
{
}fields_LOG_ETM_t;

typedef union
{
    uint32_t raw;
    fields_LOG_ETM_t fields;
}LOG_ETM_t;

typedef struct
{
}fields_LOG_SN_t;

typedef union
{
    uint32_t raw;
    fields_LOG_SN_t fields;
}LOG_SN_t;

typedef struct
{
}fields_LOG_PSU_STATUS_L_t;

typedef union
{
    uint32_t raw;
    fields_LOG_PSU_STATUS_L_t fields;
}LOG_PSU_STATUS_L_t;

typedef struct
{
}fields_LOG_PSU_STATUS_H_t;

typedef union
{
    uint32_t raw;
    fields_LOG_PSU_STATUS_H_t fields;
}LOG_PSU_STATUS_H_t;

typedef struct
{
}fields_LOG_LAMP_IND_t;

typedef union
{
    uint32_t raw;
    fields_LOG_LAMP_IND_t fields;
}LOG_LAMP_IND_t;

typedef struct
{
    uint32_t PWM1_ACTIVE            : 1;
    uint32_t PWM1_START_HIGH        : 1;
    uint32_t PWM2_ACTIVE            : 1;
    uint32_t PWM2_START_HIGH        : 1;
    uint32_t PWM3_ACTIVE            : 1;
    uint32_t PWM3_START_HIGH        : 1;
}fields_PWM_CTL_t;

typedef union
{
    uint32_t raw;
    fields_PWM_CTL_t fields;
}PWM_CTL_t;

typedef struct
{
}fields_PWM1_LOW_t;

typedef union
{
    uint32_t raw;
    fields_PWM1_LOW_t fields;
}PWM1_LOW_t;

typedef struct
{
}fields_PWM1_HIGH_t;

typedef union
{
    uint32_t raw;
    fields_PWM1_HIGH_t fields;
}PWM1_HIGH_t;

typedef struct
{
}fields_PWM2_LOW_t;

typedef union
{
    uint32_t raw;
    fields_PWM2_LOW_t fields;
}PWM2_LOW_t;

typedef struct
{
}fields_PWM2_HIGH_t;

typedef union
{
    uint32_t raw;
    fields_PWM2_HIGH_t fields;
}PWM2_HIGH_t;

typedef struct
{
}fields_PWM3_LOW_t;

typedef union
{
    uint32_t raw;
    fields_PWM3_LOW_t fields;
}PWM3_LOW_t;

typedef struct
{
}fields_PWM3_HIGH_t;

typedef union
{
    uint32_t raw;
    fields_PWM3_HIGH_t fields;
}PWM3_HIGH_t;

typedef struct
{
    uint32_t EN_RANGE               : 9;
    uint32_t RST                    : 1;
    uint32_t MS1_ERR_CLR            : 1;
}fields_UARTS_CONTROL_t;

typedef union
{
    uint32_t raw;
    fields_UARTS_CONTROL_t fields;
}UARTS_CONTROL_t;

typedef struct
{
    uint32_t BUSY                   : 1;
    uint32_t MS1_ERR                : 1;
}fields_UARTS_STATUS_t;

typedef union
{
    uint32_t raw;
    fields_UARTS_STATUS_t fields;
}UARTS_STATUS_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW0_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW0_L_t fields;
}UART_RAW0_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW0_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW0_H_t fields;
}UART_RAW0_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW1_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW1_L_t fields;
}UART_RAW1_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW1_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW1_H_t fields;
}UART_RAW1_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW2_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW2_L_t fields;
}UART_RAW2_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW2_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW2_H_t fields;
}UART_RAW2_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW3_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW3_L_t fields;
}UART_RAW3_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW3_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW3_H_t fields;
}UART_RAW3_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW4_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW4_L_t fields;
}UART_RAW4_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW4_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW4_H_t fields;
}UART_RAW4_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW5_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW5_L_t fields;
}UART_RAW5_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW5_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW5_H_t fields;
}UART_RAW5_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW6_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW6_L_t fields;
}UART_RAW6_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW6_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW6_H_t fields;
}UART_RAW6_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t VIN_H                  : 4;
    uint32_t VIN_L                  : 8;
    uint32_t VOUT_L                 : 8;
}fields_UART_RAW7_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW7_L_t fields;
}UART_RAW7_L_t;

typedef struct
{
    uint32_t VOUT_H                 : 4;
    uint32_t IIN_H                  : 4;
    uint32_t IIN_L                  : 8;
    uint32_t IOUT                   : 12;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW7_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW7_H_t fields;
}UART_RAW7_H_t;

typedef struct
{
    uint32_t TEMP                   : 8;
    uint32_t pad8                   : 4;
    uint32_t IPHA_H                 : 4;
    uint32_t IPHA_L                 : 8;
    uint32_t IPHB_L                 : 8;
}fields_UART_RAW8_L_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW8_L_t fields;
}UART_RAW8_L_t;

typedef struct
{
    uint32_t IPHB_H                 : 4;
    uint32_t IPHC_H                 : 4;
    uint32_t IPHC_L                 : 8;
    uint32_t CAP_EOL                : 1;
    uint32_t pad17                  : 3;
    uint32_t VINP                   : 1;
    uint32_t OTP                    : 1;
    uint32_t OCP                    : 1;
    uint32_t OVP                    : 1;
}fields_UART_RAW8_H_t;

typedef union
{
    uint32_t raw;
    fields_UART_RAW8_H_t fields;
}UART_RAW8_H_t;

typedef struct
{
}fields_UART_V_OUT_1_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_1_t fields;
}UART_V_OUT_1_t;

typedef struct
{
}fields_UART_V_OUT_2_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_2_t fields;
}UART_V_OUT_2_t;

typedef struct
{
}fields_UART_V_OUT_5_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_5_t fields;
}UART_V_OUT_5_t;

typedef struct
{
}fields_UART_V_OUT_6_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_6_t fields;
}UART_V_OUT_6_t;

typedef struct
{
}fields_UART_V_OUT_7_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_7_t fields;
}UART_V_OUT_7_t;

typedef struct
{
}fields_UART_V_OUT_8_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_8_t fields;
}UART_V_OUT_8_t;

typedef struct
{
}fields_UART_V_OUT_9_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_9_t fields;
}UART_V_OUT_9_t;

typedef struct
{
}fields_UART_V_OUT_10_t;

typedef union
{
    uint32_t raw;
    fields_UART_V_OUT_10_t fields;
}UART_V_OUT_10_t;

typedef struct
{
}fields_UART_I_OUT_1_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_1_t fields;
}UART_I_OUT_1_t;

typedef struct
{
}fields_UART_I_OUT_2_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_2_t fields;
}UART_I_OUT_2_t;

typedef struct
{
}fields_UART_I_OUT_5_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_5_t fields;
}UART_I_OUT_5_t;

typedef struct
{
}fields_UART_I_OUT_6_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_6_t fields;
}UART_I_OUT_6_t;

typedef struct
{
}fields_UART_I_OUT_7_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_7_t fields;
}UART_I_OUT_7_t;

typedef struct
{
}fields_UART_I_OUT_8_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_8_t fields;
}UART_I_OUT_8_t;

typedef struct
{
}fields_UART_I_OUT_9_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_9_t fields;
}UART_I_OUT_9_t;

typedef struct
{
}fields_UART_I_OUT_10_t;

typedef union
{
    uint32_t raw;
    fields_UART_I_OUT_10_t fields;
}UART_I_OUT_10_t;

typedef struct
{
}fields_UART_T1_t;

typedef union
{
    uint32_t raw;
    fields_UART_T1_t fields;
}UART_T1_t;

typedef struct
{
}fields_UART_T2_t;

typedef union
{
    uint32_t raw;
    fields_UART_T2_t fields;
}UART_T2_t;

typedef struct
{
}fields_UART_T3_t;

typedef union
{
    uint32_t raw;
    fields_UART_T3_t fields;
}UART_T3_t;

typedef struct
{
}fields_UART_T4_t;

typedef union
{
    uint32_t raw;
    fields_UART_T4_t fields;
}UART_T4_t;

typedef struct
{
}fields_UART_T5_t;

typedef union
{
    uint32_t raw;
    fields_UART_T5_t fields;
}UART_T5_t;

typedef struct
{
}fields_UART_T6_t;

typedef union
{
    uint32_t raw;
    fields_UART_T6_t fields;
}UART_T6_t;

typedef struct
{
}fields_UART_T7_t;

typedef union
{
    uint32_t raw;
    fields_UART_T7_t fields;
}UART_T7_t;

typedef struct
{
}fields_UART_T8_t;

typedef union
{
    uint32_t raw;
    fields_UART_T8_t fields;
}UART_T8_t;

typedef struct
{
}fields_UART_T9_t;

typedef union
{
    uint32_t raw;
    fields_UART_T9_t fields;
}UART_T9_t;

typedef struct
{
}fields_UART_MAIN_I_PH1_t;

typedef union
{
    uint32_t raw;
    fields_UART_MAIN_I_PH1_t fields;
}UART_MAIN_I_PH1_t;

typedef struct
{
}fields_UART_MAIN_I_PH2_t;

typedef union
{
    uint32_t raw;
    fields_UART_MAIN_I_PH2_t fields;
}UART_MAIN_I_PH2_t;

typedef struct
{
}fields_UART_MAIN_I_PH3_t;

typedef union
{
    uint32_t raw;
    fields_UART_MAIN_I_PH3_t fields;
}UART_MAIN_I_PH3_t;

typedef struct
{
    uint32_t EN_RANGE               : 3;
    uint32_t RST                    : 1;
    uint32_t US100_ERR_CLR          : 1;
    uint32_t Z_CROSS_ERR_CLR        : 1;
}fields_SPIS_CONTROL_t;

typedef union
{
    uint32_t raw;
    fields_SPIS_CONTROL_t fields;
}SPIS_CONTROL_t;

typedef struct
{
    uint32_t BUSY                   : 1;
    uint32_t US100_ERR              : 1;
    uint32_t SPI0_OK                : 1;
    uint32_t SPI1_OK                : 1;
    uint32_t SPI2_OK                : 1;
    uint32_t Z_CROSS_ERR            : 1;
}fields_SPIS_STATUS_t;

typedef union
{
    uint32_t raw;
    fields_SPIS_STATUS_t fields;
}SPIS_STATUS_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW0_BA_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW0_BA_t fields;
}SPI_RAW0_BA_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW0_DC_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW0_DC_t fields;
}SPI_RAW0_DC_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW0_0E_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW0_0E_t fields;
}SPI_RAW0_0E_t;

typedef struct
{
}fields_SPI_RAW1_BA_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW1_BA_t fields;
}SPI_RAW1_BA_t;

typedef struct
{
}fields_SPI_RAW1_DC_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW1_DC_t fields;
}SPI_RAW1_DC_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW2_BA_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW2_BA_t fields;
}SPI_RAW2_BA_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW2_DC_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW2_DC_t fields;
}SPI_RAW2_DC_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW2_FE_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW2_FE_t fields;
}SPI_RAW2_FE_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RAW2_HG_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RAW2_HG_t fields;
}SPI_RAW2_HG_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_OUT4_Isns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_OUT4_Isns_t fields;
}SPI_OUT4_Isns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_DC_PWR_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_DC_PWR_I_sns_t fields;
}SPI_DC_PWR_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_PH1_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_PH1_I_sns_t fields;
}SPI_PH1_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_PH2_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_PH2_I_sns_t fields;
}SPI_PH2_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_PH3_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_PH3_I_sns_t fields;
}SPI_PH3_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_28V_IN_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_28V_IN_sns_t fields;
}SPI_28V_IN_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH_A_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH_A_RLY_t fields;
}SPI_Vsns_PH_A_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH_B_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH_B_RLY_t fields;
}SPI_Vsns_PH_B_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH_C_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH_C_RLY_t fields;
}SPI_Vsns_PH_C_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH3_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH3_t fields;
}SPI_Vsns_PH3_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH2_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH2_t fields;
}SPI_Vsns_PH2_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_Vsns_PH1_t;

typedef union
{
    uint32_t raw;
    fields_SPI_Vsns_PH1_t fields;
}SPI_Vsns_PH1_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_OUT4_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_OUT4_sns_t fields;
}SPI_OUT4_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_OUT4_Isns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_OUT4_Isns_t fields;
}SPI_RMS_OUT4_Isns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_DC_PWR_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_DC_PWR_I_sns_t fields;
}SPI_RMS_DC_PWR_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_PH1_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_PH1_I_sns_t fields;
}SPI_RMS_PH1_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_PH2_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_PH2_I_sns_t fields;
}SPI_RMS_PH2_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_PH3_I_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_PH3_I_sns_t fields;
}SPI_RMS_PH3_I_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_28V_IN_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_28V_IN_sns_t fields;
}SPI_RMS_28V_IN_sns_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH_A_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH_A_RLY_t fields;
}SPI_RMS_Vsns_PH_A_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH_B_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH_B_RLY_t fields;
}SPI_RMS_Vsns_PH_B_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH_C_RLY_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH_C_RLY_t fields;
}SPI_RMS_Vsns_PH_C_RLY_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH3_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH3_t fields;
}SPI_RMS_Vsns_PH3_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH2_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH2_t fields;
}SPI_RMS_Vsns_PH2_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_Vsns_PH1_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_Vsns_PH1_t fields;
}SPI_RMS_Vsns_PH1_t;

typedef struct
{
    uint32_t L_D_RANGE              : 12;
    uint32_t L_ID_RANGE             : 4;
    uint32_t H_D_RANGE              : 12;
    uint32_t H_ID_RANGE             : 4;
}fields_SPI_RMS_OUT4_sns_t;

typedef union
{
    uint32_t raw;
    fields_SPI_RMS_OUT4_sns_t fields;
}SPI_RMS_OUT4_sns_t;

#define NUM_REGS_PACKED 154
#define NUM_REGS 154

typedef struct
{
    REGS_VERSION_t           REGS_VERSION        ;
    FPGA_VERSION_t           FPGA_VERSION        ;
    COMPILE_TIME_t           COMPILE_TIME        ;
    BITSTREAM_TIME_t         BITSTREAM_TIME      ;
    GENERAL_CONTROL_t        GENERAL_CONTROL     ;
    GENERAL_STATUS_t         GENERAL_STATUS      ;
    TIMESTAMP_L_t            TIMESTAMP_L         ;
    TIMESTAMP_H_t            TIMESTAMP_H         ;
    IO_IN_t                  IO_IN               ;
    IO_OUT0_t                IO_OUT0             ;
    IO_OUT1_t                IO_OUT1             ;
    SN_ETI_t                 SN_ETI              ;
    LOG_VDC_IN_t             LOG_VDC_IN          ;
    LOG_VAC_IN_PH_A_t        LOG_VAC_IN_PH_A     ;
    LOG_VAC_IN_PH_B_t        LOG_VAC_IN_PH_B     ;
    LOG_VAC_IN_PH_C_t        LOG_VAC_IN_PH_C     ;
    LOG_I_DC_IN_t            LOG_I_DC_IN         ;
    LOG_I_AC_IN_PH_A_t       LOG_I_AC_IN_PH_A    ;
    LOG_I_AC_IN_PH_B_t       LOG_I_AC_IN_PH_B    ;
    LOG_I_AC_IN_PH_C_t       LOG_I_AC_IN_PH_C    ;
    LOG_V_OUT_1_t            LOG_V_OUT_1         ;
    LOG_V_OUT_2_t            LOG_V_OUT_2         ;
    LOG_V_OUT_3_PH1_t        LOG_V_OUT_3_PH1     ;
    LOG_V_OUT_3_PH2_t        LOG_V_OUT_3_PH2     ;
    LOG_V_OUT_3_PH3_t        LOG_V_OUT_3_PH3     ;
    LOG_V_OUT_4_t            LOG_V_OUT_4         ;
    LOG_V_OUT_5_t            LOG_V_OUT_5         ;
    LOG_V_OUT_6_t            LOG_V_OUT_6         ;
    LOG_V_OUT_7_t            LOG_V_OUT_7         ;
    LOG_V_OUT_8_t            LOG_V_OUT_8         ;
    LOG_V_OUT_9_t            LOG_V_OUT_9         ;
    LOG_V_OUT_10_t           LOG_V_OUT_10        ;
    LOG_I_OUT_1_t            LOG_I_OUT_1         ;
    LOG_I_OUT_2_t            LOG_I_OUT_2         ;
    LOG_I_OUT_3_PH1_t        LOG_I_OUT_3_PH1     ;
    LOG_I_OUT_3_PH2_t        LOG_I_OUT_3_PH2     ;
    LOG_I_OUT_3_PH3_t        LOG_I_OUT_3_PH3     ;
    LOG_I_OUT_4_t            LOG_I_OUT_4         ;
    LOG_I_OUT_5_t            LOG_I_OUT_5         ;
    LOG_I_OUT_6_t            LOG_I_OUT_6         ;
    LOG_I_OUT_7_t            LOG_I_OUT_7         ;
    LOG_I_OUT_8_t            LOG_I_OUT_8         ;
    LOG_I_OUT_9_t            LOG_I_OUT_9         ;
    LOG_I_OUT_10_t           LOG_I_OUT_10        ;
    LOG_AC_POWER_t           LOG_AC_POWER        ;
    LOG_FAN1_SPEED_t         LOG_FAN1_SPEED      ;
    LOG_FAN2_SPEED_t         LOG_FAN2_SPEED      ;
    LOG_FAN3_SPEED_t         LOG_FAN3_SPEED      ;
    LOG_T1_t                 LOG_T1              ;
    LOG_T2_t                 LOG_T2              ;
    LOG_T3_t                 LOG_T3              ;
    LOG_T4_t                 LOG_T4              ;
    LOG_T5_t                 LOG_T5              ;
    LOG_T6_t                 LOG_T6              ;
    LOG_T7_t                 LOG_T7              ;
    LOG_T8_t                 LOG_T8              ;
    LOG_T9_t                 LOG_T9              ;
    LOG_ETM_t                LOG_ETM             ;
    LOG_SN_t                 LOG_SN              ;
    LOG_PSU_STATUS_L_t       LOG_PSU_STATUS_L    ;
    LOG_PSU_STATUS_H_t       LOG_PSU_STATUS_H    ;
    LOG_LAMP_IND_t           LOG_LAMP_IND        ;
    PWM_CTL_t                PWM_CTL             ;
    PWM1_LOW_t               PWM1_LOW            ;
    PWM1_HIGH_t              PWM1_HIGH           ;
    PWM2_LOW_t               PWM2_LOW            ;
    PWM2_HIGH_t              PWM2_HIGH           ;
    PWM3_LOW_t               PWM3_LOW            ;
    PWM3_HIGH_t              PWM3_HIGH           ;
    UARTS_CONTROL_t          UARTS_CONTROL       ;
    UARTS_STATUS_t           UARTS_STATUS        ;
    UART_RAW0_L_t            UART_RAW0_L         ;
    UART_RAW0_H_t            UART_RAW0_H         ;
    UART_RAW1_L_t            UART_RAW1_L         ;
    UART_RAW1_H_t            UART_RAW1_H         ;
    UART_RAW2_L_t            UART_RAW2_L         ;
    UART_RAW2_H_t            UART_RAW2_H         ;
    UART_RAW3_L_t            UART_RAW3_L         ;
    UART_RAW3_H_t            UART_RAW3_H         ;
    UART_RAW4_L_t            UART_RAW4_L         ;
    UART_RAW4_H_t            UART_RAW4_H         ;
    UART_RAW5_L_t            UART_RAW5_L         ;
    UART_RAW5_H_t            UART_RAW5_H         ;
    UART_RAW6_L_t            UART_RAW6_L         ;
    UART_RAW6_H_t            UART_RAW6_H         ;
    UART_RAW7_L_t            UART_RAW7_L         ;
    UART_RAW7_H_t            UART_RAW7_H         ;
    UART_RAW8_L_t            UART_RAW8_L         ;
    UART_RAW8_H_t            UART_RAW8_H         ;
    UART_V_OUT_1_t           UART_V_OUT_1        ;
    UART_V_OUT_2_t           UART_V_OUT_2        ;
    UART_V_OUT_5_t           UART_V_OUT_5        ;
    UART_V_OUT_6_t           UART_V_OUT_6        ;
    UART_V_OUT_7_t           UART_V_OUT_7        ;
    UART_V_OUT_8_t           UART_V_OUT_8        ;
    UART_V_OUT_9_t           UART_V_OUT_9        ;
    UART_V_OUT_10_t          UART_V_OUT_10       ;
    UART_I_OUT_1_t           UART_I_OUT_1        ;
    UART_I_OUT_2_t           UART_I_OUT_2        ;
    UART_I_OUT_5_t           UART_I_OUT_5        ;
    UART_I_OUT_6_t           UART_I_OUT_6        ;
    UART_I_OUT_7_t           UART_I_OUT_7        ;
    UART_I_OUT_8_t           UART_I_OUT_8        ;
    UART_I_OUT_9_t           UART_I_OUT_9        ;
    UART_I_OUT_10_t          UART_I_OUT_10       ;
    UART_T1_t                UART_T1             ;
    UART_T2_t                UART_T2             ;
    UART_T3_t                UART_T3             ;
    UART_T4_t                UART_T4             ;
    UART_T5_t                UART_T5             ;
    UART_T6_t                UART_T6             ;
    UART_T7_t                UART_T7             ;
    UART_T8_t                UART_T8             ;
    UART_T9_t                UART_T9             ;
    UART_MAIN_I_PH1_t        UART_MAIN_I_PH1     ;
    UART_MAIN_I_PH2_t        UART_MAIN_I_PH2     ;
    UART_MAIN_I_PH3_t        UART_MAIN_I_PH3     ;
    SPIS_CONTROL_t           SPIS_CONTROL        ;
    SPIS_STATUS_t            SPIS_STATUS         ;
    SPI_RAW0_BA_t            SPI_RAW0_BA         ;
    SPI_RAW0_DC_t            SPI_RAW0_DC         ;
    SPI_RAW0_0E_t            SPI_RAW0_0E         ;
    SPI_RAW1_BA_t            SPI_RAW1_BA         ;
    SPI_RAW1_DC_t            SPI_RAW1_DC         ;
    SPI_RAW2_BA_t            SPI_RAW2_BA         ;
    SPI_RAW2_DC_t            SPI_RAW2_DC         ;
    SPI_RAW2_FE_t            SPI_RAW2_FE         ;
    SPI_RAW2_HG_t            SPI_RAW2_HG         ;
    SPI_OUT4_Isns_t          SPI_OUT4_Isns       ;
    SPI_DC_PWR_I_sns_t       SPI_DC_PWR_I_sns    ;
    SPI_PH1_I_sns_t          SPI_PH1_I_sns       ;
    SPI_PH2_I_sns_t          SPI_PH2_I_sns       ;
    SPI_PH3_I_sns_t          SPI_PH3_I_sns       ;
    SPI_28V_IN_sns_t         SPI_28V_IN_sns      ;
    SPI_Vsns_PH_A_RLY_t      SPI_Vsns_PH_A_RLY   ;
    SPI_Vsns_PH_B_RLY_t      SPI_Vsns_PH_B_RLY   ;
    SPI_Vsns_PH_C_RLY_t      SPI_Vsns_PH_C_RLY   ;
    SPI_Vsns_PH3_t           SPI_Vsns_PH3        ;
    SPI_Vsns_PH2_t           SPI_Vsns_PH2        ;
    SPI_Vsns_PH1_t           SPI_Vsns_PH1        ;
    SPI_OUT4_sns_t           SPI_OUT4_sns        ;
    SPI_RMS_OUT4_Isns_t      SPI_RMS_OUT4_Isns   ;
    SPI_RMS_DC_PWR_I_sns_t   SPI_RMS_DC_PWR_I_sns;
    SPI_RMS_PH1_I_sns_t      SPI_RMS_PH1_I_sns   ;
    SPI_RMS_PH2_I_sns_t      SPI_RMS_PH2_I_sns   ;
    SPI_RMS_PH3_I_sns_t      SPI_RMS_PH3_I_sns   ;
    SPI_RMS_28V_IN_sns_t     SPI_RMS_28V_IN_sns  ;
    SPI_RMS_Vsns_PH_A_RLY_t  SPI_RMS_Vsns_PH_A_RLY;
    SPI_RMS_Vsns_PH_B_RLY_t  SPI_RMS_Vsns_PH_B_RLY;
    SPI_RMS_Vsns_PH_C_RLY_t  SPI_RMS_Vsns_PH_C_RLY;
    SPI_RMS_Vsns_PH3_t       SPI_RMS_Vsns_PH3    ;
    SPI_RMS_Vsns_PH2_t       SPI_RMS_Vsns_PH2    ;
    SPI_RMS_Vsns_PH1_t       SPI_RMS_Vsns_PH1    ;
    SPI_RMS_OUT4_sns_t       SPI_RMS_OUT4_sns    ;
}registers_t;
#pragma pack(pop)

// example to use in c file:
// registers_t* const registers = (registers_t *)FPGA_BASE_ADDRESS;


// for simple use of registers as offsets in the address space use these defined constants:

#define REGS_VERSION_i        0
#define FPGA_VERSION_i        1
#define COMPILE_TIME_i        2
#define BITSTREAM_TIME_i      3
#define GENERAL_CONTROL_i     4
#define GENERAL_STATUS_i      5
#define TIMESTAMP_L_i         6
#define TIMESTAMP_H_i         7
#define IO_IN_i               8
#define IO_OUT0_i             9
#define IO_OUT1_i            10
#define SN_ETI_i             11
#define LOG_VDC_IN_i         12
#define LOG_VAC_IN_PH_A_i    13
#define LOG_VAC_IN_PH_B_i    14
#define LOG_VAC_IN_PH_C_i    15
#define LOG_I_DC_IN_i        16
#define LOG_I_AC_IN_PH_A_i   17
#define LOG_I_AC_IN_PH_B_i   18
#define LOG_I_AC_IN_PH_C_i   19
#define LOG_V_OUT_1_i        20
#define LOG_V_OUT_2_i        21
#define LOG_V_OUT_3_PH1_i    22
#define LOG_V_OUT_3_PH2_i    23
#define LOG_V_OUT_3_PH3_i    24
#define LOG_V_OUT_4_i        25
#define LOG_V_OUT_5_i        26
#define LOG_V_OUT_6_i        27
#define LOG_V_OUT_7_i        28
#define LOG_V_OUT_8_i        29
#define LOG_V_OUT_9_i        30
#define LOG_V_OUT_10_i       31
#define LOG_I_OUT_1_i        32
#define LOG_I_OUT_2_i        33
#define LOG_I_OUT_3_PH1_i    34
#define LOG_I_OUT_3_PH2_i    35
#define LOG_I_OUT_3_PH3_i    36
#define LOG_I_OUT_4_i        37
#define LOG_I_OUT_5_i        38
#define LOG_I_OUT_6_i        39
#define LOG_I_OUT_7_i        40
#define LOG_I_OUT_8_i        41
#define LOG_I_OUT_9_i        42
#define LOG_I_OUT_10_i       43
#define LOG_AC_POWER_i       44
#define LOG_FAN1_SPEED_i     45
#define LOG_FAN2_SPEED_i     46
#define LOG_FAN3_SPEED_i     47
#define LOG_T1_i             48
#define LOG_T2_i             49
#define LOG_T3_i             50
#define LOG_T4_i             51
#define LOG_T5_i             52
#define LOG_T6_i             53
#define LOG_T7_i             54
#define LOG_T8_i             55
#define LOG_T9_i             56
#define LOG_ETM_i            57
#define LOG_SN_i             58
#define LOG_PSU_STATUS_L_i   59
#define LOG_PSU_STATUS_H_i   60
#define LOG_LAMP_IND_i       61
#define PWM_CTL_i            62
#define PWM1_LOW_i           63
#define PWM1_HIGH_i          64
#define PWM2_LOW_i           65
#define PWM2_HIGH_i          66
#define PWM3_LOW_i           67
#define PWM3_HIGH_i          68
#define UARTS_CONTROL_i      69
#define UARTS_STATUS_i       70
#define UART_RAW0_L_i        71
#define UART_RAW0_H_i        72
#define UART_RAW1_L_i        73
#define UART_RAW1_H_i        74
#define UART_RAW2_L_i        75
#define UART_RAW2_H_i        76
#define UART_RAW3_L_i        77
#define UART_RAW3_H_i        78
#define UART_RAW4_L_i        79
#define UART_RAW4_H_i        80
#define UART_RAW5_L_i        81
#define UART_RAW5_H_i        82
#define UART_RAW6_L_i        83
#define UART_RAW6_H_i        84
#define UART_RAW7_L_i        85
#define UART_RAW7_H_i        86
#define UART_RAW8_L_i        87
#define UART_RAW8_H_i        88
#define UART_V_OUT_1_i       89
#define UART_V_OUT_2_i       90
#define UART_V_OUT_5_i       91
#define UART_V_OUT_6_i       92
#define UART_V_OUT_7_i       93
#define UART_V_OUT_8_i       94
#define UART_V_OUT_9_i       95
#define UART_V_OUT_10_i      96
#define UART_I_OUT_1_i       97
#define UART_I_OUT_2_i       98
#define UART_I_OUT_5_i       99
#define UART_I_OUT_6_i      100
#define UART_I_OUT_7_i      101
#define UART_I_OUT_8_i      102
#define UART_I_OUT_9_i      103
#define UART_I_OUT_10_i     104
#define UART_T1_i           105
#define UART_T2_i           106
#define UART_T3_i           107
#define UART_T4_i           108
#define UART_T5_i           109
#define UART_T6_i           110
#define UART_T7_i           111
#define UART_T8_i           112
#define UART_T9_i           113
#define UART_MAIN_I_PH1_i   114
#define UART_MAIN_I_PH2_i   115
#define UART_MAIN_I_PH3_i   116
#define SPIS_CONTROL_i      117
#define SPIS_STATUS_i       118
#define SPI_RAW0_BA_i       119
#define SPI_RAW0_DC_i       120
#define SPI_RAW0_0E_i       121
#define SPI_RAW1_BA_i       122
#define SPI_RAW1_DC_i       123
#define SPI_RAW2_BA_i       124
#define SPI_RAW2_DC_i       125
#define SPI_RAW2_FE_i       126
#define SPI_RAW2_HG_i       127
#define SPI_OUT4_Isns_i     128
#define SPI_DC_PWR_I_sns_i  129
#define SPI_PH1_I_sns_i     130
#define SPI_PH2_I_sns_i     131
#define SPI_PH3_I_sns_i     132
#define SPI_28V_IN_sns_i    133
#define SPI_Vsns_PH_A_RLY_i 134
#define SPI_Vsns_PH_B_RLY_i 135
#define SPI_Vsns_PH_C_RLY_i 136
#define SPI_Vsns_PH3_i      137
#define SPI_Vsns_PH2_i      138
#define SPI_Vsns_PH1_i      139
#define SPI_OUT4_sns_i      140
#define SPI_RMS_OUT4_Isns_i 141
#define SPI_RMS_DC_PWR_I_sns_i 142
#define SPI_RMS_PH1_I_sns_i 143
#define SPI_RMS_PH2_I_sns_i 144
#define SPI_RMS_PH3_I_sns_i 145
#define SPI_RMS_28V_IN_sns_i 146
#define SPI_RMS_Vsns_PH_A_RLY_i 147
#define SPI_RMS_Vsns_PH_B_RLY_i 148
#define SPI_RMS_Vsns_PH_C_RLY_i 149
#define SPI_RMS_Vsns_PH3_i  150
#define SPI_RMS_Vsns_PH2_i  151
#define SPI_RMS_Vsns_PH1_i  152
#define SPI_RMS_OUT4_sns_i  153

#endif //__REGS_PKG_H__
