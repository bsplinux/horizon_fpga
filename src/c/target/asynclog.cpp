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
#include  "asynclog.h"

// Mati
#include <cstring>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <filesystem>

// end Mati

static const int        PACKET_SIZE=90;    // packet size 
static const int        PACKET_COUNT=10;   // fifo size 
static int              active_task =0;
std::thread             reader_thread_h;

//static int file_buff_disk(int fd,unsigned char *buffer,int &buffer_offset,void *p_write,unsigned int i_write);

#include <iostream>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <thread>
#include <vector>


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
            return std::nullopt; // Indicate that no packet was read due to timeout
        }

        notEmpty.wait(lock, [this]{ return count > 0; });
        Packet packet = std::move(buffer[head]);
        head = (head + 1) % capacity;
        --count;
        notFull.notify_one();
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
    }

    // Write data to the buffer, flushing to disk as needed
    int writeData(void *p_write, unsigned int i_write) {
        unsigned char *p_wbuff = (unsigned char *)p_write;
        int ret = 0;

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
            int ret = write(fd, buffer, buffer_offset);
            if (ret != buffer_offset) {
                std::cerr << "Error flushing buffer to disk" << std::endl;
                return false;
            }
            buffer_offset = 0; // Reset buffer offset
        }
        return true;
    }
};


static FIFOBuffer          *gfifo=0;
static BufferedFileWriter *gbuffer=0;

static void reader_thread(int fd,FIFOBuffer * buffer) {
    int ret=0;
    while(active_task){
        auto packetOpt = buffer->read(100); // Wait for 100 milliseconds
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
    printf("%s.%d exit log\n\r",__func__,__LINE__);
}

std::string global_log_name;

int rename_log(std::string newname) {
    int ret=-1;
    if(!global_log_name.empty()){
      ret =  rename(global_log_name.c_str(),newname.c_str());
    }   
    return ret;
}

int fd = -1;
int start_async_log(int save_block_size,std::string log_name){
    global_log_name = log_name;
    if(gbuffer ==0){
#ifdef WIN32
        int fd = open(log_name.c_str(),O_CREAT | O_WRONLY,0640 );
#else
        struct stat st = {0};
        if (stat("/log", &st) == -1) {
            mkdir("/log", 0777);
        }
        //int fd = open(log_name.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY,0640 );
        std::string full_name("/log/");
        full_name += log_name;
        fd = open(full_name.c_str(),O_SYNC | O_DIRECT | O_CREAT | O_WRONLY ,0666 );
#endif
        if(fd <0){
            printf("ERROR fail to open %s file (error=%d) \n\r",log_name.c_str(),fd);
            return -1;
        }
        // move file pointer to end of file
        int seek = lseek(fd, 0, SEEK_END);
        if (seek == -1){
        	printf("could not jump to end of file\n\r");
        	return -1;
        }
        else
        {
        	printf("Jumping %d bytes to end of file\n\r", seek);
        }

        active_task = 1;

        gfifo   = new  FIFOBuffer(PACKET_COUNT);
        gbuffer = new BufferedFileWriter(fd,save_block_size);
        reader_thread_h= std::thread([fd] { reader_thread(fd,gfifo);});

    }
    return 0;
}

void end_async_log(){
    close(fd);
	active_task = 0;
    if(reader_thread_h.joinable())
        reader_thread_h.join();
}

int print_log(void *msg,int msg_size){
    Packet packet(msg,msg_size) ;
    // Simulate packet data fill (for illustration, not actually filling data here)
    if(gfifo)
        gfifo->write(std::move(packet)); // Push pointer into the queue
    return 0;
}

std::string create_log_name(){
    return "log.txt";
}

void erase_log(){
	std::filesystem::remove_all("/log");
}

