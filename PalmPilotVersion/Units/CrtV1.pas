//Version 1 of Crt unit
unit CrtV1;

interface

Procedure Write(Const S: String);
Procedure Writeln(Const S: String);
Procedure WriteFixed(Const S: String);
Procedure GotoXY(X,Y: Integer);
Procedure ClrScr;
Procedure Delay(ms: Integer);

implementation

Uses
  Window, Rect, SystemMgr, HSUtils;

Const
  MaxX = 16;
  MaxY = 16;
  Size = 10; //Total 160*160
Type
  PScrBuf = ^TScrBuf;
  TScrBuf= Array[1..MaxX, 1..MaxY] of Char;

Var
  ScrBuf: PScrBuf;
  R: RectangleType;
  WhereX,WhereY: Integer;
  CrtEcho: Boolean;

Procedure CalcR;
begin
  WhereX:=Max(1,WhereX);
  WhereY:=Max(1,WhereY);
  RctSetRectangle(R, Size*(WhereX-1), Size*(WhereY-1), Size, Size); //LTWH
end;

Procedure Wr1(Ch: Char);
begin
  CalcR;
  WinDrawChars(Ch, 1, R.TopLeft.X, R.TopLeft.Y);
  Inc(WhereX);
end;

Procedure Write(Const S: String);
var N: Integer;
begin
  CalcR;
  N:=Length(S);
  WinDrawChars(S, N, R.TopLeft.X, R.TopLeft.Y);
  Inc(WhereX,N);
end;

Procedure Writeln(Const S: String);
var Y: Integer;
begin
  Write(S);
  WhereX:=1;
  Inc(WhereY);
  if WhereY>MaxY then begin
    for WhereY:=2 to MaxY do begin
      CalcR;
      R.Extent.X:=R.Extent.X*MaxX;
      WinCopyRectangle(NIL,NIL, R, R.TopLeft.X, R.TopLeft.Y-Size, winPaint);
    end;
    WinEraseRectangle(R,0); // Erase last line
    WhereY:=MaxY;
  end;
end;

Procedure WriteFixed(Const S: String);
var N: Integer;
begin
  for N:=1 to Length(S) do Wr1(S[N]);
end;

Procedure GotoXY(X,Y: Integer);
begin
  WhereX:=X; WhereY:=Y;
end;

Procedure ClrScr;
begin
  GotoXY(1,1); CalcR;
  R.Extent.X := R.Extent.X*MaxX;
  R.Extent.Y := R.Extent.Y*MaxY;
  WinEraseRectangle(R,0);
end;

Procedure Delay(ms: Integer);
var N: Integer;
begin
  N:=SysTaskDelay(ms * SysTicksPerSecond div 1000);
end;

begin
//  New(ScrBuf);
//  FillChar(ScrBuf^,SizeOf(ScrBuf^),' ');
end.

