
#include <string.h>
#include <thread>
#include <assert.h>
#include "socket.h"
#include "clilib.h"
#include "commondef.h"
#include "servercmd.h"
#include "sharedcmd.h"
#include "asynclog.h"

int gcount=0;
int gport=1234;

int cli_start_server(parse_t * pars_p, char *result){

    int ret;
	cget_integer(pars_p,gport,&gport);
    ret = servercmd_start(gport);
	printf("%d start server \n\r",ret);
	return 0;
}

int cli_end_server(parse_t * pars_p, char *result){
	servercmd_stop();
	return 0;
}

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
                int rx_size;
                int dst_ip  = Socket_Str2Addr((char*)"192.168.1.30");
                txudpcmd.hdr = cmdhdr_t(opcode,gcount++,sizeof(cmd1_keep_alive_t))	;
                txudpcmd.data.cmd1.message_id = opcode;
                //txudpcmd.data.cmd1.param2 = 2;
                //ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd,txudpcmd.hdr.length + sizeof(txudpcmd.hdr),dst_ip,gport);
                ret = Socket_SendTo(socket,(unsigned char*)&txudpcmd.data,txudpcmd.hdr.length,dst_ip,gport);
                // std::this_thread::sleep_for(std::chrono::milliseconds(100));
                //rx_size = Socket_ReceiveFrom(socket,(unsigned char *)&rxudpcmd,sizeof(udpcmd_t),(unsigned int *)&src_ip,(unsigned short  *)&src_port);
                //printf("%s.%d tx_size(%d) rx_size(%d) opcode(%d) resp param1(%d) reqp param2(%d)\n\r",__func__,__LINE__,ret,rx_size,rxudpcmd.hdr.opcode,rxudpcmd.data.rp_op1.resp1,rxudpcmd.data.rp_op1.resp2);
                printf("%s.%d tx_size(%d) rx_size(%d) opcode(%d) \n\r",__func__,__LINE__,ret,rx_size,rxudpcmd.hdr.opcode);
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
        }
	if(socket){
		Socket_Close(socket);
	}
	return 0;
}	

int cli_start_log(parse_t * pars_p, char *result){
   start_async_log(1024,"d:/log",std::string("127.0.0.1"),4000);
   return 0;
}

int cli_end_log(parse_t * pars_p, char *result){
   end_async_log();
   return 0;
}

int cli_log(parse_t * pars_p, char *result){
      unsigned char msg[90];
     // print_log(msg,sizeof(msg));
      return 0;
}

void RegisterDebug(void){
    register_command ((char*)"sserver"       ,cli_start_server       ,(char*)"<port>");
    register_command ((char*)"eserver"       ,cli_end_server       ,(char*)"<port>");
	register_command ((char*)"cmd"     		 ,cli_cmd 		        ,(char*)"op");
    register_command ((char*)"slog"          ,cli_start_log 	    ,(char*)"");
    register_command ((char*)"elog"          ,cli_end_log 	        ,(char*)"");
   // register_command ((char*)"log"           ,cli_log               ,(char*)"");
}

int main(int argc, char *argv[])
{
   // QCoreApplication a(argc, argv);

   TesttoolInit();
   RegisterDebug();
   TesttoolRun();
   printf("test writ 2 packets, read 2 packets \n\r");
    while(1){
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    return 0;
}


