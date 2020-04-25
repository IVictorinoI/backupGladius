program BackupGladius;

uses
  Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FormBackup};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormBackup, FormBackup);
  Application.Run;
end.
