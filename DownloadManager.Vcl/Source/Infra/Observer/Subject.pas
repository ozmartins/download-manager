unit Subject;

interface

uses
   System.Generics.Collections, Observer;

const
  cObserverNullParameter = 'Erro interno: O parâmetro "observer" não pode ser nulo.';
  cObserverDoesntExist = 'Erro interno: observado não encontrado na lista.';

type
  /// <summary>
  /// This is a concrete class used in an Observer Pattern implementation.
  /// You can compose your class with a property of this type adding observer capabilities to your class.
  /// </summary>
  TSubject = class
  private
    fObservers: TList<IObserver>;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure AddObserver(AObserver: IObserver);
    procedure RemoveObserver(AObserver: IObserver);
    procedure NotifyObservers();
  end;

implementation

uses
  System.SysUtils;

{ TSubject }

/// <summary>This method creates an instance of TSubject class.</summary>
/// <returns>It returns an instance of TSubject class.</returns>
constructor TSubject.Create;
begin
  fObservers := TList<IObserver>.Create();
end;

/// <summary>It frees the allocated memory by the class constructor.</summary>
destructor TSubject.Destroy;
begin
  fObservers.Free;
  inherited;
end;

/// <summary>Adds an observer to the observer's list. All the observers in the list will be notified when some important event happens in the subject.</summary>
/// <param name="AObserver">A class that implements the IObserver interface.</param>
/// <remarks>If parameter "AObserver" is null, an exception is raised.</remarks>
procedure TSubject.AddObserver(AObserver: IObserver);
begin
  if AObserver = nil then
    raise Exception.Create(cObserverNullParameter);
  fObservers.Add(AObserver);
end;

/// <summary>Removes an observer from the observer's list.</summary>
/// <param name="AObserver">A class that implements the IObserver interface.</param>
/// <remarks>If the parameter "AObserver" is null or if it doesn't exist in the observers' list, an exception is raised.</remarks>
procedure TSubject.RemoveObserver(AObserver: IObserver);
begin
  if AObserver = nil then
    raise Exception.Create(cObserverNullParameter);

  if not fObservers.Contains(AObserver) then
    raise Exception.Create(cObserverDoesntExist);

  fObservers.Remove(AObserver);
end;

/// <summary>Iterates over the observers' list and call the update method for all of them.</summary>
procedure TSubject.NotifyObservers();
var
  lObserver: IObserver;
begin
  for lObserver in fObservers.ToArray() do
    lObserver.Notify();
end;

end.
