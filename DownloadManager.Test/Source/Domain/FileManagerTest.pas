unit FileManagerTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TFileManagerTest = class
  public
    //Save file tests
    [Test]
    procedure SaveFileUsingAnEmptyDirectoryPath();

    [Test]
    procedure SaveFileUsingAnEmptyFileName();

    [Test]
    procedure SaveFileUsingANonExistentDirectoryPathWithoutForceDirectory();

    [Test]
    procedure SaveFileUsingANonExistentDirectoryPathButForcingDirectory();

    [Test]
    procedure SaveFileUsingAnExistingFileNameWithouOvewritten();

    [Test]
    procedure SaveFileUsingAnExistingFileNameWithOvewritten();

    //Remove file tests
    [Test]
    procedure RemoveFileUsingAnEmptyDirectoryPath();

    [Test]
    procedure RemoveFileUsingAnEmptyFileName();

    [Test]
    procedure RemoveFileUsingANonExistentFile();

    [Test]
    procedure RemoveFileUsingAnExistentFile();

    //Build complete file name tests
    [Test]
    procedure BuildCompleteFileNameUsingAnEmptyDirectoryPath();

    [Test]
    procedure BuildCompleteFileNameUsingAnEmptyFileName();

    [Test]
    procedure BuildCompleteFileNameUsingNonEmptyParameter();
  end;

implementation

uses FileManager, System.SysUtils, System.Classes, Constants, GuidGenerator;

const
  cDummyDirectory = 'j:\dummy';
  cDummyFile = 'dummy.txt';
  cUnitTestDirectory = 'UnitTest';


procedure TFileManagerTest.BuildCompleteFileNameUsingAnEmptyDirectoryPath;
begin
  {$region act/assert}
  try
    TFileManager.BuildCompleteFileName(cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.BuildCompleteFileNameUsingAnEmptyFileName;
begin
  {$region act/assert}
  try
    TFileManager.BuildCompleteFileName(cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.BuildCompleteFileNameUsingNonEmptyParameter;
var
  lCompleteFileName: String;
begin
  {$region 'act'}
  lCompleteFileName := TFileManager.BuildCompleteFileName(cDummyDirectory, cDummyFile);
  {$endregion}

  {$region 'assert'}
  Assert.AreEqual(cDummyDirectory + cBackSlash + cDummyFile, lCompleteFileName);
  {$endregion}
end;

procedure TFileManagerTest.RemoveFileUsingAnEmptyDirectoryPath;
begin
  {$region act/assert}
  try
    TFileManager.RemoveFile(cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.RemoveFileUsingAnEmptyFileName;
begin
  {$region act/assert}
  try
    TFileManager.SaveFile(nil, cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.RemoveFileUsingAnExistentFile;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash + TFileManager.GenerateUniqueName();
    TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    Assert.IsTrue(FileExists(TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}

    {$region act}
    try
      TFileManager.RemoveFile(lDirectoryPath, cDummyFile);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;
    {$endregion}

    {$region assert}
    Assert.IsFalse(FileExists(TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileManagerTest.RemoveFileUsingANonExistentFile;
var
  lFileName: String;
  lDirectoryPath: String;
begin
  {$region arrange}
  lFileName := TFileManager.GenerateUniqueName();
  lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
  {$endregion}

  {$region act/assert}
  try
    TFileManager.RemoveFile(lDirectoryPath, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, Format(cFileDoesntExists, [TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)]));
  end;
  {$endregion}
end;

procedure TFileManagerTest.SaveFileUsingAnEmptyDirectoryPath();
begin
  {$region act/assert}
  try
    TFileManager.SaveFile(nil, cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.SaveFileUsingAnEmptyFileName();
begin
  {$region act/assert}
  try
    TFileManager.SaveFile(nil, cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileManagerTest.SaveFileUsingAnExistingFileNameWithouOvewritten;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
    TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
    {$endregion}

    {$region act/assert}
    try
      TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
      Assert.Fail(cNotThronwException);
    except
      on e: Exception do
        Assert.AreEqual(e.Message, Format(cFileAlreadyExists, [TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)]));
    end;
    {$endregion}
  finally
    lStringStream.Free;
    TFileManager.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileManagerTest.SaveFileUsingAnExistingFileNameWithOvewritten;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
    TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    {$endregion}

    {$region act}
    try
      TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;
    {$endregion}

    {$region assert}
    Assert.IsTrue(FileExists(TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    TFileManager.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileManagerTest.SaveFileUsingANonExistentDirectoryPathButForcingDirectory;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + TFileManager.GenerateUniqueName();
    {$endregion}

    {$region act/assert}
    try
      TFileManager.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;

    Assert.IsTrue(FileExists(TFileManager.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    TFileManager.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileManagerTest.SaveFileUsingANonExistentDirectoryPathWithoutForceDirectory;
var
  lDirectoryPath: String;
begin
  {$region arrange}
  lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + TFileManager.GenerateUniqueName();
  {$endregion}

  {$region act/assert}
  try
    TFileManager.SaveFile(nil, lDirectoryPath, 'file.txt');
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, Format(cDirectoryDoesntExists, [lDirectoryPath]));
  end;
  {$endregion}
end;

initialization
  TDUnitX.RegisterTestFixture(TFileManagerTest);

end.
