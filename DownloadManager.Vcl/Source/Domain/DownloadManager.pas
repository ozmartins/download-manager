unit DownloadManager;

interface

uses
  System.Contnrs, Observer, Subject, Downloader, FileManager, LogDownload,
  System.Generics.Collections, Repository, MessageQueue, Net.HttpClient;

type
  TDownloadManager = class
  private
    fMessageQueue: TMessageQueue;
    fSubject: TSubject;
    fFileManager: TFileManager;
    fDownloader: TDownloader;
    fLogDownloadRepository: TRepository<TLogDownload>;
    function SaveDownloadedFile(AHttpResponse: IHttpResponse; AUrl, ACompleteFileName: String): String;
    procedure PushMessage(AMessage: String);
    procedure SaveDownloadLog(AUrl, ACompleteFileName: String; AStartDate: TDateTime);
  public
    property Subject: TSubject read fSubject;
    property MessageQueue: TMessageQueue read fMessageQueue;

    constructor Create(ADownloader: TDownloader; ALogDownloadRepository: TRepository<TLogDownload>);
    destructor Destroy(); override;

    procedure Download(AUrl: String; ACompleteFileName: String);
    procedure DownloadAsync(AUrl, ACompleteFileName: String);
    procedure Stop();
    function GetProgress(): Double;
    function ExtractFileName(AUrl: String; AHttpResponse: IHttpResponse): String; overload;
    function ExtractFileName(AUrl: String): String; overload;
  end;

implementation

uses
  System.SysUtils, Threading, System.Classes, HttpHeaderHelper, Variants,
  RepositoryConsts, DomainConsts, IdUri;

/// <summary>This method creates an instance of TDownloadManager class.</summary>
/// <param name="ADownloader">The object used to actually execute performs the download.</param>
/// <param name="ALogDownloadRepository">The repository object that's used to persist the download log.</param>
/// <returns>Returns an instance of TDownloadManager class.</returns>
constructor TDownloadManager.Create(ADownloader: TDownloader; ALogDownloadRepository: TRepository<TLogDownload>);
begin
  fLogDownloadRepository := ALogDownloadRepository;
  fFileManager := TFileManager.Create();
  fDownloader := ADownloader;
  fSubject := TSubject.Create();
  fMessageQueue := TMessageQueue.Create();
end;

/// <summary>It frees the allocated memory by the class constructor.</summary>
destructor TDownloadManager.Destroy;
begin
  fDownloader.Free;
  fSubject.Free;
  fMessageQueue.Free;
  fFileManager.Free;
  inherited;
end;

/// <summary>Performs the HTTP request to initiate the download,
/// saves the file on disk, and persists a log into the database.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="ACompleteFileName">The path, file name and extension of the file will be saved.</param>
procedure TDownloadManager.Download(AUrl, ACompleteFileName: String);
var
  lHttpResponse: IHttpResponse;
  lStartDate: TDateTime;
begin
  PushMessage(cDownloadStarted);

  lStartDate := Now;

  lHttpResponse := fDownloader.Download(AUrl);

  if GetProgress() >= 100 then
  begin
    PushMessage(cDownloadCompleted);

    SaveDownloadedFile(lHttpResponse, AUrl, ACompleteFileName);

    SaveDownloadLog(AUrl, ACompleteFileName, lStartDate);
  end;
end;

/// <summary>Saves the downloaded file on disk</summary>
/// <param name="AHttpResponse">The HTTP response object that contains the file content.</param>
/// <param name="ACompleteFileName">The path, file name and extension of the file will be saved.</param>
/// <param name="AUrl">The URL used to download the file</param>
/// <returns>Returns the created complete file name.</returns>
function TDownloadManager.SaveDownloadedFile(AHttpResponse: IHttpResponse; AUrl, ACompleteFileName: String): String;
begin
  fFileManager.SaveFile(AHttpResponse.ContentStream, ACompleteFileName, True, True);

  PushMessage(Format(cFileSaved, [ACompleteFileName]));

  Result := ACompleteFileName;
end;

/// <summary>Saves the log into the database.</summary>
/// <param name="AUrl">The URL used to download the file</param>
/// <param name="ACompleteFileName">The saved complete file name.</param>
/// <param name="AStartDate">The date and time when the download has started.</param>
procedure TDownloadManager.SaveDownloadLog(AUrl, ACompleteFileName: String; AStartDate: TDateTime);
begin
  fLogDownloadRepository.Insert(TLogDownload.Create(AUrl, ACompleteFileName, AStartDate, Now));

  PushMessage(cLogCreate);
end;

/// <summary> Call the download method through the TTask.Run method.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="ACompleteFileName">The path, file name and extension of the file will be saved.</param>
procedure TDownloadManager.DownloadAsync(AUrl, ACompleteFileName: String);
begin
  TTask.Run(
    procedure ()
    begin
      try
        Self.Download(AUrl, ACompleteFileName);
      except
        on e: Exception do
        begin
          fMessageQueue.Push(e.Message);
          fSubject.NotifyObservers();
        end;
      end;
    end
  );
end;

/// <summary>A method that tries to get the downloaded file name from
/// the HTTP response header or from the request URL.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="AHttpResponse">The HTTP response object returned by the request.</param>
/// <returns>The filename from the content-disposition header field. If it is empty,
/// then return the document component from the request URL.</returns>
function TDownloadManager.ExtractFileName(AUrl: String; AHttpResponse: IHttpResponse): String;
begin
  Result := THttpHeaderHelper.ExtractFileNameFromHeader(AHttpResponse);

  if Result.IsEmpty then
    Result := TIdUri.Create(AUrl).Document;
end;

function TDownloadManager.ExtractFileName(AUrl: String): String;
var
  lHttpResponse: IHttpResponse;
begin
  lHttpResponse := fDownloader.DownloadHeader(AUrl);

  Result := THttpHeaderHelper.ExtractFileNameFromHeader(lHttpResponse);

  if Result.IsEmpty then
    Result := TIdUri.Create(AUrl).Document;
end;

/// <summary>Gets the value of the downloader progress property.</summary>
/// <returns>The value of the downloader progress property.</returns>
function TDownloadManager.GetProgress(): Double;
begin
  Result := fDownloader.Progress;
end;

/// <summary>Pushes a message into the public message queue.</summary>
procedure TDownloadManager.PushMessage(AMessage: String);
begin
  fMessageQueue.Push(AMessage);
  fSubject.NotifyObservers();
end;

/// <summary>Asks for downloader to stop.</summary>
procedure TDownloadManager.Stop();
begin
  fDownloader.Abort();
  fMessageQueue.Push(cDownloadAborted);
end;

end.
