unit FileManager;

interface

uses System.Classes, System.SysUtils, DomainConsts;

type
  TFileManager = class
  public
    class procedure SaveFile(ASourceStream: TStream; ADestDirectory: String; ADestFile: String; AForceDirectory: Boolean = False; AOverwriteExistentFile: Boolean = False);
    class procedure RemoveFile(ADirectoryPath: String; AFileName: String);
    class function BuildCompleteFileName(ADirectoryPath: String; AFileName: String): String;
    class function GenerateUniqueName(APrefix: String): String;
  end;

implementation

uses
  GuidGenerator;

/// <summary> Concatenates the directory path and the file name, including a path delimiter if necessary.</summary>
/// <param name="ADirectoryPath">The directory path.</param>
/// <param name="AFileName">The name (with extension) of the file.</param>
/// <remarks>
/// If "ADirectoryPath" or "AFileName" is null, an exception is raised.
/// </remarks>
/// <returns>The complete file name.</returns>
class function TFileManager.BuildCompleteFileName(ADirectoryPath, AFileName: String): String;
begin
  if ADirectoryPath.IsEmpty() then
    raise Exception.Create(cDirectoryPathIsEmpty);

  if AFileName.IsEmpty() then
    raise Exception.Create(cFileNameIsEmpty);

  Result := IncludeTrailingPathDelimiter(ADirectoryPath) + AFileName;
end;

/// <summary> Concatenates the prefix parameter with a GUID to create a unique file name.</summary>
/// <param name="APrefix">A string will be placed at the start of the generated file name.</param>
/// <returns>The generated file name.</returns>
class function TFileManager.GenerateUniqueName(APrefix: String): String;
begin
  Result := TGuidGenerator.GenerateGuidAsStringWithoutSpecialChars();
end;

/// <summary> Removes the specified file from the specified directory.</summary>
/// <param name="ADirectoryPath">The directory path where the file is.</param>
/// <param name="AFileName">The name (with extension) of the file you want to remove.</param>
/// <remarks>If the file doesn't exist in the directory, an exception will be thrown.</remarks>
class procedure TFileManager.RemoveFile(ADirectoryPath, AFileName: String);
var
  lCompleteFileName: String;
begin
  lCompleteFileName := BuildCompleteFileName(ADirectoryPath, AFileName);

  if not FileExists(lCompleteFileName) then
    raise Exception.Create(Format(cFileDoesntExists, [lCompleteFileName]));

  DeleteFile(lCompleteFileName);
end;

/// <summary>It checks if the directory already exists. After that, it saves the content of ASourceStream into a file.</summary>
/// <param name="ASourceStream">A stream that contains the data you want to save into the file.</param>
/// <param name="ADestDirectory">The directory path where you want to save your file. If AForceDirectory is true, the directory will be created in case it doesn't exist.</param>
/// <param name="ADestFile">The name (with extension) of the new file. If the file already exists and AOverwriteExistentFile is false, an exception is thrown.</param>
/// <param name="AForceDirectory">Indicates if the directory should be created in case it doesn't exist.</param>
/// <param name="AOverwriteExistentFile">Indicates if the file should be overwritten in case it already exists.</param>
/// <remarks>
/// An exception will be thrown in the following cases:
/// - ADestDirectory is empty
/// - ADestFile is empty
/// - ADestDirectory doesn't exist and AForceDirectory is false
/// - ADestFile already exists and AOverwriteExistentFile is false
/// </remarks>
class procedure TFileManager.SaveFile(ASourceStream: TStream; ADestDirectory: String; ADestFile: String; AForceDirectory: Boolean = False; AOverwriteExistentFile: Boolean = False);
var
  lFileStream: TFileStream;
  lCompleteFileName: String;
begin
  lCompleteFileName := BuildCompleteFileName(ADestDirectory, ADestFile);

  if AForceDirectory then
    ForceDirectories(ADestDirectory);

  if not DirectoryExists(ADestDirectory) then
    raise Exception.Create(Format(cDirectoryDoesntExists, [ADestDirectory]));

  if FileExists(lCompleteFileName) and (not AOverwriteExistentFile) then
    raise Exception.Create(Format(cFileAlreadyExists, [lCompleteFileName]));

  lFileStream := TFileStream.Create(lCompleteFileName, fmCreate);
  try
    lFileStream.CopyFrom(ASourceStream);
  finally
    lFileStream.Free;
  end;
end;

end.
