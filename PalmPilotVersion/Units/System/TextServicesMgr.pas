/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: TextServicesMgr.h
 *
 * Description:
 *    Header file for Text Services Manager.
 *
 * History:
 *       Created by Ken Krugler
 *    03/05/98 kwk   Created by Ken Krugler.
 *    02/03/99 kwk   Changed name to TextServicesMgr.h, was TextServices.h.
 *    10/20/99 kwk   Moved private stuff into TextServicesPrv.h
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit TextServicesMgr; //DOLATER;

interface

Uses SysEvent, SystemMgr;

implementation

end.

//#define m68kMoveQd2Instr   0x7400

// Selectors for routines found in the international manager. The order
// of these selectors MUST match the jump table in TextServicesMgr.c.

typedef enum {
   tsmGetFepMode = 0,
   tsmSetFepMode,
   
   tsmHandleEvent,
   
   tsmMaxSelector = tsmHandleEvent,
   tsmBigSelector = 0x7FFF          // Force tsmSelector to be 16 bits.
} TsmSelector;


/***********************************************************************
 * Public constants
 ***********************************************************************/

// Our UInt32 version number installed as feature: tsmFtrCreator,tsmFtrVersion
// 0xMMmfsbbb, where MM is major version, m is minor version
// f is bug fix, s is stage: 3-release,2-beta,1-alpha,0-development,
// bbb is build number for non-releases 
// V1.12b3   would be: 0x01122003
// V2.00a2   would be: 0x02001002
// V1.01     would be: 0x01013000

#define     tsmAPIVersion     (sysMakeROMVersion(3, 5, 0, sysROMStageRelease, 0))

// Possible values for the .buttonID field in a tsmFepButtonEvent event.
#define tsmFepButtonConvert   0
#define tsmFepButtonConfirm   1
#define tsmFepButtonKana      2
#define tsmFepButtonOnOff     3

/********************************************************************
 * Type and creator of Text Services Library database
 ********************************************************************/
 
// Feature Creators and numbers, for use with the FtrGet() call.
#define     tsmFtrCreator        sysFileCTextServices

// Selector used with call to FtrGet(tsmFtrCreator, xxx) to get the version number
// of the Text Services Manager Fep (front-end processor) API.
#define     tsmFtrNumFepVersion     0

// Types. Used to identify the Text Services library databases.
#define     tsmLibType           sysFileTLibrary   

// DOLATER kwk - figure out if prefs type needs to be here.
#define     tsmPrefsType         'rsrc'            // Our Preferences Database type

// Name to used with SysLibFind.
#define     tsmFepLibName        "Tsm Fep Library"

// Tsm Fep library traps, for calling input methods.
enum {
   tsmLibTrapFepOpen = sysLibTrapOpen,
   tsmLibTrapFepClose = sysLibTrapClose,
   tsmLibTrapFepSleep = sysLibTrapSleep,
   tsmLibTrapFepWake = sysLibTrapWake,
   
   tsmLibTrapGetFepInfo = sysLibTrapCustom,
   tsmLibTrapFepHandleEvent,
   tsmLibTrapFepMapEvent,
   tsmLibTrapFepTerminate,
   tsmLibTrapFepReset,
   tsmLibTrapFepCommitAction,
   tsmLibTrapFepDrawModeIndicator,
   tsmLibTrapGetFepMode,
   
   tsmLibTrapFepReserved0,
   tsmLibTrapFepReserved1,
   tsmLibTrapFepReserved2,
   tsmLibTrapFepReserved3,
   tsmLibTrapFepReserved4,
   tsmLibTrapFepReserved5,
   tsmLibTrapFepReserved6,
   tsmLibTrapFepReserved7,
   tsmLibTrapFepReserved8,
   tsmLibTrapFepReserved9,
   
   tsmLibTrapFepCustom        // First custom Tsm Fep trap starts here.
};

// Errors specific to the Text Services Fep library.

#define  tsmErrUnimplemented        (tsmErrorClass | 0)
#define  tsmErrFepNeedCommit        (tsmErrorClass | 1)
#define  tsmErrFepCantCommit        (tsmErrorClass | 2)
#define  tsmErrFepNotOpen           (tsmErrorClass | 3)
#define  tsmErrFepStillOpen         (tsmErrorClass | 4)
#define  tsmErrFepWrongAPI          (tsmErrorClass | 5)
#define  tsmErrFepWrongEncoding     (tsmErrorClass | 6)
#define  tsmErrFepWrongLanguage     (tsmErrorClass | 7)
#define  tsmErrFepReentrancy        (tsmErrorClass | 8)
#define  tsmErrFepCustom            (tsmErrorClass | 128)

// Input mode - used with TsmGetFepMode.

typedef enum {
   tsmFepModeDefault,
   tsmFepModeOff,
   
   tsmFepModeCustom = 128,
   
   tsmFepModeBig = 0x7fff  // Force it to be 16 bits.
} TsmFepModeType;


/***********************************************************************
 * Public types
 ***********************************************************************/

// Structure returned by TsmLibGetFepInfo routine.
typedef struct {
   UInt32   apiVersion;    // Tsm API implemented by library.
   UInt32   libVersion;    // Custom API implemented by library.
   UInt32   libMaker;      // Who made this input method?
   UInt16   encoding;      // e.g. encoding_CP1252
   UInt16   language;      // e.g. JAPANESE
} TsmFepInfoType;

// Structure passed to TsmFepHandleEvent routine.
typedef struct {
   Int16       penOffset;  // Offset (relative to start of inline text)
                           // of event's screenX/screenY location.
   Boolean     penLeading; // True -> position is on leading edge of the
                           // character at penOffset.
   Boolean     formEvent;  // True -> caller is form code, thus NO CHANGES
                           // to TsmStatusRec are allowed.
   UInt16      maxInline;  // Max allowable size of inline, in bytes.
   Char *      primeText;  // ptr to selected text (if inline not active)
   UInt16      primeOffset;   // Offset to selected text.
   UInt16      primeLen;   // Length of selected text.
} TsmFepEventType;

// Structure exchanged with many Fep routines. This is how
// the Fep tells the editing code what to display, and how
// to display it. Note that it's also the context record for the
// Fep, thus additional (private) conversion information will
// typically be appended by the Fep.

typedef struct {
   UInt16      refnum;        // Refnum of Fep shared library.
   
   Char*       inlineText;    // ptr to inline text.
   
   UInt16      convertedLen;  // Length of converted text.
   UInt16      pendingLen;    // Length of unconverted (pending) text.
   
   UInt16      selectStart;   // Start of selection range.
   UInt16      selectEnd;     // End of selection range (can extend past
                              // end of inline text)
   
   UInt16      convertStart;  // Start of converted clause highlighting
   UInt16      convertEnd;    // End of converted clause highlighting
} TsmFepStatusType;

// Structure returned by TsmLibFepHandleEvent/TsmLibFepTerminate routines
// and passed to the TsmLibFepCommitAction routine. Note that the updateText
// and updateSelection flags are for efficiency only - the field code can
// use these to reduce the amount of redrawing required.

typedef struct {
   UInt16   dumpLength;          // Length of text to dump (or zero)
   UInt16   primedLength;        // Length of priming text used by FEP
   
   Boolean  updateText;          // True -> update inline text.
   Boolean  updateSelection;     // True -> update selection range.
   Boolean  updateFepMode;       // True -> update Fep mode indicator.
   
   Boolean  handledEvent;        // True -> Fep handled event.
} TsmFepActionType;

/***********************************************************************
 * Public routines
 ***********************************************************************/

// Return the current mode for the fep indicated by <inStatusP>, or the
// active fep's current session if <inStatusP> is nil.
Function TsmGetFepMode(var inStatusP: TsmFepStatusType): TsmFepModeType;
      SYS_TRAP(sysTrapTsmDispatch, tsmGetFepMode);

// Set the mode for the fep indicated by <inStatusP, or the active fep's
// current session if <inStatusP> is nil. The current mode is returned.
Function TsmSetFepMode(TsmFepStatusType* ioStatusP, TsmFepModeType inNewMode): TsmFepModeType;
      SYS_TRAP(sysTrapTsmDispatch, tsmSetFepMode);

// See if Text Services wants to handle the event.
Function TsmHandleEvent(const SysEventType* inEventP, Boolean inProcess): Boolean;
      SYS_TRAP(sysTrapTsmDispatch, tsmHandleEvent);






// Open up an instance of the Fep. The Fep is responsible for allocating
// the TsmFepStatusType structure (to which it might append additional
// context information) and returning back a pointer to it.
Err TsmLibFepOpen(UInt16 inRefnum, TsmFepStatusType** outStatusP)
                  SYS_TRAP(tsmLibTrapFepOpen);

// Close down an instance of the Fep. The Fep is responsible
// for disposing of the TsmFepStatusType which it allocated in TsmLibFepOpen().
Err TsmLibFepClose(UInt16 inRefnum, TsmFepStatusType* ioStatusP)
                  SYS_TRAP(tsmLibTrapFepClose);

// TsmLibFepSleep and TsmLibFepWake do nothing.
Err TsmLibFepSleep(UInt16 inRefnum)
                  SYS_TRAP(tsmLibTrapFepSleep);

Err TsmLibFepWake(UInt16 inRefnum)
                  SYS_TRAP(tsmLibTrapFepWake);

// Return information about the Fep in the TsmFepInfoType structure.
Err TsmLibGetFepInfo(UInt16 inRefnum, TsmFepInfoType* outInfoP)
                  SYS_TRAP(tsmLibTrapGetFepInfo);

// Handle an event passed in <inEventP>. Additional information about the event
// is passed in the TsmFepEventType structure. Update the inline text data in
// the TsmFepStatusType, and tell the caller what happened by setting up the
// TsmFepActionType structure (including whether the event was handled by the
// Fep).
Err TsmLibFepHandleEvent(  UInt16 inRefnum,
                           const SysEventType* inEventP,
                           const TsmFepEventType* inTsmEventP,
                           TsmFepStatusType* ioStatusP,
                           TsmFepActionType* outActionP)
                  SYS_TRAP(tsmLibTrapFepHandleEvent);

// Decide if <inEvent> should be remapped to some other event. If so, return true. If
// we return true, and <inProcess> is true, then go ahead and perform the remapping by
// posting a new event with the remapped info.
Boolean TsmLibFepMapEvent( UInt16 inRefnum,
                           const TsmFepStatusType* inStatusP,
                           const SysEventType* inEventP,
                           Boolean inProcess)
                  SYS_TRAP(tsmLibTrapFepMapEvent);

// Terminate an inline session. Typically this involves 'dumping' all of the
// converted text, and potentially deleting any untransliterated input text.
// As with TsmLibFepHandleEvent, update the inline text data in the TsmFepStatusType,
// and indicate what was done in the TsmFepActionType.
Err TsmLibFepTerminate(UInt16 inRefnum, TsmFepStatusType* ioStatusP, TsmFepActionType* outActionP)
                  SYS_TRAP(tsmLibTrapFepTerminate);

// Reset an inline session. The state of the Fep is reset to empty, raw
// text, nothing to dump, etc. This call should only be made when the conversion
// results are not required, otherwise TsmTerminate should be used.
Err TsmLibFepReset(UInt16 inRefnum, TsmFepStatusType* ioStatusP)
                  SYS_TRAP(tsmLibTrapFepReset);

// The caller has processed the action which was returned by either the
// TsmHandleEvent or TsmTerminate routine, so it is now safe to reset any
// temporary state information (e.g. dumped text) in <ioStatus>.
Err TsmLibFepCommitAction(UInt16 inRefnum, TsmFepStatusType* ioStatusP)
                  SYS_TRAP(tsmLibTrapFepCommitAction);

// Draw the Fep mode indicator at location <x,y>.
Boolean TsmLibFepDrawModeIndicator( UInt16 inRefnum,
                                    const TsmFepStatusType* inStatusP,
                                    UInt16 state, 
                                    Int16 x,
                                    Int16 y)
                  SYS_TRAP(tsmLibTrapFepDrawModeIndicator);

// Get the Fep mode.
TsmFepModeType TsmLibGetFepMode(UInt16 inRefnum, const TsmFepStatusType* inStatusP)
                  SYS_TRAP(tsmLibTrapGetFepMode);

// Standard declaration for unimplemented Tsm routines. They all return an Err,
// and their first parameter is a refnum (followed by zero..n additional parameters).
Err TsmLibReserved(UInt16 inRefnum);

implementation

end.

