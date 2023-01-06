/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: List.h
 *
 * Description:
 *        This file defines list structures and routines.
 *
 * History:
 *              November 3, 1994        Created by Roger Flores
 *                      Name    Date            Description
 *                      ----    ----            -----------
 *                      bob     2/9/99  fixed const stuff
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit List;

interface

Uses {$ifdef PalmVer35} Traps30, {$endif}
     Window, Rect{, Event}, Font;

Const
  noListSelection = -1;

Type
  //-------------------------------------------------------------------
  // List structures
  //-------------------------------------------------------------------

  ListAttrType = Record
    Flags: UInt16;
    // usable        :1;      // set if part of ui
    // enabled       :1;      // set if interactable (not grayed out)
    // visible       :1;      // set if drawn
    // poppedUp         :1;      // set if choices displayed in popup win.
    // hasScrollBar     :1;      // set if the list has a scroll bar
    // search        :1;      // set if incremental search is enabled
    // reserved         :2;
  end;

  // Load data callback routine prototype
  // void ListDrawDataFuncType (Int16 itemNum, RectangleType * bounds, Char **itemsText);

  ListDrawDataFuncPtr = Pointer; //!!! ListDrawDataFuncType;

  ListPtr = ^ListType;
  ListType = Record
    id: UInt16;
    bounds: RectangleType;
    attr: ListAttrType;
    itemsText: ^PChar; //?? Char * *itemsText;
    numItems: Int16;             // number of choices in the list
    currentItem: Int16;          // currently display choice
    topItem: Int16;              // top item visible when poped up
    font: FontID;                // font used to draw list
    reserved: UInt8;
    popupWin: WinHandle;            // used only by popup lists
    drawItemsCallback: ListDrawDataFuncPtr;  // 0 indicates no function
  end;

//-------------------------------------------------------------------
// List routines
//-------------------------------------------------------------------

Procedure LstDrawList(var listP: ListType);
                     SYS_TRAP(sysTrapLstDrawList);

Procedure LstEraseList(var listP: ListType);
                     SYS_TRAP(sysTrapLstEraseList);

Function LstGetSelection(var listP: ListType): Int16;
                     SYS_TRAP(sysTrapLstGetSelection);

Function LstGetSelectionText(var listP: ListType; itemNum: Int16): PChar;
                     SYS_TRAP(sysTrapLstGetSelectionText);

Function LstHandleEvent(var listP: ListType; var Event{: EventType}): Boolean;
                     SYS_TRAP(sysTrapLstHandleEvent);

Procedure LstSetHeight(var listP: ListType; visibleItems: Int16);
                     SYS_TRAP(sysTrapLstSetHeight);

Procedure LstSetPosition(var listP: ListType; x,y: Coord);
                     SYS_TRAP(sysTrapLstSetPosition);

Procedure LstSetSelection(var listP: ListType; itemNum: Int16);
                     SYS_TRAP(sysTrapLstSetSelection);

//itemsText = Array[] of pChar
Procedure LstSetListChoices(var listP: ListType; var itemsText{: ppChar}; numItems: Int16);
                     SYS_TRAP(sysTrapLstSetListChoices);

Procedure LstSetDrawFunction(var listP: ListType; func: ListDrawDataFuncPtr);
                     SYS_TRAP(sysTrapLstSetDrawFunction);

Procedure LstSetTopItem(var listP: ListType; itemNum: Int16);
                     SYS_TRAP(sysTrapLstSetTopItem);

Procedure LstMakeItemVisible(var listP: ListType; itemNum: Int16);
                     SYS_TRAP(sysTrapLstMakeItemVisible);

Function LstGetNumberOfItems(var listP: ListType): Int16;
                     SYS_TRAP(sysTrapLstGetNumberOfItems);

Function LstPopupList(var listP: ListType): Int16;
                     SYS_TRAP(sysTrapLstPopupList);

Function LstScrollList(var listP: ListType; direction: WinDirectionType; itemCount: Int16): Boolean;
                     SYS_TRAP(sysTrapLstScrollList);

Function LstGetVisibleItems(var listP: ListType): Int16;
                     SYS_TRAP(sysTrapLstGetVisibleItems);

{$ifdef PalmVer35}
Function LstNewList(var fp{: FormPtr}{void **formPP};
   id: UInt16; x, y, width, height: Coord;
   font: FontID; visibleItems, triggerId: Int16): Err;
                     SYS_TRAP(sysTrapLstNewList);
{$endif}

implementation

end.

