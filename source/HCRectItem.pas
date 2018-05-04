{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{            �ĵ�RectItem�������ʵ�ֵ�Ԫ               }
{                                                       }
{*******************************************************}

unit HCRectItem;

interface

uses
  Windows, Classes, Controls, Graphics, HCItem, HCDrawItem, HCTextStyle, HCParaStyle,
  HCStyleMatch, HCStyle, HCCommon, HCCustomData, HCDataCommon;

type
  THCCustomRectItem = class(THCCustomItem)
  strict private
    FStyle: THCStyle;
    FWidth, FHeight: Integer;
    FTextWrapping: Boolean;  // �ı�����

    // ��ʶ�ڲ��߶��Ƿ����˱仯�����ڴ�Item�ڲ���ʽ��ʱ����������Data��ʶ��Ҫ���¸�ʽ����Item
    // �����һ����Ԫ�����ݱ仯��û������������仯ʱ������Ҫ���¸�ʽ�����Ҳ����Ҫ���¼���ҳ��
    // ��ӵ�д�Item��Dataʹ�����Ӧ��������ֵΪFalse���ɲο�TableItem.KeyPress��ʹ��
    FHeightChanged: Boolean;
  protected
    function GetWidth: Integer; virtual;
    procedure SetWidth(const Value: Integer); virtual;
    function GetHeight: Integer; virtual;
    procedure SetHeight(const Value: Integer); virtual;
    function BreakByOffset(const AOffset: Integer): THCCustomItem; override;
    function CanConcatItems(const AItem: THCCustomItem): Boolean; override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create; overload; override;
    constructor Create(const AWidth, AHeight: Integer); overload; virtual;
    // ���󷽷������̳�
    function ApplySelectTextStyle(const AStyle: THCStyle; const AMatchStyle: TStyleMatch): Integer; virtual;
    procedure ApplySelectParaStyle(const AStyle: THCStyle; const AMatchStyle: TParaMatch); virtual;
    procedure FormatToDrawItem(const AStyle: THCStyle); virtual;

    /// <summary> ���������Ϊ�����ҳ�Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer; virtual;
    function DeleteSelected: Boolean; virtual;
    procedure MarkStyleUsed(const AMark: Boolean); virtual;
    procedure SaveSelectToStream(const AStream: TStream); virtual;
    function SaveSelectToText: string; virtual;
    function GetActiveItem: THCCustomItem; virtual;
    function GetActiveDrawItem: THCCustomDrawItem; virtual;
    function GetActiveDrawItemCoord: TPoint; virtual;
    /// <summary> ��ȡָ��Xλ�ö�Ӧ��Offset </summary>
    function GetOffsetAt(const X: Integer): Integer; virtual;
    /// <summary> ��ȡ����X��Y�Ƿ���ѡ�������� </summary>
    function CoordInSelect(const X, Y: Integer): Boolean; virtual;
    /// <summary> ��������ʱ�ڲ��Ƿ���ָ����Key��Shif </summary>
    function WantKeyDown(const Key: Word; const Shift: TShiftState): Boolean; virtual;
    /// <summary> ��ɢ����ʱ�Ƿ�ּ�� </summary>
    function JustifySplit: Boolean; virtual;
    /// <summary> ���¹��λ�� </summary>
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); virtual;
    procedure GetCurStyle(var AStyleNo, AParaNo: Integer); virtual;

    /// <summary> ��ȡ��ָ���߶��ڵĽ���λ�ô����¶�(��ʱû�õ�ע����) </summary>
    /// <param name="AHeight">ָ���ĸ߶ȷ�Χ</param>
    /// <param name="ADItemMostBottom">��׶�DItem�ĵײ�λ��</param>
    //procedure GetPageFmtBottomInfo(const AHeight: Integer; var ADItemMostBottom: Integer); virtual;

    /// <summary> �����ʽ����ķ�ҳλ�� </summary>
    /// <param name="ADrawItemRectTop">��Ӧ��DrawItem��Rect.Top�����м��һ��</param>
    /// <param name="ADrawItemRectBottom">��Ӧ��DrawItem��Rect.Bottom�����м��һ��</param>
    /// <param name="APageDataFmtTop">ҳ����Top</param>
    /// <param name="APageDataFmtBottom">ҳ����Bottom</param>
    /// <param name="AStartSeat">��ʼ�����ҳλ��</param>
    /// <param name="ABreakSeat">��Ҫ��ҳλ��</param>
    /// <param name="AFmtOffset">Ϊ�˱ܿ���ҳλ����������ƫ�Ƶĸ߶�</param>
    /// <param name="AFmtHeightInc">Ϊ�˱ܿ���ҳλ�ø߶�����ֵ</param>
    procedure CheckFormatPage(const ADrawItemRectTop, ADrawItemRectBottom,
      APageDataFmtTop, APageDataFmtBottom, AStartSeat: Integer;
      var ABreakSeat, AFmtOffset, AFmtHeightInc: Integer); virtual;

    function InsertItem(const AItem: THCCustomItem): Boolean; virtual;
    function InsertText(const AText: string): Boolean; virtual;
    function InsertGraphic(const AGraphic: TGraphic; const ANewPara: Boolean): Boolean; virtual;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; virtual;

    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    function SelectExists: Boolean; virtual;
    procedure DragNotify(const AFinish: Boolean); virtual;
    // ��ǰRectItem�Ƿ�����Ҫ�����Data(Ϊ������뷵��TCustomRichData����)
    function GetActiveData: THCCustomData; virtual;
    // ����ָ��λ�ô��Ķ���Data(Ϊ������뷵��TCustomRichData����)
    function GetTopLevelDataAt(const X, Y: Integer): THCCustomData; virtual;

    procedure TraverseItem(const ATraverse: TItemTraverse); virtual;
    //
    function GetLength: Integer; override;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property TextWrapping: Boolean read FTextWrapping write FTextWrapping;  // �ı�����
    property HeightChanged: Boolean read FHeightChanged write FHeightChanged;
  end;

  THCDomainItem = class(THCCustomRectItem)  // ��
  private
    FLevel: Byte;
    FMarkType: TMarkType;
  protected
    function GetOffsetAt(const X: Integer): Integer; override;
    function JustifySplit: Boolean; override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create; override;
    property MarkType: TMarkType read FMarkType write FMarkType;
    property Level: Byte read FLevel write FLevel;
  end;

  THCTextRectItem = class(THCCustomRectItem)
  private
    FTextStyleNo: Integer;
  protected
    function SelectExists: Boolean; override;
    function GetOffsetAt(const X: Integer): Integer; override;
    function JustifySplit: Boolean; override;
    function ApplySelectTextStyle(const AStyle: THCStyle;
      const AMatchStyle: TStyleMatch): Integer; override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    procedure SetTextStyleNo(const Value: Integer); virtual;
  public
    constructor Create; override;
    property TextStyleNo: Integer read FTextStyleNo write SetTextStyleNo;
  end;

  TGripType = (gtNone, gtLeftTop, gtRightTop, gtLeftBottom, gtRightBottom,
    gtLeft, gtTop, gtRight, gtBottom);

  THCResizeRectItem = class(THCCustomRectItem)
  private
    FGripSize: Word;  // �϶����С
    FResizing: Boolean;  // �����϶��ı��С
    FCanResize: Boolean;  // ��ǰ�Ƿ��ڿɸı��С״̬
    FResizeGrip: TGripType;
    FResizeRect: TRect;
    FResizeX, FResizeY: Integer;  // �϶�����ʱ��ʼλ��
    FResizeWidth, FResizeHeight: Integer;  // ���ź�Ŀ���
    function GetGripType(const X, Y: Integer): TGripType;
  protected
    /// <summary> ��ȡ����X��Y�Ƿ���ѡ�������� </summary>
    function CoordInSelect(const X, Y: Integer): Boolean; override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure PaintTop(const ACanvas: TCanvas); override;
    // �̳�THCCustomItem���󷽷�
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function CanDrag: Boolean; override;
    function SelectExists: Boolean; override;
    /// <summary> ���¹��λ�� </summary>
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); override;

    function GetResizing: Boolean; virtual;
    procedure SetResizing(const Value: Boolean); virtual;
    property ResizeGrip: TGripType read FResizeGrip;
  public
    constructor Create; override;
    property GripSize: Word read FGripSize write FGripSize;
    property Resizing: Boolean read GetResizing write SetResizing;
    property ResizeRect: TRect read FResizeRect;
    property ResizeWidth: Integer read FResizeWidth;
    property ResizeHeight: Integer read FResizeHeight;
    property CanResize: Boolean read FCanResize write FCanResize;
  end;

implementation

{ THCCustomRectItem }

procedure THCCustomRectItem.ApplySelectParaStyle(const AStyle: THCStyle;
  const AMatchStyle: TParaMatch);
begin
end;

function THCCustomRectItem.ApplySelectTextStyle(const AStyle: THCStyle;
  const AMatchStyle: TStyleMatch): Integer;
begin
end;

function THCCustomRectItem.BreakByOffset(const AOffset: Integer): THCCustomItem;
begin
  Result := nil;
end;

function THCCustomRectItem.CanConcatItems(const AItem: THCCustomItem): Boolean;
begin
  Result := False;
end;

procedure THCCustomRectItem.CheckFormatPage(const ADrawItemRectTop, ADrawItemRectBottom,
  APageDataFmtTop, APageDataFmtBottom, AStartSeat: Integer; var ABreakSeat,
  AFmtOffset, AFmtHeightInc: Integer);
begin
  AFmtHeightInc := 0;
  ABreakSeat := 0;
  if ADrawItemRectBottom > APageDataFmtBottom then
    AFmtOffset := APageDataFmtBottom - ADrawItemRectTop
  else
    AFmtOffset := 0;
end;

function THCCustomRectItem.CoordInSelect(const X, Y: Integer): Boolean;
begin
  Result := False;
end;

constructor THCCustomRectItem.Create;
begin
  inherited Create;
  FWidth := 100;   // Ĭ�ϳߴ�
  FHeight := 50;
  FTextWrapping := False;
  FHeightChanged := False;
end;

constructor THCCustomRectItem.Create(const AWidth, AHeight: Integer);
begin
  inherited Create;  // ���ﲻ�̳еĻ���THCCustomRectItem���ൽ����ʱ�����ܵ��õ�
  Width := AWidth;   // THCCustomRectItem.Create�����������Լ���Create�����ѭ��
  Height := AHeight;
  FTextWrapping := False;
  FHeightChanged := False;
end;

function THCCustomRectItem.DeleteSelected: Boolean;
begin
  Result := False;
end;

procedure THCCustomRectItem.DragNotify(const AFinish: Boolean);
begin
end;

procedure THCCustomRectItem.FormatToDrawItem(const AStyle: THCStyle);
begin
end;

function THCCustomRectItem.GetActiveData: THCCustomData;
begin
  Result := nil;
end;

function THCCustomRectItem.GetActiveDrawItem: THCCustomDrawItem;
begin
  Result := nil;
end;

function THCCustomRectItem.GetActiveDrawItemCoord: TPoint;
begin
  Result := Point(0, 0);
end;

function THCCustomRectItem.GetActiveItem: THCCustomItem;
begin
  Result := Self;
end;

procedure THCCustomRectItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
begin
end;

procedure THCCustomRectItem.GetCurStyle(var AStyleNo, AParaNo: Integer);
begin
  AStyleNo := Self.StyleNo;
  AParaNo := Self.ParaNo;
end;

function THCCustomRectItem.ClearFormatExtraHeight: Integer;
begin
  Result := 0;
end;

function THCCustomRectItem.GetHeight: Integer;
begin
  Result := FHeight;
end;

function THCCustomRectItem.GetLength: Integer;
begin
  Result := 1;
end;

function THCCustomRectItem.GetOffsetAt(const X: Integer): Integer;
begin
  if X < 0 then
    Result := OffsetBefor
  else
  if X > Width then
    Result := OffsetAfter
  else
    Result := OffsetInner;
end;

function THCCustomRectItem.GetTopLevelDataAt(const X, Y: Integer): THCCustomData;
begin
  Result := nil;
end;

//procedure THCCustomRectItem.GetPageFmtBottomInfo(const AHeight: Integer;
//  var ADItemMostBottom: Integer);
//begin
//end;

function THCCustomRectItem.GetWidth: Integer;
begin
  Result := FWidth;
end;

function THCCustomRectItem.InsertGraphic(const AGraphic: TGraphic;
  const ANewPara: Boolean): Boolean;
begin
end;

function THCCustomRectItem.InsertItem(const AItem: THCCustomItem): Boolean;
begin
end;

function THCCustomRectItem.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
begin
end;

function THCCustomRectItem.InsertText(const AText: string): Boolean;
begin
end;

function THCCustomRectItem.JustifySplit: Boolean;
begin
  Result := True;
end;

procedure THCCustomRectItem.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Key := 0;
end;

procedure THCCustomRectItem.KeyPress(var Key: Char);
begin
  Key := #0
end;

procedure THCCustomRectItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FWidth, SizeOf(FWidth));
  AStream.ReadBuffer(FHeight, SizeOf(FHeight));
end;

procedure THCCustomRectItem.MarkStyleUsed(const AMark: Boolean);
begin
end;

procedure THCCustomRectItem.SaveSelectToStream(const AStream: TStream);
begin
end;

function THCCustomRectItem.SaveSelectToText: string;
begin
  Result := '';
end;

procedure THCCustomRectItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FWidth, SizeOf(FWidth));
  AStream.WriteBuffer(FHeight, SizeOf(FHeight));
end;

function THCCustomRectItem.SelectExists: Boolean;
begin
  Result := False;
end;

procedure THCCustomRectItem.SetHeight(const Value: Integer);
begin
  FHeight := Value;
end;

procedure THCCustomRectItem.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

procedure THCCustomRectItem.TraverseItem(const ATraverse: TItemTraverse);
begin
end;

function THCCustomRectItem.WantKeyDown(const Key: Word;
  const Shift: TShiftState): Boolean;
begin
  Result := False;
end;

{ THCResizeRectItem }

function THCResizeRectItem.CanDrag: Boolean;
begin
  Result := not FResizing;
end;

function THCResizeRectItem.CoordInSelect(const X, Y: Integer): Boolean;
begin
  Result := SelectExists and PtInRect(Bounds(0, 0, Width, Height), Point(X, Y))
    and (GetGripType(X, Y) = gtNone);
end;

constructor THCResizeRectItem.Create;
begin
  inherited Create;
  FCanResize := True;
  FGripSize := 8;
end;

procedure THCResizeRectItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;

  if (not APaintInfo.Print) and Active then  // ����״̬�����ƽ����ê��
  begin
    if Resizing then
    begin
      case FResizeGrip of
        gtLeftTop:
          FResizeRect := Bounds(ADrawRect.Left + Width - FResizeWidth,
            ADrawRect.Top + Height - FResizeHeight, FResizeWidth, FResizeHeight);

        gtRightTop:
          FResizeRect := Bounds(ADrawRect.Left,
            ADrawRect.Top + Height - FResizeHeight, FResizeWidth, FResizeHeight);

        gtLeftBottom:
          FResizeRect := Bounds(ADrawRect.Left + Width - FResizeWidth,
            ADrawRect.Top, FResizeWidth, FResizeHeight);

        gtRightBottom:
          FResizeRect := Bounds(ADrawRect.Left, ADrawRect.Top, FResizeWidth, FResizeHeight);
      end;

      APaintInfo.TopItems.Add(Self);
    end;

    // ���������϶���ʾê��
    ACanvas.Brush.Color := clGray;
    ACanvas.FillRect(Bounds(ADrawRect.Left, ADrawRect.Top, GripSize, GripSize));
    ACanvas.FillRect(Bounds(ADrawRect.Right - GripSize, ADrawRect.Top, GripSize, GripSize));
    ACanvas.FillRect(Bounds(ADrawRect.Left, ADrawRect.Bottom - GripSize, GripSize, GripSize));
    ACanvas.FillRect(Bounds(ADrawRect.Right - GripSize, ADrawRect.Bottom - GripSize, GripSize, GripSize));
  end;
end;

procedure THCResizeRectItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
begin
  if Self.Active then
    ACaretInfo.Visible := False;
end;

function THCResizeRectItem.GetGripType(const X, Y: Integer): TGripType;
var
  vPt: TPoint;
begin
  vPt := Point(X, Y);
  if PtInRect(Bounds(0, 0, GripSize, GripSize), vPt) then
    Result := gtLeftTop
  else
  if PtInRect(Bounds(Width - GripSize, 0, GripSize, GripSize), vPt) then
    Result := gtRightTop
  else
  if PtInRect(Bounds(0, Height - GripSize, GripSize, GripSize), vPt) then
    Result := gtLeftBottom
  else
  if PtInRect(Bounds(Width - GripSize, Height - GripSize, GripSize, GripSize), vPt) then
    Result := gtRightBottom
  else
    Result := gtNone;
end;

function THCResizeRectItem.GetResizing: Boolean;
begin
  Result := FResizing;
end;

procedure THCResizeRectItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FResizeGrip := gtNone;
  inherited MouseDown(Button, Shift, X, Y);
  if Active then
  begin
    FResizeGrip := GetGripType(X, Y);
    FResizing := FResizeGrip <> gtNone;
    if FResizing then
    begin
      FResizeX := X;
      FResizeY := Y;
    end;
  end;
end;

procedure THCResizeRectItem.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vW, vH: Integer;
  vBL: Single;
begin
  inherited;
  GCursor := crDefault;
  if Active then
  begin
    if FResizing then  // ����������
    begin
      vBL := Width / Height;
      vW := X - FResizeX;
      vH := Y - FResizeY;
      if vW > vH then
        vH := Round(vW / vBL)
      else
        vW := Round(vH * vBL);

      case FResizeGrip of
        gtLeftTop:
          begin
            FResizeWidth := Width - vW;
            FResizeHeight := Height - vH;
          end;

        gtRightTop:
          begin
            FResizeWidth := Width + vW;
            FResizeHeight := Height - vH;
          end;

        gtLeftBottom:
          begin
            FResizeWidth := Width - vW;
            FResizeHeight := Height + vH;
          end;

        gtRightBottom:
          begin
            FResizeWidth := Width + vW;
            FResizeHeight := Height + vH;
          end;
      end;
    end
    else  // ������
    begin
      case GetGripType(X, Y) of
        gtLeftTop, gtRightBottom:
          GCursor := crSizeNWSE;

        gtRightTop, gtLeftBottom:
          GCursor := crSizeNESW;

        gtLeft, gtRight:
          GCursor := crSizeWE;

        gtTop, gtBottom:
          GCursor := crSizeNS;
      end;
    end;
  end;
end;

procedure THCResizeRectItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if FResizing then
  begin
    Width := FResizeWidth;
    Height := FResizeHeight;
    FResizing := False;
  end;
end;

procedure THCResizeRectItem.PaintTop(const ACanvas: TCanvas);
begin
  inherited;
  //ACanvas.DrawFocusRect(ADrawRect);  // �����Ϊɶ����������
  ACanvas.Brush.Style := bsClear;
  ACanvas.Rectangle(FResizeRect);
end;

function THCResizeRectItem.SelectExists: Boolean;
begin
  Result := IsSelectComplate or Active;
end;

procedure THCResizeRectItem.SetResizing(const Value: Boolean);
begin
  if FResizing <> Value then
    FResizing := Value;
end;

{ THCTextRectItem }

function THCTextRectItem.ApplySelectTextStyle(const AStyle: THCStyle;
  const AMatchStyle: TStyleMatch): Integer;
begin
  FTextStyleNo := AMatchStyle.GetMatchStyleNo(AStyle, FTextStyleNo);
end;

constructor THCTextRectItem.Create;
begin
  inherited Create;
  FTextStyleNo := -1;
end;

function THCTextRectItem.GetOffsetAt(const X: Integer): Integer;
begin
  if X < Width div 2 then
    Result := OffsetBefor
  else
    Result := OffsetAfter;
end;

function THCTextRectItem.JustifySplit: Boolean;
begin
  Result := False;
end;

procedure THCTextRectItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FTextStyleNo, SizeOf(FTextStyleNo));
end;

procedure THCTextRectItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FTextStyleNo, SizeOf(FTextStyleNo));
end;

function THCTextRectItem.SelectExists: Boolean;
begin
  Result := ioSelectComplate in Options;
end;

procedure THCTextRectItem.SetTextStyleNo(const Value: Integer);
begin
  if FTextStyleNo <> Value then
    FTextStyleNo := Value;
end;

{ THCDomainItem }

constructor THCDomainItem.Create;
begin
  Width := 0;
  Height := 10;
  inherited Create(Width, Height);
  Self.StyleNo := THCStyle.RsDomain;
  FLevel := 0;
end;

procedure THCDomainItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;
  if not APaintInfo.Print then  // ����[��]
  begin
    if FMarkType = cmtBeg then
    begin
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Color := clActiveBorder;
      ACanvas.MoveTo(ADrawRect.Left + 2, ADrawRect.Top - 1);
      ACanvas.LineTo(ADrawRect.Left, ADrawRect.Top - 1);
      ACanvas.LineTo(ADrawRect.Left, ADrawRect.Bottom + 1);
      ACanvas.LineTo(ADrawRect.Left + 2, ADrawRect.Bottom + 1);
    end
    else
    begin
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Color := clActiveBorder;
      ACanvas.MoveTo(ADrawRect.Right - 2, ADrawRect.Top - 1);
      ACanvas.LineTo(ADrawRect.Right, ADrawRect.Top - 1);
      ACanvas.LineTo(ADrawRect.Right, ADrawRect.Bottom + 1);
      ACanvas.LineTo(ADrawRect.Right - 2, ADrawRect.Bottom + 1);
    end;
  end;
end;

function THCDomainItem.GetOffsetAt(const X: Integer): Integer;
begin
  if (X >= 0) and (X <= Width) then
  begin
    if FMarkType = cmtBeg then
      Result := OffsetAfter
    else
      Result := OffsetBefor;
  end
  else
    Result := inherited GetOffsetAt(X);
end;

function THCDomainItem.JustifySplit: Boolean;
begin
  Result := False;
end;

procedure THCDomainItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FMarkType, SizeOf(FMarkType));
end;

procedure THCDomainItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FMarkType, SizeOf(FMarkType));
end;

end.
