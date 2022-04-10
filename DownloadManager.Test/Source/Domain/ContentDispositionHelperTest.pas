unit ContentDispositionHelperTest;

interface

uses
  DUnitX.TestFramework, System.SysUtils, Constants, ContentDispositionHelper;

const
  cExpectFileName = 'file.txt';

  cAttachmentContentDispositionWithFileName = 'attachment; filename="'+cExpectFileName+'"';
  cInlineContentDispositionWithFileName = 'inline; filename="'+cExpectFileName+'"';
  cOtherContentDispositionWithFileName = 'other; filename="'+cExpectFileName+'"';

  cAttachmentContentDispositionWithEmptyFileName = 'attachment; filename=""';
  cInLineContentDispositionWithEmptyFileName = 'inline; filename=""';
  cOtherContentDispositionWithEmptyFileName = 'other; filename=""';

  cAttachmentContentDispositionWithoutFileName = 'attachment';
  cInLineContentDispositionWithoutFileName = 'inline';
  cOtherContentDispositionWithoutFileName = 'other';

type
  [TestFixture]
  TContentDispositionHelperTest = class
  public

    [Test]
    [TestCase('cAttachmentContentDispositionWithFileName', cAttachmentContentDispositionWithFileName + cComma + cExpectFileName)]
    [TestCase('cInlineContentDispositionWithFileName', cInlineContentDispositionWithFileName + cComma + cExpectFileName)]
    [TestCase('cOtherContentDispositionWithFileName', cOtherContentDispositionWithFileName + cComma + cExpectFileName)]
    [TestCase('cAttachmentContentDispositionWithEmptyFileName', cAttachmentContentDispositionWithEmptyFileName + cComma + cEmptyString)]
    [TestCase('cInLineContentDispositionWithEmptyFileName', cInLineContentDispositionWithEmptyFileName + cComma + cEmptyString)]
    [TestCase('cOtherContentDispositionWithEmptyFileName', cOtherContentDispositionWithEmptyFileName + cComma + cEmptyString)]
    [TestCase('cAttachmentContentDispositionWithoutFileName', cAttachmentContentDispositionWithoutFileName + cComma + cEmptyString)]
    [TestCase('cInLineContentDispositionWithoutFileName', cInLineContentDispositionWithoutFileName + cComma + cEmptyString)]
    [TestCase('cOtherContentDispositionWithoutFileName', cOtherContentDispositionWithoutFileName + cComma + cEmptyString)]
    procedure TestExtractFileName(AContentDisposition: String; AExpectedResult: String);

    [Test]
    [TestCase('cAttachmentContentDispositionWithFileName', cAttachmentContentDispositionWithFileName + cComma + cContentDispositionTypeNameAttachment)]
    [TestCase('cInlineContentDispositionWithFileName', cInlineContentDispositionWithFileName + cComma + cContentDispositionTypeNameInLine)]
    [TestCase('cAttachmentContentDispositionWithEmptyFileName', cAttachmentContentDispositionWithEmptyFileName + cComma + cContentDispositionTypeNameAttachment)]
    [TestCase('cInLineContentDispositionWithEmptyFileName', cInLineContentDispositionWithEmptyFileName + cComma + cContentDispositionTypeNameInLine)]
    [TestCase('cAttachmentContentDispositionWithoutFileName', cAttachmentContentDispositionWithoutFileName + cComma + cContentDispositionTypeNameAttachment)]
    [TestCase('cInLineContentDispositionWithoutFileName', cInLineContentDispositionWithoutFileName + cComma + cContentDispositionTypeNameInLine)]
    procedure TestExtractType(AContentDisposition: String; AExpectedResult: String);

    [Test]
    procedure TestExtractTypeWithOtherContentDispositionAndValidFileName();

    [Test]
    procedure TestExtractTypeWithOtherContentDispositionAndEmptyFileName();

    [Test]
    procedure TestExtractTypeWithOtherContentDispositionAndWithoutFileName();

    [Test]
    procedure TestExtractTypeWithEmptyContentDisposition();
  end;

implementation

uses TypInfo;


{ TContentDispositionHelperTest }

procedure TContentDispositionHelperTest.TestExtractFileName(AContentDisposition, AExpectedResult: String);
var
  lFileName: String;
begin
  {$region act}
  lFileName := TContentDispositionHelper.ExtractFileName(AContentDisposition);
  {$endregion}

  {$region assert}
  Assert.AreEqual(lFileName, AExpectedResult);
  {$endregion}
end;

procedure TContentDispositionHelperTest.TestExtractType(AContentDisposition: String; AExpectedResult: String);
var
  lType: TContentDispositionType;
  lEnumName: String;
begin
  {$region act}
  lType := TContentDispositionHelper.ExtractType(AContentDisposition);
  {$endregion}

  {$region assert}
  lEnumName := GetEnumName(TypeInfo(TContentDispositionType), Ord(lType));

  Assert.AreEqual(lEnumName, AExpectedResult);
  {$endregion}

end;

procedure TContentDispositionHelperTest.TestExtractTypeWithEmptyContentDisposition;
begin
  {$region act/assert}
  try
    TContentDispositionHelper.ExtractType(EmptyStr);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionHelperTest.TestExtractTypeWithOtherContentDispositionAndEmptyFileName;
begin
  {$region act/assert}
  try
    TContentDispositionHelper.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionHelperTest.TestExtractTypeWithOtherContentDispositionAndValidFileName;
begin
  {$region act/assert}
  try
    TContentDispositionHelper.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail();
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionHelperTest.TestExtractTypeWithOtherContentDispositionAndWithoutFileName;
begin
  {$region act/assert}
  try
    TContentDispositionHelper.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

initialization
  TDUnitX.RegisterTestFixture(TContentDispositionHelperTest);

end.
