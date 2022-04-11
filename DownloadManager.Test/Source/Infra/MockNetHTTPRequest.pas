unit MockNetHTTPRequest;

interface

uses System.Classes, System.Net.UrlClient, System.Net.HttpClient, System.Net.HttpClientComponent, SimpleNetHTTPRequest;

type
  TMockNetHTTPRequest = class(TInterfacedObject, ISimpleNetHTTPRequest)
  private
    fCompleteRequest: Boolean;
    fContentLength: Integer;
    fHttpResponseForGet: IHttpResponse;
    fHttpResponseForHead: IHttpResponse;
    fOnReceiveData: TReceiveDataEvent;
    fOnRequestCompleted: TRequestCompletedEvent;
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
    constructor Create(AHttpResponseForGet: IHttpResponse; AHttpResponseForHead: IHttpResponse; AContentLength: Integer; ACompleteRequest: Boolean);

    property Client: TNetHTTPClient read GetClient write SetClient;
    property OnReceiveData: TReceiveDataEvent read GetOnReceiveData write SetOnReceiveData;
    property OnRequestCompleted: TRequestCompletedEvent read GetOnRequestCompleted write SetOnRequestCompleted;
    property OnRequestError: TRequestErrorEvent read GetOnRequestError write SetOnRequestError;

    function Get(const AURL: string; const AResponseContent: TStream = nil; const AHeaders: TNetHeaders = nil): IHTTPResponse;
    function Head(const AURL: string; const AHeaders: TNetHeaders = nil): IHTTPResponse;
  End;

implementation

{ TMockNetHTTPRequest }

constructor TMockNetHTTPRequest.Create(AHttpResponseForGet: IHttpResponse; AHttpResponseForHead: IHttpResponse; AContentLength: Integer; ACompleteRequest: Boolean);
begin
  fCompleteRequest := ACompleteRequest;
  fHttpResponseForGet := AHttpResponseForGet;
  fHttpResponseForHead := AHttpResponseForHead;
  fContentLength := AContentLength;
end;

function TMockNetHTTPRequest.Get(const AURL: string; const AResponseContent: TStream; const AHeaders: TNetHeaders): IHTTPResponse;
var
  I: Integer;
  lAbort: Boolean;
begin
  for I := 0 to fContentLength do
  begin
    lAbort := False;

    if Assigned(OnReceiveData) then
      OnReceiveData(nil, fContentLength, I, lAbort);

    if lAbort then break;
  end;

  if fCompleteRequest and Assigned(OnRequestCompleted) then
    OnRequestCompleted(nil, fHttpResponseForGet);

  Result := fHttpResponseForGet;
end;

function TMockNetHTTPRequest.GetClient: TNetHTTPClient;
begin
  Result := nil;
end;

function TMockNetHTTPRequest.GetOnReceiveData: TReceiveDataEvent;
begin
  Result := fOnReceiveData;
end;

function TMockNetHTTPRequest.GetOnRequestCompleted: TRequestCompletedEvent;
begin
  Result := fOnRequestCompleted;
end;

function TMockNetHTTPRequest.GetOnRequestError: TRequestErrorEvent;
begin
  //
end;

function TMockNetHTTPRequest.Head(const AURL: string; const AHeaders: TNetHeaders): IHTTPResponse;
begin
  Result := fHttpResponseForHead;
end;

procedure TMockNetHTTPRequest.SetClient(ANetHTTPClient: TNetHTTPClient);
begin
end;

procedure TMockNetHTTPRequest.SetOnReceiveData(AReceiveDataEvent: TReceiveDataEvent);
begin
  fOnReceiveData := AReceiveDataEvent;
end;

procedure TMockNetHTTPRequest.SetOnRequestCompleted(ARequestCompletedEvent: TRequestCompletedEvent);
begin
  fOnRequestCompleted := ARequestCompletedEvent;
end;

procedure TMockNetHTTPRequest.SetOnRequestError(
  ARequestErrorEvent: TRequestErrorEvent);
begin

end;

end.
