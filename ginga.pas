{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Ginga;

{$warn 5023 off : no warning about unused units}
interface

uses
  ginga.parser, APIInformation, Ginga.Erro, ginga.restclient, GingaDatasetAPI, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('APIInformation', @APIInformation.Register);
  RegisterUnit('GingaDatasetAPI', @GingaDatasetAPI.Register);
end;

initialization
  RegisterPackage('Ginga', @Register);
end.
