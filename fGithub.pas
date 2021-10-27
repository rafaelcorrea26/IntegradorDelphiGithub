unit fGithub;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uConnectionAPI;

type
  TfrmGithub = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGithub: TfrmGithub;

implementation

{$R *.dfm}

procedure TfrmGithub.Button1Click(Sender: TObject);
begin
  TConnectionAPI.ConnectionAPI.GetFollowers;
end;

end.
