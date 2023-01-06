/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SystemResources.h
 *
 * Description:
 *    Include file for both PalmRez and the C Compiler. This file contains
 *  equates used by both tools. When compiling using the C compiler
 *  the variable RESOURCE_COMPILER must be defined.
 *
 * History:
 *    02/27/95 ron   Created by Ron Marianetti
 *    08/04/95 vmk   Added system resource id for Desktop Link user info
 *    02/03/98 tlw   Changed sysFileCDefaultApp from sysFileCMemory which
 *                   no longer exists to sysFileCPreferences.
 *    6/23/98  jhl   Added FlashMgr resource
 *    06/23/98 jhl   Added FlashMgr resource
 *    05/05/99 kwk   Added simulator creator/file types, also the
 *                   Japanese user dict panel creator and the TSM
 *                   library creator.
 *    05/06/99 lyl   Added OEM System File type
 *    06/25/99 kwk   Added sysResIDAppPrefs & sysResIDOverlayFeatures.
 *    07/14/99 kwk   Added sysResTSilkscreen.
 *    08/08/99 kwk   Added sysFileCJEDict.
 *    09/20/99 kwk   Added keyboard feature for reentrancy check.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SystemResources;

interface

Const

//-----------------------------------------------------------
// This section is common to both the C and Resource Compiler
//-----------------------------------------------------------

//................................................................
// File types and creators
//
// Each database shall have a creator ID and a type.
//
// The creator ID shall establish which application, patch, or extension
// a particular database is associated with.  The creator ID should identify
// the application/patch/extension, NOT who created it.
//
// The type will determine which part of an application,
// patch, or extension a particular database is.
//
// There can be only one database per application, patch, or extension
// which has type 'application', 'patch', or 'extension'.
//
// Creators:
//
// ROM-based applications created by Palm Computing have all-lower case
// creator ID's.  Third-party applications have creator ID's which
// are either all caps, or mixed case.  The same requirements go for
// system patches and extensions.
//
// All applications, system patches and extensions shall have unique creator
// ID's.
//
// Types:
//
// 'Application', 'Extension', and 'Patch' file/database types for ROM-based
// apps shall be all-lower case (they are defined below).  Other
// file/database types must be mixed-case,
// or all caps.  These other types are internal to the applications, and
// therefore the system is unconcerned with their exact values.
//................................................................
  sysFileCSystem                ='psys';   // Creator type for System files
  sysFileCOEMSystem             ='poem';   // Creator type for OEM System files
  sysFileCGraffiti              ='graf';   // Creator type for Graffiti databases
  sysFileCSystemPatch           ='ptch';   // Creator for System resource file patches

  sysFileCCalculator            ='calc';   // Creator type for Calculator App
  sysFileCSecurity              ='secr';   // Creator type for Security App
  sysFileCPreferences           ='pref';   // Creator type for Preferences App
  sysFileCAddress               ='addr';   // Creator type for Address App
  sysFileCToDo                  ='todo';   // Creator type for To Do App
  sysFileCDatebook              ='date';   // Creator type for Datebook App
  sysFileCMemo                  ='memo';   // Creator type for MemoPad App
  sysFileCSync                  ='sync';   // Creator type for HotSync App
  sysFileCMemory                ='memr';   // Creator type for Memory App
  sysFileCMail                  ='mail';   // Creator type for Mail App
  sysFileCExpense               ='exps';   // Creator type for Expense App
  sysFileCLauncher              ='lnch';   // Creator type for Launcher App
  sysFileCClipper               ='clpr';   // Creator type for clipper app.
  sysFileCSetup                 ='setp';   // Creator type for setup app.
  sysFileCActivate              ='actv';   // Creator type for activation app.
  sysFileCFlashInstaller        ='fins';   // Creator type for FlashInstaller app.
  sysFileCRFDiag                ='rfdg';   // Creator type for RF diagnostics app.
  sysFileCMessaging             ='msgs';   // Creator type for Messaging App
  sysFileCModemFlashTool        ='gsmf';   // Creator type for Palm V modem flash app.
  sysFileCJEDict                ='dict';   // Creator type for JEDict app.
  sysFileHotSyncServer          ='srvr';   // Creator type for HotSync(R) Server app.
  sysFileHotSyncServerUpdate    ='hssu';   // Creator type for HotSync(R) Server update app.

// The following two apps are manufacturing, calibration and maintenance related
  sysFileCMACUtilScreen         ='mcut';   // Creator type for screen oriented MACUtil app.
  sysFileCMACUtilSerial         ='mcus';   // Creator type for serial line driven MACUtil app.
  sysResIDMACUtilAutostart      =10000;    // Autostart serial MACUtil

// Demo Apps
  sysFileCGraffitiDemo          ='gdem';   // Creator type for Graffiti Demo
  sysFileCMailDemo              ='mdem';   // Creator type for Mail Demo

  sysFileCFirstApp             = sysFileCPreferences;  // Creator type for First App after reset
  sysFileCAltFirstApp          = sysFileCSetup;        // Creator type for First alternate App after reset (with hard key pressed)
  sysFileCDefaultApp           = sysFileCPreferences;  // Creator type for Default app
  sysFileCDefaultButton1App    = sysFileCDatebook;     // Creator type for dflt hard button 1 app
  sysFileCDefaultButton2App    = sysFileCAddress;      // Creator type for dflt hard button 2 app
  sysFileCDefaultButton3App    = sysFileCToDo;         // Creator type for dflt hard button 3 app
  sysFileCDefaultButton4App    = sysFileCMemo;         // Creator type for dflt hard button 4 app
  sysFileCDefaultCalcButtonApp = sysFileCCalculator;   // Creator type for dflt calc button app
  sysFileCDefaultCradleApp     = sysFileCSync;         // Creator type for dflt hot sync button app
  sysFileCDefaultModemApp      = sysFileCSync;         // Creator type for dflt modem button app
  sysFileCDefaultAntennaButtonApp = sysFileCLauncher;  // Creator type for dflt antenna up button app
  sysFileCNullApp               ='0000';   // Creator type for non-existing app
  sysFileCSimulator             ='????';  // Creator type for Simulator files (app.tres, sys.tres)
                                    // '????' does not compile with VC++ (Elaine Server)

  sysFileCDigitizer             ='digi';   // Creator type for Digitizer Panel
  sysFileCGeneral               ='gnrl';   // Creator type for General Panel
  sysFileCFormats               ='frmt';   // Creator type for Formats Panel
  sysFileCShortCuts             ='shct';   // Creator type for ShortCuts Panel
  sysFileCButtons               ='bttn';   // Creator type for Buttons Panel
  sysFileCOwner                 ='ownr';   // Creator type for Owner Panel
  sysFileCModemPanel            ='modm';   // Creator type for Modem Panel
  sysFileCDialPanel             ='dial';   // Creator type for Dial Panel
  sysFileCNetworkPanel          ='netw';   // Creator type for Network Panel
  sysFileCWirelessPanel         ='wrls';   // Creator type for the wireless Panel.
  sysFileCUserDict              ='udic';   // Creator type for the UserDict panel.
  sysFileCPADHtal               ='hpad';   // Creator type for PAD HTAL lirary
  sysFileCTCPHtal               ='htcp';   // Creator type for TCP HTAL lirary
  sysFileCMineHunt              ='mine';   // Creator type for MineHunt App
  sysFileCPuzzle15              ='puzl';   // Creator type for Puzzle "15" App
  sysFileCOpenLibInfo           ='olbi';   // Creator type for Feature Manager features
                                           // used for saving open library info under PalmOS v1.x
  sysFileCHwrFlashMgr           ='flsh';   // Creator type for HwrFlashMgr features

// Libraries.  If the resource used by these are expected to be treated as part of
// the system's usage then the Memory app must be changed.
  sysFileTLibrary               ='libr';   // File type of Shared Libraries
  sysFileTLibraryExtension      ='libx';   // File type of library extensions

  sysFileCNet                   ='netl';   // Creator type for Net (TCP/IP) Library
  sysFileCRmpLib                ='netp';   // Creator type for RMP Library (NetLib plug-in)
  sysFileCINetLib               ='inet';   // Creator type for INet Library
  sysFileCSecLib                ='secl';   // Creator type for Ir Library
  sysFileCWebLib                ='webl';   // Creator type for Web Library
  sysFileCIrLib                 ='irda';   // Creator type for Ir Library

  sysFileCSerialMgr             ='smgr';   // Creator for SerialMgrNew used for features.
  sysFileCSerialWrapper         ='swrp';   // Creator type for Serial Wrapper Library.
  sysFileCIrSerialWrapper       ='iwrp';   // Creator type for Ir Serial Wrapper Library.
  sysFileCTextServices          ='tsml';   // Creator type for Text Services Library.

  sysFileTUartPlugIn            ='sdrv';   // File type for SerialMgrNew physical port plug-in.
  sysFileTVirtPlugin            ='vdrv';   // Flir type for SerialMgrNew virtual port plug-in.
  sysFileCUart328               ='u328';   // Creator type for '328 UART plug-in
  sysFileCUart328EZ             ='u8EZ';   // Creator type for '328EZ UART plug-in
  sysFileCUart650               ='u650';   // Creator type for '650 UART plug-in
  sysFileCVirtIrComm            ='ircm';   // Creator type for IrComm virtual port plug-in.

  sysFileTSystem                ='rsrc';   // File type for Main System File
  sysFileTSystemPatch           ='ptch';   // File type for System resource file patches
  sysFileTKernel                ='krnl';   // File type for System Kernel (AMX)
  sysFileTBoot                  ='boot';   // File type for SmallROM System File
  sysFileTSmallHal              ='shal';   // File type for SmallROM HAL File
  sysFileTBigHal                ='bhal';   // File type for Main ROM HAL File
  sysFileTSplash                ='spls';   // File type for Main ROM Splash File
  sysFileTUIAppShell            ='uish';   // File type for UI Application Shell
  sysFileTOverlay               ='ovly';   // File type for UI overlay database
  sysFileTExtension             ='extn';   // File type for System Extensions
  sysFileTApplication           ='appl';   // File type for applications
  sysFileTPanel                 ='panl';   // File type for preference panels
  sysFileTSavedPreferences      ='sprf';   // File type for saved preferences
  sysFileTPreferences           ='pref';   // File type for preferences
  sysFileTMidi                  ='smfr';   // File type for Standard MIDI File record databases
  sysFileTpqa                   ='pqa ';   // File type for the PQA files.

  sysFileTUserDictionary        ='dict';   // File type for input method user dictionary.
  sysFileTLearningData          ='lean';   // File type for input method learning data.

  sysFileTGraffitiMacros        ='macr';   //  Graffiti Macros database

  sysFileTHtalLib               ='htal';   //  HTAL library

  sysFileTExgLib                ='exgl';   // Type of Exchange libraries

  sysFileTFileStream            ='strm';   //  Default File Stream database type

  sysFileTTemp                  ='temp';   //  Temporary database type; in future versions
                                           //  of PalmOS (although likely not before 3.3), the
                                           //  system may automatically delete any db's of
                                           //  this type at reset time (however, apps are still
                                           //  responsible for deleting the ones they create
                                           //  before exiting to protect valuable storage space)

  sysFileTScriptPlugin          ='scpt';   // File type for plugin to the Network Panel to
                                           //extend scripting capabilities.

  sysFileTSimulator             ='????';   // File type for Simulator files (app.tres, sys.tres)
                                           // '????' does not compile with VC++ (Elaine Server)

//................................................................
// Resource types and IDs
//................................................................
  sysResTBootCode               ='boot';   // Resource type of boot resources
  sysResIDBootReset            = 10000;    // Reset code
  sysResIDBootInitCode         = 10001;    // Init code
  sysResIDBootSysCodeStart     = 10100;    // System code resources start here
  sysResIDBootSysCodeMin       = 10102;    // IDs 'Start' to this must exist!!
  sysResIDBootUICodeStart      = 10200;    // UI code resources start here
  sysResIDBootUICodeMin        = 10203;    // IDs 'Start' to this must exist!!

  sysResIDBootHAL              = 19000;    // HAL code resource (from HAL.prc)

  sysResIDBitmapSplash         = 19000;    // ID of (boot) splash screen bitmap
  sysResIDBitmapConfirm        = 19001;    // ID of hard reset confirmation bitmap

  sysResTAppPrefs               ='pref';   // Resource type of App preferences resources
  sysResIDAppPrefs             = 0;        // Application preference

  sysResTExtPrefs               ='xprf';   // Resource type of extended preferences
  sysResIDExtPrefs             = 0;        // Extended preferences

  sysResTAppCode                ='code';   // Resource type of App code resources
  sysResTAppGData               ='data';   // Resource type of App global data resources

  sysResTExtensionCode          ='extn';   // Resource type of Extensions code
  sysResTExtensionOEMCode       ='exte';   // Resource type of OEM Extensions code

  sysResTFeatures               ='feat';   // Resource type of System features table
  sysResIDFeatures             = 10000;    // Resource ID of System features table
  sysResIDOverlayFeatures      = 10001;    // Resource ID of system overlay feature table.

  sysResTCountries              ='cnty';   // Resource type of System countries table
  sysResIDCountries            = 10000;    // Resource ID of System countries table

  sysResTLibrary                ='libr';   // Resource type of System Libraries
  //sysResIDLibrarySerMgr328   = 10000;    // Dragonball (68328) UART
  //sysResIDLibrarySerMgr681   = 10001;    // 68681 UART
  //sysResIDLibraryRMPPlugIn   = 10002;    // Reliable Message Protocol NetLib Plug-in

  sysResTSilkscreen             ='silk';   // Resource type of silkscreen info.

  sysResTGrfTemplate            ='tmpl';   // Graffiti templates "file"
  sysResIDGrfTemplate          = 10000;    // Graffiti templates "file" ID
  sysResTGrfDictionary          ='dict';   // Graffiti dictionary "file"
  sysResIDGrfDictionary        = 10000;    // Graffiti dictionary "file" ID
  sysResIDGrfDefaultMacros     = 10000;    // sysResTDefaultDB resource with Graffiti Macros database

  sysResTDefaultDB              ='dflt';   // Default database resource type
  sysResIDDefaultDB            = 1;        // resource ID of sysResTDefaultDB in each app

  sysResTErrStrings             ='tSTL';   // list of error strings
  sysResIDErrStrings           = 10000;    // resource ID is (errno>>8)+sysResIDErrStrings

  sysResIDOEMDBVersion         = 20001;    // resource ID of "tver" and "tint" versions in OEM stamped databases

// System Preferences
  sysResTSysPref                =sysFileCSystem;
  sysResIDSysPrefMain          = 0;        // Main preferences
  sysResIDSysPrefPassword      = 1;        // Password
  sysResIDSysPrefFindStr       = 2;        // Find string
  sysResIDSysPrefCalibration   = 3;        // Digitizer calibration.
  sysResIDDlkUserInfo          = 4;        // Desktop Link user information.
  sysResIDDlkLocalPC           = 5;        // Desktop Link local PC host name
  sysResIDDlkCondFilterTab     = 6;        // Desktop Link conduit filter table
  sysResIDModemMgrPref         = 7;        // Modem Manager preferences
  sysResIDDlkLocalPCAddr       = 8;        // Desktop Link local PC host address
  sysResIDDlkLocalPCMask       = 9;        // Desktop Link local PC host subnet mask

// These prefs store parameters to pass to an app when launched with a button
  sysResIDButton1Param         = 10;       // Parameter for hard button 1 app
  sysResIDButton2Param         = 11;       // Parameter for hard button 2 app
  sysResIDButton3Param         = 12;       // Parameter for hard button 3 app
  sysResIDButton4Param         = 13;       // Parameter for hard button 4 app
  sysResIDCalcButtonParam      = 14;       // Parameter for calc button app
  sysResIDCradleParam          = 15;       // Parameter for hot sync button app
  sysResIDModemParam           = 16;       // Parameter for modem button app
  sysResIDAntennaButtonParam   = 17;       // Parameter for antenna up button app

// New for Color, user's color preferences
  sysResIDPrefUIColorTableBase  = 17;      // base + depth = ID of actual pref
  sysResIDPrefUIColorTable1     = 18;      // User's UI colors for 1bpp displays
  sysResIDPrefUIColorTable2     = 19;      // User's UI colors for 2bpp displays
  sysResIDPrefUIColorTable4     = 21;      // User's UI colors for 4bpp displays
  sysResIDPrefUIColorTable8     = 25;      // User's UI colors for 8bpp displays

// FlashMgr Resources - old
  sysResTFlashMgr               ='flsh';
  sysResIDFlashMgrWorkspace    = 1;        // RAM workspace during flash activity

// FlashMgr Resources - new
  sysResTHwrFlashIdent          ='flid';   // Flash identification code resource
  sysResIDHwrFlashIdent        = 10000;    // Flash identification code resource

  sysResTHwrFlashCode           ='flcd';   // Flash programming code resource
                                           // (resource ID determined by device type)

// OEM Feature type and id.
  sysFtrTOEMSys                 =sysFileCOEMSystem;
  sysFtrIDOEMSysHideBatteryGauge  = 1;    

// Onscreen keyboard features
  sysFtrTKeyboard               ='keyb';
  sysFtrIDKeyboardActive       = 1;        // Boolean value, true => keyboard is active.
                                           // Currently only used for Japanese.

// Activation status values.
  sysActivateStatusFeatureIndex = 1;    
  sysActivateNeedGeorgeQuery    = 0;    
  sysActivateNeedMortyQuery     = 1;    
  sysActivateFullyActivated     = 2;    

  sysMaxUserDomainNameLength    = 64;   

// Current clipper feature indeces
  sysClipperPQACardNoIndex= 1;    
  sysClipperPQADbIDIndex  = 2;

implementation

end.

