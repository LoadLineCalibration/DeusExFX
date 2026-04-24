object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Bucur'#259'-te de via'#539#259'!'
  ClientHeight = 202
  ClientWidth = 284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object imgAppIcon: TImage
    Left = 8
    Top = 12
    Width = 64
    Height = 64
    Center = True
  end
  object EsLinkLabel1: TEsLinkLabel
    Left = 8
    Top = 127
    Width = 133
    Height = 15
    Caption = 'Free ES VCL Components'
    ParentShowHint = False
    ShowHint = True
    Url = 'https://github.com/errorcalc/FreeEsVCLComponents'
    LinkColor = clBlue
    LinkStyle = Mixed
  end
  object Button1: TButton
    Left = 199
    Top = 167
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object memoAboutText: TMemo
    Left = 84
    Top = 12
    Width = 192
    Height = 109
    Alignment = taCenter
    Color = clBtnFace
    HideSelection = False
    Lines.Strings = (
      ''
      'DeusExFX is a program for '
      'viewing and editing models in the '
      'DeusEx .3d format.'
      ''
      'Inspired by UnrealFX.')
    ReadOnly = True
    TabOrder = 1
  end
  object edtVersion: TEdit
    Left = 8
    Top = 167
    Width = 181
    Height = 25
    Cursor = crArrow
    AutoSize = False
    BorderStyle = bsNone
    ParentColor = True
    ReadOnly = True
    TabOrder = 2
    Text = 'edtVersion'
  end
end
