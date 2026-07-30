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
    FLastLogLength: Integer;
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
  TmpFullLog: string;
  TmpDeltaLog: string;
begin
  pnButtons.Visible := ATask.State in [tsNone, tsWorking, tsInterrupting];
  btnStopTask.Enabled := ATask.State in [tsNone, tsWorking];

  lbCurState.Caption := Format('“екущее состо€ние задачи: %0:s', [CS_TASK_STATE[ATask.State]]);

  // —писок параметров и лог полностью пересоздаЄм, только если сменилась выбранна€ задача
  if (ATask <> FDLLTask) then
  begin
    lvParams.Items.Clear();

    for TmpParamId := 0 to High(ATask.MethodParams) do
    begin
      TmpParamInfo := ATask.DllMethod.Params[TmpParamId];
      TmpListItem := lvParams.Items.Add();
      TmpListItem.Caption := TmpParamInfo.ParamName;
      TmpListItem.SubItems.Add(CS_PARAM_TYPE_STR[TmpParamInfo.ParamType]);
      TmpListItem.SubItems.Add(ATask.MethodParams[TmpParamId].ToStringValue());
    end;

    mmLog.Clear();
    FLastLogLength := 0;
  end;

  TmpFullLog := ATask.MethodLog;
  if (Length(TmpFullLog) > FLastLogLength) then
  begin
    TmpDeltaLog := Copy(TmpFullLog, FLastLogLength + 1, MaxInt);
    FLastLogLength := Length(TmpFullLog);

    SendMessage(mmLog.Handle, EM_SETSEL, mmLog.GetTextLen, mmLog.GetTextLen);
    SendMessage(mmLog.Handle, EM_REPLACESEL, 0, LPARAM(PChar(TmpDeltaLog)));
  end;

  mmResult.Text := ATask.MethodResult;

  FDLLTask := ATask;
end;

end.
