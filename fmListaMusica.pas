unit fmListaMusica;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BusinessSkinForm, bsSkinCtrls,
  bsdbctrls, Vcl.ExtCtrls, Vcl.DBCGrids,
  bsPngImageList, Vcl.StdCtrls;

type
  TfListaMusica = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    Panel1: TPanel;
    imgCapa: TImage;
    GridPanel1: TGridPanel;
    lblTitulo: TbsSkinStdLabel;
    lblSubtitulo: TbsSkinStdLabel;
    DBCtrlGrid: TDBCtrlGrid;
    Panel2: TPanel;
    GridPanel2: TGridPanel;
    bsSkinDBText1: TbsSkinDBText;
    ico: TbsPngImageView;
    bsSkinDBText2: TbsSkinDBText;
    Panel3: TPanel;
    pnlBotoes: TPanel;
    bsSkinSpeedButton6: TbsSkinSpeedButton;
    btExp_MenuMusicas: TbsSkinMenuSpeedButton;
    bsPngImageView1: TbsPngImageView;
    btSlidePB: TbsPngImageView;
    btMusica: TbsPngImageView;
    btMusicaPB: TbsPngImageView;
    btLetra: TbsPngImageView;
    btSlideLetra: TbsPngImageView;
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DBCtrlGridClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure bsSkinSpeedButton6Click(Sender: TObject);
    procedure btExp_MenuMusicasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBCtrlGridPaintPanel(DBCtrlGrid: TDBCtrlGrid; Index: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure btExp_MenuMusicasShowTrackMenu(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    id_album: integer;
    dir: string;
    inicio: Boolean;
  end;

var
  fListaMusica: TfListaMusica;

implementation

{$R *.dfm}

uses fmMenu, dmComponentes, fmMonitorMenuMusicas;

procedure TfListaMusica.bsSkinSpeedButton6Click(Sender: TObject);
begin
  fmIndex.abreLetraMusicaAlbum(DM.qrMUSICAS.FieldByName('ID_ALBUM').AsInteger);
end;

procedure TfListaMusica.btExp_MenuMusicasClick(Sender: TObject);
begin
  fmIndex.expandirArea(Sender);
end;

procedure TfListaMusica.btExp_MenuMusicasShowTrackMenu(Sender: TObject);
var
  tag: integer;
begin
  fmIndex.botao_trmenu := TbsSkinMenuSpeedButton(Sender);
  tag := fmIndex.botao_trmenu.tag;
  fmIndex.monitores(tag);
end;

procedure TfListaMusica.DBCtrlGridClick(Sender: TObject);
begin
  if DBCtrlGrid.DataSource = DM.dsMUSICAS
    then fmIndex.dbctrlMusicasClick(Sender)
    else fmIndex.abrirArquivo(DBCtrlGrid.DataSource.DataSet.FieldByName('DIR').AsString);
end;

procedure TfListaMusica.DBCtrlGridPaintPanel(DBCtrlGrid: TDBCtrlGrid;
  Index: Integer);
begin
  if DBCtrlGrid.DataSource <> DM.dsMUSICAS then Exit;

  if (DBCtrlGrid.DataSource.DataSet.FieldByName('URL_INSTRUMENTAL').AsString <> '') then
  begin
    btSlidePB.Visible := true;
    btMusicaPB.Visible := true;
    GridPanel2.ColumnCollection[4].Value := 40;
    GridPanel2.ColumnCollection[7].Value := 40;
  end
  else
  begin
    btSlidePB.Visible := false;
    btMusicaPB.Visible := false;
    GridPanel2.ColumnCollection[4].Value := 0;
    GridPanel2.ColumnCollection[7].Value := 0;
  end;
end;

procedure TfListaMusica.FormActivate(Sender: TObject);
var
  sr : TSearchRec;
  iRetorno : Integer;
  i: integer;
begin
  if (inicio <> true) then
  begin
    inicio := True;

    fmIndex.monitor_bt_label(btExp_MenuMusicas);

    bsPngImageView1.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);
    btSlidePB.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);
    btSlideLetra.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);
    btMusica.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);
    btMusicaPB.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);
    btLetra.Visible := (DBCtrlGrid.DataSource = DM.dsMUSICAS);

    if DBCtrlGrid.DataSource = DM.dsMUSICAS then
    begin
      DM.qrMUSICAS.Close;
      DM.qrMUSICAS.Parameters.ParamByName('ID_ALBUM').Value := id_album;
      DM.qrMUSICAS.Open;

      if (fMonitorMenuMusicas <> nil) then
      begin
        fmIndex.copiaDadosTelaExtendida();
      end;
    end
    else
    begin
      DBCtrlGrid.Visible := False;
      if not DM.cdsArquivos.Active then
      begin
        DM.cdsArquivos.CreateDataSet;
      end;
      DM.cdsArquivos.Open;
      DM.cdsArquivos.EmptyDataSet;

      dir := dir+'\';
      dir := StringReplace(dir,'\\','\',[rfIgnoreCase, rfReplaceAll]);

      if not(DirectoryExists(dir)) then
        Exit;

      iRetorno := FindFirst(dir + '*.*', faAnyFile, sr);
      i := 0;
      while iRetorno = 0 do
      begin
        if (sr.Name <> '.') and (sr.Name <> '..') then
          if sr.Attr <> faDirectory then
          begin
            i := i+1;
            DM.cdsArquivos.Append;
            DM.cdsArquivos.FieldByName('FAIXA').Value := i;
            DM.cdsArquivos.FieldByName('NOME').Value := ChangeFileExt(sr.Name,'');
            DM.cdsArquivos.FieldByName('DIR').Value := dir+sr.Name;
            DM.cdsArquivos.Post;
          end;
          iRetorno := FindNext(sr);
      end;
      FindClose(sr);
      DM.cdsArquivos.First;
      DBCtrlGrid.Visible := True;
    end;

    FormResize(Sender);
  end;
end;

procedure TfListaMusica.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  if (btExp_MenuMusicas.ImageIndex = 54)
  //  then btExp_MenuMusicasClick(btExp_MenuMusicas);
end;

procedure TfListaMusica.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  fmIndex.FormKeyUp(Sender, Key, Shift);
end;

procedure TfListaMusica.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  fmIndex.MouseWheel('Down', Sender, Shift, MousePos, Handled);
end;

procedure TfListaMusica.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  fmIndex.MouseWheel('Up', Sender, Shift, MousePos, Handled);
end;

procedure TfListaMusica.FormResize(Sender: TObject);
begin
  DBCtrlGrid.RowCount := Trunc(DBCtrlGrid.ClientHeight / 40);
end;

end.
