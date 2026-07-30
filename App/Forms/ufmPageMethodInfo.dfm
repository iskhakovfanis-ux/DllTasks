object fmPageMethodInfo: TfmPageMethodInfo
  Left = 0
  Top = 0
  Width = 602
  Height = 325
  TabOrder = 0
  object lvMethodParams: TListView
    Left = 0
    Top = 0
    Width = 602
    Height = 325
    Align = alClient
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
        Caption = 'Description'
        Width = 300
      end>
    ReadOnly = True
    TabOrder = 0
    ViewStyle = vsReport
  end
end
