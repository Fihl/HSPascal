/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: CharLatin.h
 *
 * Description:
 *       This file defines the characters found in the Palm OS Latin
 *       character encoding, which is based on the Microsoft code page
 *       1252 character encoding (Microsoft extension to ISO 8859-1
 *       character encoding).
 *
 * History:
 *    March 5th, 1998   Created by Ken Krugler
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit CharLatin;

interface

/***********************************************************************
 * Public constants
 ***********************************************************************/

// Characters found in Chars.h are guaranteed to exist in the regular
// (stdFont, boldFont, largeFont, largeBoldFont) fonts on the device,
// even if the character encoding supported by the device is not Latin.

// The characters listed below are those from the Palm OS Latin character
// encoding which are not part of every possible character encoding that
// will be supported by the Palm OS, and thus should ONLY be used when
// you have first verified that the device's character encoding is
//
// Characters that are part of code page 1252, but not guaranteed
// to exist in every possible PalmOS encoding. These names are based on
// the Unicode 2.0 standard.

Const
  chrReverseSolidus                =0x005C;   // Is yen char in Japanese fonts.

  chrEuroSign                         =0x0080;   // Was numeric space (valid thru 3.2)
// Undefined                           0x0081
  chrSingleLow9QuotationMark          =0x0082;
  chrSmall_F_Hook                     =0x0083;
  chrDoubleLow9QuotationMark          =0x0084;
  chrHorizontalEllipsis               =0x0085;   // Also at 0x18 in 3.1 and later roms.
  chrDagger                           =0x0086;
  chrDoubleDagger                     =0x0087;
  chrModifierCircumflexAccent         =0x0088;
  chrPerMilleSign                     =0x0089;
  chrCapital_S_Caron                  =0x008A;
  chrSingleLeftPointingAngleQuotationMark   =0x008B;
  chrCapital_OE                       =0x008C;
// Undefined                           0x008D   // Was diamondChr (valid thru 3.0)
// Undefined                           0x008E   // Was clubChr (valid thru 3.0)
                                          // Will become chrCapital_Z_Caron
// Undefined                           0x008F   // Was heartChr (valid thru 3.0)
// Undefined                           0x0090   // Was spadeChr (valid thru 3.0)
  chrLeftSingleQuotationMark          =0x0091;
  chrRightSingleQuotationMark         =0x0092;
  chrLeftDoubleQuotationMark          =0x0093;
  chrRightDoubleQuotationMark         =0x0094;
  chrBullet                           =0x0095;
  chrEnDash                           =0x0096;
  chrEmDash                           =0x0097;
  chrSmallTilde                       =0x0098;
  chrTradeMarkSign                    =0x0099;
  chrSmall_S_Caron                    =0x009A;
  chrSingleRightPointingAngleQuotationMark =0x009B;
  chrSmall_OE                         =0x009C;
// Undefined                           0x009D   // Was command stroke (valid thru 3.0)
// Undefined                           0x009E   // Was shortcut stroke (valid thru 3.0)
                                          // Will become chrSmall_Z_Caron
  chrCapital_Y_Diaeresis              =0x009F;
  chrNoBreakSpace                     =0x00A0;
  chrInvertedExclamationMark          =0x00A1;
  chrCentSign                         =0x00A2;
  chrPoundSign                        =0x00A3;
  chrCurrencySign                     =0x00A4;
  chrYenSign                          =0x00A5;
  chrBrokenBar                        =0x00A6;
  chrSectionSign                      =0x00A7;
  chrDiaeresis                        =0x00A8;
  chrCopyrightSign                    =0x00A9;
  chrFeminineOrdinalIndicator         =0x00AA;
  chrLeftPointingDoubleAngleQuotationMark   =0x00AB;
  chrNotSign                          =0x00AC;
  chrSoftHyphen                       =0x00AD;
  chrRegisteredSign                   =0x00AE;
  chrMacron                           =0x00AF;
  chrDegreeSign                       =0x00B0;
  chrPlusMinusSign                    =0x00B1;
  chrSuperscriptTwo                   =0x00B2;
  chrSuperscriptThree                 =0x00B3;
  chrAcuteAccent                      =0x00B4;
  chrMicroSign                        =0x00B5;
  chrPilcrowSign                      =0x00B6;
  chrMiddleDot                        =0x00B7;
  chrCedilla                          =0x00B8;
  chrSuperscriptOne                   =0x00B9;
  chrMasculineOrdinalIndicator        =0x00BA;
  chrRightPointingDoubleAngleQuotationMark =0x00BB;
  chrVulgarFractionOneQuarter         =0x00BC;
  chrVulgarFractionOneHalf            =0x00BD;
  chrVulgarFractionThreeQuarters      =0x00BE;
  chrInvertedQuestionMark             =0x00BF;
  chrCapital_A_Grave                  =0x00C0;
  chrCapital_A_Acute                  =0x00C1;
  chrCapital_A_Circumflex             =0x00C2;
  chrCapital_A_Tilde                  =0x00C3;
  chrCapital_A_Diaeresis              =0x00C4;
  chrCapital_A_RingAbove              =0x00C5;
  chrCapital_AE                       =0x00C6;
  chrCapital_C_Cedilla                =0x00C7;
  chrCapital_E_Grave                  =0x00C8;
  chrCapital_E_Acute                  =0x00C9;
  chrCapital_E_Circumflex             =0x00CA;
  chrCapital_E_Diaeresis              =0x00CB;
  chrCapital_I_Grave                  =0x00CC;
  chrCapital_I_Acute                  =0x00CD;
  chrCapital_I_Circumflex             =0x00CE;
  chrCapital_I_Diaeresis              =0x00CF;
  chrCapital_Eth                      =0x00D0;
  chrCapital_N_Tilde                  =0x00D1;
  chrCapital_O_Grave                  =0x00D2;
  chrCapital_O_Acute                  =0x00D3;
  chrCapital_O_Circumflex             =0x00D4;
  chrCapital_O_Tilde                  =0x00D5;
  chrCapital_O_Diaeresis              =0x00D6;
  chrMultiplicationSign               =0x00D7;
  chrCapital_O_Stroke                 =0x00D8;
  chrCapital_U_Grave                  =0x00D9;
  chrCapital_U_Acute                  =0x00DA;
  chrCapital_U_Circumflex             =0x00DB;
  chrCapital_U_Diaeresis              =0x00DC;
  chrCapital_Y_Acute                  =0x00DD;
  chrCapital_Thorn                    =0x00DE;
  chrSmall_SharpS                     =0x00DF;
  chrSmall_A_Grave                    =0x00E0;
  chrSmall_A_Acute                    =0x00E1;
  chrSmall_A_Circumflex               =0x00E2;
  chrSmall_A_Tilde                    =0x00E3;
  chrSmall_A_Diaeresis                =0x00E4;
  chrSmall_A_RingAbove                =0x00E5;
  chrSmall_AE                         =0x00E6;
  chrSmall_C_Cedilla                  =0x00E7;
  chrSmall_E_Grave                    =0x00E8;
  chrSmall_E_Acute                    =0x00E9;
  chrSmall_E_Circumflex               =0x00EA;
  chrSmall_E_Diaeresis                =0x00EB;
  chrSmall_I_Grave                    =0x00EC;
  chrSmall_I_Acute                    =0x00ED;
  chrSmall_I_Circumflex               =0x00EE;
  chrSmall_I_Diaeresis                =0x00EF;
  chrSmall_Eth                        =0x00F0;
  chrSmall_N_Tilde                    =0x00F1;
  chrSmall_O_Grave                    =0x00F2;
  chrSmall_O_Acute                    =0x00F3;
  chrSmall_O_Circumflex               =0x00F4;
  chrSmall_O_Tilde                    =0x00F5;
  chrSmall_O_Diaeresis                =0x00F6;
  chrDivisionSign                     =0x00F7;
  chrSmall_O_Stroke                   =0x00F8;
  chrSmall_U_Grave                    =0x00F9;
  chrSmall_U_Acute                    =0x00FA;
  chrSmall_U_Circumflex               =0x00FB;
  chrSmall_U_Diaeresis                =0x00FC;
  chrSmall_Y_Acute                    =0x00FD;
  chrSmall_Thorn                      =0x00FE;
  chrSmall_Y_Diaeresis                =0x00FF;

// Alternative names for some characters.

  chrBackslash                        =chrReverseSolidus;
  chrNonBreakingSpace                 =chrNoBreakSpace;

// Old character names.
(*******************!!
  lowSingleCommaQuoteChr=chrSingleLow9QuotationMark; // 0x0082
  scriptFChr            =chrSmall_F_Hook;            // 0x0083
  lowDblCommaQuoteChr   =chrDoubleLow9QuotationMark; // 0x0084
  daggerChr             =chrDagger;                  // 0x0086
  dblDaggerChr          =chrDoubleDagger;            // 0x0087
  circumflexChr         =chrModifierCircumflexAccent;// 0x0088
  perMilleChr           =chrPerMilleSign;            // 0x0089
  upSHacekChr           =chrCapital_S_Caron;         // 0x008A
  leftSingleGuillemetChr   =chrSingleLeftPointingAngleQuotationMark;   // 0x008B
  upOEChr               =chrCapital_OE;              // 0x008C
  singleOpenCommaQuoteChr  =chrLeftSingleQuotationMark; // 0x0091
  singleCloseCommaQuoteChr =chrRightSingleQuotationMark; // 0x0092
  dblOpenCommaQuoteChr  =chrLeftDoubleQuotationMark; // 0x0093
  dblCloseCommaQuoteChr =chrRightDoubleQuotationMark;// 0x0094
  bulletChr             =chrBullet;                  // 0x0095
  enDashChr             =chrEnDash;                  // 0x0096
  emDashChr             =chrEmDash;                  // 0x0097
  spacingTildeChr       =chrSmallTilde;              // 0x0098
  trademarkChr          =chrTradeMarkSign;           // 0x0099
  lowSHacekChr          =chrSmall_S_Caron;           // 0x009A
  rightSingleGuillemetChr  =chrSingleRightPointingAngleQuotationMark; // 0x009B
  lowOEChr              =chrSmall_OE;                // 0x009C
  upYDiaeresisChr       =chrCapital_Y_Diaeresis;     // 0x009F
  nonBreakSpaceChr      =chrNoBreakSpace;            // 0x00A0
  invertedExclamationChr   =chrInvertedExclamationMark; // 0x00A1
  centChr               =chrCentSign;                // 0x00A2
  poundChr              =chrPoundSign;               // 0x00A3
  currencyChr           =chrCurrencySign;            // 0x00A4
  yenChr                =chrYenSign;                 // 0x00A5
  brokenVertBarChr      =chrBrokenBar;               // 0x00A6
  sectionChr            =chrSectionSign;             // 0x00A7
  spacingDiaeresisChr   =chrDiaeresis;               // 0x00A8
  copyrightChr          =chrCopyrightSign;           // 0x00A9
  feminineOrdinalChr    =chrFeminineOrdinalIndicator;   // 0x00AA
  leftGuillemetChr      =chrLeftPointingDoubleAngleQuotationMark; // 0x00AB
  notChr                =chrNotSign                  // 0x00AC
  softHyphenChr         =chrSoftHyphen;              // 0x00AD
  registeredChr         =chrRegisteredSign;          // 0x00AE
  spacingMacronChr      =chrMacron;                  // 0x00AF
  degreeChr             =chrDegreeSign;              // 0x00B0
  plusMinusChr          =chrPlusMinusSign;           // 0x00B1
  superscript2Chr       =chrSuperscriptTwo;          // 0x00B2
  superscript3Chr       =chrSuperscriptThree;        // 0x00B3
  spacingAcuteChr       =chrAcuteAccent;             // 0x00B4
  microChr              =chrMicroSign;               // 0x00B5
  paragraphChr          =chrPilcrowSign;             // 0x00B6
  middleDotChr          =chrMiddleDot;               // 0x00B7
  spacingCedillaChr     =chrCedilla;                 // 0x00B8
  superscript1Chr       =chrSuperscriptOne;          // 0x00B9
  masculineOrdinalChr      =chrMasculineOrdinalIndicator; // 0x00BA
  rightGuillemetChr     =chrRightPointingDoubleAngleQuotationMark; // 0x00BB
  fractOneQuarterChr    =chrVulgarFractionOneQuarter;   // 0x00BC
  fractOneHalfChr       =chrVulgarFractionOneHalf;   // 0x00BD
  fractThreeQuartersChr =chrVulgarFractionThreeQuarters; // 0x00BE
  invertedQuestionChr      =chrInvertedQuestionMark;    // 0x00BF
  upAGraveChr           =chrCapital_A_Grave;         // 0x00C0
  upAAcuteChr           =chrCapital_A_Acute;         // 0x00C1
  upACircumflexChr      =chrCapital_A_Circumflex;    // 0x00C2
  upATildeChr           =chrCapital_A_Tilde;         // 0x00C3
  upADiaeresisChr       =chrCapital_A_Diaeresis;     // 0x00C4
  upARingChr            =chrCapital_A_RingAbove;     // 0x00C5
  upAEChr               =chrCapital_AE;              // 0x00C6
  upCCedillaChr         =chrCapital_C_Cedilla;       // 0x00C7
  upEGraveChr           =chrCapital_E_Grave;         // 0x00C8
  upEAcuteChr           =chrCapital_E_Acute;         // 0x00C9
  upECircumflexChr      =chrCapital_E_Circumflex;    // 0x00CA
  upEDiaeresisChr       =chrCapital_E_Diaeresis;     // 0x00CB
  upIGraveChr           =chrCapital_I_Grave;         // 0x00CC
  upIAcuteChr           =chrCapital_I_Acute;         // 0x00CD
  upICircumflexChr      =chrCapital_I_Circumflex;    // 0x00CE
  upIDiaeresisChr       =chrCapital_I_Diaeresis;     // 0x00CF
  upEthChr              =chrCapital_Eth;             // 0x00D0
  upNTildeChr           =chrCapital_N_Tilde;         // 0x00D1
  upOGraveChr           =chrCapital_O_Grave;         // 0x00D2
  upOAcuteChr           =chrCapital_O_Acute;         // 0x00D3
  upOCircumflexChr      =chrCapital_O_Circumflex;    // 0x00D4
  upOTildeChr           =chrCapital_O_Tilde;         // 0x00D5
  upODiaeresisChr       =chrCapital_O_Diaeresis;     // 0x00D6
  multiplyChr           =chrMultiplicationSign;      // 0x00D7
  upOSlashChr           =chrCapital_O_Stroke;        // 0x00D8
  upUGraveChr           =chrCapital_U_Grave;         // 0x00D9
  upUAcuteChr           =chrCapital_U_Acute;         // 0x00DA
  upUCircumflexChr      =chrCapital_U_Circumflex;    // 0x00DB
  upUDiaeresisChr       =chrCapital_U_Diaeresis;     // 0x00DC
  upYAcuteChr           =chrCapital_Y_Acute;         // 0x00DD
  upThorn               =chrCapital_Thorn;           // 0x00DE
  lowSharpSChr          =chrSmall_SharpS;            // 0x00DF
  lowAGraveChr          =chrSmall_A_Grave;           // 0x00E0
  lowAAcuteChr          =chrSmall_A_Acute;           // 0x00E1
  lowACircumflexChr     =chrSmall_A_Circumflex;      // 0x00E2
  lowATildeChr          =chrSmall_A_Tilde;           // 0x00E3
  lowADiaeresisChr      =chrSmall_A_Diaeresis;       // 0x00E4
  lowARingChr           =chrSmall_A_RingAbove;       // 0x00E5
  lowAEChr              =chrSmall_AE;                // 0x00E6
  lowCCedillaChr        =chrSmall_C_Cedilla;         // 0x00E7
  lowEGraveChr          =chrSmall_E_Grave;           // 0x00E8
  lowEAcuteChr          =chrSmall_E_Acute;           // 0x00E9
  lowECircumflexChr     =chrSmall_E_Circumflex;      // 0x00EA
  lowEDiaeresisChr      =chrSmall_E_Diaeresis;       // 0x00EB
  lowIGraveChr          =chrSmall_I_Grave;           // 0x00EC
  lowIAcuteChr          =chrSmall_I_Acute;           // 0x00ED
  lowICircumflexChr     =chrSmall_I_Circumflex;      // 0x00EE
  lowIDiaeresisChr      =chrSmall_I_Diaeresis;       // 0x00EF
  lowEthChr             =chrSmall_Eth;               // 0x00F0
  lowNTildeChr          =chrSmall_N_Tilde;           // 0x00F1
  lowOGraveChr          =chrSmall_O_Grave;           // 0x00F2
  lowOAcuteChr          =chrSmall_O_Acute;           // 0x00F3
  lowOCircumflexChr     =chrSmall_O_Circumflex;      // 0x00F4
  lowOTildeChr          =chrSmall_O_Tilde;           // 0x00F5
  lowODiaeresisChr      =chrSmall_O_Diaeresis;       // 0x00F6
  divideChr             =chrDivisionSign;            // 0x00F7
  lowOSlashChr          =chrSmall_O_Stroke;          // 0x00F8
  lowUGraveChr          =chrSmall_U_Grave;           // 0x00F9
  lowUAcuteChr          =chrSmall_U_Acute;           // 0x00FA
  lowUCircumflexChr     =chrSmall_U_Circumflex;      // 0x00FB
  lowUDiaeresisChr      =chrSmall_U_Diaeresis;       // 0x00FC
  lowYAcuteChr          =chrSmall_Y_Acute;           // 0x00FD
  lowThorn              =chrSmall_Thorn;             // 0x00FE
  lowYDiaeresisChr      =chrSmall_Y_Diaeresis;       // 0x00FF
End of old names ******************)

// The  horizEllipsisChr (0x85) still exists in the font, but (in 3.1 and later roms)
// has been duplicated at location 0x18, so that it will be available with all future
// character encodings. If you are running on pre-3.1 roms, then you should use the
// chrHorizontalEllipsis character constant name (0x85), otherwise use chrEllipsis (0x18).
// The ChrHorizEllipsis macro in Chars.h can be used to determine the correct character code.

//  horizEllipsisChr  =_Obsolete__use_ChrHorizEllipsis_macro;

// The following characters were moved in the four standard fonts with the
// 3.1 release of PalmOS; they still exist in their old positions in the
// font, but eventually will be removed:
//
// Old character name   Old position   New character name   New position
//
// numericSpaceChr      0x80        chrNumericSpace      0x19
// commandStrokeChr     0x9D        chrCommandStroke  0x16
// shortcutStrokeChr 0x9E        chrShortcutStroke 0x17

  numericSpaceChrV30      =0x80;  //    ** COPIED TO 0x19; will be removed **
  commandStrokeChrV30     =0x9D;  // ** COPIED TO 0x16; will be removed **
  shortcutStrokeChrV30    =0x9E;  // ** COPIED TO 0x17; will be removed **

//  numericSpaceChr   =_Obsolete__use_ChrNumericSpace_macro;
//  commandStrokeChr  =_Obsolete__use_commandStrokeChrV30_or_chrCommandStroke;
//  shortcutStrokeChr =_Obsolete__use_shortcutStrokeChrV30_or_chrShortcutStroke;

// The following characters were removed from the four standard fonts and
// placed in the 9pt symbol font (see Chars.h).

  // diamondChr        0x8D
  // clubChr           0x8E
  // heartChr          0x8F
  // spadeChr          0x90

  diamondChrV30           =0x8D;  // As of PalmOS v3.2, these characters are
  clubChrV30              =0x8E;  // now available in the Symbol-9 font. They
  heartChrV30             =0x8F;  // still appear in the regular fonts for now,
  spadeChrV30             =0x90;  // but they WILL be removed in a future release.

implementation

end.

