Unit Crt;
//Version 2 of Crt

//Enhanced by Ken Pemberton to use proportional fonts etc.

(*
An enhancement on Christen's CRT unit. Allows for line-wrapping so that overrun text is not truncated.

TO-DO:
======

Because of dealing with variable-sized characters, the WhereX function (and almost certainly WhereY once
we start with anything other than the default font), while MAINTAINED by this code for it's own purposes,
is useless as a point of reference. Still to be done: reverse-maintenance of WhereX (and WhereY later), based
on nearest whole character position to current pixel position. Something along the lines of (WhereXPixel div SizeX)+1, I think. Not a biggie, but I don't need it right now. Once done, also move WhereX and WhereY into the
interface. For now, though, they are safer where they are, as we'd rather not have app programmers trying to
use them and get confused.

Replace const MaxXPixel with OS lookup/query.

*)



interface

Procedure Write(Const S: String);
Procedure Writeln(Const S: String);
Procedure WriteFixed(X,Y: Integer; Const S: String);
Procedure GotoXY(X,Y: Integer);
Procedure ClrScr;
Procedure Delay(ms: Integer);

var
  WhereX,WhereY: Integer; //Not exact

implementation

Uses
  Window, Rect, SystemMgr, HSUtils, Font;

Const
  MaxX = 20;
  MaxXPixel = 160;  // replace this with system-lookup!
  MaxY = 16;
  SizeX= 08;
  SizeY= 10; // 10 drops off below-cursor parts of lower-case letters g,y,p,q,jj
  Size = 10; //Total 160*160
Var
  R: RectangleType;
  WhereXPixel: integer;
  CrtEcho: Boolean;

Procedure CalcR;
begin
  WhereX:=Max(1,WhereX);
  WhereY:=Max(1,WhereY);
  RctSetRectangle(R, WhereXPixel, SizeY*(WhereY-1), SizeX, SizeY); //LTWH
end;

procedure DoWrap;
begin
  WhereX := 0;
  WhereXPixel := 0;
  inc(WhereY);
  if WhereY>MaxY then begin
    for WhereY:=2 to MaxY do begin
      CalcR;
      R.Extent.X:=R.Extent.X*MaxX;
      WinCopyRectangle(NIL,NIL, R, R.TopLeft.X, R.TopLeft.Y-SizeY, winPaint);
    end;
    WinEraseRectangle(R,0); // Erase last line
    WhereY:=MaxY;
  end;
end;

procedure CheckWrap;
begin
  if WhereXPixel>(MaxXPixel-SizeX) then
    DoWrap;
end;

Procedure Wr1(Ch: Char; Fixed: Boolean);
begin
  CalcR;
  if Fixed then WinDrawChars(Ch, 1, R.TopLeft.X, R.TopLeft.Y);
  WinDrawChar(ord(Ch), R.TopLeft.X, R.TopLeft.Y);
  Inc(WhereX);
  if Fixed then Inc(WhereXPixel,SizeX)
  else          Inc(WhereXPixel,FntCharWidth(Ch));
  CheckWrap;
end;

Procedure Write(Const S: String);
var n: integer;
begin
  for n:=1 to length(s) do
    Wr1(s[n], False);
end;

Procedure Writeln(Const S: String);
var Y: Integer;
begin
  Write(S);
  DoWrap;
end;

Procedure WriteFixed(X,Y: Integer; Const S: String);
begin
  gotoxy(X,Y);
  for X:=1 to Length(S) do
    Wr1(S[X],True);
end;

Procedure GotoXY(X,Y: Integer);
begin
  WhereX:=X;
  WhereY:=Y;
  WhereXPixel:= ((X-1)*SizeX);  // is there a better way of doing this?
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

end.
