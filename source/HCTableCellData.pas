{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{            ���Ԫ���ڸ���������Ԫ               }
{                                                       }
{*******************************************************}

unit HCTableCellData;

interface

uses
  Windows, Types, HCRichData, HCCustomData, HCCommon;

type
  TGetRootDataEvent = function (): THCCustomData of object;
  TGetEnableUndoEvent = function (): Boolean of object;

  THCTableCellData = class(THCRichData)
  private
    FActive,

    // ��ʶ��Ԫ��ȫѡ״̬(ȫѡʱ�����Ȼû���ڲ�Item��ҲӦ��ʶ��ѡ������)
    // ��CellData�����EmptyDataʱ��ȫѡ��û��SelectEndItem����ȡ��ѡ��״̬ʱ
    // ��δȫѡһ����������Ҫ�Լ���¼ȫѡ״̬
    FCellSelectedAll
      : Boolean;
    FCellHeight: Integer;  // ������Ԫ��߶�(��ϲ����ֶ��ϸߣ���Ԫ��߶Ȼ���ڵ����������ݸ߶�)
    FOnGetRootData: TGetRootDataEvent;
    FOnGetEnableUndo: TGetEnableUndoEvent;
    function PointInCellRect(const APt: TPoint): Boolean;
  protected
    function GetHeight: Cardinal; override;

    /// <summary> ȡ��ѡ�� </summary>
    /// <returns>ȡ��ʱ��ǰ�Ƿ���ѡ�У�True����ѡ�У�False����ѡ��</returns>
    function DisSelect: Boolean; override;

    /// <summary> ɾ��ѡ�� </summary>
    function DeleteSelected: Boolean; override;

    procedure _FormatReadyParam(const AStartItemNo: Integer;
      var APrioDrawItemNo: Integer; var APos: TPoint); override;

    function EnableUndo: Boolean; override;

    procedure SetActive(const Value: Boolean);
  public
    //constructor Create; override;
    /// <summary> ȫѡ </summary>
    procedure SelectAll; override;

    /// <summary> �����Ƿ���AItem��ѡ�������� </summary>
    function CoordInSelect(const X, Y, AItemNo, AOffset: Integer;
      const ARestrain: Boolean): Boolean; override;

    /// <summary> ����ָ�������µ�Item��Offset </summary>
    procedure GetItemAt(const X, Y: Integer; var AItemNo, AOffset, ADrawItemNo: Integer;
      var ARestrain: Boolean); override;
    function GetRootData: THCCustomData; override;

    /// <summary> ѡ�ڵ�һ��Item��ǰ�� </summary>
    function SelectFirstItemOffsetBefor: Boolean;

    /// <summary> ѡ�����һ��Item����� </summary>
    function SelectLastItemOffsetAfter: Boolean;

    /// <summary> ѡ�ڵ�һ�� </summary>
    function SelectFirstLine: Boolean;

    /// <summary> ѡ�����һ�� </summary>
    function SelectLastLine: Boolean;

    /// <summary> ���������Ϊ�����ҳ�Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer;

    /// <summary> ��Ԫ��ȫ��״̬ </summary>
    property CellSelectedAll: Boolean read FCellSelectedAll write FCellSelectedAll;

    /// <summary> ������Ԫ��߶� </summary>
    property CellHeight: Integer read FCellHeight write FCellHeight;
    // ���ڱ���л��༭�ĵ�Ԫ��
    property Active: Boolean read FActive write SetActive;

    property OnGetRootData: TGetRootDataEvent read FOnGetRootData write FOnGetRootData;
    property OnGetEnableUndo: TGetEnableUndoEvent read FOnGetEnableUndo write FOnGetEnableUndo;
  end;

implementation

uses
  HCRectItem, HCStyle, HCItem;

{ THCTableCellData }

function THCTableCellData.ClearFormatExtraHeight: Integer;
var
  i, vFmtOffset, vFormatIncHight: Integer;
begin
  Result := 0;
  vFmtOffset := 0;
  for i := 1 to DrawItems.Count - 1 do
  begin
    if DrawItems[i].LineFirst then
    begin
      if DrawItems[i].Rect.Top <> DrawItems[i - 1].Rect.Bottom then
      begin
        vFmtOffset := DrawItems[i].Rect.Top - DrawItems[i - 1].Rect.Bottom;
        if vFmtOffset > Result then
          Result := vFmtOffset;
      end;
    end;

    OffsetRect(DrawItems[i].Rect, 0, -vFmtOffset);

    if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.Null then  // RectItem�����ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
    begin
      vFormatIncHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).ClearFormatExtraHeight;
      DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vFormatIncHight;
    end;
  end;
end;

function THCTableCellData.CoordInSelect(const X, Y, AItemNo,
  AOffset: Integer; const ARestrain: Boolean): Boolean;
begin
  if FCellSelectedAll then
    Result := PointInCellRect(Point(X, Y))
  else
    Result := inherited CoordInSelect(X, Y, AItemNo, AOffset, ARestrain);
end;

function THCTableCellData.DeleteSelected: Boolean;
begin
  Result := inherited DeleteSelected;
  FCellSelectedAll := False;
end;

function THCTableCellData.DisSelect: Boolean;
begin
  Result := inherited DisSelect;
  FCellSelectedAll := False;
end;

function THCTableCellData.EnableUndo: Boolean;
begin
  if Assigned(FOnGetEnableUndo) then
    Result := OnGetEnableUndo
  else
    Result := inherited EnableUndo;
end;

function THCTableCellData.GetHeight: Cardinal;
begin
  Result := inherited GetHeight;
  if DrawItems.Count > 0 then
    Result := Result + DrawItems[0].Rect.Top;
end;

procedure THCTableCellData.GetItemAt(const X, Y: Integer; var AItemNo, AOffset,
  ADrawItemNo: Integer; var ARestrain: Boolean);
begin
  inherited GetItemAt(X, Y, AItemNo, AOffset, ADrawItemNo, ARestrain);
  if FCellSelectedAll then
    ARestrain := not PointInCellRect(Point(X, Y))
end;

function THCTableCellData.GetRootData: THCCustomData;
begin
  if Assigned(FOnGetRootData) then
    Result := FOnGetRootData
  else
    Result := inherited GetRootData;
end;

function THCTableCellData.PointInCellRect(const APt: TPoint): Boolean;
begin
  Result := PtInRect(Bounds(0, 0, Width, FCellHeight), APt);
end;

procedure THCTableCellData.SelectAll;
begin
  inherited SelectAll;
  FCellSelectedAll := True;
end;

function THCTableCellData.SelectFirstItemOffsetBefor: Boolean;
begin
  Result := False;
  if (not SelectExists) and (SelectInfo.StartItemNo = 0) then
    Result := SelectInfo.StartItemOffset = 0;
end;

function THCTableCellData.SelectFirstLine: Boolean;
begin
  Result := Self.GetParaFirstItemNo(SelectInfo.StartItemNo) = 0;
end;

function THCTableCellData.SelectLastItemOffsetAfter: Boolean;
begin
  Result := False;
  if (not SelectExists) and (SelectInfo.StartItemNo = Self.Items.Count - 1) then  // ���һ��
    Result := SelectInfo.StartItemOffset = Self.GetItemAfterOffset(SelectInfo.StartItemNo);
end;

function THCTableCellData.SelectLastLine: Boolean;
begin
  Result := Self.GetParaLastItemNo(SelectInfo.StartItemNo) = Self.Items.Count - 1;
end;

procedure THCTableCellData.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
    FActive := Value;

  if not FActive then
  begin
    {if Self.MouseDownItemNo >= 0 then
      Self.Items[Self.MouseDownItemNo].Active := False;}
    Self.DisSelect;
    Self.InitializeField;
    Style.UpdateInfoRePaint;
  end;
end;

procedure THCTableCellData._FormatReadyParam(const AStartItemNo: Integer;
  var APrioDrawItemNo: Integer; var APos: TPoint);
begin
  { �͸��಻ͬ�������Ϊ�漰��ҳʱ��ЩDrawItem������ƫ�ƣ��������¸�ʽ��ʱ
    ��ʼDrawItem�������ϴο�ҳ��ƫ�Ƶģ���Ӱ�챾�ε�λ�ü��㣬���Ա���ʽ��ʱ
    ȫ����0��ʼ����������˺�������Ҫ�˴������򽫸����еĴ˺���ȡ���鷽�� }
  {APrioDrawItemNo := -1;
  APos.X := 0;
  APos.Y := 0;
  DrawItems.Clear; }
  inherited _FormatReadyParam(AStartItemNo, APrioDrawItemNo, APos);
end;

end.
