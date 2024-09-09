#ifndef __SPIS_H__
#define __SPIS_H__
#include "ap_int.h"

//#define NUM_REGS 128
#define MAX_SPIS 3
#define MAX_CHANS 8
#define SPI_BASE 0x41E00000

#define SPI_REG_RXFIFO 0x6C
#define SPI_REG_TXFIFO 0x68
#define SPI_REG_STAT   0x64
#define SPI_REG_CTRL   0x60
#define SPI_REG_SSEL   0x70
#define SPI_REG_RST    0x40

#define RST_VAL        0xA
#define START_SPI      0x6
#define HALT_SPI       0x4
#define STAT_RX_EMPTY_MASK 0x1
#define STAT_TX_EMPTY_MASK 0x4

//#define MAX_UARTS 9
//#define UART_BASE 0x42C00000
//
//#define UART_REG_RXFIFO 0x0
//#define UART_REG_TXFIFO 0x4
//#define UART_REG_STAT   0x8
//#define UART_REG_CTRL   0xC
//
//#define UART_REG_CTRL_RST_FIFO 0x3
//
//#define UART_REG_STAT_RX_VALID  0x1
//#define UART_REG_STAT_RX_FULL   0x2
//#define UART_REG_STAT_TX_EMPTY  0x4
//#define UART_REG_STAT_TX_FULL   0x8
//#define UART_REG_STAT_INTR_EN   0x10
//#define UART_REG_STAT_OVRRN_ERR 0x20
//#define UART_REG_STAT_FRAME_ERR 0x40
//#define UART_REG_STAT_PRTY_ERR  0x80
//
//#define REQUEST_FRAME_COMMAND 0xAA
//// RX_SIZE including last byte CRC

enum uart_state {disable, init, wr_fifo, tx, rd_fifo, done};

typedef struct {
	unsigned char num;
	unsigned int  adr;
	uart_state state;
} spi_info_t;

void spis(
	volatile unsigned int * axi,
	ap_uint<MAX_CHANS> spi_en[MAX_SPIS],
	ap_uint<12> spis_d[MAX_SPIS*MAX_CHANS]
);


#endif //__SPIS_H__
