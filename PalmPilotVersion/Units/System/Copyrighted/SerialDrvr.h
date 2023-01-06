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
 *		SerHWDrvr.h
 *
 * Description:
 *		Constants and data structures for serial drvr ('sdrv') code.
 *
 * History:
 *		1/23/98	Created by Ben Manuto
 *******************************************************************/


#ifndef __SERIALDRVR_H__
#define __SERIALDRVR_H__

#include <PalmTypes.h>

// ********** Constants

#define kDrvrCreator				0
#define kDrvrResID				0
#define kDrvrCODEType			'code'


// kDrvrVersion is included by all sdrv's and vdrv's and is returned by the drvr to the
// serial manager to show the driver version is consistent with the required version of
// drvr the new serial manager needs in order to operate properly. 
#define kDrvrVersion				3

#define kMaxPortDescStrLen		64
#define kPortDescStrID			1000

// Flags denoting capabilities and features of this port.

#define portPhysicalPort		0x00000001		// Should be unset for virtual port.

#define portRS232Capable		0x00000004		// Denotes this serialHW has a RS-232 port.
#define portIRDACapable			0x00000008		// Denotes this serialHW has a IR port and support IRDA mode.

#define portCradlePort 			0x00000010		// Denotes this SerialHW controls the cradle port.
#define portExternalPort		0x00000020		// Denotes this SerialHW's port is external or on a memory card.
#define portModemPort			0x00000040		// Denotes this SerialHW communicates with a modem.

#define portCncMgrVisible		0x00000080		// Denotes this serial port's name is to be displayted in the Connection panel.
#define portPrivateUse			0x00001000		// Set if this drvr is for special software and NOT general apps in system.	


// ********** Structs

typedef enum DrvrIRQEnum {
	drvrIRQNone = 0x00,
	drvrIRQ1 = 0x01,
	drvrIRQ2 = 0x02,
	drvrIRQ3 = 0x04,
	drvrIRQ4 = 0x08,
	drvrIRQ5 = 0x10,
	drvrIRQ6 = 0x20,
	drvrIRQOther = 0x40
} DrvrIRQEnum;
	

// ***** Info about this particular port

typedef struct {								
	UInt32 drvrID; 					// e.g. creator type, such as 'u328'
	UInt32 drvrVersion;				// version of code that works for this HW.
	UInt32 maxBaudRate;				// Maximum baud rate for this uart.
	UInt32 handshakeThreshold;		// Baud rate at which hardware handshaking should be used.
	UInt32 portFlags;					// flags denoting features of this uart.
	Char * portDesc;					// Pointer to null-terminated string describing this HW.
	DrvrIRQEnum irqType;				// IRQ line for this uart serial HW.
	UInt8 reserved;
} DrvrInfoType;

typedef DrvrInfoType *DrvrInfoPtr;


typedef enum DrvrEntryOpCodeEnum {			// OpCodes for the entry function.
	drvrEntryGetUartFeatures,
	drvrEntryGetDrvrFuncts
} DrvrEntryOpCodeEnum;


typedef enum DrvrStatusEnum {
	drvrStatusCtsOn			= 0x0001,
	drvrStatusRtsOn			= 0x0002,
	drvrStatusDsrOn 			= 0x0004,
	drvrStatusTxFifoFull  	= 0x0008,
	drvrStatusTxFifoEmpty	= 0x0010,
	drvrStatusBreakAsserted	= 0x0020,
	drvrStatusDataReady		= 0x0040,		// For polling mode debugger only at this time.
	drvrStatusLineErr			= 0x0080			// For polling mode debugger only at this time.
} DrvrStatusEnum;	


// ********** Entry Point Function type

typedef Err (*DrvEntryPointProcPtr)(DrvrEntryOpCodeEnum opCode, void * uartData);


// ********** ADT and functions for Rcv Queue.

typedef Err (*WriteByteProcPtr)(void * theQ, UInt8 theByte, UInt16 lineErrs);
typedef Err (*WriteBlockProcPtr)(void * theQ, UInt8 * bufP, UInt16 size, UInt16 lineErrs);
typedef UInt32 (*GetSizeProcPtr)(void * theQ);
typedef UInt32 (*GetSpaceProcPtr)(void * theQ);

typedef struct DrvrRcvQType {
	void * 				rcvQ;
	WriteByteProcPtr	qWriteByte;
	WriteBlockProcPtr qWriteBlock;
	GetSizeProcPtr		qGetSize;
	GetSpaceProcPtr	qGetSpace;
} DrvrRcvQType;

typedef DrvrRcvQType *DrvrHWRcvQPtr;

#endif		// __SERIALDRVR_H__

