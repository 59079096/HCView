{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-12-3             }
{                                                       }
{            ֧����ע���ܵ��ĵ��������Ԫ             }
{                                                       }
{*******************************************************}

unit HCAnnotateData;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Generics.Collections, HCCustomData,
  HCRichData, HCItem, HCStyle, HCParaStyle, HCTextStyle, HCTextItem, HCRectItem,
  HCCommon, HCList;

type
  THCDataAnnotate = class(TSelectInfo)  // Data��ע��Ϣ
  private
    FID, FStartDrawItemNo, FEndDrawItemNo: Integer;
    FTitle, FText: string;
  public
    procedure Initialize; override;
    procedure CopyRange(const ASrc: TSelectInfo);
    property ID: Integer read FID write FID;
    property StartDrawItemNo: Integer read FStartDrawItemNo write FStartDrawItemNo;
    property EndDrawItemNo: Integer read FEndDrawItemNo write FEndDrawItemNo;
    property Title: string read FTitle write FTitle;
    property Text: string read FText write FText;
  end;

  THCDataAnnotates = class(TObjectList<THCDataAnnotate>)
  private
    FOnInsert, FOnRemove: TNotifyEvent;
  protected
    procedure Notify(const Value: THCDataAnnotate; Action: TCollectionNotification); override;
  public
    procedure NewDataAnnotate(const ASelectInfo: TSelectInfo; const ATitle, AText: string);
    property OnInsert: TNotifyEvent read FOnInsert write FOnInsert;
    property OnRemove: TNotifyEvent read FOnRemove write FOnRemove;
  end;

  THCAnnotateMark = (amFirst, amNormal, amLast, amBoth);
  THCDrawItemAnnotate = class(TObject)  // DrawItemע����ʱ��Ӧ������Ϣ
  public
    DrawRect: TRect;
    Mark: THCAnnotateMark;
    DataAnnotate: THCDataAnnotate;

    function First: Boolean;
    function Last: Boolean;
  end;

  THCDrawItemAnnotates = class(TObjectList<THCDrawItemAnnotate>)  // ĳDrawItem��Ӧ��������ע��Ϣ
  public
    procedure NewDrawAnnotate(const ARect: TRect; const AMark: THCAnnotateMark;
      const ADataAnnotate: THCDataAnnotate);
  end;

  TDataDrawItemAnnotateEvent = procedure(const AData: THCCustomData; const ADrawItemNo: Integer;
    const ADrawRect: TRect; const ADataAnnotate: THCDataAnnotate) of object;
  TDataAnnotateEvent = procedure(const AData: THCCustomData; const ADataAnnotate: THCDataAnnotate) of object;
  TDataItemNotifyEvent = procedure(const AData: THCCustomData; const AItem: THCCustomItem) of object;

  THCAnnotateData = class(THCRichData)  // ֧����ע���ܵ�Data��
  private
    FDataAnnotates: THCDataAnnotates;
    FHotAnnotate, FActiveAnnotate: THCDataAnnotate;  // ��ǰ������ע����ǰ�������ע
    FDrawItemAnnotates: THCDrawItemAnnotates;
    FOnDrawItemAnnotate: TDataDrawItemAnnotateEvent;
    FOnInsertAnnotate, FOnRemoveAnnotate: TDataAnnotateEvent;
    FOnInsertItem, FOnRemoveItem: TDataItemNotifyEvent;

    procedure DoInsertItem(const AItem: THCCustomItem);
    procedure DoRemoveItem(const AItem: THCCustomItem);

    /// <summary> ��ȡָ����DrawItem��������ע�Լ��ڸ���ע�е����� </summary>
    /// <param name="ADrawItemNo"></param>
    /// <param name="ACanvas">Ӧ����DrawItem��ʽ��Canvas</param>
    /// <returns></returns>
    function DrawItemOfAnnotate(const ADrawItemNo: Integer;
      const ACanvas: TCanvas; const ADrawRect: TRect): Boolean;

    /// <summary> ָ��DrawItem��Χ�ڵ���ע��ȡ���Ե�DrawItem��Χ </summary>
    /// <param name="AFirstDrawItemNo">��ʼDrawItem</param>
    /// <param name="ALastDrawItemNo">����DrawItem</param>
    procedure CheckAnnotateRange(const AFirstDrawItemNo, ALastDrawItemNo: Integer);  // ������PaintData�ﴦ��ģ�Ӧ�������ݱ䶯��ʹ���ã�������ӿ�PaintData��Ч��

    function GetDrawItemFirstDataAnnotateAt(const ADrawItemNo, X, Y: Integer): THCDataAnnotate;
  protected
    procedure DoDataInsertItem(const AData: THCCustomData; const AItem: THCCustomItem); virtual;
    procedure DoDataRemoveItem(const AData: THCCustomData; const AItem: THCCustomItem); virtual;
    procedure DoItemOpertion(const AItemNo, AOffset: Integer; const AOperation: THCOperation); override;
    procedure DoDrawItemPaintContent(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect, AClearRect: TRect; const ADrawText: string;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure DoInsertAnnotate(Sender: TObject);
    procedure DoRemoveAnnotate(Sender: TObject);
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

    property OnDrawItemAnnotate: TDataDrawItemAnnotateEvent read FOnDrawItemAnnotate write FOnDrawItemAnnotate;
    property OnInsertAnnotate: TDataAnnotateEvent read FOnInsertAnnotate write FOnInsertAnnotate;
    property OnRemoveAnnotate: TDataAnnotateEvent read FOnRemoveAnnotate write FOnRemoveAnnotate;
    property OnInsertItem: TDataItemNotifyEvent read FOnInsertItem write FOnInsertItem;
    property OnRemoveItem: TDataItemNotifyEvent read FOnRemoveItem write FOnRemoveItem;
    property HotAnnotate: THCDataAnnotate read FHotAnnotate;
    property ActiveAnnotate: THCDataAnnotate read FActiveAnnotate;
  end;

implementation

{ THCAnnotateData }

procedure THCAnnotateData.CheckAnnotateRange(const AFirstDrawItemNo, ALastDrawItemNo: Integer);
var
  i, vFirstNo, vLastNo: Integer;
  vDataAnnotate: THCDataAnnotate;
  vDrawRect: TRect;
  vRectItem: THCCustomRectItem;
begin
  if AFirstDrawItemNo < 0 then Exit;

  vFirstNo := Self.DrawItems[AFirstDrawItemNo].ItemNo;
  vLastNo := Self.DrawItems[ALastDrawItemNo].ItemNo;

  for i := 0 to FDataAnnotates.Count - 1 do
  begin
    vDataAnnotate := FDataAnnotates[i];

    if vDataAnnotate.EndItemNo < vFirstNo then  // δ���뱾�β��ҷ�Χ
      Continue;

    if vDataAnnotate.StartItemNo > vLastNo then  // �������β��ҵķ�Χ
      Break;

    vDataAnnotate.StartDrawItemNo :=
      Self.GetDrawItemNoByOffset(vDataAnnotate.StartItemNo, vDataAnnotate.StartItemOffset);
    vDataAnnotate.EndDrawItemNo :=
      Self.GetDrawItemNoByOffset(vDataAnnotate.EndItemNo, vDataAnnotate.EndItemOffset);
    if vDataAnnotate.EndItemOffset = Self.DrawItems[vDataAnnotate.EndDrawItemNo].CharOffs then  // ����ڽ�������ǰ�棬����һ��
      vDataAnnotate.EndDrawItemNo := vDataAnnotate.EndDrawItemNo - 1;
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
  FDataAnnotates := THCDataAnnotates.Create;
  FDataAnnotates.OnInsert := DoInsertAnnotate;
  FDataAnnotates.OnRemove := DoRemoveAnnotate;
  FDrawItemAnnotates := THCDrawItemAnnotates.Create;
  inherited Create(AStyle);
  FHotAnnotate := nil;
  FActiveAnnotate := nil;
  Self.Items.OnInsertItem := DoInsertItem;
  Self.Items.OnRemoveItem := DoRemoveItem;
end;

destructor THCAnnotateData.Destroy;
begin
  FDataAnnotates.Free;
  FDrawItemAnnotates.Free;
  inherited Destroy;
end;

procedure THCAnnotateData.DoDataInsertItem(const AData: THCCustomData;
  const AItem: THCCustomItem);
begin
  if Assigned(FOnInsertItem) then
    FOnInsertItem(AData, AItem);
end;

procedure THCAnnotateData.DoDataRemoveItem(const AData: THCCustomData;
  const AItem: THCCustomItem);
begin
  if Assigned(FOnRemoveItem) then
    FOnRemoveItem(AData, AItem);
end;

procedure THCAnnotateData.DoDrawItemPaintContent(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect, AClearRect: TRect;
  const ADrawText: string; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
  ADataScreenBottom: Integer; const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);
var
  i: Integer;
  vActive: Boolean;
  vDrawAnnotate: THCDrawItemAnnotate;
begin
  if Assigned(FOnDrawItemAnnotate) and DrawItemOfAnnotate(ADrawItemNo, ACanvas, AClearRect) then  // ��ǰDrawItem��ĳ��ע�е�һ����
  begin
    for i := 0 to FDrawItemAnnotates.Count - 1 do  // ��DrawItem������ע��Ϣ
    begin
      vDrawAnnotate := FDrawItemAnnotates[i];

      if not APaintInfo.Print then
      begin
        vActive := vDrawAnnotate.DataAnnotate.Equals(FHotAnnotate) or
          vDrawAnnotate.DataAnnotate.Equals(FActiveAnnotate);

        if vActive then
          ACanvas.Brush.Color := AnnotateBKActiveColor
        else
          ACanvas.Brush.Color := AnnotateBKColor;

        ACanvas.FillRect(vDrawAnnotate.DrawRect);
      end;

      if vDrawAnnotate.First then  // ����עͷ [
      begin
        ACanvas.Pen.Color := clRed;
        ACanvas.MoveTo(vDrawAnnotate.DrawRect.Left + 2, vDrawAnnotate.DrawRect.Top - 2);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Left, vDrawAnnotate.DrawRect.Top);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Left, vDrawAnnotate.DrawRect.Bottom);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Left + 2, vDrawAnnotate.DrawRect.Bottom + 2);
      end;

      if vDrawAnnotate.Last then  // ����עβ ]
      begin
        ACanvas.Pen.Color := clRed;
        ACanvas.MoveTo(vDrawAnnotate.DrawRect.Right - 2, vDrawAnnotate.DrawRect.Top - 2);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Right, vDrawAnnotate.DrawRect.Top);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Right, vDrawAnnotate.DrawRect.Bottom);
        ACanvas.LineTo(vDrawAnnotate.DrawRect.Right - 2, vDrawAnnotate.DrawRect.Bottom + 2);

        FOnDrawItemAnnotate(AData, ADrawItemNo, vDrawAnnotate.DrawRect, vDrawAnnotate.DataAnnotate);
      end;
    end;
  end;

  inherited DoDrawItemPaintContent(AData, ADrawItemNo, ADrawRect, AClearRect,
    ADrawText, ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom,
    ACanvas, APaintInfo);
end;

procedure THCAnnotateData.DoInsertAnnotate(Sender: TObject);
begin
  Style.UpdateInfoRePaint;
  if Assigned(FOnInsertAnnotate) then
    FOnInsertAnnotate(Self, THCDataAnnotate(Sender));
end;

procedure THCAnnotateData.DoInsertItem(const AItem: THCCustomItem);
begin
  DoDataInsertItem(Self, AItem);
end;

procedure THCAnnotateData.DoItemOpertion(const AItemNo, AOffset: Integer;
  const AOperation: THCOperation);
var
  i: Integer;
begin
  for i := 0 to FDataAnnotates.Count - 1 do
  begin
    if FDataAnnotates[i].StartItemNo > AItemNo then
      Break;

    if FDataAnnotates[i].StartItemNo = AItemNo then
    begin
      if FDataAnnotates[i].EndItemNo = AItemNo then
      begin

      end
      else
      begin

      end;
    end
    else
    if FDataAnnotates[i].EndItemNo = AItemNo then
    begin

    end
    else
    if (AItemNo > FDataAnnotates[i].StartItemNo) and (AItemNo < FDataAnnotates[i].EndItemNo) then
    begin

    end;
  end;
end;

procedure THCAnnotateData.DoRemoveAnnotate(Sender: TObject);
begin
  Style.UpdateInfoRePaint;
  if Assigned(FOnRemoveAnnotate) then
    FOnRemoveAnnotate(Self, THCDataAnnotate(Sender));
end;

procedure THCAnnotateData.DoRemoveItem(const AItem: THCCustomItem);
begin
  DoDataRemoveItem(Self, AItem);
end;

function THCAnnotateData.DrawItemOfAnnotate(const ADrawItemNo: Integer;
  const ACanvas: TCanvas; const ADrawRect: TRect): Boolean;
var
  i, vItemNo: Integer;
  vDataAnnotate: THCDataAnnotate;
begin
  Result := False;
  if FDataAnnotates.Count = 0 then Exit;

  vItemNo := Self.DrawItems[ADrawItemNo].ItemNo;
  if vItemNo < FDataAnnotates.First.StartItemNo then Exit;
  if vItemNo > FDataAnnotates.Last.EndItemNo then Exit;

  FDrawItemAnnotates.Clear;
  for i := 0 to FDataAnnotates.Count - 1 do
  begin
    vDataAnnotate := FDataAnnotates[i];

    if vDataAnnotate.EndItemNo < vItemNo then  // δ���뱾�β��ҷ�Χ
      Continue;

    if vDataAnnotate.StartItemNo > vItemNo then  // �������β��ҵķ�Χ
      Break;

    if ADrawItemNo = vDataAnnotate.StartDrawItemNo then
    begin
      if ADrawItemNo = vDataAnnotate.EndDrawItemNo then  // ��ǰDrawItem������ע��ʼ������ע����
      begin
        FDrawItemAnnotates.NewDrawAnnotate(
          Rect(ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vDataAnnotate.StartItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Top,
            ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vDataAnnotate.EndItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Bottom),
          amBoth, vDataAnnotate);
      end
      else  // ������עͷ
      begin
        FDrawItemAnnotates.NewDrawAnnotate(
          Rect(ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vDataAnnotate.StartItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
            ADrawRect.Top, ADrawRect.Right, ADrawRect.Bottom),
          amFirst, vDataAnnotate);
      end;

      Result := True;
    end
    else
    if ADrawItemNo = vDataAnnotate.EndDrawItemNo then  // ��ǰDrawItem����ע����
    begin
      FDrawItemAnnotates.NewDrawAnnotate(
        Rect(ADrawRect.Left, ADrawRect.Top,
          ADrawRect.Left + GetDrawItemOffsetWidth(ADrawItemNo, vDataAnnotate.EndItemOffset - Self.DrawItems[ADrawItemNo].CharOffs + 1, ACanvas),
          ADrawRect.Bottom),
        amLast, vDataAnnotate);

      Result := True;
    end
    else
    if (ADrawItemNo > vDataAnnotate.StartDrawItemNo) and (ADrawItemNo < vDataAnnotate.EndDrawItemNo) then  // ��ǰDrawItem����ע��Χ��
    begin
      FDrawItemAnnotates.NewDrawAnnotate(ADrawRect, amNormal, vDataAnnotate);
      Result := True;
    end;
  end;
end;

procedure THCAnnotateData.GetCaretInfo(const AItemNo, AOffset: Integer;
  var ACaretInfo: THCCaretInfo);
var
  vDataAnnotate: THCDataAnnotate;
  X: Integer;
begin
  inherited GetCaretInfo(AItemNo, AOffset, ACaretInfo);

  vDataAnnotate := GetDrawItemFirstDataAnnotateAt(CaretDrawItemNo,
    GetDrawItemOffsetWidth(CaretDrawItemNo,
      SelectInfo.StartItemOffset - DrawItems[CaretDrawItemNo].CharOffs + 1),
    DrawItems[CaretDrawItemNo].Rect.Top + 1);

  if FActiveAnnotate <> vDataAnnotate then
  begin
    FActiveAnnotate := vDataAnnotate;
    Style.UpdateInfoRePaint;
  end;
end;

function THCAnnotateData.GetDrawItemFirstDataAnnotateAt(
  const ADrawItemNo, X, Y: Integer): THCDataAnnotate;
var
  i, vStyleNo: Integer;
  vPt: TPoint;
begin
  Result := nil;

  vStyleNo := GetDrawItemStyle(ADrawItemNo);
  if vStyleNo > THCStyle.Null then
    Style.TextStyles[vStyleNo].ApplyStyle(Style.DefCanvas);

  if DrawItemOfAnnotate(ADrawItemNo, Style.DefCanvas, DrawItems[ADrawItemNo].Rect) then
  begin
    vPt := Point(X, Y);
    for i := 0 to FDrawItemAnnotates.Count - 1 do
    begin
      if PtInRect(FDrawItemAnnotates[i].DrawRect, vPt) then
      begin
        Result := FDrawItemAnnotates[i].DataAnnotate;
        Break;  // ��ֻȡһ��
      end;
    end;
  end;
end;

procedure THCAnnotateData.InitializeField;
begin
  inherited InitializeField;
  FDataAnnotates.Clear;
  FHotAnnotate := nil;
  FActiveAnnotate := nil;
end;

function THCAnnotateData.InsertAnnotate(const ATitle, AText: string): Boolean;
begin
  Result := False;
  if not CanEdit then Exit;
  if not Self.SelectExists then Exit;

  FDataAnnotates.NewDataAnnotate(SelectInfo, ATitle, AText);
end;

procedure THCAnnotateData.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vDataAnnotate: THCDataAnnotate;
begin
  inherited MouseMove(Shift, X, Y);

  vDataAnnotate := GetDrawItemFirstDataAnnotateAt(MouseMoveDrawItemNo, X, Y);

  if FHotAnnotate <> vDataAnnotate then
  begin
    FHotAnnotate := vDataAnnotate;
    Style.UpdateInfoRePaint;
  end;
end;

procedure THCAnnotateData.PaintData(const ADataDrawLeft, ADataDrawTop,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom, AVOffset, AFristDItemNo,
  ALastDItemNo: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  CheckAnnotateRange(AFristDItemNo, ALastDItemNo);  // ָ��DrawItem��Χ�ڵ���ע��ȡ���Ե�DrawItem��Χ
  inherited PaintData(ADataDrawLeft, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, AVOffset, AFristDItemNo, ALastDItemNo, ACanvas, APaintInfo);
  FDrawItemAnnotates.Clear;
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

procedure THCDataAnnotates.NewDataAnnotate(const ASelectInfo: TSelectInfo;
  const ATitle, AText: string);
var
  vDataAnnotate: THCDataAnnotate;
begin
  vDataAnnotate := THCDataAnnotate.Create;
  vDataAnnotate.CopyRange(ASelectInfo);
  vDataAnnotate.Title := ATitle;
  vDataAnnotate.Text := AText;
  vDataAnnotate.ID := Self.Add(vDataAnnotate);
end;

procedure THCDataAnnotates.Notify(const Value: THCDataAnnotate;
  Action: TCollectionNotification);
begin
  if Action = cnAdded then
  begin
    if Assigned(FOnInsert) then
      FOnInsert(Value);
  end
  else
  if Action = cnRemoved then
  begin
    if Assigned(FOnRemove) then
      FOnRemove(Value);
  end;

  inherited Notify(Value, Action);
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

procedure THCDrawItemAnnotates.NewDrawAnnotate(const ARect: TRect;
  const AMark: THCAnnotateMark; const ADataAnnotate: THCDataAnnotate);
var
  vDrawItemAnnotate: THCDrawItemAnnotate;
begin
  vDrawItemAnnotate := THCDrawItemAnnotate.Create;
  vDrawItemAnnotate.DrawRect := ARect;
  vDrawItemAnnotate.Mark := AMark;
  vDrawItemAnnotate.DataAnnotate := ADataAnnotate;
  Self.Add(vDrawItemAnnotate);
end;

end.
