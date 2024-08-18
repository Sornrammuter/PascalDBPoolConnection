unit uMain;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs,  StdCtrls, ExtCtrls,
  Uni, Data.DB, DBAccess, UniProvider, SQLServerUniProvider,
  DBPoolConnection,
  DBPoolConnection.Interfaces,
  DBPoolConnection.Types, MemDS;

type

  { TFrmMain }

  TFrmMain = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    UniQuery: TUniQuery;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TThreadTest = class(TThread)
  private
    FStatus: string;
    procedure Logar;
  public
    procedure Execute; override;
  end;

  function NewDatabase(ATenantDatabase: string): TObject;

var
  FrmMain: TFrmMain;
  FPool: IDBPoolConnection;


implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TFrmMain.Button1Click(Sender: TObject);
var
  i: Integer;
  t: TThreadTest;
begin
  for i := 1 to 200 do
  begin
    t := TThreadTest.Create(True);
    t.FreeOnTerminate := True;
    t.Start;
  end;
end;

procedure TFrmMain.Button2Click(Sender: TObject);
begin
  ShowMessage(FPool.GetStatus);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FPool := TDBPoolConnection.GetInstance
    .SetMaxPool(100)
    .SetOnCreateDatabaseComponent(NewDatabase);
end;

function NewDatabase(ATenantDatabase: string): TObject;
var
  Conn: TUniConnection;
begin
  Conn := TUniConnection.Create(nil);
  Conn.ConnectString :=
  'Provider Name=SQL Server;Data Source=.;Initial Catalog=iLabPlus_RNTEST;User ID=sa;Password=cavaria;Login Prompt=False';
  //..config your connection and open connection, check your TenantDatabse in Ini File for example
  Conn.Open;
  Sleep(100); //Uncomment this line to test with delay
  Result := Conn;
end;


{ TThreadTest }

procedure TThreadTest.Execute;
var
  vDBConnection: IDBConnection;
begin
  vDBConnection := FPool.GetDBConnection;
  if vDBConnection <> nil then
  begin
    FStatus := 'OK GetConnection';
    //Using your connection
    FrmMain.UniQuery.Connection := vDBConnection.DatabaseComponent as TUniConnection;
    FrmMain.UniQuery.SQL.Text := 'select * from PAT';
    FrmMain.UniQuery.Open;
  end
  else
    FStatus := 'FAIL GetConnection';
  Synchronize(Logar);
end;

procedure TThreadTest.Logar;
begin
  FrmMain.Memo1.Lines.Add(FStatus);
end;

end.
