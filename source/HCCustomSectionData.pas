{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                �ĵ��ڶ����������Ԫ                 }
{                                                       }
{*******************************************************}

unit HCCustomSectionData;

interface

uses
  Classes, HCRichData;

type
  // �����ĵ�ҳü��ҳ�š�ҳ��Data���࣬��Ҫ���ڴ����ĵ���Data�仯ʱ���е����Ի��¼�
  // ��ֻ��״̬�л���ҳü��ҳ�š�ҳ���л�ʱ��Ҫ֪ͨ�ⲿ�ؼ���������ؼ�״̬�仯��
  // ����Ԫ��ֻ���л�ʱ����Ҫ
  THCCustomSectionData = class(THCRichData)
  private
    FOnReadOnlySwitch: TNotifyEvent;
  protected
    procedure SetReadOnly(const Value: Boolean); override;
  public
    property OnReadOnlySwitch: TNotifyEvent read FOnReadOnlySwitch write FOnReadOnlySwitch;
  end;

  THCHeaderData = class(THCCustomSectionData);

  THCFooterData = class(THCCustomSectionData);

implementation

{ THCCustomSectionData }

procedure THCCustomSectionData.SetReadOnly(const Value: Boolean);
begin
  if Self.ReadOnly <> Value then
  begin
    inherited SetReadOnly(Value);

    if Assigned(FOnReadOnlySwitch) then
      FOnReadOnlySwitch(Self);
  end;
end;

end.
