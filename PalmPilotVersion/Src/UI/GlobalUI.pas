unit GlobalUI;

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

Const
  HSPasName     = 'HSPascal';
  mnuNew        = 101;
  mnuOpen       = 102;
  mnuClose      = 103;
  mnuSave       = 104;
  mnuSaveAs     = 105;
  mnuSaveAll    = 106;

  mnuPrintSetup = 110;
  mnuPrint      = 111;
  mnuExit       = 199;

  mnuCut        = 201;
  mnuCopy       = 202;
  mnuPaste      = 203;
  mnuSelectAll  = 204;

  mnuFind       = 301;
  mnuFindFilesX = 302;
  mnuReplace    = 303;
  mnuFindNext   = 304;
  mnuFindIncX    = 305;
  mnuGotoLine   = 306;

  mnuCompile    = 401;
  mnuUpload     = 402;
  mnuInfo       = 403;
  mnuOptions    = 404;
  mnuOpenF10    = 405;
  mnuDebugWin   = 406;

  mnuHelpF1     = 500;
  mnuHelpPDF1   = 501; //501..509
  mnuHelpPDF3   = 503; //#3 is last document from Palm web
  mnuHelpPDF9   = 509;
  mnuHelpAbout  = 510;

  mnuExitF4     = 901;

  //Psudo menues
  mnuBackSpace  = 1001; 
  mnuTabKey     = 1002;
  mnuEnterKey   = 1003;
  mnuEnterOpen  = 1004;

  sbUI_Line    = 0;
  sbUI_Modif   = 1;
  sbUI_Info    = 2;

implementation

end.
 