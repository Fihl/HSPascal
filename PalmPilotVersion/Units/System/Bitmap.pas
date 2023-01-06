/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Bitmap.h
 *
 * Description:
 *        This file defines bitmap structures and routines.
 *
 * History:
 *    September, 1999   Created by Bertrand Simon
 *       Name  Date     Description
 *       ----  ----     -----------
 *       BS    9/99     Create
 *       jmp   12/23/99 Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Bitmap;

interface

{$ifdef PalmVer35} Uses Traps35; {$endif}

//-----------------------------------------------
// The Bitmap Structure.
//-----------------------------------------------

Const // bitmap version numbers
  BitmapVersionZero = 0;
  BitmapVersionOne  = 1;
  BitmapVersionTwo  = 2;

Type // Compression Types for BitMap BitmapVersionTwo.
  BitmapCompressionType= (
    BitmapCompressionTypeScanLine = 0,
    BitmapCompressionTypeRLE,
    BitmapCompressionTypeNone = 0xFF
  );

  BitmapFlagsType= Record
    Flags16: UInt16
    // compressed:1;          // Data format:  0=raw; 1=compressed
    // hasColorTable:1;       // if true, color table stored before bits[]
    // hasTransparency:1;     // true if transparency is used
    // indirect:1;         // true if bits are stored indirectly
    // forScreen:1;        // system use only
  end;

  BitmapPtr= ^BitmapType;
  BitmapType= Record // this definition correspond to the 'Tbmp' and 'tAIB' resource types
    width: Int16;
    height: Int16;
    rowBytes: UInt16;
    flags: BitmapFlagsType;
    pixelSize: UInt8;         // bits/pixel
    version: UInt8;           // version of bitmap. This is vers 2
    nextDepthOffset: UInt16;  // # of DWords to next BitmapType
                                //  from beginnning of this one
    transparentIndex: UInt8;  // v2 only, if flags.hasTransparency is true,
            // index number of transparent color
    compressionType: UInt8;   // v2 only, if flags.compressed is true, this is
            // the type, see BitmapCompressionType

    reserved: UInt16;           // for future use, must be zero!
  end;
   // [colorTableType] pixels | pixels*
   // If hasColorTable != 0, we have:
   //   ColorTableType followed by pixels.
   // If hasColorTable == 0:
   //   this is the start of the pixels
   // if indirect != 0 bits are stored indirectly.
   //   the address of bits is stored here
   //   In some cases the ColorTableType will
   //   have 0 entries and be 2 bytes long.


// This is the structure of a color table. It maps pixel values into
//  RGB colors. Each element in the table corresponds to the next
//  index, starting at 0.

  RGBColorType= Record
    index,    // index of color or best match to cur CLUT or unused.
    r,        // amount of red, 0->255
    g,        // amount of green, 0->255
    b: UInt8  // amount of blue, 0->255
  end;

  ColorTablePtr= ^ColorTableType;
  ColorTableType= Record
    // high bits(numEntries > 256) reserved
    numEntries: UInt16;    // number of entries in table
    // entry[]: RGBColorType; // array 0..numEntries-1 of colors
  end;

// get start of color table entries aray given pointer to ColorTableType
//Function ColorTableEntries(var ct: ColorTableType)((RGBColorType *)((ColorTableType *)(ctP)+1))

// Bitmap management

{$ifdef PalmVer35}
Function BmpCreate(width, height: Coord; depth: UInt8;
   var colortable: ColorTableType; var error: UInt16): BitmapPtr;
  CDECL; SYS_TRAP(sysTrapBmpCreate);

Function BmpDelete(var bitmapP: BitmapType): Err; CDECL; SYS_TRAP(sysTrapBmpDelete);

Function BmpCompress(var bitmapP: BitmapType; compType: BitmapCompressionType): Err;
  CDECL; SYS_TRAP(sysTrapBmpCompress);

Function BmpGetBits(var bitmapP: BitmapType): Pointer;
  CDECL; SYS_TRAP(sysTrapBmpGetBits);

Function BmpGetColortable(var bitmapP: BitmapType): ColorTablePtr;
  CDECL; SYS_TRAP(sysTrapBmpGetColortable);

Function BmpSize(var bitmapP: BitmapType): UInt16; CDECL; SYS_TRAP(sysTrapBmpSize);

Function BmpBitsSize(var bitmapP: BitmapType): UInt16; CDECL; SYS_TRAP(sysTrapBmpBitsSize);

Function BmpColortableSize(var bitmapP: BitmapType): UInt16; CDECL; SYS_TRAP(sysTrapBmpColortableSize);
{$endif}

implementation

end.
