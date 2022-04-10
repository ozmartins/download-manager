unit FileManager;

interface

uses System.Classes, System.SysUtils;

const
  cDirectoryDoesntExists = 'Internal error: The destination directory (%s) doesn''t exists.';
  cFileAlreadyExists  = 'Internal error: The file (%s) already exists.';
  cFileDoesntExists  = 'Internal error: The file (%s) doesn''t exists.';
  cFileNameIsEmpty  = 'Internal error: The file name is empty.';
  cDirectoryPathIsEmpty  = 'Internal error: The directory name is empty.';

type
  ///<summary>Offers some tools to help with file management.</summary>
  TFileManager = class
  public
    class procedure SaveFile(ASourceStream: TStream; ADestDirectory: String; ADestFile: String; AForceDirectory: Boolean = False; AOverwriteExistentFile: Boolean = False);
    class procedure RemoveFile(ADirectoryPath: String; AFileName: String);
    class function BuildCompleteFileName(ADirectoryPath: String; AFileName: String): String;
  end;

implementation

{ TFileManager }

/// <summary>Create a file on disk based on stream object.</summary>
/// <param name="ASourceStream">A stream object that has the source data</param>
/// <param name="ADestFolder">Name of the directory where the file will be saved.</param>
/// <param name="ADestFile">Used to name the file that will be created.</param>
/// <remarks>
/// If the parameter "ADestFolder" doesn't exist on the disk or the parameter "ADestFile" is empty, an exception is raised.
/// </remarks>
class function TFileManager.BuildCompleteFileName(ADirectoryPath, AFileName: String): String;
begin
  if ADirectoryPath.IsEmpty() then
    raise Exception.Create(cDirectoryPathIsEmpty);

  if AFileName.IsEmpty() then
    raise Exception.Create(cFileNameIsEmpty);

  Result := IncludeTrailingPathDelimiter(ADirectoryPath) + AFileName;
end;

/// <summary>It checks if the file exists. After that, it removes the file from the disk.</summary>
/// <param name="ADirectoryPath">Your file directory path.</param>
/// <param name="AFileName">The name (with extension) of the file you want to remove. If the file doesn't exist an exception is thrown.</param>
/// <remarks>
/// An exception will be thrown in the following cases:
/// - ADirectoryPath is empty
/// - AFileName is empty
/// - AFileName doesn't exist
/// </remarks>
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
/// <param name="AOverwriteExistentFilet">Indicates if the file should be overwritten in case it already exists.</param>
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
