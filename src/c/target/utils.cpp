#include "utils.h"


int is_mounted(char *mount_point){
	struct stat mountpoint;
	struct stat parent;
	char mountp[80]={0};
	sprintf(mountp,"%s",mount_point);
	
	if (stat(mountp, &mountpoint) == -1) {
		return 0;
	}
	sprintf(mountp,"%s/..",mount_point);

	if (stat(mountp, &parent) == -1) {
		return 0;
	}

	if (mountpoint.st_dev == parent.st_dev) {
    	return 0;	
	} else {
    	return 1;
	}
	return 0;
}

int is_mounted(std::string  mount_point){
	return is_mounted((char*)(mount_point.c_str()));	
}

int mount(std::string device, std::string dir){

    int ret = 0;
    int l = 100 + device.length() + dir.length();
    char *pcmd = (char*)calloc(1,l);

    if(pcmd ==0){
        fprintf(stderr,"%s.%d alloc(%d) fail \n\r",__func__,__LINE__,l);
        return -1;
    }

    if(!is_path_exist(device)){
        fprintf(stderr,"%s.%d Error device [%s] not exist \n\r",device.c_str());
        return -1;
    }

    if(!is_path_exist(dir)){
        fs::create_directories(dir);
    }

    sprintf(pcmd,"mount -o sync %s %s > /dev/null 2>&1",device.c_str(),dir.c_str());
    ret = system(pcmd);
   // fprintf(stderr,"%s.%d %d= mount dev(%s) dir(%s)\n\r",__func__,__LINE__,ret,device.c_str(),dir.c_str());
 //   fprintf(stderr,"%s.%d   %d = %s \n\r",__func__,__LINE__,ret,pcmd);

    free(pcmd);
    return ret;
}
int unmount(std::string dir){
    int l = 100 +  dir.length();
    char *pcmd = (char*)calloc(1,l);
    int ret=0;

    if(is_path_exist(dir)){
        sprintf(pcmd,"umount %s > /dev/null 2>&1",dir.c_str());
        int ret = system(pcmd);
       // fprintf(stderr,"%s.%d ret[%d] = [%s] \n\r",__func__,__LINE__,ret,pcmd);
        if(!is_mounted(dir)){
            fs::remove_all(dir);
        }
    }
    if(pcmd)
        free(pcmd);
    return ret;
}


int storage_get_info(std::string mount_point,uint64_t &disk_size,uint64_t &disk_use,uint64_t &disk_free  ){
    struct statfs s;

    
    if(statfs(mount_point.c_str(),&s) != 0){
        perror(mount_point.c_str());
        return -1;
    }

    if(s.f_blocks > 0){
        disk_size = (uint64_t)(s.f_blocks * s.f_bsize );
        disk_use  = (uint64_t)((s.f_blocks - s.f_bfree) * s.f_bsize );
        disk_free = (uint64_t)(s.f_bavail * s.f_bsize );
        return 0;
    }
  //  fprintf(stderr,"%s.%d error get info\n\r",__func__,__LINE__);
    return -1;
}

