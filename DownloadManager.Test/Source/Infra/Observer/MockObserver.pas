unit MockObserver;

interface

uses
  Observer;

type
  TMockObserver = class(TInterfacedObject, IObserver)
  private
    fNotifyCalled: Boolean;
  public
    property NotifyCalled: Boolean read fNotifyCalled write fNotifyCalled;

    constructor Create();

    procedure Notify();
  end;

implementation

uses

System.SysUtils;

constructor TMockObserver.Create;
begin
  fNotifyCalled := false;
end;

procedure TMockObserver.Notify;
begin
  fNotifyCalled := True;
end;

end.
