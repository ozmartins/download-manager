unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Data.DbxSqlite, Data.SqlExpr, Data.FMTBcd, Vcl.StdCtrls,
  Datasnap.Provider, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  Vcl.ComCtrls, DateUtils, System.StrUtils, System.Threading, Data.DBXMySQL,
  DownloadManager, Downloader, SimpleNetHTTPRequestProxy, Observer, LogDownloadRepository;

type
  TMainForm = class(TForm, IObserver)
    SqLiteConnection: TSQLConnection;
    LogDownloadSqlDataSet: TSQLDataSet;
    LogDownloadDataSource: TDataSource;
    LogDownloadClientDataSet: TClientDataSet;
    LogDownloadProvider: TDataSetProvider;
    DownloadGroupBox: TGroupBox;
    UrlEdit: TEdit;
    DownloadButton: TButton;
    StopButton: TButton;
    ProgressBar: TProgressBar;
    StatusBar: TStatusBar;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    SequenceSQLDataSet: TSQLDataSet;
    SequenceDataSetProvider: TDataSetProvider;
    SequenceClientDataSet: TClientDataSet;
    SequenceDataSource: TDataSource;
    ViewProgressButton: TButton;
    HistoryButton: TButton;

    procedure FormCreate(Sender: TObject);
    procedure DownloadButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
    procedure HistoryButtonClick(Sender: TObject);
    procedure ViewProgressButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HistoryGroupBoxClick(Sender: TObject);
  private
    fDownloader: TDownloader;
    fDownloadManager: TDownloadManager;
    fHttpRequest: TSimpleNetHTTPRequestProxy;
    fLogDownloadRepository: TLogDownloadRepository;
    fLastShownMessage: String;

    function GetDestinationDirectory(): String;
    procedure CreateDownloader();
    procedure CreateLogDownloadRepository();
    procedure CreateDownloadManager();
    procedure SetupSQLConnection(ASQLConnection: TSQLConnection);
    procedure ConfigureComponentEnablement(ADownloadState: TDownloaderState);
    procedure LogDownloadRepository;
    procedure CheckAbortedDownload();
    procedure CheckCompletedDownload();
    procedure CheckLastError();
  public
    procedure Notify();
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Math;

const
  cEmptyUrlMessage = 'Você precisa informar a URL antes de clicar no botão "Download".';
  cDownloaderIsBusy = 'Já existe um download em andamento e a ferramenta não suporta downloads simultâneos. Por favor aguarde.';
  cDownloaderCantStopNow = 'Não há downloads em andamento no momento.';
  cDownloadCompleted = 'Download concluído com sucesso! O arquivo está disponível em %s';
  cDownloadAborted = 'Download abortado pelo usuário';
  cDatabaseParameter = 'Database';
  cDatabaseFileExtension = '.db';
  cScrollBarWidth = 20;
  cDownloadDirectoryName = 'Download';
  cDownloadProgressMessage = 'Progresso do download: %d';
  cDownloadInterruptConfirmation = 'Existe um download em andamento, deseja interrompe-lo';

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
begin
  if Trim(UrlEdit.Text) = EmptyStr then
    MessageDlg(cEmptyUrlMessage, mtInformation, [mbOk], 0)
  else if fDownloader.State <> TDownloaderState.dsIdle then
    MessageDlg(cDownloaderIsBusy, mtInformation, [mbOk], 0)
  else
    fDownloadManager.DownloadAsync(UrlEdit.Text, GetDestinationDirectory());
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if (fDownloader.State = TDownloaderState.dsDownloading) then
    if MessageDlg(cDownloadInterruptConfirmation, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      CanClose := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  fLastShownMessage := EmptyStr;

  SetupSQLConnection(SqLiteConnection);

  CreateDownloader();

  CreateLogDownloadRepository();

  CreateDownloadManager();

  fLogDownloadRepository.SelectAll();
end;

procedure TMainForm.HistoryButtonClick(Sender: TObject);
begin
  fLogDownloadRepository.SelectAll();
end;

procedure TMainForm.HistoryGroupBoxClick(Sender: TObject);
begin
  ShowMessage(LogDownloadSqlDataSet.CommandText)
end;

procedure TMainForm.LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
begin
  raise E;
end;

procedure TMainForm.Notify;
begin
  ConfigureComponentEnablement(fDownloader.State);

  Application.ProcessMessages();

  CheckAbortedDownload();

  CheckCompletedDownload();

  ProgressBar.Position := IfThen(fDownloader.State = TDownloaderState.dsIdle, 0, Trunc(fDownloadManager.GetProgress()));

  CheckLastError();
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  if fDownloader.State <> TDownloaderState.dsDownloading then
    MessageDlg(cDownloaderCantStopNow, mtInformation, [mbOk], 0);

  fDownloadManager.Stop();
end;

procedure TMainForm.ViewProgressButtonClick(Sender: TObject);
begin
  MessageDlg(Format(cDownloadProgressMessage, [Trunc(fDownloader.Progress)]), mtInformation, [mbOk], 0);
end;

function TMainForm.GetDestinationDirectory: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + cDownloadDirectoryName;
end;

procedure TMainForm.SetupSQLConnection(ASQLConnection: TSQLConnection);
begin
  ASQLConnection.Close;
  ASQLConnection.Params.Clear();
  ASQLConnection.Params.Add('DriverUnit=Data.DbxSqlite');
  ASQLConnection.Params.Add('DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bpl');
  ASQLConnection.Params.Add('MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqliteDriver280.bpl');
  ASQLConnection.Params.Add('FailIfMissing=True');
  ASQLConnection.Params.Add('Database='+ChangeFileExt(Application.ExeName, '.db'));
  ASQLConnection.Open;
end;

procedure TMainForm.ConfigureComponentEnablement(ADownloadState: TDownloaderState);
begin
  StopButton.Enabled := ADownloadState = TDownloaderState.dsDownloading;
  ViewProgressButton.Enabled := ADownloadState = TDownloaderState.dsDownloading;
  ProgressBar.Visible := ADownloadState = TDownloaderState.dsDownloading;
  UrlEdit.Visible := ADownloadState <> TDownloaderState.dsDownloading;
end;

procedure TMainForm.CreateDownloader;
begin
  fHttpRequest := TSimpleNetHTTPRequestProxy.Create(NetHTTPRequest);
  fDownloader := TDownloader.Create(fHttpRequest);
  fDownloader.Subject.AddObserver(Self);
end;

procedure TMainForm.CreateDownloadManager;
begin
  fDownloadManager := TDownloadManager.Create(fDownloader, fLogDownloadRepository);
  fDownloadManager.Subject.AddObserver(Self);
end;

procedure TMainForm.CreateLogDownloadRepository;
begin
  fLogDownloadRepository := TLogDownloadRepository.Create(
    SqLiteConnection,
    LogDownloadSqlDataSet,
    LogDownloadClientDataSet,
    SequenceSqlDataSet,
    SequenceClientDataSet
  );
end;

procedure TMainForm.LogDownloadRepository;
begin
  if (fDownloader.State = TDownloaderState.dsAborted) and (fLastShownMessage <> cDownloadAborted) then
  begin
    MessageDlg(Format(cDownloadAborted, [GetDestinationDirectory()]), mtWarning, [mbOk], 0);
    fLastShownMessage := cDownloadAborted;
  end;
end;

procedure TMainForm.CheckAbortedDownload;
begin
  if (fDownloader.State = TDownloaderState.dsAborted) and (fLastShownMessage <> cDownloadAborted) then
  begin
    MessageDlg(Format(cDownloadAborted, [GetDestinationDirectory()]), mtWarning, [mbOk], 0);
    fLastShownMessage := cDownloadAborted;
  end;
end;

procedure TMainForm.CheckCompletedDownload;
begin
  if (fDownloader.State = TDownloaderState.dsIdle) and (fDownloadManager.GetProgress() >= 100) and (fLastShownMessage <> cDownloadCompleted) then
  begin
    MessageDlg(Format(cDownloadCompleted, [GetDestinationDirectory()]), mtInformation, [mbOk], 0);
    fLastShownMessage := cDownloadCompleted;
  end;
end;

procedure TMainForm.CheckLastError;
var
  lLastError: String;
begin
  lLastError := fDownloader.PopLastError();

  if lLastError.IsEmpty then
    lLastError := fDownloadManager.PopLastError();

  if not lLastError.IsEmpty then
    MessageDlg(lLastError, mtError, [mbOk], 0);
end;

end.
