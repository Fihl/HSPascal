program HSPascal;

uses
  Windows,
  Forms,
  ComCtrls,
  SysUtils,
  HspcUI,
  GlobalUI,
  Util,
  DebugFrm,
  AboutFrm,
  Buildin,
  SplashFrm,
  HelpFrm;

{$R *.RES}

begin
  //Win32Platform:=1; //VER_PLATFORM_WIN32_NT;
  //Win32MajorVersion:=4;

  //Must exists, else SearchPath not set to $(DELPHI)\Source\Vcl and HackRichEdit defined
  //if ComCtrlsCheck then;   {xifdef HackRichEdit}
  SplashForm := TSplashForm.Create(Application);
  SplashForm.Splash(1000);

  Application.Initialize;
  Application.CreateForm(TUI, UI);
  Application.CreateForm(TFormDebug, FormDebug);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
  SplashForm.Free;
end.

