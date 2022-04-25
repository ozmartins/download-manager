unit Main;

interface

uses
  Forms, System.Classes, Data.DbxSqlite, Data.FMTBcd, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Datasnap.Provider,
  Datasnap.DBClient, Data.DB, Data.SqlExpr, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Controls, Downloader, DownloadManager, SimpleNetHTTPRequestProxy,
  Observer, MessageQueue, Vcl.Dialogs, LogDownload, Repository;

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
    FileSaveDialog: TFileSaveDialog;

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
    fLogDownloadRepository: TRepository<TLogDownload>;
    fLastShownMessage: String;

    function GetDestinationDirectory(): String;
    function GetDestinationFileName(AUrl: String): String;
    function ExecuteSaveDialog(AUrl: String): String;

    procedure CreateDownloader();
    procedure CreateDownloadManager();
    procedure ConfigureComponentEnablement();
    procedure CheckMessages(); overload;
    procedure CheckMessages(AMessageQueue: TMessageQueue); overload;
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
  System.Math, History, System.SysUtils, StrUtils, DesktopConsts,
  System.UITypes, FileManager;

{$R *.dfm}

procedure TMainForm.DownloadButtonClick(Sender: TObject);
var
  lCompleteFileName: String;
begin
  if Trim(UrlEdit.Text) = EmptyStr then
  begin
    MessageDlg(cEmptyUrlMessage, mtInformation, [mbOk], 0);
    UrlEdit.SetFocus();
  end
  else if fDownloader.Downloading() then
    MessageDlg(cDownloaderIsBusyMessage, mtInformation, [mbOk], 0)
  else
  begin
    lCompleteFileName := ExecuteSaveDialog(UrlEdit.Text);
    if lCompleteFileName.IsEmpty then
      MessageDlg('O nome do arquivo não foi informado.', TMsgDlgType.mtWarning, [mbOk], 0)
    else
      fDownloadManager.DownloadAsync(UrlEdit.Text, lCompleteFileName);
  end;
end;

function TMainForm.ExecuteSaveDialog(AUrl: String): String;
begin
  FileSaveDialog.DefaultFolder := GetDestinationDirectory();

  FileSaveDialog.FileName := GetDestinationFileName(AUrl);

  if FileSaveDialog.Execute() then
    Result := FileSaveDialog.FileName
  else
    Result := EmptyStr;
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

  fLogDownloadRepository := TRepository<TLogDownload>.Create();

  CreateDownloader();

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

function TMainForm.GetDestinationFileName(AUrl: String): String;
var
  lFileName: String;
  lFileExtension: String;
  lFileNameWithouExtension: String;
  lCompleteFileName: String;
  lCount: Integer;
begin
  lCount := 0;

  lFileName := fDownloadManager.ExtractFileName(AUrl);

  lFileNameWithouExtension := ChangeFileExt(lFileName, '');

  lCompleteFileName := TFileManager.BuildCompleteFileName(GetDestinationDirectory(), lFileName);

  while FileExists(lCompleteFileName) do
  begin
    lCount := lCount + 1;

    lFileExtension := ExtractFileExt(lFileName);

    lFileName := Format(lFileNameWithouExtension + ' (%d)' + lFileExtension, [lCount]);

    lCompleteFileName := TFileManager.BuildCompleteFileName(GetDestinationDirectory(), lFileName);
  end;

  Result := lFileName;
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
begin
  fDownloadManager := TDownloadManager.Create(fDownloader, fLogDownloadRepository);

  fDownloadManager.Subject.AddObserver(Self);
end;

procedure TMainForm.CheckMessages();
begin
  CheckMessages(fDownloader.MessageQueue);
  CheckMessages(fDownloadManager.MessageQueue);
end;

procedure TMainForm.CheckMessages(AMessageQueue: TMessageQueue);
var
  lLastMsg: String;
begin
  lLastMsg := AMessageQueue.Pull();
  while not lLastMsg.IsEmpty do
  begin
    Log(lLastMsg);
    lLastMsg := AMessageQueue.Pull();
  end;
end;

end.
