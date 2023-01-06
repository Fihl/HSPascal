/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: FileStream.h
 *
 * Description:
 *    Pilot File Stream equates -- File Streams were initially implemented
 *    in PalmOS v3.0 (not available in earlier versions)
 *
 * History:
 *    11/24/97 vmk      - Created by Vitaly Kruglikov 
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit FileStream; //DOLATER;

interface

Uses Traps30, ErrorBase;

/************************************************************
 * File Stream error codes
 * the constant dmErrorClass is defined in ErrorBase.h
 *************************************************************/

Const
  fileErrMemError            =fileErrorClass | 1;  // out of memory error
  fileErrInvalidParam        =fileErrorClass | 2;  // invalid parameter value passed
  fileErrCorruptFile         =fileErrorClass | 3;  // the file is corrupted/invalid/not a stream file
  fileErrNotFound            =fileErrorClass | 4;  // couldn't find the file
  fileErrTypeCreatorMismatch =fileErrorClass | 5;  // file's type and creator didn't match those expected
  fileErrReplaceError        =fileErrorClass | 6;  // couldn't replace an existing file
  fileErrCreateError         =fileErrorClass | 7;  // couldn't create a new file
  fileErrOpenError           =fileErrorClass | 8;  // generic open error
  fileErrInUse               =fileErrorClass | 9;  // file couldn't be opened or deleted because it is in use
  fileErrReadOnly            =fileErrorClass | 10; // couldn't open in write mode because db is read-only
  fileErrInvalidDescriptor   =fileErrorClass | 11; // invalid file descriptor (FileHandle)
  fileErrCloseError          =fileErrorClass | 12; // error closing the database
  fileErrOutOfBounds         =fileErrorClass | 13; // attempted operation went out of bounds of the file
  fileErrPermissionDenied    =fileErrorClass | 14; // couldn't write to a file open for read-only access
  fileErrIOError             =fileErrorClass | 15; // general I/O error
  fileErrEOF                 =fileErrorClass | 16; // end-of-file error
  fileErrNotStream           =fileErrorClass | 17; // attempted to open a file that is not a stream



/************************************************************
 * File Stream handle type
 *************************************************************/
Type FileHand=MemHandle;

Const
  fileNullHandle=NIL;

/************************************************************
 * Mode flags passed to FileOpen
 *************************************************************/

// fileModeReadOnly, fileModeReadWrite, fileModeUpdate, and fileModeAppend are mutually exclusive - only
// pass one of them to FileOpen!
  fileModeReadOnly           =0x80000000;       // open for read access
  fileModeReadWrite          =0x40000000;       // create for read/write access, discarding previous if any */
  fileModeUpdate             =0x20000000;       // open/create for read/write, preserving previous if any
  fileModeAppend             =0x10000000;       // open/create for read/write, always writing at the end

  fileModeLeaveOpen          =0x08000000;       // leave open when app quits
  fileModeExclusive          =0x04000000;       // don't let anyone else open it
  fileModeAnyTypeCreator     =0x02000000;       // if set, skip type/creator validation when
                                                         // opening or replacing an existing file

  fileModeTemporary          =0x01000000;       // will automatically delete the file when it is closed;
                                                         // if this bit is set and the file type passed to FileOpen is zero,
                                                         // FileOpen will use sysFileTTemp (defined in SystemResources.h for the file
                                                         // type (recommended) - this will enable automatic cleanup of undeleted
                                                         // temp files following a system crash in future PalmOS versions
                                                         // (post-crash cleanup will likely come after 3.0)

  fileModeDontOverwrite      =0x00800000;       // if set, will prevent fileModeReadWrite from discarding an existing file
                                                         // with the same name; may only be specified together with fileModeReadWrite

// For debugging/validation
  fileModeAllFlags = fileModeReadOnly  |
                     fileModeReadWrite |
                     fileModeUpdate    |
                     fileModeAppend    |
                     fileModeLeaveOpen |
                     fileModeExclusive |
                     fileModeAnyTypeCreator |
                     fileModeTemporary |
                     fileModeDontOverwrite;

/************************************************************
 * Origin passed to FileSetPos
 *************************************************************/
Type
  FileOriginEnum = (

   fileOriginBeginning  = 1,        // from the beginning (first data byte of file)
   fileOriginCurrent,               // from the current position
   fileOriginEnd);                  // from the end of file (one position beyond last data byte)


/************************************************************
 * Operation passed to FileControl
 *************************************************************/
  FileOpEnum = (
   fileOpNone = 0,                  // no-op

   fileOpDestructiveReadMode,       // switch to destructive read mode (there is no turning back);
                                    // implicitly rewinds the file to the beginning;
                                    // destructive read mode deletes file stream data blocks as
                                    // data is being read, thus freeing up storage automatically;
                                    // once in destructive read mode, FileWrite, FileSeek and FileTruncate
                                    // are not allowed; stream's contents after closing (or crash)
                                    // are undefined.
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    zero on success; fileErr... on error

   fileOpGetEOFStatus,              // get end-of-file status (err = fileErrEOF indicates end of file condition);
                                    // use FileClearerr to clear this error status
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    zero if _not_ end of file; non-zero if end of file

   fileOpGetLastError,              // get error code from last operation on file stream, and
                                    // clear the last error code value (will not change end of file
                                    // or I/O error status -- use FileClearerr to reset all error codes)
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    Error code from last file stream operation

   fileOpClearError,                // clear I/O and end of file error status, and last error
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    zero on success; fileErr... on error

   fileOpGetIOErrorStatus,          // get I/O error status (like C runtime's ferror); use FileClearerr
                                    // to clear this error status
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    zero if _not_ I/O error; non-zero if I/O error is pending

   fileOpGetCreatedStatus,          // find out whether the FileOpen call caused the file to
                                    // be created
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = ptr to Boolean type variable
                                    //    valueLenP = ptr to Int32 variable set to sizeof(Boolean)
                                    // RETURNS:
                                    //    zero on success; fileErr... on error;
                                    //    the Boolean variable will be set to non zero if the file was created.

   fileOpGetOpenDbRef,              // get the open database reference (handle) of the underlying
                                    // database that implements the stream (NULL if none);
                                    // this is needed for performing PalmOS-specific operations on
                                    // the underlying database, such as changing or getting creator/type,
                                    // version, backup/reset bits, etc.
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = ptr to DmOpenRef type variable
                                    //    valueLenP = ptr to Int32 variable set to sizeof(DmOpenRef)
                                    // RETURNS:
                                    //    zero on success; fileErr... on error;
                                    //    the DmOpenRef variable will be set to the file's open db reference
                                    //    that may be passed to Data Manager calls;
                                    // WARNING:
                                    //    Do not make any changes to the data of the underlying database --
                                    //    this will cause the file stream to become corrupted.

   fileOpFlush,                     // flush any cached data to storage
                                    // ARGUMENTS:
                                    //    stream = open stream handle
                                    //    valueP = NULL
                                    //    valueLenP = NULL
                                    // RETURNS:
                                    //    zero on success; fileErr... on error;




   fileOpLAST                       // ***ADD NEW OPERATIONS BEFORE THIS ENTRY***
                                    // ***  AND ALWAYS AFTER EXISTING ENTRIES ***
                                    // ***     FOR BACKWARD COMPATIBILITY     ***
   );


/************************************************************
 * File Stream procedures
 *************************************************************/

// Open/create a file stream (name must all be valid -- non-null, non-empty)
// (errP is optional - set to NULL to ignore)
Function FileOpen(cardNo: UInt16; nameP: PChar; type_: UInt32; creator: UInt32;
   openMode: UInt32; var errP: Err): FileHand;
                     SYS_TRAP(sysTrapFileOpen);
//New better version Function FileOpen(cardNo: UInt16; Const nameP: String; 
//                       typ,creator,openmode: UInt32; var errP: Err): FileHand; SYS_TRAP(sysTrapFileOpen);

// Close the file stream
Function FileClose(stream: FileHand): Err;
                     SYS_TRAP(sysTrapFileClose);

// Delete a file
Function FileDelete(cardNo: UInt16; nameP: PChar): Err;
                     SYS_TRAP(sysTrapFileDelete);


// Low-level routine for reading data from a file stream -- use helper macros FileRead and FileDmRead
// instead of calling this function directly;
// (errP is optional - set to NULL to ignore)
Function FileReadLow(stream: FileHand; baseP: Pointer; offset: Int32; dataStoreBased: Boolean; objSize: Int32;
   numObj: Int32; var errP: Err): Int32;
                     SYS_TRAP(sysTrapFileReadLow);

/***********************************************************************
 *
 * MACRO:      FileRead
 *
 * DESCRIPTION:   Read data from a file into a buffer.  If you need to read into a data storage
 *                heap-based chunk, record or resource, you _must_ use FileDmRead instead.
 *
 * PROTOTYPE:  Int32 FileRead(FileHand stream, void * bufP, Int32 objSize, Int32 numObj, var errP: Err)
 *
 * PARAMETERS: stream      -- handle of open file
 *             bufP        -- buffer for reading data
 *             objSize     -- size of each object to read
 *             numObj      -- number of objects to read
 *             errP        -- ptr to variable for returning the error code (fileErr...)
 *                            (OPTIONAL -- pass NULL to ignore)
 *
 * RETURNED:   the number of objects that were read - this may be less than
 *             the number of objects requested
 *
 ***********************************************************************/
Function FileRead(stream: FileHand; bufP: Pointer; objSize, numObj: Int32; var errP: Err): Int32;


/***********************************************************************
 *
 * MACRO:      FileDmRead
 *
 * DESCRIPTION:   Read data from a file into a data storage heap-based chunk, record
 *                or resource.
 *
 * PROTOTYPE:  Int32 FileDmRead(FileHand stream, void * startOfDmChunkP, Int32 destOffset,
 *                   Int32 objSize, Int32 numObj, var errP: Err)
 *
 * PARAMETERS: stream      -- handle of open file
 *             startOfDmChunkP
 *                         -- ptr to beginning of data storage heap-based chunk, record or resource
 *             destOffset  -- offset from base ptr to the destination area (must be >= 0)
 *             objSize     -- size of each object to read
 *             numObj      -- number of objects to read
 *             errP        -- ptr to variable for returning the error code (fileErr...)
 *                            (OPTIONAL -- pass NULL to ignore)
 *
 * RETURNED:   the number of objects that were read - this may be less than
 *             the number of objects requested
 *
 ***********************************************************************/
Function FileDmRead(stream: FileHand; startOfDmChunkP: Pointer; destOffset, objSize, numObj: Int32; var errP: Err): Int32;


// Write data to a file stream
// (errP is optional - set to NULL to ignore)
Function FileWrite(stream: FileHand; dataP: Pointer; objSize: Int32; numObj: Int32; var errP: Err): Int32;
                     SYS_TRAP(sysTrapFileWrite);

// Set position within a file stream
Function FileSeek(stream: FileHand; offset: Int32; origin: FileOriginEnum): Err;
                     SYS_TRAP(sysTrapFileSeek);

Procedure FileRewind(stream: FileHand);

// Get current position and filesize
// (fileSizeP and errP are optional - set to NULL to ignore)
Function FileTell(stream: FileHand; var fileSizeP: Int32; var errP: Err): Int32;
                     SYS_TRAP(sysTrapFileTell);

// Truncate a file
Function FileTruncate(stream: FileHand; newSize: Int32): Err;
                     SYS_TRAP(sysTrapFileTruncate);

// Returns the error code from the last operation on this file stream;
// if resetLastError is non-zero, resets the error status
Function FileControl(op: FileOpEnum; stream: FileHand; valueP: Pointer; var valueLenP: Int32): Err;
                     SYS_TRAP(sysTrapFileControl);

Function  FileEOF(stream: FileHand): Boolean;
Procedure FileError(stream: FileHand);
Procedure FileClearErr(stream: FileHand);
Procedure FileGetLastError(stream: FileHand);
Procedure FileFlush(stream: FileHand);

implementation

Function FileRead(stream: FileHand; bufP: Pointer; objSize, numObj: Int32; var errP: Err): Int32;
begin
  FileRead:=FileReadLow(stream, bufP, 0/*offset*/, false/*dataStoreBased*/, objSize, numObj, errP)
end;

Function FileDmRead(stream: FileHand; startOfDmChunkP: Pointer; destOffset, objSize, numObj: Int32; var errP: Err): Int32;
begin
  FileDmRead:=FileReadLow(stream, startOfDmChunkP, destOffset, true/*dataStoreBased*/, objSize, numObj, errP);
end;

Procedure FileRewind(stream: FileHand);
var Err: Integer;
begin
  FileClearerr(stream);
  Err:=FileSeek(stream, 0, fileOriginBeginning);
end;

Function FileEOF(stream: FileHand): Boolean;
begin
  FileEOF := FileControl(fileOpGetEOFStatus, stream, NIL, PInt32(NIL)^) = fileErrEOF
end;

Procedure FileError(stream: FileHand);
var Err: Integer;
begin
  Err:=FileControl(fileOpGetIOErrorStatus, stream, NIL, PInt32(NIL)^)
end;

Procedure FileClearErr(stream: FileHand);
var Err: Integer;
begin
  Err:=FileControl(fileOpClearError, stream, NIL, PInt32(NIL)^)
end;

Procedure FileGetLastError(stream: FileHand);
var Err: Integer;
begin
  Err:=FileControl(fileOpGetLastError, stream, NIL, PInt32(NIL)^)
end;

Procedure FileFlush(stream: FileHand);
var Err: Integer;
begin
  Err:=FileControl(fileOpFlush, stream, NIL, PInt32(NIL)^)
end;

end.

