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

/// <summary>Interrupts the downloading process.</summary>
/// <remarks>If no downloading is being performed, raises an exception.</remarks>
procedure TDownloader.Abort;
begin
  if fState <> TDownloaderState.dsDownloading then
    raise Exception.Create(cDownloaderIsNotDownloading);

  fState := TDownloaderState.dsAborted;

  Subject.NotifyObservers();
end;

/// <summary>Checks the downloader state to decide if a new download can be started.</summary>
/// <param name="Item">The item to remove
/// <returns>True if the state is different from "downloading", otherwise, false.</returns>
function TDownloader.AllowNewDownload: Boolean;
begin
  Result := fState <> TDownloaderState.dsDownloading;
end;

/// <summary>This method creates an instance of TDownloader class.</summary>
/// <param name="AHttpRequest">An implementation of ISimpleNetHTTPRequest that will be used to execute the download.</param>
/// <remarks>If AHttpRequest is null, raises an exception.</remarks>
/// <returns>Returns an instance of TDownloader class.</returns>
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
  fMessageQueue.Free;
  inherited;
end;

/// <summary>Download a file from a URL</summary>
/// <param name="AUrl">The URL from where the file will be downloaded</param>
/// <remarks>
/// If the AUrl argument is empty, an exception is thrown.
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

/// <summary>Checks the downloader state to decide if it's performing a download or not.</summary>
/// <returns>True if the state is "Downloading", otherwise, it returns false.</returns>
function TDownloader.Downloading: Boolean;
begin
  Result := fState = TDownloaderState.dsDownloading;
end;

/// <summary>A private method used to deal with fHTTPRequest.OnReceiveData event.
/// This method keeps track of download progress and completes the aborting process.</summary>
/// </param>
/// <param name="Sender">The component that triggered the event.</param>
/// <param name="AContentLength">The total length of the response content.</param>
/// <param name="AReadCount">The number of bytes already downloaded.</param>
/// <param name="AAbort">A parameter that's used to abort the downloading process.</param>
procedure TDownloader.OnReceiveData(const Sender: TObject; AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  if AContentLength <> 0 then
    fProgress := AReadCount / AContentLength  * 100;

  AAbort := fState = TDownloaderState.dsAborted;

  Subject.NotifyObservers();
end;

/// <summary>A private method that is used to deal with fHTTPRequest.OnRequestCompleted event.
/// This method just puts the downloader in the completed state.</summary>
/// <param name="Sender">The component that triggered the event.</param>
/// <param name="AResponse">The complete response to the request.</param>
procedure TDownloader.OnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
  if fProgress >= 100 then
  begin
    fState := TDownloaderState.dsCompleted;
    Subject.NotifyObservers();
  end;
end;

/// <summary>A private method that is used to deal with fHTTPRequest.OnRequestError event.
/// This method just puts an error message in a queue.</summary>
/// <param name="Sender">The component that triggered the event.</param>
/// <param name="AError">The error message.</param>
procedure TDownloader.OnRequestError(const Sender: TObject; const AError: string);
begin
  fMessageQueue.Push(AError);
  Subject.NotifyObservers();
end;

end.
