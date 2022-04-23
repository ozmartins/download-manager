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

/// <summary>Removes a specific register from sequence table in the database.</summary>
/// <param name="AId">The record ID you want to remove.</param>
procedure TSequenceRepository.Delete(AId: Variant);
begin
  OpenDataSetWithOneRegistry(cSequenceTableName, cTableNameFieldName, AId);

  fClientDataSet.Delete();

  PersistToDataBase();
end;

/// <summary>Inserts a register into the sequence table in the database.</summary>
/// <param name="AEntity">The entity with the log data.</param>
procedure TSequenceRepository.Insert(AEntity: TSequence);
begin
  OpenDataSetWithNoRegistry(cSequenceTableName);

  fClientDataSet.Append;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

/// <summary>A private method that maps data from TSequence to a dataset.</summary>
/// <param name="AEntity">The entity with the sequence data.</param>
procedure TSequenceRepository.MapFieldsFromEntityToDataSet(ASequence: TSequence);
begin
  fClientDataSet.FieldByName(cLastIdFieldName).Value := ASequence.LastId;
  fClientDataSet.FieldByName(cTableNameFieldName).Value := ASequence.TableName;
end;

/// <summary>Uses the internal dataset to retrieve all the entries from the sequence table in the database.</summary>
procedure TSequenceRepository.SelectAll();
begin
  OpenDataSetWithAllRegistries(cSequenceTableName);
end;

/// <summary>Uses the internal dataset to retrieve a specific entry from the sequence table in the database.</summary>
/// <param name="AId">The record ID you want to recover.</param>
procedure TSequenceRepository.SelectById(AId: Variant);
begin
  OpenDataSet(cSequenceTableName, AId);
end;

/// <summary>Updates a specific sequence register in the database.</summary>
/// <param name="AId">The record ID you want to update.</param>
/// <param name="AEntity">The entity with the sequence data.</param>
procedure TSequenceRepository.Update(AId: Variant; AEntity: TSequence);
begin
  OpenDataSetWithOneRegistry(cSequenceTableName, cTableNameFieldName, AEntity.TableName);

  fClientDataSet.Edit;

  MapFieldsFromEntityToDataSet(AEntity);

  fClientDataSet.Post;

  PersistToDataBase();
end;

end.
