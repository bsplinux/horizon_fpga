/**
 * axidmak_of.c
 * parsing axi dma device tree 
 * This file contains functions for parsing the relevant device tree entries for
 * the DMA engines that are used.
 *
 **/

// Kernel Dependencies
#include <linux/of.h>               // Device tree parsing functions
#include <linux/of_address.h>       // Device tree parsing functions
#include <linux/of_irq.h>
#include <linux/platform_device.h>  // Platform device definitions

// Local Dependencies
#include "kdriver_of.h"             // Internal Definitions


/*----------------------------------------------------------------------------
 * Internal Helper Functions
 *----------------------------------------------------------------------------*/
 // get the dma direction axi-dma-mm2s-channel (write) axi-dma-s2mm-channel(read)
static int axidma_parse_compatible_property(struct device_node *dma_chan_node,of_chan_info_t *chan)
{
    struct device_node *np=0;
    int rc1=0,rc2=0;

    // Shorten the name for the dma_chan_node
    np = dma_chan_node;
	rc1 = of_device_is_compatible(np, "xlnx,axi-dma-mm2s-channel");
	rc2 = of_device_is_compatible(np, "xlnx,axi-dma-s2mm-channel");
//	printk("%s.%d rc1(%d) rc2(%d) channel_id(%d) \n",__func__,__LINE__,rc1,rc2,chan->channel_id);

	
    // Determine if the channel is DMA or VDMA, and if it is transmit or receive
    if (rc1 == 0) {
        chan->type = OF_AXIDMA_DMA;  
        chan->dir = OF_AXIDMA_READ; // mm2s
    } else if (rc2 == 0) {
        chan->type 	= OF_AXIDMA_DMA;  
        chan->dir 	= OF_AXIDMA_WRITE; //s2mm 
    }	

    return 0;
}
// get devicetree channel name
static int axidma_of_parse_dma_name(struct device_node *driver_node, int index,of_chan_info_t *chan)
{
    int rc;

    // Parse the index'th dma name from the 'dma-names' property
    rc = of_property_read_string_index(driver_node, "dma-names", index,&chan->name);
    if (rc < 0) {
        printk( "%s.%d ERROR Unable to read DMA name index(%d) from the 'dma-names' property.\n",__func__,__LINE__,index);
        return -EINVAL;
    }

    return 0;
}

// fill channel ID 
static int axidma_of_parse_channel(struct device_node *dma_node, int channel, of_chan_info_t *chan)
{
    int rc;
    struct device_node *dma_chan_node;
    u32 channel_id;
	int count;
	struct resource r;		

    // Verify that the DMA node has two channel (child) nodes, one for TX and RX
    count = of_get_child_count(dma_node);
	//printk("%s.%d channel(%d) nodes (%d).\n",__func__,__LINE__,channel,count);
    if (count < 1) {
        printk("%s.%d ERROR DMA does not have any channel nodes (%d).\n",__func__,__LINE__,count);
        return -EINVAL;
    } else if (of_get_child_count(dma_node) > 2) {
		printk("%s.%d ERROR DMA has more than two channel nodes(%d).\n",__func__,__LINE__,count);		
        return -EINVAL;
    }


	rc = of_address_to_resource(dma_node,0,&r);
	
    if(rc == 0){
		chan->phys_addr    = (void*)r.start;
    }	

    // Go to the child node that we're parsing
    dma_chan_node = of_get_next_child(dma_node, NULL);

    // Check if the specified node exists
    if (dma_chan_node == NULL) {
        printk( "%s.%d ERROR Unable to find child node number %d.\n",__func__,__LINE__, channel);
		return -EINVAL;
    }
	
	//printk("%s.%d channel(%d) (%s) (%s) addr(0x%llx)\n\r ",__func__,__LINE__,channel,dma_chan_node->name,dma_chan_node->full_name,r.start);		
#if 1	
    if ((channel &1) == 1) {
		struct device_node *dma_chan_node2;
        dma_chan_node2 = of_get_next_child(dma_node, dma_chan_node);
		if(dma_chan_node2 != NULL){
			//printk("%s.%d channel(%d) (%s) (%s)\n\r ",__func__,__LINE__,channel,dma_chan_node2->name,dma_chan_node2->full_name);				
			dma_chan_node = dma_chan_node2;
		}	
    }
#endif	

    // Read out the channel's unique device id, and put it in the structure
    if (of_find_property(dma_chan_node, "xlnx,device-id", NULL) == NULL) {
        printk( "ERROR: DMA channel is missing the 'xlnx,device-id' property.\n");
        return -EINVAL;
    }
    rc = of_property_read_u32(dma_chan_node, "xlnx,device-id", &channel_id);
    if (rc < 0) {
        printk("ERROR: Unable to read the 'xlnx,device-id' property.\n");
        return -EINVAL;
    }
    chan->channel_id = channel_id;

    // Use the compatible string to determine the channel's information
    rc = axidma_parse_compatible_property(dma_chan_node, chan);
    if (rc < 0) {
		printk("ERROR: axidma_parse_compatible_property id(%d)\n",channel_id);
        return rc;
    }
	//printk("************Exit Success id(%d)*****************\n",channel_id);
    return 0;
}

/*----------------------------------------------------------------------------
 * Public Interface
 *----------------------------------------------------------------------------*/
 
 
// get number of channels  
int of_num_channels(struct device_node *driver_node)
{
    int num_dmas=0, num_dma_names=0;

    // Check that the device tree node has the 'dmas' and 'dma-names' properties
#if 0
    if (of_find_property(driver_node, "dma-names", NULL) == NULL) {
        printk( "%s.%d Property 'dma-names' is missing.\n",__func__,__LINE__);
        return -EINVAL;
    } else if (of_find_property(driver_node, "dmas", NULL) == NULL) {
        printk( "%s.%d Property 'dmas' is missing.\n",__func__,__LINE__);
        return -EINVAL;
    }

    // Get the length of the properties, and make sure they are not empty
    num_dma_names = of_property_count_strings(driver_node, "dma-names");
    if (num_dma_names < 0) {
        printk("%s.%d Unable to get the 'dma-names' property length.\n",__func__,__LINE__);
        return -EINVAL;
    } else if (num_dma_names == 0) {
        printk("%s.%d dma-names property is empty.\n",__func__,__LINE__);
        return -EINVAL;
    }
	num_dmas = num_dma_names;
#endif	
#if 1	
    num_dmas = of_count_phandle_with_args(driver_node, "dmas", "#dma-cells");
    if (num_dmas < 0) {
        printk( "%s.%d ERROR Unable to get the 'dmas' property length.\n",__func__,__LINE__);
        return -EINVAL;
    } else if (num_dmas == 0) {
        printk( "%s.%d ERROR dmas' property is empty.\n",__func__,__LINE__);
        return -EINVAL;
    }
#endif
//	printk( "%s.%d num_dmas(%d)\n",__func__,__LINE__,num_dmas);

    return num_dmas;
}


// fill of_chan_info_t with device tree channel info 
int of_parse_dma_nodes(struct device_node *driver_node,int index, of_chan_info_t * axi_dma_ch )
{
  
    int channel;
	int rc =0;
    struct of_phandle_args phandle_args;
    struct device_node  *dma_node=NULL;

	
    // Initialize the channel type counts

    /* For each DMA channel specified in the deivce tree, parse out the
     * information about the channel, namely its direction and type. */
    
		
        // Get the phanlde to the DMA channel
        rc = of_parse_phandle_with_args(driver_node, "dmas", "#dma-cells", index,&phandle_args);
		//printk("%s.%d rc(%d) index(%d) \n\r ",__func__,__LINE__,rc,index);
        if (rc < 0) {
            printk("%s.%d ERROR Unable to get phandle %d from the 'dmas' property.\n",__func__,__LINE__, index);
            return rc;
        }
	//	printk("%s.%d rc(%d) \n\r ",__func__,__LINE__,rc);

        // Check that the phandle has the expected arguments
        dma_node = phandle_args.np;
        channel  = phandle_args.args[0];
		
		
	 //   printk("%s.%d channel(%d) (%s) (%s)  \n\r ",__func__,__LINE__,channel,dma_node->name,dma_node->full_name);		
        if (phandle_args.args_count < 1) {
            printk("%s.%d ERROR Phandle %d in the 'dmas' property is missing the channel direciton argument.\n",__func__,__LINE__, index);
            return -EINVAL;
        } else if (channel != 0 && channel != 1) {
            printk("%s.%d ERROR  Phandle %d in the 'dmas' property has an invalid channel (argument 0).\n",__func__,__LINE__, index);
            return -EINVAL;
        }
	
        // Parse out the information about the channel
        rc = axidma_of_parse_channel(dma_node, channel, axi_dma_ch);
        if (rc < 0) {
			printk("%s.%d ERROR axidma_of_parse_channel\n\r",__func__,__LINE__);
            return rc;
        }
	
        // Parse the name of the channel
#if 1        
        rc = axidma_of_parse_dma_name(driver_node, index,axi_dma_ch);
        if (rc < 0) {
			printk("%s.%d ERROR: axidma_of_parse_dma_name \n\r",__func__,__LINE__);			
            return rc;
        }
#endif		
		
	return rc;	
}




unsigned int of_parse_address(struct device_node *node,char *nodename,int index){
	struct device_node *np=0;
	struct resource r={0};	
    int rc;	
	
	np = of_find_compatible_node(NULL,NULL,nodename);	
	
	if(np){
		rc = of_address_to_resource(np,index,&r);
	//	printk("***********  %s.%d [%s]->addr(0x%x) index(%d)\n\r",__func__,__LINE__,nodename,r.start,index);
		if(rc == 0){
			return (unsigned int)r.start;
		}	
	}	
	return 0;	
}




// Assuming you have the 'node' and 'pdev->dev.of_node' already defined




int of_get_domain(struct device_node *node,char *nodename, unsigned int *paddr,unsigned int *psize){
		struct device_node *np;
		int rc; 
		int i=0;
		const __be32 *reg=0;
		struct resource r={0};	
		np = of_find_node_by_name(0, nodename);
		printk("%s.%d  np(0x%x) nodename(%s) n\r",__func__,__LINE__,np,nodename);
		if(np){
			reg = of_get_address(np, 0, NULL, NULL);
			printk("%s.%d name(%s) full(%s)\n\r",__func__,__LINE__,np->name,np->full_name);
		}	
	return 0;
}
	
int of_parse_interrupt_number(struct device_node *node,char *nodename,int index){
	struct device_node *np=0;
	int irq_num=0;
	struct resource r;	
    int rc;	
	
	np = of_find_compatible_node(NULL,NULL,nodename);	
	
	if(np){
		irq_num = irq_of_parse_and_map(np,index);
	}	
	
	//printk("***********  %s.%d [%s]->irq_num(%d)  \n\r",__func__,__LINE__,nodename,irq_num);
	return irq_num;
	
}
