unit MessageQueue;

interface

uses
  System.Classes;

const
  cMessageParameterIsNull = 'O parâmetro AMessage não pode ser nulo.';

type
  TMessageQueue = class
  private
    fStringList: TStringList;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Push(AMessage: String);
    function Pull(): String;
    function Count(): Integer;
  end;

implementation

uses
  System.SysUtils;

{ TMessageQueue }

/// <summary>Creates an instance of TMessageQueue</summary>
/// <returns>An instance of TMessageQueue</returns>
function TMessageQueue.Count: Integer;
begin
  Result := fStringList.Count;
end;

constructor TMessageQueue.Create;
begin
  fStringList := TStringList.Create();
end;

/// <summary>Destroy the objects created by the class</summary>
destructor TMessageQueue.Destroy;
begin
  fStringList.Free;
end;

/// <summary> Removes the first message from the queue and returns it</summary>
/// <param name="Item">The item to remove
/// <returns>If the message count is bigger then zero, it returns the first message. Otherwise, it returns an empty string.</returns>
function TMessageQueue.Pull: String;
begin
  Result := EmptyStr;
  if fStringList.Count > 0 then
  begin
    Result := fStringList[0];
    fStringList.Delete(0);
  end;
end;

/// <summary>Inserts a message at the end of the queue.</summary>
/// <param name="AMessage">The message to be inserted</param>
/// <remarks>If parameter "AMessage" is null, an exception is raised.</remarks>
procedure TMessageQueue.Push(AMessage: String);
begin
  if AMessage.IsEmpty then
    raise Exception.Create(cMessageParameterIsNull);

  fStringList.Add(AMessage);
end;

end.
