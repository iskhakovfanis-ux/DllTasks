unit uDLLController;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Interfaces.DllReader,

  uDLLMethod,
  uDLLTask;

type
  TDLLInfo = class(TObject)
  private
    FDLLName: string;
    FMethods: TList<IDLLMethod>;
  private
    function GetMethodCount(): Integer;
    function GetMethodItem(AIndex: Integer): IDLLMethod;
  protected
    procedure AddMethod(const AMethodName, AMethodDescription: string; const AMethodParams: TArray<TParamInfo>);
  public
    constructor Create(const ADllName: string);
    destructor Destroy(); override;
  public
    property DLLName: string
             read FDLLName;
    property MethodCount: Integer
             read GetMethodCount;
    property MethodItem[AIndex: Integer]: IDLLMethod
             read GetMethodItem;
  end;

  TDLLController = class(TObject)
  private
    FDLLInfoList: TObjectDictionary<string, TDLLInfo>;
    FTaskList: TList<IDLLTask>;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    /// <summary>
    ///   Идемпотентное добавление данных о методе
    /// </summary>
    /// <param name="ADllName"> Полное название библиотеки </param>
    /// <param name="AMethodName"> Название метода </param>
    /// <param name="AParams"> Список параметров </param>
    /// <param name="ADescription"> Описание метода </param>
    procedure AddDllMethod(const ADLLName: string; const AMethodName: string; const AParams: TArray<TParamInfo>;
              const ADescription: string);
    function StartTask(const AMethod: IDLLMethod; const AMethodParams: IDLLMethodParams): IDLLTask;
  public
    property TaskList: TList<IDLLTask>
             read FTaskList;
  end;

  /// <summary>
  ///   Класс реализует интерфейс IDLLMethodsController для добавления данных по методам библиотеки
  ///   Используется как прокси без реального удаления основного класса
  /// </summary>
  TDLLMethodsController = class(TInterfacedObject, IDLLMethodsController)
  private
    FInstance: TDLLController;
  public
    constructor Create(AInstance: TDLLController);
  public
    /// <summary>
    ///   Идемпотентное добавление данных о методе
    /// </summary>
    /// <param name="ADllName"> Полное название библиотеки </param>
    /// <param name="AMethodName"> Название метода </param>
    /// <param name="AParams"> Список параметров </param>
    /// <param name="ADescription"> Описание метода </param>
    procedure AddDllMethod(const ADLLName: string; const AMethodName: string; const AParams: TArray<TParamInfo>;
              const ADescription: string); stdcall;
  end;

implementation

constructor TDLLMethodsController.Create(AInstance: TDLLController);
begin
  inherited Create();

  FInstance := AInstance;
end;

procedure TDLLMethodsController.AddDllMethod(const ADLLName, AMethodName: string; const AParams: TArray<TParamInfo>;
          const ADescription: string);
begin
  if Assigned(FInstance) then
    FInstance.AddDllMethod(ADLLName, AMethodName, AParams, ADescription);
end;

constructor TDLLController.Create;
begin
  inherited Create();

  FDLLInfoList := TObjectDictionary<string, TDLLInfo>.Create([doOwnsValues]);
end;

destructor TDLLController.Destroy;
begin
  FreeAndNil(FDLLInfoList);

  inherited Destroy();
end;

{ TDLLController }

procedure TDLLController.AddDllMethod(const ADLLName, AMethodName: string; const AParams: TArray<TParamInfo>;
          const ADescription: string);
var
  TmpDllName: string;
  TmpDllInfo: TDLLInfo;
begin
  TmpDllName := LowerCase(ADLLName);
  if (not FDLLInfoList.TryGetValue(TmpDllName, TmpDllInfo)) then
  begin
    TmpDllInfo := TDLLInfo.Create(ADLLName);
    FDLLInfoList.Add(TmpDllName, TmpDllInfo);
  end;

  TmpDllInfo.AddMethod(AMethodName, ADescription, AParams);
end;

function TDLLController.StartTask(const AMethod: IDLLMethod; const AMethodParams: IDLLMethodParams): IDLLTask;
var
  TmpDLLTask: TDLLTask;
begin
  TmpDLLTask := TDLLTask.Create(AMethod, AMethodParams);

  // TODO: Нужно еще передать обработчик прогресса операции!

  TmpDLLTask.Start();

  Result := TmpDLLTask;

  FTaskList.Add(Result);
end;

constructor TDLLInfo.Create(const ADllName: string);
begin
  inherited Create();

  FDLLName := ADllName;
  FMethods := TList<IDLLMethod>.Create();
end;

destructor TDLLInfo.Destroy();
begin
  FreeAndNil(FMethods);

  inherited Destroy();
end;

procedure TDLLInfo.AddMethod(const AMethodName, AMethodDescription: string; const AMethodParams: TArray<TParamInfo>);
begin
  FMethods.Add(TDLLMethod.Create(FDLLName, AMethodName, AMethodDescription, AMethodParams));
end;

function TDLLInfo.GetMethodCount: Integer;
begin
  Result := FMethods.Count;
end;

function TDLLInfo.GetMethodItem(AIndex: Integer): IDLLMethod;
begin
  Result := FMethods[AIndex];
end;

end.
