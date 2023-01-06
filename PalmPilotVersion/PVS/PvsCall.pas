Program StrTest;

{$d+}

Uses Crt, Form, Window, StringMgr, hsutils;

resource
  AlertShow = (ResTalt, , , 0, 0, 0, 'Results', '^1 ^2 ^3', 'OK');

var
  S: String;

function IntToString(I: Integer): String;
begin
  IntToString := '123';
end; 

procedure Test;
var
  N: Integer;
  S1: String;
begin
  S1 := IntToString(42);
  Writeln(S);
  Writeln(S1);
  Delay(2000);
  N := frmCustomAlert(AlertShow, 'The answer is ', S1, '.');
  N := frmCustomAlert(AlertShow, 'The answer is ', IntToString(42), '.');
end;

begin
  Test;
end.




Program PvsCall; // Check calling parameters

Uses MemoryMgr, Form, Field, HSUtils;

Function S2Handle: MemHandle;
var  NewH: MemHandle; newp: ^String;
begin
  S2Handle := NewH;  //<<<<<<
end;

Procedure S2Field(FldID: UInt16; Const S: String);
var
  NewH: MemHandle;
begin
  NewH := S2Handle;   // push return value!!!
end;

begin
  S2Field(2000, 'sd')///i2s(123)); /// <<<< does not work!!!!! sp
end.

