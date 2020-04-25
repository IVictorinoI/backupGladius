object FormBackup: TFormBackup
  Left = 354
  Top = 185
  Width = 709
  Height = 270
  Caption = 'Gladius Backup'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -27
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnDblClick = FormDblClick
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 37
  object bbCriarBackup: TBitBtn
    Left = 48
    Top = 8
    Width = 233
    Height = 81
    Caption = 'Criar backup'
    TabOrder = 0
    OnClick = bbCriarBackupClick
  end
  object bbRestaurarBackup: TBitBtn
    Left = 48
    Top = 112
    Width = 233
    Height = 81
    Caption = 'Rastaurar backup'
    TabOrder = 1
    OnClick = bbRestaurarBackupClick
  end
  object MemLog: TMemo
    Left = 304
    Top = 0
    Width = 389
    Height = 211
    Align = alRight
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Visible = False
  end
  object DB: TIBDatabase
    Connected = True
    DatabaseName = 
      '127.0.0.1:C:\ProjetosDelphi\votacao\banco\BANCO_GL_22-02-2015.FD' +
      'B'
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey')
    LoginPrompt = False
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = [tfQExecute, tfStmt, tfConnect, tfMisc]
    Left = 64
    Top = 48
  end
  object XPManifest1: TXPManifest
    Left = 96
    Top = 48
  end
  object IdIPWatch1: TIdIPWatch
    Active = False
    HistoryFilename = 'iphist.dat'
    Left = 128
    Top = 48
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 16
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      object Pastabackup1: TMenuItem
        Caption = 'Pasta backup'
        OnClick = Pastabackup1Click
      end
    end
  end
end
