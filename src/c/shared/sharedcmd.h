#define COMMAD_SERVER_PORT (1234)
#define SYNC 0xa5
#pragma pack(4)
struct cmdhdr_t{
    unsigned char opcode;
    unsigned char sync;  // 0xa5
    unsigned char count;
    unsigned char length;  // data lenght
    cmdhdr_t() {}
    cmdhdr_t(int op,int cnt,int len) : opcode(op),sync(SYNC),count(cnt),length(len) {}
};

#define TELEMETRY_BYTES (198) // spec says 196???

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
	unsigned char DC_IN_Status                :  0; //
	unsigned char AC_IN_Status                :  1; //
	unsigned char Power_Out_Status            :  2; //
	unsigned char MIU_COM_Status              :  3; //
	unsigned char OUT1_OC                     :  4; //
	unsigned char OUT2_OC                     :  5; //
	unsigned char OUT3_OC                     :  6; //
	unsigned char OUT4_OC                     :  7; //
	unsigned char OUT5_OC                     :  8; //
	unsigned char OUT6_OC                     :  9; //
	unsigned char OUT7_OC                     :  0; //
	unsigned char OUT8_OC                     : 11; //
	unsigned char OUT9_OC                     : 12; //
	unsigned char OUT10_OC                    : 13; //
	unsigned char DC_IN_OV                    : 14; //
	unsigned char OUT1_OV                     : 15; //
	unsigned char OUT2_OV                     : 16; //
	unsigned char OUT3_OV                     : 17; //
	unsigned char OUT4_OV                     : 18; //
	unsigned char OUT5_OV                     : 19; //
	unsigned char OUT6_OV                     : 20; //
	unsigned char OUT7_OV                     : 21; //
	unsigned char OUT8_OV                     : 22; //
	unsigned char OUT9_OV                     : 23; //
	unsigned char OUT10_OV                    : 24; //
	unsigned char DC_IN_UV                    : 25; //
	unsigned char AC_IN_UV                    : 26; //
	unsigned char PH1_Status                  : 27; //
	unsigned char PH2_Status                  : 28; //
	unsigned char PH3_Status                  : 29; //
	unsigned char Neutral_Status              : 30; //
	unsigned char Is_Logfile_Running          : 31; //
	unsigned char Is_Logfile_Erase_In_Process : 32; //
	unsigned char Fan1_Speed_Status           : 33; //
	unsigned char Fan2_Speed_Status           : 34; //
	unsigned char Fan3_Speed_Status           : 35; //
	unsigned char OVER_TEMP_Status            : 36; //
	unsigned char CC_Inhibit                  : 37; //
	unsigned char EC_Inhibit                  : 38; //
	unsigned char System_Reset                : 39; //
	unsigned char System_Off                  : 30; //
	unsigned char MIU_Watchdog_Status         : 41; //
	unsigned char ON_OFF_Switch_State         : 42; //
	unsigned char Capacitor1_end_of_life      : 43; //
	unsigned char Capacitor2_end_of_life      : 44; //
	unsigned char Capacitor3_end_of_life      : 45; //
	unsigned char Capacitor4_end_of_life      : 46; //
	unsigned char Capacitor5_end_of_life      : 47; //
	unsigned char Capacitor6_end_of_life      : 48; //
	unsigned char Capacitor7_end_of_life      : 49; //
	unsigned char Capacitor8_end_of_life      : 50; //
	unsigned char Capacitor9_end_of_life      : 51; //
	unsigned char Capacitor10_end_of_life     : 52; //
	unsigned char Capacitor11_end_of_life     : 53; //
	unsigned char Capacitor12_end_of_life     : 54; //
	unsigned char Capacitor13_end_of_life     : 55; //
	unsigned char Capacitor14_end_of_life     : 56; //
	unsigned char Capacitor15_end_of_life     : 57; //
	unsigned char Capacitor16_end_of_life     : 58; //
	unsigned char Spare0                      : 59; //
	unsigned char Spare1                      : 60; //
	unsigned char Spare2                      : 61; //
	unsigned char Spare3                      : 62; //
	unsigned char Spare4                      : 63; //
}PSU_Status_t;

typedef union {
	PSU_Status_t fields;
	unsigned long long word;
}PSU_Status_union_t;
                                       // Description                                    Units	Range	      Resolution
typedef struct{                        //                                                |------|-------------|---------|
	unsigned char 	    Message_ID   ; // Unique message ID - must be 0x81               N/A	0x81	N/A
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
	unsigned short 	    Fan_Speed    ; // PSU Fan Speed                                  RPM	[1 - 30,000]  1RPM
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
	unsigned long long	Spare0       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare1       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare2       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare3       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare4       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare5       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare6       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare7       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long	Spare8       ; // N/A                                            N/A	N/A	          N/A
	unsigned long long  Spare9       ; // N/A                                            N/A	N/A	          N/A
}cmd81_telemetry_t;

typedef struct{
    char raw[TELEMETRY_BYTES];
}cmd81_telemetry_array_t;

typedef union{
    cmd81_telemetry_t fields;
    cmd81_telemetry_array_t array;
}cmd81_union_t;

enum{
    CMD_OP0,
    CMD_OP1,
    CMD_OP2,
    CMD_OP3,
    CMD_OP4,
    CMD_OP5,
};

typedef union{
    cmd1_keep_alive_t           cmd1;
    cmd2_tcu_control_t          cmd2;
    cmd3_logfile_maintenance_t  cmd3;
    cmd4_gmt_t                  cmd4;
    cmd5_reg_rw_t               cmd5;
}cmd_data_t ;

typedef struct {
    cmdhdr_t        hdr;
    cmd_data_t      data;
}udpcmd_t;


