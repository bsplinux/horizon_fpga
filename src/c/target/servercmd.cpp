#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <thread>
#include <assert.h>
#include <cstring>
#include "socket.h"
//#include "commondef.h"
#include "sharedcmd.h"
#include "asynclog.h"
#include "servercmd.h"
#include "regs_pkg.h"

extern unsigned int * regs_a;
extern int log_mseconds;
extern registers_t* const registers;

static int task_active=0;

ServerStatus::ServerStatus() :
		log_active(true),
		board_id(0),
		received_first_keep_alive(false),
		keep_alive_cnt(0),
		log_mseconds(1),
		log_udp_port(MDC_PORT),
		log_paused(false),
		ETI_task_acitve(true),
		host_ip(0),
		update_log_name(false)
		{
        }

ServerStatus::~ServerStatus() {
}

std::string log_mount_path;
//board command server
int servercmd_start(int server_port, ServerStatus &server_status){
    int count=1;
    if(task_active !=0){
        fprintf(stderr,"%s.%d ERROR allrady start \n\r",__func__,__LINE__);
        return -1;
    }

	task_active = 1;
    fprintf(stderr,"start %d readers \n\r",count);
	log_mount_path = create_log_dir();
	start_async_log(1024, log_mount_path, server_status); //FIXME enable this. log should start automatically

    std::thread t([&count,server_port, &server_status] {
    	int src_ip=0,src_port=0;
		int rx_size;
        int socket = Socket_UDPServer(server_port);
        cmd_data_t *pcmd = (cmd_data_t *) calloc(1,sizeof(cmd_data_t));
        while(task_active){
            if(!Socket_IsRxPacketMS(socket,100)){
               continue;
            }
            //rx_size = Socket_ReceiveFrom(socket,(unsigned char *)pcmd,sizeof(udpcmd_t),(unsigned int *)&src_ip,(unsigned short  *)&src_port);
            rx_size = Socket_ReceiveFrom(socket,(unsigned char *)pcmd,sizeof(cmd_data_t),(unsigned int *)&src_ip,(unsigned short  *)&src_port);
//            if(pcmd->hdr.sync != SYNC){
//				fprintf(stderr,"%s.%d worng sync\n\r",__func__,__LINE__);
//				continue;
//			}
            //fprintf(stderr,"reader pkt rx(%d) \n\r",retr);
            switch(pcmd->cmd1.message_id){
                case  CMD_OP1:
                {
					if(rx_size != (sizeof(pcmd->cmd1))){
						printf("%s.%d  worng packet size  \n\r",__func__,__LINE__);
						continue;
					}
					server_status.keep_alive_cnt++;
					// TODO delete keep alive error if exists
					// registers.GENERAL_CONTROL.CONTROL_ALIVE_ERROR = 0;
					// write to register
					if(!server_status.received_first_keep_alive){  //  first keep alive received
						server_status.received_first_keep_alive = true;
						server_status.host_ip = src_ip;
						printf("received first keep alive, from ip = %d\n\r", src_ip);
					}
					printf("Got cmd(%d) \n\r",pcmd->cmd1.message_id);
					count++;
                }
				break;
                case  CMD_OP2:
                {
					if(rx_size != (sizeof(pcmd->cmd2))){
						printf("%s.%d  worng packet size  \n\r",__func__,__LINE__);
						continue;
					}
					printf("Got cmd(%d) tcu_id(%d) on_off(%d)\n\r",pcmd->cmd2.message_id, pcmd->cmd2.tcu_id, pcmd->cmd2.on_off);
					if (pcmd->cmd2.tcu_id == 0)  //ECTCU
					{
						// do not set the status directly it comes from registers //server_status.message.log.message_base.PSU_Status.fields.EC_Inhibit = pcmd->cmd2.on_off;
						// TODO set register  registers.GENERAL_CONTROL.CONTROL_ECTCU_INH = pcmd->cmd2.on_off;
					}
					else if (pcmd->cmd2.tcu_id == 1)  //CCTCU
					{
						// do not set the status directly it comes from registers //server_status.message.log.message_base.PSU_Status.fields.CC_Inhibit = pcmd->cmd2.on_off;
						// TODO set register  registers.GENERAL_CONTROL.CONTROL_CCTCU_INH = pcmd->cmd2.on_off
					}

					count++;
				}
				break;
                case  CMD_OP3:
                {
					if(rx_size != (sizeof(pcmd->cmd3))){
						printf("%s.%d  worng packet size  \n\r",__func__,__LINE__);
						continue;
					}
					printf("Got cmd(%d) command(%d) \n\r",pcmd->cmd3.message_id, pcmd->cmd3.command);
        		    count++;
        		    if(pcmd->cmd3.command == 0){ // stop log
        		    	if (server_status.log_active) {
        		    		//end_async_log();
        		    		server_status.log_active = false;
        		    		server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 0;
        		    		printf("Pusing Log \n\r");
        		    	}
        		    }
        		    if(pcmd->cmd3.command == 1){ // start log
        		    	if (!server_status.log_active) {
        		    		//std::string log_name = create_log_name();
        		    		//start_async_log(1024, log_name, HOST_IP, server_status);
        		    		server_status.log_active = true;
        		    		server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 1;
        		    		printf("restarting log \n\r");
        		    	}
        		    }
        		    if(pcmd->cmd3.command == 2){ // erase log
        		    	if(server_status.log_active) {
        		    		end_async_log();
        		    		server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 0;
        		    	}
        		    	server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Erase_In_Process = 1;
        		    	erase_log();
        		    	server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Erase_In_Process = 0;
        		    	// now restarting log
        		    	
       		    		start_async_log(1024, log_mount_path, server_status);
       		    		server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 1;
       		    		server_status.log_active = true;
        		        printf("erasing log\n\r");
        		    }
				}
				break;
                case  CMD_OP4:
                {
					if(rx_size != (sizeof(pcmd->cmd4))){
						printf("%s.%d  worng packet size, got %d expected %d  \n\r",__func__,__LINE__,rx_size, sizeof(pcmd->cmd4) );
						continue;
					}
					printf("Got cmd(%d) gmt_time(%d) gmt_microseconds(%d)\n\r",pcmd->cmd4.message_id, pcmd->cmd4.gmt_time, pcmd->cmd4.microseconds);
					// change file name of log
					server_status.update_log_name = true;
					count++;
                }
				break;
                case  CMD_OP5:
                {
					int ret;
					unsigned int reg_val = 0;
                	if(rx_size != (sizeof(pcmd->cmd5))){
						printf("%s.%d  worng packet size  \n\r",__func__,__LINE__);
						continue;
					}
					printf("Got cmd(%d) command(%d) reg_a(%d) reg_d(%d)\n\r",pcmd->cmd5.message_id, pcmd->cmd5.command, pcmd->cmd5.reg_address, pcmd->cmd5.reg_data);
					if(pcmd->cmd5.command == 0){ // write
						//regs_a[pcmd->cmd5.reg_address] = pcmd->cmd5.reg_data;
						//reg_val = regs_a[pcmd->cmd5.reg_address];
					}
					else if (pcmd->cmd5.command == 1){ // read
						//reg_val = regs_a[pcmd->cmd5.reg_address];
						reg_val = pcmd->cmd5.reg_data + 1;
					}

					cmd5_reg_rw_t *resp = (cmd5_reg_rw_t *) calloc(1,sizeof(cmd5_reg_rw_t));
					resp->command = pcmd->cmd5.command;
					resp->reg_address = pcmd->cmd5.reg_address;
					resp->reg_data = reg_val;
					ret = Socket_SendTo(socket,(unsigned char*)resp,sizeof(cmd5_reg_rw_t),src_ip,src_port);
					printf("Sent %d bytes, cmd(%d) command(%d) reg_a(%d) reg_d(%d)\n\r",ret, resp->message_id, resp->command, resp->reg_address, resp->reg_data);
					free(resp);
					count++;
                }
				break;
                case  CMD_OP6:
                {
					if(rx_size != (sizeof(pcmd->cmd6))){
						printf("%s.%d  worng packet size  \n\r",__func__,__LINE__);
						continue;
					}
					if(pcmd->cmd6.log_mseconds > 0)
						server_status.log_mseconds = pcmd->cmd6.log_mseconds;
					if(pcmd->cmd6.board_id > 0) {
						server_status.board_id = pcmd->cmd6.board_id;
						// TODO update board id in registers
					}
					if(pcmd->cmd6.log_udp_port > 0)
						server_status.log_udp_port = pcmd->cmd6.log_udp_port;
					printf("Got cmd(%d) board_id(%d) log_mseconds(%d) log_udp_port(%d)\n\r",pcmd->cmd6.message_id, pcmd->cmd6.board_id, pcmd->cmd6.log_mseconds, pcmd->cmd6.log_udp_port);
					count++;
                }
				break;
                default:
                break;
            }
       }    
		if(socket)
			Socket_Close(socket);
		printf("%s.%d exit server \n\r",__func__,__LINE__);
		return 0;
    });
    t.detach();
		
    return 0;
}

void servercmd_stop(ServerStatus &server_status){
	server_status.~ServerStatus();
	task_active =0;
}

static const char psu_log_id_const[11] = PSU_LOG_ID;
void init_message(ServerStatus &server_status)
{
	memcpy(server_status.message.log.header.Log_ID,psu_log_id_const,10);
	server_status.message.log.header.Log_Payload_Size   = TELEMETRY_BYTES - 1; //the -1 as we do not include the messaage id
	printf("compile Log_Payload_Size %d\n\r",server_status.message.log.header.Log_Payload_Size);
	server_status.message.log.header.GMT_Time           = 0;
	server_status.message.log.header.Micro_Sec          = 0;
	server_status.message.log.footer_checksum           = 0;

	server_status.message.log.message_base.VDC_IN       = 2;
	server_status.message.log.message_base.VAC_IN_PH_A  = 3;
	server_status.message.log.message_base.VAC_IN_PH_B  = 4;
	server_status.message.log.message_base.VAC_IN_PH_C  = 5;
	server_status.message.log.message_base.I_DC_IN      = 6;
	server_status.message.log.message_base.I_AC_IN_PH_A = 7;
	server_status.message.log.message_base.I_AC_IN_PH_B = 8;
	server_status.message.log.message_base.I_AC_IN_PH_C = 9;
	server_status.message.log.message_base.V_OUT_1      = 10;
	server_status.message.log.message_base.V_OUT_2      = 11;
	server_status.message.log.message_base.V_OUT_3_ph1  = 12;
	server_status.message.log.message_base.V_OUT_3_ph2  = 13;
	server_status.message.log.message_base.V_OUT_3_ph3  = 14;
	server_status.message.log.message_base.V_OUT_4      = 15;
	server_status.message.log.message_base.V_OUT_5      = 16;
	server_status.message.log.message_base.V_OUT_6      = 17;
	server_status.message.log.message_base.V_OUT_7      = 18;
	server_status.message.log.message_base.V_OUT_8      = 19;
	server_status.message.log.message_base.V_OUT_9      = 20;
	server_status.message.log.message_base.V_OUT_10     = 21;
	server_status.message.log.message_base.I_OUT_1      = 22;
	server_status.message.log.message_base.I_OUT_2      = 23;
	server_status.message.log.message_base.I_OUT_3_ph1  = 24;
	server_status.message.log.message_base.I_OUT_3_ph2  = 25;
	server_status.message.log.message_base.I_OUT_3_ph3  = 26;
	server_status.message.log.message_base.I_OUT_4      = 27;
	server_status.message.log.message_base.I_OUT_5      = 28;
	server_status.message.log.message_base.I_OUT_6      = 29;
	server_status.message.log.message_base.I_OUT_7      = 30;
	server_status.message.log.message_base.I_OUT_8      = 31;
	server_status.message.log.message_base.I_OUT_9      = 32;
	server_status.message.log.message_base.I_OUT_10     = 33;
	server_status.message.log.message_base.AC_Power     = 34;
	server_status.message.log.message_base.Fan1_Speed   = 35;
	server_status.message.log.message_base.Fan2_Speed   = 36;
	server_status.message.log.message_base.Fan3_Speed   = 37;
	server_status.message.log.message_base.Volume_size  = 0;
	server_status.message.log.message_base.Logfile_size = 0;
	server_status.message.log.message_base.T1           = 40;
	server_status.message.log.message_base.T2           = 41;
	server_status.message.log.message_base.T3           = 42;
	server_status.message.log.message_base.T4           = 43;
	server_status.message.log.message_base.T5           = 44;
	server_status.message.log.message_base.T6           = 45;
	server_status.message.log.message_base.T7           = 46;
	server_status.message.log.message_base.T8           = 47;
	server_status.message.log.message_base.T9           = 48;
	server_status.message.log.message_base.ETM          = registers->COMPILE_TIME.raw;
	printf("compile time 0x%08X\n\r",server_status.message.log.message_base.ETM);
	server_status.message.log.message_base.Major        = 0;
	server_status.message.log.message_base.Minor        = 1;
	server_status.message.log.message_base.Build        = 5;
	server_status.message.log.message_base.Hotfix       = 0;
	server_status.message.log.message_base.SN           = 0;
    server_status.message.log.message_base.PSU_Status.word  = 0;
    server_status.message.log.message_base.Lamp_Ind     = 56;
    server_status.message.log.message_base.FW_Major     = registers->FPGA_VERSION.fields.REV_MAJOR & 0xFF;
    server_status.message.log.message_base.FW_Minor     = registers->FPGA_VERSION.fields.REV_MINOR & 0xFF;
    server_status.message.log.message_base.FW_Build     = 0;
    server_status.message.log.message_base.FW_Hotfix    = 0;
    server_status.message.log.message_base.Spare0       = 57;
    server_status.message.log.message_base.Spare1       = 58;
    server_status.message.log.message_base.Spare2       = 59;
    server_status.message.log.message_base.Spare3       = 60;
    server_status.message.log.message_base.Spare4       = 61;
    server_status.message.log.message_base.Spare5       = 62;
    server_status.message.log.message_base.Spare6       = 63;
    server_status.message.log.message_base.Spare7       = 64;
    server_status.message.log.message_base.Spare8       = 65;
    server_status.message.log.message_base.Spare9       = 66;

    server_status.message.tele.tele.Message_ID          = MESSAGE_ID_CONST;
}

void format_message(ServerStatus &server_status, unsigned int disk_size,unsigned int disk_use)
{
	static short cnt = 0;
	unsigned char checksum;
	// read status from HW and format correctly for LOG
	server_status.message.log.header.GMT_Time           ++;
	server_status.message.log.header.Micro_Sec          ++;

	server_status.message.log.message_base.VDC_IN       = cnt++;//  not samples in this version of the board, for debug = cnt
	/*server_status.message.log.message_base.VAC_IN_PH_A  =          (short)(registers->LOG_VAC_IN_PH_A.raw  & 0xFFFF);
	server_status.message.log.message_base.VAC_IN_PH_B  =          (short)(registers->LOG_VAC_IN_PH_B.raw  & 0xFFFF);
	server_status.message.log.message_base.VAC_IN_PH_C  =          (short)(registers->LOG_VAC_IN_PH_C.raw  & 0xFFFF);
	server_status.message.log.message_base.I_DC_IN      =          (short)(registers->LOG_I_DC_IN.raw      & 0xFFFF);
	server_status.message.log.message_base.I_AC_IN_PH_A =          (short)(registers->LOG_I_AC_IN_PH_A.raw & 0xFFFF);
	server_status.message.log.message_base.I_AC_IN_PH_B =          (short)(registers->LOG_I_AC_IN_PH_B.raw & 0xFFFF);
	server_status.message.log.message_base.I_AC_IN_PH_C =          (short)(registers->LOG_I_AC_IN_PH_C.raw & 0xFFFF);
	server_status.message.log.message_base.V_OUT_1      =          (short)(registers->LOG_V_OUT_1.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_2      =          (short)(registers->LOG_V_OUT_2.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_3_ph1  =          (short)(registers->LOG_V_OUT_3_PH1.raw  & 0xFFFF);
	server_status.message.log.message_base.V_OUT_3_ph2  =          (short)(registers->LOG_V_OUT_3_PH2.raw  & 0xFFFF);
	server_status.message.log.message_base.V_OUT_3_ph3  =          (short)(registers->LOG_V_OUT_3_PH3.raw  & 0xFFFF);
	server_status.message.log.message_base.V_OUT_4      =          (short)(registers->LOG_V_OUT_4.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_5      =          (short)(registers->LOG_V_OUT_5.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_6      =          (short)(registers->LOG_V_OUT_6.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_7      =          (short)(registers->LOG_V_OUT_7.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_8      =          (short)(registers->LOG_V_OUT_8.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_9      =          (short)(registers->LOG_V_OUT_9.raw      & 0xFFFF);
	server_status.message.log.message_base.V_OUT_10     =          (short)(registers->LOG_V_OUT_10.raw     & 0xFFFF);
	server_status.message.log.message_base.I_OUT_1      =          (short)(registers->LOG_I_OUT_1.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_2      =          (short)(registers->LOG_I_OUT_2.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_3_ph1  =          (short)(registers->LOG_I_OUT_3_PH1.raw  & 0xFFFF);
	server_status.message.log.message_base.I_OUT_3_ph2  =          (short)(registers->LOG_I_OUT_3_PH2.raw  & 0xFFFF);
	server_status.message.log.message_base.I_OUT_3_ph3  =          (short)(registers->LOG_I_OUT_3_PH3.raw  & 0xFFFF);
	server_status.message.log.message_base.I_OUT_4      =          (short)(registers->LOG_I_OUT_4.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_5      =          (short)(registers->LOG_I_OUT_5.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_6      =          (short)(registers->LOG_I_OUT_6.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_7      =          (short)(registers->LOG_I_OUT_7.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_8      =          (short)(registers->LOG_I_OUT_8.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_9      =          (short)(registers->LOG_I_OUT_9.raw      & 0xFFFF);
	server_status.message.log.message_base.I_OUT_10     =          (short)(registers->LOG_I_OUT_10.raw     & 0xFFFF);
	server_status.message.log.message_base.AC_Power     = (unsigned short)(registers->LOG_AC_POWER.raw     & 0xFFFF);
	server_status.message.log.message_base.Fan1_Speed   ++;
	server_status.message.log.message_base.Fan2_Speed   ++;
	server_status.message.log.message_base.Fan3_Speed   ++;
	*/
	server_status.message.log.message_base.Volume_size  = disk_size;
	server_status.message.log.message_base.Logfile_size = disk_use;
	/*
	server_status.message.log.message_base.T1           =          (char )(registers->LOG_T1.raw           & 0xFF);
	server_status.message.log.message_base.T2           =          (char )(registers->LOG_T2.raw           & 0xFF);
	server_status.message.log.message_base.T3           =          (char )(registers->LOG_T3.raw           & 0xFF);
	server_status.message.log.message_base.T4           =          (char )(registers->LOG_T4.raw           & 0xFF);
	server_status.message.log.message_base.T5           =          (char )(registers->LOG_T5.raw           & 0xFF);
	server_status.message.log.message_base.T6           =          (char )(registers->LOG_T6.raw           & 0xFF);
	server_status.message.log.message_base.T7           =          (char )(registers->LOG_T7.raw           & 0xFF);
	server_status.message.log.message_base.T8           =          (char )(registers->LOG_T8.raw           & 0xFF);
	server_status.message.log.message_base.T9           =          (char )(registers->LOG_T9.raw           & 0xFF);
	*/
	//server_status.message.log.message_base.ETM        ++;//=  (unsigned int)(registers->LOG_ETM.raw);
	//server_status.message.log.message_base.SN           = (unsigned char)(registers->LOG_SN.raw & 0xFF);
	server_status.message.log.message_base.PSU_Status.word   =  0;//(unsigned long long)0xFFFFFFFF << 32;
	server_status.message.log.message_base.PSU_Status.fields.Fan1_Speed_Status   =  1;//(unsigned long long)0xFFFFFFFF << 32;
	//printf("0x%016llX\n\r",server_status.message.log.message_base.PSU_Status.word);
    //server_status.message.log.message_base.PSU_Status.word   = server_status.message.log.message_base.PSU_Status.fields.DC_IN_Status = 1; // 0xDEADBEAF;
    //server_status.message.log.message_base.Lamp_Ind     ++;

    // calculate checksum
    for(unsigned int i = 0 ; i < sizeof(server_status.message.raw - 1); i++) // -1 to exclude the checksum itself
    	checksum += server_status.message.raw[i];
    //checksum = ~checksum;
	server_status.message.log.footer_checksum           = checksum;
}

