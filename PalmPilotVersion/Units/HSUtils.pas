unit HSUtils;

interface

Function Min(a,b: Integer): Integer;
Function Max(a,b: Integer): Integer;
Function i2s(I: Integer): String; // Integer2String (16 bit)
Function l2s(I: Longint): String; // Long2String (32 bit)
Function r2s(R: Real): String;    // Real2String (Single)
Function s2i(const S: String): Longint;

function s2u32(Const S: String): UInt32; Assembler;
Procedure StringByIndex(var S: PChar; Index: Integer);

//----------------------------------------------
//   Author : Chris Burrows, CFB Software
const
  V100 = $01003001;
  V200 = $02003000;
  V300 = $03003000;
  V310 = $03103000;
  V320 = $03203000;
  V330 = $03303000;
  V350 = $03503001;
  V351 = $03513000;
function VersionSupported(MinVersion: UInt32): boolean;
//----------------------------------------------

Var
  // Can be used as "NilStringPtr^" where a NIL is required
  // as in PwdSet('Oldpassword', NilStringPtr^);
  NilStringPtr: ^String;

  NilInt16:  ^Int16;
  NilInt32:  ^Int32;
  NilUInt32: ^UInt32;

implementation

Uses
  FeatureMgr, SystemMgr;

Function Min(a,b: Integer): Integer;
begin
  if a<b then Min:=a else Min:=b
end;

Function Max(a,b: Integer): Integer;
begin
  if a>b then Max:=a else Max:=b
end;

Function i2s(I: Integer): String; // Integer2String (16 bit)
var S: String;
begin
  Str(I,S);
  i2s:=S;
end;

Function l2s(I: Longint): String; // Long2String (32 bit)
var S: String;
begin
  Str(I,S);
  l2s:=S;
end;

Function r2s(R: Real): String; // Real2String (Single)
var S: String;
begin
  Str(R,S);
  r2s:=S;
end;

Function s2i(const S: String): Longint;
var rc: Integer; res: Longint;
begin
  Val(S,res,rc);
  s2i:=res;
end;

// Remember to use function s2u32(Const S: String): UInt32 as defined in HSUtils
// Use it as: x:=FtrPtrNew(s2u32('TEST'), 123, 8, MyPointer);

function s2u32(Const S: String): UInt32; Assembler;
ASM     move.l  S,a0
        move.l  (a0),12(a6)
end;

Procedure StringByIndex(var S: PChar; Index: Integer);
var N: Integer; P: ^Longint;
begin
  P:=@S;
  for N:=2 to Index do begin
    if S^=#0 then EXIT;
    Inc(P^, Length(S)+1);
  end;
end;

//----------------------------------------------
//
//   Check if the Palm ROM is the required
//   version.
//
//   Author : Chris Burrows, CFB Software
//   Date   : August 2001
//   WWW    : http://www.cfbsoftware.com
//
//   Freeware source code example for PalmOS
//
//----------------------------------------------
function VersionSupported(MinVersion: UInt32): boolean;
var
  ErrNo: Err;
  ROMVersion : UInt32;
begin
  ErrNo := FtrGet(S2U32(sysFtrCreator), sysFtrNumROMVersion, ROMVersion);
  VersionSupported := ROMVersion >= MinVersion
end;

end.

