/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: CharShiftJIS.h
 *
 * Description:
 *          Header file for Shift-JIS (code page 932) Japanese character
 *       encoding. These are based on Windows-J implementation of the
 *       Shift-JIS standard.
 *
 * Written by TransPac Software, Inc.
 *
 * History:
 *       Created by Ken Krugler
 * 12 Mar 98   kwk   New today.
 * 06 Apr 98   kwk   Reverted back to #define instead of const values.
 * 07 Apr 98   kwk   Added TxtCharIsHiragana & TxtCharIsKatakana macros.
 * 09 Apr 98   kwk   Made this entire file conditional on NON_INTERNATIONAL.
 * 15 Apr 98   kwk   Filled out full set of character names (from Unicode
 *             2.0 standard).
 * 17 Apr 98   kwk   Resolved duplicated names (thanks Microsoft).
 * 28 May 98   kwk   Put in horizEllipsisChr & numericSpaceChr.
 * 29 Jun 98   kwk   Changed name from CharCP932.h to CharShiftJIS.h.
 * 15 Aug 98   CSS   Reworked the extended character attribute #defines so
 *             we've now got a MicroSoft bit and a bunch of field
 *             values specifying kana, romaji, kanji, greek, etc.
 *             that don't overlap with the standard attributes.
 *          CSS   Recoded the TxtCharIsHiragana/Katakana macros to
 *             AND with class mask and compare with class.
 * 23 Aug 98   kwk   Added charXClassKanaSound.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit CharShiftJIS;

interface

Uses TextMgr;

/***********************************************************************
 * Public macros
 ***********************************************************************/

//#define  TxtCharIsHiragana(ch)   (  (TxtCharXAttr(ch) & charXClassMask) \
//                        == charXClassHiragana)
//#define  TxtCharIsKatakana(ch)   (  (TxtCharXAttr(ch) & charXClassMask) \
//                        == charXClassKatakana)

/***********************************************************************
 * Public constants
 ***********************************************************************/

// Transliteration operations that are not universal, but can be applied
// to Japanese text.

Const
  translitOpFullToHalfKatakana  =translitOpCustomBase+0;
  translitOpHalfToFullKatakana  =translitOpCustomBase+1;
  translitOpFullToHalfRomaji    =translitOpCustomBase+2;
  translitOpHalfToFullRomaji    =translitOpCustomBase+3;
  translitOpKatakanaToHiragana  =translitOpCustomBase+4;
  translitOpHiraganaToKatakana  =translitOpCustomBase+5;
  translitOpCombineSoundMark    =translitOpCustomBase+6;
  translitOpDivideSoundMark     =translitOpCustomBase+7;
  translitOpRomajiToHiragana    =translitOpCustomBase+8;
  translitOpHiraganaToRomaji    =translitOpCustomBase+9;

// Extended character attributes for the Shift-JIS (CP932) code page.
// Note that these attributes have to be on an encoding basis, since
// they're shared across all languages which use this encoding. For
// Japanese there's only one language, so we're OK to encode wrapping
// info here, which is often language-dependent.

  charXAttrMask       =0x00ff;
  charXAttrFollowing  =0x0001;
  charXAttrLeading    =0x0002;
  charXAttrBreak      =0x0004;
  charXAttrMicroSoft  =0x0008;

  charXClassMask      =0x0f00;
  charXClassRomaji    =0x0100;
  charXClassHiragana  =0x0200;
  charXClassKatakana  =0x0300;
  charXClassKanaSound =0x0400;
  charXClassGreek     =0x0500;
  charXClassCyrillic  =0x0600;
  charXClassKanjiL1   =0x0700;
  charXClassKanjiL2   =0x0800;
  charXClassKanjiOther=0x0900;
  charXClassOther     =0x0a00;
  charXClassUndefined =0x0b00;

// Some ShiftJIS-specific combinations. Every byte in a stream of
// ShiftJIS data must be either a single byte, a single/low byte,
// or a high/low byte.

  byteAttrSingleLow     =byteAttrSingle | byteAttrLast;
  byteAttrHighLow       =byteAttrFirst | byteAttrLast;

  kFirstHighByte       =0x81;
  kFirstLowByte        =0x40;

// Character codes that are specific to Shift JIS. These names
// are generated from the Unicode 2.0 data files.

  chrYenSign                      =0x005c;

  chrFirstSJISDoubleByte          =0x8140;

  chrHalfwidthIdeographicFullStop =0x00A1;
  chrHalfwidthLeftCornerBracket   =0x00A2;
  chrHalfwidthRightCornerBracket  =0x00A3;
  chrHalfwidthIdeographicComma    =0x00A4;
  chrHalfwidthKatakanaMiddleDot   =0x00A5;
  chrHalfwidthKatakana_WO         =0x00A6;
  chrHalfwidthKatakanaSmall_A     =0x00A7;
  chrHalfwidthKatakanaSmall_I     =0x00A8;
  chrHalfwidthKatakanaSmall_U     =0x00A9;
  chrHalfwidthKatakanaSmall_E     =0x00AA;
  chrHalfwidthKatakanaSmall_O     =0x00AB;
  chrHalfwidthKatakanaSmall_YA    =0x00AC;
  chrHalfwidthKatakanaSmall_YU    =0x00AD;
  chrHalfwidthKatakanaSmall_YO    =0x00AE;
  chrHalfwidthKatakanaSmall_TU    =0x00AF;
  chrHalfwidthKatakanaHiraganaProlongedSoundMark =0x00B0;
  chrHalfwidthKatakana_A          =0x00B1;
  chrHalfwidthKatakana_I          =0x00B2;
  chrHalfwidthKatakana_U          =0x00B3;
  chrHalfwidthKatakana_E          =0x00B4;
  chrHalfwidthKatakana_O          =0x00B5;
  chrHalfwidthKatakana_KA         =0x00B6;
  chrHalfwidthKatakana_KI         =0x00B7;
  chrHalfwidthKatakana_KU         =0x00B8;
  chrHalfwidthKatakana_KE         =0x00B9;
  chrHalfwidthKatakana_KO         =0x00BA;
  chrHalfwidthKatakana_SA         =0x00BB;
  chrHalfwidthKatakana_SI         =0x00BC;
  chrHalfwidthKatakana_SU         =0x00BD;
  chrHalfwidthKatakana_SE         =0x00BE;
  chrHalfwidthKatakana_SO         =0x00BF;
  chrHalfwidthKatakana_TA         =0x00C0;
  chrHalfwidthKatakana_TI         =0x00C1;
  chrHalfwidthKatakana_TU         =0x00C2;
  chrHalfwidthKatakana_TE         =0x00C3;
  chrHalfwidthKatakana_TO         =0x00C4;
  chrHalfwidthKatakana_NA         =0x00C5;
  chrHalfwidthKatakana_NI         =0x00C6;
  chrHalfwidthKatakana_NU         =0x00C7;
  chrHalfwidthKatakana_NE         =0x00C8;
  chrHalfwidthKatakana_NO         =0x00C9;
  chrHalfwidthKatakana_HA         =0x00CA;
  chrHalfwidthKatakana_HI         =0x00CB;
  chrHalfwidthKatakana_HU         =0x00CC;
  chrHalfwidthKatakana_HE         =0x00CD;
  chrHalfwidthKatakana_HO         =0x00CE;
  chrHalfwidthKatakana_MA         =0x00CF;
  chrHalfwidthKatakana_MI         =0x00D0;
  chrHalfwidthKatakana_MU         =0x00D1;
  chrHalfwidthKatakana_ME         =0x00D2;
  chrHalfwidthKatakana_MO         =0x00D3;
  chrHalfwidthKatakana_YA         =0x00D4;
  chrHalfwidthKatakana_YU         =0x00D5;
  chrHalfwidthKatakana_YO         =0x00D6;
  chrHalfwidthKatakana_RA         =0x00D7;
  chrHalfwidthKatakana_RI         =0x00D8;
  chrHalfwidthKatakana_RU         =0x00D9;
  chrHalfwidthKatakana_RE         =0x00DA;
  chrHalfwidthKatakana_RO         =0x00DB;
  chrHalfwidthKatakana_WA         =0x00DC;
  chrHalfwidthKatakana_N          =0x00DD;
  chrHalfwidthKatakanaVoicedSoundMark   =0x00DE;
  chrHalfwidthKatakanaSemiVoicedSoundMark=0x00DF;

  chrIdeographicSpace             =0x8140;
  chrIdeographicComma             =0x8141;
  chrIdeographicFullStop          =0x8142;
  chrFullwidthComma               =0x8143;
  chrFullwidthFullStop            =0x8144;
  chrKatakanaMiddleDot            =0x8145;
  chrFullwidthColon               =0x8146;
  chrFullwidthSemicolon           =0x8147;
  chrFullwidthQuestionMark        =0x8148;
  chrFullwidthExclamationMark     =0x8149;
  chrKatakanaHiraganaVoicedSoundMark =0x814A;
  chrKatakanaHiraganaSemiVoicedSoundMark=0x814B;
  chrAcuteAccent                  =0x814C;
  chrFullwidthGraveAccent         =0x814D;
  chrDiaeresis                    =0x814E;
  chrFullwidthCircumflexAccent    =0x814F;
  chrFullwidthMacron              =0x8150;
  chrFullwidthLowLine             =0x8151;
  chrKatakanaIterationMark        =0x8152;
  chrKatakanaVoicedIterationMark  =0x8153;
  chrHiraganaIterationMark        =0x8154;
  chrHiraganaVoicedIterationMark  =0x8155;
  chrDittoMark                    =0x8156;
  chrIdeographicIterationMark     =0x8158;
  chrIdeographicClosingMark       =0x8159;
  chrIdeographicNumberZero        =0x815A;
  chrKatakanaHiraganaProlongedSoundMark=0x815B;
  chrHorizontalBar                =0x815C;
  chrHyphen                       =0x815D;
  chrFullwidthSolidus             =0x815E;
  chrFullwidthReverseSolidus      =0x815F;
  chrFullwidthTilde               =0x8160;
  chrParallelTo                   =0x8161;
  chrFullwidthVerticalLine        =0x8162;
  chrFullwidthHorizontalEllipsis  =0x8163;
  chrTwoDotLeader                 =0x8164;
  chrLeftSingleQuotationMark      =0x8165;
  chrRightSingleQuotationMark     =0x8166;
  chrLeftDoubleQuotationMark      =0x8167;
  chrRightDoubleQuotationMark     =0x8168;
  chrFullwidthLeftParenthesis     =0x8169;
  chrFullwidthRightParenthesis    =0x816A;
  chrLeftTortoiseShellBracket     =0x816B;
  chrRightTortoiseShellBracket    =0x816C;
  chrFullwidthLeftSquareBracket   =0x816D;
  chrFullwidthRightSquareBracket  =0x816E;
  chrFullwidthLeftCurlyBracket    =0x816F;
  chrFullwidthRightCurlyBracket   =0x8170;
  chrLeftAngleBracket             =0x8171;
  chrRightAngleBracket            =0x8172;
  chrLeftDoubleAngleBracket       =0x8173;
  chrRightDoubleAngleBracket      =0x8174;
  chrLeftCornerBracket            =0x8175;
  chrRightCornerBracket           =0x8176;
  chrLeftWhiteCornerBracket       =0x8177;
  chrRightWhiteCornerBracket      =0x8178;
  chrLeftBlackLenticularBracket   =0x8179;
  chrRightBlackLenticularBracket  =0x817A;
  chrFullwidthPlusSign            =0x817B;
  chrFullwidthHyphenMinus         =0x817C;
  chrPlusMinusSign                =0x817D;
  chrMultiplicationSign           =0x817E;
  chrDivisionSign                 =0x8180;
  chrFullwidthEqualsSign          =0x8181;
  chrNotEqualTo                   =0x8182;
  chrFullwidthLessThanSign        =0x8183;
  chrFullwidthGreaterThanSign     =0x8184;
  chrLessThanOverEqualTo          =0x8185;
  chrGreaterThanOverEqualTo       =0x8186;
  chrInfinity                     =0x8187;
  chrTherefore                    =0x8188;
  chrMaleSign                     =0x8189;
  chrFemaleSign                   =0x818A;
  chrDegreeSign                   =0x818B;
  chrPrime                        =0x818C;
  chrDoublePrime                  =0x818D;
  chrDegreeCelsius                =0x818E;
  chrFullwidthYenSign             =0x818F;
  chrFullwidthDollarSign          =0x8190;
  chrFullwidthCentSign            =0x8191;
  chrFullwidthPoundSign           =0x8192;
  chrFullwidthPercentSign         =0x8193;
  chrFullwidthNumberSign          =0x8194;
  chrFullwidthAmpersand           =0x8195;
  chrFullwidthAsterisk            =0x8196;
  chrFullwidthCommercialAt        =0x8197;
  chrSectionSign                  =0x8198;
  chrWhiteStar                    =0x8199;
  chrBlackStar                    =0x819A;
  chrWhiteCircle                  =0x819B;
  chrBlackCircle                  =0x819C;
  chrBullseye                     =0x819D;
  chrWhiteDiamond                 =0x819E;
  chrBlackDiamond                 =0x819F;
  chrWhiteSquare                  =0x81A0;
  chrBlackSquare                  =0x81A1;
  chrWhiteUpPointingTriangle      =0x81A2;
  chrBlackUpPointingTriangle      =0x81A3;
  chrWhiteDownPointingTriangle    =0x81A4;
  chrBlackDownPointingTriangle    =0x81A5;
  chrReferenceMark                =0x81A6;
  chrPostalMark                   =0x81A7;
  chrRightwardsArrow              =0x81A8;
  chrLeftwardsArrow               =0x81A9;
  chrUpwardsArrow                 =0x81AA;
  chrDownwardsArrow               =0x81AB;
  chrGetaMark                     =0x81AC;
  chrElementOf                    =0x81B8;
  chrContainsAsMember             =0x81B9;
  chrSubsetOfOrEqualTo            =0x81BA;
  chrSupersetOfOrEqualTo          =0x81BB;
  chrSubsetOf                     =0x81BC;
  chrSupersetOf                   =0x81BD;
  chrUnion                        =0x81BE;
  chrIntersection                 =0x81BF;
  chrLogicalAnd                   =0x81C8;
  chrLogicalOr                    =0x81C9;
  chrFullwidthNotSign             =0x81CA;
  chrRightwardsDoubleArrow        =0x81CB;
  chrLeftRightDoubleArrow         =0x81CC;
  chrForAll                       =0x81CD;
  chrThereExists                  =0x81CE;
  chrAngle                        =0x81DA;
  chrUpTack                       =0x81DB;
  chrArc                          =0x81DC;
  chrPartialDifferential          =0x81DD;
  chrNabla                        =0x81DE;
  chrIdenticalTo                  =0x81DF;
  chrApproximatelyEqualToOrTheImageOf=0x81E0;
  chrMuchLessThan                 =0x81E1;
  chrMuchGreaterThan              =0x81E2;
  chrSquareRoot                   =0x81E3;
  chrReversedTilde                =0x81E4;
  chrProportionalTo               =0x81E5;
  chrBecause                      =0x81E6;
  chrIntegral                     =0x81E7;
  chrDoubleIntegral               =0x81E8;
  chrAngstromSign                 =0x81F0;
  chrPerMilleSign                 =0x81F1;
  chrMusicSharpSign               =0x81F2;
  chrMusicFlatSign                =0x81F3;
  chrEighthNote                   =0x81F4;
  chrDagger                       =0x81F5;
  chrDoubleDagger                 =0x81F6;
  chrPilcrowSign                  =0x81F7;
  chrLargeCircle                  =0x81FC;

  chrFullwidthDigitZero           =0x824F;
  chrFullwidthDigitOne            =0x8250;
  chrFullwidthDigitTwo            =0x8251;
  chrFullwidthDigitThree          =0x8252;
  chrFullwidthDigitFour           =0x8253;
  chrFullwidthDigitFive           =0x8254;
  chrFullwidthDigitSix            =0x8255;
  chrFullwidthDigitSeven          =0x8256;
  chrFullwidthDigitEight          =0x8257;
  chrFullwidthDigitNine           =0x8258;
  chrFullwidthCapital_A           =0x8260;
  chrFullwidthCapital_B           =0x8261;
  chrFullwidthCapital_C           =0x8262;
  chrFullwidthCapital_D           =0x8263;
  chrFullwidthCapital_E           =0x8264;
  chrFullwidthCapital_F           =0x8265;
  chrFullwidthCapital_G           =0x8266;
  chrFullwidthCapital_H           =0x8267;
  chrFullwidthCapital_I           =0x8268;
  chrFullwidthCapital_J           =0x8269;
  chrFullwidthCapital_K           =0x826A;
  chrFullwidthCapital_L           =0x826B;
  chrFullwidthCapital_M           =0x826C;
  chrFullwidthCapital_N           =0x826D;
  chrFullwidthCapital_O           =0x826E;
  chrFullwidthCapital_P           =0x826F;
  chrFullwidthCapital_Q           =0x8270;
  chrFullwidthCapital_R           =0x8271;
  chrFullwidthCapital_S           =0x8272;
  chrFullwidthCapital_T           =0x8273;
  chrFullwidthCapital_U           =0x8274;
  chrFullwidthCapital_V           =0x8275;
  chrFullwidthCapital_W           =0x8276;
  chrFullwidthCapital_X           =0x8277;
  chrFullwidthCapital_Y           =0x8278;
  chrFullwidthCapital_Z           =0x8279;
  chrFullwidthSmall_A             =0x8281;
  chrFullwidthSmall_B             =0x8282;
  chrFullwidthSmall_C             =0x8283;
  chrFullwidthSmall_D             =0x8284;
  chrFullwidthSmall_E             =0x8285;
  chrFullwidthSmall_F             =0x8286;
  chrFullwidthSmall_G             =0x8287;
  chrFullwidthSmall_H             =0x8288;
  chrFullwidthSmall_I             =0x8289;
  chrFullwidthSmall_J             =0x828A;
  chrFullwidthSmall_K             =0x828B;
  chrFullwidthSmall_L             =0x828C;
  chrFullwidthSmall_M             =0x828D;
  chrFullwidthSmall_N             =0x828E;
  chrFullwidthSmall_O             =0x828F;
  chrFullwidthSmall_P             =0x8290;
  chrFullwidthSmall_Q             =0x8291;
  chrFullwidthSmall_R             =0x8292;
  chrFullwidthSmall_S             =0x8293;
  chrFullwidthSmall_T             =0x8294;
  chrFullwidthSmall_U             =0x8295;
  chrFullwidthSmall_V             =0x8296;
  chrFullwidthSmall_W             =0x8297;
  chrFullwidthSmall_X             =0x8298;
  chrFullwidthSmall_Y             =0x8299;
  chrFullwidthSmall_Z             =0x829A;

  chrHiraganaSmall_A              =0x829F;
  chrHiragana_A                   =0x82A0;
  chrHiraganaSmall_I              =0x82A1;
  chrHiragana_I                   =0x82A2;
  chrHiraganaSmall_U              =0x82A3;
  chrHiragana_U                   =0x82A4;
  chrHiraganaSmall_E              =0x82A5;
  chrHiragana_E                   =0x82A6;
  chrHiraganaSmall_O              =0x82A7;
  chrHiragana_O                   =0x82A8;
  chrHiragana_KA                  =0x82A9;
  chrHiragana_GA                  =0x82AA;
  chrHiragana_KI                  =0x82AB;
  chrHiragana_GI                  =0x82AC;
  chrHiragana_KU                  =0x82AD;
  chrHiragana_GU                  =0x82AE;
  chrHiragana_KE                  =0x82AF;
  chrHiragana_GE                  =0x82B0;
  chrHiragana_KO                  =0x82B1;
  chrHiragana_GO                  =0x82B2;
  chrHiragana_SA                  =0x82B3;
  chrHiragana_ZA                  =0x82B4;
  chrHiragana_SI                  =0x82B5;
  chrHiragana_ZI                  =0x82B6;
  chrHiragana_SU                  =0x82B7;
  chrHiragana_ZU                  =0x82B8;
  chrHiragana_SE                  =0x82B9;
  chrHiragana_ZE                  =0x82BA;
  chrHiragana_SO                  =0x82BB;
  chrHiragana_ZO                  =0x82BC;
  chrHiragana_TA                  =0x82BD;
  chrHiragana_DA                  =0x82BE;
  chrHiragana_TI                  =0x82BF;
  chrHiragana_DI                  =0x82C0;
  chrHiraganaSmall_TU             =0x82C1;
  chrHiragana_TU                  =0x82C2;
  chrHiragana_DU                  =0x82C3;
  chrHiragana_TE                  =0x82C4;
  chrHiragana_DE                  =0x82C5;
  chrHiragana_TO                  =0x82C6;
  chrHiragana_DO                  =0x82C7;
  chrHiragana_NA                  =0x82C8;
  chrHiragana_NI                  =0x82C9;
  chrHiragana_NU                  =0x82CA;
  chrHiragana_NE                  =0x82CB;
  chrHiragana_NO                  =0x82CC;
  chrHiragana_HA                  =0x82CD;
  chrHiragana_BA                  =0x82CE;
  chrHiragana_PA                  =0x82CF;
  chrHiragana_HI                  =0x82D0;
  chrHiragana_BI                  =0x82D1;
  chrHiragana_PI                  =0x82D2;
  chrHiragana_HU                  =0x82D3;
  chrHiragana_BU                  =0x82D4;
  chrHiragana_PU                  =0x82D5;
  chrHiragana_HE                  =0x82D6;
  chrHiragana_BE                  =0x82D7;
  chrHiragana_PE                  =0x82D8;
  chrHiragana_HO                  =0x82D9;
  chrHiragana_BO                  =0x82DA;
  chrHiragana_PO                  =0x82DB;
  chrHiragana_MA                  =0x82DC;
  chrHiragana_MI                  =0x82DD;
  chrHiragana_MU                  =0x82DE;
  chrHiragana_ME                  =0x82DF;
  chrHiragana_MO                  =0x82E0;
  chrHiraganaSmall_YA             =0x82E1;
  chrHiragana_YA                  =0x82E2;
  chrHiraganaSmall_YU             =0x82E3;
  chrHiragana_YU                  =0x82E4;
  chrHiraganaSmall_YO             =0x82E5;
  chrHiragana_YO                  =0x82E6;
  chrHiragana_RA                  =0x82E7;
  chrHiragana_RI                  =0x82E8;
  chrHiragana_RU                  =0x82E9;
  chrHiragana_RE                  =0x82EA;
  chrHiragana_RO                  =0x82EB;
  chrHiraganaSmall_WA             =0x82EC;
  chrHiragana_WA                  =0x82ED;
  chrHiragana_WI                  =0x82EE;
  chrHiragana_WE                  =0x82EF;
  chrHiragana_WO                  =0x82F0;
  chrHiragana_N                   =0x82F1;

  chrKatakanaSmall_A              =0x8340;
  chrKatakana_A                   =0x8341;
  chrKatakanaSmall_I              =0x8342;
  chrKatakana_I                   =0x8343;
  chrKatakanaSmall_U              =0x8344;
  chrKatakana_U                   =0x8345;
  chrKatakanaSmall_E              =0x8346;
  chrKatakana_E                   =0x8347;
  chrKatakanaSmall_O              =0x8348;
  chrKatakana_O                   =0x8349;
  chrKatakana_KA                  =0x834A;
  chrKatakana_GA                  =0x834B;
  chrKatakana_KI                  =0x834C;
  chrKatakana_GI                  =0x834D;
  chrKatakana_KU                  =0x834E;
  chrKatakana_GU                  =0x834F;
  chrKatakana_KE                  =0x8350;
  chrKatakana_GE                  =0x8351;
  chrKatakana_KO                  =0x8352;
  chrKatakana_GO                  =0x8353;
  chrKatakana_SA                  =0x8354;
  chrKatakana_ZA                  =0x8355;
  chrKatakana_SI                  =0x8356;
  chrKatakana_ZI                  =0x8357;
  chrKatakana_SU                  =0x8358;
  chrKatakana_ZU                  =0x8359;
  chrKatakana_SE                  =0x835A;
  chrKatakana_ZE                  =0x835B;
  chrKatakana_SO                  =0x835C;
  chrKatakana_ZO                  =0x835D;
  chrKatakana_TA                  =0x835E;
  chrKatakana_DA                  =0x835F;
  chrKatakana_TI                  =0x8360;
  chrKatakana_DI                  =0x8361;
  chrKatakanaSmall_TU             =0x8362;
  chrKatakana_TU                  =0x8363;
  chrKatakana_DU                  =0x8364;
  chrKatakana_TE                  =0x8365;
  chrKatakana_DE                  =0x8366;
  chrKatakana_TO                  =0x8367;
  chrKatakana_DO                  =0x8368;
  chrKatakana_NA                  =0x8369;
  chrKatakana_NI                  =0x836A;
  chrKatakana_NU                  =0x836B;
  chrKatakana_NE                  =0x836C;
  chrKatakana_NO                  =0x836D;
  chrKatakana_HA                  =0x836E;
  chrKatakana_BA                  =0x836F;
  chrKatakana_PA                  =0x8370;
  chrKatakana_HI                  =0x8371;
  chrKatakana_BI                  =0x8372;
  chrKatakana_PI                  =0x8373;
  chrKatakana_HU                  =0x8374;
  chrKatakana_BU                  =0x8375;
  chrKatakana_PU                  =0x8376;
  chrKatakana_HE                  =0x8377;
  chrKatakana_BE                  =0x8378;
  chrKatakana_PE                  =0x8379;
  chrKatakana_HO                  =0x837A;
  chrKatakana_BO                  =0x837B;
  chrKatakana_PO                  =0x837C;
  chrKatakana_MA                  =0x837D;
  chrKatakana_MI                  =0x837E;
  chrKatakana_MU                  =0x8380;
  chrKatakana_ME                  =0x8381;
  chrKatakana_MO                  =0x8382;
  chrKatakanaSmall_YA             =0x8383;
  chrKatakana_YA                  =0x8384;
  chrKatakanaSmall_YU             =0x8385;
  chrKatakana_YU                  =0x8386;
  chrKatakanaSmall_YO             =0x8387;
  chrKatakana_YO                  =0x8388;
  chrKatakana_RA                  =0x8389;
  chrKatakana_RI                  =0x838A;
  chrKatakana_RU                  =0x838B;
  chrKatakana_RE                  =0x838C;
  chrKatakana_RO                  =0x838D;
  chrKatakanaSmall_WA             =0x838E;
  chrKatakana_WA                  =0x838F;
  chrKatakana_WI                  =0x8390;
  chrKatakana_WE                  =0x8391;
  chrKatakana_WO                  =0x8392;
  chrKatakana_N                   =0x8393;
  chrKatakana_VU                  =0x8394;
  chrKatakanaSmall_KA             =0x8395;
  chrKatakanaSmall_KE             =0x8396;

  chrGreekCapitalAlpha            =0x839F;
  chrGreekCapitalBeta             =0x83A0;
  chrGreekCapitalGamma            =0x83A1;
  chrGreekCapitalDelta            =0x83A2;
  chrGreekCapitalEpsilon          =0x83A3;
  chrGreekCapitalZeta             =0x83A4;
  chrGreekCapitalEta              =0x83A5;
  chrGreekCapitalTheta            =0x83A6;
  chrGreekCapitalIota             =0x83A7;
  chrGreekCapitalKappa            =0x83A8;
  chrGreekCapitalLamda            =0x83A9;
  chrGreekCapitalMu               =0x83AA;
  chrGreekCapitalNu               =0x83AB;
  chrGreekCapitalXi               =0x83AC;
  chrGreekCapitalOmicron          =0x83AD;
  chrGreekCapitalPi               =0x83AE;
  chrGreekCapitalRho              =0x83AF;
  chrGreekCapitalSigma            =0x83B0;
  chrGreekCapitalTau              =0x83B1;
  chrGreekCapitalUpsilon          =0x83B2;
  chrGreekCapitalPhi              =0x83B3;
  chrGreekCapitalChi              =0x83B4;
  chrGreekCapitalPsi              =0x83B5;
  chrGreekCapitalOmega            =0x83B6;
  chrGreekSmallAlpha              =0x83BF;
  chrGreekSmallBeta               =0x83C0;
  chrGreekSmallGamma              =0x83C1;
  chrGreekSmallDelta              =0x83C2;
  chrGreekSmallEpsilon            =0x83C3;
  chrGreekSmallZeta               =0x83C4;
  chrGreekSmallEta                =0x83C5;
  chrGreekSmallTheta              =0x83C6;
  chrGreekSmallIota               =0x83C7;
  chrGreekSmallKappa              =0x83C8;
  chrGreekSmallLamda              =0x83C9;
  chrGreekSmallMu                 =0x83CA;
  chrGreekSmallNu                 =0x83CB;
  chrGreekSmallXi                 =0x83CC;
  chrGreekSmallOmicron            =0x83CD;
  chrGreekSmallPi                 =0x83CE;
  chrGreekSmallRho                =0x83CF;
  chrGreekSmallSigma              =0x83D0;
  chrGreekSmallTau                =0x83D1;
  chrGreekSmallUpsilon            =0x83D2;
  chrGreekSmallPhi                =0x83D3;
  chrGreekSmallChi                =0x83D4;
  chrGreekSmallPsi                =0x83D5;
  chrGreekSmallOmega              =0x83D6;

  chrCyrillicCapital_A            =0x8440;
  chrCyrillicCapital_BE           =0x8441;
  chrCyrillicCapital_VE           =0x8442;
  chrCyrillicCapital_GHE          =0x8443;
  chrCyrillicCapital_DE           =0x8444;
  chrCyrillicCapital_IE           =0x8445;
  chrCyrillicCapital_IO           =0x8446;
  chrCyrillicCapital_ZHE          =0x8447;
  chrCyrillicCapital_ZE           =0x8448;
  chrCyrillicCapital_I            =0x8449;
  chrCyrillicCapitalShort_I       =0x844A;
  chrCyrillicCapital_KA           =0x844B;
  chrCyrillicCapital_EL           =0x844C;
  chrCyrillicCapital_EM           =0x844D;
  chrCyrillicCapital_EN           =0x844E;
  chrCyrillicCapital_O            =0x844F;
  chrCyrillicCapital_PE           =0x8450;
  chrCyrillicCapital_ER           =0x8451;
  chrCyrillicCapital_ES           =0x8452;
  chrCyrillicCapital_TE           =0x8453;
  chrCyrillicCapital_U            =0x8454;
  chrCyrillicCapital_EF           =0x8455;
  chrCyrillicCapital_HA           =0x8456;
  chrCyrillicCapital_TSE          =0x8457;
  chrCyrillicCapital_CHE          =0x8458;
  chrCyrillicCapital_SHA          =0x8459;
  chrCyrillicCapital_SHCHA        =0x845A;
  chrCyrillicCapitalHardSign      =0x845B;
  chrCyrillicCapital_YERU         =0x845C;
  chrCyrillicCapitalSoftSign      =0x845D;
  chrCyrillicCapital_E            =0x845E;
  chrCyrillicCapital_YU           =0x845F;
  chrCyrillicCapital_YA           =0x8460;
  chrCyrillicSmall_A              =0x8470;
  chrCyrillicSmall_BE             =0x8471;
  chrCyrillicSmall_VE             =0x8472;
  chrCyrillicSmall_GHE            =0x8473;
  chrCyrillicSmall_DE             =0x8474;
  chrCyrillicSmall_IE             =0x8475;
  chrCyrillicSmall_IO             =0x8476;
  chrCyrillicSmall_ZHE            =0x8477;
  chrCyrillicSmall_ZE             =0x8478;
  chrCyrillicSmall_I              =0x8479;
  chrCyrillicSmallShort_I         =0x847A;
  chrCyrillicSmall_KA             =0x847B;
  chrCyrillicSmall_EL             =0x847C;
  chrCyrillicSmall_EM             =0x847D;
  chrCyrillicSmall_EN             =0x847E;
  chrCyrillicSmall_O              =0x8480;
  chrCyrillicSmall_PE             =0x8481;
  chrCyrillicSmall_ER             =0x8482;
  chrCyrillicSmall_ES             =0x8483;
  chrCyrillicSmall_TE             =0x8484;
  chrCyrillicSmall_U              =0x8485;
  chrCyrillicSmall_EF             =0x8486;
  chrCyrillicSmall_HA             =0x8487;
  chrCyrillicSmall_TSE            =0x8488;
  chrCyrillicSmall_CHE            =0x8489;
  chrCyrillicSmall_SHA            =0x848A;
  chrCyrillicSmall_SHCHA          =0x848B;
  chrCyrillicSmallHardSign        =0x848C;
  chrCyrillicSmall_YERU           =0x848D;
  chrCyrillicSmallSoftSign        =0x848E;
  chrCyrillicSmall_E              =0x848F;
  chrCyrillicSmall_YU             =0x8490;
  chrCyrillicSmall_YA             =0x8491;

  chrBoxDrawingsLightHorizontal               =0x849F;
  chrBoxDrawingsLightVertical                 =0x84A0;
  chrBoxDrawingsLightDownAndRight             =0x84A1;
  chrBoxDrawingsLightDownAndLeft              =0x84A2;
  chrBoxDrawingsLightUpAndLeft                =0x84A3;
  chrBoxDrawingsLightUpAndRight               =0x84A4;
  chrBoxDrawingsLightVerticalAndRight         =0x84A5;
  chrBoxDrawingsLightDownAndHorizontal        =0x84A6;
  chrBoxDrawingsLightVerticalAndLeft          =0x84A7;
  chrBoxDrawingsLightUpAndHorizontal          =0x84A8;
  chrBoxDrawingsLightVerticalAndHorizontal    =0x84A9;
  chrBoxDrawingsHeavyHorizontal               =0x84AA;
  chrBoxDrawingsHeavyVertical                 =0x84AB;
  chrBoxDrawingsHeavyDownAndRight             =0x84AC;
  chrBoxDrawingsHeavyDownAndLeft              =0x84AD;
  chrBoxDrawingsHeavyUpAndLeft                =0x84AE;
  chrBoxDrawingsHeavyUpAndRight               =0x84AF;
  chrBoxDrawingsHeavyVerticalAndRight         =0x84B0;
  chrBoxDrawingsHeavyDownAndHorizontal        =0x84B1;
  chrBoxDrawingsHeavyVerticalAndLeft          =0x84B2;
  chrBoxDrawingsHeavyUpAndHorizontal          =0x84B3;
  chrBoxDrawingsHeavyVerticalAndHorizontal    =0x84B4;
  chrBoxDrawingsVerticalHeavyAndRightLight    =0x84B5;
  chrBoxDrawingsDownLightAndHorizontalHeavy   =0x84B6;
  chrBoxDrawingsVerticalHeavyAndLeftLight     =0x84B7;
  chrBoxDrawingsUpLightAndHorizontalHeavy     =0x84B8;
  chrBoxDrawingsVerticalLightAndHorizontalHeavy  =0x84B9;
  chrBoxDrawingsVerticalLightAndRightHeavy    =0x84BA;
  chrBoxDrawingsDownHeavyAndHorizontalLight   =0x84BB;
  chrBoxDrawingsVerticalLightAndLeftHeavy     =0x84BC;
  chrBoxDrawingsUpHeavyAndHorizontalLight     =0x84BD;
  chrBoxDrawingsVerticalHeavyAndHorizontalLight  =0x84BE;

  chrCircledDigitOne              =0x8740;
  chrCircledDigitTwo              =0x8741;
  chrCircledDigitThree            =0x8742;
  chrCircledDigitFour             =0x8743;
  chrCircledDigitFive             =0x8744;
  chrCircledDigitSix              =0x8745;
  chrCircledDigitSeven            =0x8746;
  chrCircledDigitEight            =0x8747;
  chrCircledDigitNine             =0x8748;
  chrCircledNumberTen             =0x8749;
  chrCircledNumberEleven          =0x874A;
  chrCircledNumberTwelve          =0x874B;
  chrCircledNumberThirteen        =0x874C;
  chrCircledNumberFourteen        =0x874D;
  chrCircledNumberFifteen         =0x874E;
  chrCircledNumberSixteen         =0x874F;
  chrCircledNumberSeventeen       =0x8750;
  chrCircledNumberEighteen        =0x8751;
  chrCircledNumberNineteen        =0x8752;
  chrCircledNumberTwenty          =0x8753;
  chrRomanNumeralOne              =0x8754;
  chrRomanNumeralTwo              =0x8755;
  chrRomanNumeralThree            =0x8756;
  chrRomanNumeralFour             =0x8757;
  chrRomanNumeralFive             =0x8758;
  chrRomanNumeralSix              =0x8759;
  chrRomanNumeralSeven            =0x875A;
  chrRomanNumeralEight            =0x875B;
  chrRomanNumeralNine             =0x875C;
  chrRomanNumeralTen              =0x875D;
  chrSquareMiri                   =0x875F;
  chrSquareKiro                   =0x8760;
  chrSquareSenti                  =0x8761;
  chrSquareMeetoru                =0x8762;
  chrSquareGuramu                 =0x8763;
  chrSquareTon                    =0x8764;
  chrSquareAaru                   =0x8765;
  chrSquareHekutaaru              =0x8766;
  chrSquareRittoru                =0x8767;
  chrSquareWatto                  =0x8768;
  chrSquareKarorii                =0x8769;
  chrSquareDoru                   =0x876A;
  chrSquareSento                  =0x876B;
  chrSquarePaasento               =0x876C;
  chrSquareMiribaaru              =0x876D;
  chrSquarePeezi                  =0x876E;
  chrSquareMm                     =0x876F;
  chrSquareCm                     =0x8770;
  chrSquareKm                     =0x8771;
  chrSquareMg                     =0x8772;
  chrSquareKg                     =0x8773;
  chrSquareCc                     =0x8774;
  chrSquareMSquared               =0x8775;
  chrSquareEraNameHeisei          =0x877E;
  chrReversedDoublePrimeQuotationMark=0x8780;
  chrLowDoublePrimeQuotationMark     =0x8781;
  chrNumeroSign                   =0x8782;
  chrSquareKk                     =0x8783;
  chrTelephoneSign                =0x8784;
  chrCircledIdeographHigh         =0x8785;
  chrCircledIdeographCentre       =0x8786;
  chrCircledIdeographLow          =0x8787;
  chrCircledIdeographLeft         =0x8788;
  chrCircledIdeographRight        =0x8789;
  chrParenthesizedIdeographStock  =0x878A;
  chrParenthesizedIdeographHave   =0x878B;
  chrParenthesizedIdeographRepresent =0x878C;
  chrSquareEraNameMeizi           =0x878D;
  chrSquareEraNameTaisyou         =0x878E;
  chrSquareEraNameSyouwa          =0x878F;
  chrApproximatelyEqualToOrTheImageOfDup=0x8790;      // Same as 0x81E0
  chrIdenticalToDup               =0x8791;            // Same as 0x81DF
  chrIntegralDup                  =0x8792;            // Same as 0x81E7
  chrContourIntegral              =0x8793;
  chrNArySummation                =0x8794;
  chrSquareRootDup                =0x8795;            // Same as 0x81E3
  chrUpTackDup                    =0x8796;            // Same as 0x81DB
  chrAngleDup                     =0x8797;            // Same as 0x81DA
  chrRightAngle                   =0x8798;
  chrRightTriangle                =0x8799;
  chrBecauseDup                   =0x879A;            // Same as 0x81E6
  chrIntersectionDup              =0x879B;            // Same as 0x81BF
  chrUnionDup                     =0x879C;            // Same as 0x81BE

  chrSmallRomanNumeralOne         =0xEEEF;
  chrSmallRomanNumeralTwo         =0xEEF0;
  chrSmallRomanNumeralThree       =0xEEF1;
  chrSmallRomanNumeralFour        =0xEEF2;
  chrSmallRomanNumeralFive        =0xEEF3;
  chrSmallRomanNumeralSix         =0xEEF4;
  chrSmallRomanNumeralSeven       =0xEEF5;
  chrSmallRomanNumeralEight       =0xEEF6;
  chrSmallRomanNumeralNine        =0xEEF7;
  chrSmallRomanNumeralTen         =0xEEF8;
  chrFullwidthNotSignDup          =0xEEF9;            // Same as 0x81CA
  chrFullwidthBrokenBar           =0xEEFA;
  chrFullwidthApostrophe          =0xEEFB;
  chrFullwidthQuotationMark       =0xEEFC;

  chrSmallRomanNumeralOneDup      =0xFA40;            // Same as 0xEEEF
  chrSmallRomanNumeralTwoDup      =0xFA41;            // Same as 0xEEF0
  chrSmallRomanNumeralThreeDup    =0xFA42;            // Same as 0xEEF1
  chrSmallRomanNumeralFourDup     =0xFA43;            // Same as 0xEEF2
  chrSmallRomanNumeralFiveDup     =0xFA44;            // Same as 0xEEF3
  chrSmallRomanNumeralSixDup      =0xFA45;            // Same as 0xEEF4
  chrSmallRomanNumeralSevenDup    =0xFA46;            // Same as 0xEEF5
  chrSmallRomanNumeralEightDup    =0xFA47;            // Same as 0xEEF6
  chrSmallRomanNumeralNineDup     =0xFA48;            // Same as 0xEEF7
  chrSmallRomanNumeralTenDup      =0xFA49;            // Same as 0xEEF8
  chrRomanNumeralOneDup           =0xFA4A;            // Same as 0x8754
  chrRomanNumeralTwoDup           =0xFA4B;            // Same as 0x8755
  chrRomanNumeralThreeDup         =0xFA4C;            // Same as 0x8756
  chrRomanNumeralFourDup          =0xFA4D;            // Same as 0x8757
  chrRomanNumeralFiveDup          =0xFA4E;            // Same as 0x8758
  chrRomanNumeralSixDup           =0xFA4F;            // Same as 0x8759
  chrRomanNumeralSevenDup         =0xFA50;            // Same as 0x875A
  chrRomanNumeralEightDup         =0xFA51;            // Same as 0x875B
  chrRomanNumeralNineDup          =0xFA52;            // Same as 0x875C
  chrRomanNumeralTenDup           =0xFA53;            // Same as 0x875D
  chrFullwidthNotSignDup2         =0xFA54;            // Same as 0xEEF9 & 0x81CA
  chrFullwidthBrokenBarDup        =0xFA55;            // Same as 0xEEFA
  chrFullwidthApostropheDup       =0xFA56;            // Same as 0xEEFB
  chrFullwidthQuotationMarkDup    =0xFA57;            // Same as 0xEEFC
  chrParenthesizedIdeographStockDup  =0xFA58;         // Same as 0x878A
  chrNumeroSignDup                =0xFA59;            // Same as 0x8782
  chrTelephoneSignDup             =0xFA5A;            // Same as 0x8784
  chrBecauseDup2                  =0xFA5B;            // Same as 0x81E6 & 0x879A

  chrLastSJISDoubleByte            =0xFCFC;

// Alternative character names.

  chrChouon  =chrKatakanaHiraganaProlongedSoundMark;

// Old character names.

implementation

end.

