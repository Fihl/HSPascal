/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: UIResources.h
 *
 * Description:
 *        This file defines UI resource types & ids.
 *
 * History:
 *              ??/??/??        ???     Created.
 *              06/29/99        CS              Added constantRscType & ResLoadConstant().
 *              07/07/99        kwk     Added fepFieldExtraBytesID, maxCategoryWidthID,
 *                                                      extraStackSpaceID.
 *              07/09/99        kwk     Added silkscreenRscType & formRscType.
 *              07/12/99        kwk     Added sysFatalAlert.
 *              07/18/99        kwk     Added strListRscType, system string list resources.
 *              08/08/99        kwk     Added sysEditMenuJapAddWord/LookupWord.
 *              09/07/99        kwk     Added StrippedBase/GenericLaunchErrAlert
 *              09/17/99 jmp    Added a new NoteView form and menu to eliminate the goto
 *                              top/bottom menu items and other extraneous UI elements
 *                              that we no longer use in the built-in apps. We need to keep
 *                              the old NoteView form and menu around for backwards
 *                              compatibility.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit UIResources;

interface

Uses {x$ifdef PalmVer35} Traps35; {x$endif}

// System Default app icon (for apps missing a tAIB)
Const defaultAppIconBitmap           =10000;
Const defaultAppSmallIconBitmap      =10001;

// System version string ID - this is hidden in
// the SystemVersion.rsrc resource, because the 'system' resources
// don't have ResEdit formats.
Const systemVersionID                =10000;


//------------------------------------------------------------
// Resource Type Constants 
//------------------------------------------------------------

Const strRsc                         ='tSTR';
Const ainRsc                         ='tAIN';
Const iconType                       ='tAIB';
Const bitmapRsc                      ='Tbmp';
Const bsBitmapRsc                    ='Tbsb';
Const alertRscType                   ='Talt';
Const kbdRscType                     ='tkbd';
Const MenuRscType                    ='MBAR';
Const fontRscType                    ='NFNT';
Const verRsc                         ='tver';
Const appInfoStringsRsc              ='tAIS';
Const fontIndexType                  ='fnti';
Const midiRsc                        ='MIDI';
Const colorTableRsc                  ='tclt';
Const MenuCtlRsc                     ='tcbr';
Const constantRscType                ='tint';
Const formRscType                    ='tFRM';
Const silkscreenRscType              ='silk';
Const strListRscType                 ='tSTL';
Const wrdListRscType                 ='wrdl';


//------------------------------------------------------------
// App Version Constants
//------------------------------------------------------------

Const appVersionID                   =1;     // our apps use tver 1 resource
Const appVersionAlternateID          =1000;  // CW Constructor uses tver 1000 resource
                                             // so we'll look for ours first, then try theirs
Const ainID                          =1000;

//  kwk - should resource ids >= 10000 be in a private header file, so that
// developers know they're not guaranteed to be around (or in the same format)?

//------------------------------------------------------------
// System Information Constants
//------------------------------------------------------------

Const fepFieldExtraBytesID          =10000; // Extra bytes for expanded field if FEP is active.
Const maxCategoryWidthID            =10001; // Max pixel width for category trigger.
Const extraStackSpaceID             =10002; // Extra stack space for non-English locales


//------------------------------------------------------------
// System Alerts
//------------------------------------------------------------

Const SelectACategoryAlert           =10000;

// This alert broke 1.0 applications and is now disabled until later.
// It is redefined below (10015).
//Const RemoveCategoryAlert          =10001;
//Const RemoveCategoryRecordsButton  =0;
//Const RemoveCategoryNameButton     =1;
//Const RemoveCategoryCancelButton   =2;

Const LowBatteryAlert                =10002;
Const VeryLowBatteryAlert            =10003;
Const UndoAlert                      =10004;
Const UndoCancelButton               =1;

Const MergeCategoryAlert             =10005;
Const MergeCategoryYes               =0;
Const MergeCategoryNo                =1;

Const privateRecordInfoAlert         =10006;

Const ClipboardLimitAlert            =10007;

Const CategoryExistsAlert            =10012;

Const DeviceFullAlert                =10013;

Const categoryAllUsedAlert           =10014;

Const RemoveCategoryAlert            =10015;    // See alert 10001
Const RemoveCategoryYes              =0;
Const RemoveCategoryNo               =1;

Const DemoUnitAlert                  =10016;

Const NoDataToBeamAlert              =10017;

// New for PalmOS 3.1
Const LowCradleChargedBatteryAlert      =10018; // (Not present in Palm VII)
Const VeryLowCradleChargedBatteryAlert  =10019; // (Not present in Palm VII)

// New for PalmOS 3.1 (Instant Karma only)
Const CategoryTooLongAlert           =10020;    // (Not present in Palm VII)

// New for PalmOS 3.2 - Alerts used by the ErrAlertCustom()  call.
Const ErrOKAlert                     =10021;    // Error Alert with just an OK button
Const ErrOKCancelAlert               =10022;    // Error Alert with an OK & Cancel button
Const ErrCancelAlert                 =10023;    // Error Alert with just Cancel button.  Special case for antenna down alert.
Const InfoOKAlert                    =10024;    // Info alert with just an OK button
Const InfoOKCancelAlert              =10025;    // Info alert with an OK & Cancel button
Const InfoCancelAlert                =10026;    // Info alert with just a Cancel button
Const PrivacyWarningAlert            =10027;    // Privacy warning for weblib
Const ConfirmationOKAlert            =10028;    // Confirmation alert with just an OK button
Const ConfirmationOKCancelAlert      =10029;    // Confirmation alert with an OK & Cancel button
Const ConfirmationCancelAlert        =10030;    // Confirmation alert with just a Cancel button
Const WarningOKAlert                 =10031;    // Warning Alert with just an OK button
Const WarningOKCancelAlert           =10032;    // Warning Alert with an OK & Cancel button
Const WarningCancelAlert             =10033;    // Warning Alert with just Cancel button.  Special case for antenna down alert.

// New for PalmOS 3.5 - Launch error alerts
Const StrippedBaseLaunchErrAlert     =10034;    // Launch error because of stripped base.
Const GenericLaunchErrAlert          =10035;    // Generic launch error.

// New for PalmOS 3.5 - Fatal Alert template
Const sysFatalAlert                  =10100;    // Template for fatal alert

// New for PalmOS 3.5 - Alerts used by new security traps
Const secInvalidPasswordAlert                       =13250;
Const secGotoInvalidRecordAlert                     =13251;
Const secShowPrivateTempPassEntryAlert              =13260;
Const secShowPrivatePermanentPassEntryAlert         =13261;
Const secShowMaskedPrivateTempPassEntryAlert        =13264;
Const secShowMaskedPrivatePermanentPassEntryAlert   =13265;
Const secHideRecordsAlert                           =13268;
Const secMaskRecordsAlert                           =13269;
Const secHideMaskRecordsOK                          =0;
Const secHideMaskRecordsCancel                      =1;

// command-bar bitmaps
Const BarCutBitmap                   =10030;
Const BarCopyBitmap                  =10031;
Const BarPasteBitmap                 =10032;
Const BarUndoBitmap                  =10033;
Const BarBeamBitmap                  =10034;
Const BarSecureBitmap                =10035;
Const BarDeleteBitmap                =10036;
Const BarInfoBitmap                  =10037;

//Masking bitmaps
Const SecLockBitmap                  =10050;
Const SecLockWidth                   =6;
Const SecLockHeight                  =8;

// System Menu Bar and Menus
Const sysEditMenuID                  =10000;
Const sysEditMenuUndoCmd             =10000;
Const sysEditMenuCutCmd              =10001;
Const sysEditMenuCopyCmd             =10002;
Const sysEditMenuPasteCmd            =10003;
Const sysEditMenuSelectAllCmd        =10004;
Const sysEditMenuSeparator           =10005;
Const sysEditMenuKeyboardCmd         =10006;
Const sysEditMenuGraffitiCmd         =10007;

// Dynamically added to System Edit menu at runtime
Const sysEditMenuJapAddWord          =10100;
Const sysEditMenuJapLookupWord       =10101;

// Note View Menu Bar and Menus
Const noteMenuID                     =10200; // Old NoteView MenuBar
Const noteUndoCmd                    =sysEditMenuUndoCmd;
Const noteCutCmd                     =sysEditMenuCutCmd;
Const noteCopyCmd                    =sysEditMenuCopyCmd;
Const notePasteCmd                   =sysEditMenuPasteCmd;
Const noteSelectAllCmd               =sysEditMenuSelectAllCmd;
Const noteSeparator                  =sysEditMenuSeparator;
Const noteKeyboardCmd                =sysEditMenuKeyboardCmd;
Const noteGraffitiCmd                =sysEditMenuKeyboardCmd;

Const noteFontCmd                    =10200; // These are here for backwards
Const noteTopOfPageCmd               =10201; // compatibility.  The built-in
Const noteBottomOfPageCmd            =10202; // apps no longer use them.
Const notePhoneLookupCmd             =10203;

Const newNoteMenuID                  =10300; // The Edit Menu for the new NoteView.
Const newNoteFontCmd                 =10300; // MenuBar is the same as it is for
Const newNotePhoneLookupCmd          =10301; // the old NoteView MenuBar.

// Note View (used by Datebook, To Do, Address, and Expense apps)
Const NoteView                       =10900; // The new NoteView is "new" as of Palm OS 3.5.
Const NewNoteView                    =10950; // Same as old NoteView, but points to newNoteMenuID and doesn't ref UI objects listed below.
Const NoteField                      =10901;
Const NoteDoneButton                 =10902;
Const NoteSmallFontButton            =10903; // Not in NewNoteView, use FontCmd instead.
Const NoteLargeFontButton            =10904; // Not in NewNoteView, use FontCmd instead.
Const NoteDeleteButton               =10905;
Const NoteUpButton                   =10906; // Not in NewNoteView, use scrollbars now.
Const NoteDownButton                 =10907; // Not in NewNoteView, use scrollbars now.
Const NoteScrollBar                  =10908;
Const NoteFontGroup                  =1;
Const noteViewMaxLength              =4096; // not including null, tied to tFLD rsrc 10901


// About Box - used by Datebook, Memo, Address, To Do, & others
Const aboutDialog                    =11000;
Const aboutNameLabel                 =11001;
Const aboutVersionLabel              =11002;
Const aboutErrorStr                  =11003;


// Category New Name Dialog (used for new and renamed categories)
Const categoryNewNameDialog          =11100;
Const categoryNewNameField           =11103;
Const categoryNewNameOKButton        =11104;


// Categories Edit Dialog
Const CategoriesEditForm             =10000;
Const CategoriesEditList             =10002;
Const CategoriesEditOKButton         =10003;
Const CategoriesEditNewButton        =10004;
Const CategoriesEditRenameButton     =10005;
Const CategoriesEditDeleteButton     =10006;


// Graffiti Reference Dialog
Const graffitiReferenceDialog        =11200;
Const graffitiReferenceDoneButton    =11202;
Const graffitiReferenceUpButton      =11203;
Const graffitiReferenceDownButton    =11204;
Const graffitiReferenceFirstBitmap   =11205;


// System string resources
Const daysOfWeekStrID                =10000;    // OBSOLETE - use daysOfWeekStdStrListID
Const dayFullNamesStrID              =10001;    // OBSOLETE - use daysOfWeekLongStrListID
Const monthNamesStrID                =10002;    // OBSOLETE - use monthNamesStdStrListID
Const monthFullNamesStrID            =10003;    // OBSOLETE - use monthNamesLongStrListID
Const categoryAllStrID               =10004;
Const categoryEditStrID              =10005;
Const menuCommandStrID               =10006;
Const launcherBatteryStrID           =10007;
Const systemNameStrID                =10008;
Const phoneLookupTitleStrID          =10009;
Const phoneLookupAddStrID            =10010;
Const phoneLookupFormatStrID         =10011;

// System string list resources
//  kwk - put in error string defines here (range)
Const daysOfWeekShortStrListID       =10200;
Const daysOfWeekStdStrListID         =10201;
Const daysOfWeekLongStrListID        =10202;
Const monthNamesShortStrListID       =10203;
Const monthNamesStdStrListID         =10204;
Const monthNamesLongStrListID        =10205;
Const prefDateFormatsStrListID       =10206;
Const prefDOWDateFormatsStrListID    =10207;


//------------------------------------------------------------
// Misc. resource routines
//------------------------------------------------------------

Function ResLoadForm(rscID: UInt16): Pointer;
                  SYS_TRAP(sysTrapResLoadForm);

Function ResLoadMenu(rscID: UInt16): Pointer;
                  SYS_TRAP(sysTrapResLoadMenu);

//Function ResLoadString(rscID: UInt16): String;

{x$ifdef PalmVer35}
Function ResLoadConstant(rscID: UInt16): UInt32;
                  SYS_TRAP(sysTrapResLoadConstant);
{x$endif}

implementation

end.

