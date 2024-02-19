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
namespace fs = std::filesystem;

#include  "socket.h"
#include  "asynclog.h"

static const int        PACKET_SIZE=200;    // packet size 
static const int        PACKET_COUNT=10;   // fifo size 
static int              active_task =0;
static std::string         g_log_path;
static std::thread         g_log_hread_h;
static char g_msg[PACKET_SIZE];
static int  g_msg_size = sizeof(g_msg);

//static int file_buff_disk(int fd,unsigned char *buffer,int &buffer_offset,void *p_write,unsigned int i_write);

struct Packet {
    unsigned char data [PACKET_SIZE];
    int           length  = PACKET_SIZE;
    Packet() {};
    Packet(void *msg,int l) {l = std::min(l,PACKET_SIZE); memcpy(data,msg,l); };
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
    FIFOBuffer(size_t capacity) : capacity(capacity), count(0), head(0), tail(0), buffer(capacity) {}

    void write(Packet&& packet) {
        printf("%s.%d pkt lenght(%d) \n\r",__func__,__LINE__,packet.length);
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
            printf("%s.%d pkt ms(%d) \n\r",__func__,__LINE__,timeout_ms);
            return std::nullopt; // Indicate that no packet was read due to timeout
        }
        //notEmpty.wait(lock, [this]{ return count > 0; });
        Packet packet = std::move(buffer[head]);
        head = (head + 1) % capacity;
        --count;
        notFull.notify_one();

        printf("%s.%d pkt cnt(%d) \n\r",__func__,__LINE__,count);
        return packet;
    }
};


class BufferedFileWriter {
private:
    int fd; // File descriptor
    unsigned char *buffer;
    int buffer_offset;
    int buffer_size;
public:
    BufferedFileWriter(int fd,int bsize) : fd(fd), buffer_offset(0),buffer_size(bsize) {
        // Initialize the buffer to zeros or leave it uninitialized based on your needs
        // std::fill_n(buffer, BUFFER_SIZE, 0);

#ifdef WIN32
        buffer = new unsigned char [buffer_size];
#else
        buffer = (unsigned char*)aligned_alloc(512, buffer_size);
#endif

    }

    ~BufferedFileWriter() {
        // Ensure any remaining data is flushed to disk when the object is destroyed
        flushBuffer();
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
        printf("%s.%d ws(%d) ofs(%d)\n\r",__func__,__LINE__,i_write,buffer_offset);
        if (buffer_offset > 0) {
            unsigned int cpy_size = std::min(buffer_size - buffer_offset, (int)i_write);
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

            if (ret != buffer_size) {
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
            int ret = write(fd, buffer, buffer_offset);
            if (ret != buffer_offset) {
                //std::cerr << "Error flushing buffer to disk" << std::endl;
printf("%s.%d Flush Fail DIFF(%d) req size(%d) ret(%d)\n\r",__func__,__LINE__,diff,buffer_offset,ret);
                return false;
            }
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



int rename_log(std::string newname) {
//    int ret=-1;
//    if(!global_log_name.empty()){
//      ret =  rename(global_log_name.c_str(),newname.c_str());
 //   }
  //  return ret;
    return 0;
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

int start_async_log(int save_block_size,std::string log_path,std::string dst_log_ip, ServerStatus &server_status ){
	fs::path directory ;
	std::vector<fs::path> files;
	int newNumber =1;
	int fd;
	static std::thread         reader_thread_h;
	g_log_path = log_path;
	directory = log_path;
	static BufferedFileWriter  *gbuffer=0;
	static FIFOBuffer          *gfifo  =0;


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

#ifdef WIN32

      fd = open(new_log_file_name.c_str(),O_CREAT | O_WRONLY,0640 );
#else

      fd = open(new_log_file_name.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
#endif
      if(fd <0){
          printf("ERROR fail to open %s file (error=%d) \n\r",new_log_file_name.c_str(),fd);
          return -1;
      }

      active_task = 1;

      gfifo   = new  FIFOBuffer(PACKET_COUNT);
      gbuffer = new BufferedFileWriter(fd,save_block_size);
      reader_thread_h= std::thread([] { reader_thread(gbuffer,gfifo);});
      std::thread t([dst_log_ip, server_status] {
           int pkt_count = 0;
           int log_count = 0;
           unsigned int i_dst_ip = Socket_Str2Addr((char*)dst_log_ip.c_str());
           int socket = Socket_UDPSocket();
           assert(socket >0);
            // Simulate packet data fill (for illustration, not actually filling data here)
            while(active_task){
                Packet packet(g_msg,g_msg_size) ;
                log_count = (log_count + 1) % server_status.log_mseconds;
                if(gfifo && log_count == 0){
                    gfifo->write(std::move(packet)); // Push pointer into the queue
                    printf("%s.%d write paket\n\r",__func__,__LINE__);
                 }
                pkt_count = (pkt_count + 1) % 10;
                if(pkt_count==0){
					Socket_SendTo(socket,(unsigned char*)packet.data,packet.length,i_dst_ip, server_status.log_udp_port);
                }
                usleep(1000);
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
    return "/log";
}

void erase_log(){
#ifdef LINUX
    std::filesystem::remove_all(g_log_path);
#endif
}

