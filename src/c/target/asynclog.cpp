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




#include  "socket.h"
#include  "asynclog.h"
#include  "utils.h"
#include  "servercmd.h"

#define MAX_ALLOW_FREE_SIZE_B 0x100000

namespace fs = std::filesystem;

//static const int        PACKET_SIZE;    // packet size
static const int        PACKET_COUNT=10;   // fifo size 
static int              active_task =0;
static std::string         g_log_path;
static std::thread         g_log_hread_h;
static uint64_t  		   g_disk_free_size=0;
//static char g_msg[PACKET_SIZE];
//static int  g_msg_size = sizeof(g_msg);



//extern ServerStatus server_status;

//static int file_buff_disk(int fd,unsigned char *buffer,int &buffer_offset,void *p_write,unsigned int i_write);

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
        fd = open(current_fn.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
#endif
        if(fd <0){
            printf("ERROR fail to open %s file (error=%d) \n\r",current_fn.c_str(),fd);
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
        fd = open(current_fn.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
        buffer = (unsigned char*)aligned_alloc(512, buffer_size);
#endif
        if(fd <0){
            printf("ERROR fail to open %s file (error=%d) \n\r",current_fn.c_str(),fd);
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
    oss << std::setw(5) << std::setfill('0') << number;
    return oss.str();
}

static std::string getCurrentTimeFormatted() {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);

    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d-%H-%M-%S");
    return ss.str();
}

static int getLastNumberFromFilename(const fs::path& path) {
    std::string filename = path.filename().string();
    // Assuming the filename is correctly formatted and the number is at the end
    std::string numberStr = filename.substr(filename.find_last_of('-') + 1);
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
			return a.filename().string() < b.filename().string();
		});

		// Check if there are any files in the directory

				// The last file in the sorted list
		 std::string lastFile = files.back().filename().string();
		 newNumber = getLastNumberFromFilename(lastFile) + 1;
		 std::cout << "The last file is: " << lastFile << std::endl;
	 } else {
			  std::cout << "No files found in the directory." << std::endl;
	 }

	 std::string new_file_name = getCurrentTimeFormatted() + "-" + formatNumber(newNumber);
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
		
	  
	        
      active_task = 1;

      gfifo   = new  FIFOBuffer(PACKET_COUNT);
      gbuffer = new BufferedFileWriter(new_log_file_name,save_block_size);
      reader_thread_h= std::thread([] { reader_thread(gbuffer,gfifo);});
	   
	  
      std::thread t([newNumber, &server_status, log_path, gbuffer,&files] {
	  using namespace std::chrono;		  
           int pkt_count = 0;
           int log_count = 0;
		   long long interval_micro = 1000; // 1 milliseconds
		   uint64_t disk_size  =0;
		   uint64_t disk_use   =0;
		   uint64_t disk_free  =0; 		   
           int socket = Socket_UDPSocket();
           assert(socket >0);
		   int ret = storage_get_info(log_path,disk_size,disk_use,disk_free);	
		   if(ret !=0){
				printf("%s.%d ERROR Fail To get disk size on mount %s\n\r",__func__,__LINE__,log_path.c_str());
		  }	
	
		   auto next_time = steady_clock::now() + microseconds(interval_micro);
		   
		   
            // Simulate packet data fill (for illustration, not actually filling data here)
            while(active_task){
                if (server_status.update_log_name) { // on first keep alive we need to update log file name
                	 std::string new_file_name = getCurrentTimeFormatted() + "-" + formatNumber(newNumber);
                	 std::cout << "The new filename will be: " << new_file_name << std::endl;
                	 std::string new_log_file_name = log_path + "/" + new_file_name;

                	// TODO rename the log file name
                	 gbuffer->update_file_name(new_log_file_name);
                	server_status.update_log_name = false;
                	//rename(new_log_file_name.c_str(),);
                }
				g_disk_free_size = disk_free - gbuffer->get_write_acc();
				if(g_disk_free_size < MAX_ALLOW_FREE_SIZE_B){
					std::thread deleteThread([&files] { deleteFile(files); });  // Same here, copy capture
					deleteThread.detach();  
				}
				
                format_message(server_status);

                Packet packet(&server_status.message,sizeof(message_superset_union_t)) ;
                log_count = (log_count + 1) % server_status.log_mseconds;
                if(gfifo && log_count == 0 && server_status.log_active){
                    gfifo->write(std::move(packet)); // Push pointer into the queue
					
					
                    //printf("%s.%d write paket\n\r",__func__,__LINE__);
                 }
                pkt_count = (pkt_count + 1) % 10;
                if(pkt_count==0 && server_status.host_ip != 0){
                	server_status.message.tele.tele.Message_ID = MESSAGE_ID_CONST;

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
					// worng time was spend
					printf("%s.%d worng time was spend\n\r",__func__,__LINE__);
				}

				// Schedule next execution
				next_time += microseconds(interval_micro);
            }
			if(socket)
				Socket_Close(socket);
            if(reader_thread_h.joinable())
                reader_thread_h.join();


            active_task =1;
            return 0;
        });
        t.detach();


   // sleep(100);
    //printf("%s.%d end func\n\r",__func__,__LINE__);

    return 0;
}

void end_async_log(void){
    if(active_task){
        active_task = 0;
        while(active_task)
         usleep(0);
    }
    printf("%s.%d exit\n\r",__func__,__LINE__);
}


std::string create_log_name(){
    return "/work/log";
}

void erase_log(){
#ifdef LINUX
    std::filesystem::remove_all(g_log_path);
#endif
}




