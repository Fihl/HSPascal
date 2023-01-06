Unit PackerIO;
{$I-,A-}

interface

(* Zip layout ***************************************************************)
Type
  tID= array[1..4] of Char;		{'PK'#n#m}
  tLocalZipHdr = record
    zlVersionNeededToExtract: array[0..1] of byte;
    zlGeneralPurposeBits: word;
    zlCompMode: word;
    zlLastModTime: word;
    zlLastModDate: word;
    zlCrc32: Longint;
    zlCompressedSize: Longint;
    zlUncompressedSize: Longint;
    zlFileNameLength: word;
    zlExtraFieldLength: word;
  end;

  tCentralZipHdr = record
    zcVersionMadeBy: array[0..1] of byte;
    zcLocal: tLocalZipHdr;
    zcCommentLength: word;
    zcDiskNumStart: word;
    zcInternAttr: word;
    zcExtrnAttr: Longint;
    zcLocalHdrOffset: Longint;
  end;

  tEndZipHdr = Record
    zeCntDisk: word;
    zeNoDiskWithCentral: word;
    zeNoEntriesCentral: word;
    zeTotEntriesCentral: word;
    zeSizeCentral: Longint;
    zeOffsetStartCentral: Longint;
    zeCommentLength: word;
  end;

Const
  LREC_SIZE  =  26;   (* lengths of local file headers, central *)
  CREC_SIZE  =  42;   (*  directory headers, and the end-of-    *)
  ECREC_SIZE =  18;   (*  central-dir record, respectively      *)

  CentralZipID:	tID='PK'#1#2;
  LocalZipID:	tID='PK'#3#4;
  EndZipID:	tID='PK'#5#6;

  zSTORED	= 0;		(* compression methods *)
  zSHRUNK	= 1;
  zREDUCED1	= 2;
  zREDUCED2	= 3;
  zREDUCED3	= 4;
  zREDUCED4	= 5;
  zIMPLODED	= 6;
  zTOKENIZED	= 7;
  zDEFLATED	= 8;
  zNUM_METHODS	= 9;

Const
  CompMeth: array[0..zNUM_METHODS-1,1..9] of char=(
  'Stored   ',
  'Shrunk   ',
  'Reduced  ',
  'Reduced2 ',
  'Reduced3 ',
  'Reduced4 ',
  'Imploded ',
  'Tokenized',
  'Deflated ');
  

(* Arc layout ***************************************************************)
Const
  arcmarc    = 26;              { special archive marker }
  arcver     = 9;               { max archive header version code }

type
  BufArray    = Array[1.. 565000] of Byte;	{Big array} /////////////////////
  BufPtr      = ^BufArray;
  tArcRec = Record
    ArcMark	:  Byte;
    ArcType	:  Byte;
    ArcName	:  Array[1..13] of Byte;
    ArcSize	:  LongInt;
    ArcDate	:  Word;
    ArcTime	:  Word;
    ArcCRC	:  Word;
    ArcLen	:  LongInt;
    ArcMaxBits	:  Byte;		{Only there if ArcType=8}
  end;

(* Local buffer layout *****************************************************)
Type
  eArcType=(eArc,eZip);
  tIORec = Record			{Internal file IO rec}
    ioPackFile	: File;
    ioComprType	: Byte;
    ioName	: String;
    ioInfo	: String[63];
    ioSize	: LongInt;
    ioSizeReal	: LongInt;
    ioDate	: Word;
    ioTime	: Word;
    ioCRC		: Word;
    ioCRC32	: Longint;
    ioMaxBits	: Byte;
    ioCurFileNo,
    ioMaxFileNo	: Integer;
    {ZipOffsetEnd,			{Current offset for End mark}
    ioZipOffsetDir,			{Current offset for next Dir}
    ioZipOffsetFil: Longint;		{Current offset for next File}
    case ioWhat: eArcType of
    eZip: (ioEndZipHdr: tEndZipHdr;
           ioGeneralPurposeBits: word;
           );
  End;

Const
   CrcTab : array [0..255] of Word = { Table for CRC calculation   }
  ( $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);

  CrcTab32 : array [0..255] of LongWord= //Longint = { Table for CRC calculation   }
  ( $00000000, $77073096, $ee0e612c, $990951ba, $076dc419,
    $706af48f, $e963a535, $9e6495a3, $0edb8832, $79dcb8a4,
    $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07,
    $90bf1d91, $1db71064, $6ab020f2, $f3b97148, $84be41de,
    $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7, $136c9856,
    $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9,
    $fa0f3d63, $8d080df5, $3b6e20c8, $4c69105e, $d56041e4,
    $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
    $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3,
    $45df5c75, $dcd60dcf, $abd13d59, $26d930ac, $51de003a,
    $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599,
    $b8bda50f, $2802b89e, $5f058808, $c60cd9b2, $b10be924,
    $2f6f7c87, $58684c11, $c1611dab, $b6662d3d, $76dc4190,
    $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f,
    $9fbfe4a5, $e8b8d433, $7807c9a2, $0f00f934, $9609a88e,
    $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
    $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed,
    $1b01a57b, $8208f4c1, $f50fc457, $65b0d9c6, $12b7e950,
    $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3,
    $fbd44c65, $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2,
    $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb, $4369e96a,
    $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5,
    $aa0a4c5f, $dd0d7cc9, $5005713c, $270241aa, $be0b1010,
    $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
    $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17,
    $2eb40d81, $b7bd5c3b, $c0ba6cad, $edb88320, $9abfb3b6,
    $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615,
    $73dc1683, $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8,
    $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1, $f00f9344,
    $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb,
    $196c3671, $6e6b06e7, $fed41b76, $89d32be0, $10da7a5a,
    $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
    $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1,
    $a6bc5767, $3fb506dd, $48b2364b, $d80d2bda, $af0a1b4c,
    $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef,
    $4669be79, $cb61b38c, $bc66831a, $256fd2a0, $5268e236,
    $cc0c7795, $bb0b4703, $220216b9, $5505262f, $c5ba3bbe,
    $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31,
    $2cd99e8b, $5bdeae1d, $9b64c2b0, $ec63f226, $756aa39c,
    $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
    $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b,
    $e5d5be0d, $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242,
    $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1,
    $18b74777, $88085ae6, $ff0f6a70, $66063bca, $11010b5c,
    $8f659eff, $f862ae69, $616bffd3, $166ccf45, $a00ae278,
    $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7,
    $4969474d, $3e6e77db, $aed16a4a, $d9d65adc, $40df0b66,
    $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
    $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605,
    $cdd70693, $54de5729, $23d967bf, $b3667a2e, $c4614ab8,
    $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b,
    $2d02ef8d);

Const
  DLE = $90;

Function  OpenPackFile(var IORec: tIORec; fName: String): Boolean;
Function  ClosePackFile(var IORec: tIORec): Boolean;
Function  NextPackFile(var IORec: tIORec): Boolean;
Function  PackIoRead(var IORec: tIORec; var Data; Size: Longint): Boolean;
Procedure InitHdr(var Hdr: tIORec);

implementation

Function ReadID(var IORec: tIORec; Pos: Longint; var Wanted: tID): Boolean;
var Buf: tID; n: Integer;
begin
  ReadID:=False;
  with IORec do
    case ioWhat of
    eArc: EXIT;
    eZip: begin
            Seek(ioPackFile,Pos);
            BlockRead(ioPackFile,Buf,SizeOf(Buf),n);
            if n<>SizeOf(Buf) then EXIT;
            if Buf<>Wanted then EXIT;
          end;
    end;
  ReadID:=True;
end;

Function DoZipString(var IORec: tIORec; Size: Word; var Buf: String): Boolean;
var n: Integer;
begin
  DoZipString:=False;
  with IORec do begin
    SetLength(Buf,Size); if Size>255 then EXIT;
    if Size>0 then begin
      BlockRead(ioPackFile,Buf[1],Size,n); if n<>Size then EXIT;
    end;
  end;
  DoZipString:=True;
end;


Function  PackIoRead(var IORec: tIORec; var Data; Size: Longint): Boolean;
var Buf: tLocalZipHdr; n: Integer; S: String;
begin
  PackIoRead:=False;
  With IORec do begin
    case ioWhat of
    eArc: EXIT; {@@@}
    eZip: begin
            if not ReadID(IORec,ioZipOffsetFil,LocalZipID) then EXIT;
            BlockRead(ioPackFile,Buf,SizeOf(Buf),n); if n<>SizeOf(Buf) then EXIT;
            if not DoZipString(IORec,Buf.zlFileNameLength,S) then EXIT;
            if not DoZipString(IORec,Buf.zlExtraFieldLength,S) then EXIT;
            BlockRead(ioPackFile,Data,Size,n); if n<>Size then EXIT;
          end;
    end;
  end;
  PackIoRead:=True;
end;

Procedure InitHdr(var Hdr: tIORec);
begin
  with Hdr do begin
    FillChar(Hdr,SizeOf(Hdr),0);
    ioWhat:=eArc;
  end;
end;

Function OpenPackFile(var IORec: tIORec; fName: String): Boolean;
var
  n: Integer;
  L,L2: Longint;
  Buf: record
         case integer of
         0: (ArcID: Array[1..2] of Char);
         1: (ZipID: Array[1..4] of Char;
             ZipRec: tEndZipHdr);		{Makes the biggest variant!}
       end;
begin
  OpenPackFile:=False;
  With IORec do begin
    FillChar(IORec,SizeOf(IORec),0);
    FileMode := 0; Assign(ioPackFile,fName); Reset(ioPackFile,1);
    if IOResult<>0 then EXIT;
    blockread(ioPackFile,Buf,SizeOf(Buf),n);
    if SizeOf(Buf)<>n then EXIT;
    if Buf.ArcID=#$1A#0 then ioWhat:=eArc
    else
      if Buf.ZipID=LocalZipID then ioWhat:=eZip else EXIT;
    ioMaxFileNo:=MaxInt;
    if ioWhat=eZip then
      with ioEndZipHdr do begin	(*  Function find_end_central_dir() *)
        L:=FileSize(ioPackFile)-SizeOf(Buf);
        L2:=L-66000; if L2<0 then L2:=0;	{EndMark in upper app 64 KByte}
        repeat
          Seek(ioPackFile,L); BlockRead(ioPackFile,Buf,SizeOf(Buf),n);
          if Buf.ZipID=EndZipID then begin
            ioEndZipHdr:=Buf.ZipRec; L:=-1;
          end else dec(L);
        until L<=L2;
        if L=L2 then EXIT;	{Not found endmark}
        { CurfileNo:=0; {} ioMaxFileNo:=ioEndZipHdr.zeNoEntriesCentral;
        {zeTotEntriesCentral}
        ioZipOffsetDir:=zeOffsetStartCentral;
      end;
  end;
  OpenPackFile:=True;
end;

Function NextPackFile(var IORec: tIORec): Boolean;
var Buf: tCentralZipHdr; n: Integer; S: String;
begin
  NextPackFile:=False;
  with IORec do
    case ioWhat of
    eArc: EXIT;
    eZip: if ioCurFileNo>=ioMaxFileNo then EXIT
          else with Buf,zcLocal do begin
            inc(ioCurFileNo);
            if not ReadID(IORec,ioZipOffsetDir,CentralZipID) then EXIT;
            inc(ioZipOffsetDir,SizeOf(tID));
            BlockRead(ioPackFile,Buf,SizeOf(Buf),n);
            inc(ioZipOffsetDir,SizeOf(Buf));
            if n<>SizeOf(Buf) then EXIT;
            if not DoZipString(IORec,zlFileNameLength,S) then EXIT;
            inc(ioZipOffsetDir,zlFileNameLength);
            ioName	:= S;
            if not DoZipString(IORec,zlExtraFieldLength,S) then EXIT;
            inc(ioZipOffsetDir,zlExtraFieldLength);
            ioInfo	:= S;
            ioComprType	:= zlCompMode;
            ioSize	:= zlCompressedSize;
            ioSizeReal	:= zlUncompressedSize; {zlExtraFieldLength;}
            ioDate	:= zlLastModDate;
            ioTime	:= zlLastModTime;
            ioCRC32	:= zlCrc32;
            ioZipOffsetFil:=zcLocalHdrOffset;
            ioGeneralPurposeBits:=zlGeneralPurposeBits;
          end;
    end;
  NextPackFile:=True;
end;

Function ClosePackFile(var IORec: tIORec): Boolean;
begin
  Close(IORec.ioPackFile);
  ClosePackFile:=IOResult=0;
end;

end.
