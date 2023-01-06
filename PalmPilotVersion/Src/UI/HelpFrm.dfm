object FormHelp: TFormHelp
  Left = 244
  Top = 55
  Width = 766
  Height = 530
  Caption = 'pdf Help'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbPascal: TGroupBox
    Left = 0
    Top = 0
    Width = 758
    Height = 57
    Align = alTop
    Caption = 'Pascal'
    TabOrder = 0
    Visible = False
  end
  object gbPDF: TGroupBox
    Left = 0
    Top = 57
    Width = 758
    Height = 446
    Align = alClient
    Caption = 'Help'
    TabOrder = 1
    object Pdf1: TPdf
      Left = 2
      Top = 15
      Width = 754
      Height = 429
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ControlData = {00000200EE4D0000572C00000000000000}
    end
  end
end
