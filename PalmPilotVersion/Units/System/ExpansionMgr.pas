/******************************************************************************
 *
 * Copyright (c) 2000-2002 Palm, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ExpansionMgr.h
 *
 * Release: Palm OS SDK 5.0 (108167)
 *
 * Description:
 *    Header file for Expansion Manager.
 *
 * History:
 *    02/25/00 jed   Created by Jesse Donaldson.
 *
 * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ExpansionMgr;

Interface

Uses Traps50;

Const
  expErrorClass      =0x2900;       // Post 3.5 this is defined in ErrorBase.h
  sysTrapExpansionMgr   =sysTrapExpansionDispatch;


  expFtrIDVersion          =0;    // ID of feature containing version of ExpansionMgr.
                                  // Check existence of this feature to see if ExpMgr is installed.

  expMgrVersionNum         =200;  // version of the ExpansionMgr, obtained from the feature

  expInvalidSlotRefNum     =0;

   // Post 3.5 these are defined in NotifyMgr.h.
         sysNotifyCardInsertedEvent  ='crdi';   // Broadcast when an ExpansionMgr card is
                                                // inserted into a slot, and the slot driver
                                                // calls ExpCardInserted.  Always broadcast
                                                // from UI task.
                                                // ExpansionMgr will play a sound & attempt to
                                                // mount a volume unless 'handled' is set
                                                // to true by a notification handler.
                                                // PARAMETER: slot number cast as void*

         sysNotifyCardRemovedEvent   ='crdo';   // Broadcast when an ExpansionMgr card is
                                                // removed from a slot, and the slot driver
                                                // calls ExpCardRemoved.  Always broadcast
                                                // from UI task.
                                                // ExpansionMgr will play a sound & attempt to
                                                // unmount a volume unless 'handled' is set
                                                // to true by a notification handler.
                                                // PARAMETER: slot number cast as void*

         sysNotifyVolumeMountedEvent ='volm';   // Broadcast when a VFSMgr volume is
                                                // mounted, Always broadcast
                                                // from UI task.
                                                // PARAMETER: VFSAnyMountParamPtr cast as void*

         sysNotifyVolumeUnmountedEvent ='volu'; // Broadcast when a VFSMgr volume is
                                                // unmounted, Always broadcast
                                                // from UI task.
                                                // PARAMETER: volume refNum cast as void*


         sysFileCExpansionMgr        ='expn';   // Type of Expansion Manager extension database

         sysFileTSlotDriver          ='libs';   // file type for slot driver libraries

  //SKIPPED  typedef Err (*ExpPollingProcPtr)(UInt16 slotLibRefNum, void *slotPollRefConP);


/************************************************************
 * Capabilities of the hardware device for ExpCardInfoType.capabilityFlags
 *************************************************************/
  expCapabilityHasStorage    =0x00000001;  // card supports reading (& maybe writing) sectors
  expCapabilityReadOnly      =0x00000002;  // card is read only
  expCapabilitySerial        =0x00000004;  // card supports dumb serial interface

  expCardInfoStringMaxLen     =31;

Type
  ExpCardInfoPtr = ^ExpCardInfoType;
  ExpCardInfoType = Record
    capabilityFlags: UInt32;                           // bits for different stuff the card supports
    manufacturerStr: String[expCardInfoStringMaxLen];  // Manufacturer, e.g., "Palm", "Motorola", etc...
    productStr: String[expCardInfoStringMaxLen];       // Name of product, e.g., "SafeBackup 32MB"
    deviceClassStr: String[expCardInfoStringMaxLen];   // Type of product, e.g., "Backup", "Ethernet", etc.
    deviceUniqueIDStr: String[expCardInfoStringMaxLen];// Unique identifier for product, e.g., a serial number.  Set to "" if no such identifier exists.
  end;

Const
/************************************************************
 * Iterator start and stop constants.
 * Used by ExpSlotEnumerate
 *************************************************************/
  expIteratorStart              =0;
  expIteratorStop               =-1; //0xffffffffL


/************************************************************
 * Bits in the 'handled' field used in Card Inserted and Removed notifications
 *************************************************************/
  expHandledVolume      =0x01;  // any volumes associated with the card have been dealt with... the ExpansionMgr will not mount or unmount as appropriate.
  expHandledSound       =0x02;  // Any pleasing sounds have already been played... the ExpansionMgr will not play a pleasing sound on this insertion/removal.


/************************************************************
 * Error codes
 *************************************************************/
  expErrUnsupportedOperation        =expErrorClass | 1;     // unsupported or undefined opcode and/or creator
  expErrNotEnoughPower              =expErrorClass | 2;     // the required power is not available

  expErrCardNotPresent              =expErrorClass | 3;     // no card is present
  expErrInvalidSlotRefNum           =expErrorClass | 4;     // slot reference number is bad
  expErrSlotDeallocated             =expErrorClass | 5;     // slot reference number is within valid range, but has been deallocated.
  expErrCardNoSectorReadWrite       =expErrorClass | 6;     // the card does not support the
                                                                  // SlotDriver block read/write API
  expErrCardReadOnly                =expErrorClass | 7;     // the card does support R/W API
                                                                  // but the card is read only
  expErrCardBadSector               =expErrorClass | 8;     // the card does support R/W API
                                                                  // but the sector is bad
  expErrCardProtectedSector         =expErrorClass | 9;     // The card does support R/W API
                                                                  // but the sector is protected
  expErrNotOpen                     =expErrorClass | 10;    // slot driver library has not been opened
  expErrStillOpen                   =expErrorClass | 11;    // slot driver library is still open - maybe it was opened > once
  expErrUnimplemented               =expErrorClass | 12;    // Call is unimplemented
  expErrEnumerationEmpty            =expErrorClass | 13;    // No values remaining to enumerate
  expErrIncompatibleAPIVer          =expErrorClass | 14;    // The API version of this slot driver is not supported by this version of ExpansionMgr.


/************************************************************
 * Common media types.  Used by SlotCardMediaType and SlotMediaType.
 *************************************************************/
  expMediaType_Any            ='wild';   // matches all media types when looking up a default directory
  expMediaType_MemoryStick    ='mstk';
  expMediaType_CompactFlash   ='cfsh';
  expMediaType_SecureDigital  ='sdig';
  expMediaType_MultiMediaCard ='mmcd';
  expMediaType_SmartMedia     ='smed';
  expMediaType_RAMDisk        ='ramd';   // a RAM disk based media
  expMediaType_PoserHost      ='pose';   // Host filesystem emulated by Poser
  expMediaType_MacSim         ='PSim';   // Host filesystem emulated by Poser


/************************************************************
 * Selectors for routines found in the Expansion manager. The order
 * of these selectors MUST match the jump table in ExpansionMgr.c.
 *************************************************************/
  expTrapInit               =0;
  expTrapSlotDriverInstall  =1;
  expTrapSlotDriverRemove   =2;
  expTrapSlotLibFind        =3;
  expTrapSlotRegister       =4;
  expTrapSlotUnregister     =5;
  expTrapCardInserted       =6;
  expTrapCardRemoved        =7;
  expTrapCardPresent        =8;
  expTrapCardInfo           =9;
  expTrapSlotEnumerate      =10;
  expTrapCardGetSerialPort  =11;

  expTrapMaxSelector        =expTrapCardGetSerialPort;


Function ExpInit: Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapInit);

Function ExpSlotDriverInstall(dbCreator: UInt32; var slotLibRefNumP: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotDriverInstall);

Function ExpSlotDriverRemove(slotLibRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotDriverRemove);

Function ExpSlotLibFind(slotRefNum: UInt16; var slotLibRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotLibFind);

Function ExpSlotRegister(slotLibRefNum: UInt16; var slotRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotRegister);

Function ExpSlotUnregister(slotRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotUnregister);

Function ExpCardInserted(slotRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapCardInserted);

Function ExpCardRemoved(slotRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapCardRemoved);

Function ExpCardPresent(slotRefNum: UInt16): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapCardPresent);

Function ExpCardInfo(slotRefNum: UInt16; var infoP: ExpCardInfoType): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapCardInfo);

Function ExpSlotEnumerate(var slotRefNumP: UInt16; var slotIteratorP: UInt32): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapSlotEnumerate);

Function ExpCardGetSerialPort(slotRefNum: UInt16; var portP: UInt32): Err;
      SYS_TRAP(sysTrapExpansionMgr,expTrapCardGetSerialPort);

Implementation

end.


