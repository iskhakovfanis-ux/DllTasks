program DllTasks;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  Interfaces.DllReader in '../Shared/Interfaces.DllReader.pas',
  uDLLMethod in 'uDLLMethod.pas',
  uDLLController in 'uDLLController.pas',
  uCancelationToken in 'uCancelationToken.pas',
  uDLLMethodParams in 'uDLLMethodParams.pas',
  uDLLTask in 'uDLLTask.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
