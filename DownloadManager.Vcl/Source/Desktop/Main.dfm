object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Download Manager'
  ClientHeight = 441
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
  OnResize = FormResize
  TextHeight = 15
  object DownloadGroupBox: TGroupBox
    Left = 0
    Top = 0
    Width = 584
    Height = 89
    Align = alTop
    Caption = 'Download'
    TabOrder = 0
    DesignSize = (
      584
      89)
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
      Left = 435
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
    Top = 422
    Width = 584
    Height = 19
    Color = clMaroon
    Panels = <
      item
        Width = 50
      end>
  end
  object HistoryGroupBox: TGroupBox
    Left = 0
    Top = 89
    Width = 584
    Height = 333
    Align = alClient
    Caption = 'Hist'#243'rico'
    TabOrder = 2
    object HistoryDownloadsGrid: TDBGrid
      Left = 2
      Top = 17
      Width = 580
      Height = 314
      Align = alClient
      DataSource = LogDownloadDataSource
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'Codigo'
          Title.Caption = 'C'#243'digo'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Url'
          Title.Caption = 'URL'
          Width = 329
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DataInicio'
          Title.Caption = 'In'#237'cio'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DataFim'
          Title.Caption = 'Fim'
          Visible = True
        end>
    end
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
    Connected = True
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
  object NetHTTPClient: TNetHTTPClient
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 72
    Top = 240
  end
  object NetHTTPRequest: TNetHTTPRequest
    Client = NetHTTPClient
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
end
