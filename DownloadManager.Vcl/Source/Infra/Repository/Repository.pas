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

/// <summary>This method creates an instance of TSequence class.</summary>
/// <param name="ATableName">The name of table which ID will be tracked.</param>
/// <returns>It returns an instance of TSequence class.</returns>
constructor TRepository<TEntity>.Create(ASqlDataSet: TSqlDataSet; AClientDataSet: TClientDataSet);
begin
  fSqlDataSet := ASqlDataSet;
  fClientDataSet := AClientDataSet;
  fClientDataSet.OnReconcileError := OnReconcileError;
end;

/// <summary>A private method to deal with dataset OnReconcileError event.</summary>
/// <param name="DataSet">The dataset that triggered the event.</param>
/// <param name="E">The exception object.</param>
/// <param name="UpdateKind">Indicates if the exception occurred during insertion, updating, or deleting.</param>
/// <param name="Action">A var parameter that allows us to decide how to respond to the error.</param>
procedure TRepository<TEntity>.OnReconcileError(DataSet: TCustomClientDataSet; E: EReconcileError; UpdateKind: TUpdateKind; var Action: TReconcileAction);
begin
  fLastError := E.Message;
end;

/// <summary>Opens the internal dataset using a 1=2 expression.</summary>
/// <param name="ATableName">The table name is used in the SELECT statement.</param>
/// <remarks>If the internal dataset retrieves one or more records, an exception is thrown.</remarks>
procedure TRepository<TEntity>.OpenDataSetWithNoRegistry(ATableName: String);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForNoRegistry, [ATableName]);

  OpenDataSet(lSql, []);

  if fClientDataSet.RecordCount > 0 then
    raise Exception.Create(cMoreThanZeroRegistryFound);
end;

/// <summary>Opens the internal dataset using the ASql parameter.</summary>
/// <param name="ASql">The SQL statement was used to open the dataset.</param>
/// <param name="AParams">An array of params is used to bind the SQL statement.</param>
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

/// <summary>Opens the internal dataset using no WHERE expression.</summary>
/// <param name="ATableName">The table name is used in the SELECT statement.</param>
procedure TRepository<TEntity>.OpenDataSetWithAllRegistries(ATableName: String);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForAllRegistries, [ATableName]);
  OpenDataSet(lSql, []);
end;

/// <summary>Opens the internal dataset using the primary key in the WHERE expression.</summary>
/// <param name="ATableName">The table name is used in the SELECT statement.</param>
/// <param name="AIdFieldName">The name of the primary key field.</param>
/// <remarks>If the internal dataset retrieves a number of records different from one, an exception is thrown.</remarks>
procedure TRepository<TEntity>.OpenDataSetWithOneRegistry(ATableName, AIdFieldName: String; AId: Variant);
var
  lSql: String;
begin
  lSql := Format(cCommandTextForOneRegistry, [ATableName, AIdFieldName]);

  OpenDataSet(lSql, [AId]);

  if fClientDataSet.RecordCount <> 1 then
    raise Exception.Create(cMoreThanOneRegistryFound);
end;

/// <summary>Commits the data to the database and checks for persistence errors.</summary>
/// <remarks>If an error occurs during the persistence, an exception is thrown.</remarks>
procedure TRepository<TEntity>.PersistToDataBase;
var
  lErrorsCount: Integer;
begin
  lErrorsCount := fClientDataSet.ApplyUpdates(0);

  if lErrorsCount > 0 then
    raise Exception.Create(IfThen(fLastError.IsEmpty, cUnknownError));
end;

/// <summary>Opens the internal dataset using the ASql parameter.</summary>
/// <param name="ASql">The SQL statement was used to open the dataset.</param>
/// <param name="AParams">An array of params is used to bind the SQL statement.</param>
procedure TRepository<TEntity>.Select(ASql: String; AParams: array of variant);
begin
  OpenDataSet(ASql, AParams);
end;

end.
