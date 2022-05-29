unit ginga.parser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, DB;

type
  TModel = class of TObject;

  { GingaParser }

  GingaParser = class
    // Esses metódos liberam seus parametros que não serão usados no contexto externo.
    // No caso dos ObterResposta o stream é liberado
    // No caso do ObterStream o objeto é liberado
    class function ObterRespostaV(aStream : TStringStream) : Variant; // Retorna em Variant
    class function ObterRespostaC(aStream : TStringStream; aClasse : TModel) : TFPList; // Retorna em Colection
    class procedure ObterRespostaO(aStream : TStringStream; aObject : TObject); // Retorna em Object
    class function ObterStream(aContent: TObject; aLiberarObjeto : Boolean) : TStringStream; // Retorna o objeto em stream
    class function PreencherBufDataset(aDataSet: TBufDataset; aList: TFPList): Integer;
    class procedure PreencherObjetoComDataSet(aDataset: TDataset; aObjeto: TObject);
    class procedure AtualizarRegistroBufDataset(aDataset: TDataset; aObjeto: TObject);
  end;

implementation

uses
  fpjsonrtti, fpjson, Rtti;

{ GingaParser }

class function GingaParser.ObterRespostaV(aStream: TStringStream): Variant;
begin
  try
    Result  := aStream.ReadString(aStream.Size);
  finally
    aStream.Free;
  end;
end;

class function GingaParser.ObterRespostaC(aStream: TStringStream; aClasse: TModel): TFPList;
var
  aJSONDeStreamer : TJSONDeStreamer;
  aData           : TJSONData;
  aObj            : TObject;
  I               : Integer;
begin
  try
    aJSONDeStreamer := TJSONDeStreamer.Create(nil);
    Result          := TFPList.Create;
    aData           := GetJSON(aStream.ReadString(aStream.Size), True);
    aJSONDeStreamer.Options := aJSONDeStreamer.Options + [jdoCaseInsensitive,jdoIgnorePropertyErrors];

    for I := 0 to aData.Count - 1 do
    begin
      aObj := aClasse.Create;
      aJSONDeStreamer.JSONToObject(aData.Items[I] as TJSONObject, aObj);
      Result.Add(aObj);
    end;
  finally
    aStream.Free;
    aJSONDeStreamer.Free;
    AData.Free;
  end;
end;

class procedure GingaParser.ObterRespostaO(aStream: TStringStream; aObject: TObject);
var
  aJSONDeStreamer : TJSONDeStreamer;
  aData           : TJSONData;
begin
  try
    aJSONDeStreamer := TJSONDeStreamer.Create(nil);
    aData           := GetJSON(aStream.ReadString(aStream.Size), True);
    aJSONDeStreamer.Options := aJSONDeStreamer.Options + [jdoCaseInsensitive,jdoIgnorePropertyErrors];
    aJSONDeStreamer.JSONToObject(aData as TJSONObject, aObject);
  finally
    aStream.Free;
    aJSONDeStreamer.Free;
    AData.Free;
  end;
end;

class function GingaParser.ObterStream(aContent: TObject; aLiberarObjeto: Boolean): TStringStream;
var
  aJSONStreamer : TJSONStreamer;
  aJSONString   : string;
begin
  Result := TStringStream.Create;

  aJSONStreamer := TJSONStreamer.Create(nil);

  try
    aJSONStreamer.Options := aJSONStreamer.Options + [jsoTStringsAsObject];
    aJSONString           := aJSONStreamer.ObjectToJSONString(aContent);

    Result.WriteString(aJSONString);
  finally
    aJSONStreamer.Free;

    if aLiberarObjeto then aContent.Free;
  end;
end;

class function GingaParser.PreencherBufDataset(aDataSet: TBufDataset; aList: TFPList): Integer;
var
  aContextRTTI : TRttiContext;
  aInfoRTTI    : TRttiType;
  aPropRTTI    : TRttiProperty;
  aField       : TField;
  I            : Integer;
begin
  // Para que esta rotina funcione o nome do campo no dataset deve ser o mesmo da propriedade da classe
  Result := aList.Count;
  if Result = 0 then Exit;

  try
    aDataSet.Close;
    aDataSet.CreateDataset;
    aDataSet.Open;

    aContextRTTI := TRttiContext.Create;
    aInfoRTTI := aContextRTTI.GetType(TObject(aList.Items[0]).ClassInfo);

    for I := 0 to aList.Count - 1 do
    begin
      aDataSet.Append;
      for aPropRTTI in aInfoRTTI.GetProperties do
      begin
        aField := aDataSet.FieldByName(aPropRTTI.Name);
        case aField.DataType of
          ftString   : aField.AsString   := aPropRTTI.GetValue(aList.Items[I]).AsString;
          ftInteger  : aField.AsInteger  := aPropRTTI.GetValue(aList.Items[I]).AsInteger;
          ftBoolean  : aField.AsBoolean  := aPropRTTI.GetValue(aList.Items[I]).AsBoolean;
          ftCurrency : aField.AsCurrency := aPropRTTI.GetValue(aList.Items[I]).AsCurrency;
          ftDateTime : aField.AsDateTime := TDateTime(aPropRTTI.GetValue(aList.Items[I]).AsExtended);
          ftFloat    : aField.AsFloat    := aPropRTTI.GetValue(aList.Items[I]).AsExtended;
          else raise Exception.Create('Tipo não tratado.');
        end;
      end;
      aDataSet.Post;
    end;
  finally
    aDataSet.First;
  end
end;

class procedure GingaParser.PreencherObjetoComDataSet(aDataset: TDataset; aObjeto: TObject);
var
  aContextRTTI : TRttiContext;
  aInfoRTTI    : TRttiType;
  aPropRTTI    : TRttiProperty;
  aField       : TField;
begin
  // Para que esta rotina funcione o nome do campo no dataset deve ser o mesmo da propriedade da classe
  if not Assigned(aObjeto) then raise Exception.Create('Objeto não instanciado.');

  aContextRTTI := TRttiContext.Create;
  aInfoRTTI    := aContextRTTI.GetType(aObjeto.ClassInfo);

   for aPropRTTI in aInfoRTTI.GetProperties do
   begin
     aField := aDataSet.FieldByName(aPropRTTI.Name);

     case aField.DataType of
       ftString   : aPropRTTI.SetValue(aObjeto, aField.AsString);
       ftInteger  : aPropRTTI.SetValue(aObjeto, aField.AsInteger);
       ftBoolean  : aPropRTTI.SetValue(aObjeto, aField.AsBoolean);
       ftCurrency : aPropRTTI.SetValue(aObjeto, aField.AsCurrency);
       ftDateTime : aPropRTTI.SetValue(aObjeto, aField.AsDateTime);
       ftFloat    : aPropRTTI.SetValue(aObjeto, aField.AsFloat);
       else raise Exception.Create('Tipo não tratado.');
     end;
   end;
end;

class procedure GingaParser.AtualizarRegistroBufDataset(aDataset: TDataset; aObjeto: TObject);
var
  aContextRTTI : TRttiContext;
  aInfoRTTI    : TRttiType;
  aPropRTTI    : TRttiProperty;
  aField       : TField;
begin
  // Para que esta rotina funcione o nome do campo no dataset deve ser o mesmo da propriedade da classe
  if not Assigned(aObjeto) then raise Exception.Create('Objeto não instanciado.');

  aContextRTTI := TRttiContext.Create;
  aInfoRTTI    := aContextRTTI.GetType(aObjeto.ClassInfo);

  aDataSet.Edit;
  for aPropRTTI in aInfoRTTI.GetProperties do
  begin
    aField := aDataSet.FieldByName(aPropRTTI.Name);
    case aField.DataType of
      ftString   : aField.AsString   := aPropRTTI.GetValue(aObjeto).AsString;
      ftInteger  : aField.AsInteger  := aPropRTTI.GetValue(aObjeto).AsInteger;
      ftBoolean  : aField.AsBoolean  := aPropRTTI.GetValue(aObjeto).AsBoolean;
      ftCurrency : aField.AsCurrency := aPropRTTI.GetValue(aObjeto).AsCurrency;
      ftDateTime : aField.AsDateTime := TDateTime(aPropRTTI.GetValue(aObjeto).AsExtended);
      ftFloat    : aField.AsFloat    := aPropRTTI.GetValue(aObjeto).AsExtended;
      else raise Exception.Create('Tipo não tratado.');
    end;
  end;
  aDataSet.Post;

  aObjeto.Free;
end;

end.

