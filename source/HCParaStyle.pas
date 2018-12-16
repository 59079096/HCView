{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
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

  /// <summary> �δ�ֱ���뷽ʽ���ϡ����С���) </summary>
  TParaAlignVert = (pavTop, pavCenter, pavBottom);

  TParaLineSpaceMode = (pls100, pls115, pls150, pls200, plsFix);

  THCParaStyle = class(TPersistent)
  strict private
    FLineSpaceMode: TParaLineSpaceMode;
    FFristIndent,// ��������
    FLeftIndent  // ������
      : Integer;
    FBackColor: TColor;
    FAlignHorz: TParaAlignHorz;
    FAlignVert: TParaAlignVert;
  public
    CheckSaveUsed: Boolean;
    TempNo: Integer;
    constructor Create;
    destructor Destroy; override;
    function EqualsEx(const ASource: THCParaStyle): Boolean;
    procedure AssignEx(const ASource: THCParaStyle);
    procedure SaveToStream(const AStream: TStream);
    procedure LoadFromStream(const AStream: TStream; const AFileVersion: Word);
    function ToCSS: string;
    function ToXml: string;
  published
    property LineSpaceMode: TParaLineSpaceMode read FLineSpaceMode write FLineSpaceMode;
    //property LineSpace: Integer read FLineSpace write SetLineSpace;
    //property LineSpaceHalf: Integer read FLineSpaceHalf;
    property FristIndent: Integer read FFristIndent write FFristIndent;
    property LeftIndent: Integer read FLeftIndent write FLeftIndent;
    property BackColor: TColor read FBackColor write FBackColor;
    property AlignHorz: TParaAlignHorz read FAlignHorz write FAlignHorz;
    property AlignVert: TParaAlignVert read FAlignVert write FAlignVert;
  end;

implementation

uses
  SysUtils, HCCommon;

{ THCParaStyle }

procedure THCParaStyle.AssignEx(const ASource: THCParaStyle);
begin
  Self.FLineSpaceMode := ASource.LineSpaceMode;
  //Self.FLineSpace := ASource.LineSpace;
  //Self.FLineSpaceHalf := ASource.LineSpaceHalf;
  Self.FFristIndent := ASource.FristIndent;
  Self.FLeftIndent := ASource.LeftIndent;
  Self.FBackColor := ASource.BackColor;
  Self.FAlignHorz := ASource.AlignHorz;
  Self.FAlignVert := ASource.AlignVert;
end;

constructor THCParaStyle.Create;
begin
  FFristIndent := 0;
  FLeftIndent := 0;
  FLineSpaceMode := TParaLineSpaceMode.pls100;
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
  //(Self.FLineSpace = ASource.LineSpace)
  (Self.FLineSpaceMode = ASource.LineSpaceMode)
  and (Self.FFristIndent = ASource.FristIndent)
  and (Self.LeftIndent = ASource.LeftIndent)
  and (Self.FBackColor = ASource.BackColor)
  and (Self.FAlignHorz = ASource.AlignHorz)
  and (Self.FAlignVert = ASource.AlignVert);
end;

procedure THCParaStyle.LoadFromStream(const AStream: TStream; const AFileVersion: Word);
var
  vLineSpace: Integer;
begin
  if AFileVersion < 15 then
    AStream.ReadBuffer(vLineSpace, SizeOf(vLineSpace));

  if AFileVersion > 16 then
    AStream.ReadBuffer(FLineSpaceMode, SizeOf(FLineSpaceMode));
  //FLineSpaceHalf := FLineSpace div 2;
  AStream.ReadBuffer(FFristIndent, SizeOf(FFristIndent));  // ��������
  AStream.ReadBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������

  if AFileVersion > 18 then
    LoadColorFromStream(FBackColor, AStream)
  else
    AStream.ReadBuffer(FBackColor, SizeOf(FBackColor));

  AStream.ReadBuffer(FAlignHorz, SizeOf(FAlignHorz));

  if AFileVersion > 17 then
    AStream.ReadBuffer(FAlignVert, SizeOf(FAlignVert));
end;

procedure THCParaStyle.SaveToStream(const AStream: TStream);
begin
  AStream.WriteBuffer(FLineSpaceMode, SizeOf(FLineSpaceMode));
  AStream.WriteBuffer(FFristIndent, SizeOf(FFristIndent));  // ��������
  AStream.WriteBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������
  //AStream.WriteBuffer(FBackColor, SizeOf(FBackColor));
  SaveColorToStream(FBackColor, AStream);
  AStream.WriteBuffer(FAlignHorz, SizeOf(FAlignHorz));
  AStream.WriteBuffer(FAlignVert, SizeOf(FAlignVert));
end;

function THCParaStyle.ToCSS: string;
begin
  Result := ' text-align: ';
  case FAlignHorz of
    pahLeft: Result := Result + 'left';
    pahRight: Result := Result + 'right';
    pahCenter: Result := Result + 'center';
    pahJustify, pahScatter: Result := Result + 'justify';
  end;

  case FLineSpaceMode of
    pls100: Result := Result + '; line-height: 100%';
    pls115: Result := Result + '; line-height: 115%';
    pls150: Result := Result + '; line-height: 150%';
    pls200: Result := Result + '; line-height: 200%';
    plsFix: Result := Result + '; line-height: 10px';
  end;
end;

function THCParaStyle.ToXml: string;

  function GetLineSpaceModeXML: string;
  begin
    case FLineSpaceMode of
      pls100: Result := '100';
      pls115: Result := '115';
      pls150: Result := '150';
      pls200: Result := '200';
      plsFix: Result := 'fix';
    end;
  end;

  function GetHorzXML: string;
  begin
    case FAlignHorz of
      pahLeft: Result := 'left';
      pahRight: Result := 'right';
      pahCenter: Result := 'center';
      pahJustify: Result := 'justify';
      pahScatter: Result := 'scatter';
    end;
  end;

  function GetVertXML: string;
  begin
    case FAlignVert of
      pavTop: Result := 'top';
      pavCenter: Result := 'center';
      pavBottom: Result := 'bottom';
    end;
  end;

begin
  Result := '<ps fristindent="' + IntToStr(FFristIndent) + '"'
    + ' leftindent="' + IntToStr(FLeftIndent) + '"'
    + ' bkcolor="' + GetColorHtmlRGB(FBackColor) + '"'
    + ' spacemode="' + GetLineSpaceModeXML + '"'
    + ' horz="' + GetHorzXML + '"'
    + ' vert="' + GetVertXML + '"></ps>';
end;

end.
