unit uCancelationToken;

interface

uses
  Interfaces.DllReader;

type
  TCancelationToken = class(TInterfacedObject, ICancelationToken)
  public
    procedure Cancel(); stdcall;
    function IsCancelationRequired(): Boolean; stdcall;
    function IsFinished(): Boolean; stdcall;
  end;

implementation

{ TCancelationToken }

procedure TCancelationToken.Cancel;
begin

end;

function TCancelationToken.IsCancelationRequired: Boolean;
begin

end;

function TCancelationToken.IsFinished: Boolean;
begin

end;

end.
