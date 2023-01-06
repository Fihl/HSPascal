/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Menu.h
 *
 * Description:
 *        This file defines menu structures and routines.
 *
 * History:
 *              November 18, 1994       Created by Roger Flores
 *                      Name    Date            Description
 *                      ----    ----            -----------
 *                      gap     09/29/99        Added gsiWasEnabled to MenuCmdBarType
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Menu;

interface

Uses Window, Font, Rect, ErrorBase, Traps35;

Const menuErrorClass = 0x2600;
  // Errors returned by Menu routines
  menuErrNoMenu          = menuErrorClass + 1;
  menuErrNotFound        = menuErrorClass + 2;
  menuErrSameId          = menuErrorClass + 3;
  menuErrTooManyItems    = menuErrorClass + 4;
  menuErrOutOfMemory     = menuErrorClass + 5;

Type
  // Command bar structures
  MenuCmdBarResultType = (
    menuCmdBarResultNone,        // send nothing (this'd be quite unusual but is allowed)
    menuCmdBarResultChar,        // char to send (with commandKeyMask bit set)
    menuCmdBarResultMenuItem,    // id of the menu item
    menuCmdBarResultNotify       // Nofication Manager notification type
  );

  // maximum length of the prompt string to display in the command bar
Const
  menuCmdBarMaxTextLength=20;

Type
  MenuCmdBarButtonPtr = ^MenuCmdBarButtonType;
  MenuCmdBarButtonType = Record
    bitmapId: UInt16;
    name: array [0..menuCmdBarMaxTextLength-1] of Char;  //Sorry, no subtraction yet
    resultType: MenuCmdBarResultType;
    result: UInt32
  end;

  MenuCmdBarType = Record
    bitsBehind: WinHandle;
    timeoutTick: Int32; // tick to disappear on
    top: Coord;
    numButtons: Int16;
    insPtWasEnabled: Boolean;
    gsiWasEnabled: Boolean;
    buttonsData: MenuCmdBarButtonPtr
  end;

Const // to tell MenuCmdBarAddButton where to add the button: on right or left.
  menuCmdBarOnRight = 0;
  menuCmdBarOnLeft = 0xff;

  //Menu-specific
  noMenuSelection = -1;
  noMenuItemSelection = -1;
  separatorItemSelection = -2;

  // cause codes for menuOpen Event
  menuButtonCause = 0;
  menuCommandCause = 1;

  // To match Apple's ResEdit the first byte of a menu item's text can
  // be a special char indicating a special menu item.
  MenuSeparatorChar = '-';

Type
  MenuItemPtr = ^MenuItemType;
  MenuItemType = Record
    id: UInt16;            // id of the menu item
    command: Char;         // command key
    Flags: UInt8;          //hidden: 1;     // true if menu item is hidden
    itemStr: PChar;        // string to be displayed
  end;

  MenuPullDownPtr = ^MenuPullDownType;
  MenuPullDownType = Record
    menuWin: WinHandle;       // window of pull-down menu
    bounds: RectangleType;    // bounds of the pulldown
    bitsBehind: WinHandle;    // saving bits behind pull-down menu
    titleBounds: RectangleType;          // bounds of the title in menu bar
    title: PChar;       // menu title displayed in menu bar
    Flags: UInt16;                      //hidden: 1;     // true if pulldown is hidden
                                        //numItems: 15;  // number of items in the menu
    items: MenuItemPtr;       // array of menu items
  end;

  MenuBarAttrType = Record
    Flags: UInt16;                      //visible:1;         // Set if menu bar is drawn
                                        //commandPending:1;  // Set if next key is a command
                                        //insPtEnabled:1;    // Set if insPt was on when menu was drawn
                                        //needsRecalc:1;     // if set then recalc menu dimensions
  end;

  MenuBarPtr = ^MenuBarType;
  MenuBarType = Record
    barWin: WinHandle;        // window of menu bar
    bitsBehind: WinHandle;    // saving bits behind menu bar
    savedActiveWin: WinHandle;
    bitsBehindStatus: WinHandle;
    attr: MenuBarAttrType;
    curMenu: Int16;        // current menu or -1 if none
    curItem: Int16;        // current item in curMenu, -1 if none
    commandTick: Int32;                 //
    numMenus: Int16;            // number of menus
    menus: MenuPullDownPtr;      // array of menus
  end;

Function MenuInit(resourceId: UInt16): MenuBarPtr; SYS_TRAP(sysTrapMenuInit);

Function MenuGetActiveMenu: MenuBarPtr; SYS_TRAP(sysTrapMenuGetActiveMenu);

Function MenuSetActiveMenu(menuP: MenuBarPtr): MenuBarPtr; SYS_TRAP(sysTrapMenuSetActiveMenu);

Procedure MenuDispose(menuP: MenuBarPtr); SYS_TRAP(sysTrapMenuDispose);

Function MenuHandleEvent(menuP: MenuBarPtr; var Event{: EventType}; Var error: UInt16): Boolean;
  SYS_TRAP(sysTrapMenuHandleEvent);

Procedure MenuDrawMenu(menuP: MenuBarPtr); SYS_TRAP(sysTrapMenuDrawMenu);

Procedure MenuEraseStatus(menuP: MenuBarPtr); SYS_TRAP(sysTrapMenuEraseStatus);

Procedure MenuSetActiveMenuRscID(resourceId: UInt16); SYS_TRAP(sysTrapMenuSetActiveMenuRscID);

function MenuCmdBarAddButton(where: UInt8; bitmapId: UInt16;
  resultType: MenuCmdBarResultType; result: UInt32; nameP: String): Err; SYS_TRAP(sysTrapMenuCmdBarAddButton);

Function MenuCmdBarGetButtonData(buttonIndex: Int16; var bitmapIdP: UInt16;
  var resultTypeP: MenuCmdBarResultType; var resultP: UInt32; nameP: PChar): Boolean;
  SYS_TRAP(sysTrapMenuCmdBarGetButtonData);

Procedure MenuCmdBarDisplay; SYS_TRAP(sysTrapMenuCmdBarDisplay);

Function MenuShowItem(id: UInt16): Boolean; SYS_TRAP(sysTrapMenuShowItem);

Function MenuHideItem(id: UInt16): Boolean; SYS_TRAP(sysTrapMenuHideItem);

Function MenuAddItem(positionId: UInt16; id: UInt16; cmd: char; Const textP: String): Err;
  SYS_TRAP(sysTrapMenuAddItem);

implementation

end.

