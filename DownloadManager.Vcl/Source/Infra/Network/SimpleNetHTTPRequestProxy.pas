unit SimpleNetHTTPRequestProxy;

interface

uses System.Classes, System.Net.UrlClient, System.Net.HttpClient, System.Net.HttpClientComponent, SimpleNetHTTPRequest;

type
  /// <summary> This is a proxy class that maps the ISimpleNetHTTPRequest interface to a TNetHTTPRequest object.</summary>
  TSimpleNetHTTPRequestProxy = class(TInterfacedObject, ISimpleNetHTTPRequest)
  private
    fNetHTTPRequest: TNetHTTPRequest;
  protected
    function GetClient(): TNetHTTPClient;
    procedure SetClient(ANetHTTPClient: TNetHTTPClient);

    function GetOnReceiveData(): TReceiveDataEvent;
    procedure SetOnReceiveData(AReceiveDataEvent: TReceiveDataEvent);

    function GetOnRequestCompleted(): TRequestCompletedEvent;
    procedure SetOnRequestCompleted(ARequestCompletedEvent: TRequestCompletedEvent);

    function GetOnRequestError(): TRequestErrorEvent;
    procedure SetOnRequestError(ARequestErrorEvent: TRequestErrorEvent);
  public
    constructor Create(ANetHTTPRequest: TNetHTTPRequest);

    property Client: TNetHTTPClient read GetClient write SetClient;
    property OnReceiveData: TReceiveDataEvent read GetOnReceiveData write SetOnReceiveData;
    property OnRequestCompleted: TRequestCompletedEvent read GetOnRequestCompleted write SetOnRequestCompleted;
    property OnRequestError: TRequestErrorEvent read GetOnRequestError write SetOnRequestError;

    function Get(const AURL: string; const AResponseContent: TStream = nil; const AHeaders: TNetHeaders = nil): IHTTPResponse;
    function Head(const AURL: string; const AHeaders: TNetHeaders = nil): IHTTPResponse;
  End;

implementation

{ TSimpleNetHTTPRequestProxy }

constructor TSimpleNetHTTPRequestProxy.Create(ANetHTTPRequest: TNetHTTPRequest);
begin
  fNetHTTPRequest := ANetHTTPRequest;
end;

function TSimpleNetHTTPRequestProxy.Get(const AURL: string; const AResponseContent: TStream; const AHeaders: TNetHeaders): IHTTPResponse;
begin
  Result := fNetHTTPRequest.Get(AURL, AResponseContent, AHeaders);
end;

function TSimpleNetHTTPRequestProxy.GetClient: TNetHTTPClient;
begin
  Result := fNetHTTPRequest.Client;
end;

function TSimpleNetHTTPRequestProxy.GetOnReceiveData: TReceiveDataEvent;
begin
  Result := fNetHTTPRequest.OnReceiveData;
end;

function TSimpleNetHTTPRequestProxy.GetOnRequestCompleted: TRequestCompletedEvent;
begin
  Result := fNetHTTPRequest.OnRequestCompleted;
end;

function TSimpleNetHTTPRequestProxy.GetOnRequestError: TRequestErrorEvent;
begin
  Result := fNetHTTPRequest.OnRequestError;
end;

function TSimpleNetHTTPRequestProxy.Head(const AURL: string; const AHeaders: TNetHeaders): IHTTPResponse;
begin
  Result := fNetHTTPRequest.Head(AURL, AHeaders);
end;

procedure TSimpleNetHTTPRequestProxy.SetClient(ANetHTTPClient: TNetHTTPClient);
begin
  fNetHTTPRequest.Client := ANetHTTPClient;
end;

procedure TSimpleNetHTTPRequestProxy.SetOnReceiveData(AReceiveDataEvent: TReceiveDataEvent);
begin
  fNetHTTPRequest.OnReceiveData := AReceiveDataEvent;
end;

procedure TSimpleNetHTTPRequestProxy.SetOnRequestCompleted(ARequestCompletedEvent: TRequestCompletedEvent);
begin
  fNetHTTPRequest.OnRequestCompleted := ARequestCompletedEvent;
end;

procedure TSimpleNetHTTPRequestProxy.SetOnRequestError(ARequestErrorEvent: TRequestErrorEvent);
begin
  fNetHTTPRequest.OnRequestError := ARequestErrorEvent;
end;

end.
