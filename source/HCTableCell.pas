{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
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
  Classes, Graphics, HCStyle, HCCustomData, HCTableCellData, HCCommon;

type
  TTableCell = class
  private
    FCellData: THCTableCellData;
    FWidth,    // ���ϲ����¼ԭʼ��(�����е�һ�б��ϲ��󣬵ڶ����޷�ȷ��ˮƽ��ʼλ��)
    FHeight,   // ���ϲ����¼ԭʼ�ߡ���¼�϶��ı���
    FRowSpan,  // ��Ԫ��缸�У����ںϲ�Ŀ�굥Ԫ���¼�ϲ��˼��У��ϲ�Դ��¼�ϲ�����Ԫ����кţ�0û���кϲ�
    FColSpan   // ��Ԫ��缸�У����ںϲ�Ŀ�굥Ԫ���¼�ϲ��˼��У��ϲ�Դ��¼�ϲ�����Ԫ����кţ�0û���кϲ�
      : Integer;
    FBackgroundColor: TColor;
  protected
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  public
    constructor Create(const AStyle: THCStyle);
    destructor Destroy; override;
    function MergeSource: Boolean;
    function MergeDest: Boolean;

    /// <summary> ���������Ϊ�����ҳ�Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer;

    procedure SaveToStream(const AStream: TStream); virtual;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word);

    property CellData: THCTableCellData read FCellData write FCellData;

    /// <summary>
    /// ��Ԫ���ȣ�Ϊ��ʹ��ȫ�ֵ�GCellPadding�����ݵĿ����TableItem�д���
    /// </summary>
    property Width: Integer read FWidth write FWidth;
    /// <summary> ��Ԫ��߶�(��CellVPadding * 2 ��Ҫ���ںϲ�Ŀ�굥Ԫ����������ϲ�����>=���ݸ߶�) </summary>
    property Height: Integer read FHeight write FHeight;
    property RowSpan: Integer read FRowSpan write FRowSpan;
    property ColSpan: Integer read FColSpan write FColSpan;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
    // ���ڱ���л��༭�ĵ�Ԫ��
    property Active: Boolean read GetActive write SetActive;
  end;

implementation

uses
  SysUtils;

{ TTableCell }

constructor TTableCell.Create(const AStyle: THCStyle);
begin
  FCellData := THCTableCellData.Create(AStyle);
  //FCellData.ParentData := AParentData;
  FBackgroundColor := AStyle.BackgroudColor;
  FRowSpan := 0;
  FColSpan := 0;
end;

destructor TTableCell.Destroy;
begin
  FCellData.Free;
  inherited;
end;

function TTableCell.GetActive: Boolean;
begin
  if FCellData <> nil then
    Result := FCellData.Active
  else
    Result := False;
end;

function TTableCell.ClearFormatExtraHeight: Integer;
begin
  Result := 0;
  if FCellData <> nil then
    Result := FCellData.ClearFormatExtraHeight;
end;

procedure TTableCell.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vNullData: Boolean;
begin
  AStream.ReadBuffer(FWidth, SizeOf(FWidth));
  AStream.ReadBuffer(FHeight, SizeOf(FHeight));
  AStream.ReadBuffer(FRowSpan, SizeOf(FRowSpan));
  AStream.ReadBuffer(FColSpan, SizeOf(FColSpan));

  AStream.ReadBuffer(vNullData, SizeOf(vNullData));
  if not vNullData then
    FCellData.LoadFromStream(AStream, AStyle, AFileVersion)
  else
  begin
    FCellData.Free;
    FCellData := nil;
  end;
end;

function TTableCell.MergeDest: Boolean;
begin
  Result := (FRowSpan > 0) or (FColSpan > 0);
end;

function TTableCell.MergeSource: Boolean;
begin
  Result := FCellData = nil;
end;

procedure TTableCell.SaveToStream(const AStream: TStream);
var
  vNullData: Boolean;
begin
  { ��Ϊ�����Ǻϲ���ĵ�Ԫ�����Ե�������� }
  AStream.WriteBuffer(FWidth, SizeOf(FWidth));
  AStream.WriteBuffer(FHeight, SizeOf(FHeight));
  AStream.WriteBuffer(FRowSpan, SizeOf(FRowSpan));
  AStream.WriteBuffer(FColSpan, SizeOf(FColSpan));

  { ������ }
  vNullData := FCellData = nil;
  AStream.WriteBuffer(vNullData, SizeOf(vNullData));
  if not vNullData then
    FCellData.SaveToStream(AStream);
end;

procedure TTableCell.SetActive(const Value: Boolean);
begin
  if FCellData <> nil then
    FCellData.Active := Value;
end;

end.
