object fIdentificaMonitores: TfIdentificaMonitores
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'fIdentificaMonitores'
  ClientHeight = 300
  ClientWidth = 400
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object rotulo: TLabel
    Left = 0
    Top = 0
    Width = 400
    Height = 300
    Align = alClient
    Alignment = taCenter
    AutoSize = False
    Caption = '0'
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -200
    Font.Name = 'Arial Rounded MT Bold'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    Layout = tlCenter
    ExplicitLeft = -137
    ExplicitTop = -160
    ExplicitWidth = 600
    ExplicitHeight = 400
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 312
    Top = 128
  end
end
