unit RepositoryConsts;

interface

const
  cDormConfFile = 'dorm.conf';

  cDormConfFileContent = '{' + #13#10 +
                         '  "persistence": {'+ #13#10 +
                         '    "development": {'+ #13#10 +
                         '      "database_adapter": "dorm.adapter.Sqlite3.TSqlite3PersistStrategy",'+ #13#10 +
                         '      "database_connection_string": "%s",'+ #13#10 +
                         '      "key_type": "integer",'+ #13#10 +
                         '      "null_key_value": null,'+ #13#10 +
                         '      "keys_generator": "dorm.adapter.UIB.Firebird.TUIBFirebirdTableSequence"'+ #13#10 +
                         '    },'+ #13#10 +
                         '    "release": {'+ #13#10 +
                         '      "database_adapter": "dorm.adapter.Sqlite3.TSqlite3PersistStrategy",'+ #13#10 +
                         '      "database_connection_string": "%s",'+ #13#10 +
                         '      "key_type": "integer",'+ #13#10 +
                         '      "null_key_value": null,'+ #13#10 +
                         '      "keys_generator": "dorm.adapter.UIB.Firebird.TUIBFirebirdTableSequence"'+ #13#10 +
                         '    },'+ #13#10 +
                         '    "test": {'+ #13#10 +
                         '      "database_adapter": "dorm.adapter.Sqlite3.TSqlite3PersistStrategy",'+ #13#10 +
                         '      "database_connection_string": "%s",'+ #13#10 +
                         '      "key_type": "integer",'+ #13#10 +
                         '      "null_key_value": null,'+ #13#10 +
                         '      "keys_generator": "dorm.adapter.UIB.Firebird.TUIBFirebirdTableSequence"'+ #13#10 +
                         '    }'+ #13#10 +
                         '  },'+ #13#10 +
                         '  "config": {'+ #13#10 +
                         '    "logger_class_name": "dorm.loggers.FileLog.TdormFileLog"'+ #13#10 +
                         '  }'+ #13#10 +
                         '}';

implementation

end.
