object sePNGEditorForm: TsePNGEditorForm
  Left = 412
  Top = 324
  BorderStyle = bsDialog
  Caption = 'PngImage Editor'
  ClientHeight = 266
  ClientWidth = 355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 96
    Top = 8
    Width = 249
    Height = 249
    OnPaint = PaintBox1Paint
  end
  object Label1: TLabel
    Left = 8
    Top = 160
    Width = 3
    Height = 13
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 81
    Height = 25
    Caption = 'Load...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 40
    Width = 81
    Height = 25
    Caption = 'Clear'
    TabOrder = 1
    OnClick = Button2Click
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 88
    Width = 81
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = BitBtn1Click
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object BitBtn2: TBitBtn
    Left = 8
    Top = 120
    Width = 81
    Height = 25
    TabOrder = 3
    OnClick = BitBtn2Click
    Kind = bkCancel
  end
  object OD: TOpenDialog
    DefaultExt = 'png'
    Filter = 'PNG image|*.png'
    Left = 16
    Top = 16
  end
end
