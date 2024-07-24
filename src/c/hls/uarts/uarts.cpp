#include "uarts.h"

void uart_fifo_rst(
	volatile unsigned int * axi,
	uart_info_t info
	)
{
	unsigned int a = info.adr + UART_REG_CTRL;
	axi[a/sizeof(int)] = UART_REG_CTRL_RST_FIFO;
}

unsigned char uart_stat (
	volatile unsigned int * axi,
	uart_info_t info
	)
{
	unsigned char stat = 0;
	unsigned int a = info.adr + UART_REG_STAT;
	stat = axi[a/sizeof(int)] & 0x000000FF;
	return stat;
}

void uart_write(
	volatile unsigned int * axi,
	uart_info_t info,
	unsigned char d
	)
{
	unsigned int a = info.adr + UART_REG_TXFIFO;
	axi[a/sizeof(int)] = d;
}

unsigned char uart_read(
	volatile unsigned int * axi,
	uart_info_t info
	)
{
	unsigned int a = info.adr + UART_REG_RXFIFO;
	return axi[a/sizeof(int)];
}

// each call to this function will read all enabled uarts once, and exit when done.
// can't change the enabled uarts, it's a one time selection
// you should call this function once evey milisecond
void uarts(
	volatile unsigned int * axi,
	//volatile unsigned int regs[NUM_REGS],
	ap_uint<MAX_UARTS> uart_en,
	ap_uint<64> uarts_d[MAX_UARTS],
	volatile ap_uint<MAX_UARTS> *uart_de
)
{
	uart_info_t uarts_info[MAX_UARTS];
	ap_uint<MAX_UARTS> uarts_busy = 0xFFFFFFFF;
	unsigned char stat;
	unsigned char rx_d[MAX_UARTS][RX_SIZE];
	ap_uint<MAX_UARTS> de_int = {0};

	init_loop: for(int i = 0; i < MAX_UARTS; i++)
	{
		uarts_info[i].rx_cnt = 0;
		uarts_info[i].num = i;
		uarts_info[i].adr = UART_BASE + i * 0x10000;
		if (uart_en[i] == 0)
			uarts_info[i].state = disable;
		else
			uarts_info[i].state = idle;
	}

	main_loop: for(;;)
	{
		uarts_loop: for(int i = 0; i < MAX_UARTS; i++)
		{
			if (uarts_info[i].state == disable)
				uarts_busy[i] = 0;
			if(uarts_busy[i] == 0)  // will happen if this uart is done but others are still waiting or in disable state
				continue;

			switch (uarts_info[i].state) {
			case idle: // send word to uart asking for data
				uart_fifo_rst(axi, uarts_info[i]);
				de_int[i] = 1;
				*uart_de = de_int;
				uart_write(axi, uarts_info[i], REQUEST_FRAME_COMMAND);
				uarts_info[i].state = wt4tx;
				break;
			case wt4tx:	// wait until data was full sent to target
				stat = uart_stat(axi, uarts_info[i]);
				if (stat & UART_REG_STAT_TX_EMPTY) // waiting for fifo to be empty telling us data was sent to UART
				{
					uarts_info[i].state = wt4rx;
					de_int[i] = 0;
					*uart_de = de_int;
				}
				break;
			case wt4rx: // wait until all data was received
				stat = uart_stat(axi, uarts_info[i]);
				if (stat & UART_REG_STAT_RX_VALID)
				{
					if (uarts_info[i].rx_cnt < RX_SIZE)
						rx_d[i][uarts_info[i].rx_cnt] = uart_read(axi, uarts_info[i]);
					else if (uarts_info[i].rx_cnt == (RX_SIZE)) // last byte which is also crc byte
					{
						volatile unsigned char dummy = uart_read(axi, uarts_info[i]);
						// note, we do not check CRC?
						uarts_info[i].state = data_valid;
					}
					uarts_info[i].rx_cnt++;
				}
				break;
			case data_valid:
				uarts_d[i]( 7, 0) = rx_d[i][0];
				uarts_d[i](15, 8) = rx_d[i][1];
				uarts_d[i](23,16) = rx_d[i][2];
				uarts_d[i](31,24) = rx_d[i][3];
				uarts_d[i](39,32) = rx_d[i][4];
				uarts_d[i](47,40) = rx_d[i][5];
				uarts_d[i](55,48) = rx_d[i][6];
				uarts_d[i](63,56) = rx_d[i][7];
				uarts_info[i].state = idle;
				uarts_busy[i] = 0;
				break;
			default:
				break;
			}
		}
		if (uarts_busy == 0)
			break;
	}
}
