/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ClipBoard.h
 *
 * Description:
 *        This file defines clipboard structures and routines.
 *
 * History:
 *              September 1, 1994       Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Clipboard;

interface

{$ifdef PalmVer35} Uses Traps33; {$endif}


Const
  numClipboardFormats   =3;
  cbdMaxTextLength      =1000;

// Clipboard standard formats
Type
  clipboardFormats = (clipboardText, clipboardInk, clipboardBitmap);

  ClipboardFormatType = clipboardFormats;

  ClipboardItem = Record
    item: MemHandle;
    length: UInt16
  end;

//----------------------------------------------------------
// Clipboard Functions
//----------------------------------------------------------

Procedure ClipboardAddItem(format: ClipboardFormatType; var ptr; length: UInt16);
                     SYS_TRAP(sysTrapClipboardAddItem);

{$ifdef PalmVer35}
Function ClipboardAppendItem(format: ClipboardFormatType; var ptr; var length: UInt16): Err;
                     SYS_TRAP(sysTrapClipboardAppendItem);
{$endif}

Function ClipboardGetItem(format: ClipboardFormatType; var length: UInt16): MemHandle;
                     SYS_TRAP(sysTrapClipboardGetItem);

implementation

end.

