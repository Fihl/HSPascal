HSP 

Husk
  Include(set,element)
  Exclude()


CodePage 1252



procedure CaretPos(H: THandle; var Row, Column: Word);
begin
  Row := SendMessage(H, EM_LINEFROMCHAR, -1, 0);
  Column := LoWord(SendMessage(H, EM_GETSEL, 0, 0)) - SendMessage(H, EM_LINEINDEX, -1, 0);
end;


(***************************************************************
$(DELPHI)\Source\Vcl   HackRichEdit
@result

 b: byte; i: integer;
 longint(b) => moveq #0,d0 + move.b
 longint(i) => load I + ext.l d0
 Why does "case b of" signextend!!! insteadof moveq #0 first (See loadX(), xxOTyp^.TMAXV>127)

 ?? -Dxxx	Define conditionals   (is in doc, DocIntrn1)
 ?? -Oxxx	PRG & UNI directory
 ?? -Ixxx	Include directories


Typecast,   Inc(Longint(P), 4); 


 doc: ebnf, buildin, online crossrefference, standard pascal comparison
Exit handler
Make a buildin trap: "Debugger"

I would have expected the following code to have given me an error as 's' is
declared TWICE. (var S and procedure header S)

// tab= "	"
FSysStrCopy: //S:=Copy(S,N,N)
Err_InvDir: S:='Invalid compiler directive (ApplName was AppName???!!)';    //??????????????????????????????????

TEST:
g:=Longint(('l')) shl 24 or Longint('i') shl 16 or Longint('b') shl 8 or Longint('r');

No main code called => Crash in hspmain . CallInitCode

FIND does not work more than 80%
Redeclaration in VAR(x) of a proc(X: Integer);
SaveAs does not set name on tabsheet

CL not used in: Expres(var CL,Code: tDag): TypPtr;
NONO: AddSet elem + range => addRange(low,high: byte) high=0 => only
FWDCNT: Integer; NOT as global. Keep StringList of Src pos (names is ok)
Strings on stack
kCond not supported!


INSTALL:
To answer Mayank's question, the best way would be to connect to the
RPC port and send an RPC command to invoke the HostImportDatabase
function.  Information on doing this can be found in Debugger.html
that comes in the Emulator's "Docs" directory.
-- Keith

The (non-standard Pascal) optional construct to allow identifiers to be
qualified by the name of the unit that they are defined in
  UnitName.Identifier
e.g. Crt.Write(S)
would be useful to have in HS to avoid name-clashes.


Function l2s(I: Longint): String; // Long2String (32 bit)
var S: String;
begin
  Str(I,S);
  i2s:=S;  <<<< legal !!!! wrong code!!!!!!!!!!!!
end;


No error when using undeclared procs (declared, but no body)
Width of str(I:8,s) and str(R:8:2,s)

ASM: LEA MyProc,A0 make 0(pc),A0

kConst has int, real, string

Integer = 16bit

DATstr Save data i code segment

ABS =   BCLR #7,15,31 (Dn)
        BCLR #7,<EA>
SQRi = LoadI, mul Dn,Dn
     = pea, FSysSrqi
succ/pred = inc <EA>
odd= Load, shr, scs Dn, not Dn
sqt = pea, FSysSqrtR


include
exclude
format

String = SSTR!, not a type ID

In Delphi you write:
Const  // not Var
  XX: Integer = 47;
I could do this in my old Amiga/Atari versions.
But I have not come to this yet.

***************************************************************)


  eLinePos:          begin
                       Result:=i2s(Editor.CaretPos.X);
                       EXIT;
                       Start:=Editor.SelStart;
                       //Ch:=Editor.Text[Start];
                       While (Start>0) and (Editor.Text[Start]>=' ') do
                         Dec(Start);
                       N:=Editor.SelStart - Start +1;
                       Result:=i2s(N);
                     end;
  eLinePrev,
  eLineThis:         begin
                       N:=Editor.CaretPos.Y;
                       if What=eLinePrev then Dec(N);
                       if N<0 then N:=0;
                       Result:=Editor.Lines[N];
                       EXIT;
                       Start:=Editor.SelStart;
                       if What=eLinePrev then begin
                         While (Start>0) and (Editor.Text[Start]>=' ') do Dec(Start); //End on #10
                         While (Start>0) and (Editor.Text[Start]< ' ') do Dec(Start); //End on ';'
                       end;
                       for N:=Start downto 1 do
                         if Editor.Text[N]<' ' then BREAK else S:=Editor.Text[N]+S;
                       for N:=Editor.SelStart+1 to Max do
                         if Editor.Text[N]<' ' then BREAK else S:=S+Editor.Text[N];
                       Result:=S;
                     end;

