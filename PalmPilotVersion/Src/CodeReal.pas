{***** Real Code ***************************************************************}
Unit CodeReal;

interface

Uses SysUtils, Global, Util, Misc, Dag;

Type
  TCode68K = Class
    Constructor Create;
    Procedure Code68K(var RetOPS: CodeWordArray; What: eCode; lEA,rEA: tEA; Size: eEASize=easNone);
    Procedure InitRegs;
  end;

Function  DisAsm(mCode: Array of Word; C1,C2: Integer; Comment: String=''): String;

var
  DagId68k: Integer; //Set before each CodeInstr call
  LastUsedReg: array[Boolean] of eReg;

implementation

Constructor TCode68K.Create;
begin
end;

Procedure TCode68K.InitRegs;
var i: eReg;
begin
  FillChar(Regs,SizeOf(Regs),0);
  for i:=rNONE to RegLast do Regs[i].RegType:=RegsOrig[i];
  RegsFree:=RegsData+RegsAddr;
  MaxRec:=[];
  FillChar(Vars,SizeOf(Vars),0);
  FillChar(Temps,SizeOf(Temps),0);
  LastUsedReg[False]:=RegFirstAn;
  LastUsedReg[True] :=RegFirstDn;
end;

{**********************************************************************}
procedure TCode68K.Code68K(var RetOPS: CodeWordArray; What: eCode; lEA,rEA: tEA;Size: eEASize=easNone);
var OpS: CodeWordArray; OpInx: Integer;

procedure SwapEAs;
var H: tEA;
begin
  H:=lEA; lEA:=rEA; rEA:=H
end;

procedure AddW(W: Integer);
begin
  OpS[OpInx]:=Word(W and $0000FFFF); Inc(OpInx)
end;
procedure AddL(L: Integer);
begin
  AddW(L shr 16);
  AddW(L and $FFFF);
end;

function CodeEA(Const EA: tEA): Integer;
var Reg: Byte;
begin
  with EA do begin
    Reg:=RegBits[EAl];
    if not (EAh in [EPDIS,EIMED]) then
      if Reg>7 then InternalError('Codegen. Bad reg');
    case EAh of
    EDREG: Result:=Reg;
    EAREG: Result:=$08+Reg;
    EAIND: Result:=$10+Reg;
    EAINC: Result:=$18+Reg;
    EADEC: Result:=$20+Reg;
    EADIS: if EAofs=0 then Result:=$10+Reg else begin Result:=$28+Reg; AddW(EAofs) end;
    EAIXw: begin
             Result:=$30+Reg;
             AddW(RegBits[EAi] shl 12 + lo(EAofs)); //Index.W *1
             if not IsOfsInt8(EA) then InternalError0;
           end;
    EAIXl: begin
             Result:=$30+Reg;
             AddW(RegBits[EAi] shl 12 + 1 shl 11 + lo(EAofs)); //Index.L *1
             if not IsOfsInt8(EA) then InternalError0;
           end;
    //EABSW, EABSL:
    EPDIS: begin Result:=$3A; AddW(EAOfs) end;
    EIMED: begin
             Result:=$3C;
             if EAsize>=easL then AddL(EAOfs) else AddW(EAOfs)
           end;
    else   Result:=0;
           InternalError0
    end;
  end;
end;

// CodeInstr
var
  N: Integer;
  lReg,lReg9,lEASize6: Integer;
  rReg,rReg9,rEASize6: Integer;
Procedure SetLeftImmSizeFromRight(SkipIfxxxA: Boolean=False); //Skip if fx AddA #nn,A7
begin
  if SkipIfxxxA and (rEA.EAh=EAREG) then
    EXIT;
  if lEA.EAh=EIMED then lEA.EAsize:=rEA.EAsize;
  lEASize6:=K68Size[lEA.EAsize] shl 6;
end;

begin  //Code68K
  try
    if Size<>easNone then begin
      lEA.EAsize:=Size; rEA.EAsize:=Size;
    end;
    if rEA.EAsize=easNone then
      rEA.EAsize:=lEA.EAsize;
    if lEA.EAsize=easNone then
      lEA.EAsize:=rEA.EAsize;

    SetLength(OpS,5); OpInx:=1; OpS[0]:=0;
    lReg:=RegBits[lEA.EAl]; lReg9:= lReg shl 9; lEASize6:=K68Size[lEA.EAsize] shl 6;
    rReg:=RegBits[rEA.EAl]; rReg9:= rReg shl 9; rEASize6:=K68Size[rEA.EASize] shl 6;
    case What of
    codEA:    OpS[0]:=CodeEA(lEA);
    codENTER: begin OpS[0]:=$4E50 + rReg; AddW(lEA.EAofs) end; //Link A6
    codLEAVE: OpS[0]:=$4E58 + 6;                               //UNLK A6
    codRTS:   OpS[0]:=$4E75;
    codLEA:   OpS[0]:=$41C0+ CodeEA(lEA) + rReg9;
    codPEA:   case lEA.EAh of
              EIMED: begin
                       OpS[0]:=$4840+ $38;
                       if lEA.EAsize<=easW then AddW(lEA.EAOfs)
                       else begin
                         Inc(OpS[0]);
                         AddL(lEA.EAOfs)
                       end;
                     end;
              EAREG: OpS[0]:=$2F00+CodeEA(lEA);   //MOVE.L An,-(SP)
              else   OpS[0]:=$4840+CodeEA(lEA);   //PEA <ea>
              end;
    codMOVE:  begin
                SetLeftImmSizeFromRight;
                if (lEA.EAh=EIMED) and (rEA.EAh=EDREG) then begin
                  case lEA.EAofs of
                  -128..127: OpS[0]:=$7000+ rReg9 + lo(lEA.EAofs);
                  end;
                end;
                if (OpS[0]=0) and (lEA.EAh=EIMED) then
                  case lEA.EAofs of
                   0: begin
                        Code68K(RetOPS,codCLR,rEA,EA_None);
                        EXIT;
                      end;
                  -1: If rEA.EAsize=easB then OpS[0]:=$50c0+CodeEA(rEA); // ST.b EA
                  1..32767: if lEA.EAsize=easL then
                            if (rEA.EAh=EADEC) and (rEA.EAl=rA7) then begin
                              OpS[0]:=$4840+ $38; //PEA abs.w
                              AddW(lEA.EAOfs);
                            end;
                  end;
                if OpS[0]=0 then begin
                  OpS[0]:=CodeEA(lEA);
                  N:=CodeEA(rEA);                        //mmmrrr
                  N:=(N shr 3 + (N and 7) shl 3);        //rrrmmm
                  Inc(OpS[0],N shl 6);
                  case rEA.EAsize of
                  easB: inc(OpS[0],$1000);
                  easW: inc(OpS[0],$3000);
                  else  inc(OpS[0],$2000);
                  end;
                end;
              end;
    codCLR:   begin OpS[0]:=$4200+CodeEA(lEA)+lEASize6 end;
    codTST:   begin OpS[0]:=$4A00+CodeEA(lEA)+lEASize6 end;
    codEXT:   if lEA.EAsize<=easW then OpS[0]:=$4880+lReg else OpS[0]:=$48C0+lReg;
    codNEG:   OpS[0]:=$4400 + CodeEA(lEA) + lEASize6;
    codSWAP:  OpS[0]:=$4840 + CodeEA(lEA);
    codNOT:   OpS[0]:=$4600 + CodeEA(lEA) + lEASize6;
    codCALL:  begin OpS[0]:=$6100; AddW(lEA.EAofs) end;
    codJMP:   begin OpS[0]:=$6000; AddW(lEA.EAofs) end;
    codEQ:    begin OpS[0]:=$6700 + CodeEA(lEA) end;
    codNE:    begin OpS[0]:=$6600 + CodeEA(lEA) end;
    codGT:    begin OpS[0]:=$6E00 + CodeEA(lEA) end;
    codLT:    begin OpS[0]:=$6D00 + CodeEA(lEA) end;
    codGE:    begin OpS[0]:=$6C00 + CodeEA(lEA) end;
    codLE:    begin OpS[0]:=$6F00 + CodeEA(lEA) end;

    //op    ea    A     I     Q
    //add   d000  d000  0600  5000
    //sub   9000  9000  0400  5100
    //or    8000        0000
    //eor   b000        0a00
    //and   c000        0200
    //lsl   e110                       Imm => +0000, Dn => +0020
    //lsr   e010                       Imm => +0000, Dn => +0020
    //muls  c1c0
    //divs  81c0
    //mod = divs + swap 4840+Dn
    codRDV: InternalError('MOD!');

    codADD,
    codSUB,
    codCMP:   begin
                SetLeftImmSizeFromRight(True);
                if IsImm1_8(lEA) and (What<>codCMP) then begin //xxxQ
                  N:=(lEA.EAofs and 7) shl 9 + CodeEA(rEA) + lEASize6;
                  Case What of
                  codADD: OpS[0]:=$5000+N;
                  codSUB: OpS[0]:=$5100+N;
                  end;
                end else
                if lEA.EAh=EIMED then begin //xxxI
                  case What of
                  codADD: OpS[0]:=$0600;
                  codSUB: OpS[0]:=$0400;
                  codCMP: OpS[0]:=$0C00;
                  end;
                  if rEA.EAh=EAREG then begin //ADDA / SUBA / CMPA
                    case What of
                    codADD: OpS[0]:=$D000;
                    codSUB: OpS[0]:=$9000;
                    codCMP: OpS[0]:=$B000;
                    end;
                    if IsImmInt16(lEA) then begin
                      lEA.EASize:=easW;
                      inc(OpS[0],$00C0);
                    end else inc(OpS[0],$01C0);
                    inc(OpS[0],rReg9+CodeEA(lEA));
                  end else begin
                    if lEA.EASize<=easW then AddW(lEA.EAofs) else AddL(lEA.EAofs);
                    inc(OpS[0],CodeEA(rEA) + lEASize6);
                  end;
                end else begin
                  case What of
                  codADD: OpS[0]:=$D000;
                  codSUB: OpS[0]:=$9000;
                  codCMP: opS[0]:=$B000;
                  end;
                  if rEA.EAh=EDREG then
                    inc(OpS[0],CodeEA(lEA) + rReg9 + lEASize6)
                  else
                    inc(OpS[0],$0100+CodeEA(rEA) + lReg9 + lEASize6); //Mode=100,101,110
                end;
              end;
    codSHL,codSHR: //lsl,lsr
              begin
                if What=codSHR then OpS[0]:=$E000 else OpS[0]:=$E100;
                if lEA.EAh=EIMED then begin
                  if lEA.EAofs<0 then Ops[0]:=Ops[0] xor $0100; // lsl <-> lsr
                  lEA.EAofs:=abs(lEA.EAofs);
                  //if lEA.EAofs=1 then inc(OpS[0],CodeEA(rEA)+$02C0)
                  //else
                  begin
                    if rEA.EAh<>EDREG then InternalError('SHL/SHR Dn');
                    if not IsImm1_8(lEA) then InternalError('SHL/SHR imm');
                    N:=lEA.EAofs shl 9; if lEA.EAofs=8 then N:=0;
                    inc(OpS[0],rReg + $0008 + N + rEASize6);
                  end;
                end else begin
                  if lEA.EAh<>EDREG then InternalError('SHL/SHR Dn');
                  inc(OpS[0],CodeEA(rEA)+ $0028+ lReg9+ rEASize6) //lsx Dn,Dn
                end;
              end;
    codXOR:   begin //EOR
                //nono if not (lEA.EAh in [EDREG,EIMED]) then SwapEAs;
                if not (lEA.EAh in [EDREG,EIMED]) then InternalError0;
                OpS[0]:=$B100 + lEASize6 + lReg9 + CodeEA(rEA);
              end;
    codMUL,codDIV:
              begin //Signed version!!!!!
                if What=codMUL then OpS[0]:=$C1C0 else OpS[0]:=$81C0;
                if rEA.EAh<>EDREG then InternalError('Dn required');
                lEA.EASize:=easW;;;; //!!!
                Inc(OpS[0],rReg9+ CodeEA(lEA));
              end;
    codOR,codAND:
            begin
              SetLeftImmSizeFromRight;
              if lEA.EAh=EIMED then begin //xxxI
                case What of
                codOR:  OpS[0]:=$0000;
                codAND: OpS[0]:=$0200;
                end;
                if lEA.EASize<=easW then AddW(lEA.EAofs) else AddL(lEA.EAofs);
                inc(OpS[0],CodeEA(rEA) + lEASize6);
              end else begin
                if What=codOR then OpS[0]:=$8000 else OpS[0]:=$C000;
                if rEA.EAh<>EDREG then begin
                  SwapEAs; inc(OpS[0],$0100);
                end;
                if rEA.EAh<>EDREG then InternalError0;
                inc(OpS[0], lEASize6+ rReg9+ CodeEA(lEA));
              end;
            end;
    else    InternalError0;
    end;
    SetLength(OpS,OpInx);
    RetOpS:=OpS;
  except
    Debug('Error in CodeInstr:'+i2s(DagId68k));
    RAISE
  end;
end;

{**********************************************************************}
Function  DisAsm(mCode: Array of Word; C1,C2: Integer; Comment: String=''): String;
var
  OP,PC,LastW: Word;
  H6_7,H2,H9_10_11,H6_7_8,H3_4_5, Src,Dst: Byte;
  ShortOP: ShortInt;
function Get1w: Word;
begin
  if C1<=C2 then Result:=mCode[C1] else Result:=0;
  Inc(C1);
  LastW:=Result;
end;
function Get1L: LongWord;
begin
  Result:=(Get1w shl 16) + Get1w
end;
function Get1: SmallInt;
begin
  Result:=SmallInt(Get1w)
end;

function EA(ModeReg: Byte; Size: ShortInt=-1): String;
function OP2(S: String): String;
var B: ShortInt; S2: String; Ch: Char;
begin
  Get1w; Move(LastW,B,1);
  if (LastW and $0800)<>0 then S2:='.L' else S2:='.W';
  if (LastW and $8000)<>0 then Ch:='A' else Ch:='D';
  Result:=Format('%d(%s,%s%d%s)',[B,S,Ch,(LastW shr 12) and 7,S2]);
end;
var M,R: Byte;
begin {EA}
  Result:='???';
  M:=ModeReg shr 3; R:=ModeReg and 7;
  if Size=-1 then Size:=H6_7;
  Case M of
  0: Result:=Format('D%d',[R]);
  1: Result:=Format('A%d',[R]);
  2: Result:=Format('(A%d)',[R]);
  3: Result:=Format('(A%d)+',[R]);
  4: Result:=Format('-(A%d)',[R]);
  5: Result:=Format('%d(A%d)',[Get1,R]);
  6: Result:=OP2(Format('A%d',[R]));
  7: case R of
     0: Result:=Format('%d',[Get1]);
     1: Result:=Format('%d',[Integer(Get1L)]);
     2: begin
          Result:=Format('%d(PC)',[2+Get1]);
          Comment:=Comment+Format('$%x',[$FFFF and (2+LastW+PC)]);
        end;
     3: Result:=OP2('PC');
     4: case Size of
        0: Result:=Format('#$%.2x',[Lo(Get1w)]);              //B
        3, //For DIVS #nn,Dn
        1: Result:=Format('#%d',[Get1]);                      //W
        2: Result:=Format('#%d',[Integer(Get1L)]);            //L
        Else Result:=' ?? ';
        end;
     end;
  end;
end;

Function Size(B: Byte): String;
begin
  Case B and 3 of 0: Result:='.B'; 1: Result:='.W' else Result:='.L' end;
end;
Function SizeWL(B: Byte): String;
begin
  if odd(B) then Result:='.L' else Result:='.W'
end;
Function Cond(B: Byte): String;
const cc: Array[0..15] of String[2]=
  ('T ','F ','HI','LS','CC','CS','NE','EQ','VC','VS','PL','MI','GE','LT','GT','LE');
begin
  Result:=cc[B and 15];
end;
Function EADataEA: String;
begin
  case H6_7_8 of
  0,1,2: Result:=Format('%s %s,D%d',[Size(H6_7_8),EA(Src),H9_10_11]);
  4,5,6: Result:=Format('%s D%d,%s',[Size(H6_7_8),H9_10_11,EA(Src)]);
  3:     Result:=Format('.W %s,A%d',[EA(Src,1),H9_10_11]); //SUBA.W
  7:     Result:=Format('.L %s,A%d',[EA(Src,2),H9_10_11]); //SUBA.L
  end;
end;
function EaSrcSize: String;
begin
  Result:=Size(H6_7)+' '+EA(Src);
end;
function ImmToDestEASize: String;
begin
  if H6_7<=1 then Result:=Format('%s #%d,%s',[Size(H6_7),Get1,EA(Src)])
  else            Result:=Format('%s #%d,%s',[Size(H6_7),Get1L,EA(Src)]);
end;
function RegList(ToEA: Boolean): String;
var s16:  Set of 0..15; N: Integer;
begin
  Get1w; Move(LastW,S16,2);
  Result:='';
  if ToEA then for n:=0 to 15 do Result:=Result+chr(48+ord(N in S16))
  else         for n:=15 downto 0 do Result:=Result+chr(48+ord(N in S16));
end;
(******************************************************************************)
var
  S,S2: String;
  N,I: Integer;
  C0: Integer;
  W: Word;
  DoDebugName: Boolean;
Const
  //Str0: Array[0..7] of String=('OR','AND','SUB','ADD','???','EOR','CMP','MOVES');
  Shifts: Array[0..3] of String[3]=('AS','LS','ROX','RO');
  ShiftCnt: Array[0..7] of Byte=(8,1,2,3,4,5,6,7);
  //Str2: Array[0..7] of String=('
begin {DisAsm}
  Result:='';
  While C1<=C2 do begin
    C0:=C1; PC:=C0*2;
    Get1w;
    OP:=LastW; H2:=(OP shr 8) and 15;
    Move(OP,ShortOP,1); //SmallInt
    H9_10_11:=(OP shr 9) and 7;
    H6_7_8:=(OP shr 6) and 7; H6_7:=H6_7_8 and 3;
    H3_4_5:=(OP shr 3) and 7;
    Src:=OP and 63;
    Dst:=(OP shr 6) and 63; Dst:=(Dst shr 3) + ((Dst shl 3) and $38);
    DoDebugName:=False;
    S:='';
    if S='' then
      case OP of
      $4E71: S:='NOP';
      $4E72: S:='STOP';
      $4E75: begin S:='RTS'; DoDebugName:=True end;
      $4E76: S:='TRAPV';
      $4E40..$4E4E: S:=Format('TRAP %d',[OP and 15]);
      $4E4F: S:=Format('SysTrap $%.4x',[Get1w]);
      end;
    if S='' then
      case OP and $FFF8 of
      $4840: S:=Format('SWAP D%d',[OP and 7]);
      $4800: S:='NBCD '+Ea(Src);
      $4E50: S:=Format('LINK A%d,#%d',[OP and 7,Get1]);
      $4E58: S:=Format('UNLK A%d',[OP and 7]);
      end;
    if S='' then
      case OP and $FFC0 of
      $4E80: S:='JSR '+EA(Src);
      $4EC0: begin S:='JMP '+EA(Src); DoDebugName:= Src=16{x010 0000=JMP (A0)} end;
      end;
    if S='' then
      Case OP shr 8 of
      0:  S:='OR'+ImmToDestEASize;
      2:  S:='AND'+ImmToDestEASize;
      4:  S:='SUB'+ImmToDestEASize;
      6:  S:='ADD'+ImmToDestEASize;
      10: S:='EOR'+ImmToDestEASize;
      12: S:='CMP'+ImmToDestEASize;
      //14: S:='MOVES'+ImmToDestEASize;
      $40: if H6_7=3 then S:='MOVE SR,'+EA(Src) else S:='NEGX'+EaSrcSize;
      $41,$43,$45,$47,$49,$4b,$4d,$4e:
           S:=Format('LEA %s,A%d',[EA(Src),H9_10_11]);
      $42: if H6_7=3 then S:='MOVE CCR,'+EA(Src) else S:='CLR'+EaSrcSize;
      $44: if H6_7=3 then S:='MOVE '+EA(Src)+',CCR' else S:='NEG'+EaSrcSize;
      $46: if H6_7=3 then S:='MOVE '+EA(Src)+',SR' else S:='NOT'+EaSrcSize;
      $48: case H6_7_8 of
           1:   if H3_4_5>1 then S:='PEA '+EA(Src);
           2,3: if H3_4_5=0 then begin
                  if H6_7_8=2 then S:=Format('EXT.W D%d',[OP and 7])
                  else             S:=Format('EXT.L D%d',[OP and 7])
                end else
                  S:=Format('MOVEM%s %s,%s',[SizeWL(H6_7_8),RegList(True),EA(Src)]);
           end;
      $4A: S:='TST'+EaSrcSize;
      $4C: begin S:=RegList(False); S:=Format('MOVEM%s %s,%s',[SizeWL(H6_7_8),EA(Src),S]) end;
      end;
    if S='' then
      Case OP shr 12 of
      //0: S:=Str0[H9_10_11]+' '+EA(Src);
      0: case H6_7_8 of
         2: S:=Format('BCLR #%d,%s',[Get1,EA(Src)]);
         6: S:=Format('BCLR D%d,%s',[H9_10_11,EA(Src)]);
         3: S:=Format('BSET #%d,%s',[Get1,EA(Src)]);
         7: S:=Format('BSET D%d,%s',[H9_10_11,EA(Src)]);
         1: S:=Format('BCHG #%d,%s',[Get1,EA(Src)]);
         5: S:=Format('BCHG D%d,%s',[H9_10_11,EA(Src)]);
         end;
      1: S:='MOVE.B '+EA(Src,0)+','+EA(Dst,0);
      3: S:='MOVE.W '+EA(Src,1)+','+EA(Dst,1);
      2: S:='MOVE.L '+EA(Src,2)+','+EA(Dst,2);
      4: case H9_10_11 of
         0: Case H6_7_8 of
            0,1,2: S:='NEGX '+Size(H6_7_8)+EA(Src);
            3:     S:='MOVE SR,'+EA(Src);
            4,6:   S:='CHK xxx';
            //7:
            end;
         end;
      5: if H6_7=3 then begin
           if H3_4_5=1 then S:=Format('DB%s D%d,%d',[Cond(H2),OP and 7,Get1])
           else             S:=Format('S%s %s',[Cond(H2),EA(Src)]);
         end else begin
           if H9_10_11=0 then H9_10_11:=8;
           if (OP and $0100)=0 then S:=Format('ADDQ%s #%d,%s',[Size(H6_7),H9_10_11,EA(Src)])
           else                     S:=Format('SUBQ%s #%d,%s',[Size(H6_7),H9_10_11,EA(Src)]);
         end;
      6: begin //Bcc, BRA, BSR
           case H2 of 0: S:='BRA'; 1: S:='BSR' else S:='B'+Cond(H2) end;
           N:=ShortInt(Lo(OP)); if N=0 then N:=Get1;
           S:=Format('%s %.4x',[S,C0*2+N+2]);
         end;
      7: S:=Format('MOVEQ #%d,D%d',[ShortOP,H2 shr 1]);
      8: case H6_7_8 of
         4: S:='SBCD xx';
         3: S:=Format('DIVU %s,D%d',[EA(Src),H9_10_11]);
         7: S:=Format('DIVS %s,D%d',[EA(Src),H9_10_11]);
         else S:='OR'+EADataEA;
         end;
      9: case H6_7_8 of
         3,7: S:='SUB'+EADataEA; //SUBA!
         //5,6: S:='SUBX'; strange!!
         else S:='SUB'+EADataEA; //0,4
         end;
      11:case H6_7_8 of
         3,7:  S:='CMP'+EADataEA; //CMPA
         0..2: S:='CMP'+EADataEA; //.BWL
         5,6:  if H3_4_5=1 then S:=Format('CMPM%s (A%d)+,(A%d)+',[Size(H6_7),OP and 7,H9_10_11])
               else S:='EOR'+EADataEA;
         else S:='EOR'+EADataEA;
         end;
      12:case H6_7_8 of
         4: S:='ABCD xx';
         3: S:=Format('MULU %s,D%d',[EA(Src),H9_10_11]);
         7: S:=Format('MULS %s,D%d',[EA(Src),H9_10_11]);
         else (**** case H3_4_5 of
              0: S:=Format('EXG D%d,D%d',[H9_10_11,OP and 7]);
              1: case H6_7_8 of
                 5: S:=Format('EXG A%d,A%d',[H9_10_11,OP and 7]);
                 6: S:=Format('EXG D%d,A%d',[H9_10_11,OP and 7]);
                 end; (****)
              //else
                S:='AND'+EADataEA;
              //end;
         end;
      13:case H6_7_8 of
         3,7:   S:='ADD'+EADataEA; //ADDA
         ///4,5,6: S:='ADDX';
         else   S:='ADD'+EADataEA;
         end;
      14:begin
           if Odd(OP shr 8) then S:='L' else S:='R';
           case H6_7_8 of
           3,7: S:=Shifts[H9_10_11 and 3]+S+' '+EA(Src);
           else S:=Shifts[H3_4_5 and 3]+S+Size(H6_7);
                if odd(OP shr 5) then // i/r = count in reg
                  S:=Format('%s D%d,D%d',[S,H9_10_11,OP and 7])
                else //immcount
                  S:=Format('%s #%d,D%d',[S,ShiftCnt[H9_10_11],OP and 7]);
           end;
         end;
      end;
    if S='' then
      S:='??? ??';
    if DoDebugName then begin
      if C1<=C2 then begin
        W:=mCode[C1]; N:=Hi(W)-$80;
        if N in [1..16] then begin
          Comment:=Char(Lo(Get1W));
          for N:=1 to N div 2 do begin
            W:=Get1W; Comment:=Comment+Char(Hi(W))+Char(Lo(W));
          end;
        end;
      end;
      if C1<=C2 then if mCode[C1]=$4E71 then Get1W;
    end;

    for I:=Length(S) downto 1 do
      if S[I]=' ' then begin
        for N:=I to 7 do Insert(' ',S,N);
        BREAK
      end;
    S2:='';
    For N:=C0 to C1-1 do
      if N>C2 then S2:=S2+'???? ' else S2:=S2+Format('%.4x ',[mCode[N]]);
    S2:=Copy(S2+'          ',1,14);
    if Comment<>'' then
      S:=Copy(S+'                          ',1,26)+';'+Comment;
    {$ifdef VersionUI} Write(Format('%.4x: %s %s',[C0*2,S2,S])); {$Endif}
    Result:=Result+' ('+S+')';
    Comment:='';
  end;
end;

end.


