unit DownloadManager;

interface

uses
  System.Contnrs, Observer, Subject, Downloader, FileManager, LogDownload, System.Generics.Collections, LogDownloadRepository;

type
  TDownloadManager = class
  private
    fLastError: String;
    fSubject: TSubject;
    fFileManager: TFileManager;
    fDownloader: TDownloader;
    fLogDownloadRepository: TLogDownloadRepository;
  public
    property Subject: TSubject read fSubject;

    constructor Create(ADownloader: TDownloader; ALogDownloadRepository: TLogDownloadRepository);
    destructor Destroy(); override;

    function Download(AUrl: String; ADestinationDirectory: String): Int64;
    procedure DownloadAsync(AUrl, ADestinationDirectory: String);
    procedure Stop();
    function GetProgress(): Double;
    function PopLastError(): String;
  end;

implementation

uses
  System.SysUtils, Threading, System.Classes, Net.HttpClient,
  ContentDisposition, Variants;

{ TDownloadManager }

constructor TDownloadManager.Create(ADownloader: TDownloader; ALogDownloadRepository: TLogDownloadRepository);
begin
  fLogDownloadRepository := ALogDownloadRepository;
  fFileManager := TFileManager.Create();
  fDownloader := ADownloader;
  fSubject := TSubject.Create();
end;

destructor TDownloadManager.Destroy;
begin
  fDownloader.Free;
  fSubject.Free;
  inherited;
end;

function TDownloadManager.Download(AUrl, ADestinationDirectory: String): Int64;
var
  lFileName: String;
  lHttpResponse: IHttpResponse;
  lStartDate: TDateTime;
begin
  lStartDate := Now;

  lHttpResponse := fDownloader.Download(AUrl);

  lFileName := TContentDisposition.ExtractFileName(lHttpResponse.HeaderValue['Content-Disposition']);

  fFileManager.SaveFile(lHttpResponse.ContentStream, ADestinationDirectory, lFileName, True, True);

  Result := fLogDownloadRepository.Insert(TLogDownload.Create(0, AUrl, lStartDate, Now));
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
          fLastError := e.Message;
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

function TDownloadManager.PopLastError: String;
begin
  Result := fLastError;
  fLastError := EmptyStr;
end;

procedure TDownloadManager.Stop();
begin
  fDownloader.Abort();
end;

end.
