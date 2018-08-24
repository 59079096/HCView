unit frm_TableProperty;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HCView, HCTableItem, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmTableProperty = class(TForm)
    pgTable: TPageControl;
    tsTable: TTabSheet;
    tsRow: TTabSheet;
    tsCell: TTabSheet;
    edtCellHPadding: TEdit;
    edtCellVPadding: TEdit;
    edtBorderWidth: TEdit;
    chkBorderVisible: TCheckBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    pnl1: TPanel;
    btnOk: TButton;
    cbbRowAlignVert: TComboBox;
    lbl3: TLabel;
    lbl6: TLabel;
    edtRowHeight: TEdit;
    lbl7: TLabel;
    cbbCellAlignVert: TComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCellHPaddingChange(Sender: TObject);
  private
    { Private declarations }
    FReFormt: Boolean;
  public
    { Public declarations }
    procedure SetHCView(const AHCView: THCView);
  end;

var
  frmTableProperty: TfrmTableProperty;

implementation

uses
  HCCustomRichData, HCTableCell;

{$R *.dfm}

{ TfrmTableProperty }

procedure TfrmTableProperty.btnOkClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

procedure TfrmTableProperty.edtCellHPaddingChange(Sender: TObject);
begin
  FReFormt := True;
end;

procedure TfrmTableProperty.FormShow(Sender: TObject);
begin
  pgTable.ActivePageIndex := 0;
  FReFormt := False;
end;

procedure TfrmTableProperty.SetHCView(const AHCView: THCView);
var
  viValue{, vRowAlignIndex}: Integer;
  vTableItem: THCTableItem;
  vData: THCCustomRichData;
  vAlignVert: TAlignVert;
begin
  vData := AHCView.ActiveSection.ActiveData;
  vTableItem := vData.GetCurItem as THCTableItem;

  // ���
  edtCellHPadding.Text := IntToStr(vTableItem.CellHPadding);
  edtCellVPadding.Text := IntToStr(vTableItem.CellVPadding);
  chkBorderVisible.Checked := vTableItem.BorderVisible;
  edtBorderWidth.Text := IntToStr(vTableItem.BorderWidth);

  // ��
  tsRow.Caption := '��(' + IntToStr(vTableItem.SelectCellRang.StartRow + 1) + ')';
  edtRowHeight.Text := IntToStr(vTableItem.Rows[vTableItem.SelectCellRang.StartRow].Height);  // �и�

  {vAlignVert := vTableItem.GetEditCell.AlignVert;
  cbbRowAlignVert.ItemIndex := Ord(vAlignVert) + 1;
  for i := 0 to vTableItem.Rows[vTableItem.SelectCellRang.StartRow].ColCount - 1 do
  begin
    if vAlignVert <> vTableItem.Cells[vTableItem.SelectCellRang.StartRow, i].AlignVert then  // �в�ͬ
    begin
      cbbRowAlignVert.ItemIndex := 0;  // �Զ���
      Break;
    end;
  end;
  vRowAlignIndex := cbbRowAlignVert.ItemIndex;}

  // ��Ԫ��
  tsCell.Caption := '��Ԫ��(' + IntToStr(vTableItem.SelectCellRang.StartRow + 1) + ','
    + IntToStr(vTableItem.SelectCellRang.StartCol + 1) + ')';
  vAlignVert := vTableItem.GetEditCell.AlignVert;
  cbbCellAlignVert.ItemIndex := Ord(vAlignVert);

  //
  Self.ShowModal;
  if Self.ModalResult = mrOk then
  begin
    AHCView.BeginUpdate;
    try
      // ���
      vTableItem.CellHPadding := StrToIntDef(edtCellHPadding.Text, 5);
      vTableItem.CellVPadding := StrToIntDef(edtCellVPadding.Text, 0);
      vTableItem.BorderWidth := StrToIntDef(edtBorderWidth.Text, 1);
      vTableItem.BorderVisible := chkBorderVisible.Checked;

      // ��
      if TryStrToInt(edtRowHeight.Text, viValue) then
        vTableItem.Rows[vTableItem.SelectCellRang.StartRow].Height := viValue;  // �и�
      {if (cbbRowAlignVert.ItemIndex > 0) and (cbbRowAlignVert.ItemIndex <> vRowAlignIndex) then  // ��Ч������
      begin
        vAlignVert := TAlignVert(cbbRowAlignVert.ItemIndex - 1);
        for i := 0 to vTableItem.Rows[vTableItem.SelectCellRang.StartRow].ColCount - 1 do
          vTableItem.Cells[vTableItem.SelectCellRang.StartRow, i].AlignVert := vAlignVert;
      end;}

      // ��Ԫ��
      vTableItem.GetEditCell.AlignVert := TAlignVert(cbbCellAlignVert.ItemIndex);

      if FReFormt then
        AHCView.ActiveSection.ReFormatActiveItem;
    finally
      AHCView.EndUpdate;
    end;
  end;
end;

end.
