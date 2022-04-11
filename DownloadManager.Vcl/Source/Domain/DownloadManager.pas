unit DownloadManager;

interface

uses
  System.Contnrs, Observer, Subject, Downloader, FileManager, LogDownload, System.Generics.Collections, LogDownloadRepository;

type
  TDownloadManager = class
  private
    fFileManager: TFileManager;
    fDownloader: TDownloader;
    fLogDownloadRepository: TLogDownloadRepository;
  public
    constructor Create(ADownloader: TDownloader);
    destructor Destroy(); override;

    function Download(AUrl: String; ADestinationDirectory: String): Int64;
    function DownloadAsync(AUrl, ADestinationDirectory: String): Int64;
    procedure Stop(ADonwloadId: Int64);
    function GetProgress(ADonwloadId: Int64): Double;
    function GetLogs(): TList<TLogDownload>;
  end;

implementation

uses
  System.SysUtils, Threading, System.Classes, Net.HttpClient,
  ContentDisposition, Variants;

{ TDownloadManager }

constructor TDownloadManager.Create(ADownloader: TDownloader);
begin
  fLogDownloadRepository := TLogDownloadRepository.Create('');
  fFileManager := TFileManager.Create();
  fDownloader := ADownloader;
end;

destructor TDownloadManager.Destroy;
begin
  fDownloader.Free;
  inherited;
end;

function TDownloadManager.Download(AUrl, ADestinationDirectory: String): Int64;
var
  lFileName: String;
  lHttpResponse: IHttpResponse;
begin
  Result := fLogDownloadRepository.Insert(TLogDownload.Create(null, AUrl, Now, null));

  lHttpResponse := fDownloader.Download(AUrl);

  lFileName := TContentDisposition.ExtractFileName(lHttpResponse.HeaderValue['Content-Disposition']);

  fFileManager.SaveFile(lHttpResponse.ContentStream, ADestinationDirectory, lFileName);
end;

function TDownloadManager.DownloadAsync(AUrl, ADestinationDirectory: String): Int64;
begin
  TTask.Run(procedure begin Self.Download(AUrl, ADestinationDirectory); end);

  Result := 0;
end;

function TDownloadManager.GetLogs: TList<TLogDownload>;
begin
  Result := nil;
end;

function TDownloadManager.GetProgress(ADonwloadId: Int64): Double;
begin
  Result := fDownloader.Progress;
end;

procedure TDownloadManager.Stop(ADonwloadId: Int64);
begin
  fDownloader.Abort();
end;

end.
