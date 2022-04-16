unit Main;

interface

uses
  Forms, System.Classes, Data.DbxSqlite, Data.FMTBcd, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Datasnap.Provider,
  Datasnap.DBClient, Data.DB, Data.SqlExpr, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Controls, Downloader, DownloadManager, SimpleNetHTTPRequestProxy,
  LogDownloadRepository, Observer;

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
    fCloseTheWindowWhenDownloadFinishes: Boolean;
    fShowProgressOnButtonCaption: Boolean;
    fDownloader: TDownloader;
    fDownloadManager: TDownloadManager;
    fHttpRequest: TSimpleNetHTTPRequestProxy;
    fLogDownloadRepository: TLogDownloadRepository;
    fLastShownMessage: String;

    function GetDestinationDirectory(): String;
    function Downloading(): Boolean;
    procedure CreateDownloader();
    procedure CreateLogDownloadRepository();
    procedure CreateDownloadManager();
    procedure SetupSQLConnection(ASQLConnection: TSQLConnection);
    procedure ConfigureComponentEnablement(ADownloadState: TDownloaderState);
    procedure CheckMessages();
    procedure Log(AText: String);
    procedure ShowHistoryForm();
    procedure UpdateProgressBar();
    procedure UpdateViewProgressButton();
  public
    procedure Notify();
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Math, History, System.SysUtils, Vcl.Dialogs, StrUtils, DesktopConsts;

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
begin
  if Trim(UrlEdit.Text) = EmptyStr then
  begin
    MessageDlg(cEmptyUrlMessage, mtInformation, [mbOk], 0);
    UrlEdit.SetFocus();
  end
  else if Downloading() then
    MessageDlg(cDownloaderIsBusyMessage, mtInformation, [mbOk], 0)
  else
    fDownloadManager.DownloadAsync(UrlEdit.Text, GetDestinationDirectory());
end;

function TMainForm.Downloading: Boolean;
begin
  Result := (fDownloader.State = TDownloaderState.dsDownloading);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Downloading() then
  begin
    CanClose := False;
    if (MessageDlg(cDownloadInterruptConfirmationMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      fDownloadManager.Stop();
      fCloseTheWindowWhenDownloadFinishes := True;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  fLastShownMessage := EmptyStr;

  fCloseTheWindowWhenDownloadFinishes := False;

  fShowProgressOnButtonCaption := False;

  SetupSQLConnection(SqLiteConnection);

  CreateDownloader();

  CreateLogDownloadRepository();

  CreateDownloadManager();
end;

procedure TMainForm.HistoryButtonClick(Sender: TObject);
begin  
  ShowHistoryForm();
end;

procedure TMainForm.Log(AText: String);
begin
  LogMemo.Lines.Add(Format(cLogText, [DateTimeToStr(Now), AText]));
end;

procedure TMainForm.LogDownloadClientDataSetReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
begin
  Log(E.Message);
end;

procedure TMainForm.Notify;
begin
  ConfigureComponentEnablement(fDownloader.State);

  UpdateProgressBar();

  UpdateViewProgressButton();

  CheckMessages();  

  if fCloseTheWindowWhenDownloadFinishes and (not Downloading) then
    Self.Close()
  else
    Application.ProcessMessages();
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  if not Downloading() then
    MessageDlg(cDownloaderCantStopNowMessage, mtInformation, [mbOk], 0)
  else
    fDownloadManager.Stop();
end;

procedure TMainForm.UpdateProgressBar;
begin
  ProgressBar.Position := IfThen(Downloading(), Trunc(fDownloadManager.GetProgress()), 0);

  ViewProgressButton.Caption := IfThen(fDownloadManager.GetProgress >= 100, cViewMessageButtonCaption, ViewProgressButton.Caption);
end;

procedure TMainForm.UpdateViewProgressButton;
var
  lProgressText: String;
begin
  if fShowProgressOnButtonCaption and Downloading() then
    lProgressText := Format(cDownloadProgressMessage, [Trunc(fDownloader.Progress).ToString()+'%'])
  else
    lProgressText := cViewMessageButtonCaption;  
  
  ViewProgressButton.Caption := lProgressText;
end;

procedure TMainForm.ViewProgressButtonClick(Sender: TObject);
begin
  fShowProgressOnButtonCaption := not fShowProgressOnButtonCaption;
  UpdateViewProgressButton();
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
  ASQLConnection.Params.Add(Format(cDatabase, [ChangeFileExt(Application.ExeName, cDatabaseFileExtension)]));
  ASQLConnection.Open;
end;

procedure TMainForm.ShowHistoryForm;
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

procedure TMainForm.ConfigureComponentEnablement(ADownloadState: TDownloaderState);
begin
  DownloadButton.Enabled := ADownloadState = TDownloaderState.dsIdle;
  StopButton.Enabled := ADownloadState = TDownloaderState.dsDownloading;
  ViewProgressButton.Enabled := ADownloadState = TDownloaderState.dsDownloading;
  HistoryButton.Enabled := ADownloadState = TDownloaderState.dsIdle;
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
