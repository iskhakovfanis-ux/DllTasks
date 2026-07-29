program DllTasks;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  Interfaces.DllReader in '..\Shared\Interfaces.DllReader.pas',
  uDLLMethod in 'uDLLMethod.pas',
  uDLLController in 'uDLLController.pas',
  uCancelationToken in 'uCancelationToken.pas',
  uDLLTask in 'uDLLTask.pas',
  ufmMethodParams in 'Forms\ufmMethodParams.pas' {fmStartMethod},
  ufmPageMethodInfo in 'Forms\ufmPageMethodInfo.pas' {fmPageMethodInfo: TFrame},
  ufmPageTaskInfo in 'Forms\ufmPageTaskInfo.pas' {fmPageTaskInfo: TFrame},
  uViewController in 'uViewController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
