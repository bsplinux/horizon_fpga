#include <stdio.h>
/******************************************************************************
* Copyright (C) 2007 - 2020 Xilinx, Inc.  All rights reserved.
* Copyright (C) 2023 Advanced Micro Devices, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

/****************************************************************************/
/**
*
* @file xsysmon_low_level_example.c
*
* This file contains a design example using the basic driver functions
* of the System Monitor driver. The example here shows using the
* driver/device in polled mode to check the on-chip temperature and voltages.
*
*
* @note
*
* The values of the on-chip temperature and the on-chip Vccaux voltage are read
* from the device and then the alarm thresholds are set in such a manner that
* the alarms occur.
*
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who    Date     Changes
* ----- -----  -------- -----------------------------------------------------
* 1.00a xd/sv  05/22/07 First release
* 2.00a sv     07/07/08 Changed the example to read 16 bits of data from the
*			the ADC data registers.
* 4.00a ktn    10/22/09 Updated the example to use macros that have been
*		        renamed to remove _m from the name of the macro.
* 5.01a bss    03/13/12 Modified while loop condition to wait for EOS bit
*				to become high
* 5.03a bss    04/25/13 Modified SysMonLowLevelExample function to set
*			Sequencer Mode as Safe mode instead of Single
*			channel mode before configuring Sequencer registers.
*			CR #703729
* 7.3   ms   01/23/17 Added xil_printf statement in main function to
*                     ensure that "Successfully ran" and "Failed" strings
*                     are available in all examples. This is a fix for
*                     CR-965028.
* 7.8   cog  07/20/23 Added support for SDT flow
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xsysmon_hw.h"
#include "xstatus.h"
#include "xil_printf.h"

/************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define SYSMON_BASEADDR		XPAR_SYSMON_0_BASEADDR

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Function Prototypes *****************************/

int SysMonLowLevelExample(u32 BaseAddress);

/************************** Variable Definitions ****************************/

/****************************************************************************/
/**
*
* Main function that invokes the example given in this file.
*
* @param	None.
*
* @return
*		- XST_SUCCESS if the example has completed successfully.
*		- XST_FAILURE if the example has failed.
*
* @note		None.
*
*****************************************************************************/
/*
int main(void)
{
	int Status;

	/*
	 * Run the SysMonitor Low level example, specify the Base Address that
	 * is generated in xparameters.h.
	 */
	/*Status = SysMonLowLevelExample(SYSMON_BASEADDR);
	if (Status != XST_SUCCESS) {
		xil_printf("Sysmon lowlevel Example Failed\r\n");
		return XST_FAILURE;
	}
	xil_printf("Successfully ran Sysmon lowlevel Example\r\n");
	return XST_SUCCESS;

}
*/
/****************************************************************************/
/**
*
* This function runs a test on the System Monitor device using the
* basic driver functions.
* The function does the following tasks:
*	- Reset the device
*	- Setup alarm thresholds for on-chip temperature and VCCAUX.
*	- Setup sequence registers to continuously monitor on-chip temperature
*	 and VCCAUX.
*	- Setup configuration registers to start the sequence.
*	- Read latest on-chip temperature and VCCAUX, as well as their maximum
*	 and minimum values. Also check if alarm(s) are set.
*
* @param	BaseAddress is the XPAR_<SYSMON_ADC_instance>_BASEADDRESS value
*		from xparameters.h.
*
* @return	XST_SUCCESS
*
* @note		None.
*
****************************************************************************/
int SysMonLowLevelExample(u32 BaseAddress)
{
	u32 RegValue;
	u32 vcc12 = 0U;

	/*
	 * Reset the device.
	 */
	XSysMon_WriteReg(BaseAddress, XSM_SRR_OFFSET, XSM_SRR_IPRST_MASK);

	/*
	 * Disable the Channel Sequencer before configuring the Sequence
	 * registers.
	 */
	RegValue = XSysMon_ReadReg(BaseAddress, XSM_CFR1_OFFSET) &
			(~ XSM_CFR1_SEQ_VALID_MASK);
	XSysMon_WriteReg(BaseAddress, XSM_CFR1_OFFSET,	RegValue |
				XSM_CFR1_SEQ_SAFEMODE_MASK);

	/*
	 *  Set the Acquisition time for the specified channels.
	 */
	XSysMon_WriteReg(BaseAddress,XSM_SEQ00_OFFSET, XSM_SEQ_CH_VPVN);

	/*
	 *  Set the input mode for the specified channels.
	 */
	XSysMon_WriteReg(BaseAddress, XSM_SEQ00_OFFSET, XSM_SEQ_CH_VPVN);

	/*
	 * Enable the following channels in the Sequencer registers:
	 * 	- VPVN
	XSysMon_WriteReg(BaseAddress, XSM_SEQ00_OFFSET, XSM_SEQ_CH_VPVN);

	/*
	 * Set the ADCCLK frequency equal to 1/32 of System clock for the System
	 * Monitor/ADC in the Configuration Register 2.
	 */
	XSysMon_WriteReg(BaseAddress, XSM_CFR2_OFFSET, 32 << XSM_CFR2_CD_SHIFT);


	/*
	 * Enable the Channel Sequencer in continuous sequencer cycling mode.
	 */
	RegValue = XSysMon_ReadReg(BaseAddress, XSM_CFR1_OFFSET) &
			(~ XSM_CFR1_SEQ_VALID_MASK);
	XSysMon_WriteReg(BaseAddress, XSM_CFR1_OFFSET,	RegValue |
				XSM_CFR1_SEQ_CONTINPASS_MASK);


	/*
	 * Wait till the End of Sequence occurs
	 */
	XSysMon_ReadReg(BaseAddress, XSM_SR_OFFSET); /* Clear the old status */
	while (((XSysMon_ReadReg(BaseAddress, XSM_SR_OFFSET)) &
			XSM_SR_EOS_MASK) != XSM_SR_EOS_MASK);
	/*
	 * Read the current value of the on-chip VCCAUX voltage.
	 */
	vcc12 = XSysMon_ReadReg(BaseAddress, XSM_VPVN_OFFSET);

	printf("Vcc12 Raw = %d\n\r", vcc12);

	return XST_SUCCESS;
}
