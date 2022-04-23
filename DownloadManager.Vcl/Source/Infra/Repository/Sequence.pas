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

/// <summary>This method creates an instance of TSequence class.</summary>
/// <param name="ATableName">The name of table which ID will be tracked.</param>
/// <param name="ALastId">The last used ID for a record in the table.</param>
/// <returns>It returns an instance of TSequence class.</returns>
constructor TSequence.Create(ATableName: String; ALastId: Int64);
begin
  fTableName := ATableName;
  fLastId := ALastId;
end;

end.
