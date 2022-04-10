unit Downloader;

interface

uses
  SimpleNetHTTPRequest, System.Net.HttpClient, Subject, System.Net.Mime, System.Net.HttpClientComponent ;

const
  cDownloaderIsNotDownloading = 'Internal error: Downloader isn''t downloading now.';
  cDownloaderIsBusy = 'Internal error: Downloader is busy now. Try again later';
  cUrlIsEmpty = 'Internal error: The AUrl argument is empty.';
  cUrlIsNotALink = 'Internal error: The AUrl argument doesn''t stand for a download link.';
  cResponseHeaderDoesNotContainsContentField = 'Internal error: The response header doesn''t have the Content-Disposition field.';
  cContentDisposition = 'Content-Disposition';
  cNetHTTPRequestIsNull = 'The ANetHTTPRequestIsNull argument can''t be null.';

type
  TDownloaderState = (dsIdle, dsDownloading, dsAborted);

  TDownloader = class
  private
    fSubject: TSubject;
    fHttpRequest: ISimpleNetHTTPRequest;
    fProgress: Double;
    fState: TDownloaderState;

    procedure OnReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
    procedure OnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);

    function Downloadable(AUrl: String): Boolean;
  public
    property Subject: TSubject read fSubject;
    property Progress: Double read fProgress;
    property State: TDownloaderState read fState;

    constructor Create(AHttpRequest: ISimpleNetHttpRequest);
    destructor Destroy(); override;

    function Download(AUrl: String): IHttpResponse;
    procedure Abort();
  end;

implementation

uses
  System.SysUtils, ContentDisposition;

{ TDownloader }

/// <summary> Interrupts the downloading process.</summary>
/// <remarks>If no downloading is being performed, raises an exception.</remarks>
procedure TDownloader.Abort;
begin
  if fState <> TDownloaderState.dsDownloading then
    raise Exception.Create(cDownloaderIsNotDownloading);

  fState := TDownloaderState.dsAborted;
end;

/// <summary>This method creates an instance of TDownloader class.</summary>
/// <param name="ANetHTTPRequest">An instance of TNetHTTPRequest will be used to execute the download. Is not necessary to feed the "Client" property.</param>
/// <remarks>If ANetHTTPRequest is null, raises an exception.</remarks>
/// <returns>It returns an instance of TDownloader class.</returns>
constructor TDownloader.Create(AHttpRequest: ISimpleNetHttpRequest);
begin
  if AHttpRequest = nil then
    raise Exception.Create(cNetHTTPRequestIsNull);

  fHttpRequest := AHttpRequest;
  fHttpRequest.Client := TNetHTTPClient.Create(nil);
  fHttpRequest.OnReceiveData := OnReceiveData;
  fHttpRequest.OnRequestCompleted := OnRequestCompleted;

  fProgress := 0;
  fState := TDownloaderState.dsIdle;
  fSubject := TSubject.Create();
end;

/// <summary>It frees the allocated memory by the class constructor.</summary>
destructor TDownloader.Destroy;
begin
  fSubject.Free;
  fHttpRequest.Client.Free;
  inherited;
end;

/// <summary>Download a file from a URL</summary>
/// <param name="AUrl">The URL from where the file will be downloaded</param>
/// <remarks>
/// If the AUrl argument is empty, an exception is thrown.
/// If the AUrl argument doesn't stand for a download link, an exception is thrown.
/// If a download is already being executed, an exception is thrown.
/// </remarks>
/// <returns>Returns a IHttpResponse interface</returns>
function TDownloader.Download(AUrl: String): IHttpResponse;
begin
  if AUrl.IsEmpty() then
    raise Exception.Create(cUrlIsEmpty);

  if not Downloadable(AUrl) then
    raise Exception.Create(cUrlIsNotALink);

  if fState <> TDownloaderState.dsIdle then
    raise Exception.Create(cDownloaderIsBusy);

  fState := TDownloaderState.dsDownloading;

  Result := fHttpRequest.Get(AUrl);
end;

/// <summary>A private method that analyses the HTTP header to check if the URL stands for a download link.</summary>
/// <param name="AUrl">The URL you want to check.</param>
/// <returns>If the Content-Disposition field in the HTTP header has a file name, returns true, otherwise returns false.</returns>
function TDownloader.Downloadable(AUrl: String): Boolean;
var
  lResponse: IHttpResponse;
begin
  if AUrl.IsEmpty() then
    raise Exception.Create(cUrlIsEmpty);

  lResponse := fHttpRequest.Head(AUrl);
  try
    if (not lResponse.ContainsHeader(cContentDisposition)) then
      raise Exception.Create(cResponseHeaderDoesNotContainsContentField);

    Result := TContentDisposition.ExtractType(lResponse.HeaderValue[cContentDisposition]) = cdtAttachment;
  finally
    lResponse._Release();
  end;
end;

/// <summary>Private method used to deal with fNetHTTPRequest.OnReceiveData event. This method keep track on download progress.</summary>
procedure TDownloader.OnReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  if fState = TDownloaderState.dsAborted then
  begin
    AAbort := True;
    fState := TDownloaderState.dsIdle;
  end;

  if AContentLength <> 0 then
    fProgress := AReadCount / AContentLength  * 100;

  Subject.NotifyObservers();
end;

/// <summary>A private method that is used to deal with fNetHTTPRequest.OnRequestCompleted event. This method just puts the downloader in an idle state.</summary>
procedure TDownloader.OnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
  fState := TDownloaderState.dsIdle;
end;

end.
