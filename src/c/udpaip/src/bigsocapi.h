#ifndef BIGSOCAPI_H
#define BIGSOCAPI_H
#include <string>
//using std::string;

namespace bigsoc {
    static const int    DEFAULT_PORT = 7070;
    static const std::string DEFAULT_IP = "127.0.0.1";
}


/*************************************************
 * liberary to read/write with tcp/ip socket
 * can use up to 32 reader
**************************************************/

// must select one:
typedef enum{
    bigsoc_type_writer, // for the writer need to run in different thread of the reader
    bigsoc_type_reader  // for the reader need to run in different thread of the writer
}bigsoc_type_t;

//behavor flags
enum{
    BIGSOC_HAS_START_HEADER, // BIT inform writer/reader that transfer has heder
    BIGSOC_WAIT_FOR_CLIENT, // BIT for writer to wait for its clients
};
// Protocol for network comunication
// TCP is default , for multicast you must use UDP
typedef enum{
    BIGSOC_PROTOCOL_TCP,
    BIGSOC_PROTOCOL_UDP
}bigsoc_protocol_t;

//#ifndef BIT
//#define BIT(b) (1<<(b))
//#endif
// case user not assign ip/port parameters
//#define BIGSOC_DEFUALT_PORT  7070
//#define BIGSOC_DEFUALT_IP  "127.0.0.1"

// open params
struct bigsoc_open_params_t {
	// port:
	// any port recomended to use 7070
    int port = bigsoc::DEFAULT_PORT;            
	// dest_ip:
	//1. support local 127.0.0.1 ,
	//2. unicast like 192.168.0.50 , 
	//3. multicast like 224.0.0.1 ,
    // 4. brodcast like 192.168.0.255
    std::string dest_ip = bigsoc::DEFAULT_IP;   
	//work_mode:
	// bigsoc_type_t  is it writer(0)  or reader(1) 	
	// In TCP protocol the writer is the server but in UDP protocol the reader is the server. 
    bigsoc_type_t work_mode;
	//protocol:
	//bigsoc_protocol_t TCP(0) or UDP(1) 
    bigsoc_protocol_t protocol;
};

typedef struct bigsoc_t{
    //close all sesions for reader or writer
    void (*close)(struct bigsoc_t *&handle);
    // give if any client connected
    int  (*is_client_wait)(struct bigsoc_t *handle);
    // write buffer to all the waited clients
    int  (*write)(struct bigsoc_t *handle,void*pData,int size,unsigned int flags,int dst_ip,int dst_port);
    // client test if there is data to read
    int  (*is_there_data)(struct bigsoc_t *handle,int wait_ms);
    // read data give the length of read it recomended that the given data will biger then
    // transimision data
    int  (*read)(struct bigsoc_t *handle,void*pData,int size,int &src_ip,int &src_port,unsigned int flags);
    void *p_sys; // local handle
}bigsoc_t;
// use of open and setup the liberary open as writer or reader
//#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

bigsoc_t *  bigsoc_open(bigsoc_open_params_t & params);


#ifdef __cplusplus
}
#endif


#endif // BIGSOCAPI_H
