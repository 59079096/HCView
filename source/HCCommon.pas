{*******************************************************}
{                                                       }
{               HCView V1.1  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  HCView���빫����Ԫ                   }
{                                                       }
{*******************************************************}

unit HCCommon;

interface

uses
  Windows, Controls, Classes, Graphics, HCStyle;

const
  HC_TEXTMAXSIZE = 4294967295;
  HC_EXCEPTION = 'HC�쳣��';
  HCS_EXCEPTION_NULLTEXT = HC_EXCEPTION + '�ı�Item�����ݳ���Ϊ�յ������';
  HCS_EXCEPTION_TEXTOVER = HC_EXCEPTION + 'TextItem�����ݳ������������ֽ���4294967295��';
  HCS_EXCEPTION_MEMORYLESS = HC_EXCEPTION + '����ʱû�����뵽�㹻���ڴ棡';
  //HCS_EXCEPTION_UNACCEPTDATATYPE = HC_EXCEPTION + '���ɽ��ܵ��������ͣ�';
  HCS_EXCEPTION_STRINGLENGTHLIMIT = HC_EXCEPTION + '�˰汾��֧��������������ʽ�ַ�������65535��';

  HC_EXT = '.hcf';

  // 1.3 ֧�ָ������󱣴�Ͷ�ȡ(δ�������¼���)
  // 1.4 ֧�ֱ��Ԫ��߿���ʾ���Եı���Ͷ�ȡ
  // 1.5 �ع��м��ļ��㷽ʽ
  // 1.6 EditItem���ӱ߿�����
  // 1.7 �������ع�����м��Ĵ洢
  HC_FileVersion = '1.7';
  HC_FileVersionInt = 17;

  LineSpaceMin = 8;  // �м����Сֵ
  PagePadding = 20;  // ��ҳ����ʾʱ֮��ļ��
  PMSLineHeight = 24;  // ��д��Χ�ߵĳ���
  AnnotationWidth = 200;  // ��ע��ʾ������
  // ���������׵��ַ�             |                    |                   |
  DontLineFirstChar = '`-=[]\;'',./~!@#$%^&*()_+{}|:"<>?�����������ܣ���������������������������������������������������������';
  DontLineLastChar = '/\��';

type
  THCProcedure = reference to procedure();
  THCFunction = reference to function(): Boolean;

  TPageOrientation = (cpoPortrait, cpoLandscape);  // ֽ�ŷ������񡢺���

  TExpressArea = (ceaNone, ceaLeft, ceaTop, ceaRight, ceaBottom);  // ��ʽ�����򣬽��������������Ҹ�ʽ��

  TBorderSide = (cbsLeft, cbsTop, cbsRight, cbsBottom, cbsLTRB, cbsRTLB);
  TBorderSides = set of TBorderSide;

  TViewModel = (
    vmPage,  // ҳ����ͼ����ʾҳü��ҳ��
    vmWeb  // Web��ͼ������ʾҳü��ҳ��
  );

  TSectionArea = (saHeader, saPage, saFooter);  // ��ǰ��������ĵ���һ����
  TSaveParts = set of TSectionArea;  // ����ʱ���ļ���������

  TCharType = (
    jctBreak,  //  �ضϵ�
    jctHZ,  // ����
    jctZM,  // �����ĸ
    //jctCNZM,  // ȫ����ĸ
    jctSZ,  // �������
    //jctCNSZ,  // ȫ������
    jctFH  // ��Ƿ���
    //jctCNFH   // ȫ�Ƿ���
    );

  TPaperSize = (psCustom, ps4A0, ps2A0, psA0, psA1, psA2,
    psA3, psA4, psA5, psA6, psA7, psA8,
    psA9, psA10, psB0, psB1, psB2, psB3,
    psB4, psB5, psB6, psB7, psB8, psB9,
    psB10, psC0, psC1, psC2, psC3, psC4,
    psC5, psC6, psC7, psC8, psC9, psC10,
    psLetter, psLegal, psLedger, psTabloid,
    psStatement, psQuarto, psFoolscap, psFolio,
    psExecutive, psMonarch, psGovernmentLetter,
    psPost, psCrown, psLargePost, psDemy,
    psMedium, psRoyal, psElephant, psDoubleDemy,
    psQuadDemy, psIndexCard3_5, psIndexCard4_6,
    psIndexCard5_8, psInternationalBusinessCard,
    psUSBusinessCard, psEmperor, psAntiquarian,
    psGrandEagle, psDoubleElephant, psAtlas,
    psColombier, psImperial, psDoubleLargePost,
    psPrincess, psCartridge, psSheet, psHalfPost,
    psDoublePost, psSuperRoyal, psCopyDraught,
    psPinchedPost, psSmallFoolscap, psBrief, psPott,
    psPA0, psPA1, psPA2, psPA3, psPA4, psPA5,
    psPA6, psPA7, psPA8, psPA9, psPA10, psF4,
    psA0a, psJISB0, psJISB1, psJISB2, psJISB3,
    psJISB4, psJISB5, psJISB6, psJISB7, psJISB8,
    psJISB9, psJISB10, psJISB11, psJISB12,
    psANSI_A, psANSI_B, psANSI_C, psANSI_D,
    psANSI_E, psArch_A, psArch_B, psArch_C,
    psArch_D, psArch_E, psArch_E1,
    ps16K, ps32K);

  TCaretInfo = record
    X, Y, Height, PageIndex: Integer;
    Visible: Boolean;
  end;

  TMarkType = (cmtBeg, cmtEnd);

  TCaret = Class(TObject)
  private
    FHeight: Integer;
    FOwnHandle: THandle;
  protected
    procedure SetHeight(const Value: Integer);
  public
    X, Y: Integer;
    //Visible: Boolean;
    constructor Create(const AHandle: THandle);
    destructor Destroy; override;
    procedure ReCreate;
    procedure Show(const AX, AY: Integer); overload;
    procedure Show; overload;
    procedure Hide;
    property Height: Integer read FHeight write SetHeight;
  end;

  function IsKeyPressWant(const AKey: Char): Boolean;
  function IsKeyDownWant(const AKey: Word): Boolean;

  /// <summary> Ч�ʸ��ߵķ����ַ����ַ���λ�ú��� </summary>
  function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;

  /// <summary> �����ַ����� </summary>
  function GetCharType(const AChar: Word): TCharType;

  /// <summary>
  /// ����ָ��λ�����ַ����ĸ��ַ�����(0����һ��ǰ��)
  /// </summary>
  /// <param name="ACanvas"></param>
  /// <param name="AText"></param>
  /// <param name="X"></param>
  /// <returns></returns>
  function GetCharOffsetByX(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;

  // ���ݺ��ִ�С��ȡ�������ִ�С
  function GetFontSize(const AFontSize: string): Single;
  function GetFontSizeStr(AFontSize: Single): string;
  function GetPaperSizeStr(APaperSize: Integer): string;

  function GetVersionAsInteger(const AVersion: string): Integer;

  /// <summary> �����ļ���ʽ���汾 </summary>
  procedure _SaveFileFormatAndVersion(const AStream: TStream);
  /// <summary> ��ȡ�ļ���ʽ���汾 </summary>
  procedure _LoadFileFormatAndVersion(const AStream: TStream; var AFileFormat, AVersion: string);

  {$IFDEF DEBUG}
  procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
  {$ENDIF}

var
  GCursor: TCursor;
  HC_FILEFORMAT: Word;

implementation

uses
  SysUtils;

{$IFDEF DEBUG}
procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
var
  vFont: TFont;
begin
  vFont := TFont.Create;
  try
    vFont.Assign(ACanvas.Font);
    ACanvas.Font.Color := clGray;
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [];
    ACanvas.Font.Name := 'Courier New';
    ACanvas.Brush.Style := bsClear;

    ACanvas.TextOut(ALeft, ATop, AInfo);
  finally
    ACanvas.Font.Assign(vFont);
    FreeAndNil(vFont);
  end;
end;
{$ENDIF}

function GetCharType(const AChar: Word): TCharType;
begin
  case AChar of
    $4E00..$9FA5: Result := jctHZ;  // ����

    $21..$2F,  // !"#$%&'()*+,-./
    $3A..$40,  // :;<=>?@
    $5B..$60,  // [\]^_`
    $7B..$7E   // {|}~
      : Result := jctFH;

    //$FF01..$FF0F,  // ������������������������������

    $30..$39: Result := jctSZ;  // 0..9

    $41..$5A, $61..$7A: Result := jctZM;  // A..Z, a..z
  else
    Result := jctBreak;
  end;
end;

function IsKeyPressWant(const AKey: Char): Boolean;
begin
  Result := AKey in [#32..#126];  // <#32��ASCII������ #127��ASCII DEL
end;

function IsKeyDownWant(const AKey: Word): Boolean;
begin
  Result := AKey in [VK_BACK, VK_DELETE, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN,
    VK_HOME, VK_END, VK_TAB];
end;

function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AStr) do
  begin
    if AChar = AStr[i] then
    begin
      Result := i;
      Exit
    end;
  end;
end;

function GetFontSize(const AFontSize: string): Single;
begin
  if AFontSize = '����' then Result := 42
  else
  if AFontSize = 'С��' then Result := 36
  else
  if AFontSize = 'һ��' then Result := 26
  else
  if AFontSize = 'Сһ' then Result := 24
  else
  if AFontSize = '����' then Result := 22
  else
  if AFontSize = 'С��' then Result := 18
  else
  if AFontSize = '����' then Result := 16
  else
  if AFontSize = 'С��' then Result := 15
  else
  if AFontSize = '�ĺ�' then Result := 14
  else
  if AFontSize = 'С��' then Result := 12
  else
  if AFontSize = '���' then Result := 10.5
  else
  if AFontSize = 'С��' then Result := 9
  else
  if AFontSize = '����' then Result := 7.5
  else
  if AFontSize = 'С��' then Result := 6.5
  else
  if AFontSize = '�ߺ�' then Result := 5.5
  else
  if AFontSize = '�˺�' then Result := 5
  else
  if not TryStrToFloat(AFontSize, Result) then
    raise Exception.Create(HC_EXCEPTION + '�����ֺŴ�С�����޷�ʶ���ֵ��' + AFontSize);
end;

function GetFontSizeStr(AFontSize: Single): string;
begin
  if AFontSize = 42 then Result := '����'
  else
  if AFontSize = 36 then Result := 'С��'
  else
  if AFontSize = 26 then Result := 'һ��'
  else
  if AFontSize = 24 then Result := 'Сһ'
  else
  if AFontSize = 22 then Result := '����'
  else
  if AFontSize = 18 then Result := 'С��'
  else
  if AFontSize = 16 then Result := '����'
  else
  if AFontSize = 15 then Result := 'С��'
  else
  if AFontSize = 14 then Result := '�ĺ�'
  else
  if AFontSize = 12 then Result := 'С��'
  else
  if AFontSize = 10.5 then Result := '���'
  else
  if AFontSize = 9 then Result := 'С��'
  else
  if AFontSize = 7.5 then Result := '����'
  else
  if AFontSize = 6.5 then Result := 'С��'
  else
  if AFontSize = 5.5 then Result := '�ߺ�'
  else
  if AFontSize = 5 then Result := '�˺�'
  else
    Result := FormatFloat('#.#', AFontSize);
end;

function GetPaperSizeStr(APaperSize: Integer): string;
begin
  case APaperSize of
    DMPAPER_A3: Result := 'A3';
    DMPAPER_A4: Result := 'A4';
    DMPAPER_A5: Result := 'A5';
    DMPAPER_B5: Result := 'B5';
  else
    Result := '�Զ���';
  end;
end;

function GetVersionAsInteger(const AVersion: string): Integer;
var
  vsVer: string;
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AVersion) do
  begin
    if AVersion[i] in ['0'..'9'] then
      vsVer := vsVer + AVersion[i];
  end;
  Result := vsVer.ToInteger;
end;

/// <summary> �����ļ���ʽ���汾 </summary>
procedure _SaveFileFormatAndVersion(const AStream: TStream);
var
  vS: string;
begin
  vS := HC_EXT;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
  // �汾
  vS := HC_FileVersion;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
end;

/// <summary> ��ȡ�ļ���ʽ���汾 </summary>
procedure _LoadFileFormatAndVersion(const AStream: TStream; var AFileFormat, AVersion: string);
begin
  // �ļ���ʽ
  SetLength(AFileFormat, Length(HC_EXT));
  AStream.ReadBuffer(AFileFormat[1], Length(HC_EXT) * SizeOf(Char));

  // �汾
  SetLength(AVersion, Length(HC_FileVersion));
  AStream.ReadBuffer(AVersion[1], Length(HC_FileVersion) * SizeOf(Char));
end;

function GetCharOffsetByX(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;
var
  i, vX, vCharWidth: Integer;
begin
  Result := -1;

  if X < 0 then
    Result := 0
  else
  if X > ACanvas.TextWidth(AText) then
    Result := Length(AText)
  else
  begin
    vX := 0;
    for i := 1 to Length(AText) do  { TODO : �пո�Ϊ���ַ�����Ч }
    begin
      vCharWidth := ACanvas.TextWidth(AText[i]);
      vX := vX + vCharWidth;
      if vX > X then  // ��ǰ�ַ�����λ����X��
      begin
        if vX - vCharWidth div 2 > X then  // �����ǰ�벿��
          Result := i - 1  // ��Ϊǰһ������
        else
          Result := i;
        Break;
      end;
    end;
  end;
end;

{ TCaret }

constructor TCaret.Create(const AHandle: THandle);
begin
  FOwnHandle := AHandle;
  CreateCaret(FOwnHandle, 0, 2, 20);
end;

destructor TCaret.Destroy;
begin
  DestroyCaret;
  FOwnHandle := 0;
  inherited;
end;

procedure TCaret.Hide;
begin
  HideCaret(FOwnHandle);
end;

procedure TCaret.ReCreate;
begin
  DestroyCaret;
  CreateCaret(FOwnHandle, 0, 2, FHeight);
end;

procedure TCaret.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    ReCreate;
  end;
end;

procedure TCaret.Show;
begin
  Show(X, Y);
end;


procedure TCaret.Show(const AX, AY: Integer);
begin
  ReCreate;
  SetCaretPos(AX, AY);
  ShowCaret(FOwnHandle);
end;

initialization
  if HC_FILEFORMAT = 0 then
    HC_FILEFORMAT := RegisterClipboardFormat(HC_EXT);

end.
