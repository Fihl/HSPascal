/******************************************************************************
 *
 * Copyright (c) 2000-2002 Palm, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: VFSMgr.h
 *
 * Release: Palm OS SDK 5.0 (108167)
 *
 * Description:
 *    Header file for VFS Manager.
 *
 * History:
 *    02/25/00 jed   Created by Jesse Donaldson.
 *
 * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit VFSMgr;

Interface

Uses Traps50, ExpansionMgr, SystemResources, DataMgr;
//Uses PalmTypes, CoreTraps, SystemMgr, ExpansionMgr;

Const
  sysFileCVFSMgr     = 'vfsm';   // Creator type for VFSMgr...
  vfsErrorClass                   = 0x2A00;  // Post-3.5 this is defined in ErrorBase.h
  sysTrapVFSMgr   = sysTrapFileSystemDispatch;    // = sysTrapSysReserved3; //= $A348;

  vfsFtrIDVersion    =0;   // ID of feature containing version of VFSMgr.
                           // Check existence of this feature to see if VFSMgr is installed.

  vfsFtrIDDefaultFS  =1; // ID of feature containing the creator ID of the default filesystem library
                         // this is the default choice when choosing a library for formatting/mounting

  vfsMgrVersionNum   =200;  // version of the VFSMgr, obtained from the feature

// MountClass constants:
  vfsMountClass_SlotDriver    =sysFileTSlotDriver;
  vfsMountClass_Simulator     =sysFileTSimulator;
  vfsMountClass_POSE          ='pose';



Type
  // Base MountParamType; others such as SlotMountParamType are extensions of this base type,
  // switched on value of "mountClass" parameter.  It will make more sense someday when there
  // are other kinds of FileSystems...  (Trust us.  :-)
  VFSAnyMountParamPtr=^VFSAnyMountParamType;
  VFSAnyMountParamType = Record
    volRefNum: UInt16;          // The volRefNum of the volume.
    reserved: UInt16;
    mountClass: UInt32;         // 'libs' for slotDriver-based filesystems
   // Other fields here, depending on value of 'mountClass'
  end;

  VFSSlotMountParamType = Record
    vfsMountParam: VFSAnyMountParamType;     // mountClass = VFSMountClass_SlotDriver = 'libs'
    slotLibRefNum: UInt16; 
    slotRefNum: UInt16;
  end;

  VFSPOSEMountParamType = Record
    vfsMountParam: VFSAnyMountParamType;     // mountClass = VFSMountClass_POSE = 'pose'
    poseSlotNum: UInt8;
  end;


  { For Example...
  VFSOtherMountParamTag = Record
    vfsMountParam: VFSAnyMountParamType;    // mountClass = 'othr' (for example)
    otherValue: UInt16;
  end;
  }

  FileInfoPtr = ^FileInfoType;
  FileInfoType = Record
    attributes: UInt32;
    nameP: PChar;           // buffer to receive full name; pass NULL to avoid getting name
    nameBufLen: UInt16;       // size of nameP buffer, in bytes
  end;

  VolumeInfoPtr = ^VolumeInfoType;
  VolumeInfoType = Record
    attributes: UInt32;       // read-only etc.
    fsType: UInt32;           // Filesystem type for this volume (defined below)
    fsCreator: UInt32;        // Creator code of filesystem driver for this volume.  For use with VFSCustomControl().
    mountClass: UInt32;       // mount class that mounted this volume

    // For slot based filesystems: (mountClass = vfsMountClass_SlotDriver)
    slotLibRefNum: UInt16;    // Library on which the volume is mounted
    slotRefNum: UInt16;       // ExpMgr slot number of card containing volume
    mediaType: UInt32;        // Type of card media (mediaMemoryStick, mediaCompactFlash, etc...)
    reserved: UInt32;         // reserved for future use (other mountclasses may need more space)
  end;


  FileRef = UInt32;

Const
  vfsInvalidVolRef     =0;     // constant for an invalid volume reference, guaranteed not to represent a valid one.  Use it like you would use NULL for a FILE*.
  vfsInvalidFileRef    =0;     // constant for an invalid file reference, guaranteed not to represent a valid one.  Use it like you would use NULL for a FILE*.


/************************************************************
 * File Origin constants: (for the origins of relative offsets passed to 'seek' type routines).
 *************************************************************/
  vfsOriginBeginning    =0;  // from the beginning (first data byte of file)
  vfsOriginCurrent      =1;  // from the current position
  vfsOriginEnd          =2;  // from the end of file (one position beyond last data byte, only negative offsets are legal)

Type FileOrigin= UInt16;


/************************************************************
 * openMode flags passed to VFSFileOpen
 *************************************************************/
Const
  vfsModeExclusive         =0x0001;      // don't let anyone else open it
  vfsModeRead              =0x0002;      // open for read access
  vfsModeWrite             =0x0004 | vfsModeExclusive;     // open for write access, implies exclusive
  vfsModeCreate            =0x0008;      // create the file if it doesn't already exist.  Implemented in VFS layer, no FS lib call will ever have to handle this.
  vfsModeTruncate          =0x0010;      // Truncate file to 0 bytes after opening, removing all existing data.  Implemented in VFS layer, no FS lib call will ever have to handle this.
  vfsModeReadWrite         =vfsModeWrite | vfsModeRead;     // open for read/write access
  vfsModeLeaveOpen         =0x0020;      // Leave the file open even if when the foreground task closes


// Combination flag constants, for error checking purposes:
  vfsModeAll               =vfsModeExclusive | vfsModeRead | vfsModeWrite | vfsModeCreate | vfsModeTruncate | vfsModeReadWrite | vfsModeLeaveOpen;
  vfsModeVFSLayerOnly      =vfsModeCreate | vfsModeTruncate;      // flags only used apps & the VFS layer, FS libraries will never see these.


/************************************************************
 * File Attributes
 *************************************************************/
  vfsFileAttrReadOnly      =$00000001;
  vfsFileAttrHidden        =$00000002;
  vfsFileAttrSystem        =$00000004;
  vfsFileAttrVolumeLabel   =$00000008;
  vfsFileAttrDirectory     =$00000010;
  vfsFileAttrArchive       =$00000020;
  vfsFileAttrLink          =$00000040;

  vfsFileAttrAll           =$0000007f;


/************************************************************
 * Volume Attributes
 *************************************************************/
  vfsVolumeAttrSlotBased   =$00000001;    // reserved
  vfsVolumeAttrReadOnly    =$00000002;    // volume is read only
  vfsVolumeAttrHidden      =$00000004;    // volume should not be user-visible.

/************************************************************
 * Date constants (for use with VFSFileGet/SetDate)
 *************************************************************/
  vfsFileDateCreated       =1;
  vfsFileDateModified      =2;
  vfsFileDateAccessed      =3;

/************************************************************
 * Iterator start and stop constants.
 * Used by VFSVolumeEnumerate, VFSDirEntryEnumerate, VFSDirEntryEnumerate
 *************************************************************/
  vfsIteratorStart              =0;
  vfsIteratorStop               =-1; //0xffffffffL


/************************************************************
 * 'handled' field bit constants
 * (for use with Volume Mounted/Unmounted notifications)
 *************************************************************/
  vfsHandledUIAppSwitch =1;         // Any UI app switching has already been handled.
                                    // The VFSMgr will not UIAppSwitch to the start.prc app
                                    // (but it will loaded & sent the AutoStart launchcode),
                                    // and the Launcher will not switch to itself.
  vfsHandledStartPrc    =2;         // And automatic running of start.prc has already been handled.
                                    // VFSMgr will not load it, send it the AutoStart launchcode,
                                    // or UIAppSwitch to it.

/************************************************************
 * Format/Mount flags (for use with VFSVolumeFormat/Mount)
 *************************************************************/
  vfsMountFlagsUseThisFileSystem    =0x01;  // Mount/Format the volume with the filesystem specified
//  vfsMountFlagsPrivate1           =   0x02  // for system use only
//  vfsMountFlagsPrivate2           =   0x04  // for system use only
  vfsMountFlagsReserved1            =0x08;  // reserved
  vfsMountFlagsReserved2            =0x10;  // reserved
  vfsMountFlagsReserved3            =0x20;  // reserved
  vfsMountFlagsReserved4            =0x40;  // reserved
  vfsMountFlagsReserved5            =0x80;  // reserved


/************************************************************
 * Common filesystem types.  Used by FSFilesystemType and SlotCardIsFilesystemSupported.
 *************************************************************/
  vfsFilesystemType_VFAT      ='vfat';      // FAT12 and FAT16 extended to handle long file names
  vfsFilesystemType_FAT       ='fats';      // FAT12 and FAT16 which only handles 8.3 file names
  vfsFilesystemType_NTFS      ='ntfs';      // Windows NT filesystem
  vfsFilesystemType_HFSPlus   ='hfse';      // The Macintosh extended hierarchical filesystem
  vfsFilesystemType_HFS       ='hfss';      // The Macintosh standard hierarchical filesystem
  vfsFilesystemType_MFS       ='mfso';      // The Macintosh original filesystem
  vfsFilesystemType_EXT2      ='ext2';      // Linux filesystem
  vfsFilesystemType_FFS       ='ffsb';      // Unix Berkeley block based filesystem
  vfsFilesystemType_NFS       ='nfsu';      // Unix Networked filesystem
  vfsFilesystemType_AFS       ='afsu';      // Unix Andrew filesystem
  vfsFilesystemType_Novell    ='novl';      // Novell filesystem
  vfsFilesystemType_HPFS      ='hpfs';      // OS2 High Performance filesystem


/************************************************************
 * Error codes
 *************************************************************/
  vfsErrBufferOverflow        =vfsErrorClass | 1;  // passed in buffer is too small
  vfsErrFileGeneric           =vfsErrorClass | 2;  // Generic file error.
  vfsErrFileBadRef            =vfsErrorClass | 3;  // the fileref is invalid (has been closed, or was not obtained from VFSFileOpen())
  vfsErrFileStillOpen         =vfsErrorClass | 4;  // returned from FSFileDelete if the file is still open
  vfsErrFilePermissionDenied  =vfsErrorClass | 5;  // The file is read only
  vfsErrFileAlreadyExists     =vfsErrorClass | 6;  // a file of this name exists already in this location
  vfsErrFileEOF               =vfsErrorClass | 7;  // file pointer is at end of file
  vfsErrFileNotFound          =vfsErrorClass | 8;  // file was not found at the path specified
  vfsErrVolumeBadRef          =vfsErrorClass | 9;  // the volume refnum is invalid.
  vfsErrVolumeStillMounted    =vfsErrorClass | 10; // returned from FSVolumeFormat if the volume is still mounted
  vfsErrNoFileSystem          =vfsErrorClass | 11; // no installed filesystem supports this operation
  vfsErrBadData               =vfsErrorClass | 12; // operation could not be completed because of invalid data (i.e., import DB from .PRC file)
  vfsErrDirNotEmpty           =vfsErrorClass | 13; // can't delete a non-empty directory
  vfsErrBadName               =vfsErrorClass | 14; // invalid filename, or path, or volume label or something...
  vfsErrVolumeFull            =vfsErrorClass | 15; // not enough space left on volume
  vfsErrUnimplemented         =vfsErrorClass | 16; // this call is not implemented
  vfsErrNotADirectory         =vfsErrorClass | 17; // This operation requires a directory
  vfsErrIsADirectory          =vfsErrorClass | 18; // This operation requires a regular file, not a directory
  vfsErrDirectoryNotFound     =vfsErrorClass | 19; // Returned from VFSFileCreate when the path leading up to the new file does not exist
  vfsErrNameShortened         =vfsErrorClass | 20; // A volume name or filename was automatically shortened to conform to filesystem spec

/************************************************************
 * Selectors for routines found in the VFS manager. The order
 * of these selectors MUST match the jump table in VFSMgr.c.
 *************************************************************/
Const
  vfsTrapInit                 =0;
  vfsTrapCustomControl        =1;

  vfsTrapFileCreate           =2;
  vfsTrapFileOpen             =3;
  vfsTrapFileClose            =4;
  vfsTrapFileReadData         =5;
  vfsTrapFileRead             =6;
  vfsTrapFileWrite            =7;
  vfsTrapFileDelete           =8;
  vfsTrapFileRename           =9;
  vfsTrapFileSeek             =10;
  vfsTrapFileEOF              =11;
  vfsTrapFileTell             =12;
  vfsTrapFileResize           =13;
  vfsTrapFileGetAttributes    =14;
  vfsTrapFileSetAttributes    =15;
  vfsTrapFileGetDate          =16;
  vfsTrapFileSetDate          =17;
  vfsTrapFileSize             =18;

  vfsTrapDirCreate            =19;
  vfsTrapDirEntryEnumerate    =20;
  vfsTrapGetDefaultDirectory  =21;
  vfsTrapRegisterDefaultDirectory   =22;
  vfsTrapUnregisterDefaultDirectory =23;

  vfsTrapVolumeFormat         =24;
  vfsTrapVolumeMount          =25;
  vfsTrapVolumeUnmount        =26;
  vfsTrapVolumeEnumerate      =27;
  vfsTrapVolumeInfo           =28;
  vfsTrapVolumeGetLabel       =29;
  vfsTrapVolumeSetLabel       =30;
  vfsTrapVolumeSize           =31;

  vfsTrapInstallFSLib         =32;
  vfsTrapRemoveFSLib          =33;
  vfsTrapImportDatabaseFromFile  =34;
  vfsTrapExportDatabaseToFile    =35;
  vfsTrapFileDBGetResource    =36;
  vfsTrapFileDBInfo           =37;
  vfsTrapFileDBGetRecord      =38;

  vfsTrapImportDatabaseFromFileCustom  =39;
  vfsTrapExportDatabaseToFileCustom    =40;

  // System use only
  vfsTrapPrivate1             =41;

  vfsMaxSelector              =vfsTrapPrivate1;


(* SKIPPED
typedef Err (*VFSImportProcPtr)
            (UInt32 totalBytes, UInt32 offset, void *userDataP);
typedef Err (*VFSExportProcPtr)
            (UInt32 totalBytes, UInt32 offset, void *userDataP);
(****)

Function VFSInit: Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapInit);

// if you pass NULL for fsCreator, VFS will iterate through
// all installed filesystems until it finds one that does not return an error.
Function VFSCustomControl(fsCreator: UInt32; apiCreator: UInt32; apiSelector: UInt16;
                          valueP: Pointer; var valueLenP: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapCustomControl);

Function VFSFileCreate(volRefNum: UInt16; pathNameP: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileCreate);

Function VFSFileOpen(volRefNum: UInt16; pathNameP: String;
   openMode: UInt16; var fileRefP: FileRef): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileOpen);

Function VFSFileClose(fileRef_: FileRef): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileClose);

Function VFSFileReadData(fileRef_: FileRef; numBytes: UInt32; bufBaseP: Pointer;
                  offset: UInt32; var numBytesReadP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileReadData);

Function VFSFileRead(fileRef_: FileRef; numBytes: UInt32; bufP: Pointer; var numBytesReadP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileRead);

Function VFSFileWrite(fileRef_: FileRef; numBytes: UInt32; dataP: Pointer; var numBytesWrittenP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileWrite);

// some file routines work on directories
Function VFSFileDelete(volRefNum: UInt16; pathNameP: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileDelete);

Function VFSFileRename(volRefNum: UInt16; pathNameP: String; newNameP: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileRename);

Function VFSFileSeek(fileRef_: FileRef; origin: FileOrigin; offset: Int32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileSeek);

Function VFSFileEOF(fileRef_: FileRef): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileEOF);

Function VFSFileTell(fileRef_: FileRef; var filePosP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileTell);

Function VFSFileSize(fileRef_: FileRef; var fileSizeP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileSize);

Function VFSFileResize(fileRef_: FileRef; newSize: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileResize);

Function VFSFileGetAttributes(fileRef_: FileRef; var attributesP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileGetAttributes);

Function VFSFileSetAttributes(fileRef_: FileRef; attributes: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileSetAttributes);

Function VFSFileGetDate(fileRef_: FileRef; whichDate: UInt16; var dateP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileGetDate);

Function VFSFileSetDate(fileRef_: FileRef; whichDate: UInt16; date: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileSetDate);


Function VFSDirCreate(volRefNum: UInt16; dirNameP: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapDirCreate);

Function VFSDirEntryEnumerate(dirRef: FileRef; var dirEntryIteratorP: UInt32; var infoP: FileInfoType): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapDirEntryEnumerate);


Function VFSGetDefaultDirectory(volRefNum: UInt16; fileTypeStr: String; 
         pathStr: PChar; var bufLenP: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapGetDefaultDirectory);

Function VFSRegisterDefaultDirectory(fileTypeStr: String; mediaType: UInt32;
         pathStr: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapRegisterDefaultDirectory);

Function VFSUnregisterDefaultDirectory(fileTypeStr: String;  mediaType: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapUnregisterDefaultDirectory);



Function VFSVolumeFormat(flags: UInt8; fsLibRefNum: UInt16; vfsMountParamP: VFSAnyMountParamPtr): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeFormat);

Function VFSVolumeMount(flags: UInt8; fsLibRefNum: UInt16; vfsMountParamP: VFSAnyMountParamPtr): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeMount);

Function VFSVolumeUnmount(volRefNum: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeUnmount);


Function VFSVolumeEnumerate(var volRefNumP: UInt16; var volIteratorP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeEnumerate);

Function VFSVolumeInfo(volRefNum: UInt16; var volInfoP: VolumeInfoType): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeInfo);

Function VFSVolumeGetLabel(volRefNum: UInt16; labelP: String; bufLen: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeGetLabel);

Function VFSVolumeSetLabel(volRefNum: UInt16; labelP: String): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeSetLabel);

Function VFSVolumeSize(volRefNum: UInt16; var volumeUsedP, volumeTotalP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapVolumeSize);

Function VFSInstallFSLib(creator: UInt32; var fsLibRefNumP: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapInstallFSLib);

Function VFSRemoveFSLib(fsLibRefNum: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapRemoveFSLib);

Function VFSImportDatabaseFromFile(volRefNum: UInt16; pathNameP: String;
                     var cardNoP: UInt16;  var dbIDP: LocalID): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapImportDatabaseFromFile);

Function VFSImportDatabaseFromFileCustom(volRefNum: UInt16; pathNameP: String; 
                     var cardNoP: UInt16; var dbIDP: LocalID;
                     importProcP: Pointer; //VFSImportProcPtr;
                     userDataP: Pointer): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapImportDatabaseFromFileCustom);

Function VFSExportDatabaseToFile(volRefNum: UInt16; pathNameP: String;
                     cardNo: UInt16; dbID: LocalID): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapExportDatabaseToFile);

Function VFSExportDatabaseToFileCustom(volRefNum: UInt16; pathNameP: String;
                     cardNo: UInt16; dbID: LocalID;
                     exportProcP: Pointer; //VFSExportProcPtr;
                     userDataP: Pointer): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapExportDatabaseToFileCustom);

Function VFSFileDBGetResource(ref: FileRef; type_: DmResType; resID: DmResID; var resHP: MemHandle): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileDBGetResource);

Function VFSFileDBInfo(ref: FileRef; nameP: String;
               var attributesP: UInt16; 
               var versionP: UInt16; 
               var crDateP: UInt32; 
               var modDateP: UInt32; 
               var bckUpDateP: UInt32; 
               var modNumP: UInt32; 
               var appInfoHP: MemHandle; 
               var sortInfoHP: MemHandle; 
               var typeP: UInt32; 
               var creatorP: UInt32; 
               var numRecordsP: UInt16): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileDBInfo);

Function VFSFileDBGetRecord(ref: FileRef; recIndex: UInt16;
                            var recHP: MemHandle; 
                           var recAttrP: UInt8;
                           var uniqueIDP: UInt32): Err;
      SYS_TRAP(sysTrapVFSMgr,vfsTrapFileDBGetRecord);

Implementation

end.

