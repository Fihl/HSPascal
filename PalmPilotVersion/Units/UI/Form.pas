/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Form.h
 *
 * Description:
 *        This file defines dialog box structures and routines.
 *
 * History:
 *              September 6, 1994       Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Form;

interface

Uses
  {$ifdef PalmVer35} Traps30, Traps35, {$endif}
  Preferences, Window, Rect, Font, Field, Control, List,
  ScrollBar, Table;

Const
  noFocus=0xFFFF;
  frmInvalidObjectId = $FFFF;
  frmNoSelectedControl = $FF;

  //Update code send as part of a frmUpdate event.
  frmRedrawUpdateCode = $8000;

Type
  // Alert constants and structures
  alertTypes = (
   informationAlert,
   confirmationAlert,
   warningAlert,
   errorAlert);
  AlertType = alertTypes;

  AlertTemplateType = Record
    alertType: UInt16;
    helpRscID: UInt16;
    numButtons: UInt16;
    defaultButton: UInt16
  end;

  // Types of object in a dialog box
  formObjects = (
    frmFieldObj,
    frmControlObj,
    frmListObj,
    frmTableObj,
    frmBitmapObj,
    frmLineObj,
    frmFrameObj,
    frmRectangleObj,
    frmLabelObj,
    frmTitleObj,
    frmPopupObj,
    frmGraffitiStateObj,
    frmGadgetObj,
    frmScrollBarObj);

  FormObjectKind = formObjects;

  FormObjAttrType = Record
    Flags: UInt16;   // Set if part of ui
    //usable   = bit:1
    //reserved = bit:15;
  end;

Const
  // Gadget support:
  formGadgetDrawCmd         = 0; // paramP is unspecified
  formGadgetEraseCmd        = 1; // paramP is unspecified
  formGadgetHandleEventCmd  = 2; // paramP is an EventType* for the relevant event.

Type
  FormGadgetAttrType = Record
    Flags: UInt16;
    //usable     :1; // Set if part of ui - "should be drawn"
    //isExtended  :1;   // Set if the structure is an "Extended" gadget (i.e., the 'handler' field is present)
    //visible    :1; // Set if drawn - "has been drawn" or "must do work to erase"
    //reserved    :13;  // pad it out
  end;

  //struct FormType; // forward reference to FormType so we can declare the handler type:
  // Boolean (FormGadgetHandlerType) (struct FormGadgetType *gadgetP, UInt16 cmd, void *paramP);
  FormGadgetHandlerPtr = ^FormGadgetHandlerType;
  FormGadgetHandlerType = Pointer;

  FormGadgetPtr = ^FormGadgetType;
  FormGadgetType = Record
    id: UInt16;
    attr: FormGadgetAttrType;
    rect: RectangleType;
    data: Pointer;
    handler: FormGadgetHandlerPtr; // FormGadgetHandlerType  *handler;
  end;

  // All of the smaller form objects:

  FormBitmapPtr = ^FormBitmapType;
  FormBitmapType = Record
    attr: FormObjAttrType;
    pos: PointType;
    rscID: UInt16
  end;

  FormLineType = Record
    attr: FormObjAttrType;
    point1,
    point2: PointType
  end;

  FormFrameType = Record
    id: UInt16;
    attr: FormObjAttrType;
    rect: RectangleType;
    frameType: UInt16
  end;

  FormRectangleType = Record
    attr: FormObjAttrType;
    rect: RectangleType
  end;

  FormLabelPtr = ^FormLabelType;
  FormLabelType = Record
    id: UInt16;
    pos: PointType;
    attr: FormObjAttrType;
    FontId: eFontID;
    Reserved: UInt8;
    text: PChar
  end;

  FormTitleType = Record
    rect: RectangleType;
    text: PChar
  end;

  FormPopupType = Record
    controlID: UInt16;
    listID: UInt16
  end;

  FrmGraffitiStatePtr = ^FrmGraffitiStateType;
  FrmGraffitiStateType = Record
    pos: PointType
  end;

  FormObjectPtr = ^FormObjectType;
  FormObjectType = Record
    ptr: Pointer;
    field: ^FieldType;
    control: ^ControlType;
    graphicsControl: ^GraphicControlType;
    sliderControl: ^SliderControlType;
    list: ^ListType;
    tabel: ^TableType;
    bitmap: ^FormBitmapType;
    //   FormLineType *line;
    //   FormFrameType *frame;
    //   FormRectangleType *rectangle;
    label_: ^FormLabelType;
    title: ^FormTitleType;
    popup: ^FormPopupType;
    grfState: ^FrmGraffitiStateType;
    gadget: ^FormGadgetType;
    scrollBar: ^ScrollBarType;
  end;

  FormObjListType = Record
    objectType: FormObjectKind;
    reserved: UInt8;
    object_: FormObjectType;
  end;

  FormAttrType = Record
    Flags: UInt16;
    // usable        :1;   // Set if part of ui
    // enabled       :1;   // Set if interactable (not grayed out)
    // visible       :1;   // Set if drawn, used internally
    // dirty         :1;   // Set if dialog has been modified
    // saveBehind    :1;   // Set if bits behind form are save when form ids drawn
    // graffitiShift         :1;     // Set if graffiti shift indicator is supported
    // globalsAvailable         :1;     // Set by Palm OS if globals are available for the
    // form event handler
    // reserved                 :9;
    reserved2: UInt16;        // FormAttrType now explicitly 32-bits wide.
  end;

  FormEventHandlerPtr = ^FormEventHandlerType;
  FormEventHandlerType = Pointer; // Boolean FormEventHandlerType (EventType * eventP);

  FormPtr = ^FormType;
  FormType = Record
    window: WindowType;
    formId: UInt16;
    attr: FormAttrType;
    bitsBehindForm: WinHandle;
    handler: FormEventHandlerPtr; //^FormEventHandlerType;
    focus: UInt16;
    defaultButton: UInt16;
    helpRscId: UInt16;
    menuRscId: UInt16;
    numObjects: UInt16;
    objects: ^FormObjListType;
  end;

  // FormActiveStateType: this structure is passed to FrmActiveState for
  // saving and restoring active form/window state; this structure's
  // contents are abstracted because the contents will differ significantly
  // as PalmOS evolves
  // Added for PalmOS 3.0
  FormActiveStateType = Record
    data: Array[0..10] of UInt16;
  end;

  // FrmCustomResponseAlert callback routine prototype
  // Boolean FormCheckResponseFuncType (Int16 button, Char * attempt);
  // FormCheckResponseFuncType * FormCheckResponseFuncPtr;

  FormCheckResponseFuncPtr= Pointer;

  //-----------------------------------------------
  //  Macros
  //-----------------------------------------------

  (***
  #if ERROR_CHECK_LEVEL == ERROR_CHECK_FULL
    #define ECFrmValidatePtr(formP) FrmValidatePtr(formP)
  #else
    #define ECFrmValidatePtr(formP)
  #endif
  ***)

  //--------------------------------------------------------------------
  //
  // Form Function
  //
  //--------------------------------------------------------------------

Function FrmInitForm(rscID: UInt16): FormPtr; SYS_TRAP(sysTrapFrmInitForm);

Procedure FrmDeleteForm(FormP: FormPtr); SYS_TRAP(sysTrapFrmDeleteForm);

Procedure FrmDrawForm(FormP: FormPtr); SYS_TRAP(sysTrapFrmDrawForm);

Procedure FrmEraseForm(FormP: FormPtr); SYS_TRAP(sysTrapFrmEraseForm);

Function FrmGetActiveForm: FormPtr; SYS_TRAP(sysTrapFrmGetActiveForm);

Procedure FrmSetActiveForm(formP: FormPtr); SYS_TRAP(sysTrapFrmSetActiveForm);

Function FrmGetActiveFormID: UInt16;
                     SYS_TRAP(sysTrapFrmGetActiveFormID);

Function FrmGetUserModifiedState(FormP: FormPtr): Boolean;
                     SYS_TRAP(sysTrapFrmGetUserModifiedState);

Procedure FrmSetNotUserModified(FormP: FormPtr);
                     SYS_TRAP(sysTrapFrmSetNotUserModified);

Function FrmGetFocus(FormP: FormPtr): UInt16;
                     SYS_TRAP(sysTrapFrmGetFocus);

Procedure FrmSetFocus(FormP: FormPtr; fieldindex: UInt16);
                     SYS_TRAP(sysTrapFrmSetFocus);

Function FrmHandleEvent(FormP: FormPtr; var Event{: EventType}): Boolean;
                     SYS_TRAP(sysTrapFrmHandleEvent);

Procedure FrmGetFormBounds(FormP: FormPtr; var rP: RectangleType);
                     SYS_TRAP(sysTrapFrmGetFormBounds);

Function FrmGetWindowHandle(FormP: FormPtr): WinHandle;
                     SYS_TRAP(sysTrapFrmGetWindowHandle);

Function FrmGetFormId(FormP: FormPtr): UInt16;
                     SYS_TRAP(sysTrapFrmGetFormId);

Function FrmGetFormPtr(formId: UInt16): FormPtr;
                     SYS_TRAP(sysTrapFrmGetFormPtr);

Function FrmGetFirstForm: FormPtr;
                     SYS_TRAP(sysTrapFrmGetFirstForm);

Function FrmGetNumberOfObjects(FormP: FormPtr): UInt16;
                     SYS_TRAP(sysTrapFrmGetNumberOfObjects);

Function FrmGetObjectIndex(FormP: FormPtr; objID: UInt16): UInt16;
                     SYS_TRAP(sysTrapFrmGetObjectIndex);

Function FrmGetObjectId(FormP: FormPtr; objIndex: UInt16): UInt16;
                     SYS_TRAP(sysTrapFrmGetObjectId);

Function FrmGetObjectType(FormP: FormPtr; objIndex: UInt16): FormObjectKind;
                     SYS_TRAP(sysTrapFrmGetObjectType);

function FrmGetObjectPtr(FormP: FormPtr; objIndex: UInt16): Pointer;
                     SYS_TRAP(sysTrapFrmGetObjectPtr);

Procedure FrmGetObjectBounds(FormP: FormPtr; objIndex: UInt16; var rP: RectangleType);
                     SYS_TRAP(sysTrapFrmGetObjectBounds);

Procedure FrmHideObject(FormP: FormPtr; objIndex: UInt16);
                     SYS_TRAP(sysTrapFrmHideObject);

Procedure FrmShowObject(FormP: FormPtr; objIndex: UInt16);
                     SYS_TRAP(sysTrapFrmShowObject);

Procedure FrmGetObjectPosition(FormP: FormPtr; objIndex: UInt16; var x,y: Coord);
                     SYS_TRAP(sysTrapFrmGetObjectPosition);

Procedure FrmSetObjectPosition(FormP: FormPtr; objIndex: UInt16; x,y: Coord);
                     SYS_TRAP(sysTrapFrmSetObjectPosition);

Procedure FrmSetObjectBounds(FormP: FormPtr; objIndex: UInt16;
   var bounds: RectangleType);
                     SYS_TRAP(sysTrapFrmSetObjectBounds);

Function FrmGetControlValue(FormP: FormPtr; controlID: UInt16): Int16;
                     SYS_TRAP(sysTrapFrmGetControlValue);

Procedure FrmSetControlValue(FormP: FormPtr; controlID: UInt16; newValue: Int16);
                     SYS_TRAP(sysTrapFrmSetControlValue);

Function FrmGetControlGroupSelection(FormP: FormPtr; groupNum: UInt8): UInt8;
                     SYS_TRAP(sysTrapFrmGetControlGroupSelection);

Procedure FrmSetControlGroupSelection(FormP: FormPtr; groupNum: UInt8; controlID: UInt16);
                     SYS_TRAP(sysTrapFrmSetControlGroupSelection);

Procedure FrmCopyLabel(FormP: FormPtr; labelID: UInt16; Const newLable: String);
                     SYS_TRAP(sysTrapFrmCopyLabel);

Function FrmGetLabel(FormP: FormPtr; labelID: UInt16): PChar;
                     SYS_TRAP(sysTrapFrmGetLabel);

Procedure FrmSetCategoryLabel(FormP: FormPtr; objIndex: UInt16;
   Const newLabel: String);
                     SYS_TRAP(sysTrapFrmSetCategoryLabel);

Function FrmGetTitle(FormP: FormPtr): PChar;
                     SYS_TRAP(sysTrapFrmGetTitle);

Procedure FrmSetTitle(FormP: FormPtr; Var newTitle: String); //VAR not Const
                     SYS_TRAP(sysTrapFrmSetTitle);

Procedure FrmCopyTitle(FormP: FormPtr; Const newTitle: String);
                     SYS_TRAP(sysTrapFrmCopyTitle);

function FrmGetGadgetData(FormP: FormPtr; objIndex: UInt16): Pointer;
                     SYS_TRAP(sysTrapFrmGetGadgetData);

Procedure FrmSetGadgetData(FormP: FormPtr; objIndex: UInt16; var data);
                     SYS_TRAP(sysTrapFrmSetGadgetData);

{$ifdef PalmVer35}
Procedure FrmSetGadgetHandler(FormP: FormPtr; objIndex: UInt16;
   var attrP: FormGadgetHandlerPtr);
                     SYS_TRAP(sysTrapFrmSetGadgetHandler);
{$endif}

Function FrmDoDialog(FormP: FormPtr): UInt16;
                     SYS_TRAP(sysTrapFrmDoDialog);

Function FrmAlert(alertId: UInt16): UInt16;
                     SYS_TRAP(sysTrapFrmAlert);

Function FrmCustomAlert(alertId: UInt16; Const s1, s2, s3: String): UInt16;
                     SYS_TRAP(sysTrapFrmCustomAlert);

Procedure FrmHelp(helpMsgId: UInt16);
                     SYS_TRAP(sysTrapFrmHelp);

Procedure FrmUpdateScrollers(FormP: FormPtr; upIndex: UInt16;
   downIndex: UInt16; scrollableUp: Boolean; scrollabledown: Boolean);
                     SYS_TRAP(sysTrapFrmUpdateScrollers);

Function FrmVisible(FormP: FormPtr): Boolean;
                     SYS_TRAP(sysTrapFrmVisible);

Procedure FrmSetEventHandlerNONE(PForm: FormPtr); Assembler;

Procedure FrmSetEventHandler(formP: FormPtr; handler: FormEventHandlerPtr);
                     SYS_TRAP(sysTrapFrmSetEventHandler);

Function FrmDispatchEvent(var eventP{: EventType}): Boolean; SYS_TRAP(sysTrapFrmDispatchEvent);




Procedure FrmPopupForm(formId: UInt16);
                     SYS_TRAP(sysTrapFrmPopupForm);

Procedure FrmGotoForm(formId: UInt16); SYS_TRAP(sysTrapFrmGotoForm);

Procedure FrmUpdateForm(formId: UInt16; updateCode: UInt16);
                     SYS_TRAP(sysTrapFrmUpdateForm);

Procedure FrmReturnToForm(formId: UInt16);
                     SYS_TRAP(sysTrapFrmReturnToForm);

Procedure FrmCloseAllForms;
                     SYS_TRAP(sysTrapFrmCloseAllForms);

Procedure FrmSaveAllForms;
                     SYS_TRAP(sysTrapFrmSaveAllForms);

Function FrmPointInTitle(FormP: FormPtr; x,y: Coord): Boolean;
                     SYS_TRAP(sysTrapFrmPointInTitle);

Procedure FrmSetMenu(FormP: FormPtr; menuRscID: UInt16);
                     SYS_TRAP(sysTrapFrmSetMenu);

{$ifdef PalmVer35}
Function FrmValidatePtr(FormP: FormPtr): Boolean;
                     SYS_TRAP(sysTrapFrmValidatePtr);

Function FrmAddSpaceForObject(var fp: FormPtr {void **formPP};
   var objectPP: MemPtr;
   objectKind: FormObjectKind; objectSize: UInt16): Err;
      SYS_TRAP(sysTrapFrmAddSpaceForObject);

Function FrmRemoveObject(var fp: FormPtr {void **formPP};
   objIndex: UInt16): Err;
                     SYS_TRAP(sysTrapFrmRemoveObject);

Function FrmNewForm(formId: UInt16; Const titleStrP: String;
   x, y, width, height: Coord; model: Boolean;
   defaultButton, helpRscID, menuRscID: UInt16): FormPtr;
                     SYS_TRAP(sysTrapFrmNewForm);

Function FrmNewLabel(var fp: FormPtr {void **formPP};
   ID: UInt16; Const text: String;
   x,y: Coord; font: FontID): FormLabelPtr;
                     SYS_TRAP(sysTrapFrmNewLabel);

Function FrmNewBitmap(var fp: FormPtr {void **formPP};
   ID, rscID: UInt16; x,y: Coord): FormBitmapPtr;
                     SYS_TRAP(sysTrapFrmNewBitmap);

Function FrmNewGadget(var fp: FormPtr {void **formPP};
   id: UInt16; x, y, width, height: Coord): FormGadgetPtr;
                     SYS_TRAP(sysTrapFrmNewGadget);

Function FrmActiveState(var stateP: FormActiveStateType; Save: Boolean): Err;
                     SYS_TRAP(sysTrapFrmActiveState);

Function FrmCustomResponseAlert(alertId: UInt16; Const s1, s2, s3: String;
   entryStringBuf: pChar; entryStringBufLength: Int16;
   callback: FormCheckResponseFuncPtr): UInt16;
                     SYS_TRAP(sysTrapFrmCustomResponseAlert);

Function FrmNewGsi(var fp: FormPtr {void **formPP};
   x,y: Coord): FrmGraffitiStatePtr;
                     SYS_TRAP(sysTrapFrmNewGsi);
{$endif}

//  #define FrmSaveActiveState(stateP);         FrmActiveState(stateP, true);
//  #define FrmRestoreActiveState(stateP);      FrmActiveState(stateP, false);

implementation

Procedure FrmSetEventHandlerNONE(PForm: FormPtr); Assembler;
ASM     jsr     @1
        moveq   #0,d0               //Simple "Eventhandler"
        rts
@1:     move.l  PForm,-(SP);
        SysTrap FrmSetEventHandler  //FrmSetEventHandler(PForm, @SimpleEventHandler);
end;

end.

