unit SimpleNetHTTPRequest;

interface

uses System.Classes, System.Net.UrlClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  ISimpleNetHTTPRequest = Interface
    function GetClient(): TNetHTTPClient;
    procedure SetClient(ANetHTTPClient: TNetHTTPClient);

    function GetOnReceiveData(): TReceiveDataEvent;
    procedure SetOnReceiveData(AReceiveDataEvent: TReceiveDataEvent);

    function GetOnRequestCompleted(): TRequestCompletedEvent;
    procedure SetOnRequestCompleted(ARequestCompletedEvent: TRequestCompletedEvent);

    function GetOnRequestError(): TRequestErrorEvent;
    procedure SetOnRequestError(ARequestErrorEvent: TRequestErrorEvent);

    property Client: TNetHTTPClient read GetClient write SetClient;
    property OnReceiveData: TReceiveDataEvent read GetOnReceiveData write SetOnReceiveData;
    property OnRequestCompleted: TRequestCompletedEvent read GetOnRequestCompleted write SetOnRequestCompleted;
    property OnRequestError: TRequestErrorEvent read GetOnRequestError write SetOnRequestError;

    function Get(const AURL: string; const AResponseContent: TStream = nil; const AHeaders: TNetHeaders = nil): IHTTPResponse;
    function Head(const AURL: string; const AHeaders: TNetHeaders = nil): IHTTPResponse;
  End;

implementation

end.
