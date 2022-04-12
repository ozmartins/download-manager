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
    HistoryGroupBox: TGroupBox;
    HistoryDownloadsGrid: TDBGrid;
    SequenceSQLDataSet: TSQLDataSet;
    SequenceDataSetProvider: TDataSetProvider;
    SequenceClientDataSet: TClientDataSet;
    SequenceDataSource: TDataSource;

    procedure FormCreate(Sender: TObject);
    procedure DownloadButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
    procedure HistoryGroupBoxClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    fDownloader: TDownloader;
    fDownloadManager: TDownloadManager;
    fHttpRequest: TSimpleNetHTTPRequestProxy;
    fLogDownloadRepository: TLogDownloadRepository;
    fLastShownMessage: String;

    function GetDestinationDirectory(): String;
    procedure SetupSQLConnection(ASQLConnection: TSQLConnection);
  public
    procedure Notify();
  end;

var
  MainForm: TMainForm;

implementation

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

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
begin
  if Trim(UrlEdit.Text) = EmptyStr then
    MessageDlg(cEmptyUrlMessage, mtInformation, [mbOk], 0)
  else if fDownloader.State <> TDownloaderState.dsIdle then
    MessageDlg(cDownloaderIsBusy, mtInformation, [mbOk], 0)
  else
  begin
    DownloadButton.Enabled := False;
    try
      fDownloadManager.DownloadAsync(UrlEdit.Text, GetDestinationDirectory());
      StopButton.Enabled := True;
    except
      on e: Exception do
      begin
        DownloadButton.Enabled :=True;
        StopButton.Enabled := False;
        raise Exception.Create(e.Message);
      end;
    end;
  end
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SetupSQLConnection(SqLiteConnection);

  fLastShownMessage := EmptyStr;

  fHttpRequest := TSimpleNetHTTPRequestProxy.Create(NetHTTPRequest);

  fDownloader := TDownloader.Create(fHttpRequest);
  fDownloader.Subject.AddObserver(Self);

  fLogDownloadRepository := TLogDownloadRepository.Create(
    SqLiteConnection,
    LogDownloadSqlDataSet,
    LogDownloadClientDataSet,
    SequenceSqlDataSet,
    SequenceClientDataSet
  );
  fLogDownloadRepository.SelectAll();

  fDownloadManager := TDownloadManager.Create(fDownloader, fLogDownloadRepository);
  fDownloadManager.Subject.AddObserver(Self);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  HistoryDownloadsGrid.Columns[1].Width :=
      HistoryDownloadsGrid.ClientWidth
    - HistoryDownloadsGrid.Columns[0].Width
    - HistoryDownloadsGrid.Columns[2].Width
    - HistoryDownloadsGrid.Columns[3].Width
    - cScrollBarWidth
end;

function TMainForm.GetDestinationDirectory: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + cDownloadDirectoryName;
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
var
  lLastError: String;
begin
  ProgressBar.Position := Trunc(fDownloadManager.GetProgress());
  DownloadButton.Enabled := fDownloader.State = TDownloaderState.dsIdle;
  StopButton.Enabled := fDownloader.State = TDownloaderState.dsDownloading;
  Application.ProcessMessages();

  if (fDownloader.State = TDownloaderState.dsAborted) and (fLastShownMessage <> cDownloadAborted) then
  begin
    MessageDlg(Format(cDownloadAborted, [GetDestinationDirectory()]), mtWarning, [mbOk], 0);
    fLastShownMessage := cDownloadAborted;
  end;

  if (fDownloader.State = TDownloaderState.dsIdle) and (fDownloadManager.GetProgress() >= 100) and (fLastShownMessage <> cDownloadCompleted) then
  begin
    MessageDlg(Format(cDownloadCompleted, [GetDestinationDirectory()]), mtInformation, [mbOk], 0);
    fLastShownMessage := cDownloadCompleted;
  end;

  if (fDownloader.State = TDownloaderState.dsIdle) then
    ProgressBar.Position := 0;

  lLastError := fDownloader.PopLastError();
  if not lLastError.IsEmpty then
    MessageDlg(lLastError, mtError, [mbOk], 0);

  lLastError := fDownloadManager.PopLastError();
  if not lLastError.IsEmpty then
    MessageDlg(lLastError, mtError, [mbOk], 0);
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

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  if fDownloader.State <> TDownloaderState.dsDownloading then
    MessageDlg(cDownloaderCantStopNow, mtInformation, [mbOk], 0)
  else
  begin
    fDownloadManager.Stop();
    DownloadButton.Enabled := True;
    StopButton.Enabled := False;
  end;
end;

end.
