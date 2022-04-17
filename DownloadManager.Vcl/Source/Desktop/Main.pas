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
    procedure CreateDownloader();
    procedure CreateLogDownloadRepository();
    procedure CreateDownloadManager();
    procedure SetupSQLConnection(ASQLConnection: TSQLConnection);
    procedure ConfigureComponentEnablement();
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
  System.Math, History, System.SysUtils, Vcl.Dialogs, StrUtils, DesktopConsts,
  System.UITypes, IdGenerator, SequenceRepository;

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
begin
  if Trim(UrlEdit.Text) = EmptyStr then
  begin
    MessageDlg(cEmptyUrlMessage, mtInformation, [mbOk], 0);
    UrlEdit.SetFocus();
  end
  else if fDownloader.Downloading() then
    MessageDlg(cDownloaderIsBusyMessage, mtInformation, [mbOk], 0)
  else
    fDownloadManager.DownloadAsync(UrlEdit.Text, GetDestinationDirectory());
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if fDownloader.Downloading() then
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
  ConfigureComponentEnablement();

  UpdateProgressBar();

  UpdateViewProgressButton();

  CheckMessages();  

  if fCloseTheWindowWhenDownloadFinishes and (not fDownloader.Downloading()) then
    Self.Close()
  else
    Application.ProcessMessages();
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  if not fDownloader.Downloading() then
    MessageDlg(cDownloaderCantStopNowMessage, mtInformation, [mbOk], 0)
  else
    fDownloadManager.Stop();
end;

procedure TMainForm.UpdateProgressBar;
begin
  ProgressBar.Position := IfThen(fDownloader.Downloading(), Trunc(fDownloadManager.GetProgress()), 0);
end;

procedure TMainForm.UpdateViewProgressButton;
begin
  if fShowProgressOnButtonCaption and fDownloader.Downloading() then
    ViewProgressButton.Caption := Format(cDownloadProgressMessage, [Trunc(fDownloader.Progress).ToString()+'%'])
  else
    ViewProgressButton.Caption := cViewMessageButtonCaption;
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

procedure TMainForm.ConfigureComponentEnablement();
begin
  StopButton.Enabled := fDownloader.Downloading();
  ProgressBar.Visible := fDownloader.Downloading();
  ViewProgressButton.Enabled := fDownloader.Downloading();

  UrlEdit.Visible := not fDownloader.Downloading();
  HistoryButton.Enabled := not fDownloader.Downloading();
  DownloadButton.Enabled := not fDownloader.Downloading();
end;

procedure TMainForm.CreateDownloader;
begin
  fHttpRequest := TSimpleNetHTTPRequestProxy.Create(NetHTTPRequest);
  fDownloader := TDownloader.Create(fHttpRequest);
  fDownloader.Subject.AddObserver(Self);
end;

procedure TMainForm.CreateDownloadManager;
var
  lSequenceRepository: TSequenceRepository;
  lIdGenerator: TIdGenerator;
begin
  lSequenceRepository := TSequenceRepository.Create(SequenceSQLDataSet, SequenceClientDataSet);

  lIdGenerator := TIdGenerator.Create(lSequenceRepository, SequenceClientDataSet);

  fDownloadManager := TDownloadManager.Create(fDownloader, fLogDownloadRepository, lIdGenerator);

  fDownloadManager.Subject.AddObserver(Self);
end;

procedure TMainForm.CreateLogDownloadRepository;
begin
  fLogDownloadRepository := TLogDownloadRepository.Create(LogDownloadSqlDataSet, LogDownloadClientDataSet);
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
