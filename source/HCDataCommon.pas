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

unit HCDataCommon;

interface

uses
  HCCustomData;

type
  TTraverseItemEvent = procedure(const AData: THCCustomData;
    const AItemNo, ATag: Integer; var AStop: Boolean) of object;

  TItemTraverse = class(TObject)
  public
    Tag: Integer;
    Stop: Boolean;
    Process: TTraverseItemEvent;
  end;

implementation

end.
