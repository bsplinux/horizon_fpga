#ifndef SERVERCMD_H
#define SERVERCMD_H
#include <string>

class ServerStatus {
public:
	bool log_active;
	int board_id;
	bool received_keep_alive;
	int log_mseconds;
	int log_udp_port;
	ServerStatus();
    ~ServerStatus();
};

int  servercmd_start(int server_port, ServerStatus &server_status);
void servercmd_stop(ServerStatus &server_status);
#endif
