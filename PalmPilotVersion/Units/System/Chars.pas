/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Chars.h
 *
 * Description:
 *        This file defines the characters in fonts.
 *
 * History:
 *    November 3, 1994  Created by Roger Flores
 *    11/03/94 rsf   Created by Roger Flores.
 *    04/21/99 JFS   Added list of virtual command key ranges reserved
 *                   for use by licensees.
 *    09/13/99 kwk   Added vchrTsmMode.
 *    10/28/99 kwk   Defined vchrPageUp and vchrPageDown.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Chars;

interface

// Standard Unicode 2.0 names for the ascii characters. These exist in
// all of the text fonts, no matter what character encoding is being
// used by PalmOS.

Const
  chrNull                   =0x0000;
  chrStartOfHeading         =0x0001;
  chrStartOfText            =0x0002;
  chrEndOfText              =0x0003;
  chrEndOfTransmission      =0x0004;
  chrEnquiry                =0x0005;
  chrAcknowledge            =0x0006;
  chrBell                   =0x0007;
  chrBackspace              =0x0008;
  chrHorizontalTabulation   =0x0009;
  chrLineFeed               =0x000A;
  chrVerticalTabulation     =0x000B;
  chrFormFeed               =0x000C;
  chrCarriageReturn         =0x000D;
  chrShiftOut               =0x000E;
  chrShiftIn                =0x000F;
  chrDataLinkEscape         =0x0010;
  chrDeviceControlOne       =0x0011;
  chrDeviceControlTwo       =0x0012;
  chrDeviceControlThree     =0x0013;
  chrDeviceControlFour      =0x0014;
  chrNegativeAcknowledge    =0x0015;
  chrSynchronousIdle        =0x0016;
  chrEndOfTransmissionBlock =0x0017;
  chrCancel                 =0x0018;
  chrEndOfMedium            =0x0019;
  chrSubstitute             =0x001A;
  chrEscape                 =0x001B;
  chrFileSeparator          =0x001C;
  chrGroupSeparator         =0x001D;
  chrRecordSeparator        =0x001E;
  chrUnitSeparator          =0x001F;
  chrSpace                  =0x0020;
  chrExclamationMark        =0x0021;
  chrQuotationMark          =0x0022;
  chrNumberSign             =0x0023;
  chrDollarSign             =0x0024;
  chrPercentSign            =0x0025;
  chrAmpersand              =0x0026;
  chrApostrophe             =0x0027;
  chrLeftParenthesis        =0x0028;
  chrRightParenthesis       =0x0029;
  chrAsterisk               =0x002A;
  chrPlusSign               =0x002B;
  chrComma                  =0x002C;
  chrHyphenMinus            =0x002D;
  chrFullStop               =0x002E;
  chrSolidus                =0x002F;
  chrDigitZero              =0x0030;
  chrDigitOne               =0x0031;
  chrDigitTwo               =0x0032;
  chrDigitThree             =0x0033;
  chrDigitFour              =0x0034;
  chrDigitFive              =0x0035;
  chrDigitSix               =0x0036;
  chrDigitSeven             =0x0037;
  chrDigitEight             =0x0038;
  chrDigitNine              =0x0039;
  chrColon                  =0x003A;
  chrSemicolon              =0x003B;
  chrLessThanSign           =0x003C;
  chrEqualsSign             =0x003D;
  chrGreaterThanSign        =0x003E;
  chrQuestionMark           =0x003F;
  chrCommercialAt           =0x0040;
  chrCapital_A              =0x0041;
  chrCapital_B              =0x0042;
  chrCapital_C              =0x0043;
  chrCapital_D              =0x0044;
  chrCapital_E              =0x0045;
  chrCapital_F              =0x0046;
  chrCapital_G              =0x0047;
  chrCapital_H              =0x0048;
  chrCapital_I              =0x0049;
  chrCapital_J              =0x004A;
  chrCapital_K              =0x004B;
  chrCapital_L              =0x004C;
  chrCapital_M              =0x004D;
  chrCapital_N              =0x004E;
  chrCapital_O              =0x004F;
  chrCapital_P              =0x0050;
  chrCapital_Q              =0x0051;
  chrCapital_R              =0x0052;
  chrCapital_S              =0x0053;
  chrCapital_T              =0x0054;
  chrCapital_U              =0x0055;
  chrCapital_V              =0x0056;
  chrCapital_W              =0x0057;
  chrCapital_X              =0x0058;
  chrCapital_Y              =0x0059;
  chrCapital_Z              =0x005A;
  chrLeftSquareBracket      =0x005B;
  chrReverseSolidus      =0x005C; //(not in Japanese fonts)
  chrRightSquareBracket     =0x005D;
  chrCircumflexAccent       =0x005E;
  chrLowLine                =0x005F;
  chrGraveAccent            =0x0060;
  chrSmall_A                =0x0061;
  chrSmall_B                =0x0062;
  chrSmall_C                =0x0063;
  chrSmall_D                =0x0064;
  chrSmall_E                =0x0065;
  chrSmall_F                =0x0066;
  chrSmall_G                =0x0067;
  chrSmall_H                =0x0068;
  chrSmall_I                =0x0069;
  chrSmall_J                =0x006A;
  chrSmall_K                =0x006B;
  chrSmall_L                =0x006C;
  chrSmall_M                =0x006D;
  chrSmall_N                =0x006E;
  chrSmall_O                =0x006F;
  chrSmall_P                =0x0070;
  chrSmall_Q                =0x0071;
  chrSmall_R                =0x0072;
  chrSmall_S                =0x0073;
  chrSmall_T                =0x0074;
  chrSmall_U                =0x0075;
  chrSmall_V                =0x0076;
  chrSmall_W                =0x0077;
  chrSmall_X                =0x0078;
  chrSmall_Y                =0x0079;
  chrSmall_Z                =0x007A;
  chrLeftCurlyBracket       =0x007B;
  chrVerticalLine           =0x007C;
  chrRightCurlyBracket      =0x007D;
  chrTilde                  =0x007E;
  chrDelete                 =0x007F;


// Special meanings given to characters by the PalmOS
  chrPageUp              =chrVerticalTabulation;      // 0x000B
  chrPageDown            =chrFormFeed;                // 0x000C
  chrOtaSecure           =chrDeviceControlFour;       // 0x0014
  chrOta                 =chrNegativeAcknowledge;     // 0x0015
  chrCommandStroke       =chrSynchronousIdle;         // 0x0016
  chrShortcutStroke      =chrEndOfTransmissionBlock;  // 0x0017
  chrEllipsis            =chrCancel;                  // 0x0018
  chrNumericSpace        =chrEndOfMedium;             // 0x0019
  chrLeftArrow           =chrFileSeparator;           // 0x001C
  chrRightArrow          =chrGroupSeparator;          // 0x001D
  chrUpArrow             =chrRecordSeparator;         // 0x001E
  chrDownArrow           =chrUnitSeparator;           // 0x001F


//  The following are key codes used for virtual events, like
//   low battery warnings, etc. These keyboard events MUST
//   have the commandKeyMask bit set in the modifiers in order
//   to be recognized.
  vchrLowBattery         =0x0101;      // Display low battery dialog
  vchrEnterDebugger      =0x0102;      // Enter Debugger
  vchrNextField          =0x0103;      // Go to next field in form
  vchrStartConsole       =0x0104;      // Startup console task
  vchrMenu               =0x0105;      // Ctl-A
  vchrCommand            =0x0106;      // Ctl-C
  vchrConfirm            =0x0107;      // Ctl-D
  vchrLaunch             =0x0108;      // Ctl-E
  vchrKeyboard           =0x0109;      // Ctl-F popup the keyboard in appropriate mode
  vchrFind               =0x010A;
  vchrCalc               =0x010B;
  vchrPrevField          =0x010C;
  vchrAlarm              =0x010D;      // sent before displaying an alarm
  vchrRonamatic          =0x010E;      // stroke from graffiti area to top half of screen
  vchrGraffitiReference  =0x010F;      // popup the Graffiti reference
  vchrKeyboardAlpha      =0x0110;      // popup the keyboard in alpha mode
  vchrKeyboardNumeric    =0x0111;      // popup the keyboard in number mode
  vchrLock               =0x0112;      // switch to the Security app and lock the device
  vchrBacklight          =0x0113;      // toggle state of backlight
  vchrAutoOff            =0x0114;      // power off due to inactivity timer
// Added for PalmOS 3.0
  vchrExgTest            =0x0115;      // put exchange Manager into test mode (&.t)
  vchrSendData           =0x0116;      // Send data if possible
  vchrIrReceive          =0x0117;      // Initiate an Ir receive manually (&.i)
// Added for PalmOS 3.1
  vchrTsm1               =0x0118;      // Text Services silk-screen button
  vchrTsm2               =0x0119;      // Text Services silk-screen button
  vchrTsm3               =0x011A;      // Text Services silk-screen button
  vchrTsm4               =0x011B;      // Text Services silk-screen button 
// Added for PalmOS 3.2
  vchrRadioCoverageOK    =0x011C;      // Radio coverage check successful
  vchrRadioCoverageFail  =0x011D;      // Radio coverage check failure
  vchrPowerOff           =0x011E;      // Posted after autoOffChr or hardPowerChr
                                             // to put system to sleep with SysSleep.
// Added for PalmOS 3.5
  vchrResumeSleep        =0x011F;      // Posted by NotifyMgr clients after they
                                             // have deferred a sleep request in order 
                                             // to resume it.
  vchrLateWakeup         =0x0120;      // Posted by the system after waking up
                                             // to broadcast a late wakeup notification.
                                             // FOR SYSTEM USE ONLY
  vchrTsmMode            =0x0121;      // Posted by TSM to trigger mode change.

// The application launching buttons generate the following
// key codes and will also set the commandKeyMask bit in the
// modifiers field
  vchrHardKeyMin         =0x0200;
  vchrHardKeyMax         =0x02FF;         // 256 hard keys

  vchrHard1              =0x0204;
  vchrHard2              =0x0205;
  vchrHard3              =0x0206;
  vchrHard4              =0x0207;
  vchrHardPower          =0x0208;
  vchrHardCradle         =0x0209;         // Button on cradle pressed
  vchrHardCradle2        =0x020A;         // Button on cradle pressed and hwrDockInGeneric1
                                                // input on dock asserted (low).
  vchrHardContrast       =0x020B;         // Sumo's Contrast button
  vchrHardAntenna        =0x020C;         // Eleven's Antenna switch



// The following keycode RANGES are reserved for use by licensees.
// All have the commandKeyMask bit set in the event's modifiers field.
// Note that ranges include the Min and Max values themselves (i.e. key
// codes >= min and <= max are assigned to the following licensees).
//
//    Qualcomm
  vchrThumperMin         =0x0300;
  vchrThumperMax         =0x03FF;         // 256 command keys

//    Motorola
  vchrCessnaMin          =0x14CD;
  vchrCessnaMax          =0x14CD;         //   1 command key

//    TRG
  vchrCFlashMin          =0x1500;
  vchrCFlashMax          =0x150F;         //   16 command keys

//    Symbol
  vchrSPTMin             =0x15A0;
  vchrSPTMax             =0x15AF;         //  16 command keys

//    Handspring
  vchrSlinkyMin          =0x1600;
  vchrSlinkyMax          =0x16FF;         // 256 command keys



// Old names for some of the characters.
  nullChr                =chrNull;                    // 0x0000
  backspaceChr           =chrBackspace;               // 0x0008
  tabChr                 =chrHorizontalTabulation;    // 0x0009
  linefeedChr            =chrLineFeed;                // 0x000A
  pageUpChr              =chrPageUp;                  // 0x000B
  pageDownChr            =chrPageDown;                // 0x000C
  crChr                  =chrCarriageReturn;          // 0x000D
  returnChr              =chrCarriageReturn;          // 0x000D
  otaSecureChr           =chrOtaSecure;               // 0x0014
  otaChr                 =chrOta;                     // 0x0015

  escapeChr              =chrEscape;                  // 0x001B
  leftArrowChr           =chrLeftArrow;               // 0x001C
  rightArrowChr          =chrRightArrow;              // 0x001D
  upArrowChr             =chrUpArrow;                 // 0x001E
  downArrowChr           =chrDownArrow;               // 0x001F
  spaceChr               =chrSpace;                   // 0x0020
  quoteChr               =chrQuotationMark;           // 0x0022 '"'
  commaChr               =chrComma;                   // 0x002C ','
  periodChr              =chrFullStop;                // 0x002E '.'
  colonChr               =chrColon;                   // 0x003A ':'
  lowBatteryChr          =vchrLowBattery;             // 0x0101
  enterDebuggerChr       =vchrEnterDebugger;          // 0x0102
  nextFieldChr           =vchrNextField;              // 0x0103
  startConsoleChr        =vchrStartConsole;           // 0x0104
  menuChr                =vchrMenu;                   // 0x0105
  commandChr             =vchrCommand;                // 0x0106
  confirmChr             =vchrConfirm;                // 0x0107
  launchChr              =vchrLaunch;                 // 0x0108
  keyboardChr            =vchrKeyboard;               // 0x0109
  findChr                =vchrFind;                   // 0x010A
  calcChr                =vchrCalc;                   // 0x010B
  prevFieldChr           =vchrPrevField;              // 0x010C
  alarmChr               =vchrAlarm;                  // 0x010D
  ronamaticChr           =vchrRonamatic;              // 0x010E
  graffitiReferenceChr   =vchrGraffitiReference;      // 0x010F
  keyboardAlphaChr       =vchrKeyboardAlpha;          // 0x0110
  keyboardNumericChr     =vchrKeyboardNumeric;        // 0x0111
  lockChr                =vchrLock;                   // 0x0112
  backlightChr           =vchrBacklight;              // 0x0113
  autoOffChr             =vchrAutoOff;                // 0x0114
  exgTestChr             =vchrExgTest;                // 0x0115
  sendDataChr            =vchrSendData;               // 0x0116
  irReceiveChr           =vchrIrReceive;              // 0x0117
  radioCoverageOKChr     =vchrRadioCoverageOK;        // 0x011C
  radioCoverageFailChr   =vchrRadioCoverageFail;      // 0x011D
  powerOffChr            =vchrPowerOff;               // 0x011E
  resumeSleepChr         =vchrResumeSleep;            // 0x011F
  lateWakeupChr          =vchrLateWakeup;             // 0x0120
  hardKeyMin             =vchrHardKeyMin;             // 0x0200
  hardKeyMax             =vchrHardKeyMax;             // 0x02FF
  hard1Chr               =vchrHard1;                  // 0x0204
  hard2Chr               =vchrHard2;                  // 0x0205
  hard3Chr               =vchrHard3;                  // 0x0206
  hard4Chr               =vchrHard4;                  // 0x0207
  hardPowerChr           =vchrHardPower;              // 0x0208
  hardCradleChr          =vchrHardCradle;             // 0x0209
  hardCradle2Chr         =vchrHardCradle2;            // 0x020A
  hardContrastChr        =vchrHardContrast;           // 0x020B
  hardAntennaChr         =vchrHardAntenna;            // 0x020C

// Macros to determine correct character code to use for drawing numeric space
// and horizontal ellipsis.

(********
#define ChrNumericSpace(chP)                                           \
   do {                                                                 \
      UInt32 attribute;                                                 \
      if ((FtrGet(sysFtrCreator, sysFtrNumROMVersion, &attribute) == 0) \
      && (attribute >= sysMakeROMVersion(3, 1, 0, 0, 0))) {             \
         *(chP) = chrNumericSpace;                                      \
      } else {                                                          \
         *(chP) = 0x80;                                                 \
      }                                                                 \
   } while (0)

#define ChrHorizEllipsis(chP)                                          \
   do {                                                                 \
      UInt32 attribute;                                                 \
      if ((FtrGet(sysFtrCreator, sysFtrNumROMVersion, &attribute) == 0) \
      && (attribute >= sysMakeROMVersion(3, 1, 0, 0, 0))) {             \
         *(chP) = chrEllipsis;                                          \
      } else {                                                          \
         *(chP) = 0x85;                                                 \
      }                                                                 \
   } while (0)
(*******************)


Type
// Characters in the 9 point symbol font.  Resource ID 9003
  symbolChars = (
   symbolLeftArrow = 3,
   symbolRightArrow,
   symbolUpArrow,
   symbolDownArrow,
   symbolSmallDownArrow,
   symbolSmallUpArrow,
   symbolMemo = 9,
   symbolHelp,
   symbolNote,
   symbolNoteSelected,
   symbolCapsLock,
   symbolNumLock,
   symbolShiftUpper,
   symbolShiftPunc,
   symbolShiftExt,
   symbolShiftNone,
   symbolNoTime,
   symbolAlarm,
   symbolRepeat,
   symbolCheckMark,
   // These next four characters were moved from the 0x8D..0x90
   // range in the main fonts to the 9pt Symbol font in PalmOS 3.1
   symbolDiamondChr,
   symbolClubChr,
   symbolHeartChr,
   symbolSpadeChr
  );

// Character in the 7 point symbol font.  Resource ID 9005
  symbol7Chars = (
   symbol7ScrollUp = 1,
   symbol7ScrollDown,
   symbol7ScrollUpDisabled,
   symbol7ScrollDownDisabled
  );

// Characters in the 11 point symbol font.  Resource ID 9004
  symbol11Chars = (
   symbolCheckboxOff = 0,
   symbolCheckboxOn,
   symbol11LeftArrow,
   symbol11RightArrow,
   symbol11LeftArrowDisabled,    // New for Palm OS v3.2
   symbol11RightArrowDisabled    // New for Palm OS v3.2
  );

implementation

end.

