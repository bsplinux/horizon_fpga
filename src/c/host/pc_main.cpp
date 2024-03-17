#include <string.h>
#include <thread>
#include <assert.h>
#include "socket.h"
#include "clilib.h"
#include "sharedcmd.h"

int gcount=0;
int gport = COMMAD_SERVER_PORT;
int msg_count=1;

int cli_cmd(parse_t * pars_p, char *result){
    int opcode =0;
	int src_ip=0,src_port=0;
    udpcmd_t txudpcmd;
	udpcmd_t rxudpcmd;
	int ret;
    memset(&txudpcmd,0,sizeof(txudpcmd));
    memset(&rxudpcmd,0,sizeof(rxudpcmd));
    cget_integer(pars_p,opcode,&opcode);
	int socket = Socket_UDPSocket(); 	
	switch(opcode){
		case CMD_OP1 :{
            //int rx_size;	
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd1_keep_alive_t))	;
            txudpcmd.data.cmd1.message_id = opcode;
            //txudpcmd.data.cmd1.param2 = 2;
            //ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd,txudpcmd.hdr.length + sizeof(txudpcmd.hdr),dst_ip,gport);
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            // std::this_thread::sleep_for(std::chrono::milliseconds(100));
            //rx_size = Socket_ReceiveFrom(socket,(unsigned char *)&rxudpcmd,sizeof(udpcmd_t),(unsigned int *)&src_ip,(unsigned short  *)&src_port);
            //printf("%s.%d tx_size(%d) rx_size(%d) opcode(%d) resp param1(%d) reqp param2(%d)\n\r",__func__,__LINE__,ret,rx_size,rxudpcmd.hdr.opcode,rxudpcmd.data.rp_op1.resp1,rxudpcmd.data.rp_op1.resp2);
            printf("%s.%d tx_size(%d) opcode(%d) \n\r",__func__,__LINE__,ret,rxudpcmd.hdr.opcode);
        }
        break;
		case CMD_OP2 :{
            int param1 = 0;
            int param2 = 0;
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd2_tcu_control_t));
            txudpcmd.data.cmd2.message_id = opcode;
            cget_integer(pars_p,param1,&param1);
            txudpcmd.data.cmd2.tcu_id = param1;
            cget_integer(pars_p,param2,&param2);
            txudpcmd.data.cmd2.on_off = param2;
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            printf("%s.%d tx_size(%d) tcu_id(%d) on_off(%d) \n\r",__func__,__LINE__,ret,param1, param2);	
        }	
        break;
		case CMD_OP3 :{
            int param = 0;
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd3_logfile_maintenance_t));
            txudpcmd.data.cmd3.message_id = opcode;
            cget_integer(pars_p,param,&param);
            txudpcmd.data.cmd3.command = param;
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            printf("%s.%d tx_size(%d) command(%d)\n\r",__func__,__LINE__,ret,param);	
        }	
        break;
		case CMD_OP4 :{
            int param1 = 0;
            int param2 = 0;
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd4_gmt_t));
            txudpcmd.data.cmd4.message_id = opcode;
            cget_integer(pars_p,param1,&param1);
            txudpcmd.data.cmd4.gmt_time = param1;
            cget_integer(pars_p,param2,&param2);
            txudpcmd.data.cmd4.microseconds = param2;
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            printf("%s.%d tx_size(%d) gmt_time(%d) microseconds(%d) \n\r",__func__,__LINE__,ret,param1, param2);	
        }	
        break;
		case CMD_OP5 :{
            int param1 = 0;
            int param2 = 0;
            int param3 = 0;
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd5_reg_rw_t));
            txudpcmd.data.cmd4.message_id = opcode;
            cget_integer(pars_p,param1,&param1);
            txudpcmd.data.cmd5.command = param1;
            cget_integer(pars_p,param2,&param2);
            txudpcmd.data.cmd5.reg_address = param2;
            cget_integer(pars_p,param3,&param3);
            txudpcmd.data.cmd5.reg_data = param3;
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            printf("%s.%d tx_size(%d) command(%d) reg_a(%d) reg_d(%d) \n\r",__func__,__LINE__,ret,param1, param2, param3);	
            int rx_size;
            rx_size = Socket_ReceiveFrom(socket,(unsigned char *)&rxudpcmd.data,sizeof(cmd5_reg_rw_t),(unsigned int *)&src_ip,(unsigned short  *)&src_port);
            printf("%s.%d tx_size(%d) rx_size(%d) command(%d) reg_a(%d) reg_d(%d) )\n\r",__func__,__LINE__,ret,rx_size,rxudpcmd.data.cmd5.command,rxudpcmd.data.cmd5.reg_address,rxudpcmd.data.cmd5.reg_data);
        }	
        break;
		case CMD_OP6 :{
            int param1 = 0;
            int param2 = 0;
            int param3 = 0;
            int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
            txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd6_maintenace_t));
            txudpcmd.data.cmd6.message_id = opcode;
            cget_integer(pars_p,param1,&param1);
            txudpcmd.data.cmd6.board_id = param1;
            cget_integer(pars_p,param2,&param2);
            txudpcmd.data.cmd6.log_mseconds = param2;
            cget_integer(pars_p,param3,&param3);
            txudpcmd.data.cmd6.log_udp_port = param3;
            ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
            printf("%s.%d tx_size(%d) board_id(%d) log_mseconds(%d)  log_udp_port(%d) \n\r",__func__,__LINE__,ret,param1, param2, param3);	
        }	
        break;
	}
	if(socket){
		Socket_Close(socket);
	}
	return 0;
}	

void RegisterDebug(void){
	register_command ((char*)"cmd"     		 ,cli_cmd 		        ,(char*)"op");
}




 void rx_log_task() {
    int rx_size;
    short counter =0;
    unsigned int src_ip  ;
    int src_port ;
    int server_port = LOG_PORT;
    int pkt_size = sizeof(cmd81_telemetry_t) *4;
    cmd81_telemetry_t *p = ( cmd81_telemetry_t *)malloc(pkt_size);
    int  print_cnt = 0;

    int socket = Socket_UDPServer(server_port);
    printf("%s.%d Start Log Server port(%d)  socket(%d)\n\r",__func__,__LINE__,server_port,socket);
    while(1){
            if(!Socket_IsRxPacketMS(socket,100)){
               //printf("%s.%d \n\r",__func__,__LINE__);
               continue;
            }
            rx_size = Socket_ReceiveFrom(socket,(unsigned char *)p,pkt_size,(unsigned int *)&src_ip,(unsigned short  *)&src_port);
            //printf("%s.%d rx(%d) \n\r",__func__,__LINE__,(int )p->message_base.VDC_IN);
            if(p->Message_ID != MESSAGE_ID_CONST){
                printf("%s.%d worng p->Message_ID(0x%x) != MESSAGE_ID_CONST(0x%x) \n\r"  ,__func__,__LINE__,p->Message_ID , MESSAGE_ID_CONST);
            }
            if(p->message_base.VDC_IN != counter){
                printf("%s.%d worng p->message_base.VDC_IN(%d) != counter(%d) \n\r"  ,__func__,__LINE__,(int)p->message_base.VDC_IN , (int)counter);
                counter = p->message_base.VDC_IN ;

            }
            print_cnt = (print_cnt + 1) % 1000; // once in 10 seconds
            if(print_cnt == 0)
            {
                printf("VDC_IN       = %d \n\r",p->message_base.VDC_IN      );
                printf("VAC_IN_PH_A  = %d \n\r",p->message_base.VAC_IN_PH_A );
                printf("VAC_IN_PH_B  = %d \n\r",p->message_base.VAC_IN_PH_B );
                printf("VAC_IN_PH_C  = %d \n\r",p->message_base.VAC_IN_PH_C );
                printf("I_DC_IN      = %d \n\r",p->message_base.I_DC_IN     );
                printf("I_AC_IN_PH_A = %d \n\r",p->message_base.I_AC_IN_PH_A);
                printf("I_AC_IN_PH_B = %d \n\r",p->message_base.I_AC_IN_PH_B);
                printf("I_AC_IN_PH_C = %d \n\r",p->message_base.I_AC_IN_PH_C);
                printf("V_OUT_1      = %d \n\r",p->message_base.V_OUT_1     );
                printf("V_OUT_2      = %d \n\r",p->message_base.V_OUT_2     );
                printf("V_OUT_3_ph1  = %d \n\r",p->message_base.V_OUT_3_ph1 );
                printf("V_OUT_3_ph2  = %d \n\r",p->message_base.V_OUT_3_ph2 );
                printf("V_OUT_3_ph3  = %d \n\r",p->message_base.V_OUT_3_ph3 );
                printf("V_OUT_4      = %d \n\r",p->message_base.V_OUT_4     );
                printf("V_OUT_5      = %d \n\r",p->message_base.V_OUT_5     );
                printf("V_OUT_6      = %d \n\r",p->message_base.V_OUT_6     );
                printf("V_OUT_7      = %d \n\r",p->message_base.V_OUT_7     );
                printf("V_OUT_8      = %d \n\r",p->message_base.V_OUT_8     );
                printf("V_OUT_9      = %d \n\r",p->message_base.V_OUT_9     );
                printf("V_OUT_10     = %d \n\r",p->message_base.V_OUT_10    );
                printf("I_OUT_1      = %d \n\r",p->message_base.I_OUT_1     );
                printf("I_OUT_2      = %d \n\r",p->message_base.I_OUT_2     );
                printf("I_OUT_3_ph1  = %d \n\r",p->message_base.I_OUT_3_ph1 );
                printf("I_OUT_3_ph2  = %d \n\r",p->message_base.I_OUT_3_ph2 );
                printf("I_OUT_3_ph3  = %d \n\r",p->message_base.I_OUT_3_ph3 );
                printf("I_OUT_4      = %d \n\r",p->message_base.I_OUT_4     );
                printf("I_OUT_5      = %d \n\r",p->message_base.I_OUT_5     );
                printf("I_OUT_6      = %d \n\r",p->message_base.I_OUT_6     );
                printf("I_OUT_7      = %d \n\r",p->message_base.I_OUT_7     );
                printf("I_OUT_8      = %d \n\r",p->message_base.I_OUT_8     );
                printf("I_OUT_9      = %d \n\r",p->message_base.I_OUT_9     );
                printf("I_OUT_10     = %d \n\r",p->message_base.I_OUT_10    );
                printf("AC_Power     = %d \n\r",p->message_base.AC_Power    );
                printf("Fan_Speed    = %d \n\r",p->message_base.Fan_Speed   );
                printf("Fan1_Speed   = %d \n\r",p->message_base.Fan1_Speed  );
                printf("Fan2_Speed   = %d \n\r",p->message_base.Fan2_Speed  );
                printf("Fan3_Speed   = %d \n\r",p->message_base.Fan3_Speed  );
                printf("Volume_size  = %d \n\r",p->message_base.Volume_size );
                printf("Logfile_size = %d \n\r",p->message_base.Logfile_size);
                printf("T1           = %d \n\r",p->message_base.T1          );
                printf("T2           = %d \n\r",p->message_base.T2          );
                printf("T3           = %d \n\r",p->message_base.T3          );
                printf("T4           = %d \n\r",p->message_base.T4          );
                printf("T5           = %d \n\r",p->message_base.T5          );
                printf("T6           = %d \n\r",p->message_base.T6          );
                printf("T7           = %d \n\r",p->message_base.T7          );
                printf("T8           = %d \n\r",p->message_base.T8          );
                printf("T9           = %d \n\r",p->message_base.T9          );
                printf("ETM          = %d \n\r",p->message_base.ETM         );
                printf("Major        = %d \n\r",p->message_base.Major       );
                printf("Minor        = %d \n\r",p->message_base.Minor       );
                printf("Build        = %d \n\r",p->message_base.Build       );
                printf("Hotfix       = %d \n\r",p->message_base.Hotfix      );
                printf("SN           = %d \n\r",p->message_base.SN          );
                printf("PSU_Status   = %d \n\r",p->message_base.PSU_Status  );
                printf("Lamp_Ind     = %d \n\r",p->message_base.Lamp_Ind    );
                printf("Spare0       = %d \n\r",p->message_base.Spare0      );
                printf("Spare1       = %d \n\r",p->message_base.Spare1      );
                printf("Spare2       = %d \n\r",p->message_base.Spare2      );
                printf("Spare3       = %d \n\r",p->message_base.Spare3      );
                printf("Spare4       = %d \n\r",p->message_base.Spare4      );
                printf("Spare5       = %d \n\r",p->message_base.Spare5      );
                printf("Spare6       = %d \n\r",p->message_base.Spare6      );
                printf("Spare7       = %d \n\r",p->message_base.Spare7      );
                printf("Spare8       = %d \n\r",p->message_base.Spare8      );
                printf("Spare9       = %d \n\r",p->message_base.Spare9      );               
            }
            counter += 10; 
     }
 }

int main(int argc, char *argv[])
{
   // QCoreApplication a(argc, argv);
    std::thread t([] { rx_log_task();});
    t.detach();
    
   TesttoolInit();
   RegisterDebug();
   TesttoolRun();
   printf("test writ 2 packets, read 2 packets \n\r");
    while(1){
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    return 0;
}


