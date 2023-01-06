Unit SyDefault;

Interface

uses Global, CodeDag{TUnit2};

Type
  TUnit3=Class(TUnit2)
    Procedure EnterReserved;
    Procedure EnterDefType;
  end;

Implementation

Uses Misc,Scanner;

Procedure TUnit3.EnterDefType;{(Scope: TScope);}
var SymRec: tSymRec;
Const
  V10PI:  array[0..4] of word=($4000,$C90F,$DAA2,$2168,$C232); //UNUSED!!!
  //V10NAN: array[0..4] of word=($7FFF,$FFFF,$FFFF,$FFFF,$FFFF);

Procedure SaveSym(var S: String; W: eSym; RTyp: eResType);
begin
  With Next, SymRec do begin
    IdnBuf:=S; What:=W;
    SymRec.TTYPP:=@StandardType[RTyp]; {Same for CONST!!!!! CTYPP !!!!!}
    InsSym(SymRec);
    ZeroSym(SymRec);
  end;
end;
procedure EnterType(S: String; What: eSym; RTyp: eResType);
begin
  SaveSym(S,What,RTyp);
end;
procedure EnterTypeVal4(S: String; What: eSym; RTyp: eResType; Val: Longint);
begin
  SymRec.CIVal:=Val;
  SaveSym(S,What,RTyp);
end;
procedure EnterTypeVal10(S: String; What: eSym; RTyp: eResType; Var Val);
begin
  Move(Val,SymRec.CRVal,10);
  SaveSym(S,What,RTyp);
end;
procedure EnterStandardProcFunc(S: String; What: eSym; Tok: Byte);
var Rec: tSymRec;
begin
  Next.IdnBuf:=S;
  Rec.What:=What;
  Rec.ProcNo:=Tok;
  InsSym(Rec);
  //EnterScopeBlkNameObj(Scope, Integer(Ord(What) shl 16 + Tok));
end;

var OldNext: tNext;
begin {EnterDefType}
  OldNext:=Next; ZeroSym(SymRec); {Keep zero'ed}
{ Symbol data }
  //EnterType('DOUBLE',STYPP,xDBL);
  //EnterType('EXTENDED',STYPP,xEXT);   //?????
  //EnterTypeVal10('PI',SCON,xEXT,V10PI);       is in HSSys5.pas!!
  //EnterTypeVal10('NAN',SCON,xEXT,V10NAN);

  EnterType('BYTE',STYPP,xBYT);         // 0..255
  EnterType('SHORTINT',STYPP,xTiny);    // -128..127
  EnterType('SMALLINT',STYPP,xSmall);   // Integer 16bit
  EnterType('LONGINT',STYPP,xLON);      // Integer 32bit
  EnterType('INTEGER',STYPP,xINT);      // 16 or 32 bits (define default for "Integer")
  EnterType('BOOLEAN',STYPP,xBOL);      // 0..1
  EnterType('CHAR',STYPP,xCHR);         // #000..#255
  EnterType('POINTER',STYPP,xPTR);      //

  EnterType('REAL',STYPP,xSNG);         // aka Single
  EnterType('SINGLE',STYPP,xSNG);       // Single

  //PI is in HSSys5.pas!!
  EnterTypeVal4('MAXINT',SCON,xLON,MaxInt16); //xINT,MaxInt16);
  EnterTypeVal4('MAXLONGINT',SCON,xLON,MaxInt32);
  EnterTypeVal4('FALSE',SCON,xBOL,0);
  EnterTypeVal4('TRUE',SCON,xBOL,1);

  EnterStandardProcFunc('NEW',SSTP,PSysNew);
  EnterStandardProcFunc('DISPOSE',SSTP,PSysDispose);
  EnterStandardProcFunc('GETMEM',SSTP,PSysMemGet);
  EnterStandardProcFunc('FREEMEM',SSTP,PSysMemFree);
  EnterStandardProcFunc('MAXAVAIL',SSTF,FSysMemMaxAvail);
  EnterStandardProcFunc('MEMAVAIL',SSTF,FSysMemAvail);

  EnterStandardProcFunc('COS',SSTF,FSysCos);
  EnterStandardProcFunc('ABS',SSTF,FSysAbs32);
  EnterStandardProcFunc('ROUND',SSTF,FSysRound);
  EnterStandardProcFunc('ARCTAN',SSTF,FSysArcTan);
  EnterStandardProcFunc('SQR',SSTF,FSysSqr);
  EnterStandardProcFunc('PTR',SSTF,FSysPtr);
  EnterStandardProcFunc('ODD',SSTF,FSysOdd);

  EnterStandardProcFunc('SQRT',SSTF,FSysSqrt);
  EnterStandardProcFunc('TRUNC',SSTF,FSysTrunc);
  EnterStandardProcFunc('COPY',SSTF,FSysStrCopy);
  EnterStandardProcFunc('SIN',SSTF,FSysSin);
  //EnterStandardProcFunc('SWAP',SSTF,FSysSwap);
  EnterStandardProcFunc('ADDR',SSTF,FSysAddr);
  EnterStandardProcFunc('INT',SSTF,FSysInt);
  EnterStandardProcFunc('LN',SSTF,FSysLN);
  EnterStandardProcFunc('SIZEOF',SSTF,FSysSizeOf);
  EnterStandardProcFunc('EXP',SSTF,FSysExp);

  EnterStandardProcFunc('RANDOMIZE',SSTP,PSysRandomize); 
  EnterStandardProcFunc('RANDOM',SSTF,FSysRandomI);

  EnterStandardProcFunc('MOVE',SSTP,PSysMove);
  EnterStandardProcFunc('FILLCHAR',SSTP,PSysFillchar);

  EnterStandardProcFunc('CHR',SSTF,FSysChr);
  EnterStandardProcFunc('ORD',SSTF,FSysOrd);
  //EnterStandardProcFunc('CONCAT',SSTF,FSysStrAdd);
  EnterStandardProcFunc('UPCASE',SSTF,FSysUpCase);
  EnterStandardProcFunc('POS',SSTF,FSysStrPos);
  EnterStandardProcFunc('INSERT',SSTP,PSysStrIns);
  EnterStandardProcFunc('LENGTH',SSTF,FSysStrLen);
  EnterStandardProcFunc('DELETE',SSTP,PSysStrDel);

  EnterStandardProcFunc('STR',SSTP,ISysStringI);  //Special I/R
  EnterStandardProcFunc('VAL',SSTP,PSysValI);     //Special I/R

  EnterStandardProcFunc('LO',SSTF,FSysLo);
  EnterStandardProcFunc('INC',SSTP,ISysInc);
  EnterStandardProcFunc('DEC',SSTP,ISysDec);
  EnterStandardProcFunc('SUCC',SSTF,FSysSucc);
  EnterStandardProcFunc('PRED',SSTF,FSysPred);

  //EnterStandardProcFunc('FLOAT',SSTF,FSysFloat);
  //EnterStandardProcFunc('HI',SSTF,Ord(FHIB));
  //EnterStandardProcFunc('SWAPWORD',SSTF,Ord(FSWW));   //??
  //EnterStandardProcFunc('LOWORD',SSTF,Ord(FLOW));
  //EnterStandardProcFunc('HIWORD',SSTF,Ord(FHIW));

  //EnterStandardProcFunc('ORD4',SSTF,Ord(FOR4));

  //EnterStandardProcFunc('RUNERROR',SSTP,Ord(PRER));
  //EnterStandardProcFunc('HALT',SSTP,Ord(PHLT));

  //EnterType('TEXT',STYPP,xTXT);
  //EnterStandardProcFunc('PAGE',SSTP,Ord(PPAG));
  //EnterStandardProcFunc('EOLN',SSTF,Ord(FEOL));
  //EnterStandardProcFunc('EOF',SSTF,Ord(FEOF));
  //EnterStandardProcFunc('SETTEXTBUF',SSTP,Ord(PTXTBUF));
  //EnterStandardProcFunc('ASSIGN',SSTP,Ord(PASSIGN));
  //EnterStandardProcFunc('APPEND',SSTP,Ord(PAPPEND));
  //EnterStandardProcFunc('IORESULT',SSTF,Ord(FIOR));
  //EnterStandardProcFunc('FILESIZE',SSTF,Ord(FFSZ));
  //EnterStandardProcFunc('FILEPOS',SSTF,Ord(FFPO));
  //EnterStandardProcFunc('SEEKEOF',SSTF,Ord(FSEF));
  //EnterStandardProcFunc('BLOCKWRITE',SSTP,Ord(PBKW));
  //EnterStandardProcFunc('BLOCKREAD',SSTP,Ord(PBKR));
  //EnterStandardProcFunc('READLN',SSTP,Ord(PRLN));
  //EnterStandardProcFunc('CLOSE',SSTP,Ord(PCLS));
  //EnterStandardProcFunc('RENAME',SSTP,Ord(PREN));
  //EnterStandardProcFunc('SEEK',SSTP,Ord(PSEK));
  //EnterStandardProcFunc('WRITE',SSTP,Ord(PWRT));
  //EnterStandardProcFunc('READ',SSTP,Ord(PRED));
  //EnterStandardProcFunc('DEVICE',SSTP,Ord(PDEV));
  //EnterStandardProcFunc('REWRITE',SSTP,Ord(PRWR));
  //EnterStandardProcFunc('ERASE',SSTP,Ord(PERA));
  //EnterStandardProcFunc('WRITELN',SSTP,Ord(PWLN));
  //EnterStandardProcFunc('RESET',SSTP,Ord(PRST));
  //EnterStandardProcFunc('SEEKEOLN',SSTF,Ord(FSEL));

  Next:=OldNext;
end;

Procedure TUnit3.EnterReserved;

procedure EnterResW(S: String; What: eSym);
begin
  Next.IdnBuf:=S;
  //CalcIdnModus;
  EnterScopeBlkNameObj(ResWords, Integer(What));
end;

Begin {EnterReserved}
  if Assigned(ResWords) then EXIT;
  ResWords:=TScope.Create(skResWords);

  EnterResW('EXIT',SEXIT);
  EnterResW('CONTINUE',SCONT);
  EnterResW('BREAK',SBREAK);

  EnterResW('BEGIN',SBGN);
  EnterResW('PROCEDURE',SPRO);
  EnterResW('AND',SAND);
  EnterResW('DIV',SDIV);
  EnterResW('NIL',SNIL);
  EnterResW('DO',SDO);
  EnterResW('STRING',SSTR);
  EnterResW('TO',STO);
  EnterResW('PROGRAM',SPGM);
  EnterResW('CONST',SCON);
  EnterResW('PACKED',SPAC);
  EnterResW('OF',SOF);
  EnterResW('END',SEND);
  EnterResW('FOR',SFOR);
  EnterResW('WHILE',SWHL);
  EnterResW('SHL',SSHL);
  EnterResW('ELSE',SELS);
  EnterResW('DOWNTO',SDTO);
  EnterResW('IN',SIN);
  EnterResW('GOTO',SGTO);
  EnterResW('VAR',SVAR);
  EnterResW('XOR',SXOR);
  EnterResW('UNTIL',SUNT);
  EnterResW('ABSOLUTE',SABS);
  EnterResW('WITH',SWTH);
  EnterResW('CASE',SCAS);
  EnterResW('INTERFACE',SINF);
  EnterResW('IMPLEMENTATION',SIMP);
  EnterResW('RECORD',SREC);
  EnterResW('SET',SSET);
  EnterResW('INLINE',SINL);
  EnterResW('ARRAY',SARY);
  EnterResW('SHR',SSHR);
  EnterResW('THEN',STHN);
  EnterResW('REPEAT',SREP);
  EnterResW('LABEL',SLBL);
  {EnterResW('EXTERNAL',SEXT);{}
  EnterResW('USES',SUSE);
  EnterResW('UNIT',SUNI);
  EnterResW('IF',SIF);
  EnterResW('MOD',SMOD);
  EnterResW('FUNCTION',SFUN);
  EnterResW('TYPE',STYP);
  EnterResW('NOT',SNOT);
  EnterResW('ASM',SASM);
  EnterResW('OR',SOR);
  EnterResW('RESOURCE',SRSRC);

  EnterResW('OBJECT',SOBJ);
  EnterResW('PRIVATE',SPRIVATE);
  EnterResW('PUBLIC',SPUBLIC);
  EnterResW('DESTRUCTOR',SDESTRUCTOR);
  EnterResW('CONSTRUCTOR',SCONSTRUCTOR);
  EnterResW('VIRTUAL',SVIRTUAL);	{direc}
  EnterResW('ASSEMBLER',SASSEM);	{direc}
  EnterResW('NOA6FRAME',SNOA6FRAME);	{direc}
  EnterResW('SYSPROC',SDIRSYS);         {direc SysTrap}
  EnterResW('FORWARD',SFWD);		{direc}
  EnterResW('SYSTRAP',STRP);		{direc}
  EnterResW('SYS_TRAP',STRP);		{direc, as in C src's}
  EnterResW('CDECL',CDECL);		{direc}

  //EnterResW('FILE',SFIL);
End;

end.


