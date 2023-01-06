unit uMisc1;

interface

Uses SysUtils;

Function SwapL(L: Cardinal): Cardinal;
Function i2s(I: Integer): String;
Function i2h2(I: Cardinal): String;
Function i2h4(I: Cardinal): String;
Function i2sx2(I: Integer): String;
Function i2sx4(I: Integer): String;

implementation

Function SwapL(L: Cardinal): Cardinal;
begin
  Result:=Swap(L and $0000FFFF) shl 16 + Swap(L shr 16);
end;

Function i2s(I: Integer): String;
begin
  Result:=IntToStr(I);
end;

Function i2h2(I: Cardinal): String;
begin
  Result:=Format('%.4x',[I]);
end;

Function i2h4(I: Cardinal): String;
begin
  Result:=Format('%.8x',[I]);
end;

Function i2sx2(I: Integer): String;
begin
  Result:=Char(Hi(I))+Char(Lo(I))
end;

Function i2sx4(I: Integer): String;
begin
  Result:=i2sx2(I shr 16)+i2sx2(I and $0000FFFF)
end;

end.
