/******************************************************************************
 *
 * Copyright (c) 1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: UIColor.h
 *
 * Description:
 *      This file defines structs and functions for setting the "system
 *              colors" that the UI routines use.
 *
 * History:
 *              January 20, 1999        Created by Bob Ebert
 *              08/21/99        kwk     Added UIFieldFepRawText...UIFieldFepConvertedBackground
 *                                                      to the UIColorTableEntries enum.
 *              10/09/99        kwk     Added UIFieldFepUnderline to UIColorTableEntries enum.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit UIColor;

interface

Uses Window, Bitmap, Traps35;

Type
  UIColorTableEntries= (
    UIObjectFrame = 0,
    UIObjectFill,
    UIObjectForeground,
    UIObjectSelectedFill,
    UIObjectSelectedForeground,

    UIMenuFrame,
    UIMenuFill,
    UIMenuForeground,
    UIMenuSelectedFill,
    UIMenuSelectedForeground,

    UIFieldBackground,
    UIFieldText,
    UIFieldTextLines,
    UIFieldCaret,
    UIFieldTextHighlightBackground,
    UIFieldTextHighlightForeground,
    UIFieldFepRawText,
    UIFieldFepRawBackground,
    UIFieldFepConvertedText,
    UIFieldFepConvertedBackground,

    UIFormFrame,
    UIFormFill,

    UIDialogFrame,
    UIDialogFill,

    UIAlertFrame,
    UIAlertFill,

    UIOK,
    UICaution,
    UIWarning,

    UILastColorTableEntry
  );


//------------------------------------------------------------
// UI Color Table Manipulation Routines 
//------------------------------------------------------------

function UIColorGetTableEntryIndex(which: UIColorTableEntries): IndexedColorType;
  SYS_TRAP(sysTrapUIColorGetTableEntryIndex);

procedure UIColorGetTableEntryRGB(which: UIColorTableEntries; var rgbP: RGBColorType);
  SYS_TRAP(sysTrapUIColorGetTableEntryRGB);

Function UIColorSetTableEntry(which: UIColorTableEntries; var rgbP: RGBColorType): Err;
  SYS_TRAP(sysTrapUIColorSetTableEntry);

function UIColorPushTable: Err; SYS_TRAP(sysTrapUIColorPushTable);

function UIColorPopTable: Err; SYS_TRAP(sysTrapUIColorPopTable);


implementation

end.

