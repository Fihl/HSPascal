/************************************************************************************
 * Copyright © 1995 - 1998, 3Com Corporation or its subsidiaries ("3Com").  
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
 *		SerialVdrv.h
 *
 * Description:
 *		Constants and data structures for virtual driver ('vdrv') code.
 *
 * History:
 *		5/11/98	Created by Ben Manuto
 *******************************************************************/


#ifndef __SERIALVDRV_H__
#define __SERIALVDRV_H__

#include <PalmTypes.h>
#include <CoreTraps.h>
#include <SerialDrvr.h>


// ********** Constants

#define kVdrvResType			'vdrv'


// ********** Typedefs

typedef enum VdrvCtlOpCodeEnum {				// Control function opCodes
	vdrvOpCodeNoOp = 0, 
	vdrvOpCodeSetBaudRate = 0x1000,			// Set the port's baud rate.
	vdrvOpCodeSetSettingsFlags,				// Set the ports send/rvc settings
	vdrvOpCodeSetCtsTimeout,					// The HW handshake timeout.
	vdrvOpCodeClearErr,							// Clear any HW errors.
	vdrvOpCodeSetSleepMode,						// Put in sleep mode.
	vdrvOpCodeSetWakeupMode,					// Wake from sleep mode.
	vdrvOpCodeFIFOCount,							// Return bytes in FIFO
	vdrvOpCodeStartBreak,						// Start a break signal.
	vdrvOpCodeStopBreak,							// Stop a break signal
	vdrvOpCodeStartLoopback,					// Start loopback mode.
	vdrvOpCodeStopLoopback,						// Stop loopback mode.
	vdrvOpCodeFlushTxFIFO,						// Flush the TX FIFO.
	vdrvOpCodeFlushRxFIFO,						// Flush the RX FIFO.
	vdrvOpCodeSendBufferedData,				// Send any buffered data in e vdrv.
	vdrvOpCodeRcvCheckIdle,						// Check idle state.
	vdrvOpCodeEmuSetBlockingHook,				// Special opCode for the simulator.
	vdrvOpCodeGetOptTransmitSize,				// Get the optimal TX buffer size for this port.
	vdrvOpCodeGetMaxRcvBlockSize,				// Get the optimal RX buffer size for this port.
	vdrvOpCodeNotifyBytesReadFromQ,			// Notify the vdrv bytes have been removed from Q.
	
	// --- Insert new control code above this line
	vdrvOpCodeUserDef = 0x2000
} VdrvCtlOpCodeEnum;

typedef void * VdrvDataPtr;

typedef Err (*VdrvOpenProcPtr)(VdrvDataPtr* drvrDataP, UInt32 baudRate, DrvrHWRcvQPtr rcvQP);
typedef Err (*VdrvCloseProcPtr)(VdrvDataPtr drvrDataP);

typedef UInt16 (*VdrvStatusProcPtr)(VdrvDataPtr drvrDataP);
typedef Err (*VdrvControlProcPtr)(VdrvDataPtr drvrDataP,
											VdrvCtlOpCodeEnum controlCode, 
								 			void * controlDataP, 
								 			UInt16 * controlDataLenP);

typedef Err (*VdrvReadProcPtr)(VdrvDataPtr drvrDataP, void **bufP, UInt32 *sizeP);
typedef UInt32 (*VdrvWriteProcPtr)(VdrvDataPtr drvrDataP, void * bufP, UInt32 size, Err* errP);


typedef struct {
	VdrvOpenProcPtr 		drvOpen;
	VdrvCloseProcPtr 		drvClose;
	VdrvControlProcPtr 	drvControl;
	VdrvStatusProcPtr 	drvStatus;
	VdrvReadProcPtr 		drvRead;
	VdrvWriteProcPtr 		drvWrite;
} VdrvAPIType;

typedef VdrvAPIType *VdrvAPIPtr;

#endif		// __SERIALVDRV_H__

