 /****************************************************************************

File name   : socket.h

Description : API of the actions of sockets.

*****************************************************************************/


#ifndef SOCKET_H
#define SOCKET_H

#include <string>

typedef struct {
 char interface_name[20];
 unsigned int ip;
 unsigned int mask;
}ip_intrf_t;

#ifdef __cplusplus
extern "C" {
#endif
char *Socket_GetError(void);
int Socket_Init(void);
void Socket_Term(void);
unsigned int Socket_Str2Addr(char *pc_ip);
char  * Socket_Addr2Str(char *buffer, unsigned int ip);
unsigned int Socket_Accept(unsigned int socket);
unsigned int Socket_TCPServer(unsigned short localPort);
int Socket_Recv(unsigned int socket,void *buffer, int bufferLen);
int Socket_GetForeignAddress(unsigned int socket,char *address);
int Socket_TCPClient(char *foreignAddress,int foreignPort);
int Socket_Send(unsigned int socket,unsigned char *buffer,int bufferLen);
unsigned int Socket_UDPSocket(void);
unsigned int Socket_UDPServer(unsigned short localPort);
unsigned int Socket_MulticastServer(unsigned int socket,unsigned int groupaddr);
int Socket_SetMulticast(int Socket,int ttl,int isloop,unsigned int interface_ip,char* interface_name=0);
int Socket_SetMulticast2(int sockfd,int ttl,std::string interface_name,std::string multicast_group,int multicast_port);
int Socket_SetBrodcast(int Socket);

int Socket_RemoveMulticast(int Socket);
int Socket_JoinMulticast(int Socket,unsigned int group_ip,unsigned int interface_ip);
int Socket_LeaveMulticast(int Socket);
unsigned int Socket_MUDPServer(unsigned int groupaddr,unsigned short groupPort);
int  Socket_ReceiveFrom(unsigned int socket,unsigned char *buff,int bufferLen,unsigned int *srcaddr,unsigned short *srcport);
int  Socket_SendTo(unsigned int socket,unsigned char *buff,int bufferLen,unsigned int addr,unsigned short port);
int Socket_IsRxPacket(int socket);
int Socket_IsRxPacketUS(int socket,int us);
int Socket_IsRxPacketMS(int socket,int ms);
char  *Socket_GetMyAddr(char *buffer,char *theinterface);
char *Socket_GetMacAddr(char *net_interface,char *buff);
int ping(char *adress, int length,int timeout_ms,int *p_cnt);
void Socket_shutdown(int socket);
void Socket_Close(unsigned int  socket);
int Socket_ZeroCopy(int socket,int enable);
int Socket_hasIPAddress(const std::string& interfaceName);
bool Socket_isInterfaceUp(const char* interfaceName);
#ifdef __cplusplus
}
#endif

#ifdef GET_ADDR_LIST
#include <vector>
std::vector<ip_intrf_t> Socket_GetMyAddrList(void);
#endif


#endif // SOCKET_H
