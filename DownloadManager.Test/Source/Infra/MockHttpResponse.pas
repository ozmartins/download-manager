unit MockHttpResponse;

interface

uses
  System.Net.HttpClient, System.Classes, System.Net.URLClient;

type
  TMockHttpResponse = class(THttpResponse)
  strict private
    fStatusCode: Integer;
    fHeaderValue: String;
    fContainsHeader: Boolean;
  public
    constructor Create(AStatusCode: Integer; AHeaderValue: String; AContainsHeader: Boolean); overload;

    //used
    function GetHeaderValue(const AName: string): string; override;
    function ContainsHeader(const AName: string): Boolean; override;

    //unused
    procedure DoReadData(const AStream: TStream); override;
    function GetStatusCode: Integer; override;
    function GetStatusText: string; override;
    function GetVersion: THTTPProtocolVersion; override;
    function GetHeaders: TNetHeaders; override;
  end;

implementation

uses
  Constants;

{ TMockHttpResponse }

function TMockHttpResponse.ContainsHeader(const AName: string): Boolean;
begin
  Result := fContainsHeader;
end;

constructor TMockHttpResponse.Create(AStatusCode: Integer; AHeaderValue: String; AContainsHeader: Boolean);
begin
  fStatusCode := AStatusCode;
  fHeaderValue := AHeaderValue;
  fContainsHeader := AContainsHeader;
end;

procedure TMockHttpResponse.DoReadData(const AStream: TStream);
begin
  inherited;
end;

function TMockHttpResponse.GetHeaders: TNetHeaders;
begin
  Result := nil;
end;

function TMockHttpResponse.GetHeaderValue(const AName: string): string;
begin
  Result := fHeaderValue;
end;

function TMockHttpResponse.GetStatusCode: Integer;
begin
  Result := fStatusCode;
end;

function TMockHttpResponse.GetStatusText: string;
begin
  Result := cEmptyString;
end;

function TMockHttpResponse.GetVersion: THTTPProtocolVersion;
begin
  Result := THTTPProtocolVersion.HTTP_2_0;
end;

end.
