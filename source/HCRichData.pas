{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{             �ĵ��ڸ������߼�����Ԫ                }
{                                                       }
{*******************************************************}

unit HCRichData;

interface

uses
  Windows, Classes, Controls, Graphics, HCCustomData, HCCustomRichData, HCItem,
  HCStyle, HCParaStyle, HCTextStyle, HCRectItem, HCCommon, HCDataCommon;

type
  TDomain = class
  strict private
    FBeginNo, FEndNo: Integer;
  public
    constructor Create;
    procedure Clear;
    function Contain(const AItemNo: Integer): Boolean;
    property BeginNo: Integer read FBeginNo write FBeginNo;
    property EndNo: Integer read FEndNo write FEndNo;
  end;

  THCRichData = class(THCCustomRichData)  // ���ı������࣬����Ϊ������ʾ���ı���Ļ���
  private
    FHotDomain, FActiveDomain: TDomain;
    FHotDomainRGN, FActiveDomainRGN: HRGN;
    FDrawActiveDomainRegion, FDrawHotDomainRegion: Boolean;

    procedure GetDomainFrom(const AItemNo, AOffset: Integer;
      const ADomain: TDomain);
    function GetActiveDomain: TDomain;
  protected
    function CreateItemByStyle(const AStyleNo: Integer): THCCustomItem; override;
    function CreateDefaultDomainItem: THCCustomItem; override;
    function CreateDefaultTextItem: THCCustomItem; override;
    procedure PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, AVOffset: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure Clear; override;
    procedure Initialize; override;
    procedure GetCaretInfo(const AItemNo, AOffset: Integer; var ACaretInfo: TCaretInfo); override;
    function CanDeleteItem(const AItemNo: Integer): Boolean; override;
    //
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure DoDrawItemPaintBefor(const AData: THCCustomData; const ADrawItemIndex: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    function InsertItem(const AItem: THCCustomItem): Boolean; override;
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem): Boolean; override;
  public
    constructor Create(const AStyle: THCStyle); override;
    destructor Destroy; override;

    /// <summary> ѡ��ָ��Item������� </summary>
    procedure SelectItemAfter(const AItemNo: Integer);

    /// <summary> ѡ�����һ��Item������� </summary>
    procedure SelectLastItemAfter;

    procedure GetCaretInfoCur(var ACaretInfo: TCaretInfo);
    procedure TraverseItem(const ATraverse: TItemTraverse);
    property HotDomain: TDomain read FHotDomain;
    property ActiveDomain: TDomain read GetActiveDomain;
    //property ShowHotDeGroupRegion: Boolean read FShowHotDeGroupRegion write FShowHotDeGroupRegion; ����ſ�����201711281352
  end;

implementation

uses
  SysUtils, EmrElementItem, EmrGroupItem; {CreateDefaultTextItem��CreateDefaultDomainItemʹ����Emr��ص�Ԫ}

{ THCRichData }

function THCRichData.CanDeleteItem(const AItemNo: Integer): Boolean;
begin
  Result := Items[AItemNo].StyleNo <> THCStyle.RsDomain;
end;

procedure THCRichData.Clear;
begin
  inherited Clear;
  FHotDomain.Clear;
  FActiveDomain.Clear;
end;

constructor THCRichData.Create(const AStyle: THCStyle);
begin
  FHotDomain := TDomain.Create;
  FActiveDomain := TDomain.Create;
  inherited Create(AStyle);
end;

function THCRichData.CreateDefaultDomainItem: THCCustomItem;
begin
  Result := TDeGroup.Create;
  Result.ParaNo := Style.CurParaNo;
end;

function THCRichData.CreateDefaultTextItem: THCCustomItem;
begin
  Result := TEmrTextItem.CreateByText('');  // �����в��������ܵ������Դ���
  Result.StyleNo := Style.CurStyleNo;
  Result.ParaNo := Style.CurParaNo;
  if Assigned(OnCreateItem) then
    OnCreateItem(Result);
end;

function THCRichData.CreateItemByStyle(const AStyleNo: Integer): THCCustomItem;
begin
  // �Զ���������ڴ˴�����
  Result := inherited CreateItemByStyle(AStyleNo);
end;

destructor THCRichData.Destroy;
begin
  FHotDomain.Free;
  FActiveDomain.Free;
  inherited;
end;

procedure THCRichData.DoDrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vEmrItem: TEmrTextItem;
  vDrawHotDomainBorde, vDrawActiveDomainBorde: Boolean;
  vItemNo: Integer;
  vDliRGN: HRGN;
begin
  inherited DoDrawItemPaintBefor(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);;
  if not APaintInfo.Print then
  begin
    vDrawHotDomainBorde := False;
    vDrawActiveDomainBorde := False;
    vItemNo := DrawItems[ADrawItemIndex].ItemNo;

    if FHotDomain.BeginNo >= 0 then
      vDrawHotDomainBorde := FHotDomain.Contain(vItemNo);

    if FActiveDomain.BeginNo >= 0 then
      vDrawActiveDomainBorde := FActiveDomain.Contain(vItemNo);

    if vDrawHotDomainBorde or vDrawActiveDomainBorde then
    begin
      vDliRGN := CreateRectRgn(ADrawRect.Left, ADrawRect.Top, ADrawRect.Right, ADrawRect.Bottom);
      try
        if (FHotDomain.BeginNo >= 0) and vDrawHotDomainBorde then
          CombineRgn(FHotDomainRGN, FHotDomainRGN, vDliRGN, RGN_OR);
        if (FActiveDomain.BeginNo >= 0) and vDrawActiveDomainBorde then
          CombineRgn(FActiveDomainRGN, FActiveDomainRGN, vDliRGN, RGN_OR);
      finally
        DeleteObject(vDliRGN);
      end;
      {vRect := ADrawRect;
      //InflateRect(vRect, 0, -GStyle.ParaStyles[GetDrawItemParaStyle(ADrawItemIndex)].LineSpaceHalf);
      ACanvas.Pen.Color := clGreen;
      ACanvas.Pen.Style := psSolid;
      ACanvas.MoveTo(vRect.Left, vRect.Top);
      ACanvas.LineTo(vRect.Right, vRect.Top);
      ACanvas.MoveTo(vRect.Left, vRect.Bottom);
      ACanvas.LineTo(vRect.Right, vRect.Bottom);}
    end;
  end;
end;

procedure THCRichData.GetDomainFrom(const AItemNo, AOffset: Integer;
  const ADomain: TDomain);
var
  i, vStartNo, vEndNo, vCount: Integer;
begin
  ADomain.Clear;

  if (AItemNo < 0) or (AOffset < 0) then Exit;

  { ����ʼ��ʶ }
  vCount := 0;
  // ȷ����ǰ�ҵ���ʼλ��
  vStartNo := AItemNo;
  vEndNo := AItemNo;
  if Items[AItemNo] is THCDomainItem then  // ��ʼλ�þ���Group
  begin
    if (Items[AItemNo] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ����λ������ʼ���
    begin
      if AOffset = OffsetAfter then  // ����ں���
      begin
        ADomain.BeginNo := AItemNo;  // ��ǰ��Ϊ��ʼ��ʶ
        vEndNo := AItemNo + 1;
      enD
      else  // �����ǰ��
      begin
        if AItemNo > 0 then  // ���ǵ�һ��
          vStartNo := AItemNo - 1  // ��ǰһ����ǰ
        else  // ���ڵ�һ��ǰ��
          Exit;  // ��������
      end;
    end
    else  // ����λ���ǽ������
    begin
      if AOffset = OffsetAfter then  // ����ں���
      begin
        if AItemNo < Items.Count - 1 then  // �������һ��
          vEndNo := AItemNo + 1
        else  // �����һ������
          Exit;  // ��������
      end
      else  // �����ǰ��
      begin
        ADomain.EndNo := AItemNo;
        vStartNo := AItemNo - 1;
      end;
    end;
  end;

  if ADomain.BeginNo < 0 then
  begin
    for i := vStartNo downto 0 do  // ��
    begin
      if Items[i] is THCDomainItem then
      begin
        if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtBeg then  // ��ʼ���
        begin
          if vCount <> 0 then  // ��Ƕ��
            Dec(vCount)
          else
          begin
            ADomain.BeginNo := i;
            Break;
          end;
        end
        else  // �������
          Inc(vCount);  // ��Ƕ��
      end;
    end;
  end;

  { �ҽ�����ʶ }
  if (ADomain.BeginNo >= 0) and (ADomain.EndNo < 0) then
  begin
    vCount := 0;
    for i := vEndNo to Items.Count - 1 do
    begin
      if Items[i] is THCDomainItem then
      begin
        if (Items[i] as THCDomainItem).MarkType = TMarkType.cmtEnd then  // �ǽ�β
        begin
          if vCount <> 0 then
            Dec(vCount)
          else
          begin
            ADomain.EndNo := i;
            Break;
          end;
        end
        else  // ����ʼ���
          Inc(vCount);  // ��Ƕ��
      end;
    end;

    if ADomain.EndNo < 0 then
      raise Exception.Create('�쳣����ȡ�������������');
  end;
end;

function THCRichData.GetActiveDomain: TDomain;
begin
  Result := nil;
  if FActiveDomain.BeginNo >= 0 then
    Result := FActiveDomain;
end;

procedure THCRichData.GetCaretInfo(const AItemNo, AOffset: Integer;
  var ACaretInfo: TCaretInfo);
var
  vTopData: THCCustomRichData;
begin
  inherited GetCaretInfo(AItemNo, AOffset, ACaretInfo);

  // ��ֵ����Group��Ϣ������� MouseDown
  if Self.SelectInfo.StartItemNo >= 0 then
  begin
    vTopData := GetTopLevelData;
    if vTopData = Self then
    begin
      if FActiveDomain.BeginNo >= 0 then  // ԭ������Ϣ(����δͨ��������ƶ����ʱû�����)
      begin
        FActiveDomain.Clear;
        FDrawActiveDomainRegion := False;
        Style.UpdateInfoRePaint;
      end;
      // ��ȡ��ǰ��괦ActiveDeGroup��Ϣ
      Self.GetDomainFrom(Self.SelectInfo.StartItemNo, Self.SelectInfo.StartItemOffset, FActiveDomain);
      if FActiveDomain.BeginNo >= 0 then
      begin
        FDrawActiveDomainRegion := True;
        Style.UpdateInfoRePaint;
      end;
    end;
  end;
end;

procedure THCRichData.GetCaretInfoCur(var ACaretInfo: TCaretInfo);
begin
  if Style.UpdateInfo.Draging then
    Self.GetCaretInfo(Self.MouseMoveItemNo, Self.MouseMoveItemOffset, ACaretInfo)
  else
    Self.GetCaretInfo(SelectInfo.StartItemNo, SelectInfo.StartItemOffset, ACaretInfo);
end;

function THCRichData.InsertItem(const AItem: THCCustomItem): Boolean;
begin
  Result := inherited InsertItem(AItem);
  if Result then
  begin
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
  end;
end;

procedure THCRichData.Initialize;
begin
  inherited Initialize;
  FActiveDomain.Clear;
  FHotDomain.Clear;
end;

function THCRichData.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem): Boolean;
begin
  Result := inherited InsertItem(AIndex, AItem);
  if Result then
  begin
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
  end;
end;

procedure THCRichData.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  // ��������Group��Ϣ����ֵ�� GetCaretInfo
  if FActiveDomain.BeginNo >= 0 then
    Style.UpdateInfoRePaint;
  FActiveDomain.Clear;
  FDrawActiveDomainRegion := False;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure THCRichData.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vTopData: THCRichData;
begin
  // ��� FHotDeGroup ��Ϣ
  if FHotDomain.BeginNo >= 0 then
    Style.UpdateInfoRePaint;
  FHotDomain.Clear;
  FDrawHotDomainRegion := False;

  inherited MouseMove(Shift, X, Y);

  if not Self.MouseMoveRestrain then  // ��Item��
  begin
    Self.GetDomainFrom(Self.MouseMoveItemNo, Self.MouseMoveItemOffset, FHotDomain);  // ȡHotDeGroup
    vTopData := Self.GetTopLevelDataAt(X, Y) as THCRichData;
    if (vTopData = Self) or (not vTopData.FDrawHotDomainRegion) then  // �������� �� ���㲻�����Ҷ���û��HotDeGroup  201711281352
    begin
      if FHotDomain.BeginNo >= 0 then  // ��FHotDeGroup
      begin
        FDrawHotDomainRegion := True;
        Style.UpdateInfoRePaint;
      end;
    end;
  end;
end;

procedure THCRichData.PaintData(const ADataDrawLeft, ADataDrawTop,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom, AVOffset: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vOldColor: TColor;
begin
  if not APaintInfo.Print then  // �Ǵ�ӡ���Ƽ���������
  begin
    if FDrawHotDomainRegion then
      FHotDomainRGN := CreateRectRgn(0, 0, 0, 0);

    if FDrawActiveDomainRegion then
      FActiveDomainRGN := CreateRectRgn(0, 0, 0, 0);
  end;

  inherited PaintData(ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
    ADataScreenTop, ADataScreenBottom, AVOffset, ACanvas, APaintInfo);

  if not APaintInfo.Print then  // �Ǵ�ӡ���Ƽ���������
  begin
    vOldColor := ACanvas.Brush.Color;  // ��Ϊʹ��Brush���Ʊ߿�������Ҫ����ԭ��ɫ
    try
      if FDrawHotDomainRegion then
      begin
        ACanvas.Brush.Color := clActiveBorder;
        FrameRgn(ACanvas.Handle, FHotDomainRGN, ACanvas.Brush.Handle, 1, 1);
        DeleteObject(FHotDomainRGN);
      end;

      if FDrawActiveDomainRegion then
      begin
        ACanvas.Brush.Color := clBlue;
        FrameRgn(ACanvas.Handle, FActiveDomainRGN, ACanvas.Brush.Handle, 1, 1);
        DeleteObject(FActiveDomainRGN);
      end;
    finally
      ACanvas.Brush.Color := vOldColor;
    end;
  end;
end;

procedure THCRichData.SelectItemAfter(const AItemNo: Integer);
begin
  ReSetSelectAndCaret(AItemNo);
end;

procedure THCRichData.SelectLastItemAfter;
begin
  SelectItemAfter(Items.Count - 1);
end;

procedure THCRichData.TraverseItem(const ATraverse: TItemTraverse);
var
  i: Integer;
begin
  if ATraverse <> nil then
  begin
    for i := Items.Count - 1 downto 0 do  // �������������ɾ��
    begin
      if ATraverse.Stop then Break;

      ATraverse.Process(Self, i, ATraverse.Tag, ATraverse.Stop);
      if Items[i].StyleNo < THCStyle.RsNull then
        (Items[i] as THCCustomRectItem).TraverseItem(ATraverse);
    end;
  end;
end;

{ TDomain }

procedure TDomain.Clear;
begin
  FBeginNo := -1;
  FEndNo := -1;
end;

function TDomain.Contain(const AItemNo: Integer): Boolean;
begin
  Result := (AItemNo > FBeginNo) and (AItemNo < FEndNo);
end;

constructor TDomain.Create;
begin
  Clear;
end;

end.
