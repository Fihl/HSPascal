/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Table.h
 *
 * Description:
 *        This file defines table structures and routines.
 *
 * History:
 *              September 1, 1994       Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Table;

interface

Uses {$ifdef PalmVer35} Traps30, Traps35, {$endif}
     Field, Font, Rect;

  //-------------------------------------------------------------------
  // Table structures
  //-------------------------------------------------------------------

Const
  tableDefaultColumnSpacing    = 1;
  tableNoteIndicatorWidth      = 7;
  tableNoteIndicatorHeight     = 11;
  tableMaxTextItemSize         = 255; // does not incude terminating null

  tblUnusableRow               = $ffff;

Type
  // Display style of a table item
  //= tableItemStyles
  TableItemStyleType = ( checkboxTableItem,
                         customTableItem,
                         dateTableItem,
                         labelTableItem,
                         numericTableItem,
                         popupTriggerTableItem,
                         textTableItem,
                         textWithNoteTableItem,
                         timeTableItem,
                         narrowTextTableItem);

  TableItemPtr = ^TableItemType;
  TableItemType = Record
    itemType: TableItemStyleType;
    fontID: eFontID;    // font for drawing text
    intValue: Int16;
    ptr: PChar;
  end;

  // Draw item callback routine prototype, used only by customTableItem.
  //TableDrawItemFuncType  (void * tableP, Int16 row, Int16 column, RectangleType * bounds);
  TableDrawItemFuncPtr = Pointer; //^TableDrawItemFuncType;

  // Load data callback routine prototype
  // Err TableLoadDataFuncType
  //     (void * tableP, Int16 row, Int16 column, Boolean editable,
  //     MemHandle * dataH, Int16 * dataOffset, Int16 * dataSize, FieldPtr fld);
  TableLoadDataFuncPtr = Pointer; //^TableLoadDataFuncType;

  // Save data callback routine prototype
  // Boolean TableSaveDataFuncType(void * tableP, Int16 row, Int16 column);
  TableSaveDataFuncPtr = Pointer; //TableSaveDataFuncType^;

  TableColumnAttrType = Record
    width: Coord;             // width in pixels
    Flags: UInt16
    //reserved1   : 5;
    //masked      : 1;  // if both row + column masked, draw only grey box
    //editIndicator  : 1;
    //usable      : 1;
    //reserved2      : 8;
    spacing: Coord;              // space after column
    drawCallback: TableDrawItemFuncPtr;
    loadDataCallback: TableLoadDataFuncPtr;
    saveDataCallback: TableSaveDataFuncPtr;
  end;

  TableRowAttrType = Record
    id: UInt16;
    height: Coord;               // row height in pixels
    data: UInt32;

    Flags: UInt16;
    //reserved1      : 7;
    //usable      : 1;
    //reserved2      : 4;
    //masked      : 1;  // if both row + column masked, draw only grey box
    //invalid     : 1;  // true if redraw needed
    //staticHeight   : 1;  // Set if height does not expands as text is entered
    //selectable  : 1;

    reserved3: UInt16;
  end;

  TableAttrType = Record
    Flags: UInt16;
    //visible        :1;         // Set if drawn, used internally
    //editable       :1;         // Set if editable
    //editing        :1;         // Set if in edit mode
    //selected       :1;         // Set if the current item is selected
    //hasScrollBar   :1;                   // Set if the table has a scroll bar
    //reserved       :11;
  end;

  TablePtr = ^TableType;
  TableType = Record
    id: UInt16;
    bounds: RectangleType;
    attr: TableAttrType;
    numColumns: Int16
    numRows: Int16
    currentRow: Int16
    currentColumn: Int16
    topRow: Int16
    columnAttrs: ^TableColumnAttrType;
    rowAttrs: ^TableRowAttrType;
    items: TableItemPtr;
    currentField: FieldType
  end;

  //-------------------------------------------------------------------
  // Table routines
  //-------------------------------------------------------------------

Procedure TblDrawTable (var tableP: TableType);
                     SYS_TRAP(sysTrapTblDrawTable);

Procedure TblRedrawTable (var tableP: TableType);
                     SYS_TRAP(sysTrapTblRedrawTable);

Procedure TblEraseTable (var tableP: TableType);
                     SYS_TRAP(sysTrapTblEraseTable);

Function TblHandleEvent (var tableP: TableType; var Event{: EventType}): Boolean;
                     SYS_TRAP(sysTrapTblHandleEvent);

Procedure TblGetItemBounds (var tableP: TableType; row: Int16; column: Int16; var rP: RectangleType);
                     SYS_TRAP(sysTrapTblGetItemBounds);

Procedure TblSelectItem (var tableP: TableType; row: Int16; column: Int16);
                     SYS_TRAP(sysTrapTblSelectItem);

Function TblGetItemInt (var tableP: TableType; row: Int16; column: Int16): Int16;
                     SYS_TRAP(sysTrapTblGetItemInt);

Procedure TblSetItemInt (var tableP: TableType; row: Int16; column: Int16; value: Int16);
                     SYS_TRAP(sysTrapTblSetItemInt);

Procedure TblSetItemPtr (var tableP: TableType; row: Int16; column: Int16; var value);
                     SYS_TRAP(sysTrapTblSetItemPtr);

Procedure TblSetItemStyle (var tableP: TableType; row: Int16; column: Int16; Typ: TableItemStyleType);
                     SYS_TRAP(sysTrapTblSetItemStyle);

Procedure TblUnhighlightSelection (var tableP: TableType);
                     SYS_TRAP(sysTrapTblUnhighlightSelection);

Function TblRowUsable  (var tableP: TableType; row: Int16): Boolean;
                     SYS_TRAP(sysTrapTblRowUsable);

Procedure TblSetRowUsable (var tableP: TableType; row: Int16; usable: Boolean);
                     SYS_TRAP(sysTrapTblSetRowUsable);

Function TblGetLastUsableRow (var tableP: TableType): Int16;
                     SYS_TRAP(sysTrapTblGetLastUsableRow);

Procedure TblSetColumnUsable (var tableP: TableType; row: Int16; usable: Boolean);
                     SYS_TRAP(sysTrapTblSetColumnUsable);

Procedure TblSetRowSelectable (var tableP: TableType; row: Int16; selectable: Boolean);
                     SYS_TRAP(sysTrapTblSetRowSelectable);

Function TblRowSelectable (var tableP: TableType; row: Int16): Boolean;
                     SYS_TRAP(sysTrapTblRowSelectable);

Function TblGetNumberOfRows (var tableP: TableType): Int16;
                     SYS_TRAP(sysTrapTblGetNumberOfRows);

Procedure TblSetCustomDrawProcedure (var tableP: TableType; column: Int16;
   drawCallback: TableDrawItemFuncPtr);
                     SYS_TRAP(sysTrapTblSetCustomDrawProcedure);

Procedure TblSetLoadDataProcedure (var tableP: TableType; column: Int16;
   loadDataCallback: TableLoadDataFuncPtr);
                     SYS_TRAP(sysTrapTblSetLoadDataProcedure);

Procedure TblSetSaveDataProcedure (var tableP: TableType; column: Int16;
   saveDataCallback: TableSaveDataFuncPtr);
                     SYS_TRAP(sysTrapTblSetSaveDataProcedure);

Procedure TblGetBounds (var tableP: TableType; var rP: RectangleType);
                     SYS_TRAP(sysTrapTblGetBounds);

Procedure TblSetBounds (var tableP: TableType; var rp: RectangleType);
                     SYS_TRAP(sysTrapTblSetBounds);

Function TblGetRowHeight (var tableP: TableType; row: Int16): Coord;
                     SYS_TRAP(sysTrapTblGetRowHeight);

Procedure TblSetRowHeight (var tableP: TableType; row: Int16; height: Coord);
                     SYS_TRAP(sysTrapTblSetRowHeight);

Function TblGetColumnWidth (var tableP: TableType; column: Int16): Coord;
                     SYS_TRAP(sysTrapTblGetColumnWidth);

Procedure TblSetColumnWidth (var tableP: TableType; column: Int16; width: Coord);
                     SYS_TRAP(sysTrapTblSetColumnWidth);

Function TblGetColumnSpacing (var tableP: TableType; column: Int16): Coord;
                     SYS_TRAP(sysTrapTblGetColumnSpacing);

Procedure TblSetColumnSpacing (var tableP: TableType; column: Int16; spacing: Coord);
                     SYS_TRAP(sysTrapTblSetColumnSpacing);

Function TblFindRowID (var tableP: TableType; id: UInt16; var rowP: Int16): Boolean;
                     SYS_TRAP(sysTrapTblFindRowID);

Function TblFindRowData (var tableP: TableType; data: UInt32; var rowP: Int16): Boolean;
                     SYS_TRAP(sysTrapTblFindRowData);

Function TblGetRowID (var tableP: TableType; row: Int16): UInt16;
                     SYS_TRAP(sysTrapTblGetRowID);

Procedure TblSetRowID (var tableP: TableType; row: Int16; id: UInt16);
                     SYS_TRAP(sysTrapTblSetRowID);

Function TblGetRowData (var tableP: TableType; row: Int16): UInt32;
                     SYS_TRAP(sysTrapTblGetRowData);

Procedure TblSetRowData (var tableP: TableType; row: Int16; data: UInt32);
                     SYS_TRAP(sysTrapTblSetRowData);

Function TblRowInvalid (var tableP: TableType; row: Int16): Boolean;
                     SYS_TRAP(sysTrapTblRowInvalid);

Procedure TblMarkRowInvalid (var tableP: TableType; row: Int16);
                     SYS_TRAP(sysTrapTblMarkRowInvalid);

Procedure TblMarkTableInvalid (var tableP: TableType);
                     SYS_TRAP(sysTrapTblMarkTableInvalid);

Function TblGetSelection (var tableP: TableType; var rowP, columnP: Int16): Boolean;
                     SYS_TRAP(sysTrapTblGetSelection);

Procedure TblInsertRow (var tableP: TableType; row: Int16);
                     SYS_TRAP(sysTrapTblInsertRow);

Procedure TblRemoveRow (var tableP: TableType; row: Int16);
                     SYS_TRAP(sysTrapTblRemoveRow);

Procedure TblReleaseFocus (var tableP: TableType);
                     SYS_TRAP(sysTrapTblReleaseFocus);

Function TblEditing (var tableP: TableType): Boolean;
                     SYS_TRAP(sysTrapTblEditing);

Function TblGetCurrentField (var tableP: TableType): FieldPtr;
                     SYS_TRAP(sysTrapTblGetCurrentField);

Procedure TblGrabFocus (var tableP: TableType; row: Int16; column: Int16);
                     SYS_TRAP(sysTrapTblGrabFocus);

Procedure TblSetColumnEditIndicator (var tableP: TableType; column: Int16; editIndicator: Boolean);
                     SYS_TRAP(sysTrapTblSetColumnEditIndicator);

Procedure TblSetRowStaticHeight (var tableP: TableType; row: Int16; staticHeight: Boolean);
                     SYS_TRAP(sysTrapTblSetRowStaticHeight);

Procedure TblHasScrollBar (var tableP: TableType; hasScrollBar: Boolean);
                     SYS_TRAP(sysTrapTblHasScrollBar);

{$ifdef PalmVer35}
Function TblGetItemFont (var tableP: TableType; row: Int16; column: Int16): FontID;
                     SYS_TRAP(sysTrapTblGetItemFont);

Procedure TblSetItemFont (var tableP: TableType; row: Int16; column: Int16; _fontID: FontID);
                     SYS_TRAP(sysTrapTblSetItemFont);

Function TblGetItemPtr (var tableP: TableType; row: Int16; column: Int16): Pointer;
                     SYS_TRAP(sysTrapTblGetItemPtr);

Function TblRowMasked  (var tableP: TableType; row: Int16): Boolean;
                     SYS_TRAP(sysTrapTblRowMasked);

Procedure TblSetRowMasked  (var tableP: TableType; row: Int16; masked: Boolean);
                     SYS_TRAP(sysTrapTblSetRowMasked);

Procedure TblSetColumnMasked  (var tableP: TableType; row: Int16; masked: Boolean);
                     SYS_TRAP(sysTrapTblSetColumnMasked);

{$endif}

implementation

end.

