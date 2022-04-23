unit Repository;

interface

uses
  Data.SqlExpr, DataSnap.DBClient, Data.DB;

type
  TRepository<TEntity> = class
  private
    procedure OnReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
  protected
    fSqlDataSet: TSQLDataSet;
    fClientDataSet: TClientDataSet;
    fLastError: String;

    procedure OpenDataSet(ASql: String; AParams: Array of variant);
    procedure OpenDataSetWithAllRegistries(ATableName: String);
    procedure OpenDataSetWithNoRegistry(ATableName: String);
    procedure OpenDataSetWithOneRegistry(ATableName, AIdFieldName: String; AId: Variant);
    procedure PersistToDataBase();
  public
    constructor Create(ASqlDataSet: TSqlDataSet; AClientDataSet: TClientDataSet);

    procedure Insert(AEntity: TEntity); virtual; abstract;
    procedure Update(AId: Variant; AEntity: TEntity); virtual; abstract;
    procedure Delete(AId: Variant); virtual; abstract;
    procedure SelectById(AId: Variant); virtual; abstract;
    procedure SelectAll(); virtual; abstract;
    procedure Select(ASql: String; AParams: Array of variant);
  end;

implementation

uses
  System.SysUtils, StrUtils, RepositoryConsts;

constructor TRepository<TEntity>.Create(ASqlDataSet: TSqlDataSet; AClientDataSet: TClientDataSet);
begin
  fSqlDataSet := ASqlDataSet;
  fClientDataSet := AClientDataSet;
  fClientDataSet.OnReconcileError := OnReconcileError;
end;

procedure TRepository<TEntity>.OnReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
begin
  fLastError := E.Message;
end;

procedure TRepository<TEntity>.OpenDataSetWithNoRegistry(ATableName: String);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForNoRegistry, [ATableName]);

  OpenDataSet(lSql, []);

  if fClientDataSet.RecordCount > 0 then
    raise Exception.Create(cMoreThanZeroRegistryFound);
end;

procedure TRepository<TEntity>.OpenDataSet(ASql: String; AParams: Array of variant);
var
  I: Integer;
begin
  fSqlDataSet.Close;

  fSqlDataSet.CommandText := ASql;

  for I := Low(AParams) to High(AParams) do
    fSqlDataSet.Params[0].Value := AParams[I];

  fSqlDataSet.Open;

  fClientDataSet.Close();

  fClientDataSet.Open();
end;

procedure TRepository<TEntity>.OpenDataSetWithAllRegistries(ATableName: String);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForAllRegistries, [ATableName]);
  OpenDataSet(lSql, []);
end;

procedure TRepository<TEntity>.OpenDataSetWithOneRegistry(ATableName, AIdFieldName: String; AId: Variant);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForOneRegistry, [ATableName, AIdFieldName]);

  OpenDataSet(lSql, [AId]);

  if fClientDataSet.RecordCount <> 1 then
    raise Exception.Create(cMoreThanOneRegistryFound);
end;

procedure TRepository<TEntity>.PersistToDataBase;
var
  lErrorsCount: Integer;
begin
  lErrorsCount := fClientDataSet.ApplyUpdates(0);

  if lErrorsCount > 0 then
    raise Exception.Create(IfThen(fLastError.IsEmpty, cUnknownError));
end;

procedure TRepository<TEntity>.Select(ASql: String; AParams: array of variant);
begin
  OpenDataSet(ASql, AParams);
end;

end.
