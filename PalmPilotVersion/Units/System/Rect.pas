/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Rect.h
 *
 * Description:
 *   This file defines rectangle structures and routines.
 *
 * History:
 *    November 3, 1994  Created by Roger Flores
 *       Name  Date     Description
 *       ----  ----     -----------
 *       bob   2/9/99   Use Coord abstraction, fix up consts
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Rect;

interface

Type
  AbsRectType= Record
    left, top, right, bottom: Coord
  end;

  PointType= Record
    x,y: Coord
  end;

  RectanglePtr= ^RectangleType;
  RectangleType= Record
    topLeft, extent: PointType
  end;

Procedure RctSetRectangle(var rP: RectangleType; left, top, width, height: Coord);
  CDECL; SYS_TRAP(sysTrapRctSetRectangle);

Procedure RctCopyRectangle(var srcRectP, dstRectP: RectangleType);
  CDECL; SYS_TRAP(sysTrapRctCopyRectangle);

Procedure RctInsetRectangle(var rP: RectangleType; insetAmt: Coord);
  CDECL; SYS_TRAP(sysTrapRctInsetRectangle);

Procedure RctOffsetRectangle(var rP: RectangleType; deltaX, deltaY: Coord);
  CDECL; SYS_TRAP(sysTrapRctOffsetRectangle);

Function RctPtInRectangle(x,y: Coord; var rP: RectangleType): Boolean;
  CDECL; SYS_TRAP(sysTrapRctPtInRectangle);

Procedure RctGetIntersection(var r1P, r2P, r3P: RectangleType);
  CDECL; SYS_TRAP(sysTrapRctGetIntersection);

implementation

end.
