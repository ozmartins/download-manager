program DownloadManager.Vcl;

uses
  Vcl.Forms,
  Observer in 'Source\Infra\Observer\Observer.pas',
  Subject in 'Source\Infra\Observer\Subject.pas',
  ContentDisposition in 'Source\Domain\ContentDisposition.pas',
  Constants in 'Source\Infra\Constants.pas',
  FileManager in 'Source\Domain\FileManager.pas',
  GuidGenerator in 'Source\Infra\GuidGenerator.pas',
  Downloader in 'Source\Domain\Downloader.pas',
  SimpleNetHTTPRequest in 'Source\Infra\SimpleNetHTTPRequest.pas',
  SimpleNetHTTPRequestProxy in 'Source\Infra\SimpleNetHTTPRequestProxy.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
