unit uDLLController;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Generics.Collections,
  Interfaces.DllReader,

  uDLLMethod,
  uDLLTask;

type
  TDLLInfo = class(TObject)
  private
    FMethodList: TList<IDLLMethod>;
    FDLLName: string;
  protected
    procedure AddMethod(const AMethodName, AMethodDescription: string; const AMethodParams: TArray<TParamInfo>);
  public
    constructor Create(const ADLLName: string);
    destructor Destroy(); override;
  public
    property DLLName: string
             read FDLLName;
    property MethodList: TList<IDLLMethod>
             read FMethodList;
  end;

  TDLLController = class(TObject)
  private
    FDLLInfoList: TObjectDictionary<string, TDLLInfo>;
    FOnChangeTaskLog: TOnChangeTaskLog;
    FOnChangeTaskProgress: TOnChangeTaskProgress;
    FOnChangeTaskState: TOnChangeTaskState;
    FTaskList: TList<IDLLTask>;
  private
    function GetDLLItem(const ADLLName: string): TDLLInfo;
    function GetDLLItems: TArray<TDLLInfo>;
  protected
    procedure DoChangeTaskLog(const ATask: IDLLTask);
    procedure DoChangeTaskProgress(const ATask: IDLLTask; AProgress: Integer);
    procedure DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
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
    function CheckLibraryIsLoaded(const ADLLName: string): Boolean;
    function LoadLibrary(const ADLLName: string): Boolean;
    function StartTask(const AMethod: IDLLMethod; const AMethodParams: TArray<IParamValue>): IDLLTask;
  public
    property DLLItem[const ADLLName: string]: TDLLInfo
             read GetDLLItem;
    property DLLItems: TArray<TDLLInfo> read GetDLLItems;
    property TaskList: TList<IDLLTask>
             read FTaskList;
  public
    property OnChangeTaskLog: TOnChangeTaskLog
             read FOnChangeTaskLog
             write FOnChangeTaskLog;
    property OnChangeTaskProgress: TOnChangeTaskProgress
             read FOnChangeTaskProgress
             write FOnChangeTaskProgress;
    property OnChangeTaskState: TOnChangeTaskState
             read FOnChangeTaskState
             write FOnChangeTaskState;
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
  if (not Assigned(FInstance)) then
    Exit();

  // Вызываем процедуру добавления метода с копированием строк из памяти DLL в память приложения
  FInstance.AddDllMethod(ADLLName, AMethodName, AParams, ADescription);
end;

constructor TDLLController.Create;
begin
  inherited Create();

  FDLLInfoList := TObjectDictionary<string, TDLLInfo>.Create([doOwnsValues]);
  FTaskList := TList<IDLLTask>.Create();
end;

destructor TDLLController.Destroy;
begin
  FreeAndNil(FDLLInfoList);
  FreeAndNil(FTaskList);

  inherited Destroy();
end;

{ TDLLController }

procedure TDLLController.AddDllMethod(const ADLLName, AMethodName: string; const AParams: TArray<TParamInfo>;
          const ADescription: string);
var
  TmpDLLName: string;
  TmpDLLInfo: TDLLInfo;
begin
  TmpDLLName := LowerCase(ADLLName);
  if (not FDLLInfoList.TryGetValue(TmpDLLName, TmpDLLInfo)) then
  begin
    TmpDLLInfo := TDLLInfo.Create(ADLLName);
    FDLLInfoList.Add(TmpDLLName, TmpDLLInfo);
  end;

  TmpDLLInfo.AddMethod(AMethodName, ADescription, AParams);
end;

function TDLLController.CheckLibraryIsLoaded(const ADLLName: string): Boolean;
begin
  Result := FDLLInfoList.ContainsKey(LowerCase(Trim(ADLLName)));
end;

procedure TDLLController.DoChangeTaskLog(const ATask: IDLLTask);
begin
  if Assigned(FOnChangeTaskLog) then
    FOnChangeTaskLog(ATask);
end;

procedure TDLLController.DoChangeTaskProgress(const ATask: IDLLTask; AProgress: Integer);
begin
  if Assigned(FOnChangeTaskProgress) then
    FOnChangeTaskProgress(ATask, AProgress);
end;

procedure TDLLController.DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
begin
  if Assigned(FOnChangeTaskState) then
    FOnChangeTaskState(ATask, AState);
end;

function TDLLController.GetDLLItem(const ADLLName: string): TDLLInfo;
begin
  if (not FDLLInfoList.TryGetValue(LowerCase(Trim(ADLLName)), Result)) then
    Result := nil;
end;

function TDLLController.GetDLLItems: TArray<TDLLInfo>;
begin
  Result := FDLLInfoList.Values.ToArray();
end;

function TDLLController.LoadLibrary(const ADLLName: string): Boolean;
var
  TmpLibHandle: THandle;
  TmpProcAddr: Pointer;
begin
  // Если библиотека уже загружена, то больше не разрешаем загрузку
  if CheckLibraryIsLoaded(ADLLName) then
    Exit(False);

  TmpLibHandle := LoadLibraryW(PWideChar(ADLLName));
  try
    TmpProcAddr := GetProcAddress(TmpLibHandle, PWideChar(CS_GET_DLL_METHODS));

    // Если есть метод в библиотеке для вызова задачи, то запускаем задачу
    if Assigned(TmpProcAddr) then
      TDLLInfoReadMethod(TmpProcAddr)(TDLLMethodsController.Create(Self))
    else
      Exit(False);

    Result := True;
  finally
    FreeLibrary(TmpLibHandle);
  end;
end;

function TDLLController.StartTask(const AMethod: IDLLMethod; const AMethodParams: TArray<IParamValue>): IDLLTask;
var
  TmpDLLTask: TDLLTask;
begin
  TmpDLLTask := TDLLTask.Create(AMethod, AMethodParams, DoChangeTaskProgress, DoChangeTaskState, DoChangeTaskLog);
  Result := TmpDLLTask;
  TmpDLLTask.Start();
  FTaskList.Add(Result);
end;

constructor TDLLInfo.Create(const ADLLName: string);
begin
  inherited Create();

  FDLLName := ADLLName;
  FMethodList := TList<IDLLMethod>.Create();
end;

destructor TDLLInfo.Destroy();
begin
  FreeAndNil(FMethodList);

  inherited Destroy();
end;

procedure TDLLInfo.AddMethod(const AMethodName, AMethodDescription: string; const AMethodParams: TArray<TParamInfo>);
begin
  FMethodList.Add(TDLLMethod.Create(FDLLName, AMethodName, AMethodDescription, AMethodParams));
end;

end.
