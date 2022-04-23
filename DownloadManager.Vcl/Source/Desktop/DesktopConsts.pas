unit DesktopConsts;

interface

const
  {$region 'messages'}
  cEmptyUrlMessage = 'Eu preciso de uma URL para fazer o download.';
  cDownloaderIsBusyMessage = 'Já existe um download em andamento e eu não suporto downloads simultâneos (ainda). Aguarde um pouco, por favor.';
  cDownloaderCantStopNowMessage = 'Não há downloads em andamento no momento.';
  cDownloadInterruptConfirmationMessage = 'Existe um download em andamento. Se você me fechar, o download será interrompido. Quer realmente me fechar?';
  cDownloadProgressMessage = 'Progresso: %s';
  {$endregion}

  {$region 'SQL connection configuration'}
  cDriverUnit = 'DriverUnit=Data.DbxSqlite';
  cDriverPackageLoader = 'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bpl';
  cMetaDataPackageLoader = 'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqliteDriver280.bpl';
  cFailIfMissing = 'FailIfMissing=True';
  cDatabase = 'Database=%s';
  {$endregion}

  {$region 'Others'}
  cDownloadDirectoryName = 'Download';
  cDatabaseFileExtension = '.db';
  cViewMessageButtonCaption = 'Ver mensagem';
  cLogText = '[%s] -> %s';
  cShellExecuteOperationOpen = 'open';
  cShellExecuteOperationParameter = '/select,';
  cWindowsExplorer = 'explorer.exe';
  cScrollBarWidth = 37;
  {$endregion}

implementation

end.
