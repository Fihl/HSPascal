unit Traps30;

// *
// * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
// *

interface

// Palm OS 3.0 traps            Palm III and 3.0 Upgrade Card

// System Traps
Type
  SysTrapNumber30=(
    sysTrapExgInit= sysTrapFirstVer30,
    sysTrapExgConnect,
    sysTrapExgPut,
    sysTrapExgGet,
    sysTrapExgAccept,
    sysTrapExgDisconnect,
    sysTrapExgSend,
    sysTrapExgReceive,
    sysTrapExgRegisterData,
    sysTrapExgNotifyReceive,
    sysTrapExgControl,
    
    sysTrapPrgStartDialogV31,           // Updated in v3.2
    sysTrapPrgStopDialog,
    sysTrapPrgUpdateDialog,
    sysTrapPrgHandleEvent,
    
    sysTrapImcReadFieldNoSemicolon,
    sysTrapImcReadFieldQuotablePrintable,
    sysTrapImcReadPropertyParameter,
    sysTrapImcSkipAllPropertyParameters,
    sysTrapImcReadWhiteSpace,
    sysTrapImcWriteQuotedPrintable,
    sysTrapImcWriteNoSemicolon,
    sysTrapImcStringIsAscii,
    
    sysTrapTblGetItemFont,
    sysTrapTblSetItemFont,

    sysTrapFontSelect,
    sysTrapFntDefineFont,
    
    sysTrapCategoryEdit,
    
    sysTrapSysGetOSVersionString,
    sysTrapSysBatteryInfo,
    sysTrapSysUIBusy,
    
    sysTrapWinValidateHandle,
    sysTrapFrmValidatePtr,
    sysTrapCtlValidatePointer,
    sysTrapWinMoveWindowAddr,
    sysTrapFrmAddSpaceForObject,
    sysTrapFrmNewForm,
    sysTrapCtlNewControl,
    sysTrapFldNewField,
    sysTrapLstNewList,
    sysTrapFrmNewLabel,
    sysTrapFrmNewBitmap,
    sysTrapFrmNewGadget,
    
    sysTrapFileOpen,
    sysTrapFileClose,
    sysTrapFileDelete,
    sysTrapFileReadLow,
    sysTrapFileWrite,
    sysTrapFileSeek,
    sysTrapFileTell,
    sysTrapFileTruncate,
    sysTrapFileControl,

    sysTrapFrmActiveState,
    
    sysTrapSysGetAppInfo,
    sysTrapSysGetStackInfo,

    sysTrapWinScreenMode,               // was sysTrapScrDisplayMode
    sysTrapHwrLCDGetDepthV33,           // This trap obsoleted for OS 3.5 and later
    sysTrapHwrGetROMToken,
    
    sysTrapDbgControl,
    
    sysTrapExgDBRead,
    sysTrapExgDBWrite,

    sysTrapHostControl,                 // Renamed from sysTrapSysGremlins, functionality generalized
    sysTrapFrmRemoveObject,

    sysTrapSysReserved1,                // "Reserved" trap in Palm OS 3.0 and later trap table
    sysTrapSysReserved2,                // "Reserved" trap in Palm OS 3.0 and later trap table
    sysTrapSysReserved3,                // "Reserved" trap in Palm OS 3.0 and later trap table

    sysTrapOEMDispatch,
    sysTrapFirstVer31);

implementation

end.
