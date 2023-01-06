Program AESLibTest1;
{$ApplName AESLibTest1,HSP9}

Uses AESLib, ErrorBase, Crt;

Var
  Error: err;
  libRefNum: UInt16;
  key,plaintext1,plaintext2,ciphertext: AESblk16;
  ctx: ^aes_ctx;
  rval: aes_rval;

procedure AEStest;
var N: Integer;
begin
  Error := AESLib_OpenLibrary(libRefNum);
  if Error<>0 then EXIT;
  New(ctx);
  FillChar(ctx^,sizeof(ctx^),0);
  plaintext1:= 'Plain text here';
  key:=        'Kilroy was here.';
  rval := AESLibEncKey(libRefNum, key, 16, ctx^);
  for N:=1 to 10000 do //Speed test!
    rval := AESLibEncBlk(libRefNum, plaintext1, ciphertext, ctx^);
  Writeln('Plain1:  '+plaintext1);
  Writeln('Cipher:  '+ciphertext);

  rval := AESLibDecKey(libRefNum, key, 16, ctx^);
  rval := AESLibDecBlk(libRefNum, ciphertext, plaintext2, ctx^);
  Writeln('Plain2:  '+plaintext2);
  Error := AESLib_CloseLibrary(libRefNum);
  Dispose(ctx);
end;

begin
  AEStest;
  Delay(3000);
end.

