/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Find.h
 *
 * Description:
 *        This file defines field structures and routines.
 *
 * History:
 *              August 29, 1994 Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Find;

interface

Uses Rect, DataMgr;

Const
  maxFinds        = 9;
  maxFindStrLen   =16;

Type
  FindMatchPtr = ^FindMatchType;
  FindMatchType = Record
    appCardNo: UInt16;         // card number of the application
    appDbID: LocalID;          // LocalID of the application
    foundInCaller: Boolean;    // true if found in app that called Find
    reserved: UInt8;

    dbCardNo: UInt16;          // card number of the database record was found in
    dbID: LocalID;             // LocalID of the database record was found in
    recordNum: UInt16;         // index of record that contain a match
    matchPos: UInt16;          // postion in record of the match.
    matchFieldNum: UInt16;     // field number
    matchCustom: UInt32;       // app specific data
  end;

  FindParamsPtr = ^FindParamsType;
  FindParamsType = Record
    // These fields are used by the applications.
    dbAccesMode: UInt16;       // read mode and maybe show secret
    recordNum: UInt16;         // index of last record that contained a match
    more: Boolean;             // true of more matches to display
    strAsTyped: String[maxFindStrLen]; // search string as entered
    strToFind: String[maxFindStrLen];  // search string is lower case
    reserved1: UInt8;


    // The lineNumber field can be modified by the app. The continuation field can
    // be tested by the app. All other fields are private to the Find routine and
    // should NOT be accessed by applications.
    numMatches: UInt16;       // # of matches
    lineNumber: UInt16;       // next line in the results tabel
    continuation: Boolean;     // true if contining search of same app
    searchedCaller: Boolean;   // true after we've searched app that initiated the find

    callerAppDbID: LocalID;    // dbID of app that initiated search
    callerAppCardNo: UInt16;  // cardNo of app that initiated search

    appDbID: LocalID;          // dbID of app that we're currently searching
    appCardNo: UInt16;        // card number of app that we're currently searching

    newSearch: Boolean;        // true for first search
    reserved2: UInt8;
    searchState: DmSearchStateType;   // search state
    match: Array [0..maxFinds-1] of FindMatchType;
  end;

  // Param Block passsed with the sysAppLaunchCmdGoto Command
  GoToParamsPtr = ^GoToParamsType;
  GoToParamsType = Record
    searchStrLen: Int16;     // length of search string.
    dbCardNo: UInt16;         // card number of the database
    dbID: LocalID;             // LocalID of the database
    recordNum: UInt16;        // index of record that contain a match
    matchPos: UInt16;         // postion in record of the match.
    matchFieldNum: UInt16;    // field number string was found int
    matchCustom: UInt32;         // application specific info
  end;

//----------------------------------------------------------
// Find Functions
//----------------------------------------------------------

Procedure Find(goToP: GoToParamsPtr);
         SYS_TRAP(sysTrapFind);

Function FindStrInStr(Const strToSearch, strToFind: String; var posP: UInt16): Boolean;
         SYS_TRAP(sysTrapFindStrInStr);

Function FindSaveMatch(var findParams: FindParamsType; recordNum: UInt16;
   pos, fieldNum: UInt16; appCustom: UInt32; cardNo: UInt16; dbID: LocalID): Boolean;
         SYS_TRAP(sysTrapFindSaveMatch);

Procedure FindGetLineBounds(var findParams: FindParamsType; var r: RectangleType);
         SYS_TRAP(sysTrapFindGetLineBounds);

Function FindDrawHeader(var findParams: FindParamsType; Const title: String): Boolean;
         SYS_TRAP(sysTrapFindDrawHeader);

implementation

end.

