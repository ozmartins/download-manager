program DownloadManager.Vcl;

uses
  Vcl.Forms,
  Observer in 'Source\Infra\Observer\Observer.pas',
  Subject in 'Source\Infra\Observer\Subject.pas',
  HttpHeaderHelper in 'Source\Infra\Network\HttpHeaderHelper.pas',
  InfraConsts in 'Source\Infra\InfraConsts.pas',
  FileManager in 'Source\Domain\FileManager.pas',
  GuidGenerator in 'Source\Infra\GuidGenerator.pas',
  Downloader in 'Source\Domain\Downloader.pas',
  SimpleNetHTTPRequest in 'Source\Infra\Network\SimpleNetHTTPRequest.pas',
  SimpleNetHTTPRequestProxy in 'Source\Infra\Network\SimpleNetHTTPRequestProxy.pas',
  LogDownload in 'Source\Domain\LogDownload.pas',
  Repository in 'Source\Infra\Repository\Repository.pas',
  DownloadManager in 'Source\Domain\DownloadManager.pas',
  Main in 'Source\Desktop\Main.pas' {Form1},
  History in 'Source\Desktop\History.pas' {HistoryForm},
  MessageQueue in 'Source\Infra\MessageQueue.pas',
  DesktopConsts in 'Source\Desktop\DesktopConsts.pas',
  RepositoryConsts in 'Source\Infra\Repository\RepositoryConsts.pas',
  DomainConsts in 'Source\Domain\DomainConsts.pas',
  ObserverConsts in 'Source\Infra\Observer\ObserverConsts.pas',
  ORMConfigurationBuilder in 'Source\Infra\Repository\ORMConfigurationBuilder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
