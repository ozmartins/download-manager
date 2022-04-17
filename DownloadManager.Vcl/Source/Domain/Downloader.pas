unit Downloader;

interface

uses
  SimpleNetHTTPRequest, System.Net.HttpClient, Subject, System.Net.Mime, System.Net.HttpClientComponent,
  MessageQueue, DomainConsts;

type
  TDownloaderState = (dsIdle, dsDownloading, dsAborted, dsCompleted);

  TDownloader = class
  private
    fSubject: TSubject;
    fHttpRequest: ISimpleNetHTTPRequest;
    fProgress: Double;
    fState: TDownloaderState;
    fMessageQueue: TMessageQueue;

    procedure OnReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
    procedure OnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure OnRequestError(const Sender: TObject; const AError: string);
  public
    property Subject: TSubject read fSubject;
    property MessageQueue: TMessageQueue read fMessageQueue;
    property Progress: Double read fProgress;
    property State: TDownloaderState read fState;

    constructor Create(AHttpRequest: ISimpleNetHTTPRequest);
    destructor Destroy(); override;

    function Download(AUrl: String): IHttpResponse;
    procedure Abort();

    function Downloading(): Boolean;
    function AllowNewDownload(): Boolean;
  end;

implementation

uses
  System.SysUtils, HttpHeaderHelper, Vcl.Dialogs;

{ TDownloader }

/// <summary> Interrupts the downloading process.</summary>
/// <remarks>If no downloading is being performed, raises an exception.</remarks>
procedure TDownloader.Abort;
begin
  if fState <> TDownloaderState.dsDownloading then
    raise Exception.Create(cDownloaderIsNotDownloading);

  fState := TDownloaderState.dsAborted;

  Subject.NotifyObservers();
end;

/// <summary>This method creates an instance of TDownloader class.</summary>
/// <param name="ANetHTTPRequest">An instance of TNetHTTPRequest will be used to execute the download. Is not necessary to feed the "Client" property.</param>
/// <remarks>If ANetHTTPRequest is null, raises an exception.</remarks>
/// <returns>It returns an instance of TDownloader class.</returns>
function TDownloader.AllowNewDownload: Boolean;
begin
  Result := fState <> TDownloaderState.dsDownloading;
end;

constructor TDownloader.Create(AHttpRequest: ISimpleNetHTTPRequest);
begin
  if AHttpRequest = nil then
    raise Exception.Create(cNetHTTPRequestIsNull);

  fHttpRequest := AHttpRequest;
  fHttpRequest.Client := TNetHttpClient.Create(nil);
  fHttpRequest.OnReceiveData := OnReceiveData;
  fHttpRequest.OnRequestCompleted := OnRequestCompleted;
  fHttpRequest.OnRequestError := OnRequestError;

  fProgress := 0;
  fState := TDownloaderState.dsIdle;
  fSubject := TSubject.Create();
  fMessageQueue := TMessageQueue.Create();
end;

/// <summary>It frees the allocated memory by the class constructor.</summary>
destructor TDownloader.Destroy;
begin
  fSubject.Free;
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

  if Downloading() then
    raise Exception.Create(cDownloaderIsBusy);

  fState := TDownloaderState.dsDownloading;

  Result := fHttpRequest.Get(AUrl);

  Subject.NotifyObservers();
end;

function TDownloader.Downloading: Boolean;
begin
  Result := fState = TDownloaderState.dsDownloading;
end;

/// <summary>Private method used to deal with fNetHTTPRequest.OnReceiveData event. This method keep track on download progress.</summary>
procedure TDownloader.OnReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  if AContentLength <> 0 then
    fProgress := AReadCount / AContentLength  * 100;

  AAbort := fState = TDownloaderState.dsAborted;

  Subject.NotifyObservers();
end;

/// <summary>A private method that is used to deal with fNetHTTPRequest.OnRequestCompleted event. This method just puts the downloader in an idle state.</summary>
procedure TDownloader.OnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
  if fProgress >= 100 then
  begin
    fState := TDownloaderState.dsCompleted;
    Subject.NotifyObservers();
  end;
end;

procedure TDownloader.OnRequestError(const Sender: TObject; const AError: string);
begin
  fMessageQueue.Push(AError);
  Subject.NotifyObservers();
end;

end.
