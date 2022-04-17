unit SequenceRepository;

interface

uses
  Data.SqlExpr, Sequence, Datasnap.Provider, Datasnap.DBClient, Repository,
  System.Generics.Collections;

type
  TSequenceRepository = class(TRepository<TSequence>)
  private
    procedure MapFieldsFromEntityToDataSet(ASequence: TSequence);
  public
    procedure Insert(AEntity: TSequence); override;
    procedure Update(AId: Variant; AEntity: TSequence); override;
    procedure Delete(AId: Variant); override;
    procedure SelectById(AId: Variant); override;
    procedure SelectAll(); override;
  end;

implementation

uses
  System.SysUtils, RepositoryConsts;

{ TSequenceRepository }

procedure TSequenceRepository.Delete(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cSequenceTableName, cTableNameFieldName, AId);

  fClientDataSet.Delete();

  PersistToDataBase();
end;


procedure TSequenceRepository.Insert(AEntity: TSequence);
begin
  OpenDataSetWithNoRegistry(cSequenceTableName);

  fClientDataSet.Append;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

procedure TSequenceRepository.MapFieldsFromEntityToDataSet(ASequence: TSequence);
begin
  fClientDataSet.FieldByName(cLastIdFieldName).Value := ASequence.LastId;
  fClientDataSet.FieldByName(cTableNameFieldName).Value := ASequence.TableName;
end;

procedure TSequenceRepository.SelectAll();
begin
  OpenDataSetWithAllRegistries(cSequenceTableName);
end;

procedure TSequenceRepository.SelectById(AId: Variant);
begin
  OpenDataSet(cSequenceTableName, AId);
end;

procedure TSequenceRepository.Update(AId: Variant; AEntity: TSequence);
begin
  OpenDataSetWithOneRegistry(cSequenceTableName, cTableNameFieldName, AEntity.TableName);

  fClientDataSet.Edit;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

end.
