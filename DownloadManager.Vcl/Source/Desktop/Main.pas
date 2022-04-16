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
    LogMemo: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure DownloadButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
    procedure HistoryButtonClick(Sender: TObject);
    procedure ViewProgressButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
    procedure CheckMessages();
    procedure Log(AText: String);
  public
    procedure Notify();
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Math, History;

const
  cEmptyUrlMessage = 'Você precisa informar a URL antes de clicar no botão "%s".';
  cDownloaderIsBusy = 'Já existe um download em andamento e a ferramenta não suporta downloads simultâneos. Por favor aguarde.';
  cDownloaderCantStopNow = 'Não há downloads em andamento no momento.';
  cDatabaseParameter = 'Database';
  cDatabaseFileExtension = '.db';
  cScrollBarWidth = 20;
  cDownloadDirectoryName = 'Download';
  cDownloadInterruptConfirmation = 'Existe um download em andamento, deseja interrompe-lo';
  cDownloadProgressMessage = 'Progresso = %s';

  cDriverUnit = 'DriverUnit=Data.DbxSqlite';
  cDriverPackageLoader = 'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bpl';
  cMetaDataPackageLoader = 'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqliteDriver280.bpl';
  cFailIfMissing = 'FailIfMissing=True';
  cDatabase = 'Database=%s';
  cViewMessageButtonCaption = 'Ver mensagem';

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
begin
  if Trim(UrlEdit.Text) = EmptyStr then
  begin
    MessageDlg(Format(cEmptyUrlMessage, [DownloadButton.Caption]), mtInformation, [mbOk], 0);
    UrlEdit.SetFocus();
  end
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
  with THistoryForm.Create(Self) do
  begin
    try
      ShowModal();
    finally
      Free;
    end;
  end;
end;

procedure TMainForm.Log(AText: String);
begin
  LogMemo.Lines.Add('['+DateTimeToStr(Now) + '] -> ' + AText);
end;

procedure TMainForm.LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
begin
  raise E;
end;

procedure TMainForm.Notify;
begin
  ConfigureComponentEnablement(fDownloader.State);

  ProgressBar.Position := IfThen(fDownloader.State = TDownloaderState.dsIdle, 0, Trunc(fDownloadManager.GetProgress()));

  CheckMessages();

  ViewProgressButton.Caption := IfThen(fDownloadManager.GetProgress >= 100, cViewMessageButtonCaption, ViewProgressButton.Caption);

  Application.ProcessMessages();
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  if fDownloader.State <> TDownloaderState.dsDownloading then
    MessageDlg(cDownloaderCantStopNow, mtInformation, [mbOk], 0);

  fDownloadManager.Stop();
end;

procedure TMainForm.ViewProgressButtonClick(Sender: TObject);
var
  lProgressText: String;
begin
  lProgressText := Format(cDownloadProgressMessage, [Trunc(fDownloader.Progress).ToString()+'%']);
  ViewProgressButton.Caption := lProgressText;
  Log(lProgressText);
end;

function TMainForm.GetDestinationDirectory: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + cDownloadDirectoryName;
end;

procedure TMainForm.SetupSQLConnection(ASQLConnection: TSQLConnection);
begin
  ASQLConnection.Close;
  ASQLConnection.Params.Clear();
  ASQLConnection.Params.Add(cDriverUnit);
  ASQLConnection.Params.Add(cDriverPackageLoader);
  ASQLConnection.Params.Add(cMetaDataPackageLoader);
  ASQLConnection.Params.Add(cFailIfMissing);
  ASQLConnection.Params.Add(Format(cDatabase, [ChangeFileExt(Application.ExeName, '.db')]));
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

procedure TMainForm.CheckMessages();
var
  lLastMsg: String;
begin
  lLastMsg := fDownloader.MessageQueue.Pull();
  while not lLastMsg.IsEmpty do
  begin
    Log(lLastMsg);
    lLastMsg := fDownloader.MessageQueue.Pull();
  end;

  lLastMsg := fDownloadManager.MessageQueue.Pull();
  while not lLastMsg.IsEmpty do
  begin
    Log(lLastMsg);
    lLastMsg := fDownloadManager.MessageQueue.Pull();
  end;
end;

end.
