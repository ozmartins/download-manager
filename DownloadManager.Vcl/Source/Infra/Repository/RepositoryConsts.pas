unit RepositoryConsts;

interface

const
  {$region 'log download field names'}
  cIdFieldName = 'codigo';
  cUrlFieldName = 'url';
  cStartDateFieldName = 'datainicio';
  cFinishDateFieldName = 'datafim';
  {$endregion}

  {$region 'sequence field names'}
  cLastIdFieldName = 'ultimocodigo';
  cTableNameFieldName = 'nometabela';
  {$endregion}

  {$region 'select'}
  cCommandTextForOneRegistry = 'select * from %s where %s = :codigo';
  cCommandTextForNoRegistry = 'select * from %s where 1=2';
  cCommandTextForAllRegistries = 'select * from %s';
  {$endregion}

  {$region 'SQLConnection'}
  cDriverNameProperty = 'Sqlite';
  cDriverNameParam = 'DriverName=Sqlite';
  cDatabaseParam = 'Database=%s';
  cSelectLastTableID = 'select ultimocodigo, nometabela from sequence where nometabela = :nometabela';
  cSelectEspecificTableID = 'select * from sequence where nometabela = :nometabela and ultimocodigo = :ultimocodigo';
  {$endregion}

  {$region 'Messages'}
  cMoreThanOneRegistryFound = 'Algo muito estranho ocorreu: Há mais que um registro no banco de dados com o ID %d. Por favor, avise o desenvolvedor imediatamente.';
  cMoreThanZeroRegistryFound = 'Algo muito estranho ocorreu: O dataset deveria estar vazio, mas não está. Isso é um bug e preciso que você avise o desenvolvedor.';
  cUnknownError = 'Erro desconhecido';
  cTableNameParameterIsEmpty = 'O parâmetro ATableName está vazio';
  {$endregion}

  {$region 'Others'}
  cLastIdField = 'ultimocodigo';
  cTableNameField = 'nometabela';
  cLogDownloadTableName = 'logdownload';
  cSequenceTableName = 'sequence';
  {$endregion}

implementation

end.
