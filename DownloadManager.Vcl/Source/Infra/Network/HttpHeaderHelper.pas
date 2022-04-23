unit HttpHeaderHelper;

interface

uses
  DomainConsts, System.Net.HttpClient;

type
  THttpHeaderHelper = class
  public
    class function ExtractFileNameFromHeader(AHttpResponse: IHttpResponse): String;
  end;

implementation

uses System.SysUtils, InfraConsts;

{ TContentDispositionHelper }

/// <summary>Receives an IHttpResponse parameter and looks for the content-disposition field.
/// Content-disposition has the following format: 'attachment; filename="file.txt'".
/// So, the function tries to extract the file name portion from this field.</summary>
/// <param name="AHttpResponse">The response from a HTTP request.</param>
/// <returns>The file name is present in the content-disposition field in the response or an empty string if the file name can't be extracted.</returns>
class function THttpHeaderHelper.ExtractFileNameFromHeader(AHttpResponse: IHttpResponse): String;
var
  lContentDisposition: String;
  lContentDispositionElements: TArray<String>;
  lFileNameElements: TArray<String>;
  lFileNameInfo: String;
  lFileName: String;
begin
  lFileName := cEmptyString;

  if AHttpResponse.ContainsHeader('content-disposition') then
  begin
    lContentDisposition := AHttpResponse.HeaderValue['content-disposition'];

    lContentDispositionElements := lContentDisposition.Split([cSemiColon], cQuotes, cQuotes, Length(lContentDisposition), TStringSplitOptions.None);

    if (Length(lContentDispositionElements) > 1) then
    begin
      lFileNameInfo := lContentDispositionElements[1];

      lFileNameElements := lFileNameInfo.Split([cEqualSignal], cQuotes, cQuotes, Length(lFileNameInfo), TStringSplitOptions.None);

      if Length(lFileNameElements) > 1 then
        lFileName := lFileNameElements[1]
      else
        lFileName := cEmptyString;
    end;

    lFileName := lFileName.Replace(cQuotes, cEmptyString).Trim();
  end;

  Result := lFileName;
end;

end.
