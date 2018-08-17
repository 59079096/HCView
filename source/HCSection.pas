{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-8-17             }
{                                                       }
{            �ĵ�֧�ָ���Item�ڹ���ʵ�ֵ�Ԫ             }
{                                                       }
{*******************************************************}

unit HCSection;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Generics.Collections, HCCustomSection,
  HCStyle, HCFloatItem, HCCommon;

type
  THCSection = class(THCCustomSection)  // ֧�ָ���Item��Section
  private
    FFloatItems: TObjectList<THCFloatItem>;  // THCItems֧��Addʱ������ʱ����
    FFloatItemIndex: Integer;

    function GetFloatItemAt(const X, Y: Integer): Integer;
  public
    constructor Create(const AStyle: THCStyle);
    destructor Destroy; override;

    procedure Clear; override;
    procedure GetPageCaretInfo(var ACaretInfo: TCaretInfo); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure PaintPage(const APageIndex, ALeft, ATop: Integer;
      const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo); override;

    /// <summary> ���븡��Item </summary>
    function InsertFloatItem(const AFloatItem: THCFloatItem): Boolean;
  end;

implementation

{ THCSection }

procedure THCSection.Clear;
begin
  FFloatItems.Clear;
  inherited Clear;
end;

constructor THCSection.Create(const AStyle: THCStyle);
begin
  inherited Create(AStyle);
  FFloatItems := TObjectList<THCFloatItem>.Create;
  FFloatItemIndex := -1;
end;

destructor THCSection.Destroy;
begin
  FFloatItems.Free;
  inherited Destroy;
end;

function THCSection.GetFloatItemAt(const X, Y: Integer): Integer;
var
  i: Integer;
  vFloatItem: THCFloatItem;
  vRect: TRect;
begin
  Result := -1;
  for i := 0 to FFloatItems.Count - 1 do
  begin
    vFloatItem := FFloatItems[i];
    vRect := Bounds(vFloatItem.X, vFloatItem.Y, vFloatItem.Width, vFloatItem.Height);
    if PtInRect(vRect, Point(X, Y)) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure THCSection.GetPageCaretInfo(var ACaretInfo: TCaretInfo);
begin
  if FFloatItemIndex < 0 then
    inherited GetPageCaretInfo(ACaretInfo)
  else
    ACaretInfo.Visible := False;
end;

function THCSection.InsertFloatItem(const AFloatItem: THCFloatItem): Boolean;
begin
  FFloatItems.Add(AFloatItem);
  Result := True;
  Style.UpdateInfoRePaint;
  DoDataChanged(Self);
end;

procedure THCSection.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vItemIndex: Integer;
begin
  vItemIndex := GetFloatItemAt(X, Y - PagePadding);
  if FFloatItemIndex <> vItemIndex then
  begin
    if FFloatItemIndex >= 0 then
      FFloatItems[FFloatItemIndex].Active := False;

    FFloatItemIndex := vItemIndex;

    if FFloatItemIndex >= 0 then
      FFloatItems[FFloatItemIndex].Active := True;

    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
  end;

  if vItemIndex < 0 then
    inherited MouseDown(Button, Shift, X, Y);
end;

procedure THCSection.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vItemIndex: Integer;
begin
  vItemIndex := GetFloatItemAt(X, Y - PagePadding);
  if vItemIndex < 0 then
    inherited MouseMove(Shift, X, Y)
  else
    GCursor := crDefault;
end;

procedure THCSection.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure THCSection.PaintPage(const APageIndex, ALeft, ATop: Integer;
  const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
var
  i, vPageDrawTop, vPageDrawBottom: Integer;
  vFloatItem: THCFloatItem;
  vRect: TRect;
begin
  inherited PaintPage(APageIndex, ALeft, ATop, ACanvas, APaintInfo);

  vPageDrawTop := ATop;  // ӳ�䵽��ǰҳ�����Ͻ�Ϊԭ�����ʼλ��(��Ϊ����)
  vPageDrawBottom := vPageDrawTop + Self.PageHeightPix;  // ҳ�����λ��(��Ϊ����)
  // ��ǰҳ��������ʾ����������߽�
  //vPageDataScreenTop := Max(vPageDrawTop + vHeaderAreaHeight, 0);
  //vPageDataScreenBottom := Min(vPageDrawBottom - FPageSize.PageMarginBottomPix, vScaleHeight);

  for i := 0 to FFloatItems.Count - 1 do
  begin
    vFloatItem := FFloatItems[i];

    vRect := Bounds(vFloatItem.X, vFloatItem.Y, vFloatItem.Width, vFloatItem.Height);
    vRect.Offset(ALeft, ATop);
    vFloatItem.PaintTo(nil, vRect, vPageDrawTop, vPageDrawBottom, 0, 0, ACanvas, APaintInfo);
    //ACanvas.MoveTo(vFloatItem.X, vFloatItem.Y);
    //ACanvas.LineTo(vFloatItem.X + vFloatItem.Width, vFloatItem.Y + vFloatItem.Height);
  end;
end;

end.
