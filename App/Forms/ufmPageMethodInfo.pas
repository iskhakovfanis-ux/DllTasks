unit ufmPageMethodInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,

  Interfaces.DllReader;

type
  TfmPageMethodInfo = class(TFrame)
    lvMethodParams: TListView;
  private
    { Private declarations }
  public
    procedure ShowData(const AParams: TArray<TParamInfo>);
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfmPageMethodInfo.ShowData(const AParams: TArray<TParamInfo>);
var
  TmpParamInfo: TParamInfo;
  TmpListItem: TListItem;
begin
  lvMethodParams.Items.Clear();

  for TmpParamInfo in AParams do
  begin
    TmpListItem := lvMethodParams.Items.Add();
    TmpListItem.Caption := TmpParamInfo.ParamName;
    TmpListItem.SubItems.Add(CS_PARAM_TYPE_STR[TmpParamInfo.ParamType]);
    TmpListItem.SubItems.Add(TmpParamInfo.Description);
  end;
end;

end.
