#ifndef AXIDMAK_H
#define AXIDMAK_H
/*************************************************************************
axidmak.h
axidmak module is a Linux kernel module that uses Xilinx xilinx_dma.c driver
to do axis DMA between memory on the PL or on the PS the memory may hide from the PS
.e.g. that it can't access from the user PS application or the kernel only by the DMA
The limitation of the current Xilinx driver is that scatter/gather must be on the PS memory.
This means that the SG axis channel must be connect to the Zynqmp PS

Device Tree
To use the driver the device tree should be like this :

PL device tree created by the Petalinux  XXXX are lines that we remove to make it a short template  
-------------------------------------------------------------------------------------------------

/ {
	amba_pl: amba_pl@0 {
	XXXXX
	axi_dma_rx: dma@a0010000 {
		#dma-cells = <1>;
		XXXX
		dma-channel@a0010030 {
			compatible = "xlnx,axi-dma-s2mm-channel";
			XXXXX
		};
	};
	axi_dma_tx: dma@a0000000 {
	XXXXX
		dma-channel@a0000000 {
		compatible = "xlnx,axi-dma-mm2s-channel";
		XXXXX
		};
	};
	};
};
 
User device tree  
dmas = RX = 1 , TX = 0
----------------
/ {
	amba_pl@0 {
		nanrec_axidma: nanrec_axidma@0 {
		compatible = "xlnx,nanrec-axidma-1.0";
		dmas = <&axi_dma_rx 1 &axi_dma_tx 0>;  
		dma-names = "axidma_rx" , "axidma_tx";
		};
	};
};

axmdmak API :
AXIDMACMD_START_DMA : start DMA pass axidma_transfer_t that include physical buffer address and channel
                          (the driver knows the DMA direction from the device tree).
 
AXIDMACMD_CH_INFO : Get information on the channels.

**************************************************************************/




//driver name
#define AXIIMP_NAME "axiimp"
#define AXIIMP_VERSION 0x10002 


typedef struct {
	int wait_timeout_ms;
}wait_timer_t;





#define ZYNQCMD_WAIT_TIMER				_IOWR('I',3,wait_timer_t)	/* */
#define ZYNQCMD_ALERT_CANCEL			_IO('I',4)  				/* CANCLE ALERT WAIT  */




#pragma pack()


#endif
