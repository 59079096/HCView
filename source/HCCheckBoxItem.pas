{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{        �ĵ�CheckBoxItem(��ѡ��)����ʵ�ֵ�Ԫ           }
{                                                       }
{*******************************************************}

unit HCCheckBoxItem;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, HCItem, HCRectItem, HCStyle,
  HCCustomData, HCCommon;

type
  THCCheckBoxItem = class(THCTextRectItem)
  private
    FText: string;
    FChecked, FMouseIn: Boolean;
    function GetBoxRect: TRect;
  protected
    procedure SetChecked(const Value: Boolean);
    //
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string; const AChecked: Boolean);
    property Checked: Boolean read FChecked write SetChecked;
    property Text: string read FText write FText;
  end;

implementation

uses
  Math;

const
  CheckBoxSize = 14;
  BoxSpliter = 2;

{ THCCheckBoxItem }

function THCCheckBoxItem.GetBoxRect: TRect;
begin
  Result := Classes.Bounds(BoxSpliter, (Height - CheckBoxSize) div 2, CheckBoxSize, CheckBoxSize)
end;

constructor THCCheckBoxItem.Create(const AOwnerData: THCCustomData; const AText: string;
  const AChecked: Boolean);
begin
  inherited Create(AOwnerData);
  FMouseIn := False;
  Self.StyleNo := THCStyle.RsControl;
  FChecked := AChecked;
  FText := AText;
end;

procedure THCCheckBoxItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vBoxRect: TRect;
begin
  inherited;
  vBoxRect := GetBoxRect;
  OffsetRect(vBoxRect, ADrawRect.Left, ADrawRect.Top);

  if Self.IsSelectComplate then
  begin
    ACanvas.Brush.Color := AStyle.SelColor;
    ACanvas.FillRect(ADrawRect);
  end;
  AStyle.TextStyles[TextStyleNo].ApplyStyle(ACanvas);
  ACanvas.TextOut(ADrawRect.Left + BoxSpliter + CheckBoxSize + BoxSpliter,
    ADrawRect.Top + (Height - ACanvas.TextHeight('��')) div 2 + 1, FText);

  if FChecked then  // ��ѡ
  begin
    ACanvas.Font.Size := 10;
    //ACanvas.TextOut(vBoxRect.Left, vBoxRect.Top, '��');
    DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_MENU, DFCS_CHECKED or DFCS_MENUCHECK)
    //DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_BUTTON, DFCS_CHECKED or DFCS_BUTTONCHECK);
  end;
  //else
  //  DrawFrameControl(ACanvas.Handle, vBoxRect, DFC_BUTTON, DFCS_HOT or DFCS_BUTTONCHECK);

  if FMouseIn then  // ���������
  begin
    ACanvas.Pen.Color := clBlue;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
    InflateRect(vBoxRect, 1, 1);
    ACanvas.Pen.Color := clBtnFace;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end
  else  // ��겻������
  begin
    ACanvas.Pen.Color := clBlack;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end;
end;

procedure THCCheckBoxItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
var
  vSize: TSize;
begin
  ARichData.Style.TextStyles[TextStyleNo].ApplyStyle(ARichData.Style.DefCanvas);
  vSize := ARichData.Style.DefCanvas.TextExtent(FText);
  Width := BoxSpliter + CheckBoxSize + BoxSpliter + vSize.cx;  // ���
  Height := Max(vSize.cy, CheckBoxSize) + ARichData.Style.ParaStyles[ParaNo].LineSpace;
end;

procedure THCCheckBoxItem.MouseEnter;
begin
  inherited MouseEnter;
  FMouseIn := True;
end;

procedure THCCheckBoxItem.MouseLeave;
begin
  inherited MouseLeave;
  FMouseIn := False;
end;

procedure THCCheckBoxItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  //if PtInRect(GetBoxRect, Point(X, Y)) then
  GCursor := crArrow;
end;

procedure THCCheckBoxItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if PtInRect(GetBoxRect, Point(X, Y)) then
    Checked := not FChecked;
end;

procedure THCCheckBoxItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FChecked, SizeOf(FChecked));
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    FText := StringOf(vBuffer);
  end;
end;

procedure THCCheckBoxItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;  // ���65536���ֽڣ��������65536����ʹ��д���ı�����дһ��������ʶ(��#9)������ʱ����ֱ���˱�ʶ
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FChecked, SizeOf(FChecked));
  vBuffer := BytesOf(FText);
  if System.Length(vBuffer) > MAXWORD then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure THCCheckBoxItem.SetChecked(const Value: Boolean);
begin
  if FChecked <> Value then
  begin
    FChecked := Value;
  end;
end;

end.
