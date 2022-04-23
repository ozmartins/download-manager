unit Sequence;

interface

type
  TSequence = class
  private
    fLastId: Int64;
    fTableName: String;
  public
    property LastId: Int64 read fLastId write fLastId;
    property TableName: String read fTableName write fTableName;
    constructor Create(ATableName: String; ALastId: Int64);
  end;

implementation

constructor TSequence.Create(ATableName: String; ALastId: Int64);
begin
  fTableName := ATableName;
  fLastId := ALastId;
end;

end.
