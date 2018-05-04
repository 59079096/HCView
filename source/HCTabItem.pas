{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                 �ĵ�Tab����ʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCTabItem;

interface

uses
  Windows, Controls, Classes, Graphics, HCItem, HCRectItem, HCStyle, HCCommon;

type
  TTabItem = class(THCCustomRectItem)
  protected
    function JustifySplit: Boolean; override;
    function GetOffsetAt(const X: Integer): Integer; override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect; const ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom: Integer; const ACanvas: TCanvas;
      const APaintInfo: TPaintInfo); override;
  public
    constructor Create(const AWidth, AHeight: Integer); override;
  end;

implementation

{ TTabItem }

constructor TTabItem.Create(const AWidth, AHeight: Integer);
begin
  inherited Create;
  StyleNo := THCStyle.RsTab;
  Width := AWidth;
  Height := AHeight;
end;

procedure TTabItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;
  {if SelectComplate then
  begin
    ACanvas.Brush.Color := GStyle.SelColor;
    ACanvas.FillRect(ADrawRect);
  end;}
end;

function TTabItem.GetOffsetAt(const X: Integer): Integer;
begin
  if X < Width div 2 then
    Result := OffsetBefor
  else
    Result := OffsetAfter;
end;

function TTabItem.JustifySplit: Boolean;
begin
  Result := False;
end;

end.
