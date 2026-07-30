unit uDLLLibraryManager;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

type
  /// <summary>
  ///   Информация о загруженной библиотеке: THandle и количество текущих загрузок библиотеки
  /// </summary>
  TLoadedLibraryInfo = class(TObject)
  private
    FHandle: THandle;
    FRefCount: Integer;
  public
    constructor Create(AHandle: THandle);
  public
    property Handle: THandle
             read FHandle;
    property RefCount: Integer
             read FRefCount;
  end;

  /// <summary>
  ///   Централизованный менеджер загрузки DLL со счётчиком ссылок.
  /// </summary>
  TDLLLibraryManager = class(TObject)
  private
    FLock: TCriticalSection;
    FLibraries: TObjectDictionary<string, TLoadedLibraryInfo>;
    function NormalizeName(const ADLLName: string): string;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    /// <summary>
    ///   Возвращает THandle уже загруженной библиотеки либо загружает её (LoadLibraryW),
    ///   увеличивая счётчик ссылок
    /// </summary>
    function Acquire(const ADLLName: string): THandle;
    /// <summary>
    ///   Уменьшает счётчик ссылок на библиотеку. Когда счётчик достигает 0,
    ///   библиотека выгружается из памяти (FreeLibrary).
    /// </summary>
    procedure Release(const ADLLName: string);
    /// <summary>
    ///   Признак того, что библиотека прямо сейчас загружена (используется хотя бы одним потребителем).
    /// </summary>
    function IsLoaded(const ADLLName: string): Boolean;
  end;

implementation

{$REGION 'TLoadedLibraryInfo'}
constructor TLoadedLibraryInfo.Create(AHandle: THandle);
begin
  inherited Create();

  FHandle := AHandle;
  FRefCount := 0;
end;
{$ENDREGION}

{$REGION 'TDLLLibraryManager'}
constructor TDLLLibraryManager.Create();
begin
  inherited Create();

  FLock := TCriticalSection.Create();
  FLibraries := TObjectDictionary<string, TLoadedLibraryInfo>.Create([doOwnsValues]);
end;

destructor TDLLLibraryManager.Destroy();
var
  TmpInfo: TLoadedLibraryInfo;
begin
  FLock.Enter();
  try
    // На случай, если менеджер освобождается раньше, чем все задачи вызвали Release —
    // принудительно выгружаем всё, что осталось в памяти.
    for TmpInfo in FLibraries.Values do
      if (TmpInfo.Handle <> 0) then
        FreeLibrary(TmpInfo.Handle);

    FreeAndNil(FLibraries);
  finally
    FLock.Leave();
  end;

  FreeAndNil(FLock);

  inherited Destroy();
end;

function TDLLLibraryManager.NormalizeName(const ADLLName: string): string;
begin
  Result := ExpandFileName(Trim(ADLLName)).ToLower();
end;

function TDLLLibraryManager.Acquire(const ADLLName: string): THandle;
var
  TmpKey: string;
  TmpInfo: TLoadedLibraryInfo;
begin
  TmpKey := NormalizeName(ADLLName);

  FLock.Enter();
  try
    if (not FLibraries.TryGetValue(TmpKey, TmpInfo)) then
    begin
      Result := LoadLibraryW(PWideChar(ADLLName));
      if (Result = 0) then
        Exit(0);

      TmpInfo := TLoadedLibraryInfo.Create(Result);
      FLibraries.Add(TmpKey, TmpInfo);
    end;

    Inc(TmpInfo.FRefCount);
    Result := TmpInfo.Handle;
  finally
    FLock.Leave();
  end;
end;

procedure TDLLLibraryManager.Release(const ADLLName: string);
var
  TmpKey: string;
  TmpInfo: TLoadedLibraryInfo;
begin
  TmpKey := NormalizeName(ADLLName);

  FLock.Enter();
  try
    if (not FLibraries.TryGetValue(TmpKey, TmpInfo)) then
      Exit();

    Dec(TmpInfo.FRefCount);

    // Библиотеку выгружаем из памяти, только когда ей не пользуется больше ни одна задача
    if (TmpInfo.RefCount <= 0) then
    begin
      FreeLibrary(TmpInfo.Handle);
      FLibraries.Remove(TmpKey);
    end;
  finally
    FLock.Leave();
  end;
end;

function TDLLLibraryManager.IsLoaded(const ADLLName: string): Boolean;
begin
  FLock.Enter();
  try
    Result := FLibraries.ContainsKey(NormalizeName(ADLLName));
  finally
    FLock.Leave();
  end;
end;
{$ENDREGION}

end.
