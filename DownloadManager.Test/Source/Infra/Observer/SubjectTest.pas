unit SubjectTest;

interface

uses
  DUnitX.TestFramework, Subject;

type
  [TestFixture]
  TSubjectTest = class
  public
    [Test]
    procedure TestAddObserverPassingNullParameter;

    [Test]
    procedure TestAddObserverPassingMockParameter;

    [Test]
    procedure TestRemoveObservereWithNullParameter;

    [Test]
    procedure TestRemoveObservereFromAnEmptyList;

    [Test]
    procedure TestRemoveObservereWithNonExistentParamater;

    [Test]
    procedure TestRemoveObservereWithExistentParamater;

    [Test]
    procedure TestNotifyObserversWithEmptyList();

    [Test]
    procedure TestNotifyObserversWithOneRegistryInTheList();

    [Test]
    procedure TestNotifyObserversWithTwoRegistriesInTheList();

    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
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
    Assert.WillRaiseWithMessage(procedure () begin lSubject.AddObserver(nil) end, Exception, cAddObserverNullParameter);
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
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(TMockObserver.Create()) end, Exception, cRemoveObserverDoesntExist);
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
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(lMockObserver2); end, Exception, cRemoveObserverDoesntExist);
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
    Assert.WillRaiseWithMessage(procedure () begin lSubject.RemoveObserver(nil) end, Exception, cRemoveObserverNullParameter);
  finally
    lSubject.Free;
  end;
  {$endregion}
end;

procedure TSubjectTest.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TSubjectTest);

end.
