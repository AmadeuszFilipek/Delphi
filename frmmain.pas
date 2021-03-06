unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, Buttons, cManager, LCLType, Menus;

type

  { TFormMain }

  TFormMain = class(TForm)
    ArrowDown: TShape;
    ClearAll: TAction;
    btnClear: TButton;
    DrawFraction: TAction;
    btnDrawFractions: TButton;
    MainMenu1: TMainMenu;
    pnlActivePlayer: TPanel;
    Shape1: TShape;
    ArrowUp: TShape;
    Shape2: TShape;
    ShiftOrder: TAction;
    Stop: TAction;
    Start: TAction;
    btnStart: TButton;
    btnStop: TButton;
    Image1: TImage;
    NextTurn: TAction;
    TimeLabelEdit: TAction;
    edtTime: TEdit;
    Label2: TLabel;
    NameLabelEdit: TAction;
    btnNext: TButton;
    edtName: TEdit;
    Label1: TLabel;
    SetTime: TAction;
    AddPerson: TAction;
    IncrementTime: TAction;
    btnAddPerson: TButton;
    ActionList: TActionList;
    Reverse: TToggleBox;
    FormRefreshTimer: TTimer;
    procedure ClearAllExecute(Sender: TObject);
    procedure DrawFractionExecute(Sender: TObject);
    procedure btnStartUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormRefreshTimerTimer(Sender: TObject);
    procedure ShiftOrderExecute(Sender: TObject);
    procedure StopExecute(Sender: TObject);
    procedure StartExecute(Sender: TObject);
    procedure AddPersonExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NameLabelEditExecute(Sender: TObject);
    procedure NextTurnExecute(Sender: TObject);
    procedure TimeLabelEditExecute(Sender: TObject);
  private
    FPlayerName : string;
    FManager : TManager;
  public
    { public declarations }
  end;

var
  FormMain: TFormMain;

implementation
{$R *.lfm}

{ TFormMain }

procedure TFormMain.NameLabelEditExecute(Sender: TObject);
begin
     FPlayerName := edtName.Text;
end;

procedure TFormMain.NextTurnExecute(Sender: TObject);
begin
 FManager.NextTurn;
end;


procedure TFormMain.TimeLabelEditExecute(Sender: TObject);
begin
     try
       StrToInt(edtTime.Text);
     Except on E : Exception do
            ShowMessage('Heh ! szanujmy się...');
     end;
end;

procedure TFormMain.AddPersonExecute(Sender: TObject);
begin
  FManager.AddPerson(FPlayerName, TComponent(Self));
end;

procedure TFormMain.StartExecute(Sender: TObject);
begin
 FManager.Start();
 btnNext.SetFocus;
end;

procedure TFormMain.StopExecute(Sender: TObject);
begin
  FManager.Stop;
  btnStart.SetFocus;
end;

procedure TFormMain.btnStartUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
 if UTF8Key = ' ' then
 NextTurnExecute(Sender);
end;

procedure TFormMain.FormRefreshTimerTimer(Sender: TObject);
begin
  FManager.UpdateTime;
  pnlActivePlayer.Caption := 'Aktywny gracz : ' + Fmanager.GetActivePlayerName;
end;

procedure TFormMain.DrawFractionExecute(Sender: TObject);
begin
 Fmanager.DrawPlayers;
 FManager.DrawFractions;
 btnStart.SetFocus;
end;

procedure TFormMain.ClearAllExecute(Sender: TObject);
begin
     if not (FManager = nil) then begin
         FreeAndNil(FManager);
     end;
     FManager := TManager.Create(Application, StrToInt(edtTime.Text));
end;

procedure TFormMain.ShiftOrderExecute(Sender: TObject);
begin

  if FManager.Counter = 0 then exit;
  FManager.ShiftOrder;
  if ArrowUp.visible = True then begin
      ArrowUp.visible := False;
      ArrowDown.visible := True;
  end else begin
    ArrowUp.visible := True;
    ArrowDown.visible := False;
  end;
  btnStart.setFocus;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 FManager := TManager.create(Application, 25);
end;

end.

