object fmPageTaskInfo: TfmPageTaskInfo
  Left = 0
  Top = 0
  Width = 850
  Height = 670
  TabOrder = 0
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 850
    Height = 622
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 670
    object lbParamList: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 48
      Width = 806
      Height = 13
      Margins.Left = 20
      Margins.Top = 15
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1057#1087#1080#1089#1086#1082' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074' '#1079#1072#1087#1091#1089#1082#1072':'
      ExplicitLeft = 35
      ExplicitTop = -2
    end
    object lbLog: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 241
      Width = 806
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1051#1086#1075' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1079#1072#1076#1072#1095#1080':'
      ExplicitLeft = 30
      ExplicitTop = 218
    end
    object lbResult: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 434
      Width = 806
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1051#1086#1075' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1079#1072#1076#1072#1095#1080':'
      ExplicitLeft = 10
      ExplicitTop = 391
    end
    object lbCurState: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 15
      Width = 806
      Height = 13
      Margins.Left = 20
      Margins.Top = 15
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Caption = #1058#1077#1082#1091#1097#1077#1077' '#1089#1086#1089#1090#1086#1103#1085#1080#1077' '#1079#1072#1076#1072#1095#1080':'
      ExplicitWidth = 143
    end
    object lvParams: TListView
      AlignWithMargins = True
      Left = 20
      Top = 76
      Width = 806
      Height = 150
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      Columns = <
        item
          Caption = 'Name'
          Width = 100
        end
        item
          Caption = 'Type'
          Width = 100
        end
        item
          Caption = 'Value'
          Width = 200
        end>
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitTop = 36
      ExplicitWidth = 250
    end
    object mmLog: TMemo
      AlignWithMargins = True
      Left = 20
      Top = 269
      Width = 806
      Height = 150
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      ScrollBars = ssVertical
      TabOrder = 1
      ExplicitTop = 236
    end
    object mmResult: TMemo
      AlignWithMargins = True
      Left = 20
      Top = 462
      Width = 806
      Height = 150
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 20
      Margins.Bottom = 5
      Align = alTop
      ScrollBars = ssVertical
      TabOrder = 2
      ExplicitLeft = 35
      ExplicitTop = 443
    end
  end
  object pnButtons: TPanel
    Left = 0
    Top = 622
    Width = 850
    Height = 48
    Align = alBottom
    TabOrder = 1
    object btnStopTask: TButton
      Left = 22
      Top = 15
      Width = 144
      Height = 25
      Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1079#1072#1076#1072#1095#1091
      TabOrder = 0
      OnClick = btnStopTaskClick
    end
  end
end
