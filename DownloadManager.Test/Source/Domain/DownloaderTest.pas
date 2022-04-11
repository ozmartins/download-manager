unit DownloaderTest;

interface

uses
  DUnitX.TestFramework, Downloader;

type
  [TestFixture]
  TDownloaderTest = class
  public
    //Download() tests
    [Test]
    procedure DownloadWithEmptyUrl();

    [Test]
    procedure DownloadWithNonDownloadableUrl();

    [Test]
    procedure DownloadWhereResponseHeaderHasNoContenDisposition();

    [Test]
    procedure DownloadWhenDownloaderIsNotIdle();

    [Test]
    procedure DownloadSuccesfully();

    //Abort() tests
    [Test]
    procedure AbortWhenDownloaderIsNotDownloading();

    [Test]
    procedure AbortWhenDownloaderIsDownloading();

    //State transition tests
    [Test]
    procedure StateIsDownloadingAfterDownloadIsStarted();

    [Test]
    procedure StateIsAbortedAfterDownloadIsAborted();

    [Test]
    procedure StateIsIdleAfterDownloadIsCompleted();

    //Progress tests
    [Test]
    procedure ProgressInChangedDuringDownload();

    //Observer calling tests
    [Test]
    procedure ObserverIsCalledDuringDownload();
  end;

implementation

uses
  Subject, System.SysUtils, MockNetHTTPRequest, Constants, MockHttpResponse,
  System.Net.HttpClient, MockObserver, SimpleNetHTTPRequestProxy,
  System.Net.HttpClientComponent;

const
  cStatusCode200 = 200;
  cDownloadContentLength = 10;
  cDummyUrl = 'www.domain.net';
  cContentDispositionInLine = 'inline; filename="filename.txt"';
  cContentDispositionAttachment = 'attachment; filename="filename.txt"';

{ TDownloaderTest }

procedure TDownloaderTest.AbortWhenDownloaderIsDownloading;
var
  lDownloader: TDownloader;
  lMockHttpResponse: TMockHttpResponse;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, 0, False));
  lDownloader.Download(cDummyUrl);
  {$endregion}

  {$region 'act'}
  try
    lDownloader.Abort();
  except
    on e: Exception do
      Assert.Fail(e.Message);
  end;
  {$endregion}

  {$region 'assert'}
  Assert.Pass();
  {$endregion}
end;

procedure TDownloaderTest.AbortWhenDownloaderIsNotDownloading;
var
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(nil, nil, 0, False));
  {$endregion}

  {$region 'act/assert'}
  Assert.WillRaiseWithMessage(procedure () begin lDownloader.Abort(); end, Exception, cDownloaderIsNotDownloading);
  {$endregion}
end;

procedure TDownloaderTest.DownloadSuccesfully;
var
  lMockHttpResponse: TMockHttpResponse;
  lResponse: IHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, 0, False));
  {$endregion}

  try
    {$region 'act'}
    lResponse := lDownloader.Download(cDummyUrl);
    {$endregion}

    {$region 'act/assert'}
    Assert.AreEqual(lResponse.StatusCode, cStatusCode200);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.DownloadWhenDownloaderIsNotIdle;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, 0, False));
  lDownloader.Download(cDummyUrl);
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.WillRaiseWithMessage(procedure () begin lDownloader.Download(cDummyUrl); end, Exception, cDownloaderIsBusy);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.DownloadWhereResponseHeaderHasNoContenDisposition;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionInLine, False);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(nil, lMockHttpResponse, 0, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.WillRaiseWithMessage(procedure () begin lDownloader.Download(cDummyUrl); end, Exception, cResponseHeaderDoesNotContainsContentField);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.DownloadWithEmptyUrl();
var
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(nil, nil, 0, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.WillRaiseWithMessage(procedure () begin lDownloader.Download(cEmptyString); end, Exception, cUrlIsEmpty);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.DownloadWithNonDownloadableUrl;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionInLine, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(nil, lMockHttpResponse, 0, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.WillRaiseWithMessage(procedure () begin lDownloader.Download(cDummyUrl); end, Exception, cUrlIsNotALink);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.ObserverIsCalledDuringDownload;
var
  lMockHttpResponse: TMockHttpResponse;
  lMockObserver: TMockObserver;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, cDownloadContentLength, False));
  lMockObserver := TMockObserver.Create();
  {$endregion}

  try
    {$region 'act'}
    lDownloader.Subject.AddObserver((lMockObserver));
    lDownloader.Download(cDummyUrl);
    {$endregion}

    {$region 'arrange'}
    Assert.IsTrue(lMockObserver.NotifyCalled);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.ProgressInChangedDuringDownload;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, cDownloadContentLength, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsIdle);
    lDownloader.Download(cDummyUrl);
    Assert.IsTrue(lDownloader.Progress = 100);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.StateIsAbortedAfterDownloadIsAborted;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, 0, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsIdle);
    lDownloader.Download(cDummyUrl);
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsDownloading);
    lDownloader.Abort();
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsAborted);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.StateIsDownloadingAfterDownloadIsStarted;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, 0, False));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsIdle);
    lDownloader.Download(cDummyUrl);
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsDownloading);
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

procedure TDownloaderTest.StateIsIdleAfterDownloadIsCompleted;
var
  lMockHttpResponse: TMockHttpResponse;
  lDownloader: TDownloader;
begin
  {$region 'arrange'}
  lMockHttpResponse := TMockHttpResponse.Create(cStatusCode200, cContentDispositionAttachment, True);
  lDownloader := TDownloader.Create(TMockNetHTTPRequest.Create(lMockHttpResponse, lMockHttpResponse, cDownloadContentLength, True));
  {$endregion}

  try
    {$region 'act/assert'}
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsIdle);
    lDownloader.Download(cDummyUrl);
    Assert.AreEqual(lDownloader.State, TDownloaderState.dsIdle);  //It continues idle after downloading, because the state machine comes back to this state after download.
    {$endregion}
  finally
    lDownloader.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDownloaderTest);

end.
