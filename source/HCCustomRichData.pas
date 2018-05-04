{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{             �ĵ��ڸ�������������Ԫ                }
{                                                       }
{*******************************************************}

unit HCCustomRichData;

interface

uses
  Windows, Classes, Types, Controls, Graphics, SysUtils, HCCustomData, HCStyle,
  HCItem, HCDrawItem, HCTextStyle, HCParaStyle, HCStyleMatch, HCCommon;

type
  TInsertProc = reference to function(const AItem: THCCustomItem): Boolean;

  TItemPaintEvent = procedure(const AData: THCCustomData;
    const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
    const ACanvas: TCanvas; const APaintInfo: TPaintInfo) of object;

  TItemMouseEvent = procedure(const AData: THCCustomData; const AItemNo: Integer;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  THCCustomRichData = class(THCCustomData)
  strict private
    FWidth: Cardinal;
    /// <summary> ����������(���ļ��Ի���˫���ļ���ᴥ��MouseMouse��MouseUp) </summary>
    FMouseLBDowning,
    /// <summary> �����ѡ�������� </summary>
    FMouseInSelect,
    FMouseMoveRestrain  // ��������Item��Χ��MouseMove����ͨ��Լ�������ҵ���
      : Boolean;

    FMouseDownX, FMouseDownY: Integer;

    FMouseDownItemNo,
    FMouseDownItemOffset,
    FMouseMoveItemNo,
    FMouseMoveItemOffset
      : Integer;

    FReadOnly,
    FSelecting, FDraging: Boolean;

    FOnInsertItem: TItemNotifyEvent;
    FOnItemMouseDown, FOnItemMouseUp: TItemMouseEvent;
    FOnItemPaintBefor, FOnItemPaintAfter: TItemPaintEvent;
    FOnCreateItem: TNotifyEvent;  // �½���Item(Ŀǰ��Ҫ��Ϊ�˴��ֺ����������뷨����Ӣ��ʱ�ۼ��Ĵ���)

    /// <summary> ���һ����Item��ֹData��Item </summary>
    procedure AddEmptyTextItem;

    /// <summary>
    /// ��ȡָ��ItemNo�����DrawItemNo(�뱣֤AItemNo�����һ��DrawItemNoΪ-1)
    /// </summary>
    /// <param name="AItemNo"></param>
    /// <returns></returns>
    //function GetItemNearDrawItemNo(const AItemNo: Integer): Integer;

    /// <summary> Ϊ����������С��д����ظ����룬ʹ����������������֧��D7 </summary>
    function TableInsertRC(const AProc: TInsertProc): Boolean;
  protected
    function CreateItemByStyle(const AStyleNo: Integer): THCCustomItem; virtual;
    procedure Clear; override;

    // <summary> ����AItem����ʼ��˽�б�������������ѡ��λ�ú�ȷ����꣬һ������Data�䶯����������ѡ��λ�� </summary>
    procedure ReSetSelectAndCaret(const AItemNo: Integer); overload;
    procedure ReSetSelectAndCaret(const AItemNo, AOffset: Integer); overload;

    /// <summary> ��ǰItem��Ӧ�ĸ�ʽ����ʼItem�ͽ���Item(�����һ��Item) </summary>
    /// <param name="AFirstItemNo">��ʼItemNo</param>
    /// <param name="ALastItemNo">����ItemNo</param>
    procedure GetReformatItemRange(var AFirstItemNo, ALastItemNo: Integer); overload;

    /// <summary> ָ��Item��Ӧ�ĸ�ʽ����ʼItem�ͽ���Item(�����һ��Item) </summary>
    /// <param name="AFirstItemNo">��ʼItemNo</param>
    /// <param name="ALastItemNo">����ItemNo</param>
    procedure GetReformatItemRange(var AFirstItemNo, ALastItemNo: Integer; const AItemNo, AItemOffset: Integer); overload;

    /// <summary>
    /// �ϲ�2���ı�Item
    /// </summary>
    /// <param name="ADestItem">�ϲ����Item</param>
    /// <param name="ASrcItem">ԴItem</param>
    /// <returns>True:�ϲ��ɹ���False���ܺϲ�</returns>
    function MergeItemText(const ADestItem, ASrcItem: THCCustomItem): Boolean; virtual;

    // ѡ������Ӧ����ʽ
    function ApplySelectTextStyle(const AMatchStyle: TStyleMatch): Integer; override;
    function ApplySelectParaStyle(const AMatchStyle: TParaMatch): Integer; override;

    procedure DoDrawItemPaintBefor(const AData: THCCustomData; const ADrawItemIndex: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure DoDrawItemPaintAfter(const AData: THCCustomData; const ADrawItemIndex: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    function DisSelect: Boolean; override;
    function CanDeleteItem(const AItemNo: Integer): Boolean; virtual;

    /// <summary> ɾ��ѡ������(�ڲ��Ѿ��ж����Ƿ���ѡ��) </summary>
    /// <returns>True:��ѡ����ɾ���ɹ�</returns>
    function DeleteSelected: Boolean; override;

    procedure DoItemInsert(const AItem: THCCustomItem); virtual;
    procedure DoItemMouseLeave(const AItemNo: Integer); virtual;
    procedure DoItemMouseEnter(const AItemNo: Integer); virtual;
    function GetWidth: Cardinal; virtual;
    procedure SetWidth(const Value: Cardinal);
    function GetHeight: Cardinal; virtual;
    procedure SetReadOnly(const Value: Boolean); virtual;

    /// <summary>
    /// ׼����ʽ������
    /// </summary>
    /// <param name="AStartItemNo">��ʼ��ʽ����Item</param>
    /// <param name="APrioDItemNo">��һ��Item�����һ��DrawItemNo</param>
    /// <param name="APos">��ʼ��ʽ��λ��</param>
    procedure _FormatReadyParam(const AStartItemNo: Integer;
      var APrioDrawItemNo: Integer; var APos: TPoint); virtual;

    function CalcContentHeight: Integer;
  public
    constructor Create(const AStyle: THCStyle); override;
    //
    function CanEdit: Boolean;
    /// <summary> �ڹ�괦���� </summary>
    function InsertBreak: Boolean;
    function InsertText(const AText: string): Boolean;
    function InsertTable(const ARowCount, AColCount: Integer): Boolean;
    function InsertLine(const ALineHeight: Integer): Boolean;
    /// <summary> �ڹ�괦����Item </summary>
    /// <param name="AItem"></param>
    /// <returns></returns>
    function InsertItem(const AItem: THCCustomItem): Boolean; overload; virtual;

    /// <summary> ��ָ����λ�ò���Item </summary>
    /// <param name="AIndex"></param>
    /// <param name="AItem"></param>
    /// <returns></returns>
    function InsertItem(const AIndex: Integer; const AItem: THCCustomItem): Boolean; overload; virtual;

    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; override;

    function TableInsertRowAfter(const ARowCount: Byte): Boolean;
    function TableInsertRowBefor(const ARowCount: Byte): Boolean;
    function ActiveTableDeleteRow(const ARowCount: Byte): Boolean;
    function TableInsertColAfter(const AColCount: Byte): Boolean;
    function TableInsertColBefor(const AColCount: Byte): Boolean;
    function ActiveTableDeleteCol(const AColCount: Byte): Boolean;
    function MergeTableSelectCells: Boolean;
    procedure KillFocus; virtual;
    procedure DblClick(X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    {IKeyEvent}
    // Key����0��ʾ�˼�����Dataû�����κ�����
    procedure KeyPress(var Key: Char); virtual;
    // Key����0��ʾ�˼�����Dataû�����κ�����
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    // Key����0��ʾ�˼�����Dataû�����κ�����
    procedure KeyUp(var Key: Word; Shift: TShiftState); virtual;

    // Format�������ʽ��Item��ReFormat�������ʽ����Ժ���Item��DrawItem�Ĺ�������
    // Ŀǰ����Ԫ�����ˣ���Ҫ�ŵ�CellData����
    procedure ReFormat(const AStartItemNo: Integer);
    procedure FormatData(const AStartItemNo, ALastItemNo: Integer);
    // Format�������ʽ��Item��ReFormat�����ʽ����Ժ���Item��DrawItem�Ĺ�������
    procedure ReFormatData_(const AStartItemNo: Integer; const ALastItemNo: Integer = -1;
      const AExtraItemCount: Integer = 0);

    /// <summary> ���¸�ʽ����ǰItem(���ڽ��޸ĵ�ǰItem���Ի�����) </summary>
    procedure ReFormatActiveItem;
    procedure GetCurStyle(var AStyleNo, AParaNo: Integer);
    function GetActiveItem: THCCustomItem;
    function GetActiveDrawItem: THCCustomDrawItem;
    function GetActiveDrawItemCoord: TPoint;

    /// <summary> ȡ������(����ҳü��ҳ�š������л�ʱԭ�����ȡ��) </summary>
    procedure DisActive;

    /// <summary> ��ʼ���ֶκͱ��� </summary>
    procedure Initialize; virtual;

    function GetHint: string;

    /// <summary> ���ص�ǰ��괦�Ķ���Data </summary>
    function GetTopLevelData: THCCustomRichData;

    /// <summary> ����ָ��λ�ô��Ķ���Data </summary>
    function GetTopLevelDataAt(const X, Y: Integer): THCCustomRichData;

    /// <summary>
    /// ��������
    /// </summary>
    /// <param name="AOffsetX">����ƫ��</param>
    /// <param name="AOffsetY">����ƫ��</param>
    /// <param name="ADataScreenTop">�����ڵ�ǰ��Ļ¶���������϶�</param>
    /// <param name="ADataScreenBottom">�����ڵ�ǰ��Ļ¶���������¶�</param>
    /// <param name="AStartDItemNo">��ʼDItem</param>
    /// <param name="AEndDItemNo">����DItem</param>
    /// <param name="ACanvas"></param>
//    procedure PaintData(const AOffsetX, AOffsetY, ADataScreenTop, ADataScreenBottom,
//      AStartDItemNo, AEndDItemNo: Integer; const ACanvas: TCanvas);

    property MouseDownItemNo: Integer read FMouseDownItemNo;
    property MouseDownItemOffset: Integer read FMouseDownItemOffset;
    property MouseMoveItemNo: Integer read FMouseMoveItemNo;
    property MouseMoveItemOffset: Integer read FMouseMoveItemOffset;
    property MouseMoveRestrain: Boolean read FMouseMoveRestrain;

    property Width: Cardinal read GetWidth write SetWidth;
    property Height: Cardinal read GetHeight;  // ʵ�����ݵĸ�
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property OnInsertItem: TItemNotifyEvent read FOnInsertItem write FOnInsertItem;
    property OnItemMouseDown: TItemMouseEvent read FOnItemMouseDown write FOnItemMouseDown;
    property OnItemMouseUp: TItemMouseEvent read FOnItemMouseUp write FOnItemMouseUp;
    property OnItemPaintBefor: TItemPaintEvent read FOnItemPaintBefor write FOnItemPaintBefor;
    property OnItemPaintAfter: TItemPaintEvent read FOnItemPaintAfter write FOnItemPaintAfter;
    property OnCreateItem: TNotifyEvent read FOnCreateItem write FOnCreateItem;
  end;

implementation

uses
  HCTextItem, HCRectItem, HCTableItem, HCBitmapItem, HCCheckBoxItem,
  HCTabItem, HCLineItem, HCExpressItem, HCPageBreakItem;

{ THCCustomRichData }

constructor THCCustomRichData.Create(const AStyle: THCStyle);
begin
  inherited Create(AStyle);
  Items.OnItemInsert := DoItemInsert;
  AddEmptyTextItem;  // �����TextItem
  SelectInfo.StartItemNo := 0;
  SelectInfo.StartItemOffset := 0;
  FormatData(0, 0);
  Initialize;
  FReadOnly := False;
end;

function THCCustomRichData.CreateItemByStyle(
  const AStyleNo: Integer): THCCustomItem;
begin
  Result := nil;
  if AStyleNo < THCStyle.RsNull then
  begin
    case AStyleNo of
      THCStyle.RsBitmap: Result := THCBitmapItem.Create(0, 0);
      THCStyle.RsTable: Result := THCTableItem.Create(Style, 1, 1, 1, Self);
      THCStyle.RsTab: Result := TTabItem.Create(0, 0);
      THCStyle.RsLine: Result := TLineItem.Create(1, 1);
      THCStyle.RsExpress: Result := TExperssItem.Create('', '', '', '');
      THCStyle.RsControl: Result := TCheckBoxItem.Create(-1, '', False);
      THCStyle.RsPageBreak: Result := TPageBreakItem.Create(0, 1);
      THCStyle.RsDomain: Result := CreateDefaultDomainItem;
    else
      raise Exception.Create('δ�ҵ����� ' + IntToStr(AStyleNo) + ' ��Ӧ�Ĵ���Item���룡');
    end;
  end
  else
  begin
    Result := CreateDefaultTextItem;
    Result.StyleNo := AStyleNo;
  end;
end;

procedure THCCustomRichData.DblClick(X, Y: Integer);
var
  vItemNo, vItemOffset, vDrawItemNo, vX, vY: Integer;
  vRestrain: Boolean;
begin
  GetItemAt(X, Y, vItemNo, vItemOffset, vDrawItemNo, vRestrain);
  if vItemNo < 0 then Exit;
  CoordToItemOffset(X, Y, vItemNo, vItemOffset, vX, vY);
  if Items[vItemNo].StyleNo < THCStyle.RsNull then
    Items[vItemNo].DblClick(vX, vY)
  else
  begin
    Self.SelectInfo.StartItemNo := vItemNo;
    Self.SelectInfo.StartItemOffset := 0;
    if Items[vItemNo].Length > 0 then
    begin
      Self.SelectInfo.EndItemNo := vItemNo;
      Self.SelectInfo.EndItemOffset := Items[vItemNo].Length;
    end;
  end;
  Style.UpdateInfoRePaint;
  Style.UpdateInfoReCaret;
end;

function THCCustomRichData.DeleteSelected: Boolean;
var
  vDelCount, vFormatFirstItemNo, vFormatLastItemNo,
  vLen, vParaFirstItemNo, vParaLastItemNo: Integer;
  vStartItem, vEndItem, vNewItem: THCCustomItem;

  {$REGION 'ɾ��ȫѡ�еĵ���Item'}
  function DeleteItemSelectComplate: Boolean;
  begin
    Result := False;
    if CanDeleteItem(SelectInfo.StartItemNo) then  // ����ɾ��
    begin
      Items.Delete(SelectInfo.StartItemNo);
      Inc(vDelCount);
      if (SelectInfo.StartItemNo > vFormatFirstItemNo)
        and (SelectInfo.StartItemNo < vFormatLastItemNo)
      then  // ȫѡ�е�Item����ʼ��ʽ���ͽ�����ʽ���м�
      begin
        vLen := Items[SelectInfo.StartItemNo - 1].Length;
        if MergeItemText(Items[SelectInfo.StartItemNo - 1], Items[SelectInfo.StartItemNo]) then
        begin
          Items.Delete(SelectInfo.StartItemNo);
          Inc(vDelCount);
          SelectInfo.StartItemOffset := vLen;
        end;
      end
      else
      if SelectInfo.StartItemNo = vParaFirstItemNo then  // �ε�һ��ItemNo
      begin
        if vParaFirstItemNo = vParaLastItemNo then  // �ξ�һ��Itemȫɾ����
        begin
          vNewItem := CreateDefaultTextItem;
          vNewItem.ParaFirst := True;
          Items.Insert(SelectInfo.StartItemNo, vNewItem);
          SelectInfo.StartItemOffset := 0;
          Dec(vDelCount);
        end
        else
        begin
          SelectInfo.StartItemOffset := 0;
          Items[SelectInfo.StartItemNo].ParaFirst := True;
        end;
      end
      else
      if SelectInfo.StartItemNo = vParaLastItemNo then  // �����һ��ItemNo
      begin
        {if vParaFirstItemNo = vParaLastItemNo then  // �ξ�һ��Itemȫɾ����,�����ߵ������
        begin
          vItem := CreateDefaultTextItem;
          vItem.ParaFirst := True;
          Items.Insert(SelectInfo.StartItemNo, vItem);
          SelectInfo.StartItemOffset := 0;
          Dec(vDelCount);
        end
        else}
        begin
          SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
          SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
        end;
      end
      else  // ȫѡ�е�Item����ʼ��ʽ���������ʽ�����ڶ���
      begin
        if SelectInfo.StartItemNo > 0 then
          SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
      end;
    end;
    Result := True;
  end;
  {$ENDREGION}

var
  i: Integer;
  vText: string;
  vSelStartComplate,  // ѡ�з�Χ�ڵ���ʼItemȫѡ����
  vSelEndComplate,    // ѡ�з�Χ�ڵĽ���Itemȫѡ����
  vSelStartParaFirst  // ѡ����ʼ�Ƕ���
    : Boolean;
begin
  Result := False;

  if not CanEdit then Exit;

  if SelectExists then
  begin
    vDelCount := 0;
    if (SelectInfo.EndItemNo < 0) and (Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull)
    then  // ѡ��������RectItem�ڲ�
    begin
      // ����䶯������RectItem�Ŀ�ȱ仯������Ҫ��ʽ���������һ��Item
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

      if Items[SelectInfo.StartItemNo].IsSelectComplate then  // ȫѡ��
      begin
        GetParaItemRang(SelectInfo.StartItemNo, vParaFirstItemNo, vParaLastItemNo);
        Result := DeleteItemSelectComplate;
      end
      else
        Result := (Items[SelectInfo.StartItemNo] as THCCustomRectItem).DeleteSelected;

      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - vDelCount, -vDelCount);
    end
    else  // ѡ�в��Ƿ�����RectItem�ڲ�
    begin
      vEndItem := Items[SelectInfo.EndItemNo];  // ѡ�н���Item
      if SelectInfo.EndItemNo = SelectInfo.StartItemNo then  // ѡ������ͬһ��Item
      begin
        GetParaItemRang(SelectInfo.StartItemNo, vParaFirstItemNo, vParaLastItemNo);

        GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
        FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

        if vEndItem.StyleNo < THCStyle.RsNull then  // ͬһ��RectItem  ����ǰѡ�е�һ���֣�
          (vEndItem as THCCustomRectItem).DeleteSelected
        else  // ͬһ��TextItem
        begin
          if vEndItem.IsSelectComplate then  // ��TextItemȫѡ����
            Result := DeleteItemSelectComplate
          else
          begin
            vText := vEndItem.Text;
            Delete(vText, SelectInfo.StartItemOffset + 1, SelectInfo.EndItemOffset - SelectInfo.StartItemOffset);
            vEndItem.Text := vText;
          end;
        end;

        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - vDelCount, -vDelCount);
      end
      else  // ѡ�з����ڲ�ͬItem����ʼ(�����Ƕ���)ȫѡ�н�βûȫѡ����ʼûȫѡ��βȫѡ����ʼ��β��ûȫѡ
      begin
        vFormatFirstItemNo := GetParaFirstItemNo(SelectInfo.StartItemNo);  // ȡ�ε�һ��Ϊ��ʼ
        vFormatLastItemNo := GetParaLastItemNo(SelectInfo.EndItemNo);  // ȡ�����һ��Ϊ������������ע������

        FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

        vSelStartParaFirst := Items[SelectInfo.StartItemNo].ParaFirst;
        vSelStartComplate := Items[SelectInfo.StartItemNo].IsSelectComplate;  // ��ʼ�Ƿ�ȫѡ
        vSelEndComplate := Items[SelectInfo.EndItemNo].IsSelectComplate;  // ��β�Ƿ�ȫѡ

        {vSelectRangComplate :=  // ѡ�з�Χ�ڵ�Item����ȫѡ����
          (SelectInfo.StartItemOffset = 0)
           and ( ( (vItem.StyleNo < THCStyle.RsNull)
                     and (SelectInfo.EndItemOffset = OffsetAfter)
                 )
               or ( (vItem.StyleNo > THCStyle.RsNull)
                     and (SelectInfo.EndItemOffset = vItem.Length)
                  )
               );}

        if vEndItem.StyleNo < THCStyle.RsNull then  // RectItem
        begin
          if vSelEndComplate then  // �����  SelectInfo.EndItemOffset = OffsetAfter
          begin
            if CanDeleteItem(SelectInfo.EndItemNo) then  // ����ɾ��
            begin
              Items.Delete(SelectInfo.EndItemNo);
              Inc(vDelCount);
            end;
          end;
        end
        else  // TextItem
        begin
          if vSelEndComplate then  // ��ѡ���ı�Item������� SelectInfo.EndItemOffset = vEndItem.Length
          begin
            if CanDeleteItem(SelectInfo.EndItemNo) then  // ����ɾ��
            begin
              Items.Delete(SelectInfo.EndItemNo);
              Inc(vDelCount);
            end;
          end
          else  // �ı��Ҳ���ѡ�н���Item���
          begin
            // ����Item���µ�����
            vText := (vEndItem as THCTextItem).GetTextPart(SelectInfo.EndItemOffset + 1,
              vEndItem.Length - SelectInfo.EndItemOffset);
            vEndItem.Text := vText;
          end;
        end;

        // ɾ��ѡ����ʼItem��һ��������Item��һ��
        for i := SelectInfo.EndItemNo - 1 downto SelectInfo.StartItemNo + 1 do
        begin
          if CanDeleteItem(i) then  // ����ɾ��
          begin
            Items.Delete(i);
            Inc(vDelCount);
          end;
        end;

        //vStartItemBefor := False;
        vStartItem := Items[SelectInfo.StartItemNo];  // ѡ����ʼItem
        if vStartItem.StyleNo < THCStyle.RsNull then  // ��ʼ��RectItem
        begin
          if SelectInfo.StartItemOffset < OffsetAfter then  // ����ǰ������
          begin
            //vStartItemBefor := True;  // ѡ�����ʼItem��ǰ�濪ʼ
            if CanDeleteItem(SelectInfo.StartItemNo) then  // ����ɾ��
            begin
              Items.Delete(SelectInfo.StartItemNo);
              Inc(vDelCount);
            end;
            if SelectInfo.StartItemNo > vFormatFirstItemNo then
              SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
          end;
        end
        else  // ѡ����ʼ��TextItem
        begin
          if vSelStartComplate then  // ����ǰ��ʼȫѡ�� SelectInfo.StartItemOffset = 0
          begin
            //vStartItemBefor := True;  // ѡ�����ʼItem��ǰ�濪ʼ
            if CanDeleteItem(SelectInfo.StartItemNo) then  // ����ɾ��
            begin
              Items.Delete(SelectInfo.StartItemNo);
              Inc(vDelCount);
            end;
          end
          else
          //if SelectInfo.StartItemOffset < vStartItem.Length then  // ���м�(�����ж��˰ɣ�)
          begin
            vText := (vStartItem as THCTextItem).GetTextPart(1, SelectInfo.StartItemOffset);
            vStartItem.Text := vText;  // ��ʼ���µ�����
          end;
        end;

        if vSelStartComplate and vSelEndComplate then  // ѡ�е�Item��ɾ����
        begin
          if SelectInfo.StartItemNo = vFormatFirstItemNo then  // ѡ����ʼ�ڶ���ǰ
          begin
            if SelectInfo.EndItemNo = vFormatLastItemNo then  // ѡ�н����ڵ�ǰ�λ����ĳ�����(��������ȫɾ����)���������
            begin
              vNewItem := CreateDefaultTextItem;
              vNewItem.ParaFirst := True;
              Items.Insert(SelectInfo.StartItemNo, vNewItem);
              Dec(vDelCount);
            end
            else  // ѡ�н������ڶ����
              Items[SelectInfo.EndItemNo - vDelCount + 1].ParaFirst := True;  // ѡ�н���λ�ú���ĳ�Ϊ����
          end
          else
          if SelectInfo.EndItemNo = vFormatLastItemNo then  // �����ڶ����
          begin
            SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
            if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
              SelectInfo.StartItemOffset := OffsetAfter
            else
              SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
          end
          else  // ѡ����ʼ����ʼ���м䣬ѡ�н����ڽ������м�
          begin
            vLen := Items[SelectInfo.StartItemNo - 1].Length;
            if MergeItemText(Items[SelectInfo.StartItemNo - 1], Items[SelectInfo.EndItemNo - vDelCount + 1]) then  // ��ʼǰ��ͽ�������ɺϲ�
            begin
              SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
              SelectInfo.StartItemOffset := vLen;

              Items.Delete(SelectInfo.EndItemNo - vDelCount + 1);
              Inc(vDelCount);
            end
            else  // ��ʼǰ��ͽ������治�ܺϲ�
              Items[SelectInfo.EndItemNo - vDelCount + 1].ParaFirst := False;  // �ϲ����ɹ��Ͱ���
          end;
        end
        else  // ѡ�з�Χ�ڵ�Itemû��ɾ����
        begin
          if vSelStartComplate then  // ��ʼɾ������
            Items[SelectInfo.EndItemNo - vDelCount].ParaFirst := vSelStartParaFirst
          else
          if not vSelEndComplate then  // ��ʼ�ͽ�����û��ɾ����
          begin
            if MergeItemText(Items[SelectInfo.StartItemNo], Items[SelectInfo.EndItemNo - vDelCount])
            then  // ѡ����ʼ������λ�õ�Item�ϲ��ɹ�
            begin
              Items.Delete(SelectInfo.EndItemNo - vDelCount);
              Inc(vDelCount);
            end
            else  // ѡ����ʼ������λ�õ�Item���ܺϲ�
            begin
              if SelectInfo.EndItemNo <> vFormatLastItemNo then  // ѡ�н������Ƕ����һ��
                Items[SelectInfo.EndItemNo - vDelCount].ParaFirst := False;  // �ϲ����ɹ��Ͱ���
            end;
          end;
        end;

        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - vDelCount, -vDelCount);
      end;

      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
      Style.UpdateInfoRePaint;
      Style.UpdateInfoReCaret;

      inherited DeleteSelected;

      ReSetSelectAndCaret(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
      Result := True;
    end;
  end;
end;

procedure THCCustomRichData.DisActive;
var
  vItem: THCCustomItem;
begin
  Self.Initialize;

  if Items.Count > 0 then  // ҳü��Ԫ�ؼ�����л������Ĳ�����
  begin
    vItem := GetCurItem;
    if vItem <> nil then
      vItem.Active := False;
  end;
end;

function THCCustomRichData.DisSelect: Boolean;
begin
  Result := inherited DisSelect;
  if Result then
  begin
    // ��ק���ʱ���
    FDraging := False;  // ��ק���
    FMouseLBDowning := False;
    FSelecting := False;  // ׼����ѡ  
    
    // Self.Initialize;  ����ᵼ��Mouse�¼��е�FMouseLBDowning�����Ա�ȡ����
    Style.UpdateInfoReCaret;
    Style.UpdateInfoRePaint;
  end;
end;

procedure THCCustomRichData.DoDrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;
  if Assigned(FOnItemPaintAfter) then
  begin
    FOnItemPaintAfter(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCCustomRichData.DoDrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;
  if Assigned(FOnItemPaintBefor) then
  begin
    FOnItemPaintBefor(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
      ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  end;
end;

procedure THCCustomRichData.DoItemInsert(const AItem: THCCustomItem);
begin
  if Assigned(FOnInsertItem) then
    FOnInsertItem(AItem);
end;

procedure THCCustomRichData.DoItemMouseEnter(const AItemNo: Integer);
begin
  Items[AItemNo].MouseEnter;
end;

procedure THCCustomRichData.DoItemMouseLeave(const AItemNo: Integer);
begin
  Items[AItemNo].MouseLeave;
end;

procedure THCCustomRichData.ReFormat(const AStartItemNo: Integer);
begin
  FormatItemPrepare(AStartItemNo, Items.Count - 1);
  FormatData(AStartItemNo, Items.Count - 1);
  DrawItems.DeleteFormatMark;
end;

procedure THCCustomRichData.ReFormatActiveItem;
var
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
begin
  if SelectInfo.StartItemNo >= 0 then
  begin
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);

    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;
  end;
end;

procedure THCCustomRichData.FormatData(const AStartItemNo, ALastItemNo: Integer);
var
  i, vPrioDrawItemNo: Integer;
  vPos: TPoint;
begin
  _FormatReadyParam(AStartItemNo, vPrioDrawItemNo, vPos);  // ��ʽ����ʼDrawItem��ź�λ��

  for i := AStartItemNo to ALastItemNo do  // ��ʽ��
    _FormatItemToDrawItems(i, 1, FWidth, vPos, vPrioDrawItemNo);
end;

procedure THCCustomRichData.Clear;
begin
  Initialize;
  inherited Clear;
end;

function THCCustomRichData.GetActiveDrawItem: THCCustomDrawItem;
var
  vItem: THCCustomItem;
begin
  Result := nil;
  vItem := GetCurItem;
  if vItem.StyleNo < THCStyle.RsNull then
    Result := (vItem as THCCustomRectItem).GetActiveDrawItem;

  if Result = nil then
    Result := GetCurDrawItem;
end;

function THCCustomRichData.GetActiveDrawItemCoord: TPoint;
var
  vItem: THCCustomItem;
  vDrawItem: THCCustomDrawItem;
  vPt: TPoint;
begin
  Result := Point(0, 0);
  vPt := Point(0, 0);
  vDrawItem := GetCurDrawItem;
  if vDrawItem <> nil then
  begin
    Result := vDrawItem.Rect.TopLeft;

    vItem := GetCurItem;
    if vItem.StyleNo < THCStyle.RsNull then
      vPt := (vItem as THCCustomRectItem).GetActiveDrawItemCoord;

    Result.X := Result.X + vPt.X;
    Result.Y := Result.Y + vPt.Y;
  end;
end;

function THCCustomRichData.GetActiveItem: THCCustomItem;
begin
  Result := GetCurItem;
  if (Result <> nil) and (Result.StyleNo < THCStyle.RsNull) then
    Result := (Result as THCCustomRectItem).GetActiveItem;
end;

procedure THCCustomRichData.GetCurStyle(var AStyleNo, AParaNo: Integer);
var
  vCurItemNo: Integer;
begin
  vCurItemNo := GetCurItemNo;
  if Items[vCurItemNo].StyleNo < THCStyle.RsNull then
    (Items[vCurItemNo] as THCCustomRectItem).GetCurStyle(AStyleNo, AParaNo)
  else
  begin
    AStyleNo := Items[vCurItemNo].StyleNo;
    AParaNo := Items[vCurItemNo].ParaNo;
  end;
end;

function THCCustomRichData.GetHeight: Cardinal;
begin
  Result := CalcContentHeight;
end;

function THCCustomRichData.GetHint: string;
begin
  if (not FMouseMoveRestrain) and (FMouseMoveItemNo >= 0) then
    Result := Items[FMouseMoveItemNo].GetHint
  else
    Result := '';
end;

procedure THCCustomRichData.GetReformatItemRange(var AFirstItemNo,
  ALastItemNo: Integer; const AItemNo, AItemOffset: Integer);
//var
//  vDrawItemNo, vParaFirstDItemNo: Integer;
begin
  // ����ʼΪTextItem��ͬһ�к�����RectItemʱ���༭TextItem���ʽ�����ܻὫRectItem�ֵ���һ�У�
  // ���Բ���ֱ�� FormatItemPrepare(SelectInfo.StartItemNo)�������Ϊ��ʽ����Χ̫С��
  // û�н���FiniLine�����иߣ����ԴӶ����������ʼ

  // ���Item�ֶ��У��ڷ���ʼλ�����޸ģ�����ʼλ�ø�ʽ��ʱ����ʼλ�ú�ǰ���ԭ��
  // ���ɢ�����˿�ȣ�����Ӧ�ô���ʼλ����������ItemNo��ʼ��ʽ����������ʼλ�ø�ʽ��ʱ
  // ��ǰ��Item����һ�η�ɢ���ӵĿ�ȣ�������ʼλ�ø�ʽ����Ȳ���ȷ����ɷ��в�׼ȷ
  // ��������ƣ���֧�����ݸ�ʽ��ʱָ��ItemNo��Offset��
  //
  // �����ʽ��λ������������ItemB��ʼ����һ�н�������һItemA���������ı�ʱ�ɺ�ItemA�ϲ���
  // ��Ҫ��ItemA��ʼ��ʽ��
  if (AItemNo > 0) and (AItemOffset = 0) and DrawItems[Items[AItemNo].FirstDItemNo].LineFirst then  // �ڿ�ͷ
    AFirstItemNo := GetLineFirstItemNo(AItemNo - 1, Items[AItemNo - 1].Length)
  else
    AFirstItemNo := GetLineFirstItemNo(AItemNo, 0);  // ȡ�е�һ��DrawItem��Ӧ��ItemNo

  ALastItemNo := GetParaLastItemNo(AItemNo);
  {

  GetParaItemRang(AItemNo, AFirstItemNo, ALastItemNo);
  vParaFirstDItemNo := Items[AFirstItemNo].FirstDItemNo;
  // ������DrawItem
  vDrawItemNo := GetDrawItemNoByOffset(AItemNo, AItemOffset);
  while vDrawItemNo > 0 do
  begin
    if DrawItems[vDrawItemNo].LineFirst then
      Break
    else
      Dec(vDrawItemNo);
  end;
  // ����һ����ʼDrawItemNo
  Dec(vDrawItemNo);
  while vDrawItemNo > vParaFirstDItemNo do
  begin
    if DrawItems[vDrawItemNo].LineFirst then
    begin
      AFirstItemNo := DrawItems[vDrawItemNo].ItemNo;
      Break;
    end
    else
      Dec(vDrawItemNo);
  end;  }
end;

function THCCustomRichData.GetTopLevelData: THCCustomRichData;
begin
  Result := nil;
  if (SelectInfo.StartItemNo >= 0) and (SelectInfo.EndItemNo < 0) then
  begin
    if (Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull)
      and (SelectInfo.StartItemOffset = OffsetInner)
    then
      Result := (Items[SelectInfo.StartItemNo] as THCCustomRectItem).GetActiveData as THCCustomRichData;
  end;
  if Result = nil then
    Result := Self;
end;

function THCCustomRichData.GetTopLevelDataAt(const X,
  Y: Integer): THCCustomRichData;
var
  vItemNo, vOffset, vDrawItemNo, vX, vY: Integer;
  vRestrain: Boolean;
begin
  Result := nil;
  GetItemAt(X, Y, vItemNo, vOffset, vDrawItemNo, vRestrain);
  if (not vRestrain) and (vItemNo >= 0) then
  begin
    if Items[vItemNo].StyleNo < THCStyle.RsNull then
    begin
      CoordToItemOffset(X, Y, vItemNo, vOffset, vX, vY);
      Result := (Items[vItemNo] as THCCustomRectItem).GetTopLevelDataAt(vX, vY) as THCCustomRichData;
    end;
  end;
  if Result = nil then
    Result := Self;
end;

procedure THCCustomRichData.GetReformatItemRange(var AFirstItemNo,
  ALastItemNo: Integer);
begin
  GetReformatItemRange(AFirstItemNo, ALastItemNo, SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
end;

{function THCCustomRichData.GetItemNearDrawItemNo(const AItemNo: Integer): Integer;
var
  vItemNo, vLastDrawItemNo: Integer;
begin
  Result := -1;
  vItemNo := AItemNo - 1;
  while vItemNo >= 0 do
  begin
    Result := GetItemLastDrawItemNo(vItemNo);
    if Result >= 0 then
      Break;
    Dec(vItemNo);
  end;
end;}

function THCCustomRichData.GetWidth: Cardinal;
begin
  Result := FWidth;
end;

function THCCustomRichData.ActiveTableDeleteCol(const AColCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).DeleteCol(AColCount);
    end);
end;

function THCCustomRichData.ActiveTableDeleteRow(const ARowCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).DeleteRow(ARowCount);
    end);
end;

procedure THCCustomRichData.AddEmptyTextItem;
var
  vItem: THCCustomItem;
begin
  if Self.Items.Count = 0 then
  begin
    vItem := CreateDefaultTextItem;
    vItem.ParaFirst := True;
    Items.Add(vItem);  // ��ʹ��InsertText��Ϊ�����䴥��ReFormatParaʱ��Ϊû�и�ʽ��������ȡ������Ӧ��DrawItem
  end;
end;

function THCCustomRichData.ApplySelectParaStyle(
  const AMatchStyle: TParaMatch): Integer;
var
  vFirstNo, vLastNo: Integer;

  procedure DoApplyParaStyle(const AItemNo: Integer);
  var
    i, vParaNo: Integer;
  begin
    if GetItemStyle(AItemNo) < THCStyle.RsNull then  // ��ǰ��RectItem
      (Items[AItemNo] as THCCustomRectItem).ApplySelectParaStyle(Style, AMatchStyle)
    else
    begin
      GetParaItemRang(AItemNo, vFirstNo, vLastNo);
      vParaNo := AMatchStyle.GetMatchParaNo(Style, GetItemParaStyle(AItemNo));
      if GetItemParaStyle(vFirstNo) <> vParaNo then
      begin
        for i := vFirstNo to vLastNo do
          Items[i].ParaNo := vParaNo;
      end;
    end;
  end;

  procedure ApplyParaSelectedRangStyle;
  var
    i: Integer;
  begin
    // �ȴ�����ʼλ�����ڵĶΣ��Ա�������ʱ����ѭ������
    GetParaItemRang(SelectInfo.StartItemNo, vFirstNo, vLastNo);
    DoApplyParaStyle(SelectInfo.StartItemNo);

    i := vLastNo + 1; // �ӵ�ǰ�ε���һ��item��ʼ
    while i <= SelectInfo.EndItemNo do  // С�ڽ���λ��
    begin
      if Items[i].ParaFirst then
        DoApplyParaStyle(i);
      Inc(i);
    end;
  end;

var
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
begin
  if SelectInfo.StartItemNo < 0 then Exit;

  GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
  if SelectInfo.EndItemNo >= 0 then  // ��ѡ������
  begin
    vFormatLastItemNo := GetParaLastItemNo(SelectInfo.EndItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    ApplyParaSelectedRangStyle;
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
  end
  else  // û��ѡ������
  begin
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    DoApplyParaStyle(SelectInfo.StartItemNo);  // Ӧ����ʽ
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
  end;
  Style.UpdateInfoRePaint;
  Style.UpdateInfoReCaret;
end;

function THCCustomRichData.ApplySelectTextStyle(
  const AMatchStyle: TStyleMatch): Integer;

  // ��ǰItem�ɹ��ϲ���ͬ��ǰһ��Item
  function MergeItemToPrio(const AItemNo: Integer): Boolean;
  begin
    Result := (AItemNo > 0)
              and (not Items[AItemNo].ParaFirst)
              and MergeItemText(Items[AItemNo - 1], Items[AItemNo]);
  end;

  // ͬ�κ�һ��Item�ɹ��ϲ�����ǰItem
  function MergeItemToNext(const AItemNo: Integer): Boolean;
  begin
    Result := (AItemNo < Items.Count - 1)
              and (not Items[AItemNo + 1].ParaFirst)
              and MergeItemText(Items[AItemNo], Items[AItemNo + 1]);
  end;

var
  vStyleNo, vExtraCount, vLen: Integer;
  vItem: THCCustomItem;
  vText, vSelText: string;

  {$REGION 'ApplySameItemѡ����ͬһ��Item'}
  procedure ApplySameItem(const AItemNo: Integer);
  var
    vsBefor: string;
    vSelItem, vAfterItem: THCCustomItem;
  begin
    vItem := Items[AItemNo];
    if vItem.StyleNo < THCStyle.RsNull then  // ���ı�
    begin
      (vItem as THCCustomRectItem).ApplySelectTextStyle(Style, AMatchStyle);
      {Rect����ʱ�Ȳ�����
      if AMatchStyle is TTextStyleMatch then
      begin
        if (AMatchStyle as TTextStyleMatch).FontStyle = TFontStyleEx.tsCustom then
          DoApplyCustomStyle(vItem);
      end;}
    end
    else  // �ı�
    begin
      vStyleNo := AMatchStyle.GetMatchStyleNo(Style, vItem.StyleNo);
      if vItem.IsSelectComplate then  // Itemȫ����ѡ����
      begin
        vItem.StyleNo := vStyleNo;  // ֱ���޸���ʽ���
        if MergeItemToNext(AItemNo) then  // ��һ��Item�ϲ�����ǰItem
        begin
          Items.Delete(AItemNo + 1);
          Dec(vExtraCount);
        end;
        if AItemNo > 0 then  // ��ǰ�ϲ�
        begin
          vLen := Items[AItemNo - 1].Length;
          if MergeItemToPrio(AItemNo) then  // ��ǰItem�ϲ�����һ��Item(�������ϲ��ˣ�vItem�Ѿ�ʧЧ������ֱ��ʹ����)
          begin
            Items.Delete(AItemNo);
            Dec(vExtraCount);
            SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
            SelectInfo.StartItemOffset := vLen;
            SelectInfo.EndItemNo := SelectInfo.StartItemNo;
            SelectInfo.EndItemOffset := vLen + SelectInfo.EndItemOffset;
          end;
        end;
      end
      else  // Itemһ���ֱ�ѡ��
      begin
        vText := vItem.Text;
        vSelText := Copy(vText, SelectInfo.StartItemOffset + 1,  // ѡ�е��ı�
          SelectInfo.EndItemOffset - SelectInfo.StartItemOffset);
        vsBefor := Copy(vText, 1, SelectInfo.StartItemOffset);  // ǰ�벿���ı�
        vAfterItem := Items[AItemNo].BreakByOffset(SelectInfo.EndItemOffset);  // ��벿�ֶ�Ӧ��Item
        if vAfterItem <> nil then  // ѡ�����λ�ò���Item����򴴽�����Ķ���Item
        begin
          Items.Insert(AItemNo + 1, vAfterItem);
          Inc(vExtraCount);
        end;

        if vsBefor <> '' then  // ѡ����ʼλ�ò���Item�ʼ������ǰ�벿�֣�����Item����ѡ�в���
        begin
          vItem.Text := vsBefor;  // ����ǰ�벿���ı�

          // ����ѡ���ı���Ӧ��Item
          vSelItem := CreateDefaultTextItem;
          vSelItem.ParaNo := vItem.ParaNo;
          vSelItem.StyleNo := vStyleNo;
          vSelItem.Text := vSelText;

          if vAfterItem <> nil then  // �к�벿�֣��м��������ʽ��ǰ��϶����ܺϲ�
          begin
            Items.Insert(AItemNo + 1, vSelItem);
            Inc(vExtraCount);
          end
          else  // û�к�벿�֣�˵��ѡ����Ҫ�ͺ����жϺϲ�
          begin
            if (AItemNo < Items.Count - 1) and MergeItemText(vSelItem, Items[AItemNo + 1]) then
            begin
              Items[AItemNo + 1].Text := vSelText + Items[AItemNo + 1].Text;
              SelectInfo.StartItemNo := AItemNo + 1;
              SelectInfo.StartItemOffset := 0;
              SelectInfo.EndItemNo := AItemNo + 1;
              SelectInfo.EndItemOffset := Length(vSelText);
              Exit;
            end;
            Items.Insert(AItemNo + 1, vSelItem);
            Inc(vExtraCount);
          end;

          SelectInfo.StartItemNo := AItemNo + 1;
          SelectInfo.StartItemOffset := 0;
          SelectInfo.EndItemNo := AItemNo + 1;
          SelectInfo.EndItemOffset := Length(vSelText);
        end
        else  // ѡ����ʼλ����Item�ʼ
        begin
          //vItem.Text := vSelText;  // BreakByOffset�Ѿ�����ѡ�в����ı�
          vItem.StyleNo := vStyleNo;

          if MergeItemToPrio(AItemNo) then // ��ǰItem�ϲ�����һ��Item
          begin
            Items.Delete(AItemNo);
            Dec(vExtraCount);

            SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
            vLen := Items[SelectInfo.StartItemNo].Length;
            SelectInfo.StartItemOffset := vLen - Length(vSelText);
            SelectInfo.EndItemNo := SelectInfo.StartItemNo;
            SelectInfo.EndItemOffset := vLen;
          end;
        end;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'ApplyStartItemѡ���ڲ�ͬItem�У�����ѡ����ʼItem'}
  procedure ApplyRangeStartItem(const AItemNo: Integer);
  var
    vAfterItem: THCCustomItem;
  begin
    vItem := Items[AItemNo];
    if vItem.StyleNo < THCStyle.RsNull then  // ���ı�
      (vItem as THCCustomRectItem).ApplySelectTextStyle(Style, AMatchStyle)
    else  // �ı�
    begin
      vStyleNo := AMatchStyle.GetMatchStyleNo(Style, vItem.StyleNo);

      if vItem.StyleNo <> vStyleNo then
      begin
        if vItem.IsSelectComplate then  // Itemȫѡ����
          vItem.StyleNo := vStyleNo
        else  // Item����ѡ��
        begin
          vAfterItem := Items[AItemNo].BreakByOffset(SelectInfo.StartItemOffset);  // ��벿�ֶ�Ӧ��Item
          vAfterItem.StyleNo := vStyleNo;
          Items.Insert(AItemNo + 1, vAfterItem);
          Inc(vExtraCount);

          SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
          SelectInfo.StartItemOffset := 0;
          SelectInfo.EndItemNo := SelectInfo.EndItemNo + 1;
        end;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'ApplyEndItemѡ���ڲ�ͬItem�У�����ѡ�н���Item'}
  procedure ApplyRangeEndItem(const AItemNo: Integer);
  var
    vBeforItem: THCCustomItem;
  begin
    vItem := Items[AItemNo];
    if vItem.StyleNo < THCStyle.RsNull then  // ���ı�
      (vItem as THCCustomRectItem).ApplySelectTextStyle(Style, AMatchStyle)
    else  // �ı�
    begin
      vStyleNo := AMatchStyle.GetMatchStyleNo(Style, vItem.StyleNo);

      if vItem.StyleNo <> vStyleNo then
      begin
        if vItem.IsSelectComplate then  // Itemȫѡ����
          vItem.StyleNo := vStyleNo
        else  // Item����ѡ����
        begin
          vText := vItem.Text;
          vSelText := Copy(vText, 1, SelectInfo.EndItemOffset); // ѡ�е��ı�
          Delete(vText, 1, SelectInfo.EndItemOffset);
          vItem.Text := vText;

          vBeforItem := CreateDefaultTextItem;
          vBeforItem.ParaNo := vItem.ParaNo;
          vBeforItem.StyleNo := vStyleNo;
          vBeforItem.Text := vSelText;  // ����ǰ�벿���ı���Ӧ��Item
          vBeforItem.ParaFirst := vItem.ParaFirst;
          vItem.ParaFirst := False;

          Items.Insert(AItemNo, vBeforItem);
          Inc(vExtraCount);
        end;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'ApplyNorItemѡ���ڲ�ͬItem�������м�Item'}
  procedure ApplyRangeNorItem(const AItemNo: Integer);
  begin
    vItem := Items[AItemNo];
    if vItem.StyleNo < THCStyle.RsNull then  // ���ı�
      (vItem as THCCustomRectItem).ApplySelectTextStyle(Style, AMatchStyle)
    else  // �ı�
      vItem.StyleNo := AMatchStyle.GetMatchStyleNo(Style, vItem.StyleNo);
  end;
  {$ENDREGION}

var
  i, vFormatFirstItemNo, vFormatLastItemNo, vMStart, vMEnd: Integer;
begin
  Self.Initialize;
  vExtraCount := 0;

  GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
  if not SelectExists then  // û��ѡ��
  begin
    if Items[SelectInfo.StartItemNo].Length = 0 then  // ���У��ı䵱ǰ��괦��ʽ
    begin
      Items[SelectInfo.StartItemNo].StyleNo := AMatchStyle.GetMatchStyleNo(Style, Items[SelectInfo.StartItemNo].StyleNo);
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      Style.UpdateInfoRePaint;
      Style.UpdateInfoReCaret;
    end;

    Exit;
  end;

  if SelectInfo.EndItemNo < 0 then  // û������ѡ������
  begin
    if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
    begin
      // ����ı������RectItem��ȱ仯������Ҫ��ʽ�������һ��Item
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
      (Items[SelectInfo.StartItemNo] as THCCustomRectItem).ApplySelectTextStyle(Style, AMatchStyle);
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
    end;
  end
  else  // ������ѡ������
  begin
    vFormatLastItemNo := GetParaLastItemNo(SelectInfo.EndItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

    for i := SelectInfo.StartItemNo to SelectInfo.EndItemNo do
    begin
      if Items[i].StyleNo > THCStyle.RsNull then
      begin
        AMatchStyle.Append := not AMatchStyle.StyleHasMatch(Style, Items[i].StyleNo);  // ���ݵ�һ���ж��������ʽ���Ǽ�����ʽ
        Break;
      end;
    end;

    if SelectInfo.StartItemNo = SelectInfo.EndItemNo then  // ѡ�з�����ͬһItem��
      ApplySameItem(SelectInfo.StartItemNo)
    else  // ѡ�з����ڲ�ͬ��Item�������ȴ���ѡ�з�Χ����ʽ�ı䣬�ٴ���ϲ����ٴ���ѡ������ȫ������ѡ��״̬
    begin
      ApplyRangeEndItem(SelectInfo.EndItemNo);
      for i := SelectInfo.EndItemNo - 1 downto SelectInfo.StartItemNo + 1 do
        ApplyRangeNorItem(i);  // ����ÿһ��Item����ʽ
      ApplyRangeStartItem(SelectInfo.StartItemNo);

      { ��ʽ�仯�󣬴Ӻ���ǰ����ѡ�з�Χ�ڱ仯��ĺϲ� }
      //if (SelectInfo.EndItemNo < Items.Count - 1) and (not Items[SelectInfo.EndItemNo + 1].ParaFirst) then  // ѡ����������һ�����Ƕ���
      if SelectInfo.EndItemNo < vFormatLastItemNo + vExtraCount then  // ѡ����������һ�����Ƕ���
      begin
        if MergeItemToNext(SelectInfo.EndItemNo) then
        begin
          Items.Delete(SelectInfo.EndItemNo + 1);
          Dec(vExtraCount);
        end;
      end;

      for i := SelectInfo.EndItemNo downto SelectInfo.StartItemNo + 1 do
      begin
        vLen := Items[i - 1].Length;
        if MergeItemToPrio(i) then  // �ϲ���ǰһ��
        begin
          Items.Delete(i);
          Dec(vExtraCount);

          if i = SelectInfo.EndItemNo then  // ֻ�ںϲ���ѡ�����Item�żӳ�ƫ��
            SelectInfo.EndItemOffset := SelectInfo.EndItemOffset + vLen;
          SelectInfo.EndItemNo := SelectInfo.EndItemNo - 1;
        end;
      end;

      // ��ʼ��Χ
      if (SelectInfo.StartItemNo > 0) and (not Items[SelectInfo.StartItemNo].ParaFirst) then  // ѡ����ǰ�治�Ƕεĵ�һ��Item
      begin
        vLen := Items[SelectInfo.StartItemNo - 1].Length;
        if MergeItemToPrio(SelectInfo.StartItemNo) then  // �ϲ���ǰһ��
        begin
          Items.Delete(SelectInfo.StartItemNo);
          Dec(vExtraCount);

          SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
          SelectInfo.StartItemOffset := vLen;
          SelectInfo.EndItemNo := SelectInfo.EndItemNo - 1;
          if SelectInfo.StartItemNo = SelectInfo.EndItemNo then  // ѡ�еĶ��ϲ���һ����
            SelectInfo.EndItemOffset := SelectInfo.EndItemOffset + vLen;
        end;
      end;
    end;

    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + vExtraCount, vExtraCount);
  end;

  MatchItemSelectState;

  Style.UpdateInfoRePaint;
  Style.UpdateInfoReCaret;
end;

function THCCustomRichData.CalcContentHeight: Integer;
begin
  if DrawItems.Count > 0 then
    Result := DrawItems[DrawItems.Count - 1].Rect.Bottom - DrawItems[0].Rect.Top
  else
    Result := 0;
end;

function THCCustomRichData.CanDeleteItem(const AItemNo: Integer): Boolean;
begin
  Result := CanEdit;
end;

function THCCustomRichData.CanEdit: Boolean;
begin
  Result := not FReadOnly;
  if not Result then
    Beep; //MessageBeep(MB_OK);
end;

procedure THCCustomRichData.Initialize;
begin
  FMouseLBDowning := False;
  FMouseDownItemNo := -1;
  FMouseDownItemOffset := -1;
  FMouseMoveItemNo := -1;
  FMouseMoveItemOffset := -1;
  FMouseMoveRestrain := False;
  CaretDrawItemNo := -1;
  FSelecting := False;
  FDraging := False;
end;

function THCCustomRichData.InsertBreak: Boolean;
var
  vKey: Word;
begin
  Result := False;

  if not CanEdit then Exit;

  vKey := VK_RETURN;
  KeyDown(vKey, []);

  Result := True;
end;

function THCCustomRichData.InsertItem(const AIndex: Integer;
  const AItem: THCCustomItem): Boolean;
var
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
begin
  Result := False;

  if not CanEdit then Exit;

  //-------- ��ָ����Index������Item --------//

  //DeleteSelection;  // �������ѡ����������ô������������ʱ��ɾ��ѡ��
  AItem.ParaNo := Style.CurParaNo;
  if AItem is THCTextItem then
    AItem.StyleNo := Style.CurStyleNo;

  if IsEmpty then
  begin
    FormatItemPrepare(0);
    Items.Clear;
    AItem.ParaFirst := True;
    Items.Insert(0, AItem);
    ReFormatData_(0, 0, 1);
    ReSetSelectAndCaret(0);
    Result := True;
    Exit;
  end;

  {˵����������λ�ò������һ���Ҳ���λ���Ƕ���ʼ����ô����������һ�������룬
   Ҳ������Ҫ����һ����ǰҳ���룬��ʱ��AItem��ParaFirst����Ϊ�ж�����}

  if AItem.StyleNo < THCStyle.RsNull then  // ����RectItem
  begin
    if AIndex < Items.Count then  // ������ĩβ���һ��Item
    begin
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, AIndex, 0);
      if AItem.ParaFirst then  // ����һ��
      begin
        if Items[AIndex].ParaFirst then  // ��һ�ο�ʼ��Ϊ�ǿ�ʼ�����Ҫ����Ϊһ��ȥ�����жϼ���
          Items[AIndex].ParaFirst := False;
      end;
    end
    else  // ��ĩβ���һ��Item
    begin
      vFormatFirstItemNo := AIndex - 1;
      vFormatLastItemNo := AIndex - 1;
    end;

    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    Items.Insert(AIndex, AItem);
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
    ReSetSelectAndCaret(AIndex);
  end
  else  // �����ı�Item
  begin
    if AIndex < Items.Count then
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, AIndex, 0)
    else
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, AIndex - 1, 0);

    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

    if (AIndex < Items.Count) and (not AItem.ParaFirst) and (Items[AIndex].CanConcatItems(AItem)) then  // �͵�ǰλ�ô��ܺϲ�
    begin
      Items[AIndex].Text := AItem.Text + Items[AIndex].Text;
      if AItem.ParaFirst then  // ���ǵ�ԭλ���Ƕ��ף��²��벻�Ƕ��ף����Բ���ֱ�� Items[AIndex].ParaFirst := AItem.ParaFirst
        Items[AIndex].ParaFirst := True;

      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 0);
      ReSetSelectAndCaret(AIndex, AItem.Length);
    end
    else
    if (AIndex > 0) and (not AItem.ParaFirst) and (Items[AIndex - 1].CanConcatItems(AItem)) then  // ��ǰһ���ܺϲ�
    begin
      Items[AIndex - 1].Text := Items[AIndex - 1].Text + AItem.Text;
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 0);
      ReSetSelectAndCaret(AIndex - 1);
    end
    else  // ���ܺͲ���λ�ü�����λ��ǰ��Item�ϲ�
    begin
      if AItem.ParaFirst then
        Items[AIndex].ParaFirst := False;

      if Items[AIndex].Text <> '' then  // ����λ�ô����ǿ���
      begin
        Items.Insert(AIndex, AItem);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
      end
      else
      begin
        AItem.ParaFirst := Items[AIndex].ParaFirst;

        Items.Delete(AIndex);
        Items.Insert(AIndex, AItem);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      end;

      ReSetSelectAndCaret(AIndex);
    end;
  end;

  Result := True;
end;

function THCCustomRichData.InsertLine(const ALineHeight: Integer): Boolean;
var
  vItem: TLineItem;
begin
  Result := False;

  if not CanEdit then Exit;

  vItem := TLineItem.Create(Self.Width, 21);
  vItem.LineHeght := ALineHeight;
  Result := InsertItem(vItem);
end;

function THCCustomRichData.TableInsertColAfter(const AColCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).InsertColAfter(AColCount);
    end);
end;

function THCCustomRichData.TableInsertColBefor(const AColCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).InsertColBefor(AColCount);
    end);
end;

function THCCustomRichData.TableInsertRC(const AProc: TInsertProc): Boolean;
var
  vCurItemNo, vFormatFirstItemNo, vFormatLastItemNo: Integer;
begin
  Result := False;
  vCurItemNo := GetCurItemNo;
  if Items[vCurItemNo] is THCTableItem then
  begin
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, vCurItemNo, 0);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    Result := AProc(Items[vCurItemNo]);
    if Result then
    begin
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 0);
      Style.UpdateInfoReCaret;
      Style.UpdateInfoRePaint;
    end;
  end;
end;

function THCCustomRichData.TableInsertRowAfter(const ARowCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).InsertRowAfter(ARowCount);
    end);
end;

function THCCustomRichData.TableInsertRowBefor(const ARowCount: Byte): Boolean;
begin
  if not CanEdit then Exit(False);

  Result := TableInsertRC(function(const AItem: THCCustomItem): Boolean
    begin
      Result := (AItem as THCTableItem).InsertRowBefor(ARowCount);
    end);
end;

function THCCustomRichData.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
var
  vInsPos, vFormatFirstItemNo, vFormatLastItemNo: Integer;
  vEmpty: Boolean;
  vItem, vAfterItem: THCCustomItem;
  i, vItemCount, vStyleNo: Integer;
  vDataSize: Int64;
begin
  Result := False;

  if not CanEdit then Exit;

  vAfterItem := nil;
  vEmpty := IsEmpty;

  if vEmpty then  // ��
  begin
    Clear;
    vInsPos := 0;
  end
  else  // ������
  begin
    DeleteSelected;
    // ȷ������λ��
    vInsPos := SelectInfo.StartItemNo;
    if Items[vInsPos].StyleNo < THCStyle.RsNull then  // RectItem
    begin
      if SelectInfo.StartItemOffset = OffsetInner then  // ����
      begin
        GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, SelectInfo.StartItemNo, OffsetInner);
        FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
        Result := (Items[vInsPos] as THCCustomRectItem).InsertStream(AStream, AStyle, AFileVersion);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);

        Exit;
      end
      else
      if SelectInfo.StartItemOffset = OffsetBefor then  // ��ǰ
        //vIns := vCurItemNo
      else  // ���
        vInsPos := vInsPos + 1;
    end
    else  // TextItem
    begin
      // ���жϹ���Ƿ�����󣬷�ֹ��ItemʱSelectInfo.StartItemOffset = 0����ǰ����
      if SelectInfo.StartItemOffset = Items[vInsPos].Length then  // ���
        vInsPos := vInsPos + 1
      else
      if SelectInfo.StartItemOffset = 0 then  // ��ǰ
        //vIns := vCurItemNo
      else  // ����
      begin
        vAfterItem := Items[vInsPos].BreakByOffset(SelectInfo.StartItemOffset);  // ��벿�ֶ�Ӧ��Item
        vInsPos := vInsPos + 1;
      end;
    end;
  end;

  AStream.ReadBuffer(vDataSize, SizeOf(vDataSize));
  AStream.ReadBuffer(vItemCount, SizeOf(vItemCount));
  if vItemCount = 0 then Exit;

  // ��Ϊ����ĵ�һ�����ܺͲ���λ��ǰһ���ϲ�������λ�ÿ��������ף�����Ҫ�Ӳ���λ��
  // ����һ����ʼ��ʽ����Ϊ�򵥴���ֱ��ʹ������β
  GetParaItemRang(SelectInfo.StartItemNo, vFormatFirstItemNo, vFormatLastItemNo);

  // �����ʽ����ʼ������ItemNo
  if Items.Count > 0 then  // ����Empty
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo)
  else
  begin
    vFormatFirstItemNo := 0;
    vFormatLastItemNo := -1;
  end;

  for i := 0 to vItemCount - 1 do
  begin
    AStream.ReadBuffer(vStyleNo, SizeOf(vStyleNo));
    vItem := CreateItemByStyle(vStyleNo);
    vItem.LoadFromStream(AStream, AStyle, AFileVersion);
    if AStyle <> nil then  // ����ʽ��
    begin
      if vItem.StyleNo > THCStyle.RsNull then
        vItem.StyleNo := Style.GetStyleNo(AStyle.TextStyles[vItem.StyleNo], True);
      vItem.ParaNo := Style.GetParaNo(AStyle.ParaStyles[vItem.ParaNo], True);
    end
    else  // ����ʽ��
    begin
      if vItem.StyleNo > THCStyle.RsNull then
        vItem.StyleNo := Style.CurStyleNo;
      vItem.ParaNo := Style.CurParaNo;
    end;

    if (i = 0) and (vInsPos > 0) then  // ��һ�������ڿ�ʼ����(ճ��)
      vItem.ParaFirst := False;

    Items.Insert(vInsPos + i, vItem);
  end;

  if vAfterItem <> nil then  // �����������Item�м䣬ԭItem����ֳ�2��
  begin
    if MergeItemText(Items[vInsPos + vItemCount - 1], vAfterItem) then
      FreeAndNil(vAfterItem)
    else
    begin
      Items.Insert(vInsPos + vItemCount, vAfterItem);
      Inc(vItemCount);
    end;
  end;

  if (vInsPos > vFormatFirstItemNo) and (vInsPos > 0) then
  begin
    if Items[vInsPos - 1].Length = 0 then  // ����λ��ǰ���ǿ���Item
    begin
      Items[vInsPos].ParaFirst := Items[vInsPos - 1].ParaFirst;
      Items.Delete(vInsPos - 1);
      Dec(vItemCount);
    end
    else
    if MergeItemText(Items[vInsPos - 1], Items[vInsPos]) then  // ����ĺ�ǰ��ĺϲ�
    begin
      Items.Delete(vInsPos);
      Dec(vItemCount);
    end;
  end;

  ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + vItemCount, vItemCount);

  ReSetSelectAndCaret(vInsPos + vItemCount - 1);  // ѡ�в����������Itemλ��

  Style.UpdateInfoReCaret;
  Style.UpdateInfoRePaint;
end;

function THCCustomRichData.InsertItem(const AItem: THCCustomItem): Boolean;
var
  vCurItemNo: Integer;
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
  vText, vsBefor, vsAfter: string;
  vAfterItem: THCCustomItem;
begin
  Result := False;

  if not CanEdit then Exit;

  DeleteSelected;

  AItem.ParaNo := Style.CurParaNo;
  if AItem is THCTextItem then
    AItem.StyleNo := Style.CurStyleNo;

  if IsEmpty then
  begin
    FormatItemPrepare(0);
    Items.Clear;
    AItem.ParaFirst := True;
    if AItem.StyleNo > THCStyle.RsNull then
      AItem.StyleNo := Style.CurStyleNo
    else
    if AItem is THCTextRectItem then
      (AItem as THCTextRectItem).TextStyleNo := Style.CurStyleNo;

    Items.Insert(0, AItem);
    ReFormatData_(0, 0, 1);
    ReSetSelectAndCaret(0);
    Result := True;
    Exit;
  end;
  vCurItemNo := GetCurItemNo;

  if Items[vCurItemNo].StyleNo < THCStyle.RsNull then  // ��ǰλ���� RectItem
  begin
    if SelectInfo.StartItemOffset = OffsetInner then  // ��������
    begin
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
      Result := (Items[vCurItemNo] as THCCustomRectItem).InsertItem(AItem);
      if Result then
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 0);
    end
    else  // ��ǰor���
    begin
      if SelectInfo.StartItemOffset = OffsetBefor then  // ��ǰ
        Result := InsertItem(SelectInfo.StartItemNo, AItem)
      else
        Result := InsertItem(SelectInfo.StartItemNo + 1, AItem);
    end;
  end
  else  // ��ǰλ����TextItem
  begin
    if SelectInfo.StartItemOffset = 0 then  // ����ǰ�����
      Result := InsertItem(SelectInfo.StartItemNo, AItem)
    else
    if (SelectInfo.StartItemOffset = Items[vCurItemNo].Length) then  // ��TextItem������
      Result := InsertItem(SelectInfo.StartItemNo + 1, AItem)
    else  // ��Item�м�
    begin
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

      vText := Items[vCurItemNo].Text;
      vsBefor := Copy(vText, 1, SelectInfo.StartItemOffset);  // ǰ�벿���ı�
      vsAfter := Copy(vText, SelectInfo.StartItemOffset + 1, Items[vCurItemNo].Length
        - SelectInfo.StartItemOffset);  // ��벿���ı�

      if Items[vCurItemNo].CanConcatItems(AItem) then  // �ܺϲ�
      begin
        if AItem.ParaFirst then  // �¶�
        begin
          Items[vCurItemNo].Text := vsBefor;
          AItem.Text := AItem.Text + vsAfter;
          vCurItemNo := vCurItemNo + 1;
          Items.Insert(vCurItemNo, AItem);
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 1);
          ReSetSelectAndCaret(vCurItemNo);
        end
        else  // ͬһ���в���
        begin
          vsBefor := vsBefor + AItem.Text;
          Items[vCurItemNo].Text := vsBefor + vsAfter;
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo, 0);
          SelectInfo.StartItemNo := vCurItemNo;
          SelectInfo.StartItemOffset := Length(vsBefor);
          //CaretDrawItemNo := GetItemLastDrawItemNo(vCurItemNo);
        end;
      end
      else  // ���ܺϲ�
      begin
        vAfterItem := Items[vCurItemNo].BreakByOffset(SelectInfo.StartItemOffset);  // ��벿�ֶ�Ӧ��Item

        // �����벿�ֶ�Ӧ��Item
        vCurItemNo := vCurItemNo + 1;
        Items.Insert(vCurItemNo, vAfterItem);
        // ������Item
        Items.Insert(vCurItemNo, AItem);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 2, 2);
        ReSetSelectAndCaret(vCurItemNo);
      end;

      Result := True;
    end;
  end;
end;

function THCCustomRichData.InsertTable(const ARowCount,
  AColCount: Integer): Boolean;
var
  vItem: THCCustomItem;
begin
  Result := False;

  if not CanEdit then Exit;

  vItem := THCTableItem.Create(Style, ARowCount, AColCount, Self.Width, Self);
  Result := InsertItem(vItem);
end;

function THCCustomRichData.InsertText(const AText: string): Boolean;
var
  vNewPara: Boolean;

  function InsertTextItem(const AText: string): Boolean;
  var
    vItem: THCCustomItem;
  begin
    vItem := CreateDefaultTextItem;
    vItem.Text := AText;
    vItem.ParaFirst := vNewPara;
    Result := InsertItem(vItem);
    vNewPara := True;
  end;

var
  vPCharStart, vPCharEnd, vPtr: PChar;
  vS: string;
begin
  Result := False;

  if not CanEdit then Exit;

  vNewPara := False;
  vPCharStart := PChar(AText);
  vPCharEnd := vPCharStart + Length(AText);
  if vPCharStart = vPCharEnd then Exit;
  vPtr := vPCharStart;
  while vPtr < vPCharEnd do
  begin
    case vPtr^ of
      #13:
        begin
          System.SetString(vS, vPCharStart, vPtr - vPCharStart);
          if not InsertTextItem(vS) then Exit;
          Inc(vPtr);
          vPCharStart := vPtr;
          Continue;
        end;

      #10:
        begin
          Inc(vPtr);
          vPCharStart := vPtr;
          Continue;
        end;
    end;

    Inc(vPtr);
  end;
  System.SetString(vS, vPCharStart, vPtr - vPCharStart);
  Result := InsertTextItem(vS)
end;

procedure THCCustomRichData.KeyDown(var Key: Word; Shift: TShiftState);
var
  vCurItem: THCCustomItem;
  vParaFirstItemNo, vParaLastItemNo: Integer;
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
  vSelectExist: Boolean;

  {$REGION 'TABKeyDown ����'}
  procedure TABKeyDown;

    function CreateTabItem: TTabItem;
    var
      vSize: TSize;
    begin
      Style.TextStyles[Style.CurStyleNo].ApplyStyle(Style.DefCanvas);
      vSize := Style.DefCanvas.TextExtent('����');
      Result := TTabItem.Create(vSize.cx, vSize.cy);
      Result.ParaNo := Style.CurParaNo;
    end;

  var
    vItem: THCCustomItem;
  begin
    vItem := CreateTabItem;
    if vCurItem.StyleNo < THCStyle.RsNull then  // ��ǰ��RectItem
    begin
      if SelectInfo.StartItemOffset = OffsetInner then // ������
      begin
        if (vCurItem as THCCustomRectItem).WantKeyDown(Key, Shift) then  // ����˼�
        begin
          GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
          FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
          (vCurItem as THCCustomRectItem).KeyDown(Key, Shift);
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
        end;

        Exit;
      end;
    end;

    Self.InsertItem(vItem);
  end;
  {$ENDREGION}

  {$REGION 'LeftKeyDown ��������˴������漰��񣬱����RectItemKeyDown�д�����'}
  procedure LeftKeyDown;
  var
    vNewCaretDrawItemNo: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      if SelectInfo.StartItemOffset <> 0 then  // ����Item�ʼ
        SelectInfo.StartItemOffset := SelectInfo.StartItemOffset - 1
      else  // ��Item�ʼ�����
      begin
        if SelectInfo.StartItemNo > 0 then  // ���ǵ�һ��Item���ʼ����ǰ���ƶ�
        begin
          SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;  // ��һ��
          if GetItemStyle(SelectInfo.StartItemNo) < THCStyle.RsNull then
            SelectInfo.StartItemOffset := OffsetAfter
          else
            SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;

          if not DrawItems[Items[SelectInfo.StartItemNo + 1].FirstDItemNo].LineFirst then  // �ƶ�ǰItem��������ʼ
          begin
            KeyDown(Key, Shift);
            Exit;
          end;
        end
        else  // �ڵ�һ��Item�����水�������
          Key := 0;
      end;
    end;
    if Key <> 0 then
    begin
      vNewCaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
      if vNewCaretDrawItemNo <> CaretDrawItemNo then  // ��DrawItemNo��
      begin
        if (vNewCaretDrawItemNo = CaretDrawItemNo - 1)  // �ƶ���ǰһ����
          and (DrawItems[vNewCaretDrawItemNo].ItemNo = DrawItems[CaretDrawItemNo].ItemNo)  // ��ͬһ��Item
          and (DrawItems[CaretDrawItemNo].LineFirst)  // ԭ������
          and (SelectInfo.StartItemOffset = DrawItems[CaretDrawItemNo].CharOffs - 1)  // ���λ��Ҳ��ԭDrawItem����ǰ��
        then
          // ������
        else
          CaretDrawItemNo := vNewCaretDrawItemNo;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'RightKeyDown �ҷ�������˴������漰��񣬱����RectItemKeyDown�д�����'}
  procedure RightKeyDown;
  var
    vNewCaretDrawItemNo: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.StartItemNo := SelectInfo.EndItemNo;
      SelectInfo.StartItemOffset := SelectInfo.EndItemOffset;
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      if SelectInfo.StartItemOffset < vCurItem.Length then  // ����Item���ұ�
        SelectInfo.StartItemOffset := SelectInfo.StartItemOffset + 1
      else  // ��Item���ұ�
      begin
        if SelectInfo.StartItemNo < Items.Count - 1 then  // �������һ��Item�����ұ�
        begin
          SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;  // ѡ����һ��Item
          SelectInfo.StartItemOffset := 0;  // ��һ����ǰ��
          if not DrawItems[Items[SelectInfo.StartItemNo].FirstDItemNo].LineFirst then  // ��һ��Item��������ʼ
          begin
            KeyDown(Key, Shift);
            Exit;
          end;
        end
        else  // �����һ��Item�����水���ҷ����
          Key := 0;
      end;
    end;
    if Key <> 0 then
    begin
      vNewCaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
      if vNewCaretDrawItemNo = CaretDrawItemNo then  // �ƶ�ǰ����ͬһ��DrawItem
      begin
        if (SelectInfo.StartItemOffset = DrawItems[vNewCaretDrawItemNo].CharOffsetEnd)  // �ƶ���DrawItem�������
          and (vNewCaretDrawItemNo < DrawItems.Count - 1)  // �������һ��
          and (DrawItems[vNewCaretDrawItemNo].ItemNo = DrawItems[vNewCaretDrawItemNo + 1].ItemNo)  // ��һ��DrawItem�͵�ǰ��ͬһ��Item
          and (DrawItems[vNewCaretDrawItemNo + 1].LineFirst)  // ��һ��������
          and (SelectInfo.StartItemOffset = DrawItems[vNewCaretDrawItemNo + 1].CharOffs - 1)  // ���λ��Ҳ����һ��DrawItem����ǰ��
        then
          CaretDrawItemNo := vNewCaretDrawItemNo + 1;  // ����Ϊ��һ������
      end
      else
        CaretDrawItemNo := vNewCaretDrawItemNo;
    end;
  end;
  {$ENDREGION}

  {$REGION 'RectItemKeyDown Rect����Item��KeyDown�¼�'}
  procedure RectItemKeyDown;
  var
    vLineFirst: Boolean;
    vItem: THCCustomItem;
    vLen: Integer;
    vRectItem: THCCustomRectItem;
  begin
    vRectItem := vCurItem as THCCustomRectItem;
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    if SelectInfo.StartItemOffset = OffsetInner then  // ������
    begin
      if vRectItem.WantKeyDown(Key, Shift) then
      begin
        vRectItem.KeyDown(Key, Shift);
        if vRectItem.HeightChanged then
        begin
          vRectItem.HeightChanged := False;
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
        end;
      end
      else  // �ڲ�����Ӧ�˼�
      begin
        case Key of
          VK_BACK:
            begin
              SelectInfo.StartItemOffset := OffsetAfter;
              RectItemKeyDown;
            end;

          VK_DELETE:
            begin
              SelectInfo.StartItemOffset := OffsetBefor;
              RectItemKeyDown;
            end;
        end;
      end;
    end
    else
    if SelectInfo.StartItemOffset = OffsetBefor then  // ��RectItemǰ
    begin
      case Key of
        VK_LEFT:
          LeftKeyDown;

        VK_RIGHT:
          begin
            if vRectItem.WantKeyDown(Key, Shift) then
              SelectInfo.StartItemOffset := OffsetInner
            else
              SelectInfo.StartItemOffset := OffsetAfter;

            CaretDrawItemNo := Items[SelectInfo.StartItemNo].FirstDItemNo;
          end;

        VK_RETURN:
          begin
            vLineFirst := DrawItems[vCurItem.FirstDItemNo].LineFirst;
            if vLineFirst then  // RectItem�����ף��������
            begin
              vCurItem := CreateDefaultTextItem;
              vCurItem.ParaFirst := True;
              Items.Insert(SelectInfo.StartItemNo, vCurItem);
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
              SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
            end
            else  // RectItem��������
            begin
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
              vCurItem.ParaFirst := True;
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
            end;
          end;

        VK_BACK:  // ��RectItemǰ
          begin
            if vCurItem.ParaFirst then  // �Ƕ���
            begin
              vCurItem.ParaFirst := False;
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
            end
            else  // ���Ƕ���
            begin
              // ѡ����һ�����
              SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
              if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
                SelectInfo.StartItemOffset := OffsetAfter
              else
                SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;

              KeyDown(Key, Shift);  // ִ��ǰһ����ɾ��
            end;
          end;

        VK_DELETE:  // ��RectItemǰ
          begin
            if not CanDeleteItem(SelectInfo.StartItemNo) then  // ����ɾ��
            begin
              SelectInfo.StartItemOffset := OffsetAfter;
              Exit;
            end;

            if vCurItem.ParaFirst then  // �Ƕ���
            begin
              if SelectInfo.StartItemNo <> vFormatLastItemNo then  // �β���ֻ��һ��
              begin
                Items[SelectInfo.StartItemNo + 1].ParaFirst := True;
                Items.Delete(SelectInfo.StartItemNo);
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
              end
              else  // ��ɾ������
              begin
                Items.Delete(SelectInfo.StartItemNo);
                vCurItem := CreateDefaultTextItem;
                vCurItem.ParaFirst := True;
                Items.Insert(SelectInfo.StartItemNo, vCurItem);
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
              end;
            end
            else  // ���Ƕ���
            begin
              if SelectInfo.StartItemNo < vFormatLastItemNo then  // ���м�
              begin
                if Items[SelectInfo.StartItemNo - 1].StyleNo < THCStyle.RsNull then  // ǰһ����RectItem
                  vLen := OffsetAfter
                else  // ǰһ����TextItem
                  vLen := Items[SelectInfo.StartItemNo - 1].Length;

                // ���RectItemǰ��(ͬһ��)�и߶�С�ڴ�RectItme��Item(��Tab)��
                // ���ʽ��ʱ��RectItemΪ�ߣ����¸�ʽ��ʱ�����RectItem����λ����ʼ��ʽ����
                // �и߶��Ի���TabΪ�иߣ�Ҳ����RectItem�߶ȣ�������Ҫ���п�ʼ��ʽ��
                Items.Delete(SelectInfo.StartItemNo);
                if MergeItemText(Items[SelectInfo.StartItemNo - 1], Items[SelectInfo.StartItemNo]) then  // ԭRectItemǰ���ܺϲ�
                begin
                  Items.Delete(SelectInfo.StartItemNo);
                  ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 2, -2);
                end
                else
                  ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);

                SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
                SelectInfo.StartItemOffset := vLen;
              end
              else  // ��β(�β�ֻһ��Item)
              begin
                Items.Delete(SelectInfo.StartItemNo);
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);

                SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
                if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
                  SelectInfo.StartItemOffset := OffsetAfter
                else
                  SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
              end;
            end;
          end;

        VK_TAB:
          TABKeyDown;
      end;
    end
    else
    if SelectInfo.StartItemOffset = OffsetAfter then  // ����󣬺��油��һ����Item
    begin
      case Key of
        VK_BACK:
          begin
            if not CanDeleteItem(SelectInfo.StartItemNo) then  // ����ɾ��
            begin
              SelectInfo.StartItemOffset := OffsetBefor;
              Exit;
            end;

            if vCurItem.ParaFirst then  // �Ƕ���
            begin
              if (SelectInfo.StartItemNo > 0) and (SelectInfo.StartItemNo < Items.Count - 1) and (not Items[SelectInfo.StartItemNo + 1].ParaFirst) then  // ͬһ�λ�������
              begin
                Items.Delete(SelectInfo.StartItemNo);
                Items[SelectInfo.StartItemNo].ParaFirst := True;
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
              end
              else  // �ն���
              begin
                Items.Delete(SelectInfo.StartItemNo);
                vItem := CreateDefaultTextItem;
                vItem.ParaFirst := True;
                Items.Insert(SelectInfo.StartItemNo, vItem);
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
                SelectInfo.StartItemOffset := 0;
              end;
            end
            else  // ���Ƕ���
            begin
              SelectInfo.StartItemOffset := OffsetBefor;
              Key := VK_DELETE;  // ��ʱ�滻
              RectItemKeyDown;
              Key := VK_BACK;  // ��ԭ
            end;
          end;

        VK_DELETE:
          begin
            if SelectInfo.StartItemNo < Items.Count - 1 then  // �������һ��
            begin
              SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
              SelectInfo.StartItemOffset := 0;
              KeyDown(Key, Shift);
              Exit;
            end;
          end;

        VK_LEFT:
          begin
            if vRectItem.WantKeyDown(Key, Shift) then
              SelectInfo.StartItemOffset := OffsetInner
            else
              SelectInfo.StartItemOffset := OffsetBefor;

            CaretDrawItemNo := Items[SelectInfo.StartItemNo].FirstDItemNo;
          end;

        VK_RIGHT:
          RightKeyDown;

        VK_RETURN:
          begin
            vCurItem := CreateDefaultTextItem;
            vCurItem.ParaFirst := True;
            Items.Insert(SelectInfo.StartItemNo + 1, vCurItem);
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
            SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
            SelectInfo.StartItemOffset := vCurItem.Length;
            CaretDrawItemNo := Items[SelectInfo.StartItemNo].FirstDItemNo;
          end;

        VK_TAB:
          TABKeyDown;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'EnterKeyDown �س�'}
  procedure EnterKeyDown;
  var
    vItem: THCCustomItem;
  begin
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    // �жϹ��λ��������λ���
    if SelectInfo.StartItemOffset = 0 then  // �����Item��ǰ��
    begin
      if not vCurItem.ParaFirst then  // ԭ�����Ƕ���
      begin
        vCurItem.ParaFirst := True;
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      end
      else  // ԭ�����Ƕ���
      begin
        vItem := CreateDefaultTextItem;
        vItem.ParaNo := vCurItem.ParaNo;
        vItem.StyleNo := vCurItem.StyleNo;
        vItem.ParaFirst := True;
        Items.Insert(SelectInfo.StartItemNo, vItem);  // ԭλ�õ������ƶ�
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
        SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
      end;
    end
    else
    if SelectInfo.StartItemOffset = vCurItem.Length then  // �����Item�����
    begin
      if SelectInfo.StartItemNo < Items.Count - 1 then  // �������һ��Item
      begin
        vItem := Items[SelectInfo.StartItemNo + 1];  // ��һ��Item
        if not vItem.ParaFirst then  // ��һ�����Ƕ���ʼ
        begin
          vItem.ParaFirst := True;
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
        end
        else  // ��һ���Ƕ���ʼ
        begin
          vItem := CreateDefaultTextItem;
          vItem.ParaNo := vCurItem.ParaNo;
          vItem.StyleNo := vCurItem.StyleNo;
          vItem.ParaFirst := True;
          Items.Insert(SelectInfo.StartItemNo + 1, vItem);
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
        end;
        SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
        SelectInfo.StartItemOffset := 0;
      end
      else  // ��Data���һ��Item���½�����
      begin
        vItem := CreateDefaultTextItem;
        vItem.ParaNo := vCurItem.ParaNo;
        vItem.StyleNo := vCurItem.StyleNo;
        vItem.ParaFirst := True;
        Items.Insert(SelectInfo.StartItemNo + 1, vItem);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);
        SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
        SelectInfo.StartItemOffset := 0;
      end;
    end
    else  // �����Item�м�
    begin
      vItem := vCurItem.BreakByOffset(SelectInfo.StartItemOffset);  // �ضϵ�ǰItem
      vItem.ParaFirst := True;

      Items.Insert(SelectInfo.StartItemNo + 1, vItem);
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo + 1, 1);

      SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
      SelectInfo.StartItemOffset := 0;
    end;
    if Key <> 0 then
      CaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  end;
  {$ENDREGION}

  {$REGION 'DeleteKeyDown ���ɾ����'}
  procedure DeleteKeyDown;
  var
    vText: string;
    i, vCurItemNo, vLen, vDelCount, vParaNo: Integer;
  begin
    vDelCount := 0;
    vCurItemNo := SelectInfo.StartItemNo;
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);

    if SelectInfo.StartItemOffset = vCurItem.Length then  // �����Item���ұ�(��������)
    begin
      if vCurItemNo <> Items.Count - 1 then  // �������һ��Item���ұ�ɾ��
      begin
        if Items[vCurItemNo + 1].ParaFirst then  // ��һ���Ƕ��ף���괦Item����һ�����һ������һ��Ҫ������
        begin
          vFormatLastItemNo := GetParaLastItemNo(vCurItemNo + 1);  // ��ȡ��һ�����һ��
          if vCurItem.Length = 0 then  // ��ǰ�ǿ���
          begin
            FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
            Items.Delete(vCurItemNo);
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
          end
          else  // ��ǰ���ǿ���
          begin
            if Items[vCurItemNo + 1].StyleNo < THCStyle.RsNull then  // ��һ��������RectItem�����ܺϲ�
            begin
              SelectInfo.StartItemNo := vCurItemNo + 1;
              SelectInfo.StartItemOffset := OffsetBefor;
              KeyDown(Key, Shift);
              Exit;
            end
            else  // ��һ��������TextItem(��ǰ����һ�ζ�β)
            begin
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

              if Items[vCurItemNo + 1].Length = 0 then  // ��һ�εĶ������ǿ���
              begin
                Items.Delete(vCurItemNo + 1);
                Inc(vDelCount);
              end
              else  // ��һ�εĶ��ײ��ǿ���
              begin
                if (vCurItem.ClassType = Items[vCurItemNo + 1].ClassType)
                  and (vCurItem.StyleNo = Items[vCurItemNo + 1].StyleNo)
                then  // ��һ�ζ��׿ɺϲ�����ǰ(��ǰ����һ�ζ�β) 201804111209 (������MergeItemText�����)
                begin
                  vCurItem.Text := vCurItem.Text + Items[vCurItemNo + 1].Text;
                  Items.Delete(vCurItemNo + 1);
                  Inc(vDelCount);
                end
                else// ��һ�ζ��ײ��ǿ���Ҳ���ܺϲ�
                  Items[vCurItemNo + 1].ParaFirst := False;

                // ������һ�κϲ�������Item����ʽ��������ʽ
                vParaNo := Items[vCurItemNo].ParaNo;
                for i := vCurItemNo + 1 to vFormatLastItemNo - vDelCount do
                  Items[i].ParaNo := vParaNo;
              end;

              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - vDelCount, -vDelCount);
            end;
          end;
        end
        else  // ��һ�����ܺϲ�Ҳ���Ƕ��ף��ƶ�����һ����ͷ�ٵ���DeleteKeyDown
        begin
          SelectInfo.StartItemNo := vCurItemNo + 1;
          SelectInfo.StartItemOffset := 0;
          vCurItem := GetCurItem;
          {if vCurItem.StyleNo < THCStyle.RsNull then
            RectItemKeyDown
          else
            DeleteKeyDown;}
          KeyDown(Key, Shift);
          Exit;
        end;
      end;
    end
    else  // ��겻��Item���ұ�
    begin
      if not CanDeleteItem(vCurItemNo) then  // ����ɾ��
        SelectInfo.StartItemOffset := SelectInfo.StartItemOffset + 1
      else  // ��ɾ��
      begin
        vText := Items[vCurItemNo].Text;

        Delete(vText, SelectInfo.StartItemOffset + 1, 1);
        vCurItem.Text := vText;
        if vText = '' then  // ɾ����û��������
        begin
          if not DrawItems[Items[vCurItemNo].FirstDItemNo].LineFirst then  // ��Item��������(�����м����ĩβ)
          begin
            if vCurItemNo < Items.Count - 1 then  // ��������Ҳ�������һ��Item
            begin
              if MergeItemText(Items[vCurItemNo - 1], Items[vCurItemNo + 1]) then  // ��һ���ɺϲ�����һ��
              begin
                vLen := Items[vCurItemNo + 1].Length;
                GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, vCurItemNo - 1, vLen);
                FormatItemPrepare(vCurItemNo - 1, vFormatLastItemNo);
                Items.Delete(vCurItemNo);  // ɾ����ǰ
                Items.Delete(vCurItemNo);  // ɾ����һ��
                ReFormatData_(vCurItemNo - 1, vFormatLastItemNo - 2, -2);
              end
              else  // ��һ���ϲ�������һ��
              begin
                vLen := 0;
                FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
                Items.Delete(vCurItemNo);
                ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
              end;

              // �������
              SelectInfo.StartItemNo := vCurItemNo - 1;
              if GetItemStyle(SelectInfo.StartItemNo) < THCStyle.RsNull then
                SelectInfo.StartItemOffset := OffsetAfter
              else
                SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length - vLen;
            end
            else  // �����һ��Itemɾ������
            begin
              // �������
              FormatItemPrepare(vCurItemNo);
              Items.Delete(vCurItemNo);
              SelectInfo.StartItemNo := vCurItemNo - 1;
              //ReFormatData_(SelectInfo.StartItemNo, SelectInfo.StartItemNo, -1);
              DrawItems.DeleteFormatMark;
              if GetItemStyle(SelectInfo.StartItemNo) < THCStyle.RsNull then
                SelectInfo.StartItemOffset := OffsetAfter
              else
                SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
            end;
          end
          else  // ����Item��ɾ����
          begin
            if vCurItemNo <> vFormatLastItemNo then  // ��ǰ�κ��滹��Item
            begin
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
              SelectInfo.StartItemOffset := 0;
              Items[vCurItemNo + 1].ParaFirst := Items[vCurItemNo].ParaFirst;
              Items.Delete(vCurItemNo);
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
            end
            else  // ��ǰ��ɾ������
            begin
              FormatItemPrepare(vCurItemNo);
              SelectInfo.StartItemOffset := 0;
              ReFormatData_(vCurItemNo);
            end;
          end;
        end
        else  // ɾ����������
        begin
          FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
        end;
      end;
    end;
    if Key <> 0 then
      CaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  end;
  {$ENDREGION}

  {$REGION 'BackspaceKeyDown ��ǰɾ�����������Item��ǰ����ɾ��������Itemǰ�滹��Item����תΪ��ǰ��Item�����ɾ��'}
  procedure BackspaceKeyDown;
  var
    vText: string;
    i, vCurItemNo, vDrawItemNo, vLen, vDelCount, vParaNo: Integer;
  begin
    if SelectInfo.StartItemOffset = 0 then  // �����Item�ʼ
    begin
      if (vCurItem.Text = '') and (Style.ParaStyles[vCurItem.ParaNo].AlignHorz <> TParaAlignHorz.pahJustify) then
        ApplyParaAlignHorz(TParaAlignHorz.pahJustify)  // ���еȶ���Ŀ�Item��ɾ��ʱ�л�����ɢ����
      else
      if SelectInfo.StartItemNo <> 0 then  // ���ǵ�1��Item��ǰ��ɾ��
      begin
        vCurItemNo := SelectInfo.StartItemNo;
        if vCurItem.ParaFirst then  // �Ƕ���ʼItem
        begin
          vLen := Items[SelectInfo.StartItemNo - 1].Length;

          if (vCurItem.ClassType = Items[SelectInfo.StartItemNo - 1].ClassType)
            and (vCurItem.StyleNo = Items[SelectInfo.StartItemNo - 1].StyleNo)
          then  // ��ǰ���Ժ���һ���ϲ�(��ǰ�ڶ���) 201804111209 (������MergeItemText�����)
          begin
            Items[SelectInfo.StartItemNo - 1].Text := Items[SelectInfo.StartItemNo - 1].Text
              + Items[SelectInfo.StartItemNo].Text;

            vFormatFirstItemNo := GetLineFirstItemNo(SelectInfo.StartItemNo - 1, vLen);
            vFormatLastItemNo := GetParaLastItemNo(SelectInfo.StartItemNo);
            FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

            Items.Delete(SelectInfo.StartItemNo);

            // ������һ�κϲ�������Item�Ķ���ʽ��������ʽ
            vParaNo := Items[SelectInfo.StartItemNo - 1].ParaNo;
            for i := SelectInfo.StartItemNo to vFormatLastItemNo - 1 do
              Items[i].ParaNo := vParaNo;

            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);

            ReSetSelectAndCaret(SelectInfo.StartItemNo - 1, vLen);
          end
          else  // ����ʼ�Ҳ��ܺ���һ���ϲ�
          begin
            if vCurItem.Length = 0 then  // �Ѿ�û��������(���ǵ�1��Item)(����)
            begin
              FormatItemPrepare(SelectInfo.StartItemNo - 1, SelectInfo.StartItemNo);
              Items.Delete(SelectInfo.StartItemNo);
              ReFormatData_(SelectInfo.StartItemNo - 1, SelectInfo.StartItemNo - 1, -1);

              ReSetSelectAndCaret(SelectInfo.StartItemNo - 1);
            end
            else  // ��ǰɾ���Ҳ��ܺ���һ�����ϲ�
            begin
              GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

              vCurItem.ParaFirst := False;  // ��ǰ�κ���һ��Itemƴ�ӳ�һ��

              vParaNo := Items[SelectInfo.StartItemNo - 1].ParaNo;  // ��һ�ε�ParaNo
              for i := SelectInfo.StartItemNo to vFormatLastItemNo do
                Items[i].ParaNo := vParaNo;

              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);

              ReSetSelectAndCaret(SelectInfo.StartItemNo, 0);
            end;
          end;
        end
        else  // ��Item��ʼ��ǰɾ����Item���Ƕ���ʼ
        begin
          if Items[SelectInfo.StartItemNo - 1].StyleNo < THCStyle.RsNull then  // ǰ����RectItem
          begin
            vCurItemNo := SelectInfo.StartItemNo - 1;
            if CanDeleteItem(vCurItemNo) then  // ��ɾ��
            begin
              vCurItem.ParaFirst := Items[vCurItemNo].ParaFirst;
              GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
              Items.Delete(vCurItemNo);
              vDelCount := 1;
              vLen := 0;
              if not vCurItem.ParaFirst then  // ɾ��ǰ���RectItem���Ƕ���
              begin
                vCurItemNo := vCurItemNo - 1;  // ��һ��
                vLen := Items[vCurItemNo].Length;  // ��һ�������
                if MergeItemText(Items[vCurItemNo], vCurItem) then  // ��ǰ�ܺϲ�����һ��
                begin
                  Items.Delete(vCurItemNo + 1); // ɾ����ǰ��
                  vDelCount := 2;
                end;
              end;

              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - vDelCount, -vDelCount);
            end
            else  // ����ɾ����������ǰ
              vLen := OffsetBefor;

            ReSetSelectAndCaret(vCurItemNo, vLen);
          end
          else  // ǰ�����ı�����ֵΪǰ�����������´���ɾ��
          begin
            SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
            if GetItemStyle(SelectInfo.StartItemNo) < THCStyle.RsNull then
              SelectInfo.StartItemOffset := OffsetAfter
            else
              SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
            vCurItem := GetCurItem;

            BackspaceKeyDown;  // ���´���
            Exit;
          end;
        end;
      end;
    end
    else  // ��겻��Item�ʼ  �ı�
    begin
      vText := vCurItem.Text;
      Delete(vText, SelectInfo.StartItemOffset, 1);
      vCurItem.Text := vText;
      SelectInfo.StartItemOffset := SelectInfo.StartItemOffset - 1;
      if vText = '' then  // ɾ����û��������
      begin
        vCurItemNo := SelectInfo.StartItemNo;  // ��¼ԭλ��
        if not DrawItems[Items[vCurItemNo].FirstDItemNo].LineFirst then  // ��ǰ�������ף�ǰ��������
        begin
          vLen := Items[vCurItemNo - 1].Length;

          if (vCurItemNo > 0) and (vCurItemNo < vParaLastItemNo)
            and MergeItemText(Items[vCurItemNo - 1], Items[vCurItemNo + 1])
          then  // ѡ��λ����һ����ѡ��λ����һ���ɺϲ�
          begin
            GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, vCurItemNo - 1, vLen);
            FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
            Items.Delete(vCurItemNo);  // ɾ����ǰ
            Items.Delete(vCurItemNo);  // ɾ����һ��
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 2, -2);

            ReSetSelectAndCaret(SelectInfo.StartItemNo - 1, vLen);  // ��һ��ԭ���λ��
          end
          else  // ��ǰ�������ף�ɾ����û�������ˣ��Ҳ��ܺϲ���һ������һ��
          begin
            vLen := 0;
            if SelectInfo.StartItemNo = vFormatLastItemNo then  // �����һ��
            begin
              vFormatFirstItemNo := GetLineFirstItemNo(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
              Items.Delete(vCurItemNo);
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);

              ReSetSelectAndCaret(vCurItemNo - 1);
            end
            else  // ���Ƕ����һ��
            begin
              GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
              FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
              Items.Delete(vCurItemNo);
              ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);

              ReSetSelectAndCaret(vCurItemNo - 1);
            end;
          end;
        end
        else  // ���е�һ��������Itemɾ�����ˣ�
        begin
          GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
          FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);

          if vCurItemNo < vFormatLastItemNo then  // ͬ�κ��滹��
          begin
            if Items[vCurItemNo].ParaFirst then
              Items[vCurItemNo + 1].ParaFirst := True;
            Items.Delete(vCurItemNo);
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
            ReSetSelectAndCaret(vCurItemNo, 0);  // ��һ����ǰ��
          end
          else  // ͬ�κ���û��Item��
          if Items[vCurItemNo].ParaFirst then  // ��ǰ�Ƕ��ף���������ݣ��ο���
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo)  // ��������
          else  // ���������ݣ���ͬ��ǰ�滹������
          begin
            Items.Delete(vCurItemNo);
            ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo - 1, -1);
            ReSetSelectAndCaret(vCurItemNo - 1);
          end;
        end;
      end
      else  // ɾ����������
      begin
        { ���Ƕε�һ�е�����ʱ��������������һ������Item�����ƶ�����һ�е������
          ����ɾ����Ҫ����һ�п�ʼ�ж� }
        if SelectInfo.StartItemNo > vParaFirstItemNo then
          vFormatFirstItemNo := GetLineFirstItemNo(SelectInfo.StartItemNo - 1, 0)
        else
          vFormatFirstItemNo := SelectInfo.StartItemNo;

        vFormatLastItemNo := vParaLastItemNo;

        FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
        ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'HomeKeyDown ����'}
  procedure HomeKeyDown;
  var
    vFirstDItemNo, vLastDItemNo: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      vFirstDItemNo := GetSelectStartDrawItemNo;
      GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);
      SelectInfo.StartItemNo := DrawItems[vFirstDItemNo].ItemNo;
      SelectInfo.StartItemOffset := DrawItems[vFirstDItemNo].CharOffs - 1;
    end;
    if Key <> 0 then
      CaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  end;
  {$ENDREGION}

  {$REGION 'EndKeyDown ����'}
  procedure EndKeyDown;
  var
    vFirstDItemNo, vLastDItemNo: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.StartItemNo := SelectInfo.EndItemNo;
      SelectInfo.StartItemOffset := SelectInfo.EndItemOffset;
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      vFirstDItemNo := GetSelectStartDrawItemNo;
      GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);
      SelectInfo.StartItemNo := DrawItems[vLastDItemNo].ItemNo;
      SelectInfo.StartItemOffset := DrawItems[vLastDItemNo].CharOffsetEnd;
    end;
    if Key <> 0 then
      CaretDrawItemNo := GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
  end;
  {$ENDREGION}

  {$REGION 'UpKeyDown �Ϸ��򰴼�'}
  procedure UpKeyDown;
  var
    i, vCurDItemNo, vFirstDItemNo, vLastDItemNo, vX: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      vFirstDItemNo := CaretDrawItemNo;  // GetSelectStartDrawItemNo;
      GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);  // ��ǰ����ʼ����DItemNo
      if vFirstDItemNo > 0 then  // ��ǰ�в��ǵ�һ��
      begin
        { ��ȡ��ǰ���Xλ�� }
        vCurDItemNo := CaretDrawItemNo;  // GetSelectStartDrawItemNo;  // ��ǰDItem
        vX := DrawItems[vCurDItemNo].Rect.Left +
          GetDrawItemOffsetWidth(vCurDItemNo,
            SelectInfo.StartItemOffset - DrawItems[vCurDItemNo].CharOffs + 1);

        { ��ȡ��һ����Xλ�ö�Ӧ��DItem��Offset }
        vFirstDItemNo := vFirstDItemNo - 1;
        GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);  // ��һ����ʼ�ͽ���DItem

        for i := vFirstDItemNo to vLastDItemNo do
        begin
          if DrawItems[i].Rect.Right > vX then
          begin
            SelectInfo.StartItemNo := DrawItems[i].ItemNo;
            SelectInfo.StartItemOffset := DrawItems[i].CharOffs +
              GetDrawItemOffset(i, vX - DrawItems[i].Rect.Left) - 1;
            CaretDrawItemNo := i;

            Exit;  // �к��ʣ����˳�
          end;
        end;

        { û������ѡ����� }
        SelectInfo.StartItemNo := DrawItems[vLastDItemNo].ItemNo;
        SelectInfo.StartItemOffset := DrawItems[vLastDItemNo].CharOffsetEnd;
        CaretDrawItemNo := vLastDItemNo;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'DownKeyDown �·����'}
  procedure DownKeyDown;
  var
    i, vCurDItemNo, vFirstDItemNo, vLastDItemNo, vX: Integer;
  begin
    if vSelectExist then  // ��ѡ������
    begin
      SelectInfo.StartItemNo := SelectInfo.EndItemNo;
      SelectInfo.StartItemOffset := SelectInfo.EndItemOffset;
      SelectInfo.EndItemNo := -1;
      SelectInfo.EndItemOffset := -1;
    end
    else  // ��ѡ������
    begin
      vFirstDItemNo := CaretDrawItemNo;  // GetSelectStartDrawItemNo;
      GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);  // ��ǰ����ʼ����DItemNo
      if vLastDItemNo < DrawItems.Count - 1 then  // ��ǰ�в������һ��
      begin
        { ��ȡ��ǰ���Xλ�� }
        vCurDItemNo := CaretDrawItemNo;  // GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset); // ��ǰDItem

        vX := DrawItems[vCurDItemNo].Rect.Left +
          GetDrawItemOffsetWidth(vCurDItemNo,
            SelectInfo.StartItemOffset - DrawItems[vCurDItemNo].CharOffs + 1);

        { ��ȡ��һ����Xλ�ö�Ӧ��DItem��Offset }
        vFirstDItemNo := vLastDItemNo + 1;
        GetLineDrawItemRang(vFirstDItemNo, vLastDItemNo);  // ��һ����ʼ�ͽ���DItem

        for i := vFirstDItemNo to vLastDItemNo do
        begin
          if DrawItems[i].Rect.Right > vX then
          begin
            SelectInfo.StartItemNo := DrawItems[i].ItemNo;
            SelectInfo.StartItemOffset := DrawItems[i].CharOffs +
              GetDrawItemOffset(i, vX - DrawItems[i].Rect.Left) - 1;
            CaretDrawItemNo := i;

            Exit;  // �к��ʣ����˳�
          end;
        end;

        { û������ѡ����� }
        SelectInfo.StartItemNo := DrawItems[vLastDItemNo].ItemNo;
        SelectInfo.StartItemOffset := DrawItems[vLastDItemNo].CharOffsetEnd;
        CaretDrawItemNo := vLastDItemNo;
      end
      else  // ��ǰ�������һ��
        Key := 0;
    end;
  end;
  {$ENDREGION}

begin
  if not CanEdit then Exit;

  if Key in [VK_BACK, VK_DELETE, VK_RETURN, VK_TAB] then
    Self.Initialize;  // ���Itemɾ�����ˣ��������ƶ��¼���Ӱ�죬���Գ�ʼ��

  vCurItem := GetCurItem;
  if vCurItem = nil then Exit;

  vSelectExist := SelectExists;

  if vSelectExist and (Key in [VK_BACK, VK_DELETE, VK_RETURN, VK_TAB]) then
  begin
    if DeleteSelected then
    begin
      if Key in [VK_BACK, VK_DELETE] then Exit;
    end;
  end;

  GetParaItemRang(SelectInfo.StartItemNo, vParaFirstItemNo, vParaLastItemNo);

  if vCurItem.StyleNo < THCStyle.RsNull then
    RectItemKeyDown
  else
  begin
    case Key of
      VK_BACK:   BackspaceKeyDown;  // ��ɾ
      VK_RETURN: EnterKeyDown;      // �س�
      VK_LEFT:   LeftKeyDown;       // �����
      VK_RIGHT:  RightKeyDown;      // �ҷ����
      VK_DELETE: DeleteKeyDown;     // ɾ����
      VK_HOME:   HomeKeyDown;       // Home��
      VK_END:    EndKeyDown;        // End��
      VK_UP:     UpKeyDown;         // ���Ϸ�ҳ��
      VK_DOWN:   DownKeyDown;       // ���·�ҳ��
      VK_TAB:    TABKeyDown;        // TAB��
    end;
  end;

  case Key of
    VK_BACK, VK_DELETE, VK_RETURN, VK_TAB:
      begin
        Style.UpdateInfoReCaret;
        Style.UpdateInfoRePaint;
      end;

    VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END:
      begin
        if vSelectExist then
          Style.UpdateInfoRePaint;
        Style.UpdateInfoReCaret;
      end;
  end;
end;

procedure THCCustomRichData.KeyPress(var Key: Char);
var
  vCurItem, vNewItem: THCCustomItem;
  vFormatFirstItemNo, vFormatLastItemNo: Integer;

  {$REGION 'RectItemKeyPress'}
  procedure RectItemKeyPress;
  var
    vRectItem: THCCustomRectItem;
  begin
    if SelectInfo.StartItemOffset = OffsetInner then  // ��������������
    begin
      vRectItem := vCurItem as THCCustomRectItem;
      vRectItem.KeyPress(Key);
      if vRectItem.HeightChanged then
      begin
        vRectItem.HeightChanged := False;
        GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
        FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
        if Key <> #0 then
          //ReFormatPara(SelectInfo.StartItemNo);
          ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      end;
    end
    else  // ������ǰ
    begin
      vNewItem := CreateDefaultTextItem;
      vNewItem.Text := Key;
      if SelectInfo.StartItemOffset = OffsetAfter then  // �������������
      begin
        { TODO : ������Ҫ����������ı��ĺϲ������� }
        vNewItem.ParaFirst := False;  // �����ռ���е�Item���˴���Ӧ��ΪTrue
        SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
        InsertItem(SelectInfo.StartItemNo, vNewItem);
      end
      else  // ����ǰ�������ݣ�����TextItem
      begin
        if vCurItem.ParaFirst then
        begin
          vNewItem.ParaFirst := True;
          vCurItem.ParaFirst := False;
        end;
        InsertItem(SelectInfo.StartItemNo, vNewItem);
      end;
    end;
  end;
  {$ENDREGION}

var
  vText: string;
begin
  if not CanEdit then Exit;

  DeleteSelected;

  vCurItem := GetCurItem;
  if vCurItem.StyleNo < THCStyle.RsNull then
    RectItemKeyPress
  else
  begin
    vText := vCurItem.Text;
    // ����ʼΪTextItem��ͬһ�к�����RectItemʱ���༭TextItem���ʽ�����ܻὫRectItem�ֵ���һ�У�
    // ���Բ���ֱ�� FormatItemPrepare(SelectInfo.StartItemNo)�������Ϊ��ʽ����Χ̫С��
    // û�н���FiniLine�����иߣ����ԴӶ����������ʼ
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    Insert(Key, vText, SelectInfo.StartItemOffset + 1);
    vCurItem.Text := vText;
    SelectInfo.StartItemOffset := SelectInfo.StartItemOffset + 1;
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
    Self.Initialize;
  end;

  Style.UpdateInfoRePaint;
  Style.UpdateInfoReCaret;
end;

procedure THCCustomRichData.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if not CanEdit then Exit;
end;

procedure THCCustomRichData.KillFocus;
var
  vItemNo: Integer;
begin
  vItemNo := GetCurItemNo;
  if vItemNo >= 0 then
    Items[vItemNo].KillFocus;
end;

procedure THCCustomRichData.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  if not CanEdit then Exit;

  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  InsertStream(AStream, AStyle, AFileVersion);
  // ������ɺ󣬳�ʼ��
  //DisSelect; �����һ���Ǳ���ҿ�ҳ�򿪺��Զ�����������
  SelectInfo.StartItemNo := 0;
  SelectInfo.StartItemOffset := 0;
  Self.Initialize;
end;

function THCCustomRichData.MergeItemText(const ADestItem,
  ASrcItem: THCCustomItem): Boolean;
begin
  Result := ADestItem.CanConcatItems(ASrcItem);
  if Result then
    ADestItem.Text := ADestItem.Text + ASrcItem.Text;
end;

function THCCustomRichData.MergeTableSelectCells: Boolean;
var
  vItemNo, vFormatFirstItemNo, vFormatLastItemNo: Integer;
begin
  Result := False;

  if not CanEdit then Exit;

  vItemNo := GetCurItemNo;
  if Items[vItemNo].StyleNo = THCStyle.RsTable then
  begin
    Result := (Items[vItemNo] as THCTableItem).MergeSelectCells;
    if Result then  // �ϲ��ɹ�
    begin
      GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo);
      FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
      ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
      DisSelect;
      //ReFormatData_(vItemNo);
      Style.UpdateInfoRePaint;
    end;
  end;
end;

procedure THCCustomRichData.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  {$REGION 'DoItemMouseDown'}
  procedure DoItemMouseDown(const AItemNo, AOffset: Integer);
  var
    vX, vY: Integer;
  begin
    if AItemNo < 0 then Exit;
    CoordToItemOffset(X, Y, AItemNo, AOffset, vX, vY);
    Items[AItemNo].MouseDown(Button, Shift, vX, vY);

    if Assigned(OnItemMouseDown) then
      OnItemMouseDown(Self, AItemNo, Button, Shift, vX, vY);
  end;
  {$ENDREGION}

var
  vMouseDownItemNo, vMouseDownItemOffset, vDrawItemNo: Integer;
  vRestrain, vMouseDownInSelect: Boolean;
begin
  FSelecting := False;  // ׼����ѡ
  FDraging := False;  // ׼����ק
  //Style.UpdateInfo.Draging := False;

  FMouseLBDowning := (Button = mbLeft) and (Shift = [ssLeft]);

  FMouseDownX := X;
  FMouseDownY := Y;

  GetItemAt(X, Y, vMouseDownItemNo, vMouseDownItemOffset, vDrawItemNo, vRestrain);

  vMouseDownInSelect := (not vRestrain) and CoordInSelect(X, Y, vMouseDownItemNo, vMouseDownItemOffset);

  if vMouseDownInSelect then   // ��ѡ���а���
  begin
    if FMouseLBDowning then  // �����
    begin
      FDraging := True;
      Style.UpdateInfo.Draging := True;
    end;

    if Items[vMouseDownItemNo].StyleNo < THCStyle.RsNull then  // ��RectItem����ק
      DoItemMouseDown(vMouseDownItemNo, vMouseDownItemOffset);
  end
  else  // û����ѡ��������
  begin
    if (vMouseDownItemNo <> FMouseDownItemNo)
      or (vMouseDownItemOffset <> FMouseDownItemOffset)
      or (CaretDrawItemNo <> vDrawItemNo)
    then  // ��λ��
    begin
      if FMouseDownItemNo >= 0 then
        Items[FMouseDownItemNo].Active := False;  // �ɵ�ȡ������

      Style.UpdateInfoReCaret;
      Style.UpdateInfoRePaint;  // �ɵ�ȥ���㣬�µ��뽹��
    end;

    DisSelect;

    // ���¸�ֵ��λ��
    FMouseDownItemNo := vMouseDownItemNo;
    FMouseDownItemOffset := vMouseDownItemOffset;
    CaretDrawItemNo := vDrawItemNo;
    SelectInfo.StartItemNo := FMouseDownItemNo;
    SelectInfo.StartItemOffset := FMouseDownItemOffset;

    if not vRestrain then  // û����
      DoItemMouseDown(FMouseDownItemNo, FMouseDownItemOffset);
  end;
end;

procedure THCCustomRichData.MouseMove(Shift: TShiftState; X, Y: Integer);

  {$REGION 'AdjustSelectRang'}
  procedure AdjustSelectRang;

    {$REGION 'Item��ָ��ƫ���������'}
    function OffsetInItemAfter(const AItemNo, AOffset: Integer): Boolean;
    begin
      Result := False;
      if Items[AItemNo].StyleNo < THCStyle.RsNull then
        Result := AOffset = OffsetAfter
      else
        Result := AOffset = Items[AItemNo].Length;
    end;
    {$ENDREGION}

  var
    i: Integer;
  begin
    if SelectInfo.StartItemNo < 0 then Exit;

    for i := SelectInfo.StartItemNo to SelectInfo.EndItemNo do  // �������ǰѡ�е�Item��״̬
    begin
      if not (i in [FMouseDownItemNo, FMouseMoveItemNo]) then  // ������ǰ���º��ƶ�����ѡ��״̬
      begin
        Items[i].Active := False;
        if Items[i].StyleNo < THCStyle.RsNull then  // RectItem�Լ������ڲ���ȡ��ѡ��
          (Items[i] as THCCustomRectItem).DisSelect;  // Item�ڲ������Լ���ȫѡ������ѡ״̬
      end;
    end;
    SelectInfo.Initialize;

    if FMouseDownItemNo < FMouseMoveItemNo then  // ��ǰ����ѡ���ڲ�ͬ��Item
    begin
      if OffsetInItemAfter(FMouseDownItemNo, FMouseDownItemOffset) then  // ��ʼ��Item�����
      begin
        if FMouseDownItemNo < Items.Count - 1 then  // ��ʼ��Ϊ��һ��Item��ʼ
        begin
          FMouseDownItemNo := FMouseDownItemNo + 1;
          FMouseDownItemOffset := 0;
        end;
      end;
      if (FMouseMoveItemOffset = 0) and (FMouseMoveItemNo >= 0) then  // ������Item��ǰ�棬��Ϊ��һ��Item����
      begin
        FMouseMoveItemNo := FMouseMoveItemNo - 1;
        if Items[FMouseMoveItemNo].StyleNo < THCStyle.RsNull then
          FMouseMoveItemOffset := OffsetAfter
        else
          FMouseMoveItemOffset := Items[FMouseMoveItemNo].Length;
      end;

      SelectInfo.StartItemNo := FMouseDownItemNo;
      SelectInfo.StartItemOffset := FMouseDownItemOffset;
      SelectInfo.EndItemNo := FMouseMoveItemNo;
      SelectInfo.EndItemOffset := FMouseMoveItemOffset;
    end
    else
    if (FMouseMoveItemNo >= 0) and (FMouseMoveItemNo < FMouseDownItemNo) then  // �Ӻ���ǰѡ���ڲ�ͬ��Item
    begin
      if OffsetInItemAfter(FMouseMoveItemNo, FMouseMoveItemOffset) then  // ������Item�����
      begin
        if FMouseMoveItemNo < Items.Count - 1 then  // ��ʼ��Ϊ��һ��Item��ʼ
        begin
          FMouseMoveItemNo := FMouseMoveItemNo + 1;
          FMouseMoveItemOffset := 0;
        end;
      end;
      if (FMouseDownItemOffset = 0) and (FMouseDownItemNo > 0) then  // ��ʼ��Item��ǰ�棬��Ϊ��һ��Item����
      begin
        FMouseDownItemNo := FMouseDownItemNo - 1;
        if Items[FMouseDownItemNo].StyleNo < THCStyle.RsNull then
          FMouseDownItemOffset := OffsetAfter
        else
          FMouseDownItemOffset := Items[FMouseDownItemNo].Length;
      end;

      SelectInfo.StartItemNo := FMouseMoveItemNo;
      SelectInfo.StartItemOffset := FMouseMoveItemOffset;
      SelectInfo.EndItemNo := FMouseDownItemNo;
      SelectInfo.EndItemOffset := FMouseDownItemOffset;
    end
    else  // FMouseDownItemNo = FMouseMoveItemNo  // ѡ������ͬһ��Item
    begin
      if FMouseMoveItemOffset > FMouseDownItemOffset then  // ѡ�н���λ�ô�����ʼλ��
      begin
        SelectInfo.StartItemNo := FMouseDownItemNo;
        SelectInfo.StartItemOffset := FMouseDownItemOffset;
        if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then  // RectItem
        begin
          if FMouseMoveItemOffset > FMouseDownItemOffset then  // ��RectItem��ǰ��ѡ���������(ȫѡ��)
          begin
            SelectInfo.EndItemNo := FMouseMoveItemNo;
            SelectInfo.EndItemOffset := FMouseMoveItemOffset;
          end
          else  // û��ȫѡ��
          begin
            SelectInfo.EndItemNo := -1;
            SelectInfo.EndItemOffset := -1;
          end;
        end
        else  // TextItem
        begin
          SelectInfo.EndItemNo := FMouseMoveItemNo;
          SelectInfo.EndItemOffset := FMouseMoveItemOffset;
        end;
      end
      else
      if FMouseMoveItemOffset < FMouseDownItemOffset then  // ѡ�н���λ��С����ʼλ��
      begin
        SelectInfo.StartItemNo := FMouseDownItemNo;
        SelectInfo.StartItemOffset := FMouseMoveItemOffset;
        if Items[SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then  // RectItem
        begin
          if FMouseMoveItemOffset = OffsetBefor then
          begin
            SelectInfo.EndItemNo := FMouseMoveItemNo;
            SelectInfo.EndItemOffset := FMouseDownItemOffset;
          end
          else
          begin
            SelectInfo.EndItemNo := -1;
            SelectInfo.EndItemOffset := -1;
          end;
        end
        else
        begin
          SelectInfo.EndItemNo := FMouseMoveItemNo;
          SelectInfo.EndItemOffset := FMouseDownItemOffset;
        end;
      end
      else  // ����λ�ú���ʼλ����ͬ
      begin
        SelectInfo.StartItemNo := FMouseDownItemNo;
        SelectInfo.StartItemOffset := FMouseDownItemOffset;
        Items[SelectInfo.StartItemNo].Active := not FMouseMoveRestrain;
        SelectInfo.EndItemNo := -1;
        SelectInfo.EndItemOffset := -1;
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'DoItemMouseMove'}
  procedure DoItemMouseMove(const AItemNo, AOffset: Integer);
  var
    vX, vY: Integer;
  begin
    if AItemNo < 0 then Exit;
    CoordToItemOffset(X, Y, AItemNo, AOffset, vX, vY);
    Items[AItemNo].MouseMove(Shift, vX, vY);
  end;
  {$ENDREGION}

var
  vMouseMoveItemNo, vMouseMoveItemOffset, vDrawItemNo: Integer;
  vRestrain: Boolean;
begin
  if SelectedResizing then  // RectItem����ing����������
  begin
    FMouseMoveItemNo := FMouseDownItemNo;
    FMouseMoveItemOffset := FMouseDownItemOffset;
    FMouseMoveRestrain := False;
    DoItemMouseMove(FMouseMoveItemNo, FMouseMoveItemOffset);
    Style.UpdateInfoRePaint;

    Exit;
  end;

  GetItemAt(X, Y, vMouseMoveItemNo, vMouseMoveItemOffset, vDrawItemNo, vRestrain);

  if FDraging or Style.UpdateInfo.Draging{�����ק����ʼ��Ԫ���겻��λ} then  // ��ק
  begin
    GCursor := crDrag;

    FMouseMoveItemNo := vMouseMoveItemNo;
    FMouseMoveItemOffset := vMouseMoveItemOffset;
    FMouseMoveRestrain := vRestrain;
    CaretDrawItemNo := vDrawItemNo;

    Style.UpdateInfoReCaret;

    if Items[FMouseMoveItemNo].StyleNo < THCStyle.RsNull then  // RectItem
      DoItemMouseMove(FMouseMoveItemNo, FMouseMoveItemOffset);
  end
  else
  if FSelecting then  // ��ѡ
  begin
    FMouseMoveItemNo := vMouseMoveItemNo;
    FMouseMoveItemOffset := vMouseMoveItemOffset;
    FMouseMoveRestrain := vRestrain;

    AdjustSelectRang;  // ȷ��SelectRang
    MatchItemSelectState;  // ����ѡ�з�Χ�ڵ�Itemѡ��״̬
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;

    if Items[FMouseMoveItemNo].StyleNo < THCStyle.RsNull then  // RectItem
      DoItemMouseMove(FMouseMoveItemNo, FMouseMoveItemOffset);
  end
  else  // ����ק���ǻ�ѡ
  if FMouseLBDowning and ((FMouseDownX <> X) or (FMouseDownY <> Y)) then  // ��������ƶ�����ʼ��ѡ
  begin
    FSelecting := True;
  end
  else  // ����ק���ǻ�ѡ���ǰ���
  begin
    if vMouseMoveItemNo <> FMouseMoveItemNo then  // �ƶ������µ�Item��
    begin
      if FMouseMoveItemNo >= 0 then  // �ɵ��Ƴ�
        DoItemMouseLeave(FMouseMoveItemNo);
      if (vMouseMoveItemNo >= 0) and (not vRestrain) then  // �µ�����
        DoItemMouseEnter(vMouseMoveItemNo);

      Style.UpdateInfoRePaint;
    end
    else  // �����ƶ�����Item����һ����ͬһ��(������һֱ��һ��Item���ƶ�)
    begin
      if vRestrain <> FMouseMoveRestrain then  // ����Move���ϴ�Move��ͬһ��Item��2�ε����������˱仯
      begin
        if (not FMouseMoveRestrain) and vRestrain then  // �ϴ�û���������������ˣ��Ƴ�
        begin
          if FMouseMoveItemNo >= 0 then
            DoItemMouseLeave(FMouseMoveItemNo);
        end
        else
        if FMouseMoveRestrain and (not vRestrain) then  // �ϴ����������β�����������
        begin
          if vMouseMoveItemNo >= 0 then
            DoItemMouseEnter(vMouseMoveItemNo);
        end;

        Style.UpdateInfoRePaint;
      end;
    end;

    FMouseMoveItemNo := vMouseMoveItemNo;
    FMouseMoveItemOffset := vMouseMoveItemOffset;
    FMouseMoveRestrain := vRestrain;

    if not vRestrain then
      DoItemMouseMove(FMouseMoveItemNo, FMouseMoveItemOffset);
  end;
end;

procedure THCCustomRichData.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vUpItemNo, vUpItemOffset, vDrawItemNo: Integer;
  vDragStartItemNo, vDragEndItemNo: Integer;

  {$REGION ' DoItemMouseUp '}
  procedure DoItemMouseUp(const AItemNo, AOffset: Integer);
  var
    vX, vY: Integer;
  begin
    if AItemNo < 0 then Exit;
    CoordToItemOffset(X, Y, AItemNo, AOffset, vX, vY);
    Items[AItemNo].MouseUp(Button, Shift, vX, vY);

    if Assigned(FOnItemMouseUp) then
      FOnItemMouseUp(Self, AItemNo, Button, Shift, vX, vY);
  end;
  {$ENDREGION}

  {$REGION ' DragNotify ֪ͨѡ�е�Item����ק��� '}
  procedure DragNotify(const AFinish: Boolean);
  var
    i: Integer;
  begin
    // ��ʼ��RectItemһ��Ҫ����(���������Ƿ�ֹѡ��ֻ��RectItem�Ͻ���)
    if Items[vDragStartItemNo].StyleNo < THCStyle.RsNull then
      (Items[vDragStartItemNo] as THCCustomRectItem).DragNotify(AFinish);
       
    for i := vDragStartItemNo + 1 to vDragEndItemNo do
    begin
      if Items[i].StyleNo < THCStyle.RsNull then
        (Items[i] as THCCustomRectItem).DragNotify(AFinish);
    end;
  end;
  {$ENDREGION}

  {$REGION ' DragCancel '}
  procedure DragCancel;
  begin
    if DisSelect then
    begin
      Self.Initialize;
      SelectInfo.StartItemNo := vUpItemNo;
      SelectInfo.StartItemOffset := vUpItemOffset;
      CaretDrawItemNo := vDrawItemNo;  // GetDrawItemNoByOffset(SelectInfo.StartItemNo, SelectInfo.StartItemOffset);
      Style.UpdateInfoReCaret;

      if Items[vUpItemNo].StyleNo < THCStyle.RsNull then  // ����ʱ��RectItem
        DoItemMouseUp(vUpItemNo, vUpItemOffset);      
    end;
  end;
  {$ENDREGION}

  {$REGION ' DragFinish '}
  procedure DragFinish;
  begin
    { TODO : �õ���ק���� }    
    DragCancel;
  end;
  {$ENDREGION}

var
  vFormatFirstItemNo, vFormatLastItemNo: Integer;
  vRestrain: Boolean;
  vMouseUpInSelect: Boolean;
begin
  Style.UpdateInfo.Draging := False;

//  if not FMouseLBDowning then Exit;  // ���ļ��Ի���˫���ļ���ᴥ��MouseUp

  FMouseLBDowning := False;

  if SelectedResizing then  // RectItem����ing��ֹͣ����
  begin
    DoItemMouseUp(FMouseDownItemNo, FMouseDownItemOffset);
    GetReformatItemRange(vFormatFirstItemNo, vFormatLastItemNo, FMouseDownItemNo, FMouseDownItemOffset);
    FormatItemPrepare(vFormatFirstItemNo, vFormatLastItemNo);
    ReFormatData_(vFormatFirstItemNo, vFormatLastItemNo);
    Style.UpdateInfoRePaint;

    Exit;
  end;

  GetItemAt(X, Y, vUpItemNo, vUpItemOffset, vDrawItemNo, vRestrain);

  if FSelecting then  // ��ѡ��ɵ���
  begin
    FSelecting := False;
    if Items[vUpItemNo].StyleNo < THCStyle.RsNull then  // ����ʱ��RectItem
      DoItemMouseUp(vUpItemNo, vUpItemOffset);
  end
  else
  if FDraging then  // ��ק����
  begin
    FDraging := False;

    vDragStartItemNo := SelectInfo.StartItemNo;
    vDragEndItemNo := SelectInfo.EndItemNo;
    
    vMouseUpInSelect := (not vRestrain) and CoordInSelect(X, Y, vUpItemNo, vUpItemOffset);
    if not vMouseUpInSelect then  // ��ק����ʱ����ѡ��������
    begin
      DragFinish;
      DragNotify(True);
    end
    else  // ��ק����ʱ������ѡ��������
    begin
      DragCancel;
      DragNotify(False);
    end;
  end
  else  // ����ק���ǻ�ѡ
  begin
    if SelectExists(False) then  // �����Data�����ڵ�ѡ��
      DisSelect;

    if FMouseMoveItemNo < 0 then
    begin
      SelectInfo.StartItemNo := vUpItemNo;
      SelectInfo.StartItemOffset := vUpItemOffset;
    end
    else
    begin
      SelectInfo.StartItemNo := FMouseMoveItemNo;
      SelectInfo.StartItemOffset := FMouseMoveItemOffset;
    end;

    CaretDrawItemNo := vDrawItemNo;
    Style.UpdateInfoRePaint;
    Style.UpdateInfoReCaret;

    DoItemMouseUp(vUpItemNo, vUpItemOffset);  // ������Ϊ�������Ƴ�Item�����������ﲻ��vRestrainԼ��
  end;
end;

procedure THCCustomRichData.ReFormatData_(const AStartItemNo: Integer; const ALastItemNo: Integer = -1;
  const AExtraItemCount: Integer = 0);
var
  i, vLastItemNo, vLastDrawItemNo, vFormatIncHight,
  vDrawItemCount, vFmtTopOffset, vClearFmtHeight: Integer;
begin
//  vLastDrawItemNo := GetItemLastDrawItemNo(ALastItemNo);  // �����һ��DrawItem
//
//  if vLastDrawItemNo < 0 then  // û�б���ʽ������ȡͬһ���е�ǰItemǰ�������
//    vLastDrawItemNo := GetItemNearDrawItemNo(ALastItemNo);
//
//  if vLastDrawItemNo < 0 then  // ���ĵ�
//    vNextParaTop := 0
//  else
//  {if vLastDrawItemNo <> DrawItems.Count - 1 then
//    vNextParaTop := DrawItems[vLastDrawItemNo + 1].Rect.Top  // ��һ�ε���ʼλ��
//  else}
//    vNextParaTop := DrawItems[vLastDrawItemNo].Rect.Bottom;  // �θ�ʽ��ǰ���ײ�λ��
  //
  vDrawItemCount := DrawItems.Count;
  if ALastItemNo < 0 then
    FormatData(AStartItemNo, AStartItemNo)
  else
    FormatData(AStartItemNo, ALastItemNo);  // ��ʽ��ָ����Χ�ڵ�Item
  DrawItems.DeleteFormatMark;
  vDrawItemCount := DrawItems.Count - vDrawItemCount;

  // �����ʽ����εĵײ�λ�ñ仯
  if ALastItemNo < 0 then
    vLastDrawItemNo := GetItemLastDrawItemNo(AStartItemNo)
  else
    vLastDrawItemNo := GetItemLastDrawItemNo(ALastItemNo);
  vFormatIncHight := DrawItems[vLastDrawItemNo].Rect.Bottom - DrawItems.FormatBeforBottom;  // �θ�ʽ���󣬸߶ȵ�����

  // ĳ�θ�ʽ���󣬴���������Item��ӦDrawItem��Ӱ��
  // ��ͼ2017-6-8_1��Ϊͼ2017-6-8_2�Ĺ����У���3��λ��û�䣬Ҳû���µ�Item�����仯������DrawItem�������б仯
  // ��3��Item��Ӧ��FirstDItemNo��Ҫ�޸ģ����Դ˴�����DrawItemCount�����ı仯
  // Ŀǰ��ʽ��ʱALastItemNoΪ�ε����һ��������vLastDrawItemNoΪ�����һ��DrawItem
  if (vFormatIncHight <> 0) or (AExtraItemCount <> 0) or (vDrawItemCount <> 0) then
  begin
    if DrawItems.Count > vLastDrawItemNo then
    begin
      vLastItemNo := -1;
      for i := vLastDrawItemNo + 1 to DrawItems.Count - 1 do  // �Ӹ�ʽ���䶯�ε���һ�ο�ʼ
      begin
        // �����ʽ�������DrawItem��Ӧ��ItemNoƫ��
        DrawItems[i].ItemNo := DrawItems[i].ItemNo + AExtraItemCount;
        if vLastItemNo <> DrawItems[i].ItemNo then
        begin
          vLastItemNo := DrawItems[i].ItemNo;
          Items[vLastItemNo].FirstDItemNo := i;
        end;

        if vFormatIncHight <> 0 then  // ������ȷ��Ϊ0ʱ����Ҫ���´���ƫ����
        begin
          // ��ԭ��ʽ�����ҳ��ԭ��������������ƻ����ӵĸ߶Ȼָ�����
          // ������������洦��ItemNo��ƫ�ƣ��ɽ�TTableCellData.ClearFormatExtraHeight����д�����࣬����ֱ�ӵ���
          if DrawItems[i].LineFirst then
            vFmtTopOffset := DrawItems[i - 1].Rect.Bottom - DrawItems[i].Rect.Top;

          OffsetRect(DrawItems[i].Rect, 0, vFmtTopOffset);

          if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem�����ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
          begin
            vClearFmtHeight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).ClearFormatExtraHeight;
            DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vClearFmtHeight;
          end;
        end;
      end;
    end;

    // ��ԭ��ʽ�����ҳ��ԭ��������������ƻָ�����

    {if DrawItems.Count > vLastDrawItemNo + 1 then
    begin
      //vFmtTopOffset := DrawItems[vLastDrawItemNo + 1].Rect.Top - DrawItems[vLastDrawItemNo].Rect.Top;
      for i := vLastDrawItemNo + 1 to DrawItems.Count - 1 do  // �Ӹ�ʽ���䶯�ε���һ�ο�ʼ
      begin
        if DrawItems[i].LineFirst then
          vFmtTopOffset := DrawItems[i - 1].Rect.Bottom - DrawItems[i].Rect.Top;

        OffsetRect(DrawItems[i].Rect, 0, vFmtTopOffset);

        if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem�����ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
        begin
          vRectReFormatHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).ClearFormatExtraHeight;
          DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vRectReFormatHight;
        end;
      end;
    end;}
    {
    vFmtTopOffset := 0;
    for i := vLastDrawItemNo + 1 to DrawItems.Count - 1 do
    begin
      if (i > vLastDrawItemNo + 1) and DrawItems[i].LineFirst then
      begin
        if DrawItems[i].Rect.Top <> DrawItems[i - 1].Rect.Bottom then
          vFmtTopOffset := vFmtTopOffset - (DrawItems[i].Rect.Top - DrawItems[i - 1].Rect.Bottom);

        if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem�����ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
        begin
          vRectReFormatHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).GetFormatDiffClearHeight;
          DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vRectReFormatHight;
          OffsetRect(DrawItems[i].Rect, 0, vFmtTopOffset);
          vFmtTopOffset := vFmtTopOffset - vRectReFormatHight;  // ����ҳ���ӵĸ߶Ȼָ�����
          Continue;
        end;
      end;
      OffsetRect(DrawItems[i].Rect, 0, vFmtTopOffset);
    end;

    for i := vLastDrawItemNo + 1 to DrawItems.Count - 1 do
    begin
      OffsetRect(DrawItems[i].Rect, 0, vFormatIncHight);  // �¸�ʽ����ƫ��
    end; }

    {vLastItemNo := -1;
    for i := vLastDrawItemNo + 1 to DrawItems.Count - 1 do
    begin
      DrawItems[i].ItemNo := DrawItems[i].ItemNo + AExtraItemCount;
      if vLastItemNo <> DrawItems[i].ItemNo then
      begin
        vLastItemNo := DrawItems[i].ItemNo;
        Items[vLastItemNo].FirstDItemNo := i;
      end;

      // DrawItems[i]��Ӧ��Item�����ҳ�˻�ĳ��ԭ����������ƫ����
      if (DrawItems[i].LineFirst) and (DrawItems[i].Rect.Top + vFormatIncHight <> DrawItems[i - 1].Rect.Bottom) then
        vFormatIncHight := vFormatIncHight - (DrawItems[i].Rect.Top + vFormatIncHight - DrawItems[i - 1].Rect.Bottom);  // ���¸�ʽ��ʱ�Ƚ�������һ�����棬�ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��

      OffsetRect(DrawItems[i].Rect, 0, vFormatIncHight);  // �¸�ʽ����ƫ��

      if Items[DrawItems[i].ItemNo].StyleNo < THCStyle.RsNull then  // RectItem�����ڸ�ʽ��ʱ���к����м��ƫ�ƣ��¸�ʽ��ʱҪ�ָ����ɷ�ҳ�����ٴ����¸�ʽ�����ƫ��
      begin
        vRectReFormatHight := (Items[DrawItems[i].ItemNo] as THCCustomRectItem).GetFormatDiffClearHeight;
        vFormatIncHight := vFormatIncHight - vRectReFormatHight;  // ����ҳ���ӵĸ߶Ȼָ�����
        DrawItems[i].Rect.Bottom := DrawItems[i].Rect.Bottom - vRectReFormatHight;
      end;
    end; }
  end;
end;

procedure THCCustomRichData.ReSetSelectAndCaret(const AItemNo, AOffset: Integer);
begin
  Self.Initialize;
  SelectInfo.StartItemNo := AItemNo;
  SelectInfo.StartItemOffset := AOffset;
  CaretDrawItemNo := GetDrawItemNoByOffset(AItemNo, AOffset);
end;

procedure THCCustomRichData.ReSetSelectAndCaret(const AItemNo: Integer);
begin
  if Items[AItemNo].StyleNo < THCStyle.RsNull then
    ReSetSelectAndCaret(AItemNo, OffsetAfter)
  else
    ReSetSelectAndCaret(AItemNo, Items[AItemNo].Length);
end;

procedure THCCustomRichData.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure THCCustomRichData.SetWidth(const Value: Cardinal);
begin
  if FWidth <> Value then
    FWidth := Value;
end;

procedure THCCustomRichData._FormatReadyParam(const AStartItemNo: Integer;
  var APrioDrawItemNo: Integer; var APos: TPoint);
{var
  i, vEndDrawItemNo: Integer;}
begin
  { ��ȡ��ʼDrawItem����һ����ż���ʽ����ʼλ�� }
  if AStartItemNo > 0 then  // ���ǵ�һ��
  begin
    APrioDrawItemNo := GetItemLastDrawItemNo(AStartItemNo - 1);  // ��һ������DItem
    if Items[AStartItemNo].ParaFirst then
    begin
      APos.X := 0;
      APos.Y := DrawItems[APrioDrawItemNo].Rect.Bottom;
    end
    else
    begin
      APos.X := DrawItems[APrioDrawItemNo].Rect.Right;
      APos.Y := DrawItems[APrioDrawItemNo].Rect.Top;
    end;
  end
  else  // �ǵ�һ��
  begin
    APrioDrawItemNo := -1;
    APos.X := 0;
    APos.Y := 0;
  end;

  {if AEndItemNo = Items.Count - 1 then  // �� -1 �жϸղ���û��ʽ���ĸ���ȷ��
    vEndDrawItemNo := DrawItems.Count - 1
  else
    vEndDrawItemNo := GetItemLastDrawItemNo(AEndItemNo);

  if vEndDrawItemNo < 0 then
    vEndDrawItemNo := GetItemNearDrawItemNo(AEndItemNo);  // ��û�б���ʽ�����罫Item�س����б��2��ʱ����2��

  for i := vEndDrawItemNo downto APrioDrawItemNo + 1 do
    DrawItems.Delete(i);}
end;

end.


