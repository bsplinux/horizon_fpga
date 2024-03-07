#ifndef __UARTS_H__
#define __UARTS_H__
#include "ap_int.h"

#define NUM_REGS 128
#define MAX_UARTS 9
#define UART_BASE 0x42C00000

#define UART_REG_RXFIFO 0x0
#define UART_REG_TXFIFO 0x4
#define UART_REG_STAT   0x8
#define UART_REG_CTRL   0xC

#define UART_REG_CTRL_RST_FIFO 0x3

#define UART_REG_STAT_RX_VALID  0x1
#define UART_REG_STAT_RX_FULL   0x2
#define UART_REG_STAT_TX_EMPTY  0x4
#define UART_REG_STAT_TX_FULL   0x8
#define UART_REG_STAT_INTR_EN   0x10
#define UART_REG_STAT_OVRRN_ERR 0x20
#define UART_REG_STAT_FRAME_ERR 0x40
#define UART_REG_STAT_PRTY_ERR  0x80

#define REQUEST_FRAME_COMMAND 0xAA
// RX_SIZE including last byte CRC
#define RX_SIZE 9

enum uart_state {disable, idle, wt4tx, wt4rx, data_valid, done};

typedef struct {
	unsigned char num;
	unsigned int  adr;
	uart_state state;
	
} uart_info_t;

void uarts(
	volatile unsigned int * axi,
	//volatile unsigned int regs[NUM_REGS],
	ap_uint<MAX_UARTS> uart_en,
	unsigned long long uarts_d[MAX_UARTS]
);


#endif //__UARTS_H__
