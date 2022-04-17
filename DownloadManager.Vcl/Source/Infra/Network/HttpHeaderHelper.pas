unit HttpHeaderHelper;

interface

uses
  DomainConsts, System.Net.HttpClient;

type
  /// <summary>
  /// This is a class used to extract data from Content-Disposition.
  /// Content-Disposition is an HTTP header field, which can indicate
  /// if the HTTP response content should be downloaded or displayed.
  /// </summary>
  THttpHeaderHelper = class
  public
    class function ExtractFileNameFromHeader(AHttpResponse: IHttpResponse): String;
  end;

implementation

uses System.SysUtils, InfraConsts;

{ TContentDispositionHelper }

/// <summary>Receives a parameter in the following format: 'attachment; filename="file.txt'". So, the function extracts the file name portion from this parameter</summary>
/// <param name="AContentDisposition">Content-Disposition is one of the fields in the HTTP header. So get the Content-Disposition from an HTTP header and call this function to extract the file name (if it exists).</param>
/// <returns>The file name present in the content-disposition parameter, or an empty string if the file name can't be extracted</returns>
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
