unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.RTTI,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Interfaces.DllReader,
  uDLLController,
  ufmMethodParams,
  ufmPageTaskInfo,
  ufmPageMethodInfo;

type
  TForm1 = class(TForm)
    pnDlls: TPanel;
    pnAddDLL: TPanel;
    lvDLLList: TListView;
    btnLoadDLL: TButton;
    pcMethods: TPageControl;
    tsDLLMethods: TTabSheet;
    tsTaskList: TTabSheet;
    pnMethodList: TPanel;
    Panel1: TPanel;
    lvMethods: TListView;
    btnStartMethod: TButton;
    pnContent: TPanel;
    lvTaskList: TListView;
    odLoadLibrary: TOpenDialog;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLoadDLLClick(Sender: TObject);
    procedure btnStartMethodClick(Sender: TObject);
    procedure lvDLLListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvMethodsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FCurDetails: TFrame;
    FCurTask: IDLLTask;
    FDLLController: TDLLController;
    { Private declarations }
  protected
    procedure DoChangeTaskLog(const ATask: IDLLTask);
    procedure DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
    procedure UpdateTaskState(const ATask: IDLLTask);
  public
    function GetMethodByNode(AListItem: TListItem): IDLLMethod;
    function LoadLibrary(const ADLLName: string): Boolean;
    procedure ShowDLLMethods(const ADLLInfo: TDLLInfo);
    procedure ShowMethodDetails(const AMethod: IDLLMethod);
    procedure ShowTaskDetails(ATask: IDLLTask);
    procedure StartTask(const AMethod: IDLLMethod);
    procedure UpdateTaskList;
    { Public declarations }
  end;

  (*


  Добавление библиотеки в список
  Отображение списка загруженных библиотек
  Получение списка методов библиотеки

  Отображение списка запущенных задач
  Отображение списка выполненных задач
  Остановка задачи
  Оотображение информации по задаче (состояние, лог, результат)

  *)

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDLLController);
  FreeAndNil(FCurDetails);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDLLController := TDLLController.Create();
  FDLLController.OnChangeTaskLog := DoChangeTaskLog;
  FDLLController.OnChangeTaskState := DoChangeTaskState;
  FCurDetails := nil;
end;

procedure TForm1.btnLoadDLLClick(Sender: TObject);
begin
  if odLoadLibrary.Execute() then
  begin
    if LoadLibrary(odLoadLibrary.FileName) then
      ShowMessage('Библиотека успешно загружена')
    else
      ShowMessage('Не удалось загрузить библиотеку');
  end;
end;

procedure TForm1.btnStartMethodClick(Sender: TObject);
begin
  StartTask(GetMethodByNode(lvMethods.Selected));
end;

procedure TForm1.DoChangeTaskLog(const ATask: IDLLTask);
begin
  if (FCurTask = ATask) then
  begin
    if (FCurDetails is TfmPageTaskInfo) then
      (FCurDetails as TfmPageTaskInfo).ShowData(ATask);
  end;
end;

procedure TForm1.DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
begin
  if (FCurTask = ATask) then
  begin
    if (FCurDetails is TfmPageTaskInfo) then
      (FCurDetails as TfmPageTaskInfo).ShowData(ATask);
  end;

  UpdateTaskState(ATask);
end;

function TForm1.GetMethodByNode(AListItem: TListItem): IDLLMethod;
begin
  if (not Assigned(AListItem))
     or (not Assigned(AListItem.Data))
  then
    Result := nil
  else
    Result := IDLLMethod(AListItem.Data);
end;

function TForm1.LoadLibrary(const ADLLName: string): Boolean;
var
  TmpItem: TListItem;
begin
  Result := FDLLController.LoadLibrary(ADLLName);

  if Result then
  begin
    TmpItem := lvDLLList.Items.Add();

    TmpItem.Caption := ExtractFileName(ADLLName);
    TmpItem.Data := PChar(ADLLName);
    TmpItem.SubItems.Add(ExtractFilePath(ADLLName));
  end;
end;

procedure TForm1.lvDLLListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  TmpDLLItem: TDLLInfo;
begin
  if (not Assigned(Item))
     or (not Assigned(Item.Data))
  then
    TmpDLLItem := nil
  else
    TmpDLLItem := FDLLController.DLLItem[string(Item.Data)];

  ShowDLLMethods(TmpDLLItem);
end;

procedure TForm1.lvMethodsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  TmpMethodItem: IDLLMethod;
begin
  TmpMethodItem := GetMethodByNode(Item);
  btnStartMethod.Enabled := Assigned(TmpMethodItem);

  if Assigned(TmpMethodItem) then
    ShowMethodDetails(TmpMethodItem);
end;

procedure TForm1.ShowDLLMethods(const ADLLInfo: TDLLInfo);
var
  TmpI: Integer;
  TmpItem: TListItem;
  TmpMethod: IDLLMethod;
begin
  lvMethods.Items.Clear();

  if (not Assigned(ADLLInfo)) then
    Exit();

  for TmpI := 0 to ADLLInfo.MethodCount - 1 do
  begin
    TmpMethod := ADLLInfo.MethodItem[TmpI];
    TmpItem := lvMethods.Items.Add();
    TmpItem.Caption := TmpMethod.DLLMethodName;
    TmpItem.SubItems.Add(TmpMethod.Description);
    TmpItem.Data := Pointer(TmpMethod);
  end;
end;

procedure TForm1.ShowMethodDetails(const AMethod: IDLLMethod);
begin
  FCurTask := nil;
  FreeAndNil(FCurDetails);

  FCurDetails := TfmPageMethodInfo.Create(nil);
  (FCurDetails as TfmPageMethodInfo).ShowData(AMethod.Params);

  FCurDetails.Parent := pnContent;
  FCurDetails.Align := alClient;
end;

procedure TForm1.ShowTaskDetails(ATask: IDLLTask);
begin
  FCurTask := ATask;
  FreeAndNil(FCurDetails);

  FCurDetails := TfmPageTaskInfo.Create(nil);
  (FCurDetails as TfmPageTaskInfo).ShowData(ATask);

  FCurDetails.Parent := pnContent;
  FCurDetails.Align := alClient;
end;

procedure TForm1.StartTask(const AMethod: IDLLMethod);
var
  TmpModalResult: TModalResult;
  TmpParams: TArray<TValue>;
begin
  TmpModalResult := TfmStartMethod.ShowMethodParams(AMethod, TmpParams);
  if (TmpModalResult = mrOk) then
  begin
    FDLLController.StartTask(AMethod, TmpParams);
    UpdateTaskList();
    pcMethods.ActivePage := tsTaskList;
    lvTaskList.Selected := lvTaskList.Items[lvTaskList.Items.Count - 1];
  end;
end;

procedure TForm1.UpdateTaskList();
var
  TmpTaskItem: IDLLTask;
  TmpItem: TListItem;
begin
  lvTaskList.Items.Clear();

  for TmpTaskItem in FDLLController.TaskList do
  begin
    TmpItem := lvTaskList.Items.Add();
    TmpItem.Caption := TmpTaskItem.DllMethod.DLLMethodName;
    TmpItem.SubItems.Add(CS_TASK_STATE[TmpTaskItem.State]);
    TmpItem.SubItems.Add(TmpTaskItem.DllMethod.Description);
    TmpItem.Data := Pointer(TmpTaskItem);
  end;
end;

procedure TForm1.UpdateTaskState(const ATask: IDLLTask);
var
  TmpItemId: Integer;
begin
  TmpItemId := FDLLController.TaskList.IndexOf(ATask);
  if (lvTaskList.Items.Count > TmpItemId) then
    lvTaskList.Items[TmpItemId].SubItems[0] := CS_TASK_STATE[ATask.State]
  else
    UpdateTaskList();
end;

end.
