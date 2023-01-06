/************************************************************************************
 * Copyright й 1995 - 1998, 3Com Corporation or its subsidiaries ("3Com").  
 * All rights reserved.
 *   
 * This software may be copied and used solely for developing products for 
 * the Palm Computing platform and for archival and backup purposes.  Except 
 * for the foregoing, no part of this software may be reproduced or transmitted 
 * in any form or by any means or used to make any derivative work (such as 
 * translation, transformation or adaptation) without express written consent 
 * from 3Com.
 *
 * 3Com reserves the right to revise this software and to make changes in content 
 * from time to time without obligation on the part of 3Com to provide notification 
 * of such revision or changes.  
 * 3COM MAKES NO REPRESENTATIONS OR WARRANTIES THAT THE SOFTWARE IS FREE OF ERRORS 
 * OR THAT THE SOFTWARE IS SUITABLE FOR YOUR USE.  THE SOFTWARE IS PROVIDED ON AN 
 * "AS IS" BASIS.  3COM MAKES NO WARRANTIES, TERMS OR CONDITIONS, EXPRESS OR IMPLIED, 
 * EITHER IN FACT OR BY OPERATION OF LAW, STATUTORY OR OTHERWISE, INCLUDING WARRANTIES, 
 * TERMS, OR CONDITIONS OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND 
 * SATISFACTORY QUALITY.
 *
 * TO THE FULL EXTENT ALLOWED BY LAW, 3COM ALSO EXCLUDES FOR ITSELF AND ITS SUPPLIERS 
 * ANY LIABILITY, WHETHER BASED IN CONTRACT OR TORT (INCLUDING NEGLIGENCE), FOR 
 * DIRECT, INCIDENTAL, CONSEQUENTIAL, INDIRECT, SPECIAL, OR PUNITIVE DAMAGES OF 
 * ANY KIND, OR FOR LOSS OF REVENUE OR PROFITS, LOSS OF BUSINESS, LOSS OF INFORMATION 
 * OR DATA, OR OTHER FINANCIAL LOSS ARISING OUT OF OR IN CONNECTION WITH THIS SOFTWARE, 
 * EVEN IF 3COM HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * 3Com, HotSync, Palm Computing, and Graffiti are registered trademarks, and 
 * Palm III and Palm OS are trademarks of 3Com Corporation or its subsidiaries.
 *
 * IF THIS SOFTWARE IS PROVIDED ON A COMPACT DISK, THE OTHER SOFTWARE AND 
 * DOCUMENTATION ON THE COMPACT DISK ARE SUBJECT TO THE LICENSE AGREEMENT 
 * ACCOMPANYING THE COMPACT DISK.
 *
 *------------------------------------------------------------------------------------
 * FileName:
 *		SerialSdrv.h
 *
 * Description:
 *		Constants and data structures for serial drvr ('sdrv') code.
 *
 * History:
 *		5/11/98	Created by Ben Manuto
 *******************************************************************/


#ifndef __SERIALSDRV_H__
#define __SERIALSDRV_H__

#include <PalmTypes.h>
#include <CoreTraps.h>

#include <HAL.h>

#include <SerialDrvr.h>

	
// ееееееееее Constants

#define kSdrvResType			'sdrv'


// ееееееееее Typdefs

typedef enum SdrvCtlOpCodeEnum {				// Control function opCodes
	sdrvOpCodeNoOp = 0, 
	sdrvOpCodeSetBaudRate = 0x1000,			// Set baud rate
	sdrvOpCodeSetSettingsFlags,				// Set port send/rcv settings.
	sdrvOpCodeClearErr,							// Clear any HW errors.
	sdrvOpCodeEnableUART,						// Enable the UART.
	sdrvOpCodeDisableUART,						// Disable the UART.
	sdrvOpCodeEnableUARTInterrupts,			// Enable the UART interrupts.
	sdrvOpCodeDisableUARTInterrupts,			// Disable the UART interrupts.
	sdrvOpCodeSetSleepMode,						// Put the HW in sleep mode.
	sdrvOpCodeSetWakeupMode,					// Wake the HW from sleep mode.
	sdrvOpCodeRxEnable,							// Enable the RX lines.
	sdrvOpCodeRxDisable,							// Disbale the RX lines.
	sdrvOpCodeLineEnable,						// Enable the RS-232 lines.
	sdrvOpCodeFIFOCount,							// Return bytes in HW FIFO.
	sdrvOpCodeEnableIRDA,						// Enable the IR mode for the UART.
	sdrvOpCodeDisableIRDA,						// Disable the IR mode for the UART.
	sdrvOpCodeStartBreak,						// Start a break signal.
	sdrvOpCodeStopBreak,							// Stop a break signal.
	sdrvOpCodeStartLoopback,					// Start loopback mode.
	sdrvOpCodeStopLoopback,						// Stop loopback mode.
	sdrvOpCodeFlushTxFIFO,						// Flush HW TX FIFO.
	sdrvOpCodeFlushRxFIFO,						// Flsuh HW RX FIFO.
	sdrvOpCodeGetOptTransmitSize,				// Get HW optimal buffer size.
	sdrvOpCodeEnableRTS,							// De-assert the RTS line to allow data to be received.
	sdrvOpCodeDisableRTS,						// Assert the RTS line to prevent rcv buffer overflows.
	
	// --- Insert new control code above this line
	sdrvOpCodeUserDef = 0x2000
} SdrvCtlOpCodeEnum;


typedef void * SdrvDataPtr;

#if EMULATION_LEVEL == EMULATION_NONE && !defined(__GNUC__)
/* DOLATER: jwm: I'm sure we GCCites will have to worry about this at
   some stage.  Turn off the registers for now.  */

typedef void (*SerialMgrISPProcPtr)(void * portP:__A0);

typedef Err (*SdrvOpenProcPtr)(SdrvDataPtr *drvrDataP, 
										 UInt32 baudRate, 
										 void * portP, 
										 SerialMgrISPProcPtr saveDataProc);
typedef Err (*SdrvCloseProcPtr)(SdrvDataPtr drvrDataP);
typedef Err (*SdrvControlProcPtr)(SdrvDataPtr drvrDataP,
											SdrvCtlOpCodeEnum controlCode, 
								 			void * controlDataP, 
								 			UInt16 * controlDataLenP);
typedef UInt16 (*SdrvStatusProcPtr)(SdrvDataPtr drvrDataP);
typedef UInt16 (*SdrvReadCharProcPtr)(SdrvDataPtr drvrDataP:__A0):__D0;
typedef Err (*SdrvWriteCharProcPtr)(SdrvDataPtr drvrDataP, UInt8 aChar);

#else
typedef void (*SerialMgrISPProcPtr)(void * portP);
typedef Err (*SdrvOpenProcPtr)(SdrvDataPtr *drvrDataP, 
										 UInt32 baudRate, 
										 void * portP, 
										 void * saveDataProc);
typedef Err (*SdrvCloseProcPtr)(SdrvDataPtr drvrDataP);
typedef Err (*SdrvControlProcPtr)(SdrvDataPtr drvrDataP,
											SdrvCtlOpCodeEnum controlCode, 
								 			void * controlDataP, 
								 			UInt16 * controlDataLenP);
typedef UInt16 (*SdrvStatusProcPtr)(SdrvDataPtr drvrDataP);
typedef UInt16 (*SdrvReadCharProcPtr)(SdrvDataPtr drvrDataP);
typedef Err (*SdrvWriteCharProcPtr)(SdrvDataPtr drvrDataP, UInt8 aChar);
#endif


typedef struct {
	SdrvOpenProcPtr 		drvOpen;
	SdrvCloseProcPtr 		drvClose;
	SdrvControlProcPtr 	drvControl;
	SdrvStatusProcPtr 	drvStatus;
	SdrvReadCharProcPtr 	drvReadChar;
	SdrvWriteCharProcPtr drvWriteChar;
} SdrvAPIType;

typedef SdrvAPIType *SdrvAPIPtr;


// Normally, serial drvr functions are accessed (by the NewSerialMgr)
// through the above SdrvAPIType structure of ProcPtrs.

// However, SerialMgrDbg.c (the Serial Mgr linked to the boot/debugger code)
// needs to call the HAL's debug serial code through the HAL_CALL macro.


Err DrvOpen(SdrvDataPtr *drvrData, UInt32 baudRate, void * portP, 
				SerialMgrISPProcPtr saveDataProc)
		HAL_CALL(sysTrapDbgSerDrvOpen);

Err DrvClose(SdrvDataPtr drvrData)
		HAL_CALL(sysTrapDbgSerDrvClose);

Err DrvControl(SdrvDataPtr drvrData, SdrvCtlOpCodeEnum controlCode, 
					void * controlData, UInt16 * controlDataLen)
		HAL_CALL(sysTrapDbgSerDrvControl);

UInt16 DrvStatus(SdrvDataPtr drvrData)
		HAL_CALL(sysTrapDbgSerDrvStatus);

Err DrvWriteChar(SdrvDataPtr drvrData, UInt8 aChar)
		HAL_CALL(sysTrapDbgSerDrvWriteChar);

#if EMULATION_LEVEL == EMULATION_NONE && !defined(__GNUC__)
#pragma parameter __D0 DrvReadChar(__A0)
#endif
UInt16 DrvReadChar(SdrvDataPtr drvrData)
		HAL_CALL(sysTrapDbgSerDrvReadChar);

#endif		// __SERIALSDRV_H__

