/******************************************************************************
 *
 * Copyright (c) 1997-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ImcUtils.h
 *
 * Description:
 *      Routines to handle Internet Mail Consortium specs
 *
 * History:
 *      8/6/97  roger - Created
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ImcUtils; //DOLATER;

interface

implementation

end.

#ifndef EOF
#define EOF 0xffff
#endif


// Constants for some common IMC spec values.
#define parameterDelimeterChr       ';'
#define valueDelimeterChr           ':'
#define groupDelimeterChr           '.'
#define paramaterNameDelimiterChr   '='
#define endOfLineChr 0x0D
#define imcLineSeparatorString      "\015\012"
#define imcFilenameLength           32
#define imcUnlimitedChars           0xFFFE      // 64K, minus 1 character for null

// These are for functions called to handle input and output.  These are currently used
// to allow disk based or obx based transfers
typedef UInt16 GetCharF (const void *);
typedef void PutStringF(void *, const Char * const stringP);

#ifdef __GNUC__
/* DOLATER: jwm: Really, there's no such thing */
#define CONST_FUNC
#else
/* But CodeWarrior seems to believe there is! */
#define CONST_FUNC  const
#endif

#ifdef __cplusplus
extern "C" {
#endif

// maxChars does NOT include trailing null, buffer may be 1 larger.
// use imcUnlimitedChars if you don't want a max.
extern Char * ImcReadFieldNoSemicolon(void * inputStream, 
   CONST_FUNC GetCharF inputFunc, UInt16 * c, const UInt16 maxChars)
                     SYS_TRAP(sysTrapImcReadFieldNoSemicolon);

// maxChars does NOT include trailing null, buffer may be 1 larger.
// use imcUnlimitedChars if you don't want a max.
extern Char * ImcReadFieldQuotablePrintable(void * inputStream, CONST_FUNC GetCharF inputFunc, UInt16 * c, 
   const Char stopAt, const Boolean quotedPrintable, const UInt16 maxChars)
                     SYS_TRAP(sysTrapImcReadFieldQuotablePrintable);
   
extern void ImcReadPropertyParameter(void * inputStream, CONST_FUNC GetCharF inputFunc,
                              UInt16 * cP, Char * nameP, Char * valueP)
                     SYS_TRAP(sysTrapImcReadPropertyParameter);
   
extern void ImcSkipAllPropertyParameters(void * inputStream, CONST_FUNC GetCharF inputFunc, 
   UInt16 * cP, Char * identifierP, Boolean *quotedPrintableP)
                     SYS_TRAP(sysTrapImcSkipAllPropertyParameters);
   
extern void ImcReadWhiteSpace(void * inputStream, CONST_FUNC GetCharF inputFunc, 
   const UInt16 * const charAttrP, UInt16 * c)
                     SYS_TRAP(sysTrapImcReadWhiteSpace);
   
extern void ImcWriteQuotedPrintable(void * outputStream, CONST_FUNC PutStringF outputFunc, 
   const Char * stringP, const Boolean noSemicolons)
                     SYS_TRAP(sysTrapImcWriteQuotedPrintable);
   
extern void ImcWriteNoSemicolon(void * outputStream, CONST_FUNC PutStringF outputFunc, 
   const Char * const stringP)
                     SYS_TRAP(sysTrapImcWriteNoSemicolon);
   
extern Boolean ImcStringIsAscii(const Char * const stringP)
                     SYS_TRAP(sysTrapImcStringIsAscii);

#ifdef __cplusplus 
}
#endif

#undef CONST_FUNC

#endif   // _IMC_UTILS_H

