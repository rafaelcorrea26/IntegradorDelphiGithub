unit uHttp;

interface

uses
  System.JSON,
  REST.JSON,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  System.SysUtils;

type
  THttp = class;

  THttp = class
  private
    FReturnStatus :string;
    FErrorCause: string;
    FReturnMessage : string;

  public
    destructor Destroy; override;
    property ReturnStatus: string read FReturnStatus write FReturnStatus;
    property ErrorCause: string read FErrorCause write FErrorCause;
    property ReturnMessage  : string read FReturnMessage write FReturnMessage;

    function ToJson: TJSONObject;

    constructor Create;
  end;

implementation

function THttp.ToJson: TJSONObject;
begin
  result := TJson.ObjectToJsonObject(self);
end;

constructor THttp.Create;
begin
end;

destructor THttp.Destroy;
begin
  inherited;
end;

end.
