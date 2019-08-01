{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                �ĵ��߼�������ʵ�ֵ�Ԫ                 }
{                                                       }
{*******************************************************}

unit HCRichScrollBar;

interface

uses
  Windows, Classes, Controls, Graphics, Generics.Collections, HCScrollBar;

type
  TAreaMark = class(TObject)  // ������
  strict private
    FTag, FPosition, FHeight: Integer;
  public
    property Position: Integer read FPosition write FPosition;
    property Height: Integer read FHeight write FHeight;
    property Tag: Integer read FTag write FTag;
  end;

  TAreaMarks = TObjectList<TAreaMark>;

  THCRichScrollBar = class(THCScrollBar)
  private
    FAreaMarks: TAreaMarks;  // �ʺϹ̶�����ı��
    function GetAreaMarkByTag(const ATag: Integer): Integer;
    function GetAreaMarkRect(const AIndex: Integer): TRect;
  protected
    procedure DoDrawThumBefor(const ACanvas: TCanvas; const AThumRect: TRect); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure SetAreaPos(const ATag, APosition, AHeight: Integer);
  end;

implementation

{ THCRichScrollBar }

constructor THCRichScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor THCRichScrollBar.Destroy;
begin
  if Assigned(FAreaMarks) then
    FAreaMarks.Free;

  inherited Destroy;
end;

procedure THCRichScrollBar.DoDrawThumBefor(const ACanvas: TCanvas;
  const AThumRect: TRect);
var
  i: Integer;
  vRect: TRect;
begin
  case Self.Orientation of
    oriHorizontal:
      begin
      end;

    oriVertical:
      begin
        if Assigned(FAreaMarks) then
        begin
          ACanvas.Brush.Color := $006B5952;

          for i := 0 to FAreaMarks.Count - 1 do
          begin
            vRect := GetAreaMarkRect(i);

            if (vRect.Bottom > HCScrollBar.ButtonSize)
              and (vRect.Top < Self.Height - HCScrollBar.ButtonSize)
            then
              ACanvas.FillRect(vRect);
          end;
        end;
      end;
  end;
end;

function THCRichScrollBar.GetAreaMarkByTag(const ATag: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FAreaMarks.Count - 1 do
  begin
    if FAreaMarks[i].Tag = ATag then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function THCRichScrollBar.GetAreaMarkRect(const AIndex: Integer): TRect;
var
  vTop, vHeight: Integer;
begin
  SetRectEmpty(Result);

  case Self.Orientation of
    oriHorizontal:
      begin
      end;

    oriVertical:
      begin
        vTop := ButtonSize + Round(FAreaMarks[AIndex].Position * Percent);
        vHeight := Round(FAreaMarks[AIndex].Height * Percent);
        if vHeight < 2 then
          vHeight := 2;  // ��С�߶�

        Result := Bounds(0, vTop, Width, vHeight);
      end;
  end;
end;

procedure THCRichScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
  vRect: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if PtInRect(FThumRect, FMouseDownPt) then Exit;

  case Self.Orientation of
    oriHorizontal:
      begin
      end;

    oriVertical:
      begin
        if Assigned(FAreaMarks) then
        begin
          for i := 0 to FAreaMarks.Count - 1 do
          begin
            vRect := GetAreaMarkRect(i);
            if PtInRect(vRect, FMouseDownPt) then
            begin
              Self.Position := FAreaMarks[i].Position - vRect.Top;
              Break;
            end;
          end;
        end;
      end;
  end;
end;

procedure THCRichScrollBar.SetAreaPos(const ATag, APosition, AHeight: Integer);
var
  vIndex: Integer;
  vAreaMark: TAreaMark;
  vRect: TRect;
begin
  if not Assigned(FAreaMarks) then
    FAreaMarks := TAreaMarks.Create;

  vIndex := GetAreaMarkByTag(ATag);
  if vIndex < 0 then
  begin
    vAreaMark := TAreaMark.Create;
    vAreaMark.Tag := ATag;
    vAreaMark.Position := APosition;
    vAreaMark.Height := AHeight;

    FAreaMarks.Add(vAreaMark);
    vRect := GetAreaMarkRect(FAreaMarks.Count - 1);
    OffsetRect(vRect, Left, Top);
    InvalidateRect(Self.Parent.Handle, vRect, False);
  end
  else  // �ж�Ӧtag�ģ������޸�ֵ
  if (FAreaMarks[vIndex].Position <> APosition) or (FAreaMarks[vIndex].Height <> AHeight) then
  begin
    vRect := GetAreaMarkRect(vIndex);
    FAreaMarks[vIndex].Position := APosition;
    FAreaMarks[vIndex].Height := AHeight;
    OffsetRect(vRect, Left, Top);
    InvalidateRect(Self.Parent.Handle, vRect, False);  // �ɵ�ȥ

    vRect := GetAreaMarkRect(vIndex);
    OffsetRect(vRect, Left, Top);
    InvalidateRect(Self.Parent.Handle, vRect, False);  // �µ���
  end;
end;

end.
