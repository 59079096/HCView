unit HCGridView;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, Generics.Collections, Messages,
  HCScrollBar, HCRichScrollBar, HCTableRow, HCTableCell, HCTableCellData, HCStyle,
  HCItem, HCCommon, HCUndo;

type
  THCColumnPaintEvent = procedure(const ACell: THCTableCell;
    const ACanvas: TCanvas; const ARect: TRect) of object;

  THCTableRows = Class(TObjectList<THCTableRow>)
  private
    FOnRowAdd: TRowAddEvent;
  protected
    procedure Notify(const Value: THCTableRow; Action: TCollectionNotification); override;
  public
    property OnRowAdd: TRowAddEvent read FOnRowAdd write FOnRowAdd;
  end;

  THCGridPaintEvent = procedure(const ACanvas: TCanvas; const ARect: TRect) of object;

  THCCustomGridView = class(TCustomControl)
  strict private
    FStyle: THCStyle;
    FBitmap: TBitmap;
    FCaret: THCCaret;
    FHScrollBar: THCScrollBar;
    FVScrollBar: THCRichScrollBar;
    FRows: THCTableRows;
    FColWidths: TList<Integer>;
    FColDefaultWidth, FViewWidth, FViewHeight,
    FDispFirstRow, FDispLastRow, FDispFirstCol, FDispLastCol,
    FMouseDownRow, FMouseDownCol, FMouseMoveRow, FMouseMoveCol,
    FMouseDownX, FMouseDownY,
    FUpdateCount: Integer;

    FBorderWidth,  // �߿���
    FCellHPadding,  // ��Ԫ������ˮƽƫ��
    FCellVPadding,   // ��Ԫ�����ݴ�ֱƫ��(���ܴ�����͵�DrawItem�߶ȣ������Ӱ���ҳ)
    FGripSize
      : Byte;  // ��Ԫ�����ݺ͵�Ԫ��߿�ľ���

    FOutsideInfo: TOutsideInfo;  // ����ڱ�����ұ�ʱ��Ӧ������Ϣ
    FResizeInfo: TResizeInfo;

    FIsChange, FMouseLBDowning, FOutSelectInto,
    FResizing, FSelecting, FDraging, FLastChangeFormated: Boolean;
    FOnVerScroll, FOnHorScroll, FOnCaretChange, FOnChange, FOnChangeSwitch: TNotifyEvent;
    FSelectCellRang: TSelectCellRang;
    FOnPaintBackground: THCGridPaintEvent;
    FOnCellPaintBackground: THCColumnPaintEvent;

    /// <summary> ����������ʱ </summary>
    procedure DoRowAdd(const ARow: THCTableRow);
    procedure InitializeMouseInfo;
    procedure InitializeCellData(const ACellData: THCTableCellData);
    procedure DoDataChanged(Sender: TObject);
    procedure DoHorScroll(Sender: TObject; ScrollCode: TScrollCode;
      const ScrollPos: Integer);
    procedure DoVerScroll(Sender: TObject; ScrollCode: TScrollCode;
      const ScrollPos: Integer);
    function GetCell(const ARow, ACol: Integer): THCTableCell;
    function GetRowAt(const X, Y: Integer): THCTableRow;
    function GetRowIndexAt(const X, Y: Integer): Integer;
    function GetColIndexAt(const X, Y: Integer): Integer;
    procedure GetCellIndex(const X, Y: Integer; var ARow, ACol: Integer);
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
    //
    function GetHorOffset: Integer;
    function GetVerOffset: Integer;
    procedure SetBorderWidth(const Value: Byte);
    procedure SetCellHPadding(const Value: Byte);
    procedure SetCellVPadding(const Value: Byte);
    procedure SetIsChanged(const Value: Boolean);
    procedure GetViewWidth;
    procedure GetViewHeight;
    procedure CalcDisplayCellRange;
    procedure CalcScrollRang;
    function GetViewRect: TRect;
    function GetActiveCellRect: TRect;
    function GetCellRect(const ARow, ACol: Integer): TRect;
    function GetRowCount: Integer;
    function GetColCount: Integer;
    procedure UpdateView; overload;
    procedure UpdateView(const ARect: TRect); overload;
    procedure DoCaretChange;
    /// <summary> ���»�ȡ���λ�� </summary>
    procedure ReBuildCaret;
    procedure CheckUpdateInfo;
    // ����������ط���
    function DoSelfUndoNew: THCUndo;
    procedure DoSelfUndoDestroy(const AUndo: THCUndo);
    procedure DoSelfUndo(const AUndo: THCUndo);
    procedure DoSelfRedo(const ARedo: THCUndo);
    procedure Undo_ColResize(const ACol, AOldWidth, ANewWidth: Integer);
    procedure Undo_RowResize(const ARow, AOldHeight, ANewHeight: Integer);
    procedure Undo_MergeCells;
    //
    procedure PaintTo(const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure CellChangeByAction(const ARow, ACol: Integer; const AProcedure: THCProcedure);
    procedure DoMapChanged;
    procedure FormatRow(const ARow: Integer);
    procedure CalcRowCellHeight(const ARow: Integer);
    function CoordInSelect(const X, Y: Integer): Boolean;
    procedure Format;
    function ActiveDataResizing: Boolean;
    /// <summary> ȡ��ѡ�з�Χ�ڳ�ARow, ACol֮�ⵥԪ���ѡ��״̬(-1��ʾȫ��ȡ��) </summary>
    procedure DisSelectSelectedCell(const ARow: Integer = -1; const ACol: Integer = -1);
  protected
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
    /// <summary> ��ӦTab���ͷ���� </summary>
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMERASEBKGND(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    // �������뷨���������
    procedure WMImeComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    // Imm
    procedure UpdateImmPosition;
    //
    procedure Resize; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    procedure Paint; override;
    /// <summary> ��Ԫ����Ʊ��� </summary>
    procedure DoCellPaintBackground(Sender: TObject; const ACell: THCTableCell;
      const ACanvas: TCanvas; const ARect: TRect);
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEx(AOwner: TComponent; const ARowCount, AColCount: Integer);
    destructor Destroy; override;
    function ContentHeight: Integer;
    function ContentWidth: Integer;
    /// <summary> ��ʼ�������� </summary>
    procedure BeginUpdate;
    /// <summary> ������������ </summary>
    procedure EndUpdate;
    function GetEditCell: THCTableCell; overload;
    procedure GetEditCell(var ARow, ACol: Integer); overload;
    procedure DisSelect;

    property Cells[const Row, Col: Integer]: THCTableCell read GetCell;
    property HorOffset: Integer read GetHorOffset;
    property VerOffset: Integer read GetVerOffset;
    property BorderWidth: Byte read FBorderWidth write SetBorderWidth;
    property CellHPadding: Byte read FCellHPadding write SetCellHPadding;
    property CellVPadding: Byte read FCellVPadding write SetCellVPadding;
    property RowCount: Integer read GetRowCount;
    property ColCount: Integer read GetColCount;
    //
    property OnPaintBackground: THCGridPaintEvent read FOnPaintBackground write FOnPaintBackground;
    property OnCellPaintBackground: THCColumnPaintEvent read FOnCellPaintBackground write FOnCellPaintBackground;
    /// <summary> ��ֱ����������ʱ���� </summary>
    property OnVerScroll: TNotifyEvent read FOnVerScroll write FOnVerScroll;

    /// <summary> ˮƽ����������ʱ���� </summary>
    property OnHorScroll: TNotifyEvent read FOnHorScroll write FOnHorScroll;

    /// <summary> ���λ�øı�ʱ���� </summary>
    property OnCaretChange: TNotifyEvent read FOnCaretChange write FOnCaretChange;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChangeSwitch: TNotifyEvent read FOnChangeSwitch write FOnChangeSwitch;
  end;

  THCGridView = class(THCCustomGridView)
  public
    property Color;
    property OnMouseWheel;
  end;

implementation

uses
  Math, Imm;

{ THCCustomGridView }

constructor THCCustomGridView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBitmap := TBitmap.Create;
  Self.Color := clWhite;
  FUpdateCount := 0;
  FColDefaultWidth := 50;
  FDispFirstRow := -1;
  FDispLastRow := -1;
  FDispFirstCol := -1;
  FDispLastCol := -1;
  FBorderWidth := 1;
  FCellHPadding := 2;
  FCellVPadding := 2;
  FGripSize := 2;

  FStyle := THCStyle.CreateEx(True, True);
  FStyle.ShowParaLastMark := False;
  //FStyle.OnInvalidateRect := DoStyleInvalidateRect;

  FRows := THCTableRows.Create;
  FRows.OnRowAdd := DoRowAdd;  // �����ʱ�������¼�
  FColWidths := TList<Integer>.Create;
  FSelectCellRang := TSelectCellRang.Create;
  InitializeMouseInfo;

  FHScrollBar := THCScrollBar.Create(Self);
  FHScrollBar.OnScroll := DoHorScroll;
  FHScrollBar.Parent := Self;

  FVScrollBar := THCRichScrollBar.Create(Self);
  FVScrollBar.Orientation := TOrientation.oriVertical;
  FVScrollBar.OnScroll := DoVerScroll;
  FVScrollBar.Parent := Self;

  FIsChange := False;
  FLastChangeFormated := False;
end;

constructor THCCustomGridView.CreateEx(AOwner: TComponent; const ARowCount,
  AColCount: Integer);
var
  i: Integer;
  vRow: THCTableRow;
begin
  Create(AOwner);

  for i := 0 to ARowCount - 1 do
  begin
    vRow := THCTableRow.Create(FStyle, AColCount);
    FRows.Add(vRow);
  end;

  for i := 0 to AColCount - 1 do
    FColWidths.Add(FColDefaultWidth);

  Format;
end;

procedure THCCustomGridView.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
  begin
    if Assigned(FCaret) then
      FreeAndNil(FCaret);

    FCaret := THCCaret.Create(Handle);
  end;
end;

procedure THCCustomGridView.CellChangeByAction(const ARow, ACol: Integer;
  const AProcedure: THCProcedure);
var
  vCell: THCTableCell;
begin
  vCell := Cells[ARow, ACol];
  if Assigned(vCell) then
  begin
    if not vCell.CellData.CanEdit then Exit;

    AProcedure;

    if vCell.CellData.FormatHeightChange
      or vCell.CellData.FormatDrawItemChange
    then
    begin
      FLastChangeFormated := True;
      CalcRowCellHeight(ARow);
      {if FActiveData = FPageData then
        BuildSectionPages(FActiveData.FormatStartDrawItemNo)
      else
        BuildSectionPages(FSelectInfo.StartRow);}
    end;

    DoDataChanged(Self);
  end;
end;

function THCCustomGridView.ActiveDataResizing: Boolean;
begin
  Result := False;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.SelectedResizing;
end;

procedure THCCustomGridView.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure THCCustomGridView.CalcDisplayCellRange;
var
  vPos, i: Integer;
begin
  FDispFirstRow := -1;
  FDispLastRow := -1;
  FDispFirstCol := -1;
  FDispLastCol := -1;

  vPos := 0;
  for i := 0 to FRows.Count - 1 do
  begin
    vPos := vPos + FBorderWidth + FRows[i].Height;
    if (FDispFirstRow < 0) and (vPos > FVScrollBar.Position) then  // �еײ�����ʾ(�����ײ��߿�)
      FDispFirstRow := i;

    if vPos + FBorderWidth - FVScrollBar.Position >= Self.Height then
    begin
      FDispLastRow := i;
      Break;
    end;
  end;

  if FDispLastRow < 0 then
    FDispLastRow := FRows.Count - 1;

  vPos := 0;
  for i := 0 to FColWidths.Count - 1 do
  begin
    vPos := vPos + FBorderWidth + FColWidths[i];
    if (FDispFirstCol < 0) and (vPos > FHScrollBar.Position) then
      FDispFirstCol := i;

    if vPos + FBorderWidth - FHScrollBar.Position >= Self.Width then
    begin
      FDispLastCol := i;
      Break;
    end;
  end;

  if FDispLastCol < 0 then
    FDispLastCol := FColWidths.Count - 1;
end;

procedure THCCustomGridView.CalcRowCellHeight(const ARow: Integer);
var
  vNorHeightMax: Integer;
  vC: Integer;
  vCell: THCTableCell;
begin
  vNorHeightMax := 0;
  for vC := 0 to FColWidths.Count - 1 do
  begin
    vCell := FRows[ARow][vC];
    if Assigned(vCell.CellData) and (vCell.RowSpan = 0) then
      vNorHeightMax := Max(vNorHeightMax, vCell.CellData.Height);
  end;

  vNorHeightMax := vNorHeightMax + FCellVPadding + FCellVPadding;
  for vC := 0 to FColWidths.Count - 1 do
    FRows[ARow][vC].Height := vNorHeightMax;

  if FRows[ARow].AutoHeight then
    FRows[ARow].Height := vNorHeightMax
  else  // �϶��ı����и߶�
  begin
    if vNorHeightMax > FRows[ARow].Height then  // �϶��߶�ʧЧ
    begin
      FRows[ARow].AutoHeight := True;
      FRows[ARow].Height := vNorHeightMax;
    end;
  end;
end;

procedure THCCustomGridView.CalcScrollRang;
begin
  FVScrollBar.Max := ContentHeight;
  FHScrollBar.Max := ContentWidth;
end;

procedure THCCustomGridView.CheckUpdateInfo;
begin
  if FUpdateCount > 0 then Exit;

  if Assigned(FCaret) and FStyle.UpdateInfo.ReCaret then
  begin
    ReBuildCaret;
    FStyle.UpdateInfo.ReCaret := False;

    UpdateImmPosition;
  end;

  if FStyle.UpdateInfo.RePaint then
  begin
    FStyle.UpdateInfo.RePaint := False;
    UpdateView;
  end;
end;

function THCCustomGridView.ContentHeight: Integer;
var
  i: Integer;
begin
  Result := FBorderWidth;
  for i := 0 to FRows.Count - 1 do
    Result := Result + FRows[i].Height + FBorderWidth;
end;

function THCCustomGridView.ContentWidth: Integer;
var
  i: Integer;
begin
  Result := FBorderWidth;
  for i := 0 to FColWidths.Count - 1 do
    Result := Result + FColWidths[i] + FBorderWidth;
end;

function THCCustomGridView.CoordInSelect(const X, Y: Integer): Boolean;
var
  vCellData: THCTableCellData;
  vX, vY, vItemNo, vDrawItemNo, vOffset, vRow, vCol: Integer;
  vRestrain: Boolean;
  vResizeInfo: TResizeInfo;
  vRect: TRect;
begin
  Result := False;

  vResizeInfo := GetCellAt(X, Y, vRow, vCol);  // ���괦��Ϣ
  if vResizeInfo.TableSite = TTableSite.tsCell then  // �ڵ�Ԫ���У��жϵ�Ԫ���Ƿ���ѡ�з�Χ��
  begin
    if FSelectCellRang.StartRow >= 0 then  // ��ѡ����ʼ��
    begin
      if FSelectCellRang.EndRow >= 0 then  // ��ѡ�������
      begin
        Result := (vRow >= FSelectCellRang.StartRow)
              and (vRow <= FSelectCellRang.EndRow)
              and (vCol >= FSelectCellRang.StartCol)
              and (vCol <= FSelectCellRang.EndCol);
      end
      else  // ��ѡ������У��ж��Ƿ��ڵ�ǰ��Ԫ���ѡ����
      begin
        vCellData := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData;
        if vCellData.SelectExists then
        begin
          vRect := GetCellRect(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
          vX := X - vRect.Left - FCellHPadding;
          vY := Y - vRect.Top - FCellVPadding;
          vCellData.GetItemAt(vX, vY, vItemNo, vOffset, vDrawItemNo, vRestrain);

          Result := vCellData.CoordInSelect(vX, vY, vItemNo, vOffset, vRestrain);
        end;
      end;
    end;
  end;
end;

destructor THCCustomGridView.Destroy;
begin
  FreeAndNil(FRows);
  FreeAndNil(FColWidths);
  FreeAndNil(FSelectCellRang);
  FreeAndNil(FBitmap);
  FreeAndNil(FHScrollBar);
  FreeAndNil(FVScrollBar);
  FreeAndNil(FStyle);
  FreeAndNil(FCaret);
  inherited Destroy;
end;

procedure THCCustomGridView.DisSelect;
begin
  DisSelectSelectedCell;

  Self.InitializeMouseInfo;
  FSelectCellRang.Initialize;

  FSelecting := False;
  FDraging := False;
  FOutSelectInto := False;
end;

procedure THCCustomGridView.DisSelectSelectedCell(const ARow: Integer = -1;
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

procedure THCCustomGridView.DoCaretChange;
begin
  if Assigned(FOnCaretChange) then
    FOnCaretChange(Self);
end;

procedure THCCustomGridView.DoCellPaintBackground(Sender: TObject;
  const ACell: THCTableCell; const ACanvas: TCanvas; const ARect: TRect);
begin
  if Assigned(FOnCellPaintBackground) then
    FOnCellPaintBackground(ACell, ACanvas, ARect);
end;

procedure THCCustomGridView.DoDataChanged(Sender: TObject);
begin
  SetIsChanged(True);
  DoMapChanged;
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

procedure THCCustomGridView.DoHorScroll(Sender: TObject;
  ScrollCode: TScrollCode; const ScrollPos: Integer);
begin
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret(False);
  CheckUpdateInfo;
  if Assigned(FOnHorScroll) then
    FOnHorScroll(Self);
end;

procedure THCCustomGridView.DoMapChanged;
begin
  if FUpdateCount = 0 then
  begin
    CalcScrollRang;
    CheckUpdateInfo;
  end;
end;

function THCCustomGridView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  if ssCtrl in Shift then
    FHScrollBar.Position := FHScrollBar.Position - WheelDelta
  else
    FVScrollBar.Position := FVScrollBar.Position - WheelDelta;

  Result := True;
end;

procedure THCCustomGridView.DoRowAdd(const ARow: THCTableRow);
var
  i: Integer;
  vCellData: THCTableCellData;
begin
  for i := 0 to ARow.ColCount - 1 do
  begin
    vCellData := ARow.Cols[i].CellData;
    if vCellData <> nil then
      InitializeCellData(vCellData);
  end;
end;

procedure THCCustomGridView.DoSelfRedo(const ARedo: THCUndo);
begin

end;

procedure THCCustomGridView.DoSelfUndo(const AUndo: THCUndo);
begin

end;

procedure THCCustomGridView.DoSelfUndoDestroy(const AUndo: THCUndo);
begin

end;

function THCCustomGridView.DoSelfUndoNew: THCUndo;
begin

end;

procedure THCCustomGridView.DoVerScroll(Sender: TObject;
  ScrollCode: TScrollCode; const ScrollPos: Integer);
begin
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReCaret(False);
  CheckUpdateInfo;
  if Assigned(FOnVerScroll) then
    FOnVerScroll(Self);
end;

procedure THCCustomGridView.EndUpdate;
begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  DoMapChanged;
end;

procedure THCCustomGridView.Format;
var
  vR: Integer;
begin
  for vR := 0 to FRows.Count - 1 do
  begin
    FormatRow(vR);
    CalcRowCellHeight(vR);
  end;

  //CalcMergeRowHeightFrom(0);
end;

procedure THCCustomGridView.FormatRow(const ARow: Integer);
var
  vC: Integer;
  vCell: THCTableCell;
begin
  for vC := 0 to FColWidths.Count - 1 do
  begin
    vCell := FRows[ARow][vC];
    vCell.Width := FColWidths[vC];
    if Assigned(vCell.CellData) then
    begin
      vCell.CellData.Width := vCell.Width - FCellHPadding - FCellHPadding;
      vCell.CellData.ReFormat;
    end;
  end;
end;

function THCCustomGridView.GetActiveCellRect: TRect;
begin
  Result := GetCellRect(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
end;

function THCCustomGridView.GetCell(const ARow, ACol: Integer): THCTableCell;
begin
  Result := FRows[ARow][ACol];
end;

function THCCustomGridView.GetCellAt(const X, Y : Integer; var ARow, ACol: Integer;
  const AReDest: Boolean = True): TResizeInfo;

  {$REGION 'CheckRowBorderRang'}
  function CheckRowBorderRang(const ABottom: Integer): Boolean;
  begin
    Result := (Y >= ABottom - FGripSize) and (Y <= ABottom + FGripSize);  // �Ƿ����б߿�����
  end;
  {$ENDREGION}

  {$REGION 'CheckColBorderRang'}
  function CheckColBorderRang(const ALeft: Integer): Boolean;
  begin
    Result := (X >= ALeft - FGripSize) and (X <= ALeft + FGripSize);  // �Ƿ����б߿�����
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

  if (Y < 0) or (Y > FViewHeight) then Exit;

  if (X < 0) or (X > FViewWidth) then  // ���ڱ����ʱ���ж϶�Ӧλ�õ��У������ʹ��
  begin
    vTop := FBorderWidth - FVScrollBar.Position;
    for i := 0 to RowCount - 1 do
    begin
      vTop := vTop + FRows[i].FmtOffset;  // ��ʵ������TopΪ��λ�ã��������п�ҳʱ������һҳ�ײ����ѡ�е�����һҳ��һ��
      vBottom := vTop + FRows[i].Height;

      if (vTop < Y) and (vBottom > Y) then  // �ڴ�����
      begin
        ARow := i;
        Break;
      end;
      vTop := vBottom + FBorderWidth;
    end;

    Exit;
  end;

  { ��ȡ�Ƿ����л��еı߿��� }
  // �ж��Ƿ������ϱ߿�
  vTop := FBorderWidth - FVScrollBar.Position;
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
  vLeft := FBorderWidth - FHScrollBar.Position;
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

procedure THCCustomGridView.GetCellIndex(const X, Y: Integer; var ARow,
  ACol: Integer);
begin
  ARow := GetRowIndexAt(X, Y);
  if ARow >= 0 then
    ACol := GetColIndexAt(X, Y)
  else
    ACol := -1;
end;

function THCCustomGridView.GetCellRect(const ARow, ACol: Integer): TRect;
var
  i, vBorderHalf, vRow, vCol: Integer;
begin
  GetDestCell(ARow, ACol, vRow, vCol);

  vBorderHalf := FBorderWidth div 2;

  Result.Top := 0;
  for i := 0 to vRow - 1 do
    Result.Top := Result.Top + FBorderWidth + FRows[i].Height;

  Result.Top := Result.Top + vBorderHalf - FVScrollBar.Position;

  Result.Left := 0;
  for i := 0 to vCol - 1 do
    Result.Left := Result.Left + FBorderWidth + FColWidths[i];

  Result.Left := Result.Left + vBorderHalf - FHScrollBar.Position;

  Result.Right := Result.Left + FColWidths[vCol];

  if FRows[vRow][vCol].RowSpan = 0 then
    Result.Bottom := Result.Top + FRows[vRow].Height
  else
    Result.Bottom := Result.Top + FRows[vRow][vCol].Height;
end;

function THCCustomGridView.GetColCount: Integer;
begin
  Result := FColWidths.Count;
end;

function THCCustomGridView.GetColIndexAt(const X, Y: Integer): Integer;
var
  i, vLeft: Integer;
begin
  Result := -1;

  vLeft := FBorderWidth - FHScrollBar.Position;
  for i := 0 to FColWidths.Count - 1 do
  begin
    if (X > vLeft) and (X < vLeft + FColWidths[i]) then
    begin
      Result := i;
      Break;
    end;

    vLeft := vLeft + FColWidths[i] + FBorderWidth;
  end;
end;

procedure THCCustomGridView.GetDestCell(const ARow, ACol: Cardinal;
  var ADestRow, ADestCol: Integer);
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

procedure THCCustomGridView.GetEditCell(var ARow, ACol: Integer);
begin
  ARow := -1;
  ACol := -1;
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
  begin
    ARow := FSelectCellRang.StartRow;
    ACol := FSelectCellRang.StartCol;
  end;
end;

function THCCustomGridView.GetEditCell: THCTableCell;
begin
  if FSelectCellRang.EditCell then  // ��ͬһ��Ԫ���б༭
    Result := Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol]
  else
    Result := nil;
end;

function THCCustomGridView.GetHorOffset: Integer;
begin
  Result := FHScrollBar.Position;
end;

function THCCustomGridView.GetRowAt(const X, Y: Integer): THCTableRow;
var
  vRow: Integer;
begin
  Result := nil;
  vRow := GetRowIndexAt(X, Y);
  if vRow >= 0 then
    Result := FRows[vRow];
end;

function THCCustomGridView.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function THCCustomGridView.GetRowIndexAt(const X, Y: Integer): Integer;
var
  i, vTop: Integer;
begin
  Result := -1;

  vTop := FBorderWidth - FVScrollBar.Position;
  for i := 0 to FRows.Count - 1 do
  begin
    if (Y > vTop) and (Y < vTop + FRows[i].Height) then
    begin
      Result := i;
      Break;
    end;

    vTop := vTop + FRows[i].Height + FBorderWidth;
  end;
end;

procedure THCCustomGridView.GetSourceCell(const ARow, ACol: Cardinal;
  var ASrcRow, ASrcCol: Integer);
begin
  if Cells[ARow, ACol].CellData <> nil then
  begin
    ASrcRow := ARow + FRows[ARow][ACol].RowSpan;
    ASrcCol := ACol + FRows[ARow][ACol].ColSpan;
  end
  else  // Դ��Ԫ���ܻ�ȡԴ��Ԫ��
    raise Exception.Create(HCS_EXCEPTION_VOIDSOURCECELL);
end;

function THCCustomGridView.GetVerOffset: Integer;
begin
  Result := FVScrollBar.Position;
end;

procedure THCCustomGridView.GetViewHeight;
begin
  if FHScrollBar.Visible then
    FViewHeight := Height - FHScrollBar.Height
  else
    FViewHeight := Height;
end;

function THCCustomGridView.GetViewRect: TRect;
begin
  Result := Bounds(0, 0, FViewWidth, FViewHeight);
end;

procedure THCCustomGridView.GetViewWidth;
begin
  if FVScrollBar.Visible then
    FViewWidth := Width - FVScrollBar.Width
  else
    FViewWidth := Width;
end;

procedure THCCustomGridView.InitializeCellData(
  const ACellData: THCTableCellData);
begin

end;

procedure THCCustomGridView.InitializeMouseInfo;
begin
  FMouseDownRow := -1;
  FMouseDownCol := -1;
  FMouseMoveRow := -1;
  FMouseMoveCol := -1;
  FMouseLBDowning := False;
end;

procedure THCCustomGridView.KeyDown(var Key: Word; Shift: TShiftState);
var
  vOldKey: Word;
  vEditCell: THCTableCell;
begin
  vEditCell := GetEditCell;
  if Assigned(vEditCell) then
  begin
    if IsKeyDownWant(Key) then
    begin
      case Key of
        VK_BACK, VK_DELETE, VK_RETURN, VK_TAB:
          begin
            vOldKey := Key;
            CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
              procedure
              begin
                vEditCell.CellData.KeyDown(vOldKey, Shift);
              end);
            Key := vOldKey;
          end;

        VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END:
          begin
            vEditCell.CellData.KeyDown(Key, Shift);
            DoMapChanged;
          end;
      end;
    end;
  end
  else
    Key := 0;
end;

procedure THCCustomGridView.KeyPress(var Key: Char);
var
  vOldKey: Char;
  vEditCell: THCTableCell;
begin
  vEditCell := GetEditCell;
  if Assigned(vEditCell) and IsKeyPressWant(Key) then
  begin
    vOldKey := Key;
    CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
      procedure
      begin
        vEditCell.CellData.KeyPress(vOldKey);
      end);

    Key := vOldKey;
  end
  else
    Key := #0
end;

procedure THCCustomGridView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  vMouseDownRow, vMouseDownCol: Integer;
  vRect: TRect;
  vCell: THCTableCell;
begin
  inherited MouseDown(Button, Shift, X, Y);

  FMouseLBDowning := (Button = mbLeft) and (Shift = [ssLeft]);
  FOutSelectInto := False;
  FSelecting := False;  // ׼����ѡ
  FDraging := False;  // ׼����ק
  FOutsideInfo.Row := -1;

  FResizeInfo := GetCellAt(X, Y, vMouseDownRow, vMouseDownCol);

  FResizing := (Button = mbLeft) and (
    (FResizeInfo.TableSite = tsBorderRight) or (FResizeInfo.TableSite = tsBorderBottom));
  if FResizing then
  begin
    FMouseDownRow := vMouseDownRow;
    FMouseDownCol := vMouseDownCol;
    FMouseDownX := X;
    FMouseDownY := Y;
    FStyle.UpdateInfoRePaint;
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

      vRect := GetCellRect(FMouseDownRow, FMouseDownCol);
      FRows[FMouseDownRow][FMouseDownCol].CellData.MouseDown(Button, Shift,
        X - FCellHPadding - vRect.Left, Y - FCellVPadding - vRect.Top);
    end
    else  // ����ѡ��������
    begin
      // �����ִ�� DisSelect �����Mouse��Ϣ�����µ�ǰ�༭��Ԫ������Ӧȡ�������¼�
      if (vMouseDownRow <> FMouseDownRow) or (vMouseDownCol <> FMouseDownCol) then  // ��λ��
      begin
        vCell := GetEditCell;
        if vCell <> nil then  // ȡ��ԭ���༭
          vCell.Active := False;

        FStyle.UpdateInfoReCaret;
      end;

      DisSelect;  // ���ԭѡ��

      FMouseDownRow := vMouseDownRow;
      FMouseDownCol := vMouseDownCol;

      FSelectCellRang.SetStart(FMouseDownRow, FMouseDownCol);

      vRect := GetCellRect(FMouseDownRow, FMouseDownCol);
      FRows[FMouseDownRow][FMouseDownCol].CellData.MouseDown(Button, Shift,
        X - FCellHPadding - vRect.Left, Y - FCellVPadding - vRect.Top);
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

  CheckUpdateInfo;
end;

procedure THCCustomGridView.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vMoveRow, vMoveCol: Integer;

  {$REGION 'AdjustSelectRang'}
  procedure AdjustSelectRang;
  var
    vR, vC: Integer;
  begin
    // �������ʼ��Ԫ��֮��ģ��Ա��������´���ѡ�е�Ԫ���ȫѡ
    if FSelectCellRang.StartRow >= 0 then
    begin
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          if ((vR = FMouseDownRow) and (vC = FMouseDownCol))
            //or ((vRow = vMoveRow) and (vCol = vMoveCol))
          then  // ������ǰ���µ�ѡ����Ϣ����ֹ�ص������������ݵ�ѡ��

          else
          begin
            if Cells[vR, vC].CellData <> nil then
              Cells[vR, vC].CellData.DisSelect;
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

        FSelectCellRang.SetStart(FMouseDownRow, FMouseDownCol);
        FSelectCellRang.SetEnd(vMoveRow, vMoveCol);
      end
      else  // ������ѡ��
      begin
        GetDestCell(Self.RowCount - 1, Self.FColWidths.Count - 1, vR, vC);
        FMouseDownRow := vR;
        FMouseDownCol := vC;

        FSelectCellRang.SetStart(vMoveRow, vMoveCol);
        FSelectCellRang.SetEnd(FMouseDownRow, FMouseDownCol);
      end;

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
      FSelectCellRang.InitilazeEnd
    else
    begin
      if FRows[FSelectCellRang.StartRow].Cols[FSelectCellRang.StartCol].IsMergeSource then  // ��ʼѡ���ںϲ�Դ
      begin
        GetDestCell(FSelectCellRang.StartRow, FSelectCellRang.StartCol, vR, vC);
        FSelectCellRang.SetStart(vR, vC);
      end;

      if FRows[FSelectCellRang.EndRow].Cols[FSelectCellRang.EndCol].IsMergeDest then  // �����ںϲ�Ŀ��
      begin
        GetSourceCell(FSelectCellRang.EndRow, FSelectCellRang.EndCol, vR, vC);  // ��ȡĿ�귽��������ݵ���Ŀ��õ�����Դ
        FSelectCellRang.SetEnd(vR, vC);
      end;

      if (FSelectCellRang.StartRow = FSelectCellRang.EndRow)
        and (FSelectCellRang.StartCol = FSelectCellRang.EndCol)
      then  // �����ϲ�����ͬһ��Ԫ��
        FSelectCellRang.InitilazeEnd
    end;
  end;
  {$ENDREGION}

  {$REGION 'MatchCellSelectState'}
  procedure MatchCellSelectState;
  var
    vR, vC: Integer;
  begin
    if not FSelectCellRang.EditCell then
    begin
      for vR := FSelectCellRang.StartRow to FSelectCellRang.EndRow do
      begin
        for vC := FSelectCellRang.StartCol to FSelectCellRang.EndCol do
        begin
          {if (vRow = vMoveRow) and (vCol = vMoveCol) then else ʲô�������Ҫ����?}
          if Cells[vR, vC].CellData <> nil then
            Cells[vR, vC].CellData.SelectAll;
        end;
      end;
    end;
  end;
  {$ENDREGION}

var
  vRect: TRect;
  vResizeInfo: TResizeInfo;
begin
  inherited MouseMove(Shift, X, Y);
  if ActiveDataResizing then
  begin
    vRect := GetCellRect(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    Cells[FSelectCellRang.StartRow, FSelectCellRang.StartCol].CellData.MouseMove(
      Shift, X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);

    Exit;
  end;

  if FResizing then  // (ssLeft in Shift)
  begin
    FResizeInfo.DestX := X;
    FResizeInfo.DestY := Y;
    FStyle.UpdateInfoRePaint;

    Exit;
  end;

  vResizeInfo := GetCellAt(X, Y, vMoveRow, vMoveCol);

  if vResizeInfo.TableSite = tsCell then  // ����ڵ�Ԫ����
  begin
    if FMouseLBDowning or (Shift = [ssLeft]) then  // ��������ƶ�������ʱ�ڱ���� or û���ڱ���ϰ���(��ѡ����)
    begin
      if FDraging or FStyle.UpdateInfo.Draging then
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
        vRect := GetCellRect(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);

        Exit;
      end;

      if not FSelecting then
        FSelecting := True;

      if (vMoveRow <> FMouseMoveRow) or (vMoveCol <> FMouseMoveCol) then  // ����ƶ����µ�Ԫ��
      begin
        FMouseMoveRow := vMoveRow;
        FMouseMoveCol := vMoveCol;
        FStyle.UpdateInfoReCaret;

        AdjustSelectRang;  // ����ѡ����ʼ������Χ(������Ӻ�����ǰѡ�����)
        MatchCellSelectState;  // ����ѡ�з�Χ�ڸ���Ԫ���ѡ��״̬
      end;

      {if (FSelectCellRang.StartRow = FMouseMoveRow)
        and (FSelectCellRang.StartCol = FMouseMoveCol)
      then}  // ѡ����ʼ��������ͬһ����Ԫ��
      begin
        vRect := GetCellRect(FMouseMoveRow, FMouseMoveCol);
        Cells[FMouseMoveRow, FMouseMoveCol].CellData.MouseMove(Shift,
          X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);
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

      vRect := GetCellRect(FMouseMoveRow, FMouseMoveCol);
      FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseMove(Shift,
        X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);
    end;
  end
  else  // ��겻�ڵ�Ԫ����
  begin
    if (FMouseMoveRow >= 0) and (FMouseMoveCol >= 0) then
    begin
      if FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData <> nil then
        FRows[FMouseMoveRow].Cols[FMouseMoveCol].CellData.MouseLeave;  // �ɵ�Ԫ���Ƴ�
    end;

    FMouseMoveRow := -1;
    FMouseMoveCol := -1;

    if vResizeInfo.TableSite = tsBorderRight then // ��겻�ڵ�Ԫ����
      GCursor := crHSplit
    else
    if vResizeInfo.TableSite = tsBorderBottom then
      GCursor := crVSplit;
  end;

  CheckUpdateInfo;
end;

procedure THCCustomGridView.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vUpRow, vUpCol: Integer;
  vRect: TRect;
  vPt: TPoint;
  vResizeInfo: TResizeInfo;
begin
  inherited MouseUp(Button, Shift, X, Y);;

  if Button = mbRight then Exit;  // �Ҽ������˵�

  FMouseLBDowning := False;

  if ActiveDataResizing then
  begin
    vRect := GetCellRect(FSelectCellRang.StartRow, FSelectCellRang.StartCol);
    FRows[FSelectCellRang.StartRow][FSelectCellRang.StartCol].CellData.MouseUp(
      Button, Shift, X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);

    Exit;
  end;

  if FResizing then  // �϶��ı��п���Ԫ��Data��ȵĸı������¸�ʽ������
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
      vPt.Y := Y - FMouseDownY;  // ��ʹ��FResizeInfo.DestY(����ɰ��´�����Ҳ��ƫ��)
      if vPt.Y <> 0 then
      begin
        Undo_RowResize(FMouseDownRow, FRows[FMouseDownRow].Height, FRows[FMouseDownRow].Height + vPt.Y);
        FRows[FMouseDownRow].Height := FRows[FMouseDownRow].Height + vPt.Y;
        FRows[FMouseDownRow].AutoHeight := False;
       end;
    end;

    FLastChangeFormated := False;
    FResizing := False;
    GCursor := crDefault;
    FStyle.UpdateInfoRePaint;
    FStyle.UpdateInfoReCaret;

    Exit;
  end;

  if FSelecting or FStyle.UpdateInfo.Selecting then  // ��ѡ���
  begin
    FSelecting := False;

    // ���ڰ��µ�Ԫ�����Ա㵥Ԫ����Ƕ�׵ı���л�����Ӧ����(ȡ�����¡���ѡ״̬����ѡ���)
    if (FMouseDownRow >= 0) and (not FOutSelectInto) then  // �ڱ���Ҳఴ���ƶ�ʱ�ٵ���ʱ����Ч��FMouseDownRow��FMouseDownCol
    begin
      vRect := GetCellRect(FMouseDownRow, FMouseDownCol);
      Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
        X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);
    end;

    vResizeInfo := GetCellAt(X, Y, vUpRow, vUpCol);
    if vResizeInfo.TableSite = TTableSite.tsCell then  // û�л�ѡ��ҳ��հ׵ĵط�
    begin
      if (vUpRow <> FMouseDownRow) or (vUpCol <> FMouseDownCol) then  // ��ѡ��ɺ����ڷǰ��µ�Ԫ��
      begin
        vRect := GetCellRect(vUpRow, vUpCol);
        Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
          X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);
      end;
    end;
  end
  else
  if FDraging or FStyle.UpdateInfo.Draging then  // ��ק����
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
      vRect := GetCellRect(vUpRow, vUpCol);
      Cells[vUpRow, vUpCol].CellData.MouseUp(Button, Shift,
        X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);

      {if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��(����ǻ�ѡ��Χ������һ��������������ק�������ʱû�а���FMouseDownRow)
        Cells[FMouseDownRow, FMouseDownCol].CellData.InitializeField;}  // ��ק��ʼ��Ԫ�������ק�����
    end;
  end
  else  // �ǻ�ѡ������ק
  if FMouseDownRow >= 0 then  // �е��ʱ�ĵ�Ԫ��
  begin
    vRect := GetCellRect(FMouseDownRow, FMouseDownCol);
    Cells[FMouseDownRow, FMouseDownCol].CellData.MouseUp(Button, Shift,
      X - vRect.Left - FCellHPadding, Y - vRect.Top - FCellVPadding);
  end;

  CheckUpdateInfo;  // ��ѡ�������а��²��ƶ��������ʱ��Ҫ����

  FStyle.UpdateInfo.Selecting := False;
  FStyle.UpdateInfo.Draging := False;
end;

procedure THCCustomGridView.Paint;
begin
  inherited Paint;
  BitBlt(Canvas.Handle, 0, 0, FViewWidth, FViewHeight,
    FBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  Canvas.Brush.Color := Self.Color;
  Canvas.FillRect(Bounds(FVScrollBar.Left, FHScrollBar.Top, FVScrollBar.Width, FHScrollBar.Height));
end;

procedure THCCustomGridView.PaintTo(const ACanvas: TCanvas;
  const APaintInfo: TPaintInfo);

  function CreatExtPen: HPen;
  var
    APenParams: TLogBrush;
  const
    PenTypes: array[Boolean] of Integer = (PS_COSMETIC, PS_GEOMETRIC);
    //PenStyles: array[psSolid..psInsideFrame] of Word =
    //  (PS_SOLID, PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT, PS_NULL, PS_SOLID);
  begin
    APenParams.lbStyle := BS_SOLID;
    APenParams.lbColor := ACanvas.Pen.Color;
    APenParams.lbHatch := 0;
    Result := ExtCreatePen(PenTypes[FBorderWidth <> 1] or PS_ENDCAP_SQUARE,
      FBorderWidth, APenParams, 0, nil);
  end;

var
  vRect: TRect;
  vR, vC, vLeft, vTop, vRight, vBottom, vPaintLeft, vBorderHalf: Integer;
  vCell: THCTableCell;
  //vExtPen: ^TExtLogPen;
  vExtPen: HPEN;
  vOldPen: HGDIOBJ;
begin
  vRect := GetViewRect;
  if Assigned(FOnPaintBackground) then
    FOnPaintBackground(ACanvas, vRect)
  else
  begin
    ACanvas.Brush.Color := Self.Color;
    ACanvas.FillRect(vRect);
  end;
  //
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Width := FBorderWidth;
  if GetObjectType(ACanvas.Pen.Handle) = OBJ_EXTPEN then
  begin
    vExtPen := ACanvas.Pen.Handle;
    //vBottom := GetObject(ACanvas.Pen.Handle, 0, nil);
    //GetObject(ACanvas.Pen.Handle, vBottom, vExtPen);
  end
  else
    vExtPen := CreatExtPen;  // ��ΪĬ�ϵĻ���û����ñ�Ŀ��ƣ�����֧����ñ�Ļ���

  vBorderHalf := FBorderWidth div 2;
  vTop := 0;
  for vR := 0 to FDispFirstRow - 1 do
    vTop := vTop + FBorderWidth + FRows[vR].Height;

  vTop := vTop + vBorderHalf - FVScrollBar.Position;

  vPaintLeft := 0;
  for vC := 0 to FDispFirstCol - 1 do
    vPaintLeft := vPaintLeft + FBorderWidth + FColWidths[vC];

  vPaintLeft := vPaintLeft + vBorderHalf - FHScrollBar.Position;

  vLeft := vPaintLeft;
  for vR := FDispFirstRow to FDispLastRow do
  begin
    for vC := FDispFirstCol to FDispLastCol do
    begin
      vCell := Cells[vR, vC];
      if Assigned(vCell.CellData) then
      begin
        if vCell.ColSpan = 0 then
          vRight := vLeft + FBorderWidth + FColWidths[vC]
        else
          vRight := vLeft + FBorderWidth + vCell.Width;

        if vCell.RowSpan = 0 then
          vBottom := vTop + FBorderWidth + FRows[vR].Height
        else
          vBottom := vTop + FBorderWidth + vCell.Height;

        vRect := Rect(vLeft + vBorderHalf, vTop + vBorderHalf, vRight, vBottom);

        if vCell.CellData.CellSelectedAll and (not APaintInfo.Print) then
        begin
          ACanvas.Brush.Color := FStyle.SelColor;
          ACanvas.FillRect(vRect);
        end
        else
        begin
          if vCell.BackgroundColor <> HCTransparentColor then
            ACanvas.Brush.Color := vCell.BackgroundColor
          else
            ACanvas.Brush.Style := bsClear;

          if Assigned(FOnCellPaintBackground) then  // �����Զ��屳��
            FOnCellPaintBackground(vCell, ACanvas, vRect)
          else
            ACanvas.FillRect(vRect);
        end;
        // ��������
        vCell.CellData.PaintData(vLeft + vBorderHalf + FCellHPadding,
          vTop + vBorderHalf + FCellVPadding,
          vTop + vBorderHalf + vCell.Height - FCellVPadding,
          0, Self.Height,
          0, 0, vCell.CellData.DrawItems.Count - 1, ACanvas, APaintInfo);
        // ���Ʊ߿�
        vOldPen := SelectObject(ACanvas.Handle, vExtPen);
        ACanvas.MoveTo(vLeft, vTop);
        ACanvas.LineTo(vRight, vTop);
        ACanvas.LineTo(vRight, vBottom);
        ACanvas.LineTo(vLeft, vBottom);
        ACanvas.LineTo(vLeft, vTop);
        SelectObject(ACanvas.Handle, vOldPen);
      end;

      vLeft := vLeft + FBorderWidth + FColWidths[vC];
    end;

    vTop := vTop + FBorderWidth + FRows[vR].Height;
    vLeft := vPaintLeft;
  end;

  DeleteObject(vExtPen);
end;

procedure THCCustomGridView.ReBuildCaret;
var
  vCaretInfo: THCCaretInfo;
  vRect: TRect;
var
  i, vTop, vBottom, vRow, vCol: Integer;
  vPos: TPoint;
  vCaretCell: THCTableCell;
begin
  if not Assigned(FCaret) then Exit;

  if not Self.Focused then
  begin
    FCaret.Hide;
    Exit;
  end;

  if FStyle.UpdateInfo.Draging then  // ��ק
  begin
    vRow := FMouseMoveRow;
    vCol := FMouseMoveCol;
  end
  else  // ����ק
  begin
    vRow := FSelectCellRang.StartRow;
    vCol := FSelectCellRang.StartCol;
  end;

  if (vRow < 0) or (vCol < 0) then
  begin
    FCaret.Hide;
    Exit;
  end;

  if FSelectCellRang.SelectExists then
  begin
    FCaret.Hide;
    Exit;
  end;

  vCaretInfo.X := 0;
  vCaretInfo.Y := 0;
  vCaretInfo.Height := 0;
  vCaretInfo.Visible := True;

  vCaretCell := FRows[vRow][vCol];

  if FStyle.UpdateInfo.Draging then  // ��ק
  begin
    if (vCaretCell.CellData.MouseMoveItemNo < 0)
      or (vCaretCell.CellData.MouseMoveItemOffset < 0)
    then
    begin
      vCaretInfo.Visible := False;
      Exit;
    end;

    vCaretCell.GetCaretInfo(vCaretCell.CellData.MouseMoveItemNo,
      vCaretCell.CellData.MouseMoveItemOffset, vCaretInfo);
  end
  else  // ����ק
  if vCaretCell.CellData.SelectExists then  // ��ѡ��
  begin
    FCaret.Hide;
    Exit;
  end
  else  // ����ק����ѡ��
  begin
    if (vCaretCell.CellData.SelectInfo.StartItemNo < 0)
      or (vCaretCell.CellData.SelectInfo.StartItemOffset < 0)
    then
    begin
      FCaret.Hide;
      Exit;
    end;

    vCaretCell.GetCaretInfo(vCaretCell.CellData.SelectInfo.StartItemNo,
      vCaretCell.CellData.SelectInfo.StartItemOffset, vCaretInfo);
  end;

  if not vCaretInfo.Visible then
  begin
    FCaret.Hide;
    Exit;
  end;

  vRect := GetActiveCellRect;

  FCaret.X := vRect.Left + FCellHPadding + vCaretInfo.X;
  FCaret.Y := vRect.Top + FCellVPadding + vCaretInfo.Y;
  FCaret.Height := vCaretInfo.Height;
  FCaret.Show;
  DoCaretChange;
end;

procedure THCCustomGridView.Resize;
begin
  inherited Resize;
  GetViewWidth;
  GetViewHeight;
  FBitmap.SetSize(FViewWidth, FViewHeight);

  FVScrollBar.Left := Width - FVScrollBar.Width;
  FVScrollBar.Height := Height - FHScrollBar.Height;

  FHScrollBar.Top := Height - FHScrollBar.Height;
  FHScrollBar.Width := Width - FVScrollBar.Width;

  CalcScrollRang;

  FStyle.UpdateInfoRePaint;
  if FCaret <> nil then
    FStyle.UpdateInfoReCaret(False);
  CheckUpdateInfo;
end;

procedure THCCustomGridView.SetBorderWidth(const Value: Byte);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    Format;
    DoDataChanged(Self);
  end;
end;

procedure THCCustomGridView.SetCellHPadding(const Value: Byte);
begin
  if FCellHPadding <> Value then
  begin
    FCellHPadding := Value;
    Format;
    DoDataChanged(Self);
  end;
end;

procedure THCCustomGridView.SetCellVPadding(const Value: Byte);
begin
  if FCellVPadding <> Value then
  begin
    FCellVPadding := Value;
    Format;
    DoDataChanged(Self);
  end;
end;

procedure THCCustomGridView.SetIsChanged(const Value: Boolean);
begin
  if FIsChange <> Value then
  begin
    FIsChange := Value;
    if Assigned(FOnChangeSwitch) then
      FOnChangeSwitch(Self);
  end;
end;

procedure THCCustomGridView.Undo_ColResize(const ACol, AOldWidth,
  ANewWidth: Integer);
begin

end;

procedure THCCustomGridView.Undo_MergeCells;
begin

end;

procedure THCCustomGridView.Undo_RowResize(const ARow, AOldHeight,
  ANewHeight: Integer);
begin

end;

procedure THCCustomGridView.UpdateImmPosition;
var
  vhIMC: HIMC;
  vCF: TCompositionForm;
begin
  vhIMC := ImmGetContext(Handle);
  try
    vCF.ptCurrentPos := Point(FCaret.X, FCaret.Y + 5);
    vCF.dwStyle := CFS_RECT;
    vCF.rcArea := ClientRect;
    ImmSetCompositionWindow(vhIMC, @vCF);
  finally
    ImmReleaseContext(Handle, vhIMC);
  end;
end;

procedure THCCustomGridView.UpdateView(const ARect: TRect);
var
  vPaintInfo: TPaintInfo;
begin
  CalcDisplayCellRange;

  FBitmap.Canvas.Lock;
  try
    IntersectClipRect(FBitmap.Canvas.Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    vPaintInfo := TPaintInfo.Create;
    try
      vPaintInfo.ScaleX := 1;
      vPaintInfo.ScaleY := 1;
      vPaintInfo.Zoom := 1;
      vPaintInfo.WindowWidth := FViewWidth;
      vPaintInfo.WindowHeight := FViewHeight;

      PaintTo(FBitmap.Canvas, vPaintInfo);
    finally
      vPaintInfo.Free;
    end;
  finally
    FBitmap.Canvas.Unlock;
  end;

  BitBlt(Canvas.Handle, ARect.Left, ARect.Top,
    ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    FBitmap.Canvas.Handle, ARect.Left, ARect.Top, SRCCOPY);
  InvalidateRect(Self.Handle, ARect, False);
  //UpdateWindow(Self.Handle);
end;

procedure THCCustomGridView.UpdateView;
begin
  UpdateView(GetViewRect);
end;

procedure THCCustomGridView.WMERASEBKGND(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure THCCustomGridView.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTTAB or DLGC_WANTARROWS;
end;

procedure THCCustomGridView.WMImeComposition(var Message: TMessage);
var
  vEditCell: THCTableCell;
  vhIMC: HIMC;
  vSize: Integer;
  vBuffer: TBytes;
  vS: string;
begin
  if (Message.LParam and GCS_RESULTSTR) <> 0 then  // ���뷨֪ͨ��Ҫ���ձ��û�ѡ����ַ�
  begin
    vEditCell := GetEditCell;
    if Assigned(vEditCell) then
    begin
      vhIMC := ImmGetContext(Handle);
      if vhIMC <> 0 then
      begin
        try
          vSize := ImmGetCompositionString(vhIMC, GCS_RESULTSTR, nil, 0);  // ��ǰ���յ��ַ��������С
          if vSize > 0 then  // �������ַ�
          begin
            SetLength(vBuffer, vSize);
            ImmGetCompositionString(vhIMC, GCS_RESULTSTR, vBuffer, vSize);
            vS := WideStringOf(vBuffer);
            if vS <> '' then
            begin
              CellChangeByAction(FSelectCellRang.StartRow, FSelectCellRang.StartCol,
                procedure
                begin
                  vEditCell.CellData.InsertText(vS);
                end);
            end;
          end;
        finally
          ImmReleaseContext(Handle, vhIMC);
        end;
      end;
    end;
  end;
end;

procedure THCCustomGridView.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if Message.FocusedWnd <> Self.Handle then
    FCaret.Hide;
end;

procedure THCCustomGridView.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  FStyle.UpdateInfoReCaret(False);
  FStyle.UpdateInfoRePaint;
  FStyle.UpdateInfoReScroll;
  CheckUpdateInfo;
end;

procedure THCCustomGridView.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK,
    WM_RBUTTONDOWN, WM_RBUTTONDBLCLK,
    WM_MBUTTONDOWN, WM_MBUTTONDBLCLK:
      begin
        if not (csDesigning in ComponentState) and not Focused then
          Self.SetFocus;
      end;
  end;

  inherited WndProc(Message);
end;

{ THCTableRows }

procedure THCTableRows.Notify(const Value: THCTableRow;
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
