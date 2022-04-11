unit LogDownload;

interface

type
  TLogDownload = class
  private
    fId : Int64;
    fUrl: String;
    fStartDate: TDateTime;
    fFinishDate: TDateTime;
  public
    constructor Create(AId: Int64; AUrl: String; AStartDate: TDateTime; AFinishDate: TDateTime);

    property Id : Int64 read fId;
    property Url : String read fUrl;
    property StartDate : TDateTime read fStartDate;
    property FinishDate : TDateTime read fFinishDate;
  end;

implementation

{ TLogDownload }

constructor TLogDownload.Create(AId: Int64; AUrl: String; AStartDate, AFinishDate: TDateTime);
begin
  fId := AId;
  fUrl := AUrl;
  fStartDate := AStartDate;
  fFinishDate := AFinishDate;
end;

end.
