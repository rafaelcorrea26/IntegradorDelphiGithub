unit uSystem;

interface

uses
  System.JSON,
  REST.JSON,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  System.SysUtils;

type
  TSystem = class;

  TSystem = class
  private
    FName: string;

  public
    destructor Destroy; override;

    property Name: string read FName write FName;
    constructor Create;
    function ToJson: TJSONObject;
  end;

implementation

function TSystem.ToJson: TJSONObject;
begin
  result := TJson.ObjectToJsonObject(self, [joIgnoreEmptyStrings]);
end;

constructor TSystem.Create;
begin

end;

destructor TSystem.Destroy;
begin
end;

end.
