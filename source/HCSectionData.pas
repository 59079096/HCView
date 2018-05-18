{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                �ĵ��ڶ���߼�����Ԫ                 }
{                                                       }
{*******************************************************}

unit HCSectionData;

interface

uses
  Windows, Classes, Graphics, SysUtils, Controls, HCCustomRichData, HCCustomData,
  HCPage, HCItem, HCDrawItem, HCCommon, HCStyle, HCCustomSectionData,
  Generics.Collections, HCParaStyle, HCTextStyle, HCRichData;

type
  THCSectionData = class(THCCustomSectionData)  // ��������Ҫ������Ԫ��Data����Ҫ��������Ҫ�����Ի��¼�
  private
    FShowLineActiveMark: Boolean;  // ��ǰ�������ǰ��ʾ��ʶ
    FShowUnderLine: Boolean;  // �»���
    FShowLineNo: Boolean;  // �к�
    function GetPageDataFmtTop(const APageIndex: Integer): Integer;
  protected
    procedure DoDrawItemPaintBefor(const AData: THCCustomData; const ADrawItemIndex: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    {$IFDEF DEBUG}
    procedure DoDrawItemPaintAfter(const AData: THCCustomData; const ADrawItemIndex: Integer;
      const ADrawRect: TRect; const ADataDrawLeft, ADataDrawBottom, ADataScreenTop,
      ADataScreenBottom: Integer; const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    {$ENDIF}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SaveToStream(const AStream: TStream); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    function InsertStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word): Boolean; override;
  public
    constructor Create(const AStyle: THCStyle); override;

    /// <summary> �ӵ�ǰλ�ú��ҳ </summary>
    function InsertPageBreak: Boolean;
    //
    // ����
    function GetTextStr: string;
    procedure SaveToText(const AFileName: string; const AEncoding: TEncoding);
    procedure SaveToTextStream(const AStream: TStream; const AEncoding: TEncoding);
    // ��ȡ
    procedure LoadFromText(const AFileName: string; const AEncoding: TEncoding);
    procedure LoadFromTextStream(AStream: TStream; AEncoding: TEncoding);
    //
    property ShowLineActiveMark: Boolean read FShowLineActiveMark write FShowLineActiveMark;
    property ShowLineNo: Boolean read FShowLineNo write FShowLineNo;
    property ShowUnderLine: Boolean read FShowUnderLine write FShowUnderLine;
  end;

implementation

{$I HCView.inc}

uses
  Math, HCTextItem, HCRectItem, HCImageItem, HCTableItem, HCPageBreakItem;

{ THCSectionData }

constructor THCSectionData.Create(const AStyle: THCStyle);
begin
  inherited Create(AStyle);
  FShowLineActiveMark := False;
  FShowUnderLine := False;
  FShowLineNo := False;
end;

procedure THCSectionData.SaveToStream(const AStream: TStream);
begin
  AStream.WriteBuffer(FShowUnderLine, SizeOf(FShowUnderLine));
  inherited SaveToStream(AStream);
end;

procedure THCSectionData.SaveToText(const AFileName: string; const AEncoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToTextStream(Stream, AEncoding);
  finally
    Stream.Free;
  end;
end;

procedure THCSectionData.SaveToTextStream(const AStream: TStream; const AEncoding: TEncoding);
var
  Buffer, Preamble: TBytes;
begin
  Buffer := AEncoding.GetBytes(GetTextStr);
  Preamble := AEncoding.GetPreamble;
  if Length(Preamble) > 0 then
    AStream.WriteBuffer(Preamble[0], Length(Preamble));
  AStream.WriteBuffer(Buffer[0], Length(Buffer));
end;

{$IFDEF DEBUG}
procedure THCSectionData.DoDrawItemPaintAfter(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
begin
  inherited;
  {$IFDEF SHOWITEMNO}
  if ADrawItemIndex = Items[DrawItems[ADrawItemIndex].ItemNo].FirstDItemNo then  //
  {$ENDIF}
  begin
    {$IFDEF SHOWITEMNO}
    DrawDebugInfo(ACanvas, ADrawRect.Left, ADrawRect.Top - 12, IntToStr(DrawItems[ADrawItemIndex].ItemNo));
    {$ENDIF}

    {$IFDEF SHOWDRAWITEMNO}
    DrawDebugInfo(ACanvas, ADrawRect.Left, ADrawRect.Top - 12, IntToStr(ADrawItemIndex));
    {$ENDIF}
  end;
end;
{$ENDIF}

procedure THCSectionData.DoDrawItemPaintBefor(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vTop: Integer;
  vFont: TFont;
  i, vLineNo: Integer;
begin
  inherited DoDrawItemPaintBefor(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
  if not APaintInfo.Print then
  begin
    if FShowLineActiveMark then  // ������ָʾ��
    begin
      if ADrawItemIndex = GetSelectStartDrawItemNo then  // ��ѡ�е���ʼDrawItem
      begin
        ACanvas.Pen.Color := clBlue;
        ACanvas.Pen.Style := psSolid;
        vTop := ADrawRect.Top + DrawItems[ADrawItemIndex].Height div 2;

        ACanvas.MoveTo(ADataDrawLeft - 10, vTop);
        ACanvas.LineTo(ADataDrawLeft - 11, vTop);

        ACanvas.MoveTo(ADataDrawLeft - 11, vTop - 1);
        ACanvas.LineTo(ADataDrawLeft - 11, vTop + 2);
        ACanvas.MoveTo(ADataDrawLeft - 12, vTop - 2);
        ACanvas.LineTo(ADataDrawLeft - 12, vTop + 3);
        ACanvas.MoveTo(ADataDrawLeft - 13, vTop - 3);
        ACanvas.LineTo(ADataDrawLeft - 13, vTop + 4);
        ACanvas.MoveTo(ADataDrawLeft - 14, vTop - 4);
        ACanvas.LineTo(ADataDrawLeft - 14, vTop + 5);
        ACanvas.MoveTo(ADataDrawLeft - 15, vTop - 2);
        ACanvas.LineTo(ADataDrawLeft - 15, vTop + 3);
        ACanvas.MoveTo(ADataDrawLeft - 16, vTop - 2);
        ACanvas.LineTo(ADataDrawLeft - 16, vTop + 3);
      end;
    end;

    if FShowUnderLine then  // �»���
    begin
      if DrawItems[ADrawItemIndex].LineFirst then
      begin
        ACanvas.Pen.Color := clActiveBorder;
        ACanvas.Pen.Style := psSolid;
        ACanvas.MoveTo(ADataDrawLeft, ADrawRect.Bottom);
        ACanvas.LineTo(ADataDrawLeft + Self.Width, ADrawRect.Bottom);
      end;
    end;

    if FShowLineNo then  // �к�
    begin
      if DrawItems[ADrawItemIndex].LineFirst then
      begin
        vLineNo := 0;
        for i := 0 to ADrawItemIndex do
        begin
          if DrawItems[i].LineFirst then
            Inc(vLineNo);
        end;

        vFont := TFont.Create;
        try
          vFont.Assign(ACanvas.Font);
          ACanvas.Font.Color := RGB(180, 180, 180);
          ACanvas.Font.Size := 10;
          ACanvas.Font.Style := [];
          ACanvas.Font.Name := 'Courier New';
          //SetTextColor(ACanvas.Handle, RGB(180, 180, 180));
          ACanvas.Brush.Style := bsClear;
          vTop := ADrawRect.Top + (ADrawRect.Bottom - ADrawRect.Top - 16) div 2;
          ACanvas.TextOut(ADataDrawLeft - 50, vTop, IntToStr(vLineNo));
        finally
          ACanvas.Font.Assign(vFont);
          FreeAndNil(vFont);
        end;
      end;
    end;
  end;
end;

function THCSectionData.GetTextStr: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Items.Count - 1 do
    Result := Result + Items[i].Text;
end;

function THCSectionData.InsertPageBreak: Boolean;
var
  vPageBreak: TPageBreakItem;
  vKey: Word;
begin
  Result := False;

  vPageBreak := TPageBreakItem.Create(Self);
  vPageBreak.ParaFirst := True;
  // ��һ��Item�ֵ���һҳ��ǰһҳû���κ�Item���Ա༭����಻����������ǰһҳ����һ����Item
  if (SelectInfo.StartItemNo = 0) and (SelectInfo.StartItemOffset = 0) then
  begin
    vKey := VK_RETURN;
    KeyDown(vKey, []);
  end;

  Result := Self.InsertItem(vPageBreak);
end;

function THCSectionData.InsertStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word): Boolean;
begin
  // ��Ϊ����ճ��ʱ������ҪFShowUnderLine��Ϊ����ճ������FShowUnderLine��LoadFromStremʱ����
  //AStream.ReadBuffer(FShowUnderLine, SizeOf(FShowUnderLine));
  inherited InsertStream(AStream, AStyle, AFileVersion);
end;

procedure THCSectionData.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
begin
  AStream.ReadBuffer(FShowUnderLine, SizeOf(FShowUnderLine));
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
end;

function THCSectionData.GetPageDataFmtTop(const APageIndex: Integer): Integer;
//var
//  i, vContentHeight: Integer;
begin
//  Result := 0;
//  if APageIndex > 0 then
//  begin
//    vContentHeight := FPageSize.PageHeightPix  // ��ҳ����������߶ȣ���ҳ���ҳü��ҳ�ź󾻸�
//      - FPageSize.PageMarginBottomPix - GetHeaderAreaHeight;
//
//    for i := 0 to APageIndex - 1 do
//      Result := Result + vContentHeight;
//  end;
end;

procedure THCSectionData.LoadFromText(const AFileName: string; const AEncoding: TEncoding);
var
  vStream: TStream;
  vFileFormat: string;
begin
  vStream := TFileStream.Create(AFileName, fmOpenRead or fmShareExclusive);  // ֻ���򿪡������������������κη�ʽ��
  try
    vFileFormat := ExtractFileExt(AFileName);
    vFileFormat := LowerCase(vFileFormat);
    if vFileFormat = '.txt' then
      LoadFromTextStream(vStream, AEncoding);
  finally
    vStream.Free;
  end;
end;

procedure THCSectionData.LoadFromTextStream(AStream: TStream; AEncoding: TEncoding);
var
  vSize: Integer;
  vBuffer: TBytes;
  vS: string;
begin
  Clear;
  vSize := AStream.Size - AStream.Position;
  SetLength(vBuffer, vSize);
  AStream.Read(vBuffer[0], vSize);
  vSize := TEncoding.GetBufferEncoding(vBuffer, AEncoding);
  vS := AEncoding.GetString(vBuffer, vSize, Length(vBuffer) - vSize);
  if vS <> '' then
    InsertText(vS);
end;

procedure THCSectionData.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vMouseDownItemNo, vMouseDownItemOffset: Integer;
begin
  if FShowLineActiveMark then  // ��ʾ��ǰ�༭��
  begin
    vMouseDownItemNo := Self.MouseDownItemNo;
    vMouseDownItemOffset := Self.MouseDownItemOffset;
    inherited MouseDown(Button, Shift, X, Y);
    if (vMouseDownItemNo <> Self.MouseDownItemNo) or (vMouseDownItemOffset <> Self.MouseDownItemOffset) then
      Style.UpdateInfoRePaint;
  end
  else
    inherited MouseDown(Button, Shift, X, Y);
end;

end.
