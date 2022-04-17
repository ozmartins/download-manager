unit DomainConsts;

interface

const
  cDownloadStarted = 'Download iniciado';
  cDownloadAborted = 'Download abortado pelo usuário';
  cFileSaved = 'Arquivo salvo em "%s"';
  cLogCreate = 'Log do download salvo com sucesso';

  cDownloaderIsNotDownloading = 'Erro interno: O downloader não está realizando um download.';
  cDownloaderIsBusy = 'Erro interno: O downloader está ocupado. Tente novamente mais tarde.';
  cUrlIsEmpty = 'Erro interno: O parâmetro "URL" está vazio.';
  cResponseHeaderDoesNotContainsContentField = 'Erro interno: O cabeçalho da resposta HTTP não possui o campo "Content-Disposition".';
  cContentDisposition = 'Content-Disposition';
  cNetHTTPRequestIsNull = 'O parâmetro ANetHTTPRequestIsNull não pode ser nulo.';
  cDownloadCompleted = 'Download concluído com sucesso!';

  cInvalidContentDispositionTypeMessage = 'Erro interno: Valor inválido para o parâmetro AContentDisposition.';

  cDirectoryDoesntExists = 'Erro interno: The destination directory (%s) doesn''t exists.';
  cFileAlreadyExists  = 'Erro interno: The file (%s) already exists.';
  cFileDoesntExists  = 'Erro interno: The file (%s) doesn''t exists.';
  cFileNameIsEmpty  = 'Erro interno: The file name is empty.';
  cDirectoryPathIsEmpty  = 'Erro interno: The directory name is empty.';

implementation

end.
