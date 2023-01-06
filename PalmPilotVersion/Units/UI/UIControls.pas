/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: UIControls.h
 *
 * Description:
 *              Contrast & brightness control for devices with
 *                                              software contrast.
 *
 * History:
 *                      Name    Date            Description
 *                      ----    ----            -----------
 *                      bob     02/12/98        Initial version
 *                      bob     03/15/99        Added brightness
 *                      bob     08/27/99        Added UIPickColor, renamed UIControls.h
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit UIControls;

interface

Uses {$ifdef PalmVer35} Traps31, Traps35, {$endif}
     BitMap, Window;

// for UIPickColor
Const
  UIPickColorStartPalette  =0;
  UIPickColorStartRGB      =1;

Type
  UIPickColorStartType= UInt16;

{$ifdef PalmVer35}
Procedure UIContrastAdjust;             SYS_TRAP(sysTrapUIContrastAdjust);

Procedure UIBrightnessAdjust;           SYS_TRAP(sysTrapUIBrightnessAdjust);

Function UIPickColor(var indexP: IndexedColorType; var rgbP: RGBColorType;
   start: UIPickColorStartType; titleP, tipP: String): Boolean;
                                        SYS_TRAP(sysTrapUIPickColor);
{$endif}

implementation

end.

