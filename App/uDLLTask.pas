unit uDLLTask;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Interfaces.DllReader, uDLLMethod;

type
  TDLLTask = class(TInterfacedObject, IDLLTask, IDLLTaskUpdater)
  private
    FCancelationToken: ICancelationToken;
    FDllMethod: IDLLMethod;
    FMethodParams: IDLLMethodParams;
    FThread: TThread;
  private
    function GetCancelationToken(): ICancelationToken; stdcall;
    function GetDllMethod(): IDLLMethod; stdcall;
    function GetDllTaskId(): Integer; stdcall;
    function GetMethodLog(): string; stdcall;
    function GetMethodParams(): IDLLMethodParams; stdcall;
    function GetMethodResult(): string; stdcall;
    function GetProgress(): Integer; stdcall;
    function GetProgressText(): string; stdcall;
    function GetState(): TDLLTaskState; stdcall;
  protected
    procedure DoExecute(AThread: TThread);
  public
    constructor Create(const ADLLMethod: IDLLMethod; const ADLLMethodParams: IDLLMethodParams);
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
  public
    /// <summary>
    ///   Токен отмены операции
    /// </summary>
    property CancelationToken: ICancelationToken
             read GetCancelationToken;
    /// <summary>
    ///   Метод DLL, который выполняется в рамках задачи
    /// </summary>
    property DllMethod: IDLLMethod
             read GetDllMethod;
    /// <summary>
    ///   Идентификатор задачи
    /// </summary>
    property DllTaskId: Integer
             read GetDllTaskId;
    /// <summary>
    ///   Лог выполнения задачи
    /// </summary>
    property MethodLog: string
             read GetMethodLog;
    /// <summary>
    ///   Список параметров, с которыми был запущен метод
    /// </summary>
    property MethodParams: IDLLMethodParams
             read GetMethodParams;
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

constructor TDLLTask.Create(const ADLLMethod: IDLLMethod; const ADLLMethodParams: IDLLMethodParams);
begin
  inherited Create();

  FDllMethod := ADLLMethod;
  FMethodParams := ADLLMethodParams;

  FThread := TDLLTaskThread.Create(Self);
end;

destructor TDLLTask.Destroy();
begin
  if (not FThread.Finished) then
    FCancelationToken.Cancel();

  FreeAndNil(FThread);

  inherited Destroy();
end;

procedure TDLLTask.AddLog(const ALogText: string);
begin

end;

procedure TDLLTask.DoExecute(AThread: TThread);
begin
end;

function TDLLTask.GetCancelationToken(): ICancelationToken;
begin

end;

function TDLLTask.GetDllMethod(): IDLLMethod;
begin
  Result := FDllMethod;
end;

function TDLLTask.GetDllTaskId(): Integer;
begin

end;

function TDLLTask.GetMethodLog(): string;
begin

end;

function TDLLTask.GetMethodParams(): IDLLMethodParams;
begin
  Result := FMethodParams;
end;

function TDLLTask.GetMethodResult(): string;
begin

end;

function TDLLTask.GetProgress(): Integer;
begin

end;

function TDLLTask.GetProgressText(): string;
begin

end;

function TDLLTask.GetState(): TDLLTaskState;
begin

end;

procedure TDLLTask.SetError(const AErrorMsg: string);
begin

end;

procedure TDLLTask.SetProgress(AProgress: Integer; const AProgressText: string);
begin

end;

procedure TDLLTask.SetResult(const AResult: string);
begin

end;

procedure TDLLTask.SetState(AState: TDLLTaskState);
begin

end;

procedure TDLLTask.Start();
begin
  FThread.Start();
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
