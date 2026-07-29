library FileUtils;

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
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  uFileUtils in 'uFileUtils.pas',
  Interfaces.DllReader in '..\..\Shared\Interfaces.DllReader.pas',
  uMethodInvoke in 'uMethodInvoke.pas';

{$R *.res}

procedure GetDllMethods(ADLLMethodsReader: IDLLMethodsController); stdcall;
var
  TmpParams: TArray<TParamInfo>;
  TmpDLLName: array[0..MAX_PATH] of Char;
begin
  GetModuleFileName(HInstance, TmpDLLName, SizeOf(TmpDLLName));

  // Добавление информации по задаче 1
  SetLength(TmpParams, 2);
  TmpParams[0] := TParamInfo.Create(
    'ASearchMask',
    ptAnsiStringList,
    'Маска имени файла, по которой будет выполняться поиск. Может содержать несколько масок'
  );
  TmpParams[0] := TParamInfo.Create(
    'ASearchPath',
    ptAnsiString,
    'Путь к папке, в которой будет выполняться поиск'
  );
  ADLLMethodsReader.AddDllMethod(string(@TmpDllName[0]), 'SearchFiles', TmpParams,
    'Задача по поиску файлов по указанной маске в указанном каталоге и его подкаталогах');

  // Добавление информации по задаче 2
  SetLength(TmpParams, 2);
  TmpParams[0] := TParamInfo.Create(
    'ASearchSubstr',
    ptAnsiStringList,
    'Строка, по которой выполняется поиск внутри бинарного файла'
  );
  TmpParams[0] := TParamInfo.Create(
    'AFileName',
    ptAnsiString,
    'Путь к бинарному файлу'
  );
  ADLLMethodsReader.AddDllMethod(string(@TmpDllName[0]), 'CountOccurrencesInFile', TmpParams,
    'Задача по поиску кол-ва вхождений подстроки в файле');
end;

exports
  GetDllMethods,
  SearchFiles,
  CountOccurrencesInFile;

begin
end.
