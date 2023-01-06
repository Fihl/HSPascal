Program RsrcTest;

//  http://HSPascal.Fihl.net
//  Christen@Fihl.net
//

Uses
  HSFormUtils, HSUtils, Window, Form, Font, Menu, Rect, Event, SysEvent,
  List, SystemMgr, DataMgr, Control, MemoryMgr, StringMgr, Field;

{$R Tbmp03e8.bin}
{$ApplName RsrcTest,RTst} //Unregistered "RTst"

Resource
  MenuRes=(ResMBAR,,
    (ResMPUL,(6,14,75,9),(4,0,31,12),'File',
      MenuQuit=(,'X','Exit')
    )
  );
  MainForm=(ResTFRM,1000,(0,0,160,160),0,0,MenuRes,  //LTWH, Default, Help, Menu
    (FormTitle,'RsrcTest'),
    But12345=(FormButton,, (10,20,50,15), ,,,'=12345'),
    Fld1=(FormField,,(80,20,75,15),,20,stdFont),
    But2=(FormCheckBox,,(10,40,60,15),,,,'CheckBox'),
    Fld2=(FormField,,(80,40,75,15),,20,boldFont),
    (FormPushButton,,(10,80,50,13),,stdFont,,'PushButton'),
    (FormGadget,,,(80,100,20,20)),
    (FormGraffitiStateIndicator,(150,150)),

    put=(FormPopUpTrigger,,(80,1,40,12),,,,'PopupTrigger'), //1111
    lst=(FormList,,(80,1,40,33),,boldFont,('One','Two','Three','Four','Five')), //1112
    xx3=(FormPopupList,put,lst),
    (FormLabel,,(10,140),,largeFont,'Hello HSPascal'),
    (FormBitmap,,(10,110),1000)
  );
  xxx=(ResTSTL,$1234,'X',('1','22','333','4444'));

Var
  DoStop: Boolean;
  MyMenu: MenuBarPtr;

//Does use "much" stack space! (About 500 bytes per itteration)
Function Reverse(Const S: String): String;
var N: Integer;
begin
  N:=Length(S);
  if N>1 then Reverse:=Copy(S,N,1) + Reverse( Copy(S,1,N-1) )
  else Reverse:=S
end;

Function Fac(N: Longint): Longint;
begin
  if N>1 then Fac:=N*Fac(N-1)
  else Fac:=1;
end;

Function MainFormHandleEventPascal(var Event: EventType): Boolean;
Var
  N: Integer;
  PForm: FormPtr;
  Handled : Boolean;
  S: String;
  L: Longint;
begin
  Handled:=True;
  PForm := FrmGetActiveForm;
  with Event do
  case eType of
  frmOpenEvent: //Main Form
    begin
      FrmDrawForm(FrmGetActiveForm);
    end;
  ctlSelectEvent: //Control button
    case Data.CtlEnter.ControlID of
    But12345:
      begin
        // asm trap #8 end;
        //SetFieldText(fld,'123');
        S2Field(Fld1,'12345'); //SetFieldText(Fld,'1234');
      end;
      But2:
        begin
          //asm trap #8 end;
          S:=Field2S(Fld1);
          L:=s2i(S);
          if (L>0) and (L<=13) then S:='Fac='+l2s(Fac(L))
          else
            if data.ctlSelect.on then
              S:=Reverse(Copy(S,1,10)); //Max 10 chars!
          S2Field(Fld2,S); //SetFieldText(Fld,'1234');
        end;
        else Handled:=False;
      end;
  menuEvent:
    begin
      Case Data.Menu.ItemID of
        MenuQuit:  DoStop:=True;
      end;
    end;
  popSelectEvent:
    begin
      case data.popSelect.ListID of
      lst: begin
             S:=LstGetSelectionText(data.popSelect.pList^,data.popSelect.Selection);
             S2Field(Fld1,S);
           end;
      else S2Field(Fld1,'Unknown:'+i2s(data.popSelect.ListID));
      end;
    end;
  else Handled:=False;
  end;
  MainFormHandleEventPascal:=Handled;
end;
Procedure MainFormHandleEvent; Assembler;
asm
  clr.w   -(sp)                        //Room for result
  move.l  8(a6),-(sp)                  //EventPtr
  bsr     MainFormHandleEventPascal    //Call real Pascal-style function
  move.b  (sp)+,d0                     //Get result into D0
end;


Function HandleEvent(var Event: EventType): Boolean;
var
  PForm: FormPtr;
begin
  HandleEvent:=True;
  with Event do
    Case eType of
      frmLoadEvent:
        begin
          PForm:=FrmInitForm(data.frmLoad.FormID);
          FrmSetActiveForm(PForm); //Load the Form resource
          FrmSetEventHandler(PForm,@MainFormHandleEvent);
          //FrmSetEventHandlerNONE(PForm); //Is in Form.pas
        end;
      appStopEvent: DoStop:=True;
      else HandleEvent:=False;
    end;
end;

Procedure Main;
var
  Event: EventType;
  Error: UInt16;
begin
  FrmGotoForm(MainForm);
  Repeat
    EvtGetEvent(Event, evtWaitForever);
    if SysHandleEvent(Event) then CONTINUE;
    if MenuHandleEvent(MyMenu,Event,Error) then CONTINUE;
    if FrmDispatchEvent(Event) then CONTINUE;
    if HandleEvent(Event) then CONTINUE;
  Until DoStop;
  FrmCloseAllForms;
end;

begin
  Main;
end.
