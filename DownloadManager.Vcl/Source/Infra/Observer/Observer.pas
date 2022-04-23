unit Observer;

interface

uses Notification;

type
  IObserver = Interface(IInterface)
    procedure Notify();
  end;

implementation

end.
