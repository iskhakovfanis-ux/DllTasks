unit uViewController;

interface

uses
  System.Generics.Collections,

  uDLLController;

type
  TViewController = class(TObject)
  private
    FDLLList: TList<TDLLInfo>;
  public
    property DLLList: TList<TDLLInfo>
             read FDLLList;
  end;

implementation

end.
