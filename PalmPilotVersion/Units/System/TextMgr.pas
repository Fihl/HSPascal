/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: TextMgr.h
 *
 * Description:
 *          Header file for Text Manager.
 *
 * Written by TransPac Software, Inc.
 *
 * History:
 *       Created by Ken Krugler
 *    03/05/98 kwk   Created by Ken Krugler.
 *    02/02/99 kwk   Added charEncodingPalmLatin & charEncodingPalmSJIS,
 *                   since we've extended the CP1252 & CP932 encodings.
 *                   Added TxtUpperStr, TxtLowerStr, TxtUpperChar, and
 *                   TxtLowerChar macros.
 *    03/11/99 kwk   Changed TxtTruncate to TxtGetTruncationOffset.
 *    04/24/99 kwk   Moved string & character upper/lower casing macros
 *                   to IntlGlue library.
 *    04/28/99 kwk   Changed kMaxCharSize to maxCharBytes, as per Roger's request.
 *    05/15/99 kwk   Changed TxtIsValidChar to TxtCharIsValid.
 *    05/29/99 kwk   Removed include of CharAttr.h.
 *    07/13/99 kwk   Moved TxtPrepFindString into TextPrv.h
 *    09/22/99 kwk   Added TxtParamString (OS 3.5).
 *    10/28/99 kwk   Added the TxtCharIsVirtual macro.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit TextMgr;

interface

Uses ErrorBase, IntlMgr, CharAttr, Chars;

/***********************************************************************
 * Public constants
 ***********************************************************************/

// Various character encodings supported by the PalmOS. Actually these
// are a mixture of character sets (repetoires or coded character sets
// in Internet lingo) and character encodids (CES - character encoding
// standard). Many, however, are some of both (e.g. CP932 is the Shift-JIS
// encoding of the JIS character set + Microsoft's extensions).

Type
  CharEncodingType = (
    charEncodingUnknown = 0,   // Unknown to this version of PalmOS.

    charEncodingAscii,         // ISO 646-1991
    charEncodingISO8859_1,     // ISO 8859 Part 1
    charEncodingPalmLatin,     // PalmOS version of CP1252
    charEncodingShiftJIS,      // Encoding for 0208-1990 + 1-byte katakana
    charEncodingPalmSJIS,      // PalmOS version of CP932
    charEncodingUTF8,          // Encoding for Unicode
    charEncodingCP1252,        // Windows variant of 8859-1
    charEncodingCP932          // Windows variant of ShiftJIS
  );

// Transliteration operations for the TxtTransliterate call. We don't use
// an enum, since each character encoding contains its own set of special
// transliteration operations (which begin at translitOpCustomBase).

  TranslitOpType= UInt16;

Const
  translitOpUpperCase     =0;
  translitOpLowerCase     =1;

  translitOpCustomBase    =1000;     // Beginning of char-encoding specific ops.

  translitOpPreprocess    =0x8000;   // Mask for pre-process option, where
                                     // no transliteration actually is done.

// Names of the known encodings.

  encodingNameAscii       ='us-ascii';
  encodingNameISO8859_1   ='ISO-8859-1';
  encodingNameCP1252      ='ISO-8859-1-Windows-3.1-Latin-1';
  encodingNameShiftJIS    ='Shift_JIS';
  encodingNameCP932       ='Windows-31J';
  encodingNameUTF8        ='UTF-8';

// Maximum length of any encoding name.

  maxEncodingNameLength   =40;

// Flags available in the sysFtrNumCharEncodingFlags feature attribute.

  charEncodingOnlySingleByte =0x00000001;
  charEncodingHasDoubleByte  =0x00000002;
  charEncodingHasLigatures   =0x00000004;
  charEncodingLeftToRight    =0x00000008;

// Various byte attribute flags. Note that multiple flags can be
// set, thus a byte could be both a single-byte character, or the first
// byte of a multi-byte character.

  byteAttrFirst           =0x80;  // First byte of multi-byte char.
  byteAttrLast            =0x40;  // Last byte of multi-byte char.
  byteAttrMiddle          =0x20;  // Middle byte of muli-byte char.
  byteAttrSingle          =0x01;  // Single byte.

// Various sets of character attribute flags.

  charAttrPrint           =_DI|_LO|_PU|_SP|_UP|_XA;
  charAttrSpace           =_CN|_SP|_XS;
  charAttrAlNum           =_DI|_LO|_UP|_XA;
  charAttrAlpha           =_LO|_UP|_XA;
  charAttrCntrl           =_BB|_CN;
  charAttrGraph           =_DI|_LO|_PU|_UP|_XA;
  charAttrDelim           =_SP|_PU;

// Maximum size a single WChar character will occupy in a text string.

  maxCharBytes            =4;

// Text manager error codes.

  txtErrUknownTranslitOp           =txtErrorClass | 1;
  txtErrTranslitOverrun            =txtErrorClass | 2;
  txtErrTranslitOverflow           =txtErrorClass | 3;

/***********************************************************************
 * Public macros
 ***********************************************************************/

(***
#define  TxtCharIsSpace(ch)      ((TxtCharAttr(ch) & charAttrSpace) != 0)
#define  TxtCharIsPrint(ch)      ((TxtCharAttr(ch) & charAttrPrint) != 0)
#define  TxtCharIsDigit(ch)      ((TxtCharAttr(ch) & _DI) != 0)
#define  TxtCharIsAlNum(ch)      ((TxtCharAttr(ch) & charAttrAlNum) != 0)
#define  TxtCharIsAlpha(ch)      ((TxtCharAttr(ch) & charAttrAlpha) != 0)
#define  TxtCharIsCntrl(ch)      ((TxtCharAttr(ch) & charAttrCntrl) != 0)
#define  TxtCharIsGraph(ch)      ((TxtCharAttr(ch) & charAttrGraph) != 0)
#define  TxtCharIsLower(ch)      ((TxtCharAttr(ch) & _LO) != 0)
#define  TxtCharIsPunct(ch)      ((TxtCharAttr(ch) & _PU) != 0)
#define  TxtCharIsUpper(ch)      ((TxtCharAttr(ch) & _UP) != 0)
#define  TxtCharIsHex(ch)        ((TxtCharAttr(ch) & _XD) != 0)
#define  TxtCharIsDelim(ch)      ((TxtCharAttr(ch) & charAttrDelim) != 0)
(***)

// <c> is a hard key if the event modifier <m> has the command bit set
// and <c> is either in the proper range or is the calculator character.
//#define  TxtCharIsHardKey(m, c)  ((((m) & commandKeyMask) != 0) && \
//                        ((((c) >= hardKeyMin) && ((c) <= hardKeyMax)) || ((c) == calcChr)))

//#define  TxtPreviousCharSize(inText, inOffset)  TxtGetPreviousChar((inText), (inOffset), NULL)
//#define  TxtNextCharSize(inText, inOffset)      TxtGetNextChar((inText), (inOffset), NULL)


/***********************************************************************
 * Public routines
 ***********************************************************************/

// Return back byte attribute (first, last, single, middle) for <inByte>.

Function TxtByteAttr(inByte: UInt8): UInt8;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtByteAttr);

// Return back the standard attribute bits for <inChar>.

Function TxtCharAttr(inChar: WChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharAttr);

// Return back the extended attribute bits for <inChar>.

Function TxtCharXAttr(inChar: WChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharXAttr);

// Return the size (in bytes) of the character <inChar>. This represents
// how many bytes would be required to store the character in a string.

Function TxtCharSize(inChar: WChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharSize);

// Return the width (in pixels) of the character <inChar>.

Function TxtCharWidth(inChar: WChar): Int16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharWidth);

// Load the character before offset <inOffset> in the <inText> text. Return
// back the size of the character.

Function TxtGetPreviousChar(inText: pChar; inOffset: UInt32; outChar: pChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtGetPreviousChar);

// Load the character at offset <inOffset> in the <inText> text. Return
// back the size of the character.

Function TxtGetNextChar(inText: pChar; inOffset: UInt32; outChar: pChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtGetNextChar);

// Return the character at offset <inOffset> in the <inText> text.

Function TxtGetChar(inText: pChar; inOffset: UInt32): WChar;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtGetChar);

// Set the character at offset <inOffset> in the <inText> text, and
// return back the size of the character.

Function TxtSetNextChar(ioText: pChar; inOffset: UInt32; inChar: WChar): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtSetNextChar);

// Replace the substring "^X" (where X is 0..9, as specified by <inParamNum>)
// with the string <inParamStr>. If <inParamStr> is NULL then don't modify <ioStr>.
// Make sure the resulting string doesn't contain more than <inMaxLen> bytes,
// excluding the terminating null. Return back the number of occurances of
// the substring found in <ioStr>.

Function TxtReplaceStr(ioStr: pChar; inMaxLen: UInt16; inParamStr: pChar; inParamNum: UInt16): UInt16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtReplaceStr);

// Allocate a handle containing the result of substituting param0...param3
// for ^0...^3 in <inTemplate>, and return the locked result. If a parameter
// is NULL, replace the corresponding substring in the template with "".

Function TxtParamString(inTemplate, param0, param1, param2, param3: pChar): pChar;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtParamString);

// Return the bounds of the character at <inOffset> in the <inText>
// text, via the <outStart> & <outEnd> offsets, and also return the
// actual value of character at or following <inOffset>.

Function TxtCharBounds(inText: pChar; inOffset: UInt32; var outStart, outEnd: UInt32): WChar;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharBounds);

// Return the appropriate byte position for truncating <inText> such that it is
// at most <inOffset> bytes long.

Function TxtGetTruncationOffset(inText: pChar; inOffset: UInt32): UInt32;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtGetTruncationOffset);

// Search for <inTargetStr> in <inSourceStr>. If found return true and pass back
// the found position (byte offset) in <outPos>, and the length of the matched
// text in <outLength>.

Function TxtFindString(inSourceStr, inTargetStr: pChar;
         var outPos: UInt32; var outLength: UInt16): Boolean;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtFindString);

// Find the bounds of the word that contains the character at <inOffset>.
// Return the offsets in <*outStart> and <*outEnd>. Return true if the
// word we found was not empty & not a delimiter (attribute of first char
// in word not equal to space or punct).

Function TxtWordBounds(inText: pChar; inLength, inOffset: UInt32;
         var outStart, outEnd: UInt32): Boolean;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtWordBounds);

// Return the minimum (lowest) encoding required for <inChar>. If we
// don't know about the character, return encoding_Unknown.

Function TxtCharEncoding(inChar: WChar): CharEncodingType;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharEncoding);

// Return the minimum (lowest) encoding required to represent <inStr>.
// This is the maximum encoding of any character in the string, where
// highest is unknown, and lowest is ascii.

Function TxtStrEncoding(inStr: pChar): CharEncodingType;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtStrEncoding);

// Return the higher (max) encoding of <a> and <b>.

Function TxtMaxEncoding(a,b : CharEncodingType): CharEncodingType;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtMaxEncoding);

// Return a pointer to the 'standard' name for <inEncoding>. If the
// encoding is unknown, return a pointer to an empty string.

Function TxtEncodingName(inEncoding: CharEncodingType): pChar;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtEncodingName);

// Transliterate <inSrcLength> bytes of text found in <inSrcText>, based
// on the requested <inOp> operation. Place the results in <outDstText>,
// and set the resulting length in <ioDstLength>. On entry <ioDstLength>
// must contain the maximum size of the <outDstText> buffer. If the
// buffer isn't large enough, return an error (note that outDestText
// might have been modified during the operation). Note that if <inOp>
// has the preprocess bit set, then <outDstText> is not modified, and
// <ioDstLength> will contain the total space required in the destination
// buffer in order to perform the operation.

Function TxtTransliterate(inSrcText: pChar; inSrcLength: UInt16; outDstText: pChar;
         var ioDstLength: UInt16; inOp: TranslitOpType): Err;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtTransliterate);

// Return true if <inChar> is a valid (drawable) character. Note that we'll
// return false if it is a virtual character code.

Function TxtCharIsValid(inChar: WChar): Boolean;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCharIsValid);

// Compare the first <s1Len> bytes of <s1> with the first <s2Len> bytes
// of <s2>. Return the results of the comparison: < 0 if <s1> sorts before
// <s2>, > 0 if <s1> sorts after <s2>, and 0 if they are equal. Also return
// the number of bytes that matched in <s1MatchLen> and <s2MatchLen>
// (either one of which can be NULL if the match length is not needed).
// This comparison is "caseless", in the same manner as a find operation,
// thus case, character size, etc. don't matter.

Function TxtCaselessCompare(s1: pChar; s1Len: UInt16; var s1MatchLen: UInt16;
                            s2: pChar; s2Len: UInt16; var s2MatchLen: UInt16): Int16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCaselessCompare);

// Compare the first <s1Len> bytes of <s1> with the first <s2Len> bytes
// of <s2>. Return the results of the comparison: < 0 if <s1> sorts before
// <s2>, > 0 if <s1> sorts after <s2>, and 0 if they are equal. Also return
// the number of bytes that matched in <s1MatchLen> and <s2MatchLen>
// (either one of which can be NULL if the match length is not needed).

Function TxtCompare(s1: pChar; s1Len: UInt16; var s1MatchLen: UInt16;
                    s2: pChar; s2Len: UInt16; var s2MatchLen: UInt16): Int16;
      SYS_TRAP(sysTrapIntlDispatch, intlTxtCompare);

implementation

end.

