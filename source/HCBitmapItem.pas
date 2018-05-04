{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{          �ĵ�BitmapItem(ͼ��)����ʵ�ֵ�Ԫ             }
{                                                       }
{*******************************************************}

unit HCBitmapItem;

interface

uses
  Windows, Graphics, Classes, HCStyle, HCItem, HCRectItem;

type
  THCBitmapItem = class(THCResizeRectItem)
  private
    FBitmap: TBitmap;
  protected
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
    //procedure SetActive(const Value: Boolean); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    //
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure PaintTop(const ACanvas: TCanvas); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromBmpFile(const AFileName: string);
    property Bitmap: TBitmap read FBitmap;
  end;

implementation

{ THCBitmapItem }

constructor THCBitmapItem.Create;
begin
  inherited Create;
  FBitmap := TBitmap.Create;
  StyleNo := THCStyle.RsBitmap;
end;

destructor THCBitmapItem.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure THCBitmapItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  ACanvas.StretchDraw(ADrawRect, FBitmap);

  inherited DoPaint(AStyle, ADrawRect, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, ACanvas, APaintInfo);
end;

function THCBitmapItem.GetHeight: Integer;
begin
  Result := inherited GetHeight;
  if Result = 0 then
    Result := FBitmap.Height;
end;

function THCBitmapItem.GetWidth: Integer;
begin
  Result := inherited GetWidth;
  if Result = 0 then
    Result := FBitmap.Width;
end;

procedure THCBitmapItem.LoadFromBmpFile(const AFileName: string);
begin
  FBitmap.LoadFromFile(AFileName);
  Self.Width := FBitmap.Width;
  Self.Height := FBitmap.Height;
end;

procedure THCBitmapItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  FBitmap.LoadFromStream(AStream);
end;

procedure THCBitmapItem.PaintTop(const ACanvas: TCanvas);
var
  vBlendFunction: TBlendFunction;
begin
    vBlendFunction.BlendOp := AC_SRC_OVER;
    vBlendFunction.BlendFlags := 0;
    vBlendFunction.AlphaFormat := AC_SRC_OVER;  // ͨ��Ϊ 0�����ԴλͼΪ32λ���ɫ����Ϊ AC_SRC_ALPHA
    vBlendFunction.SourceConstantAlpha := 128; // ͸����
    Windows.AlphaBlend(ACanvas.Handle,
                       ResizeRect.Left,
                       ResizeRect.Top,
                       ResizeWidth,
                       ResizeHeight,
                       FBitmap.Canvas.Handle,
                       0,
                       0,
                       FBitmap.Width,
                       FBitmap.Height,
                       vBlendFunction
                       );
  inherited PaintTop(ACanvas);
end;

procedure THCBitmapItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  FBitmap.SaveToStream(AStream);
end;

end.
