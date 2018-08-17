{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-8-16             }
{                                                       }
{            �ĵ�FloatItem(����)����ʵ�ֵ�Ԫ            }
{                                                       }
{*******************************************************}

unit HCFloatItem;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Messages, HCItem, HCRectItem,
  HCStyle;

type
  THCFloatItem = class(THCCustomRectItem)  // �ɸ���Item   THCResizeRectItem
  private
    FX, FY: Integer;
  protected
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
  public
    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
  end;

implementation

{ THCFloatItem }

procedure THCFloatItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
begin
  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom,
    ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);

  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Style := psSolid;
  ACanvas.DrawFocusRect(ADrawRect);
end;

end.
