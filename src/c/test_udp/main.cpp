//#include <QCoreApplication>
#include <string.h>
#include <thread>
#include <assert.h>
#include "clilib.h"
#include "bigsocapi.h"
#include "commondef.h"

int retr=0;
int retw=0;
int size = 0x100000;
#if 0
 
int test_writer(int count){
    std::thread t([count] {
    unsigned char *p_data = (unsigned char*)calloc(1,size*2);
    bigsoc_open_params_t params={0};
    params.work_mode = bigsoc_type_writer;
    params.protocol  = BIGSOC_PROTOCOL_UDP;
    fprintf(stderr,"start writer: write %d packets\n\r",count);
    bigsoc_t * pbigsoc = bigsoc_open(params);

    for(int i=0;i<count;i++){
        retw= pbigsoc->write(pbigsoc,p_data,size,BIT(BIGSOC_HAS_START_HEADER)| BIT(BIGSOC_WAIT_FOR_CLIENT));
        fprintf(stderr,"packet(%d) tx(%d) \n\r",i,retw);
    }
    pbigsoc->close(pbigsoc);
    free(p_data);
    fprintf(stderr,"finish write all packets(%d)\n\r",count);
    });
    t.detach();
    //std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    return 0;
}

int test_reader(std::string szip,int count){
    std::thread t1([szip,count] {
      int src_ip,src_port;
      unsigned int flags;
      unsigned char *p_data = (unsigned char*)calloc(1,size*2);
      bigsoc_open_params_t params={0};
      params.work_mode = bigsoc_type_reader;
      params.dest_ip = szip;
      params.protocol = BIGSOC_PROTOCOL_UDP;
      fprintf(stderr,"start %d readers \n\r",count);
      bigsoc_t * pbigsoc = bigsoc_open(params);

      if(pbigsoc != NULL)
       for(int i=0;i<count;i++){
        // retr = pbigsoc->read(pbigsoc,p_data,size*2,BIT(BIGSOC_HAS_START_HEADER));
         fprintf(stderr,"reader pkt no(%d) rx(%d) \n\r",i,retr);
     }
     else {
           fprintf(stderr,"not writer exist\n\r");
      }
      free(p_data);
      if(pbigsoc)
        pbigsoc->close(pbigsoc);
      fprintf(stderr,"finish all %d readers \n\r",count);
      return 0;
    });
    t1.detach();
   return 0;
}
#endif
int cli_appversion(parse_t * pars_p, char *result){
    return 0;
}

int cli_udp_write(parse_t * pars_p, char *result){
    int mode = 0;
    static int port = 1234;
    int ret;
    int count=1;
    int size = 64;
    cget_integer(pars_p,count,&count);
    cget_integer(pars_p,size,&size);
    cget_integer(pars_p,port,&port);
    bigsoc_open_params_t params={0};
    params.work_mode = bigsoc_type_writer;
    params.port      = port;
    params.protocol  = BIGSOC_PROTOCOL_UDP;
    bigsoc_t * pbigsoc = bigsoc_open(params);

    std::thread t([pbigsoc,count,size] {
    unsigned char *p_data=0;
    p_data = (unsigned char *)malloc(size);
    for(int i=0;i<count;i++){
        retw= pbigsoc->write(pbigsoc,p_data,size,BIT(BIGSOC_HAS_START_HEADER)| BIT(BIGSOC_WAIT_FOR_CLIENT),0, 0);
        fprintf(stderr,"packet(%d) tx(%d) \n\r",i,retw);
     }
      bigsoc_t * ptmp = pbigsoc;
     if(pbigsoc)
        pbigsoc->close(ptmp);

    if(p_data)
        free(p_data);
    });
    t.detach();
    fprintf(stderr,"finish write all packets(%d)\n\r",count);
    return 0;
}

   

int cli_udp_read(parse_t * pars_p, char *result){
    static int port = 1234;
    int size=64;
    int count=1;
    
    static char g_szip[40]={"127.0.0.1"};
    cget_integer(pars_p,count,&count);
    cget_integer(pars_p,size,&size);
    cget_string(pars_p,g_szip,g_szip,sizeof(g_szip));
    cget_integer(pars_p,port,&port);
    bigsoc_open_params_t params={0};
    params.work_mode = bigsoc_type_reader;
    params.protocol  = BIGSOC_PROTOCOL_UDP;

    fprintf(stderr,"start %d readers \n\r",count);
    params.dest_ip   = g_szip;
    params.port      = port;
    bigsoc_t * pbigsoc = bigsoc_open(params);
    if(pbigsoc == NULL){
        fprintf(stderr,"not writer exist\n\r");
        return 0;
    }
    std::thread t([pbigsoc,count,size] {
    int src_ip,src_port;
    unsigned char *p_data = (unsigned char*)calloc(1,size*2);
    for(int i=0;i<count;i++){
       retr = pbigsoc->read(pbigsoc,p_data,size,src_ip,src_port,BIT(BIGSOC_WAIT_FOR_CLIENT));
       fprintf(stderr,"reader pkt no(%d) rx(%d) \n\r",i,retr);
    }
    bigsoc_t * ptmp = pbigsoc;
    if(pbigsoc)
      pbigsoc->close(ptmp);
    if(p_data)
        free(p_data);

    });
    t.detach();


    return 0;
}



void RegisterDebug(void){
    register_command ((char*)"version"       ,cli_appversion         ,(char*)"get test application version");
    register_command ((char*)"write"         ,cli_udp_write          ,(char*)"<count><size><port>");
    register_command ((char*)"read"          ,cli_udp_read           ,(char*)"<count><size><ip><port>");
}

int main(int argc, char *argv[])
{
   // QCoreApplication a(argc, argv);

   TesttoolInit();
   RegisterDebug();
   TesttoolRun();


    printf("test writ 2 packets, read 2 packets \n\r");
   
   

    while(1){
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    return 0;
}


#if 0
#define DEFAULT_PORT 7071;
int main(int argc, char *argv[])
{
   // QCoreApplication a(argc, argv);
    if (argc != 2)
    {
        printf("\nuse t for tx r of rx\n");
        return(0);
    }
    if (argv[1][0] == 't') {
        printf("\n writing.... \n");
        int size = 0x1000;
        unsigned char* p_data = (unsigned char*)calloc(1, size);

        bigsock_open_params_t params = { 0 };
        params.port = DEFAULT_PORT;
        params.dest_ip = "192.168.14.8";
        params.work_mode = bigsock_type_writer;
        bigsoc_t* pbigsoc = bigsoc_open(params);

        for (int i = 0; i < 300; i++) {
            printf("%d ", i);
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            retw = pbigsoc->write(pbigsoc, p_data, size, BIT(BIGSOCK_HAS_START_HEDER) | 0*BIT(BIGSOCK_WAIT_FOR_CLIENT));
         }
        retw = pbigsoc->write(pbigsoc, p_data, 4, BIT(BIGSOCK_HAS_START_HEDER) | 0*BIT(BIGSOCK_WAIT_FOR_CLIENT));


        pbigsoc->close(pbigsoc);
        fprintf(stderr, "tx(%d) \n\r", retw);
    }

    else {
        printf("\n reading.... \n");
        int cnt = 0;
        int size = 10*(1<<20);// upper limit 10Mb
        unsigned char* p_data = (unsigned char*)calloc(1, size);
        bigsock_open_params_t params = { 0 };
        params.port = DEFAULT_PORT;
        params.work_mode = bigsock_type_reader;
        params.dest_ip = "192.168.14.8";
        bigsoc_t* pbigsoc = bigsoc_open(params);
        if (!pbigsoc) {
            printf("No connection\n");
            free(p_data);
            return 0;
        }

        while (1) {
            char ss[100];
            sprintf(ss, "file %d.ply", cnt++);
            FILE* fp = fopen(ss,"wb");
            retr = pbigsoc->read(pbigsoc, p_data, size, BIT(BIGSOCK_HAS_START_HEDER));
            fprintf(stderr, "rx(%d) \n\r", retr);
            if (retr <= 4)
                break; // signal end of data
            fwrite(p_data, 1, retr, fp);
           

            fclose(fp);
        };
        pbigsoc->close(pbigsoc);
        free(p_data);
    }
   
   
 
  
  return 0;
 
}
#endif
/*
int main1(int argc, char* argv[])
{
    // QCoreApplication a(argc, argv);
    const int size = 0x100000;
    unsigned char* p_data = (unsigned char*)calloc(1, size);

    bigsock_open_params_t params = { 0 };
    params.dest_ip = "192.168.14.8";
    params.work_mode = bigsock_type_writer;
    bigsoc_t* pbigsoc = bigsoc_open(params);

    std::thread t1([] {

        unsigned char* p_data = (unsigned char*)calloc(1, size);
        bigsock_open_params_t params = { 0 };
        params.work_mode = bigsock_type_reader;
        params.dest_ip = "192.168.14.8";
        bigsoc_t* pbigsoc = bigsoc_open(params);
        retr = pbigsoc->read(pbigsoc, p_data, size, BIT(BIGSOCK_HAS_START_HEDER));
        pbigsoc->close(pbigsoc);
        return 0;
        });
    t1.detach();

    std::thread t2([] {

        unsigned char* p_data = (unsigned char*)calloc(1, size);
        bigsock_open_params_t params = { 0 };
        params.work_mode = bigsock_type_reader;
        params.dest_ip = "192.168.14.8";
        bigsoc_t* pbigsoc = bigsoc_open(params);

        retr = pbigsoc->read(pbigsoc, p_data, size, BIT(BIGSOCK_HAS_START_HEDER));
        pbigsoc->close(pbigsoc);
        return 0;
        });
    t2.detach();

    retw = pbigsoc->write(pbigsoc, p_data, size, BIT(BIGSOCK_HAS_START_HEDER) | BIT(BIGSOCK_WAIT_FOR_CLIENT));
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    fprintf(stderr, "tx(%d),rx(%d) \n\r", retw, retr);
    pbigsoc->close(pbigsoc);
    fprintf(stderr, "ptr(0x%x) tx(%d),rx(%d) \n\r", pbigsoc, retw, retr);
    return 0;
    //  return a.exec();
}
*/


