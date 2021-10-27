program Github;

uses
  Vcl.Forms,
  fGithub in 'fGithub.pas' {frmGithub},
  uConnectionAPI in 'Classes\uConnectionAPI.pas',
  uHttp in 'Classes\uHttp.pas',
  uSystem in 'Classes\uSystem.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmGithub, frmGithub);
  Application.Run;
end.
