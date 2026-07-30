unit uShellUtils;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Threading,
  Interfaces.DllReader;

procedure ExecuteCommandInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const ACmdLine: string);
procedure ExecuteCommand(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AParams: TArray<IParamValue>); stdcall;

implementation

procedure ExecuteCommandInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const ACmdLine: string);
var
  TmpStartupInfo: TStartupInfo;
  TmpProcessInfo: TProcessInformation;
  TmpSecurity: TSecurityAttributes;
  TmpStdOutRead: THandle;
  TmpStdOutWrite: THandle;
  TmpExitCode: Cardinal;
  TmpReadTask: TThread;
begin
  ZeroMemory(@TmpStartupInfo, SizeOf(TmpStartupInfo));
  TmpStartupInfo.cb := SizeOf(TmpStartupInfo);
  ZeroMemory(@TmpProcessInfo, SizeOf(TmpProcessInfo));
  TmpExitCode := ERROR_INVALID_FUNCTION;
  TmpReadTask := nil;

  ZeroMemory(@TmpSecurity, SizeOf(TmpSecurity));
  TmpSecurity.nLength := SizeOf(TmpSecurity);
  TmpSecurity.bInheritHandle := True;

  if (not CreatePipe(TmpStdOutRead, TmpStdOutWrite, @TmpSecurity, 0)) then
  begin
    TmpStdOutRead := INVALID_HANDLE_VALUE;
    TmpStdOutWrite := INVALID_HANDLE_VALUE;
  end
  else
  begin
    TmpStartupInfo.dwFlags := STARTF_USESTDHANDLES;
    TmpStartupInfo.hStdOutput := TmpStdOutWrite;
    TmpStartupInfo.hStdError := TmpStdOutWrite;

    // Родительский процесс не должен наследовать конец чтения
    SetHandleInformation(TmpStdOutRead, HANDLE_FLAG_INHERIT, 0);
  end;

  try
    // Если не удалось запустить процесс, то выводим ошибку
    if (not CreateProcess(nil, PChar(ACmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, TmpStartupInfo, TmpProcessInfo)) then
    begin
      ATaskUpdater.SetError(Format('Exception: %0:s', [SysErrorMessage(GetLastError)]));
      Exit();
    end;

    try
      try
         // Запускаем задачу чтения данных из cmd - только если пайп реально создан,
         // иначе ReadFile(INVALID_HANDLE_VALUE, ...) в цикле бессмысленен
         if (TmpStdOutRead <> INVALID_HANDLE_VALUE) then
         begin
           TmpReadTask := TThread.CreateAnonymousThread(
            procedure
            const
              CI_BUFFER_SIZE = 4096;
            var
              TmpBuffer: array[0..CI_BUFFER_SIZE - 1] of Byte;
              TmpBytesRead: DWORD;
              TmpStr: UTF8String;
            begin
              while (not ACancelationToken.IsCancelationRequired()) do
              begin
                if (not ReadFile(TmpStdOutRead, TmpBuffer, SizeOf(TmpBuffer), TmpBytesRead, nil)) then
                  Break;

                if (TmpBytesRead = 0) then
                  Break;

                SetString(TmpStr, PAnsiChar(@TmpBuffer[0]), TmpBytesRead);
                ATaskUpdater.AddLog(string(TmpStr));
              end;
            end
           );

           TmpReadTask.FreeOnTerminate := False;
           TmpReadTask.Start();
         end;

        // Если задача прерывается, то останавливаем процесс
        if (ACancelationToken.Wait(TmpProcessInfo.hProcess, INFINITE) = WAIT_OBJECT_0) then
          TerminateProcess(TmpProcessInfo.hProcess, ERROR_CANCELLED);

        GetExitCodeProcess(TmpProcessInfo.hProcess, TmpExitCode);
      finally
        CloseHandle(TmpProcessInfo.hThread);
        CloseHandle(TmpProcessInfo.hProcess);
      end;

      // Закрываем свою копию хендла записи в пайп сразу же, как только процесс точно завершён.
      // Пока этот хендл открыт, фоновая задача чтения не получит EOF в ReadFile и будет висеть в нём бесконечно
      if (TmpStdOutWrite <> INVALID_HANDLE_VALUE) then
      begin
        CloseHandle(TmpStdOutWrite);
        TmpStdOutWrite := INVALID_HANDLE_VALUE;
      end;

      // Дожидаемся завершения фоновой задачи чтения перед тем, как отдать управление обратно
      if Assigned(TmpReadTask) then
      begin
        TmpReadTask.WaitFor();
        FreeAndNil(TmpReadTask);
      end;
    finally
      ATaskUpdater.SetResult(Format('ExitCode: %0:x', [TmpExitCode]));
    end;
  finally
    if (TmpStdOutRead <> INVALID_HANDLE_VALUE) then
      CloseHandle(TmpStdOutRead);
    if (TmpStdOutWrite <> INVALID_HANDLE_VALUE) then
      CloseHandle(TmpStdOutWrite);
  end;
end;

procedure ExecuteCommand(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AParams: TArray<IParamValue>);
begin
  ExecuteCommandInner(ACancelationToken, ATaskUpdater, AParams[0].ReadAsString());
end;

end.
