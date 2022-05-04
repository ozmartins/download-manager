unit ORMConfigurationBuilder;

interface

type
  TORMConfigurationBuilder = class
  public
    class function GetDbFileName(): String;
    class function GetDormConfFileName(): String;
    class procedure CreateDormConfFileName(ADormCompleteFileName, ADbCompleteFileName: String);
  end;

implementation

uses
  RepositoryConsts, System.SysUtils;


/// <summary> Create the Delphi-ORM configuration file on disk</summary>
class procedure TORMConfigurationBuilder.CreateDormConfFileName(ADormCompleteFileName, ADbCompleteFileName: String);
var
  lDormFile: TextFile;
begin
  //NO! I am not happy with this solution
  AssignFile(lDormFile, ADormCompleteFileName);
  try
    Rewrite(lDormFile);
    WriteLn(lDormFile, Format(cDormConfFileContent, [ADbCompleteFileName, ADbCompleteFileName, ADbCompleteFileName]));
  finally
    CloseFile(lDormFile);
  end;
end;


/// <summary> Builds the DB file name</summary>
class function TORMConfigurationBuilder.GetDbFileName: String;
begin
  Result := ChangeFileExt(ExtractFileName(ParamStr(0)), '.db');
end;

/// <summary> Builds the Delphi-ORM configuration file name</summary>
class function TORMConfigurationBuilder.GetDormConfFileName: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + cDormConfFile;
end;

end.
