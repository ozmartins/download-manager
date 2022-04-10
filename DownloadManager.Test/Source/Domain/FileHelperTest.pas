unit FileHelperTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TFileHelperTest = class
  private
    function GenerateUniqueName(): String;
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

uses FileHelper, System.SysUtils, System.Classes, Constants, GuidGenerator;

const
  cDummyDirectory = 'j:\dummy';
  cDummyFile = 'dummy.txt';
  cUnitTestDirectory = 'UnitTest';


procedure TFileHelperTest.BuildCompleteFileNameUsingAnEmptyDirectoryPath;
begin
  {$region act/assert}
  try
    TFileHelper.BuildCompleteFileName(cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.BuildCompleteFileNameUsingAnEmptyFileName;
begin
  {$region act/assert}
  try
    TFileHelper.BuildCompleteFileName(cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.BuildCompleteFileNameUsingNonEmptyParameter;
var
  lCompleteFileName: String;
begin
  {$region 'act'}
  lCompleteFileName := TFileHelper.BuildCompleteFileName(cDummyDirectory, cDummyFile);
  {$endregion}

  {$region 'assert'}
  Assert.AreEqual(cDummyDirectory + cBackSlash + cDummyFile, lCompleteFileName);
  {$endregion}
end;

function TFileHelperTest.GenerateUniqueName: String;
begin
  Result := TGuidGenerator.GenerateGuidAsStringWithoutSpecialChars();
end;

procedure TFileHelperTest.RemoveFileUsingAnEmptyDirectoryPath;
begin
  {$region act/assert}
  try
    TFileHelper.RemoveFile(cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.RemoveFileUsingAnEmptyFileName;
begin
  {$region act/assert}
  try
    TFileHelper.SaveFile(nil, cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.RemoveFileUsingAnExistentFile;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash + GenerateUniqueName();
    TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    Assert.IsTrue(FileExists(TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}

    {$region act}
    try
      TFileHelper.RemoveFile(lDirectoryPath, cDummyFile);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;
    {$endregion}

    {$region assert}
    Assert.IsFalse(FileExists(TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileHelperTest.RemoveFileUsingANonExistentFile;
var
  lFileName: String;
  lDirectoryPath: String;
begin
  {$region arrange}
  lFileName := GenerateUniqueName();
  lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
  {$endregion}

  {$region act/assert}
  try
    TFileHelper.RemoveFile(lDirectoryPath, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, Format(cFileDoesntExists, [TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)]));
  end;
  {$endregion}
end;

procedure TFileHelperTest.SaveFileUsingAnEmptyDirectoryPath();
begin
  {$region act/assert}
  try
    TFileHelper.SaveFile(nil, cEmptyString, cDummyFile);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cDirectoryPathIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.SaveFileUsingAnEmptyFileName();
begin
  {$region act/assert}
  try
    TFileHelper.SaveFile(nil, cDummyDirectory, cEmptyString);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cFileNameIsEmpty);
  end;
  {$endregion}
end;

procedure TFileHelperTest.SaveFileUsingAnExistingFileNameWithouOvewritten;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
    TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
    {$endregion}

    {$region act/assert}
    try
      TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
      Assert.Fail(cNotThronwException);
    except
      on e: Exception do
        Assert.AreEqual(e.Message, Format(cFileAlreadyExists, [TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)]));
    end;
    {$endregion}
  finally
    lStringStream.Free;
    TFileHelper.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileHelperTest.SaveFileUsingAnExistingFileNameWithOvewritten;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + cBackSlash;
    TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    {$endregion}

    {$region act}
    try
      TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True, True);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;
    {$endregion}

    {$region assert}
    Assert.IsTrue(FileExists(TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    TFileHelper.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileHelperTest.SaveFileUsingANonExistentDirectoryPathButForcingDirectory;
var
  lStringStream: TStringStream;
  lDirectoryPath: String;
begin
  lStringStream := TStringStream.Create('Teste');
  try
    {$region arrange}
    lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + GenerateUniqueName();
    {$endregion}

    {$region act/assert}
    try
      TFileHelper.SaveFile(lStringStream, lDirectoryPath, cDummyFile, True);
    except
      on e: Exception do
        Assert.Fail(e.Message);
    end;

    Assert.IsTrue(FileExists(TFileHelper.BuildCompleteFileName(lDirectoryPath, cDummyFile)));
    {$endregion}
  finally
    lStringStream.Free;
    TFileHelper.RemoveFile(lDirectoryPath, cDummyFile);
    RemoveDir(lDirectoryPath);
  end;
end;

procedure TFileHelperTest.SaveFileUsingANonExistentDirectoryPathWithoutForceDirectory;
var
  lDirectoryPath: String;
begin
  {$region arrange}
  lDirectoryPath := IncludeTrailingPathDelimiter(GetCurrentDir()) + cUnitTestDirectory + GenerateUniqueName();
  {$endregion}

  {$region act/assert}
  try
    TFileHelper.SaveFile(nil, lDirectoryPath, 'file.txt');
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, Format(cDirectoryDoesntExists, [lDirectoryPath]));
  end;
  {$endregion}
end;

initialization
  TDUnitX.RegisterTestFixture(TFileHelperTest);

end.
