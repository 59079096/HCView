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

unit HCControlItem;

interface

uses
  Windows, Classes, Controls, Graphics, HCStyle, HCRectItem, HCItem, HCCustomData;

type
  THCControlItem = class(THCCustomRectItem)
  private
    FControl: TControl;
  public
    constructor Create(const AOwnerData: THCCustomData); overload; override;
  end;

implementation

{ THCControlItem }

constructor THCControlItem.Create(const AOwnerData: THCCustomData);
begin
  inherited Create(AOwnerData);
  Self.StyleNo := THCStyle.Control;
end;

end.
