/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Graffiti.h
 *
 * Description:
 *    Header for the Graffiti interface
 *
 * History:
 *    6/30  RM - Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Graffiti;

interface

Uses ErrorBase, Rect;

Const
  grfNoShortCut = 0xffff;      // Index which isn't a shortcut

/*------------------------------------------------------------------------------
 * Match info structure. Returned by GrfMatch and GrfMatchGlyph
 *-----------------------------------------------------------------------------*/
Type
  GrfMatchType = Record
    glyphID: UInt8;                   /* glyph ID of this match */
    unCertainty: UInt8;               /* unCertainty of this match (0 most certain) */
  end;


Const
  grfMaxMatches   =4;
Type
  GrfMatchInfoPtr = ^GrfMatchInfoType;
  GrfMatchInfoType = Record
    numMatches: UInt16            ;       /* number of matches returned in this structure */
    match: Array[0..grfMaxMatches-1] of GrfMatchType   ;
  end;

Const
  grfNameLength   =8;           // eight letters possible (don't forget CR)
  //grfTextLength =56;          // Use <SysEvtPrv.h>

//----------------------------------------------------------------------------
// Escape codes preceding special sequences in the dictionary or macros
//----------------------------------------------------------------------------
// In dictionary or macros preceding virtual key event sequences. These are always
// 13 byte sequences that have ASCII encoded values for the ascii code, keyCode,
//   and modifiers:
//   grfVirtualSequence, ascii,   keyCode,  modifiers.
//         1 byte        4 bytes   4 bytes   4 bytes
  grfVirtualSequence   =0x01;

// In dictionary to tell us about temp shift state changes.
  grfShiftSequence     =0x02;

// In dictionary/macros to hide special features
  grfSpecialSequence   =0x03;

// Char indicating a seqeunce of characters to expand.
  grfExpansionSequence ='@';

// Chars indicating what to expand into
  expandDateChar          ='D';
  expandTimeChar          ='T';
  expandStampChar         ='S';   // This follows 'D' or 'T' for the sake
                                       // of the mnemonic name.

  shortcutBinaryDataFlag  =0x01;


// Determine if a string has a sequence
//HasVirtualSequence(s)    (s[0] == grfVirtualSequence)
//HasSpecialSequence(s)    (s[0] == grfSpecialSequence)
//HasExpansionSequence(s)  (s[0] == grfExpansionSequence)



/*------------------------------------------------------------------------------
 * Temp shift states, returned by GrfGetState
 *-----------------------------------------------------------------------------*/
  grfTempShiftPunctuation       =1;
  grfTempShiftExtended          =2;
  grfTempShiftUpper             =3;
  grfTempShiftLower             =4;



/************************************************************
 * Graffiti result codes
 *************************************************************/
  grfErrBadParam                =grfErrorClass | 1;
  grfErrPointBufferFull         =grfErrorClass | 2;
  grfErrNoGlyphTable            =grfErrorClass | 3;
  grfErrNoDictionary            =grfErrorClass | 4;
  grfErrNoMapping               =grfErrorClass | 5;
  grfErrMacroNotFound           =grfErrorClass | 6;
  grfErrDepthTooDeep            =grfErrorClass | 7;
  grfErrMacroPtrTooSmall        =grfErrorClass | 8;
  grfErrNoMacros                =grfErrorClass | 9;

  grfErrMacroIncomplete         =grfErrorClass | 129;  // (grfWarningOffset+1)
  grfErrBranchNotFound          =grfErrorClass | 130;  // (grfWarningOffset+2)


/************************************************************
 * Graffiti interface procedures
 *************************************************************/

//-----------------------------------------------------------------
// High Level Calls
//------------------------------------------------------------------
Function GrfInit: Err;
            SYS_TRAP(sysTrapGrfInit);

Function GrfFree: Err;
            SYS_TRAP(sysTrapGrfFree);

Function GrfProcessStroke(var startPtP, endPtP: PointType; upShift: Boolean): Err;
            SYS_TRAP(sysTrapGrfProcessStroke);

Function GrfFieldChange(resetState: Boolean; var characterToDelete: UInt16): Err;
            SYS_TRAP(sysTrapGrfFieldChange);

Function GrfGetState(var capsLockP, numLockP: Boolean;
                     var tempShiftP: UInt16; var autoShiftedP: Boolean): Err;
            SYS_TRAP(sysTrapGrfGetState);

Function GrfSetState(capsLock, numLock, upperShift: Boolean): Err;
            SYS_TRAP(sysTrapGrfSetState);


//-----------------------------------------------------------------
// Mid Level Calls
//------------------------------------------------------------------

Function GrfFlushPoints: Err;
            SYS_TRAP(sysTrapGrfFlushPoints);

Function GrfAddPoint(var pt: PointType): Err;
            SYS_TRAP(sysTrapGrfAddPoint);

Function GrfInitState: Err;
            SYS_TRAP(sysTrapGrfInitState);

Function GrfCleanState: Err;
            SYS_TRAP(sysTrapGrfCleanState);

Function GrfMatch(var flagsP: UInt16 ; dataPtrP: Pointer;
                  var dataLenP, uncertainLenP: UInt16; matchInfoP: GrfMatchInfoPtr): Err;
            SYS_TRAP(sysTrapGrfMatch);

Function GrfGetMacro(Const nameP: String; var macroDataP: UInt8; var dataLenP: UInt16): Err;
            SYS_TRAP(sysTrapGrfGetMacro);

Function GrfGetAndExpandMacro(Const nameP: String; var macroDataP: UInt8; var dataLenP: UInt16): Err;
            SYS_TRAP(sysTrapGrfGetAndExpandMacro);


//-----------------------------------------------------------------
// Low Level Calls
//------------------------------------------------------------------
Function GrfFilterPoints: Err;
            SYS_TRAP(sysTrapGrfFilterPoints);

Function GrfGetNumPoints(var numPtsP: UInt16): Err;
            SYS_TRAP(sysTrapGrfGetNumPoints);

Function GrfGetPoint(index: UInt16; var pointP: PointType): Err;
            SYS_TRAP(sysTrapGrfGetPoint);

Function GrfFindBranch(flags: UInt16): Err;
            SYS_TRAP(sysTrapGrfFindBranch);

Function GrfMatchGlyph(matchInfoP: GrfMatchInfoPtr; maxUnCertainty, maxMatches: UInt16): Err;
            SYS_TRAP(sysTrapGrfMatchGlyph);

Function GrfGetGlyphMapping(glyphID: UInt16; var flagsP: UInt16;
               dataPtrP: Pointer; var dataLenP, uncertainLenP: UInt16): Err;
            SYS_TRAP(sysTrapGrfGetGlyphMapping);

Function GrfGetMacroName(index: UInt16; nameP: pChar): Err;
            SYS_TRAP(sysTrapGrfGetMacroName);

Function GrfDeleteMacro(index: UInt16): Err;
            SYS_TRAP(sysTrapGrfDeleteMacro);

Function GrfAddMacro(Const nameP: String; var macroDataP: UInt8; dataLen: UInt16): Err;
            SYS_TRAP(sysTrapGrfAddMacro);

implementation

end.

