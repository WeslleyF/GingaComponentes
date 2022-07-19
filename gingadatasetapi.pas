unit GingaDatasetAPI;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, memds;

type

  { TGingaDatasetAPI }

  TGingaDatasetAPI = class(TMemDataset)
  private
    FExecutarEventos : Boolean;

    // sobrepondo eventos padrão para evitar chamadas desnecessarias a API
    procedure DoAfterDelete; overload;
    procedure DoAfterEdit; overload;
    procedure DoAfterInsert; overload;
    procedure DoAfterOpen; overload;
    procedure DoAfterPost; overload;
    procedure DoAfterRefresh; overload;
  protected

  public
    constructor Create(AOwner:TComponent); override;
  published
    property ExecutarEventos : Boolean read FExecutarEventos write FExecutarEventos;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Ginga', [TGingaDatasetAPI]);
end;

{ TGingaDatasetAPI }

procedure TGingaDatasetAPI.DoAfterDelete;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

procedure TGingaDatasetAPI.DoAfterEdit;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

procedure TGingaDatasetAPI.DoAfterInsert;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

procedure TGingaDatasetAPI.DoAfterOpen;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

procedure TGingaDatasetAPI.DoAfterPost;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

procedure TGingaDatasetAPI.DoAfterRefresh;
begin
  if not FExecutarEventos then exit;

  Inherited;
end;

constructor TGingaDatasetAPI.Create(AOwner: TComponent);
begin
  FExecutarEventos := True;
  inherited Create(AOwner);
end;

end.
