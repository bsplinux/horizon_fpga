/****************************************************************************

File name   : socket.cpp

Description : API of the actions of sockets.

*****************************************************************************/

/* Includes --------------------------------------------------------------- */
//#define WIN32
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef WIN32
#include <time.h>
#include <sys/types.h>
//#include <winsock.h>         // For socket(), connect(), send(), and recv()
#include <ws2tcpip.h>
typedef int socklen_t;
typedef char raw_type;       // Type used for raw data on this platform
#define perror(a)
#elif defined(LINUX)
#include "oslite.h"

//#include <linux/tcp.h>

#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>       // For data types
#include <sys/socket.h>      // For socket(), connect(), send(), and recv()
#include <sys/ioctl.h>
#include <netdb.h>           // For gethostbyname()
#include <arpa/inet.h>       // For inet_addr()
#include <unistd.h>          // For close()
#include <netinet/in.h>      // For sockaddr_in
#include<linux/if.h>
#include <sys/types.h> 
#include <ifaddrs.h> 
#include <netinet/in.h>  
#include <string.h>  
#include <arpa/inet.h>
#include <time.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/ip_icmp.h>

#ifndef _LINUX_TCP_H
/* TCP socket options */
#define TCP_NODELAY		1	/* Turn off Nagle's algorithm. */
#define TCP_MAXSEG		2	/* Limit MSS */
#define TCP_CORK		3	/* Never send partially complete segments */
#define TCP_KEEPIDLE		4	/* Start keeplives after this period */
#define TCP_KEEPINTVL		5	/* Interval between keepalives */
#define TCP_KEEPCNT		6	/* Number of keepalives before death */
#define TCP_SYNCNT		7	/* Number of SYN retransmits */
#define TCP_LINGER2		8	/* Life time of orphaned FIN-WAIT-2 state */
#define TCP_DEFER_ACCEPT	9	/* Wake up listener only when data arrive */
#define TCP_WINDOW_CLAMP	10	/* Bound advertised window */
#define TCP_INFO		11	/* Information about this connection. */
#define TCP_QUICKACK		12	/* Block/reenable quick acks */
#define TCP_CONGESTION		13	/* Congestion control algorithm */
#define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
#define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
#define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
#define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
#define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */

#endif 






typedef void raw_type;       // Type used for raw data on this platform

#endif


//#include "oslite.h"
#define GET_ADDR_LIST
#include "socket.h"

/* Defines ----------------------------------------------------------------- */
#define SERVER_Q_LEB  6
#define MAX_SOCKET_LIST 10

static int m_initialized=0;

static void tcp_sock_opt(int s,int enable);

int Socket_Init(void){
#ifdef WIN32
    if (!m_initialized) {
      WORD wVersionRequested;
      WSADATA wsaData;

      wVersionRequested = MAKEWORD(2, 0);              // Request WinSock v2.0
      if (WSAStartup(wVersionRequested, &wsaData) != 0) {  // Load WinSock DLL
      }
      m_initialized = 1;
    }
  #endif
 return 0;

}

void Socket_Term(void){
#ifdef WIN32
    if (WSACleanup() != 0) {
    }
	m_initialized =0;
 #endif
}


unsigned int Socket_Str2Addr(char *pc_ip){
	if(pc_ip ==0 || pc_ip[0]==0)
		return 0;
	
	return htonl(inet_addr(pc_ip));
}

char  * Socket_Addr2Str(char *buffer,unsigned int ip){
        unsigned char *pIp = (unsigned char *)&ip;
        sprintf(buffer,"%d.%d.%d.%d",(unsigned int)pIp[3],(unsigned int)pIp[2],(unsigned int)pIp[1],(unsigned int)pIp[0]);
        return buffer;
}


unsigned int Socket_Accept(unsigned int socket){
	unsigned int newConnSD;
    if ((int)(newConnSD = accept(socket, NULL, 0)) < 0) {
			perror("**********setsockopt() failed");	  
			return -1;
	}
	return newConnSD;
}



#define INT_TO_ADDR(_addr) \
(_addr & 0xFF), \
(_addr >> 8 & 0xFF), \
(_addr >> 16 & 0xFF), \
(_addr >> 24 & 0xFF)




std::vector<ip_intrf_t> Socket_GetMyAddrList(){
     std::vector<ip_intrf_t> interface_list;
#if defined(LINUX)

    ip_intrf_t ip_intrf;
    struct ifconf ifc;
    struct ifreq ifr[10];
    int sd, ifc_num, addr, bcast, mask, network, i;
    //int j=0;

    /* Create a socket so we can use ioctl on the file
    * descriptor to retrieve the interface info.
    */
    sd = socket(PF_INET, SOCK_DGRAM, 0);
    if(sd <= 0)
        return interface_list;

    ifc.ifc_len = sizeof(ifr);
    ifc.ifc_ifcu.ifcu_buf = (caddr_t)ifr;
    if (ioctl(sd, SIOCGIFCONF, &ifc) != 0){
        close(sd);
        return interface_list;
    }
    ifc_num = ifc.ifc_len / sizeof(struct ifreq);
    //printf("%d interfaces found\n", ifc_num);

    //if(ifc_num > list_size)
    //	ifc_num = list_size;

    for (i = 0; i < ifc_num; ++i){
        if (ifr[i].ifr_addr.sa_family != AF_INET){
            continue;
        }
        /* check interface if up */
        if (ioctl(sd, SIOCGIFFLAGS, &ifr[i]) == 0){
            if(!(ifr[i].ifr_ifru.ifru_flags & IFF_UP)){
                //printf("%d) %s not up\n", i+1,ifr[i].ifr_name);
                continue;
            }
        }
        /* display the interface name */
        /* Retrieve the IP address, broadcast address, and subnet mask. */
        if (ioctl(sd, SIOCGIFADDR, &ifr[i]) == 0){
            addr = ((struct sockaddr_in *)(&ifr[i].ifr_addr))->sin_addr.s_addr;
            //printf("%d) address: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(addr));

            if(strcmp(ifr[i].ifr_name,"lo")==0){
                continue;
            }
            strcpy(ip_intrf.interface_name,ifr[i].ifr_name);
            ip_intrf.ip = htonl(addr);
        }
        if (ioctl(sd, SIOCGIFBRDADDR, &ifr[i]) == 0){
            bcast = ((struct sockaddr_in *)(&ifr[i].ifr_broadaddr))->sin_addr.s_addr;
            //printf("%d) broadcast: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(bcast));
        }
        if (ioctl(sd, SIOCGIFNETMASK, &ifr[i]) == 0){
            mask = ((struct sockaddr_in *)(&ifr[i].ifr_netmask))->sin_addr.s_addr;
            ip_intrf.mask = htonl(mask);
            //printf("%d) netmask: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(mask));
        }

        /* Compute the current network value from the address and netmask. */
        network = addr & mask;

        interface_list.push_back(ip_intrf);

        //printf("%d) network: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(network));
    }
    if(sd)
        close(sd);

    //fprintf(stderr,"%s.%d \n\r",__func__,__LINE__);

    return interface_list;
#else
    return interface_list;
#endif
}

char  *Socket_GetMyAddr(char *addrbuff,char *theinterface){
//char *szRet=0;
#ifndef WIN32
        struct ifconf ifc;
       struct ifreq ifr[10];
       int sd, ifc_num, addr, bcast, mask, network, i;

       /* Create a socket so we can use ioctl on the file
        * descriptor to retrieve the interface info.
        */
       strcpy(addrbuff,"") ;
       sd = socket(PF_INET, SOCK_DGRAM, 0);
       if (sd > 0)
       {
           ifc.ifc_len = sizeof(ifr);
           ifc.ifc_ifcu.ifcu_buf = (caddr_t)ifr;

           if (ioctl(sd, SIOCGIFCONF, &ifc) == 0)
           {
               ifc_num = ifc.ifc_len / sizeof(struct ifreq);
               //printf("%d interfaces found\n", ifc_num);

               for (i = 0; i < ifc_num; ++i)
               {
                   if (ifr[i].ifr_addr.sa_family != AF_INET)
                   {
                       continue;
                   }

                   /* display the interface name */
                   //printf("%d) interface: %s\n", i+1, ifr[i].ifr_name);


                   /* Retrieve the IP address, broadcast address, and subnet mask. */
                   if (ioctl(sd, SIOCGIFADDR, &ifr[i]) == 0)
                   {
                       addr = ((struct sockaddr_in *)(&ifr[i].ifr_addr))->sin_addr.s_addr;
                       //printf("%d) address: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(addr));
                       if(strcmp(ifr[i].ifr_name,theinterface)==0){

                           sprintf(addrbuff,"%d.%d.%d.%d",INT_TO_ADDR(addr));
                           break;
                           //printf("%s -> %s\n\r",addrbuff,theinterface);

                       }


                   }
                   if (ioctl(sd, SIOCGIFBRDADDR, &ifr[i]) == 0)
                   {
                       bcast = ((struct sockaddr_in *)(&ifr[i].ifr_broadaddr))->sin_addr.s_addr;
                       //printf("%d) broadcast: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(bcast));
                   }
                   if (ioctl(sd, SIOCGIFNETMASK, &ifr[i]) == 0)
                   {
                       mask = ((struct sockaddr_in *)(&ifr[i].ifr_netmask))->sin_addr.s_addr;
                       //printf("%d) netmask: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(mask));
                   }

                   /* Compute the current network value from the address and netmask. */
                   network = addr & mask;
                   //printf("%d) network: %d.%d.%d.%d\n", i+1, INT_TO_ADDR(network));
               }
           }

           close(sd);
       }

       //fprintf(stderr,"%s.%d \n\r",__func__,__LINE__);
#endif
	return addrbuff;
}


void Socket_shutdown(int socket){
#ifdef WIN32
        shutdown(socket,3);
#else
        shutdown(socket,SHUT_RDWR);
#endif
}

unsigned int Socket_TCPServer(unsigned short localPort){

	unsigned int s;
    char tmp=1;
	Socket_Init();
	s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	struct sockaddr_in localAddr={0};
	localAddr.sin_family = AF_INET;
	localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	localAddr.sin_port = htons(localPort);
    setsockopt (s, SOL_SOCKET, SO_REUSEADDR ,(char*) &tmp, sizeof (int));
	if (bind(s, (struct sockaddr *) &localAddr, sizeof(struct sockaddr_in)) < 0) {
		
		perror("setsockopt() failed");	  
		return -1;
	}
	if (listen(s, SERVER_Q_LEB)) {
		perror("setsockopt() failed");	  
		return -1;
	}
	
	return s;
}

int Socket_Recv(unsigned int socket,void *buffer, int bufferLen){
  int rtn;
  if ((rtn = recv(socket, (raw_type *) buffer, bufferLen, 0)) < 0) {
	return -1;
  }

  return rtn;
}

int Socket_GetForeignAddress(unsigned int socket,char *address){
  struct sockaddr_in addr;
  unsigned int addr_len = sizeof(addr);
  Socket_Init();	
  if (getpeername(socket, (struct sockaddr *) &addr,(socklen_t *) &addr_len) < 0) {
	perror("***setsockopt() failed");	  
	return -1;
  }
  strcpy(address,inet_ntoa(addr.sin_addr));
  return 0;
}



static void fillAddr(const char *address, unsigned short port,struct sockaddr_in *addr) {
  struct hostent *host=0;  // Resolve name
  memset(addr, 0, sizeof(*addr));  // Zero out address structure
  addr->sin_family = AF_INET;       // Internet address

  if ((host = gethostbyname(address)) == 0) {
    // strerror() will not work for gethostbyname() and hstrerror() 
    // is supposedly obsolete
	return;
  }
  addr->sin_addr.s_addr = *((unsigned long *) host->h_addr_list[0]);

  addr->sin_port = htons(port);     // Assign port in network byte order
}


static void tcp_sock_opt(int s,int enable){
    int optval = enable;
    setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char*)&optval, sizeof(int));
    //setsockopt (s, IPPROTO_TCP, TCP_QUICKACK,(char*) &optval, sizeof (int));
    //optval = 0;
    //setsockopt (s, IPPROTO_TCP, TCP_CORK,(char*) &optval, sizeof (int));
}

int Socket_ZeroCopy(int socket,int enable){
	int ret;
        int on = enable;

        ret = setsockopt(socket, SOL_SOCKET, 60,(char*)&on,sizeof(on));
	return ret;
}

int Socket_TCPClient_NonBlock(char *foreignAddress,int foreignPort){
    unsigned int s;
    struct sockaddr_in destAddr;

    int ret=0;
    int tmp = 0x200000;
    long arg;
#ifdef LINUX
    memset(&destAddr,0,sizeof(destAddr));

    Socket_Init();
    s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if ((int)s  < 0) {
        perror("setsockopt() failed");
        return -1;
    }

    // Set non-blocking
    if((arg = fcntl(s, F_GETFL, NULL)) < 0) {
        fprintf(stderr, "Error fcntl(..., F_GETFL)\n");
        //exit(0);
    }
    arg |= O_NONBLOCK;
    if(fcntl(s, F_SETFL, arg) < 0) {
        fprintf(stderr, "Error fcntl(..., F_SETFL)\n");
        //exit(0);
    }

    setsockopt (s, SOL_SOCKET, SO_SNDBUF,(char*) &tmp, sizeof (int));
    setsockopt (s, SOL_SOCKET, SO_RCVBUF,(char*) &tmp, sizeof (int));


    tcp_sock_opt(s,1);

    fillAddr(foreignAddress, foreignPort, &destAddr);

    // Try to connect to the given port
      ret = connect(s, (struct sockaddr *) &destAddr, sizeof(destAddr));
      if(ret < 0) {
          perror("setsockopt() failed");
          Socket_Close(s);
          return -1;
      }
      
     return s;
#endif
     return 0;
}


int Socket_TCPClient(char *foreignAddress,int foreignPort){
	unsigned int s;
	struct sockaddr_in destAddr={0};

	int ret=0;
	int tmp =0x200000;
	
	Socket_Init();
	s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
   if (s  < 0) {
		//perror("setsockopt() failed");	  
	    return -1;
   }

   setsockopt (s, SOL_SOCKET, SO_SNDBUF,(char*) &tmp, sizeof (int));
   setsockopt (s, SOL_SOCKET, SO_RCVBUF,(char*) &tmp, sizeof (int));
   tcp_sock_opt(s,1);
   
   
   
   
   fillAddr(foreignAddress, foreignPort, &destAddr);

  // Try to connect to the given port
	ret = connect(s, (struct sockaddr *) &destAddr, sizeof(destAddr));
    
    if(ret < 0) {
	  //perror("setsockopt() failed");	
	  Socket_Close(s);
	 return -1;
    }
   return s;
}



int Socket_Send(unsigned int socket,unsigned char *buffer,int bufferLen){
   int ret =-1;
    if(socket<=0){
     //   fprintf(stderr,"%s.%d no socket(%d)\n\r",__func__,__LINE__,socket);
   		return -1;
    }
    ret = send(socket, (raw_type *) buffer, bufferLen, 0);
    if (ret < 0) {
      //  fprintf(stderr,"%s.%d send faield(%d) ******************\n\r",__func__,__LINE__,ret);
	}
   // tcp_sock_opt(socket,1);
    return ret;
}


unsigned int Socket_UDPSocket(void){
	unsigned int s;
	int tmp =0x800000;
	Socket_Init();
	s = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

	setsockopt (s, SOL_SOCKET, SO_RCVBUF,(char*)&tmp, sizeof (int));
    setsockopt (s, SOL_SOCKET, SO_SNDBUF,(char*)&tmp, sizeof (int));

        /* Allow broadcast sending */
//    setsockopt (s, SOL_SOCKET, SO_BROADCAST, &(int){ 1 }, sizeof (int));	

	return s;
}


unsigned int Socket_UDPServer(unsigned short localPort){
	unsigned int s;
	int flag_on = 1;              /* socket option flag */
	int broadcastPermission = 1;
	int tmp =0x200000;
	Socket_Init();
	s = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	struct sockaddr_in localAddr={0};
	localAddr.sin_family = AF_INET;
	localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
	localAddr.sin_port = htons(localPort);
	if ((setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (char*)&flag_on,       sizeof(flag_on))) < 0){
			perror("setsockopt() failed");   
			return 0;
	}	

	if (bind(s, (struct sockaddr *) &localAddr, sizeof(struct sockaddr_in)) < 0) {
		perror("setsockopt() **** failed");	  
		fprintf(stderr,"%s.%d addr in use\n\r",__func__,__LINE__);
		return 0;
	}
	
//	setsockopt(s, SOL_SOCKET, SO_BROADCAST,(raw_type *) &broadcastPermission, sizeof(broadcastPermission));
	//	setsockopt (s, SOL_SOCKET, SO_RCVBUF, &(int){ 0x80000 }, sizeof (int));
	setsockopt (s, SOL_SOCKET, SO_RCVBUF,(char*) &tmp, sizeof (int));

	return s;
}

int  Socket_ReceiveFrom(unsigned int socket,unsigned char *buff,int bufferLen,unsigned int *srcddr,unsigned short *srcport){
	int rtn;
	struct sockaddr_in clntAddr;
	socklen_t addrLen = sizeof(clntAddr);
	rtn = recvfrom(socket, (raw_type *) buff, bufferLen, 0,(struct sockaddr *) &clntAddr,&addrLen);
	*srcddr   = htonl(clntAddr.sin_addr.s_addr);
	*srcport  = htons(clntAddr.sin_port);
  return rtn;
}

int  Socket_SendTo(unsigned int socket,unsigned char *buff,int bufferLen,unsigned int destaddr,unsigned short dstport){
        int rtn=0;
	int txsize;
	struct sockaddr_in  DstAddr={0};
        DstAddr.sin_family = AF_INET;
	DstAddr.sin_addr.s_addr = htonl(destaddr);
	DstAddr.sin_port		= htons(dstport); 
	while(bufferLen >0){
		int size = (bufferLen > 0x8000) ? 0x8000 : bufferLen;
		
		txsize =sendto(socket, (raw_type *) buff, size, 0,(struct sockaddr *) &DstAddr, sizeof(DstAddr));
		if(txsize != size){
			return rtn;
		}
		else{
			rtn +=size;
			buff += size;
			bufferLen-=size;
		}	
	}	
	
	return rtn;
}

int Socket_IsRxPacket(int socket){
	int nread;
	struct timeval tv={0};
	fd_set rfds;
	tv.tv_sec=0;
	tv.tv_usec=3000;
	FD_ZERO(&rfds);
	FD_SET(socket,&rfds);
	nread=select(socket+1,&rfds,NULL,NULL,&tv);
	return nread;
}

int Socket_IsRxPacketUS(int socket,int us){
 int nread;
 #ifdef WIN32
 struct timeval tv={0};
 #else
 struct timespec tv={0};
 #endif
 fd_set rfds;
 tv.tv_sec=us/1000000; 
#ifdef WIN32
 tv.tv_usec=(us % 1000000);
#else
 tv.tv_nsec=(us % 1000000) * 1000;
#endif
 FD_ZERO(&rfds);
 FD_SET(socket,&rfds);
#ifdef WIN32
 nread=select(socket+1,&rfds,NULL,NULL,&tv);
#else
 nread = pselect(socket+1,&rfds,NULL,NULL,&tv,0);
#endif
 return nread;
}

int Socket_IsRxPacketMS(int socket,int ms){
 int nread;
 unsigned int StartTime;
 #ifdef WIN32
 struct timeval tv={0};
 #else
 struct timespec tv={0};
 #endif
 fd_set rfds;
 tv.tv_sec=ms/1000; 
#ifdef WIN32
 tv.tv_usec= (ms % 1000) * 1000;
#else
 tv.tv_nsec=(ms % 1000) * 1000000;
#endif
 FD_ZERO(&rfds);
 FD_SET(socket,&rfds);
#ifdef WIN32
 nread=select(socket+1,&rfds,NULL,NULL,&tv);
#else
 StartTime = OS_GetKHClock();
 nread = pselect(socket+1,&rfds,NULL,NULL,&tv,0);
 StartTime = OS_GetKHClock()-StartTime; 
 //fprintf(stderr,"%s.%d nsec(%d) ms(%d)\n\r",__func__,__LINE__,tv.tv_nsec,StartTime);  	

#endif
 return nread;
}





void Socket_Close(unsigned int socket){

 #ifdef WIN32
    closesocket(socket);
  #else
    close(socket);
  #endif
}

char *Socket_GetMacAddr(char *net_interface ,char *buff){
#ifdef LINUX
    struct ifreq s;
    int fd = socket(PF_INET,SOCK_DGRAM,0);
    memset(&s, 0x00, sizeof(s));
    strcpy(s.ifr_name, net_interface);
    ioctl(fd, SIOCGIFHWADDR, &s);
    close(fd);
    sprintf(buff,"%02x:%02x:%02x:%02x:%02x:%02x",
          (unsigned char) s.ifr_addr.sa_data[0],
          (unsigned char)s.ifr_addr.sa_data[1],
          (unsigned char)s.ifr_addr.sa_data[2],
          (unsigned char)s.ifr_addr.sa_data[3],
          (unsigned char)s.ifr_addr.sa_data[4],
          (unsigned char)s.ifr_addr.sa_data[5]);
   return buff;
#endif
   return 0;
}






static unsigned short checksum(void *b, int len)
{
    unsigned short *buf = (unsigned short *)b;
    unsigned int sum=0;
    unsigned short result;

    for ( sum = 0; len > 1; len -= 2 )
        sum += *buf++;
    if ( len == 1 )
        sum += *(unsigned char*)buf;
    sum = (sum >> 16) + (sum & 0xFFFF);
    sum += (sum >> 16);
    result = ~sum;
    return result;
}

