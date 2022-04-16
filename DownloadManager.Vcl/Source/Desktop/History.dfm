object HistoryForm: THistoryForm
  Left = 0
  Top = 0
  Caption = 'Hist'#243'rico'
  ClientHeight = 455
  ClientWidth = 917
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object GridPanel: TPanel
    Left = 0
    Top = 0
    Width = 917
    Height = 399
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = -2
    ExplicitWidth = 603
    object HistoryDBGrid: TDBGrid
      Left = 0
      Top = 0
      Width = 917
      Height = 399
      Align = alClient
      DataSource = HistorySQLDataSetDataSource
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'DataInicio'
          Title.Alignment = taCenter
          Title.Caption = 'Data in'#237'cio'
          Width = 150
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'DataFim'
          Title.Alignment = taCenter
          Title.Caption = 'Data fim'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Url'
          Title.Caption = 'URL'
          Width = 580
          Visible = True
        end>
    end
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 399
    Width = 917
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 603
    DesignSize = (
      917
      37)
    object CloseButton: TButton
      Left = 832
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = CloseButtonClick
      ExplicitLeft = 518
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 436
    Width = 917
    Height = 19
    Panels = <>
    ExplicitWidth = 603
  end
  object HistorySQLDataSet: TSQLDataSet
    CommandText = 
      'select codigo, url, datainicio as datetime, datafim as datetime ' +
      'from logdownload order by datainicio'
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SqLiteConnection
    Left = 455
    Top = 184
    object HistorySQLDataSetCodigo: TLargeintField
      FieldName = 'Codigo'
      Required = True
    end
    object HistorySQLDataSetUrl: TWideStringField
      FieldName = 'Url'
      Required = True
      Size = 600
    end
    object HistorySQLDataSetDataInicio: TWideMemoField
      FieldName = 'DataInicio'
      Required = True
      BlobType = ftWideMemo
      Size = 1
    end
    object HistorySQLDataSetDataFim: TWideMemoField
      FieldName = 'DataFim'
      BlobType = ftWideMemo
      Size = 1
    end
  end
  object HistoryDataSetProvider: TDataSetProvider
    DataSet = HistorySQLDataSet
    Left = 455
    Top = 232
  end
  object HistoryClientDataSet: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'HistoryDataSetProvider'
    Left = 455
    Top = 280
    object HistoryClientDataSetCodigo: TLargeintField
      FieldName = 'Codigo'
      Required = True
    end
    object HistoryClientDataSetUrl: TWideStringField
      FieldName = 'Url'
      Required = True
      Size = 600
    end
    object HistoryClientDataSetDataInicio: TWideMemoField
      FieldName = 'DataInicio'
      Required = True
      OnGetText = DateGetText
      BlobType = ftWideMemo
    end
    object HistoryClientDataSetDataFim: TWideMemoField
      FieldName = 'DataFim'
      OnGetText = DateGetText
      BlobType = ftWideMemo
    end
  end
  object HistorySQLDataSetDataSource: TDataSource
    DataSet = HistoryClientDataSet
    Left = 455
    Top = 328
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
    Left = 455
    Top = 144
  end
end
