unit HSSys2;

interface

//Palm Resources
Type
  alertType     = (informationAlert, confirmationAlert, warningAlert, errorAlert);
  //See Font.pas  palmFont = (stdFont, boldFont, largeFont, symbolFont,
  //                          symbol11Font, symbol7Font, ledFont, largeBoldFont);
  ResUsable     = (notUsable, usable);
  ResAnchor     = (rightAnchor, leftAnchor);
  ResFrame      = (noFrame, Frame);
  ResBold       = (boldFrame, nonBoldFrame);
  ResEditable   = (notEditable, editable);
  ResUnderline  = (notUnderlined, underlined);
  ResSingleLine = (notSingleLine, singleLine);
  ResDynaSize   = (notDynamicSize, dynamicSize);
  ResJust       = (notLeftJustified, leftJustified);
  ResAutoShift  = (notAutoShift, autoShift);
  ResScrollBar  = (notHasScrollbar, hasScrollbar);
  ResNumeric    = (notNumeric, numeric);
  ResModal      = (notModal, modal);
  ResSaveBehind = (noSaveBehind, saveBehind);

  ResFormObjects = (frmFieldObj,frmControlObj,frmListObj,frmTableObj,
                    frmBitmapObj,frmLineObj,frmFrameObj,frmRectangleObj,
                    frmLabelObj,frmTitleObj,frmPopupObj,frmGraffitiStateObj,
                    frmGadgetObj,frmScrollbarObj);

  (******************************************
  Project resources //Page 69, Palm OS SDK
  Talt, Alert
  tFRM, Form
        Menu  (MENU)
        Menubar (MBAR)
  tSTR, String
        Icons
        Bitmaps

  Catalog resources //Page 67, Palm OS SDK
  tBTN, Button
  tCBX, CheckBox
  tFLD, Field (Prompt and editfield)
  tFBM, Form bitmap container
  tGDT, Gadget
  tGSI, Graffiti(r) shift indicator
  tLBL, Label
  tLST, ListBox
  tPUT, PopUp trigger (Dropdown)
  tREP, Repeating button
  tSLT, Selector trigger (ScrollBar)
  tTBL, Table
  (*****************************************)

Const
  ResTAIN = 'tAIN,I,s';     //Id,App Icon Name. ApplicationIcon name (String)
  ResTSTR = 'tSTR,I,S';     //Id, String        (ResTSTR,,1000,'Hello World')
  ResTSTL = 'tSTL,I,S,#,SL';  //Id, Prefix, Strings
  ResTVER = 'tver,I1000,S'; //Id,String         (ResTVER,,,'Version 7.8');
  ResPREF  = 'pref,I1,$001E,$0000,W,$0000,$1000'; //Stacksize (ResPREF,,,5000)
  //Flags=sysAppLaunchFlagNewStack|sysAppLaunchFlagNewGlobals|sysAppLaunchFlagUIApp|sysAppLaunchFlagSubCall
  ResTRAP  = 'TRAP,I1000,W';

  (*ALERT******************************)
  ResTalt  = 'Talt,I,W,W,#,W,S,S,S+'; //alartType, HelpRscId, Default, Title, Message, Button[s]
  //Alert=(ResTalt,,,0,0,0,'Test Dialog','HSPascal was here','Ok','Try it');
  //tAIB?

  (*MENU*******************************)
  ResMBAR  = 'MBAR,I,0,0,0,0,0,0,0,0,0, 0,0,0,0,#, 0,0,*'; //16W
  ResMPUL  = '0,0, LTWH, 0,0, LTWH, S^, #,MITEM'; //17W (Included in Menubar, but must be defined by itself)
  ///MItem = 'I,b,0,S^';            //Id,Shortcut,Title

  (*TABLE******************************)
  ///////DOLATER!!!
  ResTTBL  = 'tTBL,I,LTWHU,0,0,0,#,W+';        //Id ,L,T,W,H,ResEditable,
           //RowCount, Columns [Width]

  (*FORM*******************************)
  ResTFRM  = 'tFRM,I,0,0,0,0,$1200,LTWH,0,0,0,0,0,0,0,0,0,0,0,'+  //Page3
             'Fid,$8000,0,'+                        //^=Frame!!     //Page8 rcformattr Id ,(ResUsable),
             '0,0,0,0,0,w,w,w,#,0,0,£';                           //DefaultButton, HelpRscId, MenuRscId,

  FormTitle = 'o9,0,0,0,0,P,s';                 // 'Hello World'
  FormLabel = 'o8,I,LT,C$8000,_F,P,s';           // id,(4,20),symbol7Font,'Label'
  FormField = 'o0,I,LTWH,C$B648,P,0,0,0,0,0,0,_M,0,0,0,0,_F'; // id,(1,2,3,4),255,aFont

  FormButton =         'o1,I,LTWH,P,C$C900,$00,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tBTN'
  FormPushButton =     'o1,I,LTWH,P,C$C900,$01,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tPBN'
  FormCheckbox =       'o1,I,LTWH,P,C$C900,$02,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tCBX'
  FormPopupTrigger=    'o1,I,LTWH,P,C$C000,$03,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tPUT'
  FormSelectorTrigger= 'o1,I,LTWH,P,C$C900,$04,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tSLT'
  FormRepeatButton=    'o1,I,LTWH,P,C$C900,$05,_F,_G,$00,s'; // id,(1,2,3,4),aFont,aGroup,'tREP'

  FormList =           'o2,I,LTWH,C$4000,P,#,0,0,_F,$00,P,P,SP';
  FormPopupList =      'o10,I,W';       // id,ListID

  //Form Graffiti(r) Shift indicator
  FormGraffitiStateIndicator =  'o11,LT';        
  //Form Gadget Resource
  FormGadget =         'o12,I,C$C000,LTWH,P,P';
  //Form Bitmap Resource
  FormBitmap =         'o4,C$C900,LT,W';      //Attr,LT,id !!

  //ControlStyle=0..5=tBTN,tPBN,tCBX,tPUT,tSLT,tREP

//******************************************************************************
  ResFile  = 'XXXX,N,I,RawFile';
  ResRaw   = 'XXXX,N,I,RawString';
  ResTAIB  = 'tAIB,I,Bitmap';      //Launcher Icon= 32*22(144)
                                   //Launcher small=15*9 (34)
  //(ResTAIB,,,'0101010101010101'+'0101010101010101'+'0101010101010101'+'0101010101010101'+
  //           '0101010101010101'+'0101010101010101'+'0101010101010101'+'0101010101010101'+
  //           '0101010101010101'+'0101010101010101'+'0101010101010101'+'0101010101010101'+
  //           '0101010101010101'+'0101010101010101'+'0101010101010101'+'0101010101010101');
  //54words:  000F 0009 0002 0000 0101 0009 0000 0000 2220 7420 8820 042C 05A0

  //('data,I',,0);  //Remove data!

//--------------------------------------------------------------------
// Define Library Trap Numbers
//--------------------------------------------------------------------
// Palm specific TRAP instruction numbers
Const
  sysDbgBreakpointTrapNum = 0;  // For soft breakpoints
  sysDbgTrapNum = 8;            // For compiled breakpoints
  sysDispatchTrapNum = 15;      // Trap dispatcher

// Library Traps
Type
  SysLibTrapNumber=(
    sysLibTrapName=$A800,    //Warning: HSPC Extension, like C#
    sysLibTrapOpen,
    sysLibTrapClose,
    sysLibTrapSleep,
    sysLibTrapWake,
    sysLibTrapCustom
    );

// System Traps
// procedure yy; systrap($8001); => SysTrap $8001
// procedure yy; systrap($8001,123); => "MOVEQ #123,D2 & SysTrap $8001"
Type
  SysTrapNumber=(
    sysTrapMemInit =$A000,       //Warning: HSPC Extension, like C#
    sysTrapMemInitHeapTable,
    sysTrapMemStoreInit,
    sysTrapMemCardFormat,
    sysTrapMemCardInfo,
    sysTrapMemStoreInfo,
    sysTrapMemStoreSetInfo,
    sysTrapMemNumHeaps,
    sysTrapMemNumRAMHeaps,
    sysTrapMemHeapID,
    sysTrapMemHeapPtr,
    sysTrapMemHeapFreeBytes,
    sysTrapMemHeapSize,
    sysTrapMemHeapFlags,
    sysTrapMemHeapCompact,
    sysTrapMemHeapInit,
    sysTrapMemHeapFreeByOwnerID,
    sysTrapMemChunkNew,
    sysTrapMemChunkFree,
    sysTrapMemPtrNew,
    sysTrapMemPtrRecoverHandle,
    sysTrapMemPtrFlags,
    sysTrapMemPtrSize,
    sysTrapMemPtrOwner,
    sysTrapMemPtrHeapID,
    sysTrapMemPtrCardNo,
    sysTrapMemPtrToLocalID,
    sysTrapMemPtrSetOwner,
    sysTrapMemPtrResize,
    sysTrapMemPtrResetLock,
    sysTrapMemHandleNew,
    sysTrapMemHandleLockCount,
    sysTrapMemHandleToLocalID,
    sysTrapMemHandleLock,
    sysTrapMemHandleUnlock,
    sysTrapMemLocalIDToGlobal,
    sysTrapMemLocalIDKind,
    sysTrapMemLocalIDToPtr,
    sysTrapMemMove,
    sysTrapMemSet,
    sysTrapMemStoreSearch,
    sysTrapReserved6,                           // was sysTrapMemPtrDataStorage
    sysTrapMemKernelInit,
    sysTrapMemHandleFree,
    sysTrapMemHandleFlags,
    sysTrapMemHandleSize,
    sysTrapMemHandleOwner,
    sysTrapMemHandleHeapID,
    sysTrapMemHandleDataStorage,
    sysTrapMemHandleCardNo,
    sysTrapMemHandleSetOwner,
    sysTrapMemHandleResize,
    sysTrapMemHandleResetLock,
    sysTrapMemPtrUnlock,
    sysTrapMemLocalIDToLockedPtr,
    sysTrapMemSetDebugMode,
    sysTrapMemHeapScramble,
    sysTrapMemHeapCheck,
    sysTrapMemNumCards,
    sysTrapMemDebugMode,
    sysTrapMemSemaphoreReserve,
    sysTrapMemSemaphoreRelease,
    sysTrapMemHeapDynamic,
    sysTrapMemNVParams,

    sysTrapDmInit,
    sysTrapDmCreateDatabase,
    sysTrapDmDeleteDatabase,
    sysTrapDmNumDatabases,
    sysTrapDmGetDatabase,
    sysTrapDmFindDatabase,
    sysTrapDmDatabaseInfo,
    sysTrapDmSetDatabaseInfo,
    sysTrapDmDatabaseSize,
    sysTrapDmOpenDatabase,
    sysTrapDmCloseDatabase,
    sysTrapDmNextOpenDatabase,
    sysTrapDmOpenDatabaseInfo,
    sysTrapDmResetRecordStates,
    sysTrapDmGetLastErr,
    sysTrapDmNumRecords,
    sysTrapDmRecordInfo,
    sysTrapDmSetRecordInfo,
    sysTrapDmAttachRecord,
    sysTrapDmDetachRecord,
    sysTrapDmMoveRecord,
    sysTrapDmNewRecord,
    sysTrapDmRemoveRecord,
    sysTrapDmDeleteRecord,
    sysTrapDmArchiveRecord,
    sysTrapDmNewHandle,
    sysTrapDmRemoveSecretRecords,
    sysTrapDmQueryRecord,
    sysTrapDmGetRecord,
    sysTrapDmResizeRecord,
    sysTrapDmReleaseRecord,
    sysTrapDmGetResource,
    sysTrapDmGet1Resource,
    sysTrapDmReleaseResource,
    sysTrapDmResizeResource,
    sysTrapDmNextOpenResDatabase,
    sysTrapDmFindResourceType,
    sysTrapDmFindResource,
    sysTrapDmSearchResource,
    sysTrapDmNumResources,
    sysTrapDmResourceInfo,
    sysTrapDmSetResourceInfo,
    sysTrapDmAttachResource,
    sysTrapDmDetachResource,
    sysTrapDmNewResource,
    sysTrapDmRemoveResource,
    sysTrapDmGetResourceIndex,
    sysTrapDmQuickSort,
    sysTrapDmQueryNextInCategory,
    sysTrapDmNumRecordsInCategory,
    sysTrapDmPositionInCategory,
    sysTrapDmSeekRecordInCategory,
    sysTrapDmMoveCategory,
    sysTrapDmOpenDatabaseByTypeCreator,
    sysTrapDmWrite,
    sysTrapDmStrCopy,
    sysTrapDmGetNextDatabaseByTypeCreator,
    sysTrapDmWriteCheck,
    sysTrapDmMoveOpenDBContext,
    sysTrapDmFindRecordByID,
    sysTrapDmGetAppInfoID,
    sysTrapDmFindSortPositionV10,
    sysTrapDmSet,
    sysTrapDmCreateDatabaseFromImage,

    sysTrapDbgSrcMessage,
    sysTrapDbgMessage,
    sysTrapDbgGetMessage,
    sysTrapDbgCommSettings,
        
    sysTrapErrDisplayFileLineMsg,
    sysTrapErrSetJump,
    sysTrapErrLongJump,
    sysTrapErrThrow,
    sysTrapErrExceptionList,
        
    sysTrapSysBroadcastActionCode,
    sysTrapSysUnimplemented,
    sysTrapSysColdBoot,
    sysTrapSysReset,
    sysTrapSysDoze,
    sysTrapSysAppLaunch,
    sysTrapSysAppStartup,
    sysTrapSysAppExit,
    sysTrapSysSetA5,
    sysTrapSysSetTrapAddress,
    sysTrapSysGetTrapAddress,
    sysTrapSysTranslateKernelErr,
    sysTrapSysSemaphoreCreate,
    sysTrapSysSemaphoreDelete,
    sysTrapSysSemaphoreWait,
    sysTrapSysSemaphoreSignal,
    sysTrapSysTimerCreate,
    sysTrapSysTimerWrite,
    sysTrapSysTaskCreate,
    sysTrapSysTaskDelete,
    sysTrapSysTaskTrigger,
    sysTrapSysTaskID,
    sysTrapSysTaskUserInfoPtr,
    sysTrapSysTaskDelay,
    sysTrapSysTaskSetTermProc,
    sysTrapSysUILaunch,
    sysTrapSysNewOwnerID,
    sysTrapSysSemaphoreSet,
    sysTrapSysDisableInts,
    sysTrapSysRestoreStatus,
    sysTrapSysUIAppSwitch,
    sysTrapSysCurAppInfoPV20,
    sysTrapSysHandleEvent,
    sysTrapSysInit,
    sysTrapSysQSort,
    sysTrapSysCurAppDatabase,
    sysTrapSysFatalAlert,
    sysTrapSysResSemaphoreCreate,
    sysTrapSysResSemaphoreDelete,
    sysTrapSysResSemaphoreReserve,
    sysTrapSysResSemaphoreRelease,
    sysTrapSysSleep,
    sysTrapSysKeyboardDialogV10,
    sysTrapSysAppLauncherDialog,
    sysTrapSysSetPerformance,
    sysTrapSysBatteryInfoV20,
    sysTrapSysLibInstall,
    sysTrapSysLibRemove,
    sysTrapSysLibTblEntry,
    sysTrapSysLibFind,
    sysTrapSysBatteryDialog,
    sysTrapSysCopyStringResource,
    sysTrapSysKernelInfo,
    sysTrapSysLaunchConsole,
    sysTrapSysTimerDelete,
    sysTrapSysSetAutoOffTime,
    sysTrapSysFormPointerArrayToStrings,
    sysTrapSysRandom,
    sysTrapSysTaskSwitching,
    sysTrapSysTimerRead,

    sysTrapStrCopy,
    sysTrapStrCat,
    sysTrapStrLen,
    sysTrapStrCompare,
    sysTrapStrIToA,
    sysTrapStrCaselessCompare,
    sysTrapStrIToH,
    sysTrapStrChr,
    sysTrapStrStr,
    sysTrapStrAToI,
    sysTrapStrToLower,

    sysTrapSerReceiveISP,
        
    sysTrapSlkOpen,
    sysTrapSlkClose,
    sysTrapSlkOpenSocket,
    sysTrapSlkCloseSocket,
    sysTrapSlkSocketRefNum,
    sysTrapSlkSocketSetTimeout,
    sysTrapSlkFlushSocket,
    sysTrapSlkSetSocketListener,
    sysTrapSlkSendPacket,
    sysTrapSlkReceivePacket,
    sysTrapSlkSysPktDefaultResponse,
    sysTrapSlkProcessRPC,

    sysTrapConPutS,
    sysTrapConGetS,

    sysTrapFplInit,             // Obsolete, here for compatibilty only!
    sysTrapFplFree,             // Obsolete, here for compatibilty only!
    sysTrapFplFToA,             // Obsolete, here for compatibilty only!
    sysTrapFplAToF,             // Obsolete, here for compatibilty only!
    sysTrapFplBase10Info,       // Obsolete, here for compatibilty only!
    sysTrapFplLongToFloat,      // Obsolete, here for compatibilty only!
    sysTrapFplFloatToLong,      // Obsolete, here for compatibilty only!
    sysTrapFplFloatToULong,     // Obsolete, here for compatibilty only!
    sysTrapFplMul,              // Obsolete, here for compatibilty only!
    sysTrapFplAdd,              // Obsolete, here for compatibilty only!
    sysTrapFplSub,              // Obsolete, here for compatibilty only!
    sysTrapFplDiv,              // Obsolete, here for compatibilty only!

    sysTrapWinScreenInit,
    sysTrapScrCopyRectangle,
    sysTrapScrDrawChars,
    sysTrapScrLineRoutine,
    sysTrapScrRectangleRoutine,
    sysTrapScrScreenInfo,
    sysTrapScrDrawNotify,
    sysTrapScrSendUpdateArea,
    sysTrapScrCompressScanLine,
    sysTrapScrDeCompressScanLine,

    sysTrapTimGetSeconds,
    sysTrapTimSetSeconds,
    sysTrapTimGetTicks,
    sysTrapTimInit,
    sysTrapTimSetAlarm,
    sysTrapTimGetAlarm,
    sysTrapTimHandleInterrupt,
    sysTrapTimSecondsToDateTime,
    sysTrapTimDateTimeToSeconds,
    sysTrapTimAdjust,
    sysTrapTimSleep,
    sysTrapTimWake,

    sysTrapCategoryCreateListV10,
    sysTrapCategoryFreeListV10,
    sysTrapCategoryFind,
    sysTrapCategoryGetName,
    sysTrapCategoryEditV10,
    sysTrapCategorySelectV10,
    sysTrapCategoryGetNext,
    sysTrapCategorySetTriggerLabel,
    sysTrapCategoryTruncateName,
        
    sysTrapClipboardAddItem,
    sysTrapClipboardCheckIfItemExist,
    sysTrapClipboardGetItem,

    sysTrapCtlDrawControl,
    sysTrapCtlEraseControl,
    sysTrapCtlHideControl,
    sysTrapCtlShowControl,
    sysTrapCtlGetValue,
    sysTrapCtlSetValue,
    sysTrapCtlGetLabel,
    sysTrapCtlSetLabel,
    sysTrapCtlHandleEvent,
    sysTrapCtlHitControl,
    sysTrapCtlSetEnabled,
    sysTrapCtlSetUsable,
    sysTrapCtlEnabled,

    sysTrapEvtInitialize,
    sysTrapEvtAddEventToQueue,
    sysTrapEvtCopyEvent,
    sysTrapEvtGetEvent,
    sysTrapEvtGetPen,
    sysTrapEvtSysInit,
    sysTrapEvtGetSysEvent,
    sysTrapEvtProcessSoftKeyStroke,
    sysTrapEvtGetPenBtnList,
    sysTrapEvtSetPenQueuePtr,
    sysTrapEvtPenQueueSize,
    sysTrapEvtFlushPenQueue,
    sysTrapEvtEnqueuePenPoint,
    sysTrapEvtDequeuePenStrokeInfo,
    sysTrapEvtDequeuePenPoint,
    sysTrapEvtFlushNextPenStroke,
    sysTrapEvtSetKeyQueuePtr,
    sysTrapEvtKeyQueueSize,
    sysTrapEvtFlushKeyQueue,
    sysTrapEvtEnqueueKey,
    sysTrapEvtDequeueKeyEvent,
    sysTrapEvtWakeup,
    sysTrapEvtResetAutoOffTimer,
    sysTrapEvtKeyQueueEmpty,
    sysTrapEvtEnableGraffiti,

    sysTrapFldCopy,
    sysTrapFldCut,
    sysTrapFldDrawField,
    sysTrapFldEraseField,
    sysTrapFldFreeMemory,
    sysTrapFldGetBounds,
    sysTrapFldGetTextPtr,
    sysTrapFldGetSelection,
    sysTrapFldHandleEvent,
    sysTrapFldPaste,
    sysTrapFldRecalculateField,
    sysTrapFldSetBounds,
    sysTrapFldSetText,
    sysTrapFldGetFont,
    sysTrapFldSetFont,
    sysTrapFldSetSelection,
    sysTrapFldGrabFocus,
    sysTrapFldReleaseFocus,
    sysTrapFldGetInsPtPosition,
    sysTrapFldSetInsPtPosition,
    sysTrapFldSetScrollPosition,
    sysTrapFldGetScrollPosition,
    sysTrapFldGetTextHeight,
    sysTrapFldGetTextAllocatedSize,
    sysTrapFldGetTextLength,
    sysTrapFldScrollField,
    sysTrapFldScrollable,
    sysTrapFldGetVisibleLines,
    sysTrapFldGetAttributes,
    sysTrapFldSetAttributes,
    sysTrapFldSendChangeNotification,
    sysTrapFldCalcFieldHeight,
    sysTrapFldGetTextHandle,
    sysTrapFldCompactText,
    sysTrapFldDirty,
    sysTrapFldWordWrap,
    sysTrapFldSetTextAllocatedSize,
    sysTrapFldSetTextHandle,
    sysTrapFldSetTextPtr,
    sysTrapFldGetMaxChars,
    sysTrapFldSetMaxChars,
    sysTrapFldSetUsable,
    sysTrapFldInsert,
    sysTrapFldDelete,
    sysTrapFldUndo,
    sysTrapFldSetDirty,
    sysTrapFldSendHeightChangeNotification,
    sysTrapFldMakeFullyVisible,

    sysTrapFntGetFont,
    sysTrapFntSetFont,
    sysTrapFntGetFontPtr,
    sysTrapFntBaseLine,
    sysTrapFntCharHeight,
    sysTrapFntLineHeight,
    sysTrapFntAverageCharWidth,
    sysTrapFntCharWidth,
    sysTrapFntCharsWidth,
    sysTrapFntDescenderHeight,
    sysTrapFntCharsInWidth,
    sysTrapFntLineWidth,

    sysTrapFrmInitForm,
    sysTrapFrmDeleteForm,
    sysTrapFrmDrawForm,
    sysTrapFrmEraseForm,
    sysTrapFrmGetActiveForm,
    sysTrapFrmSetActiveForm,
    sysTrapFrmGetActiveFormID,
    sysTrapFrmGetUserModifiedState,
    sysTrapFrmSetNotUserModified,
    sysTrapFrmGetFocus,
    sysTrapFrmSetFocus,
    sysTrapFrmHandleEvent,
    sysTrapFrmGetFormBounds,
    sysTrapFrmGetWindowHandle,
    sysTrapFrmGetFormId,
    sysTrapFrmGetFormPtr,
    sysTrapFrmGetNumberOfObjects,
    sysTrapFrmGetObjectIndex,
    sysTrapFrmGetObjectId,
    sysTrapFrmGetObjectType,
    sysTrapFrmGetObjectPtr,
    sysTrapFrmHideObject,
    sysTrapFrmShowObject,
    sysTrapFrmGetObjectPosition,
    sysTrapFrmSetObjectPosition,
    sysTrapFrmGetControlValue,
    sysTrapFrmSetControlValue,
    sysTrapFrmGetControlGroupSelection,
    sysTrapFrmSetControlGroupSelection,
    sysTrapFrmCopyLabel,
    sysTrapFrmSetLabel,
    sysTrapFrmGetLabel,
    sysTrapFrmSetCategoryLabel,
    sysTrapFrmGetTitle,
    sysTrapFrmSetTitle,
    sysTrapFrmAlert,
    sysTrapFrmDoDialog,
    sysTrapFrmCustomAlert,
    sysTrapFrmHelp,
    sysTrapFrmUpdateScrollers,
    sysTrapFrmGetFirstForm,
    sysTrapFrmVisible,
    sysTrapFrmGetObjectBounds,
    sysTrapFrmCopyTitle,
    sysTrapFrmGotoForm,
    sysTrapFrmPopupForm,
    sysTrapFrmUpdateForm,
    sysTrapFrmReturnToForm,
    sysTrapFrmSetEventHandler,
    sysTrapFrmDispatchEvent,
    sysTrapFrmCloseAllForms,
    sysTrapFrmSaveAllForms,
    sysTrapFrmGetGadgetData,
    sysTrapFrmSetGadgetData,
    sysTrapFrmSetCategoryTrigger,

    sysTrapUIInitialize,
    sysTrapUIReset,

    sysTrapInsPtInitialize,
    sysTrapInsPtSetLocation,
    sysTrapInsPtGetLocation,
    sysTrapInsPtEnable,
    sysTrapInsPtEnabled,
    sysTrapInsPtSetHeight,
    sysTrapInsPtGetHeight,
    sysTrapInsPtCheckBlink,

    sysTrapLstSetDrawFunction,
    sysTrapLstDrawList,
    sysTrapLstEraseList,
    sysTrapLstGetSelection,
    sysTrapLstGetSelectionText,
    sysTrapLstHandleEvent,
    sysTrapLstSetHeight,
    sysTrapLstSetSelection,
    sysTrapLstSetListChoices,
    sysTrapLstMakeItemVisible,
    sysTrapLstGetNumberOfItems,
    sysTrapLstPopupList,
    sysTrapLstSetPosition,
        
    sysTrapMenuInit,
    sysTrapMenuDispose,
    sysTrapMenuHandleEvent,
    sysTrapMenuDrawMenu,
    sysTrapMenuEraseStatus,
    sysTrapMenuGetActiveMenu,
    sysTrapMenuSetActiveMenu,

    sysTrapRctSetRectangle,
    sysTrapRctCopyRectangle,
    sysTrapRctInsetRectangle,
    sysTrapRctOffsetRectangle,
    sysTrapRctPtInRectangle,
    sysTrapRctGetIntersection,

    sysTrapTblDrawTable,
    sysTrapTblEraseTable,
    sysTrapTblHandleEvent,
    sysTrapTblGetItemBounds,
    sysTrapTblSelectItem,
    sysTrapTblGetItemInt,
    sysTrapTblSetItemInt,
    sysTrapTblSetItemStyle,
    sysTrapTblUnhighlightSelection,
    sysTrapTblSetRowUsable,
    sysTrapTblGetNumberOfRows,
    sysTrapTblSetCustomDrawProcedure,
    sysTrapTblSetRowSelectable,
    sysTrapTblRowSelectable,
    sysTrapTblSetLoadDataProcedure,
    sysTrapTblSetSaveDataProcedure,
    sysTrapTblGetBounds,
    sysTrapTblSetRowHeight,
    sysTrapTblGetColumnWidth,
    sysTrapTblGetRowID,
    sysTrapTblSetRowID,
    sysTrapTblMarkRowInvalid,
    sysTrapTblMarkTableInvalid,
    sysTrapTblGetSelection,
    sysTrapTblInsertRow,
    sysTrapTblRemoveRow,
    sysTrapTblRowInvalid,
    sysTrapTblRedrawTable,
    sysTrapTblRowUsable,
    sysTrapTblReleaseFocus,
    sysTrapTblEditing,
    sysTrapTblGetCurrentField,
    sysTrapTblSetColumnUsable,
    sysTrapTblGetRowHeight,
    sysTrapTblSetColumnWidth,
    sysTrapTblGrabFocus,
    sysTrapTblSetItemPtr,
    sysTrapTblFindRowID,
    sysTrapTblGetLastUsableRow,
    sysTrapTblGetColumnSpacing,
    sysTrapTblFindRowData,
    sysTrapTblGetRowData,
    sysTrapTblSetRowData,
    sysTrapTblSetColumnSpacing,

    sysTrapWinCreateWindow,
    sysTrapWinCreateOffscreenWindow,
    sysTrapWinDeleteWindow,
    sysTrapWinInitializeWindow,
    sysTrapWinAddWindow,
    sysTrapWinRemoveWindow,
    sysTrapWinSetActiveWindow,
    sysTrapWinSetDrawWindow,
    sysTrapWinGetDrawWindow,
    sysTrapWinGetActiveWindow,
    sysTrapWinGetDisplayWindow,
    sysTrapWinGetFirstWindow,
    sysTrapWinEnableWindow,
    sysTrapWinDisableWindow,
    sysTrapWinGetWindowFrameRect,
    sysTrapWinDrawWindowFrame,
    sysTrapWinEraseWindow,
    sysTrapWinSaveBits,
    sysTrapWinRestoreBits,
    sysTrapWinCopyRectangle,
    sysTrapWinScrollRectangle,
    sysTrapWinGetDisplayExtent,
    sysTrapWinGetWindowExtent,
    sysTrapWinDisplayToWindowPt,
    sysTrapWinWindowToDisplayPt,
    sysTrapWinGetClip,
    sysTrapWinSetClip,
    sysTrapWinResetClip,
    sysTrapWinClipRectangle,
    sysTrapWinDrawLine,
    sysTrapWinDrawGrayLine,
    sysTrapWinEraseLine,
    sysTrapWinInvertLine,
    sysTrapWinFillLine,
    sysTrapWinDrawRectangle,
    sysTrapWinEraseRectangle,
    sysTrapWinInvertRectangle,
    sysTrapWinDrawRectangleFrame,
    sysTrapWinDrawGrayRectangleFrame,
    sysTrapWinEraseRectangleFrame,
    sysTrapWinInvertRectangleFrame,
    sysTrapWinGetFramesRectangle,
    sysTrapWinDrawChars,
    sysTrapWinEraseChars,
    sysTrapWinInvertChars,
    sysTrapWinGetPattern,
    sysTrapWinSetPattern,
    sysTrapWinSetUnderlineMode,
    sysTrapWinDrawBitmap,
    sysTrapWinModal,
    sysTrapWinGetWindowBounds,
    sysTrapWinFillRectangle,
    sysTrapWinDrawInvertedChars,

    sysTrapPrefOpenPreferenceDBV10,
    sysTrapPrefGetPreferences,
    sysTrapPrefSetPreferences,
    sysTrapPrefGetAppPreferencesV10,
    sysTrapPrefSetAppPreferencesV10,

    sysTrapSndInit,
    sysTrapSndSetDefaultVolume,
    sysTrapSndGetDefaultVolume,
    sysTrapSndDoCmd,
    sysTrapSndPlaySystemSound,

    sysTrapAlmInit,
    sysTrapAlmCancelAll,
    sysTrapAlmAlarmCallback,
    sysTrapAlmSetAlarm,
    sysTrapAlmGetAlarm,
    sysTrapAlmDisplayAlarm,
    sysTrapAlmEnableNotification,

    sysTrapHwrGetRAMMapping,
    sysTrapHwrMemWritable,
    sysTrapHwrMemReadable,
    sysTrapHwrDoze,
    sysTrapHwrSleep,
    sysTrapHwrWake,
    sysTrapHwrSetSystemClock,
    sysTrapHwrSetCPUDutyCycle,
    sysTrapHwrDisplayInit,                              // Before OS 3.5, this trap a.k.a. sysTrapHwrLCDInit
    sysTrapHwrDisplaySleep,                     // Before OS 3.5, this trap a.k.a. sysTrapHwrLCDSleep,
    sysTrapHwrTimerInit,
    sysTrapHwrCursorV33,                                        // This trap obsoleted for OS 3.5 and later
    sysTrapHwrBatteryLevel,
    sysTrapHwrDelay,
    sysTrapHwrEnableDataWrites,
    sysTrapHwrDisableDataWrites,
    sysTrapHwrLCDBaseAddrV33,                   // This trap obsoleted for OS 3.5 and later
    sysTrapHwrDisplayDrawBootScreen, // Before OS 3.5, this trap a.k.a. sysTrapHwrLCDDrawBitmap
    sysTrapHwrTimerSleep,
    sysTrapHwrTimerWake,
    sysTrapHwrDisplayWake,                              // Before OS 3.5, this trap a.k.a. sysTrapHwrLCDWake
    sysTrapHwrIRQ1Handler,
    sysTrapHwrIRQ2Handler,
    sysTrapHwrIRQ3Handler,
    sysTrapHwrIRQ4Handler,
    sysTrapHwrIRQ5Handler,
    sysTrapHwrIRQ6Handler,
    sysTrapHwrDockSignals,
    sysTrapHwrPluggedIn,

    sysTrapCrc16CalcBlock,

    sysTrapSelectDayV10,
    sysTrapSelectTimeV33,
        
    sysTrapDayDrawDaySelector,
    sysTrapDayHandleEvent,
    sysTrapDayDrawDays,
    sysTrapDayOfWeek,
    sysTrapDaysInMonth,
    sysTrapDayOfMonth,
        
    sysTrapDateDaysToDate,
    sysTrapDateToDays,
    sysTrapDateAdjust,
    sysTrapDateSecondsToDate,
    sysTrapDateToAscii,
    sysTrapDateToDOWDMFormat,
    sysTrapTimeToAscii,

    sysTrapFind,
    sysTrapFindStrInStr,
    sysTrapFindSaveMatch,
    sysTrapFindGetLineBounds,
    sysTrapFindDrawHeader,

    sysTrapPenOpen,
    sysTrapPenClose,
    sysTrapPenGetRawPen,
    sysTrapPenCalibrate,
    sysTrapPenRawToScreen,
    sysTrapPenScreenToRaw,
    sysTrapPenResetCalibration,
    sysTrapPenSleep,
    sysTrapPenWake,

    sysTrapResLoadForm,
    sysTrapResLoadMenu,
        
    sysTrapFtrInit,
    sysTrapFtrUnregister,
    sysTrapFtrGet,
    sysTrapFtrSet,
    sysTrapFtrGetByIndex,

    sysTrapGrfInit,
    sysTrapGrfFree,
    sysTrapGrfGetState,
    sysTrapGrfSetState,
    sysTrapGrfFlushPoints,
    sysTrapGrfAddPoint,
    sysTrapGrfInitState,
    sysTrapGrfCleanState,
    sysTrapGrfMatch,
    sysTrapGrfGetMacro,
    sysTrapGrfFilterPoints,
    sysTrapGrfGetNumPoints,
    sysTrapGrfGetPoint,
    sysTrapGrfFindBranch,
    sysTrapGrfMatchGlyph,
    sysTrapGrfGetGlyphMapping,
    sysTrapGrfGetMacroName,
    sysTrapGrfDeleteMacro,
    sysTrapGrfAddMacro,
    sysTrapGrfGetAndExpandMacro,
    sysTrapGrfProcessStroke,
    sysTrapGrfFieldChange,

    sysTrapGetCharSortValue,
    sysTrapGetCharAttr,
    sysTrapGetCharCaselessValue,

    sysTrapPwdExists,
    sysTrapPwdVerify,
    sysTrapPwdSet,
    sysTrapPwdRemove,

    sysTrapGsiInitialize,
    sysTrapGsiSetLocation,
    sysTrapGsiEnable,
    sysTrapGsiEnabled,
    sysTrapGsiSetShiftState,

    sysTrapKeyInit,
    sysTrapKeyHandleInterrupt,
    sysTrapKeyCurrentState,
    sysTrapKeyResetDoubleTap,
    sysTrapKeyRates,
    sysTrapKeySleep,
    sysTrapKeyWake,

    sysTrapDlkControl,                  // was sysTrapCmBroadcast

    sysTrapDlkStartServer,
    sysTrapDlkGetSyncInfo,
    sysTrapDlkSetLogEntry,

    sysTrapIntlDispatch,                // REUSED IN v3.1 (was sysTrapPsrInit in 1.0, removed in 2.0)
    sysTrapSysLibLoad,                  // REUSED IN v2.0 (was sysTrapPsrClose)
    sysTrapSndPlaySmf,                  // REUSED IN v3.0 (was sysTrapPsrGetCommand in 1.0, removed in 2.0)
    sysTrapSndCreateMidiList,           // REUSED IN v3.0 (was sysTrapPsrSendReply in 1.0, removed in 2.0)

    sysTrapAbtShowAbout,

    sysTrapMdmDial,
    sysTrapMdmHangUp,

    sysTrapDmSearchRecord,

    sysTrapSysInsertionSort,
    sysTrapDmInsertionSort,

    sysTrapLstSetTopItem,

    // Palm OS 2.X traps                Palm Pilot and 2.0 Upgrade Card
    sysTrapSclSetScrollBar,
    sysTrapSclDrawScrollBar,
    sysTrapSclHandleEvent,

    sysTrapSysMailboxCreate,
    sysTrapSysMailboxDelete,
    sysTrapSysMailboxFlush,
    sysTrapSysMailboxSend,
    sysTrapSysMailboxWait,
        
    sysTrapSysTaskWait,
    sysTrapSysTaskWake,
    sysTrapSysTaskWaitClr,
    sysTrapSysTaskSuspend,
    sysTrapSysTaskResume,
        
    sysTrapCategoryCreateList,
    sysTrapCategoryFreeList,
    sysTrapCategoryEditV20,
    sysTrapCategorySelect,
        
    sysTrapDmDeleteCategory,
        
    sysTrapSysEvGroupCreate,
    sysTrapSysEvGroupSignal,
    sysTrapSysEvGroupRead,
    sysTrapSysEvGroupWait,
        
    sysTrapEvtEventAvail,
    sysTrapEvtSysEventAvail,
    sysTrapStrNCopy,
        
    sysTrapKeySetMask,
        
    sysTrapSelectDay,
        
    sysTrapPrefGetPreference,
    sysTrapPrefSetPreference,
    sysTrapPrefGetAppPreferences,
    sysTrapPrefSetAppPreferences,
        
    sysTrapFrmPointInTitle,
        
    sysTrapStrNCat,

    sysTrapMemCmp,

    sysTrapTblSetColumnEditIndicator,

    sysTrapFntWordWrap,
        
    sysTrapFldGetScrollValues,
        
    sysTrapSysCreateDataBaseList,
    sysTrapSysCreatePanelList,

    sysTrapDlkDispatchRequest,
        
    sysTrapStrPrintF,
    sysTrapStrVPrintF,
        
    sysTrapPrefOpenPreferenceDB,

    sysTrapSysGraffitiReferenceDialog,
        
    sysTrapSysKeyboardDialog,
        
    sysTrapFntWordWrapReverseNLines,
    sysTrapFntGetScrollValues,
        
    sysTrapTblSetRowStaticHeight,
    sysTrapTblHasScrollBar,
        
    sysTrapSclGetScrollBar,
        
    sysTrapFldGetNumberOfBlankLines,

    sysTrapSysTicksPerSecond,
    sysTrapHwrBacklightV33,                     // This trap obsoleted for OS 3.5 and later
    sysTrapDmDatabaseProtect,

    sysTrapTblSetBounds,
        
    sysTrapStrNCompare,
    sysTrapStrNCaselessCompare, 
        
    sysTrapPhoneNumberLookup,
        
    sysTrapFrmSetMenu,
        
    sysTrapEncDigestMD5,
        
    sysTrapDmFindSortPosition,
        
    sysTrapSysBinarySearch,
    sysTrapSysErrString,
    sysTrapSysStringByIndex,
        
    sysTrapEvtAddUniqueEventToQueue,
        
    sysTrapStrLocalizeNumber,
    sysTrapStrDelocalizeNumber,
    sysTrapLocGetNumberSeparators,
        
    sysTrapMenuSetActiveMenuRscID,

    sysTrapLstScrollList,
        
    sysTrapCategoryInitialize,
        
    sysTrapEncDigestMD4,
    sysTrapEncDES,
        
    sysTrapLstGetVisibleItems,
        
    sysTrapWinSetWindowBounds,

    sysTrapCategorySetName,
        
    sysTrapFldSetInsertionPoint,
        
    sysTrapFrmSetObjectBounds,

    sysTrapWinSetColors,

    sysTrapFlpDispatch,
    sysTrapFlpEmDispatch,
    sysTrapFirstVer30);

Const
  sysTrapScrInit = sysTrapWinScreenInit;
  sysTrapMemPtrFree = sysTrapMemChunkFree;
  sysTrapMemPtrDataStorage = sysTrapReserved6;

implementation

end.

