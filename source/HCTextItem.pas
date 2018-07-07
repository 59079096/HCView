{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                �ı����HCItem���൥Ԫ                 }
{                                                       }
{*******************************************************}

unit HCTextItem;

interface

uses
  Windows, Classes, SysUtils, Graphics, HCStyle, HCItem;

type
  THCTextItemClass = class of THCTextItem;

  THCTextItem = class(THCCustomItem)
  private
    FText: string;
  protected
    function GetText: string; override;
    procedure SetText(const Value: string); override;
    function GetLength: Integer; override;
    procedure Assign(Source: THCCustomItem); override;
    function BreakByOffset(const AOffset: Integer): THCCustomItem; override;
    // ����Ͷ�ȡ
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor CreateByText(const AText: string); virtual;

    /// <summaryy �ɽ������� </summary>
    function CanAccept: Boolean; virtual;

    /// <summaryy ����һ�����ı� </summary>
    /// <param name="AStartOffs">���Ƶ���ʼλ��(����0)</param>
    /// <param name="ALength">����ʼλ�����Ƶĳ���</param>
    /// <returns>�ı�����</returns>
    function GetTextPart(const AStartOffs, ALength: Integer): string;
  end;

var
  HCDefaultTextItemClass: THCTextItemClass = THCTextItem;

implementation

uses
  HCCommon, HCTextStyle;

{ THCTextItem }

function THCTextItem.CanAccept: Boolean;
begin
  Result := True;
end;

constructor THCTextItem.CreateByText(const AText: string);
begin
  Create;  // ������� inherited Create; �����THCCustomItem��Create������TEmrTextItem����CreateByTextʱ����ִ���Լ���Create
  FText := AText;
end;

procedure THCTextItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  Self.Text := (Source as THCTextItem).Text;
end;

function THCTextItem.BreakByOffset(const AOffset: Integer): THCCustomItem;
begin
  if (AOffset >= Length) or (AOffset <= 0) then
    Result := nil
  else
  begin
    Result := inherited BreakByOffset(AOffset);
    Result.Text := Self.GetTextPart(AOffset + 1, Length - AOffset);
    Delete(FText, AOffset + 1, Length - AOffset);  // ��ǰItem��ȥ������ַ���
  end;
end;

function THCTextItem.GetLength: Integer;
begin
  Result := System.Length(FText);
end;

function THCTextItem.GetText: string;
begin
  Result := FText;
end;

function THCTextItem.GetTextPart(const AStartOffs, ALength: Integer): string;
begin
  Result := Copy(FText, AStartOffs, ALength);
end;

procedure THCTextItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vDSize: DWORD;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  if AFileVersion < 11 then  // ����65536������ַ�����
  begin
    AStream.ReadBuffer(vSize, SizeOf(Word));
    vDSize := vSize;
  end
  else
    AStream.ReadBuffer(vDSize, SizeOf(DWORD));

  if vDSize > 0 then
  begin
    SetLength(vBuffer, vDSize);
    AStream.Read(vBuffer[0], vDSize);
    FText := StringOf(vBuffer);
  end;
end;

procedure THCTextItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
var
  vBuffer: TBytes;
  vDSize: DWORD;  // ���HC_TEXTMAXSIZE = 4294967295���ֽڣ������������ʹ��д���ı�����дһ��������ʶ(��#9)������ʱ����ֱ���˱�ʶ
  vS: string;
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  vS := GetTextPart(AStart + 1, AEnd - AStart);
  vBuffer := BytesOf(vS);
  if System.Length(vBuffer) > HC_TEXTMAXSIZE then
    raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
  vDSize := System.Length(vBuffer);
  AStream.WriteBuffer(vDSize, SizeOf(vDSize));
  if vDSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vDSize);
end;

procedure THCTextItem.SetText(const Value: string);
begin
  FText := Value;
end;

end.
