#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <thread>
#include <assert.h>
#include "socket.h"
//#include "commondef.h"
#include "sharedcmd.h"
#include  "asynclog.h"
#include "servercmd.h"

extern unsigned int * regs_a;
extern int log_mseconds;


static int task_active=0;

ServerStatus::ServerStatus() :
		log_active(true),
		board_id(0),
		received_first_keep_alive(false),
		keep_alive_cnt(0),
		log_mseconds(1),
		log_udp_port(4000),
		log_paused(false),
		ETI_task_acitve(true),
		host_ip(0),
		update_log_name(false)
		{
}

ServerStatus::~ServerStatus() {
}

//board command server
int servercmd_start(int server_port, ServerStatus &server_status){
    int count=1;
    if(task_active !=0){
        fprintf(stderr,"%s.%d ERROR allrady start \n\r",__func__,__LINE__);
        return -1;
    }

	task_active = 1;
    fprintf(stderr,"start %d readers \n\r",count);

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
						printf("received first keep alive, from ip = %d", src_ip);
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
        		    	std::string log_name = create_log_name();
       		    		start_async_log(1024, log_name, server_status);
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



