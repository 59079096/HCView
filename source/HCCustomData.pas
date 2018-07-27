{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                 �ĵ������������Ԫ                  }
{                                                       }
{*******************************************************}

unit HCCustomData;

interface

uses
  Windows, Classes, Types, Controls, Graphics, HCItem, HCDrawItem,
  HCStyle, HCParaStyle, HCTextStyle, HCStyleMatch, HCCommon, HCUndo;

type
  TSelectInfo = class
  strict private
    FStartItemNo,  // ����ʹ��DrawItem��¼����Ϊ���ݱ䶯ʱItem��ָ��Offset��Ӧ��DrawItem�����ܺͱ䶯ǰ��һ��
    FStartItemOffset,  // ѡ����ʼ�ڵڼ����ַ����棬0��ʾ��Item��ǰ��
    FEndItemNo,
    FEndItemOffset  // ѡ�н����ڵڼ����ַ�����
      : Integer;
  public
    constructor Create;
    procedure Initialize;

    /// <summary> ѡ����ʼItem��� </summary>
    property StartItemNo: Integer read FStartItemNo write FStartItemNo;

    property StartItemOffset: Integer read FStartItemOffset write FStartItemOffset;

    /// <summary> ѡ�н���Item��� </summary>
    property EndItemNo: Integer read FEndItemNo write FEndItemNo;

    property EndItemOffset: Integer read FEndItemOffset write FEndItemOffset;
  end;

  THCCustomData = class(TObject)  // Ϊ֧�������Բ�����̫�����ԣ������CustomRichData��ͻ
  private
    FStyle: THCStyle;
    FItems: THCItems;
    FDrawItems: THCDrawItems;
    FSelectInfo: TSelectInfo;
    FDrawOptions: TDrawOptions;
    FCaretDrawItemNo: Integer;  // ��ǰItem��괦��DrawItem�޶���ֻ����صĹ�괦����ʹ��(���ͬһItem���к�OffsetΪ��βʱ��������������β��������ʼ)
    FOnGetUndoList: TGetUndoListEvent;
    procedure DrawItemPaintBefor(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure DrawItemPaintAfter(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
  protected
    /// <summary> ����ѡ�з�Χ��Item��ȫѡ�С�����ѡ��״̬ </summary>
    procedure MatchItemSelectState;

    /// <summary> ʽ��ʱ����¼��ʼDrawItem�Ͷ�����DrawItem </summary>
    /// <param name="AStartItemNo"></param>
    procedure FormatItemPrepare(const AStartItemNo: Integer; const AEndItemNo: Integer = -1);

    /// <summary>
    /// ת��ָ��Itemָ��Offs��ʽ��ΪDItem
    /// </summary>
    /// <param name="AItemNo">ָ����Item</param>
    /// <param name="AOffset">ָ���ĸ�ʽ����ʼλ��</param>
    /// <param name="AContentWidth">��ǰData��ʽ�����</param>
    /// <param name="APageContenBottom">��ǰҳ��ʽ���ײ�λ��</param>
    /// <param name="APos">��ʼλ��</param>
    /// <param name="ALastDNo">��ʼDItemNoǰһ��ֵ</param>
    /// <param name="vPageBoundary">����ҳ�ײ��߽�</param>
    procedure _FormatItemToDrawItems(const AItemNo, AOffset, AContentWidth: Integer;
      var APos: TPoint; var ALastDNo: Integer);

    /// <summary> ��ȡDItem��ָ��ƫ�ƴ������ݻ��ƿ�� </summary>
    /// <param name="ADrawItemNo"></param>
    /// <param name="ADrawOffs">�����DItem��CharOffs��Offs</param>
    /// <returns></returns>
    function GetDrawItemOffsetWidth(const ADrawItemNo, ADrawOffs: Integer): Integer;

    /// <summary> ����ָ��Item��ȡ�����ڶε���ʼ�ͽ���ItemNo </summary>
    /// <param name="AFirstItemNo1">ָ��</param>
    /// <param name="AFirstItemNo">��ʼ</param>
    /// <param name="ALastItemNo">����</param>
    procedure GetParaItemRang(const AItemNo: Integer;
      var AFirstItemNo, ALastItemNo: Integer);
    function GetParaFirstItemNo(const AItemNo: Integer): Integer;
    function GetParaLastItemNo(const AItemNo: Integer): Integer;

    /// <summary> ȡ�е�һ��DrawItem��Ӧ��ItemNo(���ڸ�ʽ��ʱ����һ����С��ItemNo��Χ) </summary>
    function GetLineFirstItemNo(const AItemNo, AOffset: Integer): Integer;

    /// <summary> ȡ�����һ��DrawItem��Ӧ��ItemNo(���ڸ�ʽ��ʱ����һ����С��ItemNo��Χ) </summary>
    function GetLineLastItemNo(const AItemNo, AOffset: Integer): Integer;

    /// <summary> ����ָ��Item��ȡ�������е���ʼ�ͽ���DrawItemNo </summary>
    /// <param name="AFirstItemNo1">ָ��</param>
    /// <param name="AFirstItemNo">��ʼ</param>
    /// <param name="ALastItemNo">����</param>
    procedure GetLineDrawItemRang(var AFirstDItemNo, ALastDItemNo: Integer); virtual;

    /// <summary> ��ȡָ��DItem��Ӧ��Text </summary>
    /// <param name="ADrawItemNo"></param>
    /// <returns></returns>
    function GetDrawItemText(const ADrawItemNo: Integer): string;

    procedure SetCaretDrawItemNo(const Value: Integer);

    function GetUndoList: THCUndoList;

    procedure DoDrawItemPaintBefor(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); virtual;
    procedure DoDrawItemPaintAfter(const AData: THCCustomData; const ADrawItemNo: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); virtual;
  public
    constructor Create(const AStyle: THCStyle); virtual;
    destructor Destroy; override;
    //
    procedure Clear; virtual;

    procedure InitializeField; virtual;

    /// <summary>
    /// ��ǰData�ǲ���������(����һ��Item������Ϊ��)
    /// </summary>
    /// <returns></returns>
    function IsEmptyData: Boolean;

    /// <summary> Ƕ��ʱ��ȡ����Data </summary>
    function GetRootData: THCCustomData; virtual;
    function CreateDefaultTextItem: THCCustomItem; virtual;
    function CreateDefaultDomainItem: THCCustomItem; virtual;
    procedure GetCaretInfo(const AItemNo, AOffset: Integer; var ACaretInfo: TCaretInfo); virtual;

    /// <summary>
    /// ���ݸ�����λ�û�ȡ�ڴ˷�Χ�ڵ���ʼ�ͽ���DItem
    /// </summary>
    /// <param name="ATop"></param>
    /// <param name="ABottom"></param>
    /// <param name="AFristDItemNo"></param>
    /// <param name="ALastDItemNo"></param>
    procedure GetDataDrawItemRang(const ATop, ABottom: Integer;
      var AFirstDItemNo, ALastDItemNo: Integer);

    /// <summary>
    /// ����ָ�������µ�Item��Offset
    /// </summary>
    /// <param name="X">ˮƽ����ֵX</param>
    /// <param name="Y">��ֱ����ֵY</param>
    /// <param name="AItemNo">���괦��Item</param>
    /// <param name="AOffset">������Item�е�λ��</param>
    /// <param name="ARestrain">True��������AItemNo��Χ��(�������Ҳ�����һ�еײ���ͨ��Լ�������ҵ���)</param>
    procedure GetItemAt(const X, Y: Integer; var AItemNo, AOffset, ADrawItemNo: Integer;
      var ARestrain: Boolean); virtual;

    /// <summary>
    /// ��ȡָ��Item��ʽ��ʱ��ʼItem
    /// </summary>
    /// <param name="AItemNo"></param>
    /// <returns></returns>
    //function GetFormatStartItemNo(const AItemNo: Integer): Integer;

    {procedure GetParaDrawItemRang(const AItemNo: Integer;
      var AFirstDItemNo, ALastDItemNo: Integer);}

    { Item��DItem���� }
    /// <summary>
    /// ��ȡItem��Ӧ�����һ��DItem
    /// </summary>
    /// <param name="AItemNo"></param>
    /// <returns></returns>
    function GetItemLastDrawItemNo(const AItemNo: Integer): Integer;

    /// <summary>
    /// Itemָ��ƫ��λ���Ƿ�ѡ��(�������ı�Item�ʹ���Rect)
    /// </summary>
    /// <param name="AItemNo"></param>
    /// <param name="AOffset"></param>
    /// <returns></returns>
    function OffsetInSelect(const AItemNo, AOffset: Integer): Boolean;

    /// <summary> �����Ƿ���AItem��ѡ�������� </summary>
    /// <param name="X"></param>
    /// <param name="Y"></param>
    /// <param name="AItemNo">X��Y����Item</param>
    /// <param name="AOffset">X��Y����Itemƫ��(����RectItem��ʱ����)</param>
    /// <param name="ARestrain">AItemNo, AOffset��X��Yλ��Լ�����(�˲���Ϊ���㵥Ԫ��Data����)</param>
    function CoordInSelect(const X, Y, AItemNo, AOffset: Integer;
      const ARestrain: Boolean): Boolean; virtual;
    /// <summary>
    /// ��ȡData�е�����X��Y����Item��Offset��������X��Y���DrawItem������
    /// </summary>
    /// <param name="X"></param>
    /// <param name="Y"></param>
    /// <param name="AItemNo"></param>
    /// <param name="AOffset"></param>
    /// <param name="AX"></param>
    /// <param name="AY"></param>
    procedure CoordToItemOffset(const X, Y, AItemNo, AOffset: Integer; var AX, AY: Integer);

    /// <summary>
    /// ����Item��ָ��Offset����DrawItem���
    /// </summary>
    /// <param name="AItemNo">ָ��Item</param>
    /// <param name="AOffset">Item��ָ��Offset</param>
    /// <returns>Offset����DrawItem���</returns>
    function GetDrawItemNoByOffset(const AItemNo, AOffset: Integer): Integer;
    function IsLineLastDrawItem(const ADrawItemNo: Integer): Boolean;
    function IsParaLastDrawItem(const ADrawItemNo: Integer): Boolean;
    function IsParaLastItem(const AItemNo: Integer): Boolean;

    function GetCurDrawItemNo: Integer;
    function GetCurDrawItem: THCCustomDrawItem;
    function GetCurItemNo: Integer;
    function GetCurItem: THCCustomItem;

    /// <summary> ����Item���ı���ʽ </summary>
    function GetItemStyle(const AItemNo: Integer): Integer;

    /// <summary> ����DDrawItem��Ӧ��Item���ı���ʽ </summary>
    function GetDrawItemStyle(const ADrawItemNo: Integer): Integer;

    /// <summary> ����Item��Ӧ�Ķ�����ʽ </summary>
    function GetItemParaStyle(const AItemNo: Integer): Integer;

    /// <summary> ����DDrawItem��Ӧ��Item�Ķ�����ʽ </summary>
    function GetDrawItemParaStyle(const ADrawItemNo: Integer): Integer;

    /// <summary> �õ�ָ��������X������DItem���ݵĵڼ����ַ� </summary>
    /// <param name="ADrawItemNo">ָ����DItem</param>
    /// <param name="X">��Data�еĺ�����</param>
    /// <returns>�ڼ����ַ�</returns>
    function GetDrawItemOffset(const ADrawItemNo, X: Integer): Integer;

    { ��ȡѡ�������Ϣ }
    /// <summary> ��ǰѡ����ʼDItemNo </summary>
    /// <returns></returns>
    function GetSelectStartDrawItemNo: Integer;

    /// <summary> ��ǰѡ�н���DItemNo </summary>
    /// <returns></returns>
    function GetSelectEndDrawItemNo: Integer;

    /// <summary> ��ȡѡ�������Ƿ���ͬһ��DItem�� </summary>
    /// <returns></returns>
    function SelectInSameDItem: Boolean;

    /// <summary> ȡ��ѡ�� </summary>
    /// <returns>ȡ��ʱ��ǰ�Ƿ���ѡ�У�True����ѡ�У�False����ѡ��</returns>
    function DisSelect: Boolean; virtual;

    /// <summary> ��ǰѡ�����������϶� </summary>
    /// <returns></returns>
    function SelectedCanDrag: Boolean;

    /// <summary> ��ǰѡ������ֻ��RectItem������������״̬ </summary>
    /// <returns></returns>
    function SelectedResizing: Boolean;

    /// <summary> ȫѡ </summary>
    procedure SelectAll; virtual;

    /// <summary> ��ǰ�����Ƿ�ȫѡ���� </summary>
    function SelectedAll: Boolean; virtual;

    /// <summary> Ϊ��Ӧ�ö��뷽ʽ </summary>
    /// <param name="AAlign">�Է���ʽ</param>
    procedure ApplyParaAlignHorz(const AAlign: TParaAlignHorz); virtual;
    procedure ApplyParaAlignVert(const AAlign: TParaAlignVert); virtual;
    procedure ApplyParaBackColor(const AColor: TColor); virtual;
    procedure ApplyParaLineSpace(const ASpace: Integer); virtual;

    // ѡ������Ӧ����ʽ
    function ApplySelectTextStyle(const AMatchStyle: TStyleMatch): Integer; virtual;
    function ApplySelectParaStyle(const AMatchStyle: TParaMatch): Integer; virtual;

    /// <summary> ɾ��ѡ�� </summary>
    function DeleteSelected: Boolean; virtual;

    /// <summary> Ϊѡ���ı�ʹ��ָ�����ı���ʽ </summary>
    /// <param name="AFontStyle">�ı���ʽ</param>
    procedure ApplyTextStyle(const AFontStyle: TFontStyleEx); virtual;
    procedure ApplyTextFontName(const AFontName: TFontName); virtual;
    procedure ApplyTextFontSize(const AFontSize: Integer); virtual;
    procedure ApplyTextColor(const AColor: TColor); virtual;
    procedure ApplyTextBackColor(const AColor: TColor); virtual;

    /// <summary> �������� </summary>
    /// <param name="ADataDrawLeft">����Ŀ������Left</param>
    /// <param name="ADataDrawTop">����Ŀ�������Top</param>
    /// <param name="ADataDrawBottom">����Ŀ�������Bottom</param>
    /// <param name="ADataScreenTop">��Ļ����Top</param>
    /// <param name="ADataScreenBottom">��Ļ����Bottom</param>
    /// <param name="AVOffset">ָ�����ĸ�λ�ÿ�ʼ�����ݻ��Ƶ�Ŀ���������ʼλ��</param>
    /// <param name="ACanvas">����</param>
    procedure PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, AVOffset: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); virtual;

    /// <summary> ���Data����ǰ </summary>
    /// <param name="ASrcData">ԴData</param>
    procedure AddData(const ASrcData: THCCustomData);

    /// <summary> �Ƿ���ѡ�� </summary>
    function SelectExists(const AIfRectItem: Boolean = True): Boolean;
    procedure MarkStyleUsed(const AMark: Boolean);

    procedure SaveToStream(const AStream: TStream); overload; virtual;
    procedure SaveToStream(const AStream: TStream; const AStartItemNo, AStartOffset,
      AEndItemNo, AEndOffset: Integer); overload; virtual;

    function SaveToText: string; overload;
    function SaveToText(const AStartItemNo, AStartOffset,
      AEndItemNo, AEndOffset: Integer): string; overload;

    /// <summary> ����ѡ�����ݵ��� </summary>
    procedure SaveSelectToStream(const AStream: TStream); virtual;
    function SaveSelectToText: string;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; virtual;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); virtual;
    //
    property Style: THCStyle read FStyle;
    property Items: THCItems read FItems;
    property DrawItems: THCDrawItems read FDrawItems;
    property SelectInfo: TSelectInfo read FSelectInfo;
    property DrawOptions: TDrawOptions read FDrawOptions write FDrawOptions;
    property CaretDrawItemNo: Integer read FCaretDrawItemNo write SetCaretDrawItemNo;
    property OnGetUndoList: TGetUndoListEvent read FOnGetUndoList write FOnGetUndoList;
  end;

type
  TTraverseItemEvent = procedure(const AData: THCCustomData;
    const AItemNo, ATag: Integer; var AStop: Boolean) of object;

  TItemTraverse = class(TObject)
  public
    Tag: Integer;
    Stop: Boolean;
    Process: TTraverseItemEvent;
  end;

implementation

uses
  SysUtils, Math, HCList, HCTextItem, HCRectItem;

{ THCCustomData }

/// <summary> �����ַ���AText�ķ�ɢ�ָ������͸��ָ�����ʼλ�� </summary>
/// <param name="AText">Ҫ������ַ���</param>
/// <param name="ACharIndexs">��¼���ָ�����ʼλ��</param>
/// <returns>��ɢ�ָ�����</returns>
function GetJustifyCount(const AText: string; const ACharIndexs: THCIntegerList): Integer;

  function IsCharSameType(const A, B: Char): Boolean;
  begin
    //if A = B then
    //  Result := True
    //else
      Result := False;
  end;

var
  i: Integer;
  vProvChar: Char;
begin
  Result := 0;
  if AText = '' then
    raise Exception.Create('�쳣�����ܶԿ��ַ��������ɢ��');

  if ACharIndexs <> nil then
    ACharIndexs.Clear;
  vProvChar := #0;
  for i := 1 to Length(AText) do
  begin
    if not IsCharSameType(vProvChar, AText[i]) then
    begin
      Inc(Result);
      if ACharIndexs <> nil then
        ACharIndexs.Add(i);
    end;
    vProvChar := AText[i];
  end;
  if ACharIndexs <> nil then
    ACharIndexs.Add(Length(AText) + 1);
end;

procedure THCCustomData.AddData(const ASrcData: THCCustomData);
var
  i: Integer;
begin
  for i := 0 to ASrcData.FItems.Count - 1 do
  begin
    FItems[FItems.Count - 1].Text := FItems[FItems.Count - 1].Text
      + ASrcData.FItems[i].Text;
  end;
end;

procedure THCCustomData.ApplyTextBackColor(const AColor: TColor);
var
  vMatchStyle: TBackColorStyleMatch;
begin
  vMatchStyle := TBackColorStyleMatch.Create;
  try
    vMatchStyle.Color := AColor;
    ApplySelectTextStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyTextColor(const AColor: TColor);
var
  vMatchStyle: TColorStyleMatch;
begin
  vMatchStyle := TColorStyleMatch.Create;
  try
    vMatchStyle.Color := AColor;
    ApplySelectTextStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyTextFontName(const AFontName: TFontName);
var
  vMatchStyle: TFontNameStyleMatch;
begin
  vMatchStyle := TFontNameStyleMatch.Create;
  try
    vMatchStyle.FontName := AFontName;
    ApplySelectTextStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyTextFontSize(const AFontSize: Integer);
var
  vMatchStyle: TFontSizeStyleMatch;
begin
  vMatchStyle := TFontSizeStyleMatch.Create;
  try
    vMatchStyle.FontSize := AFontSize;
    ApplySelectTextStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyTextStyle(const AFontStyle: TFontStyleEx);
var
  vMatchStyle: TTextStyleMatch;
begin
  vMatchStyle := TTextStyleMatch.Create;
  try
    vMatchStyle.FontStyle := AFontStyle;
    ApplySelectTextStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyParaAlignHorz(const AAlign: TParaAlignHorz);
var
  vMatchStyle: TParaAlignHorzMatch;
begin
  vMatchStyle := TParaAlignHorzMatch.Create;
  try
    vMatchStyle.Align := AAlign;
    ApplySelectParaStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyParaAlignVert(const AAlign: TParaAlignVert);
var
  vMatchStyle: TParaAlignVertMatch;
begin
  vMatchStyle := TParaAlignVertMatch.Create;
  try
    vMatchStyle.Align := AAlign;
    ApplySelectParaStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyParaBackColor(const AColor: TColor);
var
  vMatchStyle: TParaBackColorMatch;
begin
  vMatchStyle := TParaBackColorMatch.Create;
  try
    vMatchStyle.BackColor := AColor;
    ApplySelectParaStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

procedure THCCustomData.ApplyParaLineSpace(const ASpace: Integer);
var
  vMatchStyle: TParaLineSpaceMatch;
begin
  vMatchStyle := TParaLineSpaceMatch.Create;
  try
    vMatchStyle.Space := ASpace;
    ApplySelectParaStyle(vMatchStyle);
  finally
    vMatchStyle.Free;
  end;
end;

function THCCustomData.ApplySelectParaStyle(const AMatchStyle: TParaMatch): Integer;
begin
end;

function THCCustomData.ApplySelectTextStyle(const AMatchStyle: TStyleMatch): Integer;
begin
end;

procedure THCCustomData.Clear;
begin
  //DisSelect;  �ò���DisSelect��
  FSelectInfo.Initialize;
  FCaretDrawItemNo := -1;
  FDrawItems.Clear;
  FItems.Clear;
end;

function THCCustomData.CoordInSelect(const X, Y, AItemNo,
  AOffset: Integer; const ARestrain: Boolean): Boolean;
var
  vX, vY, vDrawItemNo: Integer;
  vDrawRect: TRect;
begin
  Result := False;
  if (AItemNo < 0) or (AOffset < 0) then Exit;
  if ARestrain then Exit;

  // �ж������Ƿ���AItemNo��Ӧ��AOffset��
  vDrawItemNo := GetDrawItemNoByOffset(AItemNo, AOffset);
  vDrawRect := DrawItems[vDrawItemNo].Rect;
  Result := PtInRect(vDrawRect, Point(X, Y));
  if Result then  // �ڶ�Ӧ��DrawItem��
  begin
    if FItems[AItemNo].StyleNo < THCStyle.RsNull then
    begin
      vX := X - vDrawRect.Left;
      vY := Y - vDrawRect.Top - FStyle.ParaStyles[Items[AItemNo].ParaNo].LineSpaceHalf;

      Result := (FItems[AItemNo] as THCCustomRectItem).CoordInSelect(vX, vY)
    end
    else
      Result := OffsetInSelect(AItemNo, AOffset);  // ��Ӧ��AOffset��ѡ��������
  end;
end;

procedure THCCustomData.CoordToItemOffset(const X, Y, AItemNo,
  AOffset: Integer; var AX, AY: Integer);
var
  vDrawItemNo: Integer;
  vDrawRect: TRect;
begin
  AX := X;
  AY := Y;
  if AItemNo < 0 then Exit;

  vDrawItemNo := GetDrawItemNoByOffset(AItemNo, AOffset);
  vDrawRect := FDrawItems[vDrawItemNo].Rect;
  AX := AX - vDrawRect.Left;
  AY := AY - vDrawRect.Top;
  if FItems[AItemNo].StyleNo < THCStyle.RsNull then
  begin
    case FStyle.ParaStyles[FItems[AItemNo].ParaNo].AlignVert of  // ��ֱ���뷽ʽ
      pavCenter: AY := AY - (vDrawRect.Height - (FItems[AItemNo] as THCCustomRectItem).Height) div 2;

      pavTop: AY := AY - FStyle.ParaStyles[FItems[AItemNo].ParaNo].LineSpaceHalf;
    else
      AY := AY - (vDrawRect.Height - (FItems[AItemNo] as THCCustomRectItem).Height);
    end;
  end;
end;

constructor THCCustomData.Create(const AStyle: THCStyle);
begin
  FStyle := AStyle;
  FDrawItems := THCDrawItems.Create;
  FItems := THCItems.Create;
  FCaretDrawItemNo := -1;
  FSelectInfo := TSelectInfo.Create;
end;

function THCCustomData.CreateDefaultDomainItem: THCCustomItem;
begin
  Result := THCDomainItem.Create(Self);
  Result.ParaNo := FStyle.CurParaNo;
end;

function THCCustomData.CreateDefaultTextItem: THCCustomItem;
begin
  Result := THCTextItem.Create;
  if FStyle.CurStyleNo < THCStyle.RsNull then
    Result.StyleNo := 0
  else
    Result.StyleNo := FStyle.CurStyleNo;

  Result.ParaNo := FStyle.CurParaNo;
end;

function THCCustomData.GetCurDrawItem: THCCustomDrawItem;
var
  vCurDItemNo: Integer;
begin
  vCurDItemNo := GetCurDrawItemNo;
  if vCurDItemNo < 0 then
    Result := nil
  else
    Result := FDrawItems[vCurDItemNo];
end;

function THCCustomData.GetCurDrawItemNo: Integer;
var
  i, vItemNo: Integer;
  vDItem: THCCustomDrawItem;
begin
  Result := -1;
  if SelectInfo.StartItemNo < 0 then  // û��ѡ��

  else
  begin
    if SelectExists then  // ��ѡ��ʱ����ǰ��ѡ�н���λ�õ�ItemΪ��ǰItem
    begin
      if FSelectInfo.EndItemNo >= 0 then
        vItemNo := FSelectInfo.EndItemNo
      else
        vItemNo := FSelectInfo.StartItemNo;
    end
    else
      vItemNo := FSelectInfo.StartItemNo;
    if FItems[vItemNo].StyleNo < 0 then  // ���ı�
      Result := FItems[vItemNo].FirstDItemNo
    else  // �ı�
    begin
      for i := FItems[vItemNo].FirstDItemNo to FDrawItems.Count - 1 do
      begin
        vDItem := FDrawItems[i];
        if SelectInfo.StartItemOffset - vDItem.CharOffs + 1 <= vDItem.CharLen then
        begin
          Result := i;
          Break;
        end;
      end;
    end;
  end;
end;

function THCCustomData.GetCurItem: THCCustomItem;
var
  vItemNo: Integer;
begin
  vItemNo := GetCurItemNo;
  if vItemNo < 0 then
    Result := nil
  else
    Result := FItems[vItemNo];
end;

function THCCustomData.GetCurItemNo: Integer;
begin
  {if IsEmptyData then
    Result := 0
  else}
    Result := FSelectInfo.StartItemNo
end;

function THCCustomData.DeleteSelected: Boolean;
begin
end;

destructor THCCustomData.Destroy;
begin
  FreeAndNil(FDrawItems);
  FreeAndNil(FItems);
  FreeAndNil(FSelectInfo);

  inherited Destroy;
end;

function THCCustomData.DisSelect: Boolean;
var
  i: Integer;
  vItem: THCCustomItem;
begin
  { THCCustomRichData.MouseUp����DisSelectAfterStartItemNo���б�����ʼ����ѡ�У�
   ����ദ��Ҫ������ʼ�������ڴ˷��������Ƿ�����ʼ�����Թ��� }

  Result := SelectExists;
  if Result then  // ��ѡ������
  begin
    // ���ѡ������RectItem�н�������ѭ��SelectInfo.EndItemNo<0������ȡ��ѡ�У����Ե�������StartItemNo
    vItem := FItems[SelectInfo.StartItemNo];
    vItem.DisSelect;
    vItem.Active := False;

    for i := SelectInfo.StartItemNo + 1 to SelectInfo.EndItemNo do  // ����ѡ�е�����Item
    begin
      vItem := FItems[i];
      vItem.DisSelect;
      vItem.Active := False;
    end;
    SelectInfo.EndItemNo := -1;
    SelectInfo.EndItemOffset := -1;
  end
  else  // û��ѡ��
  if SelectInfo.StartItemNo >= 0 then
  begin
    vItem := FItems[SelectInfo.StartItemNo];
    vItem.DisSelect;
    vItem.Active := False;
  end;

  SelectInfo.StartItemNo := -1;
  SelectInfo.StartItemOffset := -1;
end;

procedure THCCustomData.DoDrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
end;

procedure THCCustomData.DoDrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
end;

procedure THCCustomData.DrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vDCState: Integer;
begin
  vDCState := SaveDC(ACanvas.Handle);
  try
    DoDrawItemPaintAfter(AData, ADrawItemNo, ADrawRect, ADataDrawLeft, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  finally
    ReleaseDC(ACanvas.Handle, vDCState);
  end;
end;

procedure THCCustomData.DrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vDCState: Integer;
begin
  vDCState := SaveDC(ACanvas.Handle);
  try
    DoDrawItemPaintBefor(AData, ADrawItemNo, ADrawRect, ADataDrawLeft, ADataDrawBottom,
      ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  finally
    ReleaseDC(ACanvas.Handle, vDCState);
  end;
end;

function THCCustomData.IsEmptyData: Boolean;
begin
  Result := (FItems.Count = 1) and (FItems[0].StyleNo > THCStyle.RsNull) and (FItems[0].Text = '');
end;

procedure THCCustomData.GetDataDrawItemRang(const ATop,
  ABottom: Integer; var AFirstDItemNo, ALastDItemNo: Integer);
var
  i: Integer;
begin
  AFirstDItemNo := -1;
  ALastDItemNo := -1;
  // ��ȡ��һ������ʾ��DrawItem
  for i := 0 to FDrawItems.Count - 1 do
  begin
    if (FDrawItems[i].LineFirst)
      and (FDrawItems[i].Rect.Bottom > ATop)  // �ײ����������ϱ�
      and (FDrawItems[i].Rect.Top < ABottom)  // ����û���������±�
    then
    begin
      AFirstDItemNo := i;
      Break;
    end;
  end;

  if AFirstDItemNo < 0 then Exit;  // ��1�����������˳�

  // ��ȡ���һ������ʾ��DrawItem
  for i := AFirstDItemNo to FDrawItems.Count - 1 do
  begin
    if (FDrawItems[i].LineFirst) and (FDrawItems[i].Rect.Top >= ABottom) then
    begin
      ALastDItemNo := i - 1;
      Break;
    end
    {else
    if (FDrawItems[i].Rect.Bottom > ABottom) then
    begin
      ALastDItemNo := i;
      Break;
    end};
  end;
  if ALastDItemNo < 0 then  // �߶ȳ���Data�߶�ʱ�������1������
    ALastDItemNo := FDrawItems.Count - 1;
end;

function THCCustomData.GetDrawItemNoByOffset(const AItemNo, AOffset: Integer): Integer;
var
  i: Integer;
  vDrawItem: THCCustomDrawItem;
begin
  Result := -1;
  if FItems[AItemNo].StyleNo < THCStyle.RsNull then  // RectItem
    Result := FItems[AItemNo].FirstDItemNo
  else  // TextItem
  begin
    for i := FItems[AItemNo].FirstDItemNo to FDrawItems.Count - 1 do
    begin
      vDrawItem := FDrawItems[i];
      if vDrawItem.ItemNo <> AItemNo then
        Break;

      if AOffset - vDrawItem.CharOffs < vDrawItem.CharLen then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function THCCustomData.GetDrawItemOffset(const ADrawItemNo, X: Integer): Integer;
var
  vX, vCharWidth: Integer;
  vDrawItem: THCCustomDrawItem;
  vText: string;
  vS: string;
  vLineLast: Boolean;

  i, j,
  vSplitCount,
  viSplitW,  // ���ַ�����ʱ�м�ļ��
  vMod: Integer;
  vItem: THCCustomItem;

  vParaStyle: THCParaStyle;
  vSplitList: THCIntegerList;
begin
  Result := 0;
  vDrawItem := FDrawItems[ADrawItemNo];
  vItem  := FItems[vDrawItem.ItemNo];
  if vItem.StyleNo < FStyle.RsNull then  // ���ı�
    Result := (vItem as THCCustomRectItem).GetOffsetAt(X - vDrawItem.Rect.Left)
  else  // �ı�
  begin
    Result := vDrawItem.CharLen;  // ��ֵΪ���Ϊ���������Ҳ���ʱ����Ϊ���һ��
    vText := (vItem as THCTextItem).GetTextPart(vDrawItem.CharOffs, vDrawItem.CharLen);
    FStyle.TextStyles[vItem.StyleNo].ApplyStyle(FStyle.DefCanvas);
    vParaStyle := FStyle.ParaStyles[vItem.ParaNo];
    vX := vDrawItem.Rect.Left;

    case vParaStyle.AlignHorz of
      pahLeft, pahRight, pahCenter:
        Result := GetCharOffsetByX(FStyle.DefCanvas, vText, X - vX);

      pahJustify, pahScatter:  // 20170220001 ���ˡ���ɢ������ش���
        begin
          if vParaStyle.AlignHorz = pahJustify then  // ���˶���
          begin
            if IsParaLastDrawItem(ADrawItemNo) then  // ���˶��롢�����һ�в�����
            begin
              Result := GetCharOffsetByX(FStyle.DefCanvas, vText, X - vX);
              Exit;
            end;
          end;
          vMod := 0;
          viSplitW := vDrawItem.Width - FStyle.DefCanvas.TextWidth(vText);  // ��ǰDItem��Rect�����ڷ�ɢ�Ŀռ�
          // ���㵱ǰDitem���ݷֳɼ��ݣ�ÿһ���������е���ʼλ��
          vSplitList := THCIntegerList.Create;
          try
            vSplitCount := GetJustifyCount(vText, vSplitList);
            vLineLast := IsLineLastDrawItem(ADrawItemNo);
            if vLineLast and (vSplitCount > 0) then  // �����DItem���ٷ�һ��
              Dec(vSplitCount);
            if vSplitCount > 0 then  // �зֵ����
            begin
              vMod := viSplitW mod vSplitCount;
              viSplitW := viSplitW div vSplitCount;
            end;

            //vSplitCount := 0;
            for i := 0 to vSplitList.Count - 2 do  // vSplitList���һ�����ַ����������Զ��1
            begin
              vS := Copy(vText, vSplitList[i], vSplitList[i + 1] - vSplitList[i]);  // ��ǰ�ָ���һ���ַ���
              vCharWidth := FStyle.DefCanvas.TextWidth(vS);
              if vMod > 0 then
              begin
                Inc(vCharWidth);  // ��ֵ�����
                vSplitCount := 1;
                Dec(vMod);
              end
              else
                vSplitCount := 0;
              { ���Ӽ�� }
              if i <> vSplitList.Count - 2 then  // ���ǵ�ǰDItem�ָ������һ��
                vCharWidth := vCharWidth + viSplitW  // �ָ����
              else  // �ǵ�ǰDItem�ָ������һ��
              begin
                if not vLineLast then  // ���������һ��DItem
                  vCharWidth := vCharWidth + viSplitW;  // �ָ����
              end;

              if vX + vCharWidth > X then  // ��ǰ�ַ�����λ����X���ҵ���λ��
              begin
                vMod := Length(vS);  // ���ñ�����׼������  a b c d e fgh ijklm n opq����ʽ(����ַ�Ϊһ���ָ���)
                for j := 1 to vMod do  // ���ڵ�ǰ�ָ���һ���ַ�������һ��λ��
                begin
                  vCharWidth := FStyle.DefCanvas.TextWidth(vS[j]);
                  if i <> vSplitList.Count - 2 then  // ���ǵ�ǰDItem�ָ������һ��
                  begin
                    if j = vMod then
                      vCharWidth := vCharWidth + viSplitW + vSplitCount;
                  end
                  else  // �ǵ�ǰDItem�ָ������һ��
                  begin
                    if not vLineLast then  // ���������һ��DItem
                      vCharWidth := vCharWidth + viSplitW + vSplitCount;  // �ָ����
                  end;

                  vX := vX + vCharWidth;
                  if vX > X then  // ��ǰ�ַ�����λ����X��
                  begin
                    if vX - vCharWidth div 2 > X then  // �����ǰ�벿��
                      Result := vSplitList[i] - 1 + j - 1  // ��Ϊǰһ������
                    else
                      Result := vSplitList[i] - 1 + j;
                    Break;
                  end;
                end;

                Break;
              end;

              vX := vX + vCharWidth;
            end;
          finally
            vSplitList.Free;
          end;
        end;
    end;
  end;
end;

function THCCustomData.GetDrawItemOffsetWidth(const ADrawItemNo, ADrawOffs: Integer): Integer;
var
  vStyleNo: Integer;
  vAlignHorz: TParaAlignHorz;
  vDItem: THCCustomDrawItem;

  vSplitList: THCIntegerList;
  vLineLast: Boolean;
  vText, vS: string;
  i, j, viSplitW, vSplitCount, vMod, vCharWidth, vDOffset
    : Integer;
begin
  Result := 0;
  if ADrawOffs = 0 then Exit;

  vDItem := FDrawItems[ADrawItemNo];
  vStyleNo := FItems[vDItem.ItemNo].StyleNo;
  if vStyleNo < THCStyle.RsNull then  // ���ı�
  begin
    if ADrawOffs > OffsetBefor then
      Result := FDrawItems[ADrawItemNo].Width;
  end
  else
  begin
    FStyle.TextStyles[vStyleNo].ApplyStyle(FStyle.DefCanvas);

    vAlignHorz := FStyle.ParaStyles[GetDrawItemParaStyle(ADrawItemNo)].AlignHorz;
    case vAlignHorz of
      pahLeft, pahRight, pahCenter:
        begin
          Result := FStyle.DefCanvas.TextWidth(Copy(FItems[vDItem.ItemNo].Text,
            vDItem.CharOffs, ADrawOffs));
        end;
      pahJustify, pahScatter:  // 20170220001 ���ˡ���ɢ������ش���
        begin
          if vAlignHorz = pahJustify then  // ���˶���
          begin
            if IsParaLastDrawItem(ADrawItemNo) then  // ���˶��롢�����һ�в�����
            begin
              Result := FStyle.DefCanvas.TextWidth(Copy(FItems[vDItem.ItemNo].Text,
                vDItem.CharOffs, ADrawOffs));
              Exit;
            end;
          end;

          vText := GetDrawItemText(ADrawItemNo);
          viSplitW := vDItem.Width - FStyle.DefCanvas.TextWidth(vText);  // ��ǰDItem��Rect�����ڷ�ɢ�Ŀռ�
          vMod := 0;
          // ���㵱ǰDitem���ݷֳɼ��ݣ�ÿһ���������е���ʼλ��
          vSplitList := THCIntegerList.Create;
          try
            vSplitCount := GetJustifyCount(vText, vSplitList);
            vLineLast := IsLineLastDrawItem(ADrawItemNo);
            if vLineLast and (vSplitCount > 0) then  // �����DItem���ٷ�һ��
              Dec(vSplitCount);
            if vSplitCount > 0 then  // �зֵ����
            begin
              vMod := viSplitW mod vSplitCount;
              viSplitW := viSplitW div vSplitCount;
            end;

            vSplitCount := 0;  // ���ñ���
            for i := 0 to vSplitList.Count - 2 do  // vSplitList���һ�����ַ����������Զ��1
            begin
              vS := Copy(vText, vSplitList[i], vSplitList[i + 1] - vSplitList[i]);  // ��ǰ�ָ���һ���ַ���
              vCharWidth := FStyle.DefCanvas.TextWidth(vS);
              if vMod > 0 then
              begin
                Inc(vCharWidth);  // ��ֵ�����
                vSplitCount := 1;
                Dec(vMod);
              end
              else
                vSplitCount := 0;

              vDOffset := vSplitList[i] + Length(vS) - 1;
              if vDOffset <= ADrawOffs then  // ��ǰ�ַ�����λ����AOffsǰ
              begin
                { ���Ӽ�� }
                if i <> vSplitList.Count - 2 then  // ���ǵ�ǰDItem�ָ������һ��
                  vCharWidth := vCharWidth + viSplitW  // �ָ����
                else  // �ǵ�ǰDItem�ָ������һ��
                begin
                  if not vLineLast then  // ���������һ��DItem
                    vCharWidth := vCharWidth + viSplitW;  // �ָ����
                end;

                Result := Result + vCharWidth;
                if vDOffset = ADrawOffs then
                  Break;
              end
              else  // ��ǰ�ַ�����λ����AOffs���Ҿ���λ��
              begin
                // ׼������  a b c d e fgh ijklm n opq����ʽ(����ַ�Ϊһ���ָ���)
                for j := 1 to Length(vS) do  // ���ڵ�ǰ�ָ����⴮�ַ�������һ��λ��
                begin
                  vCharWidth := FStyle.DefCanvas.TextWidth(vS[j]);

                  vDOffset := vSplitList[i] - 1 + j;
                  if vDOffset = vDItem.CharLen then  // �ǵ�ǰDItem���һ���ָ���
                  begin
                    if not vLineLast then  // ��ǰDItem���������һ��DItem
                      vCharWidth := vCharWidth + viSplitW + vSplitCount;  // ��ǰDItem���һ���ַ����ָܷ����Ͷ�ֵ�����
                    //else �����һ��DItem�����һ���ַ������ָܷ����Ͷ�ֵ���������Ϊ����ʽ��ʱ���һ���ָ��ַ����Ҳ�Ͳ��ּ��
                  end;
                  Result := Result + vCharWidth;

                  if vDOffset = ADrawOffs then  // ��ǰ�ַ�����λ����X��
                    Break;
                end;

                Break;
              end;
            end;
          finally
            vSplitList.Free;
          end;
        end;
    end;
  end;
end;

function THCCustomData.GetDrawItemParaStyle(const ADrawItemNo: Integer): Integer;
begin
  Result := GetItemParaStyle(FDrawItems[ADrawItemNo].ItemNo);
end;

function THCCustomData.GetDrawItemStyle(const ADrawItemNo: Integer): Integer;
begin
  Result := GetItemStyle(FDrawItems[ADrawItemNo].ItemNo);
end;

function THCCustomData.GetDrawItemText(const ADrawItemNo: Integer): string;
var
  vDItem: THCCustomDrawItem;
begin
  vDItem := FDrawItems[ADrawItemNo];
  Result := FItems[vDItem.ItemNo].Text;
  if Result <> '' then
    Result := Copy(Result, vDItem.CharOffs, vDItem.CharLen);
end;

{function THCCustomData.GetFormatStartItemNo(const AItemNo: Integer): Integer;
var
  i: Integer;
begin
  Result := AItemNo;
  for i := FItems[AItemNo].FirstDItemNo downto 0 do
  begin
    if FDrawItems[i].LineFirst then
    begin
      Result := FDrawItems[i].ItemNo;
      Break;
    end;
  end;
end;}

procedure THCCustomData.GetItemAt(const X, Y: Integer;
  var AItemNo, AOffset, ADrawItemNo: Integer; var ARestrain: Boolean);
var
  i, vStartDItemNo, vEndDItemNo: Integer;
  vDrawRect: TRect;
begin
  AItemNo := -1;
  AOffset := -1;
  ADrawItemNo := -1;
  ARestrain := True;  // Ĭ��ΪԼ���ҵ�(����Item����)

  if IsEmptyData then
  begin
    AItemNo := 0;
    AOffset := 0;
    ADrawItemNo := 0;
    Exit;
  end;

  { ��ȡ��Ӧλ����ӽ�����ʼDrawItem }
  if Y < 0 then
    vStartDItemNo := 0
  else  // �ж�����һ��
  begin
    vDrawRect := FDrawItems.Last.Rect;
    if Y > vDrawRect.Bottom then  // ���һ������
      vStartDItemNo := FDrawItems.Count - 1
    else  // ���ַ������ĸ�Item
    begin
      vStartDItemNo := 0;
      vEndDItemNo := FDrawItems.Count - 1;

      while True do
      begin
        if vEndDItemNo - vStartDItemNo > 1 then  // ������1
        begin
          i := vStartDItemNo + (vEndDItemNo - vStartDItemNo) div 2;
          if Y > FDrawItems[i].Rect.Bottom then  // �����м�λ��
          begin
            vStartDItemNo := i + 1;  // �м�λ����һ��
            Continue;
          end
          else
          if Y < FDrawItems[i].Rect.Top then  // С���м�λ��
          begin
            vEndDItemNo := i - 1;  // �м�λ����һ��
            Continue;
          end
          else
          begin
            vStartDItemNo := i;  // �������м�λ�õ�
            Break;
          end;
        end
        else  // ���1
        begin
          if Y > FDrawItems[vEndDItemNo].Rect.Bottom then  // �ڶ�������
            vStartDItemNo := vEndDItemNo
          else
          if Y >= FDrawItems[vEndDItemNo].Rect.Top then  // �ڶ���
            vStartDItemNo := vEndDItemNo;
          //else ��������һ��
          Break;
        end;
      end;
    end;

    if Y < FDrawItems[vStartDItemNo].Rect.Top then  // ������ҳ�ײ���������ʱ��vStartDItemNo����һҳ��һ�������
      Dec(vStartDItemNo);
  end;

  // �ж���ָ��������һ��Item
  GetLineDrawItemRang(vStartDItemNo, vEndDItemNo);  // ����ʼ�ͽ���DrawItem
  if X <= FDrawItems[vStartDItemNo].Rect.Left then  // ���е�һ����ߵ��
  begin
    ADrawItemNo := vStartDItemNo;
    AItemNo := FDrawItems[vStartDItemNo].ItemNo;
    if FItems[AItemNo].StyleNo < THCStyle.RsNull then
      AOffset := GetDrawItemOffset(vStartDItemNo, X)
    else
      AOffset := FDrawItems[vStartDItemNo].CharOffs - 1;  // DrawItem��ʼ
  end
  else
  if X >= FDrawItems[vEndDItemNo].Rect.Right then  // �����ұߵ��
  begin
    ADrawItemNo := vEndDItemNo;
    AItemNo := FDrawItems[vEndDItemNo].ItemNo;
    if FItems[AItemNo].StyleNo < THCStyle.RsNull then
      AOffset := GetDrawItemOffset(vEndDItemNo, X)
    else
      AOffset := FDrawItems[vEndDItemNo].CharOffs + FDrawItems[vEndDItemNo].CharLen - 1;  // DrawItem���
  end
  else
  begin
    for i := vStartDItemNo to vEndDItemNo do  // ���м�
    begin
      vDrawRect := FDrawItems[i].Rect;
      if (X >= vDrawRect.Left) and (X < vDrawRect.Right) then  // 2���м�������
      begin
        ADrawItemNo := i;
        AItemNo := FDrawItems[i].ItemNo;
        if FItems[AItemNo].StyleNo < THCStyle.RsNull then
          AOffset := GetDrawItemOffset(i, X)
        else
          AOffset := FDrawItems[i].CharOffs + GetDrawItemOffset(i, X) - 1;
        ARestrain := (Y < vDrawRect.Top) or (Y > vDrawRect.Bottom);
        Break;
      end;
    end;
  end;
end;

function THCCustomData.GetItemLastDrawItemNo(const AItemNo: Integer): Integer;
//var
//  vItemNo: Integer;
begin
  Result := -1;
  // ��ReFormat�е��ô˷���ʱ����AItemNoǰ�����û�и�ʽ������Itemʱ��
  // AItemNo��Ӧ��ԭDrawItem��ItemNo������С��AItemNo��ֵ�������ж�
  // AItemNo�����¸�ʽ��ǰ�����һ��DrawItem����Ҫʹ��AItemNoԭDrawItem��
  // ItemNo��ΪDrawItem�ֵܵ��ж�ֵ
  // ���ڸ�ʽ��ʱ��ò�ʹ�ô˷�������ΪDrawItems.Count����ֻ�ǵ�ǰ��ʽ������Items
  {if FItems[AItemNo].FirstDItemNo < 0 then
    vItemNo := AItemNo
  else
    vItemNo := FDrawItems[FItems[AItemNo].FirstDItemNo].ItemNo; }
  if FItems[AItemNo].FirstDItemNo < 0 then Exit;  // ��û�и�ʽ����

  Result := FItems[AItemNo].FirstDItemNo + 1;
  while Result < FDrawItems.Count do
  begin
    if FDrawItems[Result].ParaFirst or (FDrawItems[Result].ItemNo <> AItemNo) then
      Break
    else
      Inc(Result);
  end;
  Dec(Result);
end;

function THCCustomData.GetItemParaStyle(const AItemNo: Integer): Integer;
begin
  Result := FItems[AItemNo].ParaNo;
end;

function THCCustomData.GetItemStyle(const AItemNo: Integer): Integer;
begin
  Result := FItems[AItemNo].StyleNo;
end;

procedure THCCustomData.GetLineDrawItemRang(var AFirstDItemNo, ALastDItemNo: Integer);
begin
  while AFirstDItemNo > 0 do
  begin
    if FDrawItems[AFirstDItemNo].LineFirst then
      Break
    else
      Dec(AFirstDItemNo);
  end;

  ALastDItemNo := AFirstDItemNo + 1;
  while ALastDItemNo < FDrawItems.Count do
  begin
    if FDrawItems[ALastDItemNo].LineFirst then
      Break
    else
      Inc(ALastDItemNo);
  end;
  Dec(ALastDItemNo);
end;

function THCCustomData.GetLineFirstItemNo(const AItemNo,
  AOffset: Integer): Integer;
var
  vFirstDItemNo: Integer;
begin
  Result := AItemNo;
  vFirstDItemNo := GetDrawItemNoByOffset(AItemNo, AOffset);

  while vFirstDItemNo > 0 do
  begin
    if DrawItems[vFirstDItemNo].LineFirst then
      Break
    else
      Dec(vFirstDItemNo);
  end;

  Result := DrawItems[vFirstDItemNo].ItemNo;
end;

function THCCustomData.GetLineLastItemNo(const AItemNo,
  AOffset: Integer): Integer;
var
  vLastDItemNo: Integer;
begin
  Result := AItemNo;
  vLastDItemNo := GetDrawItemNoByOffset(AItemNo, AOffset) + 1;  // ��һ����ʼ�������е�һ����ȡ���һ��ʱ�����е�һ��
  while vLastDItemNo < FDrawItems.Count do
  begin
    if FDrawItems[vLastDItemNo].LineFirst then
      Break
    else
      Inc(vLastDItemNo);
  end;
  Dec(vLastDItemNo);

  Result := DrawItems[vLastDItemNo].ItemNo;
end;

{procedure THCCustomData.GetParaDrawItemRang(const AItemNo: Integer;
  var AFirstDItemNo, ALastDItemNo: Integer);
var
  vFrItemNo, vLtItemNo: Integer;
begin
  GetParaItemRang(AItemNo, vFrItemNo, vLtItemNo);
  AFirstDItemNo := FItems[vFrItemNo].FirstDItemNo;
  ALastDItemNo := GetItemLastDrawItemNo(vLtItemNo);
end;}

function THCCustomData.GetParaFirstItemNo(const AItemNo: Integer): Integer;
begin
  Result := AItemNo;
  while Result > 0 do
  begin
    if FItems[Result].ParaFirst then
      Break
    else
      Dec(Result);
  end;
end;

procedure THCCustomData.GetParaItemRang(const AItemNo: Integer;
  var AFirstItemNo, ALastItemNo: Integer);
begin
  AFirstItemNo := AItemNo;
  while AFirstItemNo > 0 do
  begin
    if FItems[AFirstItemNo].ParaFirst then
      Break
    else
      Dec(AFirstItemNo);
  end;

  ALastItemNo := AItemNo + 1;
  while ALastItemNo < FItems.Count do
  begin
    if FItems[ALastItemNo].ParaFirst then
      Break
    else
      Inc(ALastItemNo);
  end;
  Dec(ALastItemNo);
end;

function THCCustomData.GetParaLastItemNo(const AItemNo: Integer): Integer;
begin
  // Ŀǰ��Ҫ�ⲿ�Լ�Լ��AItemNo < FItems.Count
  Result := AItemNo + 1;
  while Result < FItems.Count do
  begin
    if FItems[Result].ParaFirst then
      Break
    else
      Inc(Result);
  end;
  Dec(Result);
end;

function THCCustomData.GetRootData: THCCustomData;
begin
  Result := Self;
end;

function THCCustomData.GetSelectEndDrawItemNo: Integer;
begin
  if FSelectInfo.EndItemNo < 0 then
    Result := -1
  else
    Result := GetDrawItemNoByOffset(FSelectInfo.EndItemNo,
      FSelectInfo.EndItemOffset);
end;

function THCCustomData.GetSelectStartDrawItemNo: Integer;
begin
  if FSelectInfo.StartItemNo < 0 then
    Result := -1
  else
  begin
    Result := GetDrawItemNoByOffset(FSelectInfo.StartItemNo,
      FSelectInfo.StartItemOffset);

    if (FSelectInfo.EndItemNo >= 0)
      and (FDrawItems[Result].CharOffsetEnd = FSelectInfo.StartItemOffset)
    then  // ��ѡ��ʱ��SelectInfo.StartItemOffset�ڱ������ʱ��ҪתΪ��һ������
      Inc(Result);
  end;
end;

function THCCustomData.GetUndoList: THCUndoList;
begin
  if Assigned(FOnGetUndoList) then
    Result := FOnGetUndoList
  else
    Result := nil;
end;

procedure THCCustomData._FormatItemToDrawItems(const AItemNo, AOffset, AContentWidth: Integer;
  var APos: TPoint; var ALastDNo: Integer);

type
  TBreakPosition = (  // �ض�λ��
    jbpNone,  // ���ض�
    jbpPrev  // ��ǰһ������ض�
    //jbpCur    // �ڵ�ǰ����ض�
    );

  {$REGION 'FinishLine'}
  /// <summary> ������ </summary>
  /// <param name="AEndDItemNo">�����һ��DItem</param>
  /// <param name="ARemWidth">��ʣ����</param>
  procedure FinishLine(const ALineEndDItemNo, ARemWidth: Integer);
  var
    i, vLineBegDItemNo,  // �е�һ��DItem
    vMaxBottom,
    viSplitW, vExtraW, vW
      : Integer;
    vReSize: Boolean;
    vAlignHorz: TParaAlignHorz;
    vLineSpaceCount,   // ��ǰ�зּ���
    vDItemSpaceCount,  // ��ǰDrawItem�ּ���
    vDWidth,
    vModWidth,
    vCountWillSplit  // ��ǰ���м���DItem����ַ�
      : Integer;
    vDrawItemSplitCounts: array of Word;  // ��ǰ�и�DItem�ּ���
  begin
    { ����������ߵ�DrawItem��������DrawItem�ĸ߶� }
    vLineBegDItemNo := ALineEndDItemNo;
    for i := ALineEndDItemNo downto 0 do  // �õ�����ʼDItemNo
    begin
      if FDrawItems[i].LineFirst then
      begin
        vLineBegDItemNo := i;
        Break;
      end;
    end;
    Assert((vLineBegDItemNo >= 0), '����ʧ�ܣ�����ʼDItemNoС��0��');
    // ����DItem��Rect��λ������
    vReSize := False;  // Ĭ�ϱ��в���Ҫ������DItem��Rect
    // ��ȡ��ʽ����ֹ����һ����ʼʱ�����ô˷���������һ�Σ�2����ʽ��һ����ɴ���
    vMaxBottom := FDrawItems[ALineEndDItemNo].Rect.Bottom;  // ��Ĭ�������һ��DItem��Rect��λ�����
    for i := ALineEndDItemNo - 1 downto vLineBegDItemNo do
    begin
      //FDrawItems[i].RemWidth := ARemWidth;
      if FDrawItems[i].Rect.Bottom <> vMaxBottom then  // ��Ҫ���µ������и�DItem��Rect
        vReSize := True;
      if FDrawItems[i].Rect.Bottom > vMaxBottom then
        vMaxBottom := FDrawItems[i].Rect.Bottom;  // ��������Rect��λ��
    end;

    if vReSize then  // ��Ҫ���µ������и�DItem�߶ȣ��������ڲ�ͬ��ʽ��DItem
    begin
      for i := ALineEndDItemNo downto vLineBegDItemNo do
        FDrawItems[i].Rect.Bottom := vMaxBottom;
    end;

    // ������뷽ʽ�������������Ϊ�����������ʼ�ͽ���DItem���������ʱ������
    vAlignHorz := FStyle.ParaStyles[GetDrawItemParaStyle(ALineEndDItemNo)].AlignHorz;
    case vAlignHorz of  // ������ˮƽ���뷽ʽ
      pahLeft: ;
      pahRight:
        begin
          for i := ALineEndDItemNo downto vLineBegDItemNo do
            OffsetRect(FDrawItems[i].Rect, ARemWidth, 0);
        end;

      pahCenter:
        begin
          viSplitW := ARemWidth div 2;
          for i := ALineEndDItemNo downto vLineBegDItemNo do
            OffsetRect(FDrawItems[i].Rect, viSplitW, 0);
        end;

      pahJustify, pahScatter:  // 20170220001 ���ˡ���ɢ������ش���
        begin
          if vAlignHorz = pahJustify then  // ���˶���
          begin
            if IsParaLastDrawItem(ALineEndDItemNo) then  // ���˶��룬�����һ�в�����
              Exit;
          end
          else  // ��ɢ���룬���л�ֻ��һ���ַ�ʱ����
          begin
            if vLineBegDItemNo = ALineEndDItemNo then  // ��ֻ��һ��DrawItem
            begin
              if FItems[FDrawItems[vLineBegDItemNo].ItemNo].Length < 2 then  // ��DrawItem��Ӧ�����ݳ��Ȳ���2�������д���
              begin
                viSplitW := ARemWidth div 2;
                OffsetRect(FDrawItems[vLineBegDItemNo].Rect, viSplitW, 0);

                Exit;
              end;
            end;
          end;

          vCountWillSplit := 0;
          vLineSpaceCount := 0;
          vExtraW := 0;
          vModWidth := 0;
          viSplitW := ARemWidth;
          SetLength(vDrawItemSplitCounts, ALineEndDItemNo - vLineBegDItemNo + 1);
          for i := vLineBegDItemNo to ALineEndDItemNo do  // �������ֳɼ���
          begin
            if GetDrawItemStyle(i) < THCStyle.RsNull then  // RectItem
            begin
              if (FItems[FDrawItems[i].ItemNo] as THCCustomRectItem).JustifySplit then  // ��ɢ����ռ���
                vDItemSpaceCount := 1  // Graphic��ռ���
              else
                vDItemSpaceCount := 0; // Tab�Ȳ�ռ���
            end
            else  // TextItem
            begin
              vDItemSpaceCount := GetJustifyCount(GetDrawItemText(i), nil);  // ��ǰDItem���˼���
              if (i = ALineEndDItemNo) and (vDItemSpaceCount > 0) then  // ��β��DItem���ٷ�һ��
                Dec(vDItemSpaceCount);
            end;

            vDrawItemSplitCounts[i - vLineBegDItemNo] := vDItemSpaceCount;  // ��¼��ǰDItem�ּ���
            vLineSpaceCount := vLineSpaceCount + vDItemSpaceCount;  // ��¼�����ܹ��ּ���
            if vDItemSpaceCount > 0 then  // ��ǰDItem�зֵ����
              Inc(vCountWillSplit);  // ���ӷֵ�����DItem����
          end;

          if vLineSpaceCount > 1 then  // ��������1
          begin
            viSplitW := ARemWidth div vLineSpaceCount;  // ÿһ�ݵĴ�С
            vDItemSpaceCount := ARemWidth mod vLineSpaceCount;  // ���������ñ���
            if vDItemSpaceCount > vCountWillSplit then  // �����������в���ֵ�DItem������
            begin
              vExtraW := vDItemSpaceCount div vCountWillSplit;  // ����ֵ�ÿһ��DItem�����ٷֵ���
              vModWidth := vDItemSpaceCount mod vCountWillSplit;  // ��������ʣ��(С���в����DItem����)
            end
            else  // ����С�����в���ֵ�DItem����
              vModWidth := vDItemSpaceCount;
          end;

          { ���е�һ��DrawItem���ӵĿռ� }
          if vDrawItemSplitCounts[0] > 0 then
          begin
            FDrawItems[vLineBegDItemNo].Rect.Right := FDrawItems[vLineBegDItemNo].Rect.Right
              + vDrawItemSplitCounts[0] * viSplitW + vExtraW;
            if vModWidth > 0 then  // �����û�з���
            begin
              Inc(FDrawItems[vLineBegDItemNo].Rect.Right);  // ��ǰDrawItem���һ������
              Dec(vModWidth);  // ����ļ���һ������
            end;
          end;

          for i := vLineBegDItemNo + 1 to ALineEndDItemNo do  // �Ե�һ��Ϊ��׼�������DrawItem���ӵĿռ�
          begin
            vW := FDrawItems[i].Width;  // DrawItemԭ��Width
            if vDrawItemSplitCounts[i - vLineBegDItemNo] > 0 then  // �зֵ����
            begin
              vDWidth := vDrawItemSplitCounts[i - vLineBegDItemNo] * viSplitW + vExtraW;  // ��ֵ���width
              if vModWidth > 0 then  // �����û�з���
              begin
                if GetDrawItemStyle(i) < THCStyle.RsNull then
                begin
                  if (FItems[FDrawItems[i].ItemNo] as THCCustomRectItem).JustifySplit then
                  begin
                    Inc(vDWidth);  // ��ǰDrawItem���һ������
                    Dec(vModWidth);  // ����ļ���һ������
                  end;
                end
                else
                begin
                  Inc(vDWidth);  // ��ǰDrawItem���һ������
                  Dec(vModWidth);  // ����ļ���һ������
                end;
              end;
            end
            else  // û�зֵ����
              vDWidth := 0;

            FDrawItems[i].Rect.Left := FDrawItems[i - 1].Rect.Right;

            if GetDrawItemStyle(i) < THCStyle.RsNull then  // RectItem
            begin
              if (FItems[FDrawItems[i].ItemNo] as THCCustomRectItem).JustifySplit then  // ��ɢ����ռ���
                FDrawItems[i].Rect.Right := FDrawItems[i].Rect.Left + vW + vDWidth
              else
                FDrawItems[i].Rect.Right := FDrawItems[i].Rect.Left + vW;
            end
            else  // TextItem
              FDrawItems[i].Rect.Right := FDrawItems[i].Rect.Left + vW + vDWidth;
          end;
        end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'NewDrawItem'}
  procedure NewDrawItem(const AItemNo, AOffs, ACharLen: Integer;
    const ARect: TRect; const AParaFirst, ALineFirst: Boolean);
  var
    vDrawItem: THCCustomDrawItem;
  begin
    vDrawItem := THCCustomDrawItem.Create;
    vDrawItem.ItemNo := AItemNo;
    vDrawItem.CharOffs := AOffs;
    vDrawItem.CharLen := ACharLen;
    vDrawItem.ParaFirst := AParaFirst;
    vDrawItem.LineFirst := ALineFirst;
    vDrawItem.Rect := ARect;
    Inc(ALastDNo);
    FDrawItems.Insert(ALastDNo, vDrawItem);
    if AOffs = 1 then
      FItems[AItemNo].FirstDItemNo := ALastDNo;
  end;
  {$ENDREGION}

  {$REGION 'GetTextPlace'}
  //function GetTextPlace(const AWidth: Integer; const AStr: string): Integer;

  {$REGION '���ַ�'}
  {var
    viLen, viLastCan, vIndex: Integer;
    vWidth, vWidthCan: Integer;
    vTempStr: string;
    vNeedReCalc: Boolean;
    vSize: TSize;
  begin
    vWidthCan := 0;
    vNeedReCalc := False;
    // ���ַ�
    viLastCan := 0;
    viLen := Length(AStr);
    Result := viLen;
    vIndex := Result;
    while Result > 0 do
    begin
      vTempStr := Copy(AStr, 1, Result);
      //vWidth := FStyle.DefCanvas.TextWidth(vTempStr);
      Windows.GetTextExtentPoint32(FStyle.DefCanvas.Handle, vTempStr, Result, vSize);
      vWidth := vSize.cx;
      if vWidth > AWidth then  // �Ų���
      begin
        if viLastCan > 0 then // ���ܷ��µ��Ų���
        begin
          vNeedReCalc := True;  // ��Ҫ����ȷ������ϵ�
          Break;
        end;
        Result := Result - vIndex div 2;  // ��ǰ����
        if Result = vIndex then  // һ��Ҳ�Ų���?
        begin
          vNeedReCalc := True;
          Break;
        end;
        vIndex := Result;
        if Result = viLastCan then
        begin
          vNeedReCalc := False;  // ȷ���ϵ�
          Break;
        end;
      end
      else
      begin
        if Result = viLastCan then
        begin
          vNeedReCalc := False;  // ȷ���ϵ�
          Break;
        end;
        viLastCan := Result;  // ��¼���һ������Ҫ�ϵ��λ��
        vIndex := viLastCan;
        vWidthCan := vWidth;  // ���һ������Ҫ�ϵ���ռ�����
        Result := Result + (viLen - Result) div 2;  // �������
      end;
    end;

    if vNeedReCalc then  // ��Ҫȷ���ϵ�
    begin
      vWidth := AWidth - vWidthCan;  // ������ܷ��µĺ�ʣ����
      viLen := Result - viLastCan;  // ������ܷ��µĵ��Ų��µ��м����
      for vIndex := 1 to viLen do  // �����ж����Ĵ��ϵ�
      begin
        vTempStr := Copy(AStr, viLastCan + 1, vIndex);
        Windows.GetTextExtentPoint32(FStyle.DefCanvas.Handle, vTempStr, vIndex, vSize);
        vWidthCan := vSize.cx;  // FStyle.DefCanvas.TextWidth(vTempStr);
        if vWidthCan > vWidth then
        begin
          Result := viLastCan + vIndex - 1;  // ȷ���ϵ�
          Break;
        end;
      end;
    end;
  end; }
  {$ENDREGION}

  {var
    i, vWidth, vCharWidth: Integer;
  begin
    Result := 0;
    vWidth := FStyle.DefCanvas.TextWidth(AStr);  // ��ǰ�ַ������
    vCharWidth := 0;
    for i := Length(AStr) downto 1 do  // �Ӻ���ǰ�ҽض�λ��(�ȶ��ַ������)
    begin
      vCharWidth := vCharWidth + FStyle.DefCanvas.TextWidth(AStr[i]);  // �Ӻ���ǰ�ַ���Ⱥ�
      if vWidth - vCharWidth <= AWidth then
      begin
        Result := i - 1;
        Break;
      end;
    end;
  end;}
  {$ENDREGION}

  {$REGION 'FindLineBreak'}
  /// <summary>
  /// ��ȡ�ַ����Ű�ʱ�ضϵ���һ�е�λ��
  /// </summary>
  /// <param name="AText"></param>
  /// <param name="APos">�ڵ�X������Ͽ� X > 0</param>
  procedure FindLineBreak(const AText: string; const AStartPos: Integer; var APos: Integer);

    {$REGION 'GetHeadTailBreak �������ס�β���ַ���Լ����������ȡ�ض�λ��'}
    procedure GetHeadTailBreak(const AText: string; var APos: Integer);
    var
      vChar: Char;
    begin
      vChar := AText[APos + 1];  // ��Ϊ��Ҫ����ضϣ�����APos�϶���С��Length(AText)�ģ����ÿ���Խ��
      if PosCharHC(vChar, DontLineFirstChar) > 0 then  // ��һ���ǲ��ܷ������׵��ַ�
      begin
        Dec(APos);  // ��ǰҪ�ƶ�����һ�У���ǰһ���ض������ж�
        GetHeadTailBreak(AText, APos);
      end
      else  // ��һ�����Է������ף���ǰλ���ܷ���õ���β
      begin
        vChar := AText[APos];  // ��ǰλ���ַ�
        if PosCharHC(vChar, DontLineLastChar) > 0 then  // �ǲ��ܷ�����β���ַ�
        begin
          Dec(APos);  // ����ǰѰ�ҽض�λ��
          GetHeadTailBreak(AText, APos);
        end;
      end;
    end;
    {$ENDREGION}

    function MatchBreak(const APrevType, APosType: TCharType): TBreakPosition;
    begin
      Result := jbpNone;
      case APosType of
        jctHZ:
          begin
            if APrevType in [jctZM, jctSZ, jctHZ] then  // ��ǰλ���Ǻ��֣�ǰһ������ĸ�����֡�����
              Result := jbpPrev;
          end;

        jctZM:
          begin
            if not (APrevType in [jctZM, jctSZ]) then  // ��ǰ����ĸ��ǰһ���������֡���ĸ
              Result := jbpPrev;
          end;

        jctSZ:
          begin
            if not (APrevType in [jctZM, jctSZ]) then  // ��ǰ�����֣�ǰһ��������ĸ������
              Result := jbpPrev;
          end;

        jctFH:
          begin
            if APrevType <> jctFH then  // ��ǰ�Ƿ��ţ�ǰһ�����Ƿ���
              Result := jbpPrev;
          end;
      end;
    end;

  var
    i: Integer;
    vPosType, vPrevType, vNextType: TCharType;
  begin
    GetHeadTailBreak(AText, APos);  // �������ס�β��Լ��������APos������ʱӦ������һ��λ�ò����¸�ֵ��APos

    vPosType := GetCharType(Word(AText[APos]));  // ��ǰ����
    vNextType := GetCharType(Word(AText[APos + 1]));  // ��һ���ַ�����

    if MatchBreak(vPosType, vNextType) <> jbpPrev then  // �����ڵ�ǰ�ضϣ���ǰ��ǰ�ҽض�
    begin
      if vPosType <> jctBreak then
      begin
        for i := APos - 1 downto AStartPos + 1 do
        begin
          vPrevType := GetCharType(Word(AText[i]));
          if MatchBreak(vPrevType, vPosType) = jbpPrev then
          begin
            APos := i;
            Break;
          end;

          vPosType := vPrevType;
        end;
      end;
    end;
  end;
  {$ENDREGION}

var
  vText: string;
  vRect: TRect;
  viLen,  // �ı�Item�ַ�������
  vItemHeight,  // ��ǰItem�߶�
  vRemainderWidth
    : Integer;
  vItem: THCCustomItem;
  vRectItem: THCCustomRectItem;
  vParaStyle: THCParaStyle;
  vParaFirst, vLineFirst: Boolean;
  vCharWidths: array of Cardinal;

  procedure DoFormatRectItemToDrawItem;
  var
    vWidth: Integer;
  begin
    vRectItem.FormatToDrawItem(Self, AItemNo);
    vWidth := AContentWidth - APos.X;
    if (vRectItem.Width > vWidth) and (not vLineFirst) then  // ��ǰ��ʣ���ȷŲ����Ҳ�������
    begin
      // ƫ�Ƶ���һ��
      FinishLine(ALastDNo, vWidth);
      APos.X := 0;
      APos.Y := FDrawItems[ALastDNo].Rect.Bottom;
      vLineFirst := True;  // ��Ϊ����
    end;

    // ��ǰ�п������ܷ��»�Ų��µ��Ѿ���������
    vRect.Left := APos.X;
    vRect.Top := APos.Y;
    vRect.Right := vRect.Left + vRectItem.Width;
    vRect.Bottom := vRect.Top + vRectItem.Height + vParaStyle.LineSpace;
    NewDrawItem(AItemNo, AOffset, 1, vRect, vParaFirst, vLineFirst);

    vRemainderWidth := AContentWidth - vRect.Right;  // ������ʣ����
  end;

  /// <summary> ��ָ��ƫ�ƺ�ָ��λ�ÿ�ʼ��ʽ��Text </summary>
  /// <param name="ACharOffset">�ı���ʽ������ʼƫ��</param>
  /// <param name="APlaceWidth">�ʷ��ı��Ŀ��</param>
  /// <param name="ABasePos">vCharWidths�ж�Ӧƫ�Ƶ���ʼλ��</param>
  procedure DoFormatTextItemToDrawItems(const ACharOffset, APlaceWidth, ABasePos: Integer);
  var
    i, viPlaceOffset,  // �ܷ��µڼ����ַ�
    viBreakOffset,  // �ڼ����ַ��Ų���
    vFirstCharWidth  // ��һ���ַ��Ŀ��
      : Integer;
  begin
    vLineFirst := APos.X = 0;
    viBreakOffset := 0;  // ����λ�ã��ڼ����ַ��Ų���
    vFirstCharWidth := vCharWidths[ACharOffset - 1] - ABasePos;  // ��һ���ַ��Ŀ��

    for i := ACharOffset - 1 to viLen - 1 do
    begin
      if vCharWidths[i] - ABasePos > APlaceWidth then
      begin
        viBreakOffset := i + 1;
        Break;
      end;
    end;

    if viBreakOffset < 1 then  // ��ǰ��ʣ��ռ��vTextȫ��������
    begin
      vRect.Left := APos.X;
      vRect.Top := APos.Y;
      vRect.Right := vRect.Left + vCharWidths[viLen - 1] - ABasePos;  // ʹ���Զ�������Ľ��
      vRect.Bottom := vRect.Top + vItemHeight;
      NewDrawItem(AItemNo, ACharOffset, viLen - ACharOffset + 1, vRect, vParaFirst, vLineFirst);
      vParaFirst := False;

      vRemainderWidth := AContentWidth - vRect.Right;  // ���������ʣ����
    end
    else
    if viBreakOffset = 1 then  // ��ǰ��ʣ��ռ�����һ���ַ�Ҳ�Ų���
    begin
      if vFirstCharWidth > AContentWidth then  // Data�Ŀ�Ȳ���һ���ַ�
      begin
        vRect.Left := APos.X;
        vRect.Top := APos.Y;
        vRect.Right := vRect.Left + vCharWidths[viLen - 1] - ABasePos;  // ʹ���Զ�������Ľ��
        vRect.Bottom := vRect.Top + vItemHeight;
        NewDrawItem(AItemNo, ACharOffset, 1, vRect, vParaFirst, vLineFirst);
        vParaFirst := False;

        vRemainderWidth := AContentWidth - vRect.Right;  // ���������ʣ����
        FinishLine(ALastDNo, vRemainderWidth);

        // ƫ�Ƶ���һ�ж��ˣ�׼������һ��
        APos.X := 0;
        APos.Y := FDrawItems[ALastDNo].Rect.Bottom;  // ��ʹ�� vRect.Bottom ��Ϊ������м��иߵģ�������vRect.Bottom

        if viBreakOffset < viLen then
          DoFormatTextItemToDrawItems(viBreakOffset + 1, AContentWidth, vCharWidths[viBreakOffset - 1]);
      end
      else
      begin
        vRemainderWidth := APlaceWidth;
        FinishLine(ALastDNo, vRemainderWidth);
        // ƫ�Ƶ���һ�п�ʼ����
        APos.X := 0;
        APos.Y := FDrawItems[ALastDNo].Rect.Bottom;
        //if not vLineFirst then
        DoFormatTextItemToDrawItems(ACharOffset, AContentWidth, ABasePos);
      end;
    end
    else  // ��ǰ��ʣ�����ܷ��µ�ǰText��һ����
    begin
      if vFirstCharWidth > AContentWidth then  // Data�Ŀ�Ȳ���һ���ַ�
        viPlaceOffset := viBreakOffset
      else
        viPlaceOffset := viBreakOffset - 1;  // ��viBreakOffset���ַ��Ų��£�ǰһ���ܷ���

      FindLineBreak(vText, ACharOffset, viPlaceOffset);  // �жϴ�viPlaceOffset�����Ƿ����

      if viPlaceOffset < ACharOffset then  // �Ҳ����ض�λ�ã�����ԭλ�ýض�(�������ı����Ƕ���)
      begin
        if vFirstCharWidth > AContentWidth then  // Data�Ŀ�Ȳ���һ���ַ�
          viPlaceOffset := viBreakOffset
        else
          viPlaceOffset := viBreakOffset - 1;
      end;

      vRect.Left := APos.X;
      vRect.Top := APos.Y;
      vRect.Right := vRect.Left + vCharWidths[viPlaceOffset - 1] - ABasePos;  // ʹ���Զ�������Ľ��
      vRect.Bottom := vRect.Top + vItemHeight;

      NewDrawItem(AItemNo, ACharOffset, viPlaceOffset - ACharOffset + 1, vRect, vParaFirst, vLineFirst);
      vParaFirst := False;

      vRemainderWidth := AContentWidth - vRect.Right;  // ���������ʣ����
      FinishLine(ALastDNo, vRemainderWidth);

      // ƫ�Ƶ���һ�ж��ˣ�׼������һ��
      APos.X := 0;
      APos.Y := FDrawItems[ALastDNo].Rect.Bottom;  // ��ʹ�� vRect.Bottom ��Ϊ������м��иߵģ�������vRect.Bottom

      if viPlaceOffset < viLen then
        DoFormatTextItemToDrawItems(viPlaceOffset + 1, AContentWidth, vCharWidths[viPlaceOffset - 1]);
    end;
  end;

var
  vSize: TSize;
begin
  if not FItems[AItemNo].Visible then Exit;

  vRemainderWidth := 0;
  vItem := FItems[AItemNo];
  vParaStyle := FStyle.ParaStyles[vItem.ParaNo];
  if (AOffset = 1) and vItem.ParaFirst then  // ��һ�δ���ε�һ��Item
  begin
    vParaFirst := True;
    vLineFirst := True;
  end
  else  // �Ƕε�1��
  begin
    vParaFirst := False;
    vLineFirst := APos.X = 0;
  end;

  if vItem.StyleNo < THCStyle.RsNull then  // ��RectItem
  begin
    vRectItem := vItem as THCCustomRectItem;
    DoFormatRectItemToDrawItem;
  end
  else  // �ı�
  begin
    FStyle.TextStyles[vItem.StyleNo].ApplyStyle(FStyle.DefCanvas);
    //vItemHeight := FStyle.DefCanvas.TextHeight('��') + vParaStyle.LineSpace;  // �и�
    Windows.GetTextExtentPoint32(FStyle.DefCanvas.Handle, '��', 1, vSize);
    vItemHeight := vSize.cy + vParaStyle.LineSpace;  // �и�
    vRemainderWidth := AContentWidth - APos.X;
    vText := vItem.Text;

    if vText = '' then  // ��item(�϶��ǿ���)
    begin
      Assert(vItem.ParaFirst, HCS_EXCEPTION_NULLTEXT);
      vRect.Left := APos.X;
      vRect.Top := APos.Y;
      vRect.Right := 0;
      vRect.Bottom := vRect.Top + vItemHeight;  //DefaultCaretHeight;
      vParaFirst := True;
      vLineFirst := True;
      NewDrawItem(AItemNo, AOffset, 0, vRect, vParaFirst, vLineFirst);
      vParaFirst := False;
    end
    else  // �ǿ�Item
    begin
      viLen := Length(vText);
      SetLength(vCharWidths, viLen);

      GetTextExtentExPoint(FStyle.DefCanvas.Handle, PChar(vText), viLen, 0,  //vRemainderWidth,
        nil, PInteger(vCharWidths), vSize);

      DoFormatTextItemToDrawItems(AOffset, AContentWidth - APos.X, 0);

      SetLength(vCharWidths, 0);
    end;
  end;

  // ������һ����λ��
  if AItemNo = FItems.Count - 1 then  // �����һ��
    FinishLine(ALastDNo, vRemainderWidth)
  else  // �������һ������Ϊ��һ��Item׼��λ��
  begin
    if FItems[AItemNo + 1].ParaFirst then // ��һ���Ƕ���ʼ
    begin
      FinishLine(ALastDNo, vRemainderWidth);
      // ƫ�Ƶ���һ�ж��ˣ�׼������һ��
      APos.X := 0;
      APos.Y := FDrawItems[ALastDNo].Rect.Bottom;  // ��ʹ�� vRect.Bottom ��Ϊ������м��иߵģ���������bottom
    end
    else  // ��һ�����Ƕ���ʼ
      APos.X := vRect.Right;  // ��һ������ʼ����
  end;
end;

function THCCustomData.IsLineLastDrawItem(const ADrawItemNo: Integer): Boolean;
begin
  // �����ڸ�ʽ��������ʹ�ã���ΪDrawItems.Count����ֻ�ǵ�ǰ��ʽ������Item
  Result := (ADrawItemNo = FDrawItems.Count - 1) or (FDrawItems[ADrawItemNo + 1].LineFirst);
  {(ADItemNo < FDrawItems.Count - 1) and (not FDrawItems[ADItemNo + 1].LineFirst)}
end;

function THCCustomData.IsParaLastDrawItem(const ADrawItemNo: Integer): Boolean;
var
  vItemNo: Integer;
begin
  Result := False;
  vItemNo := FDrawItems[ADrawItemNo].ItemNo;
  if vItemNo < FItems.Count - 1 then  // �������һ��Item
  begin
    if FItems[vItemNo + 1].ParaFirst then  // ��һ���Ƕ���
      Result := FDrawItems[ADrawItemNo].CharOffsetEnd = FItems[vItemNo].Length;  // ��Item���һ��DrawItem
  end
  else  // �����һ��Item
    Result := FDrawItems[ADrawItemNo].CharOffsetEnd = FItems[vItemNo].Length;  // ��Item���һ��DrawItem
  // �����������������жϣ���Ϊ���ڸ�ʽ������ʱ����ǰ�϶���DrawItems�����һ��
  //Result :=(ADItemNo = FDrawItems.Count - 1) or (FDrawItems[ADItemNo + 1].ParaFirst);
end;

function THCCustomData.IsParaLastItem(const AItemNo: Integer): Boolean;
begin
  Result := (AItemNo = FItems.Count - 1) or (FItems[AItemNo + 1].ParaFirst);
end;

procedure THCCustomData.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  Clear;
end;

procedure THCCustomData.MarkStyleUsed(const AMark: Boolean);
var
  i: Integer;
  vItem: THCCustomItem;
begin
  for i := 0 to FItems.Count - 1 do
  begin
    vItem := FItems[i];
    if AMark then  // ���
    begin
      FStyle.ParaStyles[vItem.ParaNo].CheckSaveUsed := True;
      if vItem.StyleNo < THCStyle.RsNull then
        (vItem as THCCustomRectItem).MarkStyleUsed(AMark)
      else
        FStyle.TextStyles[vItem.StyleNo].CheckSaveUsed := True;
    end
    else  // ���¸�ֵ
    begin
      vItem.ParaNo := FStyle.ParaStyles[vItem.ParaNo].TempNo;
      if vItem.StyleNo < THCStyle.RsNull then
        (vItem as THCCustomRectItem).MarkStyleUsed(AMark)
      else
        vItem.StyleNo := FStyle.TextStyles[vItem.StyleNo].TempNo;
    end;
  end;
end;

procedure THCCustomData.MatchItemSelectState;

  {$REGION ' CheckItemSelectedState���ĳ��Item��ѡ��״̬ '}
  procedure CheckItemSelectedState(const AItemNo: Integer);
  begin
    if (AItemNo > SelectInfo.StartItemNo) and (AItemNo < SelectInfo.EndItemNo) then  // ��ѡ�з�Χ֮��
      Items[AItemNo].SelectComplate
    else
    if AItemNo = SelectInfo.StartItemNo then  // ѡ����ʼ
    begin
      if AItemNo = SelectInfo.EndItemNo then  // ѡ����ͬһ��Item
      begin
        if Items[AItemNo].StyleNo < THCStyle.RsNull then  // RectItem
        begin
          if (SelectInfo.StartItemOffset = OffsetInner)
            or (SelectInfo.EndItemOffset = OffsetInner)
          then
            Items[AItemNo].SelectPart
          else
            Items[AItemNo].SelectComplate;
        end
        else  // TextItem
        begin
          if (SelectInfo.StartItemOffset = 0)
            and (SelectInfo.EndItemOffset = Items[AItemNo].Length)
          then
            Items[AItemNo].SelectComplate
          else
            Items[AItemNo].SelectPart;
        end;
      end
      else  // ѡ���ڲ�ͬ��Item����ǰ����ʼ
      begin
        if SelectInfo.StartItemOffset = 0 then
          Items[AItemNo].SelectComplate
        else
          Items[AItemNo].SelectPart;
      end;
    end
    else  // ѡ���ڲ�ͬ��Item����ǰ�ǽ�β if AItemNo = SelectInfo.EndItemNo) then
    begin
      if Items[AItemNo].StyleNo < THCStyle.RsNull then  // RectItem
      begin
        if SelectInfo.EndItemOffset = OffsetAfter then
          Items[AItemNo].SelectComplate
        else
          Items[AItemNo].SelectPart;
      end
      else  // TextItem
      begin
        if SelectInfo.EndItemOffset = Items[AItemNo].Length then
          Items[AItemNo].SelectComplate
        else
          Items[AItemNo].SelectPart;
      end;
    end;
  end;
  {$ENDREGION}

var
  i: Integer;
begin
  if SelectExists then
  begin
    for i := SelectInfo.StartItemNo to SelectInfo.EndItemNo do  // ��ʼ����֮��İ�ȫѡ�д���
      CheckItemSelectedState(i);
  end;
end;

function THCCustomData.OffsetInSelect(const AItemNo, AOffset: Integer): Boolean;
begin
  Result := False;
  if (AItemNo < 0) or (AOffset < 0) then Exit;

  if FItems[AItemNo].StyleNo < THCStyle.RsNull then // ���ı������жϣ�����Ҫ��ȷ��CoordInSelect��ӵ���
  begin
    if (AOffset = OffsetInner) and FItems[AItemNo].IsSelectComplate then
      Result := True;

    Exit;
  end;

  if SelectExists then
  begin
    if (AItemNo > FSelectInfo.StartItemNo) and (AItemNo < FSelectInfo.EndItemNo) then
      Result := True
    else
    if AItemNo = FSelectInfo.StartItemNo then
    begin
      if AItemNo = FSelectInfo.EndItemNo then
        Result := (AOffset >= FSelectInfo.StartItemOffset) and (AOffset <= FSelectInfo.EndItemOffset)
      else
        Result := AOffset >= FSelectInfo.StartItemOffset;
    end
    else
    if AItemNo = FSelectInfo.EndItemNo then
      Result := AOffset <= FSelectInfo.EndItemOffset;
  end;
end;

procedure THCCustomData.PaintData(const ADataDrawLeft, ADataDrawTop, ADataDrawBottom,
  ADataScreenTop, ADataScreenBottom, AVOffset: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vFristDItemNo, vLastDItemNo: Integer;
  vTextDrawTop: Integer;

  {$REGION ' ��ǰ��ʾ��Χ��Ҫ���Ƶ�DrawItemȫ����ѡ�е� '}
  function DrawItemSelectAll: Boolean;
  var
    vSelStartDItemNo, vSelEndDItemNo: Integer;
  begin
    vSelStartDItemNo := GetSelectStartDrawItemNo;
    vSelEndDItemNo := GetSelectEndDrawItemNo;

    Result :=  // ��ǰҳ�Ƿ�ȫѡ����
      (
        (vSelStartDItemNo < vFristDItemNo)
        or
        (
          (vSelStartDItemNo = vFristDItemNo)
          and
          (SelectInfo.StartItemOffset = FDrawItems[vSelStartDItemNo].CharOffs)
        )
      )
      and
      (
        (vSelEndDItemNo > vLastDItemNo)
        or
        (
          (vSelEndDItemNo = vLastDItemNo)
          and
          (SelectInfo.EndItemOffset = FDrawItems[vSelEndDItemNo].CharOffs + FDrawItems[vSelEndDItemNo].CharLen)
        )
      );
  end;
  {$ENDREGION}

  {$REGION ' DrawTextJsutify 20170220001 ��ɢ������ش��� '}
  procedure DrawTextJsutify(const ARect: TRect; const AText: string; const ALineLast: Boolean);
  var
    vSplitCount, vX, vLen, viSplitW, vMod: Integer;
    vSplitList: THCIntegerList;
    i: Integer;
    vS: string;
    //vRect: TRect;
  begin
    vMod := 0;
    vX := ARect.Left;
    viSplitW := (ARect.Right - ARect.Left) - FStyle.DefCanvas.TextWidth(AText);
    // ���㵱ǰDitem���ݷֳɼ��ݣ�ÿһ���������е���ʼλ��
    vSplitList := THCIntegerList.Create;
    try
      vSplitCount := GetJustifyCount(AText, vSplitList);
      if ALineLast and (vSplitCount > 0) then  // �����DItem���ٷ�һ��
        Dec(vSplitCount);
      if vSplitCount > 0 then  // �зֵ����
      begin
        vMod := viSplitW mod vSplitCount;
        viSplitW := viSplitW div vSplitCount;
      end;

      for i := 0 to vSplitList.Count - 2 do  // vSplitList���һ�����ַ����������Զ��1
      begin
        vLen := vSplitList[i + 1] - vSplitList[i];
        vS := Copy(AText, vSplitList[i], vLen);
        //vRect := Rect(vX, vTextDrawTop, ARect.Right, ARect.Bottom);
        //Windows.DrawText(ACanvas.Handle, vS, -1, vRect, DT_LEFT or DT_SINGLELINE or vAlignVert);
        //ACanvas.TextOut(vX, vTextDrawTop, vS);

        { 201805161718
        ETO_CLIPPED�����Ľ��ü��������С�
        ETO_GLYPH_INDEX��LpStringָ����GetCharacterPlacement���ص����飬���û�н�һ�����������Դ����Ҫ���������ֱ����GDI��������������Ӧ�÷������������˱�־������λͼ���������壬�Ա�ʾ��������һ�������Դ���GDIӦ��ֱ�Ӵ�����ַ�����
        ETO_OPAQUE���õ�ǰ�ı���ɫ�������Ρ�
        ETO_RTLREADING����Middle_Eastern Windows�����ָ���˴�ֵ����Hebrew��Arabic���屻ѡ���豸����������ַ������Դ��ҵ�����Ķ�˳������������û��ָ����ֵ�����ַ����Դ����ҵ�˳���������SetTextAlign������TA_RTLREADINGֵ�ɻ��ͬ����Ч����Ϊ�����ݣ���ֵ��Ϊ����ֵ��
        ETO_GLYPH_INDEX��ETO_RTLREADINGֵ������һ��ʹ�á���ΪETO_GLYPH_INDEX��ʾ���е����Դ����Ѿ���ɣ������ͻ���Ա�ָ����ETO_RTLREADINGֵ��}
        Windows.ExtTextOut(ACanvas.Handle, vX, vTextDrawTop, ETO_OPAQUE,
          nil, PChar(vS), vLen, nil);
        vX := vX + FStyle.DefCanvas.TextWidth(vS) + viSplitW;
        if vMod > 0 then
        begin
          Inc(vX);
          Dec(vMod);
        end;
      end;
    finally
      vSplitList.Free;
    end;
  end;
  {$ENDREGION}

var
  i, vSelStartDNo, vSelStartDOffs, vSelEndDNo, vSelEndDOffs,
  vPrioStyleNo, vPrioParaNo, vVOffset, vTextHeight: Integer;
  vItem: THCCustomItem;
  vRectItem: THCCustomRectItem;
  vDItem: THCCustomDrawItem;
  vAlignHorz: TParaAlignHorz;
  vDrawRect: TRect;
  S: string;

  //vCharWidths: array of Integer;
  {j, vFit, }vLen: Integer;
  //vSize: TSize;

  vDrawsSelectAll: Boolean;
  vDCState: Integer;
begin
  if FItems.Count = 0 then Exit;

  vVOffset := ADataDrawTop - AVOffset;  // ��������ʼλ��ӳ�䵽����λ��

  GetDataDrawItemRang(Max(ADataDrawTop, ADataScreenTop) - vVOffset,  // ����ʾ������DItem��Χ
    Min(ADataDrawBottom, ADataScreenBottom) - vVOffset, vFristDItemNo, vLastDItemNo);

  if (vFristDItemNo < 0) or (vLastDItemNo < 0) then Exit;

  // ѡ����Ϣ
  vSelStartDNo := GetSelectStartDrawItemNo;  // ѡ����ʼDItem
  if vSelStartDNo < 0 then
    vSelStartDOffs := -1
  else
    vSelStartDOffs := FSelectInfo.StartItemOffset - FDrawItems[vSelStartDNo].CharOffs + 1;
  vSelEndDNo := GetSelectEndDrawItemNo;      // ѡ�н���DrawItem
  if vSelEndDNo < 0 then
    vSelEndDOffs := -1
  else
    vSelEndDOffs := FSelectInfo.EndItemOffset - FDrawItems[vSelEndDNo].CharOffs + 1;
  vDrawsSelectAll := DrawItemSelectAll;

  vPrioStyleNo := -1;
  vPrioParaNo := -1;

  ACanvas.Refresh;
  vDCState := SaveDC(ACanvas.Handle);
  try
    for i := vFristDItemNo to vLastDItemNo do  // ����Ҫ���Ƶ�����
    begin
      vDItem := FDrawItems[i];
      vItem := FItems[vDItem.ItemNo];
      vDrawRect := vDItem.Rect;
      OffsetRect(vDrawRect, ADataDrawLeft, vVOffset);  // ƫ�Ƶ�ָ���Ļ�������λ��(SectionDataʱΪҳ�����ڸ�ʽ���п���ʾ��ʼλ��)

      { ��������ǰ }
      DrawItemPaintBefor(Self, i, vDrawRect, ADataDrawLeft, ADataDrawBottom,
        ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);

      if vPrioParaNo <> vItem.ParaNo then  // ˮƽ���뷽ʽ
      begin
        vPrioParaNo := vItem.ParaNo;
        vAlignHorz := FStyle.ParaStyles[vItem.ParaNo].AlignHorz;  // ������ˮƽ���뷽ʽ
      end;

      if vItem.StyleNo < THCStyle.RsNull then  // RectItem���д������
      begin
        vRectItem := vItem as THCCustomRectItem;

        vPrioStyleNo := vRectItem.StyleNo;

        if vRectItem.IsSelectComplate then  // ѡ�б�������
        begin
          ACanvas.Brush.Color := FStyle.SelColor;
          ACanvas.FillRect(vDrawRect);
        end;
        // ��ȥ�м�ྻRect�������ݵ���ʾ����(����Ҫ��ȥ����ΪvDrawRect�Ѿ��Ǿ�����)
        InflateRect(vDrawRect, 0, -FStyle.ParaStyles[vItem.ParaNo].LineSpaceHalf);
        if vRectItem.JustifySplit then  // ��ɢռ�ռ�
          vDrawRect.Right := vDrawRect.Left + vRectItem.Width;

        case FStyle.ParaStyles[vItem.ParaNo].AlignVert of  // ��ֱ���뷽ʽ
          pavCenter: InflateRect(vDrawRect, 0, -(vDrawRect.Height - vRectItem.Height) div 2);
          pavTop: ;
        else
          vDrawRect.Top := vDrawRect.Bottom - vRectItem.Height;
        end;

        vItem.PaintTo(FStyle, vDrawRect, ADataDrawTop, ADataDrawBottom,
          ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
      end
      else  // �ı�Item
      begin
        if vItem.StyleNo <> vPrioStyleNo then  // ��Ҫ����Ӧ����ʽ
        begin
          vPrioStyleNo := vItem.StyleNo;
          FStyle.TextStyles[vPrioStyleNo].ApplyStyle(ACanvas);
          FStyle.TextStyles[vPrioStyleNo].ApplyStyle(FStyle.DefCanvas);
          vTextHeight := FStyle.DefCanvas.TextHeight('��');
        end;

        // ���ֱ���
        if ACanvas.Brush.Style <> bsClear then
        begin
          ACanvas.Brush.Color := FStyle.TextStyles[vPrioStyleNo].BackColor;
          ACanvas.FillRect(Rect(vDrawRect.Left, vDrawRect.Top, vDrawRect.Left + vDItem.Width, vDrawRect.Bottom));
        end;

        { �������֡��Ρ�ѡ������µı��� }
        if not APaintInfo.Print then  // ���Ǵ�ӡ
        begin
          if vDrawsSelectAll then  // ��ǰҪ���Ƶ���ʼ�ͽ���DrawItem����ѡ�л�Ԫ��ȫѡ�У�����Ϊѡ��
          begin
            ACanvas.Brush.Color := FStyle.SelColor;
            ACanvas.FillRect(Rect(vDrawRect.Left, vDrawRect.Top,
              vDrawRect.Left + vDItem.Width, Math.Min(vDrawRect.Bottom, ADataScreenBottom)));
          end
          else  // ����һ����ѡ��
          if vSelEndDNo >= 0 then  // ��ѡ�����ݣ����ֱ���Ϊѡ��
          begin
            ACanvas.Brush.Color := FStyle.SelColor;
            if (vSelStartDNo = vSelEndDNo) and (i = vSelStartDNo) then  // ѡ�����ݶ��ڵ�ǰDrawItem
            begin
              ACanvas.FillRect(Rect(vDrawRect.Left + GetDrawItemOffsetWidth(i, vSelStartDOffs),
                vDrawRect.Top,
                vDrawRect.Left + GetDrawItemOffsetWidth(i, vSelEndDOffs),
                Math.Min(vDrawRect.Bottom, ADataScreenBottom)));
            end
            else
            if i = vSelStartDNo then  // ѡ���ڲ�ͬDrawItem����ǰ����ʼ
            begin
              ACanvas.FillRect(Rect(vDrawRect.Left + GetDrawItemOffsetWidth(i, vSelStartDOffs),
                vDrawRect.Top,
                vDrawRect.Right,
                Math.Min(vDrawRect.Bottom, ADataScreenBottom)));
            end
            else
            if i = vSelEndDNo then  // ѡ���ڲ�ͬ��DrawItem����ǰ�ǽ���
            begin
              ACanvas.FillRect(Rect(vDrawRect.Left,
                vDrawRect.Top,
                vDrawRect.Left + GetDrawItemOffsetWidth(i, vSelEndDOffs),
                Math.Min(vDrawRect.Bottom, ADataScreenBottom)));
            end
            else
            if (i > vSelStartDNo) and (i < vSelEndDNo) then  // ѡ����ʼ�ͽ���DrawItem֮���DrawItem
              ACanvas.FillRect(vDrawRect);
          end;
        end;

        // ��ȥ�м�ྻRect�������ݵ���ʾ����
        InflateRect(vDrawRect, 0, -FStyle.ParaStyles[vItem.ParaNo].LineSpaceHalf);
        if tsSuperscript in FStyle.TextStyles[vPrioStyleNo].FontStyle then
          vDrawRect.Bottom := vDrawRect.Top + vTextHeight
        else
        if tsSubscript in FStyle.TextStyles[vPrioStyleNo].FontStyle then
          vDrawRect.Top := vDrawRect.Bottom - vTextHeight;

        vItem.PaintTo(FStyle, vDrawRect, ADataDrawTop, ADataDrawBottom,
          ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);  // ����Item�����¼�

        // �����ı�
        ACanvas.Brush.Style := bsClear;
        S := Copy(vItem.Text, vDItem.CharOffs, vDItem.CharLen);  // Ϊ�����жϣ�û��ֱ��ʹ��GetDrawItemText(i)
        if S <> '' then
        begin
          case FStyle.ParaStyles[vItem.ParaNo].AlignVert of  // ��ֱ���뷽ʽ
            pavCenter: vTextDrawTop := vDrawRect.Top + (vDrawRect.Bottom - vDrawRect.Top - vTextHeight) div 2;
            pavTop: vTextDrawTop := vDrawRect.Top;
          else
            vTextDrawTop := vDrawRect.Bottom - vTextHeight;
          end;

          case vAlignHorz of  // ˮƽ���뷽ʽ
            pahLeft, pahRight, pahCenter:  // һ�����
              begin
                {vLen := Length(S);
                SetLength(vCharWidths, vLen);
                if GetTextExtentExPoint(FStyle.DefCanvas.Handle, PChar(S), vLen,
                  vDrawRect.Right, @vFit, PInteger(vCharWidths), vSize)
                then
                begin
                  for j := vLen - 1 downto 1 do
                    Dec(vCharWidths[j], vCharWidths[j - 1]);
                  case vAlignVert of
                    DT_TOP: vDrawTop := vDrawRect.Top;
                    DT_CENTER: vDrawTop := vDrawRect.Top + (vDrawRect.Bottom - vDrawRect.Top - vTextHeight) div 2;
                  else
                    vDrawTop := vDrawRect.Bottom - vTextHeight;
                  end;
                  ExtTextOut(ACanvas.Handle, vDrawRect.Left, vDrawTop, ETO_CLIPPED, @vDrawRect, S, vLen, PInteger(vCharWidths));
                end
                else
                  Windows.DrawText(ACanvas.Handle, S, -1, vDrawRect, DT_LEFT or DT_SINGLELINE or vAlignVert);} // -1ȫ��

                vLen := Length(S);

                Windows.ExtTextOut(ACanvas.Handle, vDrawRect.Left, vTextDrawTop,
                  ETO_OPAQUE, nil, PChar(S), vLen, nil);  // ����˵���� 201805161718
                //Windows.TextOut(ACanvas.Handle, vDrawRect.Left, vTextDrawTop, PChar(S), vLen);
              end;

            pahJustify, pahScatter:  // ��ɢ�����˶���
              DrawTextJsutify(vDrawRect, S, IsLineLastDrawItem(i));
          end;
        end
        else  // ����
        begin
          if not vItem.ParaFirst then  // ���ǿ���
            raise Exception.Create(HCS_EXCEPTION_NULLTEXT);
        end;
      end;

      DrawItemPaintAfter(Self, i, vDrawRect, ADataDrawLeft, ADataDrawBottom,
        ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);  // �������ݺ�
    end;
  finally
    RestoreDC(ACanvas.Handle, vDCState);
    //ACanvas.Refresh;  Ϊʲô����䣬������ر߿��ĳЩ��Ԫ����Ʊ߿���ȷ��
  end;
end;

procedure THCCustomData.FormatItemPrepare(const AStartItemNo: Integer;
  const AEndItemNo: Integer = -1);
var
  vFirstDrawItemNo, vLastDrawItemNo: Integer;
begin
  vFirstDrawItemNo := FItems[AStartItemNo].FirstDItemNo;
  if AEndItemNo < 0 then
    vLastDrawItemNo := GetItemLastDrawItemNo(AStartItemNo)
  else
    vLastDrawItemNo := GetItemLastDrawItemNo(AEndItemNo);
  FDrawItems.MarkFormatDelete(vFirstDrawItemNo, vLastDrawItemNo);
  FDrawItems.FormatBeforBottom := FDrawItems[vLastDrawItemNo].Rect.Bottom;
end;

procedure THCCustomData.SaveToStream(const AStream: TStream);
begin
  SaveToStream(AStream, 0, 0, Items.Count - 1, Items.Last.Length);
end;

procedure THCCustomData.SaveSelectToStream(const AStream: TStream);
begin
  if SelectExists then
  begin
    if (FSelectInfo.EndItemNo < 0)
      and (FItems[FSelectInfo.StartItemNo].StyleNo < THCStyle.RsNull)
    then  // ѡ������ͬһ��RectItem
    begin
      if FItems[FSelectInfo.StartItemNo].IsSelectComplate then  // ȫѡ����
      begin
        Self.SaveToStream(AStream, FSelectInfo.StartItemNo, OffsetBefor,
          FSelectInfo.StartItemNo, OffsetAfter);
      end
      else
        (FItems[FSelectInfo.StartItemNo] as THCCustomRectItem).SaveSelectToStream(AStream);
    end
    else
    begin
      Self.SaveToStream(AStream, FSelectInfo.StartItemNo, FSelectInfo.StartItemOffset,
        FSelectInfo.EndItemNo, FSelectInfo.EndItemOffset);
    end;
  end;
end;

function THCCustomData.SaveSelectToText: string;
begin
  Result := '';

  if SelectExists then
  begin
    if (FSelectInfo.EndItemNo < 0) and (FItems[FSelectInfo.StartItemNo].StyleNo < THCStyle.RsNull) then
      Result := (FItems[FSelectInfo.StartItemNo] as THCCustomRectItem).SaveSelectToText
    else
    begin
      Result := Self.SaveToText(FSelectInfo.StartItemNo, FSelectInfo.StartItemOffset,
        FSelectInfo.EndItemNo, FSelectInfo.EndItemOffset);
    end;
  end;
end;

procedure THCCustomData.SaveToStream(const AStream: TStream; const AStartItemNo,
  AStartOffset, AEndItemNo, AEndOffset: Integer);
var
  i: Integer;
  vBegPos, vEndPos: Int64;
begin
  vBegPos := AStream.Position;
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ���ݴ�Сռλ������Խ��
  //
  { if IsEmpty then i := 0 else ��ItemҲҪ�棬CellData����ʱ�߶ȿ��ɴ�Item��ʽ���� }
  i := AEndItemNo - AStartItemNo + 1;
  AStream.WriteBuffer(i, SizeOf(i));
  if i > 0 then
  begin
    if AStartItemNo <> AEndItemNo then
    begin
      FItems[AStartItemNo].SaveToStream(AStream, AStartOffset, FItems[AStartItemNo].Length);
      for i := AStartItemNo + 1 to AEndItemNo - 1 do
        FItems[i].SaveToStream(AStream);
      FItems[AEndItemNo].SaveToStream(AStream, 0, AEndOffset);
    end
    else
      FItems[AStartItemNo].SaveToStream(AStream, AStartOffset, AEndOffset);
  end;
  //
  vEndPos := AStream.Position;
  AStream.Position := vBegPos;
  vBegPos := vEndPos - vBegPos - SizeOf(vBegPos);
  AStream.WriteBuffer(vBegPos, SizeOf(vBegPos));  // ��ǰҳ���ݴ�С
  AStream.Position := vEndPos;
end;

function THCCustomData.SaveToText(const AStartItemNo, AStartOffset, AEndItemNo,
  AEndOffset: Integer): string;
var
  i: Integer;
begin
  Result := '';
  i := AEndItemNo - AStartItemNo + 1;
  if i > 0 then
  begin
    if AStartItemNo <> AEndItemNo then
    begin
      if FItems[AStartItemNo].StyleNo > THCStyle.RsNull then
        Result := (FItems[AStartItemNo] as THCTextItem).GetTextPart(AStartOffset + 1, FItems[AStartItemNo].Length - AStartOffset)
      else
        Result := (FItems[AStartItemNo] as THCCustomRectItem).SaveSelectToText;

      for i := AStartItemNo + 1 to AEndItemNo - 1 do
        Result := Result + FItems[i].Text;

      if FItems[AEndItemNo].StyleNo > THCStyle.RsNull then
        Result := Result + (FItems[AEndItemNo] as THCTextItem).GetTextPart(1, AEndOffset)
      else
        Result := (FItems[AEndItemNo] as THCCustomRectItem).SaveSelectToText;
    end
    else  // ѡ����ͬһItem
    begin
      if FItems[AStartItemNo].StyleNo > THCStyle.RsNull then
        Result := (FItems[AStartItemNo] as THCTextItem).GetTextPart(AStartOffset + 1, AEndOffset - AStartOffset);
    end;
  end;
end;

function THCCustomData.SaveToText: string;
begin
  SaveToText(0, 0, Items.Count - 1, Items.Last.Length);
end;

procedure THCCustomData.SelectAll;
begin
  if FItems.Count > 0 then
  begin
    FSelectInfo.StartItemNo := 0;
    FSelectInfo.StartItemOffset := 0;
    if not IsEmptyData then
    begin
      FSelectInfo.EndItemNo := FItems.Count - 1;
      if FItems[FSelectInfo.EndItemNo].StyleNo < THCStyle.RsNull then
        FSelectInfo.EndItemOffset := OffsetAfter
      else
        FSelectInfo.EndItemOffset := FItems.Last.Length;
    end
    else
    begin
      FSelectInfo.EndItemNo := -1;
      FSelectInfo.EndItemOffset := -1;
    end;

    MatchItemSelectState;
  end;
end;

function THCCustomData.SelectedCanDrag: Boolean;
var
  i: Integer;
begin
  Result := True;
  if FSelectInfo.EndItemNo < 0 then
  begin
    if FSelectInfo.StartItemNo >= 0 then
      Result := FItems[FSelectInfo.StartItemNo].CanDrag;
  end
  else
  begin
    for i := FSelectInfo.StartItemNo to FSelectInfo.EndItemNo do
    begin
      if FItems[i].StyleNo < THCStyle.RsNull then
      begin
        if not FItems[i].IsSelectComplate then
        begin
          Result := False;
          Break;
        end;
      end;

      if not FItems[i].CanDrag then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

function THCCustomData.SelectedResizing: Boolean;
begin
  Result := False;
  if (FSelectInfo.StartItemNo >= 0)
    and (FSelectInfo.EndItemNo < 0)
    and (FItems[FSelectInfo.StartItemNo] is THCResizeRectItem)
  then
    Result := (FItems[FSelectInfo.StartItemNo] as THCResizeRectItem).Resizing;
end;

function THCCustomData.SelectedAll: Boolean;
begin
  Result := (FSelectInfo.StartItemNo = 0)
    and (FSelectInfo.StartItemOffset = 0)
    and (FSelectInfo.EndItemNo = FItems.Count - 1);
  if Result then
  begin
    if FItems[FSelectInfo.EndItemNo].StyleNo < THCStyle.RsNull then
      Result := FSelectInfo.EndItemOffset = OffsetAfter
    else
      Result := FSelectInfo.EndItemOffset = FItems.Last.Length;
  end;
end;

function THCCustomData.SelectExists(const AIfRectItem: Boolean = True): Boolean;
begin
  Result := False;
  if FSelectInfo.StartItemNo >= 0 then
  begin
    if FSelectInfo.EndItemNo >= 0 then
    begin
      if FSelectInfo.StartItemNo <> FSelectInfo.EndItemNo then  // ѡ���ڲ�ͬ��Item
        Result := True
      else  // ��ͬһItem
        Result := FSelectInfo.StartItemOffset <> FSelectInfo.EndItemOffset;  // ͬһItem��ͬλ��
    end
    else  // ��ǰ������һ��Item��(��Rect�м�ʹ��ѡ�У���Ե�ǰ���DataҲ����һ��Item)
    begin
      if AIfRectItem and (FItems[FSelectInfo.StartItemNo].StyleNo < THCStyle.RsNull) then
      begin
        //if FSelectInfo.StartItemOffset = OffsetInner then  �������ѡ��ʱ������
          Result := (FItems[FSelectInfo.StartItemNo] as THCCustomRectItem).SelectExists;
      end;
    end;
  end;
end;

function THCCustomData.SelectInSameDItem: Boolean;
var
  vStartDNo: Integer;
begin
  vStartDNo := GetSelectStartDrawItemNo;
  if vStartDNo < 0 then
    Result := False
  else
  begin
    if GetDrawItemStyle(vStartDNo) < THCStyle.RsNull then
      Result := FItems[FDrawItems[vStartDNo].ItemNo].IsSelectComplate and (FSelectInfo.EndItemNo < 0)
    else
      Result := vStartDNo = GetSelectEndDrawItemNo;
  end;
end;

procedure THCCustomData.SetCaretDrawItemNo(const Value: Integer);
var
  vItemNo: Integer;
begin
  if FCaretDrawItemNo <> Value then
  begin
    if (FCaretDrawItemNo >= 0) and (FCaretDrawItemNo < FDrawItems.Count) then
    begin
      vItemNo := FDrawItems[FCaretDrawItemNo].ItemNo;
      FItems[vItemNo].Active := False;
    end
    else
      vItemNo := -1;

    FCaretDrawItemNo := Value;

    if (FCaretDrawItemNo >= 0) and (FDrawItems[FCaretDrawItemNo].ItemNo <> vItemNo) then
    begin
      if FItems[FDrawItems[FCaretDrawItemNo].ItemNo].StyleNo < THCStyle.RsNull then
      begin
        if FSelectInfo.StartItemOffset = OffsetInner then
          FItems[FDrawItems[FCaretDrawItemNo].ItemNo].Active := True
      end
      else
        FItems[FDrawItems[FCaretDrawItemNo].ItemNo].Active := True;
    end;
  end;
end;

procedure THCCustomData.GetCaretInfo(const AItemNo, AOffset: Integer;
  var ACaretInfo: TCaretInfo);
var
  vDrawItemNo, vStyleItemNo: Integer;
  vDrawItem: THCCustomDrawItem;
begin
  { ע�⣺Ϊ����RectItem�������������λ�ô���Ϊ���ӣ�������ֱ�Ӹ�ֵ }
  if FCaretDrawItemNo < 0 then
  begin
    if FItems[AItemNo].StyleNo < THCStyle.RsNull then  // RectItem
      vDrawItemNo := FItems[AItemNo].FirstDItemNo
    else
      vDrawItemNo := GetDrawItemNoByOffset(AItemNo, AOffset);  // AOffset����Ӧ��DrawItemNo
  end
  else
    vDrawItemNo := FCaretDrawItemNo;

  vDrawItem := FDrawItems[vDrawItemNo];
  ACaretInfo.Height := vDrawItem.Height;  // ���߶�

  if FStyle.UpdateInfo.ReStyle then  // �Թ��ǰ��ʽΪ��ǰ��ʽ
  begin
    vStyleItemNo := AItemNo;
    if AOffset = 0 then  // ����ǰ��
    begin
      if (not FItems[AItemNo].ParaFirst)
        and (AItemNo > 0)
        and (Items[AItemNo - 1].StyleNo > THCStyle.RsNull)
      then  // ǰһ����TextItem
        vStyleItemNo := AItemNo - 1;
    end;

    FStyle.CurStyleNo := Items[vStyleItemNo].StyleNo;
    FStyle.CurParaNo := Items[vStyleItemNo].ParaNo;
  end;

  if FItems[AItemNo].StyleNo < THCStyle.RsNull then  // RectItem
  begin
    if AOffset = OffsetBefor then  // �������
      ACaretInfo.X := ACaretInfo.X + vDrawItem.Rect.Left
    else
    if AOffset = OffsetInner then  // �������ϣ����ڲ�����
    begin
      (FItems[AItemNo] as THCCustomRectItem).GetCaretInfo(ACaretInfo);
      ACaretInfo.X := ACaretInfo.X + vDrawItem.Rect.Left;
      case FStyle.ParaStyles[FItems[AItemNo].ParaNo].AlignVert of  // ��ֱ���뷽ʽ
        pavCenter: ACaretInfo.Y := ACaretInfo.Y + (vDrawItem.Rect.Height - (FItems[AItemNo] as THCCustomRectItem).Height) div 2;

        pavTop: ACaretInfo.Y := ACaretInfo.Y + FStyle.ParaStyles[FItems[AItemNo].ParaNo].LineSpaceHalf;
      else
        ACaretInfo.Y := ACaretInfo.Y + vDrawItem.Rect.Height - (FItems[AItemNo] as THCCustomRectItem).Height;
      end;
    end
    else  // �����Ҳ�
      ACaretInfo.X := ACaretInfo.X + vDrawItem.Rect.Right;
  end
  else  // TextItem
    ACaretInfo.X := ACaretInfo.X + vDrawItem.Rect.Left
      + GetDrawItemOffsetWidth(vDrawItemNo, AOffset - vDrawItem.CharOffs + 1);

  ACaretInfo.Y := ACaretInfo.Y + vDrawItem.Rect.Top;
end;

procedure THCCustomData.InitializeField;
begin
  if FCaretDrawItemNo >= 0 then
    FItems[FDrawItems[FCaretDrawItemNo].ItemNo].Active := False;

  FCaretDrawItemNo := -1;
end;

function THCCustomData.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
begin
end;

{ TSelectInfo }

constructor TSelectInfo.Create;
begin
  Self.Initialize;
end;

procedure TSelectInfo.Initialize;
begin
  FStartItemNo := -1;
  FStartItemOffset := -1;
  FEndItemNo := -1;
  FEndItemOffset := -1;
end;

end.
