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

const
  PointSize = 5;

type
  THCFloatItem = class(THCResizeRectItem)  // �ɸ���Item
  private
    FLeft, FTop: Integer;
  protected
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
  public
    function PtInClient(const X, Y: Integer): Boolean; overload;
    function PtInClient(const APoint: TPoint): Boolean; overload; virtual;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
  end;

implementation

{ THCFloatItem }

procedure THCFloatItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
begin
  {inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom,
    ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);}

  if Self.Active then
    ACanvas.DrawFocusRect(ADrawRect);
end;

function THCFloatItem.PtInClient(const APoint: TPoint): Boolean;
begin
  Result := PtInRect(Bounds(0, 0, Width, Height), APoint);
end;

function THCFloatItem.PtInClient(const X, Y: Integer): Boolean;
begin
  Result := PtInClient(Point(X, Y));
end;

end.
