{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{             �ĵ��������ָ�������͵�Ԫ                }
{                                                       }
{*******************************************************}

unit HCUndo;

interface

uses
  System.Classes, System.Generics.Collections;

type

  { THCUndo.Data���� }

  THCUndoMirror = class(TObject)
  private
    FStream: TMemoryStream;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Stream: TMemoryStream read FStream write FStream;
  end;

  THCUndoBaseData = class(TObject)  // ��������ֵ����
  private
    A, B: Integer;
  end;

  THCUndoCell = class(THCUndoBaseData)  // ��Ԫ���ڲ�HCData�Լ�����
  public
    property Row: Integer read A write A;
    property Col: Integer read B write B;
  end;

  THCUndoColSize = class(THCUndoBaseData)  // �ı��п�
  private
    FCol: Integer;
  public
    property Col: Integer read FCol write FCol;
    property OldWidth: Integer read A write A;
    property NewWidth: Integer read B write B;
  end;

  THCUndoSize = class(THCUndoBaseData)  // Item�ߴ�ı�(����RectItem)
  private
    FNewWidth, FNewHeight: Integer;
  public
    property OldWidth: Integer read A write A;
    property OldHeight: Integer read B write B;
    property NewWidth: Integer read FNewWidth write FNewWidth;
    property NewHeight: Integer read FNewHeight write FNewHeight;
  end;

  { UndoAction���� }

  TUndoActionTag = (uatDeleteText, uatInsertText, uatDeleteItem, uatInsertItem,
    uatItemProperty, uatItemSelf);

  THCCustomUndoAction = class(TObject)
  private
    FTag: TUndoActionTag;
    FItemNo,  // �¼�����ʱ��ItemNo
    FOffset  // �¼�����ʱ��Offset
      : Integer;
  public
    constructor Create; virtual;
    property ItemNo: Integer read FItemNo write FItemNo;
    property Offset: Integer read FOffset write FOffset;
    property Tag: TUndoActionTag read FTag write FTag;
  end;

  THCTextUndoAction = class(THCCustomUndoAction)
  private
    FText: string;
  public
    property Text: string read FText write FText;
  end;

  /// <summary> Itemͨ������ </summary>
  TItemProperty = (uipStyleNo, uipParaNo, uipParaFirst);

  THCItemPropertyUndoAction = class(THCCustomUndoAction)
  private
    FItemProperty: TItemProperty;
  public
    constructor Create; override;
    property ItemProperty: TItemProperty read FItemProperty write FItemProperty;
  end;

  THCItemParaFirstUndoAction = class(THCItemPropertyUndoAction)
  private
    FOldParaFirst, FNewParaFirst: Boolean;
  public
    constructor Create; override;
    property OldParaFirst: Boolean read FOldParaFirst write FOldParaFirst;
    property NewParaFirst: Boolean read FNewParaFirst write FNewParaFirst;
  end;

  THCItemUndoAction = class(THCCustomUndoAction)
  private
    FItemStream: TMemoryStream;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ItemStream: TMemoryStream read FItemStream write FItemStream;
  end;

  THCItemSelfUndoAction = class(THCCustomUndoAction)
  private
    FObject: TObject;
  public
    constructor Create; override;
    destructor Destroy; override;
    property &Object: TObject read FObject write FObject;
  end;

  THCUndoActions = class(TObjectList<THCCustomUndoAction>)
  private
    //FTag: TUndoActionTag;
  public
    //property Tag: TUndoActionTag read FTag write FTag;
  end;

  { Undo���� }

  THCCustomUndo = class(TObject)
  private
    FActions: THCUndoActions;
    FIsUndo: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Actions: THCUndoActions read FActions write FActions;
    property IsUndo: Boolean read FIsUndo write FIsUndo;
  end;

  THCUndo = class(THCCustomUndo)
  private
    FSectionIndex: Integer;
    FData: TObject;  // ��Ų�������
  public
    constructor Create; override;
    function ActionAppend(const ATag: TUndoActionTag;
      const AItemNo, AOffset: Integer): THCCustomUndoAction;
    property SectionIndex: Integer read FSectionIndex write FSectionIndex;
    property Data: TObject read FData write FData;
  end;

  THCUndoGroupStart = class(THCUndo)
  private
    FItemNo, FOffset: Integer;
  public
    property ItemNo: Integer read FItemNo write FItemNo;
    property Offset: Integer read FOffset write FOffset;
  end;

  THCUndoGroupEnd = class(THCUndoGroupStart);

  TUndoEvent = procedure (const Sender: THCUndo) of object;

  { UndoList���� }

  THCUndoList = class(TObjectList<THCUndo>)
  private
    FSeek: Integer;
    FMaxUndoCount: Cardinal;
    FOnUndo, FOnRedo, FOnNewUndo, FOnUndoDestroy: TUndoEvent;

    procedure DoNewUndo(const AUndo: THCUndo);
  protected
    procedure Notify(const Value: THCUndo; Action: TCollectionNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUndoGroup(const AItemNo, AOffset: Integer);
    procedure EndUndoGroup(const AItemNo, AOffset: Integer);
    procedure NewUndo;
    procedure Undo;
    procedure Redo;

    property MaxUndoCount: Cardinal read FMaxUndoCount write FMaxUndoCount;
    property OnNewUndo: TUndoEvent read FOnNewUndo write FOnNewUndo;
    property OnUndoDestroy: TUndoEvent read FOnUndoDestroy write FOnUndoDestroy;

    property OnUndo: TUndoEvent read FOnUndo write FOnUndo;
    property OnRedo: TUndoEvent read FOnRedo write FOnRedo;
  end;

  TGetUndoListEvent = function (): THCUndoList of object;

implementation

{ THCCustomUndo }

constructor THCCustomUndo.Create;
begin
  FIsUndo := True;
  FActions := THCUndoActions.Create;
end;

destructor THCCustomUndo.Destroy;
begin
  FActions.Free;
  inherited;
end;

{ THCUndoList }

procedure THCUndoList.BeginUndoGroup(const AItemNo, AOffset: Integer);
var
  vStartUndo: THCUndoGroupStart;
begin
  vStartUndo := THCUndoGroupStart.Create;
  vStartUndo.ItemNo := AItemNo;
  vStartUndo.Offset := AOffset;

  DoNewUndo(vStartUndo);
end;

constructor THCUndoList.Create;
begin
  inherited Create;
  FSeek := -1;
  FMaxUndoCount := 99;
end;

destructor THCUndoList.Destroy;
begin
  inherited Destroy;
end;

procedure THCUndoList.DoNewUndo(const AUndo: THCUndo);
//var
//  i, vIndex: Integer;
begin
  if (FSeek >= 0) and (FSeek < Count - 1) then
  begin
    if Items[FSeek].IsUndo then
      Inc(FSeek);
    Self.DeleteRange(FSeek, Count - FSeek);
  end;

  if Count > FMaxUndoCount then
  begin
    {Ĭ��֧���Ҳ�������ʼʱ������0����Ϊ��ʼ
    if Items[0] is THCUndoGroupStart then
    begin
      for i := 1 to Self.Count - 1 do
      begin
        if Items[i] is THCUndoGroupEnd then
        begin
          vIndex := i;
          Break;
        end;
      end;

      Self.DeleteRange(0, vIndex + 1);
    end
    else}
      Self.Delete(0);
  end;

  if Assigned(FOnNewUndo) then
    FOnNewUndo(AUndo);
  Self.Add(AUndo);
  FSeek := Self.Count - 1;
end;

procedure THCUndoList.EndUndoGroup(const AItemNo, AOffset: Integer);
var
  vEndUndo: THCUndoGroupEnd;
begin
  vEndUndo := THCUndoGroupEnd.Create;
  vEndUndo.ItemNo := AItemNo;
  vEndUndo.Offset := AOffset;

  DoNewUndo(vEndUndo);
end;

procedure THCUndoList.NewUndo;
var
  vUndo: THCUndo;
begin
  vUndo := THCUndo.Create;
  DoNewUndo(vUndo);
end;

procedure THCUndoList.Notify(const Value: THCUndo;
  Action: TCollectionNotification);
begin
  if (Action = cnRemoved) and Assigned(FOnUndoDestroy) then
    FOnUndoDestroy(Value);

  inherited Notify(Value, Action);
end;

procedure THCUndoList.Redo;

  procedure DoSeekRedoEx;
  begin
    Inc(FSeek);

    if Assigned(FOnRedo) then
      FOnRedo(Items[FSeek]);

    Items[FSeek].IsUndo := True;
  end;

var
  i, vOver, vLastId: Integer;
begin
  if FSeek < Count - 1 then
  begin
    if Items[FSeek + 1] is THCUndoGroupStart then
    begin
      vOver := 0;
      vLastId := Count - 1;

      // �ҽ���
      for i := FSeek + 2 to Count - 1 do
      begin
        if Items[i] is THCUndoGroupEnd then
        begin
          if vOver = 0 then
          begin
            vLastId := i;
            Break;
          end
          else
            Dec(vOver);
        end
        else
        if Items[i] is THCUndoGroupStart then
          Inc(vOver);
      end;

      // �������ڸ���Redo
      while FSeek < vLastId do
        DoSeekRedoEx;
    end
    else
      DoSeekRedoEx;
  end;
end;

procedure THCUndoList.Undo;

  procedure DoSeekUndoEx;
  begin
    if Assigned(FOnUndo) then
      FOnUndo(Items[FSeek]);

    Items[FSeek].IsUndo := False;
    Dec(FSeek);
  end;

var
  i, vOver, vLastId: Integer;
begin
  if FSeek >= 0 then
  begin
    if Items[FSeek] is THCUndoGroupEnd then  // �鳷�������Ӻ���ǰ��1��
    begin
      vOver := 0;

      // �ҴӺ���ǰ���1��
      vLastId := 0;
      for i := FSeek - 1 downto 0 do
      begin
        if Items[i] is THCUndoGroupStart then
        begin
          if vOver = 0 then
          begin
            vLastId := i;
            Break;
          end
          else
            Dec(vOver);
        end
        else
        if Items[i] is THCUndoGroupEnd then
          Inc(vOver);
      end;

      // �������ڸ���Undo
      while FSeek >= vLastId do
        DoSeekUndoEx;
    end
    else
      DoSeekUndoEx;
  end;
end;

{ THCUndo }

function THCUndo.ActionAppend(const ATag: TUndoActionTag;
  const AItemNo, AOffset: Integer): THCCustomUndoAction;
begin
  case ATag of
    uatDeleteText, uatInsertText:
      Result := THCTextUndoAction.Create;

    uatDeleteItem, uatInsertItem:
      Result := THCItemUndoAction.Create;

    uatItemProperty:
      Result := THCItemParaFirstUndoAction.Create;

    uatItemSelf:
      Result := THCItemSelfUndoAction.Create;
  else
    Result := THCCustomUndoAction.Create;
  end;

  Result.Tag := ATag;
  Result.ItemNo := AItemNo;
  Result.Offset := AOffset;

  FActions.Add(Result);
end;

constructor THCUndo.Create;
begin
  inherited Create;
  FSectionIndex := -1;
end;

{ THCCustomUndoAction }

constructor THCCustomUndoAction.Create;
begin
  inherited Create;
  FItemNo := -1;
  FOffset := -1;
end;

{ THCItemUndoAction }

constructor THCItemUndoAction.Create;
begin
  inherited Create;
  FItemStream := TMemoryStream.Create;
end;

destructor THCItemUndoAction.Destroy;
begin
  FItemStream.Free;
  inherited Destroy;
end;

{ THCItemPropertyUndoAction }

constructor THCItemPropertyUndoAction.Create;
begin
  inherited Create;
  Self.Tag := TUndoActionTag.uatItemProperty;
end;

{ THCItemParaFirstUndoAction }

constructor THCItemParaFirstUndoAction.Create;
begin
  inherited Create;
  FItemProperty := TItemProperty.uipParaFirst;
end;

{ THCItemSelfUndoAction }

constructor THCItemSelfUndoAction.Create;
begin
  inherited Create;
  Self.Tag := TUndoActionTag.uatItemSelf;
  FObject := nil;
end;

destructor THCItemSelfUndoAction.Destroy;
begin
  if FObject <> nil then
    FObject.Free;
  inherited Destroy;
end;

{ THCUndoMirror }

constructor THCUndoMirror.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor THCUndoMirror.Destroy;
begin
  if FStream <> nil then
    FStream.Free;
  inherited Destroy;
end;

end.
