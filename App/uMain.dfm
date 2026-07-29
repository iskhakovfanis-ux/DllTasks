object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 580
  ClientWidth = 1447
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
  object pcMethods: TPageControl
    Left = 0
    Top = 0
    Width = 746
    Height = 580
    ActivePage = tsDLLMethods
    Align = alLeft
    TabOrder = 0
    object tsDLLMethods: TTabSheet
      Caption = #1057#1087#1080#1089#1086#1082' '#1076#1086#1089#1090#1091#1087#1085#1099#1093' '#1084#1077#1090#1086#1076#1086#1074
      ExplicitLeft = 8
      ExplicitTop = 28
      ExplicitWidth = 512
      object pnDlls: TPanel
        Left = 0
        Top = 0
        Width = 311
        Height = 552
        Align = alLeft
        TabOrder = 0
        ExplicitHeight = 580
        object pnAddDLL: TPanel
          Left = 1
          Top = 501
          Width = 309
          Height = 50
          Align = alBottom
          TabOrder = 0
          ExplicitTop = 529
          object btnLoadDLL: TButton
            Left = 5
            Top = 15
            Width = 116
            Height = 25
            Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' DLL'
            TabOrder = 0
            OnClick = btnLoadDLLClick
          end
        end
        object lvDLLList: TListView
          Left = 1
          Top = 1
          Width = 309
          Height = 500
          Align = alClient
          Columns = <
            item
              Caption = 'Name'
              Width = 100
            end
            item
              AutoSize = True
              Caption = 'Path'
            end>
          TabOrder = 1
          ViewStyle = vsReport
          OnSelectItem = lvDLLListSelectItem
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitHeight = 359
        end
      end
      object pnMethodList: TPanel
        Left = 311
        Top = 0
        Width = 427
        Height = 552
        Align = alClient
        TabOrder = 1
        ExplicitLeft = 455
        ExplicitTop = 195
        ExplicitWidth = 185
        ExplicitHeight = 41
        object Panel1: TPanel
          Left = 1
          Top = 501
          Width = 425
          Height = 50
          Align = alBottom
          TabOrder = 0
          ExplicitWidth = 520
          object btnStartMethod: TButton
            Left = 15
            Top = 15
            Width = 131
            Height = 25
            Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1084#1077#1090#1086#1076
            TabOrder = 0
            OnClick = btnStartMethodClick
          end
        end
        object lvMethods: TListView
          Left = 1
          Top = 1
          Width = 425
          Height = 500
          Align = alClient
          Columns = <
            item
              Caption = 'Name'
              Width = 200
            end
            item
              Caption = 'Description'
              Width = 200
            end>
          TabOrder = 1
          ViewStyle = vsReport
          OnSelectItem = lvMethodsSelectItem
          ExplicitLeft = 125
          ExplicitTop = 205
          ExplicitWidth = 250
          ExplicitHeight = 150
        end
      end
    end
    object tsTaskList: TTabSheet
      Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095
      ImageIndex = 1
      ExplicitLeft = 5
      ExplicitTop = 27
      ExplicitWidth = 281
      object lvTaskList: TListView
        Left = 0
        Top = 0
        Width = 738
        Height = 552
        Align = alClient
        Columns = <
          item
            Caption = 'Name'
            Width = 100
          end
          item
            Caption = 'State'
            Width = 100
          end
          item
            Caption = 'Description'
            Width = 200
          end>
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitLeft = -2
      end
    end
  end
  object pnContent: TPanel
    Left = 746
    Top = 0
    Width = 701
    Height = 580
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 955
    ExplicitTop = 225
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
  object odLoadLibrary: TOpenDialog
    Filter = 'Library|*.dll'
    Left = 140
    Top = 540
  end
end
