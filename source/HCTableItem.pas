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
  Classes, SysUtils, Types, Graphics, Controls, Generics.Collections, HCDrawItem,
  HCRectItem, HCTableRow, HCCustomData, HCCustomRichData, HCTableCell, HCTableCellData,
  HCRichData, HCTextStyle, HCCommon, HCParaStyle, HCStyleMatch, HCItem, HCStyle,
  HCList, HCUndo;

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

  //PResizeInfo = ^TResizeInfo;
  TResizeInfo = record  // ������Ϣ
    TableSite: TTableSite;
    DestX, DestY: Integer;
  end;

  TPageBreak = class  // ��ҳ��Ϣ
    PageIndex, Row, BreakSeat, BreakBottom: Integer;
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

  TOutsideInfo = record  // ���������Ϣ
    Row: Integer;  // ����λ�ô���Ӧ����
    Leftside: Boolean;  // True����� False���ұ�
  end;

  THCTableItem = class(THCResizeRectItem)
  private
    FBorderWidth,  // �߿���
    FCellHPadding,  // ��Ԫ������ˮƽƫ��
    FCellVPadding   // ��Ԫ�����ݴ�ֱƫ��(���ܴ�����͵�DrawItem�߶ȣ������Ӱ���ҳ)
      : Byte;  // ��Ԫ�����ݺ͵�Ԫ��߿�ľ���

    FOutsideInfo: TOutsideInfo;  // ����ڱ�����ұ�ʱ��Ӧ������Ϣ

    FMouseDownRow, FMouseDownCol,
    FMouseMoveRow, FMouseMoveCol,
    FMouseDownX, FMouseDownY: Integer;

    FResizeInfo: TResizeInfo;

    FBorderVisible, FMouseLBDowning, FSelecting, FDraging, FOutSelectInto,
      FEnableUndo: Boolean;

    { ѡ����Ϣ(ֻ��ѡ����ʼ�ͽ����ж�>=0��˵����ѡ�ж����Ԫ��
     �ڵ�����Ԫ����ѡ��ʱ�����С�����ϢΪ-1 }
    FSelectCellRang: TSelectCellRang;
    FBorderColor: TColor;  // �߿���ɫ
    FRows: TTableRows;  // ��
    FColWidths: TList<Integer>;  // ��¼���п��(���߿򡢺�FCellHPadding * 2)�������кϲ��ĵ�Ԫ���ȡ�Լ�ˮƽ��ʼ����λ��
    FPageBreaks: TObjectList<TPageBreak>;  // ��¼���з�ҳʱ����Ϣ

    procedure InitializeMouseInfo;

    function DoCellDataGetRootData: THCCustomData;
    function DoCellDataGetEnableUndo: Boolean;

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

    procedure DblClick(const X, Y: Integer); override;
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
    function IsSelectComplateTheory: Boolean; override;
    function SelectExists: Boolean; override;
    procedure TraverseItem(const ATraverse: TItemTraverse); override;
    //

    procedure CheckFormatPageBreakBefor; override;

    /// <summary> ����ҳ </summary>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Top</param>
    /// <param name="ADrawItemRectTop">����Ӧ��DrawItem��Rect.Bottom</param>
    /// <param name="APageDataFmtTop">��ǰҳ�����ݶ���λ��</param>
    /// <param name="APageDataFmtBottom">��ǰҳ�����ݵײ�λ��</param>
    /// <param name="ACheckRow">��ǰҳ�����п�ʼ�Ű�</param>
    /// <param name="ABreakRow">��ǰҳ����ҳ������</param>
    /// <param name="AFmtOffset">����Ӧ��DrawItem��������ƫ�Ƶ���</param>
    /// <param name="ACellMaxInc">���ص�ǰҳ����Ϊ�˱ܿ���ҳλ�ö���ƫ�Ƶ����߶�(����ԭ��AFmtHeightIncΪ���ڷ���������)</param>
    procedure CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
      ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartRowNo: Integer;
      var ABreakRow, AFmtOffset, ACellMaxInc: Integer); override;
    // ����Ͷ�ȡ
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure SaveSelectToStream(const AStream: TStream); override;  // inherited TCustomRect
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    // ����������ط���
    procedure DoNewUndo(const Sender: THCUndo); override;
    procedure DoUndoDestroy(const Sender: THCUndo); override;
    procedure DoUndo(const Sender: THCUndo); override;
    procedure DoRedo(const Sender: THCUndo); override;
    procedure Undo_ColResize(const ACol, AOldWidth, ANewWidth: Integer);
    procedure Undo_MergeCells;

    function GetRowCount: Integer;
    function GetColCount: Integer;

    /// <summary> ��ȡָ�����з�Χʵ�ʶ�Ӧ�����з�Χ
    /// </summary>
    /// <param name="AStartRow"></param>
    /// <param name="AStartCol"></param>
    /// <param name="AEndRow"></param>
    /// <param name="AEndCol"></param>
    procedure AdjustCellRange(const AStartRow, AStartCol: Integer;
      var AEndRow, AEndCol: Integer);
    function MergeCells(const AStartRow, AStartCol, AEndRow, AEndCol: Integer):Boolean;
    function GetCells(ARow, ACol: Integer): THCTableCell;
    function InsertCol(const ACol, ACount: Integer): Boolean;
    function InsertRow(const ARow, ACount: Integer): Boolean;
    function DeleteCol(const ACol: Integer): Boolean;
    function DeleteRow(const ARow: Integer): Boolean;
  public
    //DrawItem: TCustomDrawItem;
    constructor Create(const AOwnerData: TCustomData; const ARowCount, AColCount,
      AWidth: Integer);
    destructor Destroy; override;

    /// <summary> ��ǰλ�ÿ�ʼ����ָ�������� </summary>
    /// <param name="AKeyword">Ҫ���ҵĹؼ���</param>
    /// <param name="AForward">True����ǰ��False�����</param>
    /// <param name="AMatchCase">True�����ִ�Сд��False�������ִ�Сд</param>
    /// <returns>True���ҵ�</returns>
    function Search(const AKeyword: string; const AForward, AMatchCase: Boolean): Boolean; override;

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
    procedure GetSourceCell(const ARow, ACol: Cardinal; var ASrcRow, ASrcCol: Integer);

    procedure SelectAll;

    /// <summary> �ж�ָ����Χ�ڵĵ�Ԫ���Ƿ���Ժϲ�(Ϊ�˸�����ϲ��˵����ƿ���״̬�ŵ�public����) </summary>
    /// <param name="AStartRow"></param>
    /// <param name="AStartCol"></param>
    /// <param name="AEndRow"></param>
    /// <param name="AEndCol"></param>
    /// <returns></returns>
    function CellsCanMerge(const AStartRow, AStartCol, AEndRow, AEndCol: Integer): Boolean;

    /// <summary> ָ�����Ƿ���ɾ�� </summary>
    function RowCanDelete(const ARow: Integer): Boolean;
    function CurRowCanDelete: Boolean;

    /// <summary> ָ�����Ƿ���ɾ�� </summary>
    function ColCanDelete(const ACol: Integer): Boolean;
    function CurColCanDelete: Boolean;

    /// <summary> ��ȡָ����Ԫ��ϲ���ĵ�Ԫ�� </summary>
    procedure GetMergeDest(const ARow, ACol: Integer; var ADestRow, ADestCol: Integer);

    /// <summary> ��ȡָ����Ԫ��ϲ���Ԫ���Data </summary>
    //function GetMergeDestCellData(const ARow, ACol: Integer): THCTableCellData;

    function MergeSelectCells: Boolean;
    function SelectedCellCanMerge: Boolean;

    function GetEditCell: THCTableCell; overload;
    procedure GetEditCell(var ARow, ACol: Integer); overload;

    function InsertRowAfter(const ACount: Integer): Boolean;
    function InsertRowBefor(const ACount: Integer): Boolean;
    function InsertColAfter(const ACount: Integer): Boolean;
    function InsertColBefor(const ACount: Integer): Boolean;
    function DeleteCurCol: Boolean;
    function DeleteCurRow: Boolean;

    property Cells[ARow, ACol: Integer]: THCTableCell read GetCells;
    property Rows: TTableRows read FRows;
    property RowCount: Integer read GetRowCount;
    property ColCount: Integer read GetColCount;
    property SelectCellRang: TSelectCellRang read FSelectCellRang;
    property BorderVisible: Boolean read FBorderVisible write FBorderVisible;
    property BorderWidth: Byte read FBorderWidth write FBorderWidth;
    property CellHPadding: Byte read FCellHPadding write FCellHPadding;
    property CellVPadding: Byte read FCellVPadding write FCellVPadding;
  end;

implementation

uses
  Math, Windows;

type
  TColCross = class(TObject)
  public
    Col, DrawItemNo, VOffset: Integer;
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
        vNorHeightMax := Max(vNorHeightMax, FRows[ARowID].Cols[vC].Height);
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
        //if vRow.Cols[vC].Height < vRow.Cols[vC].CellData.Height + 2 * FCellHPadding then
        vRow.Cols[vC].Height := vRow.Cols[vC].CellData.Height + 2 * FCellHPadding;
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

  Height := GetFormatHeight;  // ��������߶�

  // ����������
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

  if ARowCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');
  if AColCount = 0 then
    raise Exception.Create('�쳣�����ܴ�������Ϊ0�ı��');

  GripSize := 2;
  FCellHPadding := 2;
  FCellVPadding := 2;
  FDraging := False;
  FEnableUndo := True;
  FBorderWidth := 1;
  FBorderColor := clBlack;
  FBorderVisible := True;

  StyleNo := THCStyle.Table;
  ParaNo := OwnerData.Style.CurParaNo;
  CanPageBreak := True;
  FPageBreaks := TObjectList<TPageBreak>.Create;

  //FWidth := FRows[0].ColCount * (MinColWidth + FBorderWidth) + FBorderWidth;
  Height := ARowCount * (MinRowHeight + FBorderWidth) + FBorderWidth;
  FRows := TTableRows.Create;
  FRows.OnRowAdd := DoRowAdd;  // �����ʱ�������¼�
  FSelectCellRang := TSelectCellRang.Create;
  Self.InitializeMouseInfo;
  //
  vDataWidth := AWidth - (AColCount + 1) * FBorderWidth;
  for i := 0 to ARowCount - 1 do
  begin
    vRow := TTableRow.Create(OwnerData.Style, AColCount);
    vRow.SetRowWidth(vDataWidth);
    FRows.Add(vRow);
  end;
  FColWidths := TList<Integer>.Create;
  for i := 0 to AColCount - 1 do
    FColWidths.Add(FRows[0].Cols[i].Width);
end;

function THCTableItem.CurColCanDelete: Boolean;
begin
  Result := (FSelectCellRang.EndCol < 0)
    and (FSelectCellRang.StartCol >= 0)
    and ColCanDelete(FSelectCellRang.StartCol);
end;

function THCTableItem.CurRowCanDelete: Boolean;
begin
  Result := (FSelectCellRang.EndRow < 0)
    and (FSelectCellRang.StartRow >= 0)
    and RowCanDelete(FSelectCellRang.StartRow);
end;

procedure THCTableItem.DblClick(const X, Y: Integer);
var
  vPt: TPoint;
begin
  if FSelectCellRang.EditCell then
  begin
    vPt := GetCellPostion(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.DblClick(
      X - vPt.X - FCellHPadding, Y - vPt.Y - FCellVPadding);
  end
  else
    inherited DblClick(X, Y);
end;

function THCTableItem.DeleteCol(const ACol: Integer): Boolean;
var
  i, vRow: Integer;
  viDestRow, viDestCol: Integer;
begin
  Result := False;

  if not ColCanDelete(ACol) then Exit;

  for vRow := 0 to RowCount - 1 do
  begin
    if FRows[vRow].Cols[ACol].ColSpan < 0 then  // �ϲ�Դ
    begin
      GetDestCell(vRow, ACol, viDestRow, viDestCol);  // Ŀ���С���
      for i := ACol + 1 to viDestCol + FRows[viDestRow].Cols[viDestCol].ColSpan do  // ��ǰ������ĺϲ�Դ����Ŀ���1
        FRows[vRow].Cols[i].ColSpan := FRows[vRow].Cols[i].ColSpan + 1;

      if vRow = viDestRow then  // Ŀ�����п�ȼ���1
        FRows[viDestRow].Cols[viDestCol].ColSpan := FRows[viDestRow].Cols[viDestCol].ColSpan - 1;
    end
    else
    if FRows[vRow].Cols[ACol].ColSpan > 0 then  // �ϲ�Ŀ��
    begin

    end;

    FRows[vRow].Delete(ACol);
  end;
  FColWidths.Delete(ACol);

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.DeleteCurCol: Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  if FColWidths.Count > 1 then
    Result := DeleteCol(FSelectCellRang.StartCol)
end;

function THCTableItem.DeleteCurRow: Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  if FRows.Count > 1 then
    Result := DeleteRow(FSelectCellRang.StartRow)
end;

function THCTableItem.DeleteRow(const ARow: Integer): Boolean;
var
  i, vCol: Integer;
  viDestRow, viDestCol: Integer;
begin
  Result := False;

  if not RowCanDelete(ARow) then Exit;

  for vCol := 0 to FColWidths.Count - 1 do
  begin
    if FRows[ARow].Cols[vCol].RowSpan < 0 then  // �ϲ�Դ
    begin
      GetDestCell(ARow, vCol, viDestRow, viDestCol);  // Ŀ���С���
      for i := ARow + 1 to viDestCol + FRows[viDestRow].Cols[viDestCol].RowSpan do  // ��ǰ������ĺϲ�Դ����Ŀ���1
        FRows[i].Cols[vCol].RowSpan := FRows[i].Cols[vCol].RowSpan + 1;

      if vCol = viDestCol then  // Ŀ�����п�ȼ���1
        FRows[viDestRow].Cols[viDestCol].RowSpan := FRows[viDestRow].Cols[viDestCol].RowSpan - 1;
    end
    else
    if FRows[ARow].Cols[vCol].ColSpan > 0 then  // �ϲ�Ŀ��
    begin

    end;
  end;
  FRows.Delete(ARow);

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
  FPageBreaks.Free;
  FRows.Clear;
  FRows.Free;
  FColWidths.Free;
  //Dispose(FResizeInfo);
  //Dispose(FCaretInfo);
  inherited Destroy;
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
      if vCellData <> nil then
      begin
        vCellData.DisSelect;
        vCellData.InitializeField;
      end;
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

function THCTableItem.DoCellDataGetRootData: THCCustomData;
begin
  Result := OwnerData.GetRootData;
end;

function THCTableItem.DoCellDataGetEnableUndo: Boolean;
begin
  Result := OwnerData.Style.EnableUndo and FEnableUndo;
end;

procedure THCTableItem.DoNewUndo(const Sender: THCUndo);
var
  vCell: THCTableCell;
  vUndoCell: THCUndoCell;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    vUndoCell := THCUndoCell.Create;
    vUndoCell.Row := FSelectCellRang.StartRow;
    vUndoCell.Col := FSelectCellRang.StartCol;
    Sender.Data := vUndoCell;
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

      {$REGION ' ���Ƶ�Ԫ������ '}
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
          // ����ɫ
          vSelectAll := Self.IsSelectComplate or vCellData.CellSelectedAll;  // ���ȫѡ�л�Ԫ��ȫѡ��
          if vSelectAll and (not APaintInfo.Print) then  // ��ȫѡ��
            ACanvas.Brush.Color := OwnerData.Style.SelColor
          else
            ACanvas.Brush.Color := FRows[vMergeDestRow].Cols[vMergeDestCol].BackgroundColor;

          ACanvas.FillRect(Rect(vCellDrawLeft - FBorderWidth, vCellScreenTop,  // + FRows[vR].Height,
            vCellDrawLeft + FRows[vR].Cols[vC].Width + FBorderWidth, vCellScreenBottom));

          // ��ȡ����ʾ�������ʼ������DItem
          vCellData.GetDataDrawItemRang(vCellScreenTop - vMergeCellDataDrawTop,
            vCellScreenBottom - vMergeCellDataDrawTop, vFristDItemNo, vLastDItemNo);

          if vFristDItemNo >= 0 then  // �п���ʾ��DrawItem
          begin
            {$IFDEF SHOWITEMNO}
            ACanvas.Font.Color := clGray;
            ACanvas.Font.Style := [];
            ACanvas.Font.Size := 8;
            ACanvas.TextOut(vCellDrawLeft + 1, vMergeCellDataDrawTop, IntToStr(vR) + '/' + IntToStr(vC));
            {$ENDIF}

            FRows[vMergeDestRow].Cols[vMergeDestCol].PaintData(
              vCellDrawLeft + FCellHPadding, vMergeCellDataDrawTop,
              ADataDrawBottom, ADataScreenTop, vPageDataScreenBottom,
              0, ACanvas, APaintInfo);
          end;
        end;
      end;
      {$ENDREGION}

      {$REGION ' ���Ƹ���Ԫ��߿��� '}
      if FBorderVisible or (not APaintInfo.Print) then
      begin
        vDrawBorder := True;
        vBorderTop := vMergeCellDataDrawTop - FCellVPadding - FBorderWidth;  // Ŀ�굥Ԫ����ϱ߿�
        vBorderBottom := vBorderTop  // ����߿����¶�
          + Max(FRows[vR].Height, Cells[vMergeDestRow, vMergeDestCol].Height)  // ���ڿ����Ǻϲ�Ŀ�굥Ԫ�������õ�Ԫ��ߺ��и���ߵ�
          + FBorderWidth;

        { ���п�ҳ����������λ�� }
        if vBorderBottom > vPageDataScreenBottom then  // �ײ��߿� > ҳ�������Եײ�����ҳ��
        begin
          if Cells[vR, vC].RowSpan > 0 then  // �Ǻϲ�Ŀ�굥Ԫ��
          begin
            if vFristDItemNo < 0 then  // û�����ݱ����ƣ����ϲ�Ŀ�굥Ԫ�����������ƶ�����һҳ��
              vBorderBottom := vBorderTop + FRows[vR].Height + FBorderWidth  // �Ե�ǰ�н�β
            else
            if vBorderTop + FRows[vR].Height > vPageDataScreenBottom then  // Ŀ�굥Ԫ�����ڵ��о���Ҫ��ҳ��
            begin  // �ӵ�ǰ��������
              CheckRowBorderShouLian(vR);
              vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);
            end
            else
            if vBorderTop + FRows[vR].Height + FRows[vR + 1].Height > vPageDataScreenBottom then  // �����һ��Դ�п�ҳ��
            begin
              CheckRowBorderShouLian(vR + 1);
              vBorderBottom := vShouLian;
            end
            else  // ��ȻĿ�굥Ԫ���ҳ�ˣ���������λ�ò�����Ŀ�굥Ԫ�������У����������������ڵ�Դ��Ԫ����
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
            else
            if (vR < vMergeDestRow + FRows[vMergeDestRow].Cols[vMergeDestCol].RowSpan)
              and (vSrcRowBorderTop + FRows[vR].Height + FRows[vR + 1].Height > vPageDataScreenBottom)  // �ϲ�Ŀ���ڵ�ǰԴ��һԴ�п�ҳ��
            then
            begin
              CheckRowBorderShouLian(vR + 1);
              vBorderBottom := vShouLian;
            end
            else  // ��ȻĿ�굥Ԫ���ҳ�ˣ���������λ�ò�����Ŀ�굥Ԫ�������У����������������ڵ�Դ��Ԫ����(�� 2017-2-8_001.bmp)
              vDrawBorder := False;
          end
          else  // ��ͨ��Ԫ��(���Ǻϲ�Ŀ��Ҳ���Ǻϲ�Դ)
          begin
            if (vFristDItemNo < 0) and (vR <> vFirstDrawRow) then  // ��DrawItem�ɻ����Ҳ��ǿ�ҳ���һ�λ��Ƶ���
              vDrawBorder := False
            else
            begin
              //if FRows[vR].AutoHeight then  // ʲô�������Ҫ���������Զ��߶��أ�
                CheckRowBorderShouLian(vR);
              //else
              //  vShouLian := vPageDataScreenBottom;

              vBorderBottom := vShouLian;  //Ϊʲô��2 Min(vBorderBottom, vShouLian);  // ADataDrawBottom
            end;
          end;
        end;

        if vDrawBorder then  // �߿������ʾ
        begin
          ACanvas.Pen.Width := FBorderWidth;

          if FBorderVisible then  // δ���ر߿�
          begin
            ACanvas.Pen.Color := clBlack;
            ACanvas.Pen.Style := psSolid;
          end
          else
          if not APaintInfo.Print then
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

          if (not APaintInfo.Print)  // �Ǵ�ӡ
            and (vC = FRows[vR].ColCount - 1)  // ���һ��
            and ( (vBorderTop < ADataScreenTop) or (FRows[vR].FmtOffset <> 0) )  // �з�ҳ
          then  // ����ҳ��ʼ��ҳ��ʶ��
          begin
            ACanvas.Pen.Color := clGray;
            ACanvas.Pen.Style := psDot;
            ACanvas.MoveTo(vBorderRight + 5, ADataDrawTop + 5);  // vBorderTop
            ACanvas.LineTo(vBorderRight + 20, ADataDrawTop + 5);

            ACanvas.Pen.Style := psSolid;
            ACanvas.MoveTo(vBorderRight + 19, ADataDrawTop + 7);
            ACanvas.LineTo(vBorderRight + 19, ADataDrawTop + 14);
            ACanvas.LineTo(vBorderRight + 5, ADataDrawTop + 14);
            ACanvas.LineTo(vBorderRight + 5, ADataDrawTop + 6);
            ACanvas.Pen.Color := clBlack;
          end;

          if vBorderTop < ADataScreenTop then  // ���ǰ�п�ҳ�ˣ�����ҳ�󣬵ڶ�ҳ��ʼ�б���ϱ߿���ʾλ����Ҫ����
            vBorderTop := ADataScreenTop;

          if (vBorderTop > 0) and (cbsTop in FRows[vR].Cols[vC].BorderSides) then  // �ϱ߿����ʾ
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);   // ����
            ACanvas.LineTo(vBorderRight, vBorderTop);  // ����
          end;

          if cbsRight in FRows[vR].Cols[vC].BorderSides then  // �ұ߿�
          begin
            ACanvas.MoveTo(vBorderRight, vBorderTop);  // ����
            ACanvas.LineTo(vBorderRight, vBorderBottom);  // ����
          end;

          if cbsBottom in FRows[vR].Cols[vC].BorderSides then  // �±߿�
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderBottom);  // ����
            ACanvas.LineTo(vBorderRight, vBorderBottom);  // ����
          end;

          //if vC = 0 then  // ��1�л���ǰ�����ߣ���������ǰһ�к������ߴ���ǰ������
          if cbsLeft in FRows[vR].Cols[vC].BorderSides then
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);
            ACanvas.LineTo(vBorderLeft, vBorderBottom);
          end;

          if cbsLTRB in FRows[vR].Cols[vC].BorderSides then  // �������¶Խ���
          begin
            ACanvas.MoveTo(vBorderLeft, vBorderTop);
            ACanvas.LineTo(vBorderRight, vBorderBottom);
          end;

          if cbsRTLB in FRows[vR].Cols[vC].BorderSides then  // �������¶Խ���
          begin
            ACanvas.MoveTo(vBorderRight, vBorderTop);
            ACanvas.LineTo(vBorderLeft, vBorderBottom);
          end;

          if (not APaintInfo.Print)
             and (vC = FRows[vR].ColCount - 1)
             and ( ( (vR < Self.RowCount - 1) and (FRows[vR + 1].FmtOffset > 0) )  // ��һ�з�ҳ��
                   or (vShouLian > 0)  // ��������
                 )
          then  // ��ҳ��(ҳ��β)
          begin
            ACanvas.Pen.Color := clGray;
            ACanvas.Pen.Style := psDot;
            ACanvas.MoveTo(vBorderRight + 5, ADataDrawBottom - 5);  // vBorderBottom
            ACanvas.LineTo(vBorderRight + 20, ADataDrawBottom - 5);

            ACanvas.Pen.Style := psSolid;
            ACanvas.MoveTo(vBorderRight + 19, ADataDrawBottom - 7);
            ACanvas.LineTo(vBorderRight + 19, ADataDrawBottom - 14);
            ACanvas.LineTo(vBorderRight + 5, ADataDrawBottom - 14);
            ACanvas.LineTo(vBorderRight + 5, ADataDrawBottom - 6);
            ACanvas.Pen.Color := clBlack;
          end;
        end;
      end;
      {$ENDREGION}

      vCellDrawLeft := vCellDrawLeft + FColWidths[vC] + FBorderWidth;  // ͬ����һ�е���ʼLeftλ��
    end;
    vCellDataDrawTop := vCellDataDrawBottom;  // ��һ�е�Topλ��
  end;

  {$REGION ' �����϶��� '}
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
  {$ENDREGION}
end;

procedure THCTableItem.DoRedo(const Sender: THCUndo);
var
  vRedoCell: THCUndoCell;
  vColSize: THCUndoColSize;
  vMirror: THCUndoMirror;
  vStream: TMemoryStream;
  vStyleNo: Integer;
begin
  if Sender.Data is THCUndoCell then
  begin
    vRedoCell := Sender.Data as THCUndoCell;
    Cells[vRedoCell.Row, vRedoCell.Col].CellData.Redo(Sender);
  end
  else
  if Sender.Data is THCUndoColSize then
  begin
    vColSize := Sender.Data as THCUndoColSize;
    if vColSize.Col < FColWidths.Count - 1 then
    begin
      FColWidths[vColSize.Col + 1] := FColWidths[vColSize.Col + 1] +
        FColWidths[vColSize.Col] - vColSize.NewWidth;
    end;
    FColWidths[vColSize.Col] := vColSize.NewWidth;
  end
  else
  if Sender.Data is THCUndoMirror then
  begin
    vStream := TMemoryStream.Create;
    try
      Self.SaveToStream(vStream);  // ��¼�ָ�ǰ״̬

      vMirror := Sender.Data as THCUndoMirror;
      vMirror.Stream.Position := 0;
      vMirror.Stream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));
      FEnableUndo := False;
      try
        Self.LoadFromStream(vMirror.Stream, OwnerData.Style, HC_FileVersionInt);
      finally
        FEnableUndo := True;
      end;

      vMirror.Stream.Clear;
      vMirror.Stream.CopyFrom(vStream, 0);  // ����ָ�ǰ״̬
    finally
      vStream.Free;
    end;
  end
  else
    inherited DoRedo(Sender);
end;

procedure THCTableItem.DoRowAdd(const ARow: TTableRow);
var
  i: Integer;
  vCellData: THCTableCellData;
begin
  for i := 0 to ARow.ColCount - 1 do
  begin
    vCellData := ARow.Cols[i].CellData;
    if vCellData <> nil then
    begin
      vCellData.OnInsertItem := (OwnerData as THCCustomRichData).OnInsertItem;
      vCellData.OnItemResized := (OwnerData as THCCustomRichData).OnItemResized;
      vCellData.OnItemPaintAfter := (OwnerData as THCCustomRichData).OnItemPaintAfter;
      vCellData.OnItemPaintBefor := (OwnerData as THCCustomRichData).OnItemPaintBefor;
      vCellData.OnDrawItemPaintAfter := (OwnerData as THCRichData).OnDrawItemPaintAfter;
      vCellData.OnCreateItemByStyle := (OwnerData as THCRichData).OnCreateItemByStyle;
      vCellData.OnCreateItem := (OwnerData as THCCustomRichData).OnCreateItem;
      vCellData.OnGetUndoList := Self.GetSelfUndoList;
      vCellData.OnGetRootData := DoCellDataGetRootData;
      vCellData.OnGetEnableUndo := DoCellDataGetEnableUndo;
    end;
  end;
end;

procedure THCTableItem.DoUndo(const Sender: THCUndo);
var
  vCell: THCUndoCell;
  vColSize: THCUndoColSize;
  vMirror: THCUndoMirror;
  vStyleNo: Integer;
  vStream: TMemoryStream;
begin
  if Sender.Data is THCUndoCell then
  begin
    vCell := Sender.Data as THCUndoCell;
    Cells[vCell.Row, vCell.Col].CellData.Undo(Sender);
  end
  else
  if Sender.Data is THCUndoColSize then
  begin
    vColSize := Sender.Data as THCUndoColSize;
    if vColSize.Col < FColWidths.Count - 1 then
    begin
      FColWidths[vColSize.Col + 1] := FColWidths[vColSize.Col + 1] +
        FColWidths[vColSize.Col] - vColSize.OldWidth;
    end;
    FColWidths[vColSize.Col] := vColSize.OldWidth;
  end
  else
  if Sender.Data is THCUndoMirror then
  begin
    vStream := TMemoryStream.Create;
    try
      Self.SaveToStream(vStream);  // ��¼����ǰ״̬

      // �ָ�ԭ��
      vMirror := Sender.Data as THCUndoMirror;
      vMirror.Stream.Position := 0;
      vMirror.Stream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));
      FEnableUndo := False;
      try
        Self.LoadFromStream(vMirror.Stream, OwnerData.Style, HC_FileVersionInt);
      finally
        FEnableUndo := True;
      end;

      vMirror.Stream.Clear;
      vMirror.Stream.CopyFrom(vStream, 0);  // ���泷��ǰ״̬
    finally
      vStream.Free;
    end;
  end
  else
    inherited DoUndo(Sender);
end;

procedure THCTableItem.DoUndoDestroy(const Sender: THCUndo);
begin
  if Sender.Data is THCUndoCell then
    (Sender.Data as THCUndoCell).Free;

  inherited DoUndoDestroy(Sender);
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
            SelectInfo.StartItemOffset := GetItemAfterOffset(SelectInfo.StartItemNo);

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
        OwnerData.Style.UpdateInfoReCaret;
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
    vRow := TTableRow.Create(OwnerData.Style, vC);  // ע���д���ʱ��tableӵ���ߵ�Style������ʱ�Ǵ����AStyle
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
  FOutsideInfo.Row := -1;

  FResizeInfo := GetCellAt(X, Y, vMouseDownRow, vMouseDownCol);

  Resizing := (Button = mbLeft) and (
    (FResizeInfo.TableSite = tsBorderRight) or (FResizeInfo.TableSite = tsBorderBottom));
  if Resizing then
  begin
    FMouseDownRow := vMouseDownRow;
    FMouseDownCol := vMouseDownCol;
    FMouseDownX := X;
    FMouseDownY := Y;
    OwnerData.Style.UpdateInfoRePaint;
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
        OwnerData.Style.UpdateInfoReCaret;
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
  else  // ���ڵ�Ԫ����
  begin
    DisSelect;  // ȡ��ԭ��ѡ��
    Self.InitializeMouseInfo;

    if FResizeInfo.TableSite = tsOutside then  // ��������Χ
    begin
      FOutsideInfo.Row := vMouseDownRow;  // ���ұ�ʱ��Ӧ����
      FOutsideInfo.Leftside := X < 0;  // ���
    end;
  end;
end;

procedure THCTableItem.MouseLeave;
begin
  inherited;
  if (FMouseMoveRow < 0) or (FMouseMoveCol < 0) then Exit;
  if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
    FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove([], -1, -1);  // ����������ϸ�����Ѹ���Ƴ������ָܻ�������

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
      else  // �ƶ����ڰ���ǰ����
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
    then  // ������ϲ�ʱ��ѡ����ͬһ��Ԫ��
    begin
      FSelectCellRang.EndRow := -1;
      FSelectCellRang.EndCol := -1;
    end
    else
    begin
      if FRows[FSelectCellRang.StartRow].Cols[FSelectCellRang.StartCol].IsMergeSource then  // ��ʼѡ���ںϲ�Դ
      begin
        GetDestCell(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vRow, vCol);
        FSelectCellRang.StartRow := vRow;
        FSelectCellRang.StartCol := vCol;
      end;

      if FRows[FSelectCellRang.EndRow].Cols[FSelectCellRang.EndCol].IsMergeDest then  // �����ںϲ�Ŀ��
      begin
        GetSourceCell(FSelectCellRang.EndRow, FSelectCellRang.EndCol, vRow, vCol);  // ��ȡĿ�귽��������ݵ���Ŀ��õ�����Դ
        FSelectCellRang.EndRow := vRow;
        FSelectCellRang.EndCol := vCol;
      end;

      if (FSelectCellRang.StartRow = FSelectCellRang.EndRow)
        and (FSelectCellRang.StartCol = FSelectCellRang.EndCol)
      then  // �����ϲ�����ͬһ��Ԫ��
      begin
        FSelectCellRang.EndRow := -1;
        FSelectCellRang.EndCol := -1;
      end;
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
    OwnerData.Style.UpdateInfoRePaint;

    Exit;
  end;

  vResizeInfo := GetCellAt(X, Y, vMoveRow, vMoveCol);

  if vResizeInfo.TableSite = tsCell then  // ����ڵ�Ԫ����
  begin
    if FMouseLBDowning or (Shift = [ssLeft]) then  // ��������ƶ�������ʱ�ڱ���� or û���ڱ���ϰ���(��ѡ����)
    begin
      if FDraging or OwnerData.Style.UpdateInfo.Draging then
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
            FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
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
  else  // ��겻�ڵ�Ԫ����
  begin
    if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
    begin
      if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
        FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // .MouseMove(Shift, -1, -1);  // �ɵ�Ԫ���Ƴ�
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
                Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);

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

              Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);
            end;
          end
          else  // ��խ��
          begin
            if FColWidths[vUpCol] + vPt.X < MinColWidth then  // С����С���
              vPt.X := MinColWidth - FColWidths[vUpCol];

            if vPt.X <> 0 then
            begin
              Undo_ColResize(vUpCol, FColWidths[vUpCol], FColWidths[vUpCol] + vPt.X);

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
    OwnerData.Style.UpdateInfoRePaint;
    OwnerData.Style.UpdateInfoReCaret;

    Exit;
  end;

  if FSelecting or OwnerData.Style.UpdateInfo.Selecting then  // ��ѡ���
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
  if FDraging or OwnerData.Style.UpdateInfo.Draging then  // ��ק����
  begin
    FDraging := False;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);

    if vResizeInfo.TableSite = TTableSite.tsCell then  // �ϵ���ĳ��Ԫ����
    begin
      DisSelect;
      FMouseMoveRow := vUpRow;  // ��קʱ�ĵ�Ԫ��λʹ�õ���MouseMove�������
      FMouseMoveCol := vUpCol;
      // ԭʼ����������ʵ��
      //DisSelectSelectedCell(vUpRow, vUpCol);  // ȡ��������֮���������קѡ�е�Ԫ���״̬
      //FRows[vUpRow].Cols[vUpCol].CellData.CellSelectedAll := False;
      //FSelectCellRang.Initialize;  // ׼�����¸�ֵ

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

function THCTableItem.RowCanDelete(const ARow: Integer): Boolean;
var
  vCol: Integer;
begin
  Result := False;
  for vCol := 0 to FColWidths.Count - 1 do
  begin
    if FRows[ARow].Cols[vCol].RowSpan > 0 then  // �кϲ�Ŀ�������ʱ��֧��
      Exit;
  end;
  Result := True;
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

function THCTableItem.GetColCount: Integer;
begin
  Result := FColWidths.Count;
end;

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
  Result.DestX := -1;
  Result.DestY := -1;

  ARow := -1;
  ACol := -1;

  if (Y < 0) or (Y > Height) then Exit;

  if (X < 0) or (X > Width) then  // ���ڱ����ʱ���ж϶�Ӧλ�õ��У������ʹ��
  begin
    vTop := FBorderWidth;
    for i := 0 to RowCount - 1 do
    begin
      vTop := vTop + FRows[i].FmtOffset;  // ��ʵ������TopΪ��λ�ã��������п�ҳʱ������һҳ�ײ����ѡ�е�����һҳ��һ��
      vBottom := vTop + FRows[i].Height + FBorderWidth;

      if (vTop < Y) and (vBottom > Y) then  // �ڴ�����
      begin
        ARow := i;
        Break;
      end;
      vTop := vBottom;
    end;

    Exit;
  end;

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

procedure THCTableItem.GetSourceCell(const ARow, ACol: Cardinal; var ASrcRow,
  ASrcCol: Integer);
begin
  ASrcRow := ARow + FRows[ARow].Cols[ACol].RowSpan;
  ASrcCol := ACol + FRows[ARow].Cols[ACol].ColSpan;
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

function THCTableItem.InsertCol(const ACol, ACount: Integer): Boolean;
var
  i, j, vRow, vWidth: Integer;
  viDestRow, viDestCol: Integer;
  vCell: THCTableCell;
begin
  Result := False;
  { TODO : ���ݸ��е�ǰ��ƽ������һ���Ŀ�ȸ�Ҫ������� }
  vWidth := MinColWidth - FBorderWidth;

  for i := 0 to ACount - 1 do
  begin
    for vRow := 0 to RowCount - 1 do
    begin
      vCell := THCTableCell.Create(OwnerData.Style);
      vCell.Width := vWidth;

      if (ACol < FColWidths.Count) and (FRows[vRow].Cols[ACol].ColSpan < 0) then  // �ϲ���Դ��
      begin
        GetDestCell(vRow, ACol, viDestRow, viDestCol);  // Ŀ������

        // �²�������ڵ�ǰ�к��棬Ҳ��Ϊ���ϲ�����
        vCell.CellData.Free;
        vCell.CellData := nil;
        vCell.RowSpan := FRows[vRow].Cols[ACol].RowSpan;
        vCell.ColSpan := FRows[vRow].Cols[ACol].ColSpan;

        for j := ACol to viDestCol + Cells[viDestRow, viDestCol].ColSpan do  // ��������Ŀ��Զ1
          FRows[vRow].Cols[j].ColSpan := FRows[vRow].Cols[j].ColSpan - 1;  // ��Ŀ����Զ1

        FRows[viDestRow].Cols[viDestCol].ColSpan := FRows[viDestRow].Cols[viDestCol].ColSpan + 1;
      end;
      FRows[vRow].Insert(ACol, vCell);
    end;

    FColWidths.Insert(ACol, vWidth);  // �Ҳ������
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertColAfter(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  if vCell.ColSpan > 0 then
    Result := InsertCol(FSelectCellRang.StartCol + vCell.ColSpan + 1, ACount)
  else
    Result := InsertCol(FSelectCellRang.StartCol + 1, ACount);
end;

function THCTableItem.InsertColBefor(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;
  vCell.CellData.InitializeField;

  Result := InsertCol(FSelectCellRang.StartCol, ACount)
end;

function THCTableItem.InsertItem(const AItem: THCCustomItem): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell <> nil then
  begin
    //DoGetSelfUndoList.NewUndo(0, 0);
    //Self.Undo_StartRecord;
    Result := vCell.CellData.InsertItem(AItem);
  end;
end;

function THCTableItem.InsertRow(const ARow, ACount: Integer): Boolean;
var
  i, j, vCol, viDestRow, viDestCol: Integer;
  vTableRow: TTableRow;
begin
  Result := False;
  for i := 0 to ACount - 1 do
  begin
    vTableRow := TTableRow.Create(OwnerData.Style, FColWidths.Count);
    for vCol := 0 to FColWidths.Count - 1 do
    begin
      vTableRow.Cols[vCol].Width := FColWidths[vCol];

      if (ARow < FRows.Count) and (FRows[ARow].Cols[vCol].RowSpan < 0) then  // �ںϲ���Դ��Ԫ��ǰ�����
      begin
        GetDestCell(ARow, vCol, viDestRow, viDestCol);
        vTableRow.Cols[vCol].CellData.Free;
        vTableRow.Cols[vCol].CellData := nil;
        vTableRow.Cols[vCol].RowSpan := FRows[ARow].Cols[vCol].RowSpan;

        for j := ARow to viDestRow + Cells[viDestRow, viDestCol].RowSpan do  // Ŀ����п�� - �Ѿ����
          FRows[j].Cols[vCol].RowSpan := FRows[j].Cols[vCol].RowSpan - 1;  // ��Ŀ����Զ1

        FRows[viDestRow].Cols[viDestCol].RowSpan := FRows[viDestRow].Cols[viDestCol].RowSpan + 1;  // Ŀ���а����ĺϲ�Դ����1
      end;
    end;
    FRows.Insert(ARow, vTableRow);
  end;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;
  Result := True;
end;

function THCTableItem.InsertRowAfter(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  if vCell.RowSpan > 0 then
    Result := InsertRow(FSelectCellRang.StartRow + vCell.RowSpan + 1, ACount)
  else
    Result := InsertRow(FSelectCellRang.StartRow + 1, ACount)
end;

function THCTableItem.InsertRowBefor(const ACount: Integer): Boolean;
var
  vCell: THCTableCell;
begin
  Result := False;
  vCell := GetEditCell;
  if vCell = nil then Exit;

  vCell.CellData.InitializeField;

  Result := InsertRow(FSelectCellRang.StartRow, ACount);
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
var
  vOldHeight: Integer;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    vOldHeight := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.Height;
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.InsertText(AText);
    Self.SizeChanged := vOldHeight <> Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.Height;
  end
  else
    Result := inherited InsertText(AText);
end;

function THCTableItem.IsSelectComplateTheory: Boolean;
begin
  Result := IsSelectComplate;
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
  vR, vC, vR1, vC1, vRowSpan, vColSpan, vNewColSpan, vNewRowSpan,
  vEndRow, vEndCol: Integer;  // �����Ľ���λ��
begin
  Result := False;
  vEndRow := AEndRow;
  vEndCol := AEndCol;

  AdjustCellRange(AStartRow, AStartCol, vEndRow, vEndCol);

  Result := CellsCanMerge(AStartRow, AStartCol, vEndRow, vEndCol);
  if not Result then Exit;

  // ���������У����жϺ���ʼ�С��кͽ����С������һ����������
  if AStartRow = vEndRow then  // ͬһ�кϲ�
  begin
    for vC := AStartCol + 1 to vEndCol do  // �ϲ���
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        Cells[AStartRow, AStartCol].CellData.AddData(Cells[AStartRow, vC].CellData);
        Cells[AStartRow, vC].CellData.Free;
        Cells[AStartRow, vC].CellData := nil;
        //Cells[AStartRow, vC].RowSpan := 0;
      end;

      Cells[AStartRow, vC].ColSpan := AStartCol - vC;
    end;

    Cells[AStartRow, AStartCol].ColSpan := vEndCol - AStartCol;  // �ϲ�Դ����

    DeleteEmptyCols(AStartCol + 1, vEndCol);
    Result := True;
  end
  else
  if AStartCol = vEndCol then  // ͬ�кϲ�
  begin
    for vR := AStartRow + 1 to vEndRow do  // �ϲ�����
    begin
      if FRows[vR].Cols[AStartCol].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[AStartCol].CellData);
        FRows[vR].Cols[AStartCol].CellData.Free;
        FRows[vR].Cols[AStartCol].CellData := nil;
        //Cells[vR, AStartCol].ColSpan := 0;
      end;

      Cells[vR, AStartCol].RowSpan := AStartRow - vR;
    end;

    FRows[AStartRow].Cols[AStartCol].RowSpan := vEndRow - AStartRow;

    DeleteEmptyRows(AStartRow + 1, vEndRow);
    Result := True;
  end
  else  // ��ͬ�У���ͬ��
  begin
    for vC := AStartCol + 1 to vEndCol do  // ��ʼ�и��кϲ�
    begin
      if FRows[AStartRow].Cols[vC].CellData <> nil then  // ��ֹ�Ѿ��ϲ����ظ��ٺϲ�
      begin
        FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[AStartRow].Cols[vC].CellData);
        FRows[AStartRow].Cols[vC].CellData.Free;
        FRows[AStartRow].Cols[vC].CellData := nil;
      end;

      FRows[AStartRow].Cols[vC].RowSpan := 0;
      FRows[AStartRow].Cols[vC].ColSpan := AStartCol - vC;
    end;

    for vR := AStartRow + 1 to vEndRow do  // ʣ���и��кϲ�
    begin
      for vC := AStartCol to vEndCol do
      begin
        if FRows[vR].Cols[vC].CellData <> nil then
        begin
          FRows[AStartRow].Cols[AStartCol].CellData.AddData(FRows[vR].Cols[vC].CellData);
          FRows[vR].Cols[vC].CellData.Free;
          FRows[vR].Cols[vC].CellData := nil;
        end;

        FRows[vR].Cols[vC].ColSpan := AStartCol - vC;
        FRows[vR].Cols[vC].RowSpan := AStartRow - vR;
      end;
    end;

    FRows[AStartRow].Cols[AStartCol].RowSpan := vEndRow - AStartRow;
    FRows[AStartRow].Cols[AStartCol].ColSpan := vEndCol - AStartCol;

    DeleteEmptyRows(AStartRow + 1, vEndRow);
    // ɾ������
    DeleteEmptyCols(AStartCol + 1, vEndCol);

    Result := True;
  end;
end;

function THCTableItem.MergeSelectCells: Boolean;
begin
  if (FSelectCellRang.StartRow >= 0) and (FSelectCellRang.EndRow >= 0) then
  begin
    Undo_MergeCells;

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
var
  vR, vC: Integer;
begin
  Result := False;

  for vR := AStartRow to AEndRow do
  begin
    for vC := AStartCol to AEndCol do
    begin
      if FRows[vR].Cols[vC].CellData <> nil then
      begin
        if not FRows[vR].Cols[vC].CellData.CellSelectedAll then
          Exit;
      end;
    end;
  end;

  Result := True;

  {GetDestCell(AStartRow, AStartCol, vStartDestRow, vStartDestCol);
  vCell := FRows[vStartDestRow].Cols[vStartDestCol];
  vStartDestRow := vStartDestRow + vCell.RowSpan;
  vStartDestCol := vStartDestCol + vCell.ColSpan;

  // ������Ԫ�����Ч��Χ
  GetDestCell(AEndRow, AEndCol, vEndDestRow, vEndDestCol);
  vCell := FRows[vEndDestRow].Cols[vEndDestCol];
  vEndDestRow := vEndDestRow + vCell.RowSpan;
  vEndDestCol := vEndDestCol + vCell.ColSpan;

  if vStartDestRow = vEndDestRow then
    Result := vStartDestCol < vEndDestCol
  else
  if vStartDestRow < vEndDestRow then
    Result := vStartDestCol <= vEndDestCol;}
end;

procedure THCTableItem.CheckFormatPageBreak(const APageIndex, ADrawItemRectTop,
  ADrawItemRectBottom, APageDataFmtTop, APageDataFmtBottom, AStartRowNo: Integer;
  var ABreakRow, AFmtOffset, ACellMaxInc: Integer);

  procedure AddPageBreak(const ARow, ABreakSeat: Integer);
  var
    vPageBreak: TPageBreak;
  begin
    vPageBreak := TPageBreak.Create;
    vPageBreak.PageIndex := APageIndex;  // ��ҳʱ��ǰҳ���
    vPageBreak.Row := ARow;  // ��ҳ��
    vPageBreak.BreakSeat := ABreakSeat;  // ��ҳʱ�����и��з�ҳλ������
    vPageBreak.BreakBottom := APageDataFmtBottom - ADrawItemRectTop;  // ҳ�ײ�λ��

    FPageBreaks.Add(vPageBreak);
  end;

var
  vRowDataFmtTop, vBreakRowBottom,
  vLastDFromRowBottom,  // ���һ��DItem�ײ������еײ��ľ���
  vDestCellDataFmtTop,  // ��Ԫ�����ݶ���(���ϲ���Ԫ���ҳʱ��Ŀ�굥Ԫ��Ϊ׼)
  vRowMergedHeight,  // ��ǰ������ϲ������и��ܺ�
  vH,  // ��ǰDItem����ƫ�ƶ��ٿ�����ʾ����һҳ����
  vCellInc,  // ��ǰ�з�ҳ�����ӵĸ߶�
  vMergeDestRow2,
  vDestRow, vDestCol,  // �ϲ���Ŀ�굥Ԫ��
  vBreakSeat  // ��ҳʱ�����и��з�ҳλ������
    :Integer;
  i, j, k: Integer;
  vCellData: THCTableCellData;
  vDrawItem: THCCustomDrawItem;
  vFirstLinePlace: Boolean;  // ����Ԫ��������һ�����ݿ��ڷ�ҳλ������������ʾ
  vRect: TRect;
  vColCross: TColCross;
  vColCrosses: TObjectList<TColCross>;  // ��¼��ҳ�и��з�ҳ��ʼDrawItem�ͷ�ҳƫ��
begin
  ABreakRow := -1;
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

  if ABreakRow < 0 then Exit;  // ������ڵ�ǰҳ����

  {if ABreakRow = 0 then  // ����ڵ�ǰҳһ��Ҳ�Ų��£����������ʵ�ֱ���һ���ڵ�ǰҳ��ʾ����ʱ�������ƣ��������жϴ��������ݽض�
  begin
    //if vRowDataFmtTop < APageDataFmtTop then  // �����жϣ�������ڵ�2ҳ��1��ʱ��׼ȷ ��ǰҳ��ʼItem���ǵ�ǰ��񣨱���ǵ�ǰҳ��һ��Item���ͷ�ҳ��ͬ����ҳ��ȻҲ�ǵ�һ������������ʼλ�ò����ڷ�ҳ���ҳ��
    begin
      AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
      Exit;
    end;
  end;}

  { �Ų��£����жϷ�ҳλ�� }
  { -��ҳλ���Ǹ���Ԫ���һ�еģ������Ƿ���ڿ������ڷ�ҳλ�����������- }
  vFirstLinePlace := True;
  vCellInc := 0;  // �и�����Ϊ�ܿ���ҳ�������ӵĸ�ʽ���߶�
  vBreakSeat := 0;

  vColCrosses := TObjectList<TColCross>.Create;
  try

    {$REGION ' ��¼��ҳ���е�Ԫ����DrawItem��ҳʱ����ƫ���� '}
    for i := 0 to FRows[ABreakRow].ColCount - 1 do  // �������е�Ԫ����DrawItem���Ҵ��ĸ���ʼ����ƫ�Ƽ�ƫ����
    begin
      if FRows[ABreakRow].Cols[i].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
        Continue;

      GetMergeDest(ABreakRow, i, vDestRow, vDestCol);
      vCellData := FRows[vDestRow].Cols[vDestCol].CellData;

      vLastDFromRowBottom :=  // ԭ���һ��DrawItem�ײ������еײ��Ŀհ׾���
        FRows[vDestRow].Cols[vDestCol].Height - vCellData.Height - FCellVPadding;
      vDestCellDataFmtTop := vRowDataFmtTop;
      while vDestRow < ABreakRow do  // �ָ���Ŀ�굥Ԫ��
      begin
        vDestCellDataFmtTop := vDestCellDataFmtTop - FBorderWidth - FRows[vDestRow].Height;
        Inc(vDestRow);
      end;

      vColCross := TColCross.Create;
      vColCross.Col := i;

      for j := 0 to vCellData.DrawItems.Count - 1 do
      begin
        vDrawItem := vCellData.DrawItems[j];
        if not vDrawItem.LineFirst then  // ֻ��Ҫ�ж�����ÿ�е�һ��
          Continue;

        vRect := vDrawItem.Rect;
        if vDestCellDataFmtTop + vRect.Bottom + FBorderWidth + FCellVPadding > APageDataFmtBottom then  // ��ǰDrawItem�ײ�����ҳ�ײ��� 20160323002 // �еײ��ı߿�����ʾ����ʱҲ����ƫ��
        begin
          if j = 0 then  // ��һ��DrawItem�ͷŲ���
            vFirstLinePlace := False;

          // �����ҳ��DrawItem����ƫ�ƶ��ٿ�����һҳȫ��ʾ��DrawItem
          vH := APageDataFmtBottom - (vDestCellDataFmtTop + vRect.Top{ + vBottomBorder}) // ҳData�ײ� - ��ǰDrawItem��ҳ�����λ��
            + FBorderWidth;  // ���ӷ�ҳ����һҳԤ�����߿�
          vCellInc := vH - vLastDFromRowBottom;  // ʵ�����ӵĸ߶� = ��ҳ����ƫ�Ƶľ��� - ԭ���һ��DItem�ײ������еײ��Ŀհ׾���

          vColCross.DrawItemNo := j;  // �ӵ�j��DrawItem����ʼ��ҳ
          vColCross.VOffset := vH;  // ��ҳƫ��
          vColCross.MergeSrc := FRows[ABreakRow].Cols[i].RowSpan < 0;  // �����Ǻϲ�Դ

          if j > 0 then  // ���ܷ��µ�DrawItem
          begin
            if vDestCellDataFmtTop + FBorderWidth + FCellVPadding + vCellData.DrawItems[j - 1].Rect.Bottom > vBreakSeat then
              vBreakSeat := vDestCellDataFmtTop + vCellData.DrawItems[j - 1].Rect.Bottom + FBorderWidth + FCellVPadding;
          end
          else  // ��һ��DrawItem�ͷŲ���
          begin
            if vDestCellDataFmtTop > vBreakSeat then
              vBreakSeat := vDestCellDataFmtTop;
          end;

          Break;
        end;
      end;
      if ACellMaxInc < vCellInc then
        ACellMaxInc := vCellInc;  // ��¼�����з�ҳ����ƫ�Ƶ��������

      vColCrosses.Add(vColCross);
    end;

    vBreakSeat := vBreakSeat - ADrawItemRectTop;
    {$ENDREGION}

    if ACellMaxInc > 0 then  // ��ҳ�и���Ϊ��ҳ�������ӵ��������ֵ
    begin
      if not vFirstLinePlace then  // ĳ��Ԫ���һ�����ݾ��ڵ�ǰҳ�Ų����ˣ�������ҳ��������Ҫ���Ƶ���һҳ
      begin
        if ABreakRow = 0 then  // ����һ�����е�Ԫ���ڵ�ǰҳ�Ų��£���Ҫ��������
        begin
          AFmtOffset := APageDataFmtBottom - ADrawItemRectTop;
          ACellMaxInc := 0;  // ��������ƫ��ʱ���ʹ����˵�һ�е�����ƫ�ƣ�����˵��һ�е�FmtOffset��Զ��0����Ϊ��������ƫ�Ƶ��������жϵ�һ��
          Exit;
        end;

        AddPageBreak(ABreakRow, vBreakSeat);
        FRows[ABreakRow].FmtOffset := ACellMaxInc;  // ���������ƫ��ACellMaxInc��������ʼ����һҳ��ʾ
        // �кϲ�Դ��Ԫ����Ҫ�����Ŀ�굽�ˣ����������Ʒ�ҳ�е� ��һ�е� �ײ�����
        for i := 0 to vColCrosses.Count - 1 do
        begin
          if vColCrosses[i].MergeSrc then  // �ϲ�Դ������Ŀ�굥Ԫ��
          begin
            GetMergeDest(ABreakRow, vColCrosses[i].Col, vDestRow, vDestCol);
            vH := vDestRow + FRows[vDestRow].Cols[vDestCol].RowSpan;  // �ϲ����������������
            vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
            //vLastDFromRowBottom :=  // ԭ���һ��DrawItem�ײ������еײ��Ŀհ׾���
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
              vDrawItem := vCellData.DrawItems[j];
              vRect := vDrawItem.Rect;
              if j = vCellData.DrawItems.Count - 1 then
                vRect.Bottom := vRect.Bottom + FCellVPadding;
              if not vDrawItem.LineFirst then  // ֻ��Ҫ�ж��е�һ��
                Continue;

              if vDestCellDataFmtTop + vRect.Bottom > vRowDataFmtTop then  // ��ǰDrawItem�������������е���һ�еײ���
              begin
                vCellInc := vRowDataFmtTop - vDestCellDataFmtTop - vDrawItem.Rect.Top + FCellVPadding;// + FRows[ABreakRow].FmtOffset;
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
      else  // ����Ҫ���ж����Ƶ���һҳ����Ԫ�������ݿ�������һҳ��ʾ�������ڷ�ҳλ�ô���DrawItem����ƫ��
      begin
        AddPageBreak(ABreakRow, vBreakSeat);

        for i := 0 to vColCrosses.Count - 1 do  // �������е�Ԫ����DrawItem������ƫ��vH
        begin
          //if FRows[ABreakRow].Cols[vCellCrosses[i].Col].ColSpan < 0 then  // �ϲ�Ŀ��ֻ�������·��ĵ�Ԫ����ϲ����ݣ������ظ�����
          //  Continue;
          if vColCrosses[i].DrawItemNo < 0 then  // ����Ҫƫ��
            Continue;
          GetMergeDest(ABreakRow, vColCrosses[i].Col, vDestRow, vDestCol);
          vCellData := FRows[vDestRow].Cols[vDestCol].CellData;
          for j := vColCrosses[i].DrawItemNo to vCellData.DrawItems.Count - 1 do
            OffsetRect(vCellData.DrawItems[j].Rect, 0, vColCrosses[i].VOffset);
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
    FreeAndNil(vColCrosses);
  end;
end;

procedure THCTableItem.CheckFormatPageBreakBefor;
begin
  FPageBreaks.Clear;
end;

function THCTableItem.ColCanDelete(const ACol: Integer): Boolean;
var
  vRow: Integer;
begin
  Result := False;
  for vRow := 0 to RowCount - 1 do
  begin
    if FRows[vRow].Cols[ACol].ColSpan > 0 then  // �кϲ�Ŀ�������ʱ��֧��
      Exit;
  end;
  Result := True;
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

function THCTableItem.Search(const AKeyword: string; const AForward,
  AMatchCase: Boolean): Boolean;
var
  i, j, vRow, vCol: Integer;
begin
  Result := False;

  if AForward then  // ��ǰ����
  begin
    if FSelectCellRang.StartRow < 0 then  // û�б༭�ĵ�Ԫ��
    begin
      FSelectCellRang.StartRow := FRows.Count - 1;
      FSelectCellRang.StartCol := FColWidths.Count - 1;

      vRow := FSelectCellRang.StartRow;
      vCol := FSelectCellRang.StartCol;

      // �����ʼ
      if Cells[vRow, vCol].CellData <> nil then
      begin
        with Cells[vRow, vCol].CellData do
        begin
          SelectInfo.StartItemNo := Items.Count - 1;
          SelectInfo.StartItemOffset := GetItemAfterOffset(Items.Count - 1);
        end;
      end;
    end;

    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;

    if (vRow >= 0) and (vCol >= 0) then
    begin
      if Cells[vRow, vCol].CellData <> nil then
        Result := Cells[vRow, vCol].CellData.Search(AKeyword, AForward, AMatchCase);

      if not Result then  // ��ǰ��Ԫ��û�ҵ�
      begin
        for j := vCol - 1 downto 0 do  // ��ͬ�к���ĵ�Ԫ����
        begin
          if (Cells[vRow, j].ColSpan < 0) or (Cells[vRow, j].RowSpan < 0) then
            Continue
          else
          begin
            with Cells[vRow, j].CellData do
            begin
              SelectInfo.StartItemNo := Items.Count - 1;
              SelectInfo.StartItemOffset := GetItemAfterOffset(Items.Count - 1);
            end;

            Result := Cells[vRow, j].CellData.Search(AKeyword, AForward, AMatchCase);
          end;

          if Result then
          begin
            FSelectCellRang.StartCol := j;
            Break;
          end;
        end;
      end;

      if not Result then  // ͬ�к���ĵ�Ԫ��û�ҵ�
      begin
        for i := FSelectCellRang.StartRow - 1 downto 0 do
        begin
          for j := FColWidths.Count - 1 downto 0 do
          begin
            if (Cells[i, j].ColSpan < 0) or (Cells[i, j].RowSpan < 0) then
              Continue
            else
            begin
              with Cells[i, j].CellData do
              begin
                SelectInfo.StartItemNo := Items.Count - 1;
                SelectInfo.StartItemOffset := GetItemAfterOffset(Items.Count - 1);
              end;

              Result := Cells[i, j].CellData.Search(AKeyword, AForward, AMatchCase);
            end;

            if Result then
            begin
              FSelectCellRang.StartCol := j;
              Break;
            end;
          end;

          if Result then
          begin
            FSelectCellRang.StartRow := i;
            Break;
          end;
        end;
      end;
    end;
  end
  else  // ������
  begin
    if FSelectCellRang.StartRow < 0 then  // û�б༭�ĵ�Ԫ��
    begin
      FSelectCellRang.StartRow := 0;
      FSelectCellRang.StartCol := 0;

      // ��ͷ��ʼ
      Cells[0, 0].CellData.SelectInfo.StartItemNo := 0;
      Cells[0, 0].CellData.SelectInfo.StartItemOffset := 0;
    end;

    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;

    if (vRow >= 0) and (vCol >= 0) then
    begin
      Result := Cells[vRow, vCol].CellData.Search(AKeyword, AForward, AMatchCase);
      if not Result then  // ��ǰ��Ԫ��û�ҵ�
      begin
        for j := vCol + 1 to FColWidths.Count - 1 do  // ��ͬ�к���ĵ�Ԫ����
        begin
          if (Cells[vRow, j].ColSpan < 0) or (Cells[vRow, j].RowSpan < 0) then
            Continue
          else
          begin
            Cells[vRow, j].CellData.SelectInfo.StartItemNo := 0;
            Cells[vRow, j].CellData.SelectInfo.StartItemOffset := 0;

            Result := Cells[vRow, j].CellData.Search(AKeyword, AForward, AMatchCase);
          end;

          if Result then
          begin
            FSelectCellRang.StartCol := j;
            Break;
          end;
        end;
      end;

      if not Result then  // ͬ�к���ĵ�Ԫ��û�ҵ�
      begin
        for i := FSelectCellRang.StartRow + 1 to FRows.Count - 1 do
        begin
          for j := 0 to FColWidths.Count - 1 do
          begin
            if (Cells[i, j].ColSpan < 0) or (Cells[i, j].RowSpan < 0) then
              Continue
            else
            begin
              Cells[i, j].CellData.SelectInfo.StartItemNo := 0;
              Cells[i, j].CellData.SelectInfo.StartItemOffset := 0;

              Result := Cells[i, j].CellData.Search(AKeyword, AForward, AMatchCase);
            end;

            if Result then
            begin
              FSelectCellRang.StartCol := j;
              Break;
            end;
          end;

          if Result then
          begin
            FSelectCellRang.StartRow := i;
            Break;
          end;
        end;
      end;
    end;
  end;

  if not Result then
    FSelectCellRang.Initialize;
end;

procedure THCTableItem.SelectAll;
begin
  SelectComplate;
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

function THCTableItem.SelectedCellCanMerge: Boolean;
var
  vEndRow, vEndCol: Integer;
begin
  Result := False;
  if FSelectCellRang.SelectExists then
  begin
    vEndRow := FSelectCellRang.EndRow;
    vEndCol := FSelectCellRang.EndCol;
    AdjustCellRange(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vEndRow, vEndCol);
    Result := CellsCanMerge(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vEndRow, vEndCol);
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

procedure THCTableItem.Undo_ColResize(const ACol, AOldWidth,
  ANewWidth: Integer);
var
  vUndo: THCUndo;
  vUndoColSize: THCUndoColSize;
begin
  if OwnerData.Style.EnableUndo then
  begin
    Undo_StartRecord;
    vUndo := GetSelfUndoList.Last;
    if vUndo <> nil then
    begin
      vUndoColSize := THCUndoColSize.Create;
      vUndoColSize.Col := ACol;
      vUndoColSize.OldWidth := AOldWidth;
      vUndoColSize.NewWidth := ANewWidth;

      vUndo.Data := vUndoColSize;
    end;
  end;
end;

procedure THCTableItem.Undo_MergeCells;
var
  vUndo: THCUndo;
  vMirror: THCUndoMirror;
begin
  if OwnerData.Style.EnableUndo then
  begin
    Undo_StartRecord;
    vUndo := GetSelfUndoList.Last;
    if vUndo <> nil then
    begin
      vMirror := THCUndoMirror.Create;
      Self.SaveToStream(vMirror.Stream);

      vUndo.Data := vMirror;
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

procedure THCTableItem.AdjustCellRange(const AStartRow, AStartCol: Integer;
  var AEndRow, AEndCol: Integer);
var
  vR, vC, vLastRow, vLastCol, vDestRow, vDestCol: Integer;
  vCell: THCTableCell;
begin
  // ������ʼ��Ԫ���ѡ�н���ȷ���ľ�����Ч��Χ
  vLastRow := AEndRow;
  vLastCol := AEndCol;
  for vR := AStartRow to AEndRow do
  begin
    for vC := AStartCol to AEndCol do
    begin
      vCell := FRows[vR].Cols[vC];
      if (vCell.RowSpan > 0) or (vCell.ColSpan > 0) then
      begin
        GetDestCell(vR, vC, vDestRow, vDestCol);
        vCell := FRows[vDestRow].Cols[vDestCol];
        vDestRow := vDestRow + vCell.RowSpan;
        vDestCol := vDestCol + vCell.ColSpan;
        if vLastRow < vDestRow then
          vLastRow := vDestRow;
        if vLastCol < vDestCol then
          vLastCol := vDestCol;
      end;
    end;
  end;

  AEndRow := vLastRow;
  AEndCol := vLastCol;
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
        begin
          if Assigned(Cells[vR, vC].CellData) then
            Cells[vR, vC].CellData.ApplySelectParaStyle(AMatchStyle);
        end;
      end;
    end
    else  // ��ͬһ��Ԫ��
      GetEditCell.CellData.ApplySelectParaStyle(AMatchStyle);
  end
  else
    Self.ParaNo := AMatchStyle.GetMatchParaNo(OwnerData.Style, Self.ParaNo);
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
      begin
        if Cells[vR, vC].CellData <> nil then
          Cells[vR, vC].CellData.ApplySelectTextStyle(AMatchStyle);
      end;
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
    Result := vCellData.GetTopLevelDrawItem;
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
    Result := vCell.CellData.GetTopLevelItem;
end;

procedure THCTableItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
var
  i, vTop, vBottom, vRow, vCol: Integer;
  vPos: TPoint;
  vCaretCell: THCTableCell;
begin
  if OwnerData.Style.UpdateInfo.Draging then  // ��ק
  begin
    vRow := FMouseMoveRow;
    vCol := FMouseMoveCol;
  end
  else  // ����ק
  begin
    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;
  end;

  if vRow < 0 then  // û�ڱ�����棬��ǰ������
  begin
    if FOutsideInfo.Row >= 0 then  // ǰ�������Ӧ����
    begin
      if FOutsideInfo.Leftside then  // �����
        ACaretInfo.X := ACaretInfo.X - 2;  // Ϊʹ�������ԣ�����ƫ��2

      vTop := 0;
      for i := FPageBreaks.Count - 1 downto 0 do  // �ҹ�궥��λ��
      begin
        if FPageBreaks[i].Row <= FOutsideInfo.Row then  // ��ǰ��ǰ���ҳ��
        begin
          if FPageBreaks[i].PageIndex = ACaretInfo.PageIndex - 1 then  // ǰ���ҳ�����ǵ�ǰҳǰһҳ
          begin
            vTop := FPageBreaks[i].BreakBottom;  // ��ҳ�ײ�λ��
            Break;
          end;
        end;
      end;

      vBottom := Self.Height;
      for i := 0 to FPageBreaks.Count - 1 do  // �ҹ��ײ�λ��
      begin
        if FPageBreaks[i].Row >= FOutsideInfo.Row then  // ��ǰ�к����ҳ��
        begin
          if FPageBreaks[i].PageIndex = ACaretInfo.PageIndex then  // ��ҳ�ǵ�ǰҳ
          begin
            vBottom := FPageBreaks[i].BreakSeat;  // ��ҳ����λ��
            Break;
          end;
        end;
      end;

      ACaretInfo.Y := ACaretInfo.Y + vTop;
      ACaretInfo.Height := vBottom - vTop;
    end
    else
      ACaretInfo.Visible := False;

    Exit;
  end
  else
    vCaretCell := Cells[vRow, vCol];

  if OwnerData.Style.UpdateInfo.Draging then  // ��ק
  begin
    if (vCaretCell.CellData.MouseMoveItemNo < 0)
      or (vCaretCell.CellData.MouseMoveItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;
    vCaretCell.GetCaretInfo(vCaretCell.CellData.MouseMoveItemNo,
      vCaretCell.CellData.MouseMoveItemOffset, ACaretInfo)
  end
  else  // ����ק
  begin
    if (vCaretCell.CellData.SelectInfo.StartItemNo < 0)
      or (vCaretCell.CellData.SelectInfo.StartItemOffset < 0)
    then
    begin
      ACaretInfo.Visible := False;
      Exit;
    end;
    vCaretCell.GetCaretInfo(vCaretCell.CellData.SelectInfo.StartItemNo,
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

{ TColCross }

constructor TColCross.Create;
begin
  inherited;
  Col := -1;
  DrawItemNo := -1;
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
