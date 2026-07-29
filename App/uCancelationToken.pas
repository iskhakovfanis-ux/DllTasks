unit uCancelationToken;

interface

uses
  Winapi.Windows,
  System.Classes,

  Interfaces.DllReader;

type
  TCancelationToken = class(TInterfacedObject, ICancelationToken)
  private
    FCancelEvent: THandle;
  public
    constructor Create(AThread: TThread);
  public
    destructor Destroy; override;
    procedure Cancel(); stdcall;
    function IsCancelationRequired(): Boolean; stdcall;
    function Wait(AWait: Cardinal): Cardinal; overload; stdcall;
    function Wait(AWaitHandle: THandle; AWait: Cardinal): Cardinal; overload; stdcall;
  end;


implementation


constructor TCancelationToken.Create(AThread: TThread);
begin
  inherited Create();

  FCancelEvent := CreateEvent(nil, True, False, nil);
end;

destructor TCancelationToken.Destroy;
begin
  CloseHandle(FCancelEvent);

  inherited Destroy();
end;

{ TCancelationToken }

procedure TCancelationToken.Cancel();
begin
  SetEvent(FCancelEvent);
end;

function TCancelationToken.IsCancelationRequired: Boolean;
begin
  Result := (Wait(0) = WAIT_OBJECT_0);
end;

function TCancelationToken.Wait(AWaitHandle: THandle; AWait: Cardinal): Cardinal;
var
  TmpHandleList: TWOHandleArray;
begin
  TmpHandleList[0] := FCancelEvent;
  TmpHandleList[1] := AWaitHandle;
  Result := WaitForMultipleObjects(2, @TmpHandleList, False, AWait);
end;

function TCancelationToken.Wait(AWait: Cardinal): Cardinal;
begin
  Result := WaitForSingleObjectEx(FCancelEvent, AWait, False);
end;

end.
