/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Progress.h
 *
 * Description:
 *        This header file defines a generic progress dialog interface
 *
 * History:
 *              6/4/97 from Ron Marianetti's net dialog stuff   Created by Gavin Peacock
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Progress;

interface

Uses {$ifdef PalmVer35} Traps30, Traps33, {$endif}
     Form, Rect, Window{, Event};

Const
  progressMaxMessage =128;
  progressMaxTitle   =31;   // max size for title of progress dialog

// Progress callback function
// The progress dialog will call this function to get the text to display for the
// current status.
// stage - the current stage of progess as defined by your app
// message - text that can be sent from the protocol
// cancel - true if the dialog is in cancel mode
// error - current error (func should return an error message in this case...
Type
  PrgCallbackDataPtr = ^PrgCallbackData;
  PrgCallbackData = Record
    stage: UInt16;              // <= current stage
    textP: pChar;               // => buffer to hold text to display
    textLen: UInt16;            // <= length of text buffer
    message: pChar;             // <= additional text for display
    error: Err;                 // <= current error
    bitmapId: UInt16;           // => resource ID of bitmap to display
    Flags: UInt16; //canceled:1;      // <= true if user has pressed the cancel button
         //UInt16 showDetails:1;      // <= true if user pressed down arrow for more details
         //UInt16 textChanged:1;      // => if true then update text (defaults to true)
         //UInt16 timedOut:1;         // <= true if update caused by a timeout
    timeout: UInt32;            // <> timeout in ticks to force next update (for animation)

    //progress bar info (Not Implemented)
    barMaxValue: UInt32;        // the maximum value for the progress bar, if = 0 then the bar is
                                // not visible
    barCurValue: UInt32;        // the current value of the progress bar, the bar will be drawn
                                // filled the percentage of maxValue \ value
    barMessage: pChar;          // additional text for display below the progress bar.
    barFlags: UInt16;           // reserved for future use.

    //
    // *** The following fields were added in PalmOS 3.2 ***
    //

    Flags2: UInt16; //delay:1;        // => if true delay 1 second after updating form icon/msg
    userDataP: Pointer;         // <= context pointer that caller passed to PrgStartDialog
  end;

// Boolean (*PrgCallbackFunc)  (PrgCallbackDataPtr cbP);
//  PrgCallbackFunc: Function(cbP: PrgCallbackDataPtr): Boolean;
  PrgCallbackFunc = Pointer;


//---------------------------------------------------------------------------
// Structure of the Progress Info structure. This structure should be stored
//  in the interface's globals. Each of the routines in SerNetIFCommon.c
//  take a pointer to this structure.
//---------------------------------------------------------------------------


  ProgressPtr = ^ProgressType;
  ProgressType = Record
    // This field contains a pointer to the open progress dialog
    frmP: FormPtr;                          // Our progress dialog ptr

    // This field is set a maximum time for the action to take place. A cancel
    // will be generated if this timeout is reached
    timeout: UInt32;                        // max time to wait in ticks
   
   
    // This boolean is set by either the protocol (through PrgUpdateDialog()) or UI 
    //  task to inform the UI that it needs to update it's progress dialog with new 
    //  information as stored in the error, stage, and message fields. 
    Flags: UInt16; //needUpdate:1;        // true if UI update required.


    // The following boolean is set by the UI task when the user hits the cancel button.
    // When the user cancels, the UI changes to display "Cancelling..." and then waits
    // for the protocol task to notice the user cancel and set the error field to
    //  netErrUserCancel before disposing the dialog. The SerIFUserCancel() which is
    //  called from the protocol task checks this boolean.
         //UInt16            cancel:1;            // true if cancelling


    // This boolean is set by PrvCheckEvents() after we've displayed an error message
    //  in the progress dialog and changed the "cancel" button to an "OK" button.
    //  This tells the dialog event handling code in PrvCheckEvents() that it should
    //  dispose of the dialog on the next hit of the cancel/OK button.
         //UInt16            waitingForOK:1;      // true if waiting for OK button hit.


    // This boolean gets set if the user hits the down button while the UI is up. It
    //  causes more detailed progress to be shown
         //UInt16            showDetails:1;       // show progress details.

    // This is set to true whenever the message text is changed. This allows the
    // display to be more efficient by not redrawing when not needed
         //UInt16            messageChanged: 1;
   
   
    //-----------------------------------------------------------------------
    // The following fields are set by PrgUpdateDialog() and used by PrgHandleEvent()
    //  to figure out what to display in the progress dialog
    //-----------------------------------------------------------------------
   
    // This word is set by the protocol task (through PrgUpdateDialog()) when an
    //  error occurs during connection establishment. If this error is non-nil
    //  and not equal to netErrUserCancel, the UI task will display the appropriate
    //  error message and change the cancel button to an OK button, set the waitingForOK
    //  boolean and wait for the user to  hit the OK button before disposing 
    //  the dialog. 
    error: UInt16;                             // error set by interface

    // This enum is set by the protocol task (through PrgUpdateDialog()) as it
    //  progresses through the  connection establishment and is checked by 
    //  PrgHandleEvent() when needUpate is true. It is used to determine what 
    //  string to display in the progress dialog.
    stage: UInt16;                             // which stage of the connection we're in


    // This is an additional string that is displayed in the progress dialog for
    //  certain stages. The netConStageSending stage for example uses this string
    //  for holding the text string that it is sending. It is set by
    //  PrgUpdateDialog().
    message: String[progressMaxMessage];   // connection stage message.
   
    reserved1: UInt8;
   
    // Used to cache current icon number so we don't unnecessarily redraw it
    lastBitmapID: UInt16;
   
    // Text array used to hold control title for the OK/Cancel button. This
    //  must be kept around while the control is present in case of updates.
    ctlLabel: String[7];

    serviceNameP: pChar;

    //progress bar stuff (Not implemented)
    lastBarMaxValue: UInt32;
    lastBarCurValue: UInt32;
   
    // stuff for saving old window state
    oldDrawWinH: WinHandle;     
    oldActiveWinH: WinHandle;     
    oldFrmP: FormPtr;       
    oldInsPtState: Boolean;       
    reserved2: UInt8;
    oldInsPtPos: PointType;

    textCallback: PrgCallbackFunc;

    title: String[progressMaxTitle];

    //
    // *** The following fields were added in PalmOS 3.2 ***
    //

    userDataP: Pointer;
  end;



// macro to test if the user has canceled
//#define PrgUserCancel(prgP) (prgP)->cancel

//-----------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------

{$ifdef PalmVer35}
Function PrgStartDialogV31(Const title: String; textCallback: PrgCallbackFunc): ProgressPtr;
      SYS_TRAP(sysTrapPrgStartDialogV31);

Function PrgStartDialog(Const title: String; textCallback: PrgCallbackFunc; userDataP: Pointer): ProgressPtr;
      SYS_TRAP(sysTrapPrgStartDialog);

Procedure PrgStopDialog(prgP: ProgressPtr; force: Boolean);
      SYS_TRAP(sysTrapPrgStopDialog);

Procedure PrgUpdateDialog(prgGP: ProgressPtr; err, stage: UInt16;
                          Const messageP: String; updateNow: Boolean);
      SYS_TRAP(sysTrapPrgUpdateDialog);

Function PrgHandleEvent(prgGP: ProgressPtr; var Event{: EventType}): Boolean;
      SYS_TRAP(sysTrapPrgHandleEvent);
{$endif}

implementation

end.


