unit Repository;

interface

uses
  Data.SqlExpr, DataSnap.DBClient, Data.DB, System.Generics.Collections, dorm;

type
  TRepository<TEntity: class> = class
  private
    fDormSession: TSession;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Insert(AEntity: TEntity);
    procedure Delete(AId: Integer);

    function SelectById(AId: Integer): TEntity;
    function SelectAll(): TList<TEntity>;
  end;

implementation

uses
  System.SysUtils, System.Classes, StrUtils, RepositoryConsts, dorm.Commons;

/// <summary>This method creates an instance of TLogDownloadRepository class.</summary>
/// <returns>Returns an instance of TLogDownloadRepository class.</returns>
constructor TRepository<TEntity>.Create;
begin
  fDormSession := TSession.CreateConfigured(TStreamReader.Create(cDormConfFile), TdormEnvironment.deDevelopment);
end;

/// <summary>Removes a specific log register from the database.</summary>
/// <param name="AId">The record ID you want to remove.</param>
procedure TRepository<TEntity>.Delete(AId: Integer);
var
  lEntity: TEntity;
begin
  lEntity := fDormSession.Load<TEntity>(AId);
  try
    fDormSession.Delete(lEntity);
  finally
    lEntity.Free;
  end;
end;

/// <summary>Releases the memory allocated by constructor.</summary>
destructor TRepository<TEntity>.Destroy;
begin
  if Assigned(fDormSession) then
    fDormSession.Free;
end;

/// <summary>Inserts a log register into the database.</summary>
/// <param name="AEntity">The entity with the log data.</param>
procedure TRepository<TEntity>.Insert(AEntity: TEntity);
begin
  fDormSession.Insert(AEntity);
end;

/// <summary> Uses the internal dataset to retrieve all the log entries from the database.</summary>
function TRepository<TEntity>.SelectAll(): TList<TEntity>;
begin
  Result := fDormSession.LoadList<TEntity>();
end;

/// <summary> Uses the internal dataset to retrieve a specific log entry from the database.</summary>
/// <param name="AId">The record ID you want to recover.</param>
function TRepository<TEntity>.SelectById(AId: Integer): TEntity;
begin
  Result := fDormSession.Load<TEntity>(AId);
end;

end.
