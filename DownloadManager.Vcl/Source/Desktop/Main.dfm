object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Download Manager'
  ClientHeight = 476
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 15
  object DownloadGroupBox: TGroupBox
    Left = 0
    Top = 0
    Width = 584
    Height = 91
    Align = alTop
    Caption = 'Download'
    TabOrder = 0
    DesignSize = (
      584
      91)
    object DownloadButton: TButton
      Left = 10
      Top = 52
      Width = 140
      Height = 25
      Caption = 'Iniciar download'
      TabOrder = 1
      OnClick = DownloadButtonClick
    end
    object StopButton: TButton
      Left = 151
      Top = 52
      Width = 140
      Height = 25
      Caption = 'Parar download'
      Enabled = False
      TabOrder = 2
      OnClick = StopButtonClick
    end
    object ProgressBar: TProgressBar
      Left = 10
      Top = 23
      Width = 565
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      ParentDoubleBuffered = False
      Smooth = True
      MarqueeInterval = 1
      Step = 1
      TabOrder = 3
      Visible = False
    end
    object ViewProgressButton: TButton
      Left = 293
      Top = 52
      Width = 140
      Height = 25
      Caption = 'Ver mensagem'
      Enabled = False
      TabOrder = 4
      OnClick = ViewProgressButtonClick
    end
    object HistoryButton: TButton
      Left = 439
      Top = 52
      Width = 140
      Height = 25
      Caption = 'Ver hist'#243'rico'
      TabOrder = 5
      OnClick = HistoryButtonClick
    end
    object UrlEdit: TEdit
      Left = 10
      Top = 23
      Width = 565
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 
        'https://az764295.vo.msecnd.net/stable/78a4c91400152c0f27ba4d363e' +
        'b56d2835f9903a/VSCodeUserSetup-x64-1.43.0.exe'
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 457
    Width = 584
    Height = 19
    Color = clMaroon
    Panels = <
      item
        Width = 50
      end>
  end
  object LogMemo: TMemo
    Left = 0
    Top = 91
    Width = 584
    Height = 366
    Align = alClient
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
    ExplicitTop = 85
  end
  object SqLiteConnection: TSQLConnection
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DbxSqlite'
      
        'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bp' +
        'l'
      
        'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqlite' +
        'Driver280.bpl'
      'FailIfMissing=True'
      
        'Database=D:\softplan\prova-delphi\v3\download-manager\DownloadMa' +
        'nager.Vcl\Win32\Debug\DownloadManager.Vcl.db')
    Left = 295
    Top = 176
  end
  object LogDownloadSqlDataSet: TSQLDataSet
    CommandText = 'select * from logdownload'
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SqLiteConnection
    Left = 295
    Top = 232
  end
  object LogDownloadDataSource: TDataSource
    DataSet = LogDownloadClientDataSet
    Left = 295
    Top = 368
  end
  object LogDownloadClientDataSet: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'LogDownloadProvider'
    OnReconcileError = LogDownloadClientDataSetReconcileError
    Left = 295
    Top = 320
  end
  object LogDownloadProvider: TDataSetProvider
    DataSet = LogDownloadSqlDataSet
    Left = 295
    Top = 272
  end
  object NetHTTPRequest: TNetHTTPRequest
    ConnectionTimeout = 0
    SendTimeout = 0
    ResponseTimeout = 0
    Left = 72
    Top = 168
  end
  object SequenceSQLDataSet: TSQLDataSet
    CommandText = 'select * from sequence'
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SqLiteConnection
    Left = 455
    Top = 184
  end
  object SequenceDataSetProvider: TDataSetProvider
    DataSet = SequenceSQLDataSet
    Left = 455
    Top = 232
  end
  object SequenceClientDataSet: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'SequenceDataSetProvider'
    OnReconcileError = LogDownloadClientDataSetReconcileError
    Left = 455
    Top = 280
  end
  object SequenceDataSource: TDataSource
    DataSet = SequenceClientDataSet
    Left = 455
    Top = 328
  end
  object FileSaveDialog: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoOverWritePrompt, fdoPathMustExist, fdoCreatePrompt]
    Left = 184
    Top = 120
  end
end
