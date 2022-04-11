object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Prova Delphi Minist'#233'rio P'#250'blico'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object DownloadGroupBox: TGroupBox
    Left = 0
    Top = 0
    Width = 624
    Height = 85
    Align = alTop
    Caption = 'Download'
    TabOrder = 0
    DesignSize = (
      624
      85)
    object UrlEdit: TEdit
      Left = 11
      Top = 23
      Width = 446
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 
        'https://az764295.vo.msecnd.net/stable/78a4c91400152c0f27ba4d363e' +
        'b56d2835f9903a/VSCodeUserSetup-x64-1.43.0.exe'
    end
    object DownloadButton: TButton
      Left = 463
      Top = 22
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Download'
      TabOrder = 1
      OnClick = DownloadButtonClick
    end
    object StopButton: TButton
      Left = 544
      Top = 22
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Parar'
      Enabled = False
      TabOrder = 2
      OnClick = StopButtonClick
    end
    object ProgressBar: TProgressBar
      Left = 13
      Top = 52
      Width = 608
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      DoubleBuffered = True
      ParentDoubleBuffered = False
      Smooth = True
      MarqueeInterval = 1
      Step = 1
      TabOrder = 3
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Color = clMaroon
    Panels = <
      item
        Width = 50
      end>
  end
  object HistoryGroupBox: TGroupBox
    Left = 0
    Top = 85
    Width = 624
    Height = 337
    Align = alClient
    Caption = 'Hist'#243'rico'
    TabOrder = 2
    OnClick = HistoryGroupBoxClick
    object HistoryDownloadsGrid: TDBGrid
      Left = 5
      Top = 27
      Width = 616
      Height = 307
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
          Width = 359
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
      
        'Database=D:\download-manager\v3\DownloadManager\DownloadManager.' +
        'Vcl\Win32\Debug\DownloadManager.Vcl.db')
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
    Active = True
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
    Top = 192
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
