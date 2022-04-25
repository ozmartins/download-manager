unit LogDownloadRepository;

interface

uses
  Data.SqlExpr, LogDownload, Datasnap.Provider, Datasnap.DBClient, Repository,
  System.Generics.Collections, System.Variants, dorm;

type
  TLogDownloadRepository = class(TRepository<TLogDownload>)
  private
    fDormSession: TSession;
  public
    constructor Create();
    destructor Destroy();
  end;

implementation

uses
  System.SysUtils, System.Classes, RepositoryConsts, dorm.Commons;

/// <summary>This method creates an instance of TLogDownloadRepository class.</summary>
/// <returns>Returns an instance of TLogDownloadRepository class.</returns>
constructor TLogDownloadRepository.Create;
begin
  fDormSession := TSession.CreateConfigured(TStreamReader.Create(cDormConfFile), TdormEnvironment.deDevelopment);
end;

/// <summary>Removes a specific log register from the database.</summary>
/// <param name="AId">The record ID you want to remove.</param>
procedure TLogDownloadRepository.Delete(AId: Integer);
var
  lEntity: TLogDownload;
begin
  lEntity := fDormSession.Load<TLogDownload>(AId);
  try
    fDormSession.Delete(lEntity);
  finally
    lEntity.Free;
  end;
end;

/// <summary>Releases the memory allocated by constructor.</summary>
destructor TLogDownloadRepository.Destroy;
begin
  fDormSession.Free;
end;

/// <summary>Inserts a log register into the database.</summary>
/// <param name="AEntity">The entity with the log data.</param>
procedure TLogDownloadRepository.Insert(AEntity: TLogDownload);
begin
  fDormSession.Insert(AEntity);
end;

/// <summary> Uses the internal dataset to retrieve all the log entries from the database.</summary>
function TLogDownloadRepository.SelectAll(): TList<TLogDownload>;
begin
  Result := fDormSession.LoadList<TLogDownload>();
end;

/// <summary> Uses the internal dataset to retrieve a specific log entry from the database.</summary>
/// <param name="AId">The record ID you want to recover.</param>
function TLogDownloadRepository.SelectById(AId: Integer): TLogDownload;
begin
  Result := fDormSession.Load<TLogDownload>(AId);
end;

/// <summary>Updates a specific log register in the database.</summary>
/// <param name="AId">The record ID you want to update.</param>
/// <param name="AEntity">The entity with the log data.</param>
procedure TLogDownloadRepository.Update(AId: Integer; AEntity: TLogDownload);
var
  lEntity: TLogDownload;
begin
  lEntity := fDormSession.Load<TLogDownload>(AId);
  try
    lEntity.Url := AEntity.Url;
    lEntity.CompleteFileName := AEntity.CompleteFileName;
    lEntity.StartDate := AEntity.StartDate;
    lEntity.FinishDate := AEntity.FinishDate;

    fDormSession.Update(lEntity);
  finally
    lEntity.Free
  end;
end;

end.
