unit SubjectTest;

interface

uses
  DUnitX.TestFramework, Subject;

type
  [TestFixture]
  TSubjectTest = class
  public
    //AddObserver tests
    [Test]
    procedure TestAddObserverPassingNullParameter;

    [Test]
    procedure TestAddObserverPassingMockParameter;

    //RemoveObserver tests
    [Test]
    procedure TestRemoveObservereWithNullParameter;

    [Test]
    procedure TestRemoveObservereFromAnEmptyList;

    [Test]
    procedure TestRemoveObservereWithNonExistentParamater;

    [Test]
    procedure TestRemoveObservereWithExistentParamater;

    //NotifyObservers tests
    [Test]
    procedure TestNotifyObserversWithEmptyList();

    [Test]
    procedure TestNotifyObserversWithOneRegistryInTheList();

    [Test]
    procedure TestNotifyObserversWithTwoRegistriesInTheList();
  end;

implementation

uses
  System.SysUtils, MockObserver;

procedure TSubjectTest.TestAddObserverPassingMockParameter;
var
  lSubject: TSubject;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  {$endregion}

  {$region 'Act'}
  try
    try
      lSubject.AddObserver(TMockObserver.Create());
    except
      Assert.Fail();
    end;
  finally
    lSubject.Free;
  end;
  {$endregion}

  {$region 'Assert'}
  Assert.Pass();
  {$endregion}
end;

procedure TSubjectTest.TestAddObserverPassingNullParameter;
var
  lSubject: TSubject;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  {$endregion}

  {$region 'Act/Assert'}
  try
    Assert.WillRaiseWithMessage(procedure () begin lSubject.AddObserver(nil) end, Exception, cObserverNullParameter);
  finally
    lSubject.Free;
  end;
  {$endregion}
end;

procedure TSubjectTest.TestNotifyObserversWithEmptyList;
var
  lSubject: TSubject;
  lTMockObserver: TMockObserver;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  lTMockObserver := TMockObserver.Create();
  {$endregion}

  {$region 'Act'}
  Assert.IsFalse(lTMockObserver.NotifyCalled);

  lSubject.NotifyObservers();
  {$endregion}

  {$region 'Assert'}
  Assert.Isfalse(lTMockObserver.NotifyCalled);
  {$endregion}
end;

procedure TSubjectTest.TestNotifyObserversWithOneRegistryInTheList;
var
  lSubject: TSubject;
  lTMockObserver: TMockObserver;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  lTMockObserver := TMockObserver.Create();
  lSubject.AddObserver(lTMockObserver);
  {$endregion}

  {$region 'Act'}
  Assert.IsFalse(lTMockObserver.NotifyCalled);

  lSubject.NotifyObservers();
  {$endregion}

  {$region 'Assert'}
  Assert.IsTrue(lTMockObserver.NotifyCalled);
  {$endregion}
end;

procedure TSubjectTest.TestNotifyObserversWithTwoRegistriesInTheList;
var
  lSubject: TSubject;
  lTMockObserver1: TMockObserver;
  lTMockObserver2: TMockObserver;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();

  lTMockObserver1 := TMockObserver.Create();
  lTMockObserver2 := TMockObserver.Create();

  lSubject.AddObserver(lTMockObserver1);
  lSubject.AddObserver(lTMockObserver2);
  {$endregion}

  {$region 'Act'}
  Assert.IsFalse(lTMockObserver1.NotifyCalled);
  Assert.IsFalse(lTMockObserver2.NotifyCalled);

  lSubject.NotifyObservers();
  {$endregion}

  {$region 'Assert'}
  Assert.IsTrue(lTMockObserver1.NotifyCalled);
  Assert.IsTrue(lTMockObserver2.NotifyCalled);
  {$endregion}
end;

procedure TSubjectTest.TestRemoveObservereWithExistentParamater;
var
  lSubject: TSubject;
  lMockObserver: TMockObserver;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  lMockObserver := TMockObserver.Create();
  lSubject.AddObserver(lMockObserver);
  {$endregion}

  {$region 'Act'}
  try
    try
      lSubject.RemoveObserver(lMockObserver);
    except
      Assert.Fail();
    end;
  finally
    lSubject.Free;
  end;
  {$endregion}

  {$region 'Assert'}
  Assert.Pass();
  {$endregion}
end;

procedure TSubjectTest.TestRemoveObservereFromAnEmptyList;
var
  lSubject: TSubject;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  {$endregion}

  {$region 'act/assert'}
  try
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(TMockObserver.Create()) end, Exception, cObserverDoesntExist);
  finally
    lSubject.Free;
  end;
  {$endregion}
end;

procedure TSubjectTest.TestRemoveObservereWithNonExistentParamater;
var
  lSubject: TSubject;
  lMockObserver1: TMockObserver;
  lMockObserver2: TMockObserver;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  lMockObserver1 := TMockObserver.Create();
  lMockObserver2 := TMockObserver.Create();
  lSubject.AddObserver(lMockObserver1);
  {$endregion}

  {$region 'Act/Assert'}
  try
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(lMockObserver2); end, Exception, cObserverDoesntExist);
  finally
    lSubject.Free;
  end;
  {$endregion}
end;

procedure TSubjectTest.TestRemoveObservereWithNullParameter;
var
  lSubject: TSubject;
begin
  {$region 'Arrange'}
  lSubject := TSubject.Create();
  {$endregion}

  {$region 'act/assert'}
  try
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(nil) end, Exception, cObserverNullParameter);
  finally
    lSubject.Free;
  end;
  {$endregion}
end;

initialization
  TDUnitX.RegisterTestFixture(TSubjectTest);

end.
