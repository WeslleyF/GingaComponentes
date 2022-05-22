unit BufDatasetAPI;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, ginga.parser;

type
  TBufDatasetAPI = class(TBufDataset)
  private
    FConectedAPI  : Boolean;
    FResource     : string;
    FModel        : TModel;
  protected
  public
    property Model : TModel read FModel write FModel;
  published
    property ConectedAPI : Boolean read FConectedAPI write FConectedAPI;
    property Resource    : string  read FResource    write FResource;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Ginga', [TBufDatasetAPI]);
end;

end.
