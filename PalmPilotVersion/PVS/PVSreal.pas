program PVSreal;
{$define Palm}
{$define dolater}
{$define SkipAlways}
{$define s}

Uses Crt, HSUtils, SystemMgr;

{$D+,R+}

Procedure xxWriteln(Const S: String);
var N: Integer;
begin
  //HSUtils.Writeln(S);
  //N:=SysTaskDelay(SysTicksPerSecond div 3);
end;
Procedure Delay(Secs: Integer);
begin
  Secs:=SysTaskDelay(Secs*SysTicksPerSecond);
end;

Procedure FAIL(Const S: String);
begin
  writeln('F-'+S);
  Delay(2);
end;
Procedure FAILPALM(Const S: String); begin end;
Procedure QUALITY(Const S: String);
begin
  //Writeln('Q-'+S);
end;

Procedure WrLn(Const S: String);
begin
  //Writeln('Q-'+S);
end;

{$ifdef pc} { For use on TP5 on IBM }
{$N+}
{$endif}

{$ifdef s}
  type real=single;
{$else}
{$ifdef e}
  type real=extended;
{$else}
  type real=double;
{$endif}
{$endif}

const Iter=500; { Iteration count, 2000=normal }

{TEST 6.6.6.2-11, CLASS=IMPLEMENTATIONDEFINED, NUMBER= 2}

{: This program determines some of the characteristics of the
   floating-point arithmetic system of the host machine. }
{  If the program fails or the printed results do not agree
   with the known data for the machine then the program
   should be checked because some of the assumptions made
   about floating-point arithmetic may be invalid for that
   machine. In particular, underflow must not be an error. }
{V3.1: Updated to take into account IEEE standard. }

procedure machar(var ibeta , it , irnd , ngrd , machep , negep , iexp,
  minexp , maxexp : integer; var eps , epsneg , xmin , xmax : real ); forward;

procedure t6p6p6p2d11;

{  If the results from this test are not in conformity with
   the known data for the implementation,  then the quality tests
   using MACHAR will not obtain the correct results.
   The tests using MACHAR are 6.1.5-11, 6.1.5-12,
   6.6.6.2-6 to 6.6.6.2-10, 6.6.6.2-11 (this test),
   6.7.2.2-14, 6.7.2.2-15, 6.9.1-6, 6.9.1-8 and 6.9.3.5.2-2.
   The exponent range may not agree with the machine manual due to
   the definition of minexp and maxexp, see below.
   The reasons why MACHAR does not achieve the correct results
   should be communicated to the suppliers of the suite. }

var

   eps , epsneg , xmax , xmin : real;

   ibeta , iexp , irnd , it , machep , maxexp , minexp , negep , ngrd :
   integer;



begin
   machar ( ibeta , it , irnd , ngrd , machep , negep , iexp , minexp ,
      maxexp , eps , epsneg , xmin , xmax );
   writeln(' OUTPUT FROM TEST...6.6.6.2-11');
   {$ifdef Palm}
   writeln('   BETA ='+i2s(ibeta));
   writeln('      T ='+i2s(it));
   writeln('    RND ='+i2s(irnd));
   writeln('   NGRD ='+i2s(ngrd));
   writeln(' MACHEP ='+i2s(machep));
   writeln('  NEGEP ='+i2s(negep));
   writeln('   IEXP ='+i2s(iexp));
   writeln(' MINEXP ='+i2s(minexp));
   writeln(' MAXEXP ='+i2s(maxexp));
   writeln('    EPS ='+r2s(eps));
   writeln(' EPSNEG ='+r2s(epsneg));
   writeln('   XMIN ='+r2s(xmin));
   writeln('   XMAX ='+r2s(xmax));
   writeln(' IMPLEMENTATION DEFINED...6.6.6.2-11');
   Delay(2);
   {$else}
   writeln('   BETA =',ibeta:5);
   writeln('      T =',it:5);
   writeln('    RND =',irnd:5);
   writeln('   NGRD =',ngrd:5);
   writeln(' MACHEP =',machep:5);
   writeln('  NEGEP =',negep:5);
   writeln('   IEXP =',iexp:5);
   writeln(' MINEXP =',minexp:5);
   writeln(' MAXEXP =',maxexp:5);
   writeln('    EPS =',eps);
   writeln(' EPSNEG =',epsneg);
   writeln('   XMIN =',xmin);
   writeln('   XMAX =',xmax);
   writeln(' IMPLEMENTATION DEFINED...6.6.6.2-11');
   {$endif}
end;


procedure machar;
var

{ For FORTRAN version, see 'Software Manual for the Elementary
  Functions' W J Cody and W Waite, Prentice-Hall 1980, pp259-264 }

{     This subroutine is intended to determine the characteristics
      of the floating-point arithmetic system that are specified
      below.  The first three are determined according to an
      algorithm due to M. Malcolm, CACM 15 (1972), pp. 949-951,
      incorporating some, but not all, of the improvements
      suggested by M. Gentleman and S. Marovich, CACM 17 (1974),
      pp. 276-277.

      Latest revision - 1 July, 1982.

      Author - W. J. Cody
               Argonne National Laboratory

      Revised for Pascal - R. A. Freak
                           University of Tasmania
                           Hobart
                           Tasmania
                     and
                           B. A. Wichmann
                           National Physical Laboratory
                           Teddington Middx.
                           TW11 OLW  UK

      This revision for Pascal uses an extra function st to
      ensure that a machine with an overlength accumulator will
      give the correct result (ie that for stored values, not
      that for the accumulator).
      The July 1982 revision ensures the correct value for maxexp
      on IEEE implementations (both single and double), and also
      uses a different value so that round to even is not reported
      as chopping.

      ibeta    -  The radix of the floating-point representation
      it       -  The number of base ibeta digits in the floating-point
                  significand
      irnd     -  0 if floating-point addition chops,
                  1 if floating-point addition rounds
                                 (or rounds to even)
      ngrd     -  The number of guard digits for multiplication. It is
                  0 if  irnd=1, or if  irnd=0  and only  it  base ibeta
                    digits participate in the post normalization shift
                    of the floating-point significand in multiplication
                  1 if  irnd=0  and more than  it  base  ibeta  digits
                    participate in the post normalization shift of the
                    floating-point significand in multiplication
      machep   -  The largest negative integer such that
                  1.0 + ibeta ** machep <> 1.0, except that
                  machep is bounded below by -(it+3)
      negep    -  The largest negative integer such that
                  1.0 - ibeta ** negep <> 1.0, except that
                  negep is bounded below by -(it+3)
      iexp     -  The number of bits (decimal places if ibeta = 10)
                  reserved for the representation of the exponent
                  (including the bias or sign) of a floating-point
                  number
      minexp   -  The largest in magnitude negative integer such that
                  ibeta ** minexp is a positive floating-point
                  number, still having it digits.
      maxexp   -  The largest positive integer exponent for a finite
                  floating-point number
      eps      -  The smallest positive floating-point number such
                  that  1.0+eps <> 1.0. In particular, if either
                  ibeta = 2 or irnd = 0, eps = ibeta ** machep
                  otherwise, eps = (ibeta ** machep)/2
      epsneg   -  A small positive floating-point number such that
                  1.0-epsneg <> 1.0. In particular, if ibeta = 2
                  or irnd = 0, epsneg = ibeta ** negep.
                  otherwise, epsneg = (ibeta**negep)/2. Because
                  negep is bounded below by -(it+3), epsneg may not
                  be the smallest number which can alter 1.0 by
                  subtraction.
      xmin     -  The smallest non-vanishing floating-point power of
                  the radix. In particular,  xmin = ibeta ** minexp
      xmax     -  The largest finite floating-point number.  In
                  particular   xmax = (1.0-epsneg) * ibeta ** maxexp
                  Note - on some machines  xmax  will be only the
                  second, or perhaps third, largest number, being
                  too small by 1 or 2 units in the last digit of
                  the significand.   }


   i , iz , j , k , mx : integer;
   a , b , beta , betain , betam1 , one , y , z , zero : real;
   underflo : boolean;

   function st( x: real) : real;
      { This function is the identity written so that an
        overlength accumulator will not stop the algorithm
        of Cody from giving the correct result. In principle,
        this function needs to be made complex enough to
        defeat an optimizing compiler. }
      var
         y: array[ 1 .. 3 ] of real;
      begin
      y[1] := x;
      y[2] := 0.0;
      y[3] := y[1] + y[2];
      y[1] := y[3];
      st := y[1] + y[2]
      end;  {st}

begin
   one := 1.0;
   zero := 0.0;

   {   determine ibeta,beta ala Malcolm   }

   a := one + one;
   while st(st( st(a + one) - a) - one) = zero do
      a := a + a;
   b := one + one;
   while st(st(a + b) - a) = zero do
      b := b + b;
   ibeta := trunc ( st(a + b) - a);
   beta := ibeta;

   {   determine it,irnd   }

   it := 0;
   b := one;
   repeat begin
      it := it + 1;
      b := b * beta;
   end until st(st( st(b + one) - b) - one) <> zero;
   irnd := 0;
   betam1 := beta - one;
   if st(st((a + beta) + betam1) - (a + beta)) <> zero then
      irnd := 1;

   {   determine negep, epsneg   }

   negep := it + 3;
   betain := one/beta;
   a := one;

   for i := 1 to negep do
      a := a * betain;

   b := a;
   while st(st(one - a) - one) = zero do
      begin
      a := a * beta;
      negep := negep - 1;
      end;
   negep := - negep;
   epsneg := a;
   if (ibeta <> 2) and (irnd <> 0) then
      begin
      a := a * st(one + a)/(one + one);
      if st(st(one - a) - one) <> zero then
         epsneg := a;
      end;

   {   determine machep, eps   }

   machep := - it - 3;
   a := b;
   while st(st(one + a) - one) = zero do
      begin
      a := a * beta;
      machep := machep + 1;
      end;
   eps := a;
   if (ibeta <> 2) and (irnd <> 0) then
      begin
      a := a * st(one + a) / (one + one);
      if st(st(one + a) - one) <> zero then
         eps := a;
      end;

   {   determine ngrd   }

   ngrd := 0;
   if (irnd = 0) and ( st( st(one + eps) * one - one) <> zero) then
      ngrd := 1;

   {  determine iexp, minexp, xmin

      loop to determine largest i and k = 2**i such that
          (1/beta) ** (2**(i))
      does not underflow
      exit from loop is signaled by an underflow   }

   i := 0;
   k := 1;
   z := betain;
   underflo := false;
   repeat begin
      y := z;
      z := y * y;

      {   check for underflow   }

      a := z * one;
      if ( st(a + a) = zero) or (abs(z) >= y) then
         underflo := true
      else
         begin
         i := i + 1;
         k := k + k;
         end;
   end until underflo;
   if ibeta <> 10 then
      begin
      iexp := i + 1;
      mx := k + k;
      end
   else
      begin

      {  for decimal machines only   }
      iexp := 2;
      iz := ibeta;
      while k >= iz do
         begin
         iz := iz * ibeta;
         iexp := iexp + 1;
         end;
      mx := iz + iz - 1;
      end;
   underflo := false;
   repeat begin

      {   loop to determine minexp, xmin
          exit from loop is signalled by an underflow    }

      xmin := y;
      y := y * betain;
      { check for underflow here }
      a := y * one;
      if ( st(a + a) = zero) or (abs(y) >= xmin) or
         (st(y*st(one+eps)) <= y) then
         underflo := true
      else
         k := k + 1;
   end until underflo;
   minexp := - k;

   {  determine maxexp, xmax   }

   if (mx <= k + k - 3) and (ibeta <> 10) then
      begin
      mx := mx + mx;
      iexp := iexp + 1;
      end;
   maxexp := mx + minexp;
   {  adjust for machines with implicit leading
      bit in binary significand and machines with
      radix point at extreme right of significand   }

   i := maxexp + minexp;
   if ibeta = 2 then
      begin
      if (iexp=8) and (it=24) and (i=4) then
         maxexp := maxexp - 2  { IEEE single length }
      else if (iexp=11) and (it=53) and (i=4) then
         maxexp := maxexp - 2  { IEEE double length }
      else if i=0 then
         maxexp := maxexp - 1;
      end;
   if i > 20 then
      maxexp := maxexp - 1;
   if a <> y then
      maxexp := maxexp - 2;
   xmax := one - epsneg;
   if st(xmax * one) <> xmax then
      xmax := one - st(beta * epsneg);  

   xmax := xmax / (beta * beta * beta * xmin);
   i := maxexp + minexp + 3;
   for j := 1 to i do
      begin
      if ibeta = 2 then
         xmax := xmax + xmax
      else
         xmax := xmax * beta;
      end;

end;   {machar}

{TEST 6.1.5-1, CLASS=CONFORMANCE}

{: This program tests the conformance of the processor to the
   syntax productions for numbers.  }
{V3.0: Check on sum of a to j added. Writes modified to conform
   to conventions. }

procedure t6p1p5d1;

const
   { all cases are legal productions }
   a = 1;
   b = 12;
   c = 0123;
   d = 123.0123;
   e = 123.0123E+2;
   f = 123.0123E-2;
   g = 123.0123E2;
   h = 123E+2;
   i = 0123E-2;
   j = 0123E2;
var
   sum : real;

begin
   sum := a + b + c + d + e + f + g + h + i + j;
   if (sum > 49470.0) or
      (sum < 49460.0) then
      FAIL('6.1.5-1')
   else
      QUALITY('6.1.5-1')
end;
{TEST 6.1.5-2, CLASS=CONFORMANCE}

{: This program simply tests if very long numbers are permitted. }
{  The value should be representable despite its length. }
{V3.0: 4-digit check added. Spaces added in writes. }

procedure t6p1p5d2;
const
   reel = 123.456789012345678901234567890123456789;
begin
   if (reel > 123.5) or
      (reel < 123.4) then
      FAIL('6.1.5-2')
   else
      QUALITY('6.1.5-2')
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
      QUALITY('6.6.6.2-1')
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
      QUALITY('6.6.6.2-2')
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
      QUALITY('6.6.6.2-3')
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
         else
            FAIL('6.6.6.3-1, TRUNC/ROUND FUNCTIONS(1)')
      else
         if (trunc(j+0.5)=round(j)) then
            begin
               truncstatus:=truncstatus+1;
               roundstatus:=roundstatus+1
            end
         else
            FAIL('6.6.6.3-1, TRUNC/ROUND FUNCTIONS(2)')
   end;

   if (truncstatus=668) and (roundstatus=668) then
      QUALITY('6.6.6.3-1')
  else
      FAIL('6.6.6.3-1')
end;

{TEST 6.6.6.2-6, CLASS=QUALITY}

{: This test checks the implementation of the sqrt function. }
{  For FORTRAN version, see 'Software Manual for the Elementary
   Functions', Prentice-Hall 1980, W.J.Cody and W.Waite pp31-34.
   Failure indicates the implementation is worse than that given
   by Cody and Waite, but exceptional argument values could
   produce a large maximum relative error without indicating a
   numerically poor routine. }
{V3.1: Machar changed and forcestore added. }

procedure t6p6p6p2d6;

var

{      data required

          none

       other subprograms in this package

          machar - An environmental inquiry program providing
                   information on the floating-point arithmetic
                   system.  Note that the call to machar can
                   be deleted provided the following six
                   parameters are assigned the values indicated:

                   ibeta    -  The radix of the floating-point
                               representation
                   it       -  The number of base ibeta digits in the
                               floating-point significand
                   eps      -  The smallest positive floating-point
                               number such that 1.0+eps <> 1.0 . In
                               particular, if either ibeta=2 or irnd=0,
                               eps = ibeta ** machep, otherwise,
                               eps = (ibeta  **  machep)/2
                   epsneg   -  A small positive floating-point number
                               such that 1.0-epsneg <> 1.0 . In
                               particular, if ibeta=2 or irnd=0,
                               epsneg = ibeta ** negeps,
                               otherwise, epsneg = (ibeta ** negeps)/2 .
                               Because negeps is bounded below
                               by -(it+3), epsneg may not be the
                               smallest number which can alter
                               1.0 by subtraction.
                   xmin     -  The smallest non-vanishing floating-point
                               power of the radix. In particular,
                               xmin = ibeta ** minexp .
                   xmax     -  The largest finite floating-point number.
                               In particular,
                               xmax = (1.0-epsneg)*ibeta ** maxexp .
                               Note - on some machines, xmax will
                               be only the second, or perhaps third,
                               largest number, being too small by
                               1 or 2 units in the last digit of
                               the significand.

        randl(x) - A function subprogram returning logarithmically
                   distributed random real numbers.  In particular,
                          a * randl(ln(b/a))
                   is logarithmically distributed over (a,b)

          random - A function subprogram returning random real
                   numbers uniformly distributed over (0,1)


       standard subprograms required

           abs, ln, exp, sqrt
                                                                      }

   i, ibeta, iexp,  irnd, it, j, k1, k2, k3, machep, maxexp,
   minexp, n, negep, ngrd : integer;
   ix: 1 .. 30268;   iy: 1 .. 30306;   iz: 1 .. 30322;
   { Seeds for the function random which must be initialised.
     They must be > 0 and less than 30269, 30307 and 30323
     respectively. They should not be equal. }
   a, ait, albeta, b, beta, c, eps, epsneg, one, r6, r7, sqbeta, w,
   x, xmax, xmin, xn, x1, y, z, zero: real;
   failed: boolean;

function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;


function random: real;

   { I D Hill and B A Wichmann, Applied Statistics,
     Vol 31, 1982, pp 188-190. }

   { The tests using random are: 6.4.3.5-5, 6.4.3.5-8, 6.6.6.2-6,
     6.6.6.2-7, 6.6.6.2-8, 6.6.6.2-9 and 6.6.6.2-10. }

   { This function uses three multiplicative congruence
     generators to provide approximately 48-bit random
     sequences from three 16-bit integer ones. The three
     sequences are:
           ix := (ix * 171) mod 30269
           iy := (iy * 172) mod 30307
     and   iz := (iz * 170) mod 30323
     Since 30269, 30307 and 30323 are primes, all sequences can be
     of maximal length (see Seminumerical Algorithms, D E Knuth,
     Addison Wesley 1969, p19). The simple steps above cannot
     be performed without overflow on a 16-bit machine. This
     is avoided by writing:
           iy = k * 176 + r
     where    0 <= k <= 172
     and      0 <= r <= 175
     Then     172 * iy = k * 176 * 172 + r * 172
                       = k * 30272 + r * 172
                       = - k * 35 + r * 172 mod 30307
     Similarly
     with     iz = k * 178 + r
              170 * iz = - k * 63 + r * 170 mod 30323.
     and with ix = k * 177 + r
              171 * ix = - k * 2 + r * 171 mod 30269
     The values are now bounded for a 16-bit machine.
     The period is about 2.78E13.
     The fractional part of the sum of the three values as a
     fraction of the prime modulus gives the real random value. }

   var
      ni, k, r: integer;
      x: real;
   begin
   { calculate k and r for ix }
   k := ix div 177;
   r := ix - k * 177;
   ni := - k - k + 171 * r;
   { -342 <= ni <= 30096, so now reduce range }
   if ni < 0 then
      ix := ni + 30269
   else
      ix := ni;
   { k and r for iy generator }
   k := iy div 176;
   r := iy - k * 176;
   ni := - 35 * k + r * 172;
   { reduce range, -6020 <= ni <= 30100 }
   if ni < 0 then
      iy := ni + 30307
   else
      iy := ni;
   { now the same for iz }
   k := iz div 178;
   r := iz - k * 178;
   ni := - 63 * k + r * 170;
   { reduce range, -10710 <= ni <= 30090 }
   if ni < 0 then
      iz := ni + 30323
   else
      iz := ni;
   x := ix/30269.0 + iy/30307.0 + iz/30323.0;
   random := x - trunc(x)
   end  {random} ;


function randl (x: real ): real;

{     returns pseudo random numbers logarithmically distributed
      over (1,exp(x)).  thus a*randl(ln(b/a)) is logarithmically
      distributed in (a,b).

      other subroutines required

         exp(x) - the exponential routine

         random - a function program returning random real
                  numbers uniformly distributed over (0,1).
                                                                  }


begin
   randl := exp ( x * random )
end;


procedure printtestrun (n: integer; lb, ub: real;
                        big, equal, small: integer;
                        rdigits, radix: integer;
                        maxerror, xmaxerror, rmserror: real);
var
   loss: real;  { Limit for loss in accuracy }
begin
   { The limit for loss in accuracy corresponds to 4/3(BASE
     digit plus 2 bits) for the Maximum Relative Error and to
     half this for the Root Mean Square error. Such limits are
     only exceeded by routines which are believed to contain
     numerically poor algorithms except for isolated argument
     values.
     Hence MRE <= 4, RMS <= 2 for a binary machine
       and MRE <= 2, RMS <= 1 for a hexadecimal machine.
     This is an NPL addition to the Cody and Waite tests. }
   loss := 4.0 * (1.0 + ln(4.0)/albeta)/3.0;
   writeln('      RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL')
      ;
   writeln('   (',lb,',',ub,')');
   writeln;
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES, AND');
   writeln('   EQUAL', equal:5, ' TIMES' );
   writeln('   TOO SMALL',small:5,' TIMES');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> zero then
      w := ln(abs(maxerror))/albeta
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> zero then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
end;   { printtestrun }

begin  {Main program}

   machar ( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax );
   failed := false;
   beta := ibeta;
   sqbeta := sqrt(beta);
   albeta := ln(beta);
   ait := it;
   one := 1.0;
   zero := 0.0;
   a := one / sqbeta;
   b := one;
   n := Iter;
   xn := n;
   iz := 1;
   iy := 10001;
   ix := 4987;

   {   random argument accuracy tests   }

   for j := 1 to 2 do
      begin
      c := ln(b / a);
      k1 := 0;
      k3 := 0;
      x1 := zero;
      r6 := zero;
      r7 := zero;

      for i := 1 to n do
         begin
         x := a * randl(c);
         y := forcestore( x * x);
         z := sqrt(y);
         w := (z - x) / x;
         if w > zero then
            k1 := k1 + 1;
         if w < zero then
            k3 := k3 + 1;
         w := abs(w);
         if w > r6 then
            begin
            r6 := w;
            x1 := x
            end;
         r7 := r7 + w * w
         end;

      k2 := n - k1 - k3;
      r7 := sqrt(r7 / xn);
      writeln(' TEST OF SQRT(X*X) - X');
      writeln;
      printtestrun(n, a, b, k1, k2, k3, it, ibeta, r6, x1, r7);
      a := one;
      b := sqbeta
      end;

  {   special tests   }

   writeln(' TEST OF SPECIAL ARGUMENTS');
   writeln('   VALUE    X=', ' ':15, 'SQRT(X)=' );
   writeln('   XMIN   ', xmin{!!!, sqrt(xmin)});
   writeln('  1-EPSNEG', one-epsneg, sqrt(one-epsneg));
   writeln('   1.0    ', one, sqrt(one));
   writeln('  1+EPS   ', one + eps, sqrt(one + eps));
   writeln('   XMAX   ', xmax, sqrt(xmax));
   writeln('   0.0    ', zero, sqrt(zero));
   writeln;

   {   No tests for error conditions are made here.
      Test 6.6.6.2-5 calls sqrt with a negative argument.  }

   if failed then
      FAIL('6.6.6.2-6')
   else
      writeln(' QUALITY...6.6.6.2-6')
end;
{TEST 6.6.6.2-7, CLASS=QUALITY}

{: This test checks the implementation of the arctan function. }
{  For FORTRAN version, see 'Software Manual for the Elementary
   Functions', Prentice-Hall 1980, W.J.Cody and W.Waite pp211-216.
   Failure indicates the implementation is worse than that given
   by Cody and Waite, but exceptional argument values could
   produce a large maximum relative error without indicating a
   numerically poor routine. }
{V3.1: Machar changed and forcestore calls added. }

procedure t6p6p6p2d7;

var

{     data required

         none

       other subprograms in this package

         machar - as for 6.6.6.2-6

       randl(x) - as for 6.6.6.2-6

         random - as for 6.6.6.2-6

      standard subprograms required

          abs, ln, arctan,  sqrt                          }

   i, ibeta, iexp, irnd, ii, it, i1, j, k1, k2, k3, machep,
   maxexp, minexp, n, negep, ngrd: integer;
   ix: 1 .. 30268;   iy: 1 .. 30306;   iz: 1 .. 30322;
   a, ait, albeta, b, beta, betap, del, em, eps, epsneg, expon,
   half, ob32, one, ran, r6, r7, sum, two, w, x, xl, xmax, xmin,
   xn, xsq, x1, y, z, zero, zz: real;
   failed: boolean;


function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;



function random: real;


   { For details, see test 6.6.6.2-6   }

   var
      ni, k, r: integer;
      x: real;
   begin
   k := ix div 177;
   r := ix - k * 177;
   ni := - k - k + 171 * r;
   if ni < 0 then
      ix := ni + 30269
   else
      ix := ni;
   k := iy div 176;
   r := iy - k * 176;
   ni := - 35 * k + r * 172;
   if ni < 0 then
      iy := ni + 30307
   else
      iy := ni;
   k := iz div 178;
   r := iz - k * 178;
   ni := - 63 * k + r * 170;
   if ni < 0 then
      iz := ni + 30323
   else
      iz := ni;
   x := ix/30269.0 + iy/30307.0 + iz/30323.0;
   random := x - trunc(x)
   end  {random} ;


function randl (x: real ): real;

{     For details, see test 6.6.6.2-6 }


begin
   randl := exp ( x * random )
end;


procedure printtestrun (n: integer; lb, ub: real;
                        big, equal, small: integer;
                        rdigits, radix: integer;
                        maxerror, xmaxerror, rmserror: real);
var
   loss: real;  { Limit for loss in accuracy, see test 6.6.6.2-6 }
begin
   loss := 4.0 * (1.0 + ln(4.0)/albeta) / 3.0;
   writeln('      RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL')
      ;
   writeln('   (',lb,',',ub,')');
   writeln;
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES, AND');
   writeln('   EQUAL', equal:5, ' TIMES' );
   writeln('   TOO SMALL',small:5,' TIMES');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> zero then
      w := ln(abs(maxerror))/albeta
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> zero then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
end;   { printtestrun }

begin  {Main program}
   iz := 1;
   iy := 10001;
   ix := 4987;
   machar(ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax );
   failed := false;
   beta := ibeta;
   albeta := ln(beta);
   ait := it;
   one := 1.0;
   half := 0.5;
   two := 2.0;
   zero := 0.0;
   a := - 0.0625;
   b := - a;
   ob32 := b * half;
   n := Iter;
   xn := n;
   i1 := 0;

  {    random argument accuracy tests   }

   for j := 1 to 4 do
      begin
      k1 := 0;
      k3 := 0;
      x1 := zero;
      r6 := zero;
      r7 := zero;
      del := (b - a) / xn;
      xl := a;

      for i := 1 to n do
         begin
         x := del * random + xl;
         if j = 2 then
            x := ( forcestore(1.0 + x * a) - one) * 16.0;
         z := arctan(x);
         case j of
         1:
            begin
               xsq := x * x;
               em := 17.0;
               sum := xsq / em;

               for ii := 1 to 7 do
                  begin
                  em := em - two;
                  sum := (one / em - sum) * xsq
                  end;

               sum := - x * sum;
               zz := x + sum;
               sum := (x - zz) + sum;
               if irnd = 0 then
                  zz := zz + (sum + sum)
            end;
         2:
            begin
               y := x - 0.0625;
               y := y / (one + x * a);
               zz := ( arctan(y) - 8.1190004042651526021E-5 ) +
                  ob32;
               zz := zz + ob32
            end;
         3,4:
            begin
               z := z + z;
               y := x / ((half+x*half) * (forcestore(half-x)+half));
               zz := arctan(y)
            end
         end;
         w := one;
         if z <> zero then
            w := (z - zz) / z;
         if w > zero then
            k1 := k1 + 1;
         if w < zero then
            k3 := k3 + 1;
         w := abs(w);
         if w > r6 then
            begin
            r6 := w;
            x1 := x
            end;
         r7 := r7 + w * w;
         xl := xl + del
         end;

      k2 := n - k3 - k1;
      r7 := sqrt(r7 / xn);
      if j = 1 then
         begin
         writeln(' TEST OF ARCTAN(X) VS TRUNCATED TAYLOR SERIES');
         writeln
         end;
      if j = 2 then
         begin
         write(' TEST OF ARCTAN(X) VS ARCTAN(1/16) + ');
         writeln(' ARCTAN((X-1/16)/(1+X/16))');
         writeln
         end;
      if j > 2 then
         begin
         writeln(' TEST OF 2*ARCTAN(X) VS ARCTAN(2X/(1-X*X))');
         writeln
         end;
      printtestrun(n, a, b, k1, k2, k3, it, ibeta, r6, x1, r7);
      a := b;
      if j = 1 then
         b := two - sqrt( 3.0 );
      if j = 2 then
         b := sqrt(two) - one;
      if j = 3 then
         b := one
      end;

   {   special tests   }

   writeln(' THE IDENTITY ARCTAN(-X) = -ARCTAN(X) WILL BE TESTED');
   writeln;
   writeln('        X         F(X) + F(-X)');
   writeln;
   a := 5.0;

   for i := 1 to 5 do
      begin
      x := random * a;
      z := arctan(x) + arctan( - x);
      writeln(' ',x, z)
      end;
   writeln;

   writeln(' THE IDENTITY ARCTAN(X) = X, X SMALL, WILL BE TESTED');
   writeln;
   writeln('        X           X - F(X)');
   writeln;
   betap := exp(it * ln(beta) );
   x := random / betap;

   for i := 1 to 5 do
      begin
      z := x - arctan(x);
      writeln(' ',x, z);
      x := x / beta
      end;
   writeln;
   writeln;

   { Tests of ATAN against ATAN2 cannot be done in (Standard) Pascal }

   writeln(' TEST OF UNDERFLOW FOR A VERY SMALL ARGUMENT');
   writeln;
   expon := minexp * 0.75;
   x := exp(expon * ln(beta) );
   y := arctan(x);
   writeln('      ARCTAN(', x, ') = ', y);
   writeln;
   writeln(' TEST OF OVERFLOW FOR A VERY LARGE ARGUMENT');
   writeln;
   expon := maxexp * 0.75;
   x := exp(expon * ln(beta) );
   writeln;
   z := arctan(x);
   writeln('      ARCTAN(', x, ') = ', z);
   writeln;

   { Error returns of ATAN2 not applicable to Pascal. }

   if failed then
      FAIL('6.6.6.2-7')
   else
      writeln(' QUALITY...6.6.6.2-7')
end;
{TEST 6.6.6.2-8, CLASS=QUALITY}

{: This test checks the implementation of the exp function. }
{  For FORTRAN version, see 'Software Manual for the Elementary
   Functions', Prentice-Hall 1980, W.J.Cody and W.Waite pp79-83.
   Failure indicates the implementation is worse than that given
   by Cody and Waite, but exceptional argument values could
   produce a large maximum relative error without indicating a
   numerically poor routine. }
{V3.1: Machar changed and forcestore calls added. }

procedure t6p6p6p2d8;

var


{     data required

         none

      other subprograms in this package

         machar -  as for 6.6.6.2-6
         random -  as for 6.6.6.2-6


      standard subprograms required

         abs, ln, exp, sqrt
                                                                      }

   i, ibeta, iexp, irnd, it, i1, j, k1, k2, k3, machep,
   maxexp, minexp, n, negep, ngrd: integer;
   ix: 1 .. 30268;   iy: 1 .. 30306;   iz: 1 .. 30322;
   a, ait, albeta, b, beta, d, del,
   eps, epsneg, one, ran, r6, r7, two, ten,
   v, w, x, xl, xmax, xmin, xn, x1, y, z, zero, zz: real;
   failed: boolean;

function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;



function random: real;


   { For details, see test 6.6.6.2-6   }

   var
      ni, k, r: integer;
      x: real;
   begin
   k := ix div 177;
   r := ix - k * 177;
   ni := - k - k + 171 * r;
   if ni < 0 then
      ix := ni + 30269
   else
      ix := ni;
   k := iy div 176;
   r := iy - k * 176;
   ni := - 35 * k + r * 172;
   if ni < 0 then
      iy := ni + 30307
   else
      iy := ni;
   k := iz div 178;
   r := iz - k * 178;
   ni := - 63 * k + r * 170;
   if ni < 0 then
      iz := ni + 30323
   else
      iz := ni;
   x := ix/30269.0 + iy/30307.0 + iz/30323.0;
   random := x - trunc(x)
   end  {random} ;


procedure printtestrun (n: integer; lb, ub: real;
                        big, equal, small: integer;
                        rdigits, radix: integer;
                        maxerror, xmaxerror, rmserror: real);
var
   loss: real;  { Limit for loss in accuracy, see test 6.6.6.2-6 }
begin
   loss := 4.0 * (1.0 + ln(4.0)/albeta) / 3.0;
   writeln('      RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL')
      ;
   writeln('   (',lb,',',ub,')');
   writeln;
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES, AND');
   writeln('   EQUAL', equal:5, ' TIMES' );
   writeln('   TOO SMALL',small:5,' TIMES');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> zero then
      w := ln(abs(maxerror))/albeta
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> zero then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
end;   { printtestrun }

begin  {Main program}
   iz := 1;
   iy := 10001;
   ix := 4987;
   machar ( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax );
   failed := false;
   beta := ibeta;
   albeta := ln(beta);
   ait := it;
   one := 1.0;
   two := 2.0;
   ten := 10.0;
   zero := 0.0;
   v := 0.0625;
   a := two;
   b := ln(a) * 0.5;
   a := - b + v;
   d := ln(0.9 * xmax);
   n := Iter;
   xn := n;
   i1 := 0;

   {   random argument accuracy tests  }

   for j := 1 to 3 do
      begin
      k1 := 0;
      k3 := 0;
      x1 := zero;
      r6 := zero;
      r7 := zero;
      del := (b - a) / xn;
      xl := a;

      for i := 1 to n do
         begin
         x := del * random + xl;

         {   purify agruments   }

         y :=  forcestore(x - v);
         if y < zero then
            x :=  forcestore(y + v);
         z := exp(x);
         zz := exp(y);
         if j = 1 then
            z := z - z * 6.058693718652421388E-2
         else
            begin
            if ibeta = 10 then
               z := z * 6.0E-2 + z * 5.466789530794296106E-5
            else
               z := z * 0.0625 - z * 2.4453321046920570389E-3
            end;
         w := one;
         if zz <> zero then
            w := (z - zz) / zz;
         if w < zero then
            k1 := k1 + 1;
         if w > zero then
            k3 := k3 + 1;
         w := abs(w);
         if w > r6 then
            begin
            r6 := w;
            x1 := x
            end;
         r7 := r7 + w * w;
         xl := xl + del
         end;

      k2 := n - k3 - k1;
      r7 := sqrt(r7 / xn);
      writeln(' TEST OF EXP(X-', v:7:4, ') VS EXP(X)/EXP(', v:7:4, ')');
      writeln;
      printtestrun(n, a, b, k1, k2, k3, it, ibeta, r6, x1, r7);
      if j = 2 then
         begin
         a := - two * a;
         b := ten * a;
         if b < d then
            b := d
         end
      else
         begin
         v := 45.0 / 16.0;
         a := - ten * b;
         b := 4.0 * xmin * exp(it * ln(beta) );
         b := xmax;
         b := ln(b)
         end
      end;

   {   special tests   }

   writeln(' THE IDENTITY EXP(X) * EXP(-X) - 1.0 WILL BE TESTED.');
   writeln;
   writeln('        X        F(X)*F(-X) - 1');
   writeln;

   for i := 1 to 5 do
      begin
      x := random * beta;
      y := - x;
      z := exp(x) * exp(y) - one;
      writeln(' ',x, z)
      end;
   writeln;
   writeln(' TEST OF SPECIAL ARGUMENTS');
   writeln;
   x := zero;
   y := exp(x) - one;
   writeln(' EXP(0.0) - 1.0 = ', y);
   writeln;
   x := trunc( ln(xmin) );
   y := exp(x);
   writeln(' EXP(', x, ') = ', y);
   writeln;
   x := trunc( ln(xmax) - 0.5 );
   y := exp(x);
   writeln(' EXP(', x, ') = ', y);
   writeln;
   x := x / two;
   v := x / two;
   y := exp(x);
   z := exp(v);
   z := z * z;
   writeln(' IF EXP(', x, ') = ', y, ' IS NOT ABOUT');
   write(' EXP(', v, ')**2 = ', z, ' THERE IS AN ARGUMENT');
   writeln(' REDUCTION ERROR');
   writeln;

{ Test of error returns deleted since action not clear from Standard.
  Error test also deleted. }

   if failed then
      FAIL('6.6.6.2-8')
   else
      writeln(' QUALITY...6.6.6.2-8')
end;
{TEST 6.6.6.2-9, CLASS=QUALITY}

{: This test checks the implementation of the sin and cos
   functions. }
{  For FORTRAN version, see 'Software Manual for the Elementary
   Functions', Prentice-Hall 1980, W.J.Cody and W.Waite pp144-149.
   Failure indicates the implementation is worse than that given
   by Cody and Waite, but exceptional argument values could
   produce a large maximum relative error without indicating a
   numerically poor routine. }
{V3.1: Machar changed and forcestore calls added. }

procedure t6p6p6p2d9;

var


{     data required

         none

      other subprograms in this package

         machar -  as for 6.6.6.2-6
         random -  as for 6.6.6.2-6


      standard subprograms required

         abs, ln, exp, cos, sin, sqrt
                                                                      }

   i, ibeta, iexp, irnd, it, i1, j, k1, k2, k3, machep,
   maxexp, minexp, n, negep, ngrd: integer;
   ix: 1 .. 30268;   iy: 1 .. 30306;   iz: 1 .. 30322;
   a, ait, albeta, b, beta, betap,
   c, del, eps, epsneg, expon, one, ran,
   r6, r7, three, w, x, xl, xmax, xmin, xn, x1, y, z, zero, zz: real;
   failed: boolean;


function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;



function random: real;


   { For details, see test 6.6.6.2-6   }

   var
      ni, k, r: integer;
      x: real;
   begin
   k := ix div 177;
   r := ix - k * 177;
   ni := - k - k + 171 * r;
   if ni < 0 then
      ix := ni + 30269
   else
      ix := ni;
   k := iy div 176;
   r := iy - k * 176;
   ni := - 35 * k + r * 172;
   if ni < 0 then
      iy := ni + 30307
   else
      iy := ni;
   k := iz div 178;
   r := iz - k * 178;
   ni := - 63 * k + r * 170;
   if ni < 0 then
      iz := ni + 30323
   else
      iz := ni;
   x := ix/30269.0 + iy/30307.0 + iz/30323.0;
   random := x - trunc(x)
   end  {random} ;


procedure printtestrun (n: integer; lb, ub: real;
                        big, equal, small: integer;
                        rdigits, radix: integer;
                        maxerror, xmaxerror, rmserror: real);
var
   loss: real;  { Limit for loss in accuracy, see test 6.6.6.2-6 }
begin
   loss := 4.0 * (1.0 + ln(4.0)/albeta) / 3.0;
   writeln('      RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL')
      ;
   writeln('   (',lb,',',ub,')');
   writeln;
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES, AND');
   writeln('   EQUAL', equal:5, ' TIMES' );
   writeln('   TOO SMALL',small:5,' TIMES');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> zero then
      w := ln(abs(maxerror))/albeta
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> zero then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
   end;  { printtestrun }

begin  {Main program}
   iz := 1;
   iy := 10001;
   ix := 4987;
   machar ( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax );
   failed := false;
   beta := ibeta;
   albeta := ln(beta);
   ait := it;
   one := 1.0;
   zero := 0.0;
   three := 3.0;
   a := zero;
   b := 1.570796327;
   c := b;
   n := Iter;
   xn := n;
   i1 := 0;

   {   random argument accuracy tests  }

   for j := 1 to 3 do
      begin
      k1 := 0;
      k3 := 0;
      x1 := zero;
      r6 := zero;
      r7 := zero;
      del := (b - a) / xn;
      xl := a;

      for i := 1 to n do
         begin
         x := del * random + xl;
         y := x / three;
         y := forcestore(x + y) - x;
         x := three * y;
         if j = 3 then
            begin
            z := cos(x);
            zz := cos(y);
            w := one;
            if z <> zero then
               w := (z + zz * (three - 4.0 * zz * zz) ) / z
            end
         else
            begin
            z := sin(x);
            zz := sin(y);
            w := one;
            if z <> zero then
               w := (z - zz * (three - 4.0 * zz * zz) ) / z
            end;
         if w > zero then
            k1 := k1 + 1;
         if w < zero then
            k3 := k3 + 1;
         w := abs(w);
         if w > r6 then
            begin
            r6 := w;
            x1 := x
            end;
         r7 := r7 + w * w;
         xl := xl + del
         end;

      k2 := n - k1 - k3;
      r7 := sqrt(r7 / xn);
      if j = 3 then
         begin
         writeln(' TEST OF COS(X) VS 4*COS(X/3)**3-3*COS(X/3)');
         writeln
         end
      else
         begin
         writeln(' TEST OF SIN(X) VS 3*SIN(X/3)-4*SIN(X/3)**3');
         writeln
         end;
      printtestrun(n, a, b, k1, k2, k3, it, ibeta, r6, x1, r7);
      a := 18.84955592;
      if j = 2 then
         a := b + c;
      b := a + c
      end;

   {   special tests   }

   c := one / exp( ( it div 2 ) * ln(beta) );
   z := ( sin(a + c) - sin(a - c) ) / (c + c);
   writeln(' IF ', z,' IS NOT ALMOST 1.0 THEN SIN HAS THE WRONG PERIOD');
   writeln;

   writeln(' THE IDENTITY SIN(-X) = -SIN(X) WILL BE TESTED.');
   writeln;
   writeln('        X         F(X) + F(-X)');
   writeln;

   for i := 1 to 5 do
      begin
      x := random * a;
      z := sin(x) + sin( - x);
      writeln(' ',x,z)
      end;

   writeln;
   writeln(' THE IDENTITY SIN(X) = X, X SMALL, WILL BE TESTED.');
   writeln;
   writeln('        X           X - F(X)');
   writeln;
   betap := exp( it * ln(beta) );
   x := random / betap;

   for i := 1 to 5 do
      begin
      z := x - sin(x);
      writeln(' ',x, z);
      x := x / beta
      end;
   writeln;

   writeln(' THE IDENTITY COS(-X) = COS(X) WILL BE TESTED.');
   writeln;
   writeln('        X         F(X) - F(-X)');
   writeln;

   for i := 1 to 5 do
      begin
      x := random * a;
      z := cos(x) - cos( - x);
      writeln(' ',x, z)
      end;
   writeln;

   writeln(' TEST OF UNDERFLOW FOR VERY SMALL ARGUMENTS');
   writeln;
   expon := minexp * 0.75;
   x := exp( expon * ln(beta) );
   y := sin(x);
   writeln('     SIN(', x, ') = ', y);
   writeln;
   writeln(' THE FOLLOWING THREE LINES ILLUSTRATE THE LOSS IN');
   writeln(' SIGNIFICANCE FOR LARGE ARGUMENTS. THE ARGUMENTS');
   writeln(' USED ARE CONSECUTIVE.');
   writeln;
   z := sqrt(betap);
   x := z * (one - epsneg );
   y := sin(x);
   writeln('     SIN(', x, ') = ', y);
   writeln;
   y := sin(z);
   writeln('     SIN(', z, ') = ', y);
   writeln;
   x := z * (one + eps );
   y := sin(x);
   writeln('     SIN(', x, ') = ', y);
   writeln;

{ Test of error returns deleted since action not clear from Standard}

   if failed then
      FAIL('6.6.6.2-9')
   else
      writeln(' QUALITY...6.6.6.2-9')
end;

{TEST 6.6.6.2-10, CLASS=QUALITY}

{: This test checks the implementation of the ln function. }
{  For FORTRAN version, see 'Software Manual for the Elementary
   Functions', Prentice-Hall 1980, W.J.Cody and W.Waite pp54-59.
   Failure indicates the implementation is worse than that given
   by Cody and Waite, but exceptional argument values could
   produce a large maximum relative error without indicating a
   numerically poor routine. }
{V3.1: Machar changed and forcestore calls added. }

procedure t6p6p6p2d10;

var


{     data required

         none

      other subprograms in this package

         machar -  as for 6.6.6.2-6
         random -  as for 6.6.6.2-6


      standard subprograms required

         abs, ln, sqrt
                                                                      }

   i, ibeta, iexp, irnd, it, i1, j, k1, k2, k3, machep,
      maxexp, minexp, n, negep, ngrd: integer;
   ix: 1 .. 30268;   iy: 1 .. 30306;   iz: 1 .. 30322;
   a, ait, albeta, b, beta, c, d, del, eight, eps, epsneg, half, one,
      ran, r6, r7, tenth, w, x, xl, xmax, xmin, xn, x1, y, z, zero, zz:
      real;
   failed: boolean;


function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;



function random: real;


   { For details, see test 6.6.6.2-6   }

   var
      ni, k, r: integer;
      x: real;
   begin
   k := ix div 177;
   r := ix - k * 177;
   ni := - k - k + 171 * r;
   if ni < 0 then
      ix := ni + 30269
   else
      ix := ni;
   k := iy div 176;
   r := iy - k * 176;
   ni := - 35 * k + r * 172;
   if ni < 0 then
      iy := ni + 30307
   else
      iy := ni;
   k := iz div 178;
   r := iz - k * 178;
   ni := - 63 * k + r * 170;
   if ni < 0 then
      iz := ni + 30323
   else
      iz := ni;
   x := ix/30269.0 + iy/30307.0 + iz/30323.0;
   random := x - trunc(x)
   end  {random} ;


procedure printtestrun (n: integer; lb, ub: real;
                        big, equal, small: integer;
                        rdigits, radix: integer;
                        maxerror, xmaxerror, rmserror: real);
var
   loss: real;  { Limit for loss in accuracy, see test 6.6.6.2-6 }
begin
   loss := 4.0 * (1.0 + ln(4.0)/albeta) / 3.0;
   writeln('      RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL')
      ;
   writeln('   (',lb,',',ub,')');
   writeln;
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES, AND');
   writeln('   EQUAL', equal:5, ' TIMES' );
   writeln('   TOO SMALL',small:5,' TIMES');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> zero then
      w := ln(abs(maxerror))/albeta
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> zero then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + ait < zero then
      w := zero
   else
      w := w + ait;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
end;  { printtestrun }


function sign(a1, a2 : real) : real;
begin
  if - a2 < 0 then
    sign := -abs(a1)
  else
    sign := abs(a1)
end;


begin  {Main program}
   iz := 1;
   iy := 10001;
   ix := 4987;
   machar ( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
     maxexp, eps, epsneg, xmin, xmax );
   failed := false;
   beta := ibeta;
   albeta := ln(beta);
   ait := it;
   j := it div 3;
   zero := 0.0;
   half := 1/2;
   eight := 8.0;
   tenth := 0.1;
   one := 1.0;
   c := one;

   for i := 1 to j do
      c := c / beta;

   b := one + c;
   a := one - c;
   n := Iter;
   xn := n;
   i1 := 0;

   {   random argument accuracy tests   }

   for j := 1 to 4 do
      begin
      k1 := 0;
      k3 := 0;
      x1 := zero;
      r6 := zero;
      r7 := zero;
      del := (b - a) / xn;
      xl := a;

      for i := 1 to n do
         begin
         x := del * random + xl;
         case j of
         1:
            begin
               y := forcestore(x - half) - half;
               zz := ln(x);
               z := one / 3.0;
               z := y * (z - y / 4.0);
               z := (z - half) * y * y + y
            end;
         2:
            begin
               x := forcestore(x + eight) - eight;
               y := x + x / 16.0;
               z := ln(x);
               zz := ln(y) - 7.7746816434842581E-5;
               zz := zz - 31.0 / 512.0
            end;
         3:
            begin
               x := forcestore(x + eight) - eight;
               y := x + x * tenth;
               z := ln(x) / ln(10.0);
               zz := ln(y) / ln(10.0) - 3.7706015822504075E-4;
               zz := zz - 21.0 / 512.0
            end;
         4:
            begin
               z := ln(x * x);
               zz := ln(x);
               zz := zz + zz
            end
         end;
         w := one;
         if z <> zero then
           w := (z - zz) / z;
         z := sign(w, z);
         if z > zero then
            k1 := k1 + 1;
         if z < zero then
            k3 := k3 + 1;
         w := abs(w);
         if w > r6 then
            begin
            r6 := w;
            x1 := x
            end;
         r7 := r7 + w * w;
         xl := xl + del
         end;

      k2 := n - k3 - k1;
      r7 := sqrt(r7 / xn);
      case j of
      1:
         writeln(' TEST OF LN(X) VS TAYLOR SERIES EXPANSION',
            ' OF LN(1+Y)');
      2:
         writeln(' TEST OF LN(X) VS LN(17X/16)-LN(17/16)');
      3:
         writeln(' TEST OF LN(X) VS LN(11X/10)-LN(11/10)');
      4:
         writeln(' TEST OF LN(X*X) VS 2 * LN(X)')
      end;
      writeln;
      printtestrun(n, a, b, k1, k2, k3, it, ibeta, r6, x1, r7);
      case j of
         1: begin
            a := sqrt(half);
            b := 15.0 / 16.0
            end;
         2: begin
            a := sqrt(tenth);
            b := 0.9
            end;
         3,4:
            begin
            a := 16.0;
            b := 240.0
            end
         end
      end;

   {   special tests   }

   writeln(' THE IDENTITY LN(X) = - LN(1/X) WILL BE TESTED');
   writeln;
   writeln('        X         F(X) + F(1/X)');
   writeln;

   for i := 1 to 5 do
      begin
      x := random;
      x := x + x + 15.0;
      y := one / x;
      z := ln(x) + ln(y);
      writeln(' ',x,z)
      end;

   writeln;
   writeln(' TEST OF SPECIAL ARGUMENTS');
   writeln;
   x := one;
   y := ln(x);
   writeln(' LN(1.0) = ', y);
   writeln;
   x := xmin;
   y := ln(x);
   writeln(' LN(XMIN) = LN(', x, ') = ', y);
   writeln;
   x := xmax;
   y := ln(x);
   writeln(' LN(XMAX) = LN(', x, ') = ', y);
   writeln;

   {   Test 6.6.6.2-4 checks that an error is produced
      when  ln is called with a negative argument.   }

   if failed then
      FAIL('6.6.6.2-10')
   else
      writeln(' QUALITY...6.6.6.2-10')
end;
{TEST 6.7.2.2-14, CLASS=QUALITY}

{: This test checks real division by using small integers. }
{  Division of two integer-valued real quantities where the
   the true result is integer-valued is ideally exact. This
   is tested here using large integers divided by the primes
   2, 3, 5, 7, 11 and 13. For approximate division, a failure
   is indicated if the difference is more than 2 bits in the
   last place. }
{V3.1: Machar changed. }

procedure t6p7p2p2d14;

const
   ntests = 50;
var
   ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
   maxexp: integer;  { integer parameters to machar }
   eps, epsneg, xmin, xmax: real;  { real parameters to machar }
   small, equal, big, maxr, i, j: integer;
   maxerror, xmaxerror, rmserror, rmaxr: real;
   failed, support: boolean;


function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;


procedure testequal(x: real; ix: integer);
var
   relerror, y: real;
begin
   y := ix;
   if x < y then
      small := small + 1
   else if x = y then
      equal := equal + 1
   else
      big := big + 1;
   relerror := abs( (x - y) / y );
   if relerror > maxerror then
      begin
      maxerror := relerror;
      xmaxerror := x
      end;
   rmserror := rmserror + sqr(relerror)
end;  { testequal }

procedure printresults;
var
   loss, albeta, w: real;  { Limit for loss in accuracy }
begin
   { The limit for loss in accuracy corresponds to
     2 bits for the Maximum Relative Error and to
     half this for the Root Mean Square error. Such limits are
     only exceeded by poor division hardware.  }
   albeta := ln(ibeta);
   loss := ln(4.0)/albeta;
   rmserror := sqrt(rmserror/ntests);
   writeln('  THE RESULT WAS TOO LARGE',big:5,' TIMES,');
   writeln('                 EQUAL', equal:9, ' TIMES, AND' );
   writeln('                 TOO SMALL',small:5,' TIMES.');
   writeln;
   writeln('  THERE ARE', it:4, ' BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER' );
   if maxerror <> 0.0 then
      begin
      support := false;
      w := ln(abs(maxerror))/albeta
      end
   else
      w := -999.0;
   writeln('  THE MAXIMUM RELATIVE ERROR OF',maxerror,'=',
         ibeta:4,' ** ',w:7:2);
   writeln('   OCCURRED FOR X =',xmaxerror);
   if w + it < 0.0 then
      w := 0.0
   else
      w := w + it;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > loss then
      failed := true;
   if rmserror <> 0.0 then
      w := ln(abs(rmserror))/albeta
   else
      w := -999.0;
   writeln('  ROOT-MEAN-SQUARE RELATIVE ERROR =',rmserror,
         '=',ibeta:4,' ** ',w:7:2);
   if w + it < 0.0 then
      w := 0.0
   else
      w := w + it;
   writeln('   ESTIMATED LOSS OF BASE', ibeta:4,
      ' SIGNIFICANT DIGITS IS', w:7:2);
   if w > 0.5 * loss then
      failed := true;
   writeln
end;   { printtestrun }

procedure divideby(d: integer);
var
   upper, lower, i: integer;
begin
   writeln(' TEST OF REAL DIVISION BY ', d);
   xmaxerror := 0.0;
   maxerror := 0.0;
   rmserror := 0.0;
   small := 0;
   equal := 0;
   big := 0;
   upper := maxr div d;
   lower := upper - ntests + 1;
   writeln('  IN RANGE ', lower*d, '..', upper*d);
   for i := lower to upper do
      begin
      testequal( (i*d) / d, i );
      testequal( - (i*d) / d,  - i )
      end;
   printresults
end;  { divideby }

begin
   machar( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax);
   failed := false;
   support := true;
   { Calculate maximum integer value with exact real value }
   if machep < negep then
      j := - machep
   else
      j := - negep;
   { Calculate ibeta ** j - 1 }
   rmaxr := ibeta - 1;
   for i := 2 to j do
     rmaxr := ibeta * rmaxr + (ibeta - 1);
   if rmaxr >= maxint then
      maxr := maxint
   else
      maxr := trunc(rmaxr);
   rmaxr := maxr;
   { Check trunc works with this value, if not reduce rmaxr }
   while trunc(rmaxr) <> rmaxr do
      rmaxr := trunc(rmaxr - 1.0);
   maxr := trunc(rmaxr);
   divideby(2);
   divideby(3);
   divideby(5);
   divideby(7);
   divideby(11);
   divideby(13);
   writeln(' OUTPUT FROM TEST...6.7.2.2-14');
   if support then
      writeln(' REAL DIVISION IS SUPPORTED IN SENSE OF W S BROWN')
   else
      writeln(' REAL DIVISION IS APPROXIMATE');
   if failed then
      FAIL('6.7.2.2-14')
   else
      writeln(' QUALITY...6.7.2.2-14')
end;
{TEST 6.7.2.2-15, CLASS=QUALITY}

{: This test checks real +, -, *, abs and sqr by requiring
   equality for small integer-valued operands. }
{  The test checks that the operations +, -, *, abs and sqr
   applied to real operands whose values are small integers
   give exact results. To perform these checks, the minimum
   of maxint and the exact integer range of the reals must be
   found (maxr). Then computations with integers and reals
   in the range -maxr .. maxr are checked for equality.
   The correct functioning of trunc is assumed. }
{V3.1: Machar changed. }

procedure t6p7p2p2d15;

type
   op = (add, sub, mul, absr, sqrr, neg, plus);

var
   ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
   maxexp: integer;  { integer parameters to machar }
   eps, epsneg, xmin, xmax: real; { real parameters to machar }
   i, j, errorcount, maxr: integer;
   rmaxr: real;



function forcestore(x: real): real;
   { see 'st' in 6.6.6.2-11 for details}
   var
      y: array[1..3] of real;
   begin
   y[1] := x; y[2] := 0.0; y[3] := y[1] + y[2];
   y[1] := y[3]; forcestore := y[1] + y[2]
   end;



procedure test(testop: op; op1, op2, result: integer);
   var
      x, y, z: real;
   procedure equal(u, v: real);
      begin
      if u <> v then
         begin
         errorcount := errorcount + 1;
         if errorcount < 10 then
            writeln(' ',ord(testop), x, y)
         end
   end; {equal}
   begin
   x := op1;
   y := op2;
   z := result;
   equal(result, z);
   case testop of
      add: equal(x + y, z);
      sub: equal(x - y, z);
      mul: equal(x * y, z);
      absr: equal( abs(x), z);
      sqrr: equal( sqr(x), z);
      neg: equal( - x, z);
      plus: equal( + x, z)
   end
end; {test}

begin
   machar( ibeta, it, irnd, ngrd, machep, negep, iexp, minexp,
      maxexp, eps, epsneg, xmin, xmax);
   if machep < negep then
      j := - machep
   else
      j := - negep;
   { Calculate ibeta ** j - 1 }
   rmaxr := ibeta - 1;
   for i := 2 to j do
      rmaxr := ibeta * rmaxr + (ibeta - 1);
   if rmaxr >= maxint then
      maxr := maxint
   else
      maxr := trunc(rmaxr);
   rmaxr := maxr;
   { Check trunc works with this value, if not reduce rmaxr }
   while trunc(rmaxr) <> rmaxr do
      rmaxr := trunc(rmaxr - 1.0);
   maxr := trunc(rmaxr);
   errorcount := 0;
   writeln(' TEST REALS AGAINST INTEGERS IN RANGE:');
   writeln(' ', - maxr, '..', maxr);
   i := maxr div 2;
   for j := 1 to 10 do
      begin
      test(add, i + j, - j, i);
      test(add, - i, 2 * j, -(i - 2 * j) );
      test(sub, i, j, i - j);
      test(sub, - i, j, -(i + j) );
      test(mul, 1, -(i + j), -i - j);
      test(mul, -1, -(i - j), i - j);
      test(absr, - i, 0, i);
      test(absr, - j, 0, j);
      test(sqrr, j, 0, j * j);
      test(sqrr, - j, 0, j * j);
      test(neg, i, 0, - i);
      test(neg, - i - j, 0, i + j);
      test(plus, i + j, 0, i + j);
      test(plus, - i + j, 0, - i + j)
      end;
   for j := 0 to 10 do
      begin
      test(add, maxr - j, j, maxr);
      test(sub, maxr - j, - j, maxr);
      test(neg, maxr - j, 0, j - maxr);
      test(absr, - maxr + j, 0, maxr - j)
      end;
   i := trunc( sqrt(rmaxr) );
   for j := 0 to 10 do
      begin
      test(mul, i - j, i, i * i - i * j);
      test(sqrr, i - j, 0, (i * i - 2 * i * j) + j * j)
      end;

   if errorcount > 0 then
      FAIL('6.7.2.2-15, (',errorcount,' TIMES)')
   else
      writeln(' QUALITY...6.7.2.2-15')
end;
{TEST 6.7.3-1, CLASS=QUALITY}

{: This program checks if deeply nested function calls are possible. }
{V3.0: New test. }

procedure t6p7p3d1;
var x: real;
begin
   x := sqrt(sqrt(sqrt(sqr(sqr(sqrt(16.0))))));
   if (x > 2.001) or (x < 1.999) then
      FAIL('6.7.3-1, NESTED FUNCTION CALLS (X = ',x,')')
   else
      writeln(' QUALITY...6.7.3-1')
end;

{$I-}

var f,s: string[6];
procedure wait;
begin
  if s='' then if keypressed then if upcase(readkey)='Q' then halt else readln;
  if s<>'' then if keypressed then begin
    close(output);
    halt;
  end;
end;

var r: real;
begin
   writeln('Size of real= ',sizeOf(r));
   case sizeOf(r) of
   4: f:='xs.dat';
   8: f:='xd.dat';
   10:f:='xe.dat';
   end;
   write('Press ''x'' for output to ',f,', else press enter: ');
   readln(s);
   if s<>'' then 
{$ifdef pc}
     begin assign(output,f); rewrite(output); end;
{$else}
     { Will be same as on the PC some day (for compatability)}
     rewrite(output,f);
{$endif}
   writeln('Size of real= ',sizeOf(r));
   t6p6p6p2d11; 
   t6p1p5d1; wait;
   t6p1p5d2; wait; 
   t6p6p6p2d1; wait;
   t6p6p6p2d2; wait;
   t6p6p6p2d3; wait;
   t6p6p6p3d1; wait;
   t6p6p6p2d6; wait;
   t6p6p6p2d7; wait;
   t6p6p6p2d8; wait;
   t6p6p6p2d9; wait;
   t6p6p6p2d10; wait;
   t6p7p2p2d14;
   t6p7p2p2d15;
   t6p7p3d1;
   if s<>'' then Close(output);
   Delay(10);
end.
