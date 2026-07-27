unit uDLLMethodParams;

interface

uses
  Winapi.Windows,
  Interfaces.DllReader;

type
  TDLLMethodParams = class(TInterfacedObject, IDLLMethodParams)
  private
    FParams: TArray<TParamInfo>;
    FParamValues: TArray<Pointer>;
  private
    function GetParamsCount(): Integer; stdcall;
  protected
    function GetParamSize(AParamType: TParamType; AParamValue: Pointer): Cardinal;
  public
    constructor Create(const AParams: TArray<TParamInfo>);
    destructor Destroy(); override;
  public
    /// <summary>
    ///   Чтение параметра указанного типа
    /// </summary>
    /// <returns>
    ///   Значение параметра
    /// </returns>
    /// <param name="AParamId"> Номер параметра </param>
    function ReadParam(AParamId: Integer): Pointer; stdcall;

    /// <summary>
    ///   Чтение типа указанного параметра
    /// </summary>
    /// <returns>Тип параметра</returns>
    /// <param name="AParamId"> Идентификатор параметра </param>
    function ReadParamsType(AParamId: Integer): TParamType; stdcall;
    /// <summary>
    ///   Чтение информации указанного параметра
    /// </summary>
    /// <returns>Информация по параметру</returns>
    /// <param name="AParamId"> Идентификатор параметра </param>
    function ReadParamsInfo(AParamId: Integer): TParamInfo; stdcall;

    /// <summary>
    ///   Запись параметра указанного типа и индекса
    /// </summary>
    /// <param name="AParamId"> Идентификатор параметра </param>
    /// <param name="AParamValue"> Значение параметра </param>
    procedure WriteParam(AParamId: Integer; AParamValue: Pointer); stdcall;
  public
    /// <summary>
    ///   Кол-во параметров
    /// </summary>
    property ParamsCount: Integer
             read GetParamsCount;
  end;

implementation

constructor TDLLMethodParams.Create(const AParams: TArray<TParamInfo>);
begin
  inherited Create();

  FParams := AParams;
  SetLength(FParamValues, Length(AParams));
  ZeroMemory(@FParamValues[0], Length(FParamValues) * SizeOf(Pointer));
end;

destructor TDLLMethodParams.Destroy();
var
  TmpI: Integer;
begin
  // Освобождаем память, выделенные под параметры
  for TmpI := 0 to High(FParamValues) do
    if (Assigned(FParamValues[TmpI])) then
      FreeMem(FParamValues[TmpI]);

  Finalize(FParamValues);

  inherited Destroy();
end;

function TDLLMethodParams.GetParamsCount(): Integer;
begin
  Result := Length(FParams);
end;

function TDLLMethodParams.GetParamSize(AParamType: TParamType; AParamValue: Pointer): Cardinal;
begin
  case AParamType of
    ptInteger:
      Result := SizeOf(Integer);
    ptAnsiString:
      Result := Length(PAnsiString(AParamValue)^);
    ptAnsiStringList:
      Result := Length(PAnsiString(AParamValue)^);
    ptByte:
      Result := SizeOf(Byte);
    else
      Result := 0;
  end;
end;

function TDLLMethodParams.ReadParam(AParamId: Integer): Pointer;
begin
  Result := FParamValues[AParamId];
end;

function TDLLMethodParams.ReadParamsInfo(AParamId: Integer): TParamInfo;
begin
  Result := FParams[AParamId];
end;

function TDLLMethodParams.ReadParamsType(AParamId: Integer): TParamType;
begin
  Result := FParams[AParamId].ParamType;
end;

procedure TDLLMethodParams.WriteParam(AParamId: Integer; AParamValue: Pointer);
var
  TmpParamSize: Cardinal;
  TmpData: Pointer;
begin
  if (Assigned(FParamValues[AParamId])) then
    FreeMem(FParamValues[AParamId]);

  TmpData := nil;

  if Assigned(AParamValue) then
  begin
    TmpParamSize := GetParamSize(FParams[AParamId].ParamType, AParamValue);
    if (TmpParamSize > 0) then
    begin
      TmpData := AllocMem(TmpParamSize);
      CopyMemory(TmpData, AParamValue, TmpParamSize);
    end;
  end;

  FParamValues[AParamId] := TmpData;
end;

end.
