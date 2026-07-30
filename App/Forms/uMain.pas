unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
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
    procedure lvDLLListData(Sender: TObject; Item: TListItem);
    procedure lvDLLListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvMethodsData(Sender: TObject; Item: TListItem);
    procedure lvMethodsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvTaskListData(Sender: TObject; Item: TListItem);
    procedure lvTaskListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FCurDetails: TFrame;
    FCurDLLItem: TDLLInfo;
    FCurMethod: IDLLMethod;
    FCurTask: IDLLTask;
    FDLLController: TDLLController;
    FDllList: TList<TDLLInfo>;
    FMethodList: TList<IDLLMethod>;
    FTaskList: TList<IDLLTask>;
    procedure DoChangeTaskLog(const ATask: IDLLTask);
    procedure DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
    function LoadLibrary(const ADLLName: string): Boolean;
    procedure ShowMethodDetails(const AMethod: IDLLMethod);
    procedure ShowTaskDetails(ATask: IDLLTask);
    procedure StartTask(const AMethod: IDLLMethod);
    procedure UpdateDLLMethods(const ADLLInfo: TDLLInfo);
    procedure UpdateTaskList;
    procedure UpdateTaskState(const ATask: IDLLTask);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDllList);
  FreeAndNil(FTaskList);
  FreeAndNil(FMethodList);
  FreeAndNil(FCurDetails);
  FreeAndNil(FDLLController);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDLLController := TDLLController.Create();
  FDLLController.OnChangeTaskLog := DoChangeTaskLog;
  FDLLController.OnChangeTaskState := DoChangeTaskState;

  FDllList := TList<TDLLInfo>.Create();
  FTaskList := TList<IDLLTask>.Create();
  FMethodList := TList<IDLLMethod>.Create();

  FCurDetails := nil;
  FCurDLLItem := nil;
  FCurMethod := nil;
  FCurTask := nil;
end;

procedure TForm1.btnLoadDLLClick(Sender: TObject);
begin
  if odLoadLibrary.Execute() then
  begin
    if (not LoadLibrary(odLoadLibrary.FileName)) then
      ShowMessage('Не удалось загрузить библиотеку');
  end;
end;

procedure TForm1.btnStartMethodClick(Sender: TObject);
begin
  StartTask(FCurMethod);
end;

procedure TForm1.DoChangeTaskLog(const ATask: IDLLTask);
begin
  // Синхронизируем в главном потоке Vcl
  TThread.Queue(nil,
  procedure
  begin
    if (FCurTask = ATask) then
    begin
      if (FCurDetails is TfmPageTaskInfo) then
        (FCurDetails as TfmPageTaskInfo).ShowData(ATask);
    end;
  end);
end;

procedure TForm1.DoChangeTaskState(const ATask: IDLLTask; AState: TDLLTaskState);
begin
  // Синхронизируем в главном потоке Vcl
  TThread.Synchronize(nil,
  procedure
  begin
    if (FCurTask = ATask) then
    begin
      if (FCurDetails is TfmPageTaskInfo) then
        (FCurDetails as TfmPageTaskInfo).ShowData(ATask);
    end;

    UpdateTaskState(ATask);
  end);
end;

function TForm1.LoadLibrary(const ADLLName: string): Boolean;
begin
  Result := FDLLController.LoadLibrary(ADLLName);

  if Result then
  begin
    FDllList.Clear();
    FDllList.AddRange(FDLLController.DLLItems);

    lvDLLList.Items.Count := FDllList.Count;
    lvDLLList.Invalidate();
    lvDLLList.Selected := lvDLLList.Items[FDllList.Count - 1];
  end;
end;

procedure TForm1.lvDLLListData(Sender: TObject; Item: TListItem);
var
  TmpDllItem: TDLLInfo;
begin
  TmpDllItem := FDllList[Item.Index];

  Item.Caption := ExtractFileName(TmpDllItem.DLLName);
  Item.SubItems.Add(ExtractFilePath(TmpDllItem.DLLName));
end;

procedure TForm1.lvDLLListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Assigned(Item) then
    FCurDLLItem := FDllList[Item.Index]
  else
    FCurDLLItem := nil;

  if Assigned(FCurDLLItem) then
    UpdateDLLMethods(FCurDLLItem);
end;

procedure TForm1.lvMethodsData(Sender: TObject; Item: TListItem);
var
  TmpDllMethod: IDLLMethod;
begin
  TmpDllMethod := FMethodList[Item.Index];
  Item.Caption := TmpDllMethod.DLLMethodName;
  Item.SubItems.Add(TmpDllMethod.Description);
end;

procedure TForm1.lvMethodsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Assigned(Item) then
    FCurMethod := FMethodList[Item.Index]
  else
    FCurMethod := nil;

  btnStartMethod.Enabled := Assigned(FCurMethod);

  if Assigned(FCurMethod) then
    ShowMethodDetails(FCurMethod);
end;

procedure TForm1.lvTaskListData(Sender: TObject; Item: TListItem);
var
  TmpTask: IDLLTask;
begin
  TmpTask := FTaskList[Item.Index];

  Item.Caption := TmpTask.DllMethod.DLLMethodName;
  Item.SubItems.Add(CS_TASK_STATE[TmpTask.State]);
  Item.SubItems.Add(TmpTask.DllMethod.Description);
end;

procedure TForm1.lvTaskListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Assigned(Item) then
    FCurTask := FTaskList[Item.Index]
  else
    FCurTask := nil;

  if Assigned(FCurTask) then
    ShowTaskDetails(FCurTask);
end;

procedure TForm1.UpdateDLLMethods(const ADLLInfo: TDLLInfo);
begin
  FMethodList.Clear();
  FMethodList.AddRange(ADLLInfo.MethodList);

  lvMethods.Items.Count := FMethodList.Count;
  lvMethods.Invalidate();
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
  TmpParams: TArray<IParamValue>;
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
begin
  FTaskList.Clear();
  FTaskList.AddRange(FDLLController.TaskList);

  lvTaskList.Items.Count := FTaskList.Count;
  lvTaskList.Invalidate();
end;

procedure TForm1.UpdateTaskState(const ATask: IDLLTask);
var
  TmpItemId: Integer;
begin
  TmpItemId := FTaskList.IndexOf(ATask);

  // Если элемент не найден в текущем списке, то обновляем список
  if (TmpItemId < 0) then
    UpdateTaskList()
  else
    lvTaskList.UpdateItems(TmpItemId, TmpItemId);
end;

end.
