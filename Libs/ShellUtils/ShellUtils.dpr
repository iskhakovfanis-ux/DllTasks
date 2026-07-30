library ShellUtils;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  uShellUtils in 'uShellUtils.pas',
  Interfaces.DllReader in '..\..\Shared\Interfaces.DllReader.pas';

{$R *.res}

procedure GetDllMethods(ADLLMethodsReader: IDLLMethodsController); stdcall;
var
  TmpParams: TArray<TParamInfo>;
  TmpDLLName: array[0..MAX_PATH] of Char;
  TmpDLLNameLen: Cardinal;
  TmpDLLNameStr: string;
begin
  TmpDLLNameLen := GetModuleFileName(HInstance, TmpDLLName, Length(TmpDLLName));
  SetString(TmpDLLNameStr, TmpDLLName, TmpDLLNameLen);

  // Добавление информации по задаче 1
  SetLength(TmpParams, 1);
  TmpParams[0] := TParamInfo.Create(
    'ACmdLine',
    ptString,
    'Командная строка запускаемого процесса'
  );
  ADLLMethodsReader.AddDllMethod(TmpDLLNameStr, 'ExecuteCommand', TmpParams,
    'Задача по запуску внешнего процесса с перехватом его стандартного вывода');
end;

exports
  GetDllMethods,
  ExecuteCommand;

begin
end.
