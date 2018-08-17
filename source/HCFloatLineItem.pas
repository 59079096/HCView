{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-8-17             }
{                                                       }
{         �ĵ�FloatLineItem(ֱ��)����ʵ�ֵ�Ԫ           }
{                                                       }
{*******************************************************}

unit HCFloatLineItem;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Messages, HCFloatItem, HCStyle,
  HCItem;

type
  THCFloatLineItem = class(THCFloatItem)  // �ɸ���LineItem
  protected
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
  end;

implementation

{ THCFloatLineItem }

procedure THCFloatLineItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
begin
  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom,
    ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);

  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Style := psSolid;

  ACanvas.MoveTo(ADrawRect.Left, ADrawRect.Top);
  ACanvas.LineTo(ADrawRect.Right, ADrawRect.Bottom);

  if Self.Active then
  begin
    ACanvas.Ellipse(ADrawRect.Left - 5, ADrawRect.Top - 5, ADrawRect.Left + 5, ADrawRect.Top + 5);
    ACanvas.Ellipse(ADrawRect.Right - 5, ADrawRect.Bottom - 5, ADrawRect.Right + 5, ADrawRect.Bottom + 5);
  end;
end;

end.
