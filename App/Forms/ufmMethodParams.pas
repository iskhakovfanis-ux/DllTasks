unit ufmMethodParams;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Interfaces.DllReader,

  uParamValue;

type
  TfmStartMethod = class(TForm)
    pnParams: TPanel;
    pnFooter: TPanel;
    btnStart: TButton;
    btnCancel: TButton;
    lbMethodName: TLabel;
    lbMethodDescr: TLabel;
    sbParams: TScrollBox;
    lbParamList: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FDLLMethod: IDLLMethod;
    FParamControls: TList<TWinControl>;
  protected
    procedure AddParam(AParamInfo: TParamInfo);
    function GetParams(): TArray<IParamValue>;
  public
    class function ShowMethodParams(const AMethod: IDLLMethod; out AParams: TArray<IParamValue>): TModalResult;
  end;

implementation

{$R *.dfm}

procedure TfmStartMethod.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FParamControls);
end;

procedure TfmStartMethod.FormCreate(Sender: TObject);
begin
  FParamControls := TList<TWinControl>.Create();
end;

procedure TfmStartMethod.AddParam(AParamInfo: TParamInfo);
var
  TmpPanel: TPanel;
  TmpCaption: TLabel;
  TmpControl: TWinControl;
begin
  TmpPanel := TPanel.Create(sbParams);
  TmpPanel.Parent := sbParams;
  TmpPanel.AutoSize := True;
  TmpPanel.Align := alTop;
  TmpPanel.Top := MaxInt;

  TmpCaption := TLabel.Create(TmpPanel);
  TmpCaption.Parent := TmpPanel;
  TmpCaption.Align := alTop;
  TmpCaption.AlignWithMargins := True;
  TmpCaption.Margins.SetBounds(20, 10, 20, 0);
  TmpCaption.AutoSize := True;
  TmpCaption.Caption := Format('Название параметра: %0:s', [AParamInfo.ParamName]);

  TmpCaption := TLabel.Create(TmpPanel);
  TmpCaption.Parent := TmpPanel;
  TmpCaption.Top := MaxInt;
  TmpCaption.Align := alTop;
  TmpCaption.AlignWithMargins := True;
  TmpCaption.Margins.SetBounds(20, 10, 20, 0);
  TmpCaption.AutoSize := True;
  TmpCaption.Caption := Format('Описание параметра: %0:s', [AParamInfo.Description]);

  TmpCaption := TLabel.Create(TmpPanel);
  TmpCaption.Parent := TmpPanel;
  TmpCaption.Top := MaxInt;
  TmpCaption.Align := alTop;
  TmpCaption.AlignWithMargins := True;
  TmpCaption.Margins.SetBounds(20, 10, 20, 0);
  TmpCaption.AutoSize := True;
  TmpCaption.Caption := 'Значение параметра:';

  case (AParamInfo.ParamType) of
    ptInteger, ptString:
    begin
      TmpControl := TEdit.Create(TmpPanel);
      (TmpControl as TEdit).NumbersOnly := (AParamInfo.ParamType = ptInteger);
    end;
    ptBoolean:
      TmpControl := TCheckBox.Create(TmpPanel);
    ptStringList:
    begin
      TmpControl := TMemo.Create(TmpPanel);
      (TmpControl as TMemo).ScrollBars := ssBoth;
      TmpControl.Height := 100;
    end
    else
      TmpControl := nil;
  end;

  if Assigned(TmpControl) then
  begin
    TmpControl.Parent := TmpPanel;
    TmpControl.Align := alTop;
    TmpControl.Top := MaxInt;
    TmpControl.Align := alTop;
    TmpControl.AlignWithMargins := True;
    TmpControl.Margins.SetBounds(20, 10, 20, 10);
  end;

  FParamControls.Add(TmpControl);
end;

function TfmStartMethod.GetParams(): TArray<IParamValue>;
var
  TmpParamId: Integer;
  TmpControl: TWinControl;
begin
  SetLength(Result, Length(FDLLMethod.Params));

  for TmpParamId := 0 to High(FDLLMethod.Params) do
  begin
    TmpControl := FParamControls[TmpParamId];

    Result[TmpParamId] := TParamValue.Create();

    case FDLLMethod.Params[TmpParamId].ParamType of
      ptInteger:
        Result[TmpParamId].WriteAsInt(StrToInt((TmpControl as TEdit).Text));
      ptString:
        Result[TmpParamId].WriteAsString((TmpControl as TEdit).Text);
      ptStringList:
        Result[TmpParamId].WriteAsStringList((TmpControl as TMemo).Lines.ToStringArray());
      ptBoolean:
        Result[TmpParamId].WriteAsBoolean((TmpControl as TCheckBox).Checked);
    end;
  end;
end;

class function TfmStartMethod.ShowMethodParams(const AMethod: IDLLMethod; out AParams: TArray<IParamValue>): TModalResult;
var
  TmpForm: TfmStartMethod;
  TmpParamInfo: TParamInfo;
begin
  TmpForm := TfmStartMethod.Create(nil);
  try
    TmpForm.FDLLMethod := AMethod;
    TmpForm.lbMethodName.Caption := Format('Название метода: %0:s', [AMethod.DLLMethodName]);
    TmpForm.lbMethodDescr.Caption := Format('Описание метода: %0:s', [AMethod.Description]);

    for TmpParamInfo in AMethod.Params do
      TmpForm.AddParam(TmpParamInfo);

    TmpForm.sbParams.Realign();

    Result := TmpForm.ShowModal();

    if (Result = mrOk) then
      AParams := TmpForm.GetParams();
  finally
    FreeAndNil(TmpForm);
  end;
end;

end.
