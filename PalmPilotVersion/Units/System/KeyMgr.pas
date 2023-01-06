/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: KeyMgr.h
 *
 * Description:
 *    Include file for Key manager
 *
 * History:
 *    9/13/95 Created by Ron Marianetti
 *    2/04/98  srj-  added contrast key defines
 *    8/23/98  SCL-  Cross-merged 3.1 and 3.2
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit KeyMgr;

interface


/********************************************************************
 * Definition of bit field returned from KeyCurrentState
 ********************************************************************/
Const
  keyBitPower       =0x0001;      // Power key
  keyBitPageUp      =0x0002;      // Page-up
  keyBitPageDown    =0x0004;      // Page-down
  keyBitHard1       =0x0008;      // App #1
  keyBitHard2       =0x0010;      // App #2
  keyBitHard3       =0x0020;      // App #3
  keyBitHard4       =0x0040;      // App #4
  keyBitCradle      =0x0080;      // Button on cradle
  keyBitAntenna     =0x0100;      // Antenna "key" <chg 3-31-98 RM>
  keyBitContrast    =0x0200;      // Contrast key

  keyBitsAll        =0xFFFFFFFF;  // all keys

  slowestKeyDelayRate   =0xff;
  slowestKeyPeriodRate  =0xff;


/********************************************************************
 * Key manager Routines
 ********************************************************************/

// Set/Get the auto-key repeat rate
Function KeyRates(DoSet: Boolean;
                  var initDelayP, periodP, doubleTapDelayP: UInt16;
                  var queueAheadP: Boolean): Err;
                     SYS_TRAP(sysTrapKeyRates);

// Get the current state of the hardware keys
// This is now updated every tick, even when more than 1 key is held down.
Function KeyCurrentState: UInt32;
                     SYS_TRAP(sysTrapKeyCurrentState);

// Set the state of the hardware key mask which controls if the key
// generates a keyDownEvent
Function KeySetMask(keyMask: UInt32): UInt32;
                     SYS_TRAP(sysTrapKeySetMask);

implementation

end.

