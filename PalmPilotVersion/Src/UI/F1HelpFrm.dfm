object FormHelpF1: TFormHelpF1
  Left = 219
  Top = 99
  Width = 766
  Height = 265
  Caption = 'Help'
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
  object butCancel: TButton
    Left = 10
    Top = 10
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'butCancel'
    ModalResult = 2
    TabOrder = 1
  end
  object RichEdit1: TRichEdit
    Left = 0
    Top = 0
    Width = 758
    Height = 238
    Align = alClient
    TabOrder = 0
  end
end
