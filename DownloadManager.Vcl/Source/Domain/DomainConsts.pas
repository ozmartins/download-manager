unit DomainConsts;

interface

const
  {$region 'messages'}
  cDownloadStarted = 'Download iniciado';
  cDownloadAborted = 'Download abortado pelo usuário';
  cFileSaved = 'Arquivo salvo em "%s"';
  cLogCreate = 'Log do download salvo com sucesso';
  cDownloaderIsNotDownloading = 'Erro interno: O downloader não está realizando um download.';
  cDownloaderIsBusy = 'Erro interno: O downloader está ocupado. Tente novamente mais tarde.';
  cUrlIsEmpty = 'Erro interno: O parâmetro "URL" está vazio.';
  cContentDisposition = 'Content-Disposition';
  cNetHTTPRequestIsNull = 'O parâmetro ANetHTTPRequestIsNull não pode ser nulo.';
  cDownloadCompleted = 'Download concluído com sucesso!';
  cDirectoryDoesntExists = 'Erro interno: O diretório de destino (%s) não existe.';
  cFileAlreadyExists  = 'Erro interno: O arquivo (%s) já existe.';
  cFileDoesntExists  = 'Erro interno: O arquivo (%s) não existe.';
  cFileNameIsEmpty  = 'Erro interno: O nome do arquivo está vazio.';
  cDirectoryPathIsEmpty  = 'Erro interno: O nome do diretório está vazio.';
  {$endregion}

implementation

end.
