unit LogDownloadRepositoryTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TLogDownloadRepositoryTest = class
  end;

implementation

uses
  LogDownloadRepository, LogDownload, System.SysUtils, Variants;

initialization
  TDUnitX.RegisterTestFixture(TLogDownloadRepositoryTest);

end.

