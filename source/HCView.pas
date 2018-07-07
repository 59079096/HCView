{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                 �ĵ����ݰ�ҳ���ֿؼ�                  }
{                                                       }
{*******************************************************}

unit HCView;

interface

uses
  Windows, Classes, Controls, Graphics, Messages, HCStyle, HCCustomData,
  Generics.Collections, HCCommon, HCRichData, HCCustomRichData, HCDrawItem,
  HCSection, HCScrollBar, HCRichScrollBar, HCParaStyle, HCTextStyle, HCRectItem,
  HCTextItem, HCItem, HCUndo;

type
  TPageScrollModel = (psmVertical, psmHorizontal);

  TLoadSectionProc = reference to procedure(const AFileVersion: Word);

  TAnnotation = class(TObject)  // ��ע
  private
    FDrawItemRect, FPaintRect: TRect;
    FText: string;
  public
    property DrawItemRect: TRect read FDrawItemRect write FDrawItemRect;
    property PaintRect: TRect read FPaintRect write FPaintRect;
    property Text: string read FText write FText;
  end;

  TAnnotations = class(TObjectList<TAnnotation>)  // ��עs
  strict private
    FIndex: Integer;
  public
    constructor Create;
    procedure PaintTo(const ACanvas: TCanvas; const ARect: TRect;
      const APaintInfo: TSectionPaintInfo);
    procedure AddAnnotation(const ADrawItemRect: TRect; const AText: string);
    procedure MouseDown(const X, Y: Integer);
  end;

  THCView = class(TCustomControl)
  private
    { Private declarations }
    FFileName: string;
    FStyle: THCStyle;
    FSections: TObjectList<THCSection>;
    FUndoList: THCUndoList;
    FHScrollBar: THCScrollBar;
    FVScrollBar: THCRichScrollBar;
    FDataBmp: TBitmap;  // ������ʾλͼ
    FActiveSectionIndex,
    FDisplayFirstSection, FDisplayLastSection,
    FUpdateCount: Integer;
    FZoom: Single;
    FShowAnnotation: Boolean;  // ��ʾ��ע
    FIsChanged: Boolean;  // �Ƿ����˸ı�
    FAnnotations: TAnnotations;  // ��ע

    FViewModel: TViewModel;  // ������ʾģʽ��ҳ�桢Web
    FPageScrollModel: TPageScrollModel;  // ҳ�������ʾģʽ�����򡢺���
    FCaret: TCaret;
    FOnMouseDown, FOnMouseUp: TMouseEvent;
    FOnCaretChange: TNotifyEvent;
    FOnVerScroll: TNotifyEvent;
    FOnSectionCreateItem, FOnSectionReadOnlySwitch: TNotifyEvent;
    FOnSectionInsertItem: TItemNotifyEvent;
    FOnSectionItemPaintAfter, FOnSectionItemPaintBefor: TItemPaintEvent;

    FOnSectionPaintHeader, FOnSectionPaintFooter, FOnSectionPaintData,
      FOnSectionPaintPage: TSectionPagePaintEvent;

    FOnChange, FOnChangedSwitch: TNotifyEvent;
    //
    function GetDisplayWidth: Integer;
    function GetDisplayHeight: Integer;
    //
    function GetSymmetryMargin: Boolean;
    procedure SetSymmetryMargin(const Value: Boolean);
    procedure DoVScrollChange(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    //
    function NewDefaultSection: THCSection;

    /// <summary> ȫ�����(������˸��ڸ���������Item������ֻ��ǰ��˽��) </summary>
    procedure Clear;

    function GetDisplayRect: TRect;

    /// <summary> ���»�ȡ���λ�� </summary>
    procedure ReBuildCaret(const AScrollBar: Boolean = False);
    procedure GetSectionByCrood(const X, Y: Integer; var ASectionIndex: Integer);
    procedure SetZoom(const Value: Single);

    /// <summary> ɾ����ʹ�õ��ı���ʽ </summary>
    procedure _DeleteUnUsedStyle(const AParts: TSaveParts = [saHeader, saData, saFooter]);

    function GetHScrollValue: Integer;
    function GetVScrollValue: Integer;
    function GetShowLineActiveMark: Boolean;
    function GetShowLineNo: Boolean;
    function GetShowUnderLine: Boolean;
    procedure SetShowLineActiveMark(Value: Boolean);
    procedure SetShowLineNo(Value: Boolean);
    procedure SetShowUnderLine(Value: Boolean);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
    // Imm
    procedure UpdateImmPosition;
  protected
    { Protected declarations }
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure DoCaretChange;
    procedure DoSectionDataChanged(Sender: TObject);

    // ���ػ���ؽ���꣬������Change�¼�
    procedure DoSectionDataCheckUpdateInfo(Sender: TObject);
    procedure DoLoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const ALoadSectionProc: TLoadSectionProc);

    procedure DoNewUndo(const Sender: THCUndo);
    procedure DoUndo(const Sender: THCUndo);
    procedure DoRedo(const Sender: THCUndo);

    /// <summary> �ĵ�"����"�䶯(�����ޱ仯����ԳƱ߾࣬������ͼ) </summary>
    procedure DoMapChanged;
    procedure DoChange; virtual;
    procedure DoSectionCreateItem(Sender: TObject);
    procedure DoSectionReadOnlySwitch(Sender: TObject);
    procedure DoSectionInsertItem(const AItem: THCCustomItem);
    procedure DoSectionItemPaintBefor(const AData: THCCustomData;
      const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure DoSectionItemPaintAfter(const AData: THCCustomData;
      const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); virtual;

    procedure DoSectionPaintHeader(Sender: THCSection; const APageIndex: Integer;
      const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    procedure DoSectionPaintFooter(Sender: THCSection; const APageIndex: Integer;
      const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    procedure DoSectionPaintData(Sender: THCSection; const APageIndex: Integer;
      const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    procedure DoSectionPaintPage(Sender: THCSection; const APageIndex: Integer;
      const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    function DoSectionGetUndoList: THCUndoList;

    procedure DoStyleInvalidateRect(const ARect: TRect);

    /// <summary>
    /// �Ƿ��������뷨����Ĵ���������ID�ʹ���
    /// </summary>
    /// <param name="ACandiID">����ID</param>
    /// <param name="ACandi">����</param>
    /// <returns></returns>
    function DoProcessIMECandi(const ACandi: string): Boolean; virtual;
    /// <summary> ����ǰ�����ڶ�������������������Դ </summary>
    procedure DoCopyDataBefor(const AStream: TStream); virtual;

    /// <summary> ճ��ǰ������ȷ�϶�������������������Դ </summary>
    procedure DoPasteDataBefor(const AStream: TStream; const AVersion: Word); virtual;

    /// <summary> �����ĵ�ǰ�����¼������ڶ����������� </summary>
    procedure DoSaveBefor(const AStream: TStream); virtual;

    /// <summary> �����ĵ��󴥷��¼������ڶ����������� </summary>
    procedure DoSaveAfter(const AStream: TStream); virtual;

    /// <summary> ��ȡ�ĵ�ǰ�����¼�������ȷ�϶����������� </summary>
    procedure DoLoadBefor(const AStream: TStream; const AFileVersion: Word); virtual;

    /// <summary> ��ȡ�ĵ��󴥷��¼�������ȷ�϶����������� </summary>
    procedure DoLoadAfter(const AStream: TStream; const AFileVersion: Word); virtual;
    //
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    // ��Ϣ
    /// <summary> ��ӦTab���ͷ���� </summary>
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMERASEBKGND(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;

    // �������뷨���������
    procedure WMImeComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    procedure WndProc(var Message: TMessage); override;
    //
    procedure CalcScrollRang;

    /// <summary> �Ƿ��ɹ�����λ�ñ仯����ĸ��� </summary>
    procedure CheckUpdateInfo(const AScrollBar: Boolean = False);
    //
    procedure SetPageScrollModel(const Value: TPageScrollModel);
    procedure SetViewModel(const Value: TViewModel);
    procedure SetShowAnnotation(const Value: Boolean);
    procedure SetActiveSectionIndex(const Value: Integer);
    //
    procedure SetIsChanged(const Value: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    /// <summary> �޸�ֽ�ű߾� </summary>
    procedure ReMarginPaper;

    /// <summary> ȫ����յ���ӿ��ı�Item </summary>
    procedure ClearData;
    procedure DisSelect;
    procedure DeleteSelected;
    procedure DeleteSection;
    procedure FormatData;

    function InsertStream(const AStream: TStream): Boolean;
    function InsertText(const AText: string): Boolean;
    function InsertTable(const ARowCount, AColCount: Integer): Boolean;
    function InsertLine(const ALineHeight: Integer): Boolean;
    function InsertItem(const AItem: THCCustomItem): Boolean; overload;
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem): Boolean; overload;

    /// <summary> �ӵ�ǰλ�ú��� </summary>
    function InsertBreak: Boolean;

    /// <summary> �ӵ�ǰλ�ú��ҳ </summary>
    function InsertPageBreak: Boolean;

    /// <summary> �ӵ�ǰλ�ú�ֽ� </summary>
    function InsertSectionBreak: Boolean;

    // ����������
    function ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
    function ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
    function ActiveTableDeleteCurRow: Boolean;
    function ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
    function ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
    function ActiveTableDeleteCurCol: Boolean;
    //
    procedure ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
    procedure ApplyParaAlignVert(const AAlign: TParaAlignVert);
    procedure ApplyParaBackColor(const AColor: TColor);
    procedure ApplyParaLineSpace(const ASpace: Integer);
    procedure ApplyTextStyle(const AFontStyle: TFontStyleEx);
    procedure ApplyTextFontName(const AFontName: TFontName);
    procedure ApplyTextFontSize(const AFontSize: Integer);
    procedure ApplyTextColor(const AColor: TColor);
    procedure ApplyTextBackColor(const AColor: TColor);

    procedure SelectAll;
    procedure Cut;
    procedure Copy;
    procedure CopyAsText;
    procedure Paste;
    function ZoomIn(const Value: Integer): Integer;
    function ZoomOut(const Value: Integer): Integer;
    //
    procedure UpdateBuffer; overload;
    procedure UpdateBuffer(const ARect: TRect); overload;
    procedure BeginUpdate;
    procedure EndUpdate;
    //
    function GetCurItem: THCCustomItem;
    function GetActiveItem: THCCustomItem;
    function GetActiveDrawItem: THCCustomDrawItem;
    function GetActivePageIndex: Integer;
    function GetPagePreviewFirst: Integer;
    function GetPageCount: Integer;
    function GetSectionDrawLeft(const ASectionNo: Integer): Integer;

    procedure FormatSection(const ASectionNo: Integer);

    /// <summary>
    /// ��ȡָ����ҳü����ʵ�ʸ�(���ݸ߶�>�ϱ߾�ʱȡ���ݸ߶�)
    /// </summary>
    /// <param name="ASectionNo">ҳü���</param>
    /// <returns></returns>
    //function GetHeaderAreaHeight(const ASectionIndex: Integer): Integer;
    function ActiveSection: THCSection;

    /// <summary> �������������е�Topλ�� </summary>
    /// <param name="ASectionIndex"></param>
    /// <returns></returns>
    function GetSectionTopFilm(const ASectionIndex: Integer): Integer;
    // �����ĵ�
    procedure SaveToText(const AFileName: string);
    procedure SaveToBitmap(const AFileName: string);
    procedure SaveToFile(const AFileName: string);

    /// <summary> �������ݵ��� </summary>
    procedure SaveToStream(const AStream: TStream;
      const ASaveParts: TSaveParts = [saHeader, saData, saFooter]); virtual;
    // ��ȡ�ĵ�
    procedure LoadFromText(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(const AStream: TStream); virtual;
    //
    function Print(const APrinter: string): TPrintResult;
    function PrintPageRang(const AStartPageNo, AEndPageNo: Integer): TPrintResult;
    function MergeTableSelectCells: Boolean;
    procedure Undo;
    procedure Redo;
    //
    property FileName: string read FFileName write FFileName;
    property Style: THCStyle read FStyle;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    property SymmetryMargin: Boolean read GetSymmetryMargin write SetSymmetryMargin;
    property ActivePageIndex: Integer read GetActivePageIndex;
    property PagePreviewFirst: Integer read GetPagePreviewFirst;
    property PageCount: Integer read GetPageCount;
    property ActiveSectionIndex: Integer read FActiveSectionIndex write SetActiveSectionIndex;
    property HScrollValue: Integer read GetHScrollValue;
    property VScrollValue: Integer read GetVScrollValue;
    property Zoom: Single read FZoom write SetZoom;
    property Sections: TObjectList<THCSection> read FSections;
    property ShowLineActiveMark: Boolean read GetShowLineActiveMark write SetShowLineActiveMark;
    property ShowLineNo: Boolean read GetShowLineNo write SetShowLineNo;
    property ShowUnderLine: Boolean read GetShowUnderLine write SetShowUnderLine;
    property IsChanged: Boolean read FIsChanged write SetIsChanged;
    property Annotations: TAnnotations read FAnnotations;
  published
    { Published declarations }
    property OnSectionCreateItem: TNotifyEvent read FOnSectionCreateItem write FOnSectionCreateItem;
    property OnSectionItemInsert: TItemNotifyEvent read FOnSectionInsertItem write FOnSectionInsertItem;
    property OnSectionItemPaintAfter: TItemPaintEvent read FOnSectionItemPaintAfter write FOnSectionItemPaintAfter;
    property OnSectionItemPaintBefor: TItemPaintEvent read FOnSectionItemPaintBefor write FOnSectionItemPaintBefor;
    property OnSectionPaintHeader: TSectionPagePaintEvent read FOnSectionPaintHeader write FOnSectionPaintHeader;
    property OnSectionPaintFooter: TSectionPagePaintEvent read FOnSectionPaintFooter write FOnSectionPaintFooter;
    property OnSectionPaintData: TSectionPagePaintEvent read FOnSectionPaintData write FOnSectionPaintData;
    property OnSectionPaintPage: TSectionPagePaintEvent read FOnSectionPaintPage write FOnSectionPaintPage;
    property OnSectionReadOnlySwitch: TNotifyEvent read FOnSectionReadOnlySwitch write FOnSectionReadOnlySwitch;
    //
    property PageScrollModel: TPageScrollModel read FPageScrollModel write SetPageScrollModel;
    property ViewModel: TViewModel read FViewModel write SetViewModel;

    /// <summary> �Ƿ���ʾ��ע </summary>
    property ShowAnnotation: Boolean read FShowAnnotation write SetShowAnnotation;

    /// <summary> ����Section�Ƿ�ֻ�� </summary>
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnCaretChange: TNotifyEvent read FOnCaretChange write FOnCaretChange;
    property OnVerScroll: TNotifyEvent read FOnVerScroll write FOnVerScroll;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChangedSwitch: TNotifyEvent read FOnChangedSwitch write FOnChangedSwitch;
    property PopupMenu;
  end;

//procedure Register;

implementation

uses
  Printers, Imm, SysUtils, Forms, Math, Clipbrd, HCImageItem;

const
  IMN_UPDATECURSTRING = $F000;  // �����뷨��������ǰ��괦���ַ���

{procedure Register;
begin
  RegisterComponents('HCControl', [THCView]);
end;  }

{ THCView }

procedure THCView.ApplyTextStyle(const AFontStyle: TFontStyleEx);
begin
  ActiveSection.ApplyTextStyle(AFontStyle);
end;

procedure THCView.ApplyTextBackColor(const AColor: TColor);
begin
  ActiveSection.ApplyTextBackColor(AColor);
end;

procedure THCView.ApplyTextColor(const AColor: TColor);
begin
  ActiveSection.ApplyTextColor(AColor);
end;

procedure THCView.ApplyTextFontName(const AFontName: TFontName);
begin
  ActiveSection.ApplyTextFontName(AFontName);
end;

procedure THCView.ApplyTextFontSize(const AFontSize: Integer);
begin
  ActiveSection.ApplyTextFontSize(AFontSize);
end;

procedure THCView.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure THCView.CalcScrollRang;
var
  i, vWidth, vVMax, vHMax: Integer;
begin
  vVMax := 0;
  vHMax := FSections[0].PageWidthPix;
  for i := 0 to FSections.Count - 1 do
  begin
    vVMax := vVMax + FSections[i].GetFilmHeight;

    vWidth := FSections[i].PageWidthPix;

    if vWidth > vHMax then
      vHMax := vWidth;
  end;

  if FShowAnnotation then
    vHMax := vHMax + AnnotationWidth;

  vVMax := ZoomIn(vVMax + MinPadding);
  vHMax := ZoomIn(vHMax + MinPadding + MinPadding);

  FVScrollBar.Max := vVMax;
  FHScrollBar.Max := vHMax;
end;

procedure THCView.CheckUpdateInfo(const AScrollBar: Boolean = False);
begin
  if (FCaret <> nil) and FStyle.UpdateInfo.ReCaret then  // �ȴ����꣬��Ϊ���ܹ�괦��Щ��Ҫ�����ػ�
  begin
    FStyle.UpdateInfo.ReCaret := False;
    ReBuildCaret(AScrollBar);
    FStyle.UpdateInfo.ReStyle := False;
    FStyle.UpdateInfo.ReScroll := False;
    UpdateImmPosition;
  end;

  if FStyle.UpdateInfo.RePaint then
  begin
    FStyle.UpdateInfo.RePaint := False;
    UpdateBuffer;
  end;
end;

procedure THCView.Clear;
begin
  FSections.DeleteRange(1, FSections.Count - 1);
  FSections[0].Clear;
  FStyle.Initialize;
  FUndoList.Clear;
  FHScrollBar.Position := 0;
  FVScrollBar.Position := 0;
end;

procedure THCView.ClearData;
begin
  Clear;
  FFileName := '';
  FActiveSectionIndex := 0;
  FSections[0].SetEmptyData;
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret;

  DoMapChanged;
end;

procedure THCView.Copy;
var
  vStream: TMemoryStream;
  vMem: Cardinal;
  vPtr: Pointer;
begin
  if ActiveSection.SelectExists then
  begin
    vStream := TMemoryStream.Create;
    try
      _SaveFileFormatAndVersion(vStream);  // �����ļ���ʽ�Ͱ汾
      DoCopyDataBefor(vStream);  // ֪ͨ�����¼�
      _DeleteUnUsedStyle;  // ������ʹ�õ���ʽ
      FStyle.SaveToStream(vStream);
      ActiveSection.ActiveData.GetTopLevelData.SaveSelectToStream(vStream);
      vMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, vStream.Size);
      if vMem = 0 then
        raise Exception.Create(HCS_EXCEPTION_MEMORYLESS);
      vPtr := GlobalLock(vMem);
      Move(vStream.Memory^, vPtr^, vStream.Size);
      GlobalUnlock(vMem);
    finally
      vStream.Free;
    end;
    
    Clipboard.Clear;
    Clipboard.Open;
    try
      Clipboard.SetAsHandle(HC_FILEFORMAT, vMem);
    finally
      Clipboard.Close;
    end;
  end;
end;

procedure THCView.CopyAsText;
begin
  Clipboard.AsText := ActiveSection.ActiveData.GetTopLevelData.SaveSelectToText;
end;

constructor THCView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //
  FUndoList := THCUndoList.Create;
  FUndoList.OnUndo := DoUndo;
  FUndoList.OnRedo := DoRedo;
  FUndoList.OnNewUndo := DoNewUndo;

  FFileName := 'δ����';
  FIsChanged := False;
  FZoom := 1;
  FShowAnnotation := False;
  FViewModel := vmPage;
  FPageScrollModel := psmVertical;  //psmHorizontal;

  FDataBmp := TBitmap.Create;
  FStyle := THCStyle.CreateEx(True, True);
  FStyle.OnInvalidateRect := DoStyleInvalidateRect;
  FSections := TObjectList<THCSection>.Create;
  FSections.Add(NewDefaultSection);
  FActiveSectionIndex := 0;
  FDisplayFirstSection := 0;
  FDisplayLastSection := 0;
  // ��ֱ����������Χ��Resize������
  FVScrollBar := THCRichScrollBar.Create(Self);
  FVScrollBar.Parent := Self;
  FVScrollBar.Orientation := TOrientation.oriVertical;
  FVScrollBar.OnScroll := DoVScrollChange;
  // ˮƽ����������Χ��Resize������
  FHScrollBar := THCScrollBar.Create(Self);
  FHScrollBar.Parent := Self;
  FHScrollBar.Orientation := TOrientation.oriHorizontal;
  FHScrollBar.OnScroll := DoVScrollChange;

  CalcScrollRang;
end;

procedure THCView.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
    FCaret := TCaret.Create(Handle);
end;

procedure THCView.Cut;
begin
  Copy;
  ActiveSection.DeleteSelected;
end;

function THCView.ActiveSection: THCSection;
begin
  Result := FSections[FActiveSectionIndex];
end;

procedure THCView.DeleteSection;
begin
  if FActiveSectionIndex > 0 then
  begin
    FSections.Delete(FActiveSectionIndex);
    FActiveSectionIndex := FActiveSectionIndex - 1;
    FDisplayFirstSection := -1;
    FDisplayLastSection := -1;
    FStyle.UpdateInfoRePaint;
    FStyle.UpdateInfoReCaret;

    DoChange;
  end;
end;

procedure THCView.DeleteSelected;
begin
  ActiveSection.DeleteSelected;
end;

destructor THCView.Destroy;
begin
  if Assigned(FAnnotations) then
    FreeAndNil(FAnnotations);

  FreeAndNil(FSections);
  FreeAndNil(FCaret);
  FreeAndNil(FHScrollBar);
  FreeAndNil(FVScrollBar);
  FreeAndNil(FDataBmp);
  FreeAndNil(FStyle);
  FreeAndNil(FUndoList);
  inherited Destroy;
end;

procedure THCView.DisSelect;
begin
  ActiveSection.DisSelect;
  //DoMapChanged;
  DoSectionDataCheckUpdateInfo(Self);
end;

function THCView.GetDisplayHeight: Integer;
begin
  if FHScrollBar.Visible then
    Result := Height - FHScrollBar.Height
  else
    Result := Height;
end;

function THCView.GetDisplayRect: TRect;
begin
  Result := Bounds(0, 0, GetDisplayWidth, GetDisplayHeight);
end;

function THCView.GetDisplayWidth: Integer;
begin
  if FVScrollBar.Visible then
    Result := Width - FVScrollBar.Width
  else
    Result := Width;
end;

function THCView.GetHScrollValue: Integer;
begin
  Result := FHScrollBar.Position;
end;

procedure THCView.DoMapChanged;
begin
  if FUpdateCount = 0 then
  begin
    CalcScrollRang;
    CheckUpdateInfo;
  end;
end;

function THCView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  if FPageScrollModel = psmVertical then
    FVScrollBar.Position := FVScrollBar.Position - WheelDelta div 1
  else
    FHScrollBar.Position := FHScrollBar.Position - WheelDelta div 1;
  Result := True;
end;

procedure THCView.DoNewUndo(const Sender: THCUndo);
begin
  Sender.SectionIndex := FActiveSectionIndex;
  Sender.Data := ActiveSection.ActiveData;
end;

procedure THCView.DoSectionPaintData(Sender: THCSection;
  const APageIndex: Integer; const ARect: TRect; const ACanvas: TCanvas;
  const APaintInfo: TSectionPaintInfo);
begin
  if Assigned(FOnSectionPaintData) then
    FOnSectionPaintData(Sender, APageIndex, ARect, ACanvas, APaintInfo);
end;

procedure THCView.DoSectionPaintFooter(Sender: THCSection;
  const APageIndex: Integer; const ARect: TRect; const ACanvas: TCanvas;
  const APaintInfo: TSectionPaintInfo);
var
  i, vSectionStartPageIndex, vSectionIndex, vAllPageCount: Integer;
  vS: string;
begin
  if Sender.PageNoVisible then  // ��ʾҳ��
  begin
    vSectionIndex := FSections.IndexOf(Sender);
    vSectionStartPageIndex := 0;
    vAllPageCount := 0;
    for i := 0 to FSections.Count - 1 do
    begin
      if i = vSectionIndex then
        vSectionStartPageIndex := vAllPageCount;

      vAllPageCount := vAllPageCount + FSections[i].PageCount;
    end;
    vS := Format('%d/%d', [vSectionStartPageIndex + Sender.PageNoFrom + APageIndex, vAllPageCount]);
    ACanvas.Brush.Style := bsClear;
    ACanvas.TextOut(ARect.Left + (ARect.Width - ACanvas.TextWidth(vS)) div 2, ARect.Top, vS);
  end;

  if Assigned(FOnSectionPaintFooter) then
    FOnSectionPaintFooter(Sender, APageIndex, ARect, ACanvas, APaintInfo);
end;

procedure THCView.DoSectionPaintHeader(Sender: THCSection;
  const APageIndex: Integer; const ARect: TRect; const ACanvas: TCanvas;
  const APaintInfo: TSectionPaintInfo);
begin
  if Assigned(FOnSectionPaintHeader) then
    FOnSectionPaintHeader(Sender, APageIndex, ARect, ACanvas, APaintInfo);
end;

procedure THCView.DoSectionPaintPage(Sender: THCSection; const APageIndex: Integer;
  const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
begin
  if FShowAnnotation then  // ������ע
    FAnnotations.PaintTo(ACanvas, ARect, APaintInfo);

  if Assigned(FOnSectionPaintPage) then
    FOnSectionPaintPage(Sender, APageIndex, ARect, ACanvas, APaintInfo);
end;

procedure THCView.DoSectionReadOnlySwitch(Sender: TObject);
begin
  if Assigned(FOnSectionReadOnlySwitch) then
    FOnSectionReadOnlySwitch(Sender);
end;

function THCView.DoSectionGetUndoList: THCUndoList;
begin
  Result := FUndoList;// THCUndo.Create;
end;

procedure THCView.DoPasteDataBefor(const AStream: TStream; const AVersion: Word);
begin
end;

function THCView.DoProcessIMECandi(const ACandi: string): Boolean;
begin
  Result := False;
end;

procedure THCView.DoRedo(const Sender: THCUndo);
begin
  if FActiveSectionIndex <> Sender.SectionIndex then
    SetActiveSectionIndex(Sender.SectionIndex);

  ActiveSection.Redo(Sender);
end;

procedure THCView.DoSaveAfter(const AStream: TStream);
begin
  SetIsChanged(False);
end;

procedure THCView.DoSaveBefor(const AStream: TStream);
begin
  // �����ⲿ����洢�Զ������ݣ����ϴ����λ�õ�
end;

procedure THCView.DoSectionCreateItem(Sender: TObject);
begin
  if Assigned(FOnSectionCreateItem) then
    FOnSectionCreateItem(Sender);
end;

procedure THCView.DoSectionDataChanged(Sender: TObject);
begin
  DoChange;
end;

procedure THCView.DoSectionDataCheckUpdateInfo(Sender: TObject);
begin
  if FUpdateCount = 0 then
    CheckUpdateInfo;
end;

procedure THCView.DoCaretChange;
begin
  if Assigned(FOnCaretChange) then
    FOnCaretChange(Self);
end;

procedure THCView.DoChange;
begin
  SetIsChanged(True);
  DoMapChanged;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure THCView.DoCopyDataBefor(const AStream: TStream);
begin
end;

procedure THCView.DoLoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const ALoadSectionProc: TLoadSectionProc);
var
  vFileExt, vFileVersion: string;
  viVersion: Word;
begin
  AStream.Position := 0;
  _LoadFileFormatAndVersion(AStream, vFileExt, vFileVersion);  // �ļ���ʽ�Ͱ汾
  if (vFileExt <> HC_EXT) and (vFileExt <> 'cff.') then
    raise Exception.Create('����ʧ�ܣ�����' + HC_EXT + '�ļ���');

  viVersion := GetVersionAsInteger(vFileVersion);

  DoLoadBefor(AStream, viVersion);  // ��������ǰ�¼�
  AStyle.LoadFromStream(AStream, viVersion);  // ������ʽ��
  ALoadSectionProc(viVersion);  // ���ؽ�������������
  DoMapChanged;
end;

procedure THCView.DoSectionInsertItem(const AItem: THCCustomItem);
begin
  if Assigned(FOnSectionInsertItem) then
    FOnSectionInsertItem(AItem);
end;

procedure THCView.DoSectionItemPaintAfter(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  if Assigned(FOnSectionItemPaintAfter) then
  begin
    FOnSectionItemPaintAfter(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCView.DoSectionItemPaintBefor(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  if Assigned(FOnSectionItemPaintBefor) then
  begin
    FOnSectionItemPaintBefor(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCView.DoStyleInvalidateRect(const ARect: TRect);
begin
  UpdateBuffer(ARect);
end;

procedure THCView.DoUndo(const Sender: THCUndo);
begin
  if FActiveSectionIndex <> Sender.SectionIndex then
    SetActiveSectionIndex(Sender.SectionIndex);

  ActiveSection.Undo(Sender);
end;

procedure THCView.DoLoadAfter(const AStream: TStream; const AFileVersion: Word);
begin
end;

procedure THCView.DoLoadBefor(const AStream: TStream; const AFileVersion: Word);
begin
end;

procedure THCView.EndUpdate;
begin
  Dec(FUpdateCount);
  DoMapChanged;
end;

procedure THCView.FormatData;
var
  i: Integer;
begin
  for i := 0 to Sections.Count - 1 do
    Sections[i].FormatData;

  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret;
  DoMapChanged;
end;

function THCView.GetActiveDrawItem: THCCustomDrawItem;
begin
  Result := ActiveSection.GetActiveDrawItem;
end;

function THCView.GetActiveItem: THCCustomItem;
begin
  Result := ActiveSection.GetActiveItem;
end;

function THCView.GetActivePageIndex: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FActiveSectionIndex - 1 do
    Result := Result + FSections[i].PageCount;

  Result := Result + ActiveSection.ActivePageIndex;
end;

function THCView.GetCurItem: THCCustomItem;
begin
  Result := ActiveSection.GetCurItem;
end;

procedure THCView.GetSectionByCrood(const X, Y: Integer;
  var ASectionIndex: Integer);
var
  i, vY: Integer;
begin
  ASectionIndex := -1;
  vY := 0;
  for i := 0 to FSections.Count - 1 do
  begin
    vY := vY + FSections[i].GetFilmHeight;
    if vY > Y then
    begin
      ASectionIndex := i;
      Break;
    end;
  end;
  if (ASectionIndex < 0) and (vY + MinPadding >= Y) then  // ���һҳ�����Padding
    ASectionIndex := FSections.Count - 1;

  Assert(ASectionIndex >= 0, 'û�л�ȡ����ȷ�Ľ���ţ�');
end;

function THCView.GetSectionDrawLeft(const ASectionNo: Integer): Integer;
begin
  if FShowAnnotation then  // ��ʾ��ע
    Result := Max((GetDisplayWidth - ZoomIn(FSections[ASectionNo].PageWidthPix + AnnotationWidth)) div 2, MinPadding)
  else
    Result := Max((GetDisplayWidth - ZoomIn(FSections[ASectionNo].PageWidthPix)) div 2, MinPadding);
  Result := ZoomOut(Result);
end;

function THCView.GetSectionTopFilm(const ASectionIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to ASectionIndex - 1 do
    Result := Result + FSections[i].GetFilmHeight;
end;

function THCView.GetShowLineActiveMark: Boolean;
begin
  Result := FSections[0].PageData.ShowLineActiveMark;
end;

function THCView.GetShowLineNo: Boolean;
begin
  Result := FSections[0].PageData.ShowLineNo;
end;

function THCView.GetShowUnderLine: Boolean;
begin
  Result := FSections[0].PageData.ShowUnderLine;
end;

function THCView.GetSymmetryMargin: Boolean;
begin
  Result := ActiveSection.SymmetryMargin;
end;

function THCView.GetVScrollValue: Integer;
begin
  Result := FVScrollBar.Position;
end;

function THCView.InsertBreak: Boolean;
begin
  Result := Self.ActiveSection.InsertBreak;
end;

function THCView.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveSection.InsertItem(AIndex, AItem);
end;

function THCView.InsertItem(const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveSection.InsertItem(AItem);
end;

function THCView.InsertLine(const ALineHeight: Integer): Boolean;
begin
  Result := ActiveSection.InsertLine(ALineHeight);
end;

function THCView.InsertPageBreak: Boolean;
begin
  Result := Self.ActiveSection.InsertPageBreak;
end;

function THCView.InsertSectionBreak: Boolean;
var
  vSection: THCSection;
begin
  Result := False;
  vSection := NewDefaultSection;
  FSections.Insert(FActiveSectionIndex + 1, vSection);
  FActiveSectionIndex := FActiveSectionIndex + 1;
  Result := True;
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret;
  DoChange;
end;

function THCView.InsertStream(const AStream: TStream): Boolean;
var
  vStyle: THCStyle;
begin
  Result := False;

  vStyle := THCStyle.Create;
  try
    DoLoadFromStream(AStream, vStyle, procedure(const AFileVersion: Word)
      var
        vByte: Byte;
        vSection: THCSection;
        vShowUnderLine: Boolean;  // �»���
        vDataStream: TMemoryStream;
      begin
        AStream.ReadBuffer(vByte, 1);  // ������

        vDataStream := TMemoryStream.Create;
        try
          vSection := THCSection.Create(vStyle);
          try
            // ��ѭ����ֻ�����һ�ڵ�����
            vSection.LoadFromStream(AStream, vStyle, AFileVersion);
            vDataStream.Clear;
            vSection.PageData.SaveToStream(vDataStream);
            vDataStream.Position := 0;
            vDataStream.ReadBuffer(vShowUnderLine, SizeOf(vShowUnderLine));
            ActiveSection.InsertStream(vDataStream, vStyle, AFileVersion);  // ֻ�����һ�ڵ�����
          finally
            FreeAndNil(vSection);
          end;
        finally
          FreeAndNil(vDataStream);
        end;
      end);
  finally
    FreeAndNil(vStyle);
  end;
end;

function THCView.ActiveTableDeleteCurCol: Boolean;
begin
  Result := ActiveSection.ActiveTableDeleteCurCol;
end;

function THCView.ActiveTableDeleteCurRow: Boolean;
begin
  Result := ActiveSection.ActiveTableDeleteCurRow;
end;

function THCView.ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
begin
  Result := ActiveSection.ActiveTableInsertColAfter(AColCount);
end;

function THCView.ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
begin
  Result := ActiveSection.ActiveTableInsertColBefor(AColCount);
end;

function THCView.ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
begin
  Result := ActiveSection.ActiveTableInsertRowAfter(ARowCount);
end;

function THCView.ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
begin
  Result := ActiveSection.ActiveTableInsertRowBefor(ARowCount);
end;

function THCView.InsertTable(const ARowCount, AColCount: Integer): Boolean;
begin
  Self.BeginUpdate;
  try
    Result := ActiveSection.InsertTable(ARowCount, AColCount);
  finally
    Self.EndUpdate
  end;
end;

function THCView.InsertText(const AText: string): Boolean;
begin
  Self.BeginUpdate;
  try
    Result := ActiveSection.InsertText(AText);
  finally
    Self.EndUpdate;
  end;
end;

procedure THCView.KeyDown(var Key: Word; Shift: TShiftState);

  {$REGION '��ݼ�'}
  function IsCopyShortKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('C'));
  end;

  function IsCopyTextShortKey: Boolean;
  begin
    Result := (Shift = [ssCtrl, ssShift]) and (Key = ord('C'));
  end;

  function IsCutShortKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('X'));
  end;

  function IsPasteShortKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('V'));
  end;

  function IsSelectAllShortKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('A'));
  end;

  function IsUndoKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('Z'));
  end;

  function IsRedoKey: Boolean;
  begin
    Result := (Shift = [ssCtrl]) and (Key = ord('Y'));
  end;
  {$ENDREGION}

begin
  inherited;
  if IsCopyTextShortKey then
    Self.CopyAsText
  else
  if IsCopyShortKey then
    Self.Copy
  else
  if IsCutShortKey then
    Self.Cut
  else
  if IsPasteShortKey then
    Self.Paste
  else
  if IsSelectAllShortKey then
    Self.SelectAll
  else
  if IsUndoKey then
    Self.Undo
  else
  if IsRedoKey then
    Self.Redo
  else
    ActiveSection.KeyDown(Key, Shift);
end;

procedure THCView.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  ActiveSection.KeyPress(Key);
end;

procedure THCView.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  ActiveSection.KeyUp(Key, Shift);
end;

procedure THCView.LoadFromFile(const AFileName: string);
var
  vStream: TStream;
begin
  vStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(vStream);
  finally
    FreeAndNil(vStream);
  end;
end;

procedure THCView.LoadFromStream(const AStream: TStream);
var
  vByte: Byte;
  vSection: THCSection;
begin
  Self.Clear;
  AStream.Position := 0;
  DoLoadFromStream(AStream, FStyle, procedure(const AFileVersion: Word)
    var
      i: Integer;
    begin
      AStream.ReadBuffer(vByte, 1);  // ������
      // ��������
      FSections[0].LoadFromStream(AStream, FStyle, AFileVersion);
      for i := 1 to vByte - 1 do
      begin
        vSection := NewDefaultSection;
        vSection.LoadFromStream(AStream, FStyle, AFileVersion);
        FSections.Add(vSection);
      end;
    end);
end;

procedure THCView.LoadFromText(const AFileName: string);
begin
  Self.Clear;
  FStyle.Initialize;
  ActiveSection.LoadFromText(AFileName, TEncoding.ASCII);
end;

function THCView.MergeTableSelectCells: Boolean;
begin
  Result := ActiveSection.MergeTableSelectCells;
end;

procedure THCView.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vSectionIndex, vSectionDrawLeft: Integer;
  vPt: TPoint;
begin
  inherited;
  GetSectionByCrood(ZoomOut(FHScrollBar.Position + X), ZoomOut(FVScrollBar.Position + Y), vSectionIndex);
  if vSectionIndex <> FActiveSectionIndex then
    SetActiveSectionIndex(vSectionIndex);
  if FActiveSectionIndex < 0 then Exit;

  vSectionDrawLeft := GetSectionDrawLeft(FActiveSectionIndex);

  if FShowAnnotation then  // ��ע����ʾ
  begin
    if (X > vSectionDrawLeft + FSections[FActiveSectionIndex].PageWidthPix)
      and (X < vSectionDrawLeft + FSections[FActiveSectionIndex].PageWidthPix + AnnotationWidth)
    then  // ������ע������
    begin
      FAnnotations.MouseDown(X, Y);
      FStyle.UpdateInfoRePaint;
      DoSectionDataCheckUpdateInfo(Self);
      Exit;
    end;
  end;

  // ӳ�䵽��ҳ��(��ɫ����)
  vPt.X := ZoomOut(FHScrollBar.Position + X) - vSectionDrawLeft;
  vPt.Y := ZoomOut(FVScrollBar.Position + Y) - GetSectionTopFilm(FActiveSectionIndex);
  //vPageIndex := FSections[FActiveSectionIndex].GetPageByFilm(vPt.Y);
  FSections[FActiveSectionIndex].MouseDown(Button, Shift, vPt.X, vPt.Y);

  CheckUpdateInfo;  // ����ꡢ�л�����Item
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure THCView.MouseMove(Shift: TShiftState; X, Y: Integer);

  {$REGION 'ProcessHint'}
  procedure ProcessHint;
  var
    //vPt: Tpoint;
    vHint: string;
  begin
    vHint := ActiveSection.GetHint;
    if vHint <> Hint then
    begin
//      {if CustomHint <> nil then
//        CustomHint.HideHint;}
      Hint := vHint;
      Application.CancelHint;
    end
//    else
//    begin
//      {if CustomHint <> nil then
//        CustomHint.ShowHint(Self)
//      else
//      begin }
//        GetCursorPos(vPt);
//        Application.ActivateHint(vPt);
//     // end;
//    end;
  end;
  {$ENDREGION}

begin
  inherited;
  //GetSectionByCrood(FHScrollBar.Value + X, FVScrollBar.Value + Y, vSectionIndex);
  if FActiveSectionIndex >= 0 then  // ����ʱ�ڽ���
  begin
    FSections[FActiveSectionIndex].MouseMove(Shift,
      ZoomOut(FHScrollBar.Position + X) - GetSectionDrawLeft(FActiveSectionIndex),
      ZoomOut(FVScrollBar.Position + Y) - GetSectionTopFilm(FActiveSectionIndex));
    if ShowHint then
      ProcessHint;
  end;

  CheckUpdateInfo;  // ������Ҫ������괦Item

  if FStyle.UpdateInfo.Draging then
    Screen.Cursor := GCursor
  else
    Cursor := GCursor;
end;

procedure THCView.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if Button = mbRight then Exit;  // �Ҽ������˵�
  //GetSectionByCrood(FHScrollBar.Value + X, FVScrollBar.Value + Y, vSectionIndex);
  if FActiveSectionIndex >= 0 then  // ����ʱ�ڽ���
    FSections[FActiveSectionIndex].MouseUp(Button, Shift,
      ZoomOut(FHScrollBar.Position + X) - GetSectionDrawLeft(FActiveSectionIndex),
      ZoomOut(FVScrollBar.Position + Y) - GetSectionTopFilm(FActiveSectionIndex));

  if FStyle.UpdateInfo.Draging then
    Screen.Cursor := crDefault;

  Cursor := GCursor;

  CheckUpdateInfo;  // ��ѡ�������а��²��ƶ��������ʱ��Ҫ����

  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);

  FStyle.UpdateInfo.Selecting := False;
  FStyle.UpdateInfo.Draging := False;
end;

function THCView.NewDefaultSection: THCSection;
begin
  Result := THCSection.Create(FStyle);
  // �����ں����ϸ�ֵ�¼�����֤�������������Ҫ��Щ�¼��Ĳ����ɻ�ȡ���¼���
  Result.OnDataChanged := DoSectionDataChanged;
  Result.OnCheckUpdateInfo := DoSectionDataCheckUpdateInfo;
  Result.OnCreateItem := DoSectionCreateItem;
  Result.OnInsertItem := DoSectionInsertItem;
  Result.OnReadOnlySwitch := DoSectionReadOnlySwitch;
  Result.OnItemPaintAfter := DoSectionItemPaintAfter;
  Result.OnItemPaintBefor := DoSectionItemPaintBefor;
  Result.OnPaintHeader := DoSectionPaintHeader;
  Result.OnPaintFooter := DoSectionPaintFooter;
  Result.OnPaintData := DoSectionPaintData;
  Result.OnPaintPage := DoSectionPaintPage;
  Result.OnGetUndoList := DoSectionGetUndoList;
end;

procedure THCView.DoVScrollChange(Sender: TObject; ScrollCode: TScrollCode;
    var ScrollPos: Integer);
begin
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret(False);
  CheckUpdateInfo(True);
  if Assigned(FOnVerScroll) then
    FOnVerScroll(Self);
end;

function THCView.GetPageCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FSections.Count - 1 do
    Result := Result + FSections[i].PageCount;
end;

function THCView.GetPagePreviewFirst: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FActiveSectionIndex - 1 do
    Result := Result + FSections[i].PageCount;
  Result := Result + FSections[FActiveSectionIndex].DisplayFirstPageIndex;
end;

function THCView.GetReadOnly: Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to FSections.Count - 1 do
  begin
    if not FSections[i].ReadOnly then
    begin
      Result := False;
      Break;
    end;
  end;
end;

procedure THCView.Paint;
begin
  //Canvas.Draw(0, 0, FDataBmp);
  BitBlt(Canvas.Handle, 0, 0, GetDisplayWidth, GetDisplayHeight,
      FDataBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure THCView.Paste;

  procedure PasteImage;
  var
    vImageItem: THCImageItem;

    procedure RestrainImageSize;
    var
      vContentWidth, vContentHeight: Integer;
    begin
      with ActiveSection do
      begin
        vContentWidth := PageWidthPix - PageMarginLeftPix - PageMarginRightPix;
        vContentHeight := PageHeightPix - GetHeaderAreaHeight - PageMarginBottomPix;
      end;

      vImageItem.RestrainSize(vContentWidth, vContentHeight);
    end;

  begin
    vImageItem := THCImageItem.Create(Self.ActiveSection.ActiveData.GetTopLevelData);
    vImageItem.Image.Assign(Clipboard);
    RestrainImageSize;
    Self.InsertItem(vImageItem);
  end;

var
  vStream: TMemoryStream;
  vMem: Cardinal;
  vPtr: Pointer;
  vSize, viVersion: Integer;
  vFileFormat, vFileVersion: string;
  vStyle: THCStyle;
begin
  if Clipboard.HasFormat(HC_FILEFORMAT) then
  begin
    vStream := TMemoryStream.Create;
    try
      Clipboard.Open;
      try
        vMem := Clipboard.GetAsHandle(HC_FILEFORMAT);
        vSize := GlobalSize(vMem);
        vStream.SetSize(vSize);
        vPtr := GlobalLock(vMem);
        Move(vPtr^, vStream.Memory^, vSize);
        GlobalUnlock(vMem);
      finally
        Clipboard.Close;
      end;
      //
      vStream.Position := 0;
      _LoadFileFormatAndVersion(vStream, vFileFormat, vFileVersion);  // �ļ���ʽ�Ͱ汾
      viVersion := GetVersionAsInteger(vFileVersion);
      DoPasteDataBefor(vStream, viVersion);
      vStyle := THCStyle.Create;
      try
        vStyle.LoadFromStream(vStream, viVersion);
        ActiveSection.InsertStream(vStream, vStyle, viVersion);
      finally
        FreeAndNil(vStyle);
      end;
    finally
      vStream.Free;
    end;
  end
  else
  if Clipboard.HasFormat(CF_TEXT) then
    ActiveSection.InsertText(Clipboard.AsText)
  else
  if Clipboard.HasFormat(CF_BITMAP) then
    PasteImage;
end;

function THCView.Print(const APrinter: string): TPrintResult;
begin
  Result := prError;
  if APrinter <> '' then
    Printer.PrinterIndex := Printer.Printers.IndexOf(APrinter);

  if Printer.PrinterIndex >= 0 then
  begin
    Printer.Title := FFileName;
    Result := PrintPageRang(1, PageCount);
  end;
end;

function THCView.PrintPageRang(const AStartPageNo,
  AEndPageNo: Integer): TPrintResult;

  {$REGION ' GetSectionPageIndexByPageNo ��ȡָ��ҳ���ڵĽں���Խڵ�ҳ�� '}
  function GetSectionPageIndexByPageNo(const APageNo: Integer; var ASectionPageIndex: Integer): Integer;
  var
    i, vPageCount: Integer;
  begin
    vPageCount := 0;
    for i := 0 to FSections.Count - 1 do
    begin
      if vPageCount + FSections[i].PageCount >= APageNo then
      begin
        Result := i;
        ASectionPageIndex := APageNo - vPageCount - 1;  // FSections[i].PageCount;
        Break;
      end
      else
        vPageCount := vPageCount + FSections[i].PageCount;
    end;
  end;
  {$ENDREGION}

  {$REGION ' ����ҳ��������ô�ӡ�� SetPrintBySectionInfo '}
  procedure SetPrintBySectionInfo(const ASectionIndex: Integer);
  var
    vDevice: Array[0..(cchDeviceName - 1)] of Char;
    vDriver: Array[0..(MAX_PATH - 1)] of Char;
    vPort: Array[0..32] of Char;
    vHDMode: THandle;
    vPDMode: PDevMode;
  begin
    Printer.GetPrinter(vDevice, vDriver, vPort, vHDMode);
    if vHDMode <> 0 then
    begin
      // ��ȡָ��DeviceMode��ָ��
      vPDMode := GlobalLock(vHDMode);
      if vPDMode <> nil then
      begin
        vPDMode^.dmPaperSize := FSections[ASectionIndex].PaperSize;
        if vPDMode^.dmPaperSize = DMPAPER_USER then
        begin
          vPDMode^.dmPaperSize := DMPAPER_USER;  // �Զ���ֽ��
          vPDMode^.dmPaperLength := Round(FSections[ASectionIndex].PaperHeight * 10); //ֽ������ñ������ֽ�ŵĳ�����
          vPDMode^.dmPaperWidth := Round(FSections[ASectionIndex].PaperWidth * 10);   //ֽ��
          vPDMode^.dmFields := vPDMode^.dmFields or DM_PAPERSIZE or DM_PAPERLENGTH or DM_PAPERWIDTH;
        end
      end;

      ResetDC(Printer.Handle, vPDMode^);
      GlobalUnlock(vHDMode);
      //Printer.SetPrinter(vDevice, vDriver, vPort, vHDMode);
    end;
  end;
  {$ENDREGION}

var
  i, j, vStartSection, vStartPageIndex,
  vEndSection, vEndPageIndex, vPrintWidth, vPrintHeight,
  vPrintOffsetX, vPrintOffsetY, vFirstPageIndex, vLastPageIndex: Integer;
  vPrintCanvas: TCanvas;
  vPaintInfo: TSectionPaintInfo;
  vZoomInfo: TZoomInfo;
begin
  Result := prError;

  // ����ҳ���ȡ��ʼ�ںͽ�����
  vStartSection := GetSectionPageIndexByPageNo(AStartPageNo, vStartPageIndex);
  vEndSection := GetSectionPageIndexByPageNo(AEndPageNo, vEndPageIndex);

  // ȡ��ӡ����ӡ������ز���
  vPrintOffsetX := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX);  // 90
  vPrintOffsetY := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY);  // 99
  vPrintWidth := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH);
  vPrintHeight := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT);

  vPaintInfo := TSectionPaintInfo.Create;
  try
    vPaintInfo.Print := True;

    Printer.BeginDoc;
    try
      vPrintCanvas := TCanvas.Create;
      try
        vPrintCanvas.Handle := Printer.Canvas.Handle;  // Ϊʲô����vPrintCanvas�н��ӡ�Ͳ����أ�

        for i := vStartSection to vEndSection do
        begin
          vPaintInfo.SectionIndex := i;
          vPaintInfo.ScaleX := vPrintWidth / FSections[i].PageWidthPix;
          vPaintInfo.ScaleY := vPrintHeight / FSections[i].PageHeightPix;
          vPaintInfo.WindowWidth := vPrintWidth;  // FSections[vStartSection].PageWidthPix;
          vPaintInfo.WindowHeight := vPrintHeight;  // FSections[vStartSection].PageHeightPix;

          SetPrintBySectionInfo(i);

          // ȡ��ǰ�ڴ�ӡ��ʼҳ�ͽ���ҳ
          if i = vStartSection then
          begin
            vFirstPageIndex := vStartPageIndex;
            if vStartSection = vEndSection then  // ��ӡ��ʼ�ͽ�����ͬһ��
              vLastPageIndex := vEndPageIndex
            else
              vLastPageIndex := FSections[i].PageCount - 1;
          end
          else
          if i = vEndSection then
          begin
            vFirstPageIndex := 0;
            vLastPageIndex := Min(vEndPageIndex, FSections[i].PageCount - 1);
          end
          else
          begin
            vFirstPageIndex := 0;
            vLastPageIndex := FSections[i].PageCount - 1;
          end;

          vZoomInfo := vPaintInfo.ZoomCanvas(vPrintCanvas);
          try
            for j := vFirstPageIndex to vLastPageIndex do
            begin
              vPaintInfo.PageIndex := j;

              FSections[i].PaintPage(j, vPrintOffsetX, vPrintOffsetY,
                vPrintCanvas, vPaintInfo);

              if j < vLastPageIndex then
                Printer.NewPage;
            end;
          finally
            vPaintInfo.RestoreCanvasZoom(vPrintCanvas, vZoomInfo);
          end;

          if i < vEndSection then
            Printer.NewPage;
        end;
      finally
        vPrintCanvas.Handle := 0;
        vPrintCanvas.Free;
      end;
    finally
      Printer.EndDoc;
    end;
  finally
    vPaintInfo.Free;
  end;

  Result := prOk;
end;

procedure THCView.ReBuildCaret(const AScrollBar: Boolean = False);
var
  vCaretInfo: TCaretInfo;
  vDisplayHeight: Integer;
begin
  if FCaret = nil then Exit;

  if (not Self.Focused) or ((not Style.UpdateInfo.Draging) and ActiveSection.SelectExists) then
  begin
    FCaret.Hide;
    Exit;
  end;

  { ��ʼ�������Ϣ��Ϊ�����������������ֻ�ܷ������� }
  vCaretInfo.X := 0;
  vCaretInfo.Y := 0;
  vCaretInfo.Height := 0;
  vCaretInfo.Visible := True;

  ActiveSection.GetPageCaretInfo(vCaretInfo);

  if not vCaretInfo.Visible then
  begin
    FCaret.Hide;
    Exit;
  end;
  FCaret.X := ZoomIn(GetSectionDrawLeft(FActiveSectionIndex) + vCaretInfo.X) - FHScrollBar.Position;
  FCaret.Y := ZoomIn(GetSectionTopFilm(FActiveSectionIndex) + vCaretInfo.Y) - FVScrollBar.Position;
  FCaret.Height := ZoomIn(vCaretInfo.Height);

  vDisplayHeight := GetDisplayHeight;
  if not FStyle.UpdateInfo.ReScroll then // ������ƽ������ʱ�����ܽ������������
  begin
    if (FCaret.X < 0) or (FCaret.X > GetDisplayWidth) then
    begin
      FCaret.Hide;
      Exit;
    end;

    if (FCaret.Y + FCaret.Height < 0) or (FCaret.Y > vDisplayHeight) then
    begin
      FCaret.Hide;
      Exit;
    end;
  end
  else  // �ǹ�����(������������)����Ĺ��λ�ñ仯
  begin
    if FCaret.Height < vDisplayHeight then
    begin
      if FCaret.Y < 0 then
        FVScrollBar.Position := FVScrollBar.Position + FCaret.Y - MinPadding
      else
      if FCaret.Y + FCaret.Height + MinPadding > vDisplayHeight then
        FVScrollBar.Position := FVScrollBar.Position + FCaret.Y + FCaret.Height + MinPadding - vDisplayHeight;
    end;
  end;

  if FCaret.Y + FCaret.Height > vDisplayHeight then
    FCaret.Height := vDisplayHeight - FCaret.Y;

  FCaret.Show;
  DoCaretChange;
end;

procedure THCView.Redo;
begin
  BeginUpdate;
  try
    FUndoList.Redo;
  finally
    EndUpdate;
  end;
end;

procedure THCView.FormatSection(const ASectionNo: Integer);
begin
  // FSections[ASectionNo].PageData.ReFormat(0);
  FSections[ASectionNo].FormatData;
  FSections[ASectionNo].BuildSectionPages(0);
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret;

  DoChange;
end;

procedure THCView.ReMarginPaper;
begin
  ActiveSection.ReMarginPaper;
end;

procedure THCView.Resize;
var
  vDisplayWidth, vDisplayHeight: Integer;
begin
  inherited;

  vDisplayWidth := GetDisplayWidth;
  vDisplayHeight := GetDisplayHeight;

  if (vDisplayWidth > 0) and (vDisplayHeight > 0) then
    FDataBmp.SetSize(vDisplayWidth, vDisplayHeight);  // Bitmap����Ϊ0ʱ�����

  FStyle.UpdateInfoRePaint;
  if FCaret <> nil then
    FStyle.UpdateInfoReCaret(False);
  CheckUpdateInfo;
end;

procedure THCView._DeleteUnUsedStyle(const AParts: TSaveParts = [saHeader, saData, saFooter]);
var
  i, vUnCount: Integer;
begin
  for i := 0 to FStyle.TextStyles.Count - 1 do
  begin
    FStyle.TextStyles[i].CheckSaveUsed := False;
    FStyle.TextStyles[i].TempNo := THCStyle.RsNull;
  end;
  for i := 0 to FStyle.ParaStyles.Count - 1 do
  begin
    FStyle.ParaStyles[i].CheckSaveUsed := False;
    FStyle.ParaStyles[i].TempNo := THCStyle.RsNull;
  end;

  for i := 0 to FSections.Count - 1 do
    FSections[i].MarkStyleUsed(True, AParts);

  vUnCount := 0;
  for i := 0 to FStyle.TextStyles.Count - 1 do
  begin
    if FStyle.TextStyles[i].CheckSaveUsed then
      FStyle.TextStyles[i].TempNo := i - vUnCount
    else
      Inc(vUnCount);
  end;

  vUnCount := 0;
  for i := 0 to FStyle.ParaStyles.Count - 1 do
  begin
    if FStyle.ParaStyles[i].CheckSaveUsed then
      FStyle.ParaStyles[i].TempNo := i - vUnCount
    else
      Inc(vUnCount);
  end;

  for i := 0 to FSections.Count - 1 do
    FSections[i].MarkStyleUsed(False);

  for i := FStyle.TextStyles.Count - 1 downto 0 do
  begin
    if not FStyle.TextStyles[i].CheckSaveUsed then
      FStyle.TextStyles.Delete(i);
  end;

  for i := FStyle.ParaStyles.Count - 1 downto 0 do
  begin
    if not FStyle.ParaStyles[i].CheckSaveUsed then
      FStyle.ParaStyles.Delete(i);
  end;
end;

procedure THCView.SaveToBitmap(const AFileName: string);
begin

end;

procedure THCView.SaveToFile(const AFileName: string);
var
  vStream: TStream;
begin
  vStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(vStream);
  finally
    FreeAndNil(vStream);
  end;
end;

procedure THCView.SaveToStream(const AStream: TStream;
  const ASaveParts: TSaveParts = [saHeader, saData, saFooter]);
var
  vByte: Byte;
  i: Integer;
begin
  _SaveFileFormatAndVersion(AStream);  // �ļ���ʽ�Ͱ汾
  DoSaveBefor(AStream);
  _DeleteUnUsedStyle(ASaveParts);  // ɾ����ʹ�õ���ʽ(�ɷ��Ϊ�����õĴ��ˣ�����ʱItem��StyleNoȡ����)
  FStyle.SaveToStream(AStream);
  // ������
  vByte := FSections.Count;
  AStream.WriteBuffer(vByte, 1);
  // ��������
  for i := 0 to FSections.Count - 1 do
    FSections[i].SaveToStream(AStream, ASaveParts);
  DoSaveAfter(AStream);
end;

procedure THCView.SaveToText(const AFileName: string);
begin

end;

function THCView.ZoomIn(const Value: Integer): Integer;
begin
  Result := Round(Value * FZoom);
end;

function THCView.ZoomOut(const Value: Integer): Integer;
begin
  Result := Round(Value / FZoom);
end;

procedure THCView.SelectAll;
var
  i: Integer;
begin
  for i := 0 to FSections.Count - 1 do
    FSections[i].SelectAll;

  FStyle.UpdateInfoRePaint;
  CheckUpdateInfo;
end;

procedure THCView.SetActiveSectionIndex(const Value: Integer);
begin
  if FActiveSectionIndex <> Value then
  begin
    if FActiveSectionIndex >= 0 then
      FSections[FActiveSectionIndex].DisActive;
    FActiveSectionIndex := Value;
  end;
end;

procedure THCView.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  FVScrollBar.Left := Width - FVScrollBar.Width;
  FVScrollBar.Height := Height - FHScrollBar.Height;
  FVScrollBar.PageSize := FVScrollBar.Height;
  //
  FHScrollBar.Top := Height - FHScrollBar.Height;
  FHScrollBar.Width := Width - FVScrollBar.Width;
  FHScrollBar.PageSize := FHScrollBar.Width;
end;

procedure THCView.SetIsChanged(const Value: Boolean);
begin
  if FIsChanged <> Value then
  begin
    FIsChanged := Value;
    if Assigned(FOnChangedSwitch) then
      FOnChangedSwitch(Self);
  end;
end;

procedure THCView.SetPageScrollModel(const Value: TPageScrollModel);
begin
  if FViewModel = vmWeb then Exit;
  if FPageScrollModel <> Value then
    FPageScrollModel := Value;
end;

procedure THCView.SetReadOnly(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to FSections.Count - 1 do
    FSections[i].ReadOnly := Value;
end;

procedure THCView.SetShowAnnotation(const Value: Boolean);
begin
  if FShowAnnotation <> Value then
  begin
    if not Assigned(FAnnotations) then
      FAnnotations := TAnnotations.Create;

    FShowAnnotation := Value;
    FStyle.UpdateInfoRePaint;
    FStyle.UpdateInfoReCaret(False);
    DoMapChanged;
  end;
end;

procedure THCView.SetShowLineActiveMark(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to FSections.Count - 1 do
    FSections[i].PageData.ShowLineActiveMark := Value;

  UpdateBuffer;
end;

procedure THCView.SetShowLineNo(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to FSections.Count - 1 do
    FSections[i].PageData.ShowLineNo := Value;

  UpdateBuffer;
end;

procedure THCView.SetShowUnderLine(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to FSections.Count - 1 do
    FSections[i].PageData.ShowUnderLine := Value;

  UpdateBuffer;
end;

procedure THCView.SetSymmetryMargin(const Value: Boolean);
begin
  if ActiveSection.SymmetryMargin <> Value then
  begin
    ActiveSection.SymmetryMargin := Value;
    FStyle.UpdateInfoRePaint;
    FStyle.UpdateInfoReCaret(False);
    DoMapChanged;
  end;
end;

procedure THCView.SetViewModel(const Value: TViewModel);
begin
  if FPageScrollModel = psmHorizontal then Exit; // ˮƽ���������л�ģʽ
  if FViewModel <> Value then
    FViewModel := Value;
end;

procedure THCView.SetZoom(const Value: Single);
begin
  if FZoom <> Value then
  begin
    Self.SetFocus;
    FZoom := Value;
    FStyle.UpdateInfoRePaint;
    FStyle.UpdateInfoReCaret(False);
    DoMapChanged;
  end;
end;

procedure THCView.ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
begin
  ActiveSection.ApplyParaAlignHorz(AAlign);
end;

procedure THCView.ApplyParaAlignVert(const AAlign: TParaAlignVert);
begin
  ActiveSection.ApplyParaAlignVert(AAlign);
end;

procedure THCView.ApplyParaBackColor(const AColor: TColor);
begin
  ActiveSection.ApplyParaBackColor(AColor);
end;

procedure THCView.ApplyParaLineSpace(const ASpace: Integer);
begin
  ActiveSection.ApplyParaLineSpace(ASpace);
end;

procedure THCView.Undo;
begin
  BeginUpdate;
  try
    FUndoList.Undo;
  finally
    EndUpdate;
  end;
end;

procedure THCView.UpdateBuffer(const ARect: TRect);

  {$REGION ' CalcDisplaySectionAndPage ��ȡ����ʾ����ʼ�ͽ����ڡ�ҳ��� '}
  procedure CalcDisplaySectionAndPage;
  var
    i, j, vPos, vY: Integer;
    vFirstPage, vLastPage: Integer;
  begin
    if FDisplayFirstSection >= 0 then
    begin
      FSections[FDisplayFirstSection].DisplayFirstPageIndex := -1;
      FSections[FDisplayFirstSection].DisplayLastPageIndex := -1;
      FDisplayFirstSection := -1;
    end;
    if FDisplayLastSection >= 0 then
    begin
      FSections[FDisplayLastSection].DisplayFirstPageIndex := -1;
      FSections[FDisplayLastSection].DisplayLastPageIndex := -1;
      FDisplayLastSection := -1;
    end;

    vFirstPage := -1;
    vLastPage := -1;
    vPos := 0;
    if FPageScrollModel = psmVertical then
    begin
      for i := 0 to FSections.Count - 1 do
      begin
        for j := 0 to FSections[i].PageCount - 1 do
        begin
          vPos := vPos + ZoomIn(MinPadding + FSections[i].PageHeightPix);
          if vPos > FVScrollBar.Position then
          begin
            vFirstPage := j;
            Break;
          end;
        end;
        if vFirstPage >= 0 then
        begin
          FDisplayFirstSection := i;
          FSections[FDisplayFirstSection].DisplayFirstPageIndex := j;
          Break;
        end;
      end;
      if FDisplayFirstSection >= 0 then
      begin
        vY := FVScrollBar.Position + GetDisplayHeight;
        for i := FDisplayFirstSection to FSections.Count - 1 do
        begin
          for j := vFirstPage to FSections[i].PageCount - 1 do
          begin
            if vPos < vY then
              vPos := vPos + ZoomIn(MinPadding + FSections[i].PageHeightPix)
            else
            begin
              vLastPage := j;
              Break;
            end;
          end;
          if vLastPage >= 0 then
          begin
            FDisplayLastSection := i;
            FSections[FDisplayLastSection].DisplayLastPageIndex := j;
            Break;
          end;
        end;
        if FDisplayLastSection < 0 then  // û���ҵ�����ҳ����ֵΪ���һ�����һҳ
        begin
          FDisplayLastSection := FSections.Count - 1;
          FSections[FDisplayLastSection].DisplayLastPageIndex := FSections[FDisplayLastSection].PageCount - 1;
        end;
      end;
    end;
    if (FDisplayFirstSection < 0) or (FDisplayLastSection < 0) then
      raise Exception.Create('�쳣����ȡ��ǰ��ʾ��ʼҳ�ͽ���ҳʧ�ܣ�')
    else
    begin
      if FDisplayFirstSection <> FDisplayLastSection then  // ��ʼ�ͽ�������ͬһ��
      begin
        FSections[FDisplayFirstSection].DisplayLastPageIndex := FSections[FDisplayFirstSection].PageCount - 1;
        FSections[FDisplayLastSection].DisplayFirstPageIndex := 0;
      end;
    end;
  end;
  {$ENDREGION}

var
  i, vOffsetY, vDisplayWidth, vDisplayHeight: Integer;
  vPaintInfo: TSectionPaintInfo;
  vZoomInfo: TZoomInfo;
begin
  if (FUpdateCount = 0) and HandleAllocated then
  begin
    FDataBmp.Canvas.Lock;
    try
      if FShowAnnotation then
        FAnnotations.Clear;

      // ����һ���µļ������򣬸������ǵ�ǰ���������һ���ض����εĽ���
      IntersectClipRect(FDataBmp.Canvas.Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);

      // �ؼ�����
      FDataBmp.Canvas.Brush.Color := RGB(82, 89, 107);// $00E7BE9F;
      FDataBmp.Canvas.FillRect(Rect(0, 0, FDataBmp.Width, FDataBmp.Height));
      // ����ڴ˼��㵱ǰҳ��������ʼ���������Բ�����ARect����
      vDisplayWidth := GetDisplayWidth;
      vDisplayHeight := GetDisplayHeight;
      CalcDisplaySectionAndPage;  // ���㵱ǰ��Χ�ڿ���ʾ����ʼ�ڡ�ҳ�ͽ����ڡ�ҳ

      vPaintInfo := TSectionPaintInfo.Create;
      try
        vPaintInfo.ScaleX := FZoom;
        vPaintInfo.ScaleY := FZoom;
        vPaintInfo.WindowWidth := vDisplayWidth;
        vPaintInfo.WindowHeight := vDisplayHeight;

        vZoomInfo := vPaintInfo.ZoomCanvas(FDataBmp.Canvas);
        try
          for i := FDisplayFirstSection to FDisplayLastSection do
          begin
            vPaintInfo.SectionIndex := i;

            vOffsetY := ZoomOut(FVScrollBar.Position) - GetSectionTopFilm(i);  // תΪԭʼY��ƫ��
            FSections[i].PaintDisplayPage(GetSectionDrawLeft(i) - ZoomOut(FHScrollBar.Position),  // ԭʼX��ƫ��
              vOffsetY, FDataBmp.Canvas, vPaintInfo);
          end;

          for i := 0 to vPaintInfo.TopItems.Count - 1 do  // ���ƶ���Item
            vPaintInfo.TopItems[i].PaintTop(FDataBmp.Canvas);
        finally
          vPaintInfo.RestoreCanvasZoom(FDataBmp.Canvas, vZoomInfo);
        end;
      finally
        vPaintInfo.Free;
      end;
    finally
      FDataBmp.Canvas.Unlock;
    end;

    BitBlt(Canvas.Handle, ARect.Left, ARect.Top, ARect.Width, ARect.Height,
      FDataBmp.Canvas.Handle, ARect.Left, ARect.Top, SRCCOPY);

    InvalidateRect(Self.Handle, ARect, False);  // ֻ���±䶯���򣬷�ֹ��˸�����BitBlt�����������
  end;
end;

procedure THCView.UpdateBuffer;
begin
  UpdateBuffer(GetDisplayRect);
end;

procedure THCView.UpdateImmPosition;
var
  vhIMC: HIMC;
  vCF: TCompositionForm;
  vLogFont: TLogFont;
  //vIMEWnd: THandle;
  //vS: string;
  //vCandiID: Integer;
begin
  vhIMC := ImmGetContext(Handle);
  try
    // �������뷨��ǰ��괦������Ϣ
    ImmGetCompositionFont(vhIMC, @vLogFont);
    vLogFont.lfHeight := 22;
    ImmSetCompositionFont(vhIMC, @vLogFont);
    // �������뷨��ǰ���λ����Ϣ
    vCF.ptCurrentPos := Point(FCaret.X, FCaret.Y + 5);  // ���뷨��������λ��
    vCF.dwStyle := CFS_RECT;
    vCF.rcArea  := ClientRect;
    ImmSetCompositionWindow(vhIMC, @vCF);
  finally
    ImmReleaseContext(Handle, vhIMC);
  end;
  {if ActiveSection.SelectInfo.StartItemOffset > 1 then  // �������뷨���ݵ�ǰλ�ô������±�ѡ
  begin
    if GetCurItem.StyleNo < 0 then Exit;
    
    vS := GetCurItem.GetTextPart(ActiveSection.SelectInfo.StartItemOffset - 1, 2);  // ���ع��ǰ2���ַ�
    if vS <> '' then
    begin
      if vS = '����' then
        vCandiID := 4743
      else
      if vS = '����' then
        vCandiID := 10019
      else
      if vS = 'ʧȥ' then
        vCandiID := 10657
      else
        vCandiID := -1;
      if vCandiID > 0 then
      begin
        vIMEWnd := ImmGetDefaultIMEWnd(Handle);
        //SendMessage(vIMEWnd, WM_IME_CONTROL, IMC_SETCOMPOSITIONWINDOW, Integer(@vPt));
        SendMessage(vIMEWnd, WM_IME_NOTIFY, IMN_UPDATECURSTRING, vCandiID);
      end;
    end;
  end;}
end;

procedure THCView.WMERASEBKGND(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure THCView.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTTAB or DLGC_WANTARROWS;
end;

procedure THCView.WMImeComposition(var Message: TMessage);
var
  vhIMC: HIMC;
  vSize: Integer;
  vBuffer: TBytes;
  vS: string;
begin
  if (Message.LParam and GCS_RESULTSTR) <> 0 then  // ֪ͨ��������������ַ���
  begin
    // ���������ı�һ���Բ��룬����᲻ͣ�Ĵ���KeyPress�¼�
    vhIMC := ImmGetContext(Handle);
    if vhIMC <> 0 then
    begin
      try
        vSize := ImmGetCompositionString(vhIMC, GCS_RESULTSTR, nil, 0);  // ��ȡIME����ַ����Ĵ�С
        if vSize > 0 then  	// ���IME����ַ�����Ϊ�գ���û�д���
        begin
          // ȡ���ַ���
          SetLength(vBuffer, vSize);
          ImmGetCompositionString(vhIMC, GCS_RESULTSTR, vBuffer, vSize);
          SetLength(vBuffer, vSize);  // vSize - 2
          vS := WideStringOf(vBuffer);
          if vS <> '' then
          begin
            if not DoProcessIMECandi(vS) then
              ActiveSection.InsertText(vS);
          end;
        end;
      finally
        ImmReleaseContext(Handle, vhIMC);
      end;
      Message.Result := 0;
    end;
  end
  else
    inherited;
end;

procedure THCView.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if Message.FocusedWnd <> Self.Handle then
    FCaret.Hide;
end;

procedure THCView.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  //ActiveSection.DblClick(Message.XPos, Message.YPos);  // ˫��Ҳ�ŵ�MouseDown����
end;

procedure THCView.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  ReBuildCaret;
end;

procedure THCView.WndProc(var Message: TMessage);
{var
  DC: HDC;
  PS: TPaintStruct;}
begin
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
        if not (csDesigning in ComponentState) and not Focused then
        begin
          Windows.SetFocus(Handle);
          if not Focused then
            Exit;
        end;
      end;
    {WM_PAINT:
      begin
        DC := BeginPaint(Handle, PS);
        try
          BitBlt(DC,
            PS.rcPaint.Left, PS.rcPaint.Top,
            PS.rcPaint.Right - PS.rcPaint.Left - FVScrollBar.Width,
            PS.rcPaint.Bottom - PS.rcPaint.Top - FHScrollBar.Height,
            FSectionData.DataBmp.Canvas.Handle,
            PS.rcPaint.Left, PS.rcPaint.Top,
            SRCCOPY);
        finally
          EndPaint(Handle, PS);
        end;
      end; }
  end;
  inherited WndProc(Message);
end;

{ TAnnotations }

procedure TAnnotations.AddAnnotation(const ADrawItemRect: TRect; const AText: string);
var
  vAnnotation: TAnnotation;
begin
  vAnnotation := TAnnotation.Create;
  vAnnotation.DrawItemRect := ADrawItemRect;
  vAnnotation.Text := AText;
  Self.Add(vAnnotation);
end;

constructor TAnnotations.Create;
begin
  inherited Create(True);
  FIndex := -1;
end;

procedure TAnnotations.MouseDown(const X, Y: Integer);
var
  i: Integer;
  vPt: TPoint;
begin
  FIndex := -1;
  vPt := Point(X, Y);
  for i := 0 to Self.Count - 1 do
  begin
    if PtInRect(Self[i].PaintRect, vPt) then
    begin
      FIndex := i;
      Break;
    end;
  end;
end;

procedure TAnnotations.PaintTo(const ACanvas: TCanvas; const ARect: TRect;
  const APaintInfo: TSectionPaintInfo);
var
  i, vPos: Integer;
  vAnnotation: TAnnotation;
  vTextRect, vPaintRect: TRect;
begin
  if APaintInfo.Print then Exit;

  ACanvas.Brush.Color := $00F4F4F4;
  ACanvas.FillRect(Rect(ARect.Right, ARect.Top, ARect.Right + AnnotationWidth, ARect.Bottom));
  if Self.Count > 0 then
  begin
    vPos := 0;

    //ACanvas.Refresh;
    ACanvas.Font.Size := 8;
    //ACanvas.Pen.Mode := TPenMode.pmXor;
    for i := 0 to Self.Count - 1 do
    begin
      if i <> FIndex then
      begin
        ACanvas.Pen.Style := TPenStyle.psDot;
        ACanvas.Pen.Color := clRed;
      end
      else
      begin
        ACanvas.Pen.Style := TPenStyle.psSolid;
        ACanvas.Pen.Color := clMaroon;
      end;

      vAnnotation := Self.Items[i];
      if vPos < vAnnotation.DrawItemRect.Top then
        vPos := vAnnotation.DrawItemRect.Top
      else
      if vAnnotation.DrawItemRect.Top <= vPos then
        vPos := vPos + (vAnnotation.DrawItemRect.Bottom - vAnnotation.DrawItemRect.Top);

      // ������ע�ı���ʾ����
      vTextRect := Rect(ARect.Right + 30, vPos, ARect.Right + AnnotationWidth - 10,
        vAnnotation.DrawItemRect.Bottom);
      DrawTextEx(ACanvas.Handle, PChar(vAnnotation.Text), -1, vTextRect,
        DT_TOP or DT_LEFT or DT_WORDBREAK or DT_EDITCONTROL or DT_CALCRECT, nil);  // ��������

      // �����ע����
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := clYellow;
      vPaintRect := vTextRect;
      InflateRect(vPaintRect, 5, 5);
      ACanvas.RoundRect(vPaintRect, 5, 5);

      vAnnotation.PaintRect := vPaintRect;  // ��¼ PaintRect

      // ����ָ����
      ACanvas.Brush.Style := bsClear;
      ACanvas.MoveTo(vAnnotation.DrawItemRect.Right, vAnnotation.DrawItemRect.Bottom + 2);
      ACanvas.LineTo(ARect.Right, vAnnotation.DrawItemRect.Bottom + 2);
      ACanvas.LineTo(ARect.Right + 30, vPos);

      // ������ע�ı�
      DrawTextEx(ACanvas.Handle, PChar(vAnnotation.Text), -1, vTextRect, DT_TOP or DT_LEFT or DT_WORDBREAK, nil);

      vPos := vTextRect.Bottom + 5;
    end;
  end;
end;

end.
