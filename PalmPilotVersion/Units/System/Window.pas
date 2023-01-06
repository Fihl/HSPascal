/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Window.h
 *
 * Description:
 *        This file defines window structures and routines that support color.
 *
 * History:
 *    January 20, 1999  Created by Bob Ebert
 *       Name  Date     Description
 *       ----  ----     -----------
 *       bob   1/20/99  Branch off WindowNew.h
 *       BS    4/20/99  Re-design of the screen driver
 *       bob   5/26/99  Cleanup/reorg
 *       jmp   12/23/99 Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

unit Window;

{xx$define PalmVer30}
{xx$define PalmVer31}
{xx$define PalmVer33}
{xx$define PalmVer35}

interface

Uses Font, Rect, Bitmap, Traps30,Traps31,Traps33,Traps35;
  
Type
  // enum for WinScrollRectangle
  WinDirectionType= (winUp = 0, winDown, winLeft, winRight);

  // enum for WinCreateOffscreenWindow
  WindowFormatType= (screenFormat = 0, genericFormat);

  // enum for WinLockScreen
  WinLockInitType= (winLockCopy, winLockErase, winLockDontCare);

  // operations for the WinScreenMode function
  WinScreenModeOperation=(
   winScreenModeGetDefaults,
   winScreenModeGet,
   winScreenModeSetToDefaults,
   winScreenModeSet,
   winScreenModeGetSupportedDepths,
   winScreenModeGetSupportsColor);

Const // Operations for the WinPalette function
  winPaletteGet          = 0;
  winPaletteSet          = 1;
  winPaletteSetToDefault = 2;

Type

  // transfer modes for color drawing
  WinDrawOperation= (winPaint, winErase, winMask, winInvert, winOverlay, winPaintInverse);

  PatternType= (blackPattern, whitePattern, grayPattern, customPattern);

Const
  noPattern            = blackPattern;
  grayHLinePattern     = 0xAA;
  grayHLinePatternOdd  = 0x55;

Type
  // grayUnderline means dotted current foreground color
  // solidUnderline means solid current foreground color
  // colorUnderline redundant, use solidUnderline instead
  UnderlineModeType= (noUnderline, grayUnderline, solidUnderline, colorUnderline);

Const
  WinMaxSupportedDepth  = 8;
  WinNumSupportedColors = 4;

Type
  IndexedColorType = UInt8;             // 1-, 2-, 4-, or 8-bit index
  CustomPatternType= Array[0..7] of UInt8; // 8x8 1-bit deep pattern

  // for WinPalette startIndex value, respect indexes in passed table
Const
  WinUseTableIndexes= -1;

//-----------------------------------------------
// Draw state structures.
//-----------------------------------------------

Type
  DrawStateTypePtr= ^DrawStateType;
  DrawStateType= Record
    transferMode: WinDrawOperation;
    pattern: PatternType;
    underlineMode: UnderlineModeType;
    fontId: eFontID; //Cannot use FontID!
    font: FontPtr;
    patternData: CustomPatternType;
    foreColor: IndexedColorType;
    backColor: IndexedColorType;
    textColor: IndexedColorType;
  end;

Const DrawStateStackSize = 5;           // enough for a control in a field in a window

//-----------------------------------------------
// The Window Structures.
//-----------------------------------------------

Type
  FrameBitsType= Record
    Bits: UInt16;
    //cornerDiam    : 8;     // corner diameter, max 38
    //reserved_3    : 3;
    //threeD        : 1;   // Draw 3D button
    //shadowWidth   : 2;   // Width of shadow
    //width         : 2;   // Width frame
    word: UInt16; // IMPORTANT: INITIALIZE word to zero before setting bits!
  end;

  FrameType= UInt16;

  //  Standard Frame Types
Const
  noFrame         = 0;
  simpleFrame     = 1;
  rectangleFrame  = 1;
  simple3DFrame   = 0x0012;          // 3d, frame = 2
  roundFrame      = 0x0401;          // corner = 7, frame = 1
  boldRoundFrame  = 0x0702;          // corner = 7, frame = 2
  popupFrame      = 0x0205;          // corner = 2,  frame = 1, shadow = 1
  dialogFrame     = 0x0302;          // corner = 3,  frame = 2
  menuFrame       = popupFrame;

  winDefaultDepthFlag = 0xFF;

Type
  WindowFlagsType= Record
    Bits: UInt16;
    //format:1;      // window format:  0=screen mode; 1=generic mode
    //offscreen:1;   // offscreen flag: 0=onscreen;  1=offscreen
    //modal:1;       // modal flag:     0=modeless window; 1=modal window
    //focusable:1;   // focusable flag: 0=non-focusable; 1=focusable
    //enabled:1;     // enabled flag:   0=disabled; 1=enabled
    //visible:1;     // visible flag:   0-invisible; 1=visible
    //dialog:1;      // dialog flag:    0=non-dialog; 1=dialog
    //reserved :9;
  end;

  WindowTypePtr= ^WindowType;
  WinPtr = ^WindowType;
  WinHandle = ^WindowType;

  WindowType= Record
    displayWidthV20: Coord;      // use WinGetDisplayExtent instead
    displayHeightV20: Coord;     // use WinGetDisplayExtent instead
    displayAddrV20: Pointer;     // use the drawing functions instead
    windowFlags: WindowFlagsType;
    windowBounds: RectangleType;
    clippingBounds: AbsRectType;
    bitmapP: BitmapPtr;
    frameType: FrameBitsType;
    drawStateP: DrawStateTypePtr;   // was GraphicStatePtr
    nextWindow: WinPtr; 
  end;


//-----------------------------------------------
//  More graphics shapes
//-----------------------------------------------
Type
  WinLineType= Record
    x1, y1, x2, y2: Coord
  end;

  WinPolygonType= Record
    numPoints: UInt16;
    points: array[0..0] of PointType  // extensible
  end;

  WinArcType= Record
    bounds: RectangleType;
    start: Int16;
    stop:  Int16;
  end;


//-----------------------------------------------
//  Low Memory Globals
//-----------------------------------------------

// This is the structure of a low memory global reserved for the Window Manager
// In GRAPHIC_VERSION_2, it held a single drawing state.  In this version, it
// holds stack information for structures that are allocated from the dynamic heap
Type
  GraphicStateType= Record
    drawStateP: DrawStateTypePtr;
    drawStateStackP: DrawStateTypePtr;
    drawStateIndex: Int16;
    screenLockCount: UInt16;
  end;

// ----------------------
// Window manager errors
// ----------------------
//Const winErrPalette= winErrorClass or 1; //Use winErrorClass from ErrorBase!


//-----------------------------------------------
//  Macros
//-----------------------------------------------

// For now, the window handle is a pointer to a window structure,
// this however may change, so use the following macros.

Type
  WinGetWindowPointer= WindowTypePtr;
  WinGetWindowHandle= WinHandle;


//-----------------------------------------------
// Routines relating to windows management
//-----------------------------------------------

{$ifdef PalmVer30}
Function WinValidateHandle(winHandleX: WinHandle): Boolean;
  CDECL; SYS_TRAP(sysTrapWinValidateHandle);
{$endif}

Function WinCreateWindow(var bounds: RectangleType; frame: FrameType;
   model, focusable: Boolean; var error: UInt16): WinHandle;
  CDECL; SYS_TRAP(sysTrapWinCreateWindow);

Function WinCreateOffscreenWindow(width, height: Coord;
   format: WindowFormatType; var error: UInt16): Winhandle;
  CDECL; SYS_TRAP(sysTrapWinCreateOffscreenWindow);

{$ifdef PalmVer35}
Function WinCreateBitmapWindow(var bitmapP: BitmapType; var error: UInt16): WinHandle;
  CDECL; SYS_TRAP(sysTrapWinCreateBitmapWindow);
{$endif}

Procedure WinDeleteWindow(winHandleX: WinHandle; eraseIt: Boolean);
  CDECL; SYS_TRAP(sysTrapWinDeleteWindow);

Procedure WinInitializeWindow(winHandleX: WinHandle);
  CDECL; SYS_TRAP(sysTrapWinInitializeWindow);

Procedure WinAddWindow(winHandleX: WinHandle);
  CDECL; SYS_TRAP(sysTrapWinAddWindow);

Procedure WinRemoveWindow(winHandleX: WinHandle);
  CDECL; SYS_TRAP(sysTrapWinRemoveWindow);

Procedure WinMoveWindowAddr(var oldLocationP, newLocationP: WindowType);
  CDECL; SYS_TRAP(sysTrapWinMoveWindowAddr);

Procedure WinSetActiveWindow(winHandleX: WinHandle);
  CDECL; SYS_TRAP(sysTrapWinSetActiveWindow);

Function WinSetDrawWindow(winHandleX: WinHandle): WinHandle;
  CDECL; SYS_TRAP(sysTrapWinSetDrawWindow);

Function WinGetDrawWindow: WinHandle; CDECL; SYS_TRAP(sysTrapWinGetDrawWindow);

Function WinGetActiveWindow: WinHandle; CDECL; SYS_TRAP(sysTrapWinGetActiveWindow);

Function WinGetDisplayWindow: WinHandle; CDECL; SYS_TRAP(sysTrapWinGetDisplayWindow);

Function WinGetFirstWindow: WinHandle; CDECL; SYS_TRAP(sysTrapWinGetFirstWindow);

Procedure WinEnableWindow(winHandleX: WinHandle); CDECL; SYS_TRAP(sysTrapWinEnableWindow);

Procedure WinDisableWindow(winHandleX: WinHandle); CDECL; SYS_TRAP(sysTrapWinDisableWindow);

Procedure WinGetWindowFrameRect(winHandleX: WinHandle; var r: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinGetWindowFrameRect);

Procedure WinDrawWindowFrame; CDECL; SYS_TRAP(sysTrapWinDrawWindowFrame);

Procedure WinEraseWindow; CDECL; SYS_TRAP(sysTrapWinEraseWindow);

Function WinSaveBits(var source: RectangleType; var error: UInt16): WinHandle;
  CDECL; SYS_TRAP(sysTrapWinSaveBits);

Procedure WinRestoreBits(winHandleX: WinHandle; destX, destY: Coord);
  CDECL; SYS_TRAP(sysTrapWinRestoreBits);

Procedure WinCopyRectangle(srcWin, dstWin: WinHandle;
   var srcRect: RectangleType; destX, destY: Coord;
        mode: WinDrawOperation);
  CDECL; SYS_TRAP(sysTrapWinCopyRectangle);

Procedure WinScrollRectangle(var rP: RectangleType;
        direction: WinDirectionType;
   distance: Coord; var vacatedP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinScrollRectangle);

Procedure WinGetDisplayExtent(var extentX, extentY: Coord);
  CDECL; SYS_TRAP(sysTrapWinGetDisplayExtent);

Procedure WinGetWindowBounds(var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinGetWindowBounds);

Procedure WinSetWindowBounds(winHandleX: WinHandle; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinSetWindowBounds);

Procedure WinGetWindowExtent(var extentX, extentY: Coord);
  CDECL; SYS_TRAP(sysTrapWinGetWindowExtent);

Procedure WinDisplayToWindowPt(var extentX, extentY: Coord); CDECL; SYS_TRAP(sysTrapWinDisplayToWindowPt);

Procedure WinWindowToDisplayPt(var extentX, extentY: Coord); CDECL; SYS_TRAP(sysTrapWinWindowToDisplayPt);

Function WinGetBitmap(winHandleX: WinHandle): BitmapPtr; CDECL; SYS_TRAP(sysTrapWinGetBitmap);

Procedure WinGetClip(var rP: RectangleType); CDECL; SYS_TRAP(sysTrapWinGetClip);

Procedure WinSetClip(var rP: RectangleType); CDECL; SYS_TRAP(sysTrapWinSetClip);

Procedure WinResetClip; CDECL; SYS_TRAP(sysTrapWinResetClip);

Procedure WinClipRectangle(var rP: RectangleType); CDECL; SYS_TRAP(sysTrapWinClipRectangle);

Function WinModal(winHandleX: WinHandle): Boolean; CDECL; SYS_TRAP(sysTrapWinModal);

//-----------------------------------------------
// Routines to draw shapes or frames shapes
//-----------------------------------------------

// Pixel(s)
Function WinGetPixel(x,y: Coord): IndexedColorType; CDECL; SYS_TRAP(sysTrapWinGetPixel);

Procedure WinPaintPixel(x,y: Coord); CDECL; SYS_TRAP(sysTrapWinPaintPixel);

Procedure WinDrawPixel(x,y: Coord); CDECL; SYS_TRAP(sysTrapWinDrawPixel);

Procedure WinErasePixel(x,y: Coord); CDECL; SYS_TRAP(sysTrapWinErasePixel);

Procedure WinInvertPixel(x,y: Coord); CDECL; SYS_TRAP(sysTrapWinInvertPixel);

//Procedure WinPaintPixels(numPoints: UInt16; pts[]: PointType);
//  CDECL; SYS_TRAP(sysTrapWinPaintPixels);

// Line(s)
Procedure WinPaintLines(numLines: UInt16; var Lines_WinLineType); CDECL; SYS_TRAP(sysTrapWinPaintLines);

Procedure WinPaintLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinPaintLine);

Procedure WinDrawLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawLine);

Procedure WinDrawGrayLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawGrayLine);

Procedure WinEraseLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinEraseLine);

Procedure WinInvertLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinInvertLine);

Procedure WinFillLine(x1, y1, x2, y2: Coord);
  CDECL; SYS_TRAP(sysTrapWinFillLine);


// Rectangle
Procedure WinPaintRectangle(var rP: RectangleType; cornerDiam: UInt16);
  CDECL; SYS_TRAP(sysTrapWinPaintRectangle);

Procedure WinDrawRectangle(var rP: RectangleType; cornerDiam: UInt16);
  CDECL; SYS_TRAP(sysTrapWinDrawRectangle);

Procedure WinEraseRectangle(var rP: RectangleType; cornerDiam: UInt16);
  CDECL; SYS_TRAP(sysTrapWinEraseRectangle);

Procedure WinInvertRectangle(var rP: RectangleType; cornerDiam: UInt16);
  CDECL; SYS_TRAP(sysTrapWinInvertRectangle);

Procedure WinFillRectangle(var rP: RectangleType; cornerDiam: UInt16);
  CDECL; SYS_TRAP(sysTrapWinFillRectangle);

// Rectangle frames
Procedure WinPaintRectangleFrame(frame: FrameType; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinPaintRectangleFrame);

Procedure WinDrawRectangleFrame(frame: FrameType; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinDrawRectangleFrame);

Procedure WinDrawGrayRectangleFrame(frame: FrameType; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinDrawGrayRectangleFrame);

Procedure WinEraseRectangleFrame(frame: FrameType; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinEraseRectangleFrame);

Procedure WinInvertRectangleFrame(frame: FrameType; var rP: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinInvertRectangleFrame);

Procedure WinGetFramesRectangle(frame: FrameType; var rP: RectangleType;
   var obscuredRect: RectangleType);
  CDECL; SYS_TRAP(sysTrapWinGetFramesRectangle);

// Polygon
Procedure WinPaintPolygon(var pP: WinPolygonType);
  CDECL; SYS_TRAP(sysTrapWinPaintPolygon);

Procedure WinDrawPolygon(var pP: WinPolygonType);
  CDECL; SYS_TRAP(sysTrapWinDrawPolygon);

Procedure WinErasePolygon(var pP: WinPolygonType);
  CDECL; SYS_TRAP(sysTrapWinErasePolygon);

Procedure WinInvertPolygon(var pP: WinPolygonType);
  CDECL; SYS_TRAP(sysTrapWinInvertPolygon);

Procedure WinFillPolygon(var pP: WinPolygonType);
  CDECL; SYS_TRAP(sysTrapWinFillPolygon);


// Arc
Procedure WinPaintArc(var aP: WinArcType); CDECL; SYS_TRAP(sysTrapWinPaintArc);

Procedure WinDrawArc(var aP: WinArcType); CDECL; SYS_TRAP(sysTrapWinDrawArc);

Procedure WinEraseArc(var aP: WinArcType); CDECL; SYS_TRAP(sysTrapWinEraseArc);

Procedure WinInvertArc(var aP: WinArcType); CDECL; SYS_TRAP(sysTrapWinInvertArc);

Procedure WinFillArc(var aP: WinArcType); CDECL; SYS_TRAP(sysTrapWinFillArc);

// Bitmap
Procedure WinDrawBitmap(bitmapP: BitmapPtr; x,y: Coord); CDECL; SYS_TRAP(sysTrapWinDrawBitmap);

Procedure WinPaintBitmap(var bitmapP: BitmapType; x,y: Coord); CDECL; SYS_TRAP(sysTrapWinPaintBitmap);


// Characters
Procedure WinDrawChar(theChar: WChar; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawChar);

Procedure WinDrawChars(Const Chars: String; Len: Int16; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawChars);

Procedure WinPaintChar(theChar: WChar; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinPaintChar);

Procedure WinPaintChars(Const Chars: String; Len: Int16; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinPaintChars);

Procedure WinDrawInvertedChars(Const Chars: String; Len: Int16; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawInvertedChars);

Procedure WinDrawTruncChars(Const Chars: String; Len: Int16; x,y,maxWidth: Coord);
  CDECL; SYS_TRAP(sysTrapWinDrawTruncChars);

Procedure WinEraseChars(Const Chars: String; Len: Int16; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinEraseChars);

Procedure WinInvertChars(Const Chars: String; Len: Int16; x,y: Coord);
  CDECL; SYS_TRAP(sysTrapWinInvertChars);

Function WinSetUnderlineMode(mode: UnderlineModeType): UnderlineModeType;
  CDECL; SYS_TRAP(sysTrapWinSetUnderlineMode);


//-----------------------------------------------
// Routines for patterns and colors
//-----------------------------------------------

// "save" fore, back, text color, pattern, underline mode, font
Procedure WinPushDrawState; CDECL; SYS_TRAP(sysTrapWinPushDrawState);

  // "restore" saved drawing variables
Procedure WinPopDrawState; CDECL; SYS_TRAP(sysTrapWinPopDrawState);


Function WinSetDrawMode(newMode: WinDrawOperation): WinDrawOperation;
  CDECL; SYS_TRAP(sysTrapWinSetDrawMode);


Function  WinSetForeColor(foreColor: IndexedColorType): IndexedColorType;
  CDECL; SYS_TRAP(sysTrapWinSetForeColor);

Function WinSetBackColor(backColor: IndexedColorType): IndexedColorType;
  CDECL; SYS_TRAP(sysTrapWinSetBackColor);

Function WinSetTextColor(textColor: IndexedColorType): IndexedColorType;
  CDECL; SYS_TRAP(sysTrapWinSetTextColor);

// "obsolete" color call, supported for backwards compatibility
Procedure WinSetColors(var newForeColorP, oldForeColorP,
                           newBackColorP, oldBackColorP: RGBColorType);
  CDECL; SYS_TRAP(sysTrapWinSetColors);

Procedure WinGetPattern(var patternP: CustomPatternType);
  CDECL; SYS_TRAP(sysTrapWinGetPattern);

Function  WinGetPatternType: PatternType; CDECL; SYS_TRAP(sysTrapWinGetPatternType);

Procedure WinSetPattern(var patternP: CustomPatternType);
  CDECL; SYS_TRAP(sysTrapWinSetPattern);

Procedure WinSetPatternType(newPattern: PatternType);
  CDECL; SYS_TRAP(sysTrapWinSetPatternType);

Function WinPalette(operation: UInt8; startIndex: Int16;
  paletteEntries: Int16; var tableP: RGBColorType): Err;
  CDECL; SYS_TRAP(sysTrapWinPalette);

Function  WinRGBToIndex(var rgbP: RGBColorType): IndexedColorType;
  CDECL; SYS_TRAP(sysTrapWinRGBToIndex);

Procedure WinIndexToRGB(i: IndexedColorType; var rgbP: RGBColorType);
  CDECL; SYS_TRAP(sysTrapWinIndexToRGB);


//-----------------------------------------------
// New WinScreen functions
//-----------------------------------------------

Procedure WinScreenInit; CDECL; SYS_TRAP(sysTrapWinScreenInit);

Function WinScreenMode(operation: WinScreenModeOperation;
             var widthP, heightP, depthP: UInt32;
                       var enableColorP: Boolean): Err;
  CDECL; SYS_TRAP(sysTrapWinScreenMode);


//-----------------------------------------------
// Screen tracking(double buffering) support
//-----------------------------------------------
Function WinScreenLock(initMode: WinLockInitType): BytePtr;
  CDECL; SYS_TRAP(sysTrapWinScreenLock);

Procedure WinScreenUnlock; CDECL; SYS_TRAP(sysTrapWinScreenUnlock);

implementation

end.
