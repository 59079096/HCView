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
  Classes, Graphics, HCXml;

type
  /// <summary> ��ˮƽ���뷽ʽ�����ҡ����С����ˡ���ɢ) </summary>
  TParaAlignHorz = (pahLeft, pahRight, pahCenter, pahJustify, pahScatter);

  /// <summary> �δ�ֱ���뷽ʽ���ϡ����С���) </summary>
  TParaAlignVert = (pavTop, pavCenter, pavBottom);

  /// <summary> ����������ʽ </summary>
  TParaFirstLineIndent = (pfiNone, pfiIndented, pfiHanging);

  TParaLineSpaceMode = (pls100, pls115, pls150, pls200, plsFix);

  THCParaStyle = class(TPersistent)
  strict private
    FLineSpaceMode: TParaLineSpaceMode;
    FFirstIndent, // ��������
    FLeftIndent,  // ������
    FRightIndent  // ������
      : Integer;
    FBackColor: TColor;
    FAlignHorz: TParaAlignHorz;
    FAlignVert: TParaAlignVert;
  public
    CheckSaveUsed: Boolean;
    TempNo: Integer;
    constructor Create;
    function EqualsEx(const ASource: THCParaStyle): Boolean;
    procedure AssignEx(const ASource: THCParaStyle);
    procedure SaveToStream(const AStream: TStream);
    procedure LoadFromStream(const AStream: TStream; const AFileVersion: Word);
    function ToCSS: string;
    procedure ToXml(const ANode: IHCXmlNode);
    procedure ParseXml(const ANode: IHCXmlNode);
  published
    property LineSpaceMode: TParaLineSpaceMode read FLineSpaceMode write FLineSpaceMode;
    //property LineSpace: Integer read FLineSpace write SetLineSpace;
    //property LineSpaceHalf: Integer read FLineSpaceHalf;
    property FirstIndent: Integer read FFirstIndent write FFirstIndent;
    property LeftIndent: Integer read FLeftIndent write FLeftIndent;
    property RightIndent: Integer read FRightIndent write FRightIndent;
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
  FLineSpaceMode := ASource.LineSpaceMode;
  FFirstIndent := ASource.FirstIndent;
  FLeftIndent := ASource.LeftIndent;
  FRightIndent := ASource.RightIndent;
  FBackColor := ASource.BackColor;
  FAlignHorz := ASource.AlignHorz;
  FAlignVert := ASource.AlignVert;
end;

constructor THCParaStyle.Create;
begin
  FFirstIndent := 0;
  FLeftIndent := 0;
  FRightIndent := 0;
  FLineSpaceMode := TParaLineSpaceMode.pls100;
  FBackColor := clSilver;
  FAlignHorz := TParaAlignHorz.pahJustify;
  FAlignVert := TParaAlignVert.pavCenter;
end;

function THCParaStyle.EqualsEx(const ASource: THCParaStyle): Boolean;
begin
  Result :=
  //(Self.FLineSpace = ASource.LineSpace)
  (FLineSpaceMode = ASource.LineSpaceMode)
  and (FFirstIndent = ASource.FirstIndent)
  and (FLeftIndent = ASource.LeftIndent)
  and (FRightIndent = ASource.RightIndent)
  and (FBackColor = ASource.BackColor)
  and (FAlignHorz = ASource.AlignHorz)
  and (FAlignVert = ASource.AlignVert);
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
  AStream.ReadBuffer(FFirstIndent, SizeOf(FFirstIndent));  // ��������
  AStream.ReadBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������

  if AFileVersion > 18 then
    HCLoadColorFromStream(AStream, FBackColor)
  else
    AStream.ReadBuffer(FBackColor, SizeOf(FBackColor));

  AStream.ReadBuffer(FAlignHorz, SizeOf(FAlignHorz));

  if AFileVersion > 17 then
    AStream.ReadBuffer(FAlignVert, SizeOf(FAlignVert));
end;

procedure THCParaStyle.ParseXml(const ANode: IHCXmlNode);

  procedure GetXMLLineSpaceMode_;
  begin
    if ANode.Attributes['spacemode'] = '100' then
      FLineSpaceMode := pls100
    else
    if ANode.Attributes['spacemode'] = '115' then
      FLineSpaceMode := pls115
    else
    if ANode.Attributes['spacemode'] = '150' then
      FLineSpaceMode := pls150
    else
    if ANode.Attributes['spacemode'] = '200' then
      FLineSpaceMode := pls200
    else
    if ANode.Attributes['spacemode'] = 'fix' then
      FLineSpaceMode := plsFix;
  end;

  procedure GetXMLHorz_;
  begin
    if ANode.Attributes['horz'] = 'left' then
      FAlignHorz := pahLeft
    else
    if ANode.Attributes['horz'] = 'right' then
      FAlignHorz := pahRight
    else
    if ANode.Attributes['horz'] = 'center' then
      FAlignHorz := pahCenter
    else
    if ANode.Attributes['horz'] = 'justify' then
      FAlignHorz := pahJustify
    else
    if ANode.Attributes['horz'] = 'scatter' then
      FAlignHorz := pahScatter;
  end;

  procedure GetXMLVert_;
  begin
    if ANode.Attributes['vert'] = 'top' then
      FAlignVert := pavTop
    else
    if ANode.Attributes['vert'] = 'center' then
      FAlignVert := pavCenter
    else
    if ANode.Attributes['vert'] = 'bottom' then
      FAlignVert := pavBottom;
  end;

begin
  FFirstIndent := ANode.Attributes['firstindent'];
  FLeftIndent := ANode.Attributes['leftindent'];
  FBackColor := GetXmlRGBColor(ANode.Attributes['bkcolor']);
  GetXMLLineSpaceMode_;
  GetXMLHorz_;
  GetXMLVert_;
end;

procedure THCParaStyle.SaveToStream(const AStream: TStream);
begin
  AStream.WriteBuffer(FLineSpaceMode, SizeOf(FLineSpaceMode));
  AStream.WriteBuffer(FFirstIndent, SizeOf(FFirstIndent));  // ��������
  AStream.WriteBuffer(FLeftIndent, SizeOf(FLeftIndent));  // ������
  //AStream.WriteBuffer(FBackColor, SizeOf(FBackColor));
  HCSaveColorToStream(AStream, FBackColor);
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

procedure THCParaStyle.ToXml(const ANode: IHCXmlNode);

  function GetLineSpaceModeXML_: string;
  begin
    case FLineSpaceMode of
      pls100: Result := '100';
      pls115: Result := '115';
      pls150: Result := '150';
      pls200: Result := '200';
      plsFix: Result := 'fix';
    end;
  end;

  function GetHorzXML_: string;
  begin
    case FAlignHorz of
      pahLeft: Result := 'left';
      pahRight: Result := 'right';
      pahCenter: Result := 'center';
      pahJustify: Result := 'justify';
      pahScatter: Result := 'scatter';
    end;
  end;

  function GetVertXML_: string;
  begin
    case FAlignVert of
      pavTop: Result := 'top';
      pavCenter: Result := 'center';
      pavBottom: Result := 'bottom';
    end;
  end;

begin
  ANode.Attributes['firstindent'] := FFirstIndent;
  ANode.Attributes['leftindent'] := FLeftIndent;
  ANode.Attributes['bkcolor'] := GetColorXmlRGB(FBackColor);
  ANode.Attributes['spacemode'] := GetLineSpaceModeXML_;
  ANode.Attributes['horz'] := GetHorzXML_;
  ANode.Attributes['vert'] := GetVertXML_;
end;

end.
