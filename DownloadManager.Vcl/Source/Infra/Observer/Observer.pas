unit Observer;

interface

uses Notification;

type
  /// <summary>
  /// This interface has the Notify() method and it's used for the "Observer" design pattern implementation.
  /// </summary>
  IObserver = Interface(IInterface)
    procedure Notify();
  end;

implementation

end.
