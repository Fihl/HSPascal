/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Localize.h
 *
 * Description:
 *    Functions to localize data.
 *
 * History:
 *    8/28/96  Roger - Initial version
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Localize;

interface


// The number format (thousands separator and decimal point).  This defines
// how numbers are formatted and not neccessarily currency numbers (i.e. Switzerland).
Type
  NumberFormatType = (
    nfCommaPeriod,
    nfPeriodComma,
    nfSpaceComma,
    nfApostrophePeriod,
    nfApostropheComma
  );


Procedure LocGetNumberSeparators(numberFormat: NumberFormatType;
            var thousandSeparator, decimalSeparator: Char);
                     SYS_TRAP(sysTrapLocGetNumberSeparators);

implementation

end.

