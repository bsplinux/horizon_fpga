 /****************************************************************************

File name   : oslite.c

Description : API of the actions of task.

*****************************************************************************/
#include "oslite.h"



#if defined LINUX
typedef struct
{
        pthread_mutex_t		Mutex;
        pthread_cond_t		Condition;
        int								SemCount;
}LinuxSemaphore_t;

#endif

int OS_GetTaskPriority (OS_Task_t Task,int *Priority){
#ifdef WIN32
    return GetThreadPriority((HANDLE)Task);
#endif

#ifdef LINUX
          struct sched_param   param;
          int				   policy;
          int				   rc;
          rc = pthread_getschedparam(Task, &policy, &param);
          *Priority = param.sched_priority;

          return rc;
#endif

}



int OS_WaitSemaphore(OS_Semaphore_t Semaphore){
#ifdef WIN32
        int err =	WaitForSingleObject((HANDLE)Semaphore,INFINITE);
        if(err == WAIT_OBJECT_0)
                return 0;
        return OS_TIMEOUT;

#endif

#if defined(LINUX)
        LinuxSemaphore_t  *pSem = (LinuxSemaphore_t  *)Semaphore;
        int rc;

        rc = pthread_mutex_lock(&pSem->Mutex);
        //assert(rc ==0);
        return 0;

#endif
}

int OS_SetSemaphore(OS_Semaphore_t Semaphore){
#ifdef WIN32
        long prev;
        int err;
        err =ReleaseSemaphore((HANDLE)Semaphore,1,&prev);
        if(err ) return 0;
        return -1;
#endif
#if defined(TI_BIOS)
        SEM_post(Semaphore);
#endif

#if defined(LINUX)
         LinuxSemaphore_t  *pSem = (LinuxSemaphore_t  *)Semaphore;
          int rc;
          rc = pthread_mutex_unlock(&pSem->Mutex);
          //assert(rc==0);
#endif

  return 0;
}

OS_Semaphore_t OS_AllocSemaphore(void){
#ifdef WIN32
        return (OS_Semaphore_t)CreateSemaphore(0,1,100,0);
#endif
#if defined(TI_BIOS)
        return SEM_create(1,0);
#endif

#if defined(LINUX)
        int rc;
        LinuxSemaphore_t  *pSem;
        pSem     = (LinuxSemaphore_t *)calloc(1,sizeof(LinuxSemaphore_t));
        //memset((void*)pSem,0,sizeof(*pSem));
        rc = pthread_mutex_init(&pSem->Mutex, NULL);
        assert(rc==0);
        return (OS_Semaphore_t)pSem;
#endif
}

int OS_DeleteSemaphore(OS_Semaphore_t Semaphore){

#ifdef WIN32
        if(Semaphore==0) return -1;
        CloseHandle((HANDLE)Semaphore);
        return 0;
#endif

#if defined(LINUX)
         LinuxSemaphore_t  *pSem = (LinuxSemaphore_t  *)Semaphore;
         pthread_mutex_destroy(&pSem->Mutex);
         free((void*)pSem);
         return 0;
#endif

}

void OS_MSleep(unsigned int ms){
#if defined(WIN32)
        Sleep(ms);
#endif
#if defined(TI_BIOS)
        TSK_sleep(ms );
#endif
#if defined(LINUX)
struct timespec timeOut,remains;
        timeOut.tv_sec = ms/1000;
        timeOut.tv_nsec = (ms % 1000) * 1000*1000;
        nanosleep(&timeOut, &remains);
#endif
}

void OS_MicroSleep(int64_t micro){
#if defined(WIN32)
        Sleep(micro/1000L);
#endif

#if defined(LINUX)
struct timespec timeOut,remains;
        timeOut.tv_sec = micro/1000000L;
        timeOut.tv_nsec = ((micro % 1000000L) *1000L);
        nanosleep(&timeOut, &remains);
#endif
}



unsigned int OS_GetKHClock(void){
#ifdef WIN32
        return clock();
#endif
#if defined(TI_BIOS)
        return CLK_getltime();
#endif
#if defined(FREESCALE_NETCOMM)
 return XX_GetClock();
#endif
#if defined(LINUX)
#if 0
    struct timeval tv;
    gettimeofday(&tv,NULL);
	return (tv.tv_sec * 1000) + (tv.tv_usec/1000);
#endif	
	struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000L +  ts.tv_nsec/1000000L ;
	
#endif
}

uint64_t OS_GetMHClock(void){
#ifdef WIN32
    FILETIME ft;
    int64_t t;
    GetSystemTimeAsFileTime(&ft);
    t = (int64_t)ft.dwHighDateTime << 32 | ft.dwLowDateTime;
    return t / 10 - 11644473600000000; /* Jan 1, 1601 */
#endif    
#if defined(LINUX)
#if 0
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return (uint64_t)tv.tv_sec * 1000000L + (uint64_t)tv.tv_usec;
#endif 
	struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000L +  ts.tv_nsec/1000L ;	
    
#endif
}

uint64_t OS_GetGHClock(void){
	struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return (uint64_t)ts.tv_sec * 1000000000L +  ts.tv_nsec ;	
}
	



int OS_SetSignal(OS_Semaphore_t Semaphore){
#ifdef WIN32
        long prev;
        int err;
        err = ReleaseSemaphore((HANDLE)Semaphore,1,&prev);

        if(err ) return 0;
        dbg_assert(0);

#endif
#if  defined(TI_BIOS)
                SEM_post(Semaphore);
#endif
#if defined(LINUX)
  LinuxSemaphore_t  *pSem = (LinuxSemaphore_t  *)Semaphore;
  pSem->SemCount++;
  pthread_cond_signal	(&pSem->Condition	);
#endif

        return 0;
}

int OS_WaitSignal(OS_Semaphore_t cond,OS_Semaphore_t lock,U32 Time ){

#ifdef WIN32

        int err=0;
        OS_SetSemaphore(lock);
        if(cond ==0) return -1;
        if(Time == TIMEOUT_INFINITY)
                err = WaitForSingleObject((HANDLE)cond,INFINITE);
        else{
                err = WaitForSingleObject((HANDLE)cond,Time);
        }
        if(err == WAIT_OBJECT_0){
                OS_WaitSemaphore(lock);
                return 0;
        }
        OS_WaitSemaphore(lock);
        return OS_TIMEOUT;
#endif

#if defined(LINUX)
        LinuxSemaphore_t  *pCond = (LinuxSemaphore_t  *)cond;
        LinuxSemaphore_t  *pLoc = (LinuxSemaphore_t  *)lock;
        int rc;
        int ret =0;

//        pthread_mutex_unlock(&pLoc->Mutex		);
        if(Time == TIMEOUT_INFINITY){
                rc = pthread_cond_wait(&pCond->Condition, &pLoc->Mutex);
        }
        else{
			 struct timespec timeout={0};
                uint64_t t=   OS_GetMHClock() + (uint64_t)(Time*1000);
				struct timespec tv = { .tv_sec  =  t / 1000000,
                                       .tv_nsec = (t % 1000000) * 1000 };
                rc =  pthread_cond_timedwait(&pCond->Condition,  &pLoc->Mutex, &tv);
                if(rc== ETIMEDOUT)
                      ret= OS_TIMEOUT;
        }

  //      pthread_mutex_lock	(&pLoc->Mutex);
        return ret;
#endif
}

OS_Semaphore_t OS_AllocSignal(void){
#ifdef WIN32
        return CreateSemaphore(0,0,100,0);
#endif
#if defined(TI_BIOS)
        return SEM_create(0,0);
#endif
#if defined(LINUX)
        int rc=0;
        LinuxSemaphore_t  *pSem;
        pSem     = (LinuxSemaphore_t  *)calloc(1,sizeof(LinuxSemaphore_t));
        assert(pSem !=0);
        memset((void*)pSem,0,sizeof(LinuxSemaphore_t));
        rc = pthread_cond_init(&pSem->Condition, NULL);
        assert(rc ==0);
        return (OS_Semaphore_t)pSem;
#endif
}

int OS_DeleteSignal(OS_Semaphore_t Semaphore){
#ifdef WIN32
        CloseHandle((HANDLE)Semaphore);
        return 0;
#endif

#if defined(LINUX)
         LinuxSemaphore_t  *pSem = (LinuxSemaphore_t  *)Semaphore;
         pthread_cond_destroy(&pSem->Condition);
         free((void*)pSem);
         return 0;
#endif
}

OS_Task_t  OS_TaskCreate(U32 StackSize,char *TaskName,OS_TaskFunc_t TaskFunc,int Priority,void *Param){
#if  defined(WIN32)
        U32 ThreadId;
        OS_Task_t task ;
    //*task = _beginthread( function, stack_size, 0);
        task = (OS_Task_t)CreateThread(
                0,										// pointer to security attributes
                StackSize,								// initial thread stack size
                (LPTHREAD_START_ROUTINE) TaskFunc,       // pointer to thread function
                Param,									 // argument for new thread
                CREATE_SUSPENDED,									 // creation flags
                (unsigned long *)&ThreadId                                // pointer to receive thread ID
                );

        SetThreadPriority((HANDLE)task,Priority);
        ResumeThread((void*)task);
        return task;
#endif
#if defined(LINUX)
        pthread_t hthread;
        int rc;
        pthread_attr_t attr;
		int policy, s;
		struct sched_param param;

		
        rc = pthread_attr_init(&attr);
        rc = pthread_attr_setstacksize(&attr, StackSize);
//    rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

        rc = pthread_create(&hthread, &attr, (void*(*)(void*))TaskFunc, Param);
        if(rc != 0){
           return 0;
        }
		
		s = pthread_getschedparam(hthread, &policy, &param);
		
		param.sched_priority = Priority;
		policy = SCHED_RR;
		pthread_setschedparam(hthread, policy, &param);
		 
    return (OS_Task_t )hthread;
#endif
}


int  OS_TaskCreate2(U32 StackSize,const char *TaskName,OS_TaskFunc_t TaskFunc,int Priority,void *Param){
#if  defined(WIN32)
    U32 ThreadId;
    OS_Task_t task ;
    //*task = _beginthread( function, stack_size, 0);
    task = (OS_Task_t)CreateThread(
                0,										// pointer to security attributes
                StackSize,								// initial thread stack size
                (LPTHREAD_START_ROUTINE) TaskFunc,      // pointer to thread function
                Param,									// argument for new thread
                CREATE_SUSPENDED,						// creation flags
                (unsigned long *)&ThreadId              // pointer to receive thread ID
                );

    SetThreadPriority((HANDLE)task,Priority);
    ResumeThread((void*)task);
    CloseHandle((HANDLE)task);
    return 0;
#endif
#if defined(LINUX)
    pthread_t hthread;
    int rc;
    pthread_attr_t attr={0};
    int policy=0, s=0;
    struct sched_param param={0};


    rc = pthread_attr_init(&attr);
    rc = pthread_attr_setstacksize(&attr, StackSize);
    //    rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

    rc = pthread_create(&hthread, &attr, (void*(*)(void*))TaskFunc, Param);
    if(rc != 0){
        return -1;
    }
    rc = pthread_detach(hthread);

    s = pthread_getschedparam(hthread, &policy, &param);

    param.sched_priority = Priority;
    policy = SCHED_RR;
    pthread_setschedparam(hthread, policy, &param);
    return 0;
#endif
}




OS_Task_t  OS_TaskCreateCPU(int StackSize,char *TaskName, OS_TaskFunc_t  TaskFunc,int Priority,int CpuNo,void *Param){
#if defined(LINUX)
			pthread_t hthread;
			int rc;
			int i;
			cpu_set_t cpu;
			pthread_attr_t attr;
			int policy, s;
			struct sched_param param;
			
			rc = pthread_attr_init(&attr);
			rc = pthread_attr_setstacksize(&attr, StackSize);
	//	  rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
			rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
	
			rc = pthread_create(&hthread, &attr, (void*(*)(void*))TaskFunc, Param);
			if(rc != 0){
				return 0;
			}

			s = pthread_getschedparam(hthread, &policy, &param);
			
			param.sched_priority = Priority;
			//rc = pthread_setschedparam(hthread, SCHED_RR   , &param);
			//fprintf(stderr,"**********%s.%d (%d) %d= set[%s]->Priority(%d) policy(%d)\n\r",__func__,__LINE__,s,rc,TaskName,Priority,policy);
			
			//CPU_ZERO(&cpu);
			//for(i=0;i<4;i++)
			//	CPU_SET(i, &cpu);
			//rc = pthread_setaffinity_np(hthread, sizeof(cpu_set_t), &cpu);
						
			return (OS_Task_t )hthread;
#endif
	
}

int        OS_GetCPUCount(void){
	
	 long nprocs	   = -1;
	 long nprocs_max   = -1;
	
# ifdef _SC_NPROCESSORS_ONLN
		nprocs = sysconf( _SC_NPROCESSORS_ONLN );
		if ( nprocs < 1 )
		{
			
			fprintf(stderr,"Could not determine number of CPUs on line. Error is %s \n\r",strerror( errno ));
			return 0;
		}
	
		nprocs_max = sysconf( _SC_NPROCESSORS_CONF );
	
		if ( nprocs_max < 1 )
		{
			fprintf(stderr,"Could not determine number of CPUs in host. Error is  %s \n\r",strerror( errno ));
			return 0;
		}
	

		return nprocs; 
	
#else
		//std::cout << "Could not determine number of CPUs" << std::endl;
		return 0;
#endif
}

int 	   OS_SwitchThreadCPU(OS_Task_t Task,int CpuNo){
#ifdef WIN32
    return 0;
#else
			int rc;
			cpu_set_t cpu;
			CPU_ZERO(&cpu);
			CPU_SET(CpuNo, &cpu);
			rc = pthread_setaffinity_np((pthread_t)Task, sizeof(cpu_set_t), &cpu);
			return rc;
#endif
}

int 	   OS_GetThreadCPU(OS_Task_t Task){
#ifdef WIN32
    return 0;
#else
			int ret;
			int i;
			cpu_set_t cpu;
			CPU_ZERO( &cpu );
			ret = pthread_getaffinity_np((pthread_t)Task  , sizeof( cpu_set_t ), &cpu);
			return ret;
#endif
}

int OS_TaskWait(OS_Task_t Task,U32 TimeOut){
#ifdef WIN32
U32 Time =TimeOut;
U32  terminat;

        while(GetExitCodeThread((HANDLE)Task,(unsigned long *)&terminat)){

                if((terminat != STILL_ACTIVE) )
                        return 0;

                if(TIMEOUT_INFINITY != TimeOut)
                {
                        Time-=1;
                        if(Time<1)
                                break;
                }
                if(TIMEOUT_IMMEDIATE == TimeOut)
                        break;
                OS_MSleep(1);
        }

#endif

#if defined(LINUX)
        U32 Time =TimeOut;
        while(OS_IsTaskRunning(Task)){
                if(TIMEOUT_INFINITY != TimeOut)
                {
                        Time-=10;
                        if(Time<10)
                                break;
                }
                if(TIMEOUT_IMMEDIATE == TimeOut)
                        break;
                OS_MSleep(1);
        }

#endif
        return -1;
}

int OS_IsTaskRunning(OS_Task_t Task){
#if  defined(WIN32)
        if(GetThreadPriority((HANDLE)Task) != THREAD_PRIORITY_ERROR_RETURN)
                return 1;
#endif

#if defined(LINUX)
        if(pthread_kill(Task, 0) == 0) return 1;
#endif
        return 0;
}

void OS_TaskDelete(OS_Task_t Task){
#ifdef WIN32
        if(Task){
                OS_TaskWait(Task,  TIMEOUT_INFINITY);
                CloseHandle((HANDLE)Task);
        }
#endif

#if defined(LINUX)
        int rc;

        //OS_TaskWait(Task,  TIMEOUT_INFINITY);
        rc = pthread_join(Task,0);
        rc = pthread_detach(Task);
#endif
}

OS_Task_t  OS_TaskGetSelf(void){
#if defined(WIN32)
        return (OS_Task_t)GetCurrentThread();
#endif
#if defined(TI_BIOS)
        OS_Task_t curtask;
        curtask = TSK_self();
        return curtask;
#endif
#if defined(LINUX)
        return pthread_self();
#endif

}

#ifdef MYALLOC

static unsigned int g_allocsize=0;

void *my_malloc(int size ){
	unsigned int *pret;
	pret = malloc(size+4);
	pret[0]=size;
	g_allocsize += size;
	//fprintf(stderr,"alloc(%d)  total(%d) [0x%x],[0x%x]\n\r",size,g_allocsize,&pret[1],pret);
	return (void*)&pret[1];
}


void *my_calloc(int items,int size ){
	unsigned int *pret;
	pret = calloc(items,size+4);
	pret[0]=size;
	g_allocsize += size*items;
//	fprintf(stderr,"alloc(%d)  total(%d) [0x%x],[0x%x]\n\r",size*items,g_allocsize,&pret[1],pret);
	return (void*)&pret[1];
}


void my_free(void *ptr){
	if(ptr){
		int size;
		unsigned int *pret= (unsigned int *)((unsigned int)ptr -4);
		size = pret[0];
		g_allocsize -= size;
		//fprintf(stderr,"my_free(%d)  total(%d) [0x%x],[0x%x] \n\r",size,g_allocsize,pret,ptr);		
		free((void*)pret);

	}
}
#endif


int OS_SetPriortyClass(int preiorty){

#if  defined(WIN32)
    int ret=0;
    ret = SetPriorityClass(GetCurrentProcess(),preiorty);
    return ret;
#endif
}


void OS_Reboot(void){
#if defined(LINUX)
  fprintf(stderr,"%s 1 reboot \n\r",__func__); 
  OS_MSleep(100);
  sync();
  setuid(0);
  //reboot(LINUX_REBOOT_CMD_MARIS);
  reboot(RB_AUTOBOOT);
  fprintf(stderr,"%s 2 reboot \n\r",__func__); 
  OS_MSleep(1000);
#endif
}



int SleepInterrupt(int sleep_ms,int min_sleep,int *active_task ){
	int sleep_sum=0;
	while(*active_task){
		OS_MSleep(min_sleep);
		sleep_sum += min_sleep;
		if(sleep_sum>=sleep_ms){
            return 0;
		}	
	}
	return 1;
}

