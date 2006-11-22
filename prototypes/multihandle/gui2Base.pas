{
  Proof of concept one handle per widget GUI.
  Graeme Geldenhuys
}

unit gui2Base;

{$mode objfpc}{$H+}

{$Define DEBUG}

interface

uses
  Classes
  ,fpgfx
  ,GFXBase
  ;

  
type

  { TWidget }

  TWidget = class(TFWindow)
  private
    FOnClick: TNotifyEvent;
    FOnPainting: TNotifyEvent;
    procedure   EvOnPaint(Sender: TObject; const Rect: TRect); virtual;
    procedure   EvOnMousePress(Sender: TObject; AButton: TMouseButton; AShift: TShiftState; const AMousePos: TPoint);
  protected
    procedure   Paint; virtual;
    property    OnPainting: TNotifyEvent read FOnPainting write FOnPainting;
    property    OnClick: TNotifyEvent read FOnClick write FOnClick;
  public
    constructor Create(AParent: TFCustomWindow);
  end;
  
  { TForm }

  TForm = class(TFWindow)
  protected
    procedure   Paint(Sender: TObject; const Rect: TRect);
  public
    constructor Create; virtual;
  end;
  
  { TButton }

  TButton = class(TWidget)
  private
    FCaption: string;
    procedure   SetCaption(const AValue: string);
  protected
    procedure   Paint; override;
  public
    constructor Create(AParent: TFCustomWindow; APosition: TPoint);
    property    Caption: string read FCaption write SetCaption;
  published
    property    OnClick;
  end;


implementation

{ TWidget }

procedure TWidget.EvOnPaint(Sender: TObject; const Rect: TRect);
begin
  {$IFDEF DEBUG} Writeln(ClassName + '.Paint'); {$ENDIF}
  if Assigned(OnPainting) then
    OnPainting(self);
  Paint;
end;

procedure TWidget.EvOnMousePress(Sender: TObject; AButton: TMouseButton;
  AShift: TShiftState; const AMousePos: TPoint);
begin
  if AButton = mbLeft then
  begin
    if Assigned(OnClick) then
      OnClick(self);
  end;
end;

procedure TWidget.Paint;
var
  r: TRect;
begin
  Canvas.SetColor(colLtGray);
  r.Left    := 0;
  r.Top     := 0;
  r.Right   := Width;
  r.Bottom  := Height;
  Canvas.FillRect(r);
end;

constructor TWidget.Create(AParent: TFCustomWindow);
begin
  inherited Create(AParent, []);
  OnPaint := @EvOnPaint;
  OnMouseReleased := @EvOnMousePress;
  Show;
end;

{ TForm }

procedure TForm.Paint(Sender: TObject; const Rect: TRect);
var
  r: TRect;
begin
  {$IFDEF DEBUG} Writeln(ClassName + '.Paint'); {$ENDIF}
  Canvas.SetColor(colWhite);
  r.Left    := 0;
  r.Top     := 0;
  r.Right   := Width;
  r.Bottom  := Height;
  Canvas.FillRect(r);
end;

constructor TForm.Create;
begin
  inherited Create(nil, [woWindow]);
  OnPaint := @Paint;
end;

{ TButton }

procedure TButton.SetCaption(const AValue: string);
begin
  if FCaption=AValue then exit;
  FCaption:=AValue;
  Paint;
end;

procedure TButton.Paint;
var
  Pt: TPoint;
begin
  inherited Paint;
  Canvas.SetColor(colBlack);
  Canvas.DrawRect(Rect(0, 0, Width, Height));

  Pt.x := (Width - Canvas.TextWidth(FCaption)) div 2;
  Pt.y := (Height - Canvas.FontCellHeight) div 2;
  Canvas.TextOut(Pt, FCaption);
end;

constructor TButton.Create(AParent: TFCustomWindow; APosition: TPoint);
begin
  inherited Create(AParent);
  SetPosition(APosition);
  SetClientSize(Size(75, 25));
  SetMinMaxClientSize(Size(75, 25), Size(75, 25));
end;

end.

