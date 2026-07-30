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
    procedure btnStartClick(Sender: TObject);
  private
    FDLLMethod: IDLLMethod;
    FParamControls: TList<TWinControl>;
    // Валидированные параметры сохраняются здесь после успешного нажатия "Запустить"
    FValidatedParams: TArray<IParamValue>;
  protected
    procedure AddParam(AParamInfo: TParamInfo);
    /// <summary>
    ///   Выполняется попытка чтения параметров. Если параметры некорректные, то выводится текст ошибки, которая
    ///   в дальнейшем показывается пользователю (форма при этом не закрывается)
    /// </summary>
    function TryGetParams(out AParams: TArray<IParamValue>; out AErrorMsg: string): Boolean;
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

function TfmStartMethod.TryGetParams(out AParams: TArray<IParamValue>; out AErrorMsg: string): Boolean;
var
  TmpParamId: Integer;
  TmpControl: TWinControl;
  TmpParamInfo: TParamInfo;
begin
  Result := True;
  AErrorMsg := string.Empty;
  SetLength(AParams, Length(FDLLMethod.Params));

  for TmpParamId := 0 to High(FDLLMethod.Params) do
  begin
    TmpParamInfo := FDLLMethod.Params[TmpParamId];
    TmpControl := FParamControls[TmpParamId];

    AParams[TmpParamId] := TParamValue.Create();

    try
      case TmpParamInfo.ParamType of
        ptInteger:
        begin
          // Проверяем на пустую строку, чтобы исключить ошибку конвертации в число
          if (Trim((TmpControl as TEdit).Text).IsEmpty()) then
            raise Exception.CreateFmt('Параметр "%0:s" не заполнен: введите целое число', [TmpParamInfo.ParamName]);

          AParams[TmpParamId].WriteAsInt(StrToInt((TmpControl as TEdit).Text));
        end;
        ptString:
        begin
          if (Trim((TmpControl as TEdit).Text).IsEmpty()) then
            raise Exception.CreateFmt('Параметр "%0:s" не заполнен: введите значение', [TmpParamInfo.ParamName]);

          AParams[TmpParamId].WriteAsString((TmpControl as TEdit).Text);
        end;
        ptStringList:
        begin
          if ((TmpControl as TMemo).Lines.Count = 0) then
            raise Exception.CreateFmt('Параметр "%0:s" не заполнен: введите хотя бы одну строку', [TmpParamInfo.ParamName]);

          AParams[TmpParamId].WriteAsStringList((TmpControl as TMemo).Lines.ToStringArray());
        end;
        ptBoolean:
          AParams[TmpParamId].WriteAsBoolean((TmpControl as TCheckBox).Checked);
        else
          raise Exception.CreateFmt('Параметр "%0:s" имеет неподдерживаемый тип: %1:s',
                [TmpParamInfo.ParamName, CS_PARAM_TYPE_STR[TmpParamInfo.ParamType]]);
      end;
    except
      on E: Exception do
      begin
        // Не даём необработанному исключению вылететь из модального окна - вместо этого
        // сообщаем пользователю, какой конкретно параметр некорректен, и не закрываем форму.
        Result := False;
        AErrorMsg := E.Message;
        Exit();
      end;
    end;
  end;
end;

procedure TfmStartMethod.btnStartClick(Sender: TObject);
var
  TmpParams: TArray<IParamValue>;
  TmpErrorMsg: string;
begin
  if TryGetParams(TmpParams, TmpErrorMsg) then
  begin
    FValidatedParams := TmpParams;
    ModalResult := mrOk;
  end
  else
  begin
    ShowMessage(TmpErrorMsg);
    ModalResult := mrNone;
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
      AParams := TmpForm.FValidatedParams;
  finally
    FreeAndNil(TmpForm);
  end;
end;

end.
