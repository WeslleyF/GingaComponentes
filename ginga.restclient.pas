unit ginga.restclient;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, IdHTTP, Classes, fpjson;

type
  TMetodo = (TMGet, TMPost, TMPut, TMDelete);

  { TGingaRestClient }

  TGingaRestClient = class
    private
      FIdHttp      : TIdHTTP;
      FRecurso     : string;
      FEnderecoAPI : string;
      FURL         : string;

      procedure ConfigURL;
      procedure LancarErro(e : EIdHTTPProtocolException);
      procedure PrepararToken(aToken : string);
    public
      function Executar(aTipo : TMetodo; aToken : string; aBody : TStringStream; aParams : array of Variant) : TStringStream;

      constructor Criar(aRecurso, aEnderecoAPI : string);
      destructor Destruir;

      property Recurso : string read FRecurso;
  end;

implementation

uses
  Variants, Ginga.parser, Ginga.Erro;

{ TGingaRestClient }

procedure TGingaRestClient.ConfigURL;
begin
  FURL := Format('%s/%s', [FEnderecoAPI, FRecurso]);
end;

procedure TGingaRestClient.LancarErro(e: EIdHTTPProtocolException);
var
  aErroAPI  : TGingaErroAPI;
  aErroBody : TStringStream;
begin
  try
    // Preenchendo o FResponse com o body do erro porque o indy não carrega
    // corretamente em caso de erro no servidor/Cliente (HTTP 500..)
    aErroBody := TStringStream.Create(e.ErrorMessage);

    aErroAPI  := TGingaErroAPI.Create;
    GingaParser.ObterRespostaO(aErroBody, aErroAPI);
    raise Exception.Create(aErroAPI.Mensagem);
  finally
    aErroAPI.Free;
    aErroBody.Free;
  end;
end;

procedure TGingaRestClient.PrepararToken(aToken: string);
var
  aIndexToken : integer;
begin
  aIndexToken := FIdHttp.Request.CustomHeaders.IndexOfName('Authorization:Bearer');
  if aIndexToken <> -1 then FIdHttp.Request.CustomHeaders.Delete(aIndexToken);

  if aToken.IsEmpty then Exit;

  FIdHTTP.Request.CustomHeaders.FoldLines := False;
  FIdHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' +  aToken;
end;

function TGingaRestClient.Executar(aTipo: TMetodo; aToken: string; aBody: TStringStream; aParams: array of Variant): TStringStream;
var
  aResponse  : TMemoryStream;
  aURLParams, aURL : string;

  procedure MontarURL;
  var
    i : integer;
  begin
    for i := 0 to High(aParams) do
    begin
      if aURLParams = '' then aURLParams := VarToStr('/' + VarToStr(aParams[i]))
      else aURLParams := Format('%s/%s', [aURLParams, VarToStr(aParams[i])]);
    end;
  end;
begin
  aURLParams := '';
  MontarURL;
  aURL := FURL + aURLParams;

  try
    PrepararToken(aToken);

    aResponse := TMemoryStream.Create;
    if not Assigned(aBody) then aBody := TStringStream.Create;

    try
      case aTipo of
        TMGet    : FIdHttp.Get(aURL, aResponse);
        TMPost   : FIdHttp.Post(aURL, aBody, aResponse);
        TMPut    : FIdHttp.Put(aURL, aBody, aResponse);
        TMDelete : FIdHttp.Delete(aURL);
      end;

      // Prepara o retorno
      // É resposabilidade da classe cliente liberar o objeto retornado
      if aResponse.Size <> 0 then
      begin
        Result := TStringStream.Create;
        Result.LoadFromStream(aResponse);
        Result.Position:= 0;
      end;
    except
      on e : EIdHTTPProtocolException do
      begin
        LancarErro(e);
      end;
  end;
  finally
    aResponse.Free;
    aBody.Free;
  end;
end;

constructor TGingaRestClient.Criar(aRecurso, aEnderecoAPI: string);
begin
  FIdHttp  := TIdHttp.Create;
  FIdHttp.Request.Accept      := 'application/json';
  FIdHttp.Request.ContentType := 'application/json';

  FRecurso     := aRecurso;
  FEnderecoAPI := aEnderecoAPI;
  ConfigURL;
end;

destructor TGingaRestClient.Destruir;
begin
  FIdHttp.Free;
end;

end.

