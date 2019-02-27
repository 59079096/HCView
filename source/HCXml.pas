{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-12-14            }
{                                                       }
{                     xml��ʽ����                       }
{                                                       }
{*******************************************************}

unit HCXml;

interface

uses
  Classes, Windows, Graphics, XMLDoc, XMLIntf;

type
  IHCXMLDocument = IXMLDocument;

  IHCXMLNode = IXMLNode;

  THCXMLDocument = TXMLDocument;

  function GetColorXmlRGB(const AColor: TColor): string;
  function GetXmlRGBColor(const AColorStr: string): TColor;
  //function GetColorHtmlRGB(const AColor: TColor): string;

  /// <summary> BitmapתΪBase64�ַ� </summary>
  function GraphicToBase64(const AGraphic: TGraphic): string;
  procedure Base64ToGraphic(const ABase64: string; const AGraphic: TGraphic);

implementation

uses
  SysUtils, EncdDecd;

function StreamToBase64(const AStream: TStream): string;
var
  vSs:TStringStream;
begin
  vSs := TStringStream.Create('');
  try
    AStream.Position := 0;
    EncodeStream(AStream, vSs);  // ���ڴ�������Ϊbase64�ַ���
    Result := vSs.DataString;
  finally
    FreeAndNil(vSs);
  end;
end;

procedure Base64ToStream(const ABase64: string; var AStream: TStream);
var
  vSs:TStringStream;
begin
  vSs := TStringStream.Create(ABase64);
  try
    DecodeStream(vSs, AStream);//��base64�ַ�����ԭΪ�ڴ���
  finally
    FreeAndNil(vSs);
  end;
end;

function GraphicToBase64(const AGraphic: TGraphic): string;
var
  vMs: TMemoryStream;
begin
  vMs := TMemoryStream.Create;
  try
    AGraphic.SaveToStream(vMs);
    Result := StreamToBase64(vMs);  // ��base64�ַ�����ԭΪ�ڴ���
  finally
    FreeAndNil(vMs);
  end;
end;

procedure Base64ToGraphic(const ABase64: string; const AGraphic: TGraphic);
var
  vMs: TStream;
begin
  vMs := TMemoryStream.Create;
  try
    Base64ToStream(ABase64, vMs);
    vMs.Position := 0;
    AGraphic.LoadFromStream(vMs);
  finally
    FreeAndNil(vMs);
  end;
end;

function GetColorXmlRGB(const AColor: TColor): string;
begin
  Result := IntToStr(GetRValue(AColor)) + ','
    + IntToStr(GetGValue(AColor)) + ',' + IntToStr(GetBValue(AColor));
end;

function GetXmlRGBColor(const AColorStr: string): TColor;
var
  vsRGB: TStringList;
begin
  vsRGB := TStringList.Create;
  try
    vsRGB.Delimiter := ',';
    vsRGB.DelimitedText := AColorStr;
    Result := RGB(StrToInt(vsRGB[0]), StrToInt(vsRGB[1]), StrToInt(vsRGB[2]))
  finally
    FreeAndNil(vsRGB);
  end;
end;

//function GetColorHtmlRGB(const AColor: TColor): string;
//begin
//  Result := 'rgb(' + GetColorXmlRGB(AColor) + ')';
//end;

end.
