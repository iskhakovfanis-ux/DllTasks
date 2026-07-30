object fmStartMethod: TfmStartMethod
  Left = 0
  Top = 0
  Caption = #1047#1072#1087#1091#1089#1082' '#1084#1077#1090#1086#1076#1072
  ClientHeight = 578
  ClientWidth = 955
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Font.Quality = fqClearType
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnParams: TPanel
    Left = 0
    Top = 0
    Width = 955
    Height = 530
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 395
    object lbMethodName: TLabel
      AlignWithMargins = True
      Left = 21
      Top = 21
      Width = 93
      Height = 13
      Margins.Left = 20
      Margins.Top = 20
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1084#1077#1090#1086#1076#1072':'
    end
    object lbMethodDescr: TLabel
      AlignWithMargins = True
      Left = 21
      Top = 49
      Width = 93
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1084#1077#1090#1086#1076#1072':'
      WordWrap = True
    end
    object lbParamList: TLabel
      AlignWithMargins = True
      Left = 21
      Top = 77
      Width = 104
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 5
      Align = alTop
      Caption = #1057#1087#1080#1089#1086#1082' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074':'
    end
    object sbParams: TScrollBox
      Left = 1
      Top = 95
      Width = 953
      Height = 434
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 299
    end
  end
  object pnFooter: TPanel
    Left = 0
    Top = 530
    Width = 955
    Height = 48
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 395
    DesignSize = (
      955
      48)
    object btnStart: TButton
      Left = 833
      Top = 12
      Width = 105
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
      Default = True
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnCancel: TButton
      Left = 722
      Top = 12
      Width = 105
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
end
