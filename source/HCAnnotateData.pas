{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-12-3             }
{                                                       }
{             �ĵ��ڸ������߼�����Ԫ                }
{                                                       }
{*******************************************************}

unit HCAnnotateData;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Generics.Collections, HCCustomData,
  HCCustomRichData, HCItem, HCStyle, HCParaStyle, HCTextStyle, HCTextItem, HCRectItem,
  HCCommon, HCUndoRichData, HCList;

type
  THCDataAnnotate = class(TSelectInfo)  // Data��ע��Ϣ
  private
    FID, FStartDrawItemNo, FEndDrawItemNo: Integer;
  public
    procedure Initialize; override;
    procedure CopyRange(const ASrc: TSelectInfo);
    property ID: Integer read FID write FID;
    property StartDrawItemNo: Integer read FStartDrawItemNo write FStartDrawItemNo;
    property EndDrawItemNo: Integer read FEndDrawItemNo write FEndDrawItemNo;
  end;

  THCDataAnnotates = class(TObjectList<THCDataAnnotate>)
  public
    function NewAnnotate: THCDataAnnotate;
  end;

  THCAnnotateMark = (amFirst, amNormal, amLast, amBoth);
  THCDrawItemAnnotate = class(TObject)
  public
    DrawRect: TRect;
    Mark: THCAnnotateMark;

    function First: Boolean;
    function Last: Boolean;
  end;

  THCDrawItemAnnotates = class(TObjectList<THCDrawItemAnnotate>)
  public
    procedure NewAnnotate(const ARect: TRect; AMark: THCAnnotateMark);
  end;

  TDataAnnotateDrawItemEvent = procedure(const AData: THCCustomData; const ADrawItemNo: Integer; const ADrawRect: TRect) of object;

  THCAnnotateData = class(THCUndoRichData)  // ֧����ע���ܵ�Data��
  private
    FAnnotates: THCDataAnnotates;
    FHotAnnotate, FActiveAnnotate: Integer;  // ��ǰ������ע����ǰ�������ע
    FDrawAnnotates: THCDrawItemAnnotates;
    FOnAnnotateDrawItem: TDataAnnotateDrawItemEvent;

    /// <summary> ָ����DrawItem�Ƿ���ĳ��ע�ķ�Χ�� </summary>
    /// <param name="ADrawItemNo"></param>
    /// <param name="ACanvas">Ӧ����DrawItem��ʽ��Canvas</param>
    /// <returns></returns>
    function DrawItemBelongAnnotate(const ADrawItemNo: Integer;
      const ACanvas: TCanvas; const ADrawRect: TRect): Boolean;
  protected
    procedure DoDrawItemPaintContent(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect, AClearRect: TRect; const ADrawText: string;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
  public
    constructor Create(const AStyle: THCStyle); override;
    destructor Destroy; override;

    procedure GetCaretInfo(const AItemNo, AOffset: Integer; var ACaretInfo: THCCaretInfo); override;
    procedure PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure InitializeField; override;

    function InsertAnnotate(const ATitle, AText: string): Boolean;

    /// <summary> ��ָ����λ�á�ָ������ʼ����DrawItem����ȡ����ʾ����ע </summary>
    /// <param name="AHorzOffset">������ʾƫ��</param>
    /// <param name="AVertOffset">��ֱ��ʾƫ��</param>
    /// <param name="AFirstDrawItemNo">��ʼDrawItem</param>
    /// <param name="ALastDrawItemNo">����DrawItem</param>
    /// <param name="AFmtTop">�жϵĸ�ʽ����ʼλ��</param>
    /// <param name="AFmtBottom">�жϵĸ�ʽ������λ��</param>
    procedure CheckAnnotate(const AHorzOffset, AVertOffset, AFirstDrawItemNo, ALastDrawItemNo,
      AFmtTop, AFmtBottom: Integer);

    property OnAnnotateDrawItem: TDataAnnotateDrawItemEvent read FOnAnnotateDrawItem write FOnAnnotateDrawItem;
  end;

implementation

{ THCAnnotateData }

procedure THCAnnotateData.CheckAnnotate(const AHorzOffset, AVertOffset,
  AFirstDrawItemNo, ALastDrawItemNo, AFmtTop, AFmtBottom: Integer);
var
  i, vFirstNo, vLastNo: Integer;
  vAnnotate: THCDataAnnotate;
  vDrawRect: TRect;
  vRectItem: THCCustomRectItem;
begin
  if (not Assigned(FOnAnnotateDrawItem)) or (AFirstDrawItemNo < 0) then Exit;

  vFirstNo := Self.DrawItems[AFirstDrawItemNo].ItemNo;
  vLastNo := Self.DrawItems[ALastDrawItemNo].ItemNo;

  for i := 0 to FAnnotates.Count - 1 do
  begin
    vAnnotate := FAnnotates[i];

    if vAnnotate.EndItemNo < vFirstNo then  // δ���뱾�β��ҷ�Χ
      Continue;

    if vAnnotate.StartItemNo > vLastNo then  // �������β��ҵķ�Χ
      Break;

    vAnnotate := FAnnotates[i];
    vAnnotate.StartDrawItemNo := Self.GetDrawItemNoByOffset(vAnnotate.StartItemNo, vAnnotate.StartItemOffset);
    vAnnotate.EndDrawItemNo := Self.GetDrawItemNoByOffset(vAnnotate.EndItemNo, vAnnotate.EndItemOffset);
    if vAnnotate.EndItemOffset = Self.DrawItems[vAnnotate.EndDrawItemNo].CharOffs then  // ����ڽ�������ǰ�棬����һ��
      vAnnotate.EndDrawItemNo := vAnnotate.EndDrawItemNo - 1;
  end;

  {for i := AFirstDrawItemNo to ALastDrawItemNo do
  begin
    vDrawRect := DrawItems[i].Rect;
    if vDrawRect.Top > AFmtBottom then
      Break;

    if GetDrawItemStyle(i) < THCStyle.Null then
    begin
      vRectItem := Items[DrawItems[i].ItemNo] as THCCustomRectItem;

      vLineSpace := GetLineSpace(i);
      InflateRect(vDrawRect, 0, -vLineSpace div 2);  // ��ȥ�м�ྻRect�������ݵ���ʾ����

      if vRectItem.JustifySplit then  // ��ɢռ�ռ�
      begin
        vAlignHorz := Style.ParaStyles[vRectItem.ParaNo].AlignHorz;
        if ((vAlignHorz = pahJustify) and (not IsLineLastDrawItem(i)))  // ���˶����Ҳ��Ƕ����
          or (vAlignHorz = pahScatter)  // ��ɢ����
        then
          vDrawRect.Inflate(-(vDrawRect.Width - vRectItem.Width) div 2, 0)
        else
          vDrawRect.Right := vDrawRect.Left + vRectItem.Width;
      end;

      case Style.ParaStyles[vRectItem.ParaNo].AlignVert of  // ��ֱ���뷽ʽ
        pavCenter: InflateRect(vDrawRect, 0, -(vDrawRect.Height - vRectItem.Height) div 2);
        pavTop: ;
      else
        vDrawRect.Top := vDrawRect.Bottom - vRectItem.Height;
      end;

      vRectItem.CheckAnnotate(vDrawRect.Left + AHorzOffset, vDrawRect.Top + AVertOffset,
        Min(vRectItem.Height, AFmtBottom - vDrawRect.Top));
    end
    else
    if DrawItems[i].Rect.Bottom > AFmtTop then  // DrawItem��ʽ��������Ҫ�жϵĸ�ʽ��������
    begin
      if DrawItemBelongAnnotate(i, vDrawRect) then
      begin
        vDrawRect.Offset(AHorzOffset, AVertOffset);
        FOnAnnotateDrawItem(Self, i, vDrawRect);
      end;
    end;
  end; }
end;

constructor THCAnnotateData.Create(const AStyle: THCStyle);
begin
  FAnnotates := THCDataAnnotates.Create;
  FDrawAnnotates := THCDrawItemAnnotates.Create;
  inherited Create(AStyle);
  FHotAnnotate := -1;
  FActiveAnnotate := -1;
end;

destructor THCAnnotateData.Destroy;
begin
  FAnnotates.Free;
  FDrawAnnotates.Free;
  inherited Destroy;
end;

procedure THCAnnotateData.DoDrawItemPaintContent(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect, AClearRect: TRect;
  const ADrawText: string; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
var
  i: Integer;
begin
  if DrawItemBelongAnnotate(ADrawItemNo, ACanvas, AClearRect) then
  begin
    if True then
      ACanvas.Brush.Color := AnnotateBKColor
    else
      ACanvas.Brush.Color := AnnotateBKActiveColor;

    for i := 0 to FDrawAnnotates.Count - 1 do
    begin
      ACanvas.FillRect(FDrawAnnotates[i].DrawRect);

      if FDrawAnnotates[i].First then
      begin
        ACanvas.Pen.Color := clRed;
        ACanvas.MoveTo(FDrawAnnotates[i].DrawRect.Left + 2, FDrawAnnotates[i].DrawRect.Top - 2);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Left, FDrawAnnotates[i].DrawRect.Top);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Left, FDrawAnnotates[i].DrawRect.Bottom);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Left + 2, FDrawAnnotates[i].DrawRect.Bottom + 2);
      end;

      if FDrawAnnotates[i].Last then
      begin
        ACanvas.Pen.Color := clRed;
        ACanvas.MoveTo(FDrawAnnotates[i].DrawRect.Right - 2, FDrawAnnotates[i].DrawRect.Top - 2);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Right, FDrawAnnotates[i].DrawRect.Top);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Right, FDrawAnnotates[i].DrawRect.Bottom);
        ACanvas.LineTo(FDrawAnnotates[i].DrawRect.Right - 2, FDrawAnnotates[i].DrawRect.Bottom + 2);

        if Assigned(FOnAnnotateDrawItem) then
          FOnAnnotateDrawItem(AData, ADrawItemNo, FDrawAnnotates[i].DrawRect);
      end;
    end;
  end;

  inherited DoDrawItemPaintContent(AData, ADrawItemNo, ADrawRect, AClearRect,
    ADrawText, ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom,
    ACanvas, APaintInfo);
end;

function THCAnnotateData.DrawItemBelongAnnotate(const ADrawItemNo: Integer;
  const ACanvas: TCanvas; const ADrawRect: TRect): Boolean;
var
  i, vItemNo: Integer;
  vAnnotate: THCDataAnnotate;
begin
  Result := False;
  if FAnnotates.Count = 0 then Exit;

  vItemNo := Self.DrawItems[ADrawItemNo].ItemNo;
  if vItemNo < FAnnotates.First.StartItemNo then Exit;
  if vItemNo > FAnnotates.Last.EndItemNo then Exit;

  FDrawAnnotates.Clear;
  for i := 0 to FAnnotates.Count - 1 do
  begin
    vAnnotate := FAnnotates[i];

    if vAnnotate.EndItemNo < vItemNo then  // δ���뱾�β��ҷ�Χ
      Continue;

    if vAnnotate.StartItemNo > vItemNo then  // �������β��ҵķ�Χ
      Break;

    if ADrawItemNo = vAnnotate.StartDrawItemNo then
    begin
      if ADrawItemNo = vAnnotate.EndDrawItemNo then  // ��ǰDrawItem������ע��ʼ������ע����
      begin
        FDrawAnnotates.NewAnnotate(
          Rect(ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vAnnotate.StartItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Top,
            ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vAnnotate.EndItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Bottom),
          amBoth);
      end
      else  // ������עͷ
      begin
        FDrawAnnotates.NewAnnotate(
          Rect(ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vAnnotate.StartItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Top, ADrawRect.Right, ADrawRect.Bottom),
          amFirst);
      end;

      Result := True;
    end
    else
    if ADrawItemNo = vAnnotate.EndDrawItemNo then  // ��ǰDrawItem����ע����
    begin
      FDrawAnnotates.NewAnnotate(
        Rect(ADrawRect.Left, ADrawRect.Top,
          ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vAnnotate.EndItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
          ADrawRect.Bottom),
        amLast);

      Result := True;
    end
    else
    if (ADrawItemNo > vAnnotate.StartDrawItemNo) and (ADrawItemNo < vAnnotate.EndDrawItemNo) then  // ��ǰDrawItem����ע��Χ��
    begin
      FDrawAnnotates.NewAnnotate(ADrawRect, amNormal);
      Result := True;
    end;
  end;
end;

procedure THCAnnotateData.GetCaretInfo(const AItemNo, AOffset: Integer;
  var ACaretInfo: THCCaretInfo);
begin
  inherited GetCaretInfo(AItemNo, AOffset, ACaretInfo);
  if FActiveAnnotate >= 0 then  // ԭ���м������ע
  begin
    FActiveAnnotate := -1;
    Style.UpdateInfoRePaint;
  end;

  //GetDomainFrom(SelectInfo.StartItemNo, SelectInfo.StartItemOffset,
  //  THCStyle.Annotate, FActiveAnnotate);  // ��ȡ��ǰ��괦��ע
  if FActiveAnnotate >= 0 then
    Style.UpdateInfoRePaint;
end;

procedure THCAnnotateData.InitializeField;
begin
  inherited InitializeField;
  FAnnotates.Clear;
  FHotAnnotate := -1;
  FActiveAnnotate := -1;
end;

function THCAnnotateData.InsertAnnotate(const ATitle, AText: string): Boolean;
var
  vAnnotate: THCDataAnnotate;
begin
  Result := False;
  if not CanEdit then Exit;
  if not Self.SelectExists then Exit;

  vAnnotate := FAnnotates.NewAnnotate;
  vAnnotate.CopyRange(SelectInfo);
end;

procedure THCAnnotateData.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FHotAnnotate := -1;

  inherited MouseMove(Shift, X, Y);

  if FHotAnnotate >= 0 then
    Style.UpdateInfoRePaint;
end;

procedure THCAnnotateData.PaintData(const ADataDrawLeft, ADataDrawTop,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo,
  ALastDItemNo: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  CheckAnnotate(ADataDrawLeft, ADataDrawTop - AVOffset, AFristDItemNo, ALastDItemNo,
    AVOffset, AVOffset + ADataDrawBottom - ADataDrawTop);
  inherited PaintData(ADataDrawLeft, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo, ACanvas, APaintInfo);
  FDrawAnnotates.Clear;
end;

{ THCDataAnnotate }

procedure THCDataAnnotate.CopyRange(const ASrc: TSelectInfo);
begin
  Self.StartItemNo := ASrc.StartItemNo;
  Self.StartItemOffset := ASrc.StartItemOffset;
  Self.EndItemNo := ASrc.EndItemNo;
  Self.EndItemOffset := ASrc.EndItemOffset;
end;

procedure THCDataAnnotate.Initialize;
begin
  inherited Initialize;
  FID := -1;
end;

{ THCDataAnnotates }

function THCDataAnnotates.NewAnnotate: THCDataAnnotate;
begin
  Result := THCDataAnnotate.Create;
  Result.ID := Self.Add(Result);
end;

{ THCDrawItemAnnotate }

function THCDrawItemAnnotate.First: Boolean;
begin
  Result := (Mark = amFirst) or (Mark = amBoth);
end;

function THCDrawItemAnnotate.Last: Boolean;
begin
  Result := (Mark = amLast) or (Mark = amBoth);
end;

{ THCDrawItemAnnotates }

procedure THCDrawItemAnnotates.NewAnnotate(const ARect: TRect; AMark: THCAnnotateMark);
var
  vDrawAnnotate: THCDrawItemAnnotate;
begin
  vDrawAnnotate := THCDrawItemAnnotate.Create;
  vDrawAnnotate.DrawRect := ARect;
  vDrawAnnotate.Mark := AMark;
  Self.Add(vDrawAnnotate);
end;

end.
