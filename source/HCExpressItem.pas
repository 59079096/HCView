{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{          �ĵ�ExpressItem(��ʽ)����ʵ�ֵ�Ԫ            }
{                                                       }
{*******************************************************}

unit HCExpressItem;

interface

uses
  Windows, Classes, Controls, Graphics, HCStyle, HCItem, HCRectItem, HCCommon;

type
  TExpressArea = (ceaNone, ceaLeft, ceaTop, ceaRight, ceaBottom);

  // ��ʽ
  TExperssItem = class(THCCustomRectItem)
  private
    FStyle: THCStyle;
    FSLeft, FSTop, FSRight, FSBottom: string;
    FRLeft, FRTop, FRRight, FRBottom: TRect;
    FPadding: Byte;
    FActiveArea: TExpressArea;
    FCaretOffset: ShortInt;
    function GetExpressArea(const X, Y: Integer): TExpressArea;
  protected
    procedure FormatToDrawItem(const AStyle: THCStyle); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create(const ASLeft, ASTop, ASRight, ASBottom: string);
  end;

implementation

uses
  SysUtils;

{ TExperssItem }

constructor TExperssItem.Create(const ASLeft, ASTop, ASRight, ASBottom: string);
begin
  inherited Create;
  Self.StyleNo := THCStyle.RsExpress;
  FPadding := 5;
  FActiveArea := TExpressArea.ceaNone;
  FCaretOffset := -1;

  FSLeft := ASLeft;
  FSTop := ASTop;
  FSRight := ASRight;
  FSBottom := ASBottom;
end;

procedure TExperssItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  AStyle.TextStyles[0].ApplyStyle(ACanvas);
  ACanvas.TextOut(ADrawRect.Left + FRLeft.Left, ADrawRect.Top + FRLeft.Top, FSLeft);
  ACanvas.TextOut(ADrawRect.Left + FRTop.Left, ADrawRect.Top + FRTop.Top, FSTop);
  ACanvas.TextOut(ADrawRect.Left + FRRight.Left, ADrawRect.Top + FRRight.Top, FSRight);
  ACanvas.TextOut(ADrawRect.Left + FRBottom.Left, ADrawRect.Top + FRBottom.Top, FSBottom);

  ACanvas.MoveTo(ADrawRect.Left + FRLeft.Right + FPadding, ADrawRect.Top + FRTop.Bottom + FPadding);
  ACanvas.LineTo(ADrawRect.Left + FRRight.Left - FPadding, ADrawRect.Top + FRTop.Bottom + FPadding);
end;

procedure TExperssItem.FormatToDrawItem(const AStyle: THCStyle);
var
  vH, vLeftW, vRightW, vTopW, vBottomW: Integer;
begin
  FStyle := AStyle;
  FStyle.TextStyles[0].ApplyStyle(FStyle.DefCanvas);
  vH := FStyle.DefCanvas.TextHeight('��');
  vLeftW := FStyle.DefCanvas.TextWidth(FSLeft);
  vTopW := FStyle.DefCanvas.TextWidth(FSTop);
  vRightW := FStyle.DefCanvas.TextWidth(FSRight);
  vBottomW := FStyle.DefCanvas.TextWidth(FSBottom);
  // ����ߴ�
  if vTopW > vBottomW then
    Width := vLeftW + vTopW + vRightW + 6 * FPadding
  else
    Width := vLeftW + vBottomW + vRightW + 6 * FPadding;
  Height := vH * 2 + 4 * FPadding;
  // ������ַ���λ��
  vH := FStyle.DefCanvas.TextHeight('��');
  //
  FRLeft := Bounds(FPadding, (Height - vH) div 2, vLeftW, vH);
  FRRight := Bounds(Width - FPadding - vRightW, (Height - vH) div 2, vRightW, vH);
  FRTop := Bounds(FRLeft.Right + FPadding + (FRRight.Left - FPadding - (FRLeft.Right + FPadding) - vTopW) div 2,
    FPadding, vTopW, vH);
  FRBottom := Bounds(FRLeft.Right + FPadding + (FRRight.Left - FPadding - (FRLeft.Right + FPadding) - vBottomW) div 2,
    Height - FPadding - vH, vBottomW, vH);
end;

procedure TExperssItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
begin
  if FActiveArea <> TExpressArea.ceaNone then
  begin
    FStyle.TextStyles[0].ApplyStyle(FStyle.DefCanvas);
    case FActiveArea of
      ceaLeft:
        begin
          ACaretInfo.Height := FRLeft.Bottom - FRLeft.Top;
          ACaretInfo.X := FRLeft.Left + FStyle.DefCanvas.TextWidth(Copy(FSLeft, 1, FCaretOffset));
          ACaretInfo.Y := FRLeft.Top;
        end;

      ceaTop:
        begin
          ACaretInfo.Height := FRTop.Bottom - FRTop.Top;
          ACaretInfo.X := FRTop.Left + FStyle.DefCanvas.TextWidth(Copy(FSTop, 1, FCaretOffset));
          ACaretInfo.Y := FRTop.Top;
        end;

      ceaRight:
        begin
          ACaretInfo.Height := FRRight.Bottom - FRRight.Top;
          ACaretInfo.X := FRRight.Left + FStyle.DefCanvas.TextWidth(Copy(FSRight, 1, FCaretOffset));
          ACaretInfo.Y := FRRight.Top;
        end;

      ceaBottom:
        begin
          ACaretInfo.Height := FRBottom.Bottom - FRBottom.Top;
          ACaretInfo.X := FRBottom.Left + FStyle.DefCanvas.TextWidth(Copy(FSBottom, 1, FCaretOffset));
          ACaretInfo.Y := FRBottom.Top;
        end;
    end;
  end;
end;

function TExperssItem.GetExpressArea(const X, Y: Integer): TExpressArea;
var
  vPt: TPoint;
begin
  Result := TExpressArea.ceaNone;
  vPt := Point(X, Y);
  if PtInRect(FRLeft, vPt) then
    Result := TExpressArea.ceaLeft
  else
  if PtInRect(FRTop, vPt) then
    Result := TExpressArea.ceaTop
  else
  if PtInRect(FRRight, vPt) then
    Result := TExpressArea.ceaRight
  else
  if PtInRect(FRBottom, vPt) then
    Result := TExpressArea.ceaBottom;
end;

procedure TExperssItem.KeyDown(var Key: Word; Shift: TShiftState);

  procedure BackspaceKeyDown;

    procedure BackDeleteChar(var S: string);
    begin
      if FCaretOffset > 0 then
      begin
        System.Delete(S, FCaretOffset, 1);
        Dec(FCaretOffset);
      end;
    end;

  begin
    case FActiveArea of
      ceaLeft: BackDeleteChar(FSLeft);
      ceaTop: BackDeleteChar(FSTop);
      ceaRight: BackDeleteChar(FSRight);
      ceaBottom: BackDeleteChar(FSBottom);
    end;
  end;

  procedure LeftKeyDown;
  begin
    if FCaretOffset > 0 then
      Dec(FCaretOffset);
  end;

  procedure RightKeyDown;
  var
    vS: string;
  begin
    case FActiveArea of
      ceaLeft: vS := FSLeft;
      ceaTop: vS := FSTop;
      ceaRight: vS := FSRight;
      ceaBottom: vS := FSBottom;
    end;
    if FCaretOffset < System.Length(vS) then
      Inc(FCaretOffset);
  end;

  procedure DeleteKeyDown;

    procedure DeleteChar(var S: string);
    begin
      if FCaretOffset < System.Length(S) then
        System.Delete(S, FCaretOffset + 1, 1);
    end;

  begin
    case FActiveArea of
      ceaLeft: DeleteChar(FSLeft);
      ceaTop: DeleteChar(FSTop);
      ceaRight: DeleteChar(FSRight);
      ceaBottom: DeleteChar(FSBottom);
    end;
  end;

  procedure HomeKeyDown;
  begin
    FCaretOffset := 0;
  end;

  procedure EndKeyDown;
  var
    vS: string;
  begin
    case FActiveArea of
      ceaLeft: vS := FSLeft;
      ceaTop: vS := FSTop;
      ceaRight: vS := FSRight;
      ceaBottom: vS := FSBottom;
    end;
    FCaretOffset := System.Length(vS);
  end;

begin
  case Key of
    VK_BACK: BackspaceKeyDown;  // ��ɾ
    VK_LEFT: LeftKeyDown;       // �����
    VK_RIGHT: RightKeyDown;     // �ҷ����
    VK_DELETE: DeleteKeyDown;   // ɾ����
    VK_HOME: HomeKeyDown;       // Home��
    VK_END: EndKeyDown;         // End��
  end;
end;

procedure TExperssItem.KeyPress(var Key: Char);
begin
  if FActiveArea <> ceaNone then
  begin
    Inc(FCaretOffset);
    case FActiveArea of
      ceaLeft: System.Insert(Key, FSLeft, FCaretOffset);
      ceaTop: System.Insert(Key, FSTop, FCaretOffset);
      ceaRight: System.Insert(Key, FSRight, FCaretOffset);
      ceaBottom: System.Insert(Key, FSBottom, FCaretOffset);
    end;
  end
  else
    Key := #0;
end;

procedure TExperssItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);

  procedure LoadPartText(var S: string);
  var
    vSize: Word;
    vBuffer: TBytes;
  begin
    AStream.ReadBuffer(vSize, SizeOf(vSize));
    if vSize > 0 then
    begin
      SetLength(vBuffer, vSize);
      AStream.Read(vBuffer[0], vSize);
      S := StringOf(vBuffer);
    end
    else
      S := '';
  end;

begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  LoadPartText(FSLeft);
  LoadPartText(FSTop);
  LoadPartText(FSRight);
  LoadPartText(FSBottom);
end;

procedure TExperssItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vS: string;
  vX: Integer;
  vArea: TExpressArea;
  vOffset: Integer;
begin
  inherited;
  vArea := GetExpressArea(X, Y);
  if vArea <> FActiveArea then
  begin
    FActiveArea := vArea;
    FStyle.UpdateInfoReCaret;
  end;

  case FActiveArea of
    //ceaNone: ;
    ceaLeft:
      begin
        vS := FSLeft;
        vX := X - FRLeft.Left;
      end;

    ceaTop:
      begin
        vS := FSTop;
        vX := X - FRTop.Left;
      end;

    ceaRight:
      begin
        vS := FSRight;
        vX := X - FRRight.Left;
      end;

    ceaBottom:
      begin
        vS := FSBottom;
        vX := X - FRBottom.Left;
      end;
  end;
  if FActiveArea <> TExpressArea.ceaNone then
  begin
    FStyle.TextStyles[0].ApplyStyle(FStyle.DefCanvas);
    vOffset := GetCharOffsetByX(FStyle.DefCanvas, vS, vX)
  end
  else
    vOffset := -1;
  if vOffset <> FCaretOffset then
  begin
    FCaretOffset := vOffset;
    FStyle.UpdateInfoReCaret;
  end;
end;

procedure TExperssItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);

  procedure SavePartText(const S: string);
  var
    vBuffer: TBytes;
    vSize: Word;
  begin
    vBuffer := BytesOf(S);
    if System.Length(vBuffer) > MAXWORD then
      raise Exception.Create(CFE_EXCEPTION + 'TextItem�����ݳ�������ַ����ݣ�');
    vSize := System.Length(vBuffer);
    AStream.WriteBuffer(vSize, SizeOf(vSize));
    if vSize > 0 then
      AStream.WriteBuffer(vBuffer[0], vSize);
  end;

begin
  inherited SaveToStream(AStream, AStart, AEnd);
  SavePartText(FSLeft);
  SavePartText(FSTop);
  SavePartText(FSRight);
  SavePartText(FSBottom);
end;

end.
