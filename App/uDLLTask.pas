unit uDLLTask;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Interfaces.DllReader,
  uDLLMethod,
  uCancelationToken;

type
  TOnChangeTaskProgress = procedure (const ADLLTask: IDLLTask; AProgress: Integer) of object;
  TOnChangeTaskState = procedure (const ADLLTask: IDLLTask; ANewState: TDLLTaskState) of object;
  TOnChangeTaskLog = procedure (const ADLLTask: IDLLTask) of object;

  TDLLTask = class(TInterfacedObject, IDLLTask, IDLLTaskUpdater)
  private
    FCancelationToken: ICancelationToken;
    FDllMethod: IDLLMethod;
    FError: string;
    FLock: TCriticalSection;
    FMethodLog: string;
    FMethodParams: TArray<IParamValue>;
    FMethodResult: string;
    FOnChangeTaskLog: TOnChangeTaskLog;
    FOnChangeTaskProgress: TOnChangeTaskProgress;
    FOnChangeTaskState: TOnChangeTaskState;
    FProgress: Integer;
    FProgressText: string;
    FState: TDLLTaskState;
    FThread: TThread;
  private
    function GetDllMethod(): IDLLMethod; stdcall;
    function GetMethodLog(): string; stdcall;
    function GetMethodParams: TArray<IParamValue>; stdcall;
    function GetMethodResult(): string; stdcall;
    function GetProgress(): Integer; stdcall;
    function GetProgressText(): string; stdcall;
    function GetState(): TDLLTaskState; stdcall;
  protected
    procedure DoExecute(AThread: TThread);
    procedure InvokeMethod;
  public
    constructor Create(const ADLLMethod: IDLLMethod; const ADLLMethodParams: TArray<IParamValue>; AOnChangeTaskProgress:
        TOnChangeTaskProgress; AOnChangeTaskState: TOnChangeTaskState; AOnChangeTaskLog: TOnChangeTaskLog);
    destructor Destroy(); override;
  public
    procedure Start();
  public
    /// <summary>
    ///   Установка прогресса выполнения задачи
    /// </summary>
    /// <param name="AProgress"> Прогресс по операции </param>
    /// <param name="AProgressText"> Текст прогресса </param>
    procedure SetProgress(AProgress: Integer; const AProgressText: string); stdcall;

    /// <summary>
    ///   Добавление результата выполненной задачи
    /// </summary>
    /// <param name="AResult"> Текст результата </param>
    procedure SetResult(const AResult: string); stdcall;

    /// <summary>
    /// Добавление лога
    /// </summary>
    /// <param name="ALogText"> Текст лога </param>
    procedure AddLog(const ALogText: string); stdcall;

    /// <summary>
    ///   Установка ошибки
    /// </summary>
    procedure SetError(const AErrorMsg: string); stdcall;

    /// <summary>
    ///   Установка состояния задачи
    /// </summary>
    /// <param name="AState"> Новое состояние задачи </param>
    procedure SetState(AState: TDLLTaskState); stdcall;
    /// <summary>
    ///   Остановка выполнения задачи
    /// </summary>
    procedure Stop; stdcall;
  public
    /// <summary>
    ///   Токен отмены операции
    /// </summary>
    property CancelationToken: ICancelationToken
             read FCancelationToken;
    /// <summary>
    ///   Метод DLL, который выполняется в рамках задачи
    /// </summary>
    property DllMethod: IDLLMethod
             read GetDllMethod;
    /// <summary>
    ///   Лог выполнения задачи
    /// </summary>
    property MethodLog: string
             read GetMethodLog;
    /// <summary>
    ///   Список параметров, с которыми был запущен метод
    /// </summary>
    property MethodParams: TArray<IParamValue> read GetMethodParams;
    /// <summary>
    ///   JSON результат выполнения задачи
    /// </summary>
    property MethodResult: string
             read GetMethodResult;
    /// <summary>
    ///   Прогресс выполнения задачи
    /// </summary>
    property Progress: Integer
             read GetProgress;
    /// <summary>
    ///   Текст прогресса выполнения задачи
    /// </summary>
    property ProgressText: string
             read GetProgressText;
    /// <summary>
    ///   Состояние выполнения задачи
    /// </summary>
    property State: TDLLTaskState
             read GetState;
  end;

  TDLLTaskThread = class(TThread)
  private
    FInternalTask: TDLLTask;
  protected
    procedure Execute; override;
  public
    constructor Create(AInternalTask: TDLLTask);
  end;

implementation

constructor TDLLTask.Create(const ADLLMethod: IDLLMethod; const ADLLMethodParams: TArray<IParamValue>;
    AOnChangeTaskProgress: TOnChangeTaskProgress; AOnChangeTaskState: TOnChangeTaskState; AOnChangeTaskLog:
    TOnChangeTaskLog);
begin
  inherited Create();

  FLock := TCriticalSection.Create();
  FDllMethod := ADLLMethod;
  FMethodParams := ADLLMethodParams;
  FCancelationToken := TCancelationToken.Create();
  FOnChangeTaskProgress := AOnChangeTaskProgress;
  FOnChangeTaskState := AOnChangeTaskState;
  FOnChangeTaskLog := AOnChangeTaskLog;

  FThread := TDLLTaskThread.Create(Self);
end;

destructor TDLLTask.Destroy();
begin
  if (not FThread.Finished) then
    FCancelationToken.Cancel();

  FreeAndNil(FThread);
  FreeAndNil(FLock);

  inherited Destroy();
end;

procedure TDLLTask.AddLog(const ALogText: string);
begin
  FLock.Enter();
  FMethodLog := Format('%0:s'#$D#$A'%1:s %2:s',
                      [FMethodLog, FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now()), ALogText]);
  FLock.Leave();

  if Assigned(FOnChangeTaskLog) then
    FOnChangeTaskLog(Self);
end;

procedure TDLLTask.DoExecute(AThread: TThread);
begin
  // Устанавливаем состояние запуска задачи
  SetState(tsWorking);
  try
    // Вызываем метод с текущими параметрами
    InvokeMethod();
  except
    on E: Exception do
    begin
      SetError(Format('Exception. %0:s: %1:s', [E.ClassName, E.Message]));
      SetState(tsError);
    end;
  end;

  // Устанавливаем состояние завершения
  if CancelationToken.IsCancelationRequired then
    SetState(tsInterrupted)
  else
    SetState(tsFinished);
end;

function TDLLTask.GetDllMethod(): IDLLMethod;
begin
  Result := FDllMethod;
end;

function TDLLTask.GetMethodLog(): string;
begin
  FLock.Enter();
  Result := FMethodLog;
  FLock.Leave();
end;

function TDLLTask.GetMethodParams: TArray<IParamValue>;
begin
  Result := FMethodParams;
end;

function TDLLTask.GetMethodResult(): string;
begin
  FLock.Enter();
  Result := FMethodResult;
  FLock.Leave();
end;

function TDLLTask.GetProgress(): Integer;
begin
  FLock.Enter();
  Result := FProgress;
  FLock.Leave();
end;

function TDLLTask.GetProgressText(): string;
begin
  FLock.Enter();
  Result := FProgressText;
  FLock.Leave();
end;

function TDLLTask.GetState(): TDLLTaskState;
begin
  FLock.Enter();
  Result := FState;
  FLock.Leave();
end;

procedure TDLLTask.InvokeMethod();
var
  TmpLibHandle: THandle;
  TmpProcAddr: Pointer;
  TmpTaskUpdater: IDLLTaskUpdater;
begin
  TmpLibHandle := LoadLibraryW(PWideChar(FDLLMethod.DLLName));
  try
    TmpProcAddr := GetProcAddress(TmpLibHandle, PWideChar(FDllMethod.DLLMethodName));

    // Если есть метод в библиотеке для вызова задачи, то запускаем задачу
    if Assigned(TmpProcAddr) then
    begin
      TmpTaskUpdater := Self as IDLLTaskUpdater;
      TInvokeDLLMethod(TmpProcAddr)(FCancelationToken, TmpTaskUpdater, FMethodParams)
    end
    else
      raise Exception.CreateFmt('The Library hasn`t method %0:s', [FDllMethod.DLLMethodName]);
  finally
    FreeLibrary(TmpLibHandle);
  end;
end;

procedure TDLLTask.SetError(const AErrorMsg: string);
begin
  FLock.Enter();
  FError := string(PChar(AErrorMsg));
  AddLog(AErrorMsg);
  FLock.Leave();
end;

procedure TDLLTask.SetProgress(AProgress: Integer; const AProgressText: string);
var
  TmpChanged: Boolean;
begin
  FLock.Enter();

  TmpChanged := (FProgress <> AProgress) or SameText(FProgressText, AProgressText);

  if TmpChanged then
  begin
    FProgress := AProgress;
    FProgressText := string(PChar(AProgressText));
  end;

  FLock.Leave();

  // Если произошла смена прогресса, то отправляем уведомление
  if TmpChanged then
    FOnChangeTaskProgress(Self, AProgress);
end;

procedure TDLLTask.SetResult(const AResult: string);
begin
  FLock.Enter();
  FMethodResult := string(PChar(AResult));
  FLock.Leave();
end;

procedure TDLLTask.SetState(AState: TDLLTaskState);
var
  TmpChanged: Boolean;
begin
  FLock.Enter();

  TmpChanged := False;
  // Если устанавливается состояние завершения
  if (AState in [tsFinished, tsInterrupting, tsInterrupted, tsError]) then
  begin
    // И текущее состояние является рабочим или в процессе прерывания,
    // то разрешаем смену состояния
    if (FState in [tsWorking, tsInterrupting]) then
    begin
      FState := AState;
      TmpChanged := True;
    end;
  end
  // Иначе, если это обычная смена состояния, то также разрешаем смену состояния
  else if (AState in [tsWorking]) and (FState = tsNone) then
  begin
    FState := AState;
    TmpChanged := True;
  end;

  FLock.Leave();

  // Если произошла смена состояния, то отправляем уведомление
  if TmpChanged then
    FOnChangeTaskState(Self, FState);
end;

procedure TDLLTask.Start();
begin
  FThread.Start();
end;

procedure TDLLTask.Stop();
begin
  SetState(tsInterrupting);
  FCancelationToken.Cancel();
end;

constructor TDLLTaskThread.Create(AInternalTask: TDLLTask);
begin
  inherited Create(True);

  FInternalTask := AInternalTask;
end;

procedure TDLLTaskThread.Execute();
begin
  FInternalTask.DoExecute(Self);
end;

end.
