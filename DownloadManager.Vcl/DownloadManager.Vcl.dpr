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
  SimpleNetHTTPRequest in 'Source\Infra\Network\SimpleNetHTTPRequest.pas',
  SimpleNetHTTPRequestProxy in 'Source\Infra\Network\SimpleNetHTTPRequestProxy.pas',
  LogDownload in 'Source\Domain\LogDownload.pas',
  Repository in 'Source\Infra\Repository\Repository.pas',
  LogDownloadRepository in 'Source\Infra\Repository\LogDownloadRepository.pas',
  DownloadManager in 'Source\Domain\DownloadManager.pas',
  Main in 'Source\Desktop\Main.pas' {Form1},
  History in 'Source\Desktop\History.pas' {HistoryForm},
  MessageQueue in 'Source\Infra\MessageQueue.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
