/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Font.h
 *
 * Description:
 *   This file defines font structures and routines.
 *
 * History:
 *    September 13, 1994   Created by Art Lamb
 *    05/05/98 art   Add structures for font mapping table.
 *    07/03/98 kwk   Added FntWidthToOffset.
 *    10/23/98 kwk   Changed fontMapTable to 0xC000 (was 0xFFFF).
 *    10/20/99 kwk   Moved private values to FontPrv.h
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/
 
Unit Font;

interface

{$ifdef PalmVer31} Uses Traps31, Traps30; {$endif}

// Font types in FontType structure.
Const
  fontMapTable = 0xC000;
  fntTabChrWidth = 20;
  fntMissingChar = -1;

Type
  FontCharInfoPtr = ^FontCharInfo;
  FontCharInfo = Record
    Offset: Int8;
    Width:  Int8;
  end;

  FontTablePtr = ^FontPtr;
  FontPtr = ^FontType;
  FontType= Record
    fontType,        // font type
    firstChar,          // ASCII code of first character
    lastChar,        // ASCII code of last character
    maxWidth,        // maximum character width
    kernMax,         // negative of maximum character kern
    nDescent,        // negative of descent
    fRectWidth,      // width of font rectangle
    fRectHeight,     // height of font rectangle
    owTLoc,             // offset to offset/width table
    ascent,             // ascent
    descent,         // descent
    leading,         // leading
    rowWords: Int16;          // row width of bit image / 2
  End;

  FontIndexEntryPtr = ^FontIndexEntryType;
  FontIndexEntryType= Record
    rscType: UInt32;
    rscID:   UInt16;
  end;

Const  // Font mapping state table.
  fntStateIsChar     = 1;
  fntStateNextIsChar = 2;

Type
  FontMapPtr = ^FontMapType;
  FontMapType= Record
    Flags: UInt8;
    State: UInt8;
    Value: UInt16
  end;

  eFontID=(stdFont = 0x00, // Small font used for the user's writing.  Shows a good amount
    boldFont,     // Small font.  Bold for easier reading.  Used often for ui.
    largeFont,    // Larger font for easier reading.  Shows a lot less.
    symbolFont,      // Various ui images like check boxes and arrows
    symbol11Font,    // Larger various ui images
    symbol7Font,  // Smaller various ui images
    ledFont,      // Calculator specific font
    largeBoldFont,   // A thicker version of the large font.  More readable.
    fntAppFontCustomBase = 0x80);// First available application-defined font ID

  FontID = eFontID;

Const
  checkboxFont = symbol11Font;

Function FntIsAppDefined(fnt: eFontID): Boolean;

Function FntGetFont: FontID; CDECL; SYS_TRAP(sysTrapFntGetFont);
Function FntSetFont(Font: FontID): FontID; CDECL; SYS_TRAP(sysTrapFntSetFont);
Function FntGetFontPtr: FontPtr; CDECL; SYS_TRAP(sysTrapFntGetFontPtr);
Function FntBaseLine: Int16; CDECL; SYS_TRAP(sysTrapFntBaseLine);
Function FntCharHeight: Int16; CDECL; SYS_TRAP(sysTrapFntCharHeight);
Function FntLineHeight: Int16; CDECL; SYS_TRAP(sysTrapFntLineHeight);

Function FntAverageCharWidth: Int16; CDECL; SYS_TRAP(sysTrapFntAverageCharWidth);

Function FntCharWidth(Ch: Char): Int16; CDECL; SYS_TRAP(sysTrapFntCharWidth);

Function FntCharsWidth(Const Chars: String; Len: Int16): Int16;
  CDECL; SYS_TRAP(sysTrapFntCharsWidth);

{$ifdef PalmVer31}
Function FntWidthToOffset(Const Chars: String; Length: UInt16;
   pixelWidth: Int16; var leadingEdge: Boolean; //var or pointer?
   var truncWidth: Int16): Int16;               //var or pointer?
  CDECL; SYS_TRAP(sysTrapFntWidthToOffset);
{$endif}

Procedure FntCharsInWidth(Const Chars: String;
   var stringWidthP,stringLengthP: Int16;
   var fitWithinWidth: Boolean);
  CDECL; SYS_TRAP(sysTrapFntCharsInWidth);

Function FntDescenderHeight: Int16; CDECL; SYS_TRAP(sysTrapFntDescenderHeight);
Function FntLineWidth(Const Chars: String; Length: UInt16): Int16;  CDECL; SYS_TRAP(sysTrapFntLineWidth);
Function FntWordWrap(Const Chars: String; MaxWidth: UInt16): UInt16; CDECL; SYS_TRAP(sysTrapFntWordWrap);

Procedure FntWordWrapReverseNLines(Const Chars: String;
   maxWidth: UInt16; var linesToScrollP, scrollPosP: UInt16);
        CDECL; SYS_TRAP(sysTrapFntWordWrapReverseNLines);

Procedure FntGetScrollValues(Const Chars: String; Width: UInt16;
   scrollPos: UInt16; var linesP, TopLine: UInt16);
        CDECL; SYS_TRAP(sysTrapFntGetScrollValues);

{$ifdef PalmVer31}
Function FntDefineFont(Font: FontID; FontP: FontPtr): Err; CDECL; SYS_TRAP(sysTrapFntDefineFont);
{$endif}

implementation

Function FntIsAppDefined(fnt: eFontID): Boolean;
begin
  FntIsAppDefined:= fnt >= fntAppFontCustomBase;
end;

end.
