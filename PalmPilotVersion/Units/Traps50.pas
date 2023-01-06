unit Traps50;

// *
// * (c) HSPascal November-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net
// *

interface

Uses Traps30,Traps35;

// Palm OS 5.0 traps            Arm

// System Traps
Type
  SysTrapNumber50=(
    sysTrapExpansionDispatch  =sysTrapSysReserved2,  //=0xA347
    sysTrapFileSystemDispatch = sysTrapSysReserved3, //=0xA348
    xxxxxxxxx
  );
implementation

end.

// WARNING!!  The following are new traps for 4.0.  If this file is merged
// with MAIN sources, new traps that are added for products that precede
// 4.0 MUST insert their traps BEFORE this section.

//#define sysTrapSysReserved40Trap1               0xA3EC      // used by high density extension (selector trap)
//#define sysTrapSysHighDensitySelector           0xA3EC
//#define sysTrapSysReserved40Trap2               0xA3ED
//#define sysTrapSysReserved40Trap3               0xA3EE
//#define sysTrapSysReserved40Trap4               0xA3EF






// DO NOT CHANGE TRAPS ABOVE THIS LINE
// THESE TRAPS HAVE BEEN RELEASED IN THE 3.5 SDK
// NEW TRAPS FOR PALM OS 4.0 CAN BE ADDED AFTER THIS
// THE ORDER IS NOT IMPORTANT AND CAN BE CHANGED.

// New Trap selector added for New Connection Mgr API
#define sysTrapCncMgrDispatch                   0xA3F0

// new trap for notify from interrupt, implemented in SysEvtMgr.c
#define sysTrapSysNotifyBroadcastFromInterrupt  0xA3F1

// new trap for waking the UI without generating a null event
#define sysTrapEvtWakeupWithoutNilEvent         0xA3F2

// new trap for doing stable, fast, 7-bit string compare
#define sysTrapStrCompareAscii                  0xA3F3

// New trap for accessors available thru PalmOS glue
#define sysTrapAccessorDispatch                 0xA3F4

#define sysTrapBltGetPixel                      0xA3F5
#define sysTrapBltPaintPixel                    0xA3F6
#define sysTrapScrScreenInit                    0xA3F7
#define sysTrapScrUpdateScreenBitmap            0xA3F8
#define sysTrapScrPalette                       0xA3F9
#define sysTrapScrGetColortable                 0xA3FA
#define sysTrapScrGetGrayPat                    0xA3FB
#define sysTrapScrScreenLock                    0xA3FC
#define sysTrapScrScreenUnlock                  0xA3FD
#define sysTrapFntPrvGetFontList                0xA3FE

// Exchange manager functions
#define sysTrapExgRegisterDatatype              0xA3FF
#define sysTrapExgNotifyReceive                 0xA400
#define sysTrapExgNotifyGoto                    0xA401
#define sysTrapExgRequest                       0xA402
#define sysTrapExgSetDefaultApplication         0xA403
#define sysTrapExgGetDefaultApplication         0xA404
#define sysTrapExgGetTargetApplication          0xA405
#define sysTrapExgGetRegisteredApplications     0xA406
#define sysTrapExgGetRegisteredTypes            0xA407
#define sysTrapExgNotifyPreview                 0xA408
#define sysTrapExgControl                       0xA409

// 04/30/00 CS - New Locale Manager handles access to region-specific info like date formats
#define sysTrapLmDispatch                       0xA40A

// 05/10/00 kwk - New Memory Manager trap for retrieving ROM NVParam values (sys use only)
#define sysTrapMemGetRomNVParams                0xA40B

// 05/12/00 kwk - Safe character width Font Mgr call
#define sysTrapFntWCharWidth                    0xA40C

// 05/17/00 kwk - Faster DmFindDatabase
#define sysTrapDmFindDatabaseWithTypeCreator    0xA40D

// New Trap selectors added for time zone picker API
#define sysTrapSelectTimeZone                   0xA40E
#define sysTrapTimeZoneToAscii                  0xA40F

// 08/18/00 kwk - trap for doing stable, fast, 7-bit string compare.
// 08/21/00 kwk - moved here in place of sysTrapSelectDaylightSavingAdjustment.
#define sysTrapStrNCompareAscii                 0xA410

// New Trap selectors added for time zone conversion API
#define sysTrapTimTimeZoneToUTC                 0xA411
#define sysTrapTimUTCToTimeZone                 0xA412

// New trap implemented in PhoneLookup.c
#define sysTrapPhoneNumberLookupCustom          0xA413

// new trap for selecting debugger path.
#define sysTrapHwrDebugSelect                   0xA414

#define sysTrapBltRoundedRectangle              0xA415
#define sysTrapBltRoundedRectangleFill          0xA416
#define sysTrapWinPrvInitCanvas                 0xA417

#define sysTrapHwrCalcDynamicHeapSize           0xA418
#define sysTrapHwrDebuggerEnter                 0xA419
#define sysTrapHwrDebuggerExit                  0xA41A

#define sysTrapLstGetTopItem                    0xA41B

#define sysTrapHwrModelInitStage3               0xA41C

// 06/21/00 peter - New Attention Manager
#define sysTrapAttnIndicatorAllow               0xA41D
#define sysTrapAttnIndicatorAllowed             0xA41E
#define sysTrapAttnIndicatorEnable              0xA41F
#define sysTrapAttnIndicatorEnabled             0xA420
#define sysTrapAttnIndicatorSetBlinkPattern     0xA421
#define sysTrapAttnIndicatorGetBlinkPattern     0xA422
#define sysTrapAttnIndicatorTicksTillNextBlink  0xA423
#define sysTrapAttnIndicatorCheckBlink          0xA424
#define sysTrapAttnInitialize                   0xA425
#define sysTrapAttnGetAttention                 0xA426
#define sysTrapAttnUpdate                       0xA427
#define sysTrapAttnForgetIt                     0xA428
#define sysTrapAttnGetCounts                    0xA429
#define sysTrapAttnListOpen                     0xA42A
#define sysTrapAttnHandleEvent                  0xA42B
#define sysTrapAttnEffectOfEvent                0xA42C
#define sysTrapAttnIterate                      0xA42D
#define sysTrapAttnDoSpecialEffects             0xA42E
#define sysTrapAttnDoEmergencySpecialEffects    0xA42F
#define sysTrapAttnAllowClose                   0xA430
#define sysTrapAttnReopen                       0xA431
#define sysTrapAttnEnableNotification           0xA432
#define sysTrapHwrLEDAttributes                 0xA433
#define sysTrapHwrVibrateAttributes             0xA434

// Trap for getting and setting the device password hint.
#define sysTrapSecGetPwdHint                    0xA435
#define sysTrapSecSetPwdHint                    0xA436

#define sysTrapHwrFlashWrite                    0xA437

#define sysTrapKeyboardStatusNew                0xA438
#define sysTrapKeyboardStatusFree               0xA439
#define sysTrapKbdSetLayout                     0xA43A
#define sysTrapKbdGetLayout                     0xA43B
#define sysTrapKbdSetPosition                   0xA43C
#define sysTrapKbdGetPosition                   0xA43D
#define sysTrapKbdSetShiftState                 0xA43E
#define sysTrapKbdGetShiftState                 0xA43F
#define sysTrapKbdDraw                          0xA440
#define sysTrapKbdErase                         0xA441
#define sysTrapKbdHandleEvent                   0xA442

#define sysTrapOEMDispatch2                     0xA443
#define sysTrapHwrCustom                        0xA444

// 08/28/00 kwk - Trap for getting form's active field.
#define sysTrapFrmGetActiveField                0xA445

// 9/18/00 rkr - Added for playing sounds regardless of interruptible flag
#define sysTrapSndPlaySmfIrregardless           0xA446
#define sysTrapSndPlaySmfResourceIrregardless   0xA447
#define sysTrapSndInterruptSmfIrregardless      0xA448

// 10/14/00 ABa: UDA manager
#define sysTrapUdaMgrDispatch                   0xA449

// WK: private traps for PalmOS
#define sysTrapPalmPrivate1                     0xA44A
#define sysTrapPalmPrivate2                     0xA44B
#define sysTrapPalmPrivate3                     0xA44C
#define sysTrapPalmPrivate4                     0xA44D


// 11/07/00 tlw: Added accessors
#define sysTrapBmpGetDimensions                 0xA44E
#define sysTrapBmpGetBitDepth                   0xA44F
#define sysTrapBmpGetNextBitmap                 0xA450
#define sysTrapTblGetNumberOfColumns            0xA451
#define sysTrapTblGetTopRow                     0xA452
#define sysTrapTblSetSelection                  0xA453
#define sysTrapFrmGetObjectIndexFromPtr         0xA454

// 11/10/00 acs
#define sysTrapBmpGetSizes                      0xA455
#define sysTrapWinGetBounds                     0xA456


#define sysTrapBltPaintPixels                   0xA457

// 11/22/00 bob
#define sysTrapFldSetMaxVisibleLines            0xA458

// 01/09/01 acs
#define sysTrapScrDefaultPaletteState           0xA459

// 11/16/01 bob
#define sysTrapPceNativeCall                    0xA45A

// 12/04/01 lrt
#define sysTrapSndStreamCreate                  0xA45B
#define sysTrapSndStreamDelete                  0xA45C
#define sysTrapSndStreamStart                   0xA45D
#define sysTrapSndStreamPause                   0xA45E
#define sysTrapSndStreamStop                    0xA45F
#define sysTrapSndStreamSetVolume               0xA460
#define sysTrapSndStreamGetVolume               0xA461
#define sysTrapSndPlayResource                  0xA462
#define sysTrapSndStreamSetPan                  0xA463
#define sysTrapSndStreamGetPan                  0xA464

// 04/12/02 jed
#define sysTrapMultimediaDispatch               0xA465

// WARNING!! LEAVE THIS AT THE END AND ALWAYS ADD NEW TRAPS TO
// THE END OF THE TRAP TABLE BUT RIGHT BEFORE THIS TRAP, AND THEN
// RENUMBER THIS ONE TO ONE MORE THAN THE ONE RIGHT BEFORE IT!!!!!!!!!



#define sysTrapLastTrapNumber                0xA466



#define  sysNumTraps  (sysTrapLastTrapNumber - sysTrapBase)



  );

implementation

end.
