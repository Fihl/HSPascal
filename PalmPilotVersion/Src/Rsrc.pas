unit Rsrc;

interface

Uses Classes, SysUtils, Global, Util, Misc, SyDefault{TUnit3};

Type
  TUnit4=Class(TUnit3)
    Procedure DeclareResource;
  Private
  end;

implementation

var //Menu handling
  MItems: TStringList;    //Menu
  SPItems: TStringList;   //StringPointer

{ Rsrc ============================================ }
procedure TUnit4.DeclareResource;
Var
  Name: String;

Function GetARsrc(Level: Integer; var Id: Integer; CodedSoFar: Integer=0; DefHdr: String=''): String;
var
  Res,LastSGet1: String;
Function Get1(Default: Integer=0): Integer; //-1 => String
var
  TP: TypPtr;
begin
  LastSGet1:=''; Result:=0;
  if Next.Ch=SCOM then begin
    Result:=Default;
  end else
  if Next.Ch<>SRPA then begin
    TP:=FCON;
    case TP^.TTYPE of
    TUSR,
    TINT: Result:=Next.IValue;
    TCHR,
    TPAC: repeat
            Result:=-1;
            LastSGet1:=LastSGet1+Next.SValue;
            if not Scan(SPLS) then BREAK;
            TP:=FCON;
            if not (TP^.TTYPE in [TCHR,TPAC]) then Error(ExpCStr);
            CONTINUE;
          until FALSE;
    else  InternalError('RsrcType');
    end;
  end;
end;
Function GetS: String;
begin
  if Get1(-1)<>-1 then InternalError('RsrcType3');
  Result:=LastSGet1
end;
Function GetS0: String;
begin
  Result:=GetS+#0
end;

Function ConvertBitmap(S: String): String;
var N: Integer; Ch: Char;
begin
  Result:=''; N:=7; Ch:=#0;
  While S<>'' do begin
    if not (S[1] in ['.','0',' ']) then Inc(Ch, (1 shl N));
    Delete(S,1,1);
    Dec(N);
    if N<0 then begin
      Result:=Result+Ch; Ch:=#0;
      N:=7;
    end;
  end;
end;

Function  NextPos: Integer;
begin
  Result:=Length(Res)+1
end;
Procedure AddS(S: String);   begin Res:=Res+S end;
Procedure AddB(B: Integer);  begin AddS(Char(Lo(B))) end;
Procedure AddBAlign;
begin
  If Odd(Length(Res)) then
    AddB(0)
end;
Procedure AddW(W: Integer);
begin
  AddBAlign; //Align word
  AddB(Lo(Swap(W)));
  AddB(Lo(W))
end;
Procedure AddLZero;
begin
  AddW(0); AddW(0);
end;
Procedure PatchW(Pos,W: Integer);
begin
  if NOT Odd(Pos) then  //1 based!! Must be word bound
    InternalError0;
  if Pos>NextPos-2 then InternalError0;
  Res[Pos]:=Char(Hi(W)); Res[Pos+1]:=Char(Lo(W));
end;
Procedure PatchL(Pos,N: Integer);
begin
  PatchW(Pos,N shr 16);
  PatchW(Pos+2,N)
end;
Function GetResW(Pos: Integer): Integer;
begin
  if (Pos<=0) or (Pos>NextPos-2) then InternalError0;
  Result:=Ord(Res[Pos])* 256+ Ord(Res[Pos+1]);
end;

procedure CtrlAttr(Def: Integer);
var N: Integer;
begin
  N:=Get1(Def);
  (*** if ScanSLPA then
    repeat
      S:=Get1
    until FALSE;
  (***)
  AddW(N);
end;

Procedure GetPut4W(i1,i2,i3,i4: Integer);
begin
  //x FindSCOM;
  FindSLPA;
  ////Result:='';
  if i1>=0 then begin AddW(Get1(i1));           end;
  if i2>=0 then begin FindSCOM; AddW(Get1(i2)); end;
  if i3>=0 then begin FindSCOM; AddW(Get1(i3)); end;
  if i4>=0 then begin FindSCOM; AddW(Get1(i4)); end;
  Find(SRPA);
end;

var //GetARsrc
  M,N0,N,X,PosCnt,SubCnt,Items,Def2_9: Integer;
  StrN,MSI,MSPPos: Integer;
  S,S2_9,TailStr: String;
  SL: TStringList;
  Id2: Integer;
  //Ch: eSym;
  xIdnBuf1,xIdnBuf2: String;
  SymRec: tSymRec;
  B,B2: Boolean;
Function CheckIdnBuf: String;
begin
  Result:='';
  if Scan(SIDN) then begin
    Result:=Next.IdnBuf;
    Find(SEQS);
  end;
end;
Procedure ResolveIdnBuf(IdnBuf: String; Id: Integer);
begin
  if IdnBuf<>'' then begin
    Next.IdnBuf:=IdnBuf; //Restore ID
    SymRec.CIVAL:=Id; SymRec.CTYPP:=@StandardType[xLON]; //xINT!!
    InsSym(SymRec)
  end;
end;

procedure RsrcError1; begin InternalError('Bad Rsrc mask:'+S) end;
begin //GetARsrc
  SL:=TStringList.Create;
  Result:=''; Id:=0; Res:=''; PosCnt:=0; SubCnt:=0;
  try
    ZeroSym(SymRec); SymRec.What:=SCON;
    xIdnBuf1:=CheckIdnBuf;
    FindSLPA;
    //if Scan(SLPA) then
    begin
      DefHdr:=FSCON;
      SL.CommaText:=DefHdr;
      Items:=SL.Count;
      if Level=1 then begin
        //MainForm=(ResTFRM,1000,(0,0,160,160),0,0,0,
        N0:=1;
        Name:=SL[0];                  //'I,b,0,w,*'
        FindSCOM; //x
      end else begin
        //(FormGraffitiStateIndicator,(150,150)),
        //(FormTitle,,'DoodleHS'),
        N0:=0;                         //'s,s,s,s'
        //x FindSCOM;
      end;
      for N:=N0 to Items-1 do begin
        S:=Trim(UpCaseStr(SL[N]));
        S2_9:=Copy(S,2,9); Def2_9:=s2i(S2_9);
        case S2Char(S,' ') of
        'D': Debug(S); //DebugBreak on D commands!!
        'P': AddLZero;
        '#': begin SubCnt:=0; PosCnt:=NextPos; AddW(0) end;     //Position for counter
        '*': if PosCnt=0 then InternalError('# field missing')  //Counter
             else
               while ScanSCOM do begin
                 Inc(SubCnt);
                 AddS(GetARsrc(Level+1,Id2,NextPos-1,S2_9));
               end;
        '£': if PosCnt=0 then InternalError('# field missing')  //Counter
             else
               while ScanSCOM do begin
                 Inc(SubCnt);
                 S:=GetARsrc(Level+1,Id2,NextPos-1,S2_9);
                 AddS(Copy(S,1,2));
                 SPItems.AddObject(Copy(S,3,999),Pointer(NextPos)); 
                 AddLZero; //Pointer .L
               end;
        'O': if Level=1 then RsrcError1 else AddW(Def2_9 shl 8);
        'B': if S='BITMAP' then
               AddS(ConvertBitmap(GetS))
             else
               AddB(Get1(Def2_9));
        '0'..'9',
        '$': if (Copy(S,1,1)='$') and (Length(S)<=3) then AddB(s2i(S)) else AddW(s2i(S));
        'F': if Id=0 then InternalError0 else AddW(Id); //Only tFRM (Level=1)
        else
          if N>N0 then //Skip nex comma!!!
            FindSCOM;
          case S2Char(S,' ') of
          '_': begin // Byte: _F, _G, (or "_F2") (Font, Group, ) // Word: _M  (MaxChars, )
                 X:=Get1(s2i(Copy(S,3,9)));
                 if Copy(S,2,1)='M' then AddW(X) else AddB(X);
               end;
          'I': begin
                 Id:=Def2_9; if S2_9='' then Id:=-1;  //No Default => -1 => Allow Id=0
                 Id:=Get1(Id);
                 if Id=-1 then begin
                   Id:=NextRsrcLocated;
                   Inc(NextRsrcLocated);
                 end;
                 if Level=2 then
                   AddW(Id);
               end;
          'W': if S='W+' then begin
                 while ScanSCOM do begin
                   AddW(Get1); Inc(SubCnt);
                 end;
               end else begin //Wn => 'w3' => Default=3
                 AddW(Get1(Def2_9));
               end;
          'S': begin
                 B:= S='SL'; B2:= S='SP';
                 if (S='S+') or B then begin
                   //x FindSCOM;
                   if B then FindSLPA;
                   repeat
                     AddS(GetS0); Inc(SubCnt);
                   until not ScanSCOM;
                   if B then AddB(0);
                 end else
                 if B2 then begin  //SP
                   //x FindSCOM;
                   FindSLPA;
                   S:='';
                   repeat
                     S:=S+GetS0;
                     AddLZero;
                     Inc(SubCnt);
                   until not ScanSCOM;
                   AddS(S);
                 end else
                 if {(S='SP') or } (S='S^') then begin  //Menu items
                   SPItems.AddObject(GetS0,Pointer(CodedSoFar+NextPos));
                   AddLZero; //Pointer .L
                 (** end else if S='S>' then begin
                   TailStr:=GetS(TRUE)+#0;
                   AddLZero; //Pointer .L
                 (**)
                 end else if S='S' then
                   AddS(GetS0)
                 else RsrcError1;
                 if B or B2 then FindSRPA;
               end;
          'C': CtrlAttr(Def2_9);
          'L':      if S='LTWH' then GetPut4W(0,0,0,0)
               else if S='LT'   then GetPut4W(0,0,-1,-1)
               else if S='LTW'  then GetPut4W(0,0,0,-1)
               else RsrcError1;
          'M': begin
                 AddS(#255#255#255#255);
                 repeat
                   Inc(SubCnt);
                   xIdnBuf2:=CheckIdnBuf;
                   FindSLPA;
                   X:=Get1(-1); //MItem = 'I,b,0,S^';            //Id,Shortcut,Title
                   FindSCOM;
                   if X=-1 then begin
                     X:=NextRsrcLocated; Inc(NextRsrcLocated);
                   end;
                   ResolveIdnBuf(xIdnBuf2,X);
                   X:=Swap(X); //M68K!
                   S:=Copy('xx'+GetS0+#0#0#0#0#0#0,1,8);
                   FindSCOM;
                   Move(X,S[1],2); //Save first 4 bytes of Id,Key
                   MItems.Add(S+GetS0);
                   FindSRPA;
                 until not ScanSCOM;
               end;
        'N': Name:=GetS;
        'R': if CmpStr(S,'RawFile') then begin
               S:=GetS;
               S:=LoadFile(S);
               AddS(S);
             end else
             if CmpStr(S,'RawString') then begin
               S:=GetS;
               AddS(S);
             end;
          else RsrcError1;
          end;
        end;
      end;
      if PosCnt>0 then
        Res[PosCnt+1]:=Char(Lo(SubCnt)); //Max 255!!
      Find(SRPA);

      AddBAlign;
      Res:=Res+TailStr;
      AddBAlign;

      //Fixup Menu's
      if Level=1 then begin
        if MItems.Count>0 then begin
          StrN:=0; MSPPos:=1+ 16*2;   //Array[MenuPulldown] (after 16 Words)
          MSI:=GetResW(14*2-1); //Word #14=Cnt
          if MSI<>SubCnt then
            InternalError0;;;;;;
          //SP=14, #=15, ^[]=16-17
          for MSI:=1 to MSI do begin
            AddBAlign;
            PatchL(MSPPos+16*2-2,NextPos-1); //@Array of Pulldown menus (word only)
            N:=GetResW(MSPPos+15*2-2); //Word#15= #'Field
            Inc(MSPPos,17*2); //Next PullDownMenu
            for N:=1 to N do begin
              if StrN>=MItems.Count then InternalError0;
              S:=MItems[StrN]; //Has \0
              SPItems.AddObject(Copy(S,8+1,999),Pointer(NextPos+4));
              AddS(Copy(S,1,8));
              Inc(StrN);
            end;
          end;
          if StrN<>MItems.Count then InternalError0;
        end;
        //AddBAlign;

        N:=SPItems.Count;
        for N:=0 to N-1 do begin
          S:=SPItems[N]; X:=Integer(SPItems.Objects[N]);
          M:=NextPos-1;
          PatchL(X,M); //@Title
          // if Copy(S,Length(S),1)<>#0 then S:=S+#0;
          //if Odd(Length(S)) then
          //  S:=S+#0;

          AddS(S); //Title
        end;
        ///AddBAlign; //Palm does not Align last byte
      end;

      Result:=Res;
    end;

    ResolveIdnBuf(xIdnBuf1,Id);
  finally
    SL.Free;
  end;
end;

//DeclareResource
var
  S: String;
  Id: Integer;
begin //DeclareResource
  ScanNext; //Remove 'Resource'
  repeat
    Id:=0;

    MItems:=TStringList.Create; SPItems:=TStringList.Create;
    S:=GetARsrc(1,Id);
    MItems.Free;
    SPItems.Free;

    DebugIfL('Rsrc: "'+S+'"');
    if Id=0 then Write('!!!!!!!Rsrc Id is 0!'); ///InternalError('Rsrc Id is 0!');
    Rsrc.Add1Rsrc(Name,Id,S); //pref=> 'x,x,x,x', ''
    if ScanSSEM then
      if Next.Ch in [SIDN,SLPA] then CONTINUE;
    BREAK;
  until FALSE;
end;

(*******************************************************************************
  Project resources //Page 69, Palm OS SDK
  Talt, Alert
  tFRM, Form
        Menu  (MENU)
        Menubar (MBAR)
  tSTR, String
        Icons
        Bitmaps

  Catalog resources //Page 67, Palm OS SDK
  tBTN, Button
  tCBX, CheckBox
  tFLD, Field (Prompt and editfield)
  tFBM, Form bitmap container
  tGDT, Gadget
  tGSI, Graffiti(r) shift indicator
  tLBL, Label
  tLST, ListBox
  tPUT, PopUp trigger (Dropdown)
  tREP, Repeating button
  tSLT, Selector trigger (ScrollBar)
  tTBL, Table
  //*****************************************

*******************************************************************************)
end.

