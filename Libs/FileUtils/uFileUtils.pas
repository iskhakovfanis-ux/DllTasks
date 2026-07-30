unit uFileUtils;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections,
  System.IOUtils,
  Interfaces.DllReader;

procedure SearchFilesInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AMaskList: TArray<string>; const ASearchPath: string);
procedure CountOccurrencesInFileInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AMaskList: TArray<string>; const AFileName: string); stdcall;

procedure SearchFiles(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater; const AParams: TArray<IParamValue>); stdcall;
procedure CountOccurrencesInFile(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AParams: TArray<IParamValue>);

implementation

procedure SearchFiles(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater; const AParams: TArray<IParamValue>);
begin
  SearchFilesInner(ACancelationToken, ATaskUpdater, AParams[0].ReadAsStringList(), AParams[1].ReadAsString());
end;

procedure CountOccurrencesInFile(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AParams: TArray<IParamValue>);
begin
  CountOccurrencesInFileInner(ACancelationToken, ATaskUpdater, AParams[0].ReadAsStringList(), AParams[1].ReadAsString());
end;

procedure SearchFilesInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AMaskList: TArray<string>; const ASearchPath: string);
var
  TmpDirList: TQueue<string>;
  TmpFoundFiles: TStringList;
  TmpCurDir: string;
  TmpI: Integer;
  TmpSearchRec: TSearchRec;
  TmpResult: string;
begin
  TmpDirList := TQueue<string>.Create();
  TmpFoundFiles := TStringList.Create();
  try
    try
      TmpDirList.Enqueue(ASearchPath);

      while (TmpDirList.Count > 0) do
      begin
        // Если операция прервана пользователем, то выходим
        if ACancelationToken.IsCancelationRequired() then
          Exit();

        TmpCurDir := IncludeTrailingPathDelimiter(TmpDirList.Dequeue());

        ATaskUpdater.AddLog(Format('Start search in dir "%0:s"', [TmpCurDir]));

        if (FindFirst(TmpCurDir + '*.*', faAnyFile, TmpSearchRec) = 0) then
        try
          repeat
            // Если операция прервана пользователем, то выходим
            if ACancelationToken.IsCancelationRequired() then
              Exit();

            // Если это служебный каталог то пропускаем его
            if (TmpSearchRec.Attr and faDirectory = faDirectory)
               and (SameStr(TmpSearchRec.Name, '.')
               or SameStr(TmpSearchRec.Name, '..'))
            then
              Continue;

            // Если это каталог
            if (TmpSearchRec.Attr and faDirectory <> 0) then
              TmpDirList.Enqueue(TmpCurDir + TmpSearchRec.Name)
            // Иначе, если это файл
            else if (TmpSearchRec.Attr and faDirectory = 0) then
            begin
              for TmpI := 0 to High(AMaskList) do
              begin
                // Если операция прервана пользователем, то выходим
                if ACancelationToken.IsCancelationRequired() then
                  Exit();

                // Если имя файла удовлетворяет маске, то добавляем его в список файлов
                if TPath.MatchesPattern(TmpSearchRec.Name, AMaskList[TmpI], False) then
                begin
                  TmpFoundFiles.Add(TmpCurDir + TmpSearchRec.Name);
                  ATaskUpdater.AddLog(Format('Found file "%0:s" by mask "%1:s"', [TmpCurDir + TmpSearchRec.Name, AMaskList[TmpI]]));
                end;
              end;
            end;

            // Показываем текущий файл/каталог в виде прогресса
            ATaskUpdater.SetProgress(0, TmpCurDir + TmpSearchRec.Name);
          until (FindNext(TmpSearchRec) <> 0);
        finally
          FindClose(TmpSearchRec);
        end;
      end;
    finally
      TmpFoundFiles.LineBreak := #$D#$A#9;

      TmpResult := Format('Кол-во файлов, удовлетворяющие заданной маске: %0:d'#$D#$A'Список файлов:'#$D#$A'%1:s',
                          [TmpFoundFiles.Count, TmpFoundFiles.Text]);
      ATaskUpdater.SetResult(TmpResult);
    end;
  finally
    FreeAndNil(TmpDirList);
    FreeAndNil(TmpFoundFiles);
  end;
end;

procedure CountOccurrencesInFileInner(const ACancelationToken: ICancelationToken; const ATaskUpdater: IDLLTaskUpdater;
          const AMaskList: TArray<string>; const AFileName: string);
var
  TmpFileStream: TFileStream;
  TmpBuf: TBytes;
  TmpOffset: Int64;
  TmpReadSize: Int64;
  TmpCrossOffset: Integer;
  TmpI: Integer;
  TmpCurStr: string;
  TmpCurOffset: Integer;
  TmpOccurencesByMaskList: TObjectList<TList<Int64>>;
  TmpOccurenceCount: Integer;
  TmpOccurenceListStr: string;
  TmpResult: string;
  TmpJ: Integer;
begin
  SetLength(TmpBuf, High(Word));

  TmpOffset := 0;
  TmpCrossOffset := 0;
  // Находим максимальную длину маски. Это необходимо чтобы поиск всегда начинался с отсутпом влево, чтобы
  // исключить нахождение слова на границе буфера
  for TmpI := 0 to High(AMaskList) do
    if (TmpCrossOffset < Length(AMaskList[TmpI]) - 1) then
      TmpCrossOffset := Length(AMaskList[TmpI]) - 1;

  // Открывем файл на чтение
  TmpFileStream := TFileStream.Create(AFileName, fmOpenRead);
  TmpOccurencesByMaskList := TObjectList<TList<Int64>>.Create();
  try
    try
      TmpOccurencesByMaskList.Count := Length(AMaskList);
      repeat
        // Читаем порцию данных из файла
        TmpReadSize := TmpFileStream.Read64(TmpBuf, TmpOffset, Length(TmpBuf));
        if (TmpReadSize <= 0) then
          Break;

        // Если операция прервана пользователем, то выходим
        if ACancelationToken.IsCancelationRequired() then
          Exit();

        // Получаем строку
        TmpCurStr := TEncoding.ANSI.GetString(TmpBuf, 0, TmpReadSize);

        for TmpI := 0 to High(AMaskList) do
        begin
          // На границе блоков (размером с буффер) может быть двойной подсчет вхождения.
          // исключаем такое поведение
          if (TmpOffset > 0)
             and (TmpCrossOffset > Length(AMaskList[TmpI]) - 1)
          then
            TmpCurOffset := TmpCrossOffset - Length(AMaskList[TmpI])
          else
            TmpCurOffset := 0;

          repeat
            // Если операция прервана пользователем, то выходим
            if ACancelationToken.IsCancelationRequired() then
              Exit();

            // Выполняем поиск подстроки внутри строки
            TmpCurOffset := PosEx(AMaskList[TmpI], TmpCurStr, TmpCurOffset);

            // Если найдена подстрока, то добавляем в список
            if (TmpCurOffset >= 0) then
            begin
              if (not Assigned(TmpOccurencesByMaskList[TmpI])) then
                TmpOccurencesByMaskList[TmpI] := TList<Int64>.Create();

              // Добавляем позицию вхождения подстроки в файле
              TmpOccurencesByMaskList[TmpI].Add(TmpOffset + TmpCurOffset);
              ATaskUpdater.AddLog(Format('Found new occurence "%0:s" on position "%1:d"', [AMaskList[TmpI], TmpOffset + TmpCurOffset]));
            end;
          until (TmpCurOffset >= 0);
        end;
        Inc(TmpOffset, TmpReadSize - TmpCrossOffset);
      until TmpReadSize < Length(TmpBuf);
    finally
      TmpResult := string.Empty;

      for TmpI := 0 to TmpOccurencesByMaskList.Count - 1 do
      begin
        if (not Assigned(TmpOccurencesByMaskList[TmpI])) then
          TmpOccurenceCount := 0
        else
          TmpOccurenceCount := TmpOccurencesByMaskList[TmpI].Count;

        TmpOccurenceListStr := string.Empty;
        for TmpJ := 0 to TmpOccurenceCount - 1 do
          TmpOccurenceListStr := Format('%0:s'#9#9'%1:d'#$D#$A, [TmpOccurenceListStr, TmpOccurencesByMaskList[TmpI][TmpJ]]);

        TmpResult := Format('%0:s%1:s:'#$D#$A#9'Кол-во вхождений подсроки в файл: %2:d'#$D#$A#9'Список позиций найденных вхождений: '#$D#$A'%3:s'#$D#$A,
                            [TmpResult, AMaskList[TmpI], TmpOccurenceCount, TmpOccurenceListStr]);
      end;

      // Устанавливаем результат независимо от ситуации
      ATaskUpdater.SetResult(TmpResult);
    end;
  finally
    FreeAndNil(TmpFileStream);
    FreeAndNil(TmpOccurencesByMaskList);
  end;
end;

end.
