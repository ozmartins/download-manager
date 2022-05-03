unit History;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCGrids,
  Data.FMTBcd, Data.DB, Datasnap.DBClient, Datasnap.Provider, Data.SqlExpr,
  Data.DbxSqlite, Vcl.Mask, Vcl.DBCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids;

type
  THistoryForm = class(TForm)
    GridPanel: TPanel;
    ButtonsPanel: TPanel;
    CloseButton: TButton;
    HistoryClientDataSet: TClientDataSet;
    HistorySQLDataSetDataSource: TDataSource;
    StatusBar1: TStatusBar;
    HistoryDBGrid: TDBGrid;
    HistoryClientDataSetCompleteFileName: TStringField;
    HistoryClientDataSetUrl: TStringField;
    HistoryClientDataSetStartDate: TDateTimeField;
    HistoryClientDataSetFinishDate: TDateTimeField;

    procedure CloseButtonClick(Sender: TObject);
    procedure DateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HistoryDBGridDblClick(Sender: TObject);
  private
    procedure SelectFileInExplorer(ACompleteFileName: string);
    procedure LoadDonwnloadLog();
  end;

var
  HistoryForm: THistoryForm;

implementation

uses
  RepositoryConsts, ShellAPI, DesktopConsts, Repository, LogDownload,
  System.Generics.Collections;

{$R *.dfm}

procedure THistoryForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure THistoryForm.DateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
var
  lDateAsString: String;
begin
  if not HistoryClientDataSet.IsEmpty then
  begin
    lDateAsString := Sender.AsString;
    if not lDateAsString.IsEmpty then
      Text := DateTimeToStr(StrToDateTime(lDateAsString));
  end;
end;

procedure THistoryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HistoryClientDataSet.Close;
end;

procedure THistoryForm.FormResize(Sender: TObject);
begin
  HistoryDBGrid.Columns[2].Width :=
    + HistoryDBGrid.Width
    - HistoryDBGrid.Columns[0].Width
    - HistoryDBGrid.Columns[1].Width
    - HistoryDBGrid.Columns[3].Width
    - cScrollBarWidth;
end;

procedure THistoryForm.FormShow(Sender: TObject);
begin
  HistoryClientDataSet.Close;
  HistoryClientDataSet.CreateDataSet;

  HistoryClientDataSetStartDate.OnGetText := DateGetText;
  HistoryClientDataSetFinishDate.OnGetText := DateGetText;

  LoadDonwnloadLog();
end;

procedure THistoryForm.HistoryDBGridDblClick(Sender: TObject);
var
  lCompleteFileName: String;
begin
  if not HistoryClientDataSet.IsEmpty then
  begin
    lCompleteFileName := HistoryClientDataSetCompleteFileName.AsString;
    if not lCompleteFileName.IsEmpty then
      SelectFileInExplorer(lCompleteFileName);
  end;
end;

procedure THistoryForm.LoadDonwnloadLog;
var
  lRepository: TRepository<TLogDownload>;
  lDownloadLogList: TList<TLogDownload>;
  lLogDownload: TLogDownload;
begin
  lRepository := TRepository<TLogDownload>.Create();
  try
    lDownloadLogList := lRepository.SelectAll();
    try
      HistoryClientDataSet.EmptyDataSet;
      for lLogDownload in lDownloadLogList do
      begin
        HistoryClientDataSet.Append;
        HistoryClientDataSetStartDate.Value := lLogDownload.StartDate;
        HistoryClientDataSetFinishDate.Value := lLogDownload.FinishDate;
        HistoryClientDataSetCompleteFileName.Value := lLogDownload.CompleteFileName;
        HistoryClientDataSetUrl.Value := lLogDownload.Url;
        HistoryClientDataSet.Post;
      end;
    finally
      lDownloadLogList.Free
    end;
  finally
    lRepository.Free;
  end;
end;

procedure THistoryForm.SelectFileInExplorer(ACompleteFileName: string);
begin
  ShellExecute(
    Application.Handle,
    cShellExecuteOperationOpen,
    cWindowsExplorer,
    PChar(cShellExecuteOperationParameter + '"' + ACompleteFileName + '"'),
    nil,
    SW_NORMAL
  );
end;

end.
