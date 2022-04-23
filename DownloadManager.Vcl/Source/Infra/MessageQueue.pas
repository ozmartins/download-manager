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

/// <summary>Counts the elements in the message queue.</summary>
/// <returns>The number of elements in the message queue.</returns>
function TMessageQueue.Count: Integer;
begin
  Result := fStringList.Count;
end;

/// <summary>Creates an instance of TMessageQueue</summary>
/// <returns>An instance of TMessageQueue</returns>
constructor TMessageQueue.Create;
begin
  fStringList := TStringList.Create();
end;

/// <summary>Destroy the objects created by the class</summary>
destructor TMessageQueue.Destroy;
begin
  fStringList.Free;
end;

/// <summary>Removes the first message from the queue and returns it</summary>
/// <returns>If the message queue count is bigger than zero, it returns the first message. Otherwise, it returns an empty string.</returns>
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
