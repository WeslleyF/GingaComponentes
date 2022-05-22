unit APIInformation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs;

type
  TAPIInformation = class(TComponent)
  private
    FBaseURL : string;
  protected

  public

  published
    property BaseURL : string read FBaseURL write FBaseURL;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I apiinformation_icon.lrs}
  RegisterComponents('Ginga',[TAPIInformation]);
end;

end.
