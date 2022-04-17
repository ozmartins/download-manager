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
  Main in 'Source\Desktop\Main.pas' ,
  History in 'Source\Desktop\History.pas',
  MessageQueue in 'Source\Infra\MessageQueue.pas',
  DesktopConsts in 'Source\Desktop\DesktopConsts.pas',
  IdGenerator in 'Source\Infra\Repository\IdGenerator.pas',
  Sequence in 'Source\Infra\Repository\Sequence.pas',
  SequenceRepository in 'Source\Infra\Repository\SequenceRepository.pas',
  RepositoryConsts in 'Source\Infra\Repository\RepositoryConsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
