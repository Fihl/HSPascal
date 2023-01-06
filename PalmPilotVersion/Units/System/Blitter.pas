/***********************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Bitmap.h
 *
 * Description:
 *        Screen driver that supports color. Initially, only 2 bit gray is implemented
 *
 * History:
 *    September, 1999   Created by Bertrand Simon
 *       Name  Date     Description
 *       ----  ----     -----------
 *       BS    9/99     Create
 *       jmp   12/23/99 Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *******************************************************************/

Unit Blitter; //DOLATER;

interface

Uses Font, Window;

implementation

end.

#include <PalmTypes.h>
#include <CoreTraps.h>
#include <ErrorBase.h>
#include <Font.h>
#include <Window.h>

/**************************************************************************
 * Internal constants
 ***************************************************************************/
#define scrMaxLineBytes    160   // Max # of bytes in a scan line
                                 // used in compression/decompression calls

#define scrMaxDepth        8     // Same as hwrDisplayMaxDepth
                                 // used to reserve space for expanded patterns                                         
                                 // only used by WindowNew.c

/************************************************************
 * Blitter Errors
 *************************************************************/
#define  bltErrCompress                   (bltErrorClass | 1)
                                          

/**************************************************************************
 * enum for logical transfer modes
 ***************************************************************************/
typedef enum {scrCopy, scrAND, scrANDNOT, scrXOR, scrOR, scrCopyNOT} ScrOperation;


/************************************************************
 * Function pointer to routine used to convert source bitmap into
 *  destination bitmap depth. It converts infoP->srcBytesInLine bytes
 *  of pixels from srcWP into the destination depth and stores them
 *  into infoP->convSrcP.
 *************************************************************/
struct ScrBltInfoType;

typedef void (*ScrConvertDepthProcP)(void * srcWP, struct ScrBltInfoType * infoP);
typedef UInt16 (*TransparencyP)(UInt16 transIndex, UInt16 srcPix, UInt16 dstPix);

/**************************************************************************
 * Internal Drawing info structure used by Screen Driver. This structure is
 * used to hold local variables used by the drawing operations. 
 *
 * At the beginning of each drawing or blit operation, the basic fields
 *  in this structure are intialized using PrvGetBltInfo() 
 *  (for ScrCopyRectangle and ScrDrawChars) or PrvGetDrawInfo() (for
 *  ScrLineRoutine and ScrRectangleRoutine.
 *
 * Then the masks for the left and right edge and other line specific
 *  information is filled in by calling PrvGetLineInfo(). Most high
 *  level calls call PrvGetLineInfo() only once. The exception is 
 *  ScrDrawChars() because it essentially does a different bitblt
 *  operation for every character in the string. 
 * 
 ***************************************************************************/
typedef struct ScrBltInfoType {


   //-----------------------------------------------------------------------------
   // COMMON BASE INFO
   //............................................................................
   // The following fields are used by EVERY screen driver routine and are filled 
   //  in by both PrvGetBltInfo and  PrvGetDrawInfo.
   //-----------------------------------------------------------------------------
   ScrOperation      op;               // which drawing mode to use
   Int16             height;           // height of operation

   UInt16 *          dstBaseP;         // base address of window we're blitting to
   UInt32            dstRowBytes;      // rowBytes of window
   UInt16            dstDepth;         // bits/pixel
   UInt16            dstShift;         // log base 2 of dstDepth
   UInt16            dstPixelsInWordZ; // Number of pixels in a word -1
                                       // Z for zero based 
   UInt16            forePixels;       // packed indices of foreground color
                                       //  in destination bitmap 
   UInt16            backPixels;       // packed indices of background color
                                       //  in destination bitmap
   void *            oneBitTableP;     // pointer to table that maps 1 bit source
                                       //  into destination depth sans color
   ScrConvertDepthProcP convertP;      // procedure to use for converting the source pixels
                                       //  to the destination depth and color
   TransparencyP     transparentP;     // Procedure to use for transparency

   //-----------------------------------------------------------------------------
   // BLIT ONLY
   //............................................................................
   // The following fields are only used by blitting operations (ScrCopyRectangle
   //  and ScrDrawChars and are filled in by PrvGetBltInfo only
   //-----------------------------------------------------------------------------
   UInt16 *          srcBaseP;         // base address of window we're blitting from
   UInt32            srcRowBytes;      // rowBytes of window
   UInt16            srcDepth;         // bits/pixel
   UInt16            srcShift;         // log base 2 of srcDepth
   UInt16            srcPixelsInWordZ; // 0x0F for 1 bit, 0x07 for 2 bit, etc. 

   UInt16 *          convSrcP;         // pointer to buffer that can hold 1
                                       //  scanline of source bitmap converted
                                       //  to destination bitmap format. 
   UInt16            dynConvSrcP:1;    // true if convSrcP was dynamically allocated
                                       //  and needs to be freed
   UInt8 *           colorTranslateP;  // Color translation table
   
   //-----------------------------------------------------------------------------
   // DRAW ONLY
   //............................................................................
   // The following fields are only used by drawing operations (ScrDrawLineRoutine
   //  and ScrRectangleRoutine) and are filled in by PrvGetDrawInfo only
   //-----------------------------------------------------------------------------
   UInt8 *           patternP;         // pointer to pattern to use           
   Boolean           simple;           // true if scrCopy with solid color
   
   
   
   //-----------------------------------------------------------------------------
   // COMMON LINE INFO 
   //............................................................................
   // The following fields are are filled in by PrvGetLineInfo. These are fields that
   //   would change with every character drawn in ScrDrawChars() but common to the 
   //   entire operation in the other routines (ScrCopyRectangle, ScrLineRouting, 
   //   ScrRectangleRoutine).
   //-----------------------------------------------------------------------------
   UInt16 *          dstP;             // byte address of first dst line
   UInt32            dstRowDelta;      // delta bytes from row to row

   UInt16            leftMask;         // mask for leftmost word of row in dest
   UInt16            rightMask;        // mask for rightmost word of row in dest
   Int16             midWords;         // # of words between left and right mask in dest

   // The srcP and srcRowDelta fields are only filled in for blit operations 
   //  (when infoP->srcBaseP is not nil). 
   UInt16 *          srcP;             // byte address of first source line
   UInt32            srcRowDelta;      // delta bytes from row to row
   UInt16            forward:1;        // true if copying forward, false if
                                       // backward. 
   // The srcBytesInLine field contains the number
   // of bytes of source needed to fill 1 scan line of destination
   UInt16            srcBytesInLine;
   
   // bitOffsetP - # of bits that each word in the expanded source
   //          must be shifted right by in order to line up with
   //          the destination. 
   // srcWordOffsetP - starting word offset into the expanded source 
   //              that we must start copying from for the blit
   Int16             bitOffset;
   Int16             srcWordOffset;

   // These values hold the starting point of the source in case the source is
   // compressed.
   UInt16            srcTop;           // first scan line to display
   UInt16            srcLeft;          // first pixed from left to display

   Boolean           useTransparency;  // 'true' if this blit has a transparent color
   UInt8             transparentIndex; // index of the transparent color.
   
   } ScrBltInfoType;
typedef ScrBltInfoType* ScrBltInfoPtr;



/**************************************************************************
 * A convenient structure for accessing quad words.
 ***************************************************************************/
typedef struct UInt64Hack {
   UInt32 hiWords;
   UInt32 loWords;
} UInt64Hack;



/**************************************************************************
 * Structure of Screen Driver globals
 ***************************************************************************/
typedef struct ScrGlobalsType {
   BitmapType        bitmap;              // Bitmap info (rowBytes, depth, etc)
                                          // a pointer to this field is stored in
                                          // the bitmapP field of onscreen windows
   ColorTableType    colorTable;       // Colortable of the bitmap + 1 color entry
   RGBColorType      colorEntries[256];   // max colortable size 256 colors
      // еее DOLATER -- make sure max colortable size is based on hwrDisplayMaxDepth
   MemPtr               baseAddr;            // Following the bitmap (flags indirect)
                                          // is the address (part of bitmapType)
   CustomPatternType grayPat;             // Gray pattern
   Boolean           doDrawNotify;        // call ScrDrawNotify after drawing
   Boolean           clutDirty;           // True if the CLUT has been changed since the last
                                          // application was launched.
   AbsRectType       updateR;             // update rect when in remote mode
   UInt32            lastUpdate;          // Tickcount of last update

   // This buffer is used to hold a scan line of a source blit that
   // has been bit depth converted to match the destination bitmap.
   UInt16            expSrcSize;
   UInt16            *expSrcP;
   UInt8             *colorTranslateP[4]; // 4 color translate table to current palette
                                          // [0] for 1 bit depth to current, [1] for 2 bits etc...
   ScrBltInfoType       bltInfo;          // Buffer to hold one infoType structure used by the blitter
   } ScrGlobalsType;
typedef ScrGlobalsType* ScrGlobalsPtr;



/**************************************************************************
 * Structure for compression/decompression state object type
 ***************************************************************************/
typedef struct CompStateType {
   UInt8 data[8];
} CompStateType;

typedef CompStateType *CompStatePtr;




/************************************************************
 * Function Prototypes
 *************************************************************/
#ifdef __cplusplus
extern "C" {
#endif

// Initialization
// еее DOLATER -- move to compatibility file
#define ScrInit() WinScreenInit()


// BitBlt Functions
Err   ScrCopyRectangle(WinPtr sourceWindow, WinPtr destWindow,
               Int16 fromX, Int16 fromY, Int16 toX, Int16 toY,
               Int16 bitCount, Int16 lineCount)
            SYS_TRAP(sysTrapScrCopyRectangle);
                  
Err BltCopyRectangle(BitmapType * srcBitmapP, BitmapType * dstBitmapP, DrawStateType * drawStateP,
       Int16 fromX, Int16 fromY, Int16 toX, Int16 toY, Int16 width, Int16 height)
            SYS_TRAP(sysTrapBltCopyRectangle);

                  
// Character Functions
void  ScrDrawChars(WinPtr pWindow, Int16 xLoc, Int16 yLoc, Int16 xExtent, Int16 yExtent,
               Int16 clipTop, Int16 clipLeft, Int16 clipBottom, Int16 clipRight,
               const Char * const chars, Int16 len, FontPtr fontPtr)
            SYS_TRAP(sysTrapScrDrawChars);

void BltDrawChars(BitmapType * dstBitmapP, DrawStateType * drawStateP,
         Int16 toX, Int16 toY, Int16 xExtent, Int16 yExtent,
          Int16 clipTop, Int16 clipLeft, Int16 clipBottom,  Int16 clipRight, 
          const Char * const charsP, UInt16 len, FontPtr fontP)
            SYS_TRAP(sysTrapBltDrawChars);

// Line Draw Functions
void  ScrLineRoutine(WinPtr pWindow, Int16 x1, Int16 y1, Int16 x2, Int16 y2)
            SYS_TRAP(sysTrapScrLineRoutine);
            
void BltLineRoutine(BitmapType * bitmapP, DrawStateType * drawStateP, 
      Int16 x1, Int16 y1, Int16 x2, Int16 y2)
         SYS_TRAP(sysTrapBltLineRoutine);

void  ScrRectangleRoutine(WinPtr pWindow, Int16 x, Int16 y, Int16 extentX, 
               Int16 extentY)
            SYS_TRAP(sysTrapScrRectangleRoutine);

void BltRectangleRoutine(BitmapType * bitmapP, DrawStateType * drawStateP,
    Int16 x, Int16 y, Int16 extentX, Int16 extentY)
            SYS_TRAP(sysTrapBltRectangleRoutine);

// Utility Functions
void  ScrScreenInfo(WinPtr pWindow)
            SYS_TRAP(sysTrapScrScreenInfo);
            
void  ScrDrawNotify(Int16 updLeft, Int16 updTop,  Int16 updWidth, Int16 updHeight)
            SYS_TRAP(sysTrapScrDrawNotify);
            
void  ScrSendUpdateArea(Boolean force)    
            SYS_TRAP(sysTrapScrSendUpdateArea);

UInt16 ScrCompressScanLine(UInt8 * lineP, UInt8 * prevLineP, UInt16 width, 
               UInt8 * dstParamP, Boolean firstLine)
            SYS_TRAP(sysTrapScrCompressScanLine);

UInt16 ScrDeCompressScanLine(UInt8 * srcP, UInt8 * dstP, UInt16 width)
            SYS_TRAP(sysTrapScrDeCompressScanLine);

Int32 ScrCompress(BitmapCompressionType compressionMethod,
                  UInt8* srcP, UInt32 srcBufLen,
                  UInt8* dstP, UInt32 dstBufLen,
                  CompStateType* compStateP)
            SYS_TRAP(sysTrapScrCompress);

Int32 ScrDecompress(BitmapCompressionType compressionMethod,
                    UInt8* srcP, UInt32 srcBufLen,
                    UInt8* dstP, UInt32 dstBufLen,
                    CompStateType* decompStateP)         
            SYS_TRAP(sysTrapScrDecompress);

Err BltFindIndexes(UInt16 numEntries, RGBColorType *matchColors,
               const ColorTableType *refColorTableP)
            SYS_TRAP(sysTrapBltFindIndexes);

/*
void* BltGetBitsAddr(BitmapType* bitmapP)
            SYS_TRAP(sysTrapBltGetBitsAddr);
*/
#ifdef __cplusplus 
}
#endif



#endif // __BLITTER_H__

