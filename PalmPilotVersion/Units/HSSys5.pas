Unit HSSys5;  //Float

//Include following line if Floating are not wanted at all
//Interface Implementation end.

{ By Christen Fihl                     }
{ Copyright (C) 1990,2001 Christen Fihl}

(*******************************************************************************
Floating point, single format
SEEEEEEEE EMMMMMMM MMMMMMMM MMMMMMMM
3F 80 00 00 =    1.000
$42996CE8 = 0 10000101 00110010110110011101000
Mantissa 1 00110010110110011101000     => 1.1986360549927
Exponent 10000101 = 133. Biased by 127 => 6
Sign     0                             => 0
Total: 1.1986360549927 *2^6            => 76.71270752
(******************************************************************************)

{$D-,R-,S-}
{$MakeHelp-}

interface

Const
  MinSingle= 1.5e-45;
  MaxSingle= 3.4e+38;

  PI= 3.141592653; //$40490FDB
  AsRadians = 0.017453293;        //2*pi/360

procedure RLd;  Assembler; NoA6Frame; SysProc FRealLoadI;
procedure RAdd; Assembler; NoA6Frame; SysProc FRealAdd;
procedure RSub; Assembler; NoA6Frame; SysProc FRealSub;
procedure RMul; Assembler; NoA6Frame; SysProc FRealMul;
procedure RDiv; Assembler; NoA6Frame; SysProc FRealDiv;
procedure RCmp; Assembler; NoA6Frame; SysProc FRealCmp; //Real compare MUST return both D0 and flags set as after "TST.B D0"

function  FAbsR(F: Real): Real; Assembler; NoA6Frame; SysProc FSysAbsR;
function  FNegR(F: Real): Real; Assembler; NoA6Frame; SysProc FSysNegR;
function  FSqr(F: Real): Real; Assembler; NoA6Frame; SysProc FSysSqr;

function  FTrunc(F: Real): Longint; Assembler; NoA6Frame; SysProc FSysTrunc;
function  FInt(F: Real): Real; Assembler; NoA6Frame; SysProc FSysInt;
function  FRound(F: Real): Longint; Assembler; NoA6Frame; SysProc FSysRound;

function  FArcTan(X: Real): Real; SysProc FSysArcTan;
function  FSqrt(X: Real): Real; SysProc FSysSqrt;
function  FSin(X: Real): Real; SysProc FSysSin;
function  FCos(X: Real): Real; SysProc FSysCos;
function  FLn(X: Real): Real; SysProc FSysLN;
function  FExp(X: Real): Real; SysProc FSysExp;

procedure StrReal(var S: String; VAR R: Real; VAR Pos: SmallInt); Assembler; SysProc PSysValR;
procedure RealStr(R: Real; W,D: SmallInt; var S: String; LenOfS: SmallInt); SysProc ISysStringR;

//Utilities
Function IntPower(X: Real; I: Integer): Real;

implementation

Uses HSUtils, FloatMgr;

{ *******************************************************}
{ *                                                     *}
{ *     FLOATING POINT ROUTINES                         *}
{ *                                                     *}
{ *******************************************************}

//Input params on stack, no space for return val. Make it yourself

procedure RLd; Assembler; NoA6Frame; SysProc FRealLoadI;
ASM     MOVE.L  4(SP),-(SP)
        moveq   #sysFloatEm_f_itof,d2
        SysTrap sysTrapFlpEmDispatch
        ADDQ.L  #4,SP
        MOVE.L  D0,4(SP)                //Reuse space on stack
END;

procedure RAdd; Assembler; NoA6Frame; SysProc FRealAdd;
ASM     move.l  8(sp),-(SP)
        move.l  8(sp),-(SP)
        moveq   #sysFloatEm_f_add,d2
        SysTrap sysTrapFlpEmDispatch
        addq.l  #8,sp
        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

procedure RSub; Assembler; NoA6Frame; SysProc FRealSub;
ASM     move.l  4(sp),-(SP)
        move.l  12(sp),-(SP)
        moveq   #sysFloatEm_f_sub,d2
        SysTrap sysTrapFlpEmDispatch
        addq.l  #8,sp
        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

procedure RMul; Assembler; NoA6Frame; SysProc FRealMul;
ASM     move.l  8(sp),-(SP)
        move.l  8(sp),-(SP)
        moveq   #sysFloatEm_f_mul,d2
        SysTrap sysTrapFlpEmDispatch
        addq.l  #8,sp
        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

procedure RDiv; Assembler; NoA6Frame; SysProc FRealDiv;
ASM     move.l  4(sp),-(SP)
        move.l  12(sp),-(SP)
        moveq   #sysFloatEm_f_div,d2
        SysTrap sysTrapFlpEmDispatch
        addq.l  #8,sp

        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

procedure RCmp; Assembler; NoA6Frame; SysProc FRealCmp;
ASM     movem.l (sp)+,d0/d1/a0
        exg     d0,a0
        move.l  d0,d2
        and.l   d1,d2
        bpl     @Diff
        exg     d0,d1
        moveq   #31,d2
        bclr    d2,d0
        bclr    d2,d1
@Diff:  cmp.l   d1,d0
        jmp     (a0)
END;

function FAbsR(F: Real): Real; Assembler; NoA6Frame; SysProc FSysAbsR;
ASM     BCLR    #7,4(SP)        //Remove Sign
END;
function  FNegR(F: Real): Real; Assembler; NoA6Frame; SysProc FSysNegR;
ASM     EOR.B   #$80,4(SP)      //Flip Sign
END;

//FplFToA, FplFloatToLong, FplAToF
function FTrunc(F: Real): Longint; Assembler; NoA6Frame; SysProc FSysTrunc;
ASM     MOVE.L  4(SP),-(SP)
        moveq   #sysFloatEm_f_ftoi,d2   //N:=R
        SysTrap sysTrapFlpEmDispatch
        ADDQ.L  #4,SP
        MOVE.L  D0,4(SP)
END;

function FInt(F: Real): Real; Assembler; NoA6Frame; SysProc FSysInt;
ASM     MOVE.L  4(SP),-(SP)
        moveq   #sysFloatEm_f_ftoi,d2 //N:=R (trunc)
        SysTrap sysTrapFlpEmDispatch
        MOVE.L  D0,(SP)
        moveq   #sysFloatEm_f_itof,d2   //R:=N
        SysTrap sysTrapFlpEmDispatch
        ADDQ.L  #4,SP
        MOVE.L  D0,4(SP)
END;

function FRound(F: Real): Longint; Assembler; NoA6Frame; SysProc FSysRound;
ASM     MOVE.L  4(SP),D0
        MOVE.L  D0,-(SP)
        AND.L   #$80000000,D0            //Sign
        OR.L    #$3F000000,D0            //+/- 0.5
        MOVE.L  D0,-(SP)
        moveq   #sysFloatEm_f_add,d2
        SysTrap sysTrapFlpEmDispatch
        addq.l  #8,sp
        MOVE.L  D0,-(SP)                 //Trunc(F+0.5) or Trunc(F-0.5)
        moveq   #sysFloatEm_f_ftoi,d2   //N:=R
        SysTrap sysTrapFlpEmDispatch
        ADDQ.L  #4,SP
        MOVE.L  D0,4(SP)
END;

function FSqr(F: Real): Real; Assembler; NoA6Frame; SysProc FSysSqr;
ASM     MOVE.L  4(SP),-(SP)
        MOVE.L  (SP),-(SP)
        moveq   #sysFloatEm_f_mul,d2
        SysTrap sysTrapFlpEmDispatch
        ADDQ.L  #8,SP
        MOVE.L  D0,4(SP)
END;


//ArcTan, Hart et al 4900, p. 129 (8.40)
function FArcTan(X: Real): Real; SysProc FSysArcTan;
Function Series(X: Single): Single;
var xx: Single;
begin
  xx:=Sqr(x); //Hart et al 4900
  Series:=x*((0.197939543*xx-0.33332586045)*xx+0.9999999959792);
end;
Function Ser2(Add,tan: Single): Single;
begin
  Ser2:=Add+Series((x-tan)/(1.0+x*tan));
end;
var Sign: Boolean; XI: Longint;
begin
  Sign:=X<0; X:=Abs(X);
  ASM move X,XI end; //move(X,XI,SizeOf(XI));
  case XI of //tan(1,3,5,7,9,11,13,15 * PI/32)
  $00000000..$3DC9B5DC: x:=Series(x);
  $3DC9B5DE..$3E9B5042: x:=Ser2(0.19634954085,0.198912375114); //1*pi/16, tan(2*pi/32)
  $3E9B5043..$3F08D5B9: x:=Ser2(0.39269908170,0.414213600586); //2*pi/16, tan(4*pi/32)
  $3F08D5BA..$3F521801: x:=Ser2(0.58904862255,0.668178665632); //3*pi/16, tan(6*pi/32)
  $3F521802..$3F9BF7EC: x:=Series((x-1.0)/(x+1.0))+0.7853981634; //pi/4
  $3F9BF7ED..$3FEF789E: x:=Ser2(0.98174770425,1.496605700595); //5*pi/16, tan(10*pi/32)
  $3FEF789F..$4052FACF: x:=Ser2(1.17809724510,2.414213527663); //6*pi/16, tan(12*pi/32)
  $4052FAD0..$41227363: x:=Ser2(1.37444678590,5.027338528655); //7*pi/16, tan(14*pi/32)
  else                  x:=1.5707963268 - Series(1/x);         //pi/2
  end;
  if Sign then x:=-x;
  //Result:=x;   //NOT needed as @x=@Result
end;

function FSqrt(X: Real): Real; SysProc FSysSqrt;
var Exp: Integer; xX1: Single; X00,X0,X1: Longint; ExpO: Boolean;
  procedure SqrInt; //X1=1/2 (X1+X0/X1)  = 1/2X1 + X0/2/X1
  begin
    X1:=((X1 shr 1) +((X0 shr 1) div (X1 shr 16)));
    X00:=Longint(Exp+127) shl 23+ ((X1 shr 8) and $007FFFFF);
    Move(X00,xX1,SizeOf(xX1));
  end;

procedure SqrFloat;
begin
  xX1:=0.5* (xX1 +X/xX1)
end;
begin
  if X<=0.0 then begin FSqrt:=0.0; EXIT end;
  ASM move X,X0 end; //Move(X,X0,SizeOf(X0));
  X1:=X0;
  Exp:=Integer(X1 shr 23)-127;
  ExpO:=Odd(Exp);
  Exp:=Exp div 2;
  X1:=X1 and $007FFFFF + $00800000;
  X1:=((X1 shr 8)*$9300 + $6CFF0000);  //1th   0.5 < X1 < 1.0 !
  SqrInt;
  SqrInt;
  if ExpO then begin
    Inc(Exp);
    X1:=(X1 shr 16)*46340;             //X1:=X1*SQRT(2)/2
    //if ($80000000 and X1)=0 then begin
    if not Odd(X1 shr 31) then begin
      Dec(Exp); X1:=X1 shl 1
    end;
  end;
  //if $80000000 and X1=0 then begin Dec(Exp); X1:=X1 shl 1 end; //why not!!!!
  X0:=Longint(Exp+127) shl 23+ ((X1 shr 8) and $007FFFFF);
  ASM move X0,xX1 end; //Move(X0,xX1,SizeOf(xX1));
  SqrFloat;
  SqrFloat;
  SqrFloat;
  SqrFloat;
  FSqrt:=xX1;
end;

// Sin, Hart et al, 3341, p. 117 (8.27)
function FSin(X: Real): Real; SysProc FSysSin;
var xx: Single; Sign: Boolean;
begin
  Sign:=X<0; X:=Abs(X);
  x:=X*0.15915494309; //  x:=x/(pi/2)/4 !  =>    0->2pi => 0.000->1.000
  x:=4*(x-int(x));    // => x:=4.0*frac(x/4.0);  0->2pi => 0.000->4.000
  if x>=3 then x:=x-4 else if x>=1 then x:=2-x;
  xx:=Sqr(x);
  x:=x*((((0.000151485129
      *xx-0.00467376661)
      *xx+0.07968967895)
      *xx-0.6459637106)
      *xx+1.57079631844);
  if Sign then x:=-x;
  // Result:=x;   //NOT needed as @x=@Result
end;
function FCos(X: Real): Real; SysProc FSysCos;   // SysProc, then no return space on stack!!
begin
  FCos:=Sin(1.5707963268+x);   // Pi/2+x
end;

//Ln, Hart et al, 2662, p. 111 (9.92)
function FLn(X: Real): Real; SysProc FSysLN;
var Exp: Integer; z,zz: Single; X1: Longint;
begin
  if X<=0.0 then begin FLn:=0.0; EXIT end;
  ASM move X,X1 end; //Move(X,X1,SizeOf(X1));
  Exp:=Integer(X1 shr 23)-126;
  X1:=(X1 and $007FFFFF) or $3F000000; //exp:=exp(x); exp(x):=-1; (½..1)
  ASM move X1,X end; //Move(X1,X,SizeOf(X));
  if X1<$3F3504F3 then begin Dec(Exp); x:=x*2 end; //sqrt(½)= 0.707106769085; =$3F3504F3;
  z:=(x-1)/(x+1); zz:=sqr(z);
  FLn:=Exp*0.693147182465                                                   //*ln(2)=$3F317218
       +z*(((0.301003281*zz+0.3996579492)*zz+0.6666694845)*zz+1.999999994); //2662
end;

//Exp, Hart et al, 1022, p. 102 (8.93)
//Exp:=2**n*F(x');
function FExp(X: Real): Real; SysProc FSysExp;
var n: Integer;
begin
  if X<0.0 then begin FExp:=1/Exp(-X); EXIT end;
  x:=X*1.4426950369;    //x:=x/ln(2)   => 0..½
  n:=Round(x); x:=x-n;  //if n>127 then INF!!
  FExp:=IntPower(2.0,n)*
        (((((0.001583936553*x+0.009475173858)*x+0.05554097231)*x+
             0.2402222612)*x+0.6931473573)*x+0.9999999988);
end;



//Raise X to integer power I.  Result:= X**I
Function IntPower(X: Real; I: Integer): Real;
var
  Result: Real;
begin
  if I<0 then begin IntPower:=1.0/IntPower(X,-I); EXIT end;
  Result := 1.0;
  while I>0 do begin
    while not Odd(I) do begin //Quick version
      I:=I shr 1; X:=Sqr(X);
    end;
    Dec(I);
    Result:=Result * X
  end;
  IntPower:= Result
end;

{ *******************************************************}
{ *                                                     *}
{ *     VAL/STR ROUTINE                                 *}
{ *                                                     *}
{ *******************************************************}

procedure StrReal(var S: String; VAR R: Real; VAR Pos: SmallInt); Assembler; SysProc PSysValR;
var D: Double;
ASM     MOVE.L  S,-(SP)
        PEA     D
        MOVEQ   #sysFloatAToF,D2
        //SysTrap StrVPrintF
        SysTrap sysTrapFlpDispatch //FlpDouble FlpAToF(Char* s) FLOAT_TRAP(sysFloatAToF);
        //_d_dtof(var D: Double): Real; Assembler;
        JSR     _d_dtof                 //D still on stack!
        MOVE.L  (SP)+,D0
        MOVE.L  R,A0
        MOVE.L  D0,(A0)
        MOVE.L  Pos,A0
        CLR.W   (A0)                    //What to return??
END;

//Total field width=W
//Dec=-1 then [ <blanks> ] [ - ] <digit> . <decimals> E [ + | - ] <exponent>
//       else [ <blanks> ] [ - ] <digits> [ . <decimals> ]
procedure RealStr(R: Real; W,D: SmallInt; var S: String; LenOfS: SmallInt); SysProc ISysStringR;
var
  N,Exp,Exp2,Sgn,Comma,PreZero,Len,Digits,UseDigits,DoneDec: Integer;
  Done: Boolean;
  Res,Man: String;
  Man32: UInt32;
  DReal: Double;
Procedure Add(Ch: Char);
begin
  if Done then Exit;
  if Comma=0 then Res:=Res+'.';
  Res:=Res+Ch;
  Dec(Comma);
  Done:= Comma<=DoneDec;
end;
begin
  _f_ftod(R,DReal);
  ASM   PEA     Sgn
        PEA     Exp
        PEA     Man32
        MOVE.L  DReal+4,-(SP)
        MOVE.L  DReal+0,-(SP)
        moveq   #sysFloatBase10Info,d2
        SysTrap sysTrapFlpDispatch //No EM!!
        MOVE.L  Man32,-(SP)
        PEA     Man
        SysTrap StrIToA                 //P647
        add     #4+4+4+8+4+4,sp
  End;
  Len:=Length(Man);
  Done:=False;
  if d<0 then begin w:=Max(8,w); Digits:=w-6; DoneDec:=-(Digits-1) end
  else        begin Digits:=d+Max(0,Min(Len,Len+Exp)); DoneDec:=-d end;
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
  PreZero:=0; Comma:=Digits+Exp;
  if (Man32=0) or (d<0) then Comma:=1
  else
    if Comma<=0 then begin
      PreZero:=1-Comma; //1 extra
      Comma:=1;
    end;
  if Sgn=0 then Res:='' else Res:='-';
  for N:=1 to PreZero do Add('0');
  for N:=1 to Min(Digits,UseDigits) do Add(Man[N]);
  while not Done do Add('0');
  if d<0 then begin
    Str(Abs(Exp2):2,Man); Comma:=100; Done:=False;
    for N:=1 to Length(Man) do if Man[N]=' ' then Man[N]:='0';//!!
    Add('E'); if Exp2>=0 then Add('+') else Add('-');
    for N:=1 to Length(Man) do Add(Man[N]);
  end;
  _PadNMoveStr(Res,S,W,LenOfS); //S:=Res;
end;

end.

