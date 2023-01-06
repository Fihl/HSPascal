/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Preferences.h
 *
 * Description:
 *    Header for the system preferences
 *
 * History:
 *    02/31/95 rsf   Created by Roger Flores
 *    06/26/99 kwk   Added LanguageType.
 *    06/30/99 CS    Added MeasurementSystemType, then added it to both
 *                   CountryPreferencesType and SystemPreferencesType,
 *                   and bumped the version to 7.
 *             CS    Added prefMeasurementSystem to select this
 *                   preference.
 *             CS    Added filler fields to CountryPreferencesType
 *                   structure, since this guy gets saved as a
 *                   resource.
 *    09/20/99 gap   added additional cXXXX country values.
 *    09/20/99 gap   cPRC -> cRepChina.
 *    10/4/99  jmp   Add support for auto-off duration times in seconds
 *                   instead of minutes (the new seconds-based auto-off
 *                   duration time is preferred; the minutes-based auto-ff
 *                   duration times are maintained for compatibility).
 *    10/5/99  jmp   Make the seconds auto-off duration field a UInt16
 *                   instead of a UInt8; also define constants for the
 *                   "pegged" auto-off duration values (when the value
 *                   is pegged, we no longer automatically shut off).
 *    12/23/99 jmp   Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Preferences;

interface

Uses DateTime, Localize, DataMgr, SystemMgr;

/***********************************************************************
 * Constants
 ***********************************************************************/

Const
  noPreferenceFound  =-1;

// Preference version constants
  preferenceDataVer2       =2;
  preferenceDataVer3       =3;
  preferenceDataVer4       =4;
  preferenceDataVer5       =5;
  preferenceDataVer6       =6;
  preferenceDataVer7       =7;

// Be SURE to update "preferenceDataVerLatest" when adding a new prefs version...
  preferenceDataVerLatest  =preferenceDataVer7;

  defaultAutoOffDuration   =2;        // minutes


  sndMaxAmp          =64;    //ALSO IN SoundMgr, circular ref prevention
  defaultSysSoundVolume    =sndMaxAmp;
  defaultGameSoundVolume   =sndMaxAmp;
  defaultAlarmSoundVolume  =sndMaxAmp;

Type
  CountryType = (
     cAustralia = 0,      // 0
     cAustria,            // 1
     cBelgium,            // 2
     cBrazil,             // 3
     cCanada,             // 4
     cDenmark,            // 5
     cFinland,            // 6
     cFrance,             // 7
     cGermany,            // 8
     cHongKong,           // 9
     cIceland,            // 10
     cIreland,            // 11
     cItaly,              // 12
     cJapan,              // 13
     cLuxembourg,         // 14
     cMexico,             // 15
     cNetherlands,        // 16
     cNewZealand,         // 17
     cNorway,             // 18
     cSpain,              // 19
     cSweden,             // 20
     cSwitzerland,        // 21
     cUnitedKingdom,      // 22
     cUnitedStates,       // 23
     cIndia,              // 24
     cIndonesia,          // 25
     cKorea,              // 26
     cMalaysia,           // 27
     cRepChina,           // 28
     cPhilippines,        // 29
     cSingapore,          // 30
     cThailand,           // 31
     cTaiwan              // 32

     // Always add new countries at the end!
     // Always update OverlayMgr.cp!

  );

Const
  countryFirst    =cAustralia;
  countryLast     =cTaiwan;
  countryCount    = 33; //(countryLast - countryFirst + 1);

Type
  LanguageType = (
    languageFirst = 0,
    lEnglish = languageFirst,  // 0
    lFrench,                   // 1
    lGerman,                   // 2
    lItalian,                  // 3
    lSpanish,                  // 4
                               // 5 (English WorkPad - unused)
    lJapanese = 6,             // 6
    lDutch,                    // 7


    // Always add new languages at the end!
    // Always update OverlayMgr.cp!

    languageLast = lDutch
  );

Const
  languageCount      = 8; //languageLast - languageFirst + 1;

Type
  MeasurementSystemType = (
    unitsEnglish = 0,    // Feet, yards, miles, gallons, pounds, slugs, etc.
    unitsMetric          // Meters, liters, grams, newtons, etc.
  );


// These sound levels must corrospond to positions in the popup lists
// used by the preferences app.  These are made obsolete after V20.  The
// loudness of the sound is now represented as a number from 0 to sndMaxAmp.
  SoundLevelTypeV20 = (
    slOn = 0,
    slOff = 1
  );

Const
  countryNameLength     =20;
  currencyNameLength    =20;
  currencySymbolLength  =6;   

// An array of these structures (one per country) is kept in the system
// resource.
Type
  CountryPreferencesType = Record
    country: CountryType;              // Country the structure represents
    filler1: UInt8;                    // (Word alignment)
    countryName: String[countryNameLength-1];
    dateFormat: DateFormatType;        // Format to display date in
    longDateFormat: DateFormatType;    // Format to display date in
    weekStartDay: Int8;                // Sunday or Monday
    timeFormat: TimeFormatType;        // Format to display time in
    numberFormat: NumberFormatType;    // Format to display numbers in
    filler2: UInt8;                    // (Word alignment)
    currencyName: String[currencyNameLength-1];             // Dollars
    currencySymbol: String[currencySymbolLength-1];         // $
    uniqueCurrencySymbol: String[currencySymbolLength-1];   // US$
    currencyDecimalPlaces: UInt8;      // 2 for 1.00
    daylightSavings: DaylightSavingsTypes;   // Type of daylight savings correction
    minutesWestOfGMT: UInt32;             // minutes west of Greenwich
    measurementSystem: MeasurementSystemType;  // metric, english, etc.
    filler3: UInt8;                    // (Word alignment)
  end;

// The number format (thousands separator and decimal point).  This defines
// how numbers are formatted and not neccessarily currency numbers (i.e. Switzerland).
  AnimationLevelType = (
    alOff,                           // Never show an animation
    alEventsOnly,                    // Show an animation for an event
    alEventsAndRandom,               // Also show random animation
    alEventsAndMoreRandom            // Show random animations more frequently
  );


  SystemPreferencesChoice = (
    prefVersion,
    prefCountry,
    prefDateFormat,
    prefLongDateFormat,
    prefWeekStartDay,
    prefTimeFormat,
    prefNumberFormat,
    prefAutoOffDuration,
    prefSysSoundLevelV20,            // slOn or slOff - error beeps and other non-alarm/game sounds
    prefGameSoundLevelV20,           // slOn or slOff - game sound effects
    prefAlarmSoundLevelV20,          // slOn or slOff - alarm sound effects
    prefHidePrivateRecordsV33,
    prefDeviceLocked,
    prefLocalSyncRequiresPassword,
    prefRemoteSyncRequiresPassword,
    prefSysBatteryKind,
    prefAllowEasterEggs,
    prefMinutesWestOfGMT,
    prefDaylightSavings,
    prefRonamaticChar,
    prefHard1CharAppCreator,         // App creator for hard key #1
    prefHard2CharAppCreator,         // App creator for hard key #2
    prefHard3CharAppCreator,         // App creator for hard key #3
    prefHard4CharAppCreator,         // App creator for hard key #4
    prefCalcCharAppCreator,          // App creator for calculator soft key
    prefHardCradleCharAppCreator,    // App creator for hard cradle key
    prefLauncherAppCreator,          // App creator for launcher soft key
    prefSysPrefFlags,
    prefHardCradle2CharAppCreator,   // App creator for 2nd hard cradle key
    prefAnimationLevel,

    // Additions for PalmOS 3.0:
    prefSysSoundVolume,              // actual amplitude - error beeps and other non-alarm/game sounds
    prefGameSoundVolume,             // actual amplitude - game sound effects
    prefAlarmSoundVolume,            // actual amplitude - alarm sound effects
    prefBeamReceive,                 // False turns off IR sniffing, sends still work.
    prefCalibrateDigitizerAtReset,   // True makes the user calibrate at soft reset time
    prefSystemKeyboardID,            // ID of the preferred keyboard resource
    prefDefSerialPlugIn,             // creator ID of the default serial plug-in

    // Additions for PalmOS 3.1:
    prefStayOnWhenPluggedIn,         // don't sleep after timeout when using line current
    prefStayLitWhenPluggedIn,        // keep backlight on when not sleeping on line current

    // Additions for PalmOS 3.2:
    prefAntennaCharAppCreator,       // App creator for antenna key

    // Additions for PalmOS 3.3:
    prefMeasurementSystem,           // English, Metric, etc.

    // Additions for PalmOS 3.5:
    prefShowPrivateRecords           //returns privateRecordViewEnum
  );


  (******
  SystemPreferencesTypeV10 = Record
    version: UInt16;                  // Version of preference info

    // International preferences
    country: CountryType;             // Country the device is in
    dateFormat: DateFormatType;       // Format to display date in
    longDateFormat: DateFormatType;   // Format to display date in
    weekStartDay: UInt8;              // Sunday or Monday
    timeFormat: TimeFormatType;       // Format to display time in
    numberFormat: NumberFormatType;   // Format to display numbers in

    // system preferences
    autoOffDuration: UInt8;           // Time period before shutting off
    sysSoundLevel: SoundLevelTypeV20;    // slOn or slOff - error beeps and other non-alarm sounds
    alarmSoundLevel: SoundLevelTypeV20;  // slOn or slOff - alarm only
    hideSecretRecords: Boolean;       // True to not display records with
                                     // their secret bit attribute set
    deviceLocked: Boolean;            // Device locked until the system
                                     // password is entered
    reserved1: UInt8;
    sysPrefFlags: UInt16;             // Miscellaneous system pref flags
                                     //  copied into the global GSysPrefFlags
                                     //  at boot time.
    sysBatteryKind_: SysBatteryKind;   // The type of batteries installed. This
                                     // is copied into the globals GSysbatteryKind
                                     //  at boot time.
    reserved2: UInt8;
  end;
  (********)

// Any entries added to this structure must be initialized in
// Prefereces.c:GetPreferenceResource

  SystemPreferencesPtr = ^SystemPreferencesType;
  SystemPreferencesType = Record
    version: UInt16;                  // Version of preference info

    // International preferences
    country: CountryType;             // Country the device is in
    dateFormat: DateFormatType;       // Format to display date in
    longDateFormat: DateFormatType;   // Format to display date in
    weekStartDay: Int8;               // Sunday or Monday
    timeFormat: TimeFormatType;       // Format to display time in
    numberFormat: NumberFormatType;   // Format to display numbers in

    // system preferences
    autoOffDuration: UInt8;           // Time period in minutes before shutting off
    sysSoundLevelV20: SoundLevelTypeV20;    // slOn or slOff - error beeps and other non-alarm/game sounds
    gameSoundLevelV20: SoundLevelTypeV20;   // slOn or slOff - game sound effects
    alarmSoundLevelV20: SoundLevelTypeV20;  // slOn or slOff - alarm sound effects
    hideSecretRecords: Boolean;       // True to not display records with
                                     // their secret bit attribute set
    deviceLocked: Boolean;            // Device locked until the system
                                     // password is entered
    localSyncRequiresPassword: Boolean;  // User must enter password on Pilot
    remoteSyncRequiresPassword: Boolean; // User must enter password on Pilot
    sysPrefFlags: UInt16;             // Miscellaneous system pref flags
                                     //  copied into the global GSysPrefFlags
                                     //  at boot time. Constants are
                                     //  sysPrefFlagXXX defined in SystemPrv.h
    sysBatteryKind_: SysBatteryKind;   // The type of batteries installed. This
                                     // is copied into the globals GSysbatteryKind
                                     //  at boot time.
    reserved1: UInt8;
    minutesWestOfGMT: UInt32;         // minutes west of Greenwich
    daylightSavings: DaylightSavingsTypes;  // Type of daylight savings correction
    reserved2: UInt8;
    ronamaticChar: UInt16;            // character to generate from ronamatic stroke.
                                      //  Typically it popups the onscreen keyboard.
    hard1CharAppCreator: UInt32;      // creator of application to launch in response
                                      //  to the hard button #1. Used by SysHandleEvent.
    hard2CharAppCreator: UInt32;      // creator of application to launch in response
                                      //  to the hard button #2. Used by SysHandleEvent.
    hard3CharAppCreator: UInt32;      // creator of application to launch in response
                                      //  to the hard button #3. Used by SysHandleEvent.
    hard4CharAppCreator: UInt32;      // creator of application to launch in response
                                      //  to the hard button #4. Used by SysHandleEvent.
    calcCharAppCreator: UInt32;       // creator of application to launch in response
                                      //  to the Calculator icon. Used by SysHandleEvent.
    hardCradleCharAppCreator: UInt32; // creator of application to launch in response
                                      //  to the Cradle button. Used by SysHandleEvent.
    launcherCharAppCreator: UInt32;   // creator of application to launch in response
                                      //  to the launcher button. Used by SysHandleEvent.
    hardCradle2CharAppCreator: UInt32;// creator of application to launch in response
                                      //  to the 2nd Cradle button. Used by SysHandleEvent.
    animationLevel: AnimationLevelType;// amount of animation to display

    maskPrivateRecords: Boolean;      // Only meaningful if hideSecretRecords is true.
                                      //true to show a grey placeholder box for secret records.
                                      //was reserved3 - added for 3.5
                                       
   
    // Additions for PalmOS 3.0:
    sysSoundVolume: UInt16;              // system amplitude (0 - sndMaxAmp) - taps, beeps
    gameSoundVolume: UInt16;             // game amplitude (0 - sndMaxAmp) - explosions
    alarmSoundVolume: UInt16;            // alarm amplitude (0 - sndMaxAmp)
    beamReceive: Boolean;                // False turns off IR sniffing, sends still work.
    calibrateDigitizerAtReset: Boolean;  // True makes the user calibrate at soft reset time
    systemKeyboardID: UInt16;            // ID of the preferred keyboard resource
    defSerialPlugIn: UInt32;             // creator ID of the default serial plug-in

    // Additions for PalmOS 3.1:
    stayOnWhenPluggedIn: Boolean;        // don't sleep after timeout when using line current
    stayLitWhenPluggedIn: Boolean;       // keep backlight on when not sleeping on line current

    // Additions for PalmOS 3.2:
    antennaCharAppCreator: UInt32;       // creator of application to launch in response
                                         //  to the antenna key. Used by SysHandleEvent.

    // Additions for PalmOS 3.5:
    measurementSystem: MeasurementSystemType; // metric, english, etc.
  end;

// HSPascal!
//
// Remember to use function s2u32(Const S: String): UInt32 as defined in HSUtils
// Use it as: x:=FtrPtrNew(s2u32('TEST'), 123, 8, MyPointer);

//-------------------------------------------------------------------
// Preferences routines
//-------------------------------------------------------------------

Function PrefOpenPreferenceDBV10: DmOpenRef;
      SYS_TRAP(sysTrapPrefOpenPreferenceDBV10);

Function PrefOpenPreferenceDB(saved: Boolean): DmOpenRef;
      SYS_TRAP(sysTrapPrefOpenPreferenceDB);

Procedure PrefGetPreferences(p: SystemPreferencesPtr);
      SYS_TRAP(sysTrapPrefGetPreferences);

Procedure PrefSetPreferences(p: SystemPreferencesPtr);
      SYS_TRAP(sysTrapPrefSetPreferences);

Function PrefGetPreference(choice: SystemPreferencesChoice): UInt32;
      SYS_TRAP(sysTrapPrefGetPreference);

Procedure PrefSetPreference(choice: SystemPreferencesChoice; value: UInt32);
      SYS_TRAP(sysTrapPrefSetPreference);

Function PrefGetAppPreferences(creator: UInt32; id: UInt16; prefs: Pointer;
   var prefsSize: UInt16; saved: Boolean): Int16;
      SYS_TRAP(sysTrapPrefGetAppPreferences);

Function PrefGetAppPreferencesV10(typ: UInt32; version: Int16; prefs: Pointer;
   prefsSize: UInt16): Boolean;
      SYS_TRAP(sysTrapPrefGetAppPreferencesV10);

Procedure PrefSetAppPreferences(creator: UInt32; id: UInt16; version: Int16;
   prefs: Pointer; prefsSize: UInt16; saved: Boolean);
      SYS_TRAP(sysTrapPrefSetAppPreferences);

Procedure PrefSetAppPreferencesV10(creator: UInt32; version: Int16; prefs: Pointer; prefsSize: UInt16);
      SYS_TRAP(sysTrapPrefSetAppPreferencesV10);

implementation

end.

