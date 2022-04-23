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

procedure TLogDownloadRepository.Delete(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);

  fClientDataSet.Delete();

  PersistToDataBase();
end;


procedure TLogDownloadRepository.Insert(AEntity: TLogDownload);
begin
  OpenDataSetWithNoRegistry(cLogDownloadTableName);

  fClientDataSet.Append;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

procedure TLogDownloadRepository.MapFieldsFromEntityToDataSet(ALogDownload: TLogDownload);
begin
  fClientDataSet.FieldByName(cIdFieldName).Value := ALogDownload.Id;
  fClientDataSet.FieldByName(cUrlFieldName).Value := ALogDownload.Url;
  fClientDataSet.FieldByName(cStartDateFieldName).Value := ALogDownload.StartDate;
  fClientDataSet.FieldByName(cFinishDateFieldName).Value := ALogDownload.FinishDate;
end;

procedure TLogDownloadRepository.SelectAll();
begin
  OpenDataSetWithAllRegistries(cLogDownloadTableName);
end;

procedure TLogDownloadRepository.SelectById(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);
end;

procedure TLogDownloadRepository.Update(AId: Variant; AEntity: TLogDownload);
begin
  OpenDataSetWithOneRegistry(cLogDownloadTableName, cIdFieldName, AId);

  fClientDataSet.Edit;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

end.
