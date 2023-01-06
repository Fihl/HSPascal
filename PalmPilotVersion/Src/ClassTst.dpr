program ClassTst;
{$APPTYPE CONSOLE}

Type
  TFigure = class
    procedure Draw; virtual;
  end;
  TRectangle = class(TFigure)
    procedure Draw; override;
  end;
  TEllipse = class(TFigure)
    procedure Draw; override;
  end;

procedure TFigure.Draw;
begin
end;
procedure Trectangle.Draw;
begin
end;
procedure TEllipse.Draw;
begin
end;

var
  Figure: TFigure;
begin
  Figure := TRectangle.Create;
  Figure.Draw;  // calls TRectangle.Draw
  Figure.Destroy;
  Figure := TEllipse.Create;
  Figure.Draw;  // calls TEllipse.Draw
  Figure.Destroy;
end.

{ Virtual method table entries }

Const
  vmtSelfPtr           = -76;
  vmtIntfTable         = -72;
  vmtAutoTable         = -68;
  vmtInitTable         = -64;
  vmtTypeInfo          = -60;
  vmtFieldTable        = -56;
  vmtMethodTable       = -52;
  vmtDynamicTable      = -48;
  vmtClassName         = -44;
  vmtInstanceSize      = -40;
  vmtParent            = -36;
  vmtSafeCallException = -32;
  vmtAfterConstruction = -28;
  vmtBeforeDestruction = -24;
  vmtDispatch          = -20;
  vmtDefaultHandler    = -16;
  vmtNewInstance       = -12;
  vmtFreeInstance      = -8;
  vmtDestroy           = -4;

  vmtQueryInterface    = 0;
  vmtAddRef            = 4;
  vmtRelease           = 8;
  vmtCreateObject      = 12;

type
  TObject = class;
  TClass = class of TObject;

  TMethod = record
    Code, Data: Pointer;
  end;

{ TObject.Dispatch accepts any data type as its Message parameter.  The
  first 2 bytes of the data are taken as the message id to search for
  in the object's message methods.  TDispatchMessage is an example of
  such a structure with a word field for the message id.
}
  TDispatchMessage = record
    MsgID: Word;
  end;

  TObject = class
    constructor Create;
    procedure Free;
    class function InitInstance(Instance: Pointer): TObject;
    procedure CleanupInstance;
    function ClassType: TClass;
    class function ClassName: ShortString;
    class function ClassNameIs(const Name: string): Boolean;
    class function ClassParent: TClass;
    class function ClassInfo: Pointer;
    class function InstanceSize: Longint;
    class function InheritsFrom(AClass: TClass): Boolean;
    class function MethodAddress(const Name: ShortString): Pointer;
    class function MethodName(Address: Pointer): ShortString;
    function FieldAddress(const Name: ShortString): Pointer;
    function GetInterface(const IID: TGUID; out Obj): Boolean;
    class function GetInterfaceEntry(const IID: TGUID): PInterfaceEntry;
    class function GetInterfaceTable: PInterfaceTable;
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; virtual;
    procedure AfterConstruction; virtual;
    procedure BeforeDestruction; virtual;
    procedure Dispatch(var Message); virtual;
    procedure DefaultHandler(var Message); virtual;
    class function NewInstance: TObject; virtual;
    procedure FreeInstance; virtual;
    destructor Destroy; virtual;
  end;

var
  DispCallByIDProc: Pointer;
  ExceptProc: Pointer;    { Unhandled exception handler }
  ErrorProc: procedure (ErrorCode: Byte; ErrorAddr: Pointer);     { Error handler procedure }
  ExceptClsProc: Pointer; { Map an OS Exception to a Delphi class reference }
  ExceptObjProc: Pointer; { Map an OS Exception to a Delphi class instance }
  RaiseExceptionProc: Pointer;
  RTLUnwindProc: Pointer;
  ExceptionClass: TClass; { Exception base class (must be Exception) }
  SafeCallErrorProc: TSafeCallErrorProc; { Safecall error handler }
  AssertErrorProc: TAssertErrorProc; { Assertion error handler }
  ExitProcessProc: procedure; { Hook to be called just before the process actually exits }
  AbstractErrorProc: procedure; { Abstract method error handler }
  HPrevInst: LongWord deprecated;    { Handle of previous instance - HPrevInst cannot be tested for multiple instances in Win32}
  MainInstance: LongWord;   { Handle of the main(.EXE) HInstance }
  MainThreadID: LongWord;   { ThreadID of thread that module was initialized in }
  IsLibrary: Boolean;       { True if module is a DLL }
  CmdShow: Integer platform;       { CmdShow parameter for CreateWindow }
  CmdLine: PChar platform;         { Command line pointer }
  InitProc: Pointer;        { Last installed initialization procedure }
  ExitCode: Integer = 0;    { Program result }
  ExitProc: Pointer;        { Last installed exit procedure }
  ErrorAddr: Pointer = nil; { Address of run-time error }
  RandSeed: Longint = 0;    { Base for random number generator }
  IsConsole: Boolean;       { True if compiled as console app }
  IsMultiThread: Boolean;   { True if more than one thread }
  FileMode: Byte = 2;       { Standard mode for opening files }
  Test8086: Byte;         { CPU family (minus one) See consts below }
  Test8087: Byte = 3;     { assume 80387 FPU or OS supplied FPU emulation }
  TestFDIV: Shortint;     { -1: Flawed Pentium, 0: Not determined, 1: Ok }
  Input: Text;            { Standard input }
  Output: Text;           { Standard output }
  ErrOutput: Text;        { Standard error output }
  envp: PPChar platform;

function _ClassCreate(AClass: TClass; Alloc: Boolean): TObject;
procedure _ClassDestroy(Instance: TObject);
function _AfterConstruction(Instance: TObject): TObject;
function _BeforeDestruction(Instance: TObject; OuterMost: ShortInt): TObject;
function _IsClass(Child: TObject; Parent: TClass): Boolean;
function _AsClass(Child: TObject; Parent: TClass): TObject;

procedure       _ObjSetup;    //tobject.
asm
{       FUNCTION _ObjSetup( self: ^OBJECT; vmt: ^VMT): ^OBJECT; }
{     ->EAX     Pointer to self (possibly nil)  }
{       EDX     Pointer to vmt  (possibly nil)  }
{     <-EAX     Pointer to self                 }
{       EDX     <> 0: an object was allocated   }
{       Z-Flag  Set: failure, Cleared: Success  }

        CMP     EDX,1   { is vmt = 0, indicating a call         }
        JAE     @@skip1 { from a constructor?                   }
        RET                     { return immediately with Z-flag cleared        }

@@skip1:
        PUSH    ECX
        TEST    EAX,EAX { is self already allocated?            }
        JNE     @@noAlloc
        MOV     EAX,[EDX].ovtInstanceSize
        TEST    EAX,EAX
        JE      @@zeroSize
        PUSH    EDX
        CALL    _GetMem
        POP     EDX
        TEST    EAX,EAX
        JZ      @@fail

        {       Zero fill the memory }
        PUSH    EDI
        MOV     ECX,[EDX].ovtInstanceSize
        MOV     EDI,EAX
        PUSH    EAX
        XOR     EAX,EAX
        SHR     ECX,2
        REP     STOSD
        MOV     ECX,[EDX].ovtInstanceSize
        AND     ECX,3
        REP     STOSB
        POP     EAX
        POP     EDI

        MOV     ECX,[EDX].ovtVmtPtrOffs
        TEST    ECX,ECX
        JL      @@skip
        MOV     [EAX+ECX],EDX   { store vmt in object at this offset    }
@@skip:
        TEST    EAX,EAX { clear zero flag                               }
        POP     ECX
        RET

@@fail:
        XOR     EDX,EDX
        POP     ECX
        RET

@@zeroSize:
        XOR     EDX,EDX
        CMP     EAX,1   { clear zero flag - we were successful (kind of) }
        POP     ECX
        RET

@@noAlloc:
        MOV     ECX,[EDX].ovtVmtPtrOffs
        TEST    ECX,ECX
        JL      @@exit
        MOV     [EAX+ECX],EDX   { store vmt in object at this offset    }
@@exit:
        XOR     EDX,EDX { clear allocated flag                  }
        TEST    EAX,EAX { clear zero flag                               }
        POP     ECX
end;

procedure       _ObjCopy;
asm
{       PROCEDURE _ObjCopy( dest, src: ^OBJECT; vmtPtrOff: Longint);    }
{     ->EAX     Pointer to destination          }
{       EDX     Pointer to source               }
{       ECX     Offset of vmt in those objects. }

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EDX
        MOV     EDI,EAX

        LEA     EAX,[EDI+ECX]   { remember pointer to dest vmt pointer  }
        MOV     EDX,[EAX]       { fetch dest vmt pointer        }

        MOV     EBX,[EDX].ovtInstanceSize

        MOV     ECX,EBX { copy size DIV 4 dwords        }
        SHR     ECX,2
        REP     MOVSD

        MOV     ECX,EBX { copy size MOD 4 bytes }
        AND     ECX,3
        REP     MOVSB

        MOV     [EAX],EDX       { restore dest vmt              }

        POP     EDI
        POP     ESI
        POP     EBX
end;

procedure       _Fail;
asm
{       FUNCTION _Fail( self: ^OBJECT; allocFlag:Longint): ^OBJECT;     }
{     ->EAX     Pointer to self (possibly nil)  }
{       EDX     <> 0: Object must be deallocated        }
{     <-EAX     Nil                                     }

        TEST    EDX,EDX
        JE      @@exit  { if no object was allocated, return    }
        CALL    _FreeMem
@@exit:
        XOR     EAX,EAX
end;

function TObject.ClassType: TClass;
begin
  Pointer(Result) := PPointer(Self)^;
end;

class function TObject.ClassName: ShortString;
{$IFDEF PUREPASCAL}
begin
  Result := PShortString(PPointer(Integer(Self) + vmtClassName)^)^;
end;
{$ELSE}
asm
        { ->    EAX VMT                         }
        {       EDX Pointer to result string    }
        PUSH    ESI
        PUSH    EDI
        MOV     EDI,EDX
        MOV     ESI,[EAX].vmtClassName
        XOR     ECX,ECX
        MOV     CL,[ESI]
        INC     ECX
        REP     MOVSB
        POP     EDI
        POP     ESI
end;
{$ENDIF}

class function TObject.ClassNameIs(const Name: string): Boolean;
{$IFDEF PUREPASCAL}
var
  Temp: ShortString;
  I: Byte;
begin
  Result := False;
  Temp := ClassName;
  for I := 0 to Byte(Temp[0]) do
    if Temp[I] <> Name[I] then Exit;
  Result := True;
end;
{$ENDIF}

class function TObject.ClassParent: TClass;
{$IFDEF PUREPASCAL}
begin
  Pointer(Result) := PPointer(Integer(Self) + vmtParent)^;
  if Result <> nil then
    Pointer(Result) := PPointer(Result)^;
end;
{$ELSE}
asm
        MOV     EAX,[EAX].vmtParent
        TEST    EAX,EAX
        JE      @@exit
        MOV     EAX,[EAX]
@@exit:
end;
{$ENDIF}

class function TObject.NewInstance: TObject;
begin
  Result := InitInstance(_GetMem(InstanceSize));
end;

procedure TObject.FreeInstance;
begin
  CleanupInstance;
  _FreeMem(Self);
end;

class function TObject.InstanceSize: Longint;
begin
  Result := PInteger(Integer(Self) + vmtInstanceSize)^;
end;

constructor TObject.Create; <<<<<<<<<<<<<<<<<<<<<
begin
end;

destructor TObject.Destroy; <<<<<<<<<<<<<<<<<<<<<
begin
end;

procedure TObject.Free;
begin
  if Self <> nil then
    Destroy;
end;

class function TObject.InitInstance(Instance: Pointer): TObject;
{$IFDEF PUREPASCAL}
var
  IntfTable: PInterfaceTable;
  ClassPtr: TClass;
  I: Integer;
begin
  FillChar(Instance^, InstanceSize, 0);
  PInteger(Instance)^ := Integer(Self);
  ClassPtr := Self;
  while ClassPtr <> nil do
  begin
    IntfTable := ClassPtr.GetInterfaceTable;
    if IntfTable <> nil then
      for I := 0 to IntfTable.EntryCount-1 do
        with IntfTable.Entries[I] do begin
          if VTable <> nil then
            PInteger(@PChar(Instance)[IOffset])^ := Integer(VTable);
        end;
    ClassPtr := ClassPtr.ClassParent;
  end;
  Result := Instance;
end;
{$ENDIF}

procedure TObject.CleanupInstance;
{$IFDEF PUREPASCAL}
var
  ClassPtr: TClass;
  InitTable: Pointer;
begin
  ClassPtr := ClassType;
  InitTable := PPointer(Integer(ClassPtr) + vmtInitTable)^;
  while (ClassPtr <> nil) and (InitTable <> nil) do
  begin
    _FinalizeRecord(Self, InitTable);
    ClassPtr := ClassPtr.ClassParent;
    if ClassPtr <> nil then
      InitTable := PPointer(Integer(ClassPtr) + vmtInitTable)^;
  end;
end;
{$ENDIF}

function _IsClass(Child: TObject; Parent: TClass): Boolean;
begin
  Result := (Child <> nil) and Child.InheritsFrom(Parent);
end;

function _AsClass(Child: TObject; Parent: TClass): TObject;
{$IFDEF PUREPASCAL}
begin
  Result := Child;
  if not (Child is Parent) then
    Error(reInvalidCast);   // loses return address
end;
{$ENDIF}


procedure       GetDynaMethod;
{       function        GetDynaMethod(vmt: TClass; selector: Smallint) : Pointer;       }
asm
        { ->    EAX     vmt of class            }
        {       SI      dynamic method index    }
        { <-    ESI pointer to routine  }
        {       ZF = 0 if found         }
        {       trashes: EAX, ECX               }

        PUSH    EDI
        XCHG    EAX,ESI
        JMP     @@haveVMT
@@outerLoop:
        MOV     ESI,[ESI]
@@haveVMT:
        MOV     EDI,[ESI].vmtDynamicTable
        TEST    EDI,EDI
        JE      @@parent
        MOVZX   ECX,word ptr [EDI]
        PUSH    ECX
        ADD     EDI,2
        REPNE   SCASW
        JE      @@found
        POP     ECX
@@parent:
        MOV     ESI,[ESI].vmtParent
        TEST    ESI,ESI
        JNE     @@outerLoop
        JMP     @@exit

@@found:
        POP     EAX
        ADD     EAX,EAX
        SUB     EAX,ECX         { this will always clear the Z-flag ! }
        MOV     ESI,[EDI+EAX*2-4]

@@exit:
        POP     EDI
end;

class function TObject.InheritsFrom(AClass: TClass): Boolean;
{$IFDEF PUREPASCAL}
var
  ClassPtr: TClass;
begin
  ClassPtr := Self;
  while (ClassPtr <> nil) and (ClassPtr <> AClass) do
    ClassPtr := PPointer(Integer(ClassPtr) + vmtParent)^;
  Result := ClassPtr = AClass;
end;
{$ENDIF}


class function TObject.ClassInfo: Pointer;
begin
  Result := PPointer(Integer(Self) + vmtTypeInfo)^;
end;

procedure TObject.DefaultHandler(var Message);
begin
end;


procedure TObject.AfterConstruction;
begin
end;

procedure TObject.BeforeDestruction;
begin
end;

procedure TObject.Dispatch(var Message);
asm
    PUSH    ESI
    MOV     SI,[EDX]
    OR      SI,SI
    JE      @@default
    CMP     SI,0C000H
    JAE     @@default
    PUSH    EAX
    MOV     EAX,[EAX]
    CALL    GetDynaMethod
    POP     EAX
    JE      @@default
    MOV     ECX,ESI
    POP     ESI
    JMP     ECX

@@default:
    POP     ESI
    MOV     ECX,[EAX]
    JMP     dword ptr [ECX].vmtDefaultHandler
end;


class function TObject.MethodAddress(const Name: ShortString): Pointer;
asm
        { ->    EAX     Pointer to class        }
        {       EDX     Pointer to name }
        PUSH    EBX
        PUSH    ESI
        PUSH    EDI
        XOR     ECX,ECX
        XOR     EDI,EDI
        MOV     BL,[EDX]
        JMP     @@haveVMT
@@outer:                                { upper 16 bits of ECX are 0 !  }
        MOV     EAX,[EAX]
@@haveVMT:
        MOV     ESI,[EAX].vmtMethodTable
        TEST    ESI,ESI
        JE      @@parent
        MOV     DI,[ESI]                { EDI := method count           }
        ADD     ESI,2
@@inner:                                { upper 16 bits of ECX are 0 !  }
        MOV     CL,[ESI+6]              { compare length of strings     }
        CMP     CL,BL
        JE      @@cmpChar
@@cont:                                 { upper 16 bits of ECX are 0 !  }
        MOV     CX,[ESI]                { fetch length of method desc   }
        ADD     ESI,ECX                 { point ESI to next method      }
        DEC     EDI
        JNZ     @@inner
@@parent:
        MOV     EAX,[EAX].vmtParent     { fetch parent vmt              }
        TEST    EAX,EAX
        JNE     @@outer
        JMP     @@exit                  { return NIL                    }

@@notEqual:
        MOV     BL,[EDX]                { restore BL to length of name  }
        JMP     @@cont

@@cmpChar:                              { upper 16 bits of ECX are 0 !  }
        MOV     CH,0                    { upper 24 bits of ECX are 0 !  }
@@cmpCharLoop:
        MOV     BL,[ESI+ECX+6]          { case insensitive string cmp   }
        XOR     BL,[EDX+ECX+0]          { last char is compared first   }
        AND     BL,$DF
        JNE     @@notEqual
        DEC     ECX                     { ECX serves as counter         }
        JNZ     @@cmpCharLoop

        { found it }
        MOV     EAX,[ESI+2]

@@exit:
        POP     EDI
        POP     ESI
        POP     EBX
end;

function _ClassCreate(AClass: TClass; Alloc: Boolean): TObject;
asm
        { ->    EAX = pointer to VMT      }
        { <-    EAX = pointer to instance }
        PUSH    EDX
        PUSH    ECX
        PUSH    EBX
        TEST    DL,DL
        JL      @@noAlloc
        CALL    dword ptr [EAX].vmtNewInstance
@@noAlloc:
{$IFNDEF PC_MAPPED_EXCEPTIONS}
        XOR     EDX,EDX
        LEA     ECX,[ESP+16]
        MOV     EBX,FS:[EDX]
        MOV     [ECX].TExcFrame.next,EBX
        MOV     [ECX].TExcFrame.hEBP,EBP
        MOV     [ECX].TExcFrame.desc,offset @desc
        MOV     [ECX].TexcFrame.ConstructedObject,EAX   { trick: remember copy to instance }
        MOV     FS:[EDX],ECX
{$ENDIF}
        POP     EBX
        POP     ECX
        POP     EDX
        RET

{$IFNDEF PC_MAPPED_EXCEPTIONS}
@desc:
        JMP     _HandleAnyException

  {       destroy the object                                                      }

        MOV     EAX,[ESP+8+9*4]
        MOV     EAX,[EAX].TExcFrame.ConstructedObject
        TEST    EAX,EAX
        JE      @@skip
        MOV     ECX,[EAX]
        MOV     DL,$81
        PUSH    EAX
        CALL    dword ptr [ECX].vmtDestroy
        POP     EAX
        CALL    _ClassDestroy
@@skip:
  {       reraise the exception   }
        CALL    _RaiseAgain
{$ENDIF}
end;

procedure _ClassDestroy(Instance: TObject);
begin
  Instance.FreeInstance;
end;


function _AfterConstruction(Instance: TObject): TObject;
begin
  Instance.AfterConstruction;
  Result := Instance;
end;

function _BeforeDestruction(Instance: TObject; OuterMost: ShortInt): TObject;
// Must preserve DL on return!
{$IFDEF PUREPASCAL}
begin
  Result := Instance;
  if OuterMost > 0 then Exit;
  Instance.BeforeDestruction;
end;
{$ELSE}
asm
       { ->  EAX  = pointer to instance }
       {      DL  = dealloc flag        }
        TEST    DL,DL
        JG      @@outerMost
        RET
@@outerMost:
        PUSH    EAX
        PUSH    EDX
        MOV     EDX,[EAX]
        CALL    dword ptr [EDX].vmtBeforeDestruction
        POP     EDX
        POP     EAX
end;
{$ENDIF}

