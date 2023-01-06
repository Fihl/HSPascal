unit HSSys3;

{ By Christen Fihl                     }
{ Copyright (C) 1990,2001 Christen Fihl}

interface

{$MaxString 63}
Const MaxString=63;

(*Types Knowledgebase #1544
  Byte     = UInt8   = 0..255
  UChar    = UInt8   = 0..255
  SByte    = Int8    = -128..127
  Int      = Int16   = -32768..32767
  SWord    = Int16
  Short    = Int16
  UShort   = UInt16  = 0..65535
  UInt     = UInt16
  Word     = UInt16
  Long     = Int32   = 0..2147483648
  SDWord   = Int32
  ULong    = UInt32  = 0..4294967296
  DWord    = UInt32
  Ptr      = MemPtr
  VoidPtr  = MemPtr
  Handle   = MemHandle
  VoidHand = MemHandle
*)

Type
  //UChar    = Byte;
  //SByte    = ShortInt;
  //Int      = SmallInt;
  //SWord    = SmallInt;
  //Short    = SmallInt;
  //UShort   = SmallInt;   //!
  //UInt     = SmallInt;
  //Word     = SmallInt;
  //Long     = Longint;
  //SDWord   = Longint;
  //ULong    = Longint;    //!
  //DWord    = Longint;

  UInt8    = Byte;
  Int8     = ShortInt;
  Int16    = SmallInt;
  UInt16   = SmallInt;
  Int32    = LongInt;
  UInt32   = LongInt;

  Double   = Array[0..1] of Longint; //Not supported as buildin type. Float is buildin

  MemPtr   = Pointer;
  MemHandle = ^Pointer;

  Ptr      = Pointer;
  VoidPtr  = Pointer;
  Handle   = MemHandle;
  VoidHand = MemHandle;

  PUInt8    = ^UInt8;
  PInt8     = ^Int8;
  PInt16    = ^Int16;
  PUInt16   = ^UInt16;
  PInt32    = ^Int32;
  PUInt32   = ^UInt32;

//  SBytePtr = ^SByte;
  BytePtr  = ^Byte;
//  SWordPtr = ^SWord;
//  WordPtr  = ^Word;
//  UInt16Ptr= ^Short;
//  SDWordPtr= ^SDWord;
//  DWordPtr = ^DWord;

  BooleanPtr = ^Boolean;
  CharPtr    = ^Char;
//  SCharPtr   = ^SChar;
//  UCharPtr   = ^UChar;
//  WCharPtr   = ^WChar;
//  ShortPtr   = ^Short;
//  UShortPtr  = ^UShort;
  //IntPtr     = ^Int;
  //UIntPtr    = ^UInt;
  //LongPtr    = ^Long;
  //ULongPtr   = ^ULong;

  WChar      = UInt16;          // 'wide' int'l character type.
  Err        = UInt16;
  LocalID    = UInt32;          // local (card relative) chunk ID
  Coord      = Int16;           // screen/window coordinate

  PChar      = ^Char;

implementation

end.

