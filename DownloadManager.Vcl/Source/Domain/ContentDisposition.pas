unit ContentDisposition;

interface

const
  cInLine = 'inline';
  cAttachment = 'attachment';

  cContentDispositionTypeNameInLine = 'cdtInLine';
  cContentDispositionTypeNameAttachment = 'cdtAttachment';

  cInvalidContentDispositionTypeMessage = 'Erro interno: Valor inválido para o parâmetro AContentDisposition.';

type
  TContentDispositionType = (cdtInLine = 0, cdtAttachment = 1);

  /// <summary>
  /// This is a class used to extract data from Content-Disposition.
  /// Content-Disposition is an HTTP header field, which can indicate
  /// if the HTTP response content should be downloaded or displayed.
  /// </summary>
  TContentDisposition = class
  public
    class function ExtractType(AContentDisposition: String): TContentDispositionType;
    class function ExtractFileName(AContentDisposition: String): String;
  end;

implementation

uses System.SysUtils, Constants;

{ TContentDispositionHelper }

/// <summary>Receives a parameter in the following format: 'attachment; filename="file.txt'". So, the function extracts the file name portion from this parameter</summary>
/// <param name="AContentDisposition">Content-Disposition is one of the fields in the HTTP header. So get the Content-Disposition from an HTTP header and call this function to extract the file name (if it exists).</param>
/// <returns>The file name present in the content-disposition parameter, or an empty string if the file name can't be extracted</returns>
class function TContentDisposition.ExtractFileName(AContentDisposition: String): String;
var
  lContentDispositionElements: TArray<String>;
  lFileNameElements: TArray<String>;
  lFileNameInfo: String;
  lFileName: String;
begin
  lFileName := cEmptyString;

  lContentDispositionElements := AContentDisposition.Split([cSemiColon], cQuotes, cQuotes, Length(AContentDisposition), TStringSplitOptions.None);

  if (Length(lContentDispositionElements) > 1) then
  begin
    lFileNameInfo := lContentDispositionElements[1];

    lFileNameElements := lFileNameInfo.Split([cEqualSignal], cQuotes, cQuotes, Length(lFileNameInfo), TStringSplitOptions.None);

    if Length(lFileNameElements) > 1 then
      lFileName := lFileNameElements[1]
    else
      lFileName := cEmptyString;
  end;

  Result := lFileName.Replace(cQuotes, cEmptyString).Trim();
end;

/// <summary>Receives a parameter in the following format: 'attachment; filename="file.txt'". So, the function extracts the file name portion from this parameter</summary>
/// <param name="AContentDisposition">Content-Disposition is one of the fields in the HTTP header. So get the Content-Disposition from an HTTP header and call this function to extract the file name (if it exists).</param>
/// <returns>The file name present in the content-disposition parameter, or an empty string if the file name can't be extracted</returns>
class function TContentDisposition.ExtractType(AContentDisposition: String): TContentDispositionType;
var
  lContentDispositionElements: TArray<String>;
begin
  lContentDispositionElements := AContentDisposition.Split([cSemiColon], cQuotes, cQuotes, Length(AContentDisposition), TStringSplitOptions.None);

  if (Length(lContentDispositionElements) > 0) and (LowerCase(lContentDispositionElements[0]) = cAttachment) then
    Result := TContentDispositionType.cdtAttachment
  else if (Length(lContentDispositionElements) > 0) and (LowerCase(lContentDispositionElements[0]) = cInLine) then
    Result := TContentDispositionType.cdtInLine
  else
    raise Exception.Create(cInvalidContentDispositionTypeMessage);
end;

end.
