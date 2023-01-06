object UI: TUI
  Left = 383
  Top = 219
  Width = 491
  Height = 397
  Caption = 'High Speed Pascal'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 319
    Width = 483
    Height = 2
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Color = clBtnFace
    ParentColor = False
  end
  object pc1: TPageControl
    Left = 0
    Top = 0
    Width = 483
    Height = 319
    Align = alClient
    MultiLine = True
    TabOrder = 0
    TabStop = False
    TabWidth = 100
  end
  object panMemo1: TPanel
    Left = 0
    Top = 321
    Width = 483
    Height = 30
    Align = alBottom
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 481
      Height = 9
      TabStop = False
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
      WantReturns = False
    end
    object sbUI: TStatusBar
      Left = 1
      Top = 10
      Width = 481
      Height = 19
      Panels = <
        item
          Alignment = taCenter
          Width = 50
        end
        item
          Alignment = taCenter
          Width = 70
        end
        item
          Width = 999
        end>
      SimplePanel = False
    end
  end
  object MainMenu1: TMainMenu
    Left = 84
    Top = 186
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Tag = 101
        Caption = '&New'
        OnClick = MenuSelectTag
      end
      object Open1: TMenuItem
        Tag = 102
        Caption = '&Open...'
        ShortCut = 16463
        OnClick = MenuSelectTag
      end
      object Close1: TMenuItem
        Tag = 103
        Caption = '&Close'
        ShortCut = 16499
        OnClick = MenuSelectTag
      end
      object Save1: TMenuItem
        Tag = 104
        Caption = '&Save'
        ShortCut = 16467
        OnClick = MenuSelectTag
      end
      object Saveas1: TMenuItem
        Tag = 105
        Caption = 'Save &as...'
        OnClick = MenuSelectTag
      end
      object SaveAll1: TMenuItem
        Tag = 106
        Caption = 'Sa&ve All'
        OnClick = MenuSelectTag
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Printersetup1: TMenuItem
        Tag = 110
        Caption = 'Printer Setup...'
        OnClick = MenuSelectTag
      end
      object Print1: TMenuItem
        Tag = 111
        Caption = '&Print'
        ShortCut = 16464
        OnClick = MenuSelectTag
      end
      object MenuMRU: TMenuItem
        Caption = '-'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Tag = 199
        Caption = 'E&xit'
        OnClick = MenuSelectTag
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      GroupIndex = 1
      object Cut1: TMenuItem
        Tag = 201
        Caption = 'Cu&t'
        ShortCut = 16472
        OnClick = MenuSelectTag
      end
      object Copy1: TMenuItem
        Tag = 202
        Caption = '&Copy'
        ShortCut = 16451
        OnClick = MenuSelectTag
      end
      object Paste1: TMenuItem
        Tag = 203
        Caption = '&Paste'
        ShortCut = 16470
        OnClick = MenuSelectTag
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Selectall1: TMenuItem
        Tag = 204
        Caption = 'Select &All'
        ShortCut = 16449
        OnClick = MenuSelectTag
      end
    end
    object Character1: TMenuItem
      Caption = '&Search'
      GroupIndex = 7
      object Left1: TMenuItem
        Tag = 301
        Caption = '&Find'
        ShortCut = 16454
        OnClick = MenuSelectTag
      end
      object Right1: TMenuItem
        Tag = 302
        Caption = 'Fin&d in Files'
        Visible = False
        OnClick = MenuSelectTag
      end
      object Center1: TMenuItem
        Tag = 303
        Caption = '&Replace'
        ShortCut = 16466
        OnClick = MenuSelectTag
      end
      object Again1: TMenuItem
        Tag = 304
        Caption = '&Again'
        ShortCut = 114
        OnClick = MenuSelectTag
      end
      object Incremental1: TMenuItem
        Tag = 305
        Caption = '&Incremental'
        ShortCut = 16453
        OnClick = MenuSelectTag
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object GotoLine1: TMenuItem
        Tag = 306
        Caption = '&Goto Line'
        ShortCut = 32839
        OnClick = MenuSelectTag
      end
    end
    object Compiler1: TMenuItem
      Caption = '&Compiler'
      GroupIndex = 11
      object Compile1: TMenuItem
        Tag = 401
        Caption = '&Compile'
        ShortCut = 120
        OnClick = MenuSelectTag
      end
      object Upload1: TMenuItem
        Tag = 402
        Caption = '&Upload'
        Visible = False
        OnClick = MenuSelectTag
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object meLastCompile: TMenuItem
        Tag = 405
        Caption = 'Open Test.Pas'
        ShortCut = 121
        OnClick = MenuSelectTag
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object DebugWindow: TMenuItem
        Tag = 406
        Caption = 'Debug Window'
        ShortCut = 122
        OnClick = MenuSelectTag
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object Information1: TMenuItem
        Tag = 403
        Caption = '&Information'
        Visible = False
        OnClick = MenuSelectTag
      end
      object Options1: TMenuItem
        Tag = 404
        Caption = '&Options'
        Visible = False
        OnClick = MenuSelectTag
      end
    end
    object miHelp: TMenuItem
      Caption = 'Help'
      GroupIndex = 11
      object Help1: TMenuItem
        Tag = 500
        Caption = 'Help'
        OnClick = MenuSelectTag
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object PalmOSHelp1: TMenuItem
        Tag = 501
        Caption = 'Palm OS Reference'
      end
      object PalmOSHelp2: TMenuItem
        Tag = 502
        Caption = 'Palm OS Companion'
      end
      object PalmOSHelp3: TMenuItem
        Tag = 503
        Caption = 'Palm OS Companion2'
      end
      object PalmOSHelp4: TMenuItem
        Tag = 504
        Caption = 'Misc 4'
        Visible = False
      end
      object PalmOSHelp5: TMenuItem
        Tag = 505
        Caption = 'Misc 5'
        Visible = False
      end
      object PalmOSHelp6: TMenuItem
        Tag = 506
        Caption = 'Misc 6'
        Visible = False
      end
      object PalmOSHelp7: TMenuItem
        Tag = 507
        Caption = 'Misc 7'
        Visible = False
      end
      object PalmOSHelp8: TMenuItem
        Tag = 508
        Caption = 'Misc 8'
        Visible = False
      end
      object PalmOSHelp9: TMenuItem
        Tag = 509
        Caption = 'HSPascal'
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object miHelpAbout: TMenuItem
        Tag = 510
        Caption = 'About HSPascal...'
        OnClick = MenuSelectTag
      end
    end
  end
  object OpenDialogPas: TOpenDialog
    DefaultExt = '.pas'
    Filter = 
      'Pascal (*.pas)|*.pas|Text (*.txt)|*.txt|Config files (*.cfg)|*.c' +
      'fg|All files(*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 78
    Top = 22
  end
  object PopupMenu1: TPopupMenu
    Left = 168
    Top = 186
    object Cut1Popup: TMenuItem
      Tag = 201
      Caption = 'Cu&t'
      OnClick = MenuSelectTag
    end
    object Copy1Popup: TMenuItem
      Tag = 202
      Caption = '&Copy'
      OnClick = MenuSelectTag
    end
    object Paste1Popup: TMenuItem
      Tag = 203
      Caption = '&Paste'
      OnClick = MenuSelectTag
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 84
    Top = 96
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 168
    Top = 94
  end
  object PrintDialog1: TPrintDialog
    Left = 258
    Top = 94
  end
  object FindDialog1: TFindDialog
    Options = [frDown, frHideUpDown]
    Left = 148
    Top = 22
  end
  object ReplaceDialog1: TReplaceDialog
    Options = [frDown, frHideUpDown]
    Left = 218
    Top = 22
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 356
    Top = 22
  end
  object OpenDialogHelp: TOpenDialog
    DefaultExt = '.pdf'
    Filter = 'pdf (*.pdf)|*.pdf|All files(*.*)|*.*'
    Options = [ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 244
    Top = 184
  end
end
