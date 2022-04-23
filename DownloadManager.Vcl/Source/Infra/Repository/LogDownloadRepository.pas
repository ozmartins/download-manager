unit LogDownloadRepository;

interface

uses
  Data.SqlExpr, LogDownload, Datasnap.Provider, Datasnap.DBClient, Repository,
  System.Generics.Collections, System.Variants;

type
  TLogDownloadRepository = class(TRepository<TLogDownload>)
  private
    procedure MapFieldsFromEntityToDataSet(ALogDownload: TLogDownload);
  public
    procedure Insert(AEntity: TLogDownload); override;
    procedure Update(AId: Variant; AEntity: TLogDownload); override;
    procedure Delete(AId: Variant); override;
    procedure SelectById(AId: Variant); override;
    procedure SelectAll(); override;
  end;

implementation

uses
  System.SysUtils, RepositoryConsts;

/// <summary>Removes a specific log register from the database.</summary>
/// <param name="AId">The record ID you want to remove.</param>
procedure TLogDownloadRepository.Delete(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);

  fClientDataSet.Delete();

  PersistToDataBase();
end;

/// <summary>Inserts a log register into the database.</summary>
/// <param name="AEntity">The entity with the log data.</param>
procedure TLogDownloadRepository.Insert(AEntity: TLogDownload);
begin
  OpenDataSetWithNoRegistry(cLogDownloadTableName);

  fClientDataSet.Append;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

/// <summary>A private method that maps data from TLogDownload to a dataset.</summary>
/// <param name="AEntity">The entity with the log data.</param>
procedure TLogDownloadRepository.MapFieldsFromEntityToDataSet(ALogDownload: TLogDownload);
begin
  fClientDataSet.FieldByName(cIdFieldName).Value := ALogDownload.Id;
  fClientDataSet.FieldByName(cUrlFieldName).Value := ALogDownload.Url;
  fClientDataSet.FieldByName(cStartDateFieldName).Value := ALogDownload.StartDate;
  fClientDataSet.FieldByName(cFinishDateFieldName).Value := ALogDownload.FinishDate;
end;

/// <summary> Uses the internal dataset to retrieve all the log entries from the database.</summary>
procedure TLogDownloadRepository.SelectAll();
begin
  OpenDataSetWithAllRegistries(cLogDownloadTableName);
end;

/// <summary> Uses the internal dataset to retrieve a specific log entry from the database.</summary>
/// <param name="AId">The record ID you want to recover.</param>
procedure TLogDownloadRepository.SelectById(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);
end;

/// <summary>Updates a specific log register in the database.</summary>
/// <param name="AId">The record ID you want to update.</param>
/// <param name="AEntity">The entity with the log data.</param>
procedure TLogDownloadRepository.Update(AId: Variant; AEntity: TLogDownload);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);

  fClientDataSet.Edit;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

end.
