program FPTest;
{$APPTYPE CONSOLE}

Uses Math;

Var
  gMan: String; gExp,gSgn: Integer;
procedure MoveResStr(var FromS,ToS: String; Width,MaxLen: Integer);
begin
  While Width>Length(FromS) do Insert(' ',FromS,1);
  ToS:=FromS;
end;

//d=-1: Min=+2e+33(6=1d), Max=+1.23456789e+12(15=10d)
//d=n:  Min='1', Max='123.123123123123'/'0.0000012345678'
//12340000  -5   8  2   ' +123.40'
//12340000 -25   8  2   '   +0.00'
//12340000  -8   8  2   '   +0.12'
Procedure Dmp(R: Double; w,d: Integer; Var S: String; LenOfS: Integer);
var
  N,Exp,Exp2,Sgn,Comma,PreZero,Len,Digits,UseDigits,DoneDec: Integer;
  Done: Boolean;
  Res,Man: String;
Procedure Add(Ch: Char);
begin
  if Done then Exit;
  if Comma=0 then Res:=Res+'.'; Dec(Comma);
  Res:=Res+Ch;
  Done:= Comma<=DoneDec;
end;
begin
  Man:=gMan; Exp:=gExp; Sgn:=gSgn; //////////
  Len:=Length(Man);
  Done:=False;
  if d<0 then begin
    w:=Max(8,w); Digits:=w-6; DoneDec:=-(Digits-1);
  end else begin
    Digits:=d+Max(0,Min(Len,Len+Exp)); DoneDec:=-d;
  end;
  UseDigits:=Len;
  if Digits<Len then begin
    if Man[Digits+1]>='5' then begin
      for N:=Digits downto 1 do begin
        Inc(Man[N]);
        if Man[N]<='9' then BREAK;
        Man[N]:='0';
        if N=1 then begin  //9997 => 10000 => 1000
          Man[1]:='1'; Inc(Len);
        end;
      end;
    end;
    UseDigits:=Digits;
  end;
  Exp2:=Len+Exp-1;
  Inc(Exp,Len-Digits);
  PreZero:=0;
  Comma:=Digits+Exp;
  if (R=0) or (d<0) then Comma:=1
  else
    if Comma<=0 then begin
      PreZero:=1-Comma; //1 extra
      Comma:=1;
    end;
  if Sgn>0 then Res:='' else Res:='-';
  for N:=1 to PreZero do Add('0');
  for N:=1 to Min(Digits,UseDigits) do Add(Man[N]);
  while not Done do Add('0');
  if d<0 then begin
    Str(Abs(Exp2):2,Man); Comma:=100; Done:=False;
    for N:=1 to Length(Man) do if Man[N]=' ' then Man[N]:='0';//!!
    Add('E'); if Exp2>=0 then Add('+') else Add('-');
    for N:=1 to Length(Man) do Add(Man[N]);
  end;
  MoveResStr(Res,S,W,LenOfS); //S:=Res;
end;

procedure Dmp2(R: Double; Man: Longint; Exp: Integer; w,d,Sgn: Integer);
var Res: String;
begin
  Str(Man,gMan); gExp:=Exp; gSgn:=Sgn;
  Dmp(R,w,d,Res,100);
  Writeln('>',Res,'*');
  Writeln('.',R:w:d,'*');
end;

var w,d: Integer;
begin
  w:=10; d:=2;
  Dmp2(0.9976543,9976543, -7,w,d,1);
  Dmp2(0.0,0, 1, w,d,1);
  Dmp2(0.3,30000001, -8, w,d,1);

  Dmp2(999.9999990,999999990, -6, w,d,1);
  Dmp2(123.4567890,1234567890,-7, w,d,1);
  Dmp2(0.001234567890,1234567890,-12, w,d,1);
  Dmp2(-0.001234567890,1234567890,-12, w,d,0);
  Dmp2(222.2222220,222222220, -6, w,d,1);

  //Writeln(0.001234567:w:d);
  //Writeln(-0.001234567:w:d);
  //Writeln(123.4567:w:d);
  //Writeln(-123.4567:w:d);
  writeln(pi);
  Readln;
(*******************************************************************************
Str(R[: Width [: Decimals ] ], Str)

The format of the representation depends on the presence of Decimals.

If Decimals is omitted or negative, a floating-point decimal string is written.
If Width is omitted or less than 8, a default Width of 8 is assumed.

The format of the floating-point string is

[ <blanks> ] [ - ] <digit> . <decimals> E [ + | - ] <exponent>

The following table lists the components of the output string.

If Decimals is present, a fixed-point decimal string is written.
The format of the fixed-point string follows:

[ <blanks> ] [ - ] <digits> [ . <decimals> ]

*******************************************************************************)
end.