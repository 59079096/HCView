{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  �ĵ��ڹ���ʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCSection;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, HCRichData, HCSectionData,
  HCCustomRichData, HCTextStyle, HCParaStyle, HCItem, HCDrawItem, HCPage,
  HCCommon, HCStyle, HCCustomSectionData;

type
  TPrintResult = (prOk, prNoPrinter, prError);

  TSectionPaintInfo = class(TPaintInfo)
  strict private
    FSectionIndex, FPageIndex: Integer;
    FPageDrawRight: Integer;
  public
    property SectionIndex: Integer read FSectionIndex write FSectionIndex;
    property PageIndex: Integer read FPageIndex write FPageIndex;
    property PageDrawRight: Integer read FPageDrawRight write FPageDrawRight;
  end;

  THCSection = class;

  TOnGetPageInfoEvent = procedure(Sender: THCSection; var AStartPageIndex,
    AAllPageCount: Integer) of object;

  TSectionPagePaintEvent = procedure(Sender: THCSection; const APageIndex: Integer;
    const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo) of object;

  THCSection = class(TObject)
  private
    FStyle: THCStyle;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    FSymmetryMargin: Boolean;
    FPages: THCPages;  // ����ҳ��
    FPageSize: THCPageSize;
    FHeader: THCCustomSectionData;
    FFooter: THCCustomSectionData;
    FPageData: THCSectionData;
    FActiveData: THCRichData;  // ҳü�����ġ�ҳ��

    FPageNoVisible: Boolean;  // �Ƿ���ʾҳ��

    FPageNoFrom,  // ҳ��Ӽ���ʼ
    FActivePageIndex,
    FDisplayFirstPageIndex,  // ���Ե�һҳ
    FDisplayLastPageIndex,   // �������һҳ
    FHeaderOffset  // ҳü����ƫ��
      : Integer;

    FOnDataChanged,  // ҳü��ҳ�š�ҳ��ĳһ���޸�ʱ����
    FOnCheckUpdateInfo,  // ��ǰData��ҪUpdateInfo����ʱ����
    FOnReadOnlySwitch  // ҳü��ҳ�š�ҳ��ֻ��״̬�����仯ʱ����
      : TNotifyEvent;

    FOnGetPageInfo: TOnGetPageInfoEvent;

    FOnPaintHeader, FOnPaintFooter, FOnPaintData, FOnPaintPage: TSectionPagePaintEvent;

    /// <summary> ��ǰData���ݱ䶯��ɺ� </summary>
    /// <param name="AInsertActItemNo">���뷢����λ��</param>
    /// <param name="AOldDataHeight">����ǰData�ĸ߶�</param>
    procedure DoActiveDataChanged(const AActiveItemNo: Integer;
      const ABuildSectionPage: Boolean);

    /// <summary> ��ǰData��ҪUpdateInfo���� </summary>
    procedure DoActiveDataCheckUpdateInfo;

    procedure DoDataReadOnlySwitch(Sender: TObject);

    /// <summary>
    /// ����ҳ��ָ��DrawItem���ڵ�ҳ(��ҳ�İ����λ������ҳ)
    /// </summary>
    /// <param name="ADrawItemNo"></param>
    /// <returns></returns>
    function GetPageDataDrawItemPageIndex(const ADrawItemNo: Integer): Integer;

    /// <summary> ��ĳһҳ������ת����ҳָ��Data������(��Լ��) </summary>
    procedure PageCoordToDataCoord(const APageIndex: Integer;
      const AData: THCRichData; var AX, AY: Integer);

    function ZoomCanvas(const ACanvas: TCanvas; const AScaleX, AScaleY: Single) : TZoomInfo;
    procedure RestoreCanvasZoom(const ACanvas : TCanvas; const AOldInfo: TZoomInfo);
    procedure DoDataChanged(Sender: TObject);

    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
  protected
    // ֽ����Ϣ
    function GetPaperSize: Integer;
    procedure SetPaperSize(const Value: Integer);
    // �߾���Ϣ
    function GetPaperWidth: Single;
    function GetPaperHeight: Single;
    function GetPaperMarginTop: Single;
    function GetPaperMarginLeft: Single;
    function GetPaperMarginRight: Single;
    function GetPaperMarginBottom: Single;

    procedure SetPaperWidth(const Value: Single);
    procedure SetPaperHeight(const Value: Single);
    procedure SetPaperMarginTop(const Value: Single);
    procedure SetPaperMarginLeft(const Value: Single);
    procedure SetPaperMarginRight(const Value: Single);
    procedure SetPaperMarginBottom(const Value: Single);

    function GetPageWidthPix: Integer;
    function GetPageHeightPix: Integer;
    function GetPageMarginTopPix: Integer;
    function GetPageMarginLeftPix: Integer;
    function GetPageMarginRightPix: Integer;
    function GetPageMarginBottomPix: Integer;

    procedure SetPageWidthPix(const Value: Integer);
    procedure SetPageHeightPix(const Value: Integer);
    procedure SetPageMarginTopPix(const Value: Integer);
    procedure SetPageMarginLeftPix(const Value: Integer);
    procedure SetPageMarginRightPix(const Value: Integer);
    procedure SetPageMarginBottomPix(const Value: Integer);
    procedure SetHeaderOffset(const Value: Integer);
    function NewEmptyPage: THCPage;
    function GetPageCount: Integer;

    function GetOnInsertItem: TItemNotifyEvent;
    procedure SetOnInsertItem(const Value: TItemNotifyEvent);
    function GetOnItemPaintBefor: TItemPaintEvent;
    procedure SetOnItemPaintBefor(const Value: TItemPaintEvent);
    function GetOnItemPaintAfter: TItemPaintEvent;
    procedure SetOnItemPaintAfter(const Value: TItemPaintEvent);

    function GetOnCreateItem: TNotifyEvent;
    procedure SetOnCreateItem(const Value: TNotifyEvent);

    function GetRichDataAt(const X, Y: Integer): THCRichData;
    function GetActiveArea: TSectionArea;

    /// <summary>
    /// �������ݸ�ʽ��AVerticalλ���ڽ����е�λ��
    /// </summary>
    /// <param name="AVertical"></param>
    /// <returns></returns>
    function GetDataFmtTopFilm(const AVertical: Integer): Integer;
    function ActiveDataChangeByAction(const AProc: TChangeProc): Boolean;
  public
    constructor Create(const AStyle: THCStyle);
    destructor Destroy; override;
    //
    /// <summary> �޸�ֽ�ű߾� </summary>
    procedure ReMarginPaper;
    procedure Clear;
    procedure SetEmptyData;
    procedure DisActive;
    function SelectExists: Boolean;
    function GetHint: string;
    function GetCurItem: THCCustomItem;
    function GetActiveItem: THCCustomItem;
    function GetActiveDrawItem: THCCustomDrawItem;
    function GetActiveDrawItemCoord: TPoint;
    function GetCurrentPage: Integer;
    procedure PaintDisplayPage(const AFilmOffsetX, AFilmOffsetY, ADisplayWidth, ADisplayHeight: Integer;
      const AZoom: Single; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    /// <summary>
    /// ����ָ��ҳ��ָ����λ�ã�Ϊ��ϴ�ӡ������ADisplayWidth, ADisplayHeight����
    /// </summary>
    /// <param name="APageIndex">Ҫ���Ƶ�ҳ��</param>
    /// <param name="ALeft">����Xƫ��</param>
    /// <param name="ATop">����Yƫ��</param>
    /// <param name="AWidth">���ڻ��Ƶ�������</param>
    /// <param name="AHeight">���ڻ��Ƶ�����߶�</param>
    /// <param name="AScaleX">��������</param>
    /// <param name="AScaleY">��������</param>
    /// <param name="ACanvas"></param>
    procedure PaintPage(const APageIndex, ALeft, ATop,
      AWidth, AHeight: Integer; const AScaleX, AScaleY: Single;
      ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
    //
    procedure KillFocus;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure KeyPress(var Key: Char);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyUp(var Key: Word; Shift: TShiftState);
    //
    procedure ApplyTextStyle(const AFontStyle: TFontStyleEx);
    procedure ApplyTextFontName(const AFontName: TFontName);
    procedure ApplyTextFontSize(const AFontSize: Integer);
    procedure ApplyTextColor(const AColor: TColor);
    procedure ApplyTextBackColor(const AColor: TColor);
    function InsertText(const AText: string): Boolean;
    function InsertTable(const ARowCount, AColCount: Integer): Boolean;
    function InsertLine(const ALineHeight: Integer): Boolean;
    function InsertItem(const AItem: THCCustomItem): Boolean; overload;
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem): Boolean; overload;

    /// <summary> �ӵ�ǰλ�ú��� </summary>
    function InsertBreak: Boolean;

    /// <summary> �ӵ�ǰλ�ú��ҳ </summary>
    function InsertPageBreak: Boolean;
    //
    function ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
    function ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
    function ActiveTableDeleteRow(const ARowCount: Byte): Boolean;
    function ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
    function ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
    function ActiveTableDeleteCol(const AColCount: Byte): Boolean;
    //
    // ������ת����ָ��ҳ����
    procedure SectionToPage(const APageIndex, X, Y: Integer; var
      APageX, APageY: Integer);

    /// <summary>
    /// Ϊ��Ӧ�ö��뷽ʽ
    /// </summary>
    /// <param name="AAlign">�Է���ʽ</param>
    procedure ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
    procedure ApplyParaAlignVert(const AAlign: TParaAlignVert);
    procedure ApplyParaBackColor(const AColor: TColor);
    procedure ApplyParaLineSpace(const ASpace: Integer);

    /// <summary>
    /// ��ȡ�����Dtat�е�λ����Ϣ��ӳ�䵽ָ��ҳ��
    /// </summary>
    /// <param name="APageIndex">Ҫӳ�䵽��ҳ���</param>
    /// <param name="ACaretInfo">���λ����Ϣ</param>
    procedure GetPageCaretInfo(var ACaretInfo: TCaretInfo);

    /// <summary>
    /// ���ص�ǰ��ָ���Ĵ�ֱƫ�ƴ���Ӧ��ҳ
    /// </summary>
    /// <param name="AVOffset">��ֱƫ��</param>
    /// <returns>ҳ��ţ�-1��ʾ�޶�Ӧҳ</returns>
    function GetPageByFilm(const AVOffset: Integer): Integer;

    /// <summary> ĳҳ���������е�Topλ�� </summary>
    /// <param name="APageIndex"></param>
    /// <returns></returns>
    function GetPageTopFilm(const APageIndex: Integer): Integer;

    /// <summary>
    /// ����ָ��ҳ������ʼλ��������Data�е�Top��ע�� 20161216001
    /// </summary>
    /// <param name="APageIndex"></param>
    /// <returns></returns>
    function GetPageDataFmtTop(const APageIndex: Integer): Integer;

    /// <summary> ҳü������ҳ�е���ʼλ�� </summary>
    /// <returns></returns>
    function GetHeaderPageDrawTop: Integer;

    /// <summary>
    /// ��ȡ��ʽ����ֱλ�������ݵ���һҳ(Ŀǰֻ��GetPageCaretInfo���õ��ˣ��Ƿ����ͨ���ԣ�)
    /// </summary>
    /// <param name="AVertical">��ֱλ��</param>
    /// <returns>ҳ���</returns>
    //function GetPageByDataFmt(const AVertical: Integer): Integer;

    function GetPageMarginLeft(const APageIndex: Integer): Integer;

    /// <summary>
    /// ����ҳ��Գ����ԣ���ȡָ��ҳ�����ұ߾�
    /// </summary>
    /// <param name="APageIndex"></param>
    /// <param name="AMarginLeft"></param>
    /// <param name="AMarginRight"></param>
    procedure GetPageMarginLeftAndRight(const APageIndex: Integer;
      var AMarginLeft, AMarginRight: Integer);
    /// <summary>
    /// ������ָ��Item��ʼ���¼���ҳ
    /// </summary>
    /// <param name="AStartItemNo"></param>
    procedure BuildSectionPages(const AStartItemNo: Integer);
    function DeleteSelected: Boolean;
    procedure DisSelect;
    function MergeTableSelectCells: Boolean;
    procedure ReFormatActiveItem;
    function GetHeaderAreaHeight: Integer;
    function GetFilmHeight: Cardinal;  // ����ҳ���+�ָ���
    function GetFilmWidth: Cardinal;

    /// <summary>
    /// �����ʽ�Ƿ����û�ɾ����ʹ�õ���ʽ��������ʽ���
    /// </summary>
    /// <param name="AMark">True:�����ʽ�Ƿ����ã�Fasle:����ԭ��ʽ��ɾ����ʹ����ʽ��������</param>
    procedure MarkStyleUsed(const AMark: Boolean;
      const AParts: TSaveParts = [saHeader, saData, saFooter]);
    procedure SaveToStream(const AStream: TStream;
      const ASaveParts: TSaveParts = [saHeader, saData, saFooter]);
    procedure LoadFromText(const AFileName: string; const AEncoding: TEncoding);
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word);
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean;
    procedure FormatData;
    // ����
    // ҳ��
    property PaperSize: Integer read GetPaperSize write SetPaperSize;
    property PaperWidth: Single read GetPaperWidth write SetPaperWidth;
    property PaperHeight: Single read GetPaperHeight write SetPaperHeight;
    property PaperMarginTop: Single read GetPaperMarginTop write SetPaperMarginTop;
    property PaperMarginLeft: Single read GetPaperMarginLeft write SetPaperMarginLeft;
    property PaperMarginRight: Single read GetPaperMarginRight write SetPaperMarginRight;
    property PaperMarginBottom: Single read GetPaperMarginBottom write SetPaperMarginBottom;
    //
    property PageWidthPix: Integer read GetPageWidthPix write SetPageWidthPix;
    property PageHeightPix: Integer read GetPageHeightPix write SetPageHeightPix;
    property PageMarginTopPix: Integer read GetPageMarginTopPix write SetPageMarginTopPix;
    property PageMarginLeftPix: Integer read GetPageMarginLeftPix write SetPageMarginLeftPix;
    property PageMarginRightPix: Integer read GetPageMarginRightPix write SetPageMarginRightPix;
    property PageMarginBottomPix: Integer read GetPageMarginBottomPix write SetPageMarginBottomPix;

    property HeaderOffset: Integer read FHeaderOffset write SetHeaderOffset;
    property Header: THCCustomSectionData read FHeader;
    property Footer: THCCustomSectionData read FFooter;
    property PageData: THCSectionData read FPageData;

    /// <summary> ��ǰ�ĵ���������(ҳü��ҳ�š�ҳ��)�����ݶ��� </summary>
    property ActiveData: THCRichData read FActiveData;

    /// <summary> ��ǰ�ĵ���������ҳü��ҳ�š�ҳ�� </summary>
    property ActiveArea: TSectionArea read GetActiveArea;
    property ActivePageIndex: Integer read FActivePageIndex;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    property SymmetryMargin: Boolean read FSymmetryMargin write FSymmetryMargin;
    property DisplayFirstPageIndex: Integer read FDisplayFirstPageIndex write FDisplayFirstPageIndex;  // ���Ե�һҳ
    property DisplayLastPageIndex: Integer read FDisplayLastPageIndex write FDisplayLastPageIndex;  // �������һҳ
    property PageCount: Integer read GetPageCount;

    /// <summary> �ĵ����в����Ƿ�ֻ�� </summary>
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property OnDataChanged: TNotifyEvent read FOnDataChanged write FOnDataChanged;
    property OnReadOnlySwitch: TNotifyEvent read FOnReadOnlySwitch write FOnReadOnlySwitch;
    property OnCheckUpdateInfo: TNotifyEvent read FOnCheckUpdateInfo write FOnCheckUpdateInfo;
    property OnInsertItem: TItemNotifyEvent read GetOnInsertItem write SetOnInsertItem;
    property OnGetPageInfo: TOnGetPageInfoEvent read FOnGetPageInfo write FOnGetPageInfo;
    property OnPaintHeader: TSectionPagePaintEvent read FOnPaintHeader write FOnPaintHeader;
    property OnPaintFooter: TSectionPagePaintEvent read FOnPaintFooter write FOnPaintFooter;
    property OnPaintData: TSectionPagePaintEvent read FOnPaintData write FOnPaintData;
    property OnPaintPage: TSectionPagePaintEvent read FOnPaintPage write FOnPaintPage;
    property OnItemPaintBefor: TItemPaintEvent read GetOnItemPaintBefor write SetOnItemPaintBefor;
    property OnItemPaintAfter: TItemPaintEvent read GetOnItemPaintAfter write SetOnItemPaintAfter;
    property OnCreateItem: TNotifyEvent read GetOnCreateItem write SetOnCreateItem;
  end;

implementation

uses
  Math, HCRectItem;

{ THCSection }

function THCSection.ActiveTableDeleteCol(const AColCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.ActiveTableDeleteCol(AColCount);
    end);
end;

function THCSection.ActiveTableDeleteRow(const ARowCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.ActiveTableDeleteRow(ARowCount);
    end);
end;

function THCSection.ActiveTableInsertColAfter(const AColCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertColAfter(AColCount);
    end);
end;

function THCSection.ActiveTableInsertColBefor(const AColCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertColBefor(AColCount);
    end);
end;

function THCSection.ActiveTableInsertRowAfter(const ARowCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertRowAfter(ARowCount);
    end);
end;

function THCSection.ActiveTableInsertRowBefor(const ARowCount: Byte): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.TableInsertRowBefor(ARowCount);
    end);
end;

procedure THCSection.ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaAlignHorz(AAlign);
    end);
end;

procedure THCSection.ApplyParaAlignVert(const AAlign: TParaAlignVert);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaAlignVert(AAlign);
    end);
end;

procedure THCSection.ApplyParaBackColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaBackColor(AColor);
    end);
end;

procedure THCSection.ApplyParaLineSpace(const ASpace: Integer);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyParaLineSpace(ASpace);
    end);
end;

procedure THCSection.ApplyTextBackColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextBackColor(AColor);
    end);
end;

procedure THCSection.ApplyTextColor(const AColor: TColor);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextColor(AColor);
    end);
end;

procedure THCSection.ApplyTextFontName(const AFontName: TFontName);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextFontName(AFontName);
    end);
end;

procedure THCSection.ApplyTextFontSize(const AFontSize: Integer);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextFontSize(AFontSize);
    end);
end;

procedure THCSection.ApplyTextStyle(const AFontStyle: TFontStyleEx);
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ApplyTextStyle(AFontStyle);
    end);
end;

procedure THCSection.Clear;
begin
  FHeader.Clear;
  FFooter.Clear;
  FPageData.Clear;
  FPages.ClearEx;
end;

constructor THCSection.Create(const AStyle: THCStyle);
begin
  inherited Create;
  FStyle := AStyle;
  FPageNoVisible := True;
  FPageNoFrom := 1;
  FHeaderOffset := 20;
  FDisplayFirstPageIndex := -1;
  FDisplayLastPageIndex := -1;

  FPageSize := THCPageSize.Create(AStyle.PixelsPerInchX, AStyle.PixelsPerInchY);
  FPageData := THCSectionData.Create(AStyle);
  with FPageSize do
    FPageData.Width := PageWidthPix - PageMarginLeftPix - PageMarginRightPix;
  FPageData.OnReadOnlySwitch := DoDataReadOnlySwitch;
  // FData.PageHeight := PageHeightPix - PageMarginBottomPix - GetHeaderAreaHeight;
  // ��ReFormatSectionData�д�����FData.PageHeight

  FHeader := THCCustomSectionData.Create(AStyle);
  FHeader.OnReadOnlySwitch := DoDataReadOnlySwitch;
  FHeader.Width := FPageData.Width;

  FFooter := THCCustomSectionData.Create(AStyle);
  FFooter.OnReadOnlySwitch := DoDataReadOnlySwitch;
  FFooter.Width := FPageData.Width;

  FActiveData := FPageData;
  FSymmetryMargin := True;  // �Գ�ҳ�߾� debug

  FPages := THCPages.Create;
  NewEmptyPage;           // �����հ�ҳ
  FPages[0].StartDrawItemNo := 0;
  FPages[0].EndDrawItemNo := 0;
end;

function THCSection.DeleteSelected: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.DeleteSelected;
    end);
end;

destructor THCSection.Destroy;
begin
  FHeader.Free;
  FFooter.Free;
  FPageData.Free;
  FPageSize.Free;
  FPages.Free;
  inherited Destroy;
end;

procedure THCSection.DisActive;
begin
  //if FActiveData <> nil then
    FActiveData.DisSelect;

  FHeader.InitializeField;
  FFooter.InitializeField;
  FPageData.InitializeField;
  FActiveData := FPageData;
end;

procedure THCSection.DisSelect;
begin
  FActiveData.GetTopLevelData.DisSelect;
end;

procedure THCSection.DoActiveDataChanged(const AActiveItemNo: Integer;
  const ABuildSectionPage: Boolean);
begin
  if ABuildSectionPage then
  begin
    if FActiveData = FPageData then
      BuildSectionPages(AActiveItemNo)
    else
      BuildSectionPages(0);
    // ����Ҫ��ʱ�򣬿��Խ��滭�仯�͸߶ȱ仯�ֿ����Լ���RichEdit����Ҫ��CalcScrollRang��AdjustScroll
  end;
  DoDataChanged(Self);
end;

procedure THCSection.DoActiveDataCheckUpdateInfo;
begin
  if Assigned(FOnCheckUpdateInfo) then
    FOnCheckUpdateInfo(Self);
end;

procedure THCSection.DoDataChanged(Sender: TObject);
begin
  if Assigned(FOnDataChanged) then
    FOnDataChanged(Sender);
end;

procedure THCSection.DoDataReadOnlySwitch(Sender: TObject);
begin
  if Assigned(FOnReadOnlySwitch) then
    FOnReadOnlySwitch(Self);
end;

procedure THCSection.SetEmptyData;
begin
  FHeader.SetEmptyData;
  FFooter.SetEmptyData;
  FPageData.SetEmptyData;
end;

procedure THCSection.FormatData;
begin
  FHeader.ReFormat(0);
  Footer.ReFormat(0);
  FPageData.ReFormat(0);
  FActiveData.DisSelect;
end;

function THCSection.GetCurrentPage: Integer;
begin
  Result := -1;
  if FActiveData <> FPageData then
    Result := FActivePageIndex
  else
  begin
    if FPageData.CaretDrawItemNo < 0 then
    begin
      if FPageData.SelectInfo.StartItemNo >= 0 then
      begin
        Result := GetPageDataDrawItemPageIndex(
          FPageData.GetDrawItemNoByOffset(FPageData.SelectInfo.StartItemNo,
          FPageData.SelectInfo.StartItemOffset))
      end;
    end
    else
      Result := GetPageDataDrawItemPageIndex(FPageData.CaretDrawItemNo);
  end;
end;

function THCSection.GetActiveArea: TSectionArea;
begin
  if FActiveData = FHeader then
    Result := TSectionArea.saHeader
  else
  if FActiveData = FFooter then
    Result := TSectionArea.saFooter
  else
    Result := TSectionArea.saData;
end;

function THCSection.GetActiveDrawItem: THCCustomDrawItem;
begin
  Result := FActiveData.GetActiveDrawItem;
end;

function THCSection.GetActiveDrawItemCoord: TPoint;
begin
  Result := FActiveData.GetActiveDrawItemCoord;
end;

function THCSection.GetActiveItem: THCCustomItem;
begin
  Result := FActiveData.GetActiveItem;
end;

function THCSection.GetCurItem: THCCustomItem;
begin
  FActiveData.GetCurItem;
end;

function THCSection.GetReadOnly: Boolean;
begin
  Result := FHeader.ReadOnly and FFooter.ReadOnly and FPageData.ReadOnly;
end;

function THCSection.GetRichDataAt(const X, Y: Integer): THCRichData;
var
  vPageIndex, vMarginLeft, vMarginRight: Integer;
begin
  Result := nil;
  vPageIndex := GetPageByFilm(Y);
  GetPageMarginLeftAndRight(vPageIndex, vMarginLeft, vMarginRight);
  // ȷ�����ҳ����ʾ����
  if X < 0 then  // ����ҳ��ߵ�MinPadding����TEditArea.eaLeftPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if X > FPageSize.PageWidthPix then  // ����ҳ�ұߵ�MinPadding����TEditArea.eaRightPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if Y < 0 then  // ����ҳ�ϱߵ�MinPadding����TEditArea.eaTopPad
  begin
    Result := FActiveData;
    Exit;
  end;

  if Y > FPageSize.PageHeightPix then  // ֻ�������һҳ�±ߵ�MinPadding������ʱ����TEditArea.eaBottomPad
  begin
    Result := FActiveData;
    Exit;
  end;

  // �߾���Ϣ�������£�������
  if Y > FPageSize.PageHeightPix - FPageSize.PageMarginBottomPix then  // �����ҳ�±߾�����TEditArea.eaMarginBottom
    Exit(FFooter);

  // ҳü����ʵ�ʸ�(ҳü���ݸ߶�>�ϱ߾�ʱ��ȡҳü���ݸ߶�)
  if Y < GetHeaderAreaHeight then  // �����ҳü/�ϱ߾�����TEditArea.eaMarginTop
    Exit(FHeader);

  //if X > FPageSize.PageWidthPix - vMarginRight then Exit;  // �����ҳ�ұ߾�����TEditArea.eaMarginRight
  //if X < vMarginLeft then Exit;  // �����ҳ��߾�����TEditArea.eaMarginLeft
  //���Ҫ�������ұ߾಻�����ģ�ע��˫�����ж�ActiveDataΪnil
  Result := FPageData;
end;

function THCSection.GetDataFmtTopFilm(const AVertical: Integer): Integer;
var
  i, vTop, vContentHeight: Integer;
begin
  Result := 0;
  vTop := 0;
  vContentHeight := FPageSize.PageHeightPix  // ��ҳ����������߶ȣ���ҳ���ҳü��ҳ�ź󾻸�
    - FPageSize.PageMarginBottomPix - GetHeaderAreaHeight;
  for i := 0 to FPages.Count - 1 do
  begin
    vTop := vTop + vContentHeight;
    if vTop >= AVertical then
    begin
      vTop := AVertical - (vTop - vContentHeight);
      Break;
    end
    else
      Result := Result + MinPadding + FPageSize.PageHeightPix;
  end;
  Result := Result + MinPadding + GetHeaderAreaHeight + vTop;
end;

function THCSection.GetPageDataDrawItemPageIndex(const ADrawItemNo: Integer): Integer;
var
  i: Integer;
begin
  // ȡADrawItemNo��ʼλ������ҳ��û�п���ADrawItemNo��ҳ��������Ҫ���ǿɲο�TSection.BuildSectionPages
  Result := 0;
  if ADrawItemNo < 0 then Exit;
  Result := FPages.Count - 1;
  for i := 0 to FPages.Count - 1 do
  begin
    if FPages[i].EndDrawItemNo >= ADrawItemNo then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THCSection.GetFilmHeight: Cardinal;
begin
  Result := FPages.Count * (MinPadding + FPageSize.PageHeightPix);
end;

function THCSection.GetFilmWidth: Cardinal;
begin
  Result := FPages.Count * (MinPadding + FPageSize.PageWidthPix);
end;

function THCSection.GetHeaderAreaHeight: Integer;
begin
  Result := FHeaderOffset + FHeader.Height;
  if Result < FPageSize.PageMarginTopPix then
    Result := FPageSize.PageMarginTopPix;
  //Result := Result + 20;  // debug
end;

function THCSection.GetHeaderPageDrawTop: Integer;
var
  vHeaderHeight: Integer;
begin
  Result := FHeaderOffset;
  vHeaderHeight := FHeader.Height;
  if vHeaderHeight < (FPageSize.PageMarginTopPix - FHeaderOffset) then
    Result := Result + (FPageSize.PageMarginTopPix - FHeaderOffset - vHeaderHeight) div 2;
end;

function THCSection.GetHint: string;
begin
  //Result := '';
  //if FActiveData <> nil then
    Result := FActiveData.GetTopLevelData.GetHint;
end;

function THCSection.GetOnCreateItem: TNotifyEvent;
begin
  Result := FPageData.OnCreateItem;
end;

function THCSection.GetOnInsertItem: TItemNotifyEvent;
begin
  Result := FPageData.OnInsertItem;
end;

function THCSection.GetOnItemPaintAfter: TItemPaintEvent;
begin
  Result := FPageData.OnItemPaintAfter;
end;

function THCSection.GetOnItemPaintBefor: TItemPaintEvent;
begin
  Result := FPageData.OnItemPaintBefor;
end;

function THCSection.GetPageByFilm(const AVOffset: Integer): Integer;
var
  i, vPos: Integer;
begin
  Result := -1;
  vPos := 0;
  for i := 0 to FPages.Count - 1 do
  begin
    vPos := vPos + MinPadding + FPageSize.PageHeightPix;
    if vPos >= AVOffset then  // AVOffset < 0ʱ��2�ֿ��ܣ�1��ǰ�ڵ�һҳǰ���Padding��2����һ����
    begin
      Result := i;
      Break;
    end;
  end;

  if (Result < 0) and (AVOffset > vPos) then  // ͬ�����һҳ���棬��һҳ����
    Result := FPages.Count - 1;

  Assert(Result >= 0, 'û�л�ȡ����ȷ��ҳ��ţ�');
end;

procedure THCSection.GetPageCaretInfo(var ACaretInfo: TCaretInfo);
var
  vMarginLeft, vMarginRight: Integer;
begin
  //if FActiveData = nil then Exit;

  if (FActiveData.SelectInfo.StartItemNo < 0) or (FActivePageIndex < 0) then
  begin
    ACaretInfo.Visible := False;
    Exit;
  end;
  FActiveData.GetCaretInfoCur(ACaretInfo);
  if ACaretInfo.Visible then
  begin
    //APageIndex := GetPageByDataFmt(ACaretInfo.Y);  // ���ڱ���ҳ��GetSelectStartPageIndexֻ��ȡ����ʼҳ������������Ҫ���ݴ�ֱλ�û�ȡ�������ҳ
    GetPageMarginLeftAndRight(FActivePageIndex, vMarginLeft, vMarginRight);
    ACaretInfo.X := ACaretInfo.X + vMarginLeft;
    ACaretInfo.Y := ACaretInfo.Y + GetPageTopFilm(FActivePageIndex);

    if FActiveData = FHeader then
      ACaretInfo.Y := ACaretInfo.Y + GetHeaderPageDrawTop
    else
    if FActiveData = FPageData then
      ACaretInfo.Y := ACaretInfo.Y + GetHeaderAreaHeight - GetPageDataFmtTop(FActivePageIndex)
    else
    if FActiveData = FFooter then
      ACaretInfo.Y := ACaretInfo.Y + FPageSize.PageHeightPix - FPageSize.PageMarginBottomPix;
  end;
end;

function THCSection.GetPageCount: Integer;
begin
  Result := FPages.Count;  // ����ҳ��
end;

function THCSection.GetPageDataFmtTop(const APageIndex: Integer): Integer;
var
  i, vContentHeight: Integer;
begin
  Result := 0;
  if APageIndex > 0 then
  begin
    vContentHeight := FPageSize.PageHeightPix  // ��ҳ����������߶ȣ���ҳ���ҳü��ҳ�ź󾻸�
      - FPageSize.PageMarginBottomPix - GetHeaderAreaHeight;

    for i := 0 to APageIndex - 1 do
      Result := Result + vContentHeight;
  end;
end;

function THCSection.GetPageHeightPix: Integer;
begin
  Result := FPageSize.PageHeightPix;
end;

function THCSection.GetPageMarginBottomPix: Integer;
begin
  Result := FPageSize.PageMarginBottomPix;
end;

function THCSection.GetPageMarginLeft(const APageIndex: Integer): Integer;
var
  vMarginRight: Integer;
begin
  GetPageMarginLeftAndRight(APageIndex, Result, vMarginRight);
end;

procedure THCSection.GetPageMarginLeftAndRight(const APageIndex: Integer;
  var AMarginLeft, AMarginRight: Integer);
begin
  if FSymmetryMargin and Odd(APageIndex) then
  begin
    AMarginLeft := FPageSize.PageMarginRightPix;
    AMarginRight := FPageSize.PageMarginLeftPix;
  end
  else
  begin
    AMarginLeft := FPageSize.PageMarginLeftPix;
    AMarginRight := FPageSize.PageMarginRightPix;
  end;
end;

function THCSection.GetPageMarginLeftPix: Integer;
begin
  Result := FPageSize.PageMarginLeftPix;
end;

function THCSection.GetPageMarginRightPix: Integer;
begin
  Result := FPageSize.PageMarginRightPix;
end;

function THCSection.GetPageMarginTopPix: Integer;
begin
  Result := FPageSize.PageMarginTopPix;
end;

function THCSection.GetPageTopFilm(const APageIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := MinPadding;
  for i := 0 to APageIndex - 1 do
    Result := Result + FPageSize.PageHeightPix + MinPadding;  // ÿһҳ��������ķָ���Ϊһ��������Ԫ
end;

function THCSection.GetPageWidthPix: Integer;
begin
  Result := FPageSize.PageWidthPix;
end;

function THCSection.GetPaperHeight: Single;
begin
  Result := FPageSize.PaperHeight;
end;

function THCSection.GetPaperMarginBottom: Single;
begin
  Result := FPageSize.PaperMarginBottom;
end;

function THCSection.GetPaperMarginLeft: Single;
begin
  Result := FPageSize.PaperMarginLeft;
end;

function THCSection.GetPaperMarginRight: Single;
begin
  Result := FPageSize.PaperMarginRight;
end;

function THCSection.GetPaperMarginTop: Single;
begin
  Result := FPageSize.PaperMarginTop;
end;

function THCSection.GetPaperSize: Integer;
begin
  Result := FPageSize.PaperSize;
end;

function THCSection.GetPaperWidth: Single;
begin
  Result := FPageSize.PaperWidth;
end;

function THCSection.InsertBreak: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FPageData.InsertBreak;
    end);
end;

function THCSection.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertItem(AIndex, AItem);
    end);
end;

function THCSection.InsertItem(const AItem: THCCustomItem): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertItem(AItem);
    end);
end;

function THCSection.InsertLine(const ALineHeight: Integer): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertLine(ALineHeight);
    end);
end;

function THCSection.InsertPageBreak: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FPageData.InsertPageBreak;
    end);
end;

function THCSection.ActiveDataChangeByAction(const AProc: TChangeProc): Boolean;
var
  vHeight, vDrawItemCount, vNewDrawItemCount, vCurItemNo, vNewItemNo: Integer;
begin
  if not FActiveData.CanEdit then Exit(False);

  // ��¼�䶯ǰ��״̬
  vHeight := FActiveData.Height;
  // Ӧ��ѡ���ı���ʽ�Ȳ�������������߶ȱ仯����������DrawItem�����仯
  // Ҳ��Ҫ���¼����ҳ��ʼ����DrawItem
  vDrawItemCount := FActiveData.DrawItems.Count;
  vCurItemNo := FActiveData.GetCurItemNo;

  Result := AProc;  // ����䶯

  // �䶯���״̬
  vNewItemNo := FActiveData.GetCurItemNo;  // �䶯��ĵ�ǰItemNo
  vNewDrawItemCount := FActiveData.DrawItems.Count;
  if vNewItemNo < 0 then  // ����䶯��С��0������Ϊ��0��
    vNewItemNo := 0;

  DoActiveDataChanged(Min(vCurItemNo, vNewItemNo),  // vCurItemNo�����һ��ʱ����ʽ�޸ĺϲ���ǰһ���󲻴����ˣ�����ȡ��ΧС��
    (vDrawItemCount <> vNewDrawItemCount) or (vHeight <> FActiveData.Height));
end;

function THCSection.InsertStream(const AStream: TStream; const AStyle: THCStyle;
  const AFileVersion: Word): Boolean;
var
  vResult: Boolean;
begin
  Result := False;
  ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertStream(AStream, AStyle, AFileVersion);
      vResult := Result;
    end);
  Result := vResult;
end;

function THCSection.InsertTable(const ARowCount, AColCount: Integer): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertTable(ARowCount, AColCount);
    end);
end;

function THCSection.InsertText(const AText: string): Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.InsertText(AText);
    end);
end;

procedure THCSection.KeyDown(var Key: Word; Shift: TShiftState);
var
  vKey: Word;
begin
  if not FActiveData.CanEdit then Exit;

  if IsKeyDownWant(Key) then
  begin
    vKey := Key;
    case Key of
      VK_BACK, VK_DELETE, VK_RETURN, VK_TAB:
        begin
          ActiveDataChangeByAction(function(): Boolean
            begin
              FActiveData.KeyDown(vKey, Shift);
            end);

          Key := vKey;
        end;

      VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END:
        begin
          FActiveData.KeyDown(Key, Shift);
          DoActiveDataCheckUpdateInfo;
        end;
    end;
  end;
end;

procedure THCSection.KeyPress(var Key: Char);
var
  vKey: Char;
begin
  if not FActiveData.CanEdit then Exit;

  if IsKeyPressWant(Key) then
  begin
    vKey := Key;
    ActiveDataChangeByAction(function(): Boolean
      begin
        FActiveData.KeyPress(vKey);
      end);
    Key := vKey;
  end
  else
    Key := #0;
end;

procedure THCSection.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if not FActiveData.CanEdit then Exit;
  FActiveData.KeyUp(Key, Shift);
end;

procedure THCSection.KillFocus;
begin
  //if FActiveData <> nil then
    FActiveData.KillFocus;
end;

procedure THCSection.LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
  const AFileVersion: Word);
var
  vDataSize: Int64;
  vArea: Boolean;
  vLoadParts: TSaveParts;
begin
  AStream.ReadBuffer(vDataSize, SizeOf(vDataSize));

  AStream.ReadBuffer(FSymmetryMargin, SizeOf(FSymmetryMargin));

  FPageSize.LoadToStream(AStream, AFileVersion);  // ҳ�����
  with FPageSize do
    FPageData.Width := PageWidthPix - PageMarginLeftPix - PageMarginRightPix;

  // �ĵ�������Щ����������
  vLoadParts := [];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saHeader];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saFooter];
  AStream.ReadBuffer(vArea, SizeOf(vArea));
  if vArea then
    vLoadParts := vLoadParts + [saData];

  if saHeader in vLoadParts then
  begin
    AStream.ReadBuffer(FHeaderOffset, SizeOf(FHeaderOffset));
    FHeader.Width := FPageData.Width;
    FHeader.LoadFromStream(AStream, FStyle, AFileVersion);
  end;

  if saFooter in vLoadParts then
  begin
    FFooter.Width := FPageData.Width;
    FFooter.LoadFromStream(AStream, FStyle, AFileVersion);
  end;

  if saData in vLoadParts then
    FPageData.LoadFromStream(AStream, FStyle, AFileVersion);

  BuildSectionPages(0);
end;

procedure THCSection.LoadFromText(const AFileName: string;
  const AEncoding: TEncoding);
begin
  FPageData.LoadFromText(AFileName, AEncoding);
  BuildSectionPages(0);
end;

procedure THCSection.MarkStyleUsed(const AMark: Boolean;
  const AParts: TSaveParts = [saHeader, saData, saFooter]);
begin
  if saHeader in AParts then
    FHeader.MarkStyleUsed(AMark);

  if saFooter in AParts then
    FFooter.MarkStyleUsed(AMark);

  if saData in AParts then
    FPageData.MarkStyleUsed(AMark);
end;

function THCSection.MergeTableSelectCells: Boolean;
begin
  Result := ActiveDataChangeByAction(function(): Boolean
    begin
      Result := FActiveData.MergeTableSelectCells;
    end);
end;

procedure THCSection.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vX, vY, vPageIndex: Integer;
  vNewActiveData: THCRichData;
  vChangeActiveData: Boolean;
begin
  vChangeActiveData := False;
  vPageIndex := GetPageByFilm(Y);
  if FActivePageIndex <> vPageIndex then
    FActivePageIndex := vPageIndex;

  SectionToPage(vPageIndex, X, Y, vX, vY);  // X,Yת����ָ��ҳ������vX,vY

  vNewActiveData := GetRichDataAt(vX, vY);

  if vNewActiveData <> FActiveData then  // �µ�Data
  begin
    if ssDouble in Shift then  // ˫��
    begin
      FActiveData.DisActive;  // ȡ������
      FActiveData := vNewActiveData;
      vChangeActiveData := True;
    end
    else
      Exit;
  end;

  PageCoordToDataCoord(vPageIndex, FActiveData, vX, vY);
  vY := vY + GetPageDataFmtTop(vPageIndex);

  //if FActiveData <> nil then
  begin
    if (ssDouble in Shift) and (not vChangeActiveData) then  // ��ͬһData��˫��
      FActiveData.DblClick(vX, vY)
    else
    //if FActiveData <> nil then
      FActiveData.MouseDown(Button, Shift, vX, vY);
  end;
end;

procedure THCSection.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vPageIndex, vMarginLeft, vMarginRight: Integer;

  function GetCursor: TCursor;
  begin
    Result := crDefault;
    GetPageMarginLeftAndRight(vPageIndex, vMarginLeft, vMarginRight);
    if (X > vMarginLeft) and (X < FPageSize.PageWidthPix - vMarginRight) then
      Result := crIBeam;
  end;

var
  vX, vY: Integer;
  //vMoveData: THCRichData;
begin
  vPageIndex := GetPageByFilm(Y);
  if vPageIndex < 0 then Exit;

  SectionToPage(vPageIndex, X, Y, vX, vY);

  //if Shift <> [] then  // �в���ʱ�жϣ����ڵ�ǰ����Data��ʱ������(�������ҳ�滮ѡ��ҳ��ʱ���ټ�����ѡ�н���λ��)
  {vMoveData := GetRichDataAt(vX, vY);
  if vMoveData <> FActiveData then
  begin
    if not (FActiveData.GetTopLevelData.GetActiveItem is THCResizeRectItem) then
      Exit;  // ���ڵ�ǰ�����Data���ƶ�
  end;}

  PageCoordToDataCoord(vPageIndex, FActiveData, vX, vY);
  vY := vY + GetPageDataFmtTop(vPageIndex);

  GCursor := GetCursor;

  //if FActiveData <> nil then
    FActiveData.MouseMove(Shift, vX, vY);
end;

procedure THCSection.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vX, vY, vPageIndex: Integer;
begin
  vPageIndex := GetPageByFilm(Y);
  SectionToPage(vPageIndex, X, Y, vX, vY);

  //if GetRichDataAt(vX, vY) <> FActiveData then Exit;  // ���ڵ�ǰ�����Data��

  PageCoordToDataCoord(vPageIndex, FActiveData, vX, vY);
  vY := vY + GetPageDataFmtTop(vPageIndex);

  //if FActiveData <> nil then
  begin
    // RectItem��������MouseUp�д���������Ҫ�ж��Ƿ���Ҫ�ı�
    if FActiveData.SelectedResizing then
    begin
      ActiveDataChangeByAction(function(): Boolean
        begin
          FActiveData.MouseUp(Button, Shift, vX, vY);
        end);
    end
    else
      FActiveData.MouseUp(Button, Shift, vX, vY);
  end;
end;

function THCSection.NewEmptyPage: THCPage;
begin
  Result := THCPage.Create;
  FPages.Add(Result);
end;

procedure THCSection.PageCoordToDataCoord(const APageIndex: Integer;
  const AData: THCRichData; var AX, AY: Integer);
{var
  viTemp: Integer;}
begin
  AX := AX - GetPageMarginLeft(APageIndex);
  {if True then  // Ϊ����߽磬Լ����ƫ��1
  begin
    if AX < 0 then
      AX := 1
    else
    begin
      viTemp := FPageSize.PageWidthPix - FPageSize.PageMarginRightPix;
      if AX > viTemp then
        AX := viTemp - 1;
    end;
  end;}
  if AData = FHeader then
    AY := AY - GetHeaderPageDrawTop
  else
  if AData = FFooter then
    AY := AY - FPageSize.PageHeightPix + FPageSize.PageMarginBottomPix
  else
  if AData = FPageData then
  begin
    AY := AY - GetHeaderAreaHeight;
    {if True then  // Ϊ������һҳ����һҳü�߽粻ȷ�����ϻ����£�Լ����ƫ��1
    begin
      if AY < 0 then
        AY := 1  // ���������ģ���ҳüҳ���е��
      else
      begin
        viTemp := FPageSize.PageHeightPix - GetHeaderAreaHeight - FPageSize.PageMarginBottomPix;
        if AY > viTemp then
          AY := viTemp - 1;
      end;
    end;}
  end;
end;

procedure THCSection.PaintDisplayPage(const AFilmOffsetX, AFilmOffsetY, ADisplayWidth, ADisplayHeight: Integer;
  const AZoom: Single; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
var
  i, vPageDrawLeft, vPageDrawTop, vPageFilmTop: Integer;
begin
  vPageDrawLeft := AFilmOffsetX;
  //vHeaderAreaHeight := GetHeaderAreaHeight;  // ҳü����ʵ�ʸ�(���ݸ߶�>�ϱ߾�ʱȡ���ݸ߶�)
  for i := FDisplayFirstPageIndex to FDisplayLastPageIndex do
  begin
    APaintInfo.PageIndex := i;
    vPageFilmTop := GetPageTopFilm(i);
    vPageDrawTop := vPageFilmTop - AFilmOffsetY;  // ӳ�䵽��ǰҳ��Ϊԭ���������ʼλ��(��Ϊ����)
    PaintPage(i, vPageDrawLeft, vPageDrawTop, ADisplayWidth, ADisplayHeight,
      AZoom, AZoom, ACanvas, APaintInfo);
  end;
end;

procedure THCSection.PaintPage(const APageIndex, ALeft, ATop,
  AWidth, AHeight: Integer; const AScaleX, AScaleY: Single;
  ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);
var
  vHeaderAreaHeight, vMarginLeft, vMarginRight,
  vPageDrawLeft, vPageDrawRight, vPageDrawTop, vPageDrawBottom,  // ҳ�����λ��
  vPageDataScreenTop, vPageDataScreenBottom  // ҳ������Ļλ��
    : Integer;

  vSectionPageStart,  // �ڵĵ�һҳ��ȫ������ʼ���
  vAllPageCount: Integer;  // ȫ����ҳ��

  function GetScaleX(const Value: Integer): Integer;
  begin
    Result := Round(Value * AScaleX);
  end;

  function GetScaleY(const Value: Integer): Integer;
  begin
    Result := Round(Value * AScaleY);
  end;

  {$REGION 'ҳü'}
  procedure PaintHeader;
  var
    vHeaderDataDrawTop, vHeaderDataDrawBottom: Integer;
  begin
    vHeaderDataDrawTop := vPageDrawTop + GetHeaderPageDrawTop;
    vHeaderDataDrawBottom := vPageDrawTop + vHeaderAreaHeight;
    FHeader.PaintData(vPageDrawLeft + vMarginLeft, vHeaderDataDrawTop, vHeaderDataDrawBottom,
      Max(vHeaderDataDrawTop, 0),
      Min(vHeaderDataDrawBottom, AWidth), 0, ACanvas, APaintInfo);

    if FActiveData = FHeader then  // ��ǰ�������ҳü
    begin
      ACanvas.Pen.Color := clBlue;
      ACanvas.MoveTo(vPageDrawLeft, vHeaderDataDrawBottom);
      ACanvas.LineTo(vPageDrawRight, vHeaderDataDrawBottom);
    end;

    if Assigned(FOnPaintHeader) then
      FOnPaintHeader(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft, vHeaderDataDrawTop,
        vPageDrawRight - vMarginRight, vHeaderDataDrawBottom), ACanvas, APaintInfo);
  end;
  {$ENDREGION}

  {$REGION 'ҳ��'}
  procedure PaintFooter;
  var
    vY: Integer;
    vS: string;
  begin
    vY := vPageDrawBottom - FPageSize.PageMarginBottomPix;
    //ACanvas.TextOut(vPageDrawLeft + vMarginLeft, vY, 'ҳ��');
    FFooter.PaintData(vPageDrawLeft + vMarginLeft, vY, vPageDrawBottom,
      Max(vY, 0), Min(vPageDrawBottom, AHeight), 0, ACanvas, APaintInfo);
    if FPageNoVisible then  // ����ҳ��
    begin
      vS := Format('%d/%d', [vSectionPageStart + APageIndex + FPageNoFrom, vAllPageCount {FPages.Count}]);
      ACanvas.Brush.Style := bsClear;
      ACanvas.TextOut(vPageDrawLeft + (PageWidthPix - ACanvas.TextWidth(vS)) div 2, vY, vS);
    end;

    if FActiveData = FFooter then  // ��ǰ�������ҳ��
    begin
      ACanvas.Pen.Color := clBlue;
      ACanvas.MoveTo(vPageDrawLeft, vY);
      ACanvas.LineTo(vPageDrawRight, vY);
    end;

    if Assigned(FOnPaintFooter) then
      FOnPaintFooter(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft, vY,
        vPageDrawRight - vMarginRight, vPageDrawBottom), ACanvas, APaintInfo);
  end;
  {$ENDREGION}

  {$REGION '����ҳ������'}
  procedure PaintPageData;
  var
    vPageDataFmtTop: Integer;
  begin
    if (FPages[APageIndex].StartDrawItemNo < 0) or (FPages[APageIndex].EndDrawItemNo < 0) then
      Exit;

    //vPageDataOffsetX := Max(AFilmOffsetX - vPageDrawLeft - PageMarginLeftPix, 0);
    { ��ǰҳ�ڵ�ǰ���Գ��������ݱ߽�ӳ�䵽��ʽ���еı߽� }
    vPageDataFmtTop := GetPageDataFmtTop(APageIndex);

    { �������ݣ���Data��ָ��λ�õ����ݣ����Ƶ�ָ����ҳ�����У������տ���ʾ����������Լ�� }
    FPageData.PaintData(vPageDrawLeft + vMarginLeft,  // ��ǰҳ����Ҫ���Ƶ���Left
      vPageDrawTop + vHeaderAreaHeight,     // ��ǰҳ����Ҫ���Ƶ���Top
      vPageDrawBottom - PageMarginBottomPix,  // ��ǰҳ����Ҫ���Ƶ�Bottom
      vPageDataScreenTop,     // ������ֵ�ǰҳ���ݵ�Topλ��
      vPageDataScreenBottom,  // ������ֵ�ǰҳ����Bottomλ��
      vPageDataFmtTop,  // ָ�����ĸ�λ�ÿ�ʼ�����ݻ��Ƶ�ҳ������ʼλ��
      ACanvas,
      APaintInfo);

    if Assigned(FOnPaintData) then
    begin
      FOnPaintData(Self, APageIndex, Rect(vPageDrawLeft + vMarginLeft,
        vPageDrawTop + vHeaderAreaHeight, vPageDrawRight - vMarginRight,
        vPageDrawBottom - PageMarginBottomPix), ACanvas, APaintInfo);
    end;
  end;
  {$ENDREGION}

var
  vZoomInfo : TZoomInfo;
  vX, vY: Integer;
begin
  if FPageNoVisible then
   FOnGetPageInfo(Self, vSectionPageStart, vAllPageCount);

  vPageDrawLeft := ALeft;
  vPageDrawRight := vPageDrawLeft + FPageSize.PageWidthPix;

  vHeaderAreaHeight := GetHeaderAreaHeight;  // ҳü����ʵ�ʸ� = ҳü���ݶ���ƫ�� + ���ݸ߶ȣ������ϱ߾�ʱ�Դ�Ϊ׼
  GetPageMarginLeftAndRight(APageIndex, vMarginLeft, vMarginRight);  // ��ȡҳ���ұ߾����λ��

  vPageDrawTop := ATop;  // ӳ�䵽��ǰҳ�����Ͻ�Ϊԭ�����ʼλ��(��Ϊ����)
  vPageDrawBottom := vPageDrawTop + FPageSize.PageHeightPix;  // ҳ�����λ��(��Ϊ����)
  // ��ǰҳ����ʾ����������߽�
  //vPageScreenTop := Max(vPageDrawTop, 0);
  //vPageScreenBottom := Min(vPageDrawBottom, AHeight);
  // ��ǰҳ��������ʾ����������߽�
  vPageDataScreenTop := Max(vPageDrawTop + vHeaderAreaHeight, 0);
  vPageDataScreenBottom := Min(vPageDrawBottom - FPageSize.PageMarginBottomPix, AHeight);

  APaintInfo.PageDrawRight := vPageDrawRight;

  { ���ҳ�汳�� }
  if not APaintInfo.Print then
  begin
    ACanvas.Brush.Color := FStyle.BackgroudColor;
    ACanvas.FillRect(Rect(GetScaleX(vPageDrawLeft), GetScaleY(vPageDrawTop),
        GetScaleX(Min(vPageDrawLeft + FPageSize.PageWidthPix, AWidth)),  // Լ���߽�
        GetScaleY(Min(vPageDrawTop + FPageSize.PageHeightPix, AHeight))));
  end;

  {$REGION 'ҳü�ı߾�'}
  if vPageDrawTop + vHeaderAreaHeight > 0 then  // ҳü����ʾ
  begin
    vY := vPageDrawTop + vHeaderAreaHeight;
    if vHeaderAreaHeight > FPageSize.PageMarginTopPix then  // ҳü���ݳ���ҳ�ϱ߾�
    begin
      ACanvas.Pen.Color := clGreen;
      ACanvas.MoveTo(GetScaleX(vPageDrawLeft), GetScaleY(vY - 1));
      ACanvas.LineTo(GetScaleX(vPageDrawRight), GetScaleY(vY - 1));
    end;
    ACanvas.Pen.Color := clGray;
    ACanvas.Pen.Style := TPenStyle.psSolid;
      // ���ϣ� ��-ԭ-��
    vX := GetScaleX(vPageDrawLeft + vMarginLeft);
    vY := GetScaleY(vPageDrawTop + FPageSize.PageMarginTopPix);
    ACanvas.MoveTo(vX - GetScaleX(PMSLineHeight), vY);
    ACanvas.LineTo(vX, vY);
    ACanvas.LineTo(vX, vY - GetScaleY(PMSLineHeight));
    // ���ϣ���-ԭ-��
    vX := GetScaleX(vPageDrawRight - vMarginRight);
    ACanvas.MoveTo(vX + GetScaleX(PMSLineHeight), vY);
    ACanvas.LineTo(vX, vY);
    ACanvas.LineTo(vX, vY - GetScaleY(PMSLineHeight));
  end;
  {$ENDREGION}

  {$REGION 'ҳ�ŵı߾�'}
  if vPageDrawBottom - FPageSize.PageMarginBottomPix < AHeight then  // ҳ�ſ���ʾ
  begin
    ACanvas.Pen.Color := clGray;
    ACanvas.Pen.Style := TPenStyle.psSolid;
    //vY := vPageDrawBottom - FPageSize.PageMarginBottomPix;
    // ���£���-ԭ-��
    vX := GetScaleX(vPageDrawLeft + vMarginLeft);
    vY := GetScaleY(vPageDrawBottom - FPageSize.PageMarginBottomPix);
    ACanvas.MoveTo(vX - GetScaleX(PMSLineHeight), vY);
    ACanvas.LineTo(vX, vY);
    ACanvas.LineTo(vX, vY + GetScaleY(PMSLineHeight));
    // ���£���-ԭ-��
    vX := GetScaleX(vPageDrawRight - vMarginRight);
    ACanvas.MoveTo(vX + GetScaleX(PMSLineHeight), vY);
    ACanvas.LineTo(vX, vY);
    ACanvas.LineTo(vX, vY + GetScaleY(PMSLineHeight));
  end;
  {$ENDREGION}

  // ������Ҫ�п��˴���һ��FDisplayWidth��FDisplayHeightԼ������ʱ��Ч��
  vZoomInfo := ZoomCanvas(ACanvas, AScaleX, AScaleY);
  try
    if vPageDrawTop + vHeaderAreaHeight > 0 then  // ҳü����ʾ
      PaintHeader;

    if vPageDrawBottom - FPageSize.PageMarginBottomPix < AHeight then  // ҳ�ſ���ʾ
      PaintFooter;

    if vPageDataScreenBottom > vPageDataScreenTop then  // ��¶����������Ƶ�ǰҳ����������
      PaintPageData;

    if Assigned(FOnPaintPage) then
    begin
      FOnPaintPage(Self, APageIndex,
        Rect(vPageDrawLeft, vPageDrawTop, vPageDrawRight, vPageDrawBottom),
        ACanvas, APaintInfo);
    end;
  finally
    RestoreCanvasZoom(ACanvas, vZoomInfo);
  end;
end;

procedure THCSection.BuildSectionPages(const AStartItemNo: Integer);
var
  vPageIndex, vPageDataFmtTop, vPageDataFmtBottom, vContentHeight,
  vSuplus,  // ������ҳ����ƫ�������ܺ�
  vBreakSeat  // ��ҳλ�ã���ͬRectItem�ĺ��岻ͬ������ʾ vBreakRow
    : Integer;

  {$REGION '_FormatNewPage'}
  procedure _FormatNewPage(const APrioEndDItemNo, ANewStartDItemNo: Integer);
  var
    vPage: THCPage;
  begin
    FPages[vPageIndex].EndDrawItemNo := APrioEndDItemNo;
    vPage := THCPage.Create;
    vPage.StartDrawItemNo := ANewStartDItemNo;
    FPages.Insert(vPageIndex + 1, vPage);
    Inc(vPageIndex);
  end;
  {$ENDREGION}

  {$REGION '_FormatTableNorCheckPage'}
//  procedure _FormatTableNorCheckPage(const ADItemNo, AStartRowNo: Integer; const ATableItem: TTableItem);
//  var
//    vHeightInc: Integer;
//  begin
//    if DrawItems[ADItemNo].Rect.Bottom > vPageDataFmtBottom then  // ��ǰҳ�Ų��±������
//    begin
//      ATableItem.CheckFormatPage(
//        DrawItems[ADItemNo].Rect.Top,  // ���Ķ���λ��
//        vPageDataFmtTop,
//        vPageDataFmtBottom,  // ��ǰҳ�����ݵײ�λ��
//        AStartRowNo,
//        vBreakRow,  // ��ǰҳ��ҳ����
//        vHeightInc  // ��ǰ�и���Ϊ�˱ܿ���ҳλ�ö���ƫ�Ƶ����߶�
//        );
//      DrawItems[ADItemNo].Rect.Bottom :=  // �����ʽ���߶�
//        DrawItems[ADItemNo].Rect.Bottom + vHeightInc;
//      vSuplus := vSuplus + vHeightInc;
//      vPageDataFmtTop := vPageDataFmtBottom;
//      vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
//      if vBreakRow = 0 then  // ��һ�оͿ絽��һҳ��
//        _FormatNewPage(ADItemNo - 1, ADItemNo)  // �½�ҳ
//      else
//        _FormatNewPage(ADItemNo, ADItemNo);  // �½�ҳ
//      _FormatTableNorCheckPage(ADItemNo, vBreakRow, ATableItem);
//    end;
//    //DrawItems[vDrawItemNo].Rect.Bottom := DrawItems[vDrawItemNo].Rect.Bottom + vSuplus;
//  end;
  {$ENDREGION}

  {$REGION '_FormatRectItemCheckPage'}
  procedure _FormatRectItemCheckPage(const ADrawItemNo: Integer);
  var
    vRectItem: THCCustomRectItem;

    {$REGION '_FormatCheckPage'}
    procedure _FormatCheckPage(const AStartSeat: Integer);  // ��ʼ��ҳ�����λ�ã���ͬRectItem���岻ͬ������ʾAStartRowNo
    var
      vFmtHeightInc, vFmtOffset: Integer;
      vDrawRect: TRect;
    begin
      if FPageData.GetDrawItemStyle(ADrawItemNo) = THCStyle.RsPageBreak then
      begin
        vFmtOffset := vPageDataFmtBottom - FPageData.DrawItems[ADrawItemNo].Rect.Top;

        vSuplus := vSuplus + vFmtOffset;
        if vFmtOffset > 0 then  // ���������ƶ���
          OffsetRect(FPageData.DrawItems[ADrawItemNo].Rect, 0, vFmtOffset);

        vPageDataFmtTop := vPageDataFmtBottom;
        vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;

        _FormatNewPage(ADrawItemNo - 1, ADrawItemNo)  // �½�ҳ
      end
      else
      if FPageData.DrawItems[ADrawItemNo].Rect.Bottom > vPageDataFmtBottom then  // ��ǰҳ�Ų��±������
      begin
        vDrawRect := FPageData.DrawItems[ADrawItemNo].Rect;
        InflateRect(vDrawRect, 0, -FStyle.ParaStyles[FPageData.Items[FPageData.DrawItems[ADrawItemNo].ItemNo].ParaNo].LineSpaceHalf);
        vRectItem.CheckFormatPage(
          vDrawRect.Top,  // ���Ķ���λ�� FPageData.DrawItems[ADrawItemNo].Rect.Top,
          vDrawRect.Bottom,  // ���ĵײ�λ�� FPageData.DrawItems[ADrawItemNo].Rect.Bottom,
          vPageDataFmtTop,
          vPageDataFmtBottom,  // ��ǰҳ�����ݵײ�λ��
          AStartSeat,
          vBreakSeat,  // ��ǰҳ��ҳ����(λ��)
          vFmtOffset,  // ��ǰRectItemΪ�˱ܿ���ҳλ����������ƫ�Ƶĸ߶�
          vFmtHeightInc  // ��ǰ�и���Ϊ�˱ܿ���ҳλ�õ�Ԫ�����ݶ���ƫ�Ƶ����߶�
          );

        vSuplus := vSuplus + vFmtOffset + vFmtHeightInc;

        if vFmtOffset > 0 then  // ���������ƶ���
          OffsetRect(FPageData.DrawItems[ADrawItemNo].Rect, 0, vFmtOffset);

        FPageData.DrawItems[ADrawItemNo].Rect.Bottom :=  // �����ʽ���߶�
          FPageData.DrawItems[ADrawItemNo].Rect.Bottom + vFmtHeightInc;
        vRectItem.Height := vRectItem.Height + vFmtHeightInc;  // �������ﴦ���ػ�����RectItem�ڲ������ʣ�

        vPageDataFmtTop := vPageDataFmtBottom;
        vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
        if (vBreakSeat = 0) and (vFmtOffset > 0) then  // ��һ�оͿ絽��һҳ�ˣ����Ǳ�����������ƶ�
          _FormatNewPage(ADrawItemNo - 1, ADrawItemNo)  // �½�ҳ
        else
          _FormatNewPage(ADrawItemNo, ADrawItemNo);  // �½�ҳ
        _FormatCheckPage(vBreakSeat);  // �ӷ�ҳλ�ú����������Ƿ��ҳ
      end;
    end;
    {$ENDREGION}

  var
    i: Integer;
  begin
    vRectItem := FPageData.Items[FPageData.DrawItems[ADrawItemNo].ItemNo] as THCCustomRectItem;
    vSuplus := 0;
    {if ARectItem.StyleNo = THCStyle.RsTable then
    begin
      vBreakRow := 0;
      _FormatTableNorCheckPage(ADrawItemNo, 0, ARectItem as TTableItem);  // �������������Ƿ�����ʾ�ڵ�ǰҳ
    end;}
    vBreakSeat := 0;
    _FormatCheckPage(0);  // ���ʼλ�ã��������������Ƿ�����ʾ�ڵ�ǰҳ

    if vSuplus > 0 then
    begin
      for i := ADrawItemNo + 1 to FPageData.DrawItems.Count - 1 do
        OffsetRect(FPageData.DrawItems[i].Rect, 0, vSuplus);
    end;
  end;
  {$ENDREGION}

  {$REGION '_FormatTextItemCheckPage'}
  procedure _FormatTextItemCheckPage(const ADrawItemNo: Integer);
  var
    i, vH: Integer;
  begin
    //if not DrawItems[ADrawItemNo].LineFirst then Exit; // ע��������ֻ���ʱ����Ͳ���ֻ�ж��е�1��
    if FPageData.DrawItems[ADrawItemNo].Rect.Bottom > vPageDataFmtBottom then
    begin
      vH := vPageDataFmtBottom - FPageData.DrawItems[ADrawItemNo].Rect.Top;
      for i := ADrawItemNo to FPageData.DrawItems.Count - 1 do
        OffsetRect(FPageData.DrawItems[i].Rect, 0, vH);

      vPageDataFmtTop := vPageDataFmtBottom;
      vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;
      _FormatNewPage(ADrawItemNo - 1, ADrawItemNo); // �½�ҳ
    end;
  end;
  {$ENDREGION}

var
  i, vPrioDrawItemNo: Integer;
  vPage: THCPage;
begin
  if AStartItemNo > 0 then
    vPrioDrawItemNo := FPageData.GetItemLastDrawItemNo(AStartItemNo - 1)  // ��һ������DItem
  else
    vPrioDrawItemNo := -1;

  // ��һ��DrawItemNo����ҳ��Ϊ��ʽ����ʼҳ
  vPageIndex := -1;
  if vPrioDrawItemNo < 0 then  // û��DrawItem����0ҳ
    vPageIndex := 0
  else  // ָ����DrawItemNo
  begin
    for i := FPages.Count - 1 downto 0 do  // ���ڿ�ҳ�ģ������λ������ҳ�����Ե���
    begin
      vPage := FPages[i];
      if (vPrioDrawItemNo >= vPage.StartDrawItemNo)
        and (vPrioDrawItemNo <= vPage.EndDrawItemNo)
      then  // ��Ϊ�����п�ҳ��������Ҫ�ж���ʼ����������
      begin
        vPageIndex := i;
        Break;
      end;
    end;
  end;

  // ��Ϊ���׿����Ƿ�ҳ��������Ҫ�����׿�ʼ�жϿ�ҳ
  for i := FPageData.Items[AStartItemNo].FirstDItemNo downto 0 do
  begin
    if FPageData.DrawItems[i].LineFirst then
    begin
      vPrioDrawItemNo := i;
      Break;
    end;
  end;

  if vPrioDrawItemNo = FPages[vPageIndex].StartDrawItemNo then  // ������ҳ�ĵ�һ��DrawItem
  begin
    FPages.DeleteRange(vPageIndex, FPages.Count - vPageIndex);  // ɾ����ǰҳһֱ�����

    // ����һҳ���ʼ�����ҳ
    Dec(vPageIndex);
    if vPageIndex >= 0 then
      FPages[vPageIndex].EndDrawItemNo := -1;
  end
  else  // ���ײ���ҳ�ĵ�һ��DrawItem
    FPages.DeleteRange(vPageIndex + 1, FPages.Count - vPageIndex - 1);  // ɾ����ǰҳ����ģ�׼����ʽ��

  if FPages.Count = 0 then  // ɾ��û�ˣ������һ��Page
  begin
    vPage := THCPage.Create;
    vPage.StartDrawItemNo := vPrioDrawItemNo;
    FPages.Add(vPage);
    vPageIndex := 0;
  end;

  vPageDataFmtTop := GetPageDataFmtTop(vPageIndex);
  vContentHeight := PageHeightPix - PageMarginBottomPix - GetHeaderAreaHeight;
  vPageDataFmtBottom := vPageDataFmtTop + vContentHeight;

  for i := vPrioDrawItemNo to FPageData.DrawItems.Count - 1 do
  begin
    if FPageData.DrawItems[i].LineFirst then
    begin
      if FPageData.Items[FPageData.DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then
        _FormatRectItemCheckPage(i)
      else
        _FormatTextItemCheckPage(i);
    end;
  end;

  FPages[vPageIndex].EndDrawItemNo := FPageData.DrawItems.Count - 1;
  FActivePageIndex := GetCurrentPage;
end;

procedure THCSection.ReFormatActiveItem;
begin
  ActiveDataChangeByAction(function(): Boolean
    begin
      FActiveData.ReFormatActiveItem;
    end);
end;

procedure THCSection.ReMarginPaper;
begin
  with FPageSize do
    FPageData.Width := PageWidthPix - PageMarginLeftPix - PageMarginRightPix;

  FPageData.ReFormat(0);

  FHeader.Width := FPageData.Width;
  FHeader.ReFormat(0);

  FFooter.Width := FPageData.Width;
  FFooter.ReFormat(0);

  BuildSectionPages(0);

  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret(False);

  DoDataChanged(Self);
end;

procedure THCSection.RestoreCanvasZoom(const ACanvas: TCanvas;
  const AOldInfo: TZoomInfo);
begin
  SetViewportOrgEx(ACanvas.Handle, AOldInfo.ViewportOrg.cx, AOldInfo.ViewportOrg.cy, nil);
  SetViewportExtEx(ACanvas.Handle, AOldInfo.ViewportExt.cx, AOldInfo.ViewportExt.cy, nil);
  SetWindowOrgEx(ACanvas.Handle, AOldInfo.WindowOrg.cx, AOldInfo.WindowOrg.cy, nil);
  SetWindowExtEx(ACanvas.Handle, AOldInfo.WindowExt.cx, AOldInfo.WindowExt.cy, nil);
  SetMapMode(ACanvas.Handle, AOldInfo.MapMode);
end;

procedure THCSection.SaveToStream(const AStream: TStream;
  const ASaveParts: TSaveParts = [saHeader, saData, saFooter]);
var
  vBegPos, vEndPos: Int64;
  vArea: Boolean;
begin
  vBegPos := AStream.Position;
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ���ݴ�Сռλ������Խ��
  //
  if ASaveParts <> [] then
  begin
    AStream.WriteBuffer(FSymmetryMargin, SizeOf(FSymmetryMargin));
    FPageSize.SaveToStream(AStream);  // ҳ�����

    vArea := saHeader in ASaveParts;  // ��ҳü
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    vArea := saFooter in ASaveParts;  // ��ҳ��
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    vArea := saData in ASaveParts;  // ��ҳ��
    AStream.WriteBuffer(vArea, SizeOf(vArea));

    if saHeader in ASaveParts then  // ��ҳü
    begin
      AStream.WriteBuffer(FHeaderOffset, SizeOf(FHeaderOffset));
      FHeader.SaveToStream(AStream);
    end;

    if saFooter in ASaveParts then  // ��ҳ��
      FFooter.SaveToStream(AStream);

    if saData in ASaveParts then  // ��ҳ��
      FPageData.SaveToStream(AStream);
  end;
  //
  vEndPos := AStream.Position;
  AStream.Position := vBegPos;
  vBegPos := vEndPos - vBegPos - SizeOf(vBegPos);
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ��ǰ�����ݴ�С
  AStream.Position := vEndPos;
end;

procedure THCSection.SectionToPage(const APageIndex, X, Y: Integer; var APageX,
  APageY: Integer);
var
  vPageFilmTop{, vMarginLeft, vMarginRight}: Integer;
begin
  // Ԥ��ҳ�����Ű�ʱ����
  //GetPageMarginLeftAndRight(APageIndex, vMarginLeft, vMarginRight);
  APageX := X;// - vMarginLeft;

  vPageFilmTop := GetPageTopFilm(APageIndex);
  APageY := Y - vPageFilmTop;  // ӳ�䵽��ǰҳ��Ϊԭ���������ʼλ��(��Ϊ����)
end;

function THCSection.SelectExists: Boolean;
begin
  //Result := False;
  //if FActiveData <> nil then
    Result := FActiveData.SelectExists
end;

procedure THCSection.SetHeaderOffset(const Value: Integer);
begin
  if FHeaderOffset <> Value then
  begin
    FHeaderOffset := Value;
    BuildSectionPages(0);
    DoDataChanged(Self);
  end;
end;

procedure THCSection.SetOnCreateItem(const Value: TNotifyEvent);
begin
  FHeader.OnCreateItem := Value;
  FPageData.OnCreateItem := Value;
  FFooter.OnCreateItem := Value;
end;

procedure THCSection.SetOnInsertItem(const Value: TItemNotifyEvent);
begin
  FHeader.OnInsertItem := Value;
  FPageData.OnInsertItem := Value;
  FFooter.OnInsertItem := Value;
end;

procedure THCSection.SetOnItemPaintAfter(const Value: TItemPaintEvent);
begin
  FHeader.OnItemPaintAfter := Value;
  FPageData.OnItemPaintAfter := Value;
  FFooter.OnItemPaintAfter := Value;
end;

procedure THCSection.SetOnItemPaintBefor(const Value: TItemPaintEvent);
begin
  FHeader.OnItemPaintBefor := Value;
  FPageData.OnItemPaintBefor := Value;
  FFooter.OnItemPaintBefor := Value;
end;

procedure THCSection.SetPageHeightPix(const Value: Integer);
begin
  if FPageSize.PageHeightPix <> Value then
    FPageSize.PageHeightPix := Value;
end;

procedure THCSection.SetPageMarginBottomPix(const Value: Integer);
begin
  if FPageSize.PageMarginBottomPix <> Value then
    FPageSize.PageMarginBottomPix := Value;
end;

procedure THCSection.SetPageMarginLeftPix(const Value: Integer);
begin
  if FPageSize.PageMarginLeftPix <> Value then
    FPageSize.PageMarginLeftPix := Value;
end;

procedure THCSection.SetPageMarginRightPix(const Value: Integer);
begin
  if FPageSize.PageMarginRightPix <> Value then
    FPageSize.PageMarginRightPix := Value;
end;

procedure THCSection.SetPageMarginTopPix(const Value: Integer);
begin
  if FPageSize.PageMarginTopPix <> Value then
    FPageSize.PageMarginTopPix := Value;
end;

procedure THCSection.SetPageWidthPix(const Value: Integer);
begin
  if FPageSize.PageWidthPix <> Value then
    FPageSize.PageWidthPix := Value;
end;

procedure THCSection.SetPaperHeight(const Value: Single);
begin
  FPageSize.PaperHeight := Value;
  FPageSize.PaperSize := DMPAPER_USER;
end;

procedure THCSection.SetPaperMarginBottom(const Value: Single);
begin
  FPageSize.PaperMarginBottom := Value;
end;

procedure THCSection.SetPaperMarginLeft(const Value: Single);
begin
  FPageSize.PaperMarginLeft := Value;
end;

procedure THCSection.SetPaperMarginRight(const Value: Single);
begin
  FPageSize.PaperMarginRight := Value;
end;

procedure THCSection.SetPaperMarginTop(const Value: Single);
begin
  FPageSize.PaperMarginTop := Value;
end;

procedure THCSection.SetPaperSize(const Value: Integer);
begin
  FPageSize.PaperSize := Value;
end;

procedure THCSection.SetPaperWidth(const Value: Single);
begin
  FPageSize.PaperWidth := Value;
  FPageSize.PaperSize := DMPAPER_USER;
end;

procedure THCSection.SetReadOnly(const Value: Boolean);
begin
  FHeader.ReadOnly := Value;
  FFooter.ReadOnly := Value;
  FPageData.ReadOnly := Value;
end;

function THCSection.ZoomCanvas(const ACanvas: TCanvas; const AScaleX,
  AScaleY: Single): TZoomInfo;
begin
  Result.MapMode := GetMapMode(ACanvas.Handle);  // ����ӳ�䷽ʽ������ʧ��
  SetMapMode(ACanvas.Handle, MM_ANISOTROPIC);  // �߼���λת���ɾ����������������ⵥλ����SetWindowsEx��SetViewportExtEx����ָ����λ���������Ҫ�ı���
  SetWindowOrgEx(ACanvas.Handle, 0, 0, @Result.WindowOrg);  // ��ָ�������������豸�����Ĵ���ԭ��
  SetWindowExtEx(ACanvas.Handle, FPageSize.PageWidthPix,  // Ϊ�豸�������ô��ڵ�ˮƽ�ĺʹ�ֱ�ķ�Χ
    FPageSize.PageHeightPix, @Result.WindowExt);

  SetViewportOrgEx(ACanvas.Handle, 0, 0, @Result.ViewportOrg);  // �ĸ��豸��ӳ�䵽����ԭ��(0,0)
  // ��ָ����ֵ������ָ���豸���������X�ᡢY�᷶Χ
  SetViewportExtEx(ACanvas.Handle, Round(FPageSize.PageWidthPix * AScaleX),
    Round(FPageSize.PageHeightPix * AScaleY), @Result.ViewportExt);
end;

end.
