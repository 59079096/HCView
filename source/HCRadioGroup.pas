{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-9-15             }
{                                                       }
{             �ĵ�RadioGroup����ʵ�ֵ�Ԫ                }
{                                                       }
{*******************************************************}

unit HCRadioGroup;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Generics.Collections, HCItem,
  HCRectItem, HCStyle, HCCustomData, HCCommon;

type
  THCRadioButton = class(TObject)
    Checked: Boolean;
    Text: string;
    Position: TPoint;
  end;

  THCRadioGroup = class(THCControlItem)
  private
    FMultSelect, FMouseIn: Boolean;
    FItems: TObjectList<THCRadioButton>;
    function GetItemAt(const X, Y: Integer): Integer;
  protected
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); override;
    function GetOffsetAt(const X: Integer): Integer; override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create(const AOwnerData: THCCustomData);
    destructor Destroy; override;

    procedure AddItem(const AText: string; const AChecked: Boolean = False);

    property MultSelect: Boolean read FMultSelect write FMultSelect;
    property Items: TObjectList<THCRadioButton> read FItems;
  end;

implementation

const
  RadioButtonWidth = 16;

{ THCRadioGroup }

procedure THCRadioGroup.AddItem(const AText: string; const AChecked: Boolean = False);
var
  vRadioButton: THCRadioButton;
begin
  vRadioButton := THCRadioButton.Create;
  vRadioButton.Checked := AChecked;
  vRadioButton.Text := AText;
  FItems.Add(vRadioButton);
end;

constructor THCRadioGroup.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  Self.StyleNo := THCStyle.RadioGroup;
  Width := 100;
  FItems := TObjectList<THCRadioButton>.Create;
end;

destructor THCRadioGroup.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

procedure THCRadioGroup.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
var
  i, vLeft, vTop: Integer;
  vPoint: TPoint;
begin
  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, ACanvas, APaintInfo);

  if FMouseIn then
  begin
    ACanvas.Brush.Color := clBtnFace;
    ACanvas.FillRect(ADrawRect);
  end;

  AStyle.TextStyles[TextStyleNo].ApplyStyle(ACanvas, APaintInfo.ScaleY / APaintInfo.Zoom);

  for i := 0 to FItems.Count - 1 do
  begin
    vPoint.X := FItems[i].Position.X;
    vPoint.Y := FItems[i].Position.Y;
    vPoint.Offset(ADrawRect.Left, ADrawRect.Top);

    if FItems[i].Checked then
    begin
      DrawFrameControl(ACanvas.Handle, Bounds(vPoint.X, vPoint.Y, RadioButtonWidth, RadioButtonWidth),
        DFC_BUTTON, DFCS_CHECKED or DFCS_BUTTONRADIO)
    end
    else
    begin
      DrawFrameControl(ACanvas.Handle, Bounds(vPoint.X, vPoint.Y, RadioButtonWidth, RadioButtonWidth),
        DFC_BUTTON, DFCS_BUTTONRADIO)
    end;

    ACanvas.TextOut(vPoint.X + RadioButtonWidth, vPoint.Y, FItems[i].Text);
  end;
end;

procedure THCRadioGroup.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
var
  vSize: TSize;
  i, vLeft, vTop: Integer;
begin
  Height := FMinHeight;

  ARichData.Style.TextStyles[TextStyleNo].ApplyStyle(ARichData.Style.DefCanvas);

  vLeft := FMargin;
  vTop := FMargin;
  for i := 0 to FItems.Count - 1 do
  begin
    if FItems[i].Text <> '' then
      vSize := ARichData.Style.DefCanvas.TextExtent(FItems[i].Text)
    else
      vSize := ARichData.Style.DefCanvas.TextExtent('I');

    if vLeft + vSize.cx + RadioButtonWidth > Width then
    begin
      vLeft := FMargin;
      vTop := vTop + vSize.cy + FMargin;
    end;

    FItems[i].Position.X := vLeft;
    FItems[i].Position.Y := vTop;

    vLeft := vLeft + RadioButtonWidth + vSize.cx;
  end;

  Height := vTop + vSize.cy + FMargin;

  if Width < FMinWidth then
    Width := FMinWidth;
  if Height < FMinHeight then
    Height := FMinHeight;
end;

procedure THCRadioGroup.GetCaretInfo(var ACaretInfo: TCaretInfo);
begin
  if Self.Active then
    ACaretInfo.Visible := False;
end;

function THCRadioGroup.GetItemAt(const X, Y: Integer): Integer;
var
  i: Integer;
  vSize: TSize;
begin
  Result := -1;
  Self.OwnerData.Style.TextStyles[TextStyleNo].ApplyStyle(Self.OwnerData.Style.DefCanvas);
  for i := 0 to FItems.Count - 1 do
  begin
    vSize := Self.OwnerData.Style.DefCanvas.TextExtent(FItems[i].Text);
    if PtInRect(Bounds(FItems[i].Position.X, FItems[i].Position.Y,
      RadioButtonWidth + vSize.cx, vSize.cy), Point(X, Y))
    then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THCRadioGroup.GetOffsetAt(const X: Integer): Integer;
begin
  if X <= FMargin then
    Result := OffsetBefor
  else
  if X >= Width - FMargin then
    Result := OffsetAfter
  else
    Result := OffsetInner;
end;

procedure THCRadioGroup.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  i, vSize: Word;
  vBuffer: TBytes;
  vS, vText: string;
  vP, vPStart: PChar;
  vBool: Boolean;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  // ��Items
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.ReadBuffer(vBuffer[0], vSize);
    vS := StringOf(vBuffer);

    vP := PChar(vS);

    while vP^ <> #0 do
    begin
      vPStart := vP;
      while not (vP^ in [#0, #10, #13]) do
        Inc(vP);
      SetString(vText, vPStart, vP - vPStart);

      AddItem(vText);

      if vP^ = #13 then
        Inc(vP);
      if vP^ = #10 then
        Inc(vP);
    end;

    for i := 0 to FItems.Count - 1 do
    begin
      AStream.ReadBuffer(vBool, SizeOf(vBool));
      fitems[i].Checked := vBool;
    end;
  end;
end;

procedure THCRadioGroup.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  i, vIndex: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    vIndex := GetItemAt(X, Y);
    if vIndex >= 0 then
    begin
      FItems[vIndex].Checked := not FItems[vIndex].Checked;
      if not FMultSelect then
      begin
        for i := 0 to FItems.Count - 1 do
        begin
          if i <> vIndex then
            FItems[i].Checked := False;
        end;
      end;
    end;
  end;
end;

procedure THCRadioGroup.MouseEnter;
begin
  inherited MouseEnter;
  FMouseIn := True;
end;

procedure THCRadioGroup.MouseLeave;
begin
  inherited MouseLeave;
  FMouseIn := False;
end;

procedure THCRadioGroup.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  GCursor := crDefault;
end;

procedure THCRadioGroup.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  i, vSize: Word;
  vS: string;
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  // ��Items
  vS := '';
  for i := 0 to FItems.Count - 1 do
    vS := vS + FItems[i].Text + #13#10;

  vBuffer := BytesOf(vS);
  if System.Length(vBuffer) > MAXWORD then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);

  for i := 0 to FItems.Count - 1 do
    AStream.WriteBuffer(FItems[i].Checked, SizeOf(Boolean));
end;

end.
