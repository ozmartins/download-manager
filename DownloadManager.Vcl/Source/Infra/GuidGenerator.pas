unit GuidGenerator;

interface

const
  cGuidCantBeGenerate = 'GUID can''t be generated';

type
  TGuidGenerator = class
  public
    class function GenerateGuid: TGuid;
    class function GenerateGuidAsString: String;
    class function GenerateGuidAsStringWithoutSpecialChars: String;
  end;

implementation

uses
  System.SysUtils, InfraConsts;

class function TGuidGenerator.GenerateGUID: TGuid;
var
  lGuid: TGuid;
begin
  if CreateGuid(lGuid) <> S_OK then
     raise Exception.Create(cGuidCantBeGenerate);

  Result := lGuid;
end;

class function TGuidGenerator.GenerateGuidAsString: String;
begin
  Result := GUIDToString(GenerateGUID());
end;

class function TGuidGenerator.GenerateGuidAsStringWithoutSpecialChars: String;
begin
  Result := GenerateGuidAsString()
                  .Replace(cOpenBracket, cEmptyString)
                  .Replace(cCloseBracket, cEmptyString)
                  .Replace(cHifen, cEmptyString);
end;

end.
