program PVScon(Output);
{$define SKIP}

{$searchpath R:\Hspc; R:\Hspc\Units}
{$searchpath R:\Hspc\Units\UI; R:\Hspc\Units\System}

sdf adsf af


procedure t6p7p1d10;
type
   CharSet     = set of char;
var
   Cseta,Csetb : CharSet;
   cha,chb     : char;
   error       : boolean;
begin
 error:=error or (cha in Csetb) or (chb in Cseta) 
end;
asdadasd







(********* PROBLEM!!!!!!
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
procedure testone(var set1: sett);
begin
  if set1=[1..9] then
end;

begin
setone:=[1];

end;
adasd
(**********)






Procedure Writeln(Const S: String);
begin
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
   cseti:=['0'..'9'];
   cset1:=[]; cset2:=['A','Z']; cset3:=['0'..'9'];
   eset1:=[]; eset2:=[orange]; eset3:=[orange];
   if (cseti+cset1 = (cset3-cset2)*cseti) and
      (eset1+eset2 = eset3-eset1)
   then
      writeln(' PASS...6.4.5-5')
   else
      writeln(' FAIL...6.4.5-5')
end;


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
   writeln(' PASS...6.4.6-1');
   i:=2;
   j:=i;
   col1:=yellow;
   col2:=col1;
   col3:=[pink];
   col4:=col3;
   urray2[1]:=100;
   urray2[I]:=900;
   urray1[6]:=urray2[1];
   record1.a:=200;
   record1.b:=true;
   record2:=record1;
   writeln(' PASS...6.4.6-1')
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
   writeln(' PASS...6.4.5-1')
end;


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
   writeln(' PASS...6.4.3.3-3')
end;


{TEST 6.4.3.3-4, CLASS=CONFORMANCE}

{: This test checks that a tag-field may be redefined
   elsewhere in the declaration part. }
{  Test similar to 6.4.3.3-2. }
{V3.0: Comment revised, and value test added. }

procedure t6p4p3p3d4;
type
   which = (white,black,warlock,sand);
var
   thing : which;
{  polex : record
             case which:boolean of
               true: (realpart:real;
                      imagpart:real);
               false:(theta:real;
                      magnit:real)
           end;}
begin
{  thing := black;
   polex.which:=true;
   polex.realpart:=0.5;
   polex.imagpart:=0.8;
   if (thing = black) and polex.which then
      writeln(' PASS...6.4.3.3-4')
   else
}     writeln(' FAIL...6.4.3.3-4 (tag-field may be redefined)')
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
   writeln(' PASS...6.4.3.3-5')
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
   writeln(' PASS...6.4.3.3-6')
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
    writeln(' PASS...6.4.3.3-7')
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
    writeln (' PASS...6.4.3.3-17')
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
   writeln(' PASS...6.4.3.4-1')
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
end;


{TEST 6.4.3.5-1, CLASS=CONFORMANCE}

{: This test contains several file-variables, each of which has a
   different component-type. }
{  A file-type is a structured-type consisting of a sequence of
   components which are all one type. All cases in this program
   should be acceptable. }
{V3.1: Program parameters removed. }

{$IfNdef Skip}
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
   writeln(' PASS...6.4.3.5-1')
end;
{$endif}


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
      writeln(' PASS...6.4.5-2')
   else
      writeln(' FAIL...6.4.5-2')
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
   if col1 < col2 then writeln(' PASS...6.4.5-3')
                  else writeln(' FAIL...6.4.5-3')
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
         writeln(' PASS...6.4.5-4')
      else
         writeln(' FAIL...6.4.5-4, STRINGS(1)')
   else
      writeln(' FAIL...6.4.5-4, STRINGS(2)')
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
      writeln(' PASS...6.4.5-6')
   else
      writeln(' FAIL...6.4.5-6')
end;


{TEST 6.4.6-1, CLASS=CONFORMANCE}

{: This program tests that assignment compatible types as
   described by the Pascal Standard, are permitted by this
   processor. }
{  This program tests only those uses in assignment statements.
   All cases have been tested elsewhere, but are included here
   together for consistency. }
{V3.0: Comment revised. }

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
   compat(2,2.4,yellow,yellow,[pink],[pink]);
   a:=2;
   b:=3.1;
   colour1:=pink;
   colour2:=green;
   colour3:=[yellow];
   colour4:=[yellow];
   compat(a,b,colour1,colour2,colour3,colour4);
   compat(a,a,colour2,colour2,colour4,colour4);
   writeln(' PASS...6.4.6-2')
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
   writeln(' PASS...6.4.6-3')
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
   angle         = real;
   polar         = record
                       r : real;
                       theta : angle
                   end;
   indextype     = 1..limit;
   vector        = array[indextype] of real;
   person        = ^ persondetails;
   persondetails = record
                      age : integer;
                      married : boolean;
                      father,child,sibling : person;
                      case s:sex of
                         male   : (enlisted,bearded : boolean);
                         female : (mother,programmer : boolean)
                      end;
var
   x,y,z,max: real;
   i,j      : integer;
   k        : 0..9;
   p,q,r    : boolean;
   operator : (plus,minus,times);
   a        : array[0..63] of real;
   c        : colour;
   hue1,hue2: set of colour;
   p1,p2    : person;
   m,m1,m2  : array[1..10,1..10] of real;
   coord    : polar;
   //pooltape : array[1..4] of FileOfInteger;
   date     : record
                 month : 1..12;
                 year  : integer
              end;
begin
   writeln(' PASS...6.5.1-1')
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
      writeln(' PASS...6.5.3.2-1')
   else
      writeln(' FAIL...6.5.3.2-1')
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
   writeln(' PASS...6.6.1-1')
end;

begin
   a:=1;
   b:=2;
   withparameters(a,b);
   parameterless;
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
      writeln(' PASS...6.6.1-2')
  else
     writeln(' FAIL...6.6.1-2')
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
      writeln(' PASS...6.6.2-1')
   else
      writeln(' FAIL...6.6.2-1')
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
      writeln(' PASS...6.6.2-2')
   else
      writeln(' FAIL...6.6.2-2')
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
   writeln(' PASS...6.6.2-3')
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
  writeln( ' MESSAGE' );
   testc:='6'
end;

function testd:ptrtochar;
   {blatantly sneaky: modifying the environment via new
      and then passing it out}
var
   pp:ptrtochar;
begin
   new(pp);
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
      writeln(' PASS...6.6.2-4')
   else
      writeln(' FAIL...6.6.2-4')
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
   if counter=3 then
      writeln(' PASS...6.6.3.1-1')
   else
      if counter=2 then
         writeln(' FAIL...6.6.3.1-1, VALUE PARAMETERS')
      else
         if counter=1 then
            writeln(' FAIL...6.6.3.1-1, VAR PARAMETERS')
         else
            writeln(' FAIL...6.6.3.1-1, PARAMETERS')
end;


{TEST 6.6.3.1-2, CLASS=CONFORMANCE}

{: This program checks that set, record and array parameters are
   permitted. }
{  Similar to 6.6.3.1-1. }
{V3.0: Value check added.
   Writes altered to conform to convention. }

{$ifndef skip}
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
      writeln(' PASS...6.6.3.1-2')
   else
      if counter=2 then
         writeln(' FAIL...6.6.3.1-2, VALUE PARAMETERS')
      else
         if counter=1 then
            writeln(' FAIL...6.6.3.1-2, VAR PARAMETERS')
         else
            writeln(' FAIL...6.6.3.1-2, PARAMETERS')
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
     writeln(' FAIL...6.6.3.3-1')
   else
     writeln(' PASS...6.6.3.3-1')
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
   pass  : boolean;
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
   pass:=false;
   indirection(direct,pass);
   if pass then
      writeln(' PASS...6.6.3.3-2')
   else
      writeln(' FAIL...6.6.3.3-2')
end;


{TEST 6.6.3.3-3, CLASS=CONFORMANCE}

{: This test checks that if a variable passed as a parameter
   involves the indexing of an array, or the dereferencing of a
   pointer, then these actions are executed before the activation
   of the block. }
{V3.0: Rewritten to include type rekptr = ^rekord
   Write for FAIL elaborated. }

{$IfNdef Skip}
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
         writeln(' FAIL...6.6.3.3-3')
      else
         writeln(' PASS...6.6.3.3-3')
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
   call(urray[i],ptr^.a)
end;
{$endif}


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
      writeln(' PASS...6.6.4.1-1')
   else
      writeln(' FAIL...6.6.4.1-1')
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
      writeln(' PASS...6.6.4.1-2')
   else
      writeln(' FAIL...6.6.4.1-2')
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
     {dispose(ptr)}   { *** dispose not implemented *** }
   end;
   writeln(' PASS...6.6.5.3-2')
end;


{TEST 6.6.5.3-20, CLASS=CONFORMANCE}

{: This test contains multi-level pointers. }
{  NEW applied to a pointer to an array and then to its element
   which is itself a pointer. }
{V3.1: New test from BNI. }

{$IfNdef Skip}
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
      then writeln(' PASS...6.6.5.3-20')
      else writeln(' FAIL...6.6.5.3-20')
end;
{$endif}


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
      writeln(' PASS...6.6.6.2-1')
   else
      writeln(' FAIL...6.6.6.2-1')
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
      writeln(' PASS...6.6.6.2-2')
   else
      writeln(' FAIL...6.6.6.2-2')
end;


{TEST 6.6.6.2-3, CLASS=CONFORMANCE}

{: This program tests the implementation of the arithmetic
   functions sin, cos, exp, ln, sqrt, and arctan. }
{  A rough accuracy test is done, but is not the purpose
   of this program. }
{V3.0: Accuracy reduced to 4 digits maximum.
   Checks extended to limits both sides of all function
   results. Writes for failure standardised. }

{$IfNdef Skip}
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
      writeln(' FAIL...6.6.6.2-3, SIN FUNCTION');

   if ((-1.001<cos(pi)) and (cos(pi)<-0.999)) and
      ((0.70<cos(pi/4)) and (cos(pi/4)<0.71)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3, COS FUNCTION');

   if ((2.710<exp(1)) and (exp(1)<2.720)) and
      ((0.36<exp(-1)) and (exp(-1)<0.37)) and
      ((8100<exp(9)) and (exp(9)<8110)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3, EXP FUNCTION');

   if ((0.999<ln(exp(1))) and (ln(exp(1))<1.001)) and
      ((0.69<ln(2)) and (ln(2)<0.70)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3, LN FUNCTION');

   if ((4.99<sqrt(25)) and (sqrt(25)<5.01)) and
      ((5.09<sqrt(26)) and (sqrt(26)<5.10)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3, SQRT FUNCTION');

   if ((0.090<arctan(0.1)) and (arctan(0.1)<0.10)) and
      ((-0.001<arctan(0)) and (arctan(0)<0.001)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3, ARCTAN FUNCTION');

   if counter=6 then
      writeln(' PASS...6.6.6.2-3')
end;
{$endif}


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
      writeln(' FAIL...6.6.6.3-1, TRUNC FUNCTION');

   if (round(3.7)=4) and (round(-3.7)=-4) then
      roundstatus:=roundstatus+1
   else
      writeln(' FAIL...6.6.6.3-1, ROUND FUNCTION');

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
         else
            writeln(' FAIL...6.6.6.3-1, TRUNC/ROUND FUNCTIONS(1)')
      else
         if (trunc(j+0.5)=round(j)) then
            begin
               truncstatus:=truncstatus+1;
               roundstatus:=roundstatus+1
            end
         else
            writeln(' FAIL...6.6.6.3-1, TRUNC/ROUND FUNCTIONS(2)')
   end;

   if (truncstatus=668) and (roundstatus=668) then
      writeln(' PASS...6.6.6.3-1')
  else
      writeln(' FAIL...6.6.6.3-1')
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
      writeln(' FAIL...6.6.6.4-1, ORD OF BOOLEAN-TYPE');

   if (ord(red)=0) and (ord(orange)=1) and
      (ord(yellow)=2) and (ord(green)=3) and
      (ord(blue)=4) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1, ORD OF ENUMERATED-TYPE(1)');

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
            writeln(' FAIL...6.6.6.4-1, ORD OF INTEGER-TYPE')
         end
   end;

   colour:=blue;
   some:=orange;
   if ord(colour)=4 then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1, ORD OF ENUMERATED-TYPE(2)');

   if ord(some)=1 then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1, ORD OF SUBRANGE-TYPE');

   if counter=25 then
      writeln(' PASS...6.6.6.4-1')
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
      writeln(' PASS...6.6.6.4-2')
   else
      writeln(' FAIL...6.6.6.4-2')
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
      writeln(' FAIL...6.6.6.4-3, SUCC/PRED OF BOOLEAN-TYPE');

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
            writeln(' FAIL...6.6.6.4-3, SUCC/PRED OF INTEGER-TYPE');
            ok:=false
            end
      end;

   for digit:='0' to '8' do
      if pred(succ(digit))=digit then
         counter:=counter+1
      else
         writeln(' FAIL...6.6.6.4-3, SUCC/PRED OF CHAR-TYPE');

   if (succ(red)=orange) and (succ(orange)=yellow) and
      (succ(yellow)=green) and (succ(green)=blue) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-3, SUCC OF ENUMERATED-TYPE');
   if (red=pred(orange)) and (orange=pred(yellow)) and
      (yellow=pred(green)) and(green=pred(blue)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-3, PRED OF ENUMERATED-TYPE');

   some:=yellow;
   if (succ(some)=green) and (pred(some)=orange) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-3, SUCC/PRED OF SUBRANGE-TYPE');

   if counter=34 then
      writeln(' PASS...6.6.6.4-3')
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
      writeln(' PASS...6.6.6.5-2')
   else
      writeln(' FAIL...6.6.6.5-2')
end;


{TEST 6.7.1-1, CLASS=CONFORMANCE}

{: This program tests the precedence of operators. }
{V3.0: New test, replacing previous tests 6.7.1-1, 6.7.1-2
   and 6.7.2.1-3. }

{$ifNdef SKIP}
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
      writeln(' PASS...6.7.1-1')
   else
      begin
      if boolean in indicator then
         writeln(' FAIL...6.7.1-1, PRECEDENCE - BOOLEAN OPERATORS');
      if adding in indicator then
         writeln(' FAIL...6.7.1-1, PRECEDENCE - ADDING OPERATORS');
      if multiplying in indicator then
         writeln(' FAIL...6.7.1-1, PRECEDENCE - MULTIPLYING OPERATORS');
      if relational in indicator then
         writeln(' FAIL...6.7.1-1, PRECEDENCE - RELATIONAL OPERATORS')
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
   x:=2;
   y:=1;
   if ([x..y]=[]) and ([127..0]=[]) then
      writeln(' PASS...6.7.1-2')
   else
      writeln(' FAIL...6.7.1-2')
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
   if c=5 then writeln(' PASS...6.7.1-6')
          else writeln(' FAIL...6.7.1-6')
end;

{TEST 6.7.1-7, CLASS=CONFORMANCE}

{: This test checks that the set-constructor can denote both packed and
   unpacked set types in the appropriate contexts. }
{V3.1: New test. }

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
      writeln(' PASS...6.7.1-7')
   else
      writeln(' FAIL...6.7.1-7')
end;
{$endif}


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
      writeln(' UNKNOWN CHARACTER SET - TEST INVALIDATED')
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
      writeln(' PASS...6.7.1-8')
   else
      writeln(' FAIL...6.7.1-8')
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
      writeln(' PASS...6.7.1-9')
   else
      writeln(' FAIL...6.7.1-9')
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
         writeln(' UNKNOWN CHARACTER SET - TEST INVALIDATED')
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
      writeln(' PASS...6.7.1-10')
   else
      writeln(' FAIL...6.7.1-10')
end;


{TEST 6.7.2.2-1, CLASS=CONFORMANCE}

{: This program checks the operation of the
   operators + - and *. }
{V3.0: Write for FAIL elaborated. }

procedure t6p7p2p2d1;
var
   i, x, y , counter : integer;
begin
   counter := 0;
   for x := -10 to 10 do
   begin
      if (succ(x)=x+1) then
         counter := counter+1;
      if (pred(x) = x-1) then
         counter := counter+1;
      if (x*x=sqr(x)) then
         counter:= counter+1
   end;
   if (counter=63) then
      writeln(' PASS...6.7.2.2-1')
   else
      writeln(' FAIL...6.7.2.2-1')
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
   for i:=0 to 6 do
      for j:=1 to 4 do
         if (i mod j)=(i-(i div j)*j) then
            counter:=counter+1;
   if counter=56 then
      writeln(' PASS...6.7.2.2-2')
   else
      writeln(' FAIL...6.7.2.2-2')
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

   for i:= -10 to 10 do
   begin
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
   for i:= -10 to 10 do
   begin
      l:=i div j;
      m:= i div (-2);
      if (l=m) then counter := counter+1
   end;

   j:=5;

   for i:= -10 to 10 do
   begin
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
   for i:= -10 to 10 do
   begin
      l:=i div j;
      m:= i div (-5);
      if (l=m) then counter := counter+1
   end;

   if counter=168 then
      writeln(' PASS...6.7.2.2-3')
   else
      writeln(' FAIL...6.7.2.2-3 (div and mod with negative values)')
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
      writeln(' PASS...6.7.2.2-4')
   else
      writeln(' FAIL...6.7.2.2-4')
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
      writeln(' FAIL...6.7.2.3-1, OR OPERATOR(1)')
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
               writeln(' FAIL...6.7.2.3-1, OR OPERATOR(2)')
         end
         else
            writeln(' FAIL...6.7.2.3-1, OR OPERATOR(3)')
      end
      else
         writeln(' FAIL...6.7.2.3-1, OR OPERATOR(4)')
   end;

   { AND truth table }
   a:=false;
   b:=false;
   if a and b then
      writeln(' FAIL...6.7.2.3-1, AND OPERATOR(1)')
   else
   begin
      b:=true;
      if a and b then
         writeln(' FAIL...6.7.2.3-1, AND OPERATOR(2)')
      else
      begin
         a:=true;
         b:=false;
         if a and b then
            writeln(' FAIL...6.7.2.3-1, AND OPERATOR(3)')
         else
         begin
            b:=true;
            if a and b then
               counter:=counter+1
            else
               writeln(' FAIL...6.7.2.3-1, AND OPERATOR(4)')
         end
      end
   end;

   { NOTE: NOT is sometimes badly implemented by wordwise
           complementation, and for this reason the following
           two tests may fail. }

   if (not false)=true then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, NOT OPERATOR(1)');

   if (not true)=false then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, NOT OPERATOR(2)');

   c:=false;
   a:=true;
   b:=false;
   if (a or b)=(b or a) then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, BOOLEAN COMMUTATION');

   if ((a or b)or c)=(a or(b or c)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, BOOLEAN ASSOCIATIVITY');

   if (a and(b or c))=((a and b)or(a and c)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, BOOLEAN DISTRIBUTION');

   if not(a or b)=((not a) and(not b)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, DEMORGAN1');

   if not(a and b)=((not a) or (not b)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, DEMORGAN2');

   if not(not a)= a then
      counter:=counter+1
   else
      writeln(' FAIL...6.7.2.3-1, BOOLEAN INVERSION');

   if counter=10 then
      writeln(' PASS...6.7.2.3-1')
end;


{TEST 6.7.2.4-1, CLASS=CONFORMANCE}

{: This test checks the operation of set operators. }
{V3.0: Write for PASS shortened. Was previously 6.7.2.4-2. }

procedure t6p7p2p4d1;
var
   a,b,c,d:set of 0..10;
   counter:integer;
begin
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
      writeln(' PASS...6.7.2.4-1')
   else
      writeln(' FAIL...6.7.2.4-1')
end;


{TEST 6.7.2.4-2, CLASS=CONFORMANCE}

{: This program checks the operations of set operators on sets
   of constants and variables. }
{V3.0: Write for PASS shortened. Was previously 6.7.2.4-3. }

procedure t6p7p2p4d2;
var
   a,b,c:set of 0..10;
   counter:integer;
begin
   counter:=0;
   a:=[0,2,4,6,8,10];
   b:=[1,3,5,7,9];
   c:=[0,1,2,3,4,5,6,7,8,9,10];
   if(a+[]=a) then
      counter:=counter+1;
   if(a+b=c) then
      counter:=counter+1;
   if(a+[1,3,5,7,9]=c) then
      counter:=counter+1;
   if(a-[]=a) then
      counter:=counter+1;
   if(c-a=b) then
      counter:=counter+1;
   if(c-[0,2,4,6,8,10]=b) then
      counter:=counter+1;
   if(a*a=a) then
      counter:=counter+1;
   if(a*[]=[]) then
      counter:=counter+1;
   if(a*b=[]) then
      counter:=counter+1;
   if(a*c=a) then
      counter:=counter+1;
   if(counter=10) then
      writeln(' PASS...6.7.2.4-2')
   else
      writeln(' FAIL...6.7.2.4-2,')
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
      writeln(' PASS...6.7.2.4-5')
   else
      writeln(' FAIL...6.7.2.4-5')
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
   error    : boolean;

   procedure DoIt;

      procedure Union(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do aa[i]:=ab[i] or ac[i]
      end;

      procedure Intersection(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do aa[i]:=ab[i] and ac[i]
      end;

      procedure Difference(var aa:IvecType; var ab,ac:IvecType);
      var i:IT;
      begin
         for i:=0 to Big do aa[i]:=ab[i] and not ac[i]
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
      writeln(' PASS...6.7.2.4-6')
   else
      writeln(' FAIL...6.7.2.4-6')
end;


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
         writeln(' PASS...6.7.2.5-1')
      else
         writeln(' FAIL...6.7.2.5-1, STRING COMPARISON(1)')
   end
   else
      writeln(' FAIL...6.7.2.5-1, STRING COMPARISON(2)')
end;


{TEST 6.7.2.5-2, CLASS=CONFORMANCE}

{: This test checks the use of relational operators on sets. }
{V3.0: Write for PASS shortened. }

procedure t6p7p2p5d2;
var
   a,b:set of 0..10;
  c,counter:integer;
begin
   counter:=0;
   a:=[0,1,2,3,4,5];
   b:=[2,3,4];
   c:=3;
   if(a=[0,1,2,3,4,5]) then
     counter:=counter+1;
   if(a<>b) then
      counter:=counter+1;
   if(b<>[1,2,3,4,5]) then
      counter:=counter+1;
   if(b<=a) then
      counter:=counter+1;
   if(a>=b) then
      counter:=counter+1;
   if([0,1]<=a) then
      counter:=counter+1;
   if([1,2,3,4,5,6,10]>=b) then
      counter:=counter+1;
   if (1 in a) then
      counter:=counter+1;
   if(c in b) then
      counter:=counter+1;
   if(counter=9) then
      writeln(' PASS...6.7.2.5-2')
   else
      writeln(' FAIL...6.7.2.5-2')
end;


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
      writeln(' PASS...6.7.2.5-3')
   else
      writeln(' FAIL...6.7.2.5-3')
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
   writeln(' PASS...6.8.2.1-1');   {10}
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
            writeln(' FAIL...6.8.3.4-1, IF STATEMENT(1)')
         else
            begin
            if not b then
                writeln(' FAIL...6.8.3.4-1, IF STATEMENT(2)')
            else
               writeln(' PASS...6.8.3.4-1')
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
   writeln(' PASS...6.8.3.5-1')
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
      1000: writeln(' PASS...6.8.3.5-2')
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
      writeln(' PASS...6.8.3.7-1')
   else
      writeln(' FAIL...6.8.3.7-1')
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
      writeln(' PASS...6.8.3.7-2')
   else
      writeln(' FAIL...6.8.3.7-2')
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
   writeln(' PASS...6.8.3.7-3')
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
      writeln(' PASS...6.8.3.8-1')
   else
      writeln(' FAIL...6.8.3.8-1')
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
      writeln(' PASS...6.8.3.8-2')
   else
      writeln(' FAIL...6.8.3.8-2')
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
   if j=10 then
      writeln(' PASS...6.8.3.9-1')
   else
      writeln(' FAIL...6.8.3.9-1')
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
      writeln(' PASS...6.8.3.9-2')
   else
      writeln(' FAIL...6.8.3.9-2')
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
      writeln(' PASS...6.8.3.9-3')
   else
      writeln(' FAIL...6.8.3.9-3')
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
      writeln(' PASS...6.8.3.9-4')
   else
      writeln(' FAIL...6.8.3.9-4')
end;


{TEST 6.8.3.10-1, CLASS=CONFORMANCE}

{: This program checks the implementation of the with-statement. }
{V3.0: Writes revised. }

procedure t6p8p3p10d1;
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
      writeln(' PASS...6.8.3.10-1')
   else
      writeln(' FAIL...6.8.3.10-1')
end;



{TEST 6.8.3.10-2, CLASS=CONFORMANCE}

{: This test checks that a field-identifier is correctly
   identified when a with-statement is invoked. }
{V3.0: Writes revised. }

procedure t6p8p3p10d2;
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
      writeln(' PASS...6.8.3.10-2')
   else
      writeln(' FAIL...6.8.3.10-2')
end;


{TEST 6.8.3.10-3, CLASS=CONFORMANCE}

{: This test checks that the record-variable-list
   of a with-statement is evaluated in the correct order. }
{V3.0: Write for PASS shortened. }

procedure t6p8p3p10d3;
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
      writeln(' PASS...6.8.3.10-3')
   else
      writeln(' FAIL...6.8.3.10-3')
end;


{TEST 6.8.3.10-4, CLASS=CONFORMANCE}

{: This test checks that the selection of a variable in the
   record-variable-list is performed before the component
   statement is executed. }
{V3.0: Writes revised. }

procedure t6p8p3p10d4;
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
      writeln(' PASS...6.8.3.10-4')
   else
      writeln(' FAIL...6.8.3.10-4')
end;


{TEST 6.8.3.10-5, CLASS=CONFORMANCE}

{: This test checks that the selection of a variable in the
   record-variable-list is performed before the component
   statement is executed. }
{V3.0: Writes revised. }

procedure t6p8p3p10d5;
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
         writeln(' PASS...6.8.3.10-5')
      else
         writeln(' FAIL...6.8.3.10-5')
end;


{TEST 6.8.3.10-6, CLASS=CONFORMANCE}

{: This test checks that the order of evaluation of the
   record-variable-list in a with-statement is correctly
   implemented. }
{V3.0: Writes revised. }

procedure t6p8p3p10d6;
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
      writeln(' PASS...6.8.3.10-6')
   else
      writeln(' FAIL...6.8.3.10-6')
end;


{TEST 6.8.3.10-8, CLASS=CONFORMANCE}

{: This test contains a record-variable-list in which all the
   identifiers are identical. }
{  The record-variable-list of a with-statement can contain twice or
   more times the same identifier - to denote a record , its homonymous
   field which is itself a record, etc. }
{V3.1: New test from BNI. }

procedure t6p8p3p10d8;
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
      then writeln(' PASS...6.8.3.10-8')
      else writeln(' FAIL...6.8.3.10-8')
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
   writeln(' PASS...6.10-3')
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
   ptr4^ := [1,2];
   ptr5^[1] := 1;
   ptr6^.a := 1;
   ptr6^.b := true;
   ptr7^ := 'C';
   ptr8^ := nil;
   ptr9^ := [1];
   writeln(' PASS...6.4.4-1')
end;


begin
   t6p1p1d1;
   t6p1p1d2;
   t6p1p2d1;
   t6p1p2d3;
   t6p1p3d1;
   t6p1p3d2;
   t6p1p6d1;
   t6p1p6d3;
   t6p1p7d1;
   t6p1p7d2;
   t6p1p7d3;
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
   t6p4p3p5d1;
   t6p4p4d1;
   t6p4p5d1;
   t6p4p5d2;
   t6p4p5d3;
   t6p4p5d4;
   t6p4p5d5;
   t6p4p5d6;
   t6p4p6d1;
   t6p4p6d2;
   t6p4p6d3;
   t6p5p1d1;
   t6p5p3p2d1;
   t6p6p1d1;
   t6p6p1d2;
   t6p6p2d1;
   t6p6p2d2;
   t6p6p2d3;
   t6p6p2d4;
   t6p6p3p1d1;
   t6p6p3p1d2;
   t6p6p3p3d1;
   t6p6p3p3d2;
   t6p6p3p3d3;
   t6p6p4p1d1;
   t6p6p4p1d2;
   t6p6p5p3d2;
   t6p6p5p3d20;
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
   t6p7p2p4d2;
   t6p7p2p4d5;
   t6p7p2p4d6;
   t6p7p2p5d1;
   t6p7p2p5d2;
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
   t6p8p3p10d1;
   t6p8p3p10d2;
   t6p8p3p10d3;
   t6p8p3p10d4;
   t6p8p3p10d5;
   t6p8p3p10d6;
   t6p8p3p10d8;
   t6p10d3;
end.


FAILED!!!!!!!!!1
procedure t6p4p6d1;
var
   I: Integer;
   urray2   : array[1..4] of integer;
begin
   urray2[I]:=400; INDEX
end;


