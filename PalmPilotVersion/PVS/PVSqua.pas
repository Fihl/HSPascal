program PVScon(Output);
{xxx$define dolater}
{$define dolater2}
{$define SkipAlways}
  //t6p1p7d15;      // why not!!!
  //t6p7p1d11;      // why not!!!

Uses Crt, HSUtils, SystemMgr;

{$D+,R+}

Procedure xxWriteln(Const S: String);
var N: Integer;
begin
  //HSUtils.Writeln(S);
  //N:=SysTaskDelay(SysTicksPerSecond div 3);
end;
Procedure FAIL(Const S: String);
var N: Integer;
begin
  writeln('F-'+S);
  N:=SysTaskDelay(5*SysTicksPerSecond);
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


{TEST 6.7.1-3, CLASS=QUALITY}

{: This program checks that deeply nested expressions are
   permitted. }
{V3.0: New test. }

procedure t6p7p1d3;
const
   c0 = 1; c1 = 1; c2 = 1; c3 = 1; c4 = 1; c5 = 1; c6 = 1; c7 = 1;
   c8 = 1; c9 = 1; c10 = 1; c11 = 1; c12 = 1; c13 = 1; c14 = 1;
var
   v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14,
   sum: integer;
begin
   sum := c0 + (c1 + (c2 + (c3 + (c4 + (c5 + (c6 + (c7 +
         (c8 + (c9 + (c10 + (c11 + (c12 + (c13 + (c14))))))))))))));
   v0 := 1; v1 := 1; v2 := 1; v3 := 1; v4 := 1; v5 := 1; v6 := 1;
   v7 := 1; v8 := 1; v9 := 1; v10 := 1; v11 := 1; v12 := 1; v13 := 1;
   v14 := 1;
   sum := sum + v0 + (v1 + (v2 + (v3 + (v4 + (v5 + (v6 + (v7 +
         (v8 + (v9 + (v10 + (v11 + (v12 + (v13 + (v14))))))))))))));
   if sum <> 30 then
      FAIL('6.7.1-3')
   else
      QUALITY('6.7.1-3')
end;
{TEST 6.7.1-4, CLASS=QUALITY}

{: This program checks that deeply nested expressions are
   permitted. }
{  Note that the '+' is a real, not integer '+' which cannot be
   determined until the final part of the expression is read. }
{V3.0: New test. }

procedure t6p7p1d4;
var
   x : real;
begin
x := 1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+(1+2.0))))))))))));
if abs(x - 15.0) <=  0.001 then
   QUALITY('6.7.1-4')
else
   FAIL('6.7.1-4')
end;
{TEST 6.7.1-5, CLASS=QUALITY}

{: This test contains a deeply nested expression requiring
   temporary working store. }
{V3.0: New test. }

procedure t6p7p1d5;
var i, j, k : integer;
begin
i := 2;
j := 3;
k := 5;
i := (((i + j) - (k + 3)) * ((k - j) + (i - 10))) +
   (((i + j) mod(2 * k)) div((k + i) + (-3 * j)));
if i = 16 then
   QUALITY('6.7.1-5')
else
   FAIL('6.7.1-5')
end;
{TEST 6.7.1-15, CLASS=QUALITY}

{: This test constructs a null set by using a member-designator
   of the form maxint..-maxint. }
{V3.1: New test. maxint used in this quality version of 6.7.1-2. }

procedure t6p7p1d15;
begin
{$ifdef SkipAlways}
   FAILPALM('6.7.1-15, set of [maxint..-maxint] not allowed');
{$else}
   if ([maxint..-maxint]=[]) then
      QUALITY('6.7.1-15')
   else
      FAIL('6.7.1-15')
{$endif}
end;

{TEST 6.7.3-1, CLASS=QUALITY}

{: This program checks if deeply nested function calls are possible. }
{V3.0: New test. }

procedure t6p7p3d1;
var x: real;
begin
   x := sqrt(sqrt(sqrt(sqr(sqr(sqrt(16.0))))));
   if (x > 2.001) or (x < 1.999) then
      FAIL('6.7.3-1, NESTED FUNCTION CALLS (X = '+r2s(x)+')')
   else
      QUALITY('6.7.3-1')
end;
{TEST 6.8.3.2-1, CLASS=QUALITY}

{: This program checks that deeply nested compound statements
   are permitted. }
{V3.0: New test. }

procedure t6p8p3p2d1;
var sum: integer;
begin
   sum := 0;
     begin
     sum := sum + 1;
       begin
       sum := sum + 1;
         begin
         sum := sum + 1;
           begin
           sum := sum + 1;
             begin
             sum := sum + 1;
               begin
               sum := sum + 1;
                 begin
                 sum := sum + 1;
                   begin
                   sum := sum + 1;
                     begin
                     sum := sum + 1;
                       begin
                       sum := sum + 1;
                         begin
                         sum := sum + 1;
                           begin
                           sum := sum + 1;
                             begin
                             sum := sum + 1;
                               begin
                               sum := sum + 1;
                                 begin
                                 sum := sum + 1;
                                   begin
                                   sum := sum + 1;
                                     begin
                                     sum := sum + 1;
                                       begin
                                       sum := sum + 1;
                                         begin
                                         sum := sum + 1;
                                           begin
                                           sum := sum + 1;
                                             begin
                                             sum := sum + 1;
                                               begin
                                               sum := sum + 1;
                                                 begin
                                                 sum := sum + 1;
                                                   begin
                                                   sum := sum + 1
                                                   end
                                                 end
                                               end
                                             end
                                           end
                                         end
                                       end
                                     end
                                   end
                                 end
                               end
                             end
                           end
                         end
                       end
                     end
                   end
                 end
               end
             end
           end
         end
       end
     end;
   if sum <> 24 then
     FAIL('6.8.3.2-1')
   else
     QUALITY('6.8.3.2-1')
end;
{TEST 6.8.3.2-2, CLASS=QUALITY}

{: This program checks that a procedure may have 300 statements. }
{V3.0: New test. }

procedure t6p8p3p2d2;
var
   a0, a1, a2, a3, a4, a5, a6, a7, a8, a9: integer;
procedure permute;
   begin
   a0:=a1; a1:=a2; a2:=a3; a3:=a4; a4:=a5; a5:=a6; a6:=a7;
   a7:=a8; a8:=a9; a9:=a0; a0:=a8; a8:=a4; a4:=a6; a6:=a5;
   a5:=a1; a1:=a2; a2:=a3; a3:=a9; a9:=a7; a7:=a0; a0:=a7;
   a7:=a3; a3:=a2; a2:=a9; a9:=a8; a8:=a4; a4:=a5; a5:=a1;
   a1:=a6; a6:=a0; a0:=a5; a5:=a7; a7:=a3; a3:=a4; a4:=a1;
   a1:=a9; a9:=a2; a2:=a6; a6:=a8; a8:=a0; a0:=a8; a8:=a2;
   a2:=a4; a4:=a1; a1:=a7; a7:=a5; a5:=a3; a3:=a9; a9:=a6;
   a6:=a0; a0:=a6; a6:=a3; a3:=a2; a2:=a1; a1:=a8; a8:=a7;
   a7:=a9; a9:=a5; a5:=a4; a4:=a0; a0:=a5; a5:=a4; a4:=a6;
   a6:=a3; a3:=a8; a8:=a9; a9:=a1; a1:=a2; a2:=a7; a7:=a0;
   a0:=a7; a7:=a5; a5:=a3; a3:=a4; a4:=a9; a9:=a1; a1:=a2;
   a2:=a6; a6:=a8; a8:=a0; a0:=a9; a9:=a6; a6:=a8; a8:=a2;
   a2:=a1; a1:=a3; a3:=a5; a5:=a4; a4:=a7; a7:=a0; a0:=a8;
   a8:=a7; a7:=a6; a6:=a1; a1:=a4; a4:=a2; a2:=a5; a5:=a3;
   a3:=a9; a9:=a0; a0:=a3; a3:=a9; a9:=a8; a8:=a6; a6:=a7;
   a7:=a4; a4:=a1; a1:=a5; a5:=a2; a2:=a0; a0:=a7; a7:=a3;
   a3:=a4; a4:=a2; a2:=a1; a1:=a9; a9:=a8; a8:=a6; a6:=a5;
   a5:=a0; a0:=a4; a4:=a2; a2:=a1; a1:=a8; a8:=a9; a9:=a5;
   a5:=a6; a6:=a3; a3:=a7; a7:=a0; a0:=a6; a6:=a5; a5:=a4;
   a4:=a3; a3:=a9; a9:=a8; a8:=a1; a1:=a2; a2:=a7; a7:=a0;
   a0:=a7; a7:=a9; a9:=a1; a1:=a3; a3:=a5; a5:=a2; a2:=a4;
   a4:=a6; a6:=a8; a8:=a0; a0:=a5; a5:=a2; a2:=a3; a3:=a4;
   a4:=a9; a9:=a6; a6:=a7; a7:=a8; a8:=a1; a1:=a0; a0:=a8;
   a8:=a4; a4:=a6; a6:=a9; a9:=a5; a5:=a2; a2:=a3; a3:=a1;
   a1:=a7; a7:=a0; a0:=a7; a7:=a3; a3:=a2; a2:=a1; a1:=a8;
   a8:=a4; a4:=a9; a9:=a5; a5:=a6; a6:=a0; a0:=a9; a9:=a7;
   a7:=a3; a3:=a4; a4:=a5; a5:=a1; a1:=a2; a2:=a6; a6:=a8;
   a8:=a0; a0:=a8; a8:=a2; a2:=a4; a4:=a5; a5:=a7; a7:=a9;
   a9:=a3; a3:=a1; a1:=a6; a6:=a0; a0:=a6; a6:=a3; a3:=a2;
   a2:=a5; a5:=a8; a8:=a7; a7:=a1; a1:=a9; a9:=a4; a4:=a0;
   a0:=a9; a9:=a4; a4:=a6; a6:=a3; a3:=a8; a8:=a1; a1:=a5;
   a5:=a2; a2:=a7; a7:=a0; a0:=a7; a7:=a9; a9:=a3; a3:=a4;
   a4:=a1; a1:=a5; a5:=a2; a2:=a6; a6:=a8; a8:=a0; a0:=a1;
   a1:=a6; a6:=a8; a8:=a2; a2:=a5; a5:=a3; a3:=a9; a9:=a4;
   a4:=a7; a7:=a0; a0:=a8; a8:=a7; a7:=a6; a6:=a5; a5:=a4;
   a4:=a2; a2:=a9; a9:=a3; a3:=a1; a1:=a0; a0:=a3; a3:=a1;
   a1:=a8; a8:=a6; a6:=a7; a7:=a4; a4:=a5; a5:=a9; a9:=a2;
   a2:=a0; a0:=a7; a7:=a3; a3:=a4; a4:=a2; a2:=a5; a5:=a1;
   a1:=a8; a8:=a6; a6:=a9; a9:=a0; a0:=a4; a4:=a2; a2:=a5;
   a5:=a8; a8:=a1; a1:=a9; a9:=a6; a6:=a3; a3:=a7; a7:=a0;
   a0:=a6; a6:=a9; a9:=a4; a4:=a3; a3:=a1; a1:=a8; a8:=a5;
   a5:=a2; a2:=a7; a7:=a0; a0:=a7; a7:=a1; a1:=a5; a5:=a3;
   a3:=a9; a9:=a2; a2:=a4; a4:=a6; a6:=a8; a8:=a0
   end;
begin
   a0 :=10; a1 := 1; a2 := 2; a3 := 3; a4 := 4;
   a5 := 5; a6 := 6; a7 := 7; a8 := 8; a9 := 9;
   permute;
   if (a0 <> 1) or (a1 <> 9) or (a2 <> 5) or (a3 <> 2) or (a4 <> 7) or
      (a5 <> 8) or (a6 <> 4) or (a7 <> 3) or (a8 <> 1) or (a9 <> 6)
      then
      FAIL('6.8.3.2-2')
   else
      QUALITY('6.8.3.2-2')
end;
{TEST 6.8.3.4-2, CLASS=QUALITY}

{: This program checks that deeply nested if-statements are
   permitted. }
{V3.0: New test. }

procedure t6p8p3p4d2;
var
   i, j, sum: integer;
begin
   i := 1;
   j := 2;
   sum := 0;
   if i > j then
     begin
     end
   else
     begin
     sum := sum + 1;
     if i > j then
       begin
       end
     else
       begin
       sum := sum + 1;
       if i > j then
         begin
         end
       else
         begin
         sum := sum + 1;
         if i > j then
           begin
           end
         else
           begin
           sum := sum + 1;
           if i > j then
             begin
             end
           else
             begin
             sum := sum + 1;
             if i > j then
               begin
               end
             else
               begin
               sum := sum + 1;
               if i > j then
                 begin
                 end
               else
                 begin
                 sum := sum + 1;
                 if i > j then
                   begin
                   end
                 else
                   begin
                   sum := sum + 1;
                   if i > j then
                     begin
                     end
                   else
                     begin
                     sum := sum + 1;
                     if i > j then
                       begin
                       end
                     else
                       begin
                       sum := sum + 1;
                       if i > j then
                         begin
                         end
                       else
                         begin
                         sum := sum + 1;
                         if i > j then
                           begin
                           end
                         else
                           begin
                           sum := sum + 1;
                           if i > j then
                             begin
                             end
                           else
                             begin
                             sum := sum + 1;
                             if i > j then
                               begin
                               end
                             else
                               begin
                               sum := sum + 1;
                               if i > j then
                                 begin
                                 end
                               else
                                 begin
                                 sum := sum + 1;
                                 if i > j then
                                   begin
                                   end
                                 else
                                   begin
                                   sum := sum + 1;
                                   if i > j then
                                     begin
                                     end
                                   else
                                     begin
                                     sum := sum + 1;
                                     if i > j then
                                       begin
                                       end
                                     else
                                       begin
                                       sum := sum + 1;
                                       if i > j then
                                         begin
                                         end
                                       else
                                         begin
                                         sum := sum + 1;
                                         if i > j then
                                           begin
                                           end
                                         else
                                           begin
                                           sum := sum + 1;
                                           if i > j then
                                             begin
                                             end
                                           else
                                             begin
                                             sum := sum + 1;
                                             if i > j then
                                               begin
                                               end
                                             else
                                               begin
                                               sum := sum + 1;
                                               if i > j then
                                                 begin
                                                 end
                                               else
                                                 begin
                                                 sum := sum + 1;
                                                 if i > j then
                                                   begin
                                                   end
                                                 else
                                                   begin
                                                   sum := sum + 1
                                                   end
                                                 end
                                               end
                                             end
                                           end
                                         end
                                       end
                                     end
                                   end
                                 end
                               end
                             end
                           end
                         end
                       end
                     end
                   end
                 end
               end
             end
           end
         end
       end
     end;
   if sum <> 24 then
     FAIL('6.8.3.4-2')
   else
     QUALITY('6.8.3.4-2')
end;
{TEST 6.8.3.5-12, CLASS=QUALITY}

{: This test checks that the case-constants are of the same type
   as the case index. }
{  A processor of good quality will detect that one path of the
   case statement cannot be taken.
   The case-index in this test is a subrange and the case-constants
   are of the base type. }
{V3.1: Writes revised and comment changed. }

procedure t6p8p3p5d12;
type
   day=(mon,tue,wed);
var
   a:integer;
   d:mon..tue;
begin
   for d:=mon to tue do
      case d of
      mon: a:=1;
      tue: a:=2;
      wed: a:=3
      end;
   WrLn(' WARNING COULD BE ISSUED HERE.');
   QUALITY('6.8.3.5-12');
end;

{TEST 6.8.3.5-13, CLASS=QUALITY}

{: This test contains a large case-statement to check that the
   limit on the size of code is not a serious one. }
{  The processor has a small limit on the size of the
   case-statement if the program does not get to print
   QUALITY. }
{V3.0: Comment and writes slightly altered. Was previously
   6.8.3.5-8. }

procedure t6p8p3p5d13;
var
   sum:integer;
   i:0..255;
begin
   sum :=0;
   for i:=0 to 255 do
      case i of
       0 : sum := sum + i;
       1 : sum := sum + i;
       2 : sum := sum + i;
       3 : sum := sum + i;
       4 : sum := sum + i;
       5 : sum := sum + i;
       6 : sum := sum + i;
       7 : sum := sum + i;
       8 : sum := sum + i;
       9 : sum := sum + i;
      10 : sum := sum + i;
      11 : sum := sum + i;
      12 : sum := sum + i;
      13 : sum := sum + i;
      14 : sum := sum + i;
      15 : sum := sum + i;
      16 : sum := sum + i;
      17 : sum := sum + i;
      18 : sum := sum + i;
      19 : sum := sum + i;
      20 : sum := sum + i;
      21 : sum := sum + i;
      22 : sum := sum + i;
      23 : sum := sum + i;
      24 : sum := sum + i;
      25 : sum := sum + i;
      26 : sum := sum + i;
      27 : sum := sum + i;
      28 : sum := sum + i;
      29 : sum := sum + i;
      30 : sum := sum + i;
      31 : sum := sum + i;
      32 : sum := sum + i;
      33 : sum := sum + i;
      34 : sum := sum + i;
      35 : sum := sum + i;
      36 : sum := sum + i;
      37 : sum := sum + i;
      38 : sum := sum + i;
      39 : sum := sum + i;
      40 : sum := sum + i;
      41 : sum := sum + i;
      42 : sum := sum + i;
      43 : sum := sum + i;
      44 : sum := sum + i;
      45 : sum := sum + i;
      46 : sum := sum + i;
      47 : sum := sum + i;
      48 : sum := sum + i;
      49 : sum := sum + i;
      50 : sum := sum + i;
      51 : sum := sum + i;
      52 : sum := sum + i;
      53 : sum := sum + i;
      54 : sum := sum + i;
      55 : sum := sum + i;
      56 : sum := sum + i;
      57 : sum := sum + i;
      58 : sum := sum + i;
      59 : sum := sum + i;
      60 : sum := sum + i;
      61 : sum := sum + i;
      62 : sum := sum + i;
      63 : sum := sum + i;
      64 : sum := sum + i;
      65 : sum := sum + i;
      66 : sum := sum + i;
      67 : sum := sum + i;
      68 : sum := sum + i;
      69 : sum := sum + i;
      70 : sum := sum + i;
      71 : sum := sum + i;
      72 : sum := sum + i;
      73 : sum := sum + i;
      74 : sum := sum + i;
      75 : sum := sum + i;
      76 : sum := sum + i;
      77 : sum := sum + i;
      78 : sum := sum + i;
      79 : sum := sum + i;
      80 : sum := sum + i;
      81 : sum := sum + i;
      82 : sum := sum + i;
      83 : sum := sum + i;
      84 : sum := sum + i;
      85 : sum := sum + i;
      86 : sum := sum + i;
      87 : sum := sum + i;
      88 : sum := sum + i;
      89 : sum := sum + i;
      90 : sum := sum + i;
      91 : sum := sum + i;
      92 : sum := sum + i;
      93 : sum := sum + i;
      94 : sum := sum + i;
      95 : sum := sum + i;
      96 : sum := sum + i;
      97 : sum := sum + i;
      98 : sum := sum + i;
      99 : sum := sum + i;
      100 : sum := sum + i;
      101 : sum := sum + i;
      102 : sum := sum + i;
      103 : sum := sum + i;
      104 : sum := sum + i;
      105 : sum := sum + i;
      106 : sum := sum + i;
      107 : sum := sum + i;
      108 : sum := sum + i;
      109 : sum := sum + i;
      110 : sum := sum + i;
      111 : sum := sum + i;
      112 : sum := sum + i;
      113 : sum := sum + i;
      114 : sum := sum + i;
      115 : sum := sum + i;
      116 : sum := sum + i;
      117 : sum := sum + i;
      118 : sum := sum + i;
      119 : sum := sum + i;
      120 : sum := sum + i;
      121 : sum := sum + i;
      122 : sum := sum + i;
      123 : sum := sum + i;
      124 : sum := sum + i;
      125 : sum := sum + i;
      126 : sum := sum + i;
      127 : sum := sum + i;
      128 : sum := sum + i;
      129 : sum := sum + i;
      130 : sum := sum + i;
      131 : sum := sum + i;
      132 : sum := sum + i;
      133 : sum := sum + i;
      134 : sum := sum + i;
      135 : sum := sum + i;
      136 : sum := sum + i;
      137 : sum := sum + i;
      138 : sum := sum + i;
      139 : sum := sum + i;
      140 : sum := sum + i;
      141 : sum := sum + i;
      142 : sum := sum + i;
      143 : sum := sum + i;
      144 : sum := sum + i;
      145 : sum := sum + i;
      146 : sum := sum + i;
      147 : sum := sum + i;
      148 : sum := sum + i;
      149 : sum := sum + i;
      150 : sum := sum + i;
      151 : sum := sum + i;
      152 : sum := sum + i;
      153 : sum := sum + i;
      154 : sum := sum + i;
      155 : sum := sum + i;
      156 : sum := sum + i;
      157 : sum := sum + i;
      158 : sum := sum + i;
      159 : sum := sum + i;
      160 : sum := sum + i;
      161 : sum := sum + i;
      162 : sum := sum + i;
      163 : sum := sum + i;
      164 : sum := sum + i;
      165 : sum := sum + i;
      166 : sum := sum + i;
      167 : sum := sum + i;
      168 : sum := sum + i;
      169 : sum := sum + i;
      170 : sum := sum + i;
      171 : sum := sum + i;
      172 : sum := sum + i;
      173 : sum := sum + i;
      174 : sum := sum + i;
      175 : sum := sum + i;
      176 : sum := sum + i;
      177 : sum := sum + i;
      178 : sum := sum + i;
      179 : sum := sum + i;
      180 : sum := sum + i;
      181 : sum := sum + i;
      182 : sum := sum + i;
      183 : sum := sum + i;
      184 : sum := sum + i;
      185 : sum := sum + i;
      186 : sum := sum + i;
      187 : sum := sum + i;
      188 : sum := sum + i;
      189 : sum := sum + i;
      190 : sum := sum + i;
      191 : sum := sum + i;
      192 : sum := sum + i;
      193 : sum := sum + i;
      194 : sum := sum + i;
      195 : sum := sum + i;
      196 : sum := sum + i;
      197 : sum := sum + i;
      198 : sum := sum + i;
      199 : sum := sum + i;
      200 : sum := sum + i;
      201 : sum := sum + i;
      202 : sum := sum + i;
      203 : sum := sum + i;
      204 : sum := sum + i;
      205 : sum := sum + i;
      206 : sum := sum + i;
      207 : sum := sum + i;
      208 : sum := sum + i;
      209 : sum := sum + i;
      210 : sum := sum + i;
      211 : sum := sum + i;
      212 : sum := sum + i;
      213 : sum := sum + i;
      214 : sum := sum + i;
      215 : sum := sum + i;
      216 : sum := sum + i;
      217 : sum := sum + i;
      218 : sum := sum + i;
      219 : sum := sum + i;
      220 : sum := sum + i;
      221 : sum := sum + i;
      222 : sum := sum + i;
      223 : sum := sum + i;
      224 : sum := sum + i;
      225 : sum := sum + i;
      226 : sum := sum + i;
      227 : sum := sum + i;
      228 : sum := sum + i;
      229 : sum := sum + i;
      230 : sum := sum + i;
      231 : sum := sum + i;
      232 : sum := sum + i;
      233 : sum := sum + i;
      234 : sum := sum + i;
      235 : sum := sum + i;
      236 : sum := sum + i;
      237 : sum := sum + i;
      238 : sum := sum + i;
      239 : sum := sum + i;
      240 : sum := sum + i;
      241 : sum := sum + i;
      242 : sum := sum + i;
      243 : sum := sum + i;
      244 : sum := sum + i;
      245 : sum := sum + i;
      246 : sum := sum + i;
      247 : sum := sum + i;
      248 : sum := sum + i;
      249 : sum := sum + i;
      250 : sum := sum + i;
      251 : sum := sum + i;
      252 : sum := sum + i;
      253 : sum := sum + i;
      254 : sum := sum + i;
      //255 : sum := sum + i
      end;
   if sum = 32640-255 then //255 * 256/2
      QUALITY('6.8.3.5-13')
   else
      FAIL('6.8.3.5-13, sum='+i2s(sum)+' correct is: '+i2s(32640-255))
end;

{TEST 6.8.3.5-14, CLASS=QUALITY}

{: This program checks that 300 constants are allowed in a
   case-constant list. }
{V3.0: New test. }

procedure t6p8p3p5d14;
const
   limit = 300;
var
   i, sum: integer;
begin
   sum := 0;
   for i := -1 to limit + 4 do
      case i of
         -1, 0, 301, 302, 303, 304: ;
         1, 2, 3, 4, 5, 6, 7, 8, 9,
         10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
         20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
         30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
         40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
         50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
         60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
         70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
         80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
         90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
         100,101,102,103,104,105,106,107,108,109,
         110,111,112,113,114,115,116,117,118,119,
         120,121,122,123,124,125,126,127,128,129,
         130,131,132,133,134,135,136,137,138,139,
         140,141,142,143,144,145,146,147,148,149,
         150,151,152,153,154,155,156,157,158,159,
         160,161,162,163,164,165,166,167,168,169,
         170,171,172,173,174,175,176,177,178,179,
         180,181,182,183,184,185,186,187,188,189,
         190,191,192,193,194,195,196,197,198,199,
         200,201,202,203,204,205,206,207,208,209,
         210,211,212,213,214,215,216,217,218,219,
         220,221,222,223,224,225,226,227,228,229,
         230,231,232,233,234,235,236,237,238,239,
         240,241,242,243,244,245,246,247,248,249,
         250,251,252,253,254,255,256,257,258,259,
         260,261,262,263,264,265,266,267,268,269,
         270,271,272,273,274,275,276,277,278,279,
         280,281,282,283,284,285,286,287,288,289,
         290,291,292,293,294,295,296,297,298,299,
            300:  sum := sum + 1
      end;
   if sum <> limit then
      FAIL('6.8.3.5-14')
   else
      QUALITY('6.8.3.5-14')
end;
{TEST 6.8.3.5-15, CLASS=QUALITY}

{: This program checks that case-statements can be nested
   15 deep. }
{V3.0: New test. }

procedure t6p8p3p5d15;
var
   a, d: integer;
begin
   d := 31675;
   a := 0;
   case odd(d) of
    true:
      begin
      d := d div 2;   {15837}
      a := a + 1;
      case odd(d) of
       true:
         begin
         d := d div 2;   {7918}
         a := a + 2;
         case odd(d) of
          true: ;
          false:
            begin
            d := d div 2;   {3959}
            case odd(d) of
             true:
               begin
               d := d div 2;   {1979}
               a := a + 8;
               case odd(d) of
                true:
                  begin
                  d := d div 2;   {989}
                  a := a + 16;
                  case odd(d) of
                   true:
                     begin
                     d := d div 2;  {494}
                     a := a + 32;
                     case odd(d) of
                      true: ;
                      false:
                        begin
                        d := d div 2;   {247}
                        case odd(d) of
                         true:
                           begin
                           d := d div 2;   {123}
                           a := a + 128;
                           case odd(d) of
                            true:
                              begin
                              d := d div 2;  {61}
                              a := a + 256;
                              case odd(d) of
                               true:
                                 begin
                                 d := d div 2;  {30}
                                 a := a + 512;
                                 case odd(d) of
                                  true: ;
                                  false:
                                    begin
                                    d := d div 2;  {15}
                                    case odd(d) of
                                     true:
                                       begin
                                       d := d div 2;  {7}
                                       a := a + 2048;
                                       case odd(d) of
                                        true:
                                          begin
                                          d := d div 2; {3}
                                          a := a + 4096;
                                          case odd(d) of
                                           true:
                                             begin
                                             d := d div 2; {1}
                                             a := a + 8192;
                                             case odd(d) of
                                              true: a := a + 16384;
                                              false:
                                             end
                                             end;
                                           false:
                                          end
                                          end;
                                        false:
                                       end
                                       end;
                                     false:
                                    end
                                    end
                                 end
                                 end;
                               false:
                              end
                              end;
                            false:
                           end
                           end;
                         false:
                        end
                        end
                     end
                     end;
                   false:
                  end
                  end;
                false:
               end
               end;
             false:
            end
            end
         end
         end;
       false:
      end
      end;
    false:
   end;
   if a = 31675 then
      QUALITY('6.8.3.5-15')
   else
      FAIL('6.8.3.5-15')
end;
{TEST 6.8.3.7-4, CLASS=QUALITY}

{: This program checks that repeat-statements can be nested
   15 deep. }
{V3.0: New test. }

procedure t6p8p3p7d4;
var a0, a1, a2, a3, a4, a5, a6,
   a7, a8, a9, a10, a11, a12, a13, a14: integer;
   sum: integer;
begin
   sum := 0;
   a0 := 1;
      repeat
      sum := sum + 1;
      a1 := 1;
         repeat
         sum := sum + 1;
         a2 := 1;
            repeat
            sum := sum + 1;
            a3 := 1;
               repeat
               sum := sum + 1;
               a4 := 1;
                  repeat
                  sum := sum + 1;
                  a5 := 1;
                     repeat
                     sum := sum + 1;
                     a6 := 1;
                        repeat
                        sum := sum + 1;
                        a7 := 1;
                           repeat
                           sum := sum + 1;
                           a8 := 1;
                              repeat
                              sum := sum + 1;
                              a9 := 1;
                                 repeat
                                 sum := sum + 1;
                                 a10 := 1;
                                    repeat
                                    sum := sum + 1;
                                    a11 := 1;
                                       repeat
                                       sum := sum + 1;
                                       a12 := 1;
                                          repeat
                                          sum := sum + 1;
                                          a13 := 1;
                                             repeat
                                             sum := sum + 1;
                                             a14 := 1;
                                                repeat
                                                sum := sum - 1;
                                                a14 := a14 + 1
                                                until a14 = 3;
                                             a13 := a13 + 1
                                             until a13 = 3;
                                          a12 := a12 + 1
                                          until a12 = 3;
                                       a11 := a11 + 1
                                       until a11 = 3;
                                    a10 := a10 + 1
                                    until a10 = 3;
                                 a9 := a9 + 1
                                 until a9 = 3;
                              a8 := a8 + 1
                              until a8 = 3;
                           a7 := a7 + 1
                           until a7 = 3;
                        a6 := a6 + 1
                        until a6 = 3;
                     a5 := a5 + 1
                     until a5 = 3;
                  a4 := a4 + 1
                  until a4 = 3;
               a3 := a3 + 1
               until a3 = 3;
            a2 := a2 + 1
            until a2 = 3;
         a1 := a1 + 1
         until a1 = 3;
      a0 := a0 + 1
      until a0 = 3;
   if sum <> -2 then
      FAIL('6.8.3.7-4')
   else
      QUALITY('6.8.3.7-4')
end;

{ IFDEF PC inserted for easy move between Mac, Atari & PC /Christen Fihl }

{TEST 6.8.3.8-3, CLASS=QUALITY}

{: This program checks that while-statements can be nested
   15 deep. }
{V3.0: New test. }

procedure t6p8p3p8d3;
var
   a0, a1, a2, a3,  a4,  a5,  a6,
   a7, a8, a9, a10, a11, a12, a13, a14: integer;
   sum: integer;
begin
   sum := 0;
   a0 := 1;
   while a0 < 3 do
     begin
      sum := sum + 1;
      a1 := 1;
      while a1 < 3 do
        begin
         sum := sum + 1;
         a2 := 1;
         while a2 < 3 do
           begin
            sum := sum + 1;
            a3 := 1;
            while a3 < 3 do
              begin
               sum := sum + 1;
               a4 := 1;
               while a4 < 3 do
                 begin
                  sum := sum + 1;
                  a5 := 1;
                  while a5 < 3 do
                    begin
                     sum := sum + 1;
                     a6 := 1;
                     while a6 < 3 do
                       begin
                        sum := sum + 1;
                        a7 := 1;
                        while a7 < 3 do
                          begin
                           sum := sum + 1;
                           a8 := 1;
                           while a8 < 3 do
                             begin
                              sum := sum + 1;
                              a9 := 1;
                              while a9 < 3 do
                                begin
                                 sum := sum + 1;
                                 a10 := 1;
                                 while a10 < 3 do
                                    begin
                                    sum := sum + 1;
                                    a11 := 1;
                                    while a11 < 3 do
                                       begin
                                       sum := sum + 1;
                                       a12 := 1;
                                       while a12 < 3 do
                                          begin
                                          sum := sum + 1;
                                          a13 := 1;
                                          while a13 < 3 do
                                             begin
                                             sum := sum + 1;
                                             a14 := 1;
                                             while a14 < 3 do
                                                begin
                                                sum := sum - 1;
                                                a14 := a14 + 1
                                                end;
                                             a13 := a13 + 1
                                             end;
                                          a12 := a12 + 1
                                          end;
                                       a11 := a11 + 1
                                       end;
                                    a10 := a10 + 1
                                    end;
                                 a9 := a9 + 1
                                 end;
                              a8 := a8 + 1
                              end;
                           a7 := a7 + 1
                           end;
                        a6 := a6 + 1
                        end;
                     a5 := a5 + 1
                     end;
                  a4 := a4 + 1
                  end;
               a3 := a3 + 1
               end;
            a2 := a2 + 1
            end;
         a1 := a1 + 1
         end;
      a0 := a0 + 1
      end;
   if sum <> -2 then
      FAIL('6.8.3.8-3')
   else
      QUALITY('6.8.3.8-3')
end;
{TEST 6.8.3.9-20, CLASS=QUALITY}

{: This program checks that for-statements can be nested
   15 deep. }
{V3.0: Value check added.
   Extended nesting depth from 12 to 15. }

(****
procedure t6p8p3p9d20;
var a0, a1, a2, a3, a4, a5, a6,
   a7, a8, a9, a10, a11, a12, a13, a14: integer;
   sum: integer;
begin
   sum := 0;
   for a0 := 1 to 2 do
      begin
      sum := sum + 1;
      for a1 := 1 to 2 do
         begin
         sum := sum + 1;
         for a2 := 1 to 2 do
            begin
            sum := sum + 1;
            for a3 := 1 to 2 do
               begin
               sum := sum + 1;
               for a4 := 1 to 2 do
                  begin
                  sum := sum + 1;
                  for a5 := 1 to 2 do
                     begin
                     sum := sum + 1;
                     for a6 := 1 to 2 do
                        begin
                        sum := sum + 1;
                        for a7 := 1 to 2 do
                           begin
                           sum := sum + 1;
                           for a8 := 1 to 2 do
                              begin
                              sum := sum + 1;
                              for a9 := 1 to 2 do
                                 begin
                                 sum := sum + 1;
                                 for a10 := 1 to 2 do
                                    begin
                                    sum := sum + 1;
                                    for a11 := 1 to 2 do
                                       begin
                                       sum := sum + 1;
                                       for a12 := 1 to 2 do
                                          begin
                                          sum := sum + 1;
                                          for a13 := 1 to 2 do
                                             begin
                                             sum := sum + 1;
                                             for a14 := 1 to 2 do
                                                begin
                                                sum := sum - 1
                                                end
                                             end
                                          end
                                       end
                                    end
                                 end
                              end
                           end
                        end
                     end
                  end
               end
            end
         end
      end;
   if sum <> -2 then
      FAIL('6.8.3.9-20')
   else
      QUALITY('6.8.3.9-20')
end;
(***********)

{TEST 6.8.3.10-7, CLASS=QUALITY}

{: This test checks that with-statements may be nested to 15
   levels. }
{  The test may break a limit in some processors, particularly if a
   register is allocated for every selected variable. }
{V3.0: Value check added. Write standardised. }

(**************
procedure t6p8p3p10d7;
type
   rec1 = record
             i1:integer
           end;
   rec2 = record
             i2:integer
           end;
   rec3 = record
             i3:integer
           end;
   rec4 = record
             i4:integer
           end;
   rec5 = record
             i5:integer
           end;
   rec6 = record
             i6:integer
           end;
   rec7 = record
             i7:integer
           end;
   rec8 = record
             i8:integer
           end;
   rec9 = record
             i9:integer
           end;
   rec10 = record
             i10:integer
           end;
   rec11 = record
             i11:integer
           end;
   rec12 = record
             i12:integer
           end;
   rec13 = record
             i13:integer
           end;
   rec14 = record
             i14:integer
           end;
   rec15 = record
             i15:integer
           end;
   p1 = ^rec1;
   p2 = ^rec2;
   p3 = ^rec3;
   p4 = ^rec4;
   p5 = ^rec5;
   p6 = ^rec6;
   p7 = ^rec7;
   p8 = ^rec8;
   p9 = ^rec9;
   p10 = ^rec10;
   p11 = ^rec11;
   p12 = ^rec12;
   p13 = ^rec13;
   p14 = ^rec14;
   p15 = ^rec15;
var
   ptr1 : p1;
   ptr2 : p2;
   ptr3 : p3;
   ptr4 : p4;
   ptr5 : p5;
   ptr6 : p6;
   ptr7 : p7;
   ptr8 : p8;
   ptr9 : p9;
   ptr10 : p10;
   ptr11 : p11;
   ptr12 : p12;
   ptr13 : p13;
   ptr14 : p14;
   ptr15 : p15;
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
   new(ptr10);
   new(ptr11);
   new(ptr12);
   new(ptr13);
   new(ptr14);
   new(ptr15);
   with ptr1^ do
      with ptr2^ do
         with ptr3^ do
            with ptr4^ do
               with ptr5^ do
                  with ptr6^ do
                     with ptr7^ do
                        with ptr8^ do
                           with ptr9^ do
                              with ptr10^ do
                                 with ptr11^ do
                                    with ptr12^ do
                                       with ptr13^ do
                                          with ptr14^ do
                                             with ptr15^ do
                                                  begin
                                                  i1:=1;
                                                  i2:=2;
                                                  i3:=3;
                                                  i4:=4;
                                                  i5:=5;
                                                  i6:=6;
                                                  i7:=7;
                                                  i8:=8;
                                                  i9:=9;
                                                  i10:=10;
                                                  i11:=11;
                                                  i12:=12;
                                                  i13:=13;
                                                  i14:=14;
                                                  i15:=15
                                                  end;
   if (ptr1^.i1=1)and(ptr2^.i2=2)and(ptr3^.i3=3)and(ptr4^.i4=4)and
      (ptr5^.i5=5)and(ptr6^.i6=6)and(ptr7^.i7=7)and(ptr8^.i8=8)and
      (ptr9^.i9=9)and(ptr10^.i10=10)and(ptr11^.i11=11)and
      (ptr12^.i12=12)and(ptr13^.i13=13)and(ptr14^.i14=14)and
      (ptr15^.i15=15) then
      QUALITY('6.8.3.10-7')
   else
      FAIL('6.8.3.10-7')
end;
(********)

{TEST 6.9.1-7, CLASS=QUALITY}

{: This program checks that a list of 30 variable-accesses can
   appear in a read parameter list. }
{V3.1: Program parameter removed. }

(********
procedure t6p9p1d7;
const
   str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123';
var
    c00, c01, c02, c03, c04, c05, c06, c07, c08, c09,
    c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
    c20, c21, c22, c23, c24, c25, c26, c27, c28, c29
      : char;
   tempfile: text;
begin

{$Ifdef PC}
   assign(tempfile,'PVSTEMP.$$$'); rewrite(tempfile);
 
{$else}
   rewrite(tempfile,'PVSTEMP.$$$');
{$endif}

   WrLn(tempfile, str);
   reset(tempfile);
   read(tempfile,
       c00, c01, c02, c03, c04, c05, c06, c07, c08, c09,
       c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
       c20, c21, c22, c23, c24, c25, c26, c27, c28, c29);
   if (c00 <> 'A') or (c01 <> 'B') or (c02 <> 'C') or
      (c03 <> 'D') or (c04 <> 'E') or (c05 <> 'F') or
      (c06 <> 'G') or (c07 <> 'H') or (c08 <> 'I') or
      (c09 <> 'J') or (c10 <> 'K') or (c11 <> 'L') or
      (c12 <> 'M') or (c13 <> 'N') or (c14 <> 'O') or
      (c15 <> 'P') or (c16 <> 'Q') or (c17 <> 'R') or
      (c18 <> 'S') or (c19 <> 'T') or (c20 <> 'U') or
      (c21 <> 'V') or (c22 <> 'W') or (c23 <> 'X') or
      (c24 <> 'Y') or (c25 <> 'Z') or (c26 <> '0') or
      (c27 <> '1') or (c28 <> '2') or (c29 <> '3') then
      FAIL('6.9.1-7')
   else
      QUALITY('6.9.1-7');
   close(tempfile);

{$Ifdef PC}
   erase(tempfile);
{$else}
   erase('PVSTEMP.$$$');
{$endif}

end;

{TEST 6.9.2-2, CLASS=QUALITY}

{: This program checks that a list of 30 variable-accesses can
   appear in a readln-parameter-list. }
{V3.0: Program parameter removed. }

procedure t6p9p2d2;
const
   str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123';
var
    c00, c01, c02, c03, c04, c05, c06, c07, c08, c09,
    c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
    c20, c21, c22, c23, c24, c25, c26, c27, c28, c29,
    c30  : char;
   tempfile: text;
begin

{$Ifdef PC}
   assign(tempfile,'PVSTEMP.$$$'); rewrite(tempfile);
 
{$else}
   rewrite(tempfile,'PVSTEMP.$$$');
{$endif}

   write(tempfile, str);
   WrLn(tempfile, 'X');
   WrLn(tempfile, '4');
   reset(tempfile);
   readln(tempfile,
       c00, c01, c02, c03, c04, c05, c06, c07, c08, c09,
       c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
       c20, c21, c22, c23, c24, c25, c26, c27, c28, c29);
   read(tempfile, c30);
   if (c00 <> 'A') or (c01 <> 'B') or (c02 <> 'C') or
      (c03 <> 'D') or (c04 <> 'E') or (c05 <> 'F') or
      (c06 <> 'G') or (c07 <> 'H') or (c08 <> 'I') or
      (c09 <> 'J') or (c10 <> 'K') or (c11 <> 'L') or
      (c12 <> 'M') or (c13 <> 'N') or (c14 <> 'O') or
      (c15 <> 'P') or (c16 <> 'Q') or (c17 <> 'R') or
      (c18 <> 'S') or (c19 <> 'T') or (c20 <> 'U') or
      (c21 <> 'V') or (c22 <> 'W') or (c23 <> 'X') or
      (c24 <> 'Y') or (c25 <> 'Z') or (c26 <> '0') or
      (c27 <> '1') or (c28 <> '2') or (c29 <> '3')
      or (c30 <> '4') then
      FAIL('6.9.2-2')
   else
      QUALITY('6.9.2-2');
   close(tempfile);

{$Ifdef PC}
   erase(tempfile);
{$else}
   erase('PVSTEMP.$$$');
{$endif}
end;

{TEST 6.9.3-3, CLASS=QUALITY}

{: This program checks that a list of 30 write-parameters can
   appear in a write-parameter-list. }
{V3.1: program parameter removed. }

procedure t6p9p3d3;
const
   str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234';
var
   fail: boolean;
   c: char;
   v: packed array [ 1 .. 31 ] of char;
   i: 1 .. 31;
   tempfile: text;
begin
   fail := false;
   v := str;

{$Ifdef PC}
   assign(tempfile,'PVSTEMP.$$$'); rewrite(tempfile);
 
{$else}
   rewrite(tempfile,'PVSTEMP.$$$');
{$endif}

   write(tempfile, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
                   'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
                   'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0',
                   '1', '2', '3');
   WrLn(tempfile, '4');
   reset(tempfile);
   for i := 1 to 31 do
      begin
      read(tempfile, c);
      if c <> v[i] then
         fail := true
      end;
   if fail then
      FAIL('6.9.3-3')
   else
      QUALITY('6.9.3-3');
   close(tempfile);

{$Ifdef PC}
   erase(tempfile);
{$else}
   erase('PVSTEMP.$$$');
{$endif}
end;
{TEST 6.9.4-2, CLASS=QUALITY}

{: This program checks that a list of 30 write-parameters can
   appear in a Wr-parameter-list. }
{V3.1: Program parameter removed. }

procedure t6p9p4d2;
const
   str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123';
var
   fail: boolean;
   c: char;
   v: packed array [ 1 .. 30] of char;
   i: 1 .. 30;
   tempfile: text;
begin
   fail := false;
   v := str;

{$Ifdef PC}
   assign(tempfile,'PVSTEMP.$$$'); rewrite(tempfile);
 
{$else}
   rewrite(tempfile,'PVSTEMP.$$$');
{$endif}

   WrLn(tempfile, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
                   'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
                   'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0',
                   '1', '2', '3');
   reset(tempfile);
   for i := 1 to 30 do
      begin
      read(tempfile, c);
      if c <> v[i] then
         fail := true
      end;
   if not eoln(tempfile) then
      fail := true;
   if fail then
      FAIL('6.9.4-2')
   else
      QUALITY('6.9.4-2');
   close(tempfile);

{$Ifdef PC}
   erase(tempfile);
{$else}
   erase('PVSTEMP.$$$');
{$endif}
end;
(*****************)


{TEST 6.1.7-15, CLASS=IMPLEMENTATIONDEFINED, NUMBER= 1}

{: This program checks that the required string-characters
   are provided. }
{V3.1: New test. }

(****************
procedure t6p1p7d15;
const
   reqstr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-*/=<>.,:;^() ''';
var
   st: packed array [1 .. 52] of char;
   i, j: 1 .. 52;
   fail: boolean;
begin
   fail := false;
   st := reqstr;
   for i := 1 to 52 do
   for j := 1 to 52 do
      begin
      if (i <> j) and (st[i] = st[j]) then
         fail := true;
      end;
   if fail then
      FAIL('6.1.7-15')
   else
      WrLn(' IMPLEMENTATION DEFINED...6.1.7-15')
end;
(***********)

{TEST 6.1.9-5, CLASS=IMPLEMENTATIONDEFINED, NUMBER=16}

{: This program checks whether the required equivalent
   symbols can be used instead of the reference representation. }
{  The required alternative representations are for curly comment
   brackets and square subscript brackets. These must be provided
   since the necessary characters *, ), and . are available. }
{V3.1: Changed to test required alternatives, not just comments. }

procedure t6p1p9d5;
(* Test of alternate comment delimiters *)
var
   x: array (. 1 .. 10 .) of boolean;
   y: array [ 1 .. 10.) of boolean;
begin
   x(.1] := true;
   y[1.) := x[1];
 (* test of alternate comment delimiters. If these delimiters
   are not implemented a syntax error will result. *)
   QUALITY('6.1.9-5');
end;
{TEST 6.4.2.2-10, CLASS=IMPLEMENTATIONDEFINED, NUMBER= 6}

{: This program prints out the implementation defined value
   of maxint. }
{V3.0: Was previously 6.4.2.2-7. }

procedure t6p4p2p2d10;
begin
  WrLn('Q-6.4.2.2-10');
  WrLn(' MAXINT='+i2s(maxint));
end;
{TEST 6.4.2.2-11, CLASS=IMPLEMENTATIONDEFINED, NUMBER= 2}

{: This program observes the approximate accuracy of real
   values around 1.0. It prints the precision in decimal
   digits up to 30 places. }
{V3.1: new test. }

procedure t6p4p2p2d11;
label
   1;
var
   i: integer;
   x, y: array [ 1 .. 30 ] of real;
begin
x[1] := 1.1;  x[2] := 1.01;  x[3] := 1.001; x[4] := 1.0001;
x[5] := 1.00001;  x[6] := 1.000001;  x[7] := 1.0000001;
x[8] := 1.00000001;  x[9] := 1.000000001;  x[10] := 1.0000000001;
x[11] := 1.00000000001;  x[12] := 1.000000000001;
x[13] := 1.0000000000001;  x[14] := 1.00000000000001;
x[15] := 1.000000000000001;  x[16] := 1.0000000000000001;
x[17] := 1.00000000000000001;  x[18] := 1.000000000000000001;
x[19] := 1.0000000000000000001;  x[20] := 1.00000000000000000001;
x[21] := 1.000000000000000000001;
x[22] := 1.0000000000000000000001;
x[23] := 1.00000000000000000000001;
x[24] := 1.000000000000000000000001;
x[25] := 1.0000000000000000000000001;
x[26] := 1.00000000000000000000000001;
x[27] := 1.000000000000000000000000001;
x[28] := 1.0000000000000000000000000001;
x[29] := 1.00000000000000000000000000001;
x[30] := 1.000000000000000000000000000001;
y[1] := 0.9;  y[2] := 0.99;  y[3] := 0.999; y[4] := 0.9999;
y[5] := 0.99999;  y[6] := 0.999999;  y[7] := 0.9999999;
y[8] := 0.99999999;  y[9] := 0.999999999;  y[10] := 0.9999999999;
y[11] := 0.99999999999;  y[12] := 0.999999999999;
y[13] := 0.9999999999999;  y[14] := 0.99999999999999;
y[15] := 0.999999999999999;  y[16] := 0.9999999999999999;
y[17] := 0.99999999999999999;  y[18] := 0.999999999999999999;
y[19] := 0.9999999999999999999;  y[20] := 0.99999999999999999999;
y[21] := 0.999999999999999999999;
y[22] := 0.9999999999999999999999;
y[23] := 0.99999999999999999999999;
y[24] := 0.999999999999999999999999;
y[25] := 0.9999999999999999999999999;
y[26] := 0.99999999999999999999999999;
y[27] := 0.999999999999999999999999999;
y[28] := 0.9999999999999999999999999999;
y[29] := 0.99999999999999999999999999999;
y[30] := 0.999999999999999999999999999999;
i := 1;
while (x[i] > x[i+1]) and (y[i] < y[i+1]) do
   begin
   if i=29 then
      goto 1
   else
      i := i + 1
   end;
1:
  WrLn('Q-6.4.2.2-11');
  WrLn(' REAL ACCURACY OF UREAL:');
  if i=29 then
    WrLn(' GREATER THAN 29 DECIMAL PLACES')
  else
    WrLn(' '+ i2s(i)+' DECIMAL PLACES');
end;

{TEST 6.7.2.2-17, CLASS=IMPLEMENTATIONDEFINED, NUMBER= 7}

{: This program observes the approximate accuracy of real
   operations giving results  around 1.0. It prints the precision
   in decimal digits up to 30 places. }
{V3.1: New test. }

procedure t6p7p2p2d17;
var
   min: integer;
   x, y: array [ 1 .. 30 ] of real;
procedure nearone( v: real );
   label
      1;
   var
      i: integer;
   begin
   i := 1;
   while (x[i] > v) and (y[i] < v) do
      begin
      if i=30 then
         goto 1
      else
         i := i + 1
   end;
   1:
   if i < min then
      min := i
   end; {nearone}
begin
x[1] := 1.1;  x[2] := 1.01;  x[3] := 1.001; x[4] := 1.0001;
x[5] := 1.00001;  x[6] := 1.000001;  x[7] := 1.0000001;
x[8] := 1.00000001;  x[9] := 1.000000001;  x[10] := 1.0000000001;
x[11] := 1.00000000001;  x[12] := 1.000000000001;
x[13] := 1.0000000000001;  x[14] := 1.00000000000001;
x[15] := 1.000000000000001;  x[16] := 1.0000000000000001;
x[17] := 1.00000000000000001;  x[18] := 1.000000000000000001;
x[19] := 1.0000000000000000001;  x[20] := 1.00000000000000000001;
x[21] := 1.000000000000000000001;
x[22] := 1.0000000000000000000001;
x[23] := 1.00000000000000000000001;
x[24] := 1.000000000000000000000001;
x[25] := 1.0000000000000000000000001;
x[26] := 1.00000000000000000000000001;
x[27] := 1.000000000000000000000000001;
x[28] := 1.0000000000000000000000000001;
x[29] := 1.00000000000000000000000000001;
x[30] := 1.000000000000000000000000000001;
y[1] := 0.9;  y[2] := 0.99;  y[3] := 0.999; y[4] := 0.9999;
y[5] := 0.99999;  y[6] := 0.999999;  y[7] := 0.9999999;
y[8] := 0.99999999;  y[9] := 0.999999999;  y[10] := 0.9999999999;
y[11] := 0.99999999999;  y[12] := 0.999999999999;
y[13] := 0.9999999999999;  y[14] := 0.99999999999999;
y[15] := 0.999999999999999;  y[16] := 0.9999999999999999;
y[17] := 0.99999999999999999;  y[18] := 0.999999999999999999;
y[19] := 0.9999999999999999999;  y[20] := 0.99999999999999999999;
y[21] := 0.999999999999999999999;
y[22] := 0.9999999999999999999999;
y[23] := 0.99999999999999999999999;
y[24] := 0.999999999999999999999999;
y[25] := 0.9999999999999999999999999;
y[26] := 0.99999999999999999999999999;
y[27] := 0.999999999999999999999999999;
y[28] := 0.9999999999999999999999999999;
y[29] := 0.99999999999999999999999999999;
y[30] := 0.999999999999999999999999999999;
min := 30;
nearone(1.0 + 0.1 - 0.1);
nearone(0.1 * 10.0);
nearone(15.0 / 3.0 / 5.0);
nearone(0.6 + 0.4);
nearone( -(-1.1 + 0.1) );
nearone( abs(-2.1) / 2.1 );
nearone( sqrt(1.0/3.0) * sqrt(3.0) );
nearone( sqr( sqrt(2.0)) / 2.0 );
nearone( exp( ln(2.1) )/2.1 );
nearone( exp(ln(3.0)/2.0) / sqrt(3.0) );
nearone( exp(ln(sqr(0.1))/2.0) * 10.0 );
nearone( sin(arctan(0.75)) * 5.0 / 3.0 );
nearone( cos(arctan(4.0/3.0)) * 5.0 / 3.0 );
WrLn(' OUTPUT FROM TEST...6.7.2.2-17');
WrLn(' ACCURACY OF REAL OPERATIONS IS');
if min=30 then
   WrLn(' GREATER THAN 30 DECIMAL PLACES')
else
   WrLn(' ABOUT '+i2s(min)+ ' DECIMAL PLACES');
WrLn(' IMPLEMENTATION DEFINED...6.7.2.2-17')
end;
{TEST 6.5.3.2-6, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 1}

{: This program determines the evaluation order of
   indexed-expressions of an indexed-variable. }
{V3.1: New test. }

procedure t6p5p3p2d6;
var
   st: packed array [ 1 .. 3 ] of char;
   count: 1 .. 4;
   v: array [ 1..1, 1..1, 1..1 ] of integer;

function sideeffect(c: char; i: integer): integer;
   begin
   st[count] := c;
   count := count + 1;
   sideeffect := i;
   end;
begin
   st := '   ';
   count := 1;
   WrLn('X-6.5.3.2-6');
   WrLn(' EVAL ORDER OF V(.A,B,C.) IS ');
   v[sideeffect('A',1),sideeffect('B',1),sideeffect('C',1)] := 1;
   WrLn( st );
   WrLn(' IMPL****')
end;
{TEST 6.7.1-11, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 2}

{: This program determines the order of evaluation of the
   expressions of a member-designator. }
{V3.1: New test. }

{$IfNdef DoLater2}
procedure t6p7p1d11;
var
   st: packed array [ 1 .. 3 ] of char;
   count: 1 .. 4;
   x: set of 0 .. 2;

function sideeffect(c: char; i: integer): integer;
   begin
   st[count] := c;
   count := count + 1;
   sideeffect := i;
   end;
begin
   count := 1;
   st := '   ';
   WrLn('X-6.7.1-11');
   WrLn(' EVAL ORDER OF (. A, B, C .) IS ');
   x := [sideeffect('A',0),sideeffect('B',1),sideeffect('C',2)];
   WrLn( st );
   WrLn(' IMPL****')
end;
{$endif}

{TEST 6.7.1-12, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 3}

{: This test contains an implementation-dependency in the order of
   evaluation of expressions in a member-designator of a
   set-constructor. }
{V3.1: New test. }

procedure t6p7p1d12;
type
   ET      = (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P);
var
   evar : set of ET;
   seed : ET;

   function nasty:ET;
   begin seed:=pred(seed); nasty:=seed end;

   function horrible:ET;
   begin seed:=succ(succ(seed)); horrible:=seed end;

begin
{$ifNdef DoLater}
   seed:=F;
   evar:=[nasty..horrible];
   { Values could be [E..G]    text order
                     [G..H]    reverse order
                     [E..H]    simultaneous
                     or other or not defined }
   WrLn('X-6.7.1-12');
   WrLn(' EVAL ORDER OF (. A..B .) IS ');
   if evar = [E..G] then
      WrLn('AB')
   else if evar = [G..H] then
      WrLn('BA')
   else if evar = [E..H] then
      WrLn('SIMULTANEOUS')
   else
      WrLn('UNKNOWN');
   WrLn(' IMPL****')
{$endif}
end;

{TEST 6.7.1-13, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 3}

{: This test contains an implementation-dependency in the order of
   evaluation of member-designators of a set-constructor. }
{V3.1: New test. }

procedure t6p7p1d13;
const min=0; max=15;
type
   IT      = min..max;
var
   evar : set of IT;
   seed,i : IT;
   etab : array[IT] of IT;

   function horrible:IT;
   begin horrible:=succ(seed); seed:=pred(seed) end;

begin
{$ifNdef DoLater}
   for i:=min to max do etab[i]:=i;
   seed:=7;
   evar:=[seed,etab[horrible]];
   { Values could be [7,8]    text order
                     [6,8]    reverse order
                     or other or not defined. }
   WrLn(' IMPLEMENTATION DEPENDENT...6.7.1-13')
{$endif}
end;
{TEST 6.7.1-14, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 3}

{: This program determines the order of evaluation of the
   expressions of a set-constructor. }
{V3.1: New test. }

procedure t6p7p1d14;
var
   st: packed array [ 1 .. 2 ] of char;
   count: 1 .. 3;
   x: set of 0 .. 2;

function sideeffect(c: char; i: integer): integer;
   begin
   st[count] := c;
   count := count + 1;
   sideeffect := i;
   end;
begin
{$ifNdef DoLater}
   count := 1;
   st := '  ';
   WrLn('X-6.7.1-14');
   WrLn(' EVAL ORDER OF (. A .. B .) IS ');
   x := [sideeffect('A',0) .. sideeffect('B',1)];
   WrLn( st );
   WrLn(' IMPL****')
{$endif}
end;
{TEST 6.7.2.3-3, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 4}

{: This program determines if a boolean-expression is partially
   or completely evaluated when the value of the expression is
   determined before the expression is fully evaluated. }
{V3.1: Reclassified from IMPLEMENTATIONDEFINED. }

procedure t6p7p2p3d3;
var
   a:boolean;
   k,l:integer;

function sideeffect(var i:integer; b:boolean):boolean;
begin
   i:=i+1;
   sideeffect:=b
end;

begin
   WrLn('X-6.7.2.3-3');
   WrLn(' SHORT CIRCUIT EVALUATION OF (A AND B)');
   k:=0;
   l:=0;
   a:=sideeffect(k,false) and sideeffect(l,false);
   if (k=0) and (l=1) then
      WrLn(' ONLY SECOND EXPRESSION EVALUATED')
   else
      if (k=1) and (l=0) then
         WrLn(' ONLY FIRST EXPRESSION EVALUATED')
      else
         if(k=1) and (l=1) then
            WrLn(' BOTH EXPRESSIONS EVALUATED')
         else
            WrLn(' INEXPLICABLE RESULT');
   WrLn(' IMPL****')
end;
{TEST 6.7.2.3-4, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 4}

{: This program determines if a boolean-expression is partially
   or completely evaluated when the value of the expression is
   determined before the expression is fully evaluated. }
{V3.1: Reclassified from IMPLEMENTATIONDEFINED. }

procedure t6p7p2p3d4;
var
   a:boolean;
   k,l:integer;

function sideeffect(var i:integer; b:boolean):boolean;
begin
   i:=i+1;
   sideeffect:=b
end;

begin
   WrLn('X-6.7.2.3-4');
   WrLn(' SHORT CIRCUIT EVALUATION OF (A OR B)');
   k:=0;
   l:=0;
   a:=sideeffect(k,true) or sideeffect(l,true);
   if (k=0) and (l=1) then
      WrLn(' ONLY SECOND EXPRESSION EVALUATED')
   else
      if (k=1) and (l=0) then
         WrLn(' ONLY FIRST EXPRESSION EVALUATED')
      else
         if(k=1) and (l=1) then
            WrLn(' BOTH EXPRESSIONS EVALUATED')
         else
            WrLn(' INEXPLICABLE RESULT');
   WrLn(' IMPL****')
end;
{TEST 6.7.3-2, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 5}

{: This program determines the order of evaluation of the
   actual parameters of a function-designator. }
{V3.1: New test. }

procedure t6p7p3d2;
var
   st: packed array [ 1 .. 4 ] of char;
   count: 1 .. 5;
   x: integer;

function sideeffect(c: char; i: integer): integer;
   begin
   st[count] := c;
   count := count + 1;
   sideeffect := i;
   end;
function f(i, j: integer): integer;
   begin
   f := i + j
   end;
begin
   count := 1;
   st := '    ';
   WrLn('X-6.7.3-2');
   WrLn(' EVAL ORDER OF F(F(A,B),F(C,D)) IS ');
   x := f(f(sideeffect('A',0),sideeffect('B',1)),
          f(sideeffect('C',0),sideeffect('D',1)));
   WrLn( st );
   WrLn(' IMPL****')
end;
{TEST 6.8.2.2-1, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 6}

{: This program determines whether selection of a variable involving
   the indexing of an array occurs before or after the evaluation
   of the expression in an assignment-statement. }
{V3.1: Reclassified from IMPLEMENTATIONDEFINED. }

procedure t6p8p2p2d1;
var
   i : integer;
   a : array[1..3] of integer;
function sideeffect(var i:integer) : integer;
begin
   i:=i+1;
   sideeffect:=i
end;

begin
   WrLn('X-6.8.2.2-1');
   WrLn(' BINDING ORDER (A[I] := EXPRESSION)');
   i:=1;
   a[1]:=0;
   a[2]:=0;
   a[i]:=sideeffect(i);
   if a[1]=2 then
      WrLn(' SELECTION THEN EVALUATION')
   else
      if a[2]=2 then
         WrLn(' EVALUATION THEN SELECTION');
   WrLn(' IMPL****')
end;
{TEST 6.8.2.2-2, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 6}

{: This program determines whether selection of a variable involving
   the dereferencing of a pointer occurs before or after the
   evaluation of the expression in an assignment-statement. }
{V3.1: Reclassified from IMPLEMENTATIONDEFINED. }

procedure t6p8p2p2d2;
type
   poynter = ^rekord;
   rekord=record
            a : integer;
            b : boolean;
            link : poynter
         end;
var
   temp, ptr : poynter;
function sideeffect(var p : poynter) : integer;
begin
   p:=p^.link;
   sideeffect:=2
end;

begin
   WrLn('X-6.8.2.2-2');
   WrLn(' BINDING ORDER (P^ := EXPRESSION)');
   new(ptr);
   ptr^.a:=1;
   ptr^.b:=true;
   new(temp);
   ptr^.link:=temp;
   temp^.a:=0;
   temp^.b:=false;
   temp:=ptr;
   ptr^.a:=sideeffect(ptr);
   if temp^.a=2 then
      WrLn(' SELECTION THEN EVALUATION')
   else
      if temp^.link^.a=2 then
         WrLn(' EVALUATION THEN SELECTION');
   WrLn(' IMPL****')
end;
{TEST 6.8.2.3-2, CLASS=IMPLEMENTATIONDEPENDENT, NUMBER= 7}

{: This program determines the order of evaluation of the actual
   parameters in a procedure statement. }
{V3.1: Reclassified from IMPLEMENTATIONDEFINED. }

procedure t6p8p2p3d2;
var
   streng : packed array[1..3] of char;
   i      : integer;
function sideeffect(c : char) : integer;
begin
   streng[i] := c;
   i := i + 1;
   sideeffect := i
end;
procedure order(p,q,r : integer);
begin
   if streng = 'ABC' then
      WrLn(' ACTUAL PARAMETERS EVALUATED IN FORWARD ORDER')
   else
      if streng = 'CBA' then
         WrLn(' ACTUAL PARAMETERS EVALUATED IN REVERSE ORDER')
      else
         WrLn(' ORDER OF ACTUAL PARAMETER EVALUATION UNKNOWN')
end;
begin
   WrLn('X-6.8.2.3-2');
   i := 1;
   order(sideeffect('A'),sideeffect('B'),sideeffect('C'));
   WrLn(' IMPL****')
end;

begin
  t6p7p1d3;
  t6p7p1d4;
  t6p7p1d5;
  t6p7p1d15;
  t6p7p3d1;
  t6p8p3p2d1;
  t6p8p3p2d2;
  t6p8p3p4d2;
  t6p8p3p5d12;
  t6p8p3p5d13;
  t6p8p3p5d14;
  t6p8p3p5d15;
  t6p8p3p7d4;
  t6p8p3p8d3;
  (*** File io!
  //t6p8p3p9d20;
  //t6p8p3p10d7;
  //t6p9p1d7;
  //t6p9p2d2;
  //t6p9p3d3;
  //t6p9p4d2;
  (***)

  //t6p1p7d15;      // why not!!!
  t6p1p9d5;
  t6p4p2p2d10;
  t6p4p2p2d11;
  t6p7p2p2d17;
  t6p5p3p2d6;
  //t6p7p1d11;      // why not!!!
  t6p7p1d12;
  t6p7p1d13;
  t6p7p1d14;
  t6p7p2p3d3;
  t6p7p2p3d4;
  t6p7p3d2;
  t6p8p2p2d1;
  t6p8p2p2d2;
  t6p8p2p3d2;
end.

