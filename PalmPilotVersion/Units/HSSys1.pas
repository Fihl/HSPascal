Unit HSSys1;

interface

{$ifNdef HSLibrary}
// $R does not work in HSSys1.pas for library's. But every other place.
{$R $(exe)\tAIB03e8.bin}
{$R $(exe)\tAIB03e9.bin}
{$endif}

Const // SysProc #'s
  ISysInit        = 01;
  ISysTerm        = 02;
  ISysHalt        = 03;
  PSysMemInit     = 04;
  PSysMemGet      = 05;
  PSysMemFree     = 06;
  FSysMemAvail    = 07;
  FSysMemMaxAvail = 08;
  ISysOptStack    = 09;
  ISysOptRangeL   = 10;
  ISysOptRangeW   = 11;
  PSysRandomize   = 12;

  ISysInitLib     = 13;
  ISysTermLib     = 14;

  PSysMove        = 15;
  PSysFillChar    = 16;
  PSysCase        = 17;
  PSysPCopy       = 18;

  ISysStrLd       = 20;
  ISysStrSto      = 21;
  //ISysStrLdChar   = 22;
  ISysStrCmp      = 23;
  ISysStrAdd      = 24;
  FSysStrCopy     = 25;
  FSysStrPos      = 26;
  PSysStrIns      = 27;
  PSysStrDel      = 28;
  FSysUpCase      = 29;
  FSysStrLen      = 30;
  FSysStrPosCh    = 31;

  PSysValI        = 35;
  PSysValR        = 36;
  ISysStringI     = 37;
  ISysStringR     = 38;

  ISysSetLd       = 40;
  ISysSetLdZero   = 41;
  ISysSetAdd1     = 42;
  ISysSetAddN     = 43;
  ISysSetSto      = 44;
  ISysSetIn       = 45;
  ISysSetEQ       = 46;
  ISysSetGE       = 47;
  ISysSetLE       = 48;
  ISysSetUnion    = 49;
  ISysSetDiff     = 50;
  ISysSetInter    = 51;

  ISys32Mul       = 60;
  ISys32Sqr       = 61;
  ISys32Div       = 62;
  ISys32Mod       = 63;

  FSysAbs16       = 64;
  FSysAbs32       = 65;

  FSysNegR        = 70; //Real:= -Real;
  FSysAbsR        = 71; //Abs(Real): Real;
  FSysTrunc       = 72; //Trunc(Real): Longint;
  FSysInt         = 73; //Int(Real): Real;
  FSysRound       = 74; //Round(Real); Longint;
  FSysArcTan      = 75; //ArcTan(Real): Real;
  FSysSqr         = 76; //Sqr(Real): Real;
  FSysSqrt        = 77; //Sqrt(Real): Real;
  FSysSin         = 78; //Sin(Real): Real;
  FSysCos         = 79; //Cos(Real): Real;
  FSysLN          = 80; //Ln(Real): Real;
  FSysExp         = 81; //Exp(Real): Real;
  FSysRandomI     = 82; //Random(Integer): Integer;
  FSysRandomR     = 83; //Random: Real;  //Special, no SyDefault

  FRealLoadI      = 84;
  FRealAdd        = 85;
  FRealSub        = 86;
  FRealMul        = 87;
  FRealDiv        = 88;
  FRealCmp        = 89;

implementation

End.
