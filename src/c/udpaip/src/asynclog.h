#ifndef ASYNCLOG_H
#define ASYNCLOG_H
#include <string>
int start_async_log(int save_block_size_mul2,std::string log_path,std::string dst_log_ip,int dst_log_port ); // power of 2 and minimum 512
int rename_log(std::string newname); 
void end_async_log();
//int print_log(void *msg,int msg_size);
std::string create_log_name();
void erase_log();

#endif // ASYNCLOG_H
