{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                     ���ʵ�ֵ�Ԫ                      }
{                                                       }
{*******************************************************}

unit HCTableItem;

interface

uses
  Classes, SysUtils, Types, Graphics, Controls, Generics.Collections, HCDrawItem, HCRectItem,
  HCTableRow, HCCustomData, HCCustomRichData, HCTableCell, HCTableCellData, HCTextStyle, HCCommon,
  HCParaStyle, HCStyleMatch, HCItem, HCStyle, HCDataCommon;

type
  TSelectCellRang = class
  private
    FStartRow,  // ѡ����ʼ��
    FStartCol,  // ѡ����ʼ��
    FEndRow,    // ѡ�н�����
    FEndCol     // ѡ�н�����
      : Integer;
  public
    constructor Create;

    /// <summary> ��ʼ���ֶκͱ��� </summary>
    procedure Initialize;

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

  TTableSite = (
    tsOutside,  // �������
    tsCell,  // ��Ԫ����
    tsBorderLeft,{ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderTop,  {ֻ�е�һ��ʹ�ô�Ԫ��}
    tsBorderRight,  // ��X���ұ�
    tsBorderBottom  // ��X���±�
  );

  TResizeInfo = record
    TableSite: TTableSite;
    DestX, DestY: Integer;
  end;

  TRowAddEvent = procedure(const ARow: TTableRow) of object;

  TTableRows = Class(TObjectList<TTableRow>)
  private
    FOnRowAdd: TRowAddEvent;
  protected
    procedure Notify(const Value: TTableRow; Action: TCollectionNotification); override;
  public
    property OnRowAdd: TRowAddEvent read FOnRowAdd write FOnRowAdd;
  end;

  THCTableItem = class(THCResizeRectItem)
  private
    FBorderWidth  // �߿���
      : Integer;
    FCellHPadding,  // ��Ԫ������ˮƽƫ��
    FCellVPadding   // ��Ԫ�����ݴ�ֱƫ��(���ܴ�����͵�DrawItem�߶ȣ������Ӱ���ҳ)
      : Byte;  // ��Ԫ�����ݺ͵�Ԫ��߿�ľ���

    FMouseDownRow, FMouseDownCol,
    FMouseMoveRow, FMouseMoveCol,
    FMouseDownX, FMouseDownY: Integer;

    FResizeInfo: TResizeInfo;
    FBorderVisible, FMouseLBDowning, FSelecting, FDraging, FOutSelectInto: Boolean;
    { ѡ����Ϣ(ֻ��ѡ����ʼ�ͽ����ж�>=0��˵����ѡ�ж����Ԫ��
     �ڵ�����Ԫ����ѡ��ʱ�����С�����ϢΪ-1 }
    FSelectCellRang: TSelectCellRang;
    FBorderColor: TColor;  // �߿���ɫ
    FRows: TTableRows;  // ��
    FColWidths: TList<Integer>;  // ��¼���п��(���߿򡢺�FCellHPadding * 2)�������кϲ��ĵ�Ԫ���ȡ�Լ�ˮƽ��ʼ����λ��
    FOwnerData: THCCustomData;
    procedure InitializeMouseInfo;

    /// <summary> ����������ʱ </summary>
    procedure DoRowAdd(const ARow: TTableRow);

    /// <summary> ��ȡ��ǰ����ʽ���߶� </summary>
    /// <returns></returns>
    function GetFormatHeight: Integer;

    /// <summary> ����ָ����Ԫ����Ա�����ʼλ������(������ϲ����غϲ�����Ԫ�������) </summary>
    /// <param name="ARow"></param>
    /// <param name="ACol"></param>
    /// <returns></returns>
    function GetCellPostion(const ARow, ACol: Integer): TPoint;

    function ActiveDataResizing: Boolean;

    /// <summary> ȡ��ѡ�з�Χ�ڳ�ARow, ACol֮�ⵥԪ���ѡ��״̬(-1��ʾȫ��ȡ��) </summary>
    procedure DisSelectSelectedCell(const ARow: Integer = -1; const ACol: Integer = -1);
  protected
    function CanDrag: Boolean; override;
    function GetSelectComplate: Boolean; override;
    procedure SelectComplate; override;
    function GetResizing: Boolean; override;
    procedure SetResizing(const Value: Boolean); override;

    /// <summary>
    /// APageDataScreenBottom <= APageDataDrawBottom
    /// </summary>
    /// <param name="ACanvas"></param>
    /// <param name="ADrawRect"></param>
    /// <param name="APageDataDrawBottom">��ǰҳȥ��ҳüҳ�ţ�ʣ�³������ݵ��������ʱ�ĵײ�λ��(���ܷ�ҳ����)</param>
    /// <param name="APageDataScreenTop"></param>
    /// <param name="APageDataScreenBottom">��ǰҳȥ��ҳüҳ�ţ�ʣ�³������ݵ��������ʱ�����Եײ�λ��</param>
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    //procedure PaintPartTo(const ACanvas: TCanvas; const ADrawLeft, ADrawTop, ADrawBottom, ADataScreenTop,
    //  ADataScreenBottom, AStartRow, AStartRowDataOffs, AEndRow, AEndRowDataOffs: Integer); overload;
    {procedure ConvertToDrawItems(const AItemNo, AOffs, AContentWidth,
      AContentHeight: Integer; var APos: TPoint; var APageIndex, ALastDNo: Integer);}
    // �̳�THCCustomItem���󷽷�
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure KillFocus; override;
    // �̳�TCustomRectItem���󷽷�
    function ApplySelectTextStyle(const AStyle: THCStyle;
      const AMatchStyle: TStyleMatch): Integer; override;
    procedure ApplySelectParaStyle(const AStyle: THCStyle;
      const AMatchStyle: TParaMatch); override;
    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    /// <summary> ��������ʱ�ڲ��Ƿ���ָ����Key��Shif </summary>
    function WantKeyDown(const Key: Word; const Shift: TShiftState): Boolean; override;

    /// <summary> ���������Ϊ�����ҳ�к����м�������ƫ�ƺ󣬱Ⱦ������ӵĸ߶�(Ϊ���¸�ʽ��ʱ�������ƫ����) </summary>
    function ClearFormatExtraHeight: Integer; override;
    function DeleteSelected: Boolean; override;
    procedure DisSelect; override;
    procedure MarkStyleUsed(const AMark: Boolean); override;
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); override;
    procedure SetActive(const Value: Boolean); override;

    /// <summary> ��ȡ�����ָ���߶��ڵĽ���λ�ô��������¶�(��ʱû�õ�ע����) </summary>
    /// <param name="AHeight">ָ���ĸ߶ȷ�Χ</param>
    /// <param name="ADItemMostBottom">���һ����׶�DItem�ĵײ�λ��</param>
    //procedure GetPageFmtBottomInfo(const AHeight: Integer; var ADItemMostBottom: Integer); override;

    function CoordInSelect(const X, Y: Integer): Boolean; override;
    function GetTopLevelDataAt(const X, Y: Integer): THCCustomData; override;
    function GetActiveData: THCCustomData; override;
    function GetActiveItem: THCCustomItem; override;
    function GetActiveDrawItem: THCCustomDrawItem; override;
    function GetActiveDrawItemCoord: TPoint; override;
    function GetHint: string; override;

    function InsertText(const AText: string): Boolean; override;
    function InsertItem(const AItem: THCCustomItem): Boolean; override;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function SelectExists: Boolean; override;
    procedure TraverseItem(const ATraverse: TItemTraverse); override;
    //

    /// <summary> ����ҳ </summary>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Top</param>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Bottom</param>
    /// <param name="APageDataFmtTop">��ǰҳ�����ݶ���λ��</param>
    /// <param name="APageDataFmtBottom">��ǰҳ�����ݵײ�λ��</param>
    /// <param name="ACheckRow">��ǰҳ�����п�ʼ�Ű�</param>
    /// <param name="ABreakRow">��ǰҳ����ҳ������</param>
    /// <param name="AFmtOffset">����Ӧ��DrawItem��������ƫ�Ƶ���</param>
    /// <param name="ACellMaxInc">���ص�ǰҳ����Ϊ�˱ܿ���ҳλ�ö���ƫ�Ƶ����߶�(����ԭ��AFmtHeightIncΪ���ڷ���������)</param>
    procedure CheckFormatPage(const ADrawItemRectTop, ADrawItemRectBottom,
      APageDataFmtTop, APageDataFmtBottom, AStartRowNo: Integer;
      var ABreakRow, AFmtOffset, ACellMaxInc: Integer); override;
    // ����Ͷ�ȡ
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure SaveSelectToStream(const AStream: TStream); override;  // inherited TCustomRect
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    function GetRowCount: Integer;
    //function GetColCount: Integer;
    function MergeCells(const AStartRow, AStartCol, AEndRow, AEndCol: Integer):Boolean;
    function GetCells(ARow, ACol: Integer): THCTableCell;
  public
    //DrawItem: TCustomDrawItem;
    constructor Create(const AOwnerData: TCustomData; const ARowCount, AColCount,
      AWidth: Integer);
    destructor Destroy; override;

    /// <summary> ��ȡָ��λ�ô����С���(����Ǳ��ϲ���Ԫ���򷵻�Ŀ�굥Ԫ���С���) </summary>
    /// <param name="X">������</param>
    /// <param name="Y">������</param>
    /// <param name="ARow">���괦����</param>
    /// <param name="ACol">���괦����</param>
    ///  <param name="AReDest">��������Ǻϲ�Դ������Ŀ��</param>
    /// <returns></returns>
    function GetCellAt(const X, Y : Integer; var ARow, ACol: Integer;
      const AReDest: Boolean = True): TResizeInfo;

    procedure GetDestCell(const ARow, ACol: Cardinal; var ADestRow, ADestCol: Integer);

    procedure SelectAll;
    /// <summary> �ж�ָ����Χ�ڵĵ�Ԫ���Ƿ���Ժϲ�(Ϊ�˸�����ϲ��˵����ƿ���״̬�ŵ�public����) </summary>
    /// <param name="AStartRow"></param>
    /// <param name="AStartCol"></param>
    /// <param name="AEndRow"></param>
    /// <param name="AEndCol"></param>
    /// <returns></returns>
    function CellsCanMerge(const AStartRow, AStartCol, AEndRow, AEndCol: Integer): Boolean;

    /// <summary> ��ȡָ����Ԫ��ϲ���ĵ�Ԫ�� </summary>
    procedure GetMergeDest(const ARow, ACol: Integer; var ADestRow, ADestCol: Integer);

    /// <summary> ��ȡָ����Ԫ��ϲ���Ԫ���Data </summary>
    //function GetMergeDestCellData(const ARow, ACol: Integer): THCTableCellData;

    /// <summary> ��Ԫ���Ƿ���ȫѡ��״̬(������ȫѡ��) </summary>
    /// <param name="ARow"></param>
    /// <param name="ACol"></param>
    /// <returns>true:��ǰ��ѡ��״̬</returns>
    function CellSelectComplate(const ARow, ACol: Integer): Boolean;
    function MergeSelectCells: Boolean;
    function GetEditCell: THCTableCell; overload;
    procedure GetEditCell(var ARow, ACol: Integer); overload;

    function InsertRowAfter(const ACount: Byte): Boolean;
    function InsertRowBefor(const ACount: Byte): Boolean;
    function DeleteRow(const ACount: Byte): Boolean;
    function InsertColAfter(const ACount: Byte): Boolean;
    function InsertColBefor(const ACount: Byte): Boolean;
    function DeleteCol(const ACount: Byte): Boolean;

    property Cells[ARow, ACol: Integer]: THCTableCell read GetCells;
    property RowCount: Integer read GetRowCount;
    //property ColCount: Integer read GetColCount;
    property SelectCellRang: TSelectCellRang read FSelectCellRang;
    property BorderVisible: Boolean read FBorderVisible write FBorderVisible;
    property CellHPadding: Byte read FCellHPadding write FCellHPadding;
    property CellVPadding: Byte read FCellVPadding write FCellVPadding;
  end;

implementation

uses
  Math, Windows;

type
  TCellCross = class(TObject)
  public
    Col, DItemNo, VOffset: Integer;
    MergeSrc: Boolean;
    constructor Create;
  end;

{$I HCView.inc}

{ THCTableItem }

procedure THCTableItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);

  {$REGION 'UpdateCellSize ��ȡ������ߵ�Ԫ��߶ȣ�������Ϊ����������Ԫ��ĸ߶�'}
  procedure UpdateCellSize(const ARowID: Integer);
  var
    vC, vNorHeightMax: Integer;
  begin
    vNorHeightMax := 0;  // ����δ�����ϲ�����ߵ�Ԫ��
    // �õ�����δ�����ϲ�������ߵĵ�Ԫ��߶�
    for vC := 0 to FRows[ARowID].ColCount - 1 do
    begin
      if (FRows[ARowID].Cols[vC].CellData <> nil)  // ���Ǳ��ϲ��ĵ�Ԫ��
        and (FRows[ARowID].Cols[vC].RowSpan = 0)  // �����кϲ����е�Ԫ��
      then
        vNorHeightMax := Max(vNorHeightMax, FRows[ARowID].Cols[vC].CellData.Height + FCellVPadding * 2);
    end;

    for vC := 0 to FRows[ARowID].ColCount - 1 do
      FRows[ARowID].Cols[vC].Height := vNorHeightMax;

    if FRows[ARowID].AutoHeight then  // �����и�δ�����кϲ���������ߵ�Ϊ�и�
      FRows[ARowID].Height := vNorHeightMax
    else  // �϶��ı��˸߶�
    begin
      if vNorHeightMax > FRows[ARowID].Height then  // �϶��߶�ʧЧ
      begin
        FRows[ARowID].AutoHeight := True;
        FRows[ARowID].Height := vNorHeightMax;
      end;
      //FRows[ARowID].Height := Max(FRows[ARowID].Height, vNorHeightMax);  // ��¼�иߣ���ʵ���������е�һ��û�кϲ����и߶�
    end;
  end;
  {$ENDREGION}

  {$REGION 'ConvertRow ��ʽ��ָ����(����)'}
  procedure ConvertRow(const ARow: Cardinal);
  var
    vC, vWidth, i: Integer;
    vRow: TTableRow;
  begin
    vRow := FRows[ARow];
    vRow.FmtOffset := 0;  // �ָ��ϴθ�ʽ�����ܵ�ƫ��
    // ��ʽ������Ԫ���е�Data
    for vC := 0 to vRow.ColCount - 1 do
    begin
      if vRow.Cols[vC].CellData <> nil then
      begin
        vWidth := FColWidths[vC];
        for i := 1 to vRow.Cols[vC].ColSpan do
          vWidth := vWidth + FBorderWidth + FColWidths[vC + i];
        vRow.Cols[vC].Width := vWidth;
        vRow.Cols[vC].CellData.Width := vWidth - 2 * FCellHPadding;
        vRow.Cols[vC].CellData.ReFormat(0);
      end
    end;
  end;
  {$ENDREGION}

var
  i, vR, vC,
  vMergeDestRow, vMergeDestCol,
  vMergeDestRow2, vMergeDestCol2,
  vExtraHeight: Integer;
begin
  for vR := 0 to RowCount - 1 do  // ��ʽ������
  begin
    ConvertRow(vR);  // ��ʽ���У��������и߶�
    UpdateCellSize(vR);  // �������������кϲ������������߶ȸ���������
  end;

  for vR := 0 to RowCount - 1 do  // �������кϲ�����¸��еĸ߶�
  begin
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if Cells[vR, vC].CellData = nil then  // ��ǰ��Ԫ�񱻺ϲ���
      begin
        if Cells[vR, vC].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
          Continue;

        GetMergeDest(vR, vC, vMergeDestRow, vMergeDestCol);  // ��ȡ���ϲ�Ŀ�굥Ԫ�������к�

        if vMergeDestRow + Cells[vMergeDestRow, vC].RowSpan = vR then  // Ŀ�굥Ԫ���кϲ����˽���
        begin
          vExtraHeight := Cells[vMergeDestRow, vC].CellData.Height;  // Ŀ�굥Ԫ�����ݸ߶�
          Cells[vMergeDestRow, vC].Height := vExtraHeight;  // Ŀ�굥Ԫ��߶�
          for i := vMergeDestRow to vR - 1 do  // ��Ŀ�굽�ˣ��������к�������������
            vExtraHeight := vExtraHeight - FRows[i].Height - FBorderWidth;

          if vExtraHeight > FRows[vR].Height then  // ������ʣ��ıȵ�ǰ�и�
          begin
            for i := 0 to vC - 1{FRows[vR].ColCount - 1} do  // ��ǰ�е�ǰ��֮ǰ����Ҫ���µ�����Ԫ��߶ȣ��������֮���ѭ������
            begin
              if FRows[vR].Cols[i].CellData <> nil then  // û�б��ϲ�
                FRows[vR].Cols[i].Height := vExtraHeight  // �����Ϊ��ͨ��Ԫ��ֵΪ�и�(����Ὣ�и߸�ֵΪvExtraHeight)
              else  // ���ϲ���Դ��Ԫ��
              begin
                GetMergeDest(vR, i, vMergeDestRow2, vMergeDestCol2);  // ��ȡĿ�굥Ԫ��
                if vMergeDestRow2 + Cells[vMergeDestRow2, i].RowSpan = vR then  // Ŀ�굥Ԫ��ϲ������н�������������
                  Cells[vMergeDestRow2, i].Height := Cells[vMergeDestRow2, i].Height + vExtraHeight - FRows[vR].Height;
              end;
            end;
            FRows[vR].Height := vExtraHeight;  // ��ǰ�и߸�ֵ��ֵ
          end
          else  // ������ʣ���û�е�ǰ�иߣ��߶����ӵ���ǰ�еײ�������Ǻϲ��ĵ�Ԫ�����ݣ����ںϲ����������е����ݵײ�û�д��иߵ����
            Cells[vMergeDestRow, vC].Height :=  // 2017-1-15_1.bmp��[1, 1]����cʱ[1, 0]��[1, 2]�����
              Cells[vMergeDestRow, vC].Height + FRows[vR].Height - vExtraHeight;
        end;
      end;
    end;
  end;

  // ��������߶�
  Height := GetFormatHeight;
  i := FBorderWidth;
  for vC := 0 to FColWidths.Count - 1 do
    i := i + FColWidths[vC] + FBorderWidth;
  Width := i;
end;

constructor THCTableItem.Create(const AOwnerData: TCustomData;
  const ARowCount, AColCount, AWidth: Integer);
var
  vRow: TTableRow;
  i, vDataWidth: Integer;
begin
  inherited Create(AOwnerData);
  FOwnerData := AOwnerData;
  GripSize := 2;
  FCellHPadding := 2;
  FCellVPadding := 0;
  FDraging := False;
  //
  StyleNo := THCStyle.RsTable;
  ParaNo := FOwnerData.Style.CurParaNo;
  if ARowCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');
  if AColCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');
  FBorderWidth := 1;
  FBorderColor := clBlack;
  FBorderVisible := True;
  //FWidth := FRows[0].ColCount * (MinColWidth + FBorderWidth) + FBorderWidth;
  Height := ARowCount * (MinRowHeight + FBorderWidth) + FBorderWidth;
  FRows := TTableRows.Create;
  FRows.OnRowAdd := DoRowAdd;
  FSelectCellRang := TSelectCellRang.Create;
  Self.InitializeMouseInfo;
  //
  vDataWidth := AWidth - (AColCount + 1) * FBorderWidth;
  for i := 0 to ARowCount - 1 do
  begin
    vRow := TTableRow.Create(FOwnerData.Style, AColCount);
    vRow.SetRowWidth(vDataWidth);
    FRows.Add(vRow);
  end;
  FColWidths := TList<Integer>.Create;
  for i := 0 to AColCount - 1 do
    FColWidths.Add(FRows[0].Cols[i].Width);
end;

function THCTableItem.DeleteCol(const ACount: Byte): Boolean;
var
  i, j, vDelCount: Integer;
  //viDestRow, viDestCol: Integer;
  //vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;
  if FSelectCellRang.StartCol + ACount > FColWidths.Count - 1 then
    vDelCount := FColWidths.Count - FSelectCellRang.StartCol
  else
    vDelCount := ACount;

  for i := 0 to vDelCount - 1 do
  begin
    for j := 0 to RowCount - 1 do
    begin
      { TODO : �ϲ���Ԫ��Ĵ��� }
      FRows[j].Delete(FSelectCellRang.StartCol);
    end;
    FColWidths.Delete(FSelectCellRang.StartCol);
  end;
  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.DeleteRow(const ACount: Byte): Boolean;
var
  i, j, k, vDelCount: Integer;
  viDestRow, viDestCol: Integer;
  //vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;
  if FSelectCellRang.StartRow + ACount > RowCount - 1 then
    vDelCount := RowCount - FSelectCellRang.StartRow
  else
    vDelCount := ACount;

  for i := 0 to vDelCount - 1 do
  begin
    for j := FColWidths.Count - 1 downto 0 do
    begin
      if FRows[FSelectCellRang.StartRow].Cols[j].RowSpan <> 0 then  // ɾ���ĵ�Ԫ���Ǻϲ�Դ
      begin
        GetDestCell(FSelectCellRang.StartRow, j, viDestRow, viDestCol);

        for k := 0 to Cells[viDestRow, viDestCol].RowSpan + FRows[FSelectCellRang.StartRow].Cols[j].RowSpan do  // Ŀ����п�� - �Ѿ����
          FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan := FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan - 1;  // ��Ŀ����Զ1
        FRows[viDestRow].Cols[j].RowSpan := FRows[viDestRow].Cols[j].RowSpan + 1;  // Ŀ���а����ĺϲ�Դ����1    }
      end;
    end;
  end;
  FRows.DeleteRange(FSelectCellRang.StartRow, vDelCount);

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.DeleteSelected: Boolean;
var
  vR, vC: Integer;
begin
  Result := inherited DeleteSelected;

  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ������У�˵��ѡ�в���ͬһ��Ԫ��
    begin
      Result := True;
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          if Cells[vR, vC].CellData <> nil then
            Cells[vR, vC].CellData.DeleteSelected;
        end;
      end;
    end
    else  // ��ͬһ��Ԫ��
      Result := GetEditCell.CellData.DeleteSelected;
  end;
end;

destructor THCTableItem.Destroy;
begin
  FSelectCellRang.Free;
  FRows.Clear;
  FRows.Free;
  FColWidths.Free;
  inherited;
end;

procedure THCTableItem.DisSelect;
begin
  inherited DisSelect;

  DisSelectSelectedCell;

  FSelectCellRang.Initialize;
  Self.InitializeMouseInfo;

  FSelecting := False;
  FDraging := False;
  FOutSelectInto := False;
end;

procedure THCTableItem.DisSelectSelectedCell(const ARow: Integer = -1;
  const ACol: Integer = -1);
var
  vRow, vCol: Integer;
  vCellData: THCTableCellData;
begin
  if FSelectCellRang.StartRow >= 0 then
  begin
    // ������ʼ��ȷ����ǰ��Ԫ���ִ��DisSelect ��201805172309����
    if (FSelectCellRang.StartRow = ARow) and (FSelectCellRang.StartCol = ACol) then

    else
    begin
      vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
      vCellData.DisSelect;
      vCellData.InitializeField;
    end;

    for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
    begin
      for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
      begin
        if (vRow = ARow) and (vCol = ACol) then

        else
        begin
          vCellData := FRows[vRow].Cols[vCol].CellData;
          if vCellData <> nil then
          begin
            vCellData.DisSelect;
            vCellData.InitializeField;
          end;
        end;
      end;
    end;
  end;
end;

procedure THCTableItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vR, vC,
  vCellScreenTop,
  vCellScreenBottom,
  vCellDataDrawTop,
  vCellDrawLeft,
  vCellDataDrawBottom,
  vFristDItemNo,
  vLastDItemNo,
  vBorderLeft,
  vBorderTop,
  vBorderRight,
  vBorderBottom,
  vShouLian, vBreakBottom,
  vMergeDestRow, vMergeDestCol, vMergeDestRow2, vMergeDestCol2, vSrcRowBorderTop,
  vMergeCellDataDrawTop, vFirstDrawRow,
  vPageDataScreenBottom  // APageDataScreenBottom��ȥ���п�ҳ����һҳʱ����ǰҳ�ײ��Ŀ���
    : Integer;
  //vDrawBord: Boolean;  // ��ĳһ���ڵ�ǰҳ����ʾ������������û��һ����DItem�ܻ��ƣ���ʱ(1)������ͨ������ȴ����Ҫ���Ʊ߿�
  vSelectAll, vDrawBorder,
  vDrawCellData,
  vRowHasDItemDisplay
    : Boolean;
  vCellData: THCTableCellData;

  {$REGION 'CheckRowBorderShouLian'}
  procedure CheckRowBorderShouLian(const ARow: Integer);
  var
    vC, i: Integer;
    vRect: TRect;
  begin
    if vShouLian = 0 then  // û�м������ǰ���п�ҳ������������ѿ�ҳʱ����λ��
    begin
      vBreakBottom := 0;
      for vC := 0 to FRows[ARow].ColCount - 1 do  // ����ͬ�и��У���ȡ�ض�λ��(��Ϊ������CheckFormatPage�Ѿ���÷�ҳλ�ã����Դ˴�ֻҪһ����Ԫ���ҳλ��ͬʱ���õ�ǰ�����е�Ԫ���ҳλ��)
      begin
        vMergeCellDataDrawTop := vCellDataDrawTop;
        GetMergeDest(ARow, vC, vMergeDestRow2, vMergeDestCol2);  // ��ȡ��Ŀ�굥Ԫ�������к�
        vCellData := FRows[vMergeDestRow2].Cols[vMergeDestCol2].CellData;
        while vMergeDestRow2 < ARow do  // Ŀ�굥Ԫ���CellDataDrawTop
        begin
          vMergeCellDataDrawTop := vMergeCellDataDrawTop - FRows[vMergeDestRow2].Height - FBorderWidth;
          Inc(vMergeDestRow2);
        end;

        for i := 0 to vCellData.DrawItems.Count - 1 do
        begin
          if vCellData.DrawItems[i].LineFirst then
          begin
            vRect := vCellData.DrawItems[i].Rect;
            //if DrawiInLastLine(i) then  // ��Ԫ�������һ�����ݲ���FCellVPadding
            vRect.Bottom := vRect.Bottom + FCellVPadding; // ÿһ�п�����Ҫ�ضϵģ��ض�ʱ����Ҫ�ܷ���FCellVPadding
            if vMergeCellDataDrawTop + vRect.Bottom > ADataDrawBottom then  // ������ǰҳ��
            begin
              if i > 0 then
                vShouLian := Max(vShouLian, vMergeCellDataDrawTop + vCellData.DrawItems[i - 1].Rect.Bottom)  // ��һ����������Ϊ�ض�λ��
              else
                vShouLian := Max(vShouLian, vMergeCellDataDrawTop - FBorderWidth);

              Break;
            end
            else  // û�г�����ǰҳ
              vBreakBottom := Max(vBreakBottom, vMergeCellDataDrawTop + vRect.Bottom);  // ��¼Ϊ�ɷ��µ����һ������(�еĵ�Ԫ���ڵ�ǰҳ��ȫ����ʾ��������ҳ)
          end;
        end;
      end;
      vShouLian := Max(vShouLian, vBreakBottom);
    end;
  end;
  {$ENDREGION}

begin
  ACanvas.Pen.Width := FBorderWidth;
  // ��Ԫ��
  vFirstDrawRow := -1;
  vCellDataDrawTop := ADrawRect.Top;  // ��1�����ݻ�����ʼλ��
  for vR := 0 to FRows.Count - 1 do
  begin
    // ���ڵ�ǰ��Ļ��Χ�ڵĲ�����(1)
    vCellDataDrawTop := vCellDataDrawTop + FRows[vR].FmtOffset + FBorderWidth + FCellVPadding;
    if vCellDataDrawTop > ADataScreenBottom then  // �����ݶ������ڿ���ʾ����ײ�������
      Break;
    vCellDataDrawBottom := vCellDataDrawTop + FRows[vR].Height - FCellVPadding;

    if vCellDataDrawBottom < ADataScreenTop then  // ��ǰ�еײ�С�ڿ���ʾ������û��ʾ����
    begin
      vCellDataDrawTop := vCellDataDrawBottom;  // ׼���ж���һ���Ƿ��ǿ���ʾ��һ��
      Continue;
    end;
    if vFirstDrawRow < 0 then
      vFirstDrawRow := vR;

    vCellDrawLeft := ADrawRect.Left + FBorderWidth;

    // ѭ���������и���Ԫ�����ݺͱ߿�
    vShouLian := 0;
    vRowHasDItemDisplay := False;
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if FRows[vR].Cols[vC].ColSpan < 0 then  // �ϲ���Դ
      begin
        vCellDrawLeft := vCellDrawLeft + FColWidths[vC] + FBorderWidth;
        Continue;  // ��ͨ��Ԫ���ϲ�Ŀ�굥Ԫ��������ݣ�������Ŀ�굥Ԫ����
      end;

      vDrawCellData := True;  // ����Ŀ�����п�ҳ����Ŀ���к����ж��кϲ�������ʱ��ֻ�ڿ�ҳ�����һ��Ŀ���е�����
      if FRows[vR].Cols[vC].RowSpan < 0 then  // 20170208001 �Ǻϲ���Դ��Ԫ��(���������ų�����Դ����������ֻ��Ŀ�굥Ԫ�����·��ĵ�Ԫ��)
      begin
        if vR <> vFirstDrawRow then  // ���ǿ�ҳ���һ�λ��Ƶ���
          vDrawCellData := False;  // Ŀ�굥Ԫ���Ѿ���ҳ���������ݣ������ظ������ˣ�������к�ĵ�һ��Ҫ����
      end;

      vFristDItemNo := -1;
      vLastDItemNo := -1;
      vMergeCellDataDrawTop := vCellDataDrawTop;
      GetMergeDest(vR, vC, vMergeDestRow, vMergeDestCol);  // ��ȡ��Ŀ�굥Ԫ�������к�
      vMergeDestRow2 := vMergeDestRow;
      while vMergeDestRow2 < vR do  // �õ�Ŀ�굥Ԫ��CellDataDrawTop��ֵ
      begin
        vMergeCellDataDrawTop := vMergeCellDataDrawTop - FRows[vMergeDestRow2].Height - FBorderWidth;
        Inc(vMergeDestRow2);
      end;

      vPageDataScreenBottom := ADataScreenBottom;
      if vDrawCellData then
      begin
        if (vR < FRows.Count - 1) and (FRows[vR + 1].FmtOffset > 0) then
          vPageDataScreenBottom := vPageDataScreenBottom - FRows[vR + 1].FmtOffset;
        vCellScreenBottom := Math.Min(vPageDataScreenBottom,  // ���������������¶�
          vCellDataDrawTop
          + Max(FRows[vR].Height, FRows[vMergeDestRow].Cols[vMergeDestCol].Height) - FCellVPadding  // �иߺ��кϲ��ĵ�Ԫ���������
          );

        //Assert(vCellScreenBottom - vMergeCellDataDrawTop >= FRows[vR].Height, '�ƻ�ʹ��Continue����ȷ�ϻ���������');
        vCellData := FRows[vMergeDestRow].Cols[vMergeDestCol].CellData;  // Ŀ��CellData��20170208003 ����Ƶ�if vDrawData������20170208002����Ҫ��
        vCellScreenTop := Math.Max(ADataScreenTop, vCellDataDrawTop - FCellVPadding);  // �������϶�
        if vCellScreenTop - vMergeCellDataDrawTop < vCellData.Height then  // ����ʾ����ʼλ��С�����ݸ߶�(��>=ʱ˵�����ݸ߶�С���и�ʱ�������Ѿ���ȫ��������)
        begin
          vCellData.GetDataDrawItemRang(  // ��ȡ����ʾ�������ʼ������DItem
            vCellScreenTop - vMergeCellDataDrawTop,
            vCellScreenBottom - vMergeCellDataDrawTop,
            vFristDItemNo, vLastDItemNo);

          vSelectAll := Self.IsSelectComplate or CellSelectComplate(vR, vC);  // ���ȫѡ�л�Ԫ��ȫѡ��
          if vSelectAll then  // ��ȫѡ��
          begin
            ACanvas.Brush.Color := FOwnerData.Style.SelColor;
            vCellData.DrawOptions := vCellData.DrawOptions - [doFontBackColor];
          end
          else
          begin
            ACanvas.Brush.Color := FRows[vMergeDestRow].Cols[vMergeDestCol].BackgroundColor;
            vCellData.DrawOptions := vCellData.DrawOptions + [doFontBackColor];
          end;

          ACanvas.FillRect(Rect(vCellDrawLeft, vCellScreenTop,  // + FRows[vR].Height,
            vCellDrawLeft + FRows[vR].Cols[vC].Width, vCellScreenBottom));

          if vFristDItemNo >= 0 then  // �п���ʾ��DrawItem
          begin
            {$IFDEF SHOWITEMNO}
            ACanvas.Font.Color := clGray;
            ACanvas.Font.Style := [];
            ACanvas.Font.Size := 8;
            ACanvas.TextOut(vCellDrawLeft + 1, vMergeCellDataDrawTop, IntToStr(vC) + '/' + IntToStr(vR));
            {$ENDIF}

            vCellData.PaintData(vCellDrawLeft + FCellHPadding, vMergeCellDataDrawTop,
              ADataDrawBottom, ADataScreenTop, vPageDataScreenBottom,
              0, ACanvas, APaintInfo);
          end;
        end;
      end;
      // ���Ƹ���Ԫ��߿���
      if FBorderVisible or (not APaintInfo.Print) then
      begin
        vDrawBorder := True;
        vBorderTop := vMergeCellDataDrawTop - FCellVPadding - FBorderWidth;  // Ŀ�굥Ԫ����ϱ߿�
        vBorderBottom := vBorderTop  // ����߿����¶�
          + Max(FRows[vR].Height, Cells[vMergeDestRow, vMergeDestCol].Height)  // ���ڿ����Ǻϲ�Ŀ�굥Ԫ�������õ�Ԫ��ߺ��и���ߵ�
          + FBorderWidth;

        { ���п�ҳ����������λ�� }
        if vBorderBottom > vPageDataScreenBottom then  // �ײ��߿�>ҳ�������Եײ�����Ҫ�жϺϲ���Ԫ������
        begin
          if Cells[vR, vC].RowSpan > 0 then  // �Ǻϲ�Ŀ�굥Ԫ��
          begin
            if vFristDItemNo < 0 then  // û�����ݱ����ƣ����ϲ�Ŀ�굥Ԫ�����������ƶ�����һҳ��
              //vDrawBorder := False
              vBorderBottom := vBorderTop + FRows[vR].Height + FBorderWidth  // �Ե�ǰ�н�β
            else
            if vBorderTop + FRows[vR].Height > vPageDataScreenBottom then  // Ŀ�굥Ԫ�����ڵ��о���Ҫ��ҳ��
            begin  // �ӵ�ǰ��������
              CheckRowBorderShouLian(vR);
              vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
            end
            else  // ��ȻĿ�굥Ԫ���ҳ�ˣ���������λ�ò�����Ŀ�굥Ԫ�������У����������������ڵ�Դ��Ԫ����(�� 2017-2-8_001.bmp)
              vDrawBorder := False;
          end
          else
          if Cells[vR, vC].RowSpan < 0 then  // �ϲ�Դ��Ԫ��
          begin                              // ���ڿ�ʼ����20170208001�жϣ����Դ˴��϶��Ǻϲ�Ŀ�����·��ĵ�Ԫ��
            { �ƶ�����ǰ����ʼλ�� }
            vSrcRowBorderTop := vBorderTop;  // ���ñ�����vBorderTopֵ��Ŀ�굥Ԫ����ϱ߿�
            for vMergeDestRow2 := vMergeDestRow to vR - 1 do
              vSrcRowBorderTop := vSrcRowBorderTop + FRows[vMergeDestRow2].Height + FBorderWidth;

            if vSrcRowBorderTop + FRows[vR].Height > vPageDataScreenBottom then  // �˺ϲ�Դ��Ԫ�����ڵ��п�ҳ��
            begin  // �ӵ�ǰ��������
              if vFristDItemNo < 0 then  // ��Ϊ��������Ŀ�굥Ԫ������ƣ�������Ҫ�жϱ��ϲ�Դ��Ԫ��������λ���ܷ���������ʾ����
              begin
                vCellData := FRows[vMergeDestRow].Cols[vMergeDestCol].CellData;  // Ŀ��CellData 20170208002 ���20170208003 ����Ƶ�if vDrawData��������Ҫ��
                vCellData.GetDataDrawItemRang(  // ��ȡ����ʾ�������ʼ������DItem
                  vCellScreenTop - vMergeCellDataDrawTop,
                  vCellScreenBottom - vMergeCellDataDrawTop,
                  vFristDItemNo, vLastDItemNo);
              end;
              if vFristDItemNo < 0 then  // Ŀ�굥Ԫ��û�����ݿ��Ե�ǰ����ʾ����
              begin
                if vShouLian = 0 then  // ˵��Ŀ�굥Ԫ�����ݲ�û�г�����ǰ��
                  vShouLian := vSrcRowBorderTop;  // �ڵ�ǰ���ϱ���������ǰ����ͨ��Ԫ���ƶ�����һҳ��ʼ�ˣ�
              end
              else  // �п�����ʾ�����ݣ����ȡ����λ��
                CheckRowBorderShouLian(vR);

              vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
              // ��Ҫ���Ʊ߿򣬽��߿���λ���ƻ�Ŀ��λ��
//                vMergeDestRow2 := vMergeDestRow;
//                while vMergeDestRow2 < vR do  // �õ�Ŀ�굥Ԫ��CellDataDrawTop��ֵ
//                begin
//                  vBorderTop := vBorderTop - FRows[vMergeDestRow2].Height - FBorderWidth;
//                  Inc(vMergeDestRow2);
//                end;
            end
            else  // ��ȻĿ�굥Ԫ���ҳ�ˣ���������λ�ò�����Ŀ�굥Ԫ�������У����������������ڵ�Դ��Ԫ����(�� 2017-2-8_001.bmp)
              vDrawBorder := False;
          end
          else  // ��ͨ��Ԫ��(���Ǻϲ�Ŀ��Ҳ���Ǻϲ�Դ)
          begin
            if (vFristDItemNo < 0) and (vR <> vFirstDrawRow) then
              vDrawBorder := False
            else
            begin
              if FRows[vR].AutoHeight then
                CheckRowBorderShouLian(vR)
              else
                vShouLian := vPageDataScreenBottom;

              vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
            end;
          end;
        end;

        if vDrawBorder then
        begin
          if FBorderVisible then
          begin
            ACanvas.Pen.Color := clBlack;
            ACanvas.Pen.Style := psSolid;
          end
          else
          begin
            ACanvas.Pen.Color := clActiveBorder;
            ACanvas.Pen.Style := psDot;
          end;

          vBorderLeft := vCellDrawLeft - FBorderWidth;
          vBorderRight := vBorderLeft + FColWidths[vC] + FBorderWidth;

          vMergeDestCol2 := FRows[vMergeDestRow].Cols[vMergeDestCol].ColSpan;
          while vMergeDestCol2 > 0 do
          begin
            vBorderRight := vBorderRight + FColWidths[vMergeDestCol + vMergeDestCol2] + FBorderWidth;
            Dec(vMergeDestCol2);
          end;

          if vBorderTop < ADataScreenTop then  // ���ǰ�п�ҳ�ˣ�����ҳ�󣬵ڶ�ҳ��ʼ�б���ϱ߿���ʾλ����Ҫ����
            vBorderTop := ADataScreenTop;

          if vBorderTop > 0 then
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);   // ������
            ACanvas.LineTo(vBorderRight, vBorderTop);  // ������
          end
          else
            ACanvas.MoveTo(vBorderRight, vBorderTop);  // ������

          ACanvas.LineTo(vBorderRight, vBorderBottom);  // ������
          ACanvas.LineTo(vBorderLeft, vBorderBottom);  // ������
          if vC = 0 then  // ��1�л���ǰ�����ߣ���������ǰһ�к������ߴ���ǰ������
            ACanvas.LineTo(vBorderLeft, vBorderTop - 1);
        end;
      end;
      vCellDrawLeft := vCellDrawLeft + FColWidths[vC] + FBorderWidth;  // ͬ����һ�е���ʼLeftλ��
    end;
    vCellDataDrawTop := vCellDataDrawBottom;  // ��һ�е�Topλ��
  end;
  // �϶���
  if Resizing and (FResizeInfo.TableSite = tsBorderRight) then  // ��ֱ
  begin
    ACanvas.Pen.Color := Self.FBorderColor;
    ACanvas.Pen.Style := psDot;
    ACanvas.MoveTo(ADrawRect.Left + FResizeInfo.DestX, Max(ADataDrawTop, ADrawRect.Top));
    ACanvas.LineTo(ADrawRect.Left + FResizeInfo.DestX, Min(ADataDrawBottom,
      Min(ADrawRect.Bottom, vBorderBottom)));
  end
  else
  if Resizing and (FResizeInfo.TableSite = tsBorderBottom) then  // ˮƽ
  begin
    ACanvas.Pen.Color := Self.FBorderColor;
    ACanvas.Pen.Style := psDot;
    ACanvas.MoveTo(ADrawRect.Left, ADrawRect.Top + FResizeInfo.DestY);
    ACanvas.LineTo(ADrawRect.Right, ADrawRect.Top + FResizeInfo.DestY);
  end;
end;

procedure THCTableItem.DoRowAdd(const ARow: TTableRow);
var
  i: Integer;
begin
  for i := 0 to ARow.ColCount - 1 do
  begin
    if ARow.Cols[i].CellData <> nil then
    begin
      ARow.Cols[i].CellData.OnInsertItem := (FOwnerData as THCCustomRichData).OnInsertItem;
      ARow.Cols[i].CellData.OnItemPaintAfter := (FOwnerData as THCCustomRichData).OnItemPaintAfter;
      ARow.Cols[i].CellData.OnItemPaintBefor := (FOwnerData as THCCustomRichData).OnItemPaintBefor;

      ARow.Cols[i].CellData.OnCreateItem := (FOwnerData as THCCustomRichData).OnCreateItem;
    end;
  end;
end;

procedure THCTableItem.KeyDown(var Key: Word; Shift: TShiftState);

  function IsDirectionKey(const AKey: Word): Boolean;
  begin
    Result := AKey in [VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN];
  end;

var
  vEditCell: THCTableCell;

  function DoCrossCellKey(const AKey: Word): Boolean;
  var
    i, vRow, vCol: Integer;
  begin
    Result := False;

    vRow := -1;
    vCol := -1;

    {$REGION 'VK_LEFT'}
    if AKey = VK_LEFT then
    begin
      if vEditCell.CellData.SelectFirstItemOffsetBefor then
      begin
        // ����൥Ԫ��
        for i := FSelectCellRang.StartCol - 1 downto 0 do
        begin
          if Cells[FSelectCellRang.StartRow, i].ColSpan = 0 then
          begin
            vCol := i;
            Break;
          end;
        end;

        if vCol >= 0 then
        begin
          FSelectCellRang.StartCol := vCol;
          with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
          begin
            SelectInfo.StartItemNo := 0;
            SelectInfo.StartItemOffset := 0;
            CaretDrawItemNo := DrawItems.Count - 1;
          end;

          Result := True;
        end;
      end;
    end
    {$ENDREGION}
    else
    {$REGION 'VK_RIGHT'}
    if AKey = VK_RIGHT then
    begin
      if vEditCell.CellData.SelectLastItemOffsetAfter then
      begin
        // ���Ҳ൥Ԫ��
        for i := FSelectCellRang.StartCol + 1 to FColWidths.Count - 1 do
        begin
          if Cells[FSelectCellRang.StartRow, i].ColSpan = 0 then
          begin
            vCol := i;
            Break;
          end;
        end;

        if vCol >= 0 then
        begin
          FSelectCellRang.StartCol := vCol;
          with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
          begin
            SelectInfo.StartItemNo := 0;
            SelectInfo.StartItemOffset := 0;
            CaretDrawItemNo := 0;
          end;

          Result := True;
        end;
      end
    end
    {$ENDREGION}
    else
    {$REGION 'VK_UP'}
    if AKey = VK_UP then
    begin
      if (vEditCell.CellData.SelectFirstLine) and (FSelectCellRang.StartRow > 0) then  // ����һ�е�Ԫ��
      begin
        GetDestCell(FSelectCellRang.StartRow - 1, FSelectCellRang.StartCol, vRow, vCol);

        if (vRow >= 0) and (vCol >= 0) then
        begin
          FSelectCellRang.StartRow := vRow;
          FSelectCellRang.StartCol := vCol;
          with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
          begin
            SelectInfo.StartItemNo := Items.Count - 1;
            if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
              SelectInfo.StartItemOffset := OffsetAfter
            else
              SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;

            CaretDrawItemNo := DrawItems.Count - 1;
          end;

          Result := True;
        end;
      end;
    end
    {$ENDREGION}
    else
    {$REGION 'VK_DOWN'}
    if AKey = VK_DOWN then
    begin
      if (vEditCell.CellData.SelectLastLine) and (FSelectCellRang.StartRow < Self.RowCount - 1) then  // ����һ�е�Ԫ��
      begin
        GetDestCell(FSelectCellRang.StartRow + 1, FSelectCellRang.StartCol, vRow, vCol);
        if (vRow >= 0) and (vCol >= 0) then
        begin
          FSelectCellRang.StartRow := vRow;
          FSelectCellRang.StartCol := vCol;
          with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
          begin
            SelectInfo.StartItemNo := 0;
            SelectInfo.StartItemOffset := 0;
            CaretDrawItemNo := 0;
          end;

          Result := True;
        end;
      end;
    end;
    {$ENDREGION}
  end;

var
  vOldHeight: Integer;
  vOldKey: Word;
begin
  Self.SizeChanged := False;

  vEditCell := GetEditCell;
  if vEditCell <> nil then
  begin
    vOldKey := Key;
    vOldHeight := vEditCell.CellData.Height;
    vEditCell.CellData.KeyDown(Key, Shift);
    Self.SizeChanged := vOldHeight <> vEditCell.CellData.Height;

    if (Key = 0) and IsDirectionKey(vOldKey) then  // ��Ԫ��Dataû�������Ƿ����
    begin
      if DoCrossCellKey(vOldKey) then
      begin
        FOwnerData.Style.UpdateInfoReCaret;
        Key := vOldKey;
      end;
    end;
  end
  else
    Key := 0;
end;

procedure THCTableItem.KeyPress(var Key: Char);
var
  vOldHeight: Integer;
  vEditCell: THCTableCell;
begin
  Self.SizeChanged := False;

  vEditCell := GetEditCell;
  if vEditCell <> nil then
  begin
    vOldHeight := vEditCell.CellData.Height;
    vEditCell.CellData.KeyPress(Key);
    Self.SizeChanged := vOldHeight <> vEditCell.CellData.Height;
  end;
end;

procedure THCTableItem.KillFocus;
begin
  // ��������Ԫ��ѡ�У��������ʼ�����ٵ���ᰴ����ѡ�д�����ѡ�а��������ѱ����
  // �����ⲿ����������ʱҲ�Ѿ�ʧȥ�˰���ʱ�����У�����Ҫô����ʼ����Ҫô���׳�ʼ��
  //Self.InitializeMouseInfo;
end;

procedure THCTableItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  i, vR, vC, vWidth: Integer;
  vAutoHeight: Boolean;
  vRow: TTableRow;
begin
  FRows.Clear;
  inherited LoadFromStream(AStream, AStyle, AFileVersion);

  AStream.ReadBuffer(FBorderVisible, SizeOf(FBorderVisible));
  AStream.ReadBuffer(vR, SizeOf(vR));  // ����
  AStream.ReadBuffer(vC, SizeOf(vC));  // ����
  { �����С��� }
  for i := 0 to vR - 1 do
  begin
    vRow := TTableRow.Create(FOwnerData.Style, vC);  // ע���д���ʱ��tableӵ���ߵ�Style������ʱ�Ǵ����AStyle
    FRows.Add(vRow);
  end;

  { ���ظ��б�׼��� }
  FColWidths.Clear;
  for i := 0 to vC - 1 do
  begin
    AStream.ReadBuffer(vWidth, SizeOf(vWidth));
    FColWidths.Add(vWidth);
  end;

  { ���ظ������� }
  for vR := 0 to FRows.Count - 1 do
  begin
    AStream.ReadBuffer(vAutoHeight, SizeOf(Boolean));
    FRows[vR].AutoHeight := vAutoHeight;
    if not FRows[vR].AutoHeight then
    begin
      AStream.ReadBuffer(vWidth, SizeOf(Integer));
      FRows[vR].Height := vWidth;
    end;
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      FRows[vR].Cols[vC].CellData.Width := FColWidths[vC] - 2 * FCellHPadding;
      FRows[vR].Cols[vC].LoadFromStream(AStream, AStyle, AFileVersion);
    end;
  end;
end;

procedure THCTableItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  //i: Integer;
  vMouseDownRow, vMouseDownCol: Integer;// abstract vBottom;
  vCell: THCTableCell;
  vCellPt: TPoint;
begin
  FMouseLBDowning := (Button = mbLeft) and (Shift = [ssLeft]);
  FOutSelectInto := False;
  FSelecting := False;  // ׼����ѡ
  FDraging := False;  // ׼����ק

  FResizeInfo := GetCellAt(X, Y, vMouseDownRow, vMouseDownCol);

  Resizing := (FResizeInfo.TableSite = tsBorderRight) or (FResizeInfo.TableSite = tsBorderBottom);
  if Resizing then
  begin
    FMouseDownRow := vMouseDownRow;
    FMouseDownCol := vMouseDownCol;
    FMouseDownX := X;
    FMouseDownY := Y;
    FOwnerData.Style.UpdateInfoRePaint;
    Exit;
  end;

  if FResizeInfo.TableSite = tsCell then
  begin
    if CoordInSelect(X, Y) then  // ��ѡ�������У��������߿��߼��߿����ݲ
    begin
      if FMouseLBDowning then
        FDraging := True;

      FMouseDownRow := vMouseDownRow;  // ��¼��ק��ʼ��Ԫ��
      FMouseDownCol := vMouseDownCol;

      vCellPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
      FRows[FMouseDownRow].Cols[FMouseDownCol].CellData.MouseDown(
        Button, Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end
    else  // ����ѡ��������
    begin
      {DisSelect;  // ���ԭѡ��

      if (vMouseDownRow <> FMouseDownRow) or (vMouseDownCol <> FMouseDownCol) then  // ��λ��
      begin
        vCell := GetEditCell;
        if vCell <> nil then  // ȡ��ԭ���༭
          vCell.Active := False;

        FMouseDownRow := vMouseDownRow;
        FMouseDownCol := vMouseDownCol;
        FOwnerData.Style.UpdateInfoReCaret;
      end; }

      // �����ִ��DisSelect�����Mouse��Ϣ�����µ�ǰ�༭��Ԫ������Ӧȡ�������¼�
      if (vMouseDownRow <> FMouseDownRow) or (vMouseDownCol <> FMouseDownCol) then  // ��λ��
      begin
        vCell := GetEditCell;
        if vCell <> nil then  // ȡ��ԭ���༭
          vCell.Active := False;
        FOwnerData.Style.UpdateInfoReCaret;
      end;

      DisSelect;  // ���ԭѡ��

      FMouseDownRow := vMouseDownRow;
      FMouseDownCol := vMouseDownCol;

      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.StartCol := FMouseDownCol;

      vCellPt := GetCellPostion(FMouseDownRow, FMouseDownCol);

      FRows[FMouseDownRow].Cols[FMouseDownCol].CellData.MouseDown(
        Button, Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end;
  end
  else
  begin
    DisSelect;  // ȡ��ԭ��ѡ��
    Self.InitializeMouseInfo;
  end;
end;

procedure THCTableItem.MouseLeave;
begin
  inherited;
  if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;
  if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
    FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove([], -1, -1);  // ����������ϸ�����Ѹ���Ƴ������ָܻ�������

  if not SelectExists then
    Self.InitializeMouseInfo;
end;

procedure THCTableItem.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vMoveRow, vMoveCol: Integer;

  {$REGION 'AdjustSelectRang'}
  procedure AdjustSelectRang;
  var
    vRow, vCol: Integer;
  begin
    // �������ʼ��Ԫ��֮��ģ��Ա��������´���ѡ�е�Ԫ���ȫѡ
    if FSelectCellRang.StartRow >= 0 then
    begin
      for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          if ((vRow = FMouseDownRow) and (vCol = FMouseDownCol))
            //or ((vRow = vMoveRow) and (vCol = vMoveCol))
          then  // ������ǰ���µ�ѡ����Ϣ����ֹ�ص������������ݵ�ѡ��

          else
          begin
            if Cells[vRow, vCol].CellData <> nil then
              Cells[vRow, vCol].CellData.DisSelect;
          end;
        end;
      end;
    end;

    if FMouseDownRow < 0 then  // �ӱ������ѡ������
    begin
      if vMoveRow = 0 then  // ������ѡ��
      begin
        FMouseDownRow := 0;
        FMouseDownCol := 0;

        FSelectCellRang.StartRow := FMouseDownRow;
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndRow := vMoveRow;
        FSelectCellRang.EndCol := vMoveCol;
      end
      else  // ������ѡ��
      begin
        GetDestCell(Self.RowCount - 1, Self.FColWidths.Count - 1, vRow, vCol);
        FMouseDownRow := vRow;
        FMouseDownCol := vCol;

        FSelectCellRang.StartRow := vMoveRow;
        FSelectCellRang.StartCol := vMoveCol;
        FSelectCellRang.EndRow := FMouseDownRow;
        FSelectCellRang.EndCol := FMouseDownCol;
      end;

      {with Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData do
      begin
        SelectInfo.StartItemNo := 0;
        SelectInfo.StartItemOffset := 0;
      end;}

      FOutSelectInto := True;
    end
    else
    if FMouseMoveRow > FMouseDownRow then  // �ƶ����ڰ���������
    begin
      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.EndRow := FMouseMoveRow;

      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ�����ǰ��
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end
    else
    if FMouseMoveRow < FMouseDownRow then  // �ƶ����ڰ���������
    begin
      FSelectCellRang.StartRow := FMouseMoveRow;
      FSelectCellRang.EndRow := FMouseDownRow;

      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ�����ǰ��
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end
    else  // FMouseMoveRow = FMouseDownRow �ƶ��� = ������
    begin
      FSelectCellRang.StartRow := FMouseDownRow;
      FSelectCellRang.EndRow := FMouseMoveRow;

      if FMouseMoveCol > FMouseDownCol then  // �ƶ����ڰ������ұ�
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end
      else
      if FMouseMoveCol < FMouseDownCol then  // �ƶ����ڰ��������
      begin
        FSelectCellRang.StartCol := FMouseMoveCol;
        FSelectCellRang.EndCol := FMouseDownCol;
      end
      else  // �ƶ��� = ������
      begin
        FSelectCellRang.StartCol := FMouseDownCol;
        FSelectCellRang.EndCol := FMouseMoveCol;
      end;
    end;

    if (FSelectCellRang.StartRow = FSelectCellRang.EndRow)
      and (FSelectCellRang.StartCol = FSelectCellRang.EndCol)
    then
    begin
      FSelectCellRang.EndRow := -1;
      FSelectCellRang.EndCol := -1;
    end;
  end;
  {$ENDREGION}

  {$REGION 'MatchCellSelectState'}
  procedure MatchCellSelectState;
  var
    vRow, vCol: Integer;
  begin
    if not FSelectCellRang.EditCell then
    begin
      for vRow := FSelectCellRang.FStartRow to FSelectCellRang.FEndRow do
      begin
        for vCol := FSelectCellRang.FStartCol to FSelectCellRang.FEndCol do
        begin
          {if (vRow = vMoveRow) and (vCol = vMoveCol) then else ʲô�������Ҫ����?}
          if Cells[vRow, vCol].CellData <> nil then
            Cells[vRow, vCol].CellData.SelectAll;
        end;
      end;
    end;
  end;
  {$ENDREGION}

var
  vCellPt: TPoint;
  vResizeInfo: TResizeInfo;
begin
  if ActiveDataResizing then
  begin
    vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MouseMove(
      Shift, X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);

    Exit;
  end;

  if Resizing then  // (ssLeft in Shift)
  begin
    FResizeInfo.DestX := X;
    FResizeInfo.DestY := Y;
    FOwnerData.Style.UpdateInfoRePaint;

    Exit;
  end;

  vResizeInfo := GetCellAt(X, Y, vMoveRow, vMoveCol);

  if vResizeInfo.TableSite = tsCell then  // ����ڵ�Ԫ����
  begin
    if FMouseLBDowning or (Shift = [ssLeft]) then  // ��������ƶ�������ʱ�ڱ���� or û���ڱ���ϰ���(��ѡ����)
    begin
      if FDraging or FOwnerData.Style.UpdateInfo.Draging then
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
        vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);

        Exit;
      end;

      if not FSelecting then
        FSelecting := True;

      if (vMoveRow <> FMouseMoveRow) or (vMoveCol <> FMouseMoveCol) then  // ����ƶ����µ�Ԫ��
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;

        AdjustSelectRang;  // ����ѡ����ʼ������Χ(������Ӻ�����ǰѡ�����)
        MatchCellSelectState;  // ����ѡ�з�Χ�ڸ���Ԫ���ѡ��״̬
      end;

      {if (FSelectCellRang.StartRow = FMouseMoveRow)
        and (FSelectCellRang.StartCol = FMouseMoveCol)
      then}  // ѡ����ʼ��������ͬһ����Ԫ��
      begin
        vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
      end;
    end
    else  // ����ƶ���û�а�������
    begin
      if (vMoveRow <> FMouseMoveRow) or (vMoveCol <> FMouseMoveCol) then  // ����ƶ����µ�Ԫ��
      begin
        if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
        begin
          if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
            FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
        end;

        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
      end;

      if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;

      vCellPt := GetCellPostion(FMouseMoveRow, FMouseMoveCol);
      FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove(Shift,
        X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding);
    end;
  end
  else
  begin
    if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
    begin
      if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
        FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
    end;

    FMouseMoveRow := -1;
    FMouseMoveCol := -1;

    if vResizeInfo.TableSite = tsBorderRight then // ��겻�ڵ�Ԫ����
      GCursor := crHSplit
    else
    if vResizeInfo.TableSite = tsBorderBottom then
      GCursor := crVSplit;
  end;
end;

procedure THCTableItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vPt: TPoint;
  vUpRow, vUpCol: Integer;
  vCellPt: TPoint;
  vResizeInfo: TResizeInfo;
  //vMouseUpInSelect: Boolean;
begin
  FMouseLBDowning := False;

  if ActiveDataResizing then
  begin
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MouseUp(
      Button, Shift, X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);

    Exit;
  end;

  if Resizing then  // �϶��ı��п���Ԫ��Data��ȵĸı������¸�ʽ������
  begin
    if FResizeInfo.TableSite = tsBorderRight then  // �Ͽ�/��խ
    begin
      vPt.X := X - FMouseDownX;  // ��ʹ��FResizeInfo.DestX(����ɰ��´�����Ҳ��ƫ��)
      if vPt.X <> 0 then
      begin
        // AReDestΪFalse���ڴ����϶��ı��п�ʱ�����϶������Ǻϲ�Դ�������д��в��޺ϲ�����
        // ��ʱ�������ȡ�϶���Ŀ���б�����������϶������в�û���
        vResizeInfo := GetCellAt(FMouseDownX, FMouseDownY, vUpRow, vUpCol, False{ʵ��λ�ô�����});

        if (vResizeInfo.TableSite <> tsOutside) and (vPt.X <> 0) then  // û����������
        begin
          if vPt.X > 0 then  // �Ͽ���
          begin
            if vUpCol < FColWidths.Count - 1 then  // �Ҳ��У��Ҳ��խ����С����С���
            begin
              if FColWidths[vUpCol + 1] - vPt.X < MinColWidth then
                vPt.X := FColWidths[vUpCol + 1] - MinColWidth;

              if vPt.X <> 0 then
              begin
                FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯
                if vUpCol < FColWidths.Count - 1 then  // �Ҳ���ֲ��仯
                  FColWidths[vUpCol + 1] := FColWidths[vUpCol + 1] - vPt.X;
              end;
            end
            else  // ���Ҳ����Ͽ�
            begin
              {if FColWidths[vUpCol] + vPt.X > PageWidth then  ��ʱ�������϶�����ҳ��
                vPt.X := Width - FColWidths[vUpCol + 1];

              if vPt.X <> 0 then}
                FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯
            end;
          end
          else  // ��խ��
          begin
            if FColWidths[vUpCol] + vPt.X < MinColWidth then  // С����С���
              vPt.X := MinColWidth - FColWidths[vUpCol];

            if vPt.X <> 0 then
            begin
              FColWidths[vUpCol] := FColWidths[vUpCol] + vPt.X;  // ��ǰ�б仯
              if vUpCol < FColWidths.Count - 1 then  // �Ҳ���ֲ��仯
                FColWidths[vUpCol + 1] := FColWidths[vUpCol + 1] - vPt.X;
            end;
          end;
        end;
      end;
    end
    else
    if FResizeInfo.TableSite = tsBorderBottom then  // �ϸ�/�ϰ�
    begin
      vPt.Y := Y - FMouseDownY;  // // ��ʹ��FResizeInfo.DestY(����ɰ��´�����Ҳ��ƫ��)
      if vPt.Y <> 0 then
      begin
        FRows[FMouseDownRow].Height := FRows[FMouseDownRow].Height + vPt.Y;
        FRows[FMouseDownRow].AutoHeight := False;
       end;
    end;

    Resizing := False;
    GCursor := crDefault;
    FOwnerData.Style.UpdateInfoRePaint;
    FOwnerData.Style.UpdateInfoReCaret;

    Exit;
  end;

  if FSelecting or FOwnerData.Style.UpdateInfo.Selecting then  // ��ѡ���
  begin
    FSelecting := False;

    // ���ڰ��µ�Ԫ�����Ա㵥Ԫ����Ƕ�׵ı���л�����Ӧ����(ȡ�����¡���ѡ״̬����ѡ���)
    if (FMouseDownRow >= 0) and (not FOutSelectInto) then  // �ڱ���Ҳఴ���ƶ�ʱ�ٵ���ʱ����Ч��FMouseDownRow��FMouseDownCol
    begin
      vPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
      Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
        X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
    end;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);
    if vResizeInfo.TableSite = TTableSite.tsCell then  // û�л�ѡ��ҳ��հ׵ĵط�
    begin
      if (vUpRow <> FMouseDownRow) or (vUpCol <> FMouseDownCol) then  // ��ѡ��ɺ����ڷǰ��µ�Ԫ��
      begin
        vPt := GetCellPostion(vUpRow, vUpCol);
        Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
          X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
      end;
    end;
  end
  else
  if FDraging or FOwnerData.Style.UpdateInfo.Draging then  // ��ק����
  begin
    FDraging := False;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);

    if vResizeInfo.TableSite = TTableSite.tsCell then  // �ϵ���ĳ��Ԫ����
    begin
      DisSelectSelectedCell(vUpRow, vUpCol);  // ȡ��������֮���������קѡ�е�Ԫ���״̬
      FSelectCellRang.Initialize;  // ׼�����¸�ֵ

      // �����Ƿ�����ѡ�е�Ԫ���е�����ק������Ҫ�༭��ѡ�е�Ԫ��
      FSelectCellRang.StartRow := vUpRow;
      FSelectCellRang.StartCol := vUpCol;
      vPt := GetCellPostion(vUpRow, vUpCol);
      Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
        X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);

      {if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��(����ǻ�ѡ��Χ������һ��������������ק�������ʱû�а���FMouseDownRow)
        Cells[FMouseDownRow, FMouseDownCol].CellData.InitializeField;}  // ��ק��ʼ��Ԫ�������ק�����
    end;
  end
  else  // �ǻ�ѡ������ק
  if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��
  begin
    vPt := GetCellPostion(FMouseDownRow, FMouseDownCol);
    Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
      X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
  end;
end;

function THCTableItem.ClearFormatExtraHeight: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FRows.Count - 1 do
    Result := Result + FRows[i].ClearFormatExtraHeight;
  Self.Height := Self.Height - Result;
end;

function THCTableItem.GetFormatHeight: Integer;
var
  i: Integer;
begin
  Result := FBorderWidth;
  for i := 0 to RowCount - 1 do
    Result := Result + FRows[i].Height + FBorderWidth;
end;

function THCTableItem.GetHint: string;
var
  vCell: THCTableCell;
begin
  Result := inherited GetHint;
  if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;
  vCell := Cells[FMouseMoveRow, FMouseMoveCol];
  if (vCell <> nil) and (vCell.CellData <> nil) then
    Result := vCell.CellData.GetHint;
end;

function THCTableItem.GetCells(ARow, ACol: Integer): THCTableCell;
begin
  Result := FRows[ARow].Cols[ACol];
end;

{function THCTableItem.GetColCount: Integer;
begin
  Result := FColWidths.Count;
end;}

procedure THCTableItem.GetDestCell(const ARow, ACol: Cardinal; var ADestRow,
  ADestCol: Integer);
begin
  if Cells[ARow, ACol].CellData <> nil then
  begin
    ADestRow := ARow;
    ADestCol := ACol;
  end
  else
  begin
    ADestRow := ARow + Cells[ARow, ACol].RowSpan;
    ADestCol := ACol + Cells[ARow, ACol].ColSpan;
  end;
end;

procedure THCTableItem.GetEditCell(var ARow, ACol: Integer);
begin
  ARow := -1;
  ACol := -1;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    ARow := FSelectCellRang.StartRow;
    ACol := FSelectCellRang.StartCol;
  end;
end;

function THCTableItem.GetEditCell: THCTableCell;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol]
  else
    Result := nil;
end;

function THCTableItem.GetCellAt(const X, Y: Integer; var ARow, ACol: Integer;
  const AReDest: Boolean = True): TResizeInfo;

  {$REGION 'CheckRowBorderRang'}
  function CheckRowBorderRang(const ABottom: Integer): Boolean;
  begin
    Result := (Y >= ABottom - GripSize) and (Y <= ABottom + GripSize);  // �Ƿ����б߿�����
  end;
  {$ENDREGION}

  {$REGION 'CheckColBorderRang'}
  function CheckColBorderRang(const ALeft: Integer): Boolean;
  begin
    Result := (X >= ALeft - GripSize) and (X <= ALeft + GripSize);  // �Ƿ����б߿�����
  end;
  {$ENDREGION}

var
  i, vTop, vBottom, vDestRow, vDestCol: Integer;
  vLeft: Integer absolute vTop;
  vRight: Integer absolute vBottom;
begin
  Result.TableSite := tsOutside;
  ARow := -1;
  ACol := -1;
  if (X < 0) or (Y < 0) then Exit;
  if (X > Width) or (Y > Height) then Exit;
  { ��ȡ�Ƿ����л��еı߿��� }
  // �ж��Ƿ������ϱ߿�
  vTop := FBorderWidth;
  if CheckRowBorderRang(vTop) then  // ��һ�����ϱ߿�
  begin
    Result.TableSite := tsBorderTop;
    Exit;
  end;
  // �ж��Ƿ�������߿�
  if CheckColBorderRang(vTop) then
  begin
    Result.TableSite := tsBorderLeft;
    Exit;
  end;

  // �ж������б߿��ϻ�������
  for i := 0 to RowCount - 1 do
  begin
    vTop := vTop + FRows[i].FmtOffset;  // ��ʵ������TopΪ��λ�ã��������п�ҳʱ������һҳ�ײ����ѡ�е�����һҳ��һ��
    vBottom := vTop + FRows[i].Height + FBorderWidth;
    if CheckRowBorderRang(vBottom) then  // ��i���±߿�
    begin
      ARow := i;
      Result.TableSite := tsBorderBottom;
      Result.DestY := vBottom;
      Break;  // Ϊ����絥Ԫ��ѡʱ�������±߿�ʱACol<0����м�ѡ�е�Ҳ�����Ե������⣬�������������Ҳ���ʱExit
    end;
    if (vTop < Y) and (vBottom > Y) then  // �ڴ�����
    begin
      ARow := i;
      Break;
    end;
    vTop := vBottom;
  end;

  if ARow < 0 then Exit;

  // �ж������б߿��ϻ�������
  vLeft := FBorderWidth;
  for i := 0 to FColWidths.Count - 1 do
  begin
    vRight := vLeft + FColWidths[i] + FBorderWidth;
    GetDestCell(ARow, i, vDestRow, vDestCol);
    if CheckColBorderRang(vRight) then  // ��i���ұ߿�
    begin
      ACol := i;
      if vDestCol + Cells[vDestRow, vDestCol].ColSpan <> i then  // ���б߿�ʱ���Ҳ��Ǻϲ�Դ�����һ�У����ڵ�Ԫ���д���
        Result.TableSite := tsCell
      else
        Result.TableSite := tsBorderRight;

      Result.DestX := vRight;

      Break;
    end;
    if (vLeft < X) and (vRight > X) then  // �ڴ�����
    begin
      ACol := i;
      if (Result.TableSite = tsBorderBottom)
        and (vDestRow + Cells[vDestRow, vDestCol].RowSpan <> ARow)
      then  // ���б߿�ʱ���Ҳ��Ǻϲ�Դ�����һ�У����ڵ�Ԫ���д���
        Result.TableSite := tsCell;

      Break;
    end;
    vLeft := vRight;
  end;

  if ACol >= 0 then  // ��ȷ���ĵ�Ԫ��
  begin
    if Result.TableSite = tsOutside then  // ��������Ϊ��Ԫ����
      Result.TableSite := tsCell;

    if AReDest and (Cells[ARow, ACol].CellData = nil) then // ����Ǳ��ϲ��ĵ�Ԫ�񣬷��غϲ���ĵ�Ԫ��
      GetDestCell(ARow, ACol, ARow, ACol);
  end;
end;

function THCTableItem.GetCellPostion(const ARow, ACol: Integer): TPoint;
var
  i: Integer;
begin
  Result.X := FBorderWidth;
  Result.Y := FBorderWidth;
  for i := 0 to ARow - 1 do
    Result.Y := Result.Y + FRows[i].FmtOffset + FRows[i].Height + FBorderWidth;
  Result.Y := Result.Y + FRows[ARow].FmtOffset;
  for i := 0 to ACol - 1 do
    Result.X := Result.X + FColWidths[i] + FBorderWidth;
end;

{function THCTableItem.GetMergeDestCellData(const ARow,
  ACol: Integer): THCTableCellData;
var
  vDestRow, vDestCol: Integer;
begin
  GetMergeDest(ARow, ACol, vDestRow, vDestCol);
  Result := Cells[vDestRow, vDestCol].CellData;
end;}

procedure THCTableItem.GetMergeDest(const ARow, ACol: Integer; var ADestRow,
  ADestCol: Integer);
begin
  ADestRow := ARow;
  ADestCol := ACol;

  if Cells[ARow, ACol].RowSpan < 0 then
    ADestRow := ADestRow + Cells[ARow, ACol].RowSpan;

  if Cells[ARow, ACol].ColSpan < 0 then
    ADestCol := ADestCol + Cells[ARow, ACol].ColSpan;
end;

// ��ʱû��ע�͵��ˣ�������߼����ӣ���ò�Ҫɾ���Ա���
//procedure THCTableItem.GetPageFmtBottomInfo(const AHeight: Integer;
//  var ADItemMostBottom: Integer);
//var
//  i, j, vPageLastRow, vTop, vBottom: Integer;
//  vCellData: THCTableCellData;
//begin
//  ADItemMostBottom := Height;  // GetFormatHeight;
//  if ADItemMostBottom < AHeight then  // ������嶼�ܷ��� �� 20160323002 ���
//    Exit;
//  vTop := FBorderWidth;
//  vPageLastRow := RowCount - 1;
//  for i := 0 to RowCount - 1 do  // ��һ�г����߶�(��ҳ��)
//  begin
//    vBottom := vTop + FRows[i].Height;
//    if vBottom > AHeight then
//    begin
//      vPageLastRow := i;
//      Break;
//    end
//    else
//      vTop := vBottom + FBorderWidth;
//  end;
//
//  ADItemMostBottom := 0;
//  // ����vPageLastRow���������һҳ��ʼ�����(������� 2016-3-23_001.bmp)
//  for i := 0 to FRows[vPageLastRow].ColCount - 1 do
//  begin
//    if Cells[vPageLastRow, i].CellData = nil then
//      Continue;
//    vCellData := Cells[vPageLastRow, i].CellData;
//    if vCellData.DrawItems[0].Rect.Bottom + vTop > AHeight
//    then  // ���vPageLastRow�������еĵ�1��������һҳ��˵�����д���һҳ��ʼ����ʱ��ǰҳ����һ��
//    begin
//      Dec(vPageLastRow);  // ��һ��
//      // ������һ�еĵײ�λ��
//      //ADItemMostBottom := FBorderWidth;
//      for j := 0 to vPageLastRow do
//        ADItemMostBottom := ADItemMostBottom + FBorderWidth + FRows[i].Height;
//      Exit;
//    end;
//  end;
//  // vPageLastRow�дӵ�ǰҳ��ʼ
//  for i := 0 to FRows[vPageLastRow].ColCount - 1 do
//  begin
//    if Cells[vPageLastRow, i].CellData = nil then
//      Continue;
//    vCellData := Cells[vPageLastRow, i].CellData;
//    vBottom := vCellData.DrawItems[0].Rect.Bottom + vTop;
//    if ADItemMostBottom < vBottom then
//      ADItemMostBottom := vBottom;
//    for j := 1 to vCellData.DrawItems.Count - 1 do
//    begin
//      vBottom := vCellData.DrawItems[j].Rect.Bottom + vTop;
//      if vBottom > AHeight then  // ��ǰDItem����һҳ
//      begin
//        if ADItemMostBottom <
//          vCellData.DrawItems[j - 1].Rect.Bottom + vTop
//        then
//          ADItemMostBottom := vCellData.DrawItems[j - 1].Rect.Bottom + vTop;
//      end;
//    end;
//  end;
//end;

function THCTableItem.GetResizing: Boolean;
begin
  Result := (inherited GetResizing) or ActiveDataResizing;
end;

function THCTableItem.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function THCTableItem.GetSelectComplate: Boolean;
begin
  Result := // ���ж��Ƿ�ȫ����Ԫ��ѡ���ˣ���������ո���Ԫ���ѡ��״̬
    //(not ((RowCount = 1) and (FRows[0].ColCount = 1)))  // ����ֻ��һ����Ԫ��
    (FSelectCellRang.StartRow = 0)
    and (FSelectCellRang.StartCol = 0)
    and (FSelectCellRang.EndRow = FRows.Count - 1)
    and (FSelectCellRang.EndCol = FColWidths.Count - 1);
end;

function THCTableItem.GetTopLevelDataAt(const X, Y: Integer): THCCustomData;
var
  vResizeInfo: TResizeInfo;
  vRow, vCol: Integer;
  vCellPt: TPoint;
begin
  Result := nil;
  vResizeInfo := GetCellAt(X, Y, vRow, vCol);
  if (vRow < 0) or (vCol < 0) then Exit;
  vCellPt := GetCellPostion(vRow, vCol);
  Result := (Cells[vRow, vCol].CellData as THCCustomRichData).GetTopLevelDataAt(
    X - vCellPt.X - FCellHPadding, Y - vCellPt.Y - FCellVPadding)
end;

procedure THCTableItem.InitializeMouseInfo;
begin
  //FSelectCellRang.Initialize;  // ��ɱ���е����������ߴ��壨ʧȥ���㴥��KillFocus����������Ԫʱʧ��
  FMouseDownRow := -1;
  FMouseDownCol := -1;
  FMouseMoveRow := -1;
  FMouseMoveCol := -1;
  FMouseLBDowning := False;
end;

function THCTableItem.InsertColAfter(const ACount: Byte): Boolean;
var
  i, j, k: Integer;
  viDestRow, viDestCol: Integer;
  //vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;
  for i := 0 to ACount - 1 do
  begin
    FColWidths.Insert(FSelectCellRang.StartCol + 1, 50);
    for j := 0 to RowCount - 1 do
    begin
      vCell := THCTableCell.Create(FOwnerData.Style);
      vCell.Width := 50;
      vCell.RowSpan := FRows[j].Cols[FSelectCellRang.StartCol].RowSpan;
      vCell.ColSpan := FRows[j].Cols[FSelectCellRang.StartCol].ColSpan;

      if FRows[j].Cols[FSelectCellRang.StartCol].ColSpan <> 0 then  // �ϲ���Դ
      begin
        GetDestCell(j, FSelectCellRang.StartCol, viDestRow, viDestCol);
        vCell.CellData.Free;
        vCell.CellData := nil;
        vCell.ColSpan := FRows[j].Cols[FSelectCellRang.StartCol].ColSpan - 1;

        for k := 1 to Cells[viDestRow, viDestCol].ColSpan do  // Ŀ����п�� - �Ѿ����
          FRows[j].Cols[FSelectCellRang.StartCol + k].ColSpan := FRows[j].Cols[FSelectCellRang.StartCol + k].ColSpan - 1;  // ��Ŀ����Զ1
      end;
      FRows[j].Insert(FSelectCellRang.StartCol + 1, vCell);
    end;
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertColBefor(const ACount: Byte): Boolean;
var
  i, j, k: Integer;
  viDestRow, viDestCol: Integer;
  //vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;
  for i := 0 to ACount - 1 do
  begin
    for j := 0 to RowCount - 1 do
    begin
      vCell := THCTableCell.Create(FOwnerData.Style);
      vCell.Width := 50;
      vCell.RowSpan := FRows[j].Cols[FSelectCellRang.StartCol].RowSpan;
      vCell.ColSpan := FRows[j].Cols[FSelectCellRang.StartCol].ColSpan;

      if FRows[j].Cols[FSelectCellRang.StartCol].ColSpan < 0 then  // �ϲ���Դ
      begin
        GetDestCell(j, FSelectCellRang.StartCol, viDestRow, viDestCol);
        vCell.CellData.Free;
        vCell.CellData := nil;
        vCell.ColSpan := FRows[j].Cols[FSelectCellRang.StartCol].ColSpan;

        for k := 0 to Cells[viDestRow, viDestCol].ColSpan + FRows[j].Cols[FSelectCellRang.StartCol].ColSpan do  // Ŀ����п�� - �Ѿ����
          FRows[j].Cols[FSelectCellRang.StartCol + k].ColSpan := FRows[j].Cols[FSelectCellRang.StartCol + k].ColSpan - 1;  // ��Ŀ����Զ1
      end;
      FRows[j].Insert(FSelectCellRang.StartCol, vCell);
    end;
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertItem(const AItem: THCCustomItem): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.InsertItem(AItem);
end;

function THCTableItem.InsertRowAfter(const ACount: Byte): Boolean;
var
  i, j, k: Integer;
  viDestRow, viDestCol: Integer;
  vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;
  for i := 1 to ACount do
  begin
    vTableRow := TTableRow.Create(FOwnerData.Style, FColWidths.Count);

    for j := 0 to FColWidths.Count - 1 do
    begin
      vTableRow.Cols[j].Width := FColWidths[j];

      if FRows[FSelectCellRang.StartRow].Cols[j].RowSpan > 0 then  // �ںϲ���Ŀ�굥Ԫ�������
      begin
        // Ŀ�굥Ԫ������ĵ�Ԫ��
        vTableRow.Cols[j].CellData.Free;
        vTableRow.Cols[j].CellData := nil;
        vTableRow.Cols[j].RowSpan := -1;
        if FRows[FSelectCellRang.StartRow].Cols[j].ColSpan < 0 then
          vTableRow.Cols[j].ColSpan := FRows[FSelectCellRang.StartRow].Cols[j].ColSpan;

        for k := 1 to FRows[FSelectCellRang.StartRow].Cols[j].RowSpan do
          FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan := FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan - 1;

        FRows[FSelectCellRang.StartRow].Cols[j].RowSpan := FRows[FSelectCellRang.StartRow].Cols[j].RowSpan + 1;  // Ŀ�굥Ԫ���п����1
      end
      else
      if FRows[FSelectCellRang.StartRow].Cols[j].RowSpan < 0 then  // �ϲ�Դ��Ԫ����ҳ��
      begin
        vTableRow.Cols[j].CellData.Free;
        vTableRow.Cols[j].CellData := nil;

        for k := 0 to Cells[viDestRow, viDestCol].RowSpan + FRows[FSelectCellRang.StartRow].Cols[j].RowSpan do  // Ŀ����п�� - �Ѿ����
          FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan := FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan - 1;  // ��Ŀ����Զ1
        FRows[viDestRow].Cols[j].RowSpan := FRows[viDestRow].Cols[j].RowSpan + 1;  // Ŀ���а����ĺϲ�Դ����1
      end;
    end;

    FSelectCellRang.StartRow := FSelectCellRang.StartRow + 1;
    FRows.Insert(FSelectCellRang.StartRow, vTableRow);
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertRowBefor(const ACount: Byte): Boolean;
var
  i, j, k: Integer;
  viDestRow, viDestCol: Integer;
  vTableRow: TTableRow;
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell <> nil then
    vCell.CellData.InitializeField;

  for i := 0 to ACount - 1 do
  begin
    vTableRow := TTableRow.Create(FOwnerData.Style, FColWidths.Count);
    for j := 0 to FColWidths.Count - 1 do
    begin
      vTableRow.Cols[j].Width := FColWidths[j];

      if FRows[FSelectCellRang.StartRow].Cols[j].RowSpan < 0 then  // �ںϲ���Դ��Ԫ��ǰ�����
      begin
        GetDestCell(FSelectCellRang.StartRow, j, viDestRow, viDestCol);
        vTableRow.Cols[j].CellData.Free;
        vTableRow.Cols[j].CellData := nil;
        vTableRow.Cols[j].RowSpan := FRows[FSelectCellRang.StartRow].Cols[j].RowSpan;

        for k := 0 to Cells[viDestRow, viDestCol].RowSpan + FRows[FSelectCellRang.StartRow].Cols[j].RowSpan do  // Ŀ����п�� - �Ѿ����
          FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan := FRows[FSelectCellRang.StartRow + k].Cols[j].RowSpan - 1;  // ��Ŀ����Զ1
        FRows[viDestRow].Cols[j].RowSpan := FRows[viDestRow].Cols[j].RowSpan + 1;  // Ŀ���а����ĺϲ�Դ����1
      end;
    end;
    FRows.Insert(FSelectCellRang.StartRow, vTableRow);
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.InsertStream(AStream, AStyle, AFileVersion);
end;

function THCTableItem.InsertText(const AText: string): Boolean;
begin
  Result := False;
  inherited;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.InsertText(AText);
end;

procedure THCTableItem.MarkStyleUsed(const AMark: Boolean);
var
  vR, vC: Integer;
begin
  inherited;
  for vR := 0 to FRows.Count - 1 do
  begin
    for vC := 0 to FRows[vR].ColCount - 1 do
    begin
      if FRows[vR].Cols[vC].CellData <> nil then
        FRows[vR].Cols[vC].CellData.MarkStyleUsed(AMark);
    end;
  end;
end;

function THCTableItem.MergeCells(const AStartRow, AStartCol, AEndRow,
  AEndCol: Integer): Boolean;

  procedure DeleteEmptyRows(const ASRow, AERow: Cardinal);
  var
    vR, vC, vR1: Integer;
    vEmptyRow: Boolean;
  begin
    for vR := AERow downto ASRow do  // ������
    begin
      vEmptyRow := True;
      for vC := 0 to FRows[vR].ColCount - 1 do  // ��ǰ�и���
      begin
        if FRows[vR].Cols[vC].CellData <> nil then  // ����û�б��ϲ�����
        begin
          vEmptyRow := False;  // ���ǿ���
          Break;
        end;
      end;
      if vEmptyRow then  // ����
      begin
        for vR1 := 0 to vR - 1 do
        begin
          for vC := 0 to FRows[vR1].ColCount - 1 do
          begin
            if Cells[vR1, vC].RowSpan > 0 then
              Cells[vR1, vC].RowSpan := Cells[vR1, vC].RowSpan - 1;
          end;
        end;
        for vR1 := vR + 1 to FRows.Count - 1 do
        begin
          for vC := 0 to FRows[vR1].ColCount - 1 do
          begin
            if Cells[vR1, vC].RowSpan < 0 then
              Cells[vR1, vC].RowSpan := Cells[vR1, vC].RowSpan + 1;
          end;
        end;
        FRows.Delete(vR);  // ɾ����ǰ����
      end;
    end;
  end;

  procedure DeleteEmptyCols(const ASCol, AECol: Cardinal);
  var
    vR, vC, vC2: Integer;
    vEmptyCol: Boolean;
    vTableCell: THCTableCell;
  begin
    for vC := AECol downto ASCol do  // ѭ������
    begin
      vEmptyCol := True;
      for vR := 0 to RowCount - 1 do  // ѭ������
      begin
        if FRows[vR].Cols[vC].CellData <> nil then  // ĳ�еĵ�vC��û�б��ϲ�
        begin
          vEmptyCol := False;
          Break;
        end;
      end;
      if vEmptyCol then  // �ǿ���
      begin
        for vR := RowCount - 1 downto 0 do  // ѭ�����У�ɾ����Ӧ��
        begin
          for vC2 := 0 to vC - 1 do
          begin
            vTableCell := FRows[vR].Cols[vC2];
            if vC2 + vTableCell.ColSpan >= vC then
              vTableCell.ColSpan := vTableCell.ColSpan - 1;
          end;
          for vC2 := vC + 1 to FRows[vR].ColCount - 1 do
          begin
            vTableCell := FRows[vR].Cols[vC2];
            if vC2 + vTableCell.ColSpan < vC then
              vTableCell.ColSpan := vTableCell.ColSpan + 1;
          end;
          FRows[vR].Delete(vC);  // ɾ����
        end;
        FColWidths[vC - 1] := FColWidths[vC -1] + FBorderWidth + FColWidths[vC];
        FColWidths.Delete(vC);
      end;
    end;
  end;

var
  vR, vC, vR1, vC1, vRowSpan, vColSpan, vNewColSpan, vNewRowSpan: Integer;
begin
  Result := CellsCanMerge(AStartRow, AStartCol, AEndRow, AEndCol);
  if not Result then Exit;
  if AStartRow = AEndRow then  // ͬһ�кϲ���CellsCanMerge���жϺ���ͬһ�п϶���ͬ��
  begin
    for vC := AStartCol + 1 to AEndCol do  // �ϲ���
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        Cells[AStartRow, AStartCol].CellData.AddData(Cells[AStartRow, vC].CellData);
        Cells[AStartRow, AStartCol].ColSpan := Cells[AStartRow, AStartCol].ColSpan
          + Cells[AStartRow, vC].ColSpan + 1;

        {FRows[AStartRow].Cols[AStartCol].Width :=
          FRows[AStartRow].Cols[AStartCol].Width
          + FRows[AStartRow].Cols[vC].Width + FBorderWidth;}
        Cells[AStartRow, vC].CellData.Free;
        Cells[AStartRow, vC].CellData := nil;
        // ��¼���ϲ������(����20161109001����ʱ�������Ԫ��λ��)
        vNewColSpan := AStartCol - vC;
        vRowSpan := Cells[AStartRow, vC].RowSpan;  // Դ��Ԫ��ԭ���п��
        vColSpan := Cells[AStartRow, vC].ColSpan;  // Դ��Ԫ��ԭ���п��
        for vC1 := vC + 1 to vC + vColSpan do  // Դ��Ԫ����ΪĿ�굥Ԫ��ϲ���ͬ��Դ��Ԫ�������и����
          Cells[AStartRow, vC1].ColSpan := Cells[AStartRow, vC1].ColSpan + vNewColSpan;
        // Դ��Ԫ����ΪĿ�굥Ԫ��ϲ��Ĳ�ͬ��Դ��Ԫ�������и����
        for vR1 := AStartRow + 1 to AStartRow + vRowSpan do
        begin
          for vC1 := vC to vC + vColSpan do
            Cells[vR1, vC1].ColSpan := Cells[vR1, vC1].ColSpan + vNewColSpan;
        end;

        Cells[AStartRow, vC].ColSpan := vNewColSpan;
        Cells[AStartRow, vC].RowSpan := 0;
      end;
    end;
    DeleteEmptyCols(AStartCol + 1, AEndCol);
    Result := True;
  end
  else
  if AStartCol = AEndCol then  // ͬ�кϲ�
  begin
    for vR := AStartRow + 1 to AEndRow do  // �ϲ�����
    begin
      if FRows[vR].Cols[AStartCol].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[AStartCol].CellData);
        FRows[AStartRow].Cols[AStartCol].RowSpan := FRows[AStartRow].Cols[AStartCol].RowSpan
          + Cells[vR, AStartCol].RowSpan + 1;
        FRows[vR].Cols[AStartCol].CellData.Free;
        FRows[vR].Cols[AStartCol].CellData := nil;

        vNewRowSpan := AStartRow - vR;
        vRowSpan := Cells[vR, AStartCol].RowSpan;  // Դ��Ԫ��ԭ���п��
        vColSpan := Cells[vR, AStartCol].ColSpan;  // Դ��Ԫ��ԭ���п��
        for vR1 := vR + 1 to vR + vRowSpan do  // Դ��Ԫ����ΪĿ�굥Ԫ��ϲ���ͬ��Դ��Ԫ�������и����
          Cells[vR1, AStartCol].RowSpan := Cells[vR1, AStartCol].RowSpan + vNewRowSpan;
        // Դ��Ԫ����ΪĿ�굥Ԫ��ϲ��Ĳ�ͬ��Դ��Ԫ�������и����
        for vC1 := AStartCol + 1 to AStartCol + vColSpan do
        begin
          for vR1 := vR to vR + vRowSpan do
            Cells[vR1, vC1].RowSpan := Cells[vR1, vC1].RowSpan + vNewRowSpan;
        end;

        Cells[vR, AStartCol].RowSpan := vNewRowSpan;
        Cells[vR, AStartCol].ColSpan := 0;
      end;
    end;
    DeleteEmptyRows(AStartRow + 1, AEndRow);
    Result := True;
  end
  else  // ��ͬ�У���ͬ��
  begin
    // ��ʼ�и��кϲ�(2)
    for vC := AStartCol + 1 to AEndCol do
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[AStartRow].Cols[vC].CellData);
        FRows[AStartRow].Cols[AStartCol].ColSpan := FRows[AStartRow].Cols[AStartCol].ColSpan + 1;
        FRows[AStartRow].Cols[vC].CellData.Free;
        FRows[AStartRow].Cols[vC].CellData := nil;
        // ��¼���ϲ������(����20161109001����ʱ�������Ԫ��λ��)
        FRows[AStartRow].Cols[vC].ColSpan := AStartCol - vC;
      end;
    end;
    // ʣ���и��кϲ�
    for vR := AStartRow + 1 to AEndRow do  // ѭ����
    begin
      //vEmptyRow := True;
      for vC := AStartCol to AEndCol do
      begin
        if FRows[vR].Cols[vC].CellData <> nil then
        begin
          FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[vC].CellData);
          FRows[vR].Cols[vC].CellData.Free;
          FRows[vR].Cols[vC].CellData := nil;
          FRows[vR].Cols[vC].ColSpan := AStartCol - vC;
          FRows[vR].Cols[vC].RowSpan := AStartRow - vR;
          //vEmptyRow := False;
        end;
      end;
      //if not vEmptyRow then
        FRows[AStartRow].Cols[AStartCol].RowSpan := FRows[AStartRow].Cols[AStartCol].RowSpan + 1;
    end;
    DeleteEmptyRows(AStartRow + 1, AEndRow);
    // ɾ������
    DeleteEmptyCols(AStartCol + 1, AEndCol);

    Result := True;
  end;
end;

function THCTableItem.MergeSelectCells: Boolean;
begin
  if (FSelectCellRang.StartRow >= 0) and (FSelectCellRang.EndRow >= 0) then
  begin
    Result := MergeCells(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
      FSelectCellRang.EndRow, FSelectCellRang.EndCol);
    if Result then
    begin
      { ��ֹ�ϲ����п��л���б�ɾ����DisSelect����Խ�磬���Ժϲ���ֱ�Ӹ�ֵ������Ϣ }
      //Self.InitializeMouseInfo;  // �ϲ��󲻱���ѡ�е�Ԫ��
      FSelectCellRang.EndRow := -1;
      FSelectCellRang.EndCol := -1;
      Self.Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.InitializeField;
      DisSelect;
    end;
  end
  else
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MergeTableSelectCells
  else
    Result := False;
end;

function THCTableItem.CanDrag: Boolean;
begin
  Result := inherited CanDrag;
  if Result then
  begin
    if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
      Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectedCanDrag
    else
      Result := Self.IsSelectComplate or Self.IsSelectPart;
  end;
end;

function THCTableItem.CellsCanMerge(const AStartRow, AStartCol, AEndRow,
  AEndCol: Integer): Boolean;
begin
  if AStartRow = AEndRow then  // ͬһ��
    Result := AStartCol <> AEndCol  // ��ͬ��
  else  // ��ͬ��
  begin
    Result := (Cells[AStartRow, AStartCol].Width = Cells[AEndRow, AStartCol].Width)
      and (Cells[AStartRow, AEndCol].Width = Cells[AEndRow, AEndCol].Width);
  end;
end;

function THCTableItem.CellSelectComplate(const ARow, ACol: Integer): Boolean;
begin
  Result := False;
  if FRows[ARow].Cols[ACol].CellData = nil then Exit;

  if FSelectCellRang.SameRow then  // ͬһ��
    Result := (ARow = FSelectCellRang.StartRow)
      and (ACol >= FSelectCellRang.StartCol)
      and (ACol <= FSelectCellRang.EndCol)
  else
  if FSelectCellRang.SameCol then  // ͬһ��
    Result := (ACol = FSelectCellRang.StartCol)
      and (ARow >= FSelectCellRang.StartRow)
      and (ARow <= FSelectCellRang.EndRow)
  else  // ��ͬ�в�ͬ��
    Result := (ACol >= FSelectCellRang.StartCol)
      and (ACol <= FSelectCellRang.EndCol)
      and (ARow >= FSelectCellRang.StartRow)
      and (ARow <= FSelectCellRang.EndRow);
end;

procedure THCTableItem.CheckFormatPage(const ADrawItemRectTop, ADrawItemRectBottom,
  APageDataFmtTop, APageDataFmtBottom, AStartRowNo: Integer;
  var ABreakRow, AFmtOffset, ACellMaxInc: Integer);
var
  vRowDataFmtTop, vBreakRowBottom,
  vLastDFromRowBottom,  // ���һ��DItem�ײ������еײ��ľ���
  vDestCellDataFmtTop,  // ��Ԫ�����ݶ���(���ϲ���Ԫ���ҳʱ��Ŀ�굥Ԫ��Ϊ׼)
  vRowMergedHeight,  // ��ǰ������ϲ������и��ܺ�
  vH,  // ��ǰDItem����ƫ�ƶ��ٿ�����ʾ����һҳ����
  vCellInc,  // ��ǰ�з�ҳ�����ӵĸ߶�
  vMergeDestRow2,
  vDestRow, vDestCol  // �ϲ���Ŀ�굥Ԫ��
    :Integer;
  i, j, k: Integer;
  vCellData: THCTableCellData;
  vDItem: THCCustomDrawItem;
  vFirstLinePlace: Boolean;  // ����Ԫ��������һ�����ݿ��ڷ�ҳλ������������ʾ
  vRect: TRect;
  vCellCross: TCellCross;
  vCellCrosses: TObjectList<TCellCross>;
begin
  ABreakRow := 0;
  AFmtOffset := 0;
  ACellMaxInc := 0;  // vCellInc�����ֵ����ʾ��ǰ�и���Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�����ߵ�

  { �õ���ʼ�е�Fmt��ʼλ�� }
  vRowDataFmtTop := ADrawItemRectTop + FBorderWidth;  // ��1������Y�������ʼλ��
  for i := 0 to AStartRowNo - 1 do
    vRowDataFmtTop := vRowDataFmtTop + FRows[i].FmtOffset + FRows[i].Height + FBorderWidth;  // ��i�����ݽ���λ��

  { ����ʼ�п�ʼ��⵱ǰҳ�Ƿ��ܷ����� }
  i := AStartRowNo;
  while i < RowCount do  // ����ÿһ��
  begin
    vBreakRowBottom := vRowDataFmtTop + FRows[i].FmtOffset + FRows[i].Height + FBorderWidth;  // ��i�����ݽ���λ��
    if vBreakRowBottom > APageDataFmtBottom then  // ��i�����ݽ���λ�ó���ҳ���ݽ���λ�ã��Ų���
    begin
      ABreakRow := i;  // ��i����Ҫ�����ҳ
      //vH := APageDataFmtBottom - vRowDataFmtTop;  // ���ڷ�ҳʱ�����ҳ�ײ��ж��ٿռ����ڷŵ�i��(���ڴ�����Щ��Ԫ�������һ�����������ڵ�ǰҳ)
      Break;
    end;
    vRowDataFmtTop := vBreakRowBottom;  // ��i��������ʼλ��
    Inc(i);
  end;

//  if ABreakRow = 0 then  // ����ڵ�ǰҳһ��Ҳ�Ų��£����������ʵ�ֱ���һ���ڵ�ǰҳ��ʾ����ʱ��������
//  begin
//    //if vRowDataFmtTop < APageDataFmtTop then  // �����жϣ�������ڵ�2ҳ��1��ʱ��׼ȷ ��ǰҳ��ʼItem���ǵ�ǰ��񣨱���ǵ�ǰҳ��һ��Item���ͷ�ҳ��ͬ����ҳ��ȻҲ�ǵ�һ������������ʼλ�ò����ڷ�ҳ���ҳ��
//    begin
//      AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
//      Exit;
//    end;
//  end;

  { �Ų��£����жϷ�ҳλ�� }
  { -��ҳλ���Ǹ���Ԫ���һ�еģ������Ƿ���ڿ������ڷ�ҳλ�����������- }
  vFirstLinePlace := True;
  //vH := Max(APageDataFmtTop, vRowDataFmtTop);  // �жϵ�ǰ�з�ҳʱ�Ķ���λ��(��һ���ж�ʱ��vRowDataFmtTop��������ҳ��APageDataFmtTop)
  //vCheckTop := vH - vRowDataFmtTop;  // ����λ����Ե�Ԫ�񶥲�λ��
  //vCheckBottom := vCheckTop + APageDataFmtBottom - vH;  // �ײ�λ����Ե�Ԫ��ײ�λ��
  vCellInc := 0;  // �и�����Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�

  vCellCrosses := TObjectList<TCellCross>.Create;
  try

    {$REGION '�ȼ���û�кϲ��ĵ�Ԫ����ע�͵�'}
//    // �ȼ���û�кϲ��ĵ�Ԫ�񣬷�ֹ 201703241150.bmp ������µ�2�е�2�е�һ�����ڵ�1ҳ���£������ܼ���������˵�2�еĸ߶�
//    for i := 0 to FRows[ABreakRow].ColCount - 1 do
//    begin
//      if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
//        Continue;
//      if FRows[ABreakRow].Cols[i].RowSpan < 0 then  // �ȴ���û�кϲ��в�����
//        Continue;
//
//      vCellData := FRows[ABreakRow].Cols[i].CellData;
//      // ����ͼ 2016-4-15_1.bmp ��2�е�2�е����
//      vLastDFromRowBottom :=  // ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
//        FRows[ABreakRow].Cols[i].Height - vCellData.Height;
//      vRealCellDataFmtTop := vRowDataFmtTop;
//
//      vCellCross := TCellCross.Create;
//      vCellCross.Col := i;
//
//      for j := 0 to vCellData.DrawItems.Count - 1 do
//      begin
//        vDItem := vCellData.DrawItems[j];
//        if not vDItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
//          Continue;
//
//        if j <> vCellData.DrawItems.Count - 1 then  // ���һ�е�DItemҪ���߿�����
//          vBottomBorder := 0
//        else
//          vBottomBorder := FBorderWidth;
//
//        if vRealCellDataFmtTop + vDItem.Rect.Bottom + vBottomBorder > APageDataFmtBottom then // ��ǰDItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
//        begin
//          if j = 0 then
//            vFirstLinePlace := False;
//
//          // �����ҳ��DItem����ƫ�ƶ��ٿ�����һҳȫ��ʾ��DItem
//          vH := APageDataFmtBottom - (vRealCellDataFmtTop + vDItem.Rect.Top{ + vBottomBorder}) // ҳData�ײ� - ��ǰDItem��ҳ�����λ��
//            + FBorderWidth;  // ���ӷ�ҳ����һҳԤ�����߿�
//          vCellInc := vH - vLastDFromRowBottom;  // ʵ�����ӵĸ߶� = ��ҳ����ƫ�Ƶľ��� - ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
//
//          vCellCross.DItemNo := j;
//          vCellCross.VOffset := vH;
//
//          Break;
//        end;
//      end;
//      if ACellMaxInc < vCellInc then
//        ACellMaxInc := vCellInc;  // ��¼����Ԫ���з�ҳ����ƫ�Ƶ��������
//
//      vCellCrosses.Add(vCellCross);
//    end;
    {$ENDREGION}

    {$REGION '�ټ������кϲ��ĵ�Ԫ��'}
    for i := 0 to FRows[ABreakRow].ColCount - 1 do  // �������е�Ԫ����DItem������ƫ��vH
    begin
      if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
        Continue;

      GetMergeDest(ABreakRow, i, vDestRow, vDestCol);
      vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
      // ����ͼ 2016-4-15_1.bmp ��2�е�2�е����
      vLastDFromRowBottom :=  // ԭ���һ��DrawItem�ײ������еײ��Ŀհ׾���
        FRows[vDestRow].Cols[vDestCol].Height - vCellData.Height - FCellVPadding;
      vDestCellDataFmtTop := vRowDataFmtTop;
      while vDestRow < ABreakRow do  // �ָ���Ŀ�굥Ԫ��
      begin
        vDestCellDataFmtTop := vDestCellDataFmtTop - FBorderWidth - FRows[vDestRow].Height;
        Inc(vDestRow);
      end;

      vCellCross := TCellCross.Create;
      vCellCross.Col := i;

      for j := 0 to vCellData.DrawItems.Count - 1 do
      begin
        vDItem := vCellData.DrawItems[j];
        if not vDItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
          Continue;

        vRect := vDItem.Rect;
        if vDestCellDataFmtTop + vRect.Bottom + FBorderWidth + FCellVPadding > APageDataFmtBottom then // ��ǰDItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
        begin
          if j = 0 then
            vFirstLinePlace := False;

          // �����ҳ��DItem����ƫ�ƶ��ٿ�����һҳȫ��ʾ��DItem
          vH := APageDataFmtBottom - (vDestCellDataFmtTop + vRect.Top{ + vBottomBorder}) // ҳData�ײ� - ��ǰDItem��ҳ�����λ��
            + FBorderWidth;  // ���ӷ�ҳ����һҳԤ�����߿�
          vCellInc := vH - vLastDFromRowBottom;  // ʵ�����ӵĸ߶� = ��ҳ����ƫ�Ƶľ��� - ԭ���һ��DItem�ײ������еײ��Ŀհ׾���

          vCellCross.DItemNo := j;
          vCellCross.VOffset := vH;
          vCellCross.MergeSrc := FRows[ABreakRow].Cols[i].RowSpan < 0;

          Break;
        end;
      end;
      if ACellMaxInc < vCellInc then
        ACellMaxInc := vCellInc;  // ��¼����Ԫ���з�ҳ����ƫ�Ƶ��������

      vCellCrosses.Add(vCellCross);
    end;
    {$ENDREGION}

    {$REGION '�ɷ���2017-1-15��ע�͵�'}

  //  if not vFirstLinePlace then  // ����ĳ��Ԫ���ڷ�ҳ����һ�о���Ҫ�ŵ���һҳ(���д���һҳ��ʼ)
  //  begin
  //    vH := vCheckBottom - vCheckTop;  // ���������ƶ�����һҳ
  //    for i := 0 to FRows[ABreakRow].ColCount - 1 do  // �������е�Ԫ����DItem������ƫ��vH
  //    begin
  //      if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
  //        Continue;
  //
  //      GetMergeDest(ABreakRow, i, vMergeDestRow, vMergeDestCol);
  //      vCellData := FRows[vMergeDestRow].Cols[vMergeDestCol].CellData;
  //      for j := 0 to vCellData.DrawItems.Count - 1 do  // ����ƫ��vH
  //        OffsetRect(vCellData.DrawItems[j].Rect, 0, vH);
  //    end;
  //    ACellMaxInc := vH;
  //  end
  //  else  // ÿһ�ж����Է��µ�һ�����ݣ�����Ԫ�񲿷������ڵ�ǰҳ���������ݴ���һҳ��ʼ
  //  begin
  //    // ��ǰ��ҳ�и���Ԫ�����ҳλ��
  //    vCellInc := 0;  // �и�����Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�
  //    ACellMaxInc := 0;  // vCellInc�����ֵ����ʾ��ǰ��Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�
  //
  //    { ����û�з����ϲ���ϲ�Ŀ�굥Ԫ���ҳ }
  //    for i := 0 to FRows[ABreakRow].ColCount - 1 do  // �������У��жϷ�ҳλ��
  //    begin
  //      if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
  //        Continue;
  //
  //      vRealCellDataFmtTop := vRowDataFmtTop;
  //
  //      GetMergeDest(ABreakRow, i, vMergeDestRow, vMergeDestCol);
  //      vCellData := FRows[vMergeDestRow].Cols[vMergeDestCol].CellData;
  //      // ����ͼ 2016-4-15_1.bmp ��2�е�2�е����
  //      vLastDFromRowBottom :=  // ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
  //        FRows[vMergeDestRow].Cols[vMergeDestCol].Height - vCellData.Height;
  //      while vMergeDestRow < ABreakRow do  // �ָ���Ŀ�굥Ԫ��
  //      begin
  //        vRealCellDataFmtTop := vRealCellDataFmtTop - FBorderWidth - FRows[vMergeDestRow].Height;
  //        Inc(vMergeDestRow);
  //      end;
  //
  //      for j := 0 to vCellData.DrawItems.Count - 1 do
  //      begin
  //        vDItem := vCellData.DrawItems[j];
  //        if not vDItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
  //          Continue;
  //        if vRealCellDataFmtTop + vDItem.Rect.Bottom > APageDataFmtBottom then // ��ǰDItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
  //        begin
  //          // �����ҳ��DItem����ƫ�ƶ��ٿ�����һҳȫ��ʾ��DItem
  //          vH := APageDataFmtBottom - (vRealCellDataFmtTop + vDItem.Rect.Top); // ҳData�ײ� - ��ǰDItem��ҳ�����λ��
  //            //+ FBorderWidth;  // ��ҳ����һҳԤ�����߿�
  //          // �ӵ�ǰDItem��ʼ������ƫ�Ƶ���һҳ
  //          for k := j to vCellData.DrawItems.Count - 1 do
  //            OffsetRect(vCellData.DrawItems[k].Rect, 0, vH);
  //
  //          vCellInc := vH - vLastDFromRowBottom;  // ʵ�����ӵĸ߶� = ��ҳ����ƫ�Ƶľ��� - ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
  //          Break;
  //        end;
  //      end;
  //      if ACellMaxInc < vCellInc then
  //        ACellMaxInc := vCellInc;  // ��¼����Ԫ���з�ҳ����ƫ�Ƶ��������
  //    end;

  //    for i := 0 to FRows[ABreakRow].ColCount - 1 do  // �����У��жϷ�ҳλ��
  //    begin
  //      vRealCellDataFmtTop := vRowDataFmtTop;
  //      vRowMergedHeight := 0;
  //      if FRows[ABreakRow].Cols[i].CellData = nil then  // ���ϲ�
  //      begin
  //        if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
  //          Continue;
  //
  //        GetMergeDest(ABreakRow, i, vMergeDestRow, vMergeDestCol);
  //        vCellData := Cells[vMergeDestRow, vMergeDestCol].CellData;
  //        while vMergeDestRow < ABreakRow do
  //        begin
  //          vRowMergedHeight := vRowMergedHeight + FRows[vMergeDestRow].Height + FBorderWidth;
  //          Inc(vMergeDestRow);
  //        end;
  //        vRealCellDataFmtTop := vRealCellDataFmtTop - vRowMergedHeight;
  //      end
  //      else  // û�б��ϲ�
  //      begin
  //        vCellData := FRows[ABreakRow].Cols[i].CellData;
  //      end;
  //
  //      for j := 0 to vCellData.DrawItems.Count - 1 do
  //      begin
  //        vDItem := vCellData.DrawItems[j];
  //        if not vDItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
  //          Continue;
  //        if vRealCellDataFmtTop + vDItem.Rect.Bottom > APageDataFmtBottom then // ��ǰDItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
  //        begin
  //          // ��������ƫ�ƶ��ٿ�����һҳȫ��ʾ��DItem
  //          vH := APageDataFmtBottom - (vRealCellDataFmtTop + vDItem.Rect.Top); // ҳData�ײ� - ��ǰDItem��ҳ�����λ��
  //            //+ FBorderWidth;  // ��ҳ����һҳԤ�����߿�
  //          // ����ͼ 2016-4-15_1.bmp ��2�е�2�е����
  //          vLastDFromRowBottom :=  // ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
  //            FRows[ABreakRow].Height + vRowMergedHeight - vCellData.LastDItem.Rect.Bottom;
  //          { TODO : DItem�����е�һ��ʱ����ǰ��ĸ�DItem�����д�ֱ���뷽ʽ��ͬ�Ƿ�ҲҪ����ƫ�� }
  //          // Ŀǰ�����Ǵӵ�ǰDItem��������һ�еĸ�DItem������ƫ��
  //          for k := j to vCellData.DrawItems.Count - 1 do
  //            OffsetRect(vCellData.DrawItems[k].Rect, 0, vH);
  //
  //          vCellInc := vH - vLastDFromRowBottom;  // ʵ�����ӵĸ߶� = ��ҳ����ƫ�Ƶľ��� - ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
  //          Break;
  //        end{
  //        else
  //          vCellData.DrawItems[j].FmtTopOffset := 0};
  //      end;
  //      if ACellMaxInc < vCellInc then
  //        ACellMaxInc := vCellInc;  // ��¼����Ԫ���з�ҳ����ƫ�Ƶ��������
  //    end;
    {$ENDREGION}

    if ACellMaxInc > 0 then  // ��ҳ�и���Ϊ��ҳ�������ӵ������
    begin
      if not vFirstLinePlace then  // ĳ��Ԫ���һ�о��ڵ�ǰҳ�Ų����ˣ�����ҳ��������Ҫ���Ƶ���һҳ
      begin
        if ABreakRow = 0 then
        begin
          AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
          ACellMaxInc := 0;  // ��������ƫ��ʱ���ʹ����˵�һ�е�����ƫ�ƣ�����˵��һ�е�FmtOffset��Զ��0����Ϊ��������ƫ�Ƶ��������жϵ�һ��
          Exit;
        end;

        FRows[ABreakRow].FmtOffset := ACellMaxInc;  // �������ƣ���ͨ��Ԫ���ҳ���ӵ�ƫ�����ݴ��е�ƫ�ƴ�����
        // �кϲ�Դ��Ԫ����Ҫ�����Ŀ�굽�ˣ����������Ʒ�ҳ�е� ��һ�е� �ײ�����
        for i := 0 to vCellCrosses.Count - 1 do
        begin
          if vCellCrosses[i].MergeSrc then  // �ϲ�Դ
          begin
            GetMergeDest(ABreakRow, vCellCrosses[i].Col, vDestRow, vDestCol);
            vH := vDestRow + FRows[vDestRow].Cols[vDestCol].RowSpan;  // �ϲ����������������
            vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
            //vLastDFromRowBottom :=  // ԭ���һ��DItem�ײ������еײ��Ŀհ׾���
            //  FRows[vDestRow].Cols[vDestCol].Height - vCellData.Height - FCellVPadding;
            vDestCellDataFmtTop := vRowDataFmtTop;
            vMergeDestRow2 := vDestRow;
            while vMergeDestRow2 < ABreakRow do  // �ָ���Ŀ�굥Ԫ��
            begin
              vDestCellDataFmtTop := vDestCellDataFmtTop - FBorderWidth - FRows[vMergeDestRow2].Height;
              Inc(vMergeDestRow2);
            end;

            for j := 0 to vCellData.DrawItems.Count - 1 do
            begin
              vDItem := vCellData.DrawItems[j];
              vRect := vDItem.Rect;
              if j = vCellData.DrawItems.Count - 1 then
                vRect.Bottom := vRect.Bottom + FCellVPadding;
              if not vDItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
                Continue;
              if vDestCellDataFmtTop + vRect.Bottom > vRowDataFmtTop then  // ��ǰDItem�������������е���һ�еײ���
              begin
                vCellInc := vRowDataFmtTop - vDestCellDataFmtTop - vDItem.Rect.Top + FCellVPadding;// + FRows[ABreakRow].FmtOffset;
                for k := j to vCellData.DrawItems.Count - 1 do  // ������һ�еײ���ȫ������ȥ
                  OffsetRect(vCellData.DrawItems[k].Rect, 0, vCellInc);

                FRows[vH].Height := FRows[vH].Height + vCellInc;// - FRows[vH].FmtOffset;

                if ACellMaxInc < vCellInc then
                  ACellMaxInc := vCellInc;
                Break;
              end;
            end;

            FRows[vDestRow].Cols[vDestCol].Height := FRows[vDestRow].Cols[vDestCol].Height + ACellMaxInc;
          end;
        end;
      end
      else  // ����Ҫ���ж����Ƶ���һҳ
      begin
        for i := 0 to vCellCrosses.Count - 1 do  // �������е�Ԫ����DItem������ƫ��vH
        begin
          //if FRows[ABreakRow].Cols[vCellCrosses[i].Col].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
          //  Continue;
          if vCellCrosses[i].DItemNo < 0 then  // ����Ҫƫ��
            Continue;
          GetMergeDest(ABreakRow, vCellCrosses[i].Col, vDestRow, vDestCol);
          vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
          for j := vCellCrosses[i].DItemNo to vCellData.DrawItems.Count - 1 do
            OffsetRect(vCellData.DrawItems[j].Rect, 0, vCellCrosses[i].VOffset);
        end;

        FRows[ABreakRow].Height := FRows[ABreakRow].Height + ACellMaxInc;  // �ۼӱ��Ϊ�˿統ǰҳ�������ӵĸ߶�
        for i := 0 to FRows[ABreakRow].ColCount - 1 do  // ����ǰ�зֵ�ǰҳ������Ӱ�쵽����ص�Ԫ���Ա���һҳ��ҳʱ����
        begin
          if Cells[ABreakRow, i].ColSpan < 0 then
            Continue;

          GetMergeDest(ABreakRow, i, vDestRow, vDestCol);
          Cells[vDestRow, vDestCol].Height := Cells[vDestRow, vDestCol].Height + ACellMaxInc;
        end;
      end;
    end;
  finally
    FreeAndNil(vCellCrosses);
  end;
end;

function THCTableItem.CoordInSelect(const X, Y: Integer): Boolean;
var
  vCellPt: TPoint;
  vCellData: THCTableCellData;
  vX, vY, vItemNo, vDrawItemNo, vOffset, vRow, vCol: Integer;
  vRestrain: Boolean;
  vResizeInfo: TResizeInfo;
begin
  Result := inherited CoordInSelect(X, Y);  // ��ѡ������RectItem������(���Թ���)
  if Result then
  begin
    vResizeInfo := GetCellAt(X, Y, vRow, vCol);  // ���괦��Ϣ
    Result := vResizeInfo.TableSite = TTableSite.tsCell;  // ���괦�ڵ�Ԫ���в��ڱ߿���
    if Result then  // �ڵ�Ԫ���У��жϵ�Ԫ���Ƿ���ѡ�з�Χ��
    begin
      if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
      begin
        if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
        begin
          Result := (vRow >= FSelectCellRang.StartRow)
                and (vRow <= FSelectCellRang.EndRow)
                and (vCol >= FSelectCellRang.StartCol)
                and (vCol <= FSelectCellRang.EndCol)
        end
        else  // ��ѡ������У��ж��Ƿ��ڵ�ǰ��Ԫ���ѡ����
        begin
          vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
          if vCellData.SelectExists then
          begin
            vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
            vX := X - vCellPt.X - FCellHPadding;
            vY := Y - vCellPt.Y - FCellVPadding;
            vCellData.GetItemAt(vX, vY, vItemNo, vOffset, vDrawItemNo, vRestrain);

            Result := vCellData.CoordInSelect(vX, vY, vItemNo, vOffset, vRestrain);
          end;
        end;
      end;
    end;

    {if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
    begin
      if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
      begin
        vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
        vSelRect.TopLeft := vCellPt;
        vCellPt := GetCellPostion(FSelectCellRang.EndRow, FSelectCellRang.EndCol);
        vSelRect.Right := vCellPt.X + FColWidths[FSelectCellRang.EndCol];
        vSelRect.Bottom := vCellPt.Y + FRows[FSelectCellRang.EndRow].Height;
        Result := PtInRect(vSelRect, Point(X, Y));
      end
      else  // ��ѡ������У��жϵ�ǰ��Ԫ���Ƿ���ѡ��
      begin
        vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
        if vCellData.SelectExists then
        begin
          vCellPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
          vX := X - vCellPt.X - FCellHPadding;
          vY := Y - vCellPt.Y - FCellVPadding;
          vCellData.GetItemAt(vX, vY, vItemNo, vOffset, vDrawItemNo, vRestrain);

          Result := (not vRestrain) and vCellData.CoordInSelect(vX, vY, vItemNo, vOffset);
        end;
      end;
    end;}
  end;
end;

procedure THCTableItem.SaveSelectToStream(const AStream: TStream);
var
  vCellData: THCCustomData;
begin
  if Self.IsSelectComplate then  // ȫѡ����
    raise Exception.Create('����ѡ�����ݳ������Ӧ�����ڲ�����ȫѡ�еı��棡')
  else
  begin
    vCellData := GetActiveData;
    if vCellData <> nil then
      vCellData.SaveSelectToStream(AStream);
  end;
end;

procedure THCTableItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
var
  i, vR, vC: Integer;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  AStream.WriteBuffer(FBorderVisible, SizeOf(FBorderVisible));
  AStream.WriteBuffer(FRows.Count, SizeOf(FRows.Count));  // ����
  AStream.WriteBuffer(FColWidths.Count, SizeOf(FColWidths.Count));  // ����

  for i := 0 to FColWidths.Count - 1 do  // ���б�׼���
  begin
    vC := FColWidths[i];
    AStream.WriteBuffer(vC, SizeOf(vC));
  end;

  for vR := 0 to FRows.Count - 1 do  // ��������
  begin
    AStream.WriteBuffer(FRows[vR].AutoHeight, SizeOf(Boolean));
    if not FRows[vR].AutoHeight then
      AStream.WriteBuffer(FRows[vR].Height, SizeOf(Integer));
    for vC := 0 to FRows[vR].ColCount - 1 do  // ��������
      FRows[vR].Cols[vC].SaveToStream(AStream);
  end;
end;

procedure THCTableItem.SelectAll;
begin
  FSelectCellRang.StartRow := 0;
  FSelectCellRang.StartCol := 0;
  FSelectCellRang.EndRow := RowCount - 1;
  FSelectCellRang.EndCol := FRows[FSelectCellRang.EndRow].ColCount - 1;
end;

function THCTableItem.SelectExists: Boolean;
begin
  Result := False;
  if Self.IsSelectComplate then
    Result := True
  else
  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
      Result := True
    else  // ��ѡ������У��жϵ�ǰ��Ԫ���Ƿ���ѡ��
      Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectExists;
  end;

//  Result := (FSelectCellRang.StartRow >= 0) and (FSelectCellRang.EndRow >= 0);  // ����ѡ����ʼ�ͽ�����
//  if Result then
//  begin
//    if FSelectCellRang.SameCell then  // ѡ����ͬһ����Ԫ���У��ɵ�Ԫ������Ƿ���ѡ������
//      Result := CellSelectComplate(FSelectCellRang.StartRow, FSelectCellRang.StartCol)
//        or Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectExists;
//  end;
end;

procedure THCTableItem.SetActive(const Value: Boolean);
var
  vCell: THCTableCell;
begin
  if Self.Active <> Value then
  begin
    vCell := GetEditCell;
    if (vCell <> nil) and (vCell.CellData <> nil) then
      vCell.CellData.Active := Value;
    if not Value then
      Self.InitializeMouseInfo;

    inherited SetActive(Value);
  end;
end;

procedure THCTableItem.SetResizing(const Value: Boolean);
begin
  inherited SetResizing(Value);
end;

procedure THCTableItem.SelectComplate;
var
  vRow, vCol: Integer;
begin
  inherited SelectComplate;

  FSelectCellRang.StartRow := 0;
  FSelectCellRang.StartCol := 0;
  FSelectCellRang.EndRow := Self.RowCount - 1;
  FSelectCellRang.EndCol := FColWidths.Count - 1;

  for vRow := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
  begin
    for vCol := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
    begin
      if FRows[vRow].Cols[vCol].CellData <> nil then
        FRows[vRow].Cols[vCol].CellData.SelectAll;
    end;
  end;
end;

procedure THCTableItem.TraverseItem(const ATraverse: TItemTraverse);
var
  vR, vC: Integer;
begin
  for vR := 0 to FRows.Count - 1 do
  begin
    if ATraverse.Stop then Break;

    for vC := 0 to FColWidths.Count - 1 do
    begin
      if ATraverse.Stop then Break;

      if Cells[vR, vC].CellData <> nil then
        Cells[vR, vC].CellData.TraverseItem(ATraverse);
    end;
  end;
end;

function THCTableItem.WantKeyDown(const Key: Word;
  const Shift: TShiftState): Boolean;
begin
  Result := True;
end;

function THCTableItem.ActiveDataResizing: Boolean;
begin
  Result := False;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectedResizing
end;

procedure THCTableItem.ApplySelectParaStyle(const AStyle: THCStyle;
  const AMatchStyle: TParaMatch);
var
  vR, vC: Integer;
begin
  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    if FSelectCellRang.EndRow >= 0 then  // ��ѡ������У�˵��ѡ�в���ͬһ��Ԫ��
    begin
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        { TODO -jingtong : ����Ԫ��SelectComplateʱ������ȫ��Ӧ����ʽ }
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
          Cells[vR, vC].CellData.ApplySelectParaStyle(AMatchStyle);
      end;
    end
    else  // ��ͬһ��Ԫ��
      GetEditCell.CellData.ApplySelectParaStyle(AMatchStyle);
  end
  else
    Self.ParaNo := AMatchStyle.GetMatchParaNo(FOwnerData.Style, Self.ParaNo);
end;

function THCTableItem.ApplySelectTextStyle(const AStyle: THCStyle;
  const AMatchStyle: TStyleMatch): Integer;
var
  vR, vC: Integer;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    GetEditCell.CellData.ApplySelectTextStyle(AMatchStyle)
  else
  if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
  begin
    for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
    begin
      { TODO -jingtong : ����Ԫ��SelectComplateʱ������ȫ��Ӧ����ʽ }
      for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        Cells[vR, vC].CellData.ApplySelectTextStyle(AMatchStyle);
    end;
  end;
end;

function THCTableItem.GetActiveData: THCCustomData;
var
  vCell: THCTableCell;
begin
  Result := nil;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.GetTopLevelData;
end;

function THCTableItem.GetActiveDrawItem: THCCustomDrawItem;
var
  vCellData: THCTableCellData;
begin
  Result := nil;
  vCellData := GetActiveData as THCTableCellData;
  if vCellData <> nil then
    Result := vCellData.GetActiveDrawItem;
end;

function THCTableItem.GetActiveDrawItemCoord: TPoint;
var
  vCell: THCTableCell;
  vPt: TPoint;
begin
  Result := Point(0, 0);
  vCell := GetEditCell;
  if vCell <> nil then
  begin
    Result := vCell.CellData.GetActiveDrawItemCoord;
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Result.X := Result.X + vPt.X + FCellHPadding;
    Result.Y := Result.Y + vPt.Y + FCellVPadding;
  end;
end;

function THCTableItem.GetActiveItem: THCCustomItem;
var
  vCell: THCTableCell;
begin
  Result := Self;
  vCell := GetEditCell;
  if vCell <> nil then
    Result := vCell.CellData.GetActiveItem;
end;

procedure THCTableItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
var
  vRow, vCol: Integer;
  vPos: TPoint;
  vCaretCell: THCTableCell;
begin
  if FOwnerData.Style.UpdateInfo.Draging then
  begin
    vRow := FMouseMoveRow;
    vCol := FMouseMoveCol;
  end
  else
  begin
    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;
  end;

  if vRow < 0 then
  begin
    ACaretInfo.Visible := False;
    Exit;
  end
  else
    vCaretCell := Cells[vRow, vCol];

  if FOwnerData.Style.UpdateInfo.Draging then
  begin
    if (vCaretCell.CellData.MouseMoveItemNo < 0)
      or (vCaretCell.CellData.MouseMoveItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;  
    vCaretCell.CellData.GetCaretInfo(vCaretCell.CellData.MouseMoveItemNo,
      vCaretCell.CellData.MouseMoveItemOffset, ACaretInfo)  
  end
  else
  begin
    if (vCaretCell.CellData.SelectInfo.StartItemNo < 0)
      or (vCaretCell.CellData.SelectInfo.StartItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;
    vCaretCell.CellData.GetCaretInfo(vCaretCell.CellData.SelectInfo.StartItemNo,
      vCaretCell.CellData.SelectInfo.StartItemOffset, ACaretInfo);
  end;

  vPos := GetCellPostion(vRow, vCol);
  ACaretInfo.X := vPos.X + ACaretInfo.X + FCellHPadding;
  ACaretInfo.Y := vPos.Y + ACaretInfo.Y + FCellVPadding;
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
  Result := (FStartRow >= 0) and (FEndRow >= 0);  // ��ʱû���õ��˷���
end;

{ TCellCross }

constructor TCellCross.Create;
begin
  inherited;
  Col := -1;
  DItemNo := -1;
  VOffset := 0;
  MergeSrc := False;
end;

{ TTableRows }

procedure TTableRows.Notify(const Value: TTableRow;
  Action: TCollectionNotification);
begin
  inherited;
  if Action = TCollectionNotification.cnAdded then
  begin
    if Assigned(FOnRowAdd) then
      FOnRowAdd(Value);
  end;
end;

end.
