unit uDLLMethod;

interface

uses
  Interfaces.DllReader;

type
  TDLLMethod = class(TInterfacedObject, IDLLMethod)
  private
    FDescription: string;
    FDLLName: string;
    FMethodName: string;
    FParams: TArray<TParamInfo>;
  private
    function GetDescription(): string; stdcall;
    function GetDLLName(): string; stdcall;
    function GetMethodName(): string; stdcall;
    function GetParams(): TArray<TParamInfo>; stdcall;
  public
    constructor Create(const ADllName, AMethodName, ADescription: string; const AParams: TArray<TParamInfo>);
  public
    /// <summary>
    ///   Описание метода
    /// </summary>
    property Description: string
             read GetDescription;
    /// <summary>
    ///   Полное название библиотеки
    /// </summary>
    property DLLName: string
             read GetDLLName;
    /// <summary>
    ///   Название метода
    /// </summary>
    property MethodName: string
             read GetMethodName;
    /// <summary>
    ///   Список параметров
    /// </summary>
    property Params: TArray<TParamInfo>
             read GetParams;
  end;

implementation

constructor TDLLMethod.Create(const ADllName, AMethodName, ADescription: string; const AParams: TArray<TParamInfo>);
begin
  inherited Create();

  FDLLName := ADllName;
  FMethodName := AMethodName;
  FDescription := ADescription;
  FParams := AParams;
end;

function TDLLMethod.GetDescription(): string;
begin
  Result := FDescription;
end;

function TDLLMethod.GetDLLName(): string;
begin
  Result := FDLLName;
end;

function TDLLMethod.GetMethodName(): string;
begin
  Result := FMethodName;
end;

function TDLLMethod.GetParams(): TArray<TParamInfo>;
begin
  Result := FParams;
end;

end.
