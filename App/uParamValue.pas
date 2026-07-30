
unit uParamValue;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  Interfaces.DllReader;

type
  TParamValue = class(TInterfacedObject, IParamValue)
  private
    FData: TArray<Byte>;
    FParamType: TParamType;
  private
    function GetParamType: TParamType; stdcall;
  public
    function ReadAsBoolean: Boolean; stdcall;
    function ReadAsInt: Integer; stdcall;
    function ReadAsString: string; stdcall;
    function ReadAsStringList: TArray<string>; stdcall;
    function ReadValue: TArray<Byte>; stdcall;
    function ToStringValue: string; stdcall;
    procedure WriteAsBoolean(AValue: Boolean); stdcall;
    procedure WriteAsInt(AValue: Integer); stdcall;
    procedure WriteAsString(const AValue: string); stdcall;
    procedure WriteAsStringList(const AValue: TArray<string>); stdcall;
    procedure WriteValue(AParamType: TParamType; const AValue: TArray<Byte>); stdcall;
    property ParamType: TParamType read GetParamType;
  end;

implementation

function TParamValue.GetParamType: TParamType;
begin
  Result := FParamType;
end;

function TParamValue.ReadAsBoolean(): Boolean;
begin
  Result := PBoolean(@FData[0])^;
end;

function TParamValue.ReadAsInt(): Integer;
begin
  Result := PInteger(FData[0])^;
end;

function TParamValue.ReadAsString(): string;
begin
  Result := TEncoding.Unicode.GetString(FData);
end;

function TParamValue.ReadAsStringList(): TArray<string>;
var
  TmpStr: string;
begin
  TmpStr := ReadAsString();
  Result := TmpStr.Split([#0]);
end;

function TParamValue.ReadValue(): TArray<Byte>;
begin
  Result := FData;
end;

function TParamValue.ToStringValue(): string;
begin
  case FParamType of
    ptUnknown:
      Result := string.Empty;
    ptInteger:
      Result := IntToStr(ReadAsInt());
    ptString:
      Result := ReadAsString();
    ptStringList:
      Result := string.Join(',', ReadAsStringList);
    ptBoolean:
      Result := BoolToStr(ReadAsBoolean(), True);
  end;
end;

procedure TParamValue.WriteAsBoolean(AValue: Boolean);
begin
  FParamType := ptBoolean;
  SetLength(FData, SizeOf(Boolean));
  PBoolean(@FData[0])^ := AValue;
end;

procedure TParamValue.WriteAsInt(AValue: Integer);
begin
  FParamType := ptInteger;
  SetLength(FData, SizeOf(Integer));
  PInteger(@FData[0])^ := AValue;
end;

procedure TParamValue.WriteAsString(const AValue: string);
begin
  FParamType := ptString;
  FData := TEncoding.Unicode.GetBytes(AValue);
end;

procedure TParamValue.WriteAsStringList(const AValue: TArray<string>);
begin
  FParamType := ptStringList;
  FData := TEncoding.Unicode.GetBytes(string.Join(#0, AValue));
end;

procedure TParamValue.WriteValue(AParamType: TParamType; const AValue: TArray<Byte>);
begin
  FParamType := AParamType;
  FData := AValue;
end;

end.
