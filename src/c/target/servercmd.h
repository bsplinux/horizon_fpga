#ifndef SERVERCMD_H
#define SERVERCMD_H
#include <string>
#include "sharedcmd.h"

class ServerStatus {
public:
	bool log_active;
	int board_id;
	bool received_first_keep_alive;
	unsigned char keep_alive_cnt;
	int log_mseconds;
	int log_udp_port;
	bool log_paused;
	bool ETI_task_acitve;
	unsigned int host_ip;
	bool update_log_name;
	message_superset_union_t message;
	ServerStatus();
    ~ServerStatus();
};

int  servercmd_start(int server_port, ServerStatus &server_status);
void servercmd_stop(ServerStatus &server_status);

void init_message(ServerStatus &server_status);
void format_message(ServerStatus &server_status, unsigned int disk_size,unsigned int disk_use);


#endif
