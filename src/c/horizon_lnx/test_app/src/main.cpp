#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <unistd.h>
#include <string.h>
#include <memory.h>
#include <stdarg.h>
#include <assert.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <linux/reboot.h>
#include <sys/reboot.h>
#define __USE_GNU
#include <sched.h>
#include <pthread.h>

#include "commondef.h"
//#include "oslite.h"
//#include "syslog.h"

#define COMMAND_LINE 

void g_term_api(void);


static char zversion[30]="0.0.2.9";
static void sighandler(int signum, siginfo_t *info, void *ptr);
static struct sigaction act;
static int command_line(char *init_script );


static void sighandler(int signum, siginfo_t *info, void *ptr){
    fprintf(stderr,"close all.. \n\r");
	system("rmmod kdriver_drv.ko");
    exit(0);
}

int main (int argc, char *argv[])
{
    int ret;
	struct stat sb;
    fprintf(stderr,"vsyncc test %s-%s \n\r",__DATE__,__TIME__); 

	 //Capturing the cnrl+c key to exit the system
    act.sa_sigaction = sighandler;
    act.sa_flags = SA_SIGINFO;
    sigaction(SIGINT, &act, NULL);
    sigaction(SIGTERM,&act, NULL);
    sigaction(SIGKILL,&act, NULL);
    //syslog_set_bits(0xffff);
	
	
	if (stat("/kdriver_drv.ko", &sb) == 0) {
        system("rmmod kdriver_drv.ko");
		system("insmod /kdriver_drv.ko");
    }


#ifdef COMMAND_LINE
       command_line("");
#endif
    while(1)
    {
       // OS_MSleep(100);
    }

  return 0;
}


