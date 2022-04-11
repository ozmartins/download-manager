unit LogDownloadRepository;

interface

uses
  Data.SqlExpr, LogDownload, Datasnap.Provider, Datasnap.DBClient, Repository,
  System.Generics.Collections;

type
  TLogDownloadRepository = class(TRepository<TLogDownload>)
  public
    constructor Create(ASqlConnection: TSQLConnection; 
      ASqlDataSet: TSqlDataSet; AClientDataSet: TClientDataSet;
      ASeqSqlDataSet: TSQLDataSet; AseqClientDataSet: TClientDataSet
    );

    function Insert(AEntity: TLogDownload): Int64; override;
    procedure Update(AEntity: TLogDownload); override;
    procedure Delete(AId: Int64); override;
    procedure SelectById(AId: Int64); override;
    procedure SelectAll(); override;
  end;

implementation

uses
  System.SysUtils;

const
  cTableName = 'logdownload';

  cIdFieldIndex = 0;
  cUrlFieldIndex = 1;
  cStartDateFieldIndex = 2;
  cFinishDateFieldIndex = 3;
  
  cCommandTextForOneRegistry = 'select codigo, url, datainicio, datafim from logdownload where codigo = :codigo';
  cCommandTextForEmptyDataSet = 'select codigo, url, datainicio, datafim from logdownload where 1=2';
  cCommandTextForSelectAll = 'select codigo, url, datainicio, datafim as datafim from logdownload';

  cMoreThanOneRegistryFound = 'Something very odd happened: There is more than one registry in the database with %d ID. Run to the hills. Now!';
  cMaxRegistriesPerPageViolated = 'Pages can have a maximum of 100 registries';

  cMaxRegistriesPerPage = 100;

{ TLogDownloadRepository }

constructor TLogDownloadRepository.Create(ASqlConnection: TSQLConnection; 
  ASqlDataSet: TSQLDataSet; AClientDataSet: TClientDataSet;
  ASeqSqlDataSet: TSQLDataSet; AseqClientDataSet: TClientDataSet
);
begin
  fSqlConnection := ASqlConnection;

  fSqlDataSet := ASqlDataSet;
  fClientDataSet := AClientDataSet;

  fSeqSqlDataSet := ASeqSqlDataSet;
  fSeqClientDataSet := ASeqClientDataSet;
end;

procedure TLogDownloadRepository.Delete(AId: Int64);
var
  lErrorsCount: Integer;
begin
  fSqlDataSet.Close;
  fSqlDataSet.CommandText := cCommandTextForOneRegistry;
  fSqlDataSet.Params[0].Value := AId;
  fSqlDataSet.Open;

  fClientDataSet.Close();
  fClientDataSet.Open();

  if fClientDataSet.RecordCount <> 1 then
    raise Exception.Create(cMoreThanOneRegistryFound);

  fClientDataSet.Delete();

  lErrorsCount := fClientDataSet.ApplyUpdates(0);

  if lErrorsCount > 0 then
    raise Exception.Create(LastError);
end;


function TLogDownloadRepository.Insert(AEntity: TLogDownload): Int64;
var
  lId: Int64;
  lErrorsCount: Integer;
begin
  lId := GenerateId(cTableName);
  
  fSqlDataSet.Close;
  fSqlDataSet.CommandText := cCommandTextForEmptyDataSet;
  fSqlDataSet.Open;

  fClientDataSet.Close();
  fClientDataSet.Open();

  fClientDataSet.Append;
  fClientDataSet.Fields[cIdFieldIndex].Value := lId;
  fClientDataSet.Fields[cUrlFieldIndex].Value := AEntity.Url;
  fClientDataSet.Fields[cStartDateFieldIndex].Value := AEntity.StartDate;
  fClientDataSet.Fields[cFinishDateFieldIndex].Value := AEntity.FinishDate;
  fClientDataSet.Post;

  lErrorsCount := fClientDataSet.ApplyUpdates(0);

  if lErrorsCount > 0 then
    raise Exception.Create(LastError);

  Result := lId;
end;

//APageNumber is zero based!
procedure TLogDownloadRepository.SelectAll();
begin
  fSqlDataSet.Close;
  fSqlDataSet.CommandText := cCommandTextForSelectAll;
  fSqlDataSet.Open;

  fClientDataSet.Close();
  fClientDataSet.Open();
end;

procedure TLogDownloadRepository.SelectById(AId: Int64);
begin
  fSqlDataSet.Close;
  fSqlDataSet.CommandText := cCommandTextForOneRegistry;
  fSqlDataSet.Params[0].Value := AId;
  fSqlDataSet.Open;

  fClientDataSet.Close();
  fClientDataSet.Open();

  if fClientDataSet.RecordCount <> 1 then
    raise Exception.Create(cMoreThanOneRegistryFound);
end;

procedure TLogDownloadRepository.Update(AEntity: TLogDownload);
var
  lErrorsCount: Integer;
begin
  fSqlDataSet.Close;
  fSqlDataSet.CommandText := cCommandTextForOneRegistry;
  fSqlDataSet.Params[0].Value := AEntity.Id;
  fSqlDataSet.Open;

  fClientDataSet.Close();
  fClientDataSet.Open();

  if fClientDataSet.RecordCount <> 1 then
    raise Exception.Create(cMoreThanOneRegistryFound);

  fClientDataSet.Edit;
  fClientDataSet.Fields[cUrlFieldIndex].Value := AEntity.Url;
  fClientDataSet.Fields[cStartDateFieldIndex].Value := AEntity.StartDate;
  fClientDataSet.Fields[cFinishDateFieldIndex].Value := AEntity.FinishDate;
  fClientDataSet.Post;

  lErrorsCount := fClientDataSet.ApplyUpdates(0);

  if lErrorsCount > 0 then
    raise Exception.Create(LastError);
end;

end.
