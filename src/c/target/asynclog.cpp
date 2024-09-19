#include <stdio.h>
#include <assert.h>
#include <vector>
#include <fcntl.h> // For file control options
#include <iostream>
#include <algorithm> // Include for std::min
#include <optional>
#include <cctype>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <chrono>
#include <string>
#include <cstring>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <filesystem>
#include <atomic>
#include <cstdio> // Include C standard IO
#include <sys/time.h>
#include <ctime>

#include  "socket.h"
#include  "asynclog.h"
#include  "utils.h"
#include  "servercmd.h"
#include  "regs_pkg.h"

#define MAX_ALLOW_FREE_SIZE_B 0x100000
#define MOUNT_POINT "/mnt/mmc"

namespace fs = std::filesystem;

unsigned int get_sysmon_sample();

//static const int        PACKET_SIZE;    // packet size
static const int        PACKET_COUNT=10;   // fifo size 
static int              running_task =0;
static int              active_task =0;
static std::string         g_log_path;
static std::thread         g_log_hread_h;
static uint64_t  		   g_disk_free_size=0;
//static char g_msg[PACKET_SIZE];
//static int  g_msg_size = sizeof(g_msg);
extern registers_t* const registers;

//extern ServerStatus server_status;

//static int file_buff_disk(int fd,unsigned char *buffer,int &buffer_offset,void *p_write,unsigned int i_write);

static const char record_id_const[6] = "LFCFG"; // this is taken from IRS

void make_header(log_file_header_union_t * h)
{
	unsigned char checksum = 0;
    struct timeval tv;
    gettimeofday(&tv, NULL);// Get the current time

	memcpy(h->h.m_recordId,record_id_const,5);
	h->h.m_recordSize = 15;
	h->h.m_gmtTime = tv.tv_sec;
	h->h.m_microSec = (unsigned short)((double)tv.tv_usec * 1E-6 * 0xFFFF); // this is the format asked by client (email from Efrat Rot 21-2-24)
	h->h.m_endian = ENDIAN_CONST;
	h->h.m_bitConfig.flag = 1;
	h->h.m_bitConfig.reserved = 0;
	h->h.m_version1 = VERSION1_CONST;
	h->h.m_version2 = VERSION2_CONST;
	h->h.m_lenSize = 2;
    for(unsigned int i = 0 ; i < sizeof(log_file_header_t) - 1; i++) // -1 to exclude the checksum itself
    	checksum += h->d[i];
    h->h.m_cs = checksum;
}

struct Packet {
    unsigned char data [sizeof(message_superset_union_t)];
    int           length  = sizeof(message_superset_union_t);
    Packet() {};
    Packet(void *msg,int l) { memcpy(data,msg,l); };
};

class FIFOBuffer {
    std::vector<Packet> buffer;
    size_t capacity;
    size_t count;
    size_t head;
    size_t tail;
    std::mutex mutex;
    std::condition_variable notEmpty;
    std::condition_variable notFull;

public:
    FIFOBuffer(size_t capacity) :  buffer(capacity), capacity(capacity), count(0), head(0), tail(0) {}

    void write(Packet&& packet) {
        //printf("%s.%d pkt lenght(%d) \n\r",__func__,__LINE__,packet.length);
        std::unique_lock<std::mutex> lock(mutex);

        notFull.wait(lock, [this]{ return count < capacity; });
        buffer[tail] = std::move(packet);
        tail = (tail + 1) % capacity;
        ++count;

        notEmpty.notify_one();
    }

    std::optional<Packet> read(int timeout_ms) {

        std::unique_lock<std::mutex> lock(mutex);

        if (!notEmpty.wait_for(lock, std::chrono::milliseconds(timeout_ms), [this] { return count > 0; })) {
                  // Timeout
            //printf("%s.%d pkt ms(%d) \n\r",__func__,__LINE__,timeout_ms);
            return std::nullopt; // Indicate that no packet was read due to timeout
        }
        //notEmpty.wait(lock, [this]{ return count > 0; });
        Packet packet = std::move(buffer[head]);
        head = (head + 1) % capacity;
        --count;
        notFull.notify_one();

        //printf("%s.%d pkt cnt(%d) \n\r",__func__,__LINE__,count);
        return packet;
    }
};


class BufferedFileWriter {
private:
    int fd=0; // File descriptor
    std::string current_fn;
    unsigned char *buffer;
    unsigned int buffer_offset;
    unsigned int buffer_size;
	uint64_t write_acc=0;  
    std::mutex mutex;

public:
	uint64_t get_write_acc() {return write_acc;}
    int file_open_status() {return fd ;}
    int update_file_name(std::string update_fn){
    	//int ret =0;
    	 std::unique_lock<std::mutex> lock(mutex);
    	 close(fd);
    	 rename(current_fn.c_str(),update_fn.c_str());
    	 current_fn = update_fn;

#ifdef WIN32
        fd = open(current_fn.c_str(),O_CREAT | O_WRONLY,0640 );
#else
//        fd = open(current_fn.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
        fd = open(current_fn.c_str(),O_CREAT | O_WRONLY ,0666 );
#endif
        if(fd <0){
            printf("%s.%d ERROR fail to open %s file (error=%d) \n\r",__func__,__LINE__,current_fn.c_str(),fd);
           // return -1;
        }
		
		
		
        if(fd >0)
        	return 0;
        return -1;

    }
    BufferedFileWriter(std::string filename,int bsize) : current_fn(filename), buffer_offset(0),buffer_size(bsize) {
        // Initialize the buffer to zeros or leave it uninitialized based on your needs
        // std::fill_n(buffer, BUFFER_SIZE, 0);
    	 std::unique_lock<std::mutex> lock(mutex);
#ifdef WIN32
        fd = open(current_fn.c_str(),O_CREAT | O_WRONLY,0640 );
        buffer = new unsigned char [buffer_size];
#else
        //fd = open(current_fn.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
        fd = open(current_fn.c_str(), O_CREAT | O_WRONLY ,0666 );
        buffer = (unsigned char*)aligned_alloc(512, buffer_size);
#endif
        if(fd <0){
            printf("%s.%d ERROR fail to open %s file (error=%d) \n\r",__func__,__LINE__,current_fn.c_str(),fd);
           // return -1;
        }
		
		write_acc =0;

    }

    ~BufferedFileWriter() {
        // Ensure any remaining data is flushed to disk when the object is destroyed
        flushBuffer();
        std::unique_lock<std::mutex> lock(mutex);
		if(fd >0){
			close(fd);
			//printf("%s.%d close fd(%d) \n\r",__func__,__LINE__,fd);
			system("sync");
		}
    }

    // Write data to the buffer, flushing to disk as needed
    int writeData(void *p_write, unsigned int i_write) {
        unsigned char *p_wbuff = (unsigned char *)p_write;
        int ret = 0;
        //printf("%s.%d ws(%d) ofs(%d)\n\r",__func__,__LINE__,i_write,buffer_offset);
        if (buffer_offset > 0) {
            unsigned int cpy_size = std::min(buffer_size - buffer_offset, i_write);
            assert(cpy_size != 0);
            memcpy(&buffer[buffer_offset], (void*)p_wbuff, cpy_size);
            p_wbuff += cpy_size;
            i_write -= cpy_size;
            buffer_offset += cpy_size;
            if (buffer_offset == buffer_size) {
                if (!flushBuffer()) {
                    return -1; // Error flushing buffer
                }
            }
        }

        while (i_write >= buffer_size) {
            ret = write(fd, (unsigned char *)p_wbuff, buffer_size);

            if (ret != (int)buffer_size) {
                return -1; // Error writing to disk
            }
            p_wbuff += buffer_size;
            i_write -= buffer_size;

        }

        if (i_write > 0) {
            assert(buffer_offset == 0); // Should be empty at this point
            memcpy(buffer, (void*)p_wbuff, i_write);
            buffer_offset = i_write;
        }

        return 0;
    }

    // Flush the buffer to disk
    bool flushBuffer() {
        if (buffer_offset > 0) {
			int diff = buffer_size - buffer_offset;
			if(diff){
			//#IN_CASE_THERE_IS_ALLIMENT_ERROR
			//memset((VOID*)&buffer[buffer_size-diff],0,diff);
			//buffer_offset = buffer_size;
			//#endif
		}

		std::unique_lock<std::mutex> lock(mutex);

            int ret = write(fd, buffer, buffer_offset);
			
            if (ret != buffer_offset) {
                //std::cerr << "Error flushing buffer to disk" << std::endl;
printf("%s.%d Flush Fail DIFF(%d) req size(%d) ret(%d)\n\r",__func__,__LINE__,diff,buffer_offset,ret);
                return false;
            }
			write_acc += buffer_offset;
            buffer_offset = 0; // Reset buffer offset
			
        }
        return true;
    }
};


static void reader_thread(BufferedFileWriter * &gbuffer,FIFOBuffer *& gfifo) {
    int ret=0;
    while(active_task){
        auto packetOpt = gfifo->read(100); // Wait for 100 milliseconds
        if (packetOpt) {
            // Successfully read a packet
            // Process the packet...
              if(gbuffer)
                gbuffer->writeData(packetOpt->data,packetOpt->length);
        } else {
            // Timeout occurred, no packet was read

        }

    }

    delete gbuffer;
    gbuffer =0;
    delete gfifo;
    gfifo =0;

//    printf("%s.%d exit log\n\r",__func__,__LINE__);
}

static std::string formatNumber(int number) {
    std::ostringstream oss;
    oss << std::setw(4) << std::setfill('0') << number;
    return oss.str();
}

static std::string getCurrentTimeFormatted() {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);

    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y_%m_%d_%H_%M_%S");
    return ss.str();
}

static int getLastNumberFromFilename(const fs::path& path) {
    std::string filename = path.filename().string();
    // Assuming the filename is correctly formatted and the number is at the end
    //std::string numberStr = filename.substr(filename.find_last_of('_') + 1);
    std::string numberStr = filename.substr(0,4);
    //std::cout << "The filename is: " << filename << " the no. is: " << numberStr << std::endl;
    return std::stoi(numberStr);
}


static void deleteFile(std::vector<fs::path> &files) {
	if (!files.empty()) {
        fs::path fileToDelete = files.front(); // Get the first file

		if (fs::exists(fileToDelete)) { // Ensure the file exists
			fs::remove(fileToDelete);  // Delete the file
			std::cout << "File deleted: " << fileToDelete << std::endl;
		} else {
			std::cout << "File does not exist: " << fileToDelete << std::endl;
		}
        // Now remove the path from the vector
        files.erase(files.begin()); // Erase the first element
    } else {
        std::cout << "No files to delete." << std::endl;
    }
	
}



int start_async_log(int save_block_size,std::string log_path, ServerStatus &server_status ){
	fs::path directory ;
	std::vector<fs::path> files;
	int newNumber =1;
	static std::thread         reader_thread_h;
	g_log_path = log_path;
	directory = log_path;
	static BufferedFileWriter  *gbuffer=0;
	static FIFOBuffer          *gfifo  =0;
	int ret;
	log_file_header_union_t file_header;

    init_message(server_status);

	// Check if directory exists and is a directory
	if (fs::exists(directory) && fs::is_directory(directory)) {
		// Load files into the vector
		for (const auto& entry : fs::directory_iterator(directory)) {
			if (entry.is_regular_file()) {
				files.push_back(entry.path().filename());
			}
		}
	}
	if (!files.empty()) {
		// Sort files by their names
		std::sort(files.begin(), files.end(), [](const fs::path& a, const fs::path& b) {
			// Assuming filenames are in a format that allows alphabetical sorting
			return a.filename().string().substr(1,4) < b.filename().string().substr(1,4);
		});

		// Check if there are any files in the directory

				// The last file in the sorted list
		 std::string lastFile = files.back().filename().string();
		 newNumber = getLastNumberFromFilename(lastFile) + 1;
		 std::cout << "The last file is: " << lastFile << std::endl;
	 } else {
			  std::cout << "No files found in the directory." << std::endl;
	 }

	 std::string new_file_name = formatNumber(newNumber) + "_" + getCurrentTimeFormatted() + "_PSU.log";
	 std::cout << "The new filename will be: " << new_file_name << std::endl;
	 std::string new_log_file_name = log_path + "/" + new_file_name;
	
	 // Create a directory
	 try {
		  if (fs::create_directory(log_path)) {
			  std::cout << "Directory created: " << log_path << std::endl;
		  } else {
			  std::cout << "Directory already exists or failed to create: " << log_path << std::endl;
		  }
	  } catch (const fs::filesystem_error& e) {
		  std::cerr << "Error: " << e.what() << std::endl;
	  }

	  registers->CPU_STATUS.fields.Is_Logfile_Running = 1;
	  active_task = 1;
      gfifo   = new  FIFOBuffer(PACKET_COUNT);
      gbuffer = new BufferedFileWriter(new_log_file_name,save_block_size);
      // insert file header to file
      make_header(&file_header);
      gbuffer->writeData(&file_header, sizeof(log_file_header_union_t));
      reader_thread_h= std::thread([] { reader_thread(gbuffer,gfifo);});
	   
	  
      std::thread t([newNumber, &server_status, log_path, gbuffer,&files] {
	  using namespace std::chrono;		  
		   unsigned int rt_cnt = 0;
	  	   bool unmount_flag = false;
           int pkt_count = 0;
           int log_count = 0;
		   long long interval_micro = 1000; // 1 milliseconds
		   uint64_t disk_size  =0;
		   uint64_t disk_use   =0;
		   uint64_t disk_free  =0; 		   
		   log_file_header_union_t file_header;
           int socket = Socket_UDPSocket();
           running_task = 1;
           assert(socket >0);
		   int ret = storage_get_info(log_path,disk_size,disk_use,disk_free);	
		   if(ret !=0){
				printf("%s.%d ERROR Fail To get disk size on mount %s\n\r",__func__,__LINE__,log_path.c_str());
		  }	
	
		   auto next_time = steady_clock::now() + microseconds(interval_micro);
		   
		   
            // Simulate packet data fill (for illustration, not actually filling data here)
            while(active_task){
                bool send_to_host = false;

                pkt_count = (pkt_count + 1) % 10;
                if(pkt_count==0 && server_status.host_ip != 0)
                	send_to_host = true;

            	// as per spec 2.2.1.6 check 12v before new log
            	if (get_sysmon_sample() < 1700)
            	{
            		unmount_flag = true;
            		// if less then 10v (1700 dec) we stop everything
            		break;
            	}

            	if (server_status.update_log_name) { // on first keep alive we need to update log file name
            		std::string new_file_name = formatNumber(newNumber) + "_" + getCurrentTimeFormatted() + "_PSU.log";
                	std::cout << "The new filename will be: " << new_file_name << std::endl;
                	std::string new_log_file_name = log_path + "/" + new_file_name;

                	// TODO rename the log file name
                	gbuffer->update_file_name(new_log_file_name);
                    // insert file header to file
                    make_header(&file_header);
                    gbuffer->writeData(&file_header, sizeof(log_file_header_union_t));
                	server_status.update_log_name = false;
                }
				g_disk_free_size = disk_free - gbuffer->get_write_acc();
				if(g_disk_free_size < MAX_ALLOW_FREE_SIZE_B && server_status.log_active){
					std::thread deleteThread([&files] { deleteFile(files); });  // Same here, copy capture
					deleteThread.detach();  
				}
				
				storage_get_info(log_path,disk_size,disk_use,disk_free);
                if(send_to_host) // must check before formating message because we need to know if reading psu_status also flushes it
                	registers->PSU_CONTROL.fields.release_psu = 1; // no need to set 0 its a write only
                format_message(server_status,disk_size,disk_use);

                Packet packet(&server_status.message,sizeof(message_superset_union_t)) ;
                log_count = (log_count + 1) % server_status.log_mseconds;
                if(gfifo && log_count == 0 && server_status.log_active){
                    gfifo->write(std::move(packet)); // Push pointer into the queue
				    //printf("%s.%d write paket\n\r",__func__,__LINE__);
                }
                if(send_to_host)
                {
                	server_status.message.tele.tele.Message_ID = MESSAGE_ID_CONST; // this byte is shared by log as last byte of header or by telemetry by message id so need to override

                	registers->PSU_CONTROL.fields.release_psu = 1; // no need to set 0 its a write only
                	int ret = Socket_SendTo(socket,&server_status.message.tele.tele.Message_ID,sizeof(cmd81_telemetry_t), server_status.host_ip, server_status.log_udp_port);
                	//printf("%s.%d %d log  IP(0x%x) port(%d) \n\r",__func__,__LINE__,ret,server_status.host_ip,server_status.log_udp_port);
                }
                //next_time_micro = next_time_micro +1000;

//                usleep(1000);
			    auto now = steady_clock::now();
				auto time2sleep = duration_cast<microseconds>(next_time - now);
				if (time2sleep > microseconds(0)) {
					std::this_thread::sleep_for(time2sleep);
				}
				else {
					// missed 1m real time
					rt_cnt++;
					if(rt_cnt % 1000 == 1)
						printf("%s.%d missed real time of 1MS per iteration; cnt=%d\n\r",__func__,__LINE__,rt_cnt);
				}

				// Schedule next execution
				next_time += microseconds(interval_micro);
            }
            active_task = 0;
			if(socket)
				Socket_Close(socket);
            if(reader_thread_h.joinable())
                reader_thread_h.join();


            running_task = 0;

            if (unmount_flag && is_mounted(MOUNT_POINT))
        	{
        		if (unmount(MOUNT_POINT) == 0)
        			printf("%s.%d Unmounted eMMC Successfully\n\r",__func__,__LINE__);
        		else
        			printf("%s.%d ERROR: faild to unmount\n\r",__func__,__LINE__);
        	}
            return 0;
        });
        t.detach();


   // sleep(100);
    //printf("%s.%d end func\n\r",__func__,__LINE__);

    return 0;
}

void end_async_log(){
    if(active_task){
        active_task = 0;
        while(running_task)
         usleep(0);
    }
    printf("%s.%d exit\n\r",__func__,__LINE__);
}


std::string create_log_dir(){
    return std::string(MOUNT_POINT) + std::string("/log");
}

void erase_log(){
#ifdef LINUX
    std::filesystem::remove_all(g_log_path);
#endif
}




