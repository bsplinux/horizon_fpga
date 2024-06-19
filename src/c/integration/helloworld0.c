/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#define REGS_BASE 0x43c00000
#define SPI0_BASE 0x41E00000
#define SPI1_BASE 0x41E10000
#define SPI2_BASE 0x41E20000
#define reg(a) (*((volatile unsigned int *)(a*4)))

#define STAT_RX_EMPTY_MASK 0x1
#define STAT_TX_EMPTY_MASK 0x4

volatile unsigned int * regs_p = (volatile unsigned int *)REGS_BASE;
volatile unsigned int * spi0_p = (volatile unsigned int *)SPI0_BASE;
volatile unsigned int * spi1_p = (volatile unsigned int *)SPI1_BASE;
volatile unsigned int * spi2_p = (volatile unsigned int *)SPI2_BASE;

int main()
{
	unsigned int r0[16] = {0};
	unsigned int r1[16] = {0};
	unsigned int r2[16] = {0};
	init_platform();

    print("Hello World and Meir\n\r");
    print("Successfully ran Hello World application\n\r");

    for (int i = 0; i < 10; i++ )
    {
    	//unsigned int r = reg(i);
    	unsigned int r = regs_p[i];
    	printf("REG(0x%02X) = 0x%08X\n\r",i,r);
    }

	//printf("ADD(0x%02X) = 0x%08X\n\r",0x60,spi1_p[0x60/4]);
    spi0_p[0x40/4] = 0xA;
    spi1_p[0x40/4] = 0xA;
    spi2_p[0x40/4] = 0xA;

    spi0_p[0x60/4] = 0x6;
    spi1_p[0x60/4] = 0x6;
    spi2_p[0x60/4] = 0x6;
    spi0_p[0x70/4] = 0xFFFE;
    spi1_p[0x70/4] = 0xFFFE;
    spi2_p[0x70/4] = 0xFFFE;
	//printf("ADD(0x%02X) = 0x%08X\n\r",0x60,spi1_p[0x60/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x64,spi1_p[0x64/4]);

	r0[0] = 0x8000;
	r1[0] = 0x8000;
	r2[0] = 0x8000;
	r0[1] = 0xFFFF;
	r1[1] = 0xFFFF;
	r2[1] = 0xFFFF;
    for(int i = 2; i < 16; i++)
    {
    	r0[i] = 0x2000;
    	r1[i] = 0x2000;
    	r2[i] = 0x2000;
    }

	for(int i = 0; i < 16; i++)
	{
	    spi0_p[0x60/4] = 0x4;
	    spi1_p[0x60/4] = 0x4;
	    spi2_p[0x60/4] = 0x4;
		spi0_p[0x68/4] = r0[i];
		spi1_p[0x68/4] = r1[i];
		spi2_p[0x68/4] = r2[i];
	    for(;;)
	    	if ((spi0_p[0x64/4] & STAT_TX_EMPTY_MASK) == 0)
	    		break;
	    for(;;)
	    	if ((spi1_p[0x64/4] & STAT_TX_EMPTY_MASK) == 0)
	    		break;
	    for(;;)
	    	if ((spi2_p[0x64/4] & STAT_TX_EMPTY_MASK) == 0)
	    		break;
	    spi0_p[0x60/4] = 0x6;
	    spi1_p[0x60/4] = 0x6;
	    spi2_p[0x60/4] = 0x6;
	    for(;;)
	    	if ((spi0_p[0x64/4] & STAT_RX_EMPTY_MASK) == 0)
	    		break;
	    for(;;)
	    	if ((spi1_p[0x64/4] & STAT_RX_EMPTY_MASK) == 0)
	    		break;
	    for(;;)
	    	if ((spi2_p[0x64/4] & STAT_RX_EMPTY_MASK) == 0)
	    		break;
	    r0[i] = spi0_p[0x6C/4];
	    r1[i] = spi1_p[0x6C/4];
	    r2[i] = spi2_p[0x6C/4];
	}
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x74,spi1_p[0x74/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x78,spi1_p[0x78/4]);

//	printf("ADD(0x%02X) = 0x%08X\n\r",0x64,spi1_p[0x64/4]);
    //spi1_p[0x60/4] = 0x6;
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x64,spi1_p[0x64/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x74,spi1_p[0x74/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x78,spi1_p[0x78/4]);

//	for (int i = 0; i < 8 ; i++)
//		r[i] = spi1_p[0x6C/4];
//	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[0]);
//	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[1]);
//	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[2]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[3]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[4]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[5]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[6]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[7]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[8]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[9]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[10]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[11]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[12]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[13]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[14]);
	printf("spi 0 ADD(0x%02X) = 0x%08X\n\r",0x6C,r0[15]);

	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[3]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[4]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[5]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[6]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[7]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[8]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[9]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[10]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[11]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[12]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[13]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[14]);
	printf("spi 1 ADD(0x%02X) = 0x%08X\n\r",0x6C,r1[15]);

	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[3]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[4]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[5]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[6]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[7]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[8]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[9]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[10]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[11]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[12]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[13]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[14]);
	printf("spi 2 ADD(0x%02X) = 0x%08X\n\r",0x6C,r2[15]);

//	printf("ADD(0x%02X) = 0x%08X\n\r",0x64,spi1_p[0x64/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x74,spi1_p[0x74/4]);
//	printf("ADD(0x%02X) = 0x%08X\n\r",0x78,spi1_p[0x78/4]);

	/*for (int i = 0x40/4; i < 0x74/4; i++ )
    {
    	//unsigned int r = reg(i);
    	unsigned int r = spi1_p[i];
    	printf("ADD(0x%02X) = 0x%08X\n\r",i*4,r);
    }
*/
    cleanup_platform();
    return 0;
}
