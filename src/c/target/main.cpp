
#include <string.h>
#include <thread>
#include <assert.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <chrono>
#include <atomic>
#include <time.h>

#include "xsysmon_hw.h"

#include "socket.h"
#include "servercmd.h"
#include "sharedcmd.h"
#include "asynclog.h"
#include "regs_pkg.h"
//#include "xparameters.h"
// since xparmeters.h is not found:
#define XPAR_AXI2REGS_0_S00_AXI_BASEADDR 0x43C00000
#define XPAR_SYSMON_0_BASEADDR 0x44A00000U

// axi2regs addres 0x43c00000
// sysmon address 0x44a00000
#define REGS_BASE_ADDRESS XPAR_AXI2REGS_0_S00_AXI_BASEADDR
#define SYSMON_BASE_ADDRESS XPAR_SYSMON_0_BASEADDR

//int gcount=0;
//int gport=COMMAD_SERVER_PORT;
//int msg_count=1;
extern int log_active;
ServerStatus server_status;

volatile unsigned int *sysmon_a = 0;
volatile unsigned int *regs_a = 0;
registers_t* registers = 0;

int SysMonLowLevelExample(unsigned int BaseAddress);

void OS_MSleep(unsigned int ms){
struct timespec timeOut,remains;
        timeOut.tv_sec = ms/1000;
        timeOut.tv_nsec = (ms % 1000) * 1000*1000;
        nanosleep(&timeOut, &remains);

}

volatile unsigned int  * memmap_regs(unsigned int physcal_addr, unsigned int size){
     int memfd;
     volatile unsigned int * regs_maped=0;

     memfd = open("/dev/mem", O_RDWR | O_SYNC); // for fast access
     if (memfd == 0)
     {
    	 printf("could not open /dev/mem at address 0x%08X",physcal_addr);
    	 return 0;
     }
     regs_maped = (volatile unsigned int *)mmap(NULL,size, PROT_READ | PROT_WRITE, MAP_SHARED,memfd, (__off_t)physcal_addr);
     return regs_maped;
}

void unmap_regs(volatile unsigned int *regs_maped, unsigned int size){
     munmap((void*)regs_maped,size);
}

void init_sysmon()
{
	int Status;

	/*
	 * Run the SysMonitor Low level example, specify the Base Address that
	 * is generated in xparameters.h.
	 */
	Status = SysMonLowLevelExample((unsigned int)sysmon_a);
	if (Status != 0) {
		printf("Sysmon lowlevel Example Failed\r\n");
		//return XST_FAILURE;
	}
	//printf("Successfully ran Sysmon lowlevel Example\r\n");
}

unsigned int get_sysmon_sample()
{
	return (XSysMon_ReadReg((unsigned int)sysmon_a, XSM_VPVN_OFFSET) & 0xFFF0) >> 4;
}

static int active = 1;

std::atomic<bool> stopTask(false); // Global variable to stop the task
void ETI_task() {
	static unsigned int ETI = 0;
	printf("starting ETI task (should operate once an hour)\n\r");
	// read current ETI from SPI FLASH and update register
    // TODO
	while (!stopTask.load()) {
        // store ETI into SPI FLASH
        // TODO
        // set ETI in register

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
        else if (server_status.received_first_keep_alive)
        { // set keep alive error
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
	unsigned int vcc12;

	printf("message_superset_union_t = %d\n\r",sizeof(message_superset_union_t));
	printf("cmd81_telemetry_t = %d\n\r",sizeof(cmd81_telemetry_t));

	printf("map sysmon\n\r");
	sysmon_a = memmap_regs(SYSMON_BASE_ADDRESS,64*1024);
	printf("sysmon mapped to virtual address: 0x%08X\n\r", (unsigned int)sysmon_a);

	printf("map registers\n\r");
	regs_a = memmap_regs(REGS_BASE_ADDRESS, 4*1024);
	printf("regs mapped to virtual address: 0x%08X\n\r", (unsigned int)regs_a);
	registers = (registers_t*)regs_a;

	init_sysmon();
	/*
	for (int i = 0; i < 10000000; i++)
	{
		vcc12 = get_sysmon_sample();
		//printf("%s.%d: vcc12 = %X\r\n",__func__,__LINE__,vcc12); OS_MSleep(1);
		printf("%X\r\n",vcc12);OS_MSleep(100);
	}
	*/
	/*
	printf("testing write to first 16 regs \n\r");
    printf("%s.%d\r\n",__func__,__LINE__); OS_MSleep(50);
	for (int i = 0; i < 16; i++)
	{
		printf("%s.%d\r\n",__func__,__LINE__); OS_MSleep(50);
		regs_a[i] = i + 1;
	}
	printf("testing reading to first 16 regs \n\r");
    printf("%s.%d\r\n",__func__,__LINE__); OS_MSleep(50);
	for (int i = 0; i < 16; i++)
	{
		printf("%s.%d\r\n",__func__,__LINE__); OS_MSleep(50);
		printf("%02X=%08X  ", i,regs_a[i]);
	}
	printf ("\n\r");
	*/


	server_status.log_udp_port = MDC_PORT;
	printf("PS server start \n\r");
	//init_message(server_status);
	//start_async_log(1024, log_name, server_status); -- server is starting this not here...
	//server_status.message.log.message_base.PSU_Status.fields.Is_Logfile_Running = 1;
	//printf("starting log filename: %s\n\r",log_name.c_str());
	ret = servercmd_start(PSU_PORT, server_status);
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
	unmap_regs(regs_a, 4*1024);
	unmap_regs(sysmon_a, 64*1024);
	return 0;
}


