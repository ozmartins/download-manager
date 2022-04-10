unit ContentDispositionTest;

interface

uses
  DUnitX.TestFramework, System.SysUtils, Constants, ContentDisposition;

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
  TContentDispositionTest = class
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


{ TContentDispositionTest }

procedure TContentDispositionTest.TestExtractFileName(AContentDisposition, AExpectedResult: String);
var
  lFileName: String;
begin
  {$region act}
  lFileName := TContentDisposition.ExtractFileName(AContentDisposition);
  {$endregion}

  {$region assert}
  Assert.AreEqual(lFileName, AExpectedResult);
  {$endregion}
end;

procedure TContentDispositionTest.TestExtractType(AContentDisposition: String; AExpectedResult: String);
var
  lType: TContentDispositionType;
  lEnumName: String;
begin
  {$region act}
  lType := TContentDisposition.ExtractType(AContentDisposition);
  {$endregion}

  {$region assert}
  lEnumName := GetEnumName(TypeInfo(TContentDispositionType), Ord(lType));

  Assert.AreEqual(lEnumName, AExpectedResult);
  {$endregion}

end;

procedure TContentDispositionTest.TestExtractTypeWithEmptyContentDisposition;
begin
  {$region act/assert}
  try
    TContentDisposition.ExtractType(EmptyStr);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionTest.TestExtractTypeWithOtherContentDispositionAndEmptyFileName;
begin
  {$region act/assert}
  try
    TContentDisposition.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionTest.TestExtractTypeWithOtherContentDispositionAndValidFileName;
begin
  {$region act/assert}
  try
    TContentDisposition.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail();
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

procedure TContentDispositionTest.TestExtractTypeWithOtherContentDispositionAndWithoutFileName;
begin
  {$region act/assert}
  try
    TContentDisposition.ExtractType(cOtherContentDispositionWithFileName);
    Assert.Fail(cNotThronwException);
  except
    on e: Exception do
      Assert.AreEqual(e.Message, cInvalidContentDispositionTypeMessage);
  end;
  {$endregion}
end;

initialization
  TDUnitX.RegisterTestFixture(TContentDisposition);

end.
