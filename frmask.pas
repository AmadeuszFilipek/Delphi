unit frmAsk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormAsk }

  TFormAsk = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormAsk: TFormAsk;

implementation

{$R *.lfm}

end.

