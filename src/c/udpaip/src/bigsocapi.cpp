#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>
#include <vector>
#include <cassert>
#include "commondef.h"
#include "bigsocapi.h"
#include "socket.h"

#if  defined(LINUX)
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/sendfile.h>
#include <sys/fcntl.h>
#include <netdb.h>
#include <sys/select.h>
#include <netinet/tcp.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
//#include <QDebug>

#define BIT(b) (1<<(b))


#elif defined(WIN32) || defined(_WIN64)
#include <winsock.h>         // For socket(), connect(), send(), and recv()
typedef int socklen_t;
typedef char raw_type;
#endif

#define MAX_CLIENTS 32
using std::this_thread::sleep_for;
using std::chrono::milliseconds;
using namespace std;

#ifndef _MIN
#define _MIN(a,b) (a)<(b) ? (a) : (b);
#endif


struct bigsoc_imp_t {
    int active_flag = 0;
    int exit_flag = 0;
    bool is_copy;
   // std::vector<int> soc_clients;
    int  client_mask;
    int  connected_clients;
    unsigned int soc_clients[MAX_CLIENTS];
    int rsocket;
    int tmp_soc;
// udp
    int udp_socket;
    int server_port;
    unsigned int server_ip;
    unsigned int frame_number;
    int active=0;
};

struct msg_header_t {
    unsigned char barker[4] = { 'R','d','S','e' };
    unsigned char packet_type[2] = { 'P','C' };
    unsigned char schema_version[2] = { '1','0' };
    unsigned int msg_size = 0;
    unsigned int crc32 = 0;
};

#pragma pack(push, 4)
typedef struct {
    int offset;
    int total_size;
    int frame_number;
}udp_hdr_t;
#pragma pack(pop)

static unsigned int  crc32_tab[] = {
    0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
    0xe963a535, 0x9e6495a3,	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
    0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
    0xf3b97148, 0x84be41de,	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
    0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,	0x14015c4f, 0x63066cd9,
    0xfa0f3d63, 0x8d080df5,	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
    0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,	0x35b5a8fa, 0x42b2986c,
    0xdbbbc9d6, 0xacbcf940,	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
    0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
    0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
    0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,	0x76dc4190, 0x01db7106,
    0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
    0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
    0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
    0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
    0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
    0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
    0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
    0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
    0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
    0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
    0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
    0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
    0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
    0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
    0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
    0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
    0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
    0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
    0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
    0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
    0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
    0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
    0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
    0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
    0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
    0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
    0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
    0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
    0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
    0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
    0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
    0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
};

unsigned int crc32(const void* buf, int  size)
{
    const unsigned char* p;
    unsigned int crc = 0;
    p = (unsigned char*)buf;
    crc = crc ^ ~0U;

    while (size--)
        crc = crc32_tab[(crc ^ *p++) & 0xFF] ^ (crc >> 8);

    return crc ^ ~0U;
}


int bcount(unsigned int i)
{
    // Java: use int, and use >>> instead of >>
    // C or C++: use uint32_t
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}


static int  my_write(struct bigsoc_t* handle, void* pData, int size, unsigned int flags = BIT(BIGSOC_HAS_START_HEADER)) {
    assert(handle != NULL);
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    unsigned int crc = 0;
    unsigned int mask = 0;
    //int count = 0;
    int tx_size[32] = { size };
    unsigned char* b_data[32] = { (unsigned char*)pData };
    int ret = 0;
    msg_header_t  msg_header;
    msg_header.msg_size = size;
    int local_soc_users=0;



    if ((flags & BIT(BIGSOC_WAIT_FOR_CLIENT)) == BIT(BIGSOC_WAIT_FOR_CLIENT)) {
        while (p_sys->client_mask == 0 && p_sys->active_flag) {
            sleep_for(milliseconds(10));
        }
    }

    if (p_sys->client_mask == 0 || p_sys->active_flag == 0) {
        return 0;
    }

    local_soc_users = p_sys->connected_clients;
    for (int i = 0; i < local_soc_users; i++) {
        tx_size[i] = size;
        b_data[i] = (unsigned char*)pData;
    }

    if ((flags & BIT(BIGSOC_HAS_START_HEADER)) == BIT(BIGSOC_HAS_START_HEADER)) {
        crc = crc32(&msg_header, offsetof(msg_header_t, crc32));
        msg_header.crc32 = crc;
        for (int i = 0; i < local_soc_users; i++) {
            //      qDebug("%d/%d \n\r",p_sys->soc_clients.size(),i);

            if(p_sys->client_mask & BIT(i) && p_sys->soc_clients[i]){
                ret = Socket_Send(p_sys->soc_clients[i], (unsigned char*)&msg_header, sizeof(msg_header));
                if (ret <= 0) {
                    Socket_Close(p_sys->soc_clients[i]);
                    p_sys->soc_clients[i] =0;
                    p_sys->client_mask &= !BIT(i);
                    printf("%s.%d close(%d) mask(0x%x)\n\r",__func__,__LINE__,i,p_sys->client_mask);
                }
            }

        }
    }
    //count = p_sys->soc_clients.size();
    mask = p_sys->client_mask;
    while (mask != 0 && p_sys->active_flag) {
        for (int i = 0; i <local_soc_users && p_sys->active_flag; i++) {
            if ((BIT(i) & mask)) {
                ret = Socket_Send(p_sys->soc_clients[i], (unsigned char*)b_data[i], tx_size[i]);
                if (ret <= 0) {
                    Socket_Close(p_sys->soc_clients[i]);
                    mask &= ~BIT(i);
                    p_sys->client_mask &= ~BIT(i);
                    p_sys->soc_clients[i] =0;
                    printf("%s.%d close(%d) mask(0x%x)\n\r",__func__,__LINE__,i,p_sys->client_mask);
                }
                else {
                    b_data[i] += ret;
                    tx_size[i] -= ret;
                    if (tx_size[i] == 0) {
                        mask &= ~BIT(i);
                    }
                }
            }
        }
    }
    // qDebug("mask(0x%x)\n\r",mask);
    return size;
}

static int  my_read(struct bigsoc_t* handle, void* pData, int size, unsigned int flags = BIT(BIGSOC_HAS_START_HEADER)) {
    assert(handle != NULL);
    int ret = 0;
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    unsigned int crc;
    msg_header_t exp_msg_hdr;
    unsigned char* p_ch_exp_hdr = (unsigned char*)&exp_msg_hdr;
    msg_header_t msg_hdr;
    unsigned char* buffer = (unsigned char*)&msg_hdr;
    int rd_size = size;
    int offset = 0;
    int save_size=0;

    if ((flags & BIT(BIGSOC_HAS_START_HEADER)) == BIT(BIGSOC_HAS_START_HEADER)) {
        rd_size = 1;
        // read sync + magic
        while (offset < 8) {        // TBD: why 8 !? shouldn't it be sizeof(msg_hdr.barker) instead?
            ret = Socket_Recv(p_sys->rsocket, (char*)&buffer[offset], rd_size);
            if (ret <= 0) { // we suppose that the socket was close
                return -1;
            }

            if (offset < 8) {
                if (p_ch_exp_hdr[offset] != buffer[offset]) {
                    offset = 0;
                    continue;
                }
            }
            offset += ret;
        }
        //read reset size + crc
        rd_size = 8; // TBD: why =8 !? shouldn't it be sizeof(msg_hdr)-offset instead?
        while (offset < sizeof(msg_hdr)) {
            ret = Socket_Recv(p_sys->rsocket, (char*)&buffer[offset], rd_size);
            if (ret <= 0) { // we suppose that the socket was close
                return -1;
            }
            rd_size -= ret;
            offset += ret;
        }
        rd_size = msg_hdr.msg_size;
        exp_msg_hdr.msg_size = rd_size;
        crc = crc32(&exp_msg_hdr, offsetof(msg_header_t, crc32));
        if (crc != msg_hdr.crc32) {
            return 0;
        }
        if (rd_size > size) {
            rd_size = size;
        }
    }
    buffer = (unsigned char*)pData;
    offset = 0;
    save_size = rd_size;
    while (rd_size > 0) {
        ret = Socket_Recv(p_sys->rsocket, (char*)&buffer[offset], rd_size);
        if (ret <= 0) { // we suppose that the socket was close
            return -1;
        }

        offset += ret;
        rd_size -= ret;
    }
    return save_size - rd_size;
}

static void my_close(struct bigsoc_t*& handle) {
    bigsoc_t* p_tmp = handle;
    if (handle == NULL) return;
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    p_sys->active_flag = 0;
    if (p_sys->rsocket)
        Socket_Close(p_sys->rsocket);

    while (p_sys->client_mask !=0 || p_sys->exit_flag) {
        sleep_for(milliseconds(10));
    }

    handle = NULL;
    free((void*)p_sys);
    free((void*)p_tmp);
}

static int  is_there_data(struct bigsoc_t* handle, int ms) {
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    int ret;
    ret = Socket_IsRxPacketMS(p_sys->rsocket, ms);
    return ret;
}

static int is_client_wait(struct bigsoc_t* handle) {
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    return (p_sys->client_mask !=0);
}

//===================================== UDP ==================================
int udp_write(struct bigsoc_t *handle,void*pData,int size,unsigned int flags,int dst_ip,int dst_port){
   bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
        int ret;
        ret = Socket_SendTo(p_sys->udp_socket,(unsigned char*)pData,size,dst_ip,dst_port);
		//printf("%s.%d dip(0x%x) dport(%d)\n\r",__func__,__LINE__,dst_ip,dst_port);
            
    return ret;
}

int udp_is_there_data(struct bigsoc_t *handle,int wait_ms){
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    int ret;
    ret = Socket_IsRxPacketMS(p_sys->udp_socket, wait_ms);
    return ret;
}

int udp_is_client_wait(struct bigsoc_t *handle){
    return 1;
}


int udp_read(struct bigsoc_t *handle,void*pData,int size,int &src_ip,int & src_port,unsigned int flags){
    bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
    int rx_size=0;
     while(p_sys->active){
        if(p_sys->udp_socket<0){
            return -1;
        }

        int ret = udp_is_there_data(handle,10);
	
        if((ret <=0 )){
            if((flags & BIT(BIGSOC_WAIT_FOR_CLIENT))==0){
                return 0;
            }
			
            continue;
        }
        rx_size = Socket_ReceiveFrom(p_sys->udp_socket,(unsigned char *)pData,size,(unsigned int *)&src_ip,(unsigned short  *)&src_port);
       		
    }
    return rx_size;
}

void udp_close(struct bigsoc_t *&handle){
  bigsoc_imp_t* p_sys = (bigsoc_imp_t*)handle->p_sys;
  bigsoc_t* p_tmp = handle;

   p_sys->active =0;
  if(p_sys->udp_socket>0){
      Socket_Close(p_sys->udp_socket);
  }
  handle = NULL;
  free((void*)p_sys);
  free(handle);
  handle = NULL;
}



bigsoc_t*  bigsoc_open(bigsoc_open_params_t& params) {
    bigsoc_imp_t* p_sys = NULL;
    bigsoc_t* p_ret = NULL;
    int ret=0;
    int ttl=4,isloop=1;
    int socket = 0;
    if (params.port == 0)
        params.port = bigsoc::DEFAULT_PORT;

    if (params.dest_ip.length() == 0)
        params.dest_ip = std::string(bigsoc::DEFAULT_IP);

    if(params.protocol == BIGSOC_PROTOCOL_UDP){
        p_ret = (bigsoc_t*)calloc(1, sizeof(bigsoc_t));
        p_sys = (bigsoc_imp_t*)calloc(1, sizeof(bigsoc_imp_t));
        p_sys->active =1;
        p_ret->write            = udp_write;
        p_ret->read             = udp_read;
        p_ret->close            = udp_close;
        p_ret->is_there_data    = udp_is_there_data;
        p_ret->is_client_wait   = udp_is_client_wait;
        p_ret->p_sys = p_sys;
        if (params.work_mode == bigsoc_type_writer) {

            p_sys->server_port      = params.port;
            p_sys->server_ip        = Socket_Str2Addr((char*)params.dest_ip.c_str());
			p_sys->udp_socket       = Socket_UDPSocket();
            if(((p_sys->server_ip >>24) >= 0xe0) && ((p_sys->server_ip >>24) <= 0xef )){
                // Socket_SetMulticast(p_sys->udp_socket,3,0,0);;
             }
            else if((p_sys->server_ip & 0xff) == 0xff){
              //  Socket_SetBrodcast(p_sys->udp_socket);
            }
            
        }
        else {
            p_sys->server_ip        = Socket_Str2Addr((char*)params.dest_ip.c_str());
            if((p_sys->server_ip >>24) >= 0xe0 && (p_sys->server_ip >>24) <= 0xef ){
                  //  p_sys->udp_socket = Socket_MUDPServer(p_sys->server_ip,params.port);
                }
            else {
                p_sys->udp_socket       = Socket_UDPServer(params.port);
            }
            p_sys->server_port      = params.port;
        }
        return  p_ret;
    }


    if (params.work_mode == bigsoc_type_writer) {
        int s = (int)Socket_TCPServer((unsigned short)params.port);
        if (s <= 0) {
            return NULL;
        }
        p_sys = (bigsoc_imp_t*)calloc(1, sizeof(bigsoc_imp_t));
        p_sys->active_flag = 1;
        p_sys->exit_flag = 1;
        p_sys->connected_clients =0;
        p_sys->client_mask   =0;
        memset(p_sys->soc_clients,0,sizeof(p_sys->soc_clients));

        std::thread t([s, p_sys] {
            int ret;
            struct sockaddr_in clientname;
            int size = sizeof(clientname);
            p_sys->tmp_soc = s;
            while (p_sys->active_flag) {
                int i=0;
                ret = Socket_IsRxPacketMS(s, 100);
                if (ret == 0)
                    continue;

                if (p_sys->connected_clients < 32) {
                    int socket = accept(s, (struct sockaddr*)&clientname, (socklen_t*)&size);
                    //        fprintf(stderr,"%s.%d socet(%d)**********\n\r",__func__,__LINE__,socket);
                    for(i=0;i<p_sys->connected_clients;i++){
                       if(p_sys->soc_clients[i]==0){
                           p_sys->soc_clients[i] = socket;
                           p_sys->client_mask |= BIT(i);
                        //   printf("%s.%d mask(0x%x) i(%d) \n\r",__func__,__LINE__,p_sys->client_mask,i);
                           break;
                       }
                    }
                    if(i== p_sys->connected_clients){// new entery
                        p_sys->soc_clients[i] = socket;
                        p_sys->client_mask |= BIT(i);
                        p_sys->connected_clients++;
                      //  printf("%s.%d mask(0x%x) i(%d) count(%d)\n\r",__func__,__LINE__,p_sys->client_mask,i,p_sys->connected_clients);
                    }
                }
                //break;
            }
            //  fprintf(stderr,"%s.%d exit **********\n\r",__func__,__LINE__);
            for (int i = 0; i < p_sys->connected_clients; i++) {
                if (p_sys->soc_clients[i]) {
                    Socket_Close(p_sys->soc_clients[i]);
                }
            }
            p_sys->connected_clients =0;
            p_sys->client_mask =0;

            if (p_sys->tmp_soc)
                Socket_Close(p_sys->tmp_soc);
            p_sys->tmp_soc = 0;
            p_sys->exit_flag = 0;
            return 0;
        });
        t.detach();

    }

    else {
        socket = (int)Socket_TCPClient((char*)params.dest_ip.c_str(), (int)params.port);
        if (socket <= 0) {
            return NULL;
        }
        p_sys = (bigsoc_imp_t*)calloc(1, sizeof(bigsoc_imp_t));
        p_sys->rsocket = socket;

    }

    p_ret = (bigsoc_t*)calloc(1, sizeof(bigsoc_t));

  //  p_ret->write 	= my_write;
  //  p_ret->read 	= my_read;
    p_ret->close 	= my_close;
    p_ret->is_there_data = is_there_data;
    p_ret->is_client_wait = is_client_wait;
    p_ret->p_sys = p_sys;
    return  p_ret;
}
