unit Repository;

interface

uses
  System.Generics.Collections, Data.SqlExpr, Datasnap.Provider, 
  Datasnap.DBClient, Data.DB;

const
  cLastIdField = 'ultimocodigo';
  cTableNameField = 'nometabela';

  cLastIdFieldIndex = 0;
  cTableNameFieldIndex = 1;

  cDriverNameProperty = 'Sqlite';
  cDriverNameParam = 'DriverName=Sqlite';
  cDatabaseParam = 'Database=%s';
  cSelectLastTableID = 'select ultimocodigo, nometabela from sequence where nometabela = :nometabela';
  cSelectEspecificTableID = 'select * from sequence where nometabela = :nometabela and ultimocodigo = :ultimocodigo';

type
  TRepository<TEntity> = class
  private  
    fLastError: String;
  protected
    fSqlConnection: TSQLConnection;

    fSqlDataSet: TSQLDataSet;
    fClientDataSet: TClientDataSet;

    fSeqSqlDataSet: TSQLDataSet;
    fSeqClientDataSet: TClientDataSet;

    property LastError: String read fLastError;

    function GenerateId(ATableName: String): Int64;
  public
    function Insert(AEntity: TEntity): Int64; virtual; abstract;
    procedure Update(AEntity: TEntity); virtual; abstract;
    procedure Delete(AId: Int64); virtual; abstract;
    procedure SelectById(AId: Int64); virtual; abstract;
    procedure SelectAll(); virtual; abstract;
  end;

implementation

uses
  System.SysUtils, Constants, FileManager, System.Classes;

{ TRepository<TEntity> }

function TRepository<TEntity>.GenerateId(ATableName: String): Int64;
var
  lLastID: Int64;
  lNextID: Int64;
  lErrorsCount: Integer;
begin
  fSeqSqlDataSet.Close;
  fSeqSqlDataSet.CommandText := cSelectLastTableID;
  fSeqSqlDataSet.Params[0].Value := ATableName;
  fSeqSqlDataSet.Open;

  fSeqClientDataSet.Close;
  fSeqClientDataSet.Open;

  if fSeqClientDataSet.IsEmpty then
  begin
    fSeqClientDataSet.Append;
    fSeqClientDataSet.Fields[cLastIdFieldIndex].Value := 1;
    fSeqClientDataSet.Fields[cTableNameFieldIndex].Value := ATableName;
    fSeqClientDataSet.Post;

    lErrorsCount := fSeqClientDataSet.ApplyUpdates(0);

    if lErrorsCount > 0 then
      raise Exception.Create(LastError);

    Result := 1;
  end
  else
  begin
    lLastID := fSeqClientDataSet.Fields[cLastIdFieldIndex].Value;
    lNextID := lLastID + 1;

    fSeqSqlDataSet.Close;
    fSeqSqlDataSet.CommandText := cSelectEspecificTableID;
    fSeqSqlDataSet.Params[0].Value := ATableName;
    fSeqSqlDataSet.Params[1].Value := lLastID;
    fSeqSqlDataSet.Open;

    fSeqClientDataSet.Close;
    fSeqClientDataSet.Open;

    fSeqClientDataSet.Edit;
    fSeqClientDataSet.Fields[cLastIdFieldIndex].Value := lNextID;
    fSeqClientDataSet.Post;

    lErrorsCount := fSeqClientDataSet.ApplyUpdates(0);

    if lErrorsCount > 0 then
      raise Exception.Create(LastError);

    Result := lNextID;
  end;
end;

end.
