unit UnitPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, IBDatabase, iniFiles, XPMan, StdCtrls, Buttons, IdIPWatch,
  IdBaseComponent, IdComponent, Menus, ShellApi;

type
  TFormBackup = class(TForm)
    DB: TIBDatabase;
    bbCriarBackup: TBitBtn;
    bbRestaurarBackup: TBitBtn;
    XPManifest1: TXPManifest;
    IdIPWatch1: TIdIPWatch;
    MemLog: TMemo;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Pastabackup1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure bbCriarBackupClick(Sender: TObject);
    procedure bbRestaurarBackupClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure Pastabackup1Click(Sender: TObject);
  private
    { Private declarations }
    procedure TestaConexao;
    procedure CriaDiretorioBackup;
    function CriarBackup(destino:String):boolean;
    function RestaurarBackup(origem, destino:String):boolean;
    function GetNomeArquivoBackup:String;
    function GetDataParaNomeArquivo:string;
    function GetNomeArquivoUltimoBackup:String;
    function GetNomeArquivoParaRestaurarBackup:String;
    function FormatWordToString(a:Word):string;
    function GetAppFolder:String;
    procedure DeletaUltimoBackup;
    procedure VerificaSeExisteBancoRestaurado;
    procedure ConfigurarArquivoIniComNovoBanco(caminhoBanco:string);
    function GetNomeArquivoGBak:String;
    procedure AdicionaTextoLog(texto:String);
  public
    { Public declarations }
  end;

var
  FormBackup: TFormBackup;

implementation

uses DateUtils;

{$R *.dfm}

{ TForm1 }

procedure TFormBackup.TestaConexao;
var
  ArquivoINI : TIniFile;
  caminho,caminho2,caminho3,caminho4,caminho5:string;
begin
  ArquivoIni:=TIniFile.Create('.\SISTEMA.INI');
  Try
    caminho:=ArquivoINI.ReadString('BANCO','caminho','');
    caminho2:=ArquivoINI.ReadString('BANCO','caminho2','');
    caminho3:=ArquivoINI.ReadString('BANCO','caminho3','');
    caminho4:=ArquivoINI.ReadString('BANCO','caminho4','');
    caminho5:=ArquivoINI.ReadString('BANCO','caminho5','');
  Finally
    ArquivoIni.Free;
  end;

  Try
    DB.Close;
    if (caminho<>'') then begin
      db.DatabaseName:=caminho;
    end;
    db.Open;
  except

    try
      DB.Close;
      if (caminho2<>'') then begin
        db.DatabaseName:=caminho2;
      end;
      db.Open;
    except
      try
        DB.Close;
        if (caminho3<>'') then begin
          db.DatabaseName:=caminho3;
        end;
        db.Open;
      except
        try
          DB.Close;
          if (caminho4<>'') then begin
            db.DatabaseName:=caminho4;
          end;
          db.Open;
        except
          try
            DB.Close;
            if (caminho5<>'') then begin
              db.DatabaseName:=caminho5;
            end;
            db.Open;
          except
            try
              if not(DB.Connected) then begin
                ShowMessage('Não foi possível conectar no banco de dados do servidor: '+db.DatabaseName);
                Application.Terminate;
              end;
            except
              application.terminate;
            end;
          end;//end do Quinto except, caminho5
        end;//end do Quarto except, caminho4
      end;//end do Terceiro except, caminho3
    end;//end do segundo except, caminho2
  end;//end do primeiro except, caminho
end;

procedure TFormBackup.FormShow(Sender: TObject);
begin
  TestaConexao;
  Self.Width:= 329;
end;

procedure TFormBackup.bbCriarBackupClick(Sender: TObject);
begin
  bbCriarBackup.Enabled := false;
  Self.CriaDiretorioBackup;
  Self.CriarBackup(Self.GetNomeArquivoBackup);
  Self.DeletaUltimoBackup;
  if (Self.CriarBackup(Self.GetNomeArquivoUltimoBackup)) then begin
    ShowMessage('OK: Finalizado!');
  end;
  bbCriarBackup.Enabled := true;
end;

function TFormBackup.CriarBackup(destino:String):boolean;
var strBackup, caminhooFdb, caminhoFbk, caminhoGBak : String;
begin
  try
    Screen.Cursor := crSQLWait;
    caminhoGBak := Self.GetNomeArquivoGBak();
    caminhooFdb := db.DatabaseName;
    caminhoFbk := destino;
    strBackup := '"'+caminhoGBak+'" -b -user SYSDBA -password masterkey "'+caminhooFdb+'" "'+caminhoFbk+'" ';

    AdicionaTextoLog(strBackup);

    WinExec(PChar(strBackup), 0);
    Sleep(1200);
    Screen.Cursor := crDefault;
    
    if((FileExists(caminhoFbk))) then begin
      Result:=true;
    end else begin
      ShowMessage('ERRO: O arquivo de backup NÃO foi criado!! '+caminhoFbk);
      Result:=false;
    end;
  except
    on e:Exception do begin
      Screen.Cursor := crDefault;
      ShowMessage('ERRO ao criar backup: '+e.Message+' FDB: '+caminhooFdb+' FBK: '+caminhoFbk+' Comando: '+strBackup);
    end;
  end;
end;

procedure TFormBackup.CriaDiretorioBackup;
var appFolder:String;
begin
  appFolder := Self.GetAppFolder;
  if(not(DirectoryExists(appFolder+'Backup')))then begin
    ForceDirectories(appFolder+'Backup');
  end;
  if(not(DirectoryExists(appFolder+'Backup\Banco')))then begin
    ForceDirectories(appFolder+'Backup\Banco');
  end;
  if(not(DirectoryExists(appFolder+'Banco')))then begin
    ForceDirectories(appFolder+'Banco');
  end;
end;

function TFormBackup.GetNomeArquivoBackup: String;
begin
  result := Self.GetAppFolder+'Backup\Banco\Backup_'+Self.GetDataParaNomeArquivo+'.fbk';
end;

function TFormBackup.FormatWordToString(a: Word): string;
var s : string;
begin
  s:=IntToStr(a);
  if(Length(s)=1)then begin
    s:='0'+s;
  end;
  result:= s;
end;

function TFormBackup.GetNomeArquivoUltimoBackup: String;
begin
  result := Self.GetAppFolder+'Backup\Banco\UltimoBackup.fbk';
end;

procedure TFormBackup.DeletaUltimoBackup;
begin
  if(FileExists(Self.GetNomeArquivoUltimoBackup))then begin
    DeleteFile(Self.GetNomeArquivoUltimoBackup);
  end;
end;

function TFormBackup.RestaurarBackup(origem, destino: String):boolean;
var strBackup, caminhooFdb, caminhoFbk, caminhoGBak : String;
   c : Cardinal;
begin
  try
    if(FileExists(caminhooFdb))then begin
      ShowMessage('ERRO: O arquivo restaurado já existe: '+caminhooFdb);
      Result := false;
      exit;
    end;

    Screen.Cursor := crSQLWait;
    caminhoGBak := Self.GetNomeArquivoGBak();
    caminhooFdb := destino;
    caminhoFbk := origem;
    strBackup := '"'+caminhoGBak+'" -r -user SYSDBA -password masterkey "'+caminhoFbk+'" "'+caminhooFdb+'" ';

    AdicionaTextoLog(strBackup);

    WinExec(PChar(strBackup), 0);
    Sleep(1200);
    Screen.Cursor := crDefault;

    if(FileExists(caminhooFdb))then begin
      Result := true;
    end else begin
      ShowMessage('ERRO: O arquivo de restauração não foi criado!!! fbk:'+caminhoFbk+', fbd:'+caminhooFdb);
      Result := false;
    end;

  except
    on e:Exception do begin
      Screen.Cursor := crDefault;
      ShowMessage('ERRO ao restaurar backup: '+e.Message+', FDB: '+caminhooFdb+', FBK: '+caminhoFbk+', Comando: '+strBackup);
    end;
  end;
end;

function TFormBackup.GetNomeArquivoParaRestaurarBackup: String;
begin

  result := Self.GetAppFolder+'Banco\BancoRestaurado.fdb';
end;

procedure TFormBackup.bbRestaurarBackupClick(Sender: TObject);
begin
  bbRestaurarBackup.Enabled := false;
  Self.CriaDiretorioBackup;
  Self.VerificaSeExisteBancoRestaurado;
  if (Self.RestaurarBackup(Self.GetNomeArquivoUltimoBackup, Self.GetNomeArquivoParaRestaurarBackup)) then begin
    Self.ConfigurarArquivoIniComNovoBanco(Self.GetNomeArquivoParaRestaurarBackup);
    ShowMessage('OK: Configure o caminho do banco dos outros computadores como: '+idipwatch1.localip+':'+Self.GetNomeArquivoParaRestaurarBackup);
  end;

  bbRestaurarBackup.Enabled := true;
end;

function TFormBackup.GetDataParaNomeArquivo: string;
var dia, mes, ano, hora, minuto, segundo, msegundo: Word;
begin
  DecodeDateTime(now, ano, mes, dia, hora, minuto, segundo, msegundo);
  result := FormatWordToString(ano)+'_'+FormatWordToString(mes)+'_'+FormatWordToString(dia)+'_'+FormatWordToString(hora)+'_'+FormatWordToString(minuto)+'_'+FormatWordToString(segundo);
end;

function TFormBackup.GetAppFolder: String;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

procedure TFormBackup.VerificaSeExisteBancoRestaurado;
begin
  if(not(FileExists(Self.GetNomeArquivoParaRestaurarBackup)))then begin
    exit;
  end;
  if(messagedlg('!!!!!IMPORTANTE!!!!!'#13#10#13#10' Já existe um arquivo de banco de dados neste computador. Deseja APAGAR este arquivo e realizar uma NOVA restauração?',mtCustom, [mbYes,mbNo], 0)=mrYes)then begin
    DeleteFile(Self.GetNomeArquivoParaRestaurarBackup);
  end;
end;

procedure TFormBackup.ConfigurarArquivoIniComNovoBanco(caminhoBanco: string);
var
  ArquivoINI : TIniFile;
begin
  Try
    ArquivoINI := TIniFile.Create('.\SISTEMA.INI');
    ArquivoINI.Writestring('BANCO', 'caminho', '127.0.0.1:'+caminhoBanco);
  Finally
    ArquivoINI.Free;
  end;
end;

function TFormBackup.GetNomeArquivoGBak: String;
var gbak : String;
begin
  gbak := GetAppFolder+'gbak.exe';
  if not(FileExists(gbak)) then begin
    ShowMessage('ERRO: Arquivo gbak não encontrado: '+gbak);
  end;
  Result := gbak;
end;

procedure TFormBackup.FormDblClick(Sender: TObject);
begin
  Self.Width := 717;
  MemLog.Visible:=true;
end;

procedure TFormBackup.AdicionaTextoLog(texto: String);
begin
  MemLog.Lines.Add(texto)
end;

procedure TFormBackup.Pastabackup1Click(Sender: TObject);
var appFolder:String;
begin
  appFolder := Self.GetAppFolder;
  ShellExecute(Application.HANDLE, 'open', PChar(appFolder+'Backup\Banco'),nil,nil,SW_SHOWNORMAL);
end;

end.
