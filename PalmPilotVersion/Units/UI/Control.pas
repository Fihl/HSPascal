/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Control.h
 *
 * Description:
 *        This file defines check box structures and routines.
 *
 * History:
 *              August 29, 1994 Created by Art Lamb
 *                      Name    Date            Description
 *                      ----    ----            -----------
 *                      bob     2/9/99  Fix up const stuff
 *                      bob     4/16/99 add GraphicControlType
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Control;

interface

Uses {x$ifdef PalmVer35} Traps30, Traps35, {x$endif}
     Rect, Font, DataMgr{, Event};

Type
  ControlAttrType = Record
    Flags1: UInt8;
    // usable          :1; // set if part of ui
    // enabled    :1;   // set if interactable (not grayed out)
    // visible    :1;   // set if drawn (set internally)
    // on      :1;   // set if on (checked)
    // leftAnchor :1;   // set if bounds expand to the right
                           // clear if bounds expand to the left
    // frame      :3;
    Flags2: UInt8;
    // drawnAsSelected  :1;   // support for old-style graphic controls
                                                                                    // where control overlaps a bitmap
    // graphical  :1;   // set if images are used instead of text
    // vertical      :1;   // true for vertical sliders
    // reserved      :5;
  end;

  // = controlStyles
  ControlStyleType = (buttonCtl, pushButtonCtl, checkboxCtl, popupTriggerCtl,
                   selectorTriggerCtl, repeatingButtonCtl, sliderCtl,
                   feedbackSliderCtl);

  //=buttonFrames
  ButtonFrameType = (noButtonFrame, standardButtonFrame, boldButtonFrame, rectangleButtonFrame);

  ControlPtr = ^ControlType;
  ControlType = Record
    id: UInt16;
    bounds: RectangleType;
    text: PChar;
    attr: ControlAttrType;
    style: ControlStyleType;
    font: FontID;
    group: UInt8;
    reserved: UInt8
  end;

  // GraphicControlType *'s can be cast to ControlType *'s and passed to all
  // Control API functions (as long as the 'graphical' bit in the attrs is set)

  GraphicControlPtr = ^GraphicControlType;
  GraphicControlType = Record
    id: UInt16;
    bounds: RectangleType;
    bitmapID: DmResID;        // overlays text in ControlType
    selectedBitmapID: DmResID;   // overlays text in ControlType
    attr: ControlAttrType;
    style: ControlStyleType;
    unused: FontID;
    group: UInt8;
    reserver: UInt8;
  end;

  // SliderControlType *'s can be cast to ControlType *'s and passed to all
  // Control API functions (as long as the control style is a slider)

  SliderControlPtr = ^SliderControlType;
  SliderControlType = Record
    id: UInt16;
    bounds: RectangleType;
    thumbID: DmResID;         // overlays text in ControlType
    backgroundID: DmResID; // overlays text in ControlType
    attr: ControlAttrType;          // graphical *is* set
    style: ControlStyleType;        // must be sliderCtl or repeatingSliderCtl
    minValue: Int16;
    maxValue: Int16;
    pageSize: Int16;
    value: Int16;
    activeSliderP: MemPtr
  end;

  //----------------------------------------------------------
  //  Control Functions
  //----------------------------------------------------------

Procedure CtlDrawControl(ControlP: ControlPtr); SYS_TRAP(sysTrapCtlDrawControl);

Procedure CtlEraseControl(ControlP: ControlPtr); SYS_TRAP(sysTrapCtlEraseControl);

Procedure CtlHideControl(ControlP: ControlPtr); SYS_TRAP(sysTrapCtlHideControl);

Procedure CtlShowControl(ControlP: ControlPtr); SYS_TRAP(sysTrapCtlShowControl);

function CtlEnabled(ControlP: ControlPtr): Boolean; SYS_TRAP(sysTrapCtlEnabled);

Procedure CtlSetEnabled(ControlP: ControlPtr; usable: Boolean); SYS_TRAP(sysTrapCtlSetEnabled);

Procedure CtlSetUsable(ControlP: ControlPtr; usable: Boolean); SYS_TRAP(sysTrapCtlSetUsable);

function CtlGetValue(ControlP: ControlPtr): Int16; SYS_TRAP(sysTrapCtlGetValue);

Procedure CtlSetValue(ControlP: ControlPtr; newValue: Int16); SYS_TRAP(sysTrapCtlSetValue);

//const Char *
Function CtlGetLabel(ControlP: ControlPtr): PChar; SYS_TRAP(sysTrapCtlGetLabel);

//Procedure CtlSetLabel(ControlP: ControlPtr; const newLabel: String); SYS_TRAP(sysTrapCtlSetLabel);
Procedure CtlSetLabel(ControlP: ControlPtr; newLabel: PChar); SYS_TRAP(sysTrapCtlSetLabel);

{x$ifdef PalmVer35}
Procedure CtlSetGraphics(var cltP: ControlType;
   newBitmapID, newSelectedBitmapID: DmResID); SYS_TRAP(sysTrapCtlSetGraphics);

Procedure CtlSetSliderValues(var cltP: ControlType;
   var minValueP, maxValueP, pageSizeP, valueP: UInt16); SYS_TRAP(sysTrapCtlSetSliderValues);

Procedure CtlGetSliderValues(var cltP: ControlType;
   var minValueP, maxValueP, pageSizeP, valueP: UInt16); SYS_TRAP(sysTrapCtlGetSliderValues);

function CtlValidatePointer(ControlP: ControlPtr): Boolean; SYS_TRAP(sysTrapCtlValidatePointer);
{x$Endif}

Procedure CtlHitControl(ControlP: ControlPtr); SYS_TRAP(sysTrapCtlHitControl);

function CtlHandleEvent(ControlP: ControlPtr; var Event{: EventType}): Boolean; SYS_TRAP(sysTrapCtlHandleEvent);

{$ifdef PalmVer35}
Function CtlNewControl(var fp{: FormPtr} {void **formPP};
   ID: UInt16; Style: ControlStyleType; var textP: String;
   x, y, width, height: Coord;
   font: FontID; group: UInt8; leftAnchor: Boolean): ControlPtr; SYS_TRAP(sysTrapCtlNewControl);

function CtlNewGraphicControl(var fp{: FormPtr} {void **formPP};
   ID: UInt16;
   style: ControlStyleType; bitmapID, selectedBitmapID: DmResID;
   x, y, width, height: Coord;
   group: UInt8; leftAnchor: Boolean): GraphicControlPtr; SYS_TRAP(sysTrapCtlNewGraphicControl);

function CtlNewSliderControl(var fp{: FormPtr} {void **formPP};
   ID: UInt16;
   style: ControlStyleType; thumbID, backgroundID: DmResID;
   x, y, width, height: Coord;
   minValue, maxValue, pageSize, value: UInt16): SliderControlPtr; SYS_TRAP(sysTrapCtlNewSliderControl);

{$endif}
implementation

end.

