unit Traps33;

// *
// * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
// *

interface

Uses Traps31;

// Palm OS 3.2 & 3.3 traps      Palm VII (3.2) and Fall '99 Palm OS Flash Update (3.3)

// System Traps
Type
  SysTrapNumber33=(
    sysTrapHwrNVPrefSet=sysTrapFirstVer33,      // mapped to FlashParmsWrite
    sysTrapHwrNVPrefGet,                        // mapped to FlashParmsRead
    sysTrapFlashInit,
    sysTrapFlashCompress,
    sysTrapFlashErase,
    sysTrapFlashProgram,

    sysTrapAlmTimeChange,
    sysTrapErrAlertCustom,
    sysTrapPrgStartDialog,                      // New version of sysTrapPrgStartDialogV31

    sysTrapSerialDispatch,
    sysTrapHwrBattery,
    sysTrapDmGetDatabaseLockState,

    sysTrapCncGetProfileList,
    sysTrapCncGetProfileInfo,
    sysTrapCncAddProfile,
    sysTrapCncDeleteProfile,

    sysTrapSndPlaySmfResource,

    sysTrapMemPtrDataStorage,                   // Never actually installed until now.

    sysTrapClipboardAppendItem,

    sysTrapWiCmdV32,                            // Code moved to INetLib; trap obsolete
    sysTrapFirstVer35);

implementation

end.
 