unit ufmPageTaskInfo;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Interfaces.DllReader;

type
  TfmPageTaskInfo = class(TFrame)
    lbParamList: TLabel;
    lvParams: TListView;
    lbLog: TLabel;
    mmLog: TMemo;
    ScrollBox1: TScrollBox;
    lbResult: TLabel;
    mmResult: TMemo;
    lbCurState: TLabel;
    pnButtons: TPanel;
    btnStopTask: TButton;
    procedure btnStopTaskClick(Sender: TObject);
  private
    FDLLTask: IDLLTask;
    { Private declarations }
  public
    procedure ShowData(ATask: IDLLTask);
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfmPageTaskInfo.btnStopTaskClick(Sender: TObject);
begin
  if Assigned(FDLLTask) then
    FDLLTask.Stop();
end;

procedure TfmPageTaskInfo.ShowData(ATask: IDLLTask);
var
  TmpParamId: Integer;
  TmpParamInfo: TParamInfo;
  TmpListItem: TListItem;
  TmpParamValue: string;
begin
  FDLLTask := ATask;

  pnButtons.Visible := ATask.State in [tsNone, tsWorking, tsInterrupting];
  btnStopTask.Enabled := ATask.State in [tsNone, tsWorking];

  lbCurState.Caption := Format('Текущее состояние задачи: %0:s', [CS_TASK_STATE[ATask.State]]);

  lvParams.Items.Clear();

  for TmpParamId := 0 to High(ATask.MethodParams) do
  begin
    TmpParamInfo := ATask.DllMethod.Params[TmpParamId];
    TmpListItem := lvParams.Items.Add();
    TmpListItem.Caption := TmpParamInfo.ParamName;
    TmpListItem.SubItems.Add(CS_PARAM_TYPE_STR[TmpParamInfo.ParamType]);

    case TmpParamInfo.ParamType of
      ptInteger:
        TmpParamValue := IntToStr(ATask.MethodParams[TmpParamId].AsType<Integer>());
      ptString:
        TmpParamValue := ATask.MethodParams[TmpParamId].AsType<string>();
      ptStringList:
        TmpParamValue := string.Join(', ',  ATask.MethodParams[TmpParamId].AsType<TArray<string>>());
      ptBoolean:
        TmpParamValue := BoolToStr(ATask.MethodParams[TmpParamId].AsType<Boolean>(), True);
      else
        TmpParamValue := string.Empty;
    end;
  end;

  mmLog.Text := ATask.MethodLog;
  mmResult.Text := ATask.MethodResult;
end;

end.
