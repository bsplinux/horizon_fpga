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

namespace fs = std::filesystem;

//static const int        PACKET_SIZE;    // packet size
static const int        PACKET_COUNT=10;   // fifo size 
static int              active_task =0;
static std::string         g_log_path;
static std::thread         g_log_hread_h;
//static char g_msg[PACKET_SIZE];
//static int  g_msg_size = sizeof(g_msg);
extern ServerStatus server_status;

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
    std::mutex mutex;

public:
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

void init_message()
{
	server_status.message.log.header.Log_ID             = 0x12345678;
	server_status.message.log.header.Log_Payload_Size   = TELEMETRY_BYTES - 1; //the -1 as we do not include the messaage id
	server_status.message.log.header.GMT_Time           = 0;
	server_status.message.log.header.Micro_Sec          = 0;
	server_status.message.log.footer_checksum           = 0;

	server_status.message.log.message_base.VDC_IN       = 0;
	server_status.message.log.message_base.VAC_IN_PH_A  = 1;
	server_status.message.log.message_base.VAC_IN_PH_B  = 2;
	server_status.message.log.message_base.VAC_IN_PH_C  = 3;
	server_status.message.log.message_base.I_DC_IN      = 4;
	server_status.message.log.message_base.I_AC_IN_PH_A = 5;
	server_status.message.log.message_base.I_AC_IN_PH_B = 6;
	server_status.message.log.message_base.I_AC_IN_PH_C = 7;
	server_status.message.log.message_base.V_OUT_1      = 8;
	server_status.message.log.message_base.V_OUT_2      = 9;
	server_status.message.log.message_base.V_OUT_3_ph1  = 10;
	server_status.message.log.message_base.V_OUT_3_ph2  = 11;
	server_status.message.log.message_base.V_OUT_3_ph3  = 12;
	server_status.message.log.message_base.V_OUT_4      = 13;
	server_status.message.log.message_base.V_OUT_5      = 14;
	server_status.message.log.message_base.V_OUT_6      = 15;
	server_status.message.log.message_base.V_OUT_7      = 16;
	server_status.message.log.message_base.V_OUT_8      = 17;
	server_status.message.log.message_base.V_OUT_9      = 18;
	server_status.message.log.message_base.V_OUT_10     = 19;
	server_status.message.log.message_base.I_OUT_1      = 20;
	server_status.message.log.message_base.I_OUT_2      = 21;
	server_status.message.log.message_base.I_OUT_3_ph1  = 22;
	server_status.message.log.message_base.I_OUT_3_ph2  = 23;
	server_status.message.log.message_base.I_OUT_3_ph3  = 24;
	server_status.message.log.message_base.I_OUT_4      = 25;
	server_status.message.log.message_base.I_OUT_5      = 26;
	server_status.message.log.message_base.I_OUT_6      = 27;
	server_status.message.log.message_base.I_OUT_7      = 28;
	server_status.message.log.message_base.I_OUT_8      = 29;
	server_status.message.log.message_base.I_OUT_9      = 30;
	server_status.message.log.message_base.I_OUT_10     = 31;
	server_status.message.log.message_base.AC_Power     = 32;
	server_status.message.log.message_base.Fan_Speed    = 33;
	server_status.message.log.message_base.Fan1_Speed   = 34;
	server_status.message.log.message_base.Fan2_Speed   = 35;
	server_status.message.log.message_base.Fan3_Speed   = 36;
	server_status.message.log.message_base.Volume_size  = 37;
	server_status.message.log.message_base.Logfile_size = 38;
	server_status.message.log.message_base.T1           = 39;
	server_status.message.log.message_base.T2           = 40;
	server_status.message.log.message_base.T3           = 41;
	server_status.message.log.message_base.T4           = 42;
	server_status.message.log.message_base.T5           = 43;
	server_status.message.log.message_base.T6           = 44;
	server_status.message.log.message_base.T7           = 45;
	server_status.message.log.message_base.T8           = 46;
	server_status.message.log.message_base.T9           = 47;
	server_status.message.log.message_base.ETM          = 0xffffff;
	server_status.message.log.message_base.Major        = 48;
	server_status.message.log.message_base.Minor        = 49;
	server_status.message.log.message_base.Build        = 50;
	server_status.message.log.message_base.Hotfix       = 51;
	server_status.message.log.message_base.SN           = 52;
    server_status.message.log.message_base.PSU_Status.word  = 0;
    server_status.message.log.message_base.Lamp_Ind     = 56;
    server_status.message.log.message_base.Spare0       = 57;
    server_status.message.log.message_base.Spare1       = 58;
    server_status.message.log.message_base.Spare2       = 59;
    server_status.message.log.message_base.Spare3       = 60;
    server_status.message.log.message_base.Spare4       = 61;
    server_status.message.log.message_base.Spare5       = 62;
    server_status.message.log.message_base.Spare6       = 63;
    server_status.message.log.message_base.Spare7       = 64;
    server_status.message.log.message_base.Spare8       = 65;
    server_status.message.log.message_base.Spare9       = 66;

    server_status.message.tele.tele.Message_ID          = MESSAGE_ID_CONST;
}

void format_message()
{
	// read status from HW and format correctly for LOG
	server_status.message.log.header.GMT_Time           ++;
	server_status.message.log.header.Micro_Sec          ++;

	server_status.message.log.message_base.VDC_IN       ++;
	server_status.message.log.message_base.VAC_IN_PH_A  ++;
	server_status.message.log.message_base.VAC_IN_PH_B  ++;
	server_status.message.log.message_base.VAC_IN_PH_C  ++;
	server_status.message.log.message_base.I_DC_IN      ++;
	server_status.message.log.message_base.I_AC_IN_PH_A ++;
	server_status.message.log.message_base.I_AC_IN_PH_B ++;
	server_status.message.log.message_base.I_AC_IN_PH_C ++;
	server_status.message.log.message_base.V_OUT_1      ++;
	server_status.message.log.message_base.V_OUT_2      ++;
	server_status.message.log.message_base.V_OUT_3_ph1  ++;
	server_status.message.log.message_base.V_OUT_3_ph2  ++;
	server_status.message.log.message_base.V_OUT_3_ph3  ++;
	server_status.message.log.message_base.V_OUT_4      ++;
	server_status.message.log.message_base.V_OUT_5      ++;
	server_status.message.log.message_base.V_OUT_6      ++;
	server_status.message.log.message_base.V_OUT_7      ++;
	server_status.message.log.message_base.V_OUT_8      ++;
	server_status.message.log.message_base.V_OUT_9      ++;
	server_status.message.log.message_base.V_OUT_10     ++;
	server_status.message.log.message_base.I_OUT_1      ++;
	server_status.message.log.message_base.I_OUT_2      ++;
	server_status.message.log.message_base.I_OUT_3_ph1  ++;
	server_status.message.log.message_base.I_OUT_3_ph2  ++;
	server_status.message.log.message_base.I_OUT_3_ph3  ++;
	server_status.message.log.message_base.I_OUT_4      ++;
	server_status.message.log.message_base.I_OUT_5      ++;
	server_status.message.log.message_base.I_OUT_6      ++;
	server_status.message.log.message_base.I_OUT_7      ++;
	server_status.message.log.message_base.I_OUT_8      ++;
	server_status.message.log.message_base.I_OUT_9      ++;
	server_status.message.log.message_base.I_OUT_10     ++;
	server_status.message.log.message_base.AC_Power     ++;
	server_status.message.log.message_base.Fan_Speed    ++;
	server_status.message.log.message_base.Fan1_Speed   ++;
	server_status.message.log.message_base.Fan2_Speed   ++;
	server_status.message.log.message_base.Fan3_Speed   ++;
	server_status.message.log.message_base.Volume_size  ++;
	server_status.message.log.message_base.Logfile_size ++;
	server_status.message.log.message_base.T1           ++;
	server_status.message.log.message_base.T2           ++;
	server_status.message.log.message_base.T3           ++;
	server_status.message.log.message_base.T4           ++;
	server_status.message.log.message_base.T5           ++;
	server_status.message.log.message_base.T6           ++;
	server_status.message.log.message_base.T7           ++;
	server_status.message.log.message_base.T8           ++;
	server_status.message.log.message_base.T9           ++;
	//server_status.message.log.message_base.ETM          = 0;
	server_status.message.log.message_base.Major        ++;
	server_status.message.log.message_base.Minor        ++;
	server_status.message.log.message_base.Build        ++;
	server_status.message.log.message_base.Hotfix       ++;
	server_status.message.log.message_base.SN           ++;
    //server_status.message.log.message_base.PSU_Status.word   = 0;
    server_status.message.log.message_base.Lamp_Ind     ++;

    // calculate checksum
	server_status.message.log.footer_checksum           ++;

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
	  
      std::thread t([newNumber, &server_status, log_path, gbuffer] {
	  using namespace std::chrono;		  
           int pkt_count = 0;
           int log_count = 0;
		   long long interval_micro = 1000; // 1 milliseconds
           int socket = Socket_UDPSocket();
           assert(socket >0);
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
                format_message();

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




