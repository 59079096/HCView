{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  �ı�����ʽʵ�ֵ�Ԫ                   }
{                                                       }
{*******************************************************}

unit HCParaStyle;

interface

uses
  Classes, Graphics;

type
  /// <summary> ��ˮƽ���뷽ʽ�����ҡ����С����ˡ���ɢ) </summary>
  TParaAlignHorz = (pahLeft, pahRight, pahCenter, pahJustify, pahScatter);

  /// <summary> �δ�ֱ���뷽ʽ���¡����С���) </summary>
  TParaAlignVert = (pavBottom, pavCenter, pavTop);

  THCParaStyle = class(TPersistent)
  strict private
    FLineSpace,  // �м��
    FLineSpaceHalf,  // �м��һ��
    FFristIndent,// ��������
    FLeftIndent  // ������
      : Integer;
    FBackColor: TColor;
    FAlignHorz: TParaAlignHorz;
    FAlignVert: TParaAlignVert;
  protected
    procedure SetLineSpace(const Value: Integer);
  public
    CheckSaveUsed: Boolean;
    TempNo: Integer;
    constructor Create;
    destructor Destroy; override;
    function EqualsEx(const ASource: THCParaStyle): Boolean;
    procedure AssignEx(const ASource: THCParaStyle);
    procedure SaveToStream(const AStream: TStream);
    procedure LoadFromStream(const AStream: TStream; const AFileVersion: Word);
  published
    property LineSpace: Integer read FLineSpace write SetLineSpace;
    property LineSpaceHalf: Integer read FLineSpaceHalf;
    property FristIndent: Integer read FFristIndent write FFristIndent;
    property LeftIndent: Integer read FLeftIndent write FLeftIndent;
    property BackColor: TColor read FBackColor write FBackColor;
    property AlignHorz: TParaAlignHorz read FAlignHorz write FAlignHorz;
    property AlignVert: TParaAlignVert read FAlignVert write FAlignVert;
  end;

implementation

{ THCParaStyle }

procedure THCParaStyle.AssignEx(const ASource: THCParaStyle);
begin
  Self.FLineSpace := ASource.LineSpace;
  Self.FLineSpaceHalf := ASource.FLineSpaceHalf;
  Self.FFristIndent := ASource.FristIndent;
  Self.LeftIndent := ASource.LeftIndent;
  Self.FBackColor := ASource.BackColor;
  Self.FAlignHorz := ASource.AlignHorz;
end;

constructor THCParaStyle.Create;
begin
  FLineSpace := 8;  // ����ֵĸ�Ϊ15��
  FLineSpaceHalf := 4;
  FFristIndent := 0;
  FLeftIndent := 0;
  FBackColor := clSilver;
  FAlignHorz := TParaAlignHorz.pahJustify;
  FAlignVert := TParaAlignVert.pavCenter;
end;

destructor THCParaStyle.Destroy;
begin

  inherited;
end;

function THCParaStyle.EqualsEx(const ASource: THCParaStyle): Boolean;
begin
  Result :=
  (Self.FLineSpace = ASource.LineSpace)
  and (Self.FFristIndent = ASource.FristIndent)
  and (Self.LeftIndent = ASource.LeftIndent)
  and (Self.FBackColor = ASource.BackColor)
  and (Self.FAlignHorz = ASource.AlignHorz)
  and (Self.FAlignVert = ASource.AlignVert)
  and (Self.FLineSpace = ASource.LineSpace);
end;

procedure THCParaStyle.LoadFromStream(const AStream: TStream; const AFileVersion: Word);
begin
  AStream.ReadBuffer(FLineSpace, SizeOf(FLineSpace));
  FLineSpaceHalf := FLineSpace div 2;
  AStream.ReadBuffer(FFristIndent, SizeOf(FFristIndent));  // ��������
  AStream.ReadBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������
  AStream.ReadBuffer(FBackColor, SizeOf(FBackColor));
  AStream.ReadBuffer(FAlignHorz, SizeOf(FAlignHorz));
end;

procedure THCParaStyle.SaveToStream(const AStream: TStream);
begin
  AStream.WriteBuffer(FLineSpace, SizeOf(FLineSpace));
  AStream.WriteBuffer(FFristIndent, SizeOf(FFristIndent));  // ��������
  AStream.WriteBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������
  AStream.WriteBuffer(FBackColor, SizeOf(FBackColor));
  AStream.WriteBuffer(FAlignHorz, SizeOf(FAlignHorz));
end;

procedure THCParaStyle.SetLineSpace(const Value: Integer);
begin
  if FLineSpace <> Value then
  begin
    FLineSpace := Value;
    FLineSpaceHalf := Value div 2;
  end;
end;

end.
