unit Traps31;

// *
// * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
// *

interface

Uses Traps30;

// Palm OS 3.1 traps            Palm IIIx and Palm V

// System Traps
Type
  SysTrapNumber31=(
    sysTrapHwrLCDContrastV33= sysTrapFirstVer31,       // This trap obsoleted for OS 3.5 and later
    sysTrapSysLCDContrast,
    sysTrapUIContrastAdjust,            // Renamed from sysTrapContrastAdjust
    sysTrapHwrDockStatus,

    sysTrapFntWidthToOffset,
    sysTrapSelectOneTime,
    sysTrapWinDrawChar,
    sysTrapWinDrawTruncChars,

    sysTrapSysNotifyInit,               // Notification Manager traps
    sysTrapSysNotifyRegister,
    sysTrapSysNotifyUnregister,
    sysTrapSysNotifyBroadcast,
    sysTrapSysNotifyBroadcastDeferred,
    sysTrapSysNotifyDatabaseAdded,
    sysTrapSysNotifyDatabaseRemoved,

    sysTrapSysWantEvent,

    sysTrapFtrPtrNew,
    sysTrapFtrPtrFree,
    sysTrapFtrPtrResize,

    sysTrapSysReserved5,                // "Reserved" trap in Palm OS 3.1 and later trap table
    sysTrapFirstVer33);

implementation

end.
