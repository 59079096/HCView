{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
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
  HCStyleMatch, HCStyle, HCCommon, HCCustomData, HCUndo;

const
  /// <summary> �����RectItemǰ�� </summary>
  OffsetBefor = 0;

  /// <summary> �����RectItem������ </summary>
  OffsetInner = 1;

  /// <summary> �����RectItem���� </summary>
  OffsetAfter = 2;

type
  THCCustomRectItem = class(THCCustomItem)  // RectItem����
  strict private
    FWidth, FHeight: Integer;
    FTextWrapping: Boolean;  // �ı�����
    FOwnerData: THCCustomData;
    // ��ʶ�ڲ��߶��Ƿ����˱仯�����ڴ�Item�ڲ���ʽ��ʱ����������Data��ʶ��Ҫ���¸�ʽ����Item
    // �����һ����Ԫ�����ݱ仯��û������������仯ʱ������Ҫ���¸�ʽ�����Ҳ����Ҫ���¼���ҳ��
    // ��ӵ�д�Item��Dataʹ�����Ӧ��������ֵΪFalse���ɲο�TableItem.KeyPress��ʹ��
    FSizeChanged: Boolean;
    FCanPageBreak: Boolean;  // �ڵ�ǰҳ��ʾ����ʱ�Ƿ���Է�ҳ�ض���ʾ
    FOnGetMainUndoList: TGetUndoListEvent;
  protected
    function GetWidth: Integer; virtual;
    procedure SetWidth(const Value: Integer); virtual;
    function GetHeight: Integer; virtual;
    procedure SetHeight(const Value: Integer); virtual;

    // ����������ط���
    procedure DoNewUndo(const Sender: THCUndo); virtual;
    procedure DoUndoDestroy(const Sender: THCUndo); virtual;
    procedure DoUndo(const Sender: THCUndo); virtual;
    procedure DoRedo(const Sender: THCUndo); virtual;
    procedure Undo_StartRecord;
    function GetSelfUndoList: THCUndoList;
  public
    /// <summary> �����ڹ����ڼ䴴�� </summary>
    constructor Create(const AOwnerData: THCCustomData); overload; virtual;
    /// <summary> �����ڼ���ʱ���� </summary>
    constructor Create(const AOwnerData: THCCustomData; const AWidth, AHeight: Integer); overload; virtual;
    // ���󷽷������̳�
    function ApplySelectTextStyle(const AStyle: THCStyle; const AMatchStyle: THCStyleMatch): Integer; virtual;
    procedure ApplySelectParaStyle(const AStyle: THCStyle; const AMatchStyle: THCParaMatch); virtual;

    // ��ǰRectItem��ʽ��ʱ������Data(Ϊ������봫��TCustomRichData����)
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); virtual;

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
    procedure GetCaretInfo(var ACaretInfo: THCCaretInfo); virtual;

    /// <summary> ��ȡ��ָ���߶��ڵĽ���λ�ô����¶�(��ʱû�õ�ע����) </summary>
    /// <param name="AHeight">ָ���ĸ߶ȷ�Χ</param>
    /// <param name="ADItemMostBottom">��׶�DItem�ĵײ�λ��</param>
    //procedure GetPageFmtBottomInfo(const AHeight: Integer; var ADItemMostBottom: Integer); virtual;

    // ׼���жϷ�ҳǰ����������������Լ���¼�ķ�ҳ��Ϣ��׼�����¼����ҳ
    procedure CheckFormatPageBreakBefor; virtual;

    /// <summary> �����ʽ����ķ�ҳλ�� </summary>
    /// <param name="ADrawItemRectTop">��Ӧ��DrawItem��Rect.Top�����м��һ��</param>
    /// <param name="ADrawItemRectBottom">��Ӧ��DrawItem��Rect.Bottom�����м��һ��</param>
    /// <param name="APageDataFmtTop">ҳ����Top</param>
    /// <param name="APageDataFmtBottom">ҳ����Bottom</param>
    /// <param name="AStartSeat">��ʼ�����ҳλ��</param>
    /// <param name="ABreakSeat">��Ҫ��ҳλ��</param>
    /// <param name="AFmtOffset">Ϊ�˱ܿ���ҳλ����������ƫ�Ƶĸ߶�</param>
    /// <param name="AFmtHeightInc">Ϊ�˱ܿ���ҳλ�ø߶�����ֵ</param>
    procedure CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
      ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartSeat: Integer;
      var ABreakSeat, AFmtOffset, AFmtHeightInc: Integer); virtual;

    // �䶯�Ƿ��ڷ�ҳ��
    function ChangeNearPageBreak: Boolean; virtual;

    function InsertItem(const AItem: THCCustomItem): Boolean; virtual;
    function InsertText(const AText: string): Boolean; virtual;
    function InsertGraphic(const AGraphic: TGraphic; const ANewPara: Boolean): Boolean; virtual;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; virtual;

    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;

    /// <summary> �����ۡ���ȫѡ��(�����ڽ�RectItem���ѡ������µ�ѡ���ж�) </summary>
    function IsSelectComplateTheory: Boolean; virtual;

    function SelectExists: Boolean; virtual;

    /// <summary> ��ǰλ�ÿ�ʼ����ָ�������� </summary>
    /// <param name="AKeyword">Ҫ���ҵĹؼ���</param>
    /// <param name="AForward">True����ǰ��False�����</param>
    /// <param name="AMatchCase">True�����ִ�Сд��False�������ִ�Сд</param>
    /// <returns>True���ҵ�</returns>
    function Search(const AKeyword: string; const AForward, AMatchCase: Boolean): Boolean; virtual;

    /// <summary> ��ǰRectItem�Ƿ�����Ҫ�����Data(Ϊ������뷵��TCustomRichData����) </summary>
    function GetActiveData: THCCustomData; virtual;

    /// <summary> ����ָ��λ�ô��Ķ���Data(Ϊ������뷵��TCustomRichData����) </summary>
    function GetTopLevelDataAt(const X, Y: Integer): THCCustomData; virtual;

    procedure TraverseItem(const ATraverse: TItemTraverse); virtual;
    //
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function BreakByOffset(const AOffset: Integer): THCCustomItem; override;
    function CanConcatItems(const AItem: THCCustomItem): Boolean; override;
    procedure Assign(Source: THCCustomItem); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    function GetLength: Integer; override;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property TextWrapping: Boolean read FTextWrapping write FTextWrapping;  // �ı�����
    property SizeChanged: Boolean read FSizeChanged write FSizeChanged;

    /// <summary> �ڵ�ǰҳ��ʾ����ʱ�Ƿ���Է�ҳ�ض���ʾ </summary>
    property CanPageBreak: Boolean read FCanPageBreak write FCanPageBreak;
    property OwnerData: THCCustomData read FOwnerData;
  end;

  THCDomainItemClass = class of THCDomainItem;

  THCDomainItem = class(THCCustomRectItem)  // ��
  private
    FLevel: Byte;
    FMarkType: TMarkType;
  protected
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create(const AOwnerData: THCCustomData); override;
    function GetOffsetAt(const X: Integer): Integer; override;
    function JustifySplit: Boolean; override;
    // ��ǰRectItem��ʽ��ʱ������Data(Ϊ������봫��TCustomRichData����)
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    property MarkType: TMarkType read FMarkType write FMarkType;
    property Level: Byte read FLevel write FLevel;
  end;

  THCTextRectItem = class(THCCustomRectItem)  // ���ı���ʽ��RectItem
  private
    FTextStyleNo: Integer;
  protected
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    procedure SetTextStyleNo(const Value: Integer); virtual;
  public
    constructor Create(const AOwnerData: THCCustomData); override;
    procedure Assign(Source: THCCustomItem); override;
    function GetOffsetAt(const X: Integer): Integer; override;
    function JustifySplit: Boolean; override;
    function ApplySelectTextStyle(const AStyle: THCStyle;
      const AMatchStyle: THCStyleMatch): Integer; override;
    function SelectExists: Boolean; override;
    property TextStyleNo: Integer read FTextStyleNo write SetTextStyleNo;
  end;

  THCControlItem = class(THCTextRectItem)
  private
    FAutoSize: Boolean;  // �Ǹ��������Զ���С�������ⲿָ����С
  protected
    FMargin: Byte;
    FMinWidth, FMinHeight: Integer;
  public
    constructor Create(const AOwnerData: THCCustomData); override;
    procedure Assign(Source: THCCustomItem); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    property AutoSize: Boolean read FAutoSize write FAutoSize;
  end;

  TGripType = (gtNone, gtLeftTop, gtRightTop, gtLeftBottom, gtRightBottom,
    gtLeft, gtTop, gtRight, gtBottom);

  THCResizeRectItem = class(THCCustomRectItem)  // �ɸı��С��RectItem
  private
    FGripSize: Word;  // �϶����С
    FResizing: Boolean;  // �����϶��ı��С
    FCanResize: Boolean;  // ��ǰ�Ƿ��ڿɸı��С״̬
    FResizeGrip: TGripType;
    FResizeRect: TRect;
    FResizeWidth, FResizeHeight: Integer;  // ���ź�Ŀ���
    function GetGripType(const X, Y: Integer): TGripType;
  protected
    FResizeX, FResizeY: Integer;  // �϶�����ʱ��ʼλ��
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    // �����ָ���ط���
    procedure Undo_Resize(const ANewWidth, ANewHeight: Integer);
    procedure DoUndoDestroy(const Sender: THCUndo); override;
    procedure DoUndo(const Sender: THCUndo); override;
    procedure DoRedo(const Sender: THCUndo); override;

    function GetResizing: Boolean; virtual;
    procedure SetResizing(const Value: Boolean); virtual;
    property ResizeGrip: TGripType read FResizeGrip;
    property ResizeRect: TRect read FResizeRect;
  public
    constructor Create(const AOwnerData: THCCustomData); override;
    /// <summary> ��ȡ����X��Y�Ƿ���ѡ�������� </summary>
    function CoordInSelect(const X, Y: Integer): Boolean; override;
    procedure PaintTop(const ACanvas: TCanvas); override;
    // �̳�THCCustomItem���󷽷�
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function CanDrag: Boolean; override;

    /// <summary> ���¹��λ�� </summary>
    procedure GetCaretInfo(var ACaretInfo: THCCaretInfo); override;
    function SelectExists: Boolean; override;

    /// <summary> Լ����ָ����С��Χ�� </summary>
    procedure RestrainSize(const AWidth, AHeight: Integer); virtual;
    property GripSize: Word read FGripSize write FGripSize;
    property Resizing: Boolean read GetResizing write SetResizing;
    property ResizeWidth: Integer read FResizeWidth;
    property ResizeHeight: Integer read FResizeHeight;
    property CanResize: Boolean read FCanResize write FCanResize;
  end;

  THCAnimateRectItem = class(THCCustomRectItem)  // ����RectItem
  public
    function GetOffsetAt(const X: Integer): Integer; override;
  end;

var
  HCDefaultDomainItemClass: THCDomainItemClass = THCDomainItem;

implementation

{ THCCustomRectItem }

procedure THCCustomRectItem.ApplySelectParaStyle(const AStyle: THCStyle;
  const AMatchStyle: THCParaMatch);
begin
end;

function THCCustomRectItem.ApplySelectTextStyle(const AStyle: THCStyle;
  const AMatchStyle: THCStyleMatch): Integer;
begin
end;

procedure THCCustomRectItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  FWidth := (Source as THCCustomRectItem).Width;
  FHeight := (Source as THCCustomRectItem).Height;
end;

function THCCustomRectItem.BreakByOffset(const AOffset: Integer): THCCustomItem;
begin
  Result := nil;
end;

function THCCustomRectItem.CanConcatItems(const AItem: THCCustomItem): Boolean;
begin
  Result := False;
end;

function THCCustomRectItem.ChangeNearPageBreak: Boolean;
begin
  Result := False;  // ����� 201810172235
end;

procedure THCCustomRectItem.CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
  ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartSeat: Integer;
  var ABreakSeat, AFmtOffset, AFmtHeightInc: Integer);
begin
  ABreakSeat := -1;
  AFmtOffset := 0;
  AFmtHeightInc := 0;

  if FCanPageBreak then  // �ɷ�ҳ��ʾ����ǰҳ����һ����
  begin
    ABreakSeat := Height - AStartSeat - (APageDataFmtBottom - ADrawItemRectTop);
    if ADrawItemRectBottom > APageDataFmtBottom then
      AFmtHeightInc := APageDataFmtBottom - ADrawItemRectBottom;
  end
  else  // ����ҳ��ʾ��ƫ�Ƶ���һҳ��ͷ��ʾ
  begin
    ABreakSeat := 0;
    if ADrawItemRectBottom > APageDataFmtBottom then
      AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
  end;
end;

procedure THCCustomRectItem.CheckFormatPageBreakBefor;
begin
end;

function THCCustomRectItem.CoordInSelect(const X, Y: Integer): Boolean;
begin
  Result := False;
end;

constructor THCCustomRectItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create;
  FOwnerData := AOwnerData;
  Self.ParaNo := AOwnerData.Style.CurParaNo;
  FOnGetMainUndoList := (AOwnerData as THCCustomData).OnGetUndoList;
  FWidth := 100;   // Ĭ�ϳߴ�
  FHeight := 50;
  FTextWrapping := False;
  FSizeChanged := False;
  FCanPageBreak := False;
end;

constructor THCCustomRectItem.Create(const AOwnerData: THCCustomData; const AWidth, AHeight: Integer);
begin
  Create(AOwnerData);
  Width := AWidth;
  Height := AHeight;
end;

function THCCustomRectItem.DeleteSelected: Boolean;
begin
  Result := False;
end;

procedure THCCustomRectItem.DoNewUndo(const Sender: THCUndo);
begin
  // Sender.Data�ɰ��Զ���Ķ���
end;

procedure THCCustomRectItem.DoRedo(const Sender: THCUndo);
begin
end;

procedure THCCustomRectItem.DoUndo(const Sender: THCUndo);
begin
end;

procedure THCCustomRectItem.DoUndoDestroy(const Sender: THCUndo);
begin
  if Sender.Data <> nil then
    Sender.Data.Free;
end;

procedure THCCustomRectItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
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

procedure THCCustomRectItem.GetCaretInfo(var ACaretInfo: THCCaretInfo);
begin
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
  if X <= 0 then
    Result := OffsetBefor
  else
  if X >= Width then
    Result := OffsetAfter
  else
    Result := OffsetInner;
end;

function THCCustomRectItem.GetTopLevelDataAt(const X, Y: Integer): THCCustomData;
begin
  Result := nil;
end;

function THCCustomRectItem.GetSelfUndoList: THCUndoList;
var
  vMainUndoList: THCUndoList;
  vItemAction: THCItemSelfUndoAction;
begin
  Result := nil;
  vMainUndoList := FOnGetMainUndoList;
  if vMainUndoList.Last.Actions.Last is THCItemSelfUndoAction then
  begin
    vItemAction := vMainUndoList.Last.Actions.Last as THCItemSelfUndoAction;
    if not Assigned(vItemAction.&Object) then
    begin
      vItemAction.&Object := THCUndoList.Create;
      (vItemAction.&Object as THCUndoList).OnNewUndo := DoNewUndo;
      (vItemAction.&Object as THCUndoList).OnUndo := DoUndo;
      (vItemAction.&Object as THCUndoList).OnRedo := DoRedo;
    end;

    Result := vItemAction.&Object as THCUndoList;
  end;
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

function THCCustomRectItem.IsSelectComplateTheory: Boolean;
begin
  Result := IsSelectComplate or Active;
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

procedure THCCustomRectItem.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  Self.Active := PtInRect(Rect(0, 0, FWidth, FHeight), Point(X, Y));
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

function THCCustomRectItem.Search(const AKeyword: string; const AForward, AMatchCase: Boolean): Boolean;
begin
  Result := False;
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

procedure THCCustomRectItem.Undo_StartRecord;
begin
  if FOwnerData.Style.EnableUndo then
    GetSelfUndoList.NewUndo;
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

constructor THCResizeRectItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  FCanResize := True;
  FGripSize := 8;
end;

procedure THCResizeRectItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
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

procedure THCResizeRectItem.DoRedo(const Sender: THCUndo);
var
  vSizeAction: THCUndoSize;
begin
  if Sender.Data is THCUndoSize then
  begin
    vSizeAction := Sender.Data as THCUndoSize;
    Self.Width := vSizeAction.NewWidth;
    Self.Height := vSizeAction.NewHeight;
  end
  else
    inherited DoRedo(Sender);
end;

procedure THCResizeRectItem.DoUndo(const Sender: THCUndo);
var
  vSizeAction: THCUndoSize;
begin
  if Sender.Data is THCUndoSize then
  begin
    vSizeAction := Sender.Data as THCUndoSize;
    Self.Width := vSizeAction.OldWidth;
    Self.Height := vSizeAction.OldHeight;
  end
  else
    inherited DoUndo(Sender);
end;

procedure THCResizeRectItem.DoUndoDestroy(const Sender: THCUndo);
begin
  if Sender.Data is THCUndoSize then
    (Sender.Data as THCUndoSize).Free;

  inherited DoUndoDestroy(Sender);
end;

procedure THCResizeRectItem.GetCaretInfo(var ACaretInfo: THCCaretInfo);
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
      FResizeWidth := Width;
      FResizeHeight := Height;
    end;
  end;
end;

procedure THCResizeRectItem.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vW, vH, vTempW, vTempH: Integer;
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

      // ��������λ���ڶԽ��ߵĲ�ͬ��λ���㳤��
      case FResizeGrip of
        gtLeftTop:
          begin
            vTempW := Round(vH * vBL);
            vTempH := Round(vW / vBL);
            if vTempW > vW then
              vH := vTempH
            else
              vW := vTempW;

            FResizeWidth := Width - vW;
            FResizeHeight := Height - vH;
          end;

        gtRightTop:
          begin
            vTempW := Abs(Round(vH * vBL));
            vTempH := Abs(Round(vW / vBL));

            if vW < 0 then
            begin
              if vH > vTempH then
                vH := vTempH
              else
              if vH > 0 then
                vW := -vTempW
              else
                vW := vTempW;
            end
            else
            begin
              if -vH < vTempH then
                vH := -vTempH
              else
                vW := vTempW;
            end;

            FResizeWidth := Width + vW;
            FResizeHeight := Height - vH;
          end;

        gtLeftBottom:
          begin
            vTempW := Abs(Round(vH * vBL));
            vTempH := Abs(Round(vW / vBL));

            if vW < 0 then  // ���
            begin
              if vH < vTempH then  // �Խ������棬�����Ժ���Ϊ׼
                vH := vTempH
              else  // �Խ������棬����������Ϊ׼
                vW := -vTempW;
            end
            else  // �Ҳ�
            begin
              if (vW > vTempW) or (vH > vTempH) then  // �Խ������棬����������Ϊ׼
              begin
                if vH < 0 then
                  vW := vTempW
                else
                  vW := -vTempW;
              end
              else  // �Խ������棬�����Ժ���Ϊ׼
                vH := -vTempH;
            end;

            FResizeWidth := Width - vW;
            FResizeHeight := Height + vH;
          end;

        gtRightBottom:
          begin
            vTempW := Round(vH * vBL);
            vTempH := Round(vW / vBL);
            if vTempW > vW then
              vW := vTempW
            else
              vH := vTempH;

            FResizeWidth := Width + vW;
            FResizeHeight := Height + vH;
          end;
      end;
    end
    else  // ��������
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
    FResizing := False;

    if (FResizeWidth < 0) or (FResizeHeight < 0) then Exit;

    Undo_Resize(FResizeWidth, FResizeHeight);
    Width := FResizeWidth;
    Height := FResizeHeight;
  end;
end;

procedure THCResizeRectItem.PaintTop(const ACanvas: TCanvas);
begin
  inherited;
  //ACanvas.DrawFocusRect(ADrawRect);  // �����Ϊɶ����������
  ACanvas.Brush.Style := bsClear;
  ACanvas.Rectangle(FResizeRect);
end;

procedure THCResizeRectItem.RestrainSize(const AWidth, AHeight: Integer);
begin
end;

function THCResizeRectItem.SelectExists: Boolean;
begin
  Result := IsSelectComplateTheory;
end;

procedure THCResizeRectItem.SetResizing(const Value: Boolean);
begin
  if FResizing <> Value then
    FResizing := Value;
end;

procedure THCResizeRectItem.Undo_Resize(const ANewWidth, ANewHeight: Integer);
var
  vUndo: THCUndo;
  vUndoSize: THCUndoSize;
begin
  if OwnerData.Style.EnableUndo then
  begin
    Undo_StartRecord;
    vUndo := GetSelfUndoList.Last;
    if vUndo <> nil then
    begin
      vUndoSize := THCUndoSize.Create;
      vUndoSize.OldWidth := Self.Width;
      vUndoSize.OldHeight := Self.Height;
      vUndoSize.NewWidth := ANewWidth;
      vUndoSize.NewHeight := ANewHeight;

      vUndo.Data := vUndoSize;
    end;
  end;
end;

{ THCTextRectItem }

function THCTextRectItem.ApplySelectTextStyle(const AStyle: THCStyle;
  const AMatchStyle: THCStyleMatch): Integer;
begin
  FTextStyleNo := AMatchStyle.GetMatchStyleNo(AStyle, FTextStyleNo);
  Result := FTextStyleNo;
end;

procedure THCTextRectItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  FTextStyleNo := (Source as THCTextRectItem).TextStyleNo;
end;

constructor THCTextRectItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  if AOwnerData.Style.CurStyleNo > THCStyle.Null then
    FTextStyleNo := AOwnerData.Style.CurStyleNo
  else
    FTextStyleNo := 0;
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

constructor THCDomainItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  Self.StyleNo := THCStyle.Domain;
  FLevel := 0;
  Width := 0;
  Height := 10;
end;

procedure THCDomainItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
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

procedure THCDomainItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
var
  vItem: THCCustomItem;
begin
  Self.Width := 0;
  Self.Height := 5;  // Ĭ�ϴ�С
  if Self.MarkType = TMarkType.cmtBeg then  // ����ʼ��ʶ
  begin
    if AItemNo < ARichData.Items.Count - 1 then  // ����ʱ��������Data����������ʼ�����治һ���н���
    begin
      vItem := ARichData.Items[AItemNo + 1];
      if (vItem.StyleNo = Self.StyleNo)  // ��һ�������ʶ
        and ((vItem as THCDomainItem).MarkType = TMarkType.cmtEnd)  // ��һ���ǽ�����ʶ
      then
        Self.Width := 10  // ���ӿ���Ա�����ʱ���ɷ�����
      else
      if vItem.StyleNo > THCStyle.Null then  // �������ı����������ĸ߶�
      begin
        ARichData.Style.TextStyles[vItem.StyleNo].ApplyStyle(ARichData.Style.DefCanvas);
        Self.Height := ARichData.Style.DefCanvas.TextExtent('H').cy;
      end;
    end
    else
      Self.Width := 10;
  end
  else  // �������ʶ
  begin
    vItem := ARichData.Items[AItemNo - 1];
    if (vItem.StyleNo = Self.StyleNo)
      and ((vItem as THCDomainItem).MarkType = TMarkType.cmtBeg)
    then  // ǰһ������ʼ��ʶ
      Self.Width := 10
    else
    if vItem.StyleNo > THCStyle.Null then  // ǰ�����ı�������ǰ��ĸ߶�
    begin
      ARichData.Style.TextStyles[vItem.StyleNo].ApplyStyle(ARichData.Style.DefCanvas);
      Self.Height := ARichData.Style.DefCanvas.TextExtent('H').cy;
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

{ THCAnimateRectItem }

function THCAnimateRectItem.GetOffsetAt(const X: Integer): Integer;
begin
  if X < Width div 2 then
    Result := OffsetBefor
  else
    Result := OffsetAfter;
end;

{ THCControlItem }

procedure THCControlItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  FAutoSize := (Source as THCControlItem).AutoSize;
end;

constructor THCControlItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  FAutoSize := True;
  FMargin := 5;
  FMinWidth := 20;
  FMinHeight := 10;
end;

procedure THCControlItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FAutoSize, SizeOf(FAutoSize));
end;

procedure THCControlItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FAutoSize, SizeOf(FAutoSize));
end;

end.
