unit uConnectionAPI;

interface

uses
  REST.Client,
  IPPeerClient,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  REST.Response.Adapter,
  REST.Types,
  System.JSON,
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  System.DateUtils,
  REST.Authenticator.OAuth,
  Vcl.StdCtrls,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  uSystem,
  Winapi.Windows,
  Vcl.ExtCtrls,
  System.Math,
  System.StrUtils,
  Vcl.Grids,
  System.Win.Registry,
  Vcl.Samples.Gauges,
  REST.Authenticator.Basic,
  System.NetEncoding;

type

  TServiceAPI = (tGetFiles, tPostFiles, tUpdateFiles, tGetFollowers, tPostFollowers, tUpdateFollowers);

  TConnectionAPI = class
  private
    const
    FUrlAPI: string = 'https://api.github.com/users/';
    FUsername: string = 'yourUser'; // you really user
    FPersonalAcessTokens: string = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // you token, do you can generated

  var
    FMessage: string;
    FTotalFilesPosted: Integer;
    FTotalFilesUpdated: Integer;
    FTotalFilesError: Integer;

{$REGION 'Status (HttpStatusCodeb)API'}
    {
      200/201 - OK

      401/403 - Unauthorized

      400/404 - Bad Resquest or Not Found
    }
{$ENDREGION}
{$REGION 'Components for connection with API'}
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRestResponse: TRESTResponse;
    FBasicAuth: THTTPBasicAuthenticator;

    class var FConnectionAPI: TConnectionAPI;
{$ENDREGION}
{$REGION 'Méthods for configuration and connettion with API'}
    procedure UrlRestClient(pType: TServiceAPI);
    procedure ConfigConnectionAPI(pMethod: TRESTRequestMethod; pServico: TServiceAPI; pJson: string);
    class function GetConnectionAPI: TConnectionAPI; static;
{$ENDREGION}
{$REGION 'Méthods TOKEN'}
{$ENDREGION}
{$REGION 'Messages'}
{$ENDREGION}
  public
    constructor Create;
    destructor Destroy; override;
{$REGION 'Méthods Get'}
    function GetFiles: string;
    function GetFollowers: string;

{$ENDREGION}
{$REGION 'Méthods Delete'}
    function DeleteFiles(pCodVenda: String): string;
{$ENDREGION}
{$REGION 'Méthods Update'}
    procedure UpdateFiles(pJson, pCodProduto, pSku: String);
{$ENDREGION}
{$REGION 'Méthods and Functions publics'}
    procedure RegisterAppOnWindows(pProgram: string);
    function TamString(pString: string; pTamanho: Integer): string;
    function SystemVersion: string;
    function RemoveCharacterSpecial(aText: string): string;
    procedure ServerResponseToFile;
    procedure CreateFileTxtLog(pJason, pNomeTXT: string);
    function DecodeDateHour(pData: TDateTime): string;
    function IsDigit(pString: string): Boolean;
    function ReturnAutorizationBase64String(pSenha: String): string;
{$ENDREGION}
    property TotalFilesPosted: Integer read FTotalFilesPosted write FTotalFilesPosted;
    property TotalFilesUpdated: Integer read FTotalFilesUpdated write FTotalFilesUpdated;
    property TotalFilesError: Integer read FTotalFilesError write FTotalFilesError;

    property message: string read FMessage write FMessage;

    class procedure ReleaseMe;
    class property ConnectionAPI: TConnectionAPI read GetConnectionAPI write FConnectionAPI;

  end;

implementation

{ TConnectionAPI }

function TConnectionAPI.GetFiles: string;
var
  lSystem: TSystem;

begin
  result := '';

  ConfigConnectionAPI(rmGET, tGetFiles, '');

  if (TamString(IntToStr(FRestResponse.StatusCode), 1)) = '2' then
  begin
    lSystem := TSystem.Create;
    try
      try
        ServerResponseToFile; // ShowMessage(FRestResponse.Content);
      except
        on E: Exception do
        begin
          result := 'Error, you can try later.';
        end;
      end;
    finally
      lSystem.free;
    end;
  end
  else if (FRestResponse.StatusCode <> 400) then
  begin
    FMessage := ('Error, you can try later. Error:' + IntToStr(FRestResponse.StatusCode));
  end;
end;

function TConnectionAPI.GetFollowers: string;
var
  lSystem: TSystem;

begin
  result := '';
  ConfigConnectionAPI(rmGET, tGetFollowers, '');
  if (TamString(IntToStr(FRestResponse.StatusCode), 1)) = '2' then
  begin
    lSystem := TSystem.Create;
    try
      try
        ShowMessage(FRestResponse.Content);
      except
        on E: Exception do
        begin
          result := 'Erro.';
        end;
      end;
    finally
      lSystem.free;
    end;
  end
  else if (FRestResponse.StatusCode <> 400) then
  begin
    FMessage := ('Erro:' + IntToStr(FRestResponse.StatusCode));
  end;
end;

procedure TConnectionAPI.ConfigConnectionAPI(pMethod: TRESTRequestMethod; pServico: TServiceAPI; pJson: string);
begin

  try
    FRestClient.ResetToDefaults;
    UrlRestClient(pServico);
    FRestResponse.ResetToDefaults;
    FRestResponse.ContentEncoding := 'utf8';
    FRestRequest.ResetToDefaults;
    FRestRequest.Client := FRestClient;
    FRestRequest.ClearBody;
    FRestRequest.Response := FRestResponse;
    // FRestRequest.Params.Clear;
    // FRestRequest.Params.AddHeader('Authorization', 'Bearer' + FPassword);

    FBasicAuth.ResetToDefaults;
    FBasicAuth.Username := FUsername;
    FBasicAuth.Password := FPersonalAcessTokens;
    FRestClient.Authenticator := FBasicAuth;

    if trim(pJson) <> '' then
    begin
      FRestRequest.AddBody(pJson, ctAPPLICATION_JSON);
    end;

    FRestRequest.Method := pMethod; // showmessage(pJson);
    FRestRequest.Execute;
  Except
    on E: Exception do
    begin
      ShowMessage(FRestResponse.Content);
    end;
  end;
End;

constructor TConnectionAPI.Create;
begin
  FRestClient := TRESTClient.Create('');
  FRestRequest := TRESTRequest.Create(nil);
  FRestResponse := TRESTResponse.Create(nil);
  FBasicAuth := THTTPBasicAuthenticator.Create(nil);
end;

function TConnectionAPI.DecodeDateHour(pData: TDateTime): string;
var
  lAno, lMes, lDia, lHora, lMinuto, lSegundo, lMilisegundo: Word;
begin
  decodedatetime(now, lAno, lMes, lDia, lHora, lMinuto, lSegundo, lMilisegundo);
  result := lAno.ToString + FormatFloat('00', lMes) + FormatFloat('00', lDia) + FormatFloat('00', lHora) +
    FormatFloat('00', lMinuto) + FormatFloat('00', lSegundo);
end;

function TConnectionAPI.DeleteFiles(pCodVenda: String): string;
begin
  result := '';
  result := IntToStr(FRestResponse.StatusCode);
end;

destructor TConnectionAPI.Destroy;
begin
  FRestClient.free;
  FRestRequest.free;
  FRestResponse.free;
  FBasicAuth.free;
  inherited;
end;

class function TConnectionAPI.GetConnectionAPI: TConnectionAPI;
begin
  if NOT Assigned(FConnectionAPI) then
  begin
    FConnectionAPI := TConnectionAPI.Create;
  end;

  result := FConnectionAPI;

end;

procedure TConnectionAPI.CreateFileTxtLog(pJason, pNomeTXT: string);
var
  FBackupTxt: TStringList;
  lPublicAppDirectory, lFileNameTxt, lFullPathFile: string;
begin
  FBackupTxt := TStringList.Create;
  try
    FBackupTxt.Text := pJason;
    lPublicAppDirectory := ExtractFilePath(application.exeName) + 'Log_Erros\';
    lFileNameTxt := pNomeTXT + '_' + DecodeDateHour(now) + '.txt';
    lFullPathFile := lPublicAppDirectory + lFileNameTxt;
    // ShowMessage(lCaminhoDocumentos);

    if not DirectoryExists(lPublicAppDirectory) then
    begin
      ForceDirectories(lPublicAppDirectory);
    end;

    if DirectoryExists(lPublicAppDirectory) then
    begin
      FBackupTxt.SaveToFile(lFullPathFile);
    end;
  finally
    FBackupTxt.free;
  end;
end;

function TConnectionAPI.IsDigit(pString: string): Boolean;
begin
  result := True;
  Try
    strtoint(pString);
  Except
    result := false;
  end;
end;

procedure TConnectionAPI.RegisterAppOnWindows(pProgram: string);
var
  REG: TRegistry;
begin
  REG := TRegistry.Create;
  try
    REG.RootKey := HKEY_CURRENT_USER;
    REG.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run\', True);
    REG.WriteString(pProgram, ParamStr(0));
    REG.CloseKey;
    ShowMessage('Programa adicionado na inicialização do Windows com sucesso!');
  finally
    REG.free;
  end;
end;

class procedure TConnectionAPI.ReleaseMe;
begin
  if Assigned(FConnectionAPI) then
  begin
    FreeAndNil(FConnectionAPI);
  end;
end;

function TConnectionAPI.RemoveCharacterSpecial(aText: string): string;
const
  // Lista de Caracteres Extras
  xCarExt: array [1 .. 55] of string = ('<', '>', '!', '@', '#', '$', '%', '¨', '&', '*', '(', ')', '_', '+', '=', '{',
    '}', '[', ']', '?', ';', ':', ',', '|', '*', '"', '~', '^', '´', '`', '¨', 'æ', 'Æ', 'ø', '£', 'Ø', 'ƒ', 'ª', 'º',
    '¿', '®', '½', '¼', 'ß', 'µ', 'þ', 'ý', 'Ý', '÷', '×', '€', '-', '\', '/', '.');
var
  xTexto: string;
  i: Integer;
begin
  xTexto := aText;

  for i := 1 to 55 do
  begin
    xTexto := StringReplace(xTexto, xCarExt[i], '', [rfReplaceAll]);
  end;

  result := xTexto;

end;

function TConnectionAPI.ReturnAutorizationBase64String(pSenha: String): string;
var
  lTexto, lResult: string;
  Base64: TBase64Encoding;
begin

  try
    Base64 := TBase64Encoding.Create;

    lResult := Base64.Decode(lTexto);

    lResult := Copy(lResult, 35, lResult.Length);

    result := lResult;
  except
    on E: Exception do
    begin
      result := pSenha;
    end;
  end;
end;

procedure TConnectionAPI.ServerResponseToFile;
var
  SomeStream: tmemorystream;
  local_filename: string;
begin
{$IF DEFINED(MsWindows)}
  local_filename := ExtractFilePath(ParamStr(0)); // + 'syncdownload/Northwindpers.sqlite3';
{$ENDIF}
  SomeStream := tmemorystream.Create;
  SomeStream.WriteData(FRestResponse.RawBytes, Length(FRestResponse.RawBytes));
  SomeStream.SaveToFile(local_filename);
  SomeStream.free;
end;

function TConnectionAPI.SystemVersion: string;
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
  V1, V2, V3: Word;
  cV1, cV2, cV3: string;
  FileName: string;
begin
  FileName := application.exeName;
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    V1 := dwFileVersionMS shr 16;
    V2 := dwFileVersionMS and $FFFF;
    V3 := dwFileVersionLS shr 16;
    // V4 := dwFileVersionLS and $FFFF;
  end;
  FreeMem(VerInfo, VerInfoSize);

  cV1 := IntToStr(V1);
  cV2 := IntToStr(V2);
  cV3 := IntToStr(V3);
  result := cV1 + '.' + cV2 + '.' + cV3;
end;

procedure TConnectionAPI.UpdateFiles(pJson, pCodProduto, pSku: String);
begin

end;

procedure TConnectionAPI.UrlRestClient(pType: TServiceAPI);
begin
  case pType of
    tGetFiles:
      FRestClient.BaseURL := FUrlAPI + FUsername + '/repos/' + '/';

    tGetFollowers:
      FRestClient.BaseURL := FUrlAPI + 'followers';
  end;
end;

function TConnectionAPI.TamString(pString: string; pTamanho: Integer): string;
begin
  result := Copy(pString, 1, pTamanho);
end;

initialization

finalization

TConnectionAPI.ReleaseMe;

end.
