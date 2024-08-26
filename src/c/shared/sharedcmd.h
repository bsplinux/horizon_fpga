#ifndef __SHAREDCMD_H__
#define __SHAREDCMD_H__

// MDC is the host
#define MDC_PORT (10601)
// PSU is the Linux application on target
#define PSU_PORT (60101)
//#define LOG_PORT (60101)
#define SYNC 0xa5
//#define TARGET_IP "192.168.1.60"
#define TARGET_IP "172.20.42.25"
#define MESSAGE_ID_CONST 0x81

#pragma pack(1)
struct cmdhdr_t{
    unsigned char opcode;
    unsigned char sync;  // 0xa5
    unsigned char count;
    unsigned char length;  // data lenght
    cmdhdr_t() {}
    cmdhdr_t(int op,int cnt,int len) : opcode(op),sync(SYNC),count(cnt),length(len) {}
};

#define TELEMETRY_BYTES (196)

typedef struct{
    unsigned char message_id;          // must be 1
}cmd1_keep_alive_t;

typedef struct{
    unsigned char message_id;          // must be 2
    unsigned char tcu_id;              // 0 - ECTCU; 1 - CCTCU 
    unsigned char on_off;              // 0 - off; 1 - on
}cmd2_tcu_control_t;

typedef struct{
    unsigned char message_id;          // must be 3
    unsigned char command;             // 0 - halt & close; 1 - commence; 2 - erase  
}cmd3_logfile_maintenance_t;

typedef struct{
    unsigned char message_id;          // must be 4
    unsigned int gmt_time;             // elapes seconds from 1.1.70 UTC
    unsigned int microseconds;         // microseconds in gmt
}cmd4_gmt_t;

typedef struct{
    unsigned char message_id;         // must be 5
    unsigned char command;            // 0 - write; 1 - read
    unsigned int reg_address;         // 32 bit register address
    unsigned int reg_data;            // 32 bit register address
}cmd5_reg_rw_t;

typedef struct{
    unsigned char message_id;         // must be 5
    unsigned char board_id;           // serial no. (if 0, don't update)
    unsigned int  log_mseconds;       // how many mseconds between log to file (if 0, don't update)
    unsigned int  log_udp_port;       // udp port to send log messages to, (if 0, dont' update) the ip is 192.168.1.30 as in spec 3.1.3
}cmd6_maintenace_t;

typedef struct{
    unsigned int DC_IN_Status                : 1; // 0
    unsigned int AC_IN_Status                : 1; // 1
    unsigned int Power_Out_Status            : 1; // 2
    unsigned int MIU_COM_Status              : 1; // 3
    unsigned int OUT1_OC                     : 1; // 4
    unsigned int OUT2_OC                     : 1; // 5
    unsigned int OUT3_OC                     : 1; // 6
    unsigned int OUT4_OC                     : 1; // 7
    unsigned int OUT5_OC                     : 1; // 8
    unsigned int OUT6_OC                     : 1; // 9
    unsigned int OUT7_OC                     : 1; // 0
    unsigned int OUT8_OC                     : 1; //11
    unsigned int OUT9_OC                     : 1; //12
    unsigned int OUT10_OC                    : 1; //13
    unsigned int DC_IN_OV                    : 1; //14
    unsigned int OUT1_OV                     : 1; //15
    unsigned int OUT2_OV                     : 1; //16
    unsigned int OUT3_OV                     : 1; //17
    unsigned int OUT4_OV                     : 1; //18
    unsigned int OUT5_OV                     : 1; //19
    unsigned int OUT6_OV                     : 1; //20
    unsigned int OUT7_OV                     : 1; //21
    unsigned int OUT8_OV                     : 1; //22
    unsigned int OUT9_OV                     : 1; //23
    unsigned int OUT10_OV                    : 1; //24
    unsigned int DC_IN_UV                    : 1; //25
    unsigned int AC_IN_UV                    : 1; //26
    unsigned int PH1_Status                  : 1; //27
    unsigned int PH2_Status                  : 1; //28
    unsigned int PH3_Status                  : 1; //29
    unsigned int Neutral_Status              : 1; //30
    unsigned int Is_Logfile_Running          : 1; //31
    unsigned int Is_Logfile_Erase_In_Process : 1; //32
    unsigned int Fan1_Speed_Status           : 1; //33
    unsigned int Fan2_Speed_Status           : 1; //34
    unsigned int Fan3_Speed_Status           : 1; //35
    unsigned int OVER_TEMP_Status            : 1; //36
    unsigned int CC_Inhibit                  : 1; //37
    unsigned int EC_Inhibit                  : 1; //38
    unsigned int System_Reset                : 1; //39
    unsigned int System_Off                  : 1; //30
    unsigned int MIU_Watchdog_Status         : 1; //41
    unsigned int ON_OFF_Switch_State         : 1; //42
    unsigned int Capacitor1_end_of_life      : 1; //43
    unsigned int Capacitor2_end_of_life      : 1; //44
    unsigned int Capacitor3_end_of_life      : 1; //45
    unsigned int Capacitor4_end_of_life      : 1; //46
    unsigned int Capacitor5_end_of_life      : 1; //47
    unsigned int Capacitor6_end_of_life      : 1; //48
    unsigned int Capacitor7_end_of_life      : 1; //49
    unsigned int Capacitor8_end_of_life      : 1; //50
    unsigned int Capacitor9_end_of_life      : 1; //51
    unsigned int Capacitor10_end_of_life     : 1; //52
    unsigned int Capacitor11_end_of_life     : 1; //53
    unsigned int Capacitor12_end_of_life     : 1; //54
    unsigned int Capacitor13_end_of_life     : 1; //55
    unsigned int Capacitor14_end_of_life     : 1; //56
    unsigned int Capacitor15_end_of_life     : 1; //57
    unsigned int Capacitor16_end_of_life     : 1; //58
    unsigned int Spare0                      : 1; //59
    unsigned int Spare1                      : 1; //60
    unsigned int Spare2                      : 1; //61
    unsigned int Spare3                      : 1; //62
    unsigned int Spare4                      : 1; //63
}PSU_Status_t;

typedef union {
	PSU_Status_t fields;
	unsigned long long word;
}PSU_Status_union_t;
                                       // Description                                    Units	Range	      Resolution
typedef struct{                        //                                                |------|-------------|---------|
	//unsigned char 	    Message_ID   ; // Unique message ID - must be 0x81               N/A	0x81	N/A            this field is only for UDP not for LOG
	short 	            VDC_IN       ; // 28VDC Input voltage                            VDC	+/- 100VDC	  50mV
	short 	            VAC_IN_PH_A  ; // 115 VAC phA input  voltage                     VAC	+/- 200VAC	  100mV
	short 	            VAC_IN_PH_B  ; // 115 VAC phB input  voltage                     VAC	+/- 200VAC	  100mV
	short 	            VAC_IN_PH_C  ; // 115 VAC phC input  voltage                     VAC	+/- 200VAC	  100mV
	short 	            I_DC_IN      ; // Input DC current                               A DC	+/- 100A	  50mA
	short 	            I_AC_IN_PH_A ; // AC phA input  current                          A AC	+/- 200A	  50mA
	short 	            I_AC_IN_PH_B ; // AC phB input  current                          A AC	+/- 200A	  50mA
	short 	            I_AC_IN_PH_C ; // AC phC input  current                          A AC	+/- 200A	  50mA
	short 	            V_OUT_1      ; // Output Voltage to Fan CCA                      VDC	+/- 100VDC	  50mV
	short 	            V_OUT_2      ; // Output Voltage to MWIR Cooler                  VDC	+/- 100VDC	  50mV
	short 	            V_OUT_3_ph1  ; // Output Voltage to ADLS phase 1                 VAC	+/- 200VAC	  100mV
	short 	            V_OUT_3_ph2  ; // Output Voltage to ADLS phase 2                 VAC	+/- 200VAC	  100mV
	short 	            V_OUT_3_ph3  ; // Output Voltage to ADLS phase 3                 VAC	+/- 200VAC	  100mV
	short 	            V_OUT_4      ; // Output Voltage to EDU phase 1                  VAC	+/- 200VAC	  100mV
	short 	            V_OUT_5      ; // Output Voltage to VNIR channel                 VDC	+/- 100VDC	  50mV
	short 	            V_OUT_6      ; // Output Voltage to SWIR/MWIR channel            VDC	+/- 100VDC	  50mV
	short 	            V_OUT_7      ; // Output Voltage to MCC                          VDC	+/- 100VDC	  50mV
	short 	            V_OUT_8      ; // Output Voltage to MIU                          VDC	+/- 100VDC	  50mV
	short 	            V_OUT_9      ; // Output Voltage to LOS motors                   VDC	+/- 100VDC	  50mV
	short 	            V_OUT_10     ; // Output Voltage to INS / EDU / SPARE            VDC	+/- 100VDC	  50mV
	short 	            I_OUT_1      ; // Output Current to Fan CCA                      A DC	+/- 100A	  50mA
	short 	            I_OUT_2      ; // Output Current to MWIR Cooler                  A DC	+/- 100A	  50mA
	short 	            I_OUT_3_ph1  ; // Output Current to ADLS_phase 1                 A AC	+/- 200A	  100mA
	short 	            I_OUT_3_ph2  ; // Output Current to ADLS_phase 2                 A AC	+/- 200A	  100mA
	short 	            I_OUT_3_ph3  ; // Output Current to ADLS_phase 3                 A AC	+/- 200A	  100mA
	short 	            I_OUT_4      ; // Output Current to EDU phase 1                  A AC	+/- 200A	  100mA
	short 	            I_OUT_5      ; // Output Current to VNIR channel                 A DC	+/- 100A	  50mA
	short 	            I_OUT_6      ; // Output Current to SWIR/MWIR channel            A DC	+/- 100A	  50mA
	short 	            I_OUT_7      ; // Output Current to MCC                          A DC	+/- 100A	  50mA
	short 	            I_OUT_8      ; // Output Current to MIU                          A DC	+/- 100A	  50mA
	short 	            I_OUT_9      ; // Output Current to LOS motors                   A DC	+/- 100A	  50mA
	short 	            I_OUT_10     ; // Output Current to INS / EDU / SPARE            A DC	+/- 100A	  50mA
	unsigned short 	    AC_Power     ; // Total AC Power Consumption                     VA	    10KW	      1VA
	unsigned short 	    Fan1_Speed   ; // PSU Fan1 Speed                                 RPM	[1 - 30,000]  1RPM
	unsigned short 	    Fan2_Speed   ; // PSU Fan2 Speed                                 RPM	[1 - 30,000]  1RPM
	unsigned short 	    Fan3_Speed   ; // PSU Fan3 Speed                                 RPM	[1 - 30,000]  1RPM
	unsigned long long	Volume_size  ; // Total available volume allocated for logfiles. Bytes	10Gbyte	      1byte
	unsigned long long	Logfile_size ; // Total usage of logfiles.                       Bytes	[0-10Gbyte]	  1byte
	char 	            T1           ; // Thermistor 1                                   �C	    +/- 127�C	  1�C
	char 	            T2           ; // Thermistor 2                                   �C	    +/- 127�C	  1�C
	char 	            T3           ; // Thermistor 3                                   �C	    +/- 127�C	  1�C
	char 	            T4           ; // Thermistor 4                                   �C	    +/- 127�C	  1�C
	char 	            T5           ; // Thermistor 5                                   �C	    +/- 127�C	  1�C
	char 	            T6           ; // Thermistor 6                                   �C	    +/- 127�C	  1�C
	char 	            T7           ; // Thermistor 7                                   �C	    +/- 127�C	  1�C
	char 	            T8           ; // Thermistor 8                                   �C	    +/- 127�C	  1�C
	char 	            T9           ; // Thermistor 9                                   �C	    +/- 127�C	  1�C
	unsigned int	    ETM          ; // Elapsed Time Meter                             minutes	N/A	      1min
	unsigned char 	    Major        ; // Software Version Major                         N/A	00-FF	      N/A
	unsigned char 	    Minor        ; // Software Version Minor                         N/A	00-FF	      N/A
	unsigned char 	    Build        ; // Software Version Build                         N/A	00-FF	      N/A
	unsigned char 	    Hotfix       ; // Software Version Hotfix                        N/A	00-FF	      N/A
	unsigned char 	    SN           ; // Serial Number                                  N/A	00-FF	      N/A
	PSU_Status_union_t	PSU_Status   ; // PSU Status                                     N/A	N/A	          N/A
	unsigned char 	    Lamp_Ind     ; // Control Panel Lamp Indication                  N/A	0 � 3	      N/A
	unsigned char 	    FW_Major     ; // Firmware Version Major                         N/A	00-FF	      N/A
	unsigned char 	    FW_Minor     ; // Firmware Version Minor                         N/A	00-FF	      N/A
	unsigned char 	    FW_Build     ; // Firmware Version Build                         N/A	00-FF	      N/A
	unsigned char 	    FW_Hotfix    ; // Firmware Version Hotfix                        N/A	00-FF	      N/A
	unsigned int    	Spare0       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare1       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare2       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare3       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare4       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare5       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare6       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare7       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare8       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long  Spare9       ; // N/A                                            N/A	N/A	          N/A
} message_base_t;

typedef struct {
	unsigned char 	Message_ID   ; // Unique message ID - must be 0x81               N/A	0x81	N/A
	message_base_t  message_base;
}cmd81_telemetry_t;

//typedef union{
//    cmd81_telemetry_t fields;
//    char raw[TELEMETRY_BYTES];
//}cmd81_union_t;

typedef struct {
	unsigned int Log_ID;
	unsigned short Log_Payload_Size;
	unsigned int GMT_Time;
	unsigned short Micro_Sec;
} log_header_t;

typedef struct {
	log_header_t header;
	message_base_t message_base;
	unsigned char footer_checksum;
} log_entrie_t;

typedef struct {
	unsigned char header_padd[sizeof(log_header_t) - 1]; // only used by log
	cmd81_telemetry_t  tele;
	unsigned char footer_pad; // only used by log
} cmd81_telemetry_expanded_t;

typedef union {
	cmd81_telemetry_expanded_t tele;
	log_entrie_t               log;
	char raw[sizeof(log_header_t) - 1 + TELEMETRY_BYTES + 1];
} message_superset_union_t;

typedef struct
{
	unsigned short flag : 1; /* Flag */
	unsigned short reserved : 15; /* Reserved */
} BIT_CONFIG_DT;

typedef struct {
    char m_recordId[5]; // = {'L','F','C','F','G'};
    unsigned short m_recordSize; // = 15
    unsigned int m_gmtTime;
    unsigned short m_microSec;
    unsigned int m_endian; // = 0xCAFE2BED;
    BIT_CONFIG_DT m_bitConfig;
    unsigned int m_version1;
    unsigned int m_version2;
    unsigned char m_lenSize; // = 2;
    unsigned char m_cs;
}log_file_header_t;
    
enum{
    CMD_OP0,
    CMD_OP1,
    CMD_OP2,
    CMD_OP3,
    CMD_OP4,
    CMD_OP5,
    CMD_OP6,
};

typedef union{
    cmd1_keep_alive_t           cmd1;
    cmd2_tcu_control_t          cmd2;
    cmd3_logfile_maintenance_t  cmd3;
    cmd4_gmt_t                  cmd4;
    cmd5_reg_rw_t               cmd5;
    cmd6_maintenace_t           cmd6;
}cmd_data_t ;

typedef struct {
    cmdhdr_t        hdr;
    cmd_data_t      data;
}udpcmd_t;

#endif //__SHAREDCMD_H__
