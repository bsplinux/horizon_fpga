#ifndef ASYNCLOG_H
#define ASYNCLOG_H
#include <string>
#include "servercmd.h"
int start_async_log(int save_block_size_mul2,std::string log_path, ServerStatus &server_status ); // power of 2 and minimum 512
int rename_log(std::string newname); 
void end_async_log();
//int print_log(void *msg,int msg_size);
std::string create_log_name();
void erase_log();

#define NTP_SERVER_IP "192.168.1.10"

#endif // ASYNCLOG_H
