//See UIResDefs.r / PalmType.c

//Code0: AboveA5=$30,BelovA5=bss=8,jmpSize=8,ofs_jmptab=$20,jmptab=8byte
(* DATA(0) packing
  $80+n b0,b1,..,bn             literal data    n<=127
  $40+n                         n+1 rep ($00)   n<=63
  $20+n b                       n+2 rep (b)     n<=31
  $10+n                         n+1 ref ($FF)   n<=15
  $00                           stop.

data-0000   1564=061C, 43
 0000 001F (0000 0000 ->00) (00 0000 28->00) (0000 0028 ->00)
 ofs=13  (00 0000 0000 0000 0000 0000 00) xref DATA0
 ofs=1F! (00 0000 0000 0000 0000 0000 00) xref CODE1

 0000 001F means offset of second XREF
 (00 0000 28->00) means send packed data to 28(a5)...
***)

unit RsrcIo;
{$A-}

interface

Uses Windows, Classes, SysUtils;

Type
  tRsrcName= Array[1..4] of Char;
  TRsrcRec= Record
    Case Integer of
    2: (Name: Array[1..32] of Char;
        ApplFlags_1,ApplVers_1: Word;
        CreaTime,ModTime,BackupTime: DWord; //Since 1-1-1904
        ModNo_0,ApplInfo_0,SortInfo_0: Cardinal;
        ApplType: tRsrcName; //=appl
        ApplID: tRsrcName;
        UniqIdSeed_0, NextRecordList_0: Cardinal;
        RecCnt: Word;
        Recs: Array[1..999] of
          Record
            Name: tRsrcName;
            No:   Word;
            Ofs:  Cardinal;
          End);
        //Remember to add word(0) after structure before data
    1: (BufferStruct: Array [0..10000] of Byte);
  End;

  TRsrcs=Record AbsPos{,L2}: Integer; Name: tRsrcName; RNo: Word; Data: String end;

  TRsrc= Class
    Cnt: Integer;
    Rsrcs: Array of TRsrcs;
    AllData: String;
    Buf: TRsrcRec;
    Constructor Create;
    Function LoadFromFileWildCard(S: String): Boolean;
    Function LoadFromFile(S: String): Boolean;
    Function SaveToFile(S: String): Boolean;
    Procedure AddToFile(Fil: Integer);
    Function GetInfo: String;
    Procedure Add1Rsrc(aName: String; aId: Integer; aData: String);
    Function Get1Rsrc(No: Integer): String;
    Function Get1RsrcName(No: Integer): String;
    Function Get1RsrcId(No: Integer): Integer;
  end;

implementation

Uses Global, uMisc1, Misc, Util;

Constructor TRsrc.Create;
begin
end;

Function TRsrc.LoadFromFileWildCard(S: String): Boolean;
var sr: TSearchRec;
begin
  ReplaceDollarTokens(S);
  if Pos('*',S)+Pos('?',S)=0 then begin
    S:=LocateUsingSearch(S);
    Result:=LoadFromFile(S);
  end else begin
    Result:=FindFirst(S, 0, sr) = 0;
    if Result then begin
      repeat
        Result:=Result and LoadFromFile(ExtractFilePath(S)+sr.Name);
      until (not Result) or (FindNext(sr) <> 0);
      FindClose(sr);
    end;
  end;
end;

Function TRsrc.LoadFromFile(S: String): Boolean;
var
  M: TFileStream;
  P,Max: Integer; // Cardinal;
  NN,NC: Integer;
  RsrcName: tRsrcName;
  S2: String;
begin
  Result:=False;
  try    M:=TFileStream.Create(S,fmOpenRead)
  except EXIT
  end;
  Max:=M.Size;
  SetLength(AllData,Max);
  M.Read(AllData[1],Max);
  M.Free;
  if CmpStr(ExtractFileExt(S),'.bin') then begin
    S2:=ExtractFileName(S);
    Move(S2[1],RsrcName,Length(RsrcName));
    Add1Rsrc(RsrcName,s2i('$'+Copy(S2,5,4)),AllData);
    Result:=True;
  end else begin
    if Max>SizeOf(Buf.BufferStruct) then Max:=SizeOf(Buf.BufferStruct);
    Move(AllData[1],Buf.BufferStruct,Max);
    try
      NC:=Swap(Buf.RecCnt);
      If NC>=256 then InternalError0; //('Cannot read more than 256 rsrc''s from file');
      for NN:=1 to NC do begin
        P:=SwapL(Buf.Recs[NN].Ofs);
        if NN=NC then Max:=Length(AllData)-P
        else          Max:=Integer(SwapL(Buf.Recs[NN+1].Ofs))-P;
        (***
        Max:=Length(AllData);
        for N:=1 to Cnt do
          with Buf.Recs[N] do
            if (P<SwapL(Ofs)) and (SwapL(Ofs)<Max) then
              Max:=SwapL(Ofs);
        Dec(Max,P);
        (***)
        if Max>0 then
          with Buf.Recs[NN] do
            Add1Rsrc(Name,Swap(No),Copy(AllData,P+1,Max));
      end;
      Result:=True;
    except
      InternalError('Cannot read Resource file');
    end;
  end;
end;

Function TRsrc.SaveToFile(S: String): Boolean;
var Fil: Integer;
begin
  Result:=False;
  Fil:=FileCreate(S);
  if Fil<=0 then Error(Err_CannotWr,S)
  else
    try
      try
        AddToFile(Fil);
        Result:=True;
      finally
        FileClose(Fil)
      end;
    except
    end;
end;

Procedure TRsrc.AddToFile(Fil: Integer);
var
  CurPos,HdrSize,M,N: Integer;
  S,ApplName: String;
begin
  //Cleanup! Remove empty ones
  for N:=Cnt downto 1 do
    if Rsrcs[N].Data='' then begin
      for M:=N+1 to Cnt do Rsrcs[M-1]:=Rsrcs[M];
      Dec(Cnt); SetLength(Rsrcs,Cnt+1); //Rsrcs is 0 based. I work 1 based
    end;

  FillChar(Buf,SizeOf(Buf),0);
  with Buf do begin
    if OptionsGlobal.ApplName='' then OptionsGlobal.ApplName:='HSPascal';
    if OptionsGlobal.ApplID=''   then OptionsGlobal.ApplID:='Hspc';
    ApplName:=OptionsGlobal.ApplName;
    ApplName:=Copy(ApplName,1,SizeOf(Name)-1); Move(ApplName[1],Buf.Name,Length(ApplName)); //Max 31!
    if Length(ApplName)<=32-9 then
      Move('HSPascal',Name[32-7],8); //Nice place for this!!!!!!!!!!!

    ApplFlags_1:=Swap(1);
    ApplVers_1 :=Swap(1);
    CreaTime:=SwapL(Trunc(24*60*60*(Now-EncodeDate(1904,1,1))));
    ModTime:=CreaTime;
    //CreaTime:=SwapL($adc0bea0);  //1996
    //ModTime :=SwapL($adc0bea0);
    BackupTime:=SwapL(0);
    ModNo_0:=0; ApplInfo_0:=0; SortInfo_0:=0;
    ApplType:='appl';
    S:=OptionsGlobal.ApplID+'    '; Move(S[1],ApplID,SizeOf(ApplID));
    //UniqIdSeed_0:=SwapL($28000000);
    NextRecordList_0:=0;
    //ApplL1,ApplL2: Cardinal;
    RecCnt:=Swap(Cnt);
  end;

  HdrSize:=Longint(@Buf.Recs)-Longint(@Buf);
  SetLength(AllData,HdrSize);
  Move(Buf,AllData[1],HdrSize);
  CurPos:=Longint(@Buf.Recs[Cnt+1])-Longint(@Buf)+2;
  for N:=1 to Cnt do
    with Rsrcs[N] do begin
      AbsPos:=CurPos; Inc(CurPos,Length(Data));
    end;
  for N:=1 to Cnt do
    with Rsrcs[N] do begin
      AllData:=AllData+Name+i2sx2(RNo)+i2sx4(AbsPos);
    end;
  AllData:=AllData+#0#0; //Terminator!
  for N:=1 to Cnt do
    with Rsrcs[N] do begin
      if AbsPos<>Length(AllData) then InternalError('Resource write error');
      AllData:=AllData+Data;
    end;
  if Fil>0 then
    FileWrite(Fil,AllData[1],Length(AllData));
end;

Function TRsrc.GetInfo: String;
begin
  With Buf do
    Result:=Trim(Name)+', '+Trim(ApplType)+', '+Trim(ApplID)+', '+i2s(Swap(RecCnt))
end;

Function TRsrc.Get1Rsrc(No: Integer): String;
begin
  Result:=Rsrcs[No].Data;
end;

Function TRsrc.Get1RsrcName(No: Integer): String;
begin
  Result:=Rsrcs[No].Name;
end;

Function TRsrc.Get1RsrcId(No: Integer): Integer;
begin
  Result:=Rsrcs[No].RNo;
end;

Procedure TRsrc.Add1Rsrc(aName: String; aId: Integer; aData: String);
var
  C4: tRsrcName;
  M,N: Integer;
begin
  aName:=Copy(aName,1,SizeOf(C4));
  Move(aName[1],C4,Length(aName));
  M:=0;
  for N:=1 to Cnt do
    with Rsrcs[N] do
      if (aName=Name) and (aId=RNo) then
        M:=N;
  if M=0 then begin
    Inc(Cnt); M:=Cnt;
    SetLength(Rsrcs,Cnt+1); //Rsrcs is 0 based. I work 1 based
  end;   //Use if found, or make new
  with Rsrcs[M] do begin
    Name:=C4;
    RNo:=aId;
    Data:=aData;
  end;
end;

end.

