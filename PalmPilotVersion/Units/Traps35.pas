unit Traps35;

// *
// * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
// *

interface

Uses Traps33;

// Palm OS 3.5 traps            Palm Vx and Color

// System Traps
Type
  SysTrapNumber33=(
    // HAL Display-layer new traps
    sysTrapHwrDisplayAttributes= sysTrapFirstVer35,
    sysTrapHwrDisplayDoze,
    sysTrapHwrDisplayPalette,

    //Screen driver new traps
    sysTrapBltFindIndexes,
    sysTrapBmpGetBits, // was BltGetBitsAddr
    sysTrapBltCopyRectangle,
    sysTrapBltDrawChars,
    sysTrapBltLineRoutine,
    sysTrapBltRectangleRoutine,

    // ScrUtils new traps
    sysTrapScrCompress,
    sysTrapScrDecompress,

    // System Manager new traps
    sysTrapSysLCDBrightness,

    // WindowColor new traps
    sysTrapWinPaintChar,
    sysTrapWinPaintChars,
    sysTrapWinPaintBitmap,
    sysTrapWinGetPixel,
    sysTrapWinPaintPixel,
    sysTrapWinDrawPixel,
    sysTrapWinErasePixel,
    sysTrapWinInvertPixel,
    sysTrapWinPaintPixels,
    sysTrapWinPaintLines,
    sysTrapWinPaintLine,
    sysTrapWinPaintRectangle,
    sysTrapWinPaintRectangleFrame,
    sysTrapWinPaintPolygon,
    sysTrapWinDrawPolygon,
    sysTrapWinErasePolygon,
    sysTrapWinInvertPolygon,
    sysTrapWinFillPolygon,
    sysTrapWinPaintArc,
    sysTrapWinDrawArc,
    sysTrapWinEraseArc,
    sysTrapWinInvertArc,
    sysTrapWinFillArc,
    sysTrapWinPushDrawState,
    sysTrapWinPopDrawState,
    sysTrapWinSetDrawMode,
    sysTrapWinSetForeColor,
    sysTrapWinSetBackColor,
    sysTrapWinSetTextColor,
    sysTrapWinGetPatternType,
    sysTrapWinSetPatternType,
    sysTrapWinPalette,
    sysTrapWinRGBToIndex,
    sysTrapWinIndexToRGB,
    sysTrapWinScreenLock,
    sysTrapWinScreenUnlock,
    sysTrapWinGetBitmap,

    // UIColor new traps
    sysTrapUIColorInit,
    sysTrapUIColorGetTableEntryIndex,
    sysTrapUIColorGetTableEntryRGB,
    sysTrapUIColorSetTableEntry,
    sysTrapUIColorPushTable,
    sysTrapUIColorPopTable,

    // misc cleanup and API additions

    sysTrapCtlNewGraphicControl,

    sysTrapTblGetItemPtr,

    sysTrapUIBrightnessAdjust,
    sysTrapUIPickColor,

    sysTrapEvtSetAutoOffTimer,

    // Misc int'l/overlay support.
    sysTrapTsmDispatch,
    sysTrapOmDispatch,
    sysTrapDmOpenDBNoOverlay,
    sysTrapDmOpenDBWithLocale,
    sysTrapResLoadConstant,

    // new boot-time SmallROM HAL additions
    sysTrapHwrPreDebugInit,
    sysTrapHwrResetNMI,
    sysTrapHwrResetPWM,

    sysTrapKeyBootKeys,

    sysTrapDbgSerDrvOpen,
    sysTrapDbgSerDrvClose,
    sysTrapDbgSerDrvControl,
    sysTrapDbgSerDrvStatus,
    sysTrapDbgSerDrvWriteChar,
    sysTrapDbgSerDrvReadChar,

    // new boot-time BigROM HAL additions
    sysTrapHwrPostDebugInit,
    sysTrapHwrIdentifyFeatures,
    sysTrapHwrModelSpecificInit,
    sysTrapHwrModelInitStage2,
    sysTrapHwrInterruptsInit,

    sysTrapHwrSoundOn,
    sysTrapHwrSoundOff,

    // Kernel clock tick routine
    sysTrapSysKernelClockTick,

    // MenuEraseMenu is exposed as of PalmOS 3.5, but there are
    // no public interfaces for it yet.  Perhaps in a later release.
    sysTrapMenuEraseMenu,

    sysTrapSelectTime,

    // Menu Command Bar traps
    sysTrapMenuCmdBarAddButton,
    sysTrapMenuCmdBarGetButtonData,
    sysTrapMenuCmdBarDisplay,

    // Silkscreen info
    sysTrapHwrGetSilkscreenID,
    sysTrapEvtGetSilkscreenAreaList,

    sysTrapSysFatalAlertInit,
    sysTrapDateTemplateToAscii,

    // New traps dealing with masking private records
    sysTrapSecVerifyPW,
    sysTrapSecSelectViewStatus,
    sysTrapTblSetColumnMasked,
    sysTrapTblSetRowMasked,
    sysTrapTblRowMasked,

    // New form trap for dialogs with text entry field
    sysTrapFrmCustomResponseAlert,
    sysTrapFrmNewGsi,

    // New dynamic menu functions
    sysTrapMenuShowItem,
    sysTrapMenuHideItem,
    sysTrapMenuAddItem,

    // New form traps for "smart gadgets"
    sysTrapFrmSetGadgetHandler,

    // More new control functions
    sysTrapCtlSetGraphics,
    sysTrapCtlGetSliderValues,
    sysTrapCtlSetSliderValues,
    sysTrapCtlNewSliderControl,

    // Bitmap manager functions
    sysTrapBmpCreate,
    sysTrapBmpDelete,
    sysTrapBmpCompress,
    // sysTrapBmpGetBits defined in Screen driver traps
    sysTrapBmpGetColortable,
    sysTrapBmpSize,
    sysTrapBmpBitsSize,
    sysTrapBmpColortableSize,
    // extra window namager
    sysTrapWinCreateBitmapWindow,
    // Ask for a null event sooner (replaces a macro which Poser hated)
    sysTrapEvtSetNullEventTick,

    // Exchange manager call to allow apps to select destination categories
    sysTrapExgDoDialog,

    // this call will remove temporary UI like popup lists
    sysTrapSysUICleanup, //$A3E7

    // The following 4 traps were "Reserved" traps, present only in SOME post-release builds of Palm OS 3.5
    sysTrapWinSetForeColorRGB=                                  0xA3E8,
    sysTrapWinSetBackColorRGB=                                  0xA3E9,
    sysTrapWinSetTextColorRGB=                                  0xA3EA,
    sysTrapWinGetPixelRGB=                                      0xA3EB,

    sysTrapFirstVer40);

implementation

end.
