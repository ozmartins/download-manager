unit DownloadManager;

interface

uses
  System.Contnrs, Observer, Subject, Downloader, FileManager, LogDownload,
  System.Generics.Collections, LogDownloadRepository, MessageQueue, IdGenerator;

type
  TDownloadManager = class
  private
    fMessageQueue: TMessageQueue;
    fSubject: TSubject;
    fFileManager: TFileManager;
    fDownloader: TDownloader;
    fLogDownloadRepository: TLogDownloadRepository;
    fIdGenerator: TIdGenerator;
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
  System.SysUtils, Threading, System.Classes, Net.HttpClient,
  ContentDisposition, Variants, RepositoryConsts;

const
  cDownloadStarted = 'Download iniciado';
  cDownloadAborted = 'Download abortado pelo usuário';
  cFileSaved = 'Arquivo salvo em "%s"';
  cLogCreate = 'Log do download salvo com sucesso';

{ TDownloadManager }

constructor TDownloadManager.Create(ADownloader: TDownloader; ALogDownloadRepository: TLogDownloadRepository; AIdGenerator: TIdGenerator);
begin
  fLogDownloadRepository := ALogDownloadRepository;
  fFileManager := TFileManager.Create();
  fDownloader := ADownloader;
  fSubject := TSubject.Create();
  fMessageQueue := TMessageQueue.Create();
  fIdGenerator := AIdGenerator;
end;

destructor TDownloadManager.Destroy;
begin
  fDownloader.Free;
  fSubject.Free;
  fMessageQueue.Free;
  inherited;
end;

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

    lFileName := TContentDisposition.ExtractFileName(lHttpResponse.HeaderValue['Content-Disposition']);

    fFileManager.SaveFile(lHttpResponse.ContentStream, ADestinationDirectory, lFileName, True, True);

    PushMessage(Format(cFileSaved, [IncludeTrailingPathDelimiter(ADestinationDirectory) + lFileName]));

    lId := fIdGenerator.GenerateId(cLogDownloadTableName);

    fLogDownloadRepository.Insert(TLogDownload.Create(lId, AUrl, lStartDate, Now));

    PushMessage(cLogCreate);
  end;
end;

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

function TDownloadManager.GetProgress(): Double;
begin
  Result := fDownloader.Progress;
end;

procedure TDownloadManager.PushMessage(AMessage: String);
begin
  fMessageQueue.Push(AMessage);
  fSubject.NotifyObservers();
end;

procedure TDownloadManager.Stop();
begin
  fDownloader.Abort();
  fMessageQueue.Push(cDownloadAborted);
end;

end.
