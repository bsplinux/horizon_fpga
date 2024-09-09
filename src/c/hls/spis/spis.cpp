#include "spis.h"

#define TX_BUFF_SIZE 12
const unsigned int tx_buff[TX_BUFF_SIZE] = {
		0x8000, // frame that sets options in spi
		0xFFFF, // frame that says what chanels to read in sequence
		0x2800, // first read, but data will come only next read
		0x2800, // second read
		0x2800, // third read, first data valid d0
		0x2800, // d1
		0x2800, // d2
		0x2800, // d3
		0x2800, // d4
		0x2800, // d5
		0x2800, // d6
		0x2800  // d7
};

const int rx_max[3] = {8,4,8};

void spi_init(
	volatile unsigned int * axi,
	spi_info_t info
	)
{
	unsigned int a;
	a = info.adr + SPI_REG_RST;
	axi[a/sizeof(int)] = RST_VAL;
	a = info.adr + SPI_REG_CTRL;
	axi[a/sizeof(int)] = START_SPI;
	a = info.adr + SPI_REG_SSEL;
	axi[a/sizeof(int)] = 0xFFFE; // enable only one slave
}

void spi_halt(
	volatile unsigned int * axi,
	spi_info_t info
	)
{
	unsigned int a = info.adr + SPI_REG_CTRL;
	axi[a/sizeof(int)] = HALT_SPI;
}

void spi_cont(
	volatile unsigned int * axi,
	spi_info_t info
	)
{
	unsigned int a = info.adr + SPI_REG_CTRL;
	axi[a/sizeof(int)] = START_SPI;
}

unsigned char spi_stat (
	volatile unsigned int * axi,
	spi_info_t info
	)
{
	unsigned char stat = 0;
	unsigned int a = info.adr + SPI_REG_STAT;
	stat = axi[a/sizeof(int)];
	return stat;
}

void spi_write(
	volatile unsigned int * axi,
	spi_info_t info,
	unsigned int d
	)
{
	unsigned int a = info.adr + SPI_REG_TXFIFO;
	axi[a/sizeof(int)] = d;
}

unsigned int spi_read(
	volatile unsigned int * axi,
	spi_info_t info
	)
{
	unsigned int a = info.adr + SPI_REG_RXFIFO;
	return axi[a/sizeof(int)];
}

// each call to this function will read all enabled spis once, and exit when done.
// can't change the enabled spis, it's a one time selection
// you should call this function once evey 0.1 milisecond
ap_uint<MAX_SPIS> spis(
	volatile unsigned int * axi,
	ap_uint<MAX_SPIS> spi_en,
	ap_uint<MAX_CHANS*16> spis_d[MAX_SPIS]
)
{
	static spi_info_t spis_info[MAX_SPIS];
	static bool init_done = false;
	ap_uint<MAX_SPIS> spis_busy = 0xFFFFFFFF;
	unsigned char rx_cnt[MAX_SPIS] = {0};
	unsigned char stat;
	unsigned short rx_d[MAX_SPIS][MAX_CHANS];
	ap_uint<MAX_SPIS> spis_ok = 0xFFFFFFFF;

	if (!init_done)
	{
		init_loop: for(int i = 0; i < MAX_SPIS; i++)
		{
			spis_info[i].num = i;
			spis_info[i].adr = SPI_BASE + i * 0x10000;
			if (spi_en[i] == 0)
				spis_info[i].state = disable;
			else
				spis_info[i].state = init;
		}
		init_done = true;
	}

	main_loop: for(;;)
	{
		spis_loop: for(int i = 0; i < MAX_SPIS; i++)
		{
			if (spis_info[i].state == disable)
			{
				spis_ok[i] = 0;
				spis_busy[i] = 0;
			}
			if(spis_busy[i] == 0)  // will happen if this spi is done but others are still waiting or in disable state
				continue;

			switch (spis_info[i].state) {
			case init: // one time init
				spi_init(axi, spis_info[i]);
				spis_info[i].state = wr_fifo;
				break;
			case wr_fifo:
				spi_halt(axi,spis_info[i]);
				spi_write(axi, spis_info[i], tx_buff[rx_cnt[i]]);
				spis_info[i].state = tx;
				break;
			case tx:
				stat = spi_stat(axi, spis_info[i]);
				if ((stat & STAT_TX_EMPTY_MASK) == 0) // waiting for tx fifo to be not empty
				{
					spi_cont(axi, spis_info[i]);
					spis_info[i].state = rd_fifo;
				}
				break;
			case rd_fifo: // wait until all data was received
				stat = spi_stat(axi, spis_info[i]);
				if ((stat & STAT_RX_EMPTY_MASK) == 0)
				{
					ap_uint<32> d = spi_read(axi, spis_info[i]);
					if (rx_cnt[i] > 2)
					{
						ap_uint<4> chan = d(15,12);
						if (chan < rx_max[i])
							rx_d[i][chan] = d(15,0);
						else
							spis_ok[i] = 0;
					}
					if (rx_cnt[i] == TX_BUFF_SIZE)
						spis_info[i].state = done;
					else
						spis_info[i].state = wr_fifo;
					rx_cnt[i]++;
				}
				break;
			case done:  // this spi is done, function still needs to take care of other spis before exiting
				spis_info[i].state = wr_fifo;
				spis_busy[i] = 0;
				break;
			default:
				break;
			}
		}
		if (spis_busy == 0)
			break;
	}
	final_write: for(int spi = 0, i = 0; spi < MAX_SPIS; spi++)
	{
		spis_d[spi]( 15,  0) = rx_d[spi][0];
		spis_d[spi]( 31, 16) = rx_d[spi][1];
		spis_d[spi]( 47, 32) = rx_d[spi][2];
		spis_d[spi]( 63, 48) = rx_d[spi][3];
		spis_d[spi]( 79, 64) = rx_d[spi][4];
		spis_d[spi]( 95, 80) = rx_d[spi][5];
		spis_d[spi](111, 96) = rx_d[spi][6];
		spis_d[spi](127,112) = rx_d[spi][7];
	}
	return spis_ok;
}
