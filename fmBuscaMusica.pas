unit fmBuscaMusica;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BusinessSkinForm, Data.DB,
  Data.Win.ADODB, bsSkinCtrls, bsDBGrids, Vcl.Mask,
  bsSkinBoxCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, bsSkinGrids, Vcl.StdCtrls;

type
  TfBuscaMusica = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    GridPanel3: TGridPanel;
    txtBusca: TbsSkinEdit;
    bsSkinStdLabel5: TbsSkinStdLabel;
    DBGrid1: TbsSkinDBGrid;
    qrBUSCA: TADOQuery;
    dsBUSCA: TDataSource;
    stBusca: TbsSkinStatusBar;
    bsSkinScrollBar7: TbsSkinScrollBar;
    stBusca_0: TbsSkinStatusPanel;
    stBusca_1: TbsSkinStatusPanel;
    procedure txtBuscaChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure txtBuscaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure txtBuscaKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    id: integer;
  end;

var
  fBuscaMusica: TfBuscaMusica;

implementation

{$R *.dfm}

uses fmMenu;

procedure TfBuscaMusica.DBGrid1DblClick(Sender: TObject);
begin
  id := qrBUSCA.FieldByName('ID').AsInteger;
  close;
end;

procedure TfBuscaMusica.FormActivate(Sender: TObject);
begin
  id := -1;
  txtBusca.Text := '';
  txtBuscaChange(Sender);
end;

procedure TfBuscaMusica.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  fmIndex.FormKeyUp(Sender, Key, Shift);
end;

procedure TfBuscaMusica.FormResize(Sender: TObject);
begin
  dbGrid1.Columns[1].Width := dbGrid1.Width - dbGrid1.Columns[0].Width;
end;

procedure TfBuscaMusica.txtBuscaChange(Sender: TObject);
var
  valor: string;
  nr: integer;
  c: integer;
  filtro: string;
begin
  filtro := '';

  dbGrid1.Columns[1].Width := dbGrid1.Width - dbGrid1.Columns[0].Width;
  valor := trim(txtBusca.Text);
  stBusca_0.caption := '';
  if trim(valor) <> '' then
  begin
    val(txtBusca.Text, nr, c);
    if c = 0 then
    begin
      filtro := ' AND TIPO_HASD = ''S'' AND FAIXA = ' + valor;
      stBusca_0.caption := 'Buscando hino n�: ' + valor;
    end
    else
    begin
      filtro := ' AND NOME LIKE ''%' + fmIndex.termo_busca(valor) + '%''';
      stBusca_0.caption := 'Buscando m�sica nome: ''' + valor + '''';
    end;
  end;

  qrBUSCA.Close;
  qrBUSCA.SQL.Clear;
  qrBUSCA.SQL.Add('SELECT DISTINCT ID,FAIXA,NOME_ALBUM_COM,NOME,TIPO_HASD FROM LISTA_MUSICAS');
  qrBUSCA.SQL.Add(' WHERE 1=1 ');
  qrBUSCA.SQL.Add(filtro);
  qrBUSCA.SQL.Add(' ORDER BY NOME');
  qrBUSCA.Open;

  stBusca_1.caption := fmIndex.qtItens(qrBUSCA,'m�sica encontrada','m�sicas encontrados','Nenhuma m�sica encontrado');
  fmIndex.corCampoBusca(qrBUSCA, txtBusca,DBGrid1);
  dbGrid1.Columns[1].Width := dbGrid1.Width - dbGrid1.Columns[0].Width;
end;

procedure TfBuscaMusica.txtBuscaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    DBGrid1DblClick(Sender);
  end;
end;

procedure TfBuscaMusica.txtBuscaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  fmIndex.edtKeyUp(Sender,Key,Shift);
end;

end.
