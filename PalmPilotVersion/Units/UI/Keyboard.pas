/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Keyboard.h
 *
 * Description:
 *        This file defines the keyboard's  structures 
 *   and routines.
 *
 * History:
 *              March 29, 1995  Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Keyboard;

interface

Uses Chars;

Const kbdReturnKey    =linefeedChr;
Const kbdTabKey       =tabChr;
Const kbdBackspaceKey =backspaceChr;
Const kbdShiftKey     =2;
Const kbdCapsKey      =1;
Const kbdNoKey        =$FF;

Type
  KeyboardType = (
    kbdAlpha = 0,
    kbdNumbersAndPunc = 1,
    kbdAccent = 2,
    kbdDefault = 0xff    // based on graffiti mode (usually alphaKeyboard)
   );


/************************************************************
 * Keyboard procedures
 *************************************************************/

 // At some point the Graffiti code will need access to the
// shift and caps lock info.  Either export the structures
// or provide calls to the info.

Procedure SysKeyboardDialogV10;
                     SYS_TRAP(sysTrapSysKeyboardDialogV10);

Procedure SysKeyboardDialog (kbd: KeyboardType);
                     SYS_TRAP(sysTrapSysKeyboardDialog);

implementation

end.

