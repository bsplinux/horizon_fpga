#ifndef UTILS_H
#define UTILS_H

#include <string>

int is_path_exist(const char *path);
int is_path_exist(const std::string path);
int is_mounted(char *mount_point);
int is_mounted(std::string mount_point);
int storage_get_info(std::string mount_point,uint64_t &disk_size,uint64_t &disk_use,uint64_t &disk_free  );


#endif


