/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: DateTime.h
 *
 * Description:
 *    Date and Time calculations
 *
 * History:
 *    1/19/95  rsf - Created by Roger Flores
 *    7/15/99  rsf - moved some types in from Preferences.h
 *   12/23/99  jmp - eliminated bogus maxTime definition
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit DateTime;

interface

Uses {x$ifdef PalmVer35} Traps35, {x$endif}
     Chars;

Type
  TimeFormatType = (
    tfColon,
    tfColonAMPM,         // 1:00 pm
    tfColon24h,          // 13:00
    tfDot,
    tfDotAMPM,           // 1.00 pm
    tfDot24h,            // 13.00
    tfHoursAMPM,         // 1 pm
    tfHours24h,          // 13
    tfComma24h           // 13,00
  );


  DaylightSavingsTypes = (
    dsNone,              // Daylight Savings Time not observed
    dsUSA,               // United States Daylight Savings Time
    dsAustralia,         // Australian Daylight Savings Time
    dsWesternEuropean,   // Western European Daylight Savings Time
    dsMiddleEuropean,    // Middle European Daylight Savings Time
    dsEasternEuropean,   // Eastern European Daylight Savings Time
    dsGreatBritain,      // Great Britain and Eire Daylight Savings Time
    dsRumania,           // Rumanian Daylight Savings Time
    dsTurkey,            // Turkish Daylight Savings Time
    dsAustraliaShifted   // Australian Daylight Savings Time with shift in 1986
  );


// pass a TimeFormatType
//#define Use24HourFormat(t) ((t) == tfColon24h || (t) == tfDot24h || (t) == tfHours24h || (t) == tfComma24h)
//#define TimeSeparator(t) ((Char) ( t <= tfColon24h ? ':' : (t <= tfDot24h ? '.' : ',')))


  DateFormatType = (
    dfMDYWithSlashes,    // 12/31/95
    dfDMYWithSlashes,    // 31/12/95
    dfDMYWithDots,       // 31.12.95
    dfDMYWithDashes,     // 31-12-95
    dfYMDWithSlashes,    // 95/12/31
    dfYMDWithDots,       // 95.12.31
    dfYMDWithDashes,     // 95-12-31

    dfMDYLongWithComma,  // Dec 31, 1995
    dfDMYLong,           // 31 Dec 1995
    dfDMYLongWithDot,    // 31. Dec 1995
    dfDMYLongNoDay,      // Dec 1995
    dfDMYLongWithComma,  // 31 Dec, 1995
    dfYMDLongWithDot,    // 1995.12.31
    dfYMDLongWithSpace,  // 1995 Dec 31

    dfMYMed,             // Dec '95
    dfMYMedNoPost        // Dec 95      (added for French 2.0 ROM)
  );

  DateTimePtr = ^DateTimeType;
  DateTimeType = Record
    second: Int16;
    minute: Int16;
    hour: Int16;
    day: Int16;
    month: Int16;
    year: Int16;
    weekDay: Int16;    //Days since Sunday (0 to 6)
  End;

// This is the time format.  Times are treated as words so don't
// change the order of the members in this structure.
//
  TimePtr = ^TimeType;
  TimeType = Record
    hours: UInt8;
    minutes: UInt8;
  end;

// This is the date format.  Dates are treated as words so don't
// change the order of the members in this structure.
//
  DatePtr = ^DateType;
  DateType = Record
    y7m4d5: UInt16;
    //year  :7;                   // years since 1904 (MAC format)
    //month :4;
    //day   :5;
  end;

/************************************************************
 * Date Time Constants
 *************************************************************/

Const
  noTime = -1;    // The entire TimeType is -1 if there isn't a time.

// Maximum lengths of strings return by the date and time formating
// routine DateToAscii and TimeToAscii.
  timeStringLength   =9;
  dateStringLength   =9;
  longDateStrLength  =15;
  dowDateStringLength   =19;
  dowLongDateStrLength  =25;


  firstYear          =1904;
  numberOfYears      =128;
  lastYear           =firstYear + numberOfYears - 1;  // = 2031

// Constants for time calculations
// Could change these from xIny to yPerX
  minutesInSeconds   =60;
  hoursInMinutes     =60;
  hoursInSeconds     =3600; //(hoursInMinutes * minutesInSeconds); = 3600;
  hoursPerDay        =24;
  //#define daysInSeconds    ((Int32)(hoursPerDay) * ((Int32)hoursInSeconds))
  daysInSeconds      =86400;

  daysInWeek         =7;
  daysInYear         =365;
  daysInLeapYear     =366;
  daysInFourYears    =1461; //(daysInLeapYear + 3 * daysInYear)

  monthsInYear       =12;

  maxDays            = 46751; //((UInt32) numberOfYears / 4 * daysInFourYears - 1)

  //maxSeconds         =4039286400; // ((UInt32) maxDays * daysInSeconds)
  // = 2*$78614F40

  // Values returned by DayOfWeek routine.
  sunday             =0;
  monday             =1;
  tuesday            =2;
  wednesday          =3;
  thursday           =4;
  friday             =5;
  saturday           =6;

// Months of the year
  january            =1;
  february           =2;
  march              =3;
  april              =4;
  may                =5;
  june               =6;
  july               =7;
  august             =8;
  september          =9;
  october            =10;
  november           =11;
  december           =12;


Type
// Values returned by DayOfMonth routine.
  DayOfWeekType = (
    dom1stSun, dom1stMon, dom1stTue, dom1stWen, dom1stThu, dom1stFri, dom1stSat,
    dom2ndSun, dom2ndMon, dom2ndTue, dom2ndWen, dom2ndThu, dom2ndFri, dom2ndSat,
    dom3rdSun, dom3rdMon, dom3rdTue, dom3rdWen, dom3rdThu, dom3rdFri, dom3rdSat,
    dom4thSun, dom4thMon, dom4thTue, dom4thWen, dom4thThu, dom4thFri, dom4thSat,
    domLastSun, domLastMon, domLastTue, domLastWen, domLastThu, domLastFri,
    domLastSat
  );

// Values used by DateTemplateToAscii routine.
Const
  dateTemplateChar               =chrCircumflexAccent;

  (****
  DateTimeXX = (
    dateTemplateDayNum = '0',
    dateTemplateDOWName,
    dateTemplateMonthName,
    dateTemplateMonthNum,
    dateTemplateYearNum
  );
  (****)

  dateTemplateShortModifier     ='s';
  dateTemplateRegularModifier   ='r';
  dateTemplateLongModifier      ='l';
  dateTemplateLeadZeroModifier  ='z';

//************************************************************
//* Date and Time macros
//***********************************************************

// Convert a date in a DateType structure to an UInt16.
// #define DateToInt(date) (*(UInt16 *) &date)


// Convert a date in a DateType structure to a signed int.
// #define TimeToInt(time) (*(Int16 *) &time)



//************************************************************
//* Date Time procedures
//************************************************************

Procedure TimSecondsToDateTime(seconds: UInt32; dateTimeP: DateTimePtr);
         SYS_TRAP(sysTrapTimSecondsToDateTime);

Function TimDateTimeToSeconds(dateTimeP: DateTimePtr): UInt32;
         SYS_TRAP(sysTrapTimDateTimeToSeconds);

Procedure TimAdjust(dateTimeP: DateTimePtr; adjustment: Int32);
         SYS_TRAP(sysTrapTimAdjust);

Procedure TimeToAscii(hours, minutes: UInt8; timeFormat: TimeFormatType;
            pString: pChar);
         SYS_TRAP(sysTrapTimeToAscii);



Function DaysInMonth(month, year: Int16): Int16;
         SYS_TRAP(sysTrapDaysInMonth);

Function DayOfWeek(month, day, year: Int16): Int16;
         SYS_TRAP(sysTrapDayOfWeek);

Function DayOfMonth(month, day, year: Int16): Int16;
         SYS_TRAP(sysTrapDayOfMonth);



// Date routines.
Procedure DateSecondsToDate(seconds: UInt32; date: DatePtr);
         SYS_TRAP(sysTrapDateSecondsToDate);

Procedure DateDaysToDate(days: UInt32; date: DatePtr);
         SYS_TRAP(sysTrapDateDaysToDate);

Function DateToDays(date: DateType): UInt32;
         SYS_TRAP(sysTrapDateToDays);

Procedure DateAdjust(date: DatePtr; adjustment: Int32);
         SYS_TRAP(sysTrapDateAdjust);

Procedure DateToAscii(months, days: UInt8; years: UInt16;
            dateFormat: DateFormatType; pString: pChar);
         SYS_TRAP(sysTrapDateToAscii);

Procedure DateToDOWDMFormat(months, days: UInt8;  years: UInt16;
            dateFormat: DateFormatType; pString: pChar);
         SYS_TRAP(sysTrapDateToDOWDMFormat);

{x$ifdef PalmVer35}
Function DateTemplateToAscii(templateP: pChar;
            months, days: UInt8;
            years: UInt16; stringP: pChar; stringLen: Int16): UInt16;
         SYS_TRAP(sysTrapDateTemplateToAscii);
{x$endif}

implementation

end.

