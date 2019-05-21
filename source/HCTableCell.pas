{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  ���Ԫ��ʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCTableCell;

interface

uses
  Classes, Graphics, HCStyle, HCCustomData, HCTableCellData, HCItem, HCCommon, HCXml;

type
  TTableSite = (
    tsOutside,  // �������
    tsCell,  // ��Ԫ����
    tsBorderLeft,{ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderTop,  {ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderRight,  // ��X���ұ�
    tsBorderBottom  // ��X���±�
  );

  //PResizeInfo = ^TResizeInfo;
  TResizeInfo = record  // ������Ϣ
    TableSite: TTableSite;
    DestX, DestY: Integer;
  end;

  TOutsideInfo = record  // ���������Ϣ
    Row: Integer;  // ����λ�ô���Ӧ����
    Leftside: Boolean;  // True����� False���ұ�
  end;

  TSelectCellRang = class
  strict private
    FStartRow,  // ѡ����ʼ��
    FStartCol,  // ѡ����ʼ��
    FEndRow,    // ѡ�н�����
    FEndCol     // ѡ�н�����
      : Integer;
  public
    constructor Create;

    /// <summary> ��ʼ���ֶκͱ��� </summary>
    procedure Initialize;

    procedure InitilazeEnd;
    procedure SetStart(const ARow, ACol: Integer);
    procedure SetEnd(const ARow, ACol: Integer);

    /// <summary> ��ͬһ��Ԫ�б༭ </summary>
    function EditCell: Boolean;

    /// <summary> ѡ����ͬһ�� </summary>
    function SameRow: Boolean;

    /// <summary> ѡ����ͬһ�� </summary>
    function SameCol: Boolean;

    /// <summary> ѡ��1-n����Ԫ�� </summary>
    function SelectExists: Boolean;
    property StartRow: Integer read FStartRow write FStartRow;
    property StartCol: Integer read FStartCol write FStartCol;
    property EndRow: Integer read FEndRow write FEndRow;
    property EndCol: Integer read FEndCol write FEndCol;
  end;

  /// <summary> ��ֱ���뷽ʽ���ϡ����С���) </summary>
  THCAlignVert = (cavTop, cavCenter, cavBottom);

  THCTableCell = class
  private
    FCellData: THCTableCellData;
    FWidth,    // ���ϲ����¼ԭʼ��(�����е�һ�б��ϲ��󣬵ڶ����޷�ȷ��ˮƽ��ʼλ��)
    FHeight,   // ���ϲ����¼ԭʼ�ߡ���¼�϶��ı���
    FRowSpan,  // ��Ԫ��缸�У����ںϲ�Ŀ�굥Ԫ���¼�ϲ��˼��У��ϲ�Դ��¼�ϲ�����Ԫ����кţ�0û���кϲ�
    FColSpan   // ��Ԫ��缸�У����ںϲ�Ŀ�굥Ԫ���¼�ϲ��˼��У��ϲ�Դ��¼�ϲ�����Ԫ����кţ�0û���кϲ�
      : Integer;
    FBackgroundColor: TColor;
    FAlignVert: THCAlignVert;
    FBorderSides: TBorderSides;
  protected
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure SetHeight(const Value: Integer);
  public
    constructor Create(const AStyle: THCStyle);
    destructor Destroy; override;
    function IsMergeSource: Boolean;
    function IsMergeDest: Boolean;

    /// <summary> ���������Ϊ�����ҳ�Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer;

    procedure SaveToStream(const AStream: TStream); virtual;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word);
    procedure ToXml(const ANode: IHCXMLNode);
    procedure ParseXml(const ANode: IHCXMLNode);

    procedure GetCaretInfo(const AItemNo, AOffset: Integer;
      const ACellVPadding: Byte; var ACaretInfo: THCCaretInfo);

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
      const ACellHPadding, ACellVPadding: Byte;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);

    property CellData: THCTableCellData read FCellData write FCellData;

    /// <summary> ��Ԫ����(��CellHPadding)�����ݵĿ����TableItem�д��� </summary>
    property Width: Integer read FWidth write FWidth;
    /// <summary> ��Ԫ��߶�(��CellVPadding * 2 ��Ҫ���ںϲ�Ŀ�굥Ԫ����������ϲ�����>=���ݸ߶�) </summary>
    property Height: Integer read FHeight write SetHeight;
    property RowSpan: Integer read FRowSpan write FRowSpan;
    property ColSpan: Integer read FColSpan write FColSpan;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
    // ���ڱ���л��༭�ĵ�Ԫ��
    property Active: Boolean read GetActive write SetActive;
    property AlignVert: THCAlignVert read FAlignVert write FAlignVert;
    property BorderSides: TBorderSides read FBorderSides write FBorderSides;
  end;

implementation

uses
  SysUtils;

{ THCTableCell }

constructor THCTableCell.Create(const AStyle: THCStyle);
begin
  FCellData := THCTableCellData.Create(AStyle);
  FAlignVert := cavTop;
  FBorderSides := [cbsLeft, cbsTop, cbsRight, cbsBottom];
  FBackgroundColor := HCTransparentColor;
  FRowSpan := 0;
  FColSpan := 0;
end;

destructor THCTableCell.Destroy;
begin
  FCellData.Free;
  inherited;
end;

function THCTableCell.GetActive: Boolean;
begin
  if FCellData <> nil then
    Result := FCellData.Active
  else
    Result := False;
end;

procedure THCTableCell.GetCaretInfo(const AItemNo, AOffset: Integer;
  const ACellVPadding: Byte; var ACaretInfo: THCCaretInfo);
begin
  if FCellData <> nil then
  begin
    FCellData.GetCaretInfo(AItemNo, AOffset, ACaretInfo);
    if ACaretInfo.Visible then
    begin
      case FAlignVert of
        cavCenter: ACaretInfo.Y := ACaretInfo.Y + (FHeight - ACellVPadding - ACellVPadding - FCellData.Height) div 2;
        cavBottom: ACaretInfo.Y := ACaretInfo.Y + FHeight - ACellVPadding - FCellData.Height - ACellVPadding;
      end;
    end;
  end
  else
    ACaretInfo.Visible := False;
end;

function THCTableCell.ClearFormatExtraHeight: Integer;
begin
  if FCellData <> nil then
    Result := FCellData.ClearFormatExtraHeight
  else
    Result := 0;
end;

procedure THCTableCell.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vNullData: Boolean;
begin
  AStream.ReadBuffer(FWidth, SizeOf(FWidth));
  AStream.ReadBuffer(FHeight, SizeOf(FHeight));
  AStream.ReadBuffer(FRowSpan, SizeOf(FRowSpan));
  AStream.ReadBuffer(FColSpan, SizeOf(FColSpan));

  if AFileVersion > 11 then
  begin
    AStream.ReadBuffer(FAlignVert, SizeOf(FAlignVert));  // ��ֱ���뷽ʽ
    if AFileVersion > 18 then
      HCLoadColorFromStream(AStream, FBackgroundColor)
    else
      AStream.ReadBuffer(FBackgroundColor, SizeOf(FBackgroundColor));  // ����ɫ
  end;

  if AFileVersion > 13 then
    AStream.ReadBuffer(FBorderSides, SizeOf(FBorderSides));

  AStream.ReadBuffer(vNullData, SizeOf(vNullData));
  if not vNullData then
  begin
    FCellData.LoadFromStream(AStream, AStyle, AFileVersion);
    FCellData.CellHeight := FHeight;
  end
  else
  begin
    FCellData.Free;
    FCellData := nil;
  end;
end;

procedure THCTableCell.PaintData(const ADataDrawLeft, ADataDrawTop,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom, AVOffset: Integer;
  const ACellHPadding, ACellVPadding: Byte;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vTop: Integer;
begin
  if Assigned(FCellData) then
  begin
    case FAlignVert of
      cavTop: vTop := ADataDrawTop;
      cavCenter: vTop := ADataDrawTop + (FHeight - ACellHPadding - FCellData.Height - ACellVPadding) div 2;
      cavBottom: vTop := ADataDrawTop + FHeight - ACellHPadding - FCellData.Height - ACellVPadding;
    end;

    FCellData.PaintData(ADataDrawLeft, vTop, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom, AVOffset, ACanvas, APaintInfo);
  end;
end;

procedure THCTableCell.ParseXml(const ANode: IHCXMLNode);
begin
  FWidth := ANode.Attributes['width'];
  FHeight := ANode.Attributes['height'];
  FRowSpan := ANode.Attributes['rowspan'];
  FColSpan := ANode.Attributes['colspan'];
  FAlignVert := THCAlignVert(ANode.Attributes['vert']);
  FBackgroundColor := GetXmlRGBColor(ANode.Attributes['bkcolor']);  // ����ɫ
  SetBorderSideByPro(ANode.Attributes['border'], FBorderSides);

  if (FRowSpan < 0) or (FColSpan < 0) then
  begin
    FCellData.Free;
    FCellData := nil;
  end
  else
    FCellData.ParseXml(ANode.ChildNodes.FindNode('items'));
end;

function THCTableCell.IsMergeDest: Boolean;
begin
  Result := (FRowSpan > 0) or (FColSpan > 0);
end;

function THCTableCell.IsMergeSource: Boolean;
begin
  Result := FCellData = nil;
end;

procedure THCTableCell.SaveToStream(const AStream: TStream);
var
  vNullData: Boolean;
begin
  { ��Ϊ�����Ǻϲ���ĵ�Ԫ�����Ե�������� }
  AStream.WriteBuffer(FWidth, SizeOf(FWidth));
  AStream.WriteBuffer(FHeight, SizeOf(FHeight));
  AStream.WriteBuffer(FRowSpan, SizeOf(FRowSpan));
  AStream.WriteBuffer(FColSpan, SizeOf(FColSpan));

  AStream.WriteBuffer(FAlignVert, SizeOf(FAlignVert));  // ��ֱ���뷽ʽ
  HCSaveColorToStream(AStream, FBackgroundColor);  // ����ɫ

  AStream.WriteBuffer(FBorderSides, SizeOf(FBorderSides));

  { ������ }
  vNullData := not Assigned(FCellData);
  AStream.WriteBuffer(vNullData, SizeOf(vNullData));
  if not vNullData then
    FCellData.SaveToStream(AStream);
end;

procedure THCTableCell.SetActive(const Value: Boolean);
begin
  if FCellData <> nil then
    FCellData.Active := Value;
end;

procedure THCTableCell.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    if FCellData <> nil then
      FCellData.CellHeight := Value;
  end;
end;

procedure THCTableCell.ToXml(const ANode: IHCXMLNode);
begin
  { ��Ϊ�����Ǻϲ���ĵ�Ԫ�����Ե�������� }
  ANode.Attributes['width'] := FWidth;
  ANode.Attributes['height'] := FHeight;
  ANode.Attributes['rowspan'] := FRowSpan;
  ANode.Attributes['colspan'] := FColSpan;
  ANode.Attributes['vert'] := Ord(FAlignVert);
  ANode.Attributes['bkcolor'] := GetColorXmlRGB(FBackgroundColor);
  ANode.Attributes['border'] := GetBorderSidePro(FBorderSides);

  if Assigned(FCellData) then  // ������
    FCellData.ToXml(ANode.AddChild('items'));
end;

{ TSelectCellRang }

constructor TSelectCellRang.Create;
begin
  Initialize;
end;

function TSelectCellRang.EditCell: Boolean;
begin
   Result := (FStartRow >= 0) and (FEndRow < 0);  // ������SameRow��SameCol����ݣ�
end;

procedure TSelectCellRang.Initialize;
begin
  FStartRow := -1;
  FStartCol := -1;
  FEndRow := -1;
  FEndCol := -1;
end;

procedure TSelectCellRang.InitilazeEnd;
begin
  FEndRow := -1;
  FEndCol := -1;
end;

function TSelectCellRang.SameCol: Boolean;
begin
  Result := (FStartCol >= 0) and (FStartCol = FEndCol);
end;

function TSelectCellRang.SameRow: Boolean;
begin
  Result := (FStartRow >= 0) and (FStartRow = FEndRow);
end;

function TSelectCellRang.SelectExists: Boolean;
begin
  Result := (FEndRow >= 0) or (FEndCol >= 0);  // ��ʱû���õ��˷���
end;

procedure TSelectCellRang.SetEnd(const ARow, ACol: Integer);
begin
  FEndRow := ARow;
  FEndCol := ACol;
end;

procedure TSelectCellRang.SetStart(const ARow, ACol: Integer);
begin
  FStartRow := ARow;
  FStartCol := ACol;
end;

end.
