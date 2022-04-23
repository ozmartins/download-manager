unit GuidGenerator;

interface

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

/// <summary>Creates a GUID.</summary>
/// <remarks>Raises an exception if CreateGuid function returns a result different from OK.</remarks>
/// <returns>A GUID object.</returns>
class function TGuidGenerator.GenerateGUID: TGuid;
var
  lGuid: TGuid;
begin
  if CreateGuid(lGuid) <> S_OK then
     raise Exception.Create(cGuidCantBeGenerate);

  Result := lGuid;
end;

/// <summary>Calls GenerateGUID and convert the result to a string.</summary>
/// <returns>A string representing a GUID.</returns>
class function TGuidGenerator.GenerateGuidAsString: String;
begin
  Result := GUIDToString(GenerateGUID());
end;

/// <summary>Calls GenerateGUID, convert the result to a string, and removes all the special characters.</summary>
/// <returns>A string representing a GUID without any special characters..</returns>
class function TGuidGenerator.GenerateGuidAsStringWithoutSpecialChars: String;
begin
  Result := GenerateGuidAsString()
                  .Replace(cOpenBracket, cEmptyString)
                  .Replace(cCloseBracket, cEmptyString)
                  .Replace(cHifen, cEmptyString);
end;

end.
