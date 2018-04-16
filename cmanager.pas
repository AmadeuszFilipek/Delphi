unit cManager;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, ExtCtrls, Controls, StdCtrls, dateutils, LCLType, graphics, EpikTimer;

type

    { TManager }
    TManager = class
      private

      //OnClick - This event can also occur when:
      // The user presses Spacebar while a button or check box has focus.
      FActivePlayer : integer;
      FNextPlayer : integer; // 1 czyli normalnie, -1 w druga strone
      FCounter : integer; // ile jest osob, tylko to liczy od 1
      FTimeForPlayer : integer; // ile czasu ma gracz [min]
      FShape : TShape;
      FIsRunning : boolean; // czy ktorys zegarek jest aktywny

      FNames : array of string; // nick gracza

      FPlayerTimer : TEpikTimer; // nalicza dokladny czas
      FPlayerTime : array of TDateTime;

      FNameLabels : array of TButton;
      FTimeLabels : array of TButton;
      FFractionLabels : array of TLabel;

      public

      property IsRunning : boolean read FIsRunning; // bez edycji, nie ma wpierdalania sie w strukture klasy
      property Counter : integer read FCounter;
      property TimeForPlayer : integer read FTimeForPlayer write FTimeForPlayer;
      property ActivePlayer : integer read FActivePlayer;
      property NextPlayer : integer read FNextPlayer;

      function GetActivePlayerName : string;
      procedure DrawPlayers;
      procedure ShiftOrder;
      procedure Start;
      procedure Stop;
      procedure NextTurn;
      procedure DrawFractions;
      procedure AddPerson(pName : string; AOwner : TComponent);
      procedure ReverseOrder;
      procedure UpdateTime;
      procedure OnLabelClick(Sender: TObject);

      constructor Create(AOwner : TComponent; pTimeForPlayer : integer);
      destructor Destroy; override;

    end;

implementation
uses frmMain;
{ TManager }

function TManager.GetActivePlayerName: string;
begin
  if FCounter = 0 then exit;
  result := FNameLabels[FActivePlayer].Caption;
end;

procedure TManager.DrawPlayers;
var
    Rnd, I, J : integer;
    Flag : Boolean;
    RandomArray : array of integer;
    NameTmp : array of string;
begin
  // przemieszanie ustawienia graczy
  if FCounter = 0 then exit;
  if IsRunning then exit;
  SetLength(RandomArray, FCounter);
  SetLength(NameTmp, FCounter);
  Randomize;
  Rnd := Random(1000000) mod FCounter;
  RandomArray[0] := Rnd;
  I := 1;
  while ( I < Fcounter) do begin
      Flag := False;
      Rnd := Random(1000000) mod FCounter;
      for J := 0 to I - 1 do begin
          if Rnd = RandomArray[J] then begin
            Flag := True;
            break;
          end;
      end;
      if Flag then continue;
      RandomArray[I] := Rnd;
      I := I + 1;
  end;
  for I := 0 to FCounter - 1 do begin
      NameTmp[I] := FNameLabels[RandomArray[I]].Caption;
  end;

  for I := 0 to FCounter - 1 do begin
      FNameLabels[I].Caption := NameTmp[I];
  end;
  // losowanie aktywnego gracza
  FActivePlayer := Random(1000000) mod FCounter;
end;

procedure TManager.ShiftOrder;
begin
  FNextPlayer := FNextPlayer * (- 1);
end;

procedure TManager.Start;
begin
  if FCounter = 0 then exit;
  if IsRunning then exit;
  FPlayerTimer.Clear;
  FPlayerTimer.Start;
  FIsRunning := True;
end;

procedure TManager.Stop;
begin
  if FCounter = 0 then exit;
  FPlayerTimer.Stop;
  UpdateTime;
  FPlayerTimer.clear;
  FIsRunning := False;
end;

procedure TManager.NextTurn;
var NewActive : integer;
begin
  if FCounter = 0 then exit;
  if FIsRunning = false then exit;
  FPlayerTimer.Stop; // zatrzymujemy akcje gracza ktory skonczyl ture
  UpdateTime;
  NewActive := ActivePlayer + NextPlayer;
  if NewActive >= FCounter then begin
    FActivePlayer := 0; // pierwszy
  end else if NewActive < 0 then begin
    FActivePlayer := FCounter - 1;  // ostatni
  end else begin
    FActivePlayer := NewActive; // po prostu kolejny
  end;
  // po tym bloku Active player to juz nowy gracz
  FPlayerTimer.clear;
  FPlayerTimer.Start; // startujemy zegarek kolejnego gracza

end;

procedure TManager.DrawFractions;
const
   FractionNames : array[0..8] of string = ('Mechanema', 'Erridani Empire',
   'Orion Hegemony', 'Hydran Progress', 'Plantan', 'Descendants of Draco',
                  'Enlighted of Lyra', 'The Exiled', 'Rho Indi Syndicate');
var
    Rnd, I, J : integer;
    Flag : Boolean;
    RandomArray : array of integer;
begin
  if FCounter = 0 then exit;
  if Fcounter > 9 then exit;
  if IsRunning then exit;
  SetLength(RandomArray, FCounter);
  Randomize;
  Rnd := Random(1000000) mod 9;
  RandomArray[0] := Rnd;
  I := 1;
  while ( I < Fcounter) do begin
      Flag := False;
      Rnd := Random(1000000) mod 9;
      for J := 0 to I - 1 do begin
          if Rnd = RandomArray[J] then begin
            Flag := True;
            break;
          end;
      end;
      if Flag then continue;
      RandomArray[I] := Rnd;
      I := I + 1;
  end;

  for I := FCounter - 1 downto 0 do begin
      case RandomArray[I] of
      0 : FFractionLabels[I].Caption := FractionNames[0];
      1 : FFractionLabels[I].Caption := FractionNames[1];
      2 : FFractionLabels[I].Caption := FractionNames[2];
      3 : FFractionLabels[I].Caption := FractionNames[3];
      4 : FFractionLabels[I].Caption := FractionNames[4];
      5 : FFractionLabels[I].Caption := FractionNames[5];
      6 : FFractionLabels[I].Caption := FractionNames[6];
      7 : FFractionLabels[I].Caption := FractionNames[7];
      8 : FFractionLabels[I].Caption := FractionNames[8];
      end;
      FFractionLabels[I].Visible := True;
  end;
end;

procedure TManager.AddPerson(pName: string; AOwner: TComponent);
var Margin : integer; WidthTmp, HeightTmp, TopTmp : integer;
begin
  WidthTmp := 200;
  HeightTmp := 50;
  Margin := 130;
  TopTmp := FCounter * (HeightTmp + Margin div 3) + Margin div 3;

  SetLength(FNames, FCounter + 1);
  Fnames[FCounter] := pName;

  SetLength(FPlayerTime, FCounter + 1);
  FPlayerTime[FCounter] := 0;

  SetLength(FNameLabels, FCounter + 1 );
  FNameLabels[FCounter] := TButton.create(AOwner);
  with FNameLabels[FCounter] do begin
    visible := false;
    Parent := TWinControl(AOwner);
    Caption := pName;
    OnClick := @OnLabelClick;
    Font.Size := 22;
    Width := WidthTmp;
    Height := HeightTmp;
    Left := Margin;
    Top := TopTmp;
    Tag := Fcounter;
    visible := true;
    enabled := true;
  end;

  SetLength(FTimeLabels, FCounter + 1);
  FTimeLabels[FCounter] := TButton.create(AOwner);
  with FTimeLabels[FCounter] do begin
    visible := false;
    Parent := TWinControl(AOwner);
    Caption := FPlayerTimer.ElapsedDHMS;
    OnClick := @OnLabelClick;
    Font.Size := 22;
    Width := WidthTmp;
    Height := HeightTmp;
    Left := Width + Margin;
    Top := TopTmp;
    Tag := Fcounter;
    visible := true;
    enabled := true;
  end;

  // nazwy rasy
  SetLength(FFractionLabels, FCounter + 1 );
  FFractionLabels[FCounter] := TLabel.create(AOwner);
  with FFractionLabels[Fcounter] do begin
    visible := false;
    Parent := TWinControl(AOwner);
    Caption := '';
    Font.Size := 20;
    Width := WidthTmp;
    Height := HeightTmp;
    Left := 2* WidthTmp + Margin + 30;
    Top := TopTmp;
  end;

  FShape.Top := Margin div 6;
  FShape.Left := Margin - 30;
  FShape.Height := FCounter * (HeightTmp + Margin div 3) + Margin;
  FShape.Width := 3* WidthTmp + Margin + 40;
  FShape.Visible := true;
  FCounter := FCounter + 1;

end;

procedure TManager.ReverseOrder;
begin
     FNextPlayer := -1;
end;

procedure TManager.UpdateTime;
begin
  if IsRunning then begin
             //  FPlayerTime[FActivePlayer] +
     FPlayerTime[FActivePlayer] := TDateTime(FPlayerTimer.Elapsed / 3600 / 24) + FPlayerTime[FActivePlayer];
     FPlayerTimer.clear;
     FplayerTimer.start;
     FTimeLabels[FActivePlayer].Caption := FormatDateTime('hh:mm:ss:zz', FPlayerTime[FActivePlayer]) ;
   //  FNameLabels[FActivePlayer].Color := clBlue; // to chyba nie zadziala
  end;
end;

constructor TManager.Create(AOwner : TComponent; pTimeForPlayer: integer);
begin
     inherited Create;
     FCounter := 0;
     FTimeForPlayer := pTimeForPlayer;

     FPlayerTimer := TEpikTimer.Create(AOwner);
     FPlayerTimer.WantDays := False;
     FPlayerTimer.Clear;
     FPlayerTimer.StringPrecision := 2;

     FShape := TShape.create(AOwner);
     FShape.Parent := FormMain;
     FShape.Visible := false;
     FShape.Shape := stRoundRect;
     FShape.brush.Color := BLACKNESS;
     FShape.brush.Style := bsDiagCross;

     FActivePlayer := 0;
     FNextPlayer := 1;
end;

destructor TManager.Destroy;
var I : integer;
begin

  for I := FCounter - 1 downto 0 do begin
      FreeAndNil(FNameLabels[I]);
      FreeAndNil(FTimeLabels[I]);
      FreeAndNil(FFractionLabels[I]);
  end;
      FreeAndNil(FPlayerTimer);
     FreeAndNil(FShape);
     inherited Destroy;
end;

procedure TManager.OnLabelClick(Sender: TObject);
begin
  // pauza dla aktywnego gracza
  Stop;
  FActivePlayer := TButton(Sender).Tag;
  // i start dla nowego kliknietego gracza
  Start;
end;


end.

