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

interface

Uses Windows, Messages, SysUtils, Classes, Graphics,
     Controls, Forms, Dialogs, ExtCtrls, StdCtrls;

Type
  RsrcName= Array[1..4] of Char;
  TRsrcRec= Record
    Case Integer of
    2: (Name: Array[1..32] of Char;
        ApplFlags_1,ApplVers_1: Word;
        CreaTime,ModTime,BackupTime: DWord; //Since 1-1-1904
        ModNo_0,ApplInfo_0,SortInfo_0: Cardinal;
        ApplType: RsrcName; //=appl
        ApplId: RsrcName;
        UniqIdSeed_0, NextRecordList_0: Cardinal;
        RecCnt: Word;
        Recs: Array[1..999] of
          Record
            Name: RsrcName;
            No:   Word;
            Ofs:  Cardinal;
          End);
        //Remember to add word(0) after structure before data
    1: (BufferStruct: Array [0..10000] of Byte);
  End;

  TRsrcs=Record AbsPos,L2: Integer; Name: RsrcName; RNo: Word; Data: String end;

  TRsrc= Class
    Cnt: Integer;
    Rsrcs: Array[1..99] of TRsrcs;
    AllData: String;
    Buf: TRsrcRec;
    Constructor Create;
    Function LoadFromFile(S: String): Boolean;
    Function SaveToFile(S: String): Boolean;
    Procedure AddToFile(Fil: Integer);
    Function GetInfo: String;
    Procedure Add(aName: String; aId: Integer; aData: String);
    Function Get1Rsrc(No: Integer): String;
    Function Get1RsrcName(No: Integer): String;
    Function Get1RsrcId(No: Integer): Integer;
  end;

implementation

Uses uMisc1;

Constructor TRsrc.Create;
begin
end;

Function TRsrc.LoadFromFile(S: String): Boolean;
var
  M: TFileStream;
  P,N,NN,Max: Integer;
begin
  Result:=False;
  try
    M:=TFileStream.Create(S,fmOpenRead);
  except
    EXIT;
  end;
  Max:=M.Size;
  SetLength(AllData,Max);
  M.Read(AllData[1],Max);
  M.Free;
  Result:=True;
  if Max>SizeOf(Buf.BufferStruct) then Max:=SizeOf(Buf.BufferStruct);
  Move(AllData[1],Buf.BufferStruct,Max);
  Cnt:=Swap(Buf.RecCnt);
  for NN:=1 to Cnt do begin
    Max:=Length(AllData);
    P:=SwapL(Buf.Recs[NN].Ofs);
    for N:=1 to Cnt do
      with Buf.Recs[N] do
        if (P<SwapL(Ofs)) and (SwapL(Ofs)<Max) then
          Max:=SwapL(Ofs);
    Dec(Max,P);
    if Max>0 then with Rsrcs[NN] do begin
      AbsPos:=P; L2:=Max;
      SetLength(Data,Max);
      Name:=Buf.Recs[NN].Name;
      RNo:=Swap(Buf.Recs[NN].No);
      Data:=Copy(AllData,P+1,Max);
    end;
  end;
end;

Function TRsrc.SaveToFile(S: String): Boolean;
var Fil: Integer;
begin
  Result:=False;
  Fil:=FileCreate(S);
  if Fil>0 then
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
  CurPos,HdrSize,N: Integer;
begin
  FillChar(Buf,SizeOf(Buf),0);
  with Buf do begin
    Name:='xxx'#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    //W1,W2,W3,W4,W5,W6: Word;
    //L1,L2,L3,L4: Cardinal;
    ApplType:='appl'; ApplId:='xxxx';
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
      if AbsPos<>Length(AllData) then EXIT;  //!!
      AllData:=AllData+Data;
    end;
  if Fil>0 then
    FileWrite(Fil,AllData[1],Length(AllData));
end;

Function TRsrc.GetInfo: String;
begin
  With Buf do
    Result:=Trim(Name)+', '+Trim(ApplType)+', '+Trim(ApplId)+', '+i2s(Swap(RecCnt))
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

Procedure TRsrc.Add(aName: String; aId: Integer; aData: String);
var
  C4: RsrcName;
begin
  Inc(Cnt);
  with Rsrcs[Cnt] do begin
    if Length(aName)>=Length(C4) then move(aName[1],C4,Length(C4));
    Name:=C4;
    RNo:=aId;
    Data:=aData;
  end;
end;

(*******
#define strRsc                         'tSTR'
#define ainRsc                         'tAIN'
#define iconType                       'tAIB'
#define bitmapRsc                      'Tbmp'
#define bsBitmapRsc                    'Tbsb'
#define alertRscType                   'Talt'
#define kbdRscType                     'tkbd'
#define MenuRscType                    'MBAR'
#define fontRscType                    'NFNT'
#define verRsc                         'tver'
#define appInfoStringsRsc              'tAIS'
#define fontIndexType                  'fnti'
#define midiRsc                        'MIDI'
#define colorTableRsc                  'tclt'
#define MenuCtlRsc                     'tcbr'
#define constantRscType                'tint'
#define formRscType                    'tFRM'
#define silkscreenRscType              'silk'
#define strListRscType                 'tSTL'
#define wrdListRscType                 'wrdl'
type 'ICON' {
      hex string[128];                             /* Icon data         */
};
type 'tAIN' {
   cstring;                            /* App Icon Name */
   align word;                            /* App Icon Name is defined in */
                                       /* TMPL as an even-padded cString. */
}; /* end tAIN */
/*--------------------------------------------------------------------------------------*/
type 'tBTN' {
   integer;                            /* Button ID */
   integer;                            /* Left */
   integer;                            /* Top */
   integer;                            /* Width */
   integer;                            /* Height */
   byte        notUsable=0, usable=1;        /* Usable */
   fill byte;
   byte        rightAnchor=0, leftAnchor=1;  /* Left Anchor */
   fill byte;
   byte        noFrame=0, frame=1;           /* Frame */
   fill byte;
   byte        boldFrame=0, nonBoldFrame=1;  /* Non-bold frame */
   fill byte;
   byte        palmFont;                  /* Font ID */
   cstring;                            /* Button Label */
}; /* end tBTN */

type 'tFRM' {
   integer;                            /* Left */
   integer;                            /* Top */
   integer;                            /* Width */
   integer;                            /* Height */
   byte        notUsable=0, usable=1;        /* Usable */
   fill byte;
   byte        notModal=0, modal=1;       /* Modal */
   fill byte;
   byte        noSaveBehind=0, saveBehind=1; /* Save behind */
   fill byte;
   fill word;
   fill word;
   integer;                            /* Form ID */
   integer;                            /* Help Rsc ID */
   integer;                            /* Menu Rsc ID */
   integer;                            /* Default Button ID */
   fill word;
   fill word;

   integer = $$Countof(ObjectArray);            /* Item count */
   wide array ObjectArray {
      integer;                            /* Object ID */
      string[4];                             /* Object Type */
   };
}; /* end tFRM */

/*--------------------------------------------------------------------------------------*/
type 'tSTL' {     // Beware - Item count is one-based, but the system routine
               // must be passed a zero-based value to retrieve strings...
   cstring;                            /* Prefix */

   integer = $$Countof(StringArray);            /* Item count */
   array StringArray {
      cstring;                            /* Text */
   };
}; /* end tSTL */


/*--------------------------------------------------------------------------------------*/
type 'tSTR' {
   cstring;                            /* The String */
                                       /* TMPL allows additional hex data */
}; /* end tSTR */

#define alertType    informationAlert=0, confirmationAlert=1,     \
                  warningAlert=2, errorAlert=3

#define palmFont     stdFont=0, boldFont=1, largeFont=2,          \
                  symbolFont=3, checkboxFont=4, symbol11Font=4,   \
                  symbol7Font=5, ledFont=6, largeBoldFont=7


*******)
end.

