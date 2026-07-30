unit Interfaces.DllReader;

interface

uses
  System.Generics.Collections;

type
  /// <summary>
  ///   Тип параметра
  /// </summary>
  TParamType = (
    // Неизвестный параметр
    ptUnknown             = 0,
    // Целочисленный тип
    ptInteger             = 1,
    // Строка
    ptString              = 2,
    // Массив строк
    ptStringList          = 3,
    // Логическое значение
    ptBoolean             = 4
  );

  /// <summary>
  ///   Состояние выполнения задачи
  /// </summary>
  TDLLTaskState = (
    // Задача еще не запущена
    tsNone,
    // Задача выполняется
    tsWorking,
    // Задача завершена
    tsFinished,
    // Задача находится в процессе прерывания
    tsInterrupting,
    // Задача прервана пользователем
    tsInterrupted,
    // Ошибка при выполнении задачи
    tsError
  );

const
  CS_PARAM_TYPE_STR: array [TParamType] of string = (
    // ptUnknown
    'Unknown',
    // ptInteger
    'Integer',
    // ptString
    'String',
    // ptStringList
    'StringList',
    // ptBoolean
    'Boolean'
  );


  CS_TASK_STATE: array [TDLLTaskState] of string = (
    // tsNone
    'Задача не запускалась',
    // tsWorking
    'Выполняется',
    // tsFinished,
    'Завершена',
    // tsInterrupting,
    'Прерывается',
    // tsInterrupted,
    'Остановлена',
    // tsError
    'Завершена с ошибкой'
  );

type
  /// <summary>
  ///   Информация о параметре метода
  /// </summary>
  TParamInfo = record
    // Название параметра
    ParamName: string;
    // Тип параметра
    ParamType: TParamType;
    // Описание параметра
    Description: string;
  public
    constructor Create(const AParamName: string; AParamType: TParamType; const ADescription: string);
  end;

  IParamValue = interface(IInterface)
  ['{727AED96-527F-4F39-8153-A32AD54A3C15}']
    function GetParamType: TParamType; stdcall;
    function ReadAsBoolean: Boolean; stdcall;
    function ReadAsInt: Integer; stdcall;
    function ReadAsString: string; stdcall;
    function ReadAsStringList: TArray<string>; stdcall;
    function ReadValue: TArray<Byte>; stdcall;
    function ToStringValue: string; stdcall;
    procedure WriteAsBoolean(AValue: Boolean); stdcall;
    procedure WriteAsInt(AValue: Integer); stdcall;
    procedure WriteAsString(const AValue: string); stdcall;
    procedure WriteAsStringList(const AValue: TArray<string>); stdcall;
    procedure WriteValue(AParamType: TParamType; const AValue: TArray<Byte>); stdcall;
    property ParamType: TParamType read GetParamType;
  end;

  /// <summary>
  ///   Интерфейс метода с параметрами из DLL
  /// </summary>
  IDLLMethod = interface(IInterface)
  ['{13F1F1B2-21E5-403B-A3E3-CF4DAB637835}']
    function GetDescription(): string; stdcall;
    function GetDLLName(): string; stdcall;
    function GetDLLMethodName: string; stdcall;
    function GetParams(): TArray<TParamInfo>; stdcall;

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
    property DLLMethodName: string
             read GetDLLMethodName;
    /// <summary>
    ///   Список параметров
    /// </summary>
    property Params: TArray<TParamInfo>
             read GetParams;

  end;

  /// <summary>
  ///   Интерфейс для уведомления о добавленном методе
  /// </summry>
  IDLLMethodsController = interface(IInterface)
  ['{546BD2B1-DCAD-4ACB-8A60-6A5265173A9D}']
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

  /// <summary>
  ///   Токен отмены операции
  /// </summary>
  ICancelationToken = interface(IInterface)
  ['{9563E1D6-EE1A-4FAF-9CD8-1A1699E303ED}']
    procedure Cancel(); stdcall;
    function IsCancelationRequired(): Boolean; stdcall;
    function Wait(AWait: Cardinal): Cardinal; overload; stdcall;
    function Wait(AWaitHandle: THandle; AWait: Cardinal): Cardinal; overload; stdcall;
  end;

  /// <summary>
  ///   Интерфейс задачи (запущенная или уже выполненная)
  /// </summary>
  IDLLTask = interface(IInterface)
  ['{851B6452-54C5-4D65-BFFD-FB1CAB99DA19}']
    function GetDllMethod(): IDLLMethod; stdcall;
    function GetMethodLog(): string; stdcall;
    function GetMethodParams: TArray<IParamValue>; stdcall;
    function GetMethodResult(): string; stdcall;
    function GetProgress(): Integer; stdcall;
    function GetProgressText(): string; stdcall;
    function GetState(): TDLLTaskState; stdcall;

    /// <summary>
    ///   Остановка выполнения задачи
    /// </summary>
    procedure Stop(); stdcall;

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
    property MethodParams: TArray<IParamValue>
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

  /// <summary>
  ///   Интерфейс обновления состояния задачи
  /// </summary>
  IDLLTaskUpdater = interface(IInterface)
  ['{E817BD59-028D-41F9-B611-FC5A7F309D9F}']
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
  end;

  /// <summary>
  /// Портотип метода библиотеки для получения всех задач, которые может выполнять библиотека
  /// </summary>
  /// <param name="ADLLMethodsReader"> Интерфейс для заполнения списка задач </param>
  TDLLInfoReadMethod = procedure(const ADLLMethodsReader: IDLLMethodsController); stdcall;

  /// <summary>
  /// Портотип функции для запуска метода из библиотеки
  /// </summary>
  /// <param name="AMethodParams"> Список параметров метода </param>
  /// <param name="ATaskUpdater"> Интерфейс для изменения состояния задачи </param>
  /// <param name="AParams"> Список параметров </param>
  TInvokeDLLMethod = procedure(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
                               const AParams: TArray<IParamValue>); stdcall;

  // Каждая библиотека должна реализовывать методы
  // procedure GetDllMethods(ADLLMethodsReader: IDLLMethodsController); stdcall;
  // И методы, которые возвращались библиотекой с типом
  // procedure (const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
  //            const AParams: TArray<IParamValue>); stdcall;

  const
    CS_GET_DLL_METHODS   = 'GetDllMethods';

implementation

constructor TParamInfo.Create(const AParamName: string; AParamType: TParamType; const ADescription: string);
begin
  ParamName := AParamName;
  ParamType := AParamType;
  Description := ADescription;
end;

end.
