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
    HistorySQLDataSet: TSQLDataSet;
    HistoryDataSetProvider: TDataSetProvider;
    HistoryClientDataSet: TClientDataSet;
    HistorySQLDataSetDataSource: TDataSource;
    SqLiteConnection: TSQLConnection;
    StatusBar1: TStatusBar;
    HistoryDBGrid: TDBGrid;
    HistoryClientDataSetCodigo: TLargeintField;
    HistoryClientDataSetUrl: TWideStringField;
    HistoryClientDataSetDataInicio: TWideMemoField;
    HistoryClientDataSetDataFim: TWideMemoField;
    HistorySQLDataSetCodigo: TLargeintField;
    HistorySQLDataSetUrl: TWideStringField;
    HistorySQLDataSetDataInicio: TWideMemoField;
    HistorySQLDataSetDataFim: TWideMemoField;

    procedure CloseButtonClick(Sender: TObject);
    procedure DateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HistoryForm: THistoryForm;

implementation

{$R *.dfm}

const
  cScrollBarWidth = 37;

procedure THistoryForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure THistoryForm.DateGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := DateTimeToStr(StrToDateTime(Sender.AsString));
end;

procedure THistoryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HistoryClientDataSet.Close;
  HistorySQLDataSet.Close;
  SqLiteConnection.Close;
end;

procedure THistoryForm.FormResize(Sender: TObject);
begin
  HistoryDBGrid.Columns[2].Width :=
    + HistoryDBGrid.Width
    - HistoryDBGrid.Columns[0].Width
    - HistoryDBGrid.Columns[1].Width
    - cScrollBarWidth;
end;

procedure THistoryForm.FormShow(Sender: TObject);
begin
  HistoryClientDataSet.Close;
  HistoryClientDataSet.Open;
end;

end.
