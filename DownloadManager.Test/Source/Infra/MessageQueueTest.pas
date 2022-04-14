unit MessageQueueTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMessageQueueTest = class
  public
    [Test]
    procedure PushAnEmptyString();

    [Test]
    procedure PushAnValidMessage();

    [Test]
    procedure PushTwoValidsMessages();

    [Test]
    procedure PullAndEmptyQueue();
  end;

implementation

uses
  Constants, MessageQueue, System.SysUtils;

procedure TMessageQueueTest.PullAndEmptyQueue;
var
  lMessageQueue: TMessageQueue;
  lMessage: String;
begin
  {$region arrange}
  lMessageQueue := TMessageQueue.Create();
  {$region}

  try
    {$region act}
    lMessage := lMessageQueue.Pull();
    {$endregion}

    {$region assert}
    Assert.IsEmpty(lMessage);
    {$endregion}
  finally
    lMessageQueue.Free;
  end;
end;

procedure TMessageQueueTest.PushAnEmptyString;
var
  lMessageQueue: TMessageQueue;
begin
  {$region arrange}
  lMessageQueue := TMessageQueue.Create();
  {$region}

  try
    {$region act/assert}
    try
      lMessageQueue.Push(cEmptyString);
      Assert.Fail(cNotThronwException);
    except
      on e: Exception do
        Assert.AreEqual(e.Message, cMessageParameterIsNull);
    end;
    {$endregion}
  finally
    lMessageQueue.Free;
  end;
end;

procedure TMessageQueueTest.PushAnValidMessage;
var
  lMessageQueue: TMessageQueue;
begin
  {$region arrange}
  lMessageQueue := TMessageQueue.Create();
  {$region}

  try
    {$region act}
    lMessageQueue.Push('Teste');
    {$endregion}

    {$region assert}
    Assert.AreEqual(lMessageQueue.Count, 1);
    Assert.AreEqual(lMessageQueue.Pull, 'Teste');
    {$endregion}
  finally
    lMessageQueue.Free;
  end;
end;

procedure TMessageQueueTest.PushTwoValidsMessages;
var
  lMessageQueue: TMessageQueue;
begin
  {$region arrange}
  lMessageQueue := TMessageQueue.Create();
  {$region}

  try
    {$region act}
    lMessageQueue.Push('Teste1');
    lMessageQueue.Push('Teste2');
    {$endregion}

    {$region assert}
    Assert.AreEqual(lMessageQueue.Count, 2);
    Assert.AreEqual(lMessageQueue.Pull, 'Teste1');
    Assert.AreEqual(lMessageQueue.Pull, 'Teste2');
    {$endregion}
  finally
    lMessageQueue.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TMessageQueueTest);

end.
