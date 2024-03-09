extern "C" {
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <mntent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <mntent.h>
#include <sys/vfs.h>
#include <assert.h>
#include <dirent.h>
#include <errno.h>
#include <stdint.h>
#include <sys/mman.h>
#include <linux/input.h>
#include <fcntl.h>
#include "syslog.h"

};
#include <unistd.h>
#include <thread>
#include <vector>
#include <ctime>
#include <mutex>
#include <condition_variable>
#include <algorithm>
#include <cassert>
#include "kdriver.h"



#include "clilib.h"

using namespace std;



#define  GB 0x10000000






static uint64_t OS_GetKHClock(void){
 //   struct timeval tv;
    //gettimeofday(&tv,NULL);
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000L +  ts.tv_nsec/1000000L ;
}


static uint64_t OS_GetMHClock(void){
 //   struct timeval tv;
    //gettimeofday(&tv,NULL);
	int ret;
    struct timespec ts;
    ret = clock_gettime(CLOCK_MONOTONIC , &ts);
    return (uint64_t)ts.tv_sec * 1000000L +  (uint64_t)ts.tv_nsec/1000L ;
}

static uint64_t OS_GetGHClock(void){
 //   struct timeval tv;
    //gettimeofday(&tv,NULL);
    struct timespec ts;
	int ret;	
    ret = clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000000L +  (uint64_t)ts.tv_nsec ;
}


int cli_regio(parse_t * pars_p, char *result){
	int memfd=0;
	volatile unsigned int  *p_vaddr= 0;
	unsigned int    reg_base =  0x40000000;
	unsigned int    bank_size = 0x1000;
	int    			reg_idx   =0;
	int    			reg_val   =-1;
	cget_integer(pars_p,reg_idx,&reg_idx);
	cget_integer(pars_p,reg_val,&reg_val);


	// open with disable cashing 
	memfd = open("/dev/mem", O_RDWR | O_SYNC); // for fast access
	if(memfd <=0){
		printf("%s.%d fail to open(%s)\n\r",__func__,__LINE__,"/dev/mem");
		return 0;
	}	
	p_vaddr = (volatile unsigned int *)mmap(NULL, bank_size, PROT_READ | PROT_WRITE, MAP_SHARED,memfd,(__off_t)reg_base);	
	if((unsigned char*)p_vaddr == (unsigned char*)-1 ){
		printf("%s.%d memory map failure\n\r",__func__,__LINE__);
		p_vaddr = 0;
		return 0;				
	}
	if(reg_val == -1){
		reg_val = p_vaddr[reg_idx];
	}
	else {
		p_vaddr[reg_idx] = reg_val;
	}
	munmap((void*)p_vaddr,bank_size);
	printf("reg(0x%x) val(0x%x) \n\r",reg_idx,reg_val);
	close(memfd);
	return 0;
}	



int cli_devtree(parse_t * pars_p, char *result){
int ret;
char devname[80] = {0}; 
	cget_string(pars_p,devname,devname,sizeof(devname));
	return 0;
}


static int fd=0;


int cli_intr_test(parse_t * pars_p, char *result){
	char devname[80] = {0};
	int ret=0;
	uint64_t timer64=0; 
	
	wait_timer_t wait_timer ={0};
	sprintf(devname,"/dev/%s0",AXIIMP_NAME);
	fd = open(devname, O_RDWR);	
	if(fd>0){
		wait_timer.wait_timeout_ms = 1000;
		timer64 = OS_GetMHClock();
		ret = ioctl(fd,ZYNQCMD_WAIT_TIMER,&wait_timer);	
		timer64 = (OS_GetMHClock() - timer64);
		printf("finish time(%lld)\n\r",timer64);
		close(fd);
	}	
	return 0;
}	



void RegisterDebug(void){
	register_command((char*)"regio"	    ,cli_regio			 	,(char*)"<reg><val> read from reg");	
	register_command((char*)"intrw"	    ,cli_intr_test		 	,(char*)"<int irq> with on irq");	
	register_command((char*)"devtree"	,cli_devtree		 	,(char*)"find <name>");		
}


int command_line(char *init_script ){
	TesttoolInit();
	RegisterDebug();
	TesttoolRun();
    return 0;
}	


