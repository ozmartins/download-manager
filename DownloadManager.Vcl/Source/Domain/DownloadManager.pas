unit DownloadManager;

interface

uses
  System.Contnrs, Observer, Subject, Downloader, FileManager, LogDownload,
  System.Generics.Collections, LogDownloadRepository, MessageQueue, IdGenerator,
  Net.HttpClient;

type
  TDownloadManager = class
  private
    fMessageQueue: TMessageQueue;
    fSubject: TSubject;
    fFileManager: TFileManager;
    fDownloader: TDownloader;
    fLogDownloadRepository: TLogDownloadRepository;
    fIdGenerator: TIdGenerator;
    function GetFileName(AUrl: String; AHttpResponse: IHttpResponse): String;
    procedure PushMessage(AMessage: String);
  public
    property Subject: TSubject read fSubject;
    property MessageQueue: TMessageQueue read fMessageQueue;

    constructor Create(ADownloader: TDownloader; ALogDownloadRepository: TLogDownloadRepository; AIdGenerator: TIdGenerator);
    destructor Destroy(); override;

    procedure Download(AUrl: String; ADestinationDirectory: String);
    procedure DownloadAsync(AUrl, ADestinationDirectory: String);
    procedure Stop();
    function GetProgress(): Double;
  end;

implementation

uses
  System.SysUtils, Threading, System.Classes, HttpHeaderHelper, Variants,
  RepositoryConsts, DomainConsts, IdUri;

{ TDownloadManager }

/// <summary>This method creates an instance of TDownloadManager class.</summary>
/// <param name="ADownloader">The object used to actually execute performs the download.</param>
/// <param name="ALogDownloadRepository">The repository object that's used to persist the download log.</param>
/// <param name="AIdGenerator">The object used by the repository to generate the logs IDs.</param>
/// <returns>Returns an instance of TDownloadManager class.</returns>
constructor TDownloadManager.Create(ADownloader: TDownloader; ALogDownloadRepository: TLogDownloadRepository; AIdGenerator: TIdGenerator);
begin
  fLogDownloadRepository := ALogDownloadRepository;
  fFileManager := TFileManager.Create();
  fDownloader := ADownloader;
  fSubject := TSubject.Create();
  fMessageQueue := TMessageQueue.Create();
  fIdGenerator := AIdGenerator;
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

/// <summary> Performs the HTTP request to initiate the download,
/// saves the file on disk, and persists a log into the database.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="ADestinationDirectory">The directory where the file will be saved.</param>
procedure TDownloadManager.Download(AUrl, ADestinationDirectory: String);
var
  lFileName: String;
  lHttpResponse: IHttpResponse;
  lStartDate: TDateTime;
  lId: Int64;
begin
  PushMessage(cDownloadStarted);

  lStartDate := Now;

  lHttpResponse := fDownloader.Download(AUrl);

  if GetProgress() >= 100 then
  begin
    PushMessage(cDownloadCompleted);

    lFileName := GetFileName(AUrl, lHttpResponse);

    fFileManager.SaveFile(lHttpResponse.ContentStream, ADestinationDirectory, lFileName, True, True);

    PushMessage(Format(cFileSaved, [IncludeTrailingPathDelimiter(ADestinationDirectory) + lFileName]));

    lId := fIdGenerator.GenerateId(cLogDownloadTableName);

    fLogDownloadRepository.Insert(TLogDownload.Create(lId, AUrl, lStartDate, Now));

    PushMessage(cLogCreate);
  end;
end;

/// <summary> Call the download method through the TTask.Run method.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="ADestinationDirectory">The directory where the file will be saved.</param>
procedure TDownloadManager.DownloadAsync(AUrl, ADestinationDirectory: String);
begin
  TTask.Run(
    procedure ()
    begin
      try
        Self.Download(AUrl, ADestinationDirectory);
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

/// <summary>A private method that tries to get the downloaded file name from
/// the HTTP response header or from the request URL.</summary>
/// <param name="AUrl">The URL for the download file.</param>
/// <param name="AHttpResponse">The HTTP response object returned by the request.</param>
/// <returns>The filename from the content-disposition header field. If it is empty,
/// then return the document component from the request URL.</returns>
function TDownloadManager.GetFileName(AUrl: String; AHttpResponse: IHttpResponse): String;
begin
  Result := THttpHeaderHelper.ExtractFileNameFromHeader(AHttpResponse);

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
