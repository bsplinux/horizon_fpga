
#include <string.h>
#include <thread>
#include <assert.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <chrono>
#include <atomic>
#include "socket.h"
#include "servercmd.h"
#include "sharedcmd.h"
#include "asynclog.h"
#include "regs_pkg.h"

#define REGS_BASE_ADDRESS (0x40000000)

int gcount=0;
int gport=COMMAD_SERVER_PORT;
int msg_count=1;
extern int log_active;
ServerStatus server_status;

unsigned int *regs_a = 0;
registers_t* const registers = (registers_t *)REGS_BASE_ADDRESS;

void memmap_regs(unsigned int physcal_addr){
     int memfd;
     memfd = open("/dev/mem", O_RDWR | O_SYNC); // for fast access
     regs_a = (unsigned int *)mmap(NULL,1024, PROT_READ | PROT_WRITE, MAP_SHARED,memfd, (__off_t)physcal_addr);
}
void unmap_regs(){
     munmap((void*)regs_a,1024);
}

static int active = 1;

std::atomic<bool> stopTask(false); // Global variable to stop the task
void ETI_task() {
	static unsigned int ETI = 0;
	printf("starting ETI task (should operate once an hour)\n\r");
	// read current ETI from SPI FLASH
    // TODO
	while (!stopTask.load()) {
        // store ETI into SPI FLASH
        // TODO
        // set ETI in message
        server_status.message.log.message_base.ETM = ETI;
        printf("ETI updated to %d \n\r",ETI);

        // Sleep for 1 hour
        std::this_thread::sleep_for(std::chrono::hours(1));
        // increment ETI
        ETI++;
    }
}


void alive_task() {
	printf("starting keep alive task (should operate once in 10 seconds)\n\r");
	while (!stopTask.load()) {
        // check if keep alive was sent in the last 10 seconds
        if (server_status.keep_alive_cnt > 0) {
        	server_status.keep_alive_cnt = 0;
        	server_status.message.log.message_base.PSU_Status.fields.MIU_COM_Status = 0; // OK
        }
        else { // set keep alive error
        	// TODO write to keep alive register
        	// registers.GENERAL_CONTROL.CONTROL_ALIVE_ERROR = 1;
        	server_status.message.log.message_base.PSU_Status.fields.MIU_COM_Status = 1; // error in communication
        	printf("ERROR, keep alive not received in the last 10 seconds\n\r");
        }
        // Sleep for 10 seconds
        std::this_thread::sleep_for(std::chrono::seconds(10));
    }
}

int main(int argc, char *argv[])
{
	int minute_cnt = 0;
	int ret = 0;

	//printf("message_superset_union_t = %d\n\r",sizeof(message_superset_union_t));
	//printf("cmd81_telemetry_t = %d\n\r",sizeof(cmd81_telemetry_t));

//	printf("map registers\n\r");
//	memmap_regs(REGS_BASE_ADDRESS);
//	printf("testing write to first 16 regs \n\r");
//	for (int i = 0; i < 16; i++)
//		regs_a[i] = i + 1;
//	printf("testing reading to first 16 regs \n\r");
//	for (int i = 0; i < 16; i++)
//		printf("%02X=%08X  ", i,regs_a[i]);
//	printf ("\n\r");

	server_status.log_udp_port = LOG_PORT;
	printf("PS server start \n\r");
	std::string log_name = create_log_name();
	init_message(server_status);
	start_async_log(1024, log_name, server_status);
	server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 1;
	printf("starting log filename: %s\n\r",log_name.c_str());
	ret = servercmd_start(COMMAD_SERVER_PORT, server_status);
	printf("%d start server \n\r",ret);

	std::thread(ETI_task).detach();
	std::thread(alive_task).detach();

	while(active){
        std::this_thread::sleep_for(std::chrono::seconds(1));
        minute_cnt++;

//        if (minute_cnt == 100){
//				minute_cnt = 0;
//				if (log_active == 1){
//				//unsigned char msg[90]={' '};
//				//sprintf((char*)msg," %d  \n\r",'0' + msg_count++ % 10);
//				//print_log(msg,sizeof(msg));
//				//printf("printing to log\n\r");
//        	}
//        }
	}

	stopTask.store(true);
	servercmd_stop(server_status);
	printf("Stopping cmd server\n\r");
	unmap_regs();
	return 0;
}


