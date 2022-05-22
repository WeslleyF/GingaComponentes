unit GResource;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources;

type
  TGResource = class(TComponent)
  private
    FResource : string;
    FBaseURL  : string;
    FToken    : string;
  protected

  public

  published
    property Resource : string read FResource write FResource;
    property BaseURL  : string read FBaseURL  write FBaseURL;
    property Token    : string read FToken    write FToken;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I gresource_icon.lrs}
  RegisterComponents('Ginga', [TGResource]);
end;

end.
