#ifndef ASYNCLOG_H
#define ASYNCLOG_H
#include <string>
#include "servercmd.h"
int start_async_log(int save_block_size_mul2,std::string log_path, ServerStatus &server_status ); // power of 2 and minimum 512
int rename_log(std::string newname); 
void end_async_log();
//int print_log(void *msg,int msg_size);
std::string create_log_dir();
void erase_log();
void init_message();

#define NTP_SERVER_IP "192.168.1.10"

#define SW_VER_MJR 1
#define SW_VER_MNR 0

// these are constants from the client (ELBIT) IRS
#define ENDIAN_CONST   (0xCAFE2BED)
// these 2 constants are from the client and they were delivered orally with no indication in any document or email
#define VERSION1_CONST (0x31704A5C)
#define VERSION2_CONST (0x2C9BFC6F)

#endif // ASYNCLOG_H
