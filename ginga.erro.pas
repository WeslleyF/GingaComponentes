unit Ginga.Erro;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type
  TGingaErroAPI = class
  private
    FHttpStatus: Integer;
    FMensagem: string;
  published
    property HttpStatus: Integer read FHttpStatus write FHttpStatus;
    property Mensagem: string read FMensagem write FMensagem;
  end;

implementation

end.
