/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Field.h
 *
 * Description:
 *        This file defines field structures and routines.
 *
 * History:
 *              August 29, 1994 Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Field;

interface

Uses {x$ifdef PalmVer35} Traps30, {x$endif}
     Rect, Font, {Form, {Event, {}Window;

Const
  maxFieldTextLen = $7fff;
  maxFieldLines = 11; //Maximum number of line the a dynamicly sizing field will expand to.

Type
  // kind alignment values
  justifications = (leftAlign, centerAlign, rightAlign);
  JustificationType=justifications;

Const
  undoBufferSize = 100;

Type
  UndoMode = (undoNone, undoTyping, undoBackspace, undoDelete,
              undoPaste, undoCut, undoInput);

  FieldUndoType = Record
    mode: UndoMode;
    reserver: UInt8;
    start: UInt16;
    end_: UInt16;
    bufferLen: UInt16;
    buffer: PChar
  end;

  FieldAttrPtr = ^FieldAttrType;
  FieldAttrType = Record
    Flags: UInt16;
    // usable           :1;   // Set if part of ui
    // visible    :1;   // Set if drawn, used internally
    // editable      :1;   // Set if editable
    // singleLine :1;   // Set if only a single line is displayed
    // hasFocus         :1;     // Set if the field has the focus
    // dynamicSize   :1;     // Set if height expands as text is entered
    // insPtVisible  :1;   // Set if the ins pt is scolled into view
    // dirty      :1;   // Set if user modified
    // underlined :2;   // text underlined mode
    // justification :2;   // text alignment
    // autoShift  :1;   // Set if auto case shift
    // hasScrollBar  :1;   // Set if the field has a scroll bar
    // numeric    :1;   // Set if numeric, digits and secimal separator only
  end;

  LineInfoPtr = ^LineInfoType;
  LineInfoType = Record
    Start:  UInt16;        // position in text string of first char.
    Length: UInt16;        // number of character in the line
  end;

  FieldPtr = ^FieldType;
  FieldType = Record
    id: UInt16;
    rect: RectangleType;
    attr: FieldAttrType;
    text: PChar;        // pointer to the start of text string
    textHandle: MemHandle;    // block the contains the text string
    lines: LineInfoPtr;
    textLen: UInt16;
    textBlockSize: UInt16;
    maxChars: UInt16;
    selFirstPos: UInt16;
    selLastPos: UInt16;
    insPtXPos: UInt16;
    insPtYPos: UInt16;
    FontID: eFontID;
    reserver: UInt8;
  end;

//---------------------------------------------------------------------
// Field Functions
//---------------------------------------------------------------------

Procedure FldCopy(fldP: FieldPtr); SYS_TRAP(sysTrapFldCopy);

Procedure FldCut(fldP: FieldPtr); SYS_TRAP(sysTrapFldCut);

Procedure FldDrawField(fldP: FieldPtr); SYS_TRAP(sysTrapFldDrawField);

Procedure FldEraseField(fldP: FieldPtr); SYS_TRAP(sysTrapFldEraseField);
 
Procedure FldFreeMemory(fldP: FieldPtr); SYS_TRAP(sysTrapFldFreeMemory);

Procedure FldGetBounds(fldP: FieldPtr; var rect: RectangleType); SYS_TRAP(sysTrapFldGetBounds);

Function FldGetFont(fldP: FieldPtr): FontID; SYS_TRAP(sysTrapFldGetFont);

Procedure FldGetSelection(fldP: FieldPtr;
   var startPosition, endPosition: UInt16); SYS_TRAP(sysTrapFldGetSelection);

Function FldGetTextHandle(fldP: FieldPtr): MemHandle; SYS_TRAP(sysTrapFldGetTextHandle);

Function FldGetTextPtr(fldP: FieldPtr): pChar; SYS_TRAP(sysTrapFldGetTextPtr);

Function FldHandleEvent(fldP: FieldPtr; var Event{: EventType}): Boolean; SYS_TRAP(sysTrapFldHandleEvent);

Procedure FldPaste(fldP: FieldPtr); SYS_TRAP(sysTrapFldPaste);

Procedure FldRecalculateField(fldP: FieldPtr; redraw: Boolean); SYS_TRAP(sysTrapFldRecalculateField);

Procedure FldSetBounds(fldP: FieldPtr; var rP: RectangleType); SYS_TRAP(sysTrapFldSetBounds);

Procedure FldSetFont(fldP: FieldPtr; fid: FontID); SYS_TRAP(sysTrapFldSetFont);

Procedure FldSetText(fldP: FieldPtr; textHandle: MemHandle; offset, size: UInt16);
   SYS_TRAP(sysTrapFldSetText);

Procedure FldSetTextHandle(fldP: FieldPtr; textHandle: MemHandle); SYS_TRAP(sysTrapFldSetTextHandle);

Procedure FldSetTextPtr(fldP: FieldPtr; Const textP: String); SYS_TRAP(sysTrapFldSetTextPtr);

Procedure FldSetUsable(fldP: FieldPtr; usable: Boolean); SYS_TRAP(sysTrapFldSetUsable);

Procedure FldSetSelection(fldP: FieldPtr; startPosition, endPosition: UInt16); SYS_TRAP(sysTrapFldSetSelection);

Procedure FldGrabFocus(fldP: FieldPtr); SYS_TRAP(sysTrapFldGrabFocus);

Procedure FldReleaseFocus(fldP: FieldPtr); SYS_TRAP(sysTrapFldReleaseFocus);

Function  FldGetInsPtPosition(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetInsPtPosition);

Procedure FldSetInsPtPosition(fldP: FieldPtr; pos: UInt16); SYS_TRAP(sysTrapFldSetInsPtPosition);

Procedure FldSetInsertionPoint(fldP: FieldPtr; pos: UInt16); SYS_TRAP(sysTrapFldSetInsertionPoint);

Function  FldGetScrollPosition(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetScrollPosition);

Procedure FldSetScrollPosition(fldP: FieldPtr; pos: UInt16); SYS_TRAP(sysTrapFldSetScrollPosition);

Procedure FldGetScrollValues(fldP: FieldPtr;
   var scrollPosP, textHeightP, fieldHeightP: UInt16); SYS_TRAP(sysTrapFldGetScrollValues);

Function  FldGetTextLength(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetTextLength);

Procedure FldScrollField(fldP: FieldPtr;
   linesToScroll: UInt16; direction: WinDirectionType); SYS_TRAP(sysTrapFldScrollField);

Function  FldScrollable(fldP: FieldPtr; direction: WinDirectionType): Boolean;
   SYS_TRAP(sysTrapFldScrollable);

Function  FldGetVisibleLines(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetVisibleLines);

Function  FldGetTextHeight(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetTextHeight);

Function  FldCalcFieldHeight(chars: String; maxWidth: UInt16): UInt16; SYS_TRAP(sysTrapFldCalcFieldHeight);

Function  FldWordWrap(chars: String; maxWidth: UInt16): UInt16; SYS_TRAP(sysTrapFldWordWrap);

Procedure FldCompactText(fldP: FieldPtr); SYS_TRAP(sysTrapFldCompactText);

Function  FldDirty(fldP: FieldPtr): Boolean; SYS_TRAP(sysTrapFldDirty);

Procedure FldSetDirty(fldP: FieldPtr; dirty: Boolean); SYS_TRAP(sysTrapFldSetDirty);

Function  FldGetMaxChars(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetMaxChars);

Procedure FldSetMaxChars(fldP: FieldPtr; maxChars: UInt16); SYS_TRAP(sysTrapFldSetMaxChars);

Function  FldInsert(fldP: FieldPtr; insertChars: String; insertLen: UInt16): Boolean;
   SYS_TRAP(sysTrapFldInsert);

Procedure FldDelete(fldP: FieldPtr; start, end_: UInt16); SYS_TRAP(sysTrapFldDelete);

Procedure FldUndo(fldP: FieldPtr); SYS_TRAP(sysTrapFldUndo);

Function  FldGetTextAllocatedSize(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetTextAllocatedSize);

Procedure FldSetTextAllocatedSize(fldP: FieldPtr; allocatedSize: UInt16); SYS_TRAP(sysTrapFldSetTextAllocatedSize);

Procedure FldGetAttributes(fldP: FieldPtr; var attrP: FieldAttrType); SYS_TRAP(sysTrapFldGetAttributes);

Procedure FldSetAttributes(fldP: FieldPtr; var attrP: FieldAttrType); SYS_TRAP(sysTrapFldSetAttributes);

Procedure FldSendChangeNotification(fldP: FieldPtr); SYS_TRAP(sysTrapFldSendChangeNotification);

Procedure FldSendHeightChangeNotification(fldP: FieldPtr; pos, numLines: UInt16);
   SYS_TRAP(sysTrapFldSendHeightChangeNotification);

Function  FldMakeFullyVisible(fldP: FieldPtr): Boolean; SYS_TRAP(sysTrapFldMakeFullyVisible);

Function  FldGetNumberOfBlankLines(fldP: FieldPtr): UInt16; SYS_TRAP(sysTrapFldGetNumberOfBlankLines);

Function  FldNewField(var formPP{: FormPtr}; id: UInt16;
   x, y, width, height: Coord;
   font: FontID; maxChars: UInt32;
   editable, underlined, singleLine, dynamicSize: Boolean;
   justification: JustificationType;
   autoShift, hasScrollBar, numeric: Boolean): FieldPtr;
   SYS_TRAP(sysTrapFldNewField);

implementation

end.

