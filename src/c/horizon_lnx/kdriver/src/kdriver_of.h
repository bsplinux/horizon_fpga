#ifndef AXIDMA_OF
#define AXIDMA_OF
/**
 * axidmak_of.h
 * This file contains functions for parsing the relevant device tree entries for 
 * the DMA engines that are used. use linux driver "of" API 
 *
 **/

// Kernel Dependencies
#include <linux/of.h>               // Device tree parsing functions
#include <linux/platform_device.h>  // Platform device definitions

// Direction from the persepctive of the processor
enum {
    OF_AXIDMA_WRITE,                   // Transmits from memory to a device.
    OF_AXIDMA_READ                     // Transmits from a device to memory.
};

// AXI DMA Type
enum {
    OF_AXIDMA_DMA,                     // Standard AXI DMA engine
};

typedef struct {
		int 			dir;		// The DMA direction of the channel
		int 			type;		// The DMA type of the channel
		void*       	phys_addr;	// channel physical address	
		int 			channel_id; // The identifier for the device
		const char 		*name;		// Name of the channel 
		void 			*chan;      // The DMA channel (ignore)		
}of_chan_info_t;

// return the number of channels 
int of_num_channels(struct device_node *driver_node);
// parse by index channel and fill it with info
int of_parse_dma_nodes(struct device_node *driver_node,int index, of_chan_info_t * axi_dma_ch );
int of_parse_interrupt_number(struct device_node *driver_node,char *nodename,int index);
unsigned int of_parse_address(struct device_node *node,char *nodename,int index);
int of_get_domain(struct device_node *node ,char *nodename, unsigned int *paddr,unsigned int *psize);

#endif

                              
