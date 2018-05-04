{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                    �����ʵ�ֵ�Ԫ                     }
{                                                       }
{*******************************************************}

unit HCTableRow;

interface

uses
  HCCustomData, HCTableCell, HCTableCellData, HCStyle;

const
  MinRowHeight = 20;
  MinColWidth = 10;
  MaxListSize = Maxint div 16;

type
  PPointerList = ^TPointerList;
  TPointerList = array[0..MaxListSize] of Pointer;

  TTableRow = class(TObject)
  private
    FList: PPointerList;
    FColCount,
    FCapacity,
    FHeight,  // �иߣ��������±߿� = ���е�Ԫ����ߵ�(��Ԫ��߰�����Ԫ��Ϊ��ҳ����ĳ�ж���ƫ�Ƶĸ߶�)
    FFmtOffset  // ��ʽ��ʱ��ƫ�ƣ���Ҫ�Ǵ���ǰ���������Ƶ���һҳʱ������һҳ�ײ�����������ƶ�ʱ�ļ���
      : Integer;
    FAutoHeight: Boolean;  // True���������Զ�ƥ����ʵĸ߶� False�û��϶�����Զ���߶�
    procedure SetCapacity(const Value: Integer);
    function GetItems(Index: Integer): Pointer;
    procedure SetItems(Index: Integer; const Value: Pointer);
    procedure SetColCount(const Value: Integer);
  protected
    function GetCols(Index: Integer): TTableCell;

    property Items[Index: Integer]: Pointer read GetItems write SetItems; default;
  public
    constructor Create(const AStyle: THCStyle; const AColCount: Integer);
    destructor Destroy; override;
    function Add(Item: Pointer): Integer;
    function Insert(Index: Integer; Item: Pointer): Boolean;
    procedure Clear;
    procedure Delete(Index: Integer);
    function ClearFormatExtraHeight: Integer;
    //
    //function CalcFormatHeight: Integer;
    procedure SetRowWidth(const AWidth: Integer);
    procedure SetHeightEx(const Value: Integer);  // �ⲿ�϶��ı��и�

    //property Capacity: Integer read FCapacity write SetCapacity;
    property ColCount: Integer read FColCount write SetColCount;
    //property List: PCellDataList read FList;
    //
    property Cols[Index: Integer]: TTableCell read GetCols;

    /// <summary> ��ǰ��������û�з����ϲ���Ԫ��ĸ߶�(��CellVPadding * 2��Ϊ�����кϲ��е�Ӱ�죬����>=���ݸ߶�) </summary>
    property Height: Integer read FHeight write FHeight;
    property AutoHeight: Boolean read FAutoHeight write FAutoHeight;

    /// <summary>���ҳ��������ƫ�Ƶ���</summary>
    property FmtOffset: Integer read FFmtOffset write FFmtOffset;
  end;

implementation

uses
  SysUtils, Math;

{ TTableRow }

function TTableRow.Add(Item: Pointer): Integer;
begin
  if FColCount = FCapacity then
    SetCapacity(FCapacity + 4);  // ÿ������4��
  FList^[FColCount] := Item;
  Result := FColCount;
  Inc(FColCount);
end;

function TTableRow.Insert(Index: Integer; Item: Pointer): Boolean;
begin
  if (Index < 0) or (Index > FColCount) then
    raise Exception.CreateFmt('[Insert]�Ƿ�����:%d', [Index]);
  if FColCount = FCapacity then
    SetCapacity(FCapacity + 4);  // ÿ������4��
  if Index < FColCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FColCount - Index) * SizeOf(Pointer));
  FList^[Index] := Item;
  Inc(FColCount);
  Result := True;
end;

procedure TTableRow.SetRowWidth(const AWidth: Integer);
var
  i, vWidth: Integer;
begin
  vWidth := AWidth div FColCount;
  for i := 0 to FColCount - 2 do
  begin
    {if i = 0 then
      Cols[i].CellData.Items[0].Text := Cols[i].CellData.Items[0].Text + 'aaaaaa����';
    if i = 1 then
    begin
      Cols[i].CellData.Items[0].StyleNo := 1;
      Cols[i].CellData.Items[0].Text := '12345678910';
    end;}
    Cols[i].Width := vWidth;
  end;
  Cols[FColCount - 1].Width := AWidth - (FColCount - 1) * vWidth;  // �����ȫ�������һ����Ԫ��
end;

{function TTableRow.CalcFormatHeight: Integer;
var
  i, vH: Integer;
begin
  Result := MinRowHeight;
  for i := 0 to FColCount - 1 do
  begin
    if Cols[i] <> nil then
    begin
      vH := Cols[i].DrawItems[Cols[i].DrawItems.Count - 1].Rect.Bottom
        + Cols[i].DrawItems[Cols[i].DrawItems.Count - 1].TopOffset;

      if vH > Result then
        Result := vH;
    end;
  end;
end;}

procedure TTableRow.Clear;
begin
  SetColCount(0);
  SetCapacity(0);
end;

constructor TTableRow.Create(const AStyle: THCStyle; const AColCount: Integer);
var
  vCell: TTableCell;
  i: Integer;
begin
  FColCount := 0;
  FCapacity := 0;
  for i := 0 to AColCount - 1 do
  begin
    vCell := TTableCell.Create(AStyle);
    Add(vCell);
  end;
  FAutoHeight := True;
end;

procedure TTableRow.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FColCount) then
    raise Exception.CreateFmt('[Delete]�Ƿ��� Index:%d', [Index]);
  TTableCell(FList^[Index]).Free;
  if Index < FColCount then
    System.Move(FList^[Index + 1], FList^[Index], (FColCount - Index) * SizeOf(Pointer));
  Dec(FColCount);
end;

destructor TTableRow.Destroy;
begin
  Clear;
  inherited;
end;

function TTableRow.GetCols(Index: Integer): TTableCell;
begin
  Result := TTableCell(Items[Index]);
end;

function TTableRow.ClearFormatExtraHeight: Integer;
var
  i, vMaxDiff: Integer;
begin
  Result := FFmtOffset;
  FFmtOffset := 0;
  vMaxDiff := 0;
  for i := 0 to ColCount - 1 do
    vMaxDiff := Max(vMaxDiff, Cols[i].ClearFormatExtraHeight);

  if vMaxDiff > 0 then
  begin
    for i := 0 to ColCount - 1 do
      Self.Cols[i].Height := Self.Cols[i].Height - vMaxDiff;
    FHeight := FHeight - vMaxDiff;
  end;

  Result := Result + vMaxDiff;
end;

function TTableRow.GetItems(Index: Integer): Pointer;
begin
  if (Index < 0) or (Index >= FColCount) then
    raise Exception.CreateFmt('�쳣:[TTableRow.GetItems]����Indexֵ%d������Χ��', [Index]);
  Result := FList^[Index];
end;

procedure TTableRow.SetCapacity(const Value: Integer);
begin
  if (Value < FColCount) or (Value > MaxListSize) then
    raise Exception.CreateFmt('[SetCapacity]�Ƿ�����:%d', [Value]);
  if FCapacity <> Value then
  begin
    // ���·���ָ����С�ڴ�飬����P������nil����ָ��һ����
    // GetMem, AllocMem, �� ReallocMem������ڴ�������������ڴ��������ģ�
    // ���ǰ�����е������Ƶ��·�����ڴ���ȥ
    ReallocMem(FList, Value * SizeOf(Pointer));
    FCapacity := Value;
  end;
end;

procedure TTableRow.SetColCount(const Value: Integer);
var
  i: Integer;
begin
  if (Value < 0) or (Value > MaxListSize) then
    raise Exception.CreateFmt('[SetCount]�Ƿ�����:%d', [Value]);
  if Value > FCapacity then
    SetCapacity(Value);
  if Value > FColCount then
    FillChar(FList^[FColCount], (Value - FColCount) * SizeOf(Pointer), 0)
  else
    for i := FColCount - 1 downto Value do
      Delete(I);
  FColCount := Value;
end;

procedure TTableRow.SetHeightEx(const Value: Integer);
var
  i: Integer;
begin
  // ��������ߵĵ�Ԫ��
  for i := 0 to FColCount - 1 do
  begin
    if Cols[i].CellData <> nil then
    begin
      if Cols[i].CellData.Height > FHeight then
        FHeight := Cols[i].CellData.Height;
    end;
  end;
  if FHeight < Value then  // ����������������Ƿ��ܷ���
    FHeight := Value;
  for i := 0 to FColCount - 1 do
  begin
    if Cols[i].CellData.Height > FHeight then
      Cols[i].Height := FHeight;
  end;
end;

procedure TTableRow.SetItems(Index: Integer; const Value: Pointer);
begin
  if (Index < 0) or (Index >= FColCount) then
    raise Exception.CreateFmt('[SetItems]�쳣:%d', [Index]);

  if Value <> FList^[Index] then
    FList^[Index] := Value;
end;

end.
