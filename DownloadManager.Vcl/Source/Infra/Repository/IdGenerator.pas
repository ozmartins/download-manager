unit IdGenerator;

interface

uses
  Data.SqlExpr, DataSnap.DBClient, SequenceRepository;

type
  TIdGenerator = class
  private
    fClientDataSet: TClientDataSet;
    fSequenceRepository: TSequenceRepository;
  public
    constructor Create(ASequenceRepository: TSequenceRepository; AClientDataSet: TClientDataSet);

    function GenerateId(ATableName: String): Int64;
  end;

implementation

uses
  System.SysUtils, RepositoryConsts, Sequence, Data.DB;

{ TIdGenerator }

constructor TIdGenerator.Create(ASequenceRepository: TSequenceRepository; AClientDataSet: TClientDataSet);
begin
  fSequenceRepository := ASequenceRepository;
  fClientDataSet := AClientDataSet;
end;

function TIdGenerator.GenerateId(ATableName: String): Int64;
var
  lLastID: Int64;
  lNextID: Int64;
  lSequence: TSequence;
begin
  if ATableName.IsEmpty then
    raise Exception.Create(cTableNameParameterIsEmpty);

  fSequenceRepository.Select(cSelectLastTableID, [ATableName]);

  if fClientDataSet.IsEmpty then
  begin
    lNextID := 1;

    lSequence := TSequence.Create(ATableName, lNextID);
    try
      fSequenceRepository.Insert(lSequence);
    finally
      lSequence.Free;
    end;
  end
  else
  begin
    lLastID := fClientDataSet.FieldByName(cLastIdFieldName).Value;

    lNextID := lLastID + 1;

    fSequenceRepository.Select(cSelectEspecificTableID, [ATableName, lLastID]);

    lSequence := TSequence.Create(ATableName, lNextID);
    try
      fSequenceRepository.Update(ATableName, lSequence);
    finally
      lSequence.Free;
    end;
  end;

  Result := lNextID;
end;

end.
