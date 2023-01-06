// 6.7.1-7, 6.7.2.2-3, 6.7.2.4-2, 6.7.2.4-5
program PVScon(Output);
{$define SkipAlways}
{$define SkipMaybe}
{xxx$define dolater}
{$define dolater2}

Uses Crt, HSUtils, SystemMgr;

{$D+,R+,L+}

Procedure FAIL(Const S: String);
var N: Integer; var s2: string;
begin
  writeln('F-'+S);
  N:=SysTaskDelay(SysTicksPerSecond);
end;
Procedure PASS(Const S: String);
begin
  //Writeln('P-'+S);
end;
Procedure FAILPALM(Const S: String); begin end;

Procedure WrLn(Const S: String);
begin
  //Writeln('Q-'+S);
end;


{TEST 6.1.1-1, CLASS=CONFORMANCE}

{: This test checks that matching upper-case and lower-case
   letters are equivalent in identifiers and word-symbols
    if they are permitted. }
{  This test does not apply to processors with only one
   letter-case. }
{V3.1: Output of FAIL added. }

procedure t6p1p1d1;
var
   conform  : integer;

Begin
   BEGIN
      Conform:=1;
      CONFORM:=2;
      If conform = 2 then
         PASS('6.1.1-1')
      else
         FAIL('6.1.1-1')
   enD
end;


{TEST 6.1.1-2, CLASS=CONFORMANCE}

{: This test checks that upper-case and lower-case exponent-markers
   are equivalent. }
{  This test is not relevant to processors with only
   one letter-case. }
{V3.0: Reclassified and revised when DP7185 corrected this
   loophole in earlier drafts.  Moved from test 6.1.5-6 to
   current position to correspond to DP7185. }

procedure t6p1p1d2;
var
   i : real;
begin
   { Additionally we assume that equality tests OUGHT to work under
     the conditions in this program. }
   i:=123e2;
   if i = 123E2 then
      PASS('6.1.1-2')
   else
      FAIL('6.1.1-2')
end;


{TEST 6.1.2-1, CLASS=CONFORMANCE}

{: This test checks that identifiers and word-symbols are correctly
   distinguished in cases where the two are 'close' in a sense which
   has been found to be important. }
{  Note that this test is relevant even to processors that practice
   8-character identifier truncation, as they still have the
   responsibility to recognize the reserved word set correctly. }
{V3.0: Comment and program changed due to change in DP7185.
   Test now avoids the loophole which allowed deviant processors
   to ignore it, due to masking effect of identifiers which had
   the same first eight characters. Was previously 6.1.2-3. }

procedure t6p1p2d1;
var
   functionx,functiom:integer;
   iffy:boolean;

procedure procedur(var procedurf:integer);
begin
   procedurf := 10
end;

function functio(procedurex:integer):integer;
begin
   functio := procedurex
end;

begin
   iffy:=true;
   procedur(functionx);
   functiom := functio(functionx);
   if iffy and (functiom = 10) then
      PASS('6.1.2-1')
   else
      FAIL('6.1.2-1')
end;


{TEST 6.1.2-3, CLASS=CONFORMANCE}

{: This test checks the implementation of the .. token. }
{  If the lexical analyser of a Pascal processor is entirely
   separate from the syntax analysis, a three-character
   lookahead may be required to recognize the .. token when it
   immediately follows an integer.  (Processors which know that
   only integers are valid in the context may not need to look
   ahead.)  This test checks that the processor recognizes the
   situation correctly - it occurs frequently elsewhere in the
   package also. }
{V3.0: New test derived from 6.1.2-8. }

procedure t6p1p2d3;
type
   t = 8..15;
var
   m : t;
begin
   m := 11;
   PASS('6.1.2-3')
end;


{TEST 6.1.3-1, CLASS=CONFORMANCE}

{: This test checks that identifiers of length up
   to 70 characters are accepted. }
{  The Pascal Standard permits identifiers to be of any length. }
{V3.0: Write on failure modified. }

procedure t6p1p3d1;
const
   i10iiiiiii = 10;
   i20iiiiiiiiiiiiiiiii = 20;
   i30iiiiiiiiiiiiiiiiiiiiiiiiiii = 30;
   i40iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii = 40;
   i50iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii = 50;
   i60iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii = 60;
i70iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
                                                                = 70;

begin
   if i10iiiiiii + i20iiiiiiiiiiiiiiiii +
      i30iiiiiiiiiiiiiiiiiiiiiiiiiii +
      i40iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii +
      i50iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii +
      i60iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii +
i70iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
      <> 280 then
      FAIL('6.1.3-1')
   else
      PASS('6.1.3-1')
end;


{TEST 6.1.3-2, CLASS=CONFORMANCE}

{: This program attempts to identify deviant processors by using
   two identifiers which differ in a way that will slip through
   several implementations. }
{  The Standard does not set a limit on the length of identifiers,
   nor does it permit processors to treat different identifiers as
   equivalent.  Accordingly, processors that ignore characters in
   identifiers after the eighth (or tenth, sixteenth, etc) do not
   strictly conform to the Standard. }
{V3.0: Test reclassified to become CONFORMANCE due to
   change in DP7185.  Comment rewritten, and identifiers chosen
   to maximize detection of truncation, hashing, and tail
   preservation.  Was test 5.2.2-1. The test which was previously
   6.1.3-2 has been moved to 6.1.1-1 due to a change in DP7185
   wording. }

procedure t6p1p3d2;
const
   valueofaverylongidentifierwithatail = 10;

procedure p;
var
   valueofaverylongidentifieraithwtail:integer;
begin
   valueofaverylongidentifieraithwtail:=11;
   if valueofaverylongidentifierwithatail <>
      valueofaverylongidentifieraithwtail then
      PASS('6.1.3-2')
   else
      FAIL('6.1.3-2')
end;

begin
   p
end;


{TEST 6.1.6-1, CLASS=CONFORMANCE}

{: This program simply tests if labels are permitted. }
{V3.0: Test revised so as to include the limits of the closed
   interval of 'apparent values' by which labels are distinguished. }

procedure t6p1p6d1;
label
   0,2,3,L4,9999;
var
   x:(a,b,c,d,e,f);
begin
      x := a;
      goto L4;
   0: inc(x);
      goto 9999;
   2: inc(x);
      goto 3;
   3: inc(x);
      goto 0;
   L4: inc(x);
      goto 2;
9999: inc(x);
      if x = f then
         PASS('6.1.6-1')
      else
         FAIL('6.1.6-1')
end;


{TEST 6.1.6-3, CLASS=CONFORMANCE}

{: This test contains a label made up of five digits and whose
   integral value is less than 10000. }
{  A label is a digit-sequence whose admissibility is determined
   by its apparent integral value.  Thus the label in this program
   is correct Pascal.  Some deviant processors may limit labels
   to four digits alone, which is not correct. }
{V3.0: New test derived from DP7185. }

procedure t6p1p6d3;
label
   09876;
begin
   goto 09876;
09876:
   PASS('6.1.6-3')
end;


{TEST 6.1.7-1, CLASS=CONFORMANCE}

{: This test checks the implementation of the required type-char. }
{  Character strings consisting of a single character
   are the constants of the standard type char. }
{V3.0: Writing made to conform to conventions, and comment
   revised. }

procedure t6p1p7d1;
const
   one = '1';
   two = '2';
var
   twotoo : char;
begin
  if (one <> two) and (two = '2') then begin
    twotoo:='2';
    if twotoo = two then
       PASS('6.1.7-1')
    else
       FAIL('6.1.7-1')
    end
  else
    FAIL('6.1.7-1')
end;


{TEST 6.1.8-1, CLASS=CONFORMANCE}

{: This test checks that a comment may be used as a token separator. }
{V3.0: Comment revised. }

procedure{ Can this be here. }t6p1p8d1{ Or here. };
var
   i{ control variable }:{ colon }integer{ type };
begin
   for{ This is a FOR loop }i{ control variable }:={ assignment }
      1{ initial }to{ STEP 1 UNTIL }1{ final }do{ GO }
         PASS{ write statement }('6.1.8-1')
end;


{TEST 6.1.8-2, CLASS=CONFORMANCE}

{: This program checks that an open comment delimiter can appear
   in a comment. }
{V3.0: Comment revised due to change in DP7185. }

procedure t6p1p8d2;
begin
   { Is a { permitted in a comment. }
   PASS('6.1.8-2')
end;


{TEST 6.1.9-2, CLASS=CONFORMANCE}

{: This test includes a valid comment which may confuse a
   processor with the ( * ) sequence. }
{  Processors are not allowed to ignore one form of comment
   delimiter unless they do not have the appropriate characters
   in their set. }
{V3.0: New test derived from DP7185. }

procedure t6p1p9d2;
var
   b:boolean;
begin
   b := false;
   (*)
   b := true;
   (* The above 'statement' is commentary. *)
   if b then
      FAIL('6.1.9-2')
   else
      PASS('6.1.9-2')
end;


{TEST 6.1.9-3, CLASS=CONFORMANCE}

{: This test includes a variety of curious comments which
   exercise the lexical analyser of a Pascal processor. }
{  All are correct Pascal, and the program should be acceptable
   to a Pascal processor. Processors are not allowed
   to ignore one form of comment delimiter unless they
   do not have the appropriate characters in their set. }
{V3.0: New test derived from DP7185. }

procedure t6p1p9d3;
var
   i:0..10;
begin
   i:=0;    (* *)
   i:=i+1;  (* **)
   i:=i+1;  (* ***)
   i:=i+1;  (* ****)
   i:=i+1;  (* (*)
   i:=i+1;  {}
   i:=i+1;  {******}
   i:=i+1;  (**)
   i:=i+1;  { {{ (* (*** }
   i:=i+1;  (* (*(* { ** ) *)
   i:=i+1;
   if (((i=10))) then
      PASS('6.1.9-3')
   else
      FAIL('6.1.9-3')
end;


{TEST 6.2.1-1, CLASS=CONFORMANCE}

{: This program includes a sample of each declaration
   part in its minimal form. }
{  Every possibility is covered elsewhere in the validation suite,
   but the test is made here. }
{V3.1: Output of FAIL addded. }

procedure t6p2p1d1;
label
   1;
const
   one = 1;
type
   small = 1..3;
var
   tiny : small;
procedure p(var x : small);
begin
   x:=1
end;
begin
   goto 1;
1: p(tiny);
   if (tiny = one) then
      PASS('6.2.1-1')
   else
      FAIL('6.2.1-1')
end;


{TEST 6.2.1-2, CLASS=CONFORMANCE}

{: This program checks that repeated declarations are possible
   in the declaration parts. }
{  Practically all occurrences will re-appear elsewhere in the
   validation suite. }
{V3.1: Output of FAIL added. }

procedure t6p2p1d2;
label
   1,2,3;
const
   one=1;
   two=2;
   three=3;
type
   small = 1..3;
   larger = 1..10;
   biggest = 1..100;
var
   tiny : small;
   soso : larger;
   big : biggest;
procedure p(var x : small);
begin
   x:=1
end;
procedure q(var y : larger);
begin
   y:=2
end;
procedure r(var z : biggest);
begin
   z:=3
end;
begin
   p(tiny); goto 2;
1: r(big); goto 3;
2: q(soso); goto 1;
3: if (tiny=one) and (soso=two) and (big=three) then
      PASS('6.2.1-2')
   else
      FAIL('6.2.1-2')
end;


{TEST 6.2.2-1, CLASS=CONFORMANCE}

{: This program tests the scope conformance of the processor
   for identifiers. }
{  The Pascal Standard permits redefinition of an identifier by
   a further defining point in a region (eg. procedure block)
   enclosed by the first scope. This second region
   (and all regions enclosed by it) are excluded from the scope of
   the defining point of the first region. }
{V3.0: Comment changed - 'identifier' not 'user name'. }

procedure t6p2p2d1;
const
   range = 10;
var
   i : integer;
   dopass : boolean;
procedure redefine;
const
   range = -10;
var
   i : integer;
begin
   i:=range
end;

begin
   i:=1;
   dopass:=false;
   redefine;
   if range=-10 then
      FAIL('6.2.2-1')
   else
      dopass:=true;
   if i=-10 then
      FAIL('6.2.2-1')
   else
      if dopass then
         PASS('6.2.2-1')
end;


{TEST 6.2.2-2, CLASS=CONFORMANCE}

{: This test checks if a predefined identifier can be redefined. }
{V3.0: Failure message altered to give reason. }

procedure t6p2p2d2;
var
   true : boolean;
begin
   true:=false;
   if true = false then
      PASS('6.2.2-2')
   else
      FAIL('6.2.2-2')
end;


{TEST 6.2.2-3, CLASS=CONFORMANCE}

{: This test checks the scope conformance of pointer-types. }
{  This program is similar to 6.2.2-6, however a type identifier,
   say T, which specifies the domain of a pointer type ^T, is
   permitted to have its defining point anywhere in the type
   definition part in which ^T occurs.
   Thus in this example, (node=integer)s' scope is excluded from the
   type definition of ouch. }
{V3.1: Real changed to integer. }

procedure t6p2p2d3;
type
   node = integer;
procedure ouch;
type
   p = ^node;
   node = boolean;
var
   ptr : p;
begin
   new(ptr);
   ptr^:=true;
   Dispose(ptr);
   PASS('6.2.2-3');
end;
begin
   ouch
end;

{TEST 6.2.2-4, CLASS=CONFORMANCE}

{: This test checks that labels are allowed to be redefined
   in a region enclosed by the first scope. }
{V3.0: Comment changed and write extended. Was previously 6.2.2-5. }

procedure t6p2p2d4;
label
   4,5,6;
var
   i : integer;
procedure redefine;
label
   6,7,8;
var
   j : integer;
begin
      j:=1;
      goto 6;
   7: j:=j-1;
      goto 8;
   6: j:=j+1;
      goto 7;
   8: j:=0
end;

begin
      goto 4;
   5: i:=i+1;
      goto 6;
   4: i:=1;
      redefine;
      goto 5;
   6: if i=1 then
         FAIL('6.2.2-4')
      else
         PASS('6.2.2-4')
end;

{TEST 6.2.2-5, CLASS=CONFORMANCE}

{: This test checks the scope conformance of records. }
{  As for the other conformance tests in this section,
   it is possible to redefine a field-identifier of a record within
   the same scope as this record. }
{V3.0: Failure message altered to give reason.
   Was previously 6.2.2-6. }

procedure t6p2p2d5;
var
   j : integer;
   x : record
         j:integer
       end;
begin
   j:=1;
   x.j:=2;
   with x do
      j:=3;
   if (j=1) and (x.j=3) then PASS('6.2.2-5')
   else  FAIL('6.2.2-5')
end;


{TEST 6.2.2-6, CLASS=CONFORMANCE}

{: This test checks that a value can be assigned to a
   function-identifier anywhere in the block of the function. }
{  This test assigns the function-identifier a value from within a
   function declared within the function block, which is allowed.
   Some processors may erroneously restrict such assignments
   to the statement-part of the function-block. }
{V3.0: Note deleted from PASS message and comment revised.
   Was previously 6.2.2-8. }

procedure t6p2p2d6;
var
   j,k:integer;

function f1(i:integer):integer;
   function f2(i:integer):integer;
      function f3(i:integer):integer;
      begin
         f3:=1;
         f1:=i
      end;
   begin
      f2:=f3(i);
   end;
begin
   j:=f2(i)
end;

begin
   k:=f1(5);
   if (k=5) then
      PASS('6.2.2-6')
   else
      FAIL('6.2.2-6')
end;


{TEST 6.2.2-7, CLASS=CONFORMANCE}

{: This program hides part of a type while leaving other parts
   accessible. }
{V3.0: Comment revised and writes rewritten. Was previously 6.2.2-10.}

procedure t6p2p2d7;
type
   colour=(red,amber,green);
var
   c:colour;

procedure nested;
type
   colour=(purple,red,blue);
var
   paint:colour;
begin
   c:=green;
   paint:=red;
   c:=pred(amber);
   if (ord(c)<>0) or (ord(paint)<>1) then
      FAIL('6.2.2-7')
end;

begin
   nested;
   if (c<> red) then
      FAIL('6.2.2-7')
   else
      PASS('6.2.2-7')
end;


{TEST 6.3-1, CLASS=CONFORMANCE}

{: This program exhibits all legal productions for a constant
   in a constant-definition. }
{V3.0: Added value check, and changed identifier 'minustentoo'
   to 'minustoo' so as to avoid non-uniqueness in first
   eight characters. }

procedure t6p3d1;
const
   ten = 10;
   minusten = -10;
   minustoo = -ten;
   decade = ten;
   dot = '.';
   stars = '****';
   on = true;
   pi = 3.1415926;
   minuspi = - pi;
begin
   if (stars = '****') then pass('string');
   if (ten + minusten + decade + minustoo = 0) and
      (dot = '.') and (stars = '****') and
      (on =true) and (abs(pi+minuspi) < 0.001) then
      PASS('6.3-1')
   else
      FAIL('6.3-1')
end;


{TEST 6.4.1-1, CLASS=CONFORMANCE}

{: This program tests to see that pointer-types can be
   declared anywhere in the type-definition-part. }
{  This freedom is explicitly permitted in the Standard. }
{V3.1: Real changed to integer. }

procedure t6p4p1d1;
type
  ptr1     = ^ polar;
  polar    = record r,theta : integer end;
  purelink = ^ purelink;
  ptr2     = ^ person;
  ptr3     = ptr2;
  person   = record
               mother,father : ptr2;
               firstchild    : ptr2;
               nextsibling   : ptr3
             end;
begin
  PASS('6.4.1-1')
end;


{TEST 6.4.2.2-1, CLASS=CONFORMANCE}

{: This program tests that the standard simple types have all
   been implemented. }
{  They are denoted by predefined type identifiers. }
{V3.0: Value check added. Comment and write in case
   of failure revised. }

procedure t6p4p2p2d1;
var
   a : integer;
   b : real;
   c : boolean;
   d : char;
begin
   a:=6*2+3;
   b:=3.14159*2;
   c:=(a=15);
   d:='Z';
   if (a = 15) and (b < 6.284) and (b > 6.282) and (c =true) and (d = 'Z') then
      PASS('6.4.2.2-1')
   else
      FAIL('6.4.2.2-1')
end;


{TEST 6.4.2.2-2, CLASS=CONFORMANCE}

{: This test checks that the values within the range
   -maxint..+maxint are values of integer type. }
{V3.0: Value check added. Write in case of failure revised. }

procedure t6p4p2p2d2;
type
  natural = 0..maxint;
  whole = -maxint..+maxint;
var
   i : natural;
   j : whole;
   k : integer;
begin
   i:=maxint;
   j:=-maxint;
   k:=maxint;
   if (i = k) and (k = -j) and (k > j) then
      PASS('6.4.2.2-2')
   else
      FAIL('6.4.2.2-2')
end;


{TEST 6.4.2.2-3, CLASS=CONFORMANCE}

{: This test checks that the required constant identifiers, true
   and false, have been correctly enumerated. }
{  The Pascal Standard states that type boolean shall have
   enumeration values which are denoted by false and true, such
   that false is the predecessor of true.  It also states that
   the ord of these values are 0 and 1 respectively. }
{V3.1: Comment changed. }

procedure t6p4p2p2d3;
begin
   if (pred(true)=false) and (succ(false)=true) and
      (ord(false)=0) and (ord(true)=1) and
      (false < true)  and (ord(not false)=1) then
      PASS('6.4.2.2-3')
   else
      FAIL('6.4.2.2-3')
end;


{TEST 6.4.2.2-4, CLASS=CONFORMANCE}

{: This test checks that the character values representing
   the digits 0..9 are ordered and contiguous. }
{V3.0: Write in case of failure revised. }

procedure t6p4p2p2d4;
var
   a,b : boolean;
begin
   a:=(succ('0') = '1') and
      (succ('1') = '2') and
      (succ('2') = '3') and
      (succ('3') = '4') and
      (succ('4') = '5') and
      (succ('5') = '6') and
      (succ('6') = '7') and
      (succ('7') = '8') and
      (succ('8') = '9') ;
   b:=('0' < '1') and
      ('1' < '2') and
      ('2' < '3') and
      ('3' < '4') and
      ('4' < '5') and
      ('5' < '6') and
      ('6' < '7') and
      ('7' < '8') and
      ('8' < '9') ;
   if a and b then
      PASS('6.4.2.2-4')
   else
      FAIL('6.4.2.2-4')
end;


{TEST 6.4.2.2-5, CLASS=CONFORMANCE}

{: This test checks the ordering of the upper-case letters A-Z. }
{  The Pascal Standard states that the upper-case letters A-Z are
   ordered, but not necessarily contiguous.
   This program determines if this is so, and prints
   a message as to whether the processor passes or not.
   The test is not relevant to processors that do not implement
   a set of upper-case letters. }
{V3.0: Comment edited to reflect implementation-defined status
   of upper-case letters.  Write on failure revised. }

procedure t6p4p2p2d5;
begin
   if ('A' < 'B') and ('B' < 'C') and ('C' < 'D') and
      ('D' < 'E') and ('E' < 'F') and ('F' < 'G') and
      ('G' < 'H') and ('H' < 'I') and ('I' < 'J') and
      ('J' < 'K') and ('K' < 'L') and ('L' < 'M') and
      ('M' < 'N') and ('N' < 'O') and ('O' < 'P') and
      ('P' < 'Q') and ('Q' < 'R') and ('R' < 'S') and
      ('S' < 'T') and ('T' < 'U') and ('U' < 'V') and
      ('V' < 'W') and ('W' < 'X') and ('X' < 'Y') and
      ('Y' < 'Z') then
      PASS('6.4.2.2-5')
   else
      FAIL('6.4.2.2-5')
end;


{TEST 6.4.2.2-6, CLASS=CONFORMANCE}

{: This test checks the ordering of the lower-case letters a-z. }
{  The Pascal Standard states that the lower-case letters a-z are
   ordered, but not necessarily contiguous.
   This program determines if this is so, and prints
   a message as to whether the processor passes or not.
   The test is not relevant to processors that do not implement
   a set of lower-case letters. }
{V3.0: Comment edited to reflect implementation-defined status
   of lower-case letters.  Write on failure revised. }

procedure t6p4p2p2d6;
begin
   if ('a' < 'b') and ('b' < 'c') and ('c' < 'd') and
      ('d' < 'e') and ('e' < 'f') and ('f' < 'g') and
      ('g' < 'h') and ('h' < 'i') and ('i' < 'j') and
      ('j' < 'k') and ('k' < 'l') and ('l' < 'm') and
      ('m' < 'n') and ('n' < 'o') and ('o' < 'p') and
      ('p' < 'q') and ('q' < 'r') and ('r' < 's') and
      ('s' < 't') and ('t' < 'u') and ('u' < 'v') and
      ('v' < 'w') and ('w' < 'x') and ('x' < 'y') and
      ('y' < 'z') then
      PASS('6.4.2.2-6')
   else
      FAIL('6.4.2.2-6')
end;


{TEST 6.4.2.2-7, CLASS=CONFORMANCE}

{: This test explores the use of type-char as an enumeration-type. }
{  The Standard specifies that the ord of the first character in
   the char type shall be zero, and that the rest shall have
   consecutive ordinal values.  However, there is no easy way
   to find the last character in the set, and the function
   maxord is an approximation to this.  It uses known facts about
   character sets to guess at the set and make a first attempt
   at finding this value.  If a processor does not comply with the
   assumptions, maxord may have to be recoded to return the correct
   value for that processor.
   The test uses type  char in a number of enumeration contexts. }
{V3.1: Unnecessary defect removed. }

procedure t6p4p2p2d7;
type
   atype=array[char]of char;
   natural=0..maxint;
var
   ordi:natural;
   maxchar:char;
   a,b:atype;
   ch:char;
   ok:boolean;

function maxord:natural;
   function max(a,b:char):char;
   begin
      if a>b then max:=a else max:=b
   end; { of max }
begin
  if ord('9') = 249 then      { EBCDIC }            maxord:=255
  else if ord('9') = 57 then  { ASCII/ISO }         maxord:=127
  else                        { UNKNOWN char set }  maxord:=ord(max(';',max('Z',max('z','9'))))
end;

begin
   ok := true;
   maxchar := chr(maxord);
   for ordi:=0 to ord(maxchar) do
      a[chr(ordi)]:=chr(ordi);
   for ch := chr (0) to maxchar do
      b [ch] := a [ch];
   for ch:=chr(0) to maxchar do
      if b[ch] <> ch then ok:=false;
   for ordi:=1 to ord(maxchar) do
      if (pred(chr(ordi)) <> chr(pred(ordi))) or
      (succ(chr(pred(ordi))) <> chr(ordi)) then
         ok := false;
   if ok then
      PASS('6.4.2.2-7')
   else
      FAIL('6.4.2.2-7')
end;


{TEST 6.4.2.2-8, CLASS=CONFORMANCE}

{: This test checks that ord of an integer is the integer
   itself. }
{V3.0: New test. }

procedure t6p4p2p2d8;
var
   result:(dopass,dofail);
   i:integer;
begin
   result:=dopass;
   for i:=-100 to +100 do
      if ord(i) <> i then result:=dofail;
   if (ord(-0) <> 0) or (ord(maxint) <> maxint) or
      (ord(-maxint) <> -maxint) then result := dofail;
   if result=dopass then
      PASS('6.4.2.2-8')
   else
      FAIL('6.4.2.2-8')
end;


{TEST 6.4.2.3-1, CLASS=CONFORMANCE}

{: This program checks the possible syntax productions for
   enumerated types. }
{V3.0: Comment revised. }

procedure t6p4p2p3d1;
type
   singularitytype = (me);
   switch          = (on,off);
   maritalstatus   = (married,divorced,widowed,single);
   colour          = (red,pink,orange,yellow,green);
   cardsuit        = (heart,diamond,spade,club);
var
   i : singularitytype;
begin
   i:=me;
   PASS('6.4.2.3-1')
end;


{TEST 6.4.2.3-2, CLASS=CONFORMANCE}

{: This test checks ordering of an enumerated-type. }
{  The Pascal Standard states that the ordering of the values
   of the enumerated-type is determined by the sequence in which
   the constants are listed, the first being before the last.
   The Standard also specifies the ordinal values. }
{V3.0: Added succ(succ(succ(club))). Comment and writing
   revised to conform to conventions, and test revised to check
   that the ordinal values also conform. }

procedure t6p4p2p3d2;
var
   suit : (club,spade,diamond,heart);
   a    : boolean;
   b    : boolean;
   c    : boolean;
begin
   a:=(succ(club)=spade) and
      (succ(spade)=diamond) and
      (succ(diamond)=heart) and
      (succ(succ(succ(club))) = heart);

   b:=(club < spade) and
      (spade < diamond) and
      (diamond < heart);

   c:=(ord(club)=0) and (ord(spade)=1) and
      (ord(diamond)=2) and (ord(heart)=3);

   if a and b and c then
      PASS('6.4.2.3-2')
   else
      FAIL('6.4.2.3-2')
end;


{TEST 6.4.2.3-3, CLASS=CONFORMANCE}

{: This program illustrates the difficulties of when a type is
   defined. }
{  It is valid Pascal, since the uses follow
   the defining point. }
{V3.0: New test. }

procedure t6p4p2p3d3;
var
   x: array [(male, female), male .. female ] of integer;
begin
  x[male, male] := 1;
  if x[pred(female), pred(female)] <> 1 then
    FAIL('6.4.2.3-3')
  else
    PASS('6.4.2.3-3')
end;


{TEST 6.4.2.3-4, CLASS=CONFORMANCE}

{: This program illustrates the difficulties of when a type
   is defined. }
{  Similar to 6.4.2.3-3, but for records rather than arrays. }
{V3.0: New test. }

procedure t6p4p2p3d4;
var
   x: record
      a: (male, female);
      b: male .. female
      end;
begin
   x.a := pred(female);
   x.b := succ(x.a);
   if pred(x.b) <> male then
      FAIL('6.4.2.3-4')
   else
      PASS('6.4.2.3-4')
end;


{TEST 6.4.2.4-1, CLASS=CONFORMANCE}

{: This program tests that a type may be defined as a subrange
   of another ordinal-type (host-type). }
{V3.0: Comment revised. }

procedure t6p4p2p4d1;
type
   colour      = (red,pink,orange,yellow,green,blue);
   somecolour  = red..green;
   century     = 1..100;
   twentyone   = -10..+10;
   digits      = '0'..'9';
   zero        = 0..0;
   logical     = false..true;
var
   tf : logical;

begin
   tf:=true;
   PASS('6.4.2.4-1')
end;


{TEST 6.4.2.4-2, CLASS=CONFORMANCE}

{: This test checks that the ordinal values of a
   variable of subrange-type correspond to the host-type. }
{  Even if a variable is of a subrange type, the values it may
   take on are of its host enumeration type. }
{V3.0: New test to check ord on subranges. }

procedure t6p4p2p4d2;
type
   chesstype=(pawn,knight,bishop,castle,queen,king);
   piece=knight..king;
   century=1901..2000;
var
   year:century;
   which:piece;
begin
   year:=1980;
   which:=knight;
   if (ord(year)=1980) and (ord(which)=1) then
      PASS('6.4.2.4-2')
   else
      FAIL('6.4.2.4-2')
end;


{TEST 6.4.3.1-1, CLASS=CONFORMANCE}

{: This test checks that array, set, file and
   record types can be declared as packed. }
{V3.0: Comment revised. Was previously 6.4.3.1-3. }

procedure t6p4p3p1d1;
type
   urray    = packed array[1..10] of char;
   rekord   = packed record
                  bookcode : integer;
                  authorcode : integer
              end;
   {$IfNdef SkipAlways} fyle = packed file of urray; {$endif}
   card     = (heart,diamond,spade,club);
   sett     = packed set of card;
begin
   PASS('6.4.3.1-1')
end;


{TEST 6.4.3.1-2, CLASS=CONFORMANCE}

{: This program checks if packing is propagated throughout
   an array with multiple-indices. }
{  The Pascal Standard specifies that the packed prefix in front
   of a multiple-index array-type declaration is propagated
   to all levels of the array.  This is difficult to test
   except by exercising deviance tests on the processor by
   attempting to use such a packed object in unsuitable
   contexts.  However, in the case of arrays of char the
   residual structural compatibility allows a conformance test to
   be designed. }
{V3.0: New test to test packing propagation. }

procedure t6p4p3p1d2;
type
   table=packed array[0..99,1..12] of char;
var
   t:table;
   i:0..99;
begin
{$IfNdef SkipMaybe}
   for i:=0 to 99 do t[i]:='123456789012';
          000B12BE   EXT.W     D0                                        | 4880 
          000B12C0   MULS.W    #$0C,D0                                   | C1FC 000C 
          000B12C4   PEA       *+$0036                     ; 000B12FA    | 487A 0034 
!!!!!     000B12C8   PEA       $50(A6,D0.W)                              | 4876 0050
          000B12CC   MOVE.W    #$000C,-(A7)                ; '..'        | 3F3C 000C
          000B12D0   BSR.W     *+$0042                     ; 000B1312    | 6100 0040
{$endif}
   PASS('6.4.3.1-2')
end;


{TEST 6.4.3.2-1, CLASS=CONFORMANCE}

{: This program tests all the valid productions for an
   array declaration from the syntax. }
{V3.0: Comment revised. Three-dimensional array added. }

procedure t6p4p3p2d1;
type
   t1          = 0..1;
   cards       = (two,three,four,five,six,seven,eight,nine,ten,jack,
                  queen,king,ace);
   suit        = (heart,diamond,spade,club);
   hand        = array[cards] of suit;
   picturecards= array[jack..king] of suit;
   played      = array[cards] of array[heart..diamond] of boolean;
   playedtoo   = array[cards,heart..diamond] of boolean;
   a3          = array[t1] of array[t1] of array[t1] of boolean;
begin
   PASS('6.4.3.2-1')
end;


{TEST 6.4.3.2-2, CLASS=CONFORMANCE}

{: This test checks that an index-type may be an
   ordinal-type. }
{  BOOLEAN, CHAR, INTEGER and some user-defined type
   names can be used as an index type.
   This program tests if the processor will permit these
   except for INTEGER, which is included in a separate program. }
{V3.0: Value check added. Write revised.
   Was previously 6.4.3.2-3 }

procedure t6p4p3p2d2;
type
   digits   = '0'..'9';
   colour   = (red,pink,orange,yellow);
   intensity   = (bright,dull);
var
   alltoo   : array[boolean] of boolean;
   numeric  : array[digits] of integer;
   colours  : array[colour] of intensity;
   dcode    : array[char] of digits;
begin
   numeric['0']:=0;
   colours[pink]:=bright;
   alltoo[true]:=false;
   dcode['A']:='0';
   if (numeric['0'] = 0) and (colours[pink] = bright) and
      (alltoo[true] = false) and (dcode['A'] = '0') then
      PASS('6.4.3.2-2')
   else
      FAIL('6.4.3.2-2')
end;


{TEST 6.4.3.3-1, CLASS=CONFORMANCE}

{: This program simply tests that all valid productions from
   the syntax for record-types are accepted by this processor. }
{V3.0: According to DP7185 'd = record ; end' is syntactically
   incorrect. Test the empty record. Also, record
   definition nesting to three deep included. }

procedure t6p4p3p3d1;
type
   streng   = packed array[1..25] of char;
   married  = (false,true);
   shape    = (triangle,rectangle,square,circle);
   angle    = 0..90;
   a        = record
               year : integer;
               month : 1..12;
               day : 1..31
              end;
   b        = record
               name,firstname : streng;
               age : 0..99;
               case  married of
                  true: (spousename : streng);
                  false : ()
              end;
   c        = record
               case s : shape of
                  triangle : (side : real;
                              inclination,angle1,angle2 : angle);
                  square,rectangle : (side1,side2 : real;
                                      skew,angle3 : angle);
                  circle : (diameter : real)
              end;
   d        = record
              end;
   e        = record
                case married of
                  true : (spousename : streng);
                  false : ()
                end;
   f        = record
               i1 : integer;
               r1 : record
                     i2 : integer;
                     r2 : record
                           i3 : integer
                          end
                    end
              end;
begin
   PASS('6.4.3.3-1')
end;


{TEST 6.4.3.3-2, CLASS=CONFORMANCE}

{: This test checks that a field-identifier can be redefined. }
{  The Pascal Standard states that the occurrence of a field
   identifier within the identifier list of a record section is
   its defining point as a field identifier for the record
   type in which the record section occurs.
   This should allow redefinition of a field identifier in another
   type declaration. }
{V3.0: Comment revised, and test code added. }

procedure t6p4p3p3d2;
type
   a     = record
            realpart : real;
            imagpart : real
           end;
   realpart = (notimaginary,withbody,withsubstance);
var
   var1 : a;
   var2 : realpart;
begin
   with var1 do
      realpart := 1.0;
   var2 := withbody;
   if (var1.realpart = 1.0) and (var2 = withbody) then
      PASS('6.4.3.3-2')
   else
      FAIL('6.4.3.3-2')
end;


{TEST 6.4.3.3-3, CLASS=CONFORMANCE}

{: This test checks that an empty record can be declared. }
{  Since this is the limiting case of a structured-type, some
   processors may mis-handle it.  The following program
   illustrates one of the uses. }
{V3.0: Comment revised and test slightly extended. }

procedure t6p4p3p3d3;
type
   statuskind  = (defined,undefined);
   emptykind   = record end;
var
   empty : emptykind;
   number: record
            case status:statuskind of
               defined  : (i : integer);
               undefined: (e : emptykind)
            end;
begin
   with number do begin
      status:=defined;
      i:=7
   end;
   with number do begin
      status:=undefined
   end;
   PASS('6.4.3.3-3')
end;


{TEST 6.4.3.3-4, CLASS=CONFORMANCE}

{: This test checks that a tag-field may be redefined
   elsewhere in the declaration part. }
{  Test similar to 6.4.3.3-2. }
{V3.0: Comment revised, and value test added. }

procedure t6p4p3p3d4;
(****
type
   which = (white,black,warlock,sand);
var
  thing : which;
  polex : record
             case which:boolean of
               true: (realpart:real;
                      imagpart:real);
               false:(theta:real;
                      magnit:real)
           end;
begin
  thing := black;
  polex.which:=true;
  polex.realpart:=0.5;
  polex.imagpart:=0.8;
  if (thing = black) and polex.which then
    PASS('6.4.3.3-4')
  else (********)
begin
    FAIL('6.4.3.3-4 (tag-field may be redefined)')
end;


{TEST 6.4.3.3-5, CLASS=CONFORMANCE}

{: This test checks that an empty record can be assigned to
   field of a record. }
{  A record-value exists when none of its fields are undefined.
   Since the empty record types have no fields they are always
   defined immediately after activation (of a block or variant or
   variable).  This program assigns such a value to a compatible
   field of an identical type.  In most implementations this
   involves the very efficient transference of nothing, but
   some processors may get knotted. }
{V3.1: Unchanged since 3.0, but the validity of this test is
       doubtful. It can be argued that the program contains
       error 43 (undefined value) for the access to empty.
       However, this would make variant records difficult to
       handle correctly. Ignore this test for compiler
       validation. }

procedure t6p4p3p3d5;
type
   statuskind  = (defined,undefined);
   emptykind   = record end;
var
   empty : emptykind;
   number: record
            case status:statuskind of
               defined  : (i : integer);
               undefined: (e : emptykind)
            end;
begin
   with number do
   begin
      status:=undefined;
      e:=empty
   end;
   PASS('6.4.3.3-5')
end;

{TEST 6.4.3.3-6, CLASS=CONFORMANCE}

{: This test checks that nested variants are allowed
   with the appropriate syntax. }
{V3.0: Writing and comment revised. Was previously 6.4.3.3-13. }

procedure t6p4p3p3d6;
type
   a=record
       case b:boolean of
       true: (c:char);
       false: (case d:boolean of
               true: (e:char);
               false: (f:integer))
      end;
var
   g:a;
begin
   g.b:=false;
   g.d:=false;
   g.f:=1;
   PASS('6.4.3.3-6')
end;


{TEST 6.4.3.3-7, CLASS=CONFORMANCE}

{: This test contains negative integers as case-constants in a
   record-type. }
{  Some compilers do not accept them. }
{V3.1: New test from BNI. }

procedure t6p4p3p3d7;
type
    level = -1..1;
    state = record
               case l:level of
                  0:(stable:integer);
                  1:(positive:integer);
                  -1:(negative:integer);
            end;
var
    st:state;
begin
    st.l:=-1;
    st.negative:=10;
    PASS('6.4.3.3-7')
end;


{TEST 6.4.3.3-17, CLASS=CONFORMANCE}

{: This test contains a variant-part with only one variant. }
{V3.1: New test from BNI. }

procedure t6p4p3p3d17;
type
    one = 1..1;
    two = (a,b);
var
    rec1:record
            case tag:one of
               1:(i:integer);
         end;
    rec2:record
            case tag:two of
               a,b:(i:integer);
         end;
    rec3:record
            case two of
               a,b:(i:integer);
         end;
begin
    rec1.tag:=1;
    rec1.i:=5;
    rec2.tag:=a;
    rec2.i:=5;
    rec3.i:=5;
    PASS('6.4.3.3-17')
end;



{TEST 6.4.3.4-1, CLASS=CONFORMANCE}

{: This program simply tests that set-types are permitted. }
{V3.0: Comment revised. }

procedure t6p4p3p4d1;
type
   colour   = (red,blue,pink,green,yellow);
   setone   = set of colour;
   settwo   = set of blue..green;
   setthree = set of boolean;
   setfour  = set of 1..10;
   setfive  = set of 0..3;
   setsix   = set of (heart,diamond,spade,club);
begin
   PASS('6.4.3.4-1')
end;


{TEST 6.4.3.4-2, CLASS=CONFORMANCE}

{: This program tests if a set of char is permitted by the
   processor. }
{  Processors that have only one letter case in their
   character set should still use the test unchanged although
   it will redundantly test the letter 'z' twice.  The
   test assumes that exercising this set of characters will
   trap most deviating processors as the character sets in
   use can be guessed at.  Standard Pascal does not contain
   a maxchar function which can be used to exercise the
   processor more thoroughly. }
{V3.0: Comment and write revised. }

procedure t6p4p3p4d2;
var
   s : set of char;
begin
{$IfNdef DoLater}
   s:=[chr(0),';',' ','0'..'9','a'..'z','A'..'Z'];
   if (chr(0) in s) and (';' in s) and (' ' in s) and ('0' in s) and
      ('z' in s) and ('Z' in s) and ('9' in s) then
      PASS('6.4.3.4-2')
   else
      FAIL('6.4.3.4-2')
{$endif}
end;


{TEST 6.4.4-1, CLASS=CONFORMANCE}

{: This program simply tests that pointer-types are permitted. }
{V3.0: Dereferencing included.  Extended to include
   ptr7, ptr8 and ptr9. }

procedure t6p4p4d1;
type
   sett     = set of 1..2;
   urray    = array[1..3] of integer;
   rekord   = record
               a : integer;
               b : boolean
              end;
   ptr10    = ^sett;
   pureptr  = ^pureptr;
var
   ptr1  : ^integer;
   ptr2  : ^real;
   ptr3  : ^boolean;
   ptr4  : ^sett;
   ptr5  : ^urray;
   ptr6  : ^rekord;
   ptr7  : ^char;
   ptr8  : pureptr;
   ptr9  : ptr10;
begin
   new(ptr1);
   new(ptr2);
   new(ptr3);
   new(ptr4);
   new(ptr5);
   new(ptr6);
   new(ptr7);
   new(ptr8);
   new(ptr9);
   ptr1^ := 1;
   ptr2^ := 3.14;
   ptr3^ := true;
   {$ifNdef dolater} ptr4^ := [1,2]; {$endif}
   ptr5^[1] := 1;
   ptr6^.a := 1;
   ptr6^.b := true;
   ptr7^ := 'C';
   ptr8^ := nil;
   {$ifNdef dolater} ptr9^ := [1]; {$endif}
   Dispose(ptr1);
   Dispose(ptr2);
   Dispose(ptr3);
   Dispose(ptr4);
   Dispose(ptr5);
   Dispose(ptr6);
   Dispose(ptr7);
   Dispose(ptr8);
   Dispose(ptr9);
   PASS('6.4.4-1')
end;


{TEST 6.4.5-1, CLASS=CONFORMANCE}

{: This program simply tests that the processor conforms to the
   Standard's description of type-identity. }
{  The Pascal Standard states that types designated at two or more
   different places in the program text are identical if the same
   type identifier is used at these places, or if different
   identifiers are used which have been defined to be equivalent
   to each other. }
{V3.0: Comment revised. }

procedure t6p4p5d1;
type
   t1 = array[1..5] of boolean;
   t2 = t1;
   t3 = t2;
var
   a : t1;
   b : t2;
   c : t3;
procedure identical(var a : t1; var b : t2; var c : t3);
begin
   a[1]:=true;
   b[1]:=false;
   c[1]:=true
end;

begin
   a[1]:=true;
   b[1]:=false;
   c[1]:=false;
   identical(a,b,c);
   identical(c,a,b);
   identical(b,c,a);
   PASS('6.4.5-1')
end;


{TEST 6.4.5-2, CLASS=CONFORMANCE}

{: This test checks type compatibility of subranges. }
{  Two types are compatible if they are identical or if one is a
   subrange of the other, or if both are subranges of the same type.
   This program tests these points, but with only subranges of the
   same type having some overlap. }
{V3.0: Test revised and improved. Was previously 6.4.5-6. }

procedure t6p4p5d2;
type
   colour   = (red,pink,orange,yellow,green,blue,brown);
   colourtoo= colour;
var
   col1  : colour;
   col2  : colourtoo;
   subcol1  : red..yellow;
   subcol2  : orange..blue;
   counter : 0..3;
begin
   counter := 0;
   col1:=red;
   col2:=red;
   if col1 = col2 then counter:=counter+1;
   subcol1:=red;
   if col1 = subcol1 then counter:=counter+1;
   subcol1:=yellow;
   subcol2:=yellow;
   if subcol1 = subcol2 then counter:=counter+1;
   if counter = 3 then
      PASS('6.4.5-2')
   else
      FAIL('6.4.5-2')
end;


{TEST 6.4.5-3, CLASS=CONFORMANCE}

{: This program tests that two subranges of the same type with
   no overlap are considered as compatible by the processor. }
{V3.0: Comment and write revised. Was previously 6.4.5-7. }

procedure t6p4p5d3;
type
   color = (red,pink,orange,yellow,green,blue,brown);
var
   col1 : red..yellow;
   col2 : green..brown;
begin
   col1:=yellow;
   col2:=green;
   if col1 < col2 then PASS('6.4.5-3')
                  else FAIL('6.4.5-3')
end;


{TEST 6.4.5-4, CLASS=CONFORMANCE}

{: This test checks that string types with the same number
   of components are compatible. }
{  Was previously 6.4.5-8. }
{V3.1: Writes changed. }

procedure t6p4p5d4;
var
   string1 : packed array[1..4] of char;
   string2 : packed array[1..4] of char;
begin
   string1:='ABCD';
   string2:='EFGH';
   if 'ABC' = 'ABC' then
      if string1 <> string2 then
         PASS('6.4.5-4')
      else
         FAIL('6.4.5-4, STRINGS(1)')
   else
      FAIL('6.4.5-4, STRINGS(2)')
end;


{TEST 6.4.5-5, CLASS=CONFORMANCE}

{: This test checks the type-compatibility rules for sets. }
{  Set-types are compatible if their base-types are compatible
   which means identical or subranges thereof, and are jointly
   packed or unpacked.  This test tries several combinations
   which should be allowed. }
{V3.1: Old test completely rewritten. }

procedure t6p4p5d5;
type
   colour  = (red,pink,orange,yellow,green,blue,brown);
   CharSet = set of char;
var
   cseti  : CharSet;
   cset1  : set of char;      { different, but compatible with above }
   cset2  : set of 'A'..'Z';
   cset3  : set of '0'..'9';
   eset1  : set of colour;
   eset2  : set of red..orange;
   eset3  : set of orange..brown;
begin
{$ifNdef dolater}
   cseti:=['0'..'9'];
   cset1:=[]; cset2:=['A','Z']; cset3:=['0'..'9'];
   eset1:=[]; eset2:=[orange]; eset3:=[orange];
   if (cseti+cset1 = (cset3-cset2)*cseti) and
      (eset1+eset2 = eset3-eset1)
   then
      PASS('6.4.5-5')
   else
      FAIL('6.4.5-5')
{$endif}
end;

{TEST 6.4.5-6, CLASS=CONFORMANCE}

{: This test checks that if two types are declared identical,
   they inherit all properties in common, including operators and
   special attributes. }
{  This is checked by an analogue of type boolean. }
{V3.0: Comment and writes revised. Was previously 6.4.5-12. }

procedure t6p4p5d6;
const
   on=true;
   off=false;
type
   logical=boolean;
var
   test:integer;
   b1,b2:boolean;
   l1,l2:logical;
begin
   test:=0;
   b1:=true;   b2:=off;
   l1:=true;   l2:=off;
   if l2 then test:=test+1;
   l2:=b2;
   if b1=b2 then test:=test+1;
   b2:=l2;
   if b2 or l2 then test:=test+1;
   if test=0 then
      PASS('6.4.5-6')
   else
      FAIL('6.4.5-6')
end;


{TEST 6.4.6-1, CLASS=CONFORMANCE}

{: This program tests that assignment compatible types as
   described by the Pascal Standard, are permitted by this
   processor. }
{  This program tests only those uses in assignment statements.
   All cases have been tested elsewhere, but are included here
   together for consistency. }
{V3.0: Comment revised. }

procedure t6p4p6d1;
type
   colour = (red,pink,yellow);
   rekord = record
               a : integer;
               b : boolean
            end;
var
   i     : integer;
   j     : real;
   col1  : colour;
   col2  : pink..yellow;
   col3  : set of colour;
   col4  : set of red..pink;
   urray1   : array[1..6] of integer;
   urray2   : array[1..4] of integer;
   record1  : rekord;
   record2  : rekord;
begin
{$ifNdef dolater}
   i:=2;
   j:=i;
   col1:=yellow;
   col2:=col1;
   col3:=[pink];
   col4:=col3;
   urray2[1]:=0;
   urray1[6]:=urray2[1];
   record1.a:=2;
   record1.b:=true;
   record2:=record1;
   PASS('6.4.6-1')
{$endif}
end;


{TEST 6.4.6-2, CLASS=CONFORMANCE}

{: This test checks the use of assignment compatibility in actual
   and formal parameters. }
{  Similar to 6.4.6-1. }
{V3.0: Comment revised. }

procedure t6p4p6d2;
type
   colour = (red,pink,yellow,green);
   subcol1 = yellow..green;
   subcol2 = set of colour;
   subcol3 = set of pink..green;
var
   a        : integer;
   b        : real;
   colour1  : colour;
   colour2  : pink..green;
   colour3  : set of colour;
   colour4  : set of yellow..green;

procedure compat(i : integer; j : real;
                 col1 : colour; col2 : subcol1;
                 col3 : subcol2; col4 : subcol3);
begin
end;

begin
{$ifNdef dolater}
   compat(2,2.4,yellow,yellow,[pink],[pink]);
   a:=2;
   b:=3.1;
   colour1:=pink;
   colour2:=green;
   colour3:=[yellow];
   colour4:=[yellow];
   compat(a,b,colour1,colour2,colour3,colour4);
   compat(a,a,colour2,colour2,colour4,colour4);
   PASS('6.4.6-2')
{$endif}
end;


{TEST 6.4.6-3, CLASS=CONFORMANCE}

{: This program tests that an index expression is assignment-compatible
   with the index-type specified in the definition of the array-type. }
{V3.0: Comment revised. }

procedure t6p4p6d3;
type
   colour = (red,pink,orange,yellow,green);
   intensity = (bright,dull);
var
   array1 : array[yellow..green] of boolean;
   array2 : array[colour] of intensity;
   array3 : array[1..99] of integer;
   colour1 : red..yellow;
   i      : integer;
begin
   array1[yellow]:=true;
   colour1:=yellow;
   array1[colour1]:=false;
   array2[colour1]:=bright;
   array3[1]:=0;
   i:=2;
   array3[i*3+2]:=1;
   PASS('6.4.6-3')
end;


{TEST 6.5.1-1, CLASS=CONFORMANCE}

{: This test contains examples of legal type and variable
   declarations. }
{V3.1: Program parameters removed. }

procedure t6p5p1d1;
const
   limit = 20;
type
   natural       = 0..maxint;
   count         = integer;
   range         = integer;
   colour        = (red,yellow,green,blue);
   sex           = (male,female);
   year          = 1900..1999;
   shape         = (triangle,rectangle,circle);
   punchedcard   = array[1..80] of char;
   {$IfNdef SkipAlways} charsequence  = file of char; {$endif}
   angle         = real;
   polar         = record
                       r : real;
                       theta : angle
                   end;
   indextype     = 1..limit;
   vector        = array[indextype] of real;
   person        = ^ persondetails;
   persondetails = record
                      {$IfNdef SkipAlways} name, firstname : charsequence; {$endif}
                      age : integer;
                      married : boolean;
                      father,child,sibling : person;
                      case s:sex of
                         male   : (enlisted,bearded : boolean);
                         female : (mother,programmer : boolean)
                      end;
   {$IfNdef SkipAlways} FileOfInteger = file of integer; {$endif}

var
   x,y,z,max: real;
   i,j      : integer;
   k        : 0..9;
   p,q,r    : boolean;
   operator : (plus,minus,times);
   a        : array[0..63] of real;
   c        : colour;
   {$IfNdef SkipAlways} f: file of char; {$endif}
   hue1,hue2: set of colour;
   p1,p2    : person;
   m,m1,m2  : array[1..10,1..10] of real;
   coord    : polar;
   {$IfNdef SkipAlways} pooltape : array[1..4] of FileOfInteger; {$endif}
   date     : record
                 month : 1..12;
                 year  : integer
              end;
begin
   PASS('6.5.1-1')
end;


{TEST 6.5.3.2-1, CLASS=CONFORMANCE}

{: This test checks that the two ways of indexing a
   multi-dimensional array are equivalent. }
{V3.0: Write for PASS shortened. Was previously 6.5.3.2-2. }

procedure t6p5p3p2d1;
var
   a:array[1..4,1..4] of integer;
   b:array[1..4] of
      array[1..4] of integer;
   p:packed array [1..4,1..4]of char;
   q:packed array[1..4] of
      packed array [1..4] of char;
   i,j,counter:integer;
begin
   counter:=0;
   for i:= 1 to 4 do
      for j:=1 to 4 do
      begin
         a[i,j] := j;
         b[i,j] := j;
         case j of
         1:
           begin
               p[i,j]:='F';
               q[i,j]:='F'
           end;
         2:
           begin
               p[i,j]:='A';
               q[i,j]:='A'
           end;
         3:
           begin
               p[i,j]:='I';
               q[i,j]:='I'
           end;
         4:
           begin
               p[i,j]:='L';
               q[i,j]:='L'
           end
         end
      end;
   for i:=1 to 4 do
      for j:=1 to 4 do
      begin
         if a[i][j] <> a[i,j] then
            counter:=counter+1;
         if b[i][j] <> b[i,j] then
            counter:=counter+1;
         if p[i][j] <> p[i,j] then
            counter:=counter+1;
         if q[i][j] <> q[i,j] then
            counter:=counter+1
      end;
   if counter=0 then
      PASS('6.5.3.2-1')
   else
      FAIL('6.5.3.2-1')
end;


{TEST 6.6.1-1, CLASS=CONFORMANCE}

{: This program simply tests the syntax for procedures. }

procedure t6p6p1d1;
var
   a : integer;
   b : real;
procedure withparameters(g : integer; h : real);
var
   c : integer;
   d : real;
begin
   c:=g;
   d:=h
end;

procedure parameterless;
begin
   PASS('6.6.1-1')
end;

begin
   a:=1;
   b:=2;
   withparameters(a,b);
   parameterless;
   //WrLn('?? why');
end;


{TEST 6.6.1-2, CLASS=CONFORMANCE}

{: This program tests the implementation of forward directives,
   recursive activation, and multilevel referencing of a var
   parameter in procedures. }
{V3.1: Output of FAIL added. }

procedure t6p6p1d2;
var
   c : integer;

procedure one(var a : integer);
   forward;

procedure two(var b : integer);
begin
   b:=b+1;
   one(b)
end;

procedure one;
begin
   a:=a+1;
   if a = 1 then two(a)
end;

begin
   c:=0;
   one(c);
   if c = 3 then
      PASS('6.6.1-2')
  else
     FAIL('6.6.1-2')
end;


{TEST 6.6.2-1, CLASS=CONFORMANCE}

{: This program simply tests the syntax for functions. }
{V3.0: Value check added. Write for FAIL elaborated. }

procedure t6p6p2d1;
var
   a ,
   twopisquared : real;
   b : integer;

function power(x : real; y : integer):real;  { y>=0 }
var
   w,z : real;
   i : 0..maxint;
begin
   w:=x;
   z:=1;
   i:=y;
   while i > 0 do
   begin
      { z*(w tothepower i)=x tothepower y }
      if odd(i) then z:=z*w;
      i:=i div 2;
      w:=sqr(w)
   end;
   { z=x tothepower y }
   power:=z
end;

function twopi : real;
begin
   twopi:=6.283185
end;

begin
   a:=twopi;
   b:=2;
   twopisquared:=power(a,b);
   if (twopisquared > 39.40) and (twopisquared < 39.50)
   then
      PASS('6.6.2-1')
   else
      FAIL('6.6.2-1')
end;


{TEST 6.6.2-2, CLASS=CONFORMANCE}

{: This program tests that forward declaration and recursion in
   functions is permitted. }
{  Similar to 6.6.1-2. }

procedure t6p6p2d2;
var
   c : integer;
function one(a : integer) : integer;
   forward;

function two(b : integer) : integer;
var
   x : integer;
begin
   x:=b+1;
   x:=one(x);
   two:=x
end;

function one;
var
   y : integer;
begin
   y:=a+1;
   if y=1 then y:=two(y);
   one:=y
end;

begin
   c:=0;
   c:=one(c);
   if c = 3 then
      PASS('6.6.2-2')
   else
      FAIL('6.6.2-2')
end;


{TEST 6.6.2-3, CLASS=CONFORMANCE}

{: This program checks that the simple types and pointer-types
   are permitted as the result type of a function. }
{  The Pascal Standard specifies that the result type of a
   function can only be a simple type or a pointer type. }

procedure t6p6p2d3;
type
   subrange = 0..3;
   enumerated = (red,yellow,green);
   rectype = record
               a : integer
             end;
   ptrtype = ^rectype;
var
   a : real;
   b : integer;
   c : boolean;
   d : subrange;
   e : enumerated;
   f : char;
   g : ptrtype;

function one : real;
begin
   one:=2.63
end;
function two : integer;
begin
   two:=2
end;
function three : boolean;
begin
   three:=false
end;
function four : subrange;
begin
   four:=2
end;
function five : enumerated;
begin
   five:=yellow
end;
function six : char;
begin
   six:='6'
end;
function seven : ptrtype;
begin
   seven:=nil
end;

begin
   a:=one;
   b:=two;
   c:=three;
   d:=four;
   e:=five;
   f:=six;
   g:=seven;
   PASS('6.6.2-3')
end;


{TEST 6.6.2-4, CLASS=CONFORMANCE}

{: This test checks that functions are permitted from
   altering  their environment (ie. side effects). }
{  Though side effects are generally not to be encouraged,
   they are part of Standard Pascal and do have genuine uses.
   Functions with side effects occur elsewhere in the
   validation suite. }
{V3.1: Write statements regularized. }

procedure t6p6p2d4;
type
   ptrtochar = ^char;
var
   c1,c2,c3,dummy:char;
   p1,p2:ptrtochar;
   DoFree: ptrtochar;

function testa(ptr:ptrtochar):char;
   {sneakiest, uses pointers}
var
   pp:ptrtochar;
begin
   pp:=ptr;
   pp^ := 'P';
   testa:='1'
end;

procedure assign;
   {used by testb}
begin
   c1:='A'
end;

function testb:char;
   {sneaky, calls a procedure}
begin
   assign;
   testb:='2'
end;

function testc:char;
   {blatantly changes the environment via write}
begin
  WrLn( ' MESSAGE' );
  testc:='6'
end;

function testd:ptrtochar;
   {blatantly sneaky: modifying the environment via new
      and then passing it out}
var
   pp:ptrtochar;
begin
   new(pp);  DoFree:=pp;
   pp^:='.';
   testd:=pp
end;

function teste:char;
   {the most used side effect:global access}
begin
   c2:='S';
   teste:='3'
end;

function testf(var c:char):char;
   {straightforward}
begin
   c:='S';
   testf:='4'
end;

begin {of main program}
   new(p1);
   p1^:='F'; c1:='A'; c2:='I'; c3:='L';
   p2:=nil;
      {all variables excluding dummy have been assigned values}
   dummy:=testa(p1);
   dummy:=testb;
   dummy:=teste;
   dummy:=testf(c3);
   p2:=testd;
   dummy:=testc;
   if (p1^='P') and (c2='S') and (c3='S') then
      PASS('6.6.2-4')
   else
      FAIL('6.6.2-4');
   Dispose(DoFree);
end;



{TEST 6.6.3.1-1, CLASS=CONFORMANCE}

{: This program tests the syntax for value-parameter sections and
   variable-parameter sections. }
{  Includes example of single and multiple identifiers in the
   respective identifier-lists and a check that the correspondence
   of actual and formal parameters is correctly handled with
   identifier-lists. }
{V3.1: Comment changed to accurately describe test. }

procedure t6p6p3p1d1;
type
   colour   = (red,orange,yellow,green,blue,brown);
   subrange = red..blue;
   rekord   = record
               a : integer
              end;
   ptrtype  = ^rekord;
var
   a,b,c,d,e,f,g,h,i,j,
   k,l,m,n,o,p,q,r,s,t : integer;
   counter: integer;
   colone : subrange;
   coltwo : colour;
   colthree : colour;
   u,v,w,x : real;
   y,z : boolean;
   ptr : ptrtype;

procedure testone(a1,b1,c1,d1,e1,f1,g1,h1,i1,j1,k1,
                  l1,m1,n1,o1,p1,q1,r1,s1,t1 : integer;
                  colourone : subrange;
                  colourtwo,colourthree : colour;
                  u1,v1,w1,x1 : real;
                  y1,z1 : boolean;
                  ptr : ptrtype);
begin
   if (a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 + i1 + j1 + k1 + l1 + m1 +
       n1 + o1 + p1 + q1 + r1 + s1 + t1 = 0)
   and (colourone = orange) and (colourtwo = brown)
   and (colourthree = red) and (abs(u1 + v1 + w1 + x1) < 0.001)
   and (y1 = true) and (z1 = false)
   then
      counter:=1
end;
procedure testtwo(var a1,b1,c1,d1,e1,f1,g1,h1,i1,j1,k1,
                  l1,m1,n1,o1,p1,q1,r1,s1,t1 : integer;
                  var colourone : subrange;
                  var colourtwo,colourthree : colour;
                  var u1,v1,w1,x1 : real;
                  var y1,z1 : boolean;
                  var ptr : ptrtype);
begin
   if (a1 + b1 + c1 + d1 + e1 + f1 + g1 + h1 + i1 + j1 + k1 + l1 + m1 +
       n1 + o1 + p1 + q1 + r1 + s1 + t1 = 0)
   and (colourone = orange) and (colourtwo = brown)
   and (colourthree = red) and (abs(u1 + v1 + w1 + x1) < 0.001)
   and (y1 = true) and (z1 = false)
   then
      counter:=counter + 2
end;

begin
   a:=0; b:=0; c:=0; d:=0; e:=0; f:=0; g:=0;
   h:=0; i:=0; j:=0; k:=0; l:=0; m:=0; n:=0;
   o:=0; p:=0; q:=0; r:=0; s:=0; t:=0;
   colone:=orange;
   coltwo:=brown;
   colthree:=red;
   u:=0; v:=0; w:=0; x:=0;
   y:=true;
   z:=false;
   new(ptr);
   counter:=0;
   testone(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,
           colone,coltwo,colthree,u,v,w,x,y,z,ptr);
   testtwo(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,
           colone,coltwo,colthree,u,v,w,x,y,z,ptr);
   Dispose(ptr);
   if counter=3 then
      PASS('6.6.3.1-1')
   else
      if counter=2 then
         FAIL('6.6.3.1-1, VALUE PARAMETERS')
      else
         if counter=1 then
            FAIL('6.6.3.1-1, VAR PARAMETERS')
         else
            FAIL('6.6.3.1-1, PARAMETERS')
end;


{TEST 6.6.3.1-2, CLASS=CONFORMANCE}

{: This program checks that set, record and array parameters are
   permitted. }
{  Similar to 6.6.3.1-1. }
{V3.0: Value check added.
   Writes altered to conform to convention. }

{$ifNdef dolater}
procedure t6p6p3p1d2;
type
   sett     = set of 0..20;
   rekord   = record
               a : integer
              end;
   urray    = array[boolean] of boolean;
var
   counter : integer;
   setone, settwo,setthree,setfour,setfive,setsix : sett;
   recone,rectwo,recthree,recfour,recfive : rekord;
   urrayone,urraytwo,urraythree,urrayfour : urray;

procedure testone(set1,set2,set3,set4,set5,set6 : sett;
                  rec1,rec2,rec3,rec4,rec5 : rekord;
                  urray1,urray2,urray3,urray4 : urray);
begin
   if (set1 + set2 + set3 + set4 + set5 + set6 = [1])
   and (rec1.a + rec2.a + rec3.a + rec4.a + rec5.a = 5)
   and ((not urray1[true]) and (not urray2[true])
   and (not urray3[true]) and (not urray4[true]))
   then
      counter:=1
end;

procedure testtwo(var set1,set2,set3,set4,set5,set6 : sett;
                  var rec1,rec2,rec3,rec4,rec5 : rekord;
                  var urray1,urray2,urray3,urray4 : urray);
begin
   if (set1 + set2 + set3 + set4 + set5 + set6 = [1])
   and (rec1.a + rec2.a + rec3.a + rec4.a + rec5.a = 5)
   and ((not urray1[true]) and (not urray2[true])
   and (not urray3[true]) and (not urray4[true]))
   then
      counter:=counter + 2
end;

begin
   setone:=[1];   settwo:=[1];   setthree:=[1];
   setfour:=[1];  setfive:=[1];  setsix:=[1];
   recone.a:=1;   rectwo.a:=1;   recthree.a:=1;
   recfour.a:=1;  recfive.a:=1;
   urrayone[true]:=false;  urraytwo[true]:=false;
   urraythree[true]:=false;   urrayfour[true]:=false;
   counter:=0;
   testone(setone,settwo,setthree,setfour,setfive,setsix,
            recone,rectwo,recthree,recfour,recfive,
            urrayone,urraytwo,urraythree,urrayfour);
   testtwo(setone,settwo,setthree,setfour,setfive,setsix,
            recone,rectwo,recthree,recfour,recfive,
            urrayone,urraytwo,urraythree,urrayfour);
   if counter=3 then
      PASS('6.6.3.1-2')
   else
      if counter=2 then
         FAIL('6.6.3.1-2, VALUE PARAMETERS')
      else
         if counter=1 then
            FAIL('6.6.3.1-2, VAR PARAMETERS')
         else
            FAIL('6.6.3.1-2, PARAMETERS')
end;
{$endif}


{TEST 6.6.3.3-1, CLASS=CONFORMANCE}

{: This test checks that variable parameters have been
   implemented correctly. }
{  Jensen and Wirth state that the actual variables corresponding
   to formal variable parameters should be distinct. The axiomatic
   definition also includes non-local variables used by the
   procedure in this restriction. }
{V3.0: New test. }

procedure t6p6p3p3d1;
var a, b: integer;
procedure swap(var p, q: integer);
   var temp: integer;
   begin
   temp := p;
   p := q;
   q := temp
   end;
begin
   a := 1;  b := 2;
   swap(a, b);
   swap(a, a);
   if (b <> 1) or (a <> 2) then
     FAIL('6.6.3.3-1')
   else
     PASS('6.6.3.3-1')
end;


{TEST 6.6.3.3-2, CLASS=CONFORMANCE}

{: This test checks that any operation involving the formal
   parameter is performed immediately on the actual parameter. }
{  Depending on how variable parameter passing is implemented,
   this test may cause some processors to fail. }
{V3.0: Write for FAIL elaborated. }

procedure t6p6p3p3d2;
var
   direct : integer;
   dopass  : boolean;
procedure indirection(var indirect : integer; var result : boolean);
   begin
      indirect:=2;
      if indirect<>direct then
         result:=false
      else
         result:=true
   end;
begin
   direct:=1;
   dopass:=false;
   indirection(direct,dopass);
   if dopass then
      PASS('6.6.3.3-2')
   else
      FAIL('6.6.3.3-2')
end;


{TEST 6.6.3.3-3, CLASS=CONFORMANCE}

{: This test checks that if a variable passed as a parameter
   involves the indexing of an array, or the dereferencing of a
   pointer, then these actions are executed before the activation
   of the block. }
{V3.0: Rewritten to include type rekptr = ^rekord
   Write for FAIL elaborated. }

procedure t6p6p3p3d3;
type
   rekptr = ^rekord;
   rekord = record
               a : integer;
               link : rekptr;
               back : rekptr
            end;
var
   urray : array[1..2] of integer;
   i     : integer;
   temptr,ptr : rekptr;
procedure call(arrayloctn : integer;
               ptrderef : integer);
   begin
      i:=i+1;
      ptr:=ptr^.link;
      if (urray[i-1] <> arrayloctn) or
         (ptr^.back^.a <> ptrderef) then
         FAIL('6.6.3.3-3')
      else
         PASS('6.6.3.3-3')
   end;
begin
   urray[1]:=1;
   urray[2]:=2;
   i:=1;
   new(ptr);
   ptr^.a:=1;
   new(temptr);
   temptr^.a:=2;
   ptr^.link:=temptr;
   temptr^.back:=ptr;
   call(urray[i],ptr^.a);
   //Dispose(ptr);
   //Dispose(temptr);
end;


{TEST 6.6.4.1-1, CLASS=CONFORMANCE}

{: This program tests that predefined standard procedures may
   be redefined with no conflict. }
{V3.0: Write for FAIL elaborated. }

procedure t6p6p4p1d1;
var
   i : integer;
procedure write(var a : integer);
   begin
      a:=a+2
   end;
procedure get(var a : integer);
   begin
      a:=a*2
   end;

begin
   i:=0;
   write(i);
   get(i);
   if i=4 then
      PASS('6.6.4.1-1')
   else
      FAIL('6.6.4.1-1')
end;


{TEST 6.6.4.1-2, CLASS=CONFORMANCE}

{: This test checks that a predefined function can be redefined. }
{V3.1: Comment corrected. }

procedure t6p6p4p1d2;
var
   x: integer;

function abs(y:integer): integer;
   begin
   abs := 0
   end;

begin
   x := 10;
   if abs(x)=0 then
      PASS('6.6.4.1-2')
   else
      FAIL('6.6.4.1-2')
end;


{TEST 6.6.5.3-2, CLASS=CONFORMANCE}

{: This program tests that new and dispose operate as required. }
{  However, after a call of dispose pointer should be undefined
   and this is not tested. }
{V3.0: Comment reworded - undefinition was bad English. }

procedure t6p6p5p3d2;
var
   ptr : ^integer;
   i   : integer;
begin
   for i:=1 to 10 do
   begin
      new(ptr);
      ptr^:=i;
      dispose(ptr);
   end;
   PASS('6.6.5.3-2')
end;


{TEST 6.6.5.3-20, CLASS=CONFORMANCE}

{: This test contains multi-level pointers. }
{  NEW applied to a pointer to an array and then to its element
   which is itself a pointer. }
{V3.1: New test from BNI. }

procedure t6p6p5p3d20;
type
   pint=^integer;
   ppint=^pint;
   arr=array[1..2] of ppint;
   parr=^arr;
   pparr=^parr;
var
   ppi:ppint;
   ppa:pparr;
begin
   new(ppi);
   new(ppi^);
   ppi^^:=1;
   new(ppa);
   new(ppa^);
   new(ppa^^[ppi^^]);
   new(ppa^^[ppi^^]^);
   ppa^^[ppi^^]^^:=5;
   ppi^^:=ppi^^+1;
   new(ppa^^[ppi^^]);
   new(ppa^^[ppi^^]^);
   ppa^^[ppi^^]^^:=7;
   if ppa^^[2]^^-ppa^^[1]^^=ppi^^
      then PASS('6.6.5.3-20')
      else FAIL('6.6.5.3-20')
end;


{TEST 6.6.6.2-1, CLASS=CONFORMANCE}

{: This program tests the implementation of the arithmetic
   function abs. Both real and integer expressions are used. }
{  Note: There is also a QUALITY test of the abs function carried
   out as part of test 6.7.2.2-15. }
{V3.0: Superfluous const pi removed. Write for FAIL revised.
   Comment expanded. }

procedure t6p6p6p2d1;
var
   i, counter : integer;
   r : real;
function myabs1(i : integer):integer;
   begin
      if i<0 then
         myabs1:=-i
      else
         myabs1:=i
   end;
function myabs2(r:real):real;
   begin
      if r<0 then
         myabs2:=-r
      else
         myabs2:=r
   end;
begin
   counter:=0;
   for i:=-10 to 10 do
   begin
      if abs(i)=myabs1(i) then
         counter:=counter+1
   end;

   r:=-10.3;
   while r<10.3 do
   begin
      if abs(r)=myabs2(r) then
         counter:=counter+1;
      r:=r+0.9
   end;

   if counter=44 then
      PASS('6.6.6.2-1')
   else
      FAIL('6.6.6.2-1')
end;


{TEST 6.6.6.2-2, CLASS=CONFORMANCE}

{: This program tests the implementation of the arithmetic
   function sqr. Both real and integer expressions are used. }
{  Note: There is also a QUALITY test of the sqr function carried
   out as part of test 6.7.2.2-15. }
{V3.0: Altered to allow 4 digit accuracy.
   Write for FAIL revised. Comment expanded. }

procedure t6p6p6p2d2;
var
   i,counter : integer;
   variable : real;
begin
   counter := 0;
   for i:= -10 to 10 do
   begin
      if sqr(i) = i*i then
         counter := counter + 1
   end;
   variable := -10.3;
   while (variable < 10.3) do
   begin
      if (abs(sqr(variable) - variable * variable) < 0.001) then
         counter := counter+1;
      variable := variable + 0.9
   end;
   if (counter = 44) then
      PASS('6.6.6.2-2')
   else
      FAIL('6.6.6.2-2')
end;


{TEST 6.6.6.2-3, CLASS=CONFORMANCE}

{: This program tests the implementation of the arithmetic
   functions sin, cos, exp, ln, sqrt, and arctan. }
{  A rough accuracy test is done, but is not the purpose
   of this program. }
{V3.0: Accuracy reduced to 4 digits maximum.
   Checks extended to limits both sides of all function
   results. Writes for failure standardised. }

procedure t6p6p6p2d3;
const
   pi = 3.1415926;
var
   counter : integer;
begin
   counter := 0;
   if ((-0.001<sin(pi)) and (sin(pi)<0.001)) and
      ((0.70<sin(pi/4)) and (sin(pi/4)<0.71)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, SIN FUNCTION');

   if ((-1.001<cos(pi)) and (cos(pi)<-0.999)) and
      ((0.70<cos(pi/4)) and (cos(pi/4)<0.71)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, COS FUNCTION');

   if ((2.710<exp(1)) and (exp(1)<2.720)) and
      ((0.36<exp(-1)) and (exp(-1)<0.37)) and
      ((8100<exp(9)) and (exp(9)<8110)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, EXP FUNCTION');

   if ((0.999<ln(exp(1))) and (ln(exp(1))<1.001)) and
      ((0.69<ln(2)) and (ln(2)<0.70)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, LN FUNCTION');

   if ((4.99<sqrt(25)) and (sqrt(25)<5.01)) and
      ((5.09<sqrt(26)) and (sqrt(26)<5.10)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, SQRT FUNCTION');

   if ((0.090<arctan(0.1)) and (arctan(0.1)<0.10)) and
      ((-0.001<arctan(0)) and (arctan(0)<0.001)) then
      counter:=counter+1
   else
      FAIL('6.6.6.2-3, ARCTAN FUNCTION');

   if counter=6 then
      PASS('6.6.6.2-3')
end;


{TEST 6.6.6.3-1, CLASS=CONFORMANCE}

{: This program checks the implementation of the transfer
   functions trunc and round. }
{V3.1: Output of FAIL added. }

procedure t6p6p6p3d1;
var
   i,
   truncstatus,
   roundstatus : integer;
   j : real;
begin
   truncstatus:=0;
   roundstatus:=0;
   if (trunc(3.7)=3) and (trunc(-3.7)=-3) then
      truncstatus:=truncstatus+1
   else
      FAIL('6.6.6.3-1, TRUNC FUNCTION');

   if (round(3.7)=4) and (round(-3.7)=-4) then
      roundstatus:=roundstatus+1
   else
      FAIL('6.6.6.3-1, ROUND FUNCTION');

   j:=0;
   for i:=-333 to 333 do
   begin
      j:=i div 100;
      if j<0 then
         if (trunc(j-0.5)=round(j)) then
            begin
               truncstatus:=truncstatus+1;
               roundstatus:=roundstatus+1
            end
         else begin
            FAIL('6.6.6.3-1, TRUNC/ROUND FUNCTIONS(1)');
            BREAK;
         end
      else
         if (trunc(j+0.5)=round(j)) then
            begin
               truncstatus:=truncstatus+1;
               roundstatus:=roundstatus+1
            end
         else begin
            FAIL('6.6.6.3-1, TRUNC/ROUND FUNCTIONS(2)');
            BREAK;
         end;
   end;

   if (truncstatus=668) and (roundstatus=668) then
      PASS('6.6.6.3-1')
  else
      FAIL('6.6.6.3-1')
end;



{TEST 6.6.6.4-1, CLASS=CONFORMANCE}

{: This program checks that the implementation of the ord
   function. }
{V3.0: Comment and writes for failure revised. }

procedure t6p6p6p4d1;
type
   colourtype = (red,orange,yellow,green,blue);
var
   colour   : colourtype;
   some     : orange..green;
   i        : integer;
   counter  : integer;
   ok       : boolean;
begin
   counter:=0;
   if (ord(false)=0) and (ord(true)=1) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-1, ORD OF BOOLEAN-TYPE');

   if (ord(red)=0) and (ord(orange)=1) and
      (ord(yellow)=2) and (ord(green)=3) and
      (ord(blue)=4) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-1, ORD OF ENUMERATED-TYPE(1)');

   i:=-11;
   ok:=true;
   while ok do
   begin
      i:=i+1;
      if i>10 then
         ok:=false
      else
         if ord(i)=i then
            counter:=counter+1
         else
         begin
            ok:=false;
            FAIL('6.6.6.4-1, ORD OF INTEGER-TYPE')
         end
   end;

   colour:=blue;
   some:=orange;
   if ord(colour)=4 then
      counter:=counter+1
   else
      FAIL('6.6.6.4-1, ORD OF ENUMERATED-TYPE(2)');

   if ord(some)=1 then
      counter:=counter+1
   else
      FAIL('6.6.6.4-1, ORD OF SUBRANGE-TYPE');

   if counter=25 then
      PASS('6.6.6.4-1')
end;


{TEST 6.6.6.4-2, CLASS=CONFORMANCE}

{: This program checks the implementation of chr. }
{V3.0: Comment and write for FAIL revised. }

procedure t6p6p6p4d2;
var
   letter : char;
   counter : integer;
begin
   counter:=0;

   for letter:='0' to '9' do
      if chr(ord(letter))=letter then
         counter:=counter+1;

   if counter=10 then
      PASS('6.6.6.4-2')
   else
      FAIL('6.6.6.4-2')
end;


{TEST 6.6.6.4-3, CLASS=CONFORMANCE}

{: This program tests that the required ordinal functions succ
   and pred. }
{V3.0: Comment and test completely rewritten to be more
   comprehensive. }

procedure t6p6p6p4d3;
type
   colourtype = (red,orange,yellow,green,blue);
var
   some    : orange..green;
   i       : integer;
   counter : integer;
   ok      : boolean;
   digit   : char;
begin
   counter:=0;

   if succ(false) and not pred(true) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-3, SUCC/PRED OF BOOLEAN-TYPE');

   i:=-11;
   ok:=true;
   while ok do begin
      i:=i+1;
      if i>10 then
         ok:=false
      else
         if (succ(pred(i))=i) and (succ(succ(i))=i+2) and
            (pred(succ(i))=i) and (pred(pred(i))=i-2) then
            counter:=counter+1
         else begin
            FAIL('6.6.6.4-3, SUCC/PRED OF INTEGER-TYPE');
            ok:=false
            end
      end;

   for digit:='0' to '8' do
      if pred(succ(digit))=digit then
         counter:=counter+1
      else
         FAIL('6.6.6.4-3, SUCC/PRED OF CHAR-TYPE');

   if (succ(red)=orange) and (succ(orange)=yellow) and
      (succ(yellow)=green) and (succ(green)=blue) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-3, SUCC OF ENUMERATED-TYPE');
   if (red=pred(orange)) and (orange=pred(yellow)) and
      (yellow=pred(green)) and(green=pred(blue)) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-3, PRED OF ENUMERATED-TYPE');

   some:=yellow;
   if (succ(some)=green) and (pred(some)=orange) then
      counter:=counter+1
   else
      FAIL('6.6.6.4-3, SUCC/PRED OF SUBRANGE-TYPE');

   if counter=34 then
      PASS('6.6.6.4-3')
end;


{TEST 6.6.6.5-2, CLASS=CONFORMANCE}

{: This program tests the function odd. }
{V3.1: Comment corrected, function changed to be identical to
   Standard. Also section added to test near maxint and -maxint. }

procedure t6p6p6p5d2;
var
   i,counter : integer;
function myodd(x:integer):boolean;
   begin
      myodd := (abs(x) mod 2 = 1)
   end;
begin
   counter:=0;
   for i:=-10 to 10 do
      if odd(i) then
      begin
         if myodd(i) then counter := counter+1
      end
      else
      begin
         if not myodd(i) then counter := counter+1
      end;
   i := maxint - 10;
   while i < maxint do
      begin
      i := i + 1;
      if myodd (i) = odd (i) then
         counter := counter + 1;
      if myodd (-i) = odd (-i) then
         counter := counter + 1;
      end;
   if counter=41 then
      PASS('6.6.6.5-2')
   else
      FAIL('6.6.6.5-2,'+i2s(Counter))     // => 1 !!!
end;


{TEST 6.7.1-1, CLASS=CONFORMANCE}

{: This program tests the precedence of operators. }
{V3.0: New test, replacing previous tests 6.7.1-1, 6.7.1-2
   and 6.7.2.1-3. }

procedure t6p7p1d1;
type
   operatorcategory = (boolean,adding,multiplying,relational);
var
   indicator : set of operatorcategory;
   one,two,three,six,seven,twelve,thirteen : integer;
begin
   one:=1;
   two:=2;
   three:=3;
   six:=6;
   seven:=7;
   twelve:=12;
   thirteen:=13;
   indicator:=[];

   if (twelve/six*two < 3.9) or
      (twelve div six*two <> 4) or
      (thirteen mod six*two <> 2) or
      (thirteen*seven mod two <> 1) or
      (twelve/six/two > 1.1) or
      (twelve div six div two <> 1) or
      (twelve div seven mod two <> 1) or
      (twelve mod seven div two <> 2) or
      (twelve mod seven mod two <> 1) then
      indicator:=indicator+[multiplying];

   if (one-two+three <> 2) or
      (three-two-one <> 0) then
      indicator:=indicator+[adding];

   if (twelve*six+two <> 74) or
      (twelve+six*two <> 24) or
      (twelve*six-two <> 70) or
      (twelve-six*two <> 0) or
      (twelve/six+two < 3.9) or
      (twelve+six/two < 14.9) or
      (twelve/six-two > 0.1) or
      (twelve-six/two < 8.9) or
      (twelve div six+two <> 4) or
      (twelve+six div two <> 15) or
      (twelve div six-two <> 0) or
      (twelve-six div two <> 9) or
      (twelve mod seven+two <> 7) or
      (twelve+seven mod two <> 13) or
      (twelve mod seven-two <> 3) or
      (twelve-seven mod two <> 11) then
      indicator:=indicator+[adding,multiplying];

   if (not true and false) or
      not(not false or true) or
      not(true or false and false) then
      indicator:=indicator+[boolean];

   if not(false and true=false) or
      not(false=true and false) or
      not(false and true<>true) or
      not(true<>true and false) or
      not(false and true<true) or
      not(true>true and false) or
      not(false and true<=true) or
      not(true>=true and false) or
      not(false and true in [false]) or
      (true or true=false) or
      (false=true or true) or
      (true or true<>true) or
      (true<>true or true) or
      (true or false<true) or
      (true<false or true) or
      (true or false>true) or
      (true>false or true) or
      (true or true<=false) or
      (false>=true or true) or
      (true or true in [false]) then
      indicator:=indicator+[boolean,relational];

   if indicator=[] then
      PASS('6.7.1-1')
   else
      begin
      if boolean in indicator then
         FAIL('6.7.1-1, PRECEDENCE - BOOLEAN OPERATORS');
      if adding in indicator then
         FAIL('6.7.1-1, PRECEDENCE - ADDING OPERATORS');
      if multiplying in indicator then
         FAIL('6.7.1-1, PRECEDENCE - MULTIPLYING OPERATORS');
      if relational in indicator then
         FAIL('6.7.1-1, PRECEDENCE - RELATIONAL OPERATORS')
      end
end;


{TEST 6.7.1-2, CLASS=CONFORMANCE}

{: This test checks that the member designator x..y, where x>y,
   denotes no members. }
{V3.1: Constant null set added. }

procedure t6p7p1d2;
var
   x,y :integer;
begin
{$IfNdef DoLater}
   x:=2;
   y:=1;
   if ([x..y]=[]) and ([127..0]=[]) then
      PASS('6.7.1-2')
   else
      FAIL('6.7.1-2')
{$endif DoLater}
end;


{TEST 6.7.1-6, CLASS=CONFORMANCE}

{: This test examines valid productions of set-constructors. }
{  There is no restriction in the Pascal Standard on the use of
   expressions as factors in a set-constructor (provided that they
   yield legal set elements). This test checks 5 such productions. }
{V3.1: New test from BNI. }

procedure t6p7p1d6;
const
   three=3;
type
   colour=(blue,green,red,yellow);
var
   n,c:integer;
   p1,p2:^integer;
begin
   n:=2;
   c:=0;
   new(p1); p1^:=5;
   new(p2); p2^:=7;
   if [0..7]=[0*1..2*three+1] then
         c:=c+1;
   if [0..3,2..4]=[0..4] then
         c:=c+1;
   if [1,2,n,succ(n),1]=[1..3] then
         c:=c+1;
   if [green,yellow,blue..red]=[blue..yellow] then
         c:=c+1;
   if [p1^..p2^]=[5,6,7] then
         c:=c+1;
   if c=5 then PASS('6.7.1-6')
          else FAIL('6.7.1-6');
   Dispose(p1);
   Dispose(p2);
end;

{TEST 6.7.1-7, CLASS=CONFORMANCE}

{: This test checks that the set-constructor can denote both packed and
   unpacked set types in the appropriate contexts. }
{V3.1: New test. }

{$ifNdef dolater}
procedure t6p7p1d7;
type
   ET      = (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P);
   IT      = 0..15;
var
   enormal :        set of ET;
   epakked : packed set of ET;
   cnormal :        set of char;
   cpakked : packed set of char;
   inormal :        set of IT;
   ipakked : packed set of IT;
begin
   enormal := []; epakked := [];
   cnormal := []; cpakked := [];
   inormal := []; ipakked := [];
   enormal := [D,C..H,N];
   epakked := [D,C..H,N];
   cnormal := ['D','C'..'H','N'];
   cpakked := ['D','C'..'H','N'];
   inormal := [3,2..6,13];
   ipakked := [3,2..6,13];
   if (enormal=[C..N]-[I..M]) and (epakked=[C..N]-[I..M]) and
      (cnormal=['C'..'N']-['I'..'M']) and
      (cpakked=['C'..'N']-['I'..'M']) and
      (inormal=[2..13]-[7..12]) and (inormal=[2..13]-[7..12])
   then
      PASS('6.7.1-7')
   else
      FAIL('6.7.1-7')
end;


{TEST 6.7.1-8, CLASS=CONFORMANCE}

{: This test checks that the set-constructor can denote all values
   allowed by the canonic set-type to which it belongs. }
{  This test employs sets of types which are not subranges. }
{V3.1: New test. }

procedure t6p7p1d8;
type
   ET       = (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P);
   esetType = set of ET;
   erayType = array[ET] of boolean;
   csetType = set of char;
   crayType = array[char] of boolean;
   bsetType = set of Boolean;
   brayType = array[boolean] of boolean;
var
   Ev, Eadd   : ET;
   Cv, Cadd   : char;
   Bv, Badd   : boolean;
   Eset : esetType;
   Eray : erayType;
   Cset : csetType;
   Cray : crayType;
   Bset : bsetType;
   Bray : brayType;
   Eended, Cended, Bended, error : boolean;

function MinChar:char;
{ Returns least value in type char [see 6.4.2.2(d)] }
begin MinChar:=chr(0) end;

function MaxChar:char;
{ Should return largest value in type char, processor-dependent }
var Zero,Space:integer;
begin
   { These values MUST  be in char; even alphabet not guaranteed. }
   Zero:=ord('0'); Space:=ord(' ');
   if      (Zero= 48) and (Space= 32) then
      { ISO, ASCII }         MaxChar:=chr(127)
   else if (Zero=240) and (Space= 64) then
      { EBCDIC }             MaxChar:=chr(255)
   else if (Zero= 27) and (Space= 45) then
      { CDC }                MaxChar:=chr(63)
   else begin
      { unknown, users should modify to suit }
      MaxChar:=chr(0);
      WrLn(' UNKNOWN CHARACTER SET - TEST INVALIDATED')
   end
end;

   procedure Echeck; { deliberately tests obfuscated text allowed }
   var i:ET;
   begin
      for i:=A to P do if Eray[i] then begin if not(i in Eset) then
      error:=true end else if (i in Eset) then error:=true
   end;

   procedure Ccheck;
   var i:char;
   begin
      for i:=MinChar to MaxChar do if Cray[i] then begin
      if not(i in Cset) then error:=true end else if(i in Cset)
      then error:=true
   end;

   procedure Bcheck;
   var i:boolean;
   begin
      for i:=false to true do if Bray[i] then begin if not(i in Bset)
      then error:=true end else if (i in Bset) then error:=true
   end;

   procedure Eperm;
   begin
      Eset := Eset + [Eadd];
      Eray[Eadd] := true;
      if Eadd = P then Eended := true
      else Eadd := succ(Eadd)
   end;

   procedure Cperm;
   begin
      Cset := Cset + [Cadd];
      Cray[Cadd] := true;
      if Cadd = MaxChar then Cended := true
      else Cadd := succ(Cadd)
   end;

   procedure Bperm;
   begin
      Bset := Bset + [Badd];
      Bray[Badd] := true;
      if Badd = true then Bended := true
      else Badd := succ(Badd)
   end;

begin { of body of main program }
   error:=false;
   Eended := false; Bended := false; Cended := false;
   Eadd := A;  Cadd := MinChar;  Badd := false;
   Eset:=[]; for Ev:=A to P do Eray[Ev]:=false;
   Echeck;
   while not Eended do
      begin Eperm; Echeck end;

   Cset:=[]; for Cv:=MinChar to MaxChar do Cray[Cv]:=false;
   Ccheck;
   while not Cended do
      begin Cperm; Ccheck end;

   Bset:=[]; for Bv:=false to true do Bray[Bv]:=false;
   Bcheck;
   while not Bended do
      begin Bperm; Bcheck end;

   if not error then
      PASS('6.7.1-8')
   else
      FAIL('6.7.1-8')
end;


{TEST 6.7.1-9, CLASS=CONFORMANCE}

{: This test checks that the set-constructor can denote all values
   allowed by the canonic set-type to which it belongs. }
{  This test employs sets of types which are subranges. }
{V3.1: New test. }

procedure t6p7p1d9;
const
   LoOut=-10000; LoIn=0; HiIn=255; HiOut=+10000;
type
   subset = LoOut..HiOut;
   subsubset = LoIn..HiIn;
   SsetType = set of subsubset;
var
   Sset  : SsetType;
   i     : subset;
   error : boolean;

begin
   error:=false;
   Sset:=[LoIn..HiIn];
   for i:=LoOut to HiOut do
      if (i<LoIn) or (i>HiIn) then
         error:=error or (i in Sset)
      else
         error:=error or not(i in Sset);
   if not error then
      PASS('6.7.1-9')
   else
      FAIL('6.7.1-9')
end;


{TEST 6.7.1-10, CLASS=CONFORMANCE}

{: This test checks that the set-constructor can denote all values
   allowed by the canonic set-type to which it belongs. }
{  This test is intended to trap implementations which 'fold' their
   character set for the set of char implementation.  Implementations
   whose 'set of char' is incomplete also fail. }
{V3.1: New test. }

procedure t6p7p1d10;
type
   CharSet     = set of char;
var
   Cseta,Csetb : CharSet;
   cha,chb     : char;
   error       : boolean;

   function MinChar:char;
   { Returns least value in type char [see 6.4.2.2(d)] }
   begin MinChar:=chr(0) end;

   function MaxChar:char;
   { Should return largest value in type char, processor-dependent }
   var Zero,Space:integer;
   begin
      { These values MUST be in char; even alphabet not guaranteed. }
      Zero:=ord('0'); Space:=ord(' ');
      if      (Zero= 48) and (Space= 32) then
         { ISO, ASCII }         MaxChar:=chr(127)
      else if (Zero=240) and (Space= 64) then
         { EBCDIC }             MaxChar:=chr(255)
      else if (Zero= 27) and (Space= 45) then
         { CDC}                 MaxChar:=chr(63)
      else begin
         { unknown, users should modify to suit }
         MaxChar:=chr(0);
         WrLn(' UNKNOWN CHARACTER SET - TEST INVALIDATED')
      end
   end;

begin
   error:=false;
   { Try all pair combinations }
   for cha:=MinChar to pred(MaxChar) do begin
      for chb:=succ(cha) to MaxChar do begin
         Cseta:=[cha]; Csetb:=[chb];
         error:=error or (cha in Csetb) or (chb in Cseta) or
                    not ((cha in Cseta) and (chb in Csetb))
      end;
   end;
   if not error then
      PASS('6.7.1-10')
   else
      FAIL('6.7.1-10')
end;
{$endif dolater}

{TEST 6.7.2.2-1, CLASS=CONFORMANCE}

{: This program checks the operation of the
   operators + - and *. }
{V3.0: Write for FAIL elaborated. }

procedure t6p7p2p2d1;
var
   i, x, y , counter : integer;
begin
   counter := 0;
   for x := -10 to 10 do begin
      if (succ(x)=x+1) then
         counter := counter+1;
      if (pred(x) = x-1) then
         counter := counter+1;
      if (x*x=sqr(x)) then
         counter:= counter+1
   end;
   if (counter=63) then PASS('6.7.2.2-1') else FAIL('6.7.2.2-1')
end;


{TEST 6.7.2.2-2, CLASS=CONFORMANCE}

{: This program checks that div and mod are implemented by the
   rule specified by the Pascal Standard. }
{V3.1: Comment changed. }

procedure t6p7p2p2d2;
var
   i, j, counter : integer;
begin
   counter:=0;
   for i:=0 to 6 do
      for j:=1 to 4 do
         if ((i-j)<((i div j)*j)) and (((i div j)*j)<=i) then
            counter:=counter+1;
counter:=counter; // $12
   for i:=0 to 6 do
      for j:=1 to 4 do
         if (i mod j)=(i-(i div j)*j) then
            counter:=counter+1;
   if counter=56 then PASS('6.7.2.2-2') else FAIL('6.7.2.2-2 div/mod')
end;


{TEST 6.7.2.2-3, CLASS=CONFORMANCE}

{: This program checks that constant and variable operands for
   div and mod produce the same result, and that negative
   operands, where  permitted, are accepted. }
{V3.1: Test revised to include div and mod by 5 and div by -5. }

procedure t6p7p2p2d3;
var
   i, j, l, m,counter : integer;
begin
   counter := 0;
   j:=2;

   for i:= -10 to 10 do begin
     l:=i div j;
     m:= i div 2;
     if (l=m) then counter := counter+1;
     l:=i mod j;
     m:= i mod 2;
     if (l=m) then counter := counter+1;
     if (m >= 0) and (m < 2) and
         ((m-i) div 2 * 2 = m-i) then counter := counter+1
   end;

   j:=-2;
   for i:= -10 to 10 do begin
     l:=i div j;
     m:= i div (-2);
     if (l=m) then counter := counter+1
   end;

   j:=5;
   for i:= -10 to 10 do begin
     l:=i div j;
     m:= i div 5;
     if (l=m) then counter := counter+1;
     l:=i mod j;
     m:= i mod 5;
     if (l=m) then counter := counter+1;
     if (m >= 0) and (m < 5) and
         ((m-i) div 5 * 5 = m-i) then counter := counter+1
   end;

   j:=-5;
   for i:= -10 to 10 do begin
     l:=i div j;
     m:= i div (-5);
     if (l=m) then counter := counter+1
   end;

   if counter=168 then PASS('6.7.2.2-3') else FAIL('6.7.2.2-3 (div and mod with negative values)')
end;


{TEST 6.7.2.2-4, CLASS=CONFORMANCE}

{: This program checks that maxint satisfies the conditions laid
   down in the Pascal Standard. }
{V3.0: Last relational test extended. Was previously 6.7.2.2-5. }
{  Recoded to avoid compile-time range violation. }

procedure t6p7p2p2d4;
var
   i, max : integer;
begin
   max:=-(-maxint);
   i:=-maxint;
   if odd(maxint) then
      i:=(max-((max div 2)+1))*2
   else
      i:=(max-(max div 2))*2;
   if (maxint-1<=i) and (i<=maxint) then
      PASS('6.7.2.2-4')
   else
      FAIL('6.7.2.2-4')
end;



{TEST 6.7.2.3-1, CLASS=CONFORMANCE}

{: This test checks the operation of the Boolean operators. }
{V3.0: Writes revised. }

procedure t6p7p2p3d1;
var
   a,b,c : boolean;
   counter : integer;
begin
   counter:=0;
   a:=false;
   b:=false;
   { OR truth table }

   if a or b then
      FAIL('6.7.2.3-1, OR OPERATOR(1)')
   else
   begin
      b:=true;
      if a or b then
      begin
         a:=true;
         b:=false;
         if a or b then
         begin
            b:=true;
            if a or b then
               counter:=counter+1
            else
               FAIL('6.7.2.3-1, OR OPERATOR(2)')
         end
         else
            FAIL('6.7.2.3-1, OR OPERATOR(3)')
      end
      else
         FAIL('6.7.2.3-1, OR OPERATOR(4)')
   end;

   { AND truth table }
   a:=false;
   b:=false;
   if a and b then
      FAIL('6.7.2.3-1, AND OPERATOR(1)')
   else
   begin
      b:=true;
      if a and b then
         FAIL('6.7.2.3-1, AND OPERATOR(2)')
      else
      begin
         a:=true;
         b:=false;
         if a and b then
            FAIL('6.7.2.3-1, AND OPERATOR(3)')
         else
         begin
            b:=true;
            if a and b then
               counter:=counter+1
            else
               FAIL('6.7.2.3-1, AND OPERATOR(4)')
         end
      end
   end;

   { NOTE: NOT is sometimes badly implemented by wordwise
           complementation, and for this reason the following
           two tests may fail. }

   if (not false)=true then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, NOT OPERATOR(1)');

   if (not true)=false then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, NOT OPERATOR(2)');

   c:=false;
   a:=true;
   b:=false;
   if (a or b)=(b or a) then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, BOOLEAN COMMUTATION');

   if ((a or b)or c)=(a or(b or c)) then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, BOOLEAN ASSOCIATIVITY');

   if (a and(b or c))=((a and b)or(a and c)) then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, BOOLEAN DISTRIBUTION');

   if not(a or b)=((not a) and(not b)) then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, DEMORGAN1');

   if not(a and b)=((not a) or (not b)) then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, DEMORGAN2');

   if not(not a)= a then
      counter:=counter+1
   else
      FAIL('6.7.2.3-1, BOOLEAN INVERSION');

   if counter=10 then
      PASS('6.7.2.3-1')
end;


{TEST 6.7.2.4-1, CLASS=CONFORMANCE}

{: This test checks the operation of set operators. }
{V3.0: Write for PASS shortened. Was previously 6.7.2.4-2. }

procedure t6p7p2p4d1;
var
   a,b,c,d:set of 0..10;
   counter:integer;
begin
{$ifNdef dolater}
   counter :=0;
   a:=[0,2,4,6,8,10];
   b:=[1,3,5,7,9];
   c:=[];
   d:=[0,1,2,3,4,5,6,7,8,9,10];
   if (a+b=d) then
      counter:=counter+1;
   if (d-b=a) then
      counter := counter+1;
   if (d*b=b) then
      counter:=counter+1;
   if(d*b-b=c) then
      counter:=counter+1;
   if (a+b+c=d) then
      counter:=counter+1;
   if(counter=5) then
      PASS('6.7.2.4-1')
   else
      FAIL('6.7.2.4-1')
{$endif}
end;

{TEST 6.7.2.4-2, CLASS=CONFORMANCE}

{: This program checks the operations of set operators on sets
   of constants and variables. }
{V3.0: Write for PASS shortened. Was previously 6.7.2.4-3. }

{$ifNdef dolater}
procedure t6p7p2p4d2;
var
   a,b,c:set of 0..10;
   counter:integer;
begin
   counter:=0;
   a:=[0,2,4,6,8,10];
   b:=[1,3,5,7,9];
   c:=[0,1,2,3,4,5,6,7,8,9,10];
   if(a+[]=a) then             counter:=counter+1;
   if(a+b=c) then              counter:=counter+1;
   if(a+[1,3,5,7,9]=c) then    counter:=counter+1;
   if(a-[]=a) then             counter:=counter+1;
   if(c-a=b) then              counter:=counter+1;
   if(c-[0,2,4,6,8,10]=b) then counter:=counter+1;
   if(a*a=a) then              counter:=counter+1;
   if(a*[]=[]) then            counter:=counter+1;
   if(a*b=[]) then             counter:=counter+1;
   if(a*c=a) then              counter:=counter+1;
   if(counter=10) then
      PASS('6.7.2.4-2')
   else
      FAIL('6.7.2.4-2,'+i2s(Counter))
end;


{TEST 6.7.2.4-5, CLASS=CONFORMANCE}

{: This test checks the set operators, with all patterns possible. }
{  There are 64 (2 to 6th power) set values, so 4096 tests are made,
   which may be long (esp for bigger sets).  Another test provided
   in the suite is more economical, but less exhaustive. }
{V3.1: New test. }

procedure t6p7p2p4d5;
const
   Limit    = 64; { 2 to power of  cardinality of ET }
type
   ET       = (A,B,C,D,E,F);
   esetType = set of ET;
   erayType = array[ET] of boolean;
   Range    = 1..Limit;
var
   ev       : ET;
   s1,s2    : esetType;
   mt,
   vr,v1,v2 : erayType;
   r1,r2    : Range;
   error    : boolean;

   procedure DoIt;
   { Do all operations and check them for this pair of values. }

      procedure Union(var aa:erayType; ab,ac:erayType);
      var i:ET;
      begin
         for i:=A to F do aa[i]:=ab[i] or ac[i]
      end;

      procedure Intersection(var aa:erayType; ab,ac:erayType);
      var i:ET;
      begin
         for i:=A to F do aa[i]:=ab[i] and ac[i]
      end;

      procedure Difference(var aa:erayType; ab,ac:erayType);
      var i:ET;
      begin
         for i:=A to F do aa[i]:=ab[i] and not ac[i]
      end;

      procedure Check(SetOfE:esetType; VecOfE:eraytype);
      var i:ET;
      begin
         for i:=A to F do
            if VecOfE[i] then
               begin
                  if not (i in SetOfE) then error:=true
               end
            else
               if (i in SetOfE) then error:=true
      end;

   begin { of body of DoIt }
      Union       (vr,v1,v2); Check(s1+s2,vr);
      Intersection(vr,v1,v2); Check(s1*s2,vr);
      Difference  (vr,v1,v2); Check(s1-s2,vr)
   end;

   procedure Perm(k:Range; var sp:esetType; var vp:erayType);
   { Produce all permutations of sp and vp according to k }
   var x:ET;
   begin
      { What member to alter }
      x:=A;
      while not odd(k) do begin
         x:=succ(x); k:=k div 2
      end;
      { Alter the inclusion status of that value }
      if x in sp then sp:=sp-[x] else sp:=sp+[x];
      vp[x]:=not vp[x]
   end;

begin { of body of main program }
   error:=false;
   for ev:=A to F do mt[ev]:=false;

   s1:=[]; v1:=mt;
   r1:=1;
   while r1 <> Limit do begin
      s2:=[]; v2:=mt;
      r2:=1;
      while r2 <> Limit do begin
         DoIt;
         Perm(r2,s2,v2);
         r2:=succ(r2)
      end;
      Perm(r1,s1,v1);
      r1:=succ(r1)
   end;

   if not error then
      PASS('6.7.2.4-5')
   else
      FAIL('6.7.2.4-5')
end;


{TEST 6.7.2.4-6, CLASS=CONFORMANCE}

{: This test checks the set operators, with random values. }
{  This test is applied to a larger set size since optimization may
   have been employed for small sets of 6 elements; an exhaustive
   test is too expensive in computation time. }
{V3.1: New test. }

procedure t6p7p2p4d6;
const
   Big = 255;
   Reps = 100;
type
   IT       = 0..Big;
   IsetType = set of IT;
   IvecType = array[IT] of boolean;
var
   j        : IT;
   s1,s2    : IsetType;
   vr,v1,v2 : IvecType;
   count    : 1..Reps;
   ix       : integer;
   b,error  : boolean;

   procedure DoIt;

      procedure Union(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do begin b:=ab[i] or ac[i]; aa[i]:=b end;
      end;

      procedure Intersection(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do begin b:=ab[i] and ac[i]; aa[i]:=b end;
      end;

      procedure Difference(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do begin b:=ab[i] and not ac[i]; aa[i]:=b end;
      end;

      procedure Check(SetOfI:IsetType; var VecOfI:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do
            if VecOfI[i] then
               begin
                  if not (i in SetOfI) then error:=true
               end
            else
              if (i in SetOfI) then error:=true
      end;

   begin { of body of DoIt }
      Union       (vr,v1,v2); Check(s1+s2,vr);
      Intersection(vr,v1,v2); Check(s1*s2,vr);
      Difference  (vr,v1,v2); Check(s1-s2,vr)
   end;

   procedure Zap(var ba:IsetType; var bb:IvecType);
   var
      cc  :  IT;

      function random  :  integer;
      var
         ni,k,r:integer;
      begin
         k:=ix div 177; r:=ix-k*177;
         ni:=-2*k+171*r;
         if ni<0 then ix:=ni+30269 else ix:=ni;
         random:=ix
      end;

   begin { of body of Zap }
      cc:=random mod (Big+1);
      ba:=ba+[cc]; bb[cc]:=true; { Add member, if not present }
      cc:=random mod (Big+1);
      ba:=ba-[cc]; bb[cc]:=false; { Remove member, if present }
   end;

begin
   ix:=12; error:=false;

   s1:=[]; for j:=0 to Big do v1[j]:=false;
   s2:=[]; for j:=0 to Big do v2[j]:=false;
   for count:=1 to Reps do begin
      DoIt;
      Zap(s1,v1); Zap(s2,v2)
   end;

   if not error then
      PASS('6.7.2.4-6')
   else
      FAIL('6.7.2.4-6')
end;
{$endif dolater}

{TEST 6.7.2.5-1, CLASS=CONFORMANCE}

{: This program tests the use of relational operators on strings. }
{  The operators denote lexicographic ordering according to the
   ordering of the character set. }
{V3.0: Writes for FAIL revised. }

procedure t6p7p2p5d1;
type
   streng=packed array[1..7] of char;
var
   string1,
   string2 : streng;
begin
   string1:='STRING1';
   string2:='STRING2';
   if (string1<>string2) and (string1<string2) then
   begin
      string1:='STRINGS';
      string2:='STRINGZ';
      if (string1<>string2) and (string1<string2) then
         PASS('6.7.2.5-1')
      else
         FAIL('6.7.2.5-1, STRING COMPARISON(1)')
   end
   else
      FAIL('6.7.2.5-1, STRING COMPARISON(2)')
end;


{TEST 6.7.2.5-2, CLASS=CONFORMANCE}

{: This test checks the use of relational operators on sets. }
{V3.0: Write for PASS shortened. }

{$ifNdef dolater2}
procedure t6p7p2p5d2;
var
   a,b:set of 0..10;
  c,counter:integer;
begin
   counter:=0;
   a:=[0,1,2,3,4,5];
   b:=[2,3,4];
   c:=3;
   if(a=[0,1,2,3,4,5]) then counter:=counter+1;
   if(a<>b) then            counter:=counter+1;
   if(b<>[1,2,3,4,5]) then  counter:=counter+1;
   if(b<=a) then            counter:=counter+1;
   if(a>=b) then            counter:=counter+1;
   if([0,1]<=a) then        counter:=counter+1;
   if([1,2,3,4,5,6,10]>=b) then counter:=counter+1;
   if (1 in a) then         counter:=counter+1;
   if(c in b) then          counter:=counter+1;
   if(counter=9) then
     PASS('6.7.2.5-2')
   else
      FAIL('6.7.2.5-2')
end;
{$endif dolater} 

{TEST 6.7.2.5-3, CLASS=CONFORMANCE}

{: This test checks the use of relational operations on long
   strings. }
{  No semantic problems but the long strings could cause
   implementation difficulties. }
{V3.0: New test. }

procedure t6p7p2p5d3;
var s1, s2: packed array [1..37] of char;
    i, j: integer;
begin
   s1 := 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
   s2 := s1;
   j := 0;
   if s1 <> s2 then
      j := j + 1;
   for i := 37 downto 1 do
      begin
      s2[i] := 'B';
      if (s2 = s1) or (s2 < s1) then
         j := j + 1
      else if s2 <= s1 then
         j := j + 1
      else if s1 > s2 then
         j := j + 1
      end;
   if s2 <> 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB' then
      j := j + 1;
   if j = 0 then
      PASS('6.7.2.5-3')
   else
      FAIL('6.7.2.5-3')
end;


{TEST 6.8.2.1-1, CLASS=CONFORMANCE}

{: This test checks that all the empty clauses are permitted. }
{  Note: Permissibility of an empty clause in the field list of
   a record is actually stated in section 6.4.3.3 of the Standard,
   and in a case statement in section 6.8.3.5. }
{V3.1: Reals removed and empty else clause added. }

procedure t6p8p2p1d1;
var
   b:boolean;
   r1:record
       x:char;
       a:integer;   {1}
       end;
   r2:record
       case b:boolean of
       true:(
             c:char;
             d:char;   {2}
            );
       false:
             (e:integer);   {3}
       end;
begin
   b:=true;
   if b then;   {4}
   repeat
      b:= not b;   {5}
   until b;
   while b do
   begin
      b:=not b;   {6}
   end;
   with r1 do;   {7}
   if b then b:=true else;  {8}
   r1.a:=1;
   case r1.a of
   0:  b:=false;
   1:  ;   {9}
   2:  b:=true;   {9}
   end;
   PASS('6.8.2.1-1');   {10}
end;


{TEST 6.8.3.4-1, CLASS=CONFORMANCE}

{: This test checks a nested if-statement whose syntax is apparently
   ambiguous. }
{V3.0: Comma inserted in header.
   Writes elaborated for FAIL }

procedure t6p8p3p4d1;
const
   off=false;
var
   b:boolean;
begin
   for b:=false to true do
      begin
      if b then
         if off then
            FAIL('6.8.3.4-1, IF STATEMENT(1)')
         else
            begin
            if not b then
                FAIL('6.8.3.4-1, IF STATEMENT(2)')
            else
               PASS('6.8.3.4-1')
            end
      end
end;


{TEST 6.8.3.5-1, CLASS=CONFORMANCE}

{: This test checks that a minimal case-statement is accepted. }
{V3.0: Write shortened. }

procedure t6p8p3p5d1;
var
   i:integer;
begin
   i:=1;
   case i of
   1:
   end;
   PASS('6.8.3.5-1')
end;


{TEST 6.8.3.5-2, CLASS=CONFORMANCE}

{: This test checks that a processor will handle a case-statement
   where the case-constants are not close together. }
{  Most processors issue a jump table for a case, regardless
   of its structure. It is easy to optimise case-statements
   to generate conditional statements if this is more compact.
   Processors which employ simple strategies for implementation of
   case-statements may fail this test. }
{V3.0: Comment changed. }

procedure t6p8p3p5d2;
var
   i,j:integer;
begin
   i:=-1000;
   for j:=1 to 2 do
      case i of
      -1000: i:=-i;
      1000: PASS('6.8.3.5-2')
      end
end;


{TEST 6.8.3.7-1, CLASS=CONFORMANCE}

{: This test checks that a repeat-statement is executed at
   least once. }
{V3.0: Writes revised. }

procedure t6p8p3p7d1;
var
   counter:integer;
   bool:boolean;
begin
   bool:=true;
   counter:=0;
   repeat
      counter:=counter+1
   until bool;
   if(counter=1) then
      PASS('6.8.3.7-1')
   else
      FAIL('6.8.3.7-1')
end;


{TEST 6.8.3.7-2, CLASS=CONFORMANCE}

{: This test checks that a repeat-statement containing no statements
   is executed until the expression is true. }
{V3.0: Writes revised. }

procedure t6p8p3p7d2;
var
  a:integer;

function bool : boolean;
begin
   a:=a+1;
   bool := a>=5
end;

begin
   a:=0;
   repeat
   until bool;
   if (a=5) then
      PASS('6.8.3.7-2')
   else
      FAIL('6.8.3.7-2')
end;


{TEST 6.8.3.7-3, CLASS=CONFORMANCE}

{: This test checks that an apparently infinite loop is allowed
   by the processor. }
{  Some processors may detect the loop as being infinite. }
{V3.0: Comment and writes revised. }

procedure t6p8p3p7d3;
label
   100;
const
   eternity = false;
var
   i:integer;
begin
   i:=0;
   repeat
      i:=i+1;
      if (i>50) then
         goto 100
   until eternity;
100:
   PASS('6.8.3.7-3')
end;


{TEST 6.8.3.8-1, CLASS=CONFORMANCE}

{: This test checks that a while-statement is not entered
   if the initial value of the Boolean expression is false. }
{V3.0: Comment and writes revised. }

procedure t6p8p3p8d1;
var
   bool:boolean;
   counter:integer;
begin
   counter:=0;
   bool:=false;
   while bool do
   begin
      counter:=counter+1;
      bool:=false
   end;
   if (counter=0) then
      PASS('6.8.3.8-1')
   else
      FAIL('6.8.3.8-1')
end;


{TEST 6.8.3.8-2, CLASS=CONFORMANCE}

{: This test checks that the processor will accept a while-statement
   containing no statements. }
{V3.0: Writes revised. }

procedure t6p8p3p8d2;
var
   a:integer;

function bool:boolean;
begin
   a:=a+1;
   bool:= (a>=5)
end;

begin
   a:=0;
   while not bool do ;
   if (a=5) then
      PASS('6.8.3.8-2')
   else
      FAIL('6.8.3.8-2')
end;


{TEST 6.8.3.9-1, CLASS=CONFORMANCE}

{: This program checks that assignment follows the evaluation
   of both expressions in a for-statement. }
{V3.1: Comment changed. }

procedure t6p8p3p9d1;
var
   i,j:integer;
begin
   i:=1;
   j:=0;
   for i:= (i+1) to (i+10) do
      j:=j+1;
   if j=10 then PASS('6.8.3.9-1') else FAIL('6.8.3.9-1')
end;


{TEST 6.8.3.9-2, CLASS=CONFORMANCE}

{: This test checks that extreme values may be used in a
   for-statement. }
{  This will break a simply implemented for loop.
   In some processors the succ test may fail at the last increment
   and cause wraparound(overflow) - leading to an infinite loop. }
{V3.0: Writes revised. Was previously 6.8.3.9-7. }

procedure t6p8p3p9d2;
var
   i,j:integer;
begin
   j:=0;
   for i:= (maxint-10) to maxint do
     j:=j+1;
   for i:= (-maxint+10) downto -maxint do
      j:=j+1;
   if j = 22 then
      PASS('6.8.3.9-2')
   else
      FAIL('6.8.3.9-2,'+i2s(j))    // => 11
end;


{TEST 6.8.3.9-3, CLASS=CONFORMANCE}

{: This program checks that a control-variable of a for-statement
   is not undefined if the for-statement is left via a
   goto-statement. }
{V3.0: Writes revised. Was previously 6.8.3.9-8. }

procedure t6p8p3p9d3;
label 100;
var
   i,j:integer;
begin
   j:=1;
   for i:=1 to 10 do
   begin
      if (j=5) then
         goto 100;
      j:=j+1
   end;
100:
   if i=j then
      PASS('6.8.3.9-3')
   else
      FAIL('6.8.3.9-3')
end;


{TEST 6.8.3.9-4, CLASS=CONFORMANCE}

{: This program checks the order of evaluation of the limit
   expressions in a for-statement. }
{V3.0: Comment and writes revised. Was previously 6.8.3.9-15. }

procedure t6p8p3p9d4;
var
   i,j,k:integer;

function f(var k:integer) : integer;
begin
   k:=k+1;
   f:=k
end;

begin
   k:=0;
   j:=0;
   for i:=f(k) to f(k)+10 do
      j:=j+1;
   if (j=12) then
      PASS('6.8.3.9-4')
   else
      FAIL('6.8.3.9-4')
end;


{TEST 6.8.3.10-1, CLASS=CONFORMANCE}

{: This program checks the implementation of the with-statement. }
{V3.0: Writes revised. }

procedure t6p8p3pXd1;
var
   r1:record
        a,b:integer
      end;
   r2:record
        c,d:integer
      end;
   r3:record
        e,f:integer
      end;
   counter:integer;
begin
   counter:=0;
   with r1 do
      a:=5;
   with r1,r2,r3 do
   begin
      e:=a;
      c:=a
   end;
   with r2 do
      if c=5 then
         counter:=counter+1;
   if r2.c=5 then
      counter:=counter+1;
   if counter=2 then
      PASS('6.8.3.10-1')
   else
      FAIL('6.8.3.10-1')
end;



{TEST 6.8.3.10-2, CLASS=CONFORMANCE}

{: This test checks that a field-identifier is correctly
   identified when a with-statement is invoked. }
{V3.0: Writes revised. }

procedure t6p8p3pXd2;
var
   r:record
       i,j:integer
     end;
   i:integer;
begin
   i:=10;
   with r do
      i:=5;
   if (i=10) and (r.i=5) then
      PASS('6.8.3.10-2')
   else
      FAIL('6.8.3.10-2')
end;


{TEST 6.8.3.10-3, CLASS=CONFORMANCE}

{: This test checks that the record-variable-list
   of a with-statement is evaluated in the correct order. }
{V3.0: Write for PASS shortened. }

procedure t6p8p3pXd3;
var
   r1:record
        i,j,k:integer
      end;
   r2:record
        i,j:integer
      end;
   r3:record
        i:integer
      end;
begin
   with r1 do
   begin
      i:=0;
      j:=0;
      k:=0
   end;
   with r2 do
   begin
      i:=0;
      j:=0
   end;
   with r3 do
      i:=0;
   with r1,r2,r3 do
   begin
      i:=5;
      j:=6;
      k:=7
   end;
   if(r1.i=0) and (r1.j=0) and (r2.i=0) and (r1.k=7)
      and (r2.j=6) and (r3.i=5) then
      PASS('6.8.3.10-3')
   else
      FAIL('6.8.3.10-3')
end;


{TEST 6.8.3.10-4, CLASS=CONFORMANCE}

{: This test checks that the selection of a variable in the
   record-variable-list is performed before the component
   statement is executed. }
{V3.0: Writes revised. }

procedure t6p8p3pXd4;
var
   a:array[1..2] of record
                      i,j:integer
                    end;
   k:integer;
begin
   a[2].i:=5;
   k:=1;
   with a[k] do
   begin
      j:=1;
      k:=2;
      i:=2
   end;
   if (a[2].i=5) and (a[1].i=2) then
      PASS('6.8.3.10-4')
   else
      FAIL('6.8.3.10-4')
end;

{TEST 6.8.3.10-5, CLASS=CONFORMANCE}

{: This test checks that the selection of a variable in the
   record-variable-list is performed before the component
   statement is executed. }
{V3.0: Writes revised. }

procedure t6p8p3pXd5;
type
   pointer = ^recordtype;
   recordtype = record
                  data:integer;
                  link:pointer
                end;
var
   counter:integer;
   p,q:pointer;
begin
   counter:=0;
   new(p);
   p^.data:=0;
   new(q);
   q^.data:=1;
   q^.link:=nil;
   p^.link:=q;
   q:=p;
   with q^ do
   begin
      q:=link;
      if (data=0) and (q^.data=1) then
         counter:=counter+1
   end;
   with p^ do
   begin
      p:=link;
      { The first record now has no reference, so it could
        be deleted prematurely. }
      if (data=0) and (p^.data=1) then
         counter:=counter+1
   end;
   if counter=2 then
         PASS('6.8.3.10-5')
      else
         FAIL('6.8.3.10-5');
   //Dispose(p);
   //Dispose(q);
end;


{TEST 6.8.3.10-6, CLASS=CONFORMANCE}

{: This test checks that the order of evaluation of the
   record-variable-list in a with-statement is correctly
   implemented. }
{V3.0: Writes revised. }

procedure t6p8p3pXd6;
type
   pp = ^ptr;
   ptr = record
           i:integer;
           link:pp
         end;
var
   p,q,r : pp;
begin
   new(p);
   p^.i := 0;
   new(q);
   q^.i := 0;
   p^.link := q;
   new(r);
   r^.i := 0;
   r^.link := nil;
   q^.link := r;
   with p^, link^, link^ do
      i:=5;
   if ((r^.i=5) and (q^.i=0) and (p^.i=0)) then
      PASS('6.8.3.10-6')
   else
      FAIL('6.8.3.10-6');
   Dispose(p);
   Dispose(q);
   Dispose(r);
end;


{TEST 6.8.3.10-8, CLASS=CONFORMANCE}

{: This test contains a record-variable-list in which all the
   identifiers are identical. }
{  The record-variable-list of a with-statement can contain twice or
   more times the same identifier - to denote a record , its homonymous
   field which is itself a record, etc. }
{V3.1: New test from BNI. }

procedure t6p8p3pXd8;
var
   i:integer;
   rec:record
          i:integer;
          rec:record
                 i:integer;
                 rec:record
                        i:integer;
                     end;
              end;
       end;
begin
   rec.i:=100;
   with rec,rec do
      begin
         i:=20;
         rec.i:=3;
      end;
   with rec,rec,rec do
      begin
         i:=rec.i+1; {Here 'i' has the same meaning as 'rec.i' ,
                      or as 'rec.i' in the previous 'with'}
   end;
   i:=rec.i+rec.rec.i+rec.rec.rec.i;
   if i=124
      then PASS('6.8.3.10-8')
      else FAIL('6.8.3.10-8')
end;


{TEST 6.10-3, CLASS=CONFORMANCE}

{: The identifier after 'program' has no significance within
   a program. Hence this program should be acceptable. }
{V3.0: New test derived from a processor bug. }

procedure t6p10d3;
var
   t6p10d3: integer;
begin
   t6p10d3 := 1;
   PASS('6.10-3')
end;

{TEST 6.1.7-2, CLASS=CONFORMANCE}

{: This program tests if strings are permitted up to a length of
   68 characters. }
{  The Pascal Standard does not place an upper limit
   on the length of strings. }
{V3.0: Check on value added. Writes revised. }

{$IfNdef SkipAlways}
procedure t6p1p7d2;
type
   string1 = packed array[1..68] of char;
   string2 = packed array[1..33] of char;
var
   alpha : string1;
   i     : string2;
begin
   alpha:=
'ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOP'
 ;
   i:='IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII';
   if (alpha[9] = i[32]) then
      PASS('6.1.7-2')
   else
      FAIL('6.1.7-2')
end;
{$endif}


{TEST 6.1.7-3, CLASS=CONFORMANCE}

{: This program checks that a apostrophe-image can appear as a char
   constant and as an element of a string. }
{V3.0: Program and comment revised to become a more strict
   test for the feature. }

{$IfNdef SkipAlways}
procedure t6p1p7d3;
const
   quote = '''';
var
   s: packed array[1..5] of char;
begin
   s:='CAN''T';
   if (s[4]=quote)and(s[5]='T') then
      PASS('6.1.7-3')
   else
      FAIL('6.1.7-3')
end;
{$endif}

{TEST 6.4.3.2-3, CLASS=CONFORMANCE}
{: This program tests that an array can have extreme index
   values as its first (and only in this case) valid value. }
{V3.0: New test. }

procedure t6p4p3p2d3;
{$Ifdef SkipAlways}
begin
  FAILPALM('6.4.3.2-3, array [$8000..-maxint] not allowed')
end;
{$else}
var
   mmaxint: integer;
var
   small: array[ $8000  .. -maxint] of integer;
   large: array[ maxint ..  maxint] of integer;
begin
   mmaxint:=$8000;
   small[mmaxint] := 1;
   large[maxint] := small[mmaxint];
   if large[maxint] <> 1 then
      FAIL('6.4.3.2-3')
   else
      PASS('6.4.3.2-3')
end;
{$endif}

{TEST 6.4.3.5-1, CLASS=CONFORMANCE}
{: This test contains several file-variables, each of which has a
   different component-type. }
{  A file-type is a structured-type consisting of a sequence of
   components which are all one type. All cases in this program
   should be acceptable. }
{V3.1: Program parameters removed. }

{$IfNdef SkipAlways}
procedure t6p4p3p5d1;
type
   i = integer;
   ptrtoi = ^i;
var
   file1 : file of char;
   file2 : file of real;
   file3 : file of
            record
               a : integer;
               b : boolean
            end;
   file4 : file of set of (red,blue,green,purple);
   file5 : file of ptrtoi;
begin
   PASS('6.4.3.5-1')
end;
{$endif}

(****
begin
   t6p6p6p5d2;
   t6p7p2p4d5;
   t6p8p3p9d2;
   t6p4p4d1;     <<<<<<<<<
end...........
(***)

begin
{$ifdef xzczxczcx}
   t6p1p1d1;
   t6p1p1d2;
   t6p1p2d1;
   t6p1p2d3;
   t6p1p3d1;
   t6p1p3d2;
   t6p1p6d1;
   t6p1p6d3;
   t6p1p7d1;
   //t6p1p7d2;
   //t6p1p7d3;
   t6p1p8d2;
   t6p1p9d2;
   t6p1p9d3;
   t6p2p1d1;
   t6p2p1d2;
   t6p2p2d1;
   t6p2p2d2;
   t6p2p2d3;
   t6p2p2d4;
   t6p2p2d5;
   t6p2p2d6;
   t6p2p2d7;
   t6p3d1;
   t6p4p1d1;
   t6p4p2p2d1;
   t6p4p2p2d2;
   t6p4p2p2d3;
   t6p4p2p2d4;
   t6p4p2p2d5;
   t6p4p2p2d6;
   t6p4p2p2d7;
   t6p4p2p2d8;
   t6p4p2p3d1;
   t6p4p2p3d2;
   t6p4p2p3d3;
   t6p4p2p3d4;
   t6p4p2p4d1;
   t6p4p2p4d2;
   t6p4p3p1d1;
   t6p4p3p1d2;
   t6p4p3p2d1;
   t6p4p3p2d2;
   t6p4p3p2d3;
   t6p4p3p3d1;
   t6p4p3p3d2;
   t6p4p3p3d3;
   t6p4p3p3d4;
   t6p4p3p3d5;
   t6p4p3p3d6;
   t6p4p3p3d7;
   t6p4p3p3d17;
   t6p4p3p4d1;
   t6p4p3p4d2;
   //t6p4p3p5d1;
   asm trap #8 end;
   t6p4p4d1;
   t6p4p5d1;
   t6p4p5d2;
   t6p4p5d3;
{$else}
   t6p4p5d4;
   t6p4p5d5;
   t6p4p5d6;
   t6p4p6d1;
   t6p4p6d2;
   t6p4p6d3;
   t6p5p1d1;
   {$ifNdef dolater} t6p5p3p2d1; {$endif}   ///////
   t6p6p1d1;
   t6p6p1d2;
   t6p6p2d1;
   t6p6p2d2;
   t6p6p2d3;
   t6p6p2d4;
   t6p6p3p1d1;
   {$ifNdef dolater2} t6p6p3p1d2; {$endif}
   t6p6p3p3d1;
   t6p6p3p3d2;
   t6p6p3p3d3;
   t6p6p4p1d1;
   t6p6p4p1d2;
   t6p6p5p3d2;
   t6p6p5p3d20;  //Uses a lot on NEW!!
   t6p6p6p2d1;
   t6p6p6p2d2;
   t6p6p6p2d3;
   t6p6p6p3d1;
   t6p6p6p4d1;
   t6p6p6p4d2;
   t6p6p6p4d3;
   t6p6p6p5d2;
   t6p7p1d1;
   t6p7p1d2;
   t6p7p1d6;
   t6p7p1d7;
   t6p7p1d8;
   t6p7p1d9;
   t6p7p1d10;

   t6p7p2p2d1;
   t6p7p2p2d2;
   t6p7p2p2d3;
   t6p7p2p2d4;
   t6p7p2p3d1;
   t6p7p2p4d1;

   {$ifNdef dolater} 
   t6p7p2p4d2;
   t6p7p2p4d5;
   t6p7p2p4d6;
   {$endif}

   t6p7p2p5d1;
   {$ifNdef dolater2} t6p7p2p5d2; {$endif}
   t6p7p2p5d3;
   t6p8p2p1d1;
   t6p8p3p4d1;
   t6p8p3p5d1;
   t6p8p3p5d2;
   t6p8p3p7d1;
   t6p8p3p7d2;
   t6p8p3p7d3;
   t6p8p3p8d1;
   t6p8p3p8d2;
   t6p8p3p9d1;
   t6p8p3p9d2;
   t6p8p3p9d3;
   t6p8p3p9d4;
   t6p8p3pXd1;
   t6p8p3pXd2;
   t6p8p3pXd3;
   t6p8p3pXd4;
   t6p8p3pXd5;
   t6p8p3pXd6;
   t6p8p3pXd8;
   t6p10d3;
{$endif}
end.
