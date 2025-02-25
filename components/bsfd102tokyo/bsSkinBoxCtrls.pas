{*******************************************************************}
{                                                                   }
{       Almediadev Visual Component Library                         }
{       BusinessSkinForm                                            }
{       Version 11.51                                               }
{                                                                   }
{       Copyright (c) 2000-2016 Almediadev                          }
{       ALL RIGHTS RESERVED                                         }     
{                                                                   }
{       Home:  http://www.almdev.com                                }
{       Support: support@almdev.com                                 }
{                                                                   }
{*******************************************************************}
                                             
unit bsSkinBoxCtrls;

{$I bsdefine.inc}

{$P+,S-,W-,R-}
{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, bsSkinData, StdCtrls, bsSkinCtrls, CommCtrl, ComCtrls, Mask,
  ImgList, bsCalendar, Clipbrd, bsSkinMenus, bsUtils, bsEffects;

const
   // Billenium Effects messages
   BE_ID           = $41A2;
   BE_BASE         = CM_BASE + $0C4A;
   CM_BEPAINT      = BE_BASE + 0; // Paint client area to Billenium Effects' DC
   CM_BENCPAINT    = BE_BASE + 1; // Paint non client area to Billenium Effects' DC
   CM_BEFULLRENDER = BE_BASE + 2; // Paint whole control to Billenium Effects' DC
   CM_BEWAIT       = BE_BASE + 3; // Don't execute effect yet
   CM_BERUN        = BE_BASE + 4; // Execute effect now!

type
  TbsDrawSkinItemEvent = procedure(Cnvs: TCanvas; Index: Integer;
    ItemWidth, ItemHeight: Integer; TxtRect: TRect; State: TOwnerDrawState) of object;

  TbsCBButtonX = record
    R: TRect;
    MouseIn: Boolean;
    Down: Boolean;
  end;

  TbsOnEditCancelMode = procedure(C: TControl) of object;

  TbsCustomEdit = class(TCustomMaskEdit)
  protected
    FOnMouseEnter, FOnMouseLeave: TNotifyEvent;
    FOnUp: TNotifyEvent;
    FOnDown: TNotifyEvent;
    FOnKillFocus: TNotifyEvent;
    FOnEditCancelMode: TbsOnEditCancelMode;
    FDown: Boolean;
    FReadOnly: Boolean;
    FEditTransparent: Boolean;
    FSysPopupMenu: TbsSkinPopupMenu;
    FStopDraw: Boolean;
    procedure DoUndo(Sender: TObject);
    procedure DoCut(Sender: TObject);
    procedure DoCopy(Sender: TObject);
    procedure DoPaste(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoSelectAll(Sender: TObject);
    procedure CreateSysPopupMenu;
    procedure SetEditTransparent(Value: Boolean);
    procedure DoPaint; virtual;
    procedure DoPaint2(DC: HDC); virtual;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMAFTERDISPATCH(var Message: TMessage); message WM_AFTERDISPATCH;
    procedure WMCONTEXTMENU(var Message: TWMCONTEXTMENU); message WM_CONTEXTMENU;
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CNCtlColorEdit(var Message:TWMCTLCOLOREDIT); message  CN_CTLCOLOREDIT;
    procedure CNCtlColorStatic(var Message:TWMCTLCOLORSTATIC); message  CN_CTLCOLORSTATIC;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Change; override;
    procedure WMCHAR(var Message:TWMCHAR); message WM_CHAR;
    procedure WMSetText(var Message:TWMSetText); message WM_SETTEXT;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMMove(var Message: TMessage); message WM_MOVE;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMUndo(var Message: TMessage); message WM_UNDO;
    procedure WMLButtonDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TMessage); message WM_LBUTTONUP;
    procedure WMMOUSEMOVE(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure WMSize(var Message: TWMSIZE); message WM_SIZE;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ReadOnly read FReadOnly write FReadOnly;
    property EditTransparent: Boolean read FEditTransparent write SetEditTransparent;
    property OnUp: TNotifyEvent read FOnUp write FOnUp;
    property OnDown: TNotifyEvent read FOnDown write FOnDown;
    property OnEditCancelMode: TbsOnEditCancelMode
      read FOnEditCancelMode write FOnEditCancelMode;
  published
    property EditMask;
    property Text;
  end;

  TbsSkinNumEdit = class(TbsCustomEdit)
  protected
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    FEditorEnabled: Boolean;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    function IsValidChar(Key: Char): Boolean;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    Float: Boolean;
    constructor Create(AOwner: TComponent);
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TbsSkinCustomEdit = class(TbsCustomEdit)
  protected
    LeftButton, RightButton: TbsCBButtonX;
    FDefaultColor: TColor;
    FOnButtonClick: TNotifyEvent;
    FButtonRect: TRect;
    FButtonMode: Boolean;
    FButtonDown: Boolean;
    FButtonActive: Boolean;
    FEditRect: TRect;
    FMouseIn: Boolean;
    FIndex: Integer;
    FSD: TbsSkinData;
    FSkinDataName: String;
    Picture: TBitMap;
    FOnMouseEnter, FOnMouseLeave: TNotifyEvent;
    FDefaultFont: TFont;
    FUseSkinFont: Boolean;
    FDefaultWidth: Integer;
    FDefaultHeight: Integer;
    FAlignment: TAlignment;
    //
    FImages: TCustomImageList;
    FLeftImageIndex: Integer;
    FLeftImageHotIndex: Integer;
    FLeftImageDownIndex: Integer;
    FRightImageIndex: Integer;
    FRightImageHotIndex: Integer;
    FRightImageDownIndex: Integer;
    FButtonImageIndex: Integer;
    FOnLeftButtonClick: TNotifyEvent;
    FOnRightButtonClick: TNotifyEvent;
    function CheckActivation: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetDefaultWidth(Value: Integer);
    procedure SetDefaultHeight(Value: Integer);
    procedure OnDefaultFontChange(Sender: TObject);
    procedure SetDefaultFont(Value: TFont);
    procedure CalcRects;
    procedure SetButtonMode(Value: Boolean);
    procedure SetSkinData(Value: TbsSkinData); virtual;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure GetSkinData;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMNCPAINT(var Message: TMessage); message WM_NCPAINT;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure CMBENCPaint(var Message: TMessage); message CM_BENCPAINT;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
    procedure WMNCLBUTTONDOWN(var Message: TWMNCLBUTTONDOWN); message WM_NCLBUTTONDOWN;
    procedure WMNCLBUTTONDBCLK(var Message: TWMNCLBUTTONDOWN); message WM_NCLBUTTONDBLCLK;
    procedure WMNCLBUTTONUP(var Message: TWMNCLBUTTONUP); message WM_NCLBUTTONUP;
    procedure WMNCMOUSEMOVE(var Message: TWMNCMOUSEMOVE); message WM_NCMOUSEMOVE;
    procedure WMMOUSEMOVE(var Message: TWMNCMOUSEMOVE); message WM_MOUSEMOVE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
    procedure WMDESTROY(var Message: TMessage); message WM_DESTROY;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure CMMouseEnter;
    procedure CMMouseLeave;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure Loaded; override;
    procedure AdjustEditHeight;
    procedure CalcEditHeight(var AHeight: Integer);
    procedure CreateWnd; override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure InvalidateNC;
    procedure DrawSkinEdit(C: TCanvas; ADrawText: Boolean; AText: String);
    procedure DrawSkinEdit2(C: TCanvas; ADrawText: Boolean; AText: String);
    procedure DrawEditBackGround(C: TCanvas);
    procedure PaintSkinTo1(C: TCanvas; X, Y: Integer; AText: String);
    procedure PaintSkinTo2(C: TCanvas; X, Y: Integer; AText: String);
    procedure SetDefaultColor(Value: TColor);
    procedure DrawResizeButton(C: TCanvas; ButtonR: TRect);
    //
    procedure SetImages(Value: TCustomImageList);
    procedure SetButtonImageIndex(Value: Integer);
    procedure SetLeftImageIndex(Value: Integer);
    procedure SetLeftImageHotIndex(Value: Integer);
    procedure SetLeftImageDownIndex(Value: Integer);
    procedure SetRightImageIndex(Value: Integer);
    procedure SetRightImageHotIndex(Value: Integer);
    procedure SetRightImageDownIndex(Value: Integer);
    procedure AdjustTextRect(Update: Boolean);
    procedure DrawButtonImages(C: TCanvas);
    procedure DoPaint; override;
  public
    //
    LOffset, ROffset: Integer;
    ClRect: TRect;
    SkinRect, ActiveSkinRect: TRect;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    FontColor, DisabledFontColor: TColor;
    ActiveFontColor: TColor;
    ButtonRect: TRect;
    ActiveButtonRect: TRect;
    DownButtonRect: TRect;
    UnEnabledButtonRect: TRect;
    StretchEffect: Boolean;
    //
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData; virtual;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property BorderStyle;

    procedure PaintSkinTo(C: TCanvas; X, Y: Integer; AText: String);
    //
    property Images: TCustomImageList read FImages write SetImages;
    property ButtonImageIndex: Integer
      read FButtonImageIndex write SetButtonImageIndex;
    property LeftImageIndex: Integer
      read FLeftImageIndex write SetLeftImageIndex;
    property LeftImageHotIndex: Integer
      read FLeftImageHotIndex write SetLeftImageHotIndex;
    property LeftImageDownIndex: Integer
      read FLeftImageDownIndex write SetLeftImageDownIndex;
    property RightImageIndex: Integer
      read FRightImageIndex write SetRightImageIndex;
    property RightImageHotIndex: Integer
      read FRightImageHotIndex write SetRightImageHotIndex;
    property RightImageDownIndex: Integer 
      read FRightImageDownIndex write SetRightImageDownIndex;
    //
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor;
    property DefaultFont: TFont read FDefaultFont write SetDefaultFont;
    property UseSkinFont: Boolean read FUseSkinFont write FUseSkinFont;
    property DefaultWidth: Integer read FDefaultWidth write SetDefaultWidth;
    property DefaultHeight: Integer read FDefaultHeight write SetDefaultHeight;
    property ButtonMode: Boolean read FButtonMode write SetButtonMode;
    property SkinData: TbsSkinData read FSD write SetSkinData;
    property SkinDataName: String read FSkinDataName write FSkinDataName;
    //
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property ReadOnly;
    property Align;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Font;
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnButtonClick: TNotifyEvent read FOnButtonClick
                                         write FOnButtonClick;
    property OnLeftButtonClick: TNotifyEvent
      read FOnLeftButtonClick write FOnLeftButtonClick;
    property OnRightButtonClick: TNotifyEvent
      read FOnRightButtonClick write FOnRightButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsSkinEdit = class(TbsSkinCustomEdit)
  published
    property DefaultColor;
    property DefaultFont;
    property UseSkinFont;
    property DefaultWidth;
    property DefaultHeight;
    property ButtonMode;
    property SkinData;
    property SkinDataName;
    property OnMouseEnter;
    property OnMouseLeave;
    property ReadOnly;
    property Align;
    property Alignment;
    property Font;
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property Images;
    property ButtonImageIndex;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property OnLeftButtonClick;
    property OnRightButtonClick;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsSkinCustomCurrencyEdit = class(TbsSkinCustomEdit)
  private
    FAlignment: TAlignment;
    FFocused: Boolean;
    FValue: Extended;
    FMinValue, FMaxValue: Extended;
    FDecimalPlaces: Cardinal;
    FBeepOnError: Boolean;
    FCheckOnExit: Boolean;
    FZeroEmpty: Boolean;
    FFormatOnEditing: Boolean;
    FFormatting: Boolean;
    FDisplayFormat: String;
    procedure SetFocused(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetBeepOnError(Value: Boolean);
    procedure SetDisplayFormat(const Value: string);
    function GetDisplayFormat: string;
    procedure SetDecimalPlaces(Value: Cardinal);
    function GetValue: Extended;
    procedure SetValue(AValue: Extended);
    function GetAsInteger: Longint;
    procedure SetAsInteger(AValue: Longint);
    procedure SetMaxValue(AValue: Extended);
    procedure SetMinValue(AValue: Extended);
    procedure SetZeroEmpty(Value: Boolean);
    procedure SetFormatOnEditing(Value: Boolean);
    function GetText: string;
    procedure SetText(const AValue: string);
    function TextToValText(const AValue: string): string;
    function CheckValue(NewValue: Extended; RaiseOnError: Boolean): Extended;
    function IsFormatStored: Boolean;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
  protected
    procedure Change; override;
    procedure ReformatEditText; dynamic;
    procedure DataChanged; virtual;
    function DefaultDisplayFormat: string; virtual;
    procedure KeyPress(var Key: Char); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    function FormatDisplayText(Value: Extended): string;
    function GetDisplayText: string; virtual;
    procedure Reset; override;
    procedure CheckRange;
    procedure UpdateData;
    property Formatting: Boolean read FFormatting;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taRightJustify;
    property BeepOnError: Boolean read FBeepOnError write SetBeepOnError
      default True;
    property CheckOnExit: Boolean read FCheckOnExit write FCheckOnExit default False;
    property DecimalPlaces: Cardinal read FDecimalPlaces write SetDecimalPlaces
      default 2;
    property DisplayFormat: string read GetDisplayFormat write SetDisplayFormat
      stored IsFormatStored;
    property MaxValue: Extended read FMaxValue write SetMaxValue;
    property MinValue: Extended read FMinValue write SetMinValue;
    property FormatOnEditing: Boolean read FFormatOnEditing
      write SetFormatOnEditing default False;
    property Text: string read GetText write SetText stored False;
    property MaxLength default 0;
    property ZeroEmpty: Boolean read FZeroEmpty write SetZeroEmpty default True;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; {$IFDEF RX_D5} override; {$ENDIF}
    property AsInteger: Longint read GetAsInteger write SetAsInteger;
    property DisplayText: string read GetDisplayText;
    property Value: Extended read GetValue write SetValue;
  end;

  TbsSkinCurrencyEdit = class(TbsSkinCustomCurrencyEdit)
  protected
    function DefaultDisplayFormat: string; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DefaultColor;
    property DefaultFont;
    property UseSkinFont;
    property DefaultWidth;
    property DefaultHeight;
    property ButtonMode;
    property SkinData;
    property SkinDataName;
     property Alignment;
    property AutoSelect;
    property AutoSize;
    property BeepOnError;
    property BorderStyle;
    property CheckOnExit;
    property Color;
    property Ctl3D;
    property DecimalPlaces;
    property DisplayFormat;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property FormatOnEditing;
    property HideSelection;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property MaxValue;
    property MinValue;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Value;
    property Visible;
    property ZeroEmpty;
    property Images;
    property ButtonImageIndex;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnContextPopup;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

  TbsURLState = (bsstIN, bsstOUT);
  TbsURLLinkType = (bsltHTTP, bsltMail);

  TbsSkinURLEdit = class(TbsSkinEdit)
  private
    TempLabel: TLabel;
    FExecute: Boolean;
    FCanExecute: Boolean;
    FBtnDown: Boolean;
    FState: TbsURLState;
    FLinkType: TbsURLLinkType;
    function InText(X: Integer): Boolean;
  protected
    procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Message:TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property LinkType: TbsURLLinkType read FLinkType write FLinkType;
    Property Execute: Boolean read FExecute write FExecute;
  end;


  TbsSkinMemo = class(TMemo)
  protected
    FWallpaper: TBitMap;
    FWallpaperStretch: Boolean;
    FIsScroll: Boolean;
    FIsDown: Boolean;
    FIsCanScroll: Boolean;
    FStopDraw: Boolean;
    FTextArea: TRect;
    FBitMapBG: Boolean;
    FReadOnly: Boolean;
    FMouseIn: Boolean;
    FIndex: Integer;
    FSD: TbsSkinData;
    FSkinDataName: String;
    Picture: TBitMap;
    FOnMouseEnter, FOnMouseLeave: TNotifyEvent;
    FVScrollBar: TbsSkinScrollBar;
    FHScrollBar: TbsSkinScrollBar;
    FDefaultFont: TFont;
    FUseSkinFont: Boolean;
    FUseSkinFontColor: Boolean;
    FSysPopupMenu: TbsSkinPopupMenu;
    FTransparent: Boolean;

    procedure SetWallPaper(Value: TBitmap);
    procedure SetWallPaperStretch(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
    procedure SkinFramePaint(C: TCanvas);
    procedure DoUndo(Sender: TObject);
    procedure DoCut(Sender: TObject);
    procedure DoCopy(Sender: TObject);
    procedure DoPaste(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoSelectAll(Sender: TObject);
    procedure CreateSysPopupMenu;

    procedure OnDefaultFontChange(Sender: TObject);
    procedure SetDefaultFont(Value: TFont);

    procedure SetBitMapBG(Value: Boolean);

    procedure AdjustTextBorders;

    procedure SetVScrollBar(Value: TbsSkinScrollBar);
    procedure SetHScrollBar(Value: TbsSkinScrollBar);
    procedure OnVScrollBarChange(Sender: TObject);
    procedure OnHScrollBarChange(Sender: TObject);
    procedure SetSkinData(Value: TbsSkinData);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Change; override;
    procedure GetSkinData;
    procedure WMNCPAINT(var Message: TMessage); message WM_NCPAINT;
    procedure WMCHECKPARENTBG(var Msg: TWMEraseBkgnd); message WM_CHECKPARENTBG;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CNCtlColorEdit(var Message:TWMCTLCOLOREDIT); message  CN_CTLCOLOREDIT;
    procedure CNCtlColorStatic(var Message:TWMCTLCOLORSTATIC); message  CN_CTLCOLORSTATIC;
    procedure WMCHAR(var Message:TMessage); message WM_CHAR;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure WMCONTEXTMENU(var Message: TWMCONTEXTMENU); message WM_CONTEXTMENU;
    procedure WMAFTERDISPATCH(var Message: TMessage); message WM_AFTERDISPATCH;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
    procedure DoPaint2(DC: HDC); 

    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;

    procedure WMCOMMAND(var Message: TWMCOMMAND); message CN_COMMAND;
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMLBUTTONDOWN(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure WMLBUTTONUP(var Message: TMessage); message WM_LBUTTONUP;
    procedure WMMOUSEMOVE(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
    procedure WMSetText(var Message:TWMSetText); message WM_SETTEXT;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure WMCut(var Message: TMessage); message WM_Cut;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMUndo(var Message: TMessage); message WM_UNDO;
    procedure WMVSCROLL(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHSCROLL(var Message: TWMHScroll); message WM_HSCROLL;
    procedure DrawMemoBackGround(C: TCanvas);
    function GetDisabledFontColor: TColor;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure DoPaint;
  public
    LTPoint, RTPoint, LBPoint, RBPoint: TPoint;
    ClRect: TRect;
    SkinRect, ActiveSkinRect: TRect;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    FontColor: TColor;
    ActiveFontColor: TColor;
    BGColor: TColor;
    ActiveBGColor: TColor;
    LeftStretch, TopStretch, RightStretch, BottomStretch : Boolean;
    StretchEffect: Boolean;
    StretchType: TbsStretchType;
    //
    procedure UpDateScrollRange;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData;
  published
    //
    property Transparent: Boolean read FTransparent write SetTransparent;
    property Wallpaper: TBitMap read FWallpaper write SetWallpaper;
    property WallpaperStretch: Boolean read FWallpaperStretch write SetWallpaperStretch;
    property DefaultFont: TFont read FDefaultFont write SetDefaultFont;
    property UseSkinFont: Boolean read FUseSkinFont write FUseSkinFont;
    property UseSkinFontColor: Boolean read FUseSkinFontColor write FUseSkinFontColor;
    property BitMapBG: Boolean read FBitMapBG write SetBitMapBG;
    property VScrollBar: TbsSkinScrollBar read FVScrollBar
                                          write SetVScrollBar;
    property HScrollBar: TbsSkinScrollBar read FHScrollBar
                                          write SetHScrollBar;
    property SkinData: TbsSkinData read FSD write SetSkinData;
    property SkinDataName: String read FSkinDataName write FSkinDataName;
    //
    property ReadOnly read FReadOnly write FReadOnly;
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property Lines;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;
  

  TbsSkinMemo2 = class(TMemo)
  protected
    FMouseIn: Boolean;
    FIndex: Integer;
    FSD: TbsSkinData;
    FSkinDataName: String;
    FOnMouseEnter, FOnMouseLeave: TNotifyEvent;
    FVScrollBar: TbsSkinScrollBar;
    FHScrollBar: TbsSkinScrollBar;
    FDefaultFont: TFont;
    FUseSkinFont: Boolean;
    FUseSkinFontColor: Boolean;
    FSysPopupMenu: TbsSkinPopupMenu;
    procedure DoUndo(Sender: TObject);
    procedure DoCut(Sender: TObject);
    procedure DoCopy(Sender: TObject);
    procedure DoPaste(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoSelectAll(Sender: TObject);
    procedure CreateSysPopupMenu;
    procedure OnDefaultFontChange(Sender: TObject);
    procedure SetDefaultFont(Value: TFont);
    procedure UpDateScrollRange;
    procedure SetVScrollBar(Value: TbsSkinScrollBar);
    procedure SetHScrollBar(Value: TbsSkinScrollBar);
    procedure OnVScrollBarChange(Sender: TObject);
    procedure OnHScrollBarChange(Sender: TObject);
    procedure SetSkinData(Value: TbsSkinData);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Change; override;
    procedure GetSkinData;
    procedure WMCOMMAND(var Message: TWMCOMMAND); message CN_COMMAND;
    procedure WMCONTEXTMENU(var Message: TWMCONTEXTMENU); message WM_CONTEXTMENU;
    procedure WMAFTERDISPATCH(var Message: TMessage); message WM_AFTERDISPATCH;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CNCtlColorEdit(var Message:TWMCTLCOLOREDIT); message  CN_CTLCOLOREDIT;
    procedure WMCHAR(var Message:TMessage); message WM_CHAR;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMLBUTTONDOWN(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure WMLBUTTONUP(var Message: TMessage); message WM_LBUTTONUP;
    procedure WMMOUSEMOVE(var Message: TMessage); message WM_MOUSEMOVE;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
    procedure WMSetText(var Message:TWMSetText); message WM_SETTEXT;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMCut(var Message: TMessage); message WM_Cut;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMUndo(var Message: TMessage); message WM_UNDO;
    procedure WMVSCROLL(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHSCROLL(var Message: TWMHScroll); message WM_HSCROLL;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
    function GetDisabledFontColor: TColor;
  public
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    FontColor: TColor;
    ActiveFontColor: TColor;
    BGColor: TColor;
    ActiveBGColor: TColor;
    //
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData;
    procedure Invalidate; override;
    property BorderStyle;
    property ScrollBars;
  published
    //
    property DefaultFont: TFont read FDefaultFont write SetDefaultFont;
    property UseSkinFont: Boolean read FUseSkinFont write FUseSkinFont;
    property UseSkinFontColor: Boolean read FUseSkinFontColor write FUseSkinFontColor;
    property VScrollBar: TbsSkinScrollBar read FVScrollBar
                                          write SetVScrollBar;
    property HScrollBar: TbsSkinScrollBar read FHScrollBar
                                          write SetHScrollBar;
    property SkinData: TbsSkinData read FSD write SetSkinData;
    property SkinDataName: String read FSkinDataName write FSkinDataName;
    //
    property ReadOnly;
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property Lines;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TbsSkinCustomListBox = class;
  TbsListBox = class(TListBox)
  protected
    {$IFDEF VER130}
    FAutoComplete: Boolean;
    FLastTime: Cardinal;
    FFilter: String;
    {$ENDIF}
    FHorizontalExtentValue: Integer;
    procedure DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);
    function GetState(AItemID: Integer): TOwnerDrawState;
    procedure PaintBGWH(Cnvs: TCanvas; AW, AH, AX, AY: Integer);
    procedure PaintBG(DC: HDC);
    procedure PaintList(DC: HDC);
    procedure PaintColumnsList(DC: HDC);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawDefaultItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                           State: TOwnerDrawState);
    procedure DrawSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                           State: TOwnerDrawState);
    procedure DrawStretchSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                           State: TOwnerDrawState);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure PaintWindow(DC: HDC); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Click; override;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
    procedure CreateWnd; override;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
  public
    SkinListBox: TbsSkinCustomListBox;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property HorizontalExtentValue: Integer
      read FHorizontalExtentValue
      write FHorizontalExtentValue;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF VER130}
    property AutoComplete: Boolean  read FAutoComplete write FAutoComplete;
    {$ENDIF}
  end;

  TbsSkinCustomListBox = class(TbsSkinCustomControl)
  protected
    FShowCaptionButtons: Boolean;
    FTabWidths: TStrings;
    FUseSkinItemHeight: Boolean;
    //
    FHorizontalExtent: Boolean;
    FStopUpDateHScrollBar: Boolean;
    //
    FRowCount: Integer;
    FGlyph: TBitMap;
    FNumGlyphs: TbsSkinPanelNumGlyphs;
    FSpacing: Integer;

    FImages: TCustomImageList;
    FImageIndex: Integer;

    FOnUpButtonClick, FOnDownButtonClick, FOnCheckButtonClick: TNotifyEvent;

    FDefaultItemHeight: Integer;
    FDefaultCaptionHeight: Integer;
    FDefaultCaptionFont: TFont;
    FOnDrawItem: TbsDrawSkinItemEvent;
    NewClRect: TRect;
    ListRect: TRect;

    FCaptionMode: Boolean;
    FAlignment: TAlignment;
    Buttons: array[0..2] of TbsCBButtonX;
    OldActiveButton, ActiveButton, CaptureButton: Integer;
    NewCaptionRect: TRect;

    FOnListBoxClick: TNotifyEvent;
    FOnListBoxDblClick: TNotifyEvent;
    FOnListBoxMouseDown: TMouseEvent;
    FOnListBoxMouseMove: TMouseMoveEvent;
    FOnListBoxMouseUp: TMouseEvent;

    FOnListBoxKeyDown: TKeyEvent;
    FOnListBoxKeyPress: TKeyPressEvent;
    FOnListBoxKeyUp: TKeyEvent;

    TimerMode: Integer;
    WaitMode: Boolean;

    function GetOnListBoxDragDrop: TDragDropEvent;
    procedure SetOnListBoxDragDrop(Value: TDragDropEvent);
    function GetOnListBoxDragOver: TDragOverEvent;
    procedure SetOnListBoxDragOver(Value: TDragOverEvent);
    function GetOnListBoxStartDrag: TStartDragEvent;
    procedure SetOnListBoxStartDrag(Value: TStartDragEvent);
    function GetOnListBoxEndDrag: TEndDragEvent;
    procedure SetOnListBoxEndDrag(Value: TEndDragEvent);

    function GetFullItemWidth(Index: Integer; ACnvs: TCanvas): Integer; virtual;

    procedure SetHorizontalExtent(Value: Boolean);
    function  GetColumns: Integer;
    procedure SetColumns(Value: Integer);

    procedure SetRowCount(Value: Integer);
    procedure SetImages(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);
    procedure SetGlyph(Value: TBitMap);
    procedure SetNumGlyphs(Value: TbsSkinPanelNumGlyphs);
    procedure SetSpacing(Value: Integer);

    procedure StartTimer;
    procedure StopTimer;

    procedure ButtonDown(I: Integer; X, Y: Integer);
    procedure ButtonUp(I: Integer; X, Y: Integer);
    procedure ButtonEnter(I: Integer);
    procedure ButtonLeave(I: Integer);
    procedure DrawButton(Cnvs: TCanvas; i: Integer);
    procedure TestActive(X, Y: Integer);

    procedure ListBoxMouseDown(Button: TMouseButton; Shift: TShiftState;
                               X, Y: Integer); virtual;
    procedure ListBoxMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure ListBoxMouseUp(Button: TMouseButton; Shift: TShiftState;
                             X, Y: Integer); virtual;
    procedure ListBoxClick; virtual;
    procedure ListBoxDblClick; virtual;
    procedure ListBoxKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure ListBoxKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure ListBoxKeyPress(var Key: Char); virtual;
    procedure ListBoxEnter; virtual;
    procedure ListBoxExit; virtual;
    //
    procedure ShowScrollBar;
    procedure HideScrollBar;

    procedure ShowHScrollBar;
    procedure HideHScrollBar;

    procedure GetSkinData; override;
    procedure CalcRects;
    procedure SBChange(Sender: TObject);
    procedure HSBChange(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    //
    procedure SetShowCaptionButtons(Value: Boolean);
    procedure DefaultFontChange; override;
    procedure OnDefaultCaptionFontChange(Sender: TObject);
    procedure SetDefaultCaptionHeight(Value: Integer);
    procedure SetDefaultCaptionFont(Value: TFont);
    procedure SetDefaultItemHeight(Value: Integer);
    procedure SetCaptionMode(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetItems(Value: TStrings);
    function GetItems: TStrings;
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
    function GetMultiSelect: Boolean;
    procedure SetMultiSelect(Value: Boolean);
    function GetListBoxFont: TFont;
    procedure SetListBoxFont(Value: TFont);
    function GetListBoxTabOrder: TTabOrder;
    procedure SetListBoxTabOrder(Value: TTabOrder);
    function GetListBoxTabStop: Boolean;
    procedure SetListBoxTabStop(Value: Boolean);
    function GetListBoxDragMode: TDragMode;
    procedure SetListBoxDragMode(Value: TDragMode);
    function GetListBoxDragKind: TDragKind;
    procedure SetListBoxDragKind(Value: TDragKind);
    function GetListBoxDragCursor: TCursor;
    procedure SetListBoxDragCursor(Value: TCursor);
    //
    function GetCanvas: TCanvas;
    function GetExtandedSelect: Boolean;
    procedure SetExtandedSelect(Value: Boolean);
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    procedure SetSelected(Index: Integer; Value: Boolean);
    function GetSorted: Boolean;
    procedure SetSorted(Value: Boolean);
    function GetTopIndex: Integer;
    procedure SetTopIndex(Value: Integer);
    function GetListBoxPopupMenu: TPopupMenu;
    procedure SetListBoxPopupMenu(Value: TPopupMenu);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;

    procedure ListBoxWProc(var Message: TMessage; var Handled: Boolean); virtual;
    procedure ListBoxCreateWnd; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetAutoComplete: Boolean;
    procedure SetAutoComplete(Value: Boolean);
    procedure SetTabWidths(Value: TStrings);
    {$IFDEF VER200_UP}
    function GetListBoxTouch: TTouchManager;
    procedure SetListBoxTouch(Value: TTouchManager);
    {$ENDIF}
  public
    ScrollBar: TbsSkinScrollBar;
    HScrollBar: TbsSkinScrollBar;
    ListBox: TbsListBox;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    SItemRect, ActiveItemRect, FocusItemRect: TRect;
    ItemLeftOffset, ItemRightOffset: Integer;
    ItemTextRect: TRect;
    FontColor, ActiveFontColor, FocusFontColor: TColor;

    CaptionRect: TRect;
    CaptionFontName: String;
    CaptionFontStyle: TFontStyles;
    CaptionFontHeight: Integer;
    CaptionFontColor: TColor;
    UpButtonRect, ActiveUpButtonRect, DownUpButtonRect: TRect;
    DownButtonRect, ActiveDownButtonRect, DownDownButtonRect: TRect;
    CheckButtonRect, ActiveCheckButtonRect, DownCheckButtonRect: TRect;

    VScrollBarName, HScrollBarName, BothScrollBarName: String;
    ShowFocus: Boolean;

    ButtonsArea: TRect;
    DisabledButtonsRect: TRect;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure UpDateScrollBar;
    function CalcHeight(AItemsCount: Integer): Integer;
    //
    procedure Clear;
    function ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
    function ItemRect(Item: Integer): TRect;
    //
    property ShowCaptionButtons: Boolean
      read FShowCaptionButtons write SetShowCaptionButtons;
    property TabWidths: TStrings read FTabWidths write SetTabWidths;
    property Columns: Integer read GetColumns write SetColumns;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property ListBoxCanvas: TCanvas read GetCanvas;
    property SelCount: Integer read GetSelCount;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
    //
    property UseSkinItemHeight: Boolean
     read FUseSkinItemHeight write FUseSkinItemHeight; 
    property DefaultCaptionHeight: Integer
      read FDefaultCaptionHeight  write SetDefaultCaptionHeight;
    property DefaultCaptionFont: TFont
     read FDefaultCaptionFont  write SetDefaultCaptionFont;

    property CaptionMode: Boolean read FCaptionMode
                                         write SetCaptionMode;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    property DefaultItemHeight: Integer read FDefaultItemHeight
                                        write SetDefaultItemHeight;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect;
    property ListBoxFont: TFont read GetListBoxFont write SetListBoxFont;
    property ListBoxTabOrder: TTabOrder read GetListBoxTabOrder write SetListBoxTabOrder;
    property ListBoxTabStop: Boolean read GetListBoxTabStop write SetListBoxTabStop;
    property ExtandedSelect: Boolean read GetExtandedSelect write SetExtandedSelect;
    property Sorted: Boolean read GetSorted write SetSorted;
    property ListBoxPopupMenu: TPopupMenu read GetListBoxPopupMenu write SetListBoxPopupMenu;
    property  HorizontalExtent: Boolean
      read FHorizontalExtent
      write SetHorizontalExtent;
    property ListBoxDragMode: TDragMode read GetListBoxDragMode write SetListBoxDragMode;
    property ListBoxDragKind: TDragKind read GetListBoxDragKind write SetListBoxDragKind;
    property ListBoxDragCursor: TCursor read GetListBoxDragCursor write SetListBoxDragCursor;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete;
    property Caption;
    property Font;
    property Align;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;

    property Visible;

    property RowCount: Integer read FRowCount write SetRowCount;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;

    property Glyph: TBitMap read FGlyph write SetGlyph;
    property NumGlyphs: TbsSkinPanelNumGlyphs read FNumGlyphs write SetNumGlyphs;
    property Spacing: Integer read FSpacing write SetSpacing;
    {$IFDEF VER200_UP}
    property ListBoxTouch: TTouchManager
      read GetListBoxTouch write SetListBoxTouch;
    {$ENDIF}
    property OnClick;
    property OnUpButtonClick: TNotifyEvent read FOnUpButtonClick
                                           write FOnUpButtonClick;
    property OnDownButtonClick: TNotifyEvent read FOnDownButtonClick
                                           write FOnDownButtonClick;
    property OnCheckButtonClick: TNotifyEvent read FOnCheckButtonClick
                                           write FOnCheckButtonClick;
    property OnCanResize;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnListBoxClick: TNotifyEvent read FOnListBoxClick write FOnListBoxClick;
    property OnListBoxDblClick: TNotifyEvent read FOnListBoxDblClick write FOnListBoxDblClick;
    property OnListBoxMouseDown: TMouseEvent read FOnListBoxMouseDown write
     FOnListBoxMouseDown;
    property OnListBoxMouseMove: TMouseMoveEvent read FOnListBoxMouseMove
      write FOnListBoxMouseMove;
    property OnListBoxMouseUp: TMouseEvent read FOnListBoxMouseUp
      write FOnListBoxMouseUp;
    property OnListBoxKeyDown: TKeyEvent read FOnListBoxKeyDown write FOnListBoxKeyDown;
    property OnListBoxKeyPress: TKeyPressEvent read FOnListBoxKeyPress write FOnListBoxKeyPress;
    property OnListBoxKeyUp: TKeyEvent read FOnListBoxKeyUp write FOnListBoxKeyUp;
    property OnDrawItem: TbsDrawSkinItemEvent read FOnDrawItem write FOnDrawItem;
    property OnListBoxDragDrop: TDragDropEvent read GetOnListBoxDragDrop
      write SetOnListBoxDragDrop;
    property OnListBoxDragOver: TDragOverEvent read GetOnListBoxDragOver
      write SetOnListBoxDragOver;
    property OnListBoxStartDrag: TStartDragEvent read GetOnListBoxStartDrag
      write SetOnListBoxStartDrag;
    property OnListBoxEndDrag: TEndDragEvent read GetOnListBoxEndDrag
      write SetOnListBoxEndDrag;
  end;

  TbsSkinListBox = class(TbsSkinCustomListBox)
  published
    {$IFDEF VER200_UP}
    property ListBoxTouch;
    {$ENDIF}
    property TabWidths;
    property AutoComplete;
    property UseSkinItemHeight;
    property HorizontalExtent;
    property Columns;
    property RowCount;
    property Images;
    property ImageIndex;
    property Glyph;
    property NumGlyphs;
    property Spacing;
    property CaptionMode;
    property DefaultCaptionHeight;
    property DefaultCaptionFont;
    property Alignment;
    property DefaultItemHeight;
    property Items;
    property ItemIndex;
    property MultiSelect;
    property ListBoxFont;
    property ListBoxTabOrder;
    property ListBoxTabStop;
    property ListBoxDragMode;
    property ListBoxDragKind;
    property ListBoxDragCursor;
    property ExtandedSelect;
    property Sorted;
    property ListBoxPopupMenu;
    property ShowCaptionButtons;
    //
    property Caption;
    property Font;
    property Align;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property OnClick;
    property Visible;
    property OnUpButtonClick;
    property OnDownButtonClick;
    property OnCheckButtonClick;
    property OnCanResize;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnListBoxClick;
    property OnListBoxDblClick;
    property OnListBoxMouseDown;
    property OnListBoxMouseMove;
    property OnListBoxMouseUp;
    property OnListBoxKeyDown;
    property OnListBoxKeyPress;
    property OnListBoxKeyUp;
    property OnListBoxDragDrop;
    property OnListBoxDragOver;
    property OnListBoxStartDrag;
    property OnListBoxEndDrag;
    property OnDrawItem;
  end;

  TbsSkinScrollBox = class(TbsSkinCustomControl)
  protected
    FClicksDisabled: Boolean;
    FUpdatingScrollInfo: Boolean;
    FCanFocused: Boolean;
    FInCheckScrollBars: Boolean;
    FDown: Boolean;
    FVScrollBar: TbsSkinScrollBar;
    FHScrollBar: TbsSkinScrollBar;
    FOldVScrollBarPos: Integer;
    FOldHScrollBarPos: Integer;
    FVSizeOffset: Integer;
    FHSizeOffset: Integer;
    FBorderStyle: TbsSkinBorderStyle;
    procedure SetBorderStyle(Value: TbsSkinBorderStyle);
    procedure SetVScrollBar(Value: TbsSkinScrollBar);
    procedure SetHScrollBar(Value: TbsSkinScrollBar);
    procedure VScrollControls(AOffset: Integer);
    procedure HScrollControls(AOffset: Integer);

    procedure OnHScrollBarChange(Sender: TObject);
    procedure OnVScrollBarChange(Sender: TObject);
    procedure OnHScrollBarLastChange(Sender: TObject);
    procedure OnVScrollBarLastChange(Sender: TObject);

    procedure Notification(AComponent: TComponent;
     Operation: TOperation); override;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure WMNCPAINT(var Message: TWMNCPAINT); message WM_NCPAINT;
    procedure PaintFrame(C: TCanvas);
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure GetSkinData; override;
    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure ChangeSkinData; override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure WndProc(var Message: TMessage); override;
    procedure CMBENCPaint(var Message: TMessage); message CM_BENCPAINT;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
  public
    BGPictureIndex: Integer;
    procedure HScroll(APosition: Integer);
    procedure VScroll(APosition: Integer);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure Paint; override;
    procedure GetHRange;
    procedure GetVRange;
    procedure UpDateScrollRange;
    procedure ScrollToControl(C: TControl);
  published
    property HScrollBar: TbsSkinScrollBar read FHScrollBar
                                          write SetHScrollBar;
    property VScrollBar: TbsSkinScrollBar read FVScrollBar
                                          write SetVScrollBar;
    property BorderStyle: TbsSkinBorderStyle
      read FBorderStyle write SetBorderStyle;
    property CanFocused: Boolean read FCanFocused write FCanFocused;
    property Align;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Color;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
  end;

  TCloseUpEvent = procedure (Sender: TObject; Accept: Boolean) of object;
  TPopupAlign = (epaRight, epaLeft);

  TbsCBItem = record
    R: TRect;
    State: TOwnerDrawState;
  end;

  TbsSkinCustomComboBoxStyle = (bscbEditStyle, bscbFixedStyle);

  TbsPopupListBox = class(TbsSkinListBox)
  private
    FOldAlphaBlend: Boolean;
    FOldAlphaBlendValue: Byte;
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Hide;
    procedure Show(Origin: TPoint);
  end;

  TbsSkinCustomComboBox = class(TbsSkinCustomControl)
  protected
    FNumEdit: Boolean;
    FDropDown: Boolean;
    FToolButtonStyle: Boolean;
    FCharCase: TEditCharCase;
    FDefaultColor: TColor;
    FUseSkinSize: Boolean;
    WasInLB: Boolean;
    TimerMode: Integer;
    FListBoxWidth: Integer;
    FHideSelection: Boolean;
    FLastTime: Cardinal;
    FFilter: String;
    FAutoComplete: Boolean;
    FAlphaBlend: Boolean;
    FAlphaBlendAnimation: Boolean;
    FAlphaBlendValue: Byte;
    
    FStyle: TbsSkinCustomComboBoxStyle;

    FOnChange: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCloseUp: TNotifyEvent;
    FOnDropDown: TNotifyEvent;

    FOnListBoxDrawItem: TbsDrawSkinItemEvent;
    FOnComboBoxDrawItem: TbsDrawSkinItemEvent;

    FMouseIn: Boolean;
    FOldItemIndex: Integer;
    FDropDownCount: Integer;
    FLBDown: Boolean;
    FListBoxWindowProc: TWndMethod;
    FEditWindowProc: TWndMethod;
    //
    FListBox: TbsPopupListBox;
    //
    CBItem: TbsCBItem;
    Button: TbsCBButtonX;
    FEdit: TbsCustomEdit;
    FromEdit: Boolean;

    procedure DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);

    procedure AdjustEditHeight;
    procedure AdjustEditPos;
    procedure DrawMenuMarker(C: TCanvas; R: TRect; AActive, ADown: Boolean;
     ButtonData: TbsDataSkinButtonControl);

    procedure SetCharCase(Value: TEditCharCase); 
    function GetSelStart: Integer;
    procedure SetSelStart(Value: Integer);
    function GetSelLength: Integer;
    procedure SetSelLength(Value: Integer);

    procedure ProcessListBox;
    procedure StartTimer;
    procedure StopTimer;

    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); 
     
    function GetHorizontalExtent: Boolean;
    procedure SetHorizontalExtent(Value: Boolean);

    function GetListBoxUseSkinItemHeight: Boolean;
    procedure SetListBoxUseSkinItemHeight(Value: Boolean);

    function GetImages: TCustomImageList;
    function GetImageIndex: Integer;
    procedure SetImages(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);

    function GetListBoxDefaultFont: TFont;
    procedure SetListBoxDefaultFont(Value: TFont);

    function GetListBoxUseSkinFont: Boolean;
    procedure SetListBoxUseSkinFont(Value: Boolean);

    function GetListBoxDefaultCaptionFont: TFont;
    procedure SetListBoxDefaultCaptionFont(Value: TFont);
    function GetListBoxDefaultItemHeight: Integer;
    procedure SetListBoxDefaultItemHeight(Value: Integer);
    function GetListBoxCaptionAlignment: TAlignment;
    procedure SetListBoxCaptionAlignment(Value: TAlignment);

    procedure CheckButtonClick(Sender: TObject);

    procedure SetListBoxCaption(Value: String);
    function  GetListBoxCaption: String;
    procedure SetListBoxCaptionMode(Value: Boolean);
    function  GetListBoxCaptionMode: Boolean;

    procedure EditCancelMode(C: TControl);

    procedure ListBoxDrawItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);

    function GetSorted: Boolean;
    procedure SetSorted(Value: Boolean);

    procedure SetStyle(Value: TbsSkinCustomComboBoxStyle);
    procedure DrawDefaultItem(Cnvs: TCanvas);
    procedure DrawSkinItem(Cnvs: TCanvas);
    procedure DrawResizeSkinItem(Cnvs: TCanvas);

    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);

    procedure ListBoxWindowProcHook(var Message: TMessage);
    procedure EditWindowProcHook(var Message: TMessage); virtual;
    procedure SetItems(Value: TStrings);
    function GetItems: TStrings;

    procedure SetListBoxDrawItem(Value: TbsDrawSkinItemEvent);
    procedure SetDropDownCount(Value: Integer);
    procedure EditChange(Sender: TObject);
    procedure EditUp(AChange: Boolean);
    procedure EditDown(AChange: Boolean);
    procedure EditUp1(AChange: Boolean);
    procedure EditDown1(AChange: Boolean);
    procedure EditPageUp1(AChange: Boolean);
    procedure EditPageDown1(AChange: Boolean);
    procedure ShowEditor; virtual;
    procedure HideEditor;
    procedure DrawButton(C: TCanvas);
    procedure DrawResizeButton(C: TCanvas);
    procedure CalcRects;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer; 
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState;
              X, Y: Integer);
    procedure GetSkinData; override;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;

    procedure DefaultFontChange; override;
    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;

    procedure CreateControlDefaultImage2(B: TBitMap);
    procedure CreateControlSkinImage2(B: TBitMap);
    procedure CreateControlToolSkinImage(B: TBitMap; AText: String);
    procedure CreateControlToolDefaultImage(B: TBitMap; AText: String);

    procedure Change; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure FindLBItem(S: String);
    procedure FindLBItemFromEdit;
    procedure CalcSize(var W, H: Integer); override;
    procedure SetControlRegion; override;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure SetDefaultColor(Value: TColor);
    function GetDisabledFontColor: TColor;
    function GetTabWidths: TStrings;
    procedure SetTabWidths(Value: TStrings);
    procedure SetToolButtonStyle(Value: Boolean);
    {$IFDEF VER200_UP}
    function GetListBoxTouch: TTouchManager;
    procedure SetListBoxTouch(Value: TTouchManager);
    {$ENDIF}
  public
    ActiveSkinRect: TRect;
    ActiveFontColor: TColor;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    SItemRect, FocusItemRect, ActiveItemRect: TRect;
    ItemLeftOffset, ItemRightOffset: Integer;
    ItemTextRect: TRect;
    FontColor, FocusFontColor: TColor;
    ButtonRect,
    ActiveButtonRect,
    DownButtonRect, UnEnabledButtonRect: TRect;
    ListBoxName: String;
    ItemStretchEffect, FocusItemStretchEffect: Boolean;
    ShowFocus: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintSkinTo(C: TCanvas; X, Y: Integer; AText: String);
    procedure ChangeSkinData; override;
    procedure CloseUp(Value: Boolean);
    procedure DropDown; virtual;
    function IsPopupVisible: Boolean;
    function CanCancelDropDown: Boolean;
    procedure Invalidate; override;
    property ToolButtonStyle: Boolean
      read FToolButtonStyle write SetToolButtonStyle;
    property HideSelection: Boolean
      read FHideSelection write FHideSelection;
    property AutoComplete: Boolean read FAutoComplete write FAutoComplete;
    property AlphaBlend: Boolean read FAlphaBlend write FAlphaBlend;
    property AlphaBlendAnimation: Boolean
      read FAlphaBlendAnimation write FAlphaBlendAnimation;
    property AlphaBlendValue: Byte read FAlphaBlendValue write FAlphaBlendValue;
    property Images: TCustomImageList read GetImages write SetImages;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    property ListBoxWidth: Integer read FListBoxWidth write FListBoxWidth;
    property ListBoxUseSkinItemHeight: Boolean
      read GetListBoxUseSkinItemHeight write SetListBoxUseSkinItemHeight;
     property ListBoxCaption: String read GetListBoxCaption
                                    write SetListBoxCaption;
    property ListBoxCaptionMode: Boolean read GetListBoxCaptionMode
                                    write SetListBoxCaptionMode;

    property ListBoxDefaultFont: TFont
      read GetListBoxDefaultFont write SetListBoxDefaultFont;

    property ListBoxUseSkinFont: Boolean
      read GetListBoxUseSkinFont write SetListBoxUseSkinFont;
    property ListBoxDefaultCaptionFont: TFont
      read GetListBoxDefaultCaptionFont write SetListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight: Integer
      read GetListBoxDefaultItemHeight write SetListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment: TAlignment
      read GetListBoxCaptionAlignment write SetListBoxCaptionAlignment;

    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    //
    property CharCase: TEditCharCase read FCharCase write SetCharCase;
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor;
    property Text;
    property Align;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property DropDownCount: Integer read FDropDownCount write SetDropDownCount;
    property HorizontalExtent: Boolean
      read GetHorizontalExtent write SetHorizontalExtent;
    property Font;
    property Sorted: Boolean read GetSorted write SetSorted;
    property Style: TbsSkinCustomComboBoxStyle read FStyle write SetStyle;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;

    property TabWidths: TStrings read GetTabWidths write SetTabWidths;

    {$IFDEF VER200_UP}
    property ListBoxTouch: TTouchManager
      read GetListBoxTouch write SetListBoxTouch;
    {$ENDIF}

    property OnListBoxDrawItem: TbsDrawSkinItemEvent
      read FOnListBoxDrawItem write SetListBoxDrawItem;
    property OnComboBoxDrawItem: TbsDrawSkinItemEvent
      read FOnComboBoxDrawItem write FOnComboBoxDrawItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  published
    property UseSkinSize: Boolean read FUseSkinSize write FUseSkinSize;
  end;

  TbsSkinComboBox = class(TbsSkinCustomComboBox)
  published
    {$IFDEF VER200_UP}
    property ListBoxTouch;
    {$ENDIF}
    property ToolButtonStyle;
    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;
    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property ListBoxWidth;

    property HideSelection;
    property AutoComplete;
    property Images;
    property ImageIndex;

    property TabWidths;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property CharCase;
    //
    property DefaultColor;
    property Text;
    property Align;
    property Items;
    property ItemIndex;
    property DropDownCount;
    property HorizontalExtent;
    property Font;
    property Sorted;
    property Style;
    property OnListBoxDrawItem;
    property OnComboBoxDrawItem;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnDropDown;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  end;

  TbsSkinMRUComboBox = class(TbsSkinComboBox)
  public
    procedure AddMRUItem(Value: String);
  end;

  TbsColorBoxStyles = (bscbStandardColors, bscbExtendedColors, bscbSystemColors,
                       bscbIncludeNone, bscbIncludeDefault, bscbCustomColor,
                       bscbPrettyNames);
  TbsColorBoxStyle = set of TbsColorBoxStyles;

  TbsSkinColorComboBox = class(TbsSkinCustomComboBox)
  private
    FShowNames: Boolean;
    FNeedToPopulate: Boolean;
    FExStyle: TbsColorBoxStyle;
    FDefaultColorColor: TColor;
    FNoneColorColor: TColor;
    FSelectedColor: TColor;
    procedure SetShowNames(Value: Boolean);
    function GetColor(Index: Integer): TColor;
    function GetColorName(Index: Integer): string;
    function GetSelected: TColor;
    procedure SetSelected(const AColor: TColor);
    procedure ColorCallBack(const AName: string);
    procedure SetDefaultColorColor(const Value: TColor);
    procedure SetNoneColorColor(const Value: TColor);
    procedure SetExStyle(AStyle: TbsColorBoxStyle);
  protected
    procedure DrawColorItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
    procedure CreateWnd; override;
    function PickCustomColor: Boolean; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure OnLBCloseUp(Sender: TObject);
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Colors[Index: Integer]: TColor read GetColor;
    property ColorNames[Index: Integer]: string read GetColorName;
    procedure PopulateList;
  published
    property ToolButtonStyle;
    property HideSelection;
    property AutoComplete;
    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;
    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property ListBoxWidth;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    //
    property Align;
    property ItemIndex;
    property DropDownCount;
    property Font;
    property Sorted;
    property ExStyle: TbsColorBoxStyle read FExStyle write SetExStyle
      default [bscbStandardColors, bscbExtendedColors, bscbSystemColors];
    property Selected: TColor read GetSelected write SetSelected default clBlack;
    property DefaultColorColor: TColor read FDefaultColorColor write SetDefaultColorColor default clBlack;
    property NoneColorColor: TColor read FNoneColorColor write SetNoneColorColor default clBlack;
    property ShowNames: Boolean read FShowNames write SetShowNames;
    property OnClick;
    property OnChange;
  end;

  TbsSkinColorListBox = class(TbsSkinListBox)
  private
    FShowNames: Boolean;
    FExStyle: TbsColorBoxStyle;
    FDefaultColorColor: TColor;
    FNoneColorColor: TColor;
    FSelectedColor: TColor;
    procedure SetShowNames(Value: Boolean);
    function GetColor(Index: Integer): TColor;
    function GetColorName(Index: Integer): string;
    function GetSelected: TColor;
    procedure SetSelected(const AColor: TColor);
    procedure ColorCallBack(const AName: string);
    procedure SetDefaultColorColor(const Value: TColor);
    procedure SetNoneColorColor(const Value: TColor);
    procedure SetExStyle(AStyle: TbsColorBoxStyle);
  protected
    procedure DrawColorItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
    procedure CreateWnd; override;
    function PickCustomColor: Boolean; virtual;
    procedure Loaded; override;
    procedure ListBoxKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ListBoxDblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Colors[Index: Integer]: TColor read GetColor;
    property ColorNames[Index: Integer]: string read GetColorName;
    procedure PopulateList;
  published
    property Sorted;
    property ExStyle: TbsColorBoxStyle read FExStyle write SetExStyle
      default [bscbStandardColors, bscbExtendedColors, bscbSystemColors];
    property Selected: TColor read GetSelected write SetSelected default clBlack;
    property DefaultColorColor: TColor read FDefaultColorColor write SetDefaultColorColor default clBlack;
    property NoneColorColor: TColor read FNoneColorColor write SetNoneColorColor default clBlack;
    property ShowNames: Boolean read FShowNames write SetShowNames;
  end;

  TbsFontDevice = (fdScreen, fdPrinter, fdBoth);
  TbsFontListOption = (foAnsiOnly, foTrueTypeOnly, foFixedPitchOnly,
    foNoOEMFonts, foOEMFontsOnly, foScalableOnly, foNoSymbolFonts);
  TbsFontListOptions = set of TbsFontListOption;

  TbsSkinFontSizeComboBox = class(TbsSkinCustomComboBox)
  private
    PixelsPerInch: Integer;
    FFontName: TFontName;
    procedure SetFontName(const Value: TFontName);
    procedure Build;
    function GetSizeValue: Integer;
    procedure ShowEditor; override;
  public
    constructor Create(AOwner: TComponent); override;
    property FontName: TFontName read FFontName write SetFontName;
    property SizeValue: Integer read GetSizeValue;
  published
    property ToolButtonStyle;
    property HideSelection;
    property AutoComplete;
    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;
    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property ListBoxWidth;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    //
    property Align;
    property ItemIndex;
    property DropDownCount;
    property Font;
    property Sorted;
    property Style;
    property OnChange;
    property OnClick;
    //
  end;

  TbsSkinFontListBox = class(TbsSkinListBox)
  protected
    FDevice: TbsFontDevice;
    FUpdate: Boolean;
    FUseFonts: Boolean;
    FOptions: TbsFontListOptions;
    procedure ListBoxCreateWnd; override;
    procedure SetFontName(const NewFontName: TFontName);
    function GetFontName: TFontName;
    function GetTrueTypeOnly: Boolean;
    procedure SetDevice(Value: TbsFontDevice);
    procedure SetOptions(Value: TbsFontListOptions);
    procedure SetTrueTypeOnly(Value: Boolean);
    procedure SetUseFonts(Value: Boolean);
    procedure Reset;
    procedure DrawLBFontItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);

    procedure DrawTT(Cnvs: TCanvas; X, Y: Integer; C: TColor);
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure PopulateList;
  published
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    //
    property Align;
    property ItemIndex;
    property Font;
    property Sorted;
    //
    property Device: TbsFontDevice read FDevice write SetDevice default fdScreen;
    property FontName: TFontName read GetFontName write SetFontName;
    property Options: TbsFontListOptions read FOptions write SetOptions default [];
    property TrueTypeOnly: Boolean read GetTrueTypeOnly write SetTrueTypeOnly
      stored False;
    property UseFonts: Boolean read FUseFonts write SetUseFonts default False;
  end;

  TbsSkinFontComboBox = class(TbsSkinCustomComboBox)
  protected
    FDevice: TbsFontDevice;
    FUpdate: Boolean;
    FUseFonts: Boolean;
    FOptions: TbsFontListOptions;
    procedure SetFontName(const NewFontName: TFontName);
    function GetFontName: TFontName;
    function GetTrueTypeOnly: Boolean;
    procedure SetDevice(Value: TbsFontDevice);
    procedure SetOptions(Value: TbsFontListOptions);
    procedure SetTrueTypeOnly(Value: Boolean);
    procedure SetUseFonts(Value: Boolean);
    procedure Reset;
    procedure WMFontChange(var Message: TMessage); message WM_FONTCHANGE;

    procedure DrawLBFontItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);

    procedure DrawCBFontItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
    procedure CreateWnd; override;

    procedure DrawTT(Cnvs: TCanvas; X, Y: Integer; C: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    procedure PopulateList;
  published
    property ToolButtonStyle;
    property HideSelection;
    property AutoComplete;
    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;
    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property ListBoxWidth;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    //
    property Align;
    property ItemIndex;
    property DropDownCount;
    property Font;
    property Sorted;
    property Style;
    property OnChange;
    property OnClick;
    //
    property Device: TbsFontDevice read FDevice write SetDevice default fdScreen;
    property FontName: TFontName read GetFontName write SetFontName;
    property Options: TbsFontListOptions read FOptions write SetOptions default [];
    property TrueTypeOnly: Boolean read GetTrueTypeOnly write SetTrueTypeOnly
      stored False; 
    property UseFonts: Boolean read FUseFonts write SetUseFonts default False;
  end;

  TbsValueType = (vtInteger, vtFloat);

  TbsSkinSpinEdit = class(TbsSkinCustomControl)
  private
    FOnUpButtonClick: TNotifyEvent;
    FOnDownButtonClick: TNotifyEvent;
    FDefaultColor: TColor;
    FUseSkinSize: Boolean;
    FMouseIn: Boolean;
    FEditFocused: Boolean;
    StopCheck: Boolean;
    FDecimal: Byte;
    FMinValue, FMaxValue, FIncrement: Double;
    FromEdit: Boolean;
    FValueType: TbsValueType;
    FOnChange: TNotifyEvent;
    FValue: Double;
    OldActiveButton, ActiveButton, CaptureButton: Integer;
    TimerMode: Integer;
    WaitMode: Boolean;
    procedure StartTimer;
    procedure StopTimer;
    procedure SetValue(AValue: Double);
    procedure SetMinValue(AValue: Double);
    procedure SetMaxValue(AValue: Double);
    procedure SetEditorEnabled(AValue: Boolean);
    function  GetEditorEnabled: Boolean;
    procedure SetMaxLength(AValue: Integer);
    function  GetMaxLength: Integer;
    procedure SetValueType(NewType: TbsValueType);
    procedure SetDecimal(NewValue: Byte);
    procedure SetDefaultColor(Value: TColor);
   protected
    Buttons: array[0..1] of TbsCBButtonX;
    FOnEditKeyDown: TKeyEvent;
    FOnEditKeyPress: TKeyPressEvent;
    FOnEditKeyUp: TKeyEvent;
    FOnEditEnter: TNotifyEvent;
    FOnEditExit: TNotifyEvent;

    procedure AdjustEditHeight;

    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure EditKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure EditEnter(Sender: TObject); virtual;
    procedure EditExit(Sender: TObject); virtual;
    procedure EditMouseEnter(Sender: TObject);
    procedure EditMouseLeave(Sender: TObject); 

    procedure UpClick(Sender: TObject);
    procedure DownClick(Sender: TObject);
    function CheckValue (NewValue: Double): Double;
    procedure EditChange(Sender: TObject);
    procedure ButtonDown(I: Integer; X, Y: Integer);
    procedure ButtonUp(I: Integer; X, Y: Integer);
    procedure ButtonEnter(I: Integer);
    procedure ButtonLeave(I: Integer);
    procedure TestActive(X, Y: Integer);
    procedure CalcRects;
    procedure DrawButton(Cnvs: TCanvas; i: Integer);
    procedure DrawResizeButton(Cnvs: TCanvas; i: Integer);
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure GetSkinData; override;
    procedure DefaultFontChange; override;

    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure Change; virtual;

    procedure CalcSize(var W, H: Integer); override;
    procedure SetControlRegion; override;

  public
    ActiveSkinRect: TRect;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    FontColor, DisabledFontColor, ActiveFontColor: TColor;
    UpButtonRect, ActiveUpButtonRect, DownUpButtonRect: TRect;
    DownButtonRect, ActiveDownButtonRect, DownDownButtonRect: TRect;
    LOffset, ROffset: Integer;
    //
    FEdit: TbsSkinNumEdit;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    function IsNumText(AText: String): Boolean;
    procedure ChangeSkinData; override;
    property Text;
    procedure SimpleSetValue(AValue: Double);
    procedure PaintSkinTo(C: TCanvas; X, Y: Integer; AText: String);
  published
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor;
    property UseSkinSize: Boolean read
      FUseSkinSize write FUseSkinSize;
    property Enabled;
    property ValueType: TbsValueType read FValueType write SetValueType;
    property Decimal: Byte read FDecimal write SetDecimal default 2;
    property Align;
    property ShowHint;
    property MinValue: Double read FMinValue write SetMinValue;
    property MaxValue: Double read FMaxValue write SetMaxValue;
    property Value: Double read FValue write SetValue;
    property Increment: Double read FIncrement write FIncrement;
    property EditorEnabled: Boolean read GetEditorEnabled write SetEditorEnabled;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEditKeyDown: TKeyEvent read FOnEditKeyDown write FOnEditKeyDown;
    property OnEditKeyPress: TKeyPressEvent read FOnEditKeyPress write FOnEditKeyPress;
    property OnEditKeyUp: TKeyEvent read FOnEditKeyUp write FOnEditKeyUp;
    property OnEditEnter: TNotifyEvent read FOnEditEnter write FOnEditEnter;
    property OnEditExit: TNotifyEvent read FOnEditExit write FOnEditExit;
    property OnUpButtonClick: TNotifyEvent read FOnUpButtonClick write FOnUpButtonClick;
    property OnDownButtonClick: TNotifyEvent read FOnDownButtonClick write FOnDownButtonClick;
  end;

  TbsSkinCheckListBox = class;
  TbsCheckListBox = class(TListBox)
  protected
    {$IFDEF VER130}
    FAutoComplete: Boolean;
    FLastTime: Cardinal;
    FFilter: String;
    {$ENDIF}
    FSaveStates: TList;
    FOnClickCheck: TNotifyEvent;
    FAllowGrayed: Boolean;
    FWrapperList: TList;
    function GetSkinDisabledColor: TColor;
    procedure DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);
    procedure SkinDrawCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
    procedure SkinDrawGrayedCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
    procedure SkinDrawDisableCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
    procedure PaintBGWH(Cnvs: TCanvas; AW, AH, AX, AY: Integer);
    function CreateWrapper(Index: Integer): TObject;
    function GetWrapper(Index: Integer): TObject;
    function HaveWrapper(Index: Integer): Boolean;
    function ExtractWrapper(Index: Integer): TObject;

    procedure InvalidateCheck(Index: Integer);

    procedure SetChecked(Index: Integer; Checked: Boolean);
    function GetChecked(Index: Integer): Boolean;
    procedure SetState(Index: Integer; AState: TCheckBoxState);
    function GetState(Index: Integer): TCheckBoxState;

    function GetState1(AItemID: Integer): TOwnerDrawState;

    procedure ToggleClickCheck(Index: Integer);

    procedure DeleteString(Index: Integer); override;
    procedure ResetContent; override;

    {$IFDEF VER230_UP}
    procedure SetItemData(Index: Integer; AData: TListBoxItemData); override;
    function GetItemData(Index: Integer): TListBoxItemData; override;
    {$ELSE}
    procedure SetItemData(Index: Integer; AData: LongInt); override;
    function GetItemData(Index: Integer): LongInt; override;
    {$ENDIF}


    procedure PaintBG(DC: HDC);
    procedure PaintList(DC: HDC);
    procedure PaintColumnsList(DC: HDC);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawDefaultItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                           State1: TOwnerDrawState);
    procedure DrawSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                           State1: TOwnerDrawState);
    procedure DrawStretchSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                                  State1: TOwnerDrawState);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMNCCALCSIZE(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHITTEST(var Message: TWMNCHITTEST); message WM_NCHITTEST;
    procedure PaintWindow(DC: HDC); override;
    procedure DestroyWnd; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Click; override;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMGotFocus); message CM_EXIT;
    procedure CreateWnd; override;
    procedure CMSENCPaint(var Message: TMessage); message CM_SENCPAINT;
    function GetItemEnabled(Index: Integer): Boolean;
    procedure SetItemEnabled(Index: Integer; const Value: Boolean);
   public
    SkinListBox: TbsSkinCheckListBox;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Checked[Index: Integer]: Boolean read GetChecked write SetChecked;
    property State[Index: Integer]: TCheckBoxState read GetState write SetState;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property ItemEnabled[Index: Integer]: Boolean read GetItemEnabled write SetItemEnabled;
    property OnClickCheck: TNotifyEvent read FOnClickCheck write FOnClickCheck;
    {$IFDEF VER130}
    property AutoComplete: Boolean  read FAutoComplete write FAutoComplete; 
    {$ENDIF}
  end;

  TbsSkinCheckListBox = class(TbsSkinCustomControl)
  protected
    FShowCaptionButtons: Boolean;
    
    FTabWidths: TStrings;
    FUseSkinItemHeight: Boolean;
    FRowCount: Integer;
    FImages: TCustomImageList;
    FImageIndex: Integer;

    FGlyph: TBitMap;
    FNumGlyphs: TbsSkinPanelNumGlyphs;
    FSpacing: Integer;

    FOnUpButtonClick, FOnDownButtonClick, FOnCheckButtonClick: TNotifyEvent;

    FOnClickCheck: TNotifyEvent;

    FDefaultItemHeight: Integer;

    FOnDrawItem: TbsDrawSkinItemEvent;

    NewClRect: TRect;

    ListRect: TRect;

    FDefaultCaptionHeight: Integer;
    FDefaultCaptionFont: TFont;

    FOnListBoxClick: TNotifyEvent;
    FOnListBoxDblClick: TNotifyEvent;
    FOnListBoxMouseDown: TMouseEvent;
    FOnListBoxMouseMove: TMouseMoveEvent;
    FOnListBoxMouseUp: TMouseEvent;

    FOnListBoxKeyDown: TKeyEvent;
    FOnListBoxKeyPress: TKeyPressEvent;
    FOnListBoxKeyUp: TKeyEvent;

    FCaptionMode: Boolean;
    FAlignment: TAlignment;
    Buttons: array[0..2] of TbsCBButtonX;
    OldActiveButton, ActiveButton, CaptureButton: Integer;
    NewCaptionRect: TRect;

    TimerMode: Integer;
    WaitMode: Boolean;

    procedure SetShowCaptionButtons(Value: Boolean);

    function  GetColumns: Integer;
    procedure SetColumns(Value: Integer);

    function GetItemEnabled(Index: Integer): Boolean;
    procedure SetItemEnabled(Index: Integer; const Value: Boolean);

    procedure SetTabWidths(Value: TStrings);
    function GetOnListBoxDragDrop: TDragDropEvent;
    procedure SetOnListBoxDragDrop(Value: TDragDropEvent);
    function GetOnListBoxDragOver: TDragOverEvent;
    procedure SetOnListBoxDragOver(Value: TDragOverEvent);
    function GetOnListBoxStartDrag: TStartDragEvent;
    procedure SetOnListBoxStartDrag(Value: TStartDragEvent);
    function GetOnListBoxEndDrag: TEndDragEvent;
    procedure SetOnListBoxEndDrag(Value: TEndDragEvent);

    procedure SetOnClickCheck(const Value: TNotifyEvent);
    procedure SetRowCount(Value: Integer);
    procedure SetImages(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);
    procedure SetGlyph(Value: TBitMap);
    procedure SetNumGlyphs(Value: TbsSkinPanelNumGlyphs);
    procedure SetSpacing(Value: Integer);

    procedure StartTimer;
    procedure StopTimer;

    procedure ButtonDown(I: Integer; X, Y: Integer);
    procedure ButtonUp(I: Integer; X, Y: Integer);
    procedure ButtonEnter(I: Integer);
    procedure ButtonLeave(I: Integer);
    procedure TestActive(X, Y: Integer);
    procedure DrawButton(Cnvs: TCanvas; i: Integer);

    procedure ListBoxOnClickCheck(Sender: TObject);

    procedure SetChecked(Index: Integer; Checked: Boolean);
    function GetChecked(Index: Integer): Boolean;
    procedure SetState(Index: Integer; AState: TCheckBoxState);
    function GetState(Index: Integer): TCheckBoxState;

    procedure ListBoxMouseDown(Button: TMouseButton; Shift: TShiftState;
                               X, Y: Integer); virtual;
    procedure ListBoxMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure ListBoxMouseUp(Button: TMouseButton; Shift: TShiftState;
                             X, Y: Integer); virtual;
    procedure ListBoxClick; virtual;
    procedure ListBoxDblClick; virtual;
    procedure ListBoxKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure ListBoxKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure ListBoxKeyPress(var Key: Char); virtual;
    procedure ListBoxEnter; virtual;
    procedure ListBoxExit; virtual;
    //
    procedure ShowScrollBar;
    procedure HideScrollBar;
    //
    procedure GetSkinData; override;
    procedure CalcRects;
    procedure SBChange(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    //
    procedure OnDefaultCaptionFontChange(Sender: TObject);
    procedure SetDefaultCaptionHeight(Value: Integer);
    procedure SetDefaultCaptionFont(Value: TFont);
    procedure SetDefaultItemHeight(Value: Integer);
    procedure SetCaptionMode(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetItems(Value: TStrings);
    function GetItems: TStrings;
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
    function GetMultiSelect: Boolean;
    procedure SetMultiSelect(Value: Boolean);
    function GetListBoxFont: TFont;
    procedure SetListBoxFont(Value: TFont);
    function GetListBoxTabOrder: TTabOrder;
    procedure SetListBoxTabOrder(Value: TTabOrder);
    function GetListBoxTabStop: Boolean;
    procedure SetListBoxTabStop(Value: Boolean);
    //
    function GetCanvas: TCanvas;
    function GetExtandedSelect: Boolean;
    procedure SetExtandedSelect(Value: Boolean);
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    procedure SetSelected(Index: Integer; Value: Boolean);
    function GetSorted: Boolean;
    procedure SetSorted(Value: Boolean);
    function GetTopIndex: Integer;
    procedure SetTopIndex(Value: Integer);
    function GetListBoxPopupMenu: TPopupMenu;
    procedure SetListBoxPopupMenu(Value: TPopupMenu);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetListBoxDragMode: TDragMode;
    procedure SetListBoxDragMode(Value: TDragMode);
    function GetListBoxDragKind: TDragKind;
    procedure SetListBoxDragKind(Value: TDragKind);
    function GetListBoxDragCursor: TCursor;
    procedure SetListBoxDragCursor(Value: TCursor);
    function GetAutoComplete: Boolean;
    procedure SetAutoComplete(Value: Boolean);
  public
    ScrollBar: TbsSkinScrollBar;
    ListBox: TbsCheckListBox;
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    SItemRect, ActiveItemRect, FocusItemRect: TRect;
    ItemLeftOffset, ItemRightOffset: Integer;
    ItemTextRect: TRect;
    FontColor, ActiveFontColor, FocusFontColor: TColor;
    UnCheckImageRect, CheckImageRect: TRect;
    ItemCheckRect: TRect;

    CaptionRect: TRect;
    CaptionFontName: String;
    CaptionFontStyle: TFontStyles;
    CaptionFontHeight: Integer;
    CaptionFontColor: TColor;
    UpButtonRect, ActiveUpButtonRect, DownUpButtonRect: TRect;
    DownButtonRect, ActiveDownButtonRect, DownDownButtonRect: TRect;
    CheckButtonRect, ActiveCheckButtonRect, DownCheckButtonRect: TRect;

    VScrollBarName, HScrollBarName: String;
    ShowFocus: Boolean;

    ButtonsArea: TRect;
    DisabledButtonsRect: TRect;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Checked[Index: Integer]: Boolean read GetChecked write SetChecked;
    property State[Index: Integer]: TCheckBoxState read GetState write SetState;
    property ItemEnabled[Index: Integer]: Boolean read GetItemEnabled write SetItemEnabled;
    
    procedure ChangeSkinData; override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure UpDateScrollBar;
    function CalcHeight(AItemsCount: Integer): Integer;
    //
    procedure Clear;
    function ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
    function ItemRect(Item: Integer): TRect;
    //
    function GetAllowGrayed: Boolean;
    procedure SetAllowGrayed(Value: Boolean);
    //
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property ListBoxCanvas: TCanvas read GetCanvas;
    property SelCount: Integer read GetSelCount;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
  published
   property ShowCaptionButtons: Boolean
      read FShowCaptionButtons write SetShowCaptionButtons;
    property AllowGrayed: Boolean read GetAllowGrayed write SetAllowGrayed;
    property TabWidths: TStrings read FTabWidths write SetTabWidths;
    property UseSkinItemHeight: Boolean
     read FUseSkinItemHeight write FUseSkinItemHeight;
    property Columns: Integer read GetColumns write SetColumns;
    property CaptionMode: Boolean read FCaptionMode
                                         write SetCaptionMode;
    property DefaultCaptionHeight: Integer
      read FDefaultCaptionHeight  write SetDefaultCaptionHeight;
    property DefaultCaptionFont: TFont
     read FDefaultCaptionFont  write SetDefaultCaptionFont;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    property DefaultItemHeight: Integer read FDefaultItemHeight
                                        write SetDefaultItemHeight;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect;
    property ListBoxFont: TFont read GetListBoxFont write SetListBoxFont;
    property ListBoxTabOrder: TTabOrder read GetListBoxTabOrder write SetListBoxTabOrder;
    property ListBoxTabStop: Boolean read GetListBoxTabStop write SetListBoxTabStop;
    property ListBoxDragMode: TDragMode read GetListBoxDragMode write SetListBoxDragMode;
    property ListBoxDragKind: TDragKind read GetListBoxDragKind write SetListBoxDragKind;
    property ListBoxDragCursor: TCursor read GetListBoxDragCursor write SetListBoxDragCursor;
    property ExtandedSelect: Boolean read GetExtandedSelect write SetExtandedSelect;
    property Sorted: Boolean read GetSorted write SetSorted;
    property ListBoxPopupMenu: TPopupMenu read GetListBoxPopupMenu write SetListBoxPopupMenu;
    //
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete;
    property Caption;
    property Font;
    property Align;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;

    property Glyph: TBitMap read FGlyph write SetGlyph;
    property NumGlyphs: TbsSkinPanelNumGlyphs read FNumGlyphs write SetNumGlyphs;
    property Spacing: Integer read FSpacing write SetSpacing;
    property RowCount: Integer read FRowCount write SetRowCount;

    property OnClick;
    property OnUpButtonClick: TNotifyEvent read FOnUpButtonClick
                                           write FOnUpButtonClick;
    property OnDownButtonClick: TNotifyEvent read FOnDownButtonClick
                                           write FOnDownButtonClick;
    property OnCheckButtonClick: TNotifyEvent read FOnCheckButtonClick
                                           write FOnCheckButtonClick;
    property OnCanResize;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnClickCheck: TNotifyEvent read FOnClickCheck write SetOnClickCheck;
    property OnListBoxClick: TNotifyEvent read FOnListBoxClick write FOnListBoxClick;
    property OnListBoxDblClick: TNotifyEvent read FOnListBoxDblClick write FOnListBoxDblClick;
    property OnListBoxMouseDown: TMouseEvent read FOnListBoxMouseDown write
     FOnListBoxMouseDown;
    property OnListBoxMouseMove: TMouseMoveEvent read FOnListBoxMouseMove
      write FOnListBoxMouseMove;
    property OnListBoxMouseUp: TMouseEvent read FOnListBoxMouseUp
      write FOnListBoxMouseUp;
    property OnListBoxKeyDown: TKeyEvent read FOnListBoxKeyDown write FOnListBoxKeyDown;
    property OnListBoxKeyPress: TKeyPressEvent read FOnListBoxKeyPress write FOnListBoxKeyPress;
    property OnListBoxKeyUp: TKeyEvent read FOnListBoxKeyUp write FOnListBoxKeyUp;
    property OnDrawItem: TbsDrawSkinItemEvent read FOnDrawItem write FOnDrawItem;
    property OnListBoxDragDrop: TDragDropEvent read GetOnListBoxDragDrop
      write SetOnListBoxDragDrop;
    property OnListBoxDragOver: TDragOverEvent read GetOnListBoxDragOver
      write SetOnListBoxDragOver;
    property OnListBoxStartDrag: TStartDragEvent read GetOnListBoxStartDrag
      write SetOnListBoxStartDrag;
    property OnListBoxEndDrag: TEndDragEvent read GetOnListBoxEndDrag
      write SetOnListBoxEndDrag;
  end;

  TbsSkinUpDown = class(TbsSkinCustomControl)
  protected
    FUseSkinSize: Boolean;
    FOrientation: TUDOrientation;
    Buttons: array[0..1] of TbsCBButtonX;
    OldActiveButton, ActiveButton, CaptureButton: Integer;
    TimerMode: Integer;
    WaitMode: Boolean;
    //
    FOnUpButtonClick: TNotifyEvent;
    FOnDownButtonClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FIncrement: Integer;
    FPosition: Integer;
    FMin: Integer;
    FMax: Integer;
    procedure SetOrientation(Value: TUDOrientation);
    procedure StartTimer;
    procedure StopTimer;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure ButtonDown(I: Integer; X, Y: Integer);
    procedure ButtonUp(I: Integer; X, Y: Integer);
    procedure ButtonEnter(I: Integer);
    procedure ButtonLeave(I: Integer);
    procedure DrawButton(Cnvs: TCanvas; i: Integer);
    procedure DrawResizeButton(Cnvs: TCanvas; i: Integer);
    procedure TestActive(X, Y: Integer);
    procedure CalcRects;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetIncrement(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure GetSkinData; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;

    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure SetControlRegion; override;
    procedure CalcSize(var W, H: Integer); override;
  public
    UpButtonRect, ActiveUpButtonRect, DownUpButtonRect: TRect;
    DownButtonRect, ActiveDownButtonRect, DownDownButtonRect: TRect;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property UseSkinSize: Boolean read FUseSkinSize write FUseSkinSize;
    property Orientation: TUDOrientation read FOrientation
                                         write SetOrientation;
    property Increment: Integer read FIncrement write SetIncrement;
    property Position: Integer read FPosition write SetPosition;
    property Min: Integer read FMin write SetMin;
    property Max: Integer read FMax write SetMax;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnUpButtonClick: TNotifyEvent read FOnUpButtonClick
                                           write FOnUpButtonClick;
    property OnDownButtonClick: TNotifyEvent read FOnDownButtonClick
                                           write FOnDownButtonClick;
  end;

  TbsSkinIntUpDown = class(TbsSkinCustomControl)
  protected
    FUseSkinSize: Boolean;
    FOrientation: TUDOrientation;
    Buttons: array[0..1] of TbsCBButtonX;
    OldActiveButton, ActiveButton, CaptureButton: Integer;
    TimerMode: Integer;
    WaitMode: Boolean;
    //
    FOnUpButtonClick: TNotifyEvent;
    FOnDownButtonClick: TNotifyEvent;
    FOnUpChange: TNotifyEvent;
    FOnDownChange: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FIncrement: Integer;
    FPosition: Integer;
    FMin: Integer;
    FMax: Integer;
    procedure SetOrientation(Value: TUDOrientation);
    procedure StartTimer;
    procedure StopTimer;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure ButtonDown(I: Integer; X, Y: Integer);
    procedure ButtonUp(I: Integer; X, Y: Integer);
    procedure ButtonEnter(I: Integer);
    procedure ButtonLeave(I: Integer);
    procedure DrawButton(Cnvs: TCanvas; i: Integer);
    procedure DrawResizeButton(Cnvs: TCanvas; i: Integer);
    procedure TestActive(X, Y: Integer);
    procedure CalcRects;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetIncrement(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure GetSkinData; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;

    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure SetControlRegion; override;
    procedure CalcSize(var W, H: Integer); override;
  public
    UpButtonRect, ActiveUpButtonRect, DownUpButtonRect: TRect;
    DownButtonRect, ActiveDownButtonRect, DownDownButtonRect: TRect;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property UseSkinSize: Boolean read FUseSkinSize write FUseSkinSize;
    property Orientation: TUDOrientation read FOrientation
                                         write SetOrientation;
    property Increment: Integer read FIncrement write SetIncrement;
    property Position: Integer read FPosition write SetPosition;
    property Min: Integer read FMin write SetMin;
    property Max: Integer read FMax write SetMax;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnUpButtonClick: TNotifyEvent read FOnUpButtonClick
                                           write FOnUpButtonClick;
    property OnDownButtonClick: TNotifyEvent read FOnDownButtonClick
                                           write FOnDownButtonClick;
  end;

  TbsSkinDateEdit = class;

  TbsDateOrder = (bsdoMDY, bsdoDMY, bsdoYMD);

  TbsSkinPopupMonthCalendar = class(TbsSkinMonthCalendar)
  protected
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TbsSkinDateEdit = class(TbsSkinCustomEdit)
  private
    StopCheck: Boolean;
    FAlphaBlend: Boolean;
    FAlphaBlendValue: Byte;
    FAlphaBlendAnimation: Boolean;
    FTodayDefault: Boolean;
    FBlanksChar: Char;
    FDateSelected: Boolean;
  protected
    FMonthCalendar: TbsSkinPopupMonthCalendar;
    FOnDateChange: TNotifyEvent;
    FOldDateValue: TDateTime;
    //
     procedure CalendarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function FourDigitYear: Boolean;
    function GetDateOrder(const DateFormat: string): TbsDateOrder;
    function DefDateFormat(FourDigitYear: Boolean): string;
    function DefDateMask(BlanksChar: Char; FourDigitYear: Boolean): string;
    function MonthFromName(const S: string; MaxLen: Byte): Byte;
    procedure ExtractMask(const Format, S: string; Ch: Char; Cnt: Integer;
       var I: Integer; Blank, Default: Integer);
    function ScanDateStr(const Format, S: string; var D, M, Y: Integer): Boolean;
    function CurrentYear: Word;
    function ExpandYear(Year: Integer): Integer;
    function IsValidDate(Y, M, D: Word): Boolean;
    function ScanDate(const S, DateFormat: string; var Pos: Integer;
      var Y, M, D: Integer): Boolean;
    //
    function GetDateMask: String;
    procedure Loaded; override;

    function GetShowToday: Boolean;
    procedure SetShowToday(Value: Boolean);
    function GetWeekNumbers: Boolean;
    procedure SetWeekNumbers(Value: Boolean);

    procedure SetTodayDefault(Value: Boolean);
    function GetCalendarFont: TFont;
    procedure SetCalendarFont(Value: TFont);
    function GetCalendarWidth: Integer;
    procedure SetCalendarWidth(Value: Integer);

    function GetCalendarBoldDays: Boolean;
    procedure SetCalendarBoldDays(Value: Boolean);

    function GetCalendarHeight: Integer;
    procedure SetCalendarHeight(Value: Integer);

    function GetCalendarUseSkinFont: Boolean;
    procedure SetCalendarUseSkinFont(Value: Boolean);

    function GetCalendarSkinDataName: String;
    procedure SetCalendarSkinDataName(Value: String);

    function GetDate: TDate;
    procedure SetDate(Value: TDate);
    procedure DropDown;
    procedure CloseUp(AcceptValue: Boolean);
    procedure CalendarClick(Sender: TObject);
    procedure WndProc(var Message: TMessage); override;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CheckValidDate;
    procedure Change; override;
    //
    function GetFirstDayOfWeek: TbsDaysOfWeek;
    procedure SetFirstDayOfWeek(Value: TbsDaysOfWeek);
    function IsValidText(S: String): Boolean;
    function IsOnlyNumbers(S: String): Boolean;
    function MyStrToDate(S: String): TDate;
    function MyDateToStr(Date: TDate): String;
    //
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsDateInput: Boolean;
    procedure ValidateEdit; override;
    procedure ButtonClick(Sender: TObject);
  published
     property AlphaBlend: Boolean read FAlphaBlend write FAlphaBlend;
    property AlphaBlendAnimation: Boolean
      read FAlphaBlendAnimation write FAlphaBlendAnimation;
    property AlphaBlendValue: Byte read FAlphaBlendValue write FAlphaBlendValue;

    property UseSkinFont;

    property Date: TDate read GetDate write SetDate;
    property TodayDefault: Boolean read FTodayDefault write SetTodayDefault;

    property CalendarWidth: Integer read GetCalendarWidth write SetCalendarWidth;
    property CalendarHeight: Integer read GetCalendarHeight write SetCalendarHeight;
    property CalendarFont: TFont read GetCalendarFont write SetCalendarFont;
    property CalendarBoldDays: Boolean read GetCalendarBoldDays write SetCalendarBoldDays;
    property CalendarUseSkinFont: Boolean
      read GetCalendarUseSkinFont write SetCalendarUseSkinFont;
    property CalendarSkinDataName: String
      read GetCalendarSkinDataName write SetCalendarSkinDataName;

    property FirstDayOfWeek: TbsDaysOfWeek
      read GetFirstDayOfWeek write SetFirstDayOfWeek;


    property WeekNumbers: Boolean
      read GetWeekNumbers write SetWeekNumbers;

    property ShowToday: Boolean
      read GetShowToday write SetShowToday;

    property OnDateChange: TNotifyEvent
      read FOnDateChange write FOnDateChange;
    property DefaultFont;
    property DefaultWidth;
    property DefaultHeight;
    property ButtonMode;
    property SkinData;
    property SkinDataName;
    property OnMouseEnter;
    property OnMouseLeave;
    property ReadOnly;
    property Align;
    property Alignment;
    property Font;
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property Images;
    property ButtonImageIndex;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property OnButtonClick;
    property OnLeftButtonClick;
    property OnRightButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;


  TbsSkinTrackEdit = class;

  TbsSkinPopupTrackBar = class(TbsSkinTrackBar)
  protected
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    TrackEdit: TbsSkinTrackEdit;
    constructor Create(AOwner: TComponent); override;
  end;

  TbsTrackBarPopupKind = (tbpRight, tbpLeft);

  TbsSkinTrackEdit = class(TbsSkinCustomEdit)
  private
    FIncrement: Integer;
    FSupportUpDownKeys: Boolean;
    FPopupKind: TbsTrackBarPopupKind;
    FTrackBarWidth: Integer;
    FTrackBarSkinDataName: String;
    StopCheck, FromEdit: Boolean;
    FMinValue, FMaxValue, FValue: Integer;
    FAlphaBlend: Boolean;
    FAlphaBlendValue: Byte;
    FAlphaBlendAnimation: Boolean;
    FPopupTrackBar: TbsSkinPopupTrackBar;
    FDblClickShowTrackBar: Boolean;
    function GetJumpWhenClick: Boolean;
    procedure SetJumpWhenClick(Value: Boolean);
    procedure SetValue(AValue: Integer);
    procedure SetMinValue(AValue: Integer);
    procedure SetMaxValue(AValue: Integer);
    procedure TrackBarChange(Sender: TObject);
    procedure DropDown;
    procedure CloseUp;
  protected
    function CheckValue(NewValue: Integer): Integer;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function IsValidChar(Key: Char): Boolean;
    procedure Change; override;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
     procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    property Text;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsNumText(AText: String): Boolean;
    procedure ButtonClick(Sender: TObject);
  published
    property Increment: Integer read FIncrement write FIncrement;
    property DblClickShowTrackBar: Boolean
      read FDblClickShowTrackBar write FDblClickShowTrackBar;
    property SupportUpDownKeys: Boolean
      read FSupportUpDownKeys write FSupportUpDownKeys;
    property Alignment;
    property UseSkinFont;
    property PopupKind: TbsTrackBarPopupKind read FPopupKind write FPopupKind;
    property JumpWhenClick: Boolean
     read GetJumpWhenClick write SetJumpWhenClick;
    property TrackBarWidth: Integer
      read FTrackBarWidth write FTrackBarWidth;
    property TrackBarSkinDataName: String
      read FTrackBarSkinDataName write FTrackBarSkinDataName;
    property AlphaBlend: Boolean read FAlphaBlend write FAlphaBlend;
    property AlphaBlendAnimation: Boolean
      read FAlphaBlendAnimation write FAlphaBlendAnimation;
    property AlphaBlendValue: Byte read FAlphaBlendValue write FAlphaBlendValue;
    property MinValue: Integer read FMinValue write SetMinValue;
    property MaxValue: Integer read FMaxValue write SetMaxValue;
    property Value: Integer read FValue write SetValue;
    property DefaultFont;
    property DefaultWidth;
    property DefaultHeight;
    property ButtonMode;
    property SkinData;
    property SkinDataName;
    property Images;
    property ButtonImageIndex;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property OnMouseEnter;
    property OnMouseLeave;
    property ReadOnly;
    property Align;
    property Font;
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnButtonClick;
    property OnLeftButtonClick;
    property OnRightButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsSkinNumericEdit = class(TbsSkinCustomEdit)
  private
    StopCheck, FromEdit: Boolean;
    FMinValue, FMaxValue, FValue: Double;
    FDecimal: Byte;
    FValueType: TbsValueType;
    FIncrement: Double;
    FSupportUpDownKeys: Boolean;
    procedure SetValue(AValue: Double);
    procedure SetMinValue(AValue: Double);
    procedure SetMaxValue(AValue: Double);
    procedure SetDecimal(NewValue: Byte);
    procedure SetValueType(NewType: TbsValueType);
  protected
    function CheckValue(NewValue: Double): Double;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function IsValidChar(Key: Char): Boolean;
    procedure Change; override;
    property Text;
    procedure WMKILLFOCUS(var Message: TMessage); message WM_KILLFOCUS;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsNumText(AText: String): Boolean;
  published
    property Increment: Double read FIncrement write FIncrement;
    property SupportUpDownKeys: Boolean
      read FSupportUpDownKeys write FSupportUpDownKeys;
    property Alignment;
    property UseSkinFont;
    property Decimal: Byte read FDecimal write SetDecimal default 2;
    property ValueType: TbsValueType read FValueType write SetValueType;
    property MinValue: Double read FMinValue write SetMinValue;
    property MaxValue: Double read FMaxValue write SetMaxValue;
    property Value: Double read FValue write SetValue;
    property DefaultFont;
    property DefaultWidth;
    property DefaultHeight;
    property ButtonMode;
    property SkinData;
    property SkinDataName;
    property OnMouseEnter;
    property OnMouseLeave;
    property ReadOnly;
    property Align;
    property Font;
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property CharCase;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Images;
    property ButtonImageIndex;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property OnButtonClick;
    property OnLeftButtonClick;
    property OnRightButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsSkinMaskEdit = class(TbsSkinEdit)
  published
    property Images;
    property LeftImageIndex;
    property LeftImageHotIndex;
    property LeftImageDownIndex;
    property RightImageIndex;
    property RightImageHotIndex;
    property RightImageDownIndex;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property EditMask;
    property Font;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsSkinTimeEdit = class(TbsSkinMaskEdit)
  private
    FUpDown: TbsSkinIntUpDown;
    FShowMSec: Boolean;
    FShowSec: Boolean;
    FShowUpDown: Boolean;
    function GetIncIndex: Integer;
    procedure UpButtonClick(Sender: TObject);
    procedure DownButtonClick(Sender: TObject);
    procedure AdjustUpDown; 
    procedure SetShowMilliseconds(const Value: Boolean);
    procedure SetShowSeconds(const Value: Boolean);
    procedure SetMilliseconds(const Value: Integer);
    function GetMilliseconds: Integer;
    procedure SetTime(const Value: string);
    function GetTime: string;
    function IsValidTime(const AHour, AMinute, ASecond, AMilliSecond: Word): Boolean;
    function IsValidChar(Key: Char): Boolean;
    procedure CheckSpace(var S: String);
    procedure SetValidTime(var H, M, S, MS: Word);
    function ValidateParameter(S: String; MustLen: Integer): String;
    procedure SetShowUpDown(Value: Boolean);
    procedure ShowUpDownControl;
    procedure HideUpDownControl;
  protected
    procedure HandleOnKeyPress(Sender: TObject; var Key: Char);
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ValidateEdit; override;
    procedure DecodeTime(var Hour, Min, Sec, MSec: Word);
    procedure EncodeTime(Hour, Min, Sec, MSec: Word);
    property Milliseconds: Integer read GetMilliseconds write SetMilliseconds;
    property Time: string read GetTime write SetTime;
    property ShowMSec: Boolean read FShowMSec write SetShowMilliseconds;
    property ShowSec: Boolean read FShowSec write SetShowSeconds;
  published
    property ShowUpDown: Boolean read FShowUpDown write SetShowUpDown;
  end;

  TbsPasswordKind = (pkRoundRect, pkRect, pkTriangle);

  TbsSkinPasswordEdit = class(TbsSkinCustomControl)
  private
    FDefaultColor: TColor;
    FMouseIn: Boolean;
    FText: String;
    FLMouseSelecting: Boolean;
    FCaretPosition: Integer;
    FSelStart: Integer;
    FSelLength: Integer;
    FFVChar: Integer;
    FAutoSelect: Boolean;
    FCharCase: TEditCharCase;
    FHideSelection: Boolean;
    FMaxLength: Integer;
    FReadOnly: Boolean;
    FOnChange: TNotifyEvent;
    FPasswordKind: TbsPasswordKind;
    FTextAlignment: TAlignment;
    procedure UpdateFVC;
    procedure UpdateCaretePosition;
    procedure UpdateCarete;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMSETFOCUS(var Message: TWMSETFOCUS); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Msg: TMessage); message CM_TEXTCHANGED;
    function GetSelText: String;
    function GetVisibleSelText: String;
    function GetNextWPos(StartPosition: Integer): Integer;
    function GetPrivWPos(StartPosition: Integer): Integer;
    function GetSelStart: Integer;            
    function GetSelLength: Integer;
    function GetText: String;
    procedure SetText(const Value: String);
    procedure SetCaretPosition(const Value: Integer);
    procedure SetSelLength(const Value: Integer);
    procedure SetSelStart(const Value: Integer);
    procedure SetAutoSelect(const Value: Boolean);
    procedure SetCharCase(const Value: TEditCharCase);
    procedure SetHideSelection(const Value: Boolean);
    procedure SetMaxLength(const Value: Integer);
    procedure SetCursor(const Value: TCursor);
    procedure SetTextAlignment(const Value: TAlignment);
    procedure SetPasswordKind(const Value: TbsPasswordKind);
    procedure SetDefaultColor(Value: TColor);
  protected
    function GetEditRect: TRect; virtual;
    function GetPasswordFigureWidth: Integer;
    function GetCharX(A: Integer): Integer;
    function GetCPos(x: Integer): Integer;
    function GetSelRect: TRect; virtual;
    function GetAlignmentFlags: Integer;
    procedure PaintText(Cnv: TCanvas);
    procedure PaintSelectedText(Cnv: TCanvas);
    procedure DrawPasswordChar(SymbolRect: TRect; Selected: Boolean; Cnv: TCanvas);
    function ValidText(NewText: String): Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: Integer); override;
    procedure MouseMove(Shift: TShiftState; x, y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure SelectWord;
    procedure Change; dynamic;
    property CaretPosition: Integer read FCaretPosition write SetCaretPosition;
    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure GetSkinData; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CalcSize(var W, H: Integer); override;
    function GetPaintText: String; virtual;
  public
    //
    LOffset, ROffset: Integer;
    ClRect: TRect;
    SkinRect, ActiveSkinRect: TRect;
    CharColor, CharActiveColor, CharDisabledColor: TColor;
    //
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure PasteFromClipboard;
    procedure ShowCaret; virtual;
    procedure HideCaret; virtual;
    procedure ClearSelection;
    procedure SelectAll;
    procedure Clear;
    procedure InsertChar(Ch: Char);
    procedure InsertText(AText: String);
    procedure InsertAfter(Position: Integer; S: String; Selected: Boolean);
    procedure DeleteFrom(Position, Length : Integer; MoveCaret : Boolean);
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: String read GetSelText;
  published
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor;
    property Anchors;
    property AutoSelect: Boolean read FAutoSelect write SetAutoSelect default true;
    property CharCase: TEditCharCase read FCharCase write SetCharCase default ecNormal;
    property Constraints;
    property Color default clWindow;
    property Cursor write SetCursor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default True;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property ParentFont;
    property ParentShowHint;
    property PasswordKind: TbsPasswordKind read FPasswordKind write SetPasswordKind;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property ShowHint;
    property TabOrder;
    property TabStop default true;
    property Text: String read GetText write SetText;
    property TextAlignment : TAlignment read FTextAlignment write SetTextAlignment default taLeftJustify;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TbsPopupCheckListBox = class(TbsSkinCheckListBox)
  private
    FOldAlphaBlend: Boolean;
    FOldAlphaBlendValue: Byte;
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Hide;
    procedure Show(Origin: TPoint);
  end;

  TbsSkinCustomCheckComboBox = class(TbsSkinCustomControl)
  protected
    FDefaultColor: TColor;
    WasInLB: Boolean;
    TimerMode: Integer;

    FUseSkinSize: Boolean;

    FAlphaBlend: Boolean;
    FAlphaBlendAnimation: Boolean;
    FAlphaBlendValue: Byte;

    FOnChange: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCloseUp: TNotifyEvent;
    FOnDropDown: TNotifyEvent;

    FOnListBoxDrawItem: TbsDrawSkinItemEvent;

    FMouseIn: Boolean;
    FDropDownCount: Integer;
    FLBDown: Boolean;
    FListBoxWindowProc: TWndMethod;
    FEditWindowProc: TWndMethod;
    //
    FListBox: TbsPopupCheckListBox;
    FListBoxWidth: Integer;
    //
    CBItem: TbsCBItem;
    Button: TbsCBButtonX;


    procedure CalcSize(var W, H: Integer); override;

    procedure ProcessListBox;
    procedure StartTimer;
    procedure StopTimer;

    procedure CheckText;
    procedure SetChecked(Index: Integer; Checked: Boolean);
    function GetChecked(Index: Integer): Boolean;

    function GetListBoxUseSkinItemHeight: Boolean;
    procedure SetListBoxUseSkinItemHeight(Value: Boolean);

    function GetImages: TCustomImageList;
    function GetImageIndex: Integer;
    procedure SetImages(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);

    function GetListBoxDefaultFont: TFont;
    procedure SetListBoxDefaultFont(Value: TFont);

    function GetListBoxUseSkinFont: Boolean;
    procedure SetListBoxUseSkinFont(Value: Boolean);

    function GetListBoxDefaultCaptionFont: TFont;
    procedure SetListBoxDefaultCaptionFont(Value: TFont);
    function GetListBoxDefaultItemHeight: Integer;
    procedure SetListBoxDefaultItemHeight(Value: Integer);
    function GetListBoxCaptionAlignment: TAlignment;
    procedure SetListBoxCaptionAlignment(Value: TAlignment);

    procedure SetListBoxCaption(Value: String);
    function  GetListBoxCaption: String;
    procedure SetListBoxCaptionMode(Value: Boolean);
    function  GetListBoxCaptionMode: Boolean;

    procedure ListBoxDrawItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);

    function GetSorted: Boolean;
    procedure SetSorted(Value: Boolean);

    procedure DrawDefaultItem(Cnvs: TCanvas);
    procedure DrawSkinItem(Cnvs: TCanvas);
    procedure DrawResizeSkinItem(Cnvs: TCanvas);

    procedure ListBoxWindowProcHook(var Message: TMessage);

    procedure SetItems(Value: TStrings);
    function GetItems: TStrings;

    procedure SetListBoxDrawItem(Value: TbsDrawSkinItemEvent);
    procedure SetDropDownCount(Value: Integer);
    procedure DrawButton(C: TCanvas);
    procedure DrawResizeButton(C: TCanvas);
    procedure CalcRects;
    procedure WMTimer(var Message: TWMTimer); message WM_Timer;
    procedure WMSETFOCUS(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKILLFOCUS(var Message: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure WMSIZE(var Message: TWMSIZE); message WM_SIZE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState;
              X, Y: Integer);
    procedure GetSkinData; override;
    procedure WMMOUSEWHEEL(var Message: TMessage); message WM_MOUSEWHEEL;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;

    procedure DefaultFontChange; override;
    procedure CreateControlDefaultImage(B: TBitMap); override;
    procedure CreateControlSkinImage(B: TBitMap); override;
    procedure Change; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure EditUp1(AChange: Boolean);
    procedure EditDown1(AChange: Boolean);
    procedure EditPageUp1(AChange: Boolean);
    procedure EditPageDown1(AChange: Boolean);

    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure SetDefaultColor(Value: TColor);

    function GetDisabledFontColor: TColor;
  public
    FontName: String;
    FontStyle: TFontStyles;
    FontHeight: Integer;
    SItemRect, ActiveItemRect, FocusItemRect: TRect;
    ItemLeftOffset, ItemRightOffset: Integer;
    ItemTextRect: TRect;
    FontColor, ActiveFontColor, FocusFontColor: TColor;
    ButtonRect,
    ActiveButtonRect,
    DownButtonRect, UnEnabledButtonRect: TRect;
    ListBoxName: String;
    StretchEffect, ItemStretchEffect, FocusItemStretchEffect: Boolean;
    ActiveSkinRect: TRect;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeSkinData; override;
    procedure CloseUp(Value: Boolean);
    procedure DropDown; virtual;
    function IsPopupVisible: Boolean;
    function CanCancelDropDown: Boolean;
    procedure Invalidate; override;
  public
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor;
    property UseSkinSize: Boolean read FUseSkinSize write FUseSkinSize;
    property AlphaBlend: Boolean read FAlphaBlend write FAlphaBlend;
    property AlphaBlendAnimation: Boolean
      read FAlphaBlendAnimation write FAlphaBlendAnimation;
    property AlphaBlendValue: Byte read FAlphaBlendValue write FAlphaBlendValue;
    property Images: TCustomImageList read GetImages write SetImages;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    property ListBoxUseSkinItemHeight: Boolean
      read GetListBoxUseSkinItemHeight write SetListBoxUseSkinItemHeight;

    property ListBoxCaption: String read GetListBoxCaption
                                    write SetListBoxCaption;
    property ListBoxCaptionMode: Boolean read GetListBoxCaptionMode
                                    write SetListBoxCaptionMode;

    property ListBoxWidth: Integer read FListBoxWidth write FListBoxWidth;
    
    property ListBoxDefaultFont: TFont
      read GetListBoxDefaultFont write SetListBoxDefaultFont;

    property ListBoxUseSkinFont: Boolean
      read GetListBoxUseSkinFont write SetListBoxUseSkinFont;
    property ListBoxDefaultCaptionFont: TFont
      read GetListBoxDefaultCaptionFont write SetListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight: Integer
      read GetListBoxDefaultItemHeight write SetListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment: TAlignment
      read GetListBoxCaptionAlignment write SetListBoxCaptionAlignment;

    property Checked[Index: Integer]: Boolean read GetChecked write SetChecked;

    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    //
    property Text;
    property Align;
    property Items: TStrings read GetItems write SetItems;
    property DropDownCount: Integer read FDropDownCount write SetDropDownCount;
    property Font;
    property Sorted: Boolean read GetSorted write SetSorted;
    property OnListBoxDrawItem: TbsDrawSkinItemEvent
      read FOnListBoxDrawItem write SetListBoxDrawItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  end;

  TbsSkinCheckComboBox = class(TbsSkinCustomCheckComboBox)
  published
    property UseSkinSize;

    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;

    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property Images;
    property ImageIndex;
    property ListBoxWidth;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;

    property Enabled;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    //
    property DefaultColor;
    property Text;
    property Align;
    property Items;
    property DropDownCount;
    property Font;
    property Sorted;
    property OnListBoxDrawItem;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnDropDown;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
  end;

  TbsComboExItem = class(TCollectionItem)
  private
    FImageIndex: TImageIndex;
    FSelectedImageIndex: TImageIndex;
    FIndent: Integer;
    FCaption: String;
    FData: Pointer;
  protected
    procedure SetSelectedImageIndex(const Value: TImageIndex); virtual;
    procedure SetImageIndex(const Value: TImageIndex); virtual;
    procedure SetCaption(const Value: String); virtual;
    procedure SetData(const Value: Pointer); virtual;
    procedure SetIndex(Value: Integer); override;
  public
    constructor Create(Collection: TCollection); override;
    property Data: Pointer read FData write SetData;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: String read FCaption write SetCaption;
    property Indent: Integer read FIndent write FIndent default -1;
    property ImageIndex: TImageIndex read FImageIndex
      write SetImageIndex default -1;
    property SelectedImageIndex: TImageIndex read FSelectedImageIndex
      write SetSelectedImageIndex default -1;
  end;

  TbsSkinComboBoxEx = class;

  TbsComboExItems = class(TCollection)
  private
    function GetItem(Index: Integer):  TbsComboExItem;
    procedure SetItem(Index: Integer; Value:  TbsComboExItem);
  protected
    procedure SetComboBoxItem(Index: Integer);
    function GetOwner: TPersistent; override;
  public
    ComboBoxEx: TbsSkinComboBoxEx;
    constructor Create(AComboBoxEx: TbsSkinComboBoxEx);
    property Items[Index: Integer]:  TbsComboExItem read GetItem write SetItem; default;
    function Add: TbsComboExItem;
    function Insert(Index: Integer): TbsComboExItem;
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

  TbsSkinComboBoxEx = class(TbsSkinCustomComboBox)
  private
    FItemsEx: TbsComboExItems;
    procedure SetItemsEx(Value: TbsComboExItems);
    procedure ClearItemsEx;
  protected
    procedure DrawItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
    procedure ComboDrawItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
    procedure LoadItems;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ToolButtonStyle;
    property ItemsEx: TbsComboExItems read FItemsEx write SetItemsEx;
    property Style;
    property HideSelection;
    property AutoComplete;
    property ListBoxUseSkinFont;
    property ListBoxUseSkinItemHeight;
    property ListBoxWidth;
    property Images;
    property AlphaBlend;
    property AlphaBlendValue;
    property AlphaBlendAnimation;
    property ListBoxCaption;
    property ListBoxCaptionMode;
    property ListBoxDefaultFont;
    property ListBoxDefaultCaptionFont;
    property ListBoxDefaultItemHeight;
    property ListBoxCaptionAlignment;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation
Uses Consts, Printers, bsColorCtrls, bsConst,
     BusinessSkinForm, ShellAPI;

const
  WS_EX_LAYERED = $80000;
  CS_DROPSHADOW_ = $20000;
  CenturyOffset = 60;


{$IFNDEF VER200}
function MakeStr(C: Char; N: Integer): string;
begin
  if N < 1 then Result := ''
  else
  begin
    SetLength(Result, N);
    FillChar(Result[1], Length(Result), C);
  end;
end;
{$ELSE}
function MakeStr(C: Char; N: Integer): String;
var
  S: String;
begin
  if N < 1 then Result := ''
  else
  begin
    S := StringOfChar(C, N);
    Result := S;
  end;
end;
{$ENDIF}


//=========== TbsSkinUpDown ===============

constructor TbsSkinUpDown.Create;
begin
  inherited;
  SkinDataName := 'hupdown';
  FUseSkinSize := True;
  FMin := 0;
  FMax := 100;
  FIncrement := 1;
  FPosition := 0;
  Width := 50;
  Height := 25;
  ActiveButton := -1;
  OldActiveButton := -1;
  CaptureButton := -1;
  TimerMode := 0;
  WaitMode := False;
end;

destructor TbsSkinUpDown.Destroy;
begin
  inherited;
end;

procedure TbsSkinUpDown.CalcSize;
begin
  if FUseSkinSize then inherited;
end;

procedure TbsSkinUpDown.SetControlRegion;
begin
  if FUseSkinSize then inherited;
end;

procedure TbsSkinUpDown.SetOrientation;
begin
  FOrientation := Value;
  RePaint;
  if (csDesigning in ComponentState) and not
     (csLoading in ComponentState)
  then
    begin
      if FOrientation = udHorizontal
      then FSkinDataName := 'hupdown'
      else FSkinDataName := 'vupdown';
    end;
end;

procedure TbsSkinUpDown.CreateControlSkinImage;
var
  i: Integer;
begin
  if FUseSkinSize
  then
    begin
      inherited;
      for i := 0 to 1 do DrawButton(B.Canvas, i)
    end
  else
    for i := 0 to 1 do DrawResizeButton(B.Canvas, i)
end;

procedure TbsSkinUpDown.WMSIZE;
begin
  inherited;
  CalcRects;
end;

procedure TbsSkinUpDown.CreateControlDefaultImage;
var
  i: Integer;
begin
  CalcRects;
  for i := 0 to 1 do DrawButton(B.Canvas, i);
end;

procedure TbsSkinUpDown.CMMouseEnter;
begin
  ActiveButton := -1;
  OldActiveButton := -1;
  inherited;
end;

procedure TbsSkinUpDown.CMMouseLeave;
var
  i: Integer;
begin
  ActiveButton := -1;
  OldActiveButton := -1;
  inherited;
  for i := 0 to 1 do
    if Buttons[i].MouseIn
    then
       begin
         Buttons[i].MouseIn := False;
         RePaint;
       end;
end;

procedure TbsSkinUpDown.DrawResizeButton(Cnvs: TCanvas; i: Integer);
var
  Buffer: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  BtnCLRect: TRect;
  BSR, ABSR, DBSR, R1: TRect;
  XO, YO: Integer;
  ArrowColor: TColor;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(Buttons[i].R);
  Buffer.Height := RectHeight(Buttons[i].R);
  //
  CIndex := SkinData.GetControlIndex('resizebutton');
  if CIndex = -1
  then
    begin
      Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
    XO := RectWidth(Buttons[i].R) - RectWidth(SkinRect);
    YO := RectHeight(Buttons[i].R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if Buttons[i].Down and Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := DownFontColor;
      end
    else
    if Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := FontColor;
      end;
     if not Self.Enabled then ArrowColor := DisabledFontColor;
   end;
  //
  Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
  //
  R1 := Buttons[i].R;
  if FOrientation = udVertical
  then
    begin
      case i of
        0: DrawArrowImage(Cnvs, R1, ArrowColor, 3);
        1: DrawArrowImage(Cnvs, R1, ArrowColor, 4);
      end
    end
  else
    begin
      case i of
        1: DrawArrowImage(Cnvs, R1, ArrowColor, 1);
        0: DrawArrowImage(Cnvs, R1, ArrowColor, 2);
      end
    end;
  //
  Buffer.Free;
end;

procedure TbsSkinUpDown.DrawButton;
var
  C: TColor;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Buttons[i] do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          Cnvs.Brush.Color := BS_BTNDOWNCOLOR;
          Cnvs.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            Cnvs.Brush.Color := BS_BTNACTIVECOLOR;
            Cnvs.FillRect(R1);
          end
        else
          begin
            Frame3D(Cnvs, R1, clBtnShadow, clBtnShadow, 1);
            Cnvs.Brush.Color := clBtnFace;
            Cnvs.FillRect(R1);
          end;
      if Self.Enabled then C := clBlack else C := clGray;
      if FOrientation = udVertical
      then
        case i of
          0: DrawArrowImage(Cnvs, R, C, 3);
          1: DrawArrowImage(Cnvs, R, C, 4);
        end
      else
        case i of
          1: DrawArrowImage(Cnvs, R, C, 1);
          0: DrawArrowImage(Cnvs, R, C, 2);
        end
    end
  else
    with Buttons[i] do
    begin
      R1 := NullRect;
      case I of
        0:
          begin
            if Down and MouseIn
            then R1 := DownUpButtonRect
            else if MouseIn then R1 := ActiveUpButtonRect;
          end;
        1:
          begin
            if Down and MouseIn
            then R1 := DownDownButtonRect
            else if MouseIn then R1 := ActiveDownButtonRect;
          end
      end;
      if not IsNullRect(R1)
      then
        Cnvs.CopyRect(R, Picture.Canvas, R1);
    end;
end;

procedure TbsSkinUpDown.MouseDown;
begin
  TestActive(X, Y);
  if ActiveButton = 0
  then
    OldActiveButton := 1
  else
    OldActiveButton := 0;
  Buttons[OldActiveButton].MouseIn := False;
  if ActiveButton <> -1
  then
    begin
      CaptureButton := ActiveButton;
      ButtonDown(ActiveButton, X, Y);
    end;
  inherited;
end;

procedure TbsSkinUpDown.MouseUp;
begin
  if CaptureButton <> -1
  then ButtonUp(CaptureButton, X, Y);
  CaptureButton := -1;
  inherited;
end;

procedure TbsSkinUpDown.MouseMove;
begin
  TestActive(X, Y);
  inherited;
end;

procedure TbsSkinUpDown.TestActive(X, Y: Integer);
var
  i, j: Integer;
begin
  j := -1;
  OldActiveButton := ActiveButton;
  for i := 0 to 1 do
  begin
    if PointInRect(Buttons[i].R, Point(X, Y))
    then
      begin
        j := i;
        Break;
      end;
  end;

  ActiveButton := j;

  if (CaptureButton <> -1) and
     (ActiveButton <> CaptureButton) and (ActiveButton <> -1)
  then
    ActiveButton := -1;

  if (OldActiveButton <> ActiveButton)
  then
    begin
      if OldActiveButton <> - 1
      then
        ButtonLeave(OldActiveButton);

      if ActiveButton <> -1
      then
        ButtonEnter(ActiveButton);
    end;
end;

procedure TbsSkinUpDown.ButtonDown;
begin
  Buttons[i].MouseIn := True;
  Buttons[i].Down := True;
  RePaint;
  if FIncrement <> 0
  then
    begin
      case i of
        0: TimerMode := 2;
        1: TimerMode := 1;
      end;
      WaitMode := True;
      SetTimer(Handle, 1, 500, nil);
    end;  
end;

procedure TbsSkinUpDown.ButtonUp;
begin
  if FIncrement <> 0 then StopTimer;
  Buttons[i].Down := False;
  if ActiveButton <> i then Buttons[i].MouseIn := False;
  RePaint;
  if Buttons[i].MouseIn
  then
  case i of
    0:
      begin
        if FIncrement <> 0 then Position := Position + FIncrement;
        if Assigned(FOnUpButtonClick) then FOnUpButtonClick(Self);
      end;
     1:
       begin
         if FIncrement <> 0 then Position := Position - FIncrement;
         if Assigned(FOnDownButtonClick) then FOnDownButtonClick(Self);
       end;
  end;
end;

procedure TbsSkinUpDown.ButtonEnter(I: Integer);
begin
  if i = 0
  then
    OldActiveButton := 1
  else
    OldActiveButton := 0;
  Buttons[OldActiveButton].MouseIn := False;
  Buttons[i].MouseIn := True;
  RePaint;
  if (FIncrement <> 0) and Buttons[i].Down then SetTimer(Handle, 1, 50, nil);
end;

procedure TbsSkinUpDown.ButtonLeave(I: Integer);
begin
  Buttons[i].MouseIn := False;
  RePaint;
  if (FIncrement <> 0) and Buttons[i].Down then KillTimer(Handle, 1);
end;

procedure TbsSkinUpDown.CalcRects;
var
  OX: Integer;
  NewClRect: TRect;
begin
  if (FIndex = -1) or not UseSkinSize
  then
    begin
      if FOrientation = udVertical
      then
        begin
          Buttons[0].R := Rect(0, 0, Width, Height div 2);
          Buttons[1].R := Rect(0, Height div 2, Width, Height);
        end
      else
        begin
          Buttons[1].R := Rect(0, 0, Width div 2, Height);
          Buttons[0].R := Rect(Width div 2, 0, Width, Height);
        end;
    end
  else
    begin
      Buttons[0].R := UpButtonRect;
      Buttons[1].R := DownButtonRect;
    end;
end;

procedure TbsSkinUpDown.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 100, nil);
end;

procedure TbsSkinUpDown.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinUpDown.WMTimer;
var
  CanScroll: Boolean;
begin
  inherited;
  if WaitMode
  then
    begin
      WaitMode := False;
      StartTimer;
      Exit;
    end;
  case TimerMode of
    1: Position := Position - FIncrement;
    2: Position := Position + FIncrement;
  end;
end;

procedure TbsSkinUpDown.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinUpDownControl
    then
      with TbsDataSkinUpDownControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.UpButtonRect := UpButtonRect;
        Self.ActiveUpButtonRect := ActiveUpButtonRect;
        Self.DownUpButtonRect := DownUpButtonRect;
        if IsNullRect(Self.DownUpButtonRect)
        then Self.DownUpButtonRect := Self.ActiveUpButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.ActiveDownButtonRect := ActiveDownButtonRect;
        Self.DownDownButtonRect := DownDownButtonRect;
        if IsNullRect(Self.DownDownButtonRect)
        then Self.DownDownButtonRect := Self.ActiveDownButtonRect;
        LTPt := Point(0, 0);
        RTPt := Point(0, 0);
        LBPt := Point(0, 0);
        RBPt := Point(0, 0);
        ClRect := NullRect;
      end;
  CalcRects;    
end;

procedure TbsSkinUpDown.SetIncrement;
begin
  FIncrement := Value;
end;

procedure TbsSkinUpDown.SetPosition;
begin
  if (Value <= FMax) and (Value >= FMin)
  then
    begin
      FPosition := Value;
      if not (csDesigning in ComponentState) and Assigned(FOnChange)
      then
        FOnChange(Self);
    end;
end;

procedure TbsSkinUpDown.SetMin;
begin
  FMin := Value;
  if FPosition < FMin then FPosition := FMin;
end;

procedure TbsSkinUpDown.SetMax;
begin
  FMax := Value;
  if FPosition > FMax then FPosition := FMax;
end;

// TbsSkinIntUpDown

constructor TbsSkinIntUpDown.Create;
begin
  inherited;
  SkinDataName := 'hupdown';
  FOnUpChange := nil;
  FOnDownChange := nil;
  FUseSkinSize := True;
  FMin := 0;
  FMax := 100;
  FIncrement := 1;
  FPosition := 0;
  Width := 50;
  Height := 25;
  ActiveButton := -1;
  OldActiveButton := -1;
  CaptureButton := -1;
  TimerMode := 0;
  WaitMode := False;
end;

destructor TbsSkinIntUpDown.Destroy;
begin
  inherited;
end;

procedure TbsSkinIntUpDown.CalcSize;
begin
end;

procedure TbsSkinIntUpDown.SetControlRegion;
begin
end;

procedure TbsSkinIntUpDown.SetOrientation;
begin
  FOrientation := Value;
  RePaint;
  if (csDesigning in ComponentState) and not
     (csLoading in ComponentState)
  then
    begin
      if FOrientation = udHorizontal
      then FSkinDataName := 'hupdown'
      else FSkinDataName := 'vupdown';
    end;
end;

procedure TbsSkinIntUpDown.CreateControlSkinImage;
var
  i: Integer;
begin
  for i := 0 to 1 do DrawResizeButton(B.Canvas, i)
end;

procedure TbsSkinIntUpDown.WMSIZE;
begin
  inherited;
  CalcRects;
end;

procedure TbsSkinIntUpDown.CreateControlDefaultImage;
var
  i: Integer;
begin
  CalcRects;
  for i := 0 to 1 do DrawButton(B.Canvas, i);
end;

procedure TbsSkinIntUpDown.CMMouseEnter;
begin
  ActiveButton := -1;
  OldActiveButton := -1;
  inherited;
end;

procedure TbsSkinIntUpDown.CMMouseLeave;
var
  i: Integer;
begin
  ActiveButton := -1;
  OldActiveButton := -1;
  inherited;
  for i := 0 to 1 do
    if Buttons[i].MouseIn
    then
       begin
         Buttons[i].MouseIn := False;
         RePaint;
       end;
end;

procedure TbsSkinIntUpDown.DrawResizeButton(Cnvs: TCanvas; i: Integer);
var
  Buffer: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  BtnCLRect, SR: TRect;
  BSR, ABSR, DBSR, R1: TRect;
  XO, YO, X, Y: Integer;
  ArrowColor: TColor;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(Buttons[i].R);
  Buffer.Height := RectHeight(Buttons[i].R);
  //
  CIndex := SkinData.GetControlIndex('combobutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('resizetoolbutton');
  if CIndex = -1
  then
    begin
      Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
     //
    if Buttons[i].Down and Buttons[i].MouseIn and not IsNullRect(MenuMarkerDownRect)
    then SR := MenuMarkerDownRect else
      if Buttons[i].MouseIn and not IsNullRect(MenuMarkerActiveRect)
        then SR := MenuMarkerActiveRect else SR := MenuMarkerRect;
    //
    XO := RectWidth(Buttons[i].R) - RectWidth(SkinRect);
    YO := RectHeight(Buttons[i].R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if Buttons[i].Down and Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        if not IsNullRect(SR)
        then
          begin
            X := SR.Left + RectWidth(SR) div 2;
            Y := SR.Top + 3;
            ArrowColor := BtnSkinPicture.Canvas.Pixels[X, Y];
          end
        else
          ArrowColor := DownFontColor;
      end
    else
    if Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        if not IsNullRect(SR)
        then
          begin
            X := SR.Left + RectWidth(SR) div 2;
            Y := SR.Top + 3;
            ArrowColor := BtnSkinPicture.Canvas.Pixels[X, Y];
          end
        else
          ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        if not IsNullRect(SR)
        then
          begin
            X := SR.Left + RectWidth(SR) div 2;
            Y := SR.Top + 3;
            ArrowColor := BtnSkinPicture.Canvas.Pixels[X, Y];
          end
        else
          ArrowColor := FontColor;
      end;
   end;
  //
  Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
  //
  R1 := Buttons[i].R;
  {if Buttons[i].Down and Buttons[i].MouseIn
  then
    begin
      Inc(R1.Left, 2);
      Inc(R1.Top, 2);
    end;}  
  if FOrientation = udVertical
  then
    begin
      case i of
        0: DrawArrowImage3(Cnvs, R1, ArrowColor, 3);
        1: DrawArrowImage3(Cnvs, R1, ArrowColor, 4);
      end
    end
  else
    begin
      case i of
        1: DrawArrowImage3(Cnvs, R1, ArrowColor, 1);
        0: DrawArrowImage3(Cnvs, R1, ArrowColor, 2);
      end
    end;
  //
  Buffer.Free;
end;

procedure TbsSkinIntUpDown.DrawButton;
var
  C: TColor;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Buttons[i] do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          Cnvs.Brush.Color := BS_BTNDOWNCOLOR;
          Cnvs.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            Cnvs.Brush.Color := BS_BTNACTIVECOLOR;
            Cnvs.FillRect(R1);
          end
        else
          begin
            Frame3D(Cnvs, R1, clBtnShadow, clBtnShadow, 1);
            Cnvs.Brush.Color := clBtnFace;
            Cnvs.FillRect(R1);
          end;
      C := clBlack;
      if FOrientation = udVertical
      then
        case i of
          0: DrawArrowImage(Cnvs, R, C, 3);
          1: DrawArrowImage(Cnvs, R, C, 4);
        end
      else
        case i of
          1: DrawArrowImage(Cnvs, R, C, 1);
          0: DrawArrowImage(Cnvs, R, C, 2);
        end
    end
  else
    with Buttons[i] do
    begin
      R1 := NullRect;
      case I of
        0:
          begin
            if Down and MouseIn
            then R1 := DownUpButtonRect
            else if MouseIn then R1 := ActiveUpButtonRect;
          end;
        1:
          begin
            if Down and MouseIn
            then R1 := DownDownButtonRect
            else if MouseIn then R1 := ActiveDownButtonRect;
          end
      end;
      if not IsNullRect(R1)
      then
        Cnvs.CopyRect(R, Picture.Canvas, R1);
    end;
end;

procedure TbsSkinIntUpDown.MouseDown;
begin
  TestActive(X, Y);
  if ActiveButton = 0
  then
    OldActiveButton := 1
  else
    OldActiveButton := 0;
  Buttons[OldActiveButton].MouseIn := False;
  if ActiveButton <> -1
  then
    begin
      CaptureButton := ActiveButton;
      ButtonDown(ActiveButton, X, Y);
    end;
  inherited;
end;

procedure TbsSkinIntUpDown.MouseUp;
begin
  if CaptureButton <> -1
  then ButtonUp(CaptureButton, X, Y);
  CaptureButton := -1;
  inherited;
end;

procedure TbsSkinIntUpDown.MouseMove;
begin
  TestActive(X, Y);
  inherited;
end;

procedure TbsSkinIntUpDown.TestActive(X, Y: Integer);
var
  i, j: Integer;
begin
  j := -1;
  OldActiveButton := ActiveButton;
  for i := 0 to 1 do
  begin
    if PointInRect(Buttons[i].R, Point(X, Y))
    then
      begin
        j := i;
        Break;
      end;
  end;

  ActiveButton := j;

  if (CaptureButton <> -1) and
     (ActiveButton <> CaptureButton) and (ActiveButton <> -1)
  then
    ActiveButton := -1;

  if (OldActiveButton <> ActiveButton)
  then
    begin
      if OldActiveButton <> - 1
      then
        ButtonLeave(OldActiveButton);

      if ActiveButton <> -1
      then
        ButtonEnter(ActiveButton);
    end;
end;

procedure TbsSkinIntUpDown.ButtonDown;
begin
  Buttons[i].MouseIn := True;
  Buttons[i].Down := True;
  RePaint;
  if FIncrement <> 0
  then
    begin
      case i of
        0: TimerMode := 2;
        1: TimerMode := 1;
      end;
      WaitMode := True;
      SetTimer(Handle, 1, 500, nil);
    end;  
end;

procedure TbsSkinIntUpDown.ButtonUp;
begin
  if FIncrement <> 0 then StopTimer;
  Buttons[i].Down := False;
  if ActiveButton <> i then Buttons[i].MouseIn := False;
  RePaint;
  if Buttons[i].MouseIn
  then
  case i of
    0:
      begin
        if FIncrement <> 0 then Position := Position + FIncrement;
        if Assigned(FOnUpButtonClick) then FOnUpButtonClick(Self);
      end;
     1:
       begin
         if FIncrement <> 0 then Position := Position - FIncrement;
         if Assigned(FOnDownButtonClick) then FOnDownButtonClick(Self);
       end;
  end;
end;

procedure TbsSkinIntUpDown.ButtonEnter(I: Integer);
begin
  if i = 0
  then
    OldActiveButton := 1
  else
    OldActiveButton := 0;
  Buttons[OldActiveButton].MouseIn := False;
  Buttons[i].MouseIn := True;
  RePaint;
  if (FIncrement <> 0) and Buttons[i].Down then SetTimer(Handle, 1, 50, nil);
end;

procedure TbsSkinIntUpDown.ButtonLeave(I: Integer);
begin
  Buttons[i].MouseIn := False;
  RePaint;
  if (FIncrement <> 0) and Buttons[i].Down then KillTimer(Handle, 1);
end;

procedure TbsSkinIntUpDown.CalcRects;
var
  OX: Integer;
  NewClRect: TRect;
begin
  if FOrientation = udVertical
  then
    begin
      Buttons[0].R := Rect(0, 0, Width, Height div 2);
      Buttons[1].R := Rect(0, Height div 2, Width, Height);
   end
  else
    begin
      Buttons[1].R := Rect(0, 0, Width div 2, Height);
      Buttons[0].R := Rect(Width div 2, 0, Width, Height);
   end;
end;

procedure TbsSkinIntUpDown.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 100, nil);
end;

procedure TbsSkinIntUpDown.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinIntUpDown.WMTimer;
var
  CanScroll: Boolean;
begin
  inherited;
  if WaitMode
  then
    begin
      WaitMode := False;
      StartTimer;
      Exit;
    end;
  case TimerMode of
    1:
     begin
       Position := Position - FIncrement;
       if Assigned(FOnDownChange) then FOnDownChange(Self);
     end;
    2:
     begin
       Position := Position + FIncrement;
       if Assigned(FOnUpChange) then FOnUpChange(Self);
     end;
  end;
end;

procedure TbsSkinIntUpDown.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinUpDownControl
    then
      with TbsDataSkinUpDownControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.UpButtonRect := UpButtonRect;
        Self.ActiveUpButtonRect := ActiveUpButtonRect;
        Self.DownUpButtonRect := DownUpButtonRect;
        if IsNullRect(Self.DownUpButtonRect)
        then Self.DownUpButtonRect := Self.ActiveUpButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.ActiveDownButtonRect := ActiveDownButtonRect;
        Self.DownDownButtonRect := DownDownButtonRect;
        if IsNullRect(Self.DownDownButtonRect)
        then Self.DownDownButtonRect := Self.ActiveDownButtonRect;
        LTPt := Point(0, 0);
        RTPt := Point(0, 0);
        LBPt := Point(0, 0);
        RBPt := Point(0, 0);
        ClRect := NullRect;
      end;
  CalcRects;    
end;

procedure TbsSkinIntUpDown.SetIncrement;
begin
  FIncrement := Value;
end;

procedure TbsSkinIntUpDown.SetPosition;
begin
  if (Value <= FMax) and (Value >= FMin)
  then
    begin
      FPosition := Value;
      if not (csDesigning in ComponentState) and Assigned(FOnChange)
      then
        FOnChange(Self);
    end;
end;

procedure TbsSkinIntUpDown.SetMin;
begin
  FMin := Value;
  if FPosition < FMin then FPosition := FMin;
end;

procedure TbsSkinIntUpDown.SetMax;
begin
  FMax := Value;
  if FPosition > FMax then FPosition := FMax;
end;

constructor TbsSkinSpinEdit.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks, csAcceptsControls];
  FDefaultColor := clWindow;
  FUseSkinSize := True;
  ActiveButton := -1;
  OldActiveButton := -1;
  CaptureButton := -1;
  FValue := 0;
  FromEdit := False;
  FEdit := TbsSkinNumEdit.Create(Self);
  FEdit.Font.Assign(FDefaultFont);
  FEdit.Color := FDefaultColor;
  FIncrement := 1;
  FDecimal := 2;
  TimerMode := 0;
  WaitMode := False;
  FEdit.Parent := Self;
  FEdit.AutoSize := False;
  FEdit.Visible := True;
  FEdit.EditTransparent := False;
  FEdit.OnChange := EditChange;
  FEdit.OnUpClick := UpClick;
  FEdit.OnDownClick := DownClick;
  FEdit.OnKeyUp := EditKeyUp;
  FEdit.OnKeyDown := EditKeyDown;
  FEdit.OnKeyPress := EditKeyPress;
  FEdit.OnEnter := EditEnter;
  FEdit.OnExit := EditExit;
  FEdit.OnMouseEnter := EditMouseEnter;
  FEdit.OnMouseLeave := EditMouseLeave;
  StopCheck := True;
  Text := '0';
  StopCheck := False;
  Width := 120;
  Height := 20;
  FSkinDataName := 'spinedit';
end;

destructor TbsSkinSpinEdit.Destroy;
begin
  FEdit.Free;
  inherited;
end;

procedure TbsSkinSpinEdit.SetDefaultColor(Value: TColor);
begin
  FDefaultColor := Value;
  if (FIndex = -1) and (FEdit <> nil) then FEdit.Color := FDefaultColor;
end;

procedure TbsSkinSpinEdit.PaintSkinTo(C: TCanvas; X, Y: Integer; AText: String);
var
  B: TBitMap;
  R: TRect;
begin
  B := TBitmap.Create;
  B.Width := Width;
  B.Height := Height;
  GetSkinData;
  if Findex = -1
  then
    begin
      CreateControlDefaultImage(B);
    end
  else
    begin
      CreateControlSkinImage(B);
    end;
  // draw text
  R := Rect(FEdit.Left, FEdit.Top,
  FEdit.Left + FEdit.Width, FEdit.Top + FEdit.Height);
  B.Canvas.Font.Assign(FEdit.Font);
  B.Canvas.Brush.Style := bsClear;
  InflateRect(R, -2, 0);
  DrawText(B.Canvas.Handle, PChar(AText), Length(AText), R, DT_LEFT);
  C.Draw(X, Y, B);
  B.Free;  
end;

procedure TbsSkinSpinEdit.WMEraseBkgnd;
begin
  if not FromWMPaint
  then
    begin
      PaintWindow(Msg.DC);
    end;
end;

procedure TbsSkinSpinEdit.SetControlRegion;
begin
  if FUseSkinSize then inherited;
end;

procedure TbsSkinSpinEdit.CalcSize(var W, H: Integer);
var
  XO, YO: Integer;
begin
  if FUseSkinSize
  then
    inherited
  else
    begin
      XO := W - RectWidth(SkinRect);
      YO := H - RectHeight(SkinRect);
      NewLTPoint := LTPt;
      NewRTPoint := Point(RTPt.X + XO, RTPt.Y );
      NewClRect := ClRect;
      Inc(NewClRect.Right, XO);
    end;
end;

procedure TbsSkinSpinEdit.AdjustEditHeight;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  if FEdit = nil then Exit;
  DC := GetDC(0);
  SaveFont := SelectObject(DC, FEdit.Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  FEdit.Height := Metrics.tmHeight;
end;

procedure TbsSkinSpinEdit.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  if Focused and (FEdit <> nil) and FEdit.HandleAllocated
  then
    begin
      FEdit.SetFocus;
    end;
end;

procedure TbsSkinSpinEdit.CMEnabledChanged;
begin
  inherited;
  if not Enabled
  then
    begin
      if FIndex = -1
      then
        FEdit.Font.Color := clGrayText
      else
        FEdit.Font.Color := DisabledFontColor;
    end
  else
    if FIndex = -1
    then
      FEdit.Font.Color := FDefaultFont.Color
    else
      FEdit.Font.Color := FontColor;
end;

procedure TbsSkinSpinEdit.SetValueType(NewType: TbsValueType);
begin
  if FValueType <> NewType
  then
    begin
      FEdit.Float := ValueType = vtFloat;
      FValueType := NewType;
      if FValueType = vtInteger
      then
        begin
          FIncrement := Round(FIncrement);
          if FIncrement = 0 then FIncrement := 1;
        end;
  end;
  FEdit.Float := ValueType = vtFloat;
end;

procedure TbsSkinSpinEdit.SetDecimal(NewValue: Byte);
begin
  if FDecimal <> NewValue then begin
    FDecimal := NewValue;
  end;
end;

procedure TbsSkinSpinEdit.Change;
begin
  StopCheck := True;
  if Assigned(FOnChange) then FOnChange(Self);
  StopCheck := False;
end;

procedure TbsSkinSpinEdit.DefaultFontChange;
begin
  if ((FIndex = -1) or not FUseSkinFont) and (FEdit <> nil)
  then
    begin
      FEdit.Font.Assign(FDefaultFont);
      AdjustEditHeight;
    end;
end;

procedure TbsSkinSpinEdit.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinSpinEditControl
    then
      with TbsDataSkinSpinEditControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.ActiveSkinRect := ActiveSkinRect;
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.DisabledFontColor := DisabledFontColor;
        Self.UpButtonRect := UpButtonRect;
        Self.ActiveUpButtonRect := ActiveUpButtonRect;
        Self.DownUpButtonRect := DownUpButtonRect;
        if IsNullRect(Self.DownUpButtonRect)
        then Self.DownUpButtonRect := Self.ActiveUpButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.ActiveDownButtonRect := ActiveDownButtonRect;
        Self.DownDownButtonRect := DownDownButtonRect;
        if IsNullRect(Self.DownDownButtonRect)
        then Self.DownDownButtonRect := Self.ActiveDownButtonRect;
        LOffset := LTPoint.X;
        ROffset := RectWidth(SkinRect) - RTPoint.X;
      end;
end;

procedure TbsSkinSpinEdit.ChangeSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    with FEdit.Font do
    begin
      if FUseSkinFont
      then
        begin
          Style := FontStyle;
          Color := FontColor;
          Height := FontHeight;
          Name := FontName;
        end
      else
        begin
          Assign(FDefaultFont);
          Color := FontColor;
        end;
    end
  else
    FEdit.Font.Assign(FDefaultFont);
  //
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    FEdit.Font.Charset := SkinData.ResourceStrData.CharSet
  else
    FEdit.Font.CharSet := FDefaultFont.CharSet;
  //
  if FIndex <> -1
  then
    begin
      FEdit.EditTransparent := True;
      if FUseSkinSize
      then
        Height := RectHeight(SkinRect);
    end
  else
    begin
      FEdit.EditTransparent := False;
    end;
  CalcRects;
  if not Enabled
  then
    begin
      if FIndex = -1
      then
        FEdit.Font.Color := clGrayText
      else
        FEdit.Font.Color := DisabledFontColor;
    end
  else
    if FIndex = -1
    then
      FEdit.Font.Color := FDefaultFont.Color
    else
      if FMouseIn or FEditFocused
      then
        FEdit.Font.Color := ActiveFontColor
      else
        FEdit.Font.Color := FontColor;
  RePaint;   
end;

procedure TbsSkinSpinEdit.EditEnter;
var
  S1, S2: String;
begin
  if Assigned(FOnEditEnter) then FOnEditEnter(Self);
  FEditFocused := True;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
  then
    RePaint;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor)
  then
    FEdit.Font.Color := ActiveFontColor;
end;

procedure TbsSkinSpinEdit.EditExit;
begin
  if Assigned(FOnEditExit) then FOnEditExit(Self);
  FEditFocused := False;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
  then
    RePaint;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor)
  then
    if not FMouseIn then
      FEdit.Font.Color := FontColor;
  //
  StopCheck := True;
  if ValueType = vtFloat
  then FEdit.Text := FloatToStrF(FValue, ffFixed, 15, FDecimal)
  else FEdit.Text := IntToStr(Round(FValue));
  StopCheck := False;
end;

procedure TbsSkinSpinEdit.EditMouseEnter(Sender: TObject);
begin
  FMouseIn := True;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) and not FEditFocused
  then
    RePaint;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor) and not FEditFocused
  then
    FEdit.Font.Color := ActiveFontColor;
end;

procedure TbsSkinSpinEdit.EditMouseLeave(Sender: TObject);
begin
  FMouseIn := False;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) and not FEditFocused
  then
    RePaint;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor) and not FEditFocused
  then
    FEdit.Font.Color := FontColor;
end;

procedure TbsSkinSpinEdit.EditKeyDown;
begin
  if Assigned(FOnEditKeyDown) then FOnEditKeyDown(Self, Key, Shift);
end;

procedure TbsSkinSpinEdit.EditKeyUp;
begin
  if Assigned(FOnEditKeyUp) then FOnEditKeyUp(Self, Key, Shift);
end;

procedure TbsSkinSpinEdit.EditKeyPress;
begin
  if Assigned(FOnEditKeyPress) then FOnEditKeyPress(Self, Key);
end;

procedure TbsSkinSpinEdit.UpClick;
begin
  Value := Value + FIncrement;
  if Assigned(FOnUpButtonClick)
   then
     FOnUpButtonClick(Self);
end;

procedure TbsSkinSpinEdit.DownClick;
begin
  Value := Value - FIncrement;
  if Assigned(FOnDownButtonClick)
  then
    FOnDownButtonClick(Self);
end;

procedure TbsSkinSpinEdit.SetMaxLength;
begin
  FEdit.MaxLength := AValue;
end;

function  TbsSkinSpinEdit.GetMaxLength;
begin
  Result := FEdit.MaxLength;
end;

procedure TbsSkinSpinEdit.SetEditorEnabled;
begin
  FEdit.EditorEnabled := AValue;
end;

function  TbsSkinSpinEdit.GetEditorEnabled;
begin
  Result := FEdit.EditorEnabled;
end;

procedure TbsSkinSpinEdit.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 100, nil);
end;

procedure TbsSkinSpinEdit.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

function TbsSkinSpinEdit.CheckValue;
begin
  Result := NewValue;
  if FMaxValue <> FMinValue
  then
    begin
      if NewValue < FMinValue then
      Result := FMinValue
      else if NewValue > FMaxValue then
      Result := FMaxValue;
    end;
end;

procedure TbsSkinSpinEdit.WMTimer;
var
  CanScroll: Boolean;
begin
  inherited;
  if WaitMode
  then
    begin
      WaitMode := False;
      StartTimer;
      Exit;
    end;
  case TimerMode of
    1: Value := Value - FIncrement;
    2: Value := Value + FIncrement;
  end;
end;

procedure TbsSkinSpinEdit.SetMinValue;
begin
  FMinValue := AValue;
  if Value < FMinValue then Value := FMinValue;
end;

procedure TbsSkinSpinEdit.SetMaxValue;
var
  S: String;
begin
  FMaxValue := AValue;
  if Value > FMaxValue then Value := FMaxValue;
end;

procedure TbsSkinSpinEdit.CMMouseEnter;
begin
  inherited;
  TestActive(-1, -1);
  if not FEditFocused and (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
  then
    begin
      FMouseIn := True;
      RePaint;
    end;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor) and not FEditFocused
  then
    FEdit.Font.Color := ActiveFontColor;
    
end;

function TbsSkinSpinEdit.IsNumText;

function GetMinus: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  i := Pos('-', S);
  if i > 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos('-', S) = 0;
    end;
end;

function GetP: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  {$IFDEF VER240_UP}
  i := Pos(FormatSettings.DecimalSeparator, S);
  {$ELSE}
  i := Pos(DecimalSeparator, S);
  {$ENDIF}
  if i = 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, S) = 0;
    end;
end;

const
  EditChars = '01234567890-';
var
  i: Integer;
  S: String;
begin
  S := EditChars;
  Result := True;
  if ValueType = vtFloat
  then
    S := S + {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator;
  if (Text = '') or (Text = '-')
  then
    begin
      Result := False;
      Exit;
    end;

  for i := 1 to Length(Text) do
  begin
    if Pos(Text[i], S) = 0
    then
      begin
        Result := False;
        Break;
      end;
  end;

  Result := Result and GetMinus;

  if ValueType = vtFloat
  then
    Result := Result and GetP;

end;

procedure TbsSkinSpinEdit.CMTextChanged;
var
  NewValue, TmpValue: Double;

function CheckInput: Boolean;
begin
  if (NewValue < 0) and (TmpValue < 0)
  then
    Result := NewValue > TmpValue
  else
    Result := NewValue < TmpValue;

  if not Result and ( ((FMinValue > 0) and (TmpValue < 0))
    or ((FMaxValue < 0) and (TmpValue > 0)))
  then
    Result := True;
end;

begin
  inherited;
  if (FEdit <> nil) and not FromEdit then FEdit.Text := Text;
  if not StopCheck and IsNumText(FEdit.Text)
  then
    begin
      if ValueType = vtFloat
      then TmpValue := StrToFloat(FEdit.Text)
      else TmpValue := StrToInt(FEdit.Text);
      NewValue := CheckValue(TmpValue);
      if NewValue <> FValue
      then
        begin
          FValue := NewValue;
          Change;
        end;
      if CheckInput
      then
        begin
          StopCheck := True;
          if ValueType = vtFloat
          then FEdit.Text := FloatToStrF(NewValue, ffFixed, 15, FDecimal)
          else FEdit.Text := IntToStr(Round(FValue));
          StopCheck := False;
        end;
    end;
end;

procedure TbsSkinSpinEdit.CMMouseLeave;
var
  i: Integer;
  P: TPoint;
begin
  inherited;
  for i := 0 to 1 do
    if Buttons[i].MouseIn
    then
       begin
         Buttons[i].MouseIn := False;
         RePaint;
       end;
  GetCursorPos(P);
  if not (WindowFromPoint(P) = FEdit.Handle) and not FEditFocused and (FIndex <> -1)
     and not IsNullRect(ActiveSkinRect)
  then
    begin
      FMouseIn := False;
      RePaint;
    end;
  if (FIndex <> -1) and (ActiveFontColor <> FontColor) and not FEditFocused and
     not (WindowFromPoint(P) = FEdit.Handle)
  then
    FEdit.Font.Color := FontColor;
end;

procedure TbsSkinSpinEdit.EditChange;
begin
  FromEdit := True;
  Text := FEdit.Text;
  FromEdit := False;
end;

procedure TbsSkinSpinEdit.Invalidate;
begin
  inherited;
  if (FIndex <> -1) and (FEdit <> nil) then FEdit.DoPaint;
end;

procedure TbsSkinSpinEdit.WMSIZE;
begin
  inherited;
  CalcRects;
end;

procedure TbsSkinSpinEdit.TestActive(X, Y: Integer);
var
  i, j: Integer;
begin
  j := -1;
  OldActiveButton := ActiveButton;
  for i := 0 to 1 do
  begin
    if PtInRect(Buttons[i].R, Point(X, Y))
    then
      begin
        j := i;
        Break;
      end;
  end;

  ActiveButton := j;

  if (CaptureButton <> -1) and
     (ActiveButton <> CaptureButton) and (ActiveButton <> -1)
  then
    ActiveButton := -1;

  if (OldActiveButton <> ActiveButton)
  then
    begin
      if OldActiveButton <> - 1
      then
        ButtonLeave(OldActiveButton);

      if ActiveButton <> -1
      then
        ButtonEnter(ActiveButton);
    end;
end;

procedure TbsSkinSpinEdit.ButtonDown;
begin
  Buttons[i].MouseIn := True;
  Buttons[i].Down := True;
  RePaint;
  case i of
    0: TimerMode := 2;
    1: TimerMode := 1;
  end;
  WaitMode := True;
  SetTimer(Handle, 1, 500, nil);
end;

procedure TbsSkinSpinEdit.ButtonUp;
begin
  StopTimer;
  Buttons[i].Down := False;
  if ActiveButton <> i then Buttons[i].MouseIn := False;
  RePaint;
  if Buttons[i].MouseIn
  then
  case i of
    0:
    begin
      Value := Value + FIncrement;
      if Assigned(FOnUpButtonClick)
      then
        FOnUpButtonClick(Self);
    end;
    1:
      begin
        Value := Value - FIncrement;
        if Assigned(FOnDownButtonClick)
        then
          FOnDownButtonClick(Self);
      end;
  end;
end;

procedure TbsSkinSpinEdit.ButtonEnter(I: Integer);
begin
  Buttons[i].MouseIn := True;
  RePaint;
  if Buttons[i].Down then SetTimer(Handle, 1, 50, nil);
end;

procedure TbsSkinSpinEdit.ButtonLeave(I: Integer);
begin
  Buttons[i].MouseIn := False;
  RePaint;
  if Buttons[i].Down then KillTimer(Handle, 1);
end;

procedure TbsSkinSpinEdit.CalcRects;
const
  ButtonW = 15;
var
  OX, OY: Integer;
  NewClRect: TRect;
  BR: TRect;
begin
  if FIndex = -1
  then
    begin
      Buttons[0].R := Rect(Width - ButtonW - 2, 2, Width - 2, Height div 2);
      Buttons[1].R := Rect(Width - ButtonW - 2, Height div 2, Width - 2, Height - 2);
      FEdit.SetBounds(2, 2, Width - ButtonW - 4, Height - 4);
      FEdit.Left := 2;
      FEdit.Width := Width - ButtonW - 4;
      AdjustEditHeight;
      FEdit.Top := 2 + Height div 2 - FEdit.Height div 2 - 2;
    end
  else
  if (FIndex <> -1) and (not FUseSkinSize)
  then
    begin
      OX := Width - RectWidth(SkinRect);
      OY := Height - RectHeight(SkinRect);
      Buttons[0].R := UpButtonRect;
      if Buttons[0].R.Left > RTPt.X
      then OffsetRect(Buttons[0].R, OX, 0);
      Buttons[1].R := DownButtonRect;
      if Buttons[1].R.Left > RTPt.X
      then OffsetRect(Buttons[1].R, OX, 0);
      NewClRect := Rect(ClRect.Left, ClRect.Top,
                        ClRect.Right + OX, ClRect.Bottom + OY);

      if Buttons[0].R.Bottom <= Buttons[1].R.Bottom
      then
        begin
          BR := Rect(Buttons[0].R.Left, Buttons[0].R.Top,
                     Buttons[1].R.Right, Buttons[1].R.Bottom);
          Inc(BR.Bottom, OY);
          Buttons[0].R := Rect(BR.Left, BR.Top,
                               BR.Right, BR.Top + BR.Bottom div 2);
          Buttons[1].R := Rect(BR.Left, BR.Top + BR.Bottom div 2,
                               BR.Right, BR.Bottom);
        end
      else
        begin
          Inc(Buttons[0].R.Bottom, OY);
          Inc(Buttons[1].R.Bottom, OY);
        end;

      FEdit.Left := NewClRect.Left;
      FEdit.Width := RectWidth(NewClRect);
      AdjustEditHeight;
      FEdit.Top := NewClRect.Top + RectHeight(NewClRect) div 2 - FEdit.Height div 2;
    end
  else
    begin
      OX := Width - RectWidth(SkinRect);
      Buttons[0].R := UpButtonRect;
      if Buttons[0].R.Left > RTPt.X
      then OffsetRect(Buttons[0].R, OX, 0);
      Buttons[1].R := DownButtonRect;
      if Buttons[1].R.Left > RTPt.X
      then OffsetRect(Buttons[1].R, OX, 0);
      NewClRect := Rect(ClRect.Left, ClRect.Top,
                        ClRect.Right + OX, ClRect.Bottom);
      FEdit.Left := NewClRect.Left;
      FEdit.Width := RectWidth(NewClRect);
      AdjustEditHeight;
      FEdit.Top := NewClRect.Top + RectHeight(NewClRect) div 2 - FEdit.Height div 2;
    end;
end;

procedure TbsSkinSpinEdit.SimpleSetValue(AValue: Double);
begin
  FValue := CheckValue(AValue);
  StopCheck := True;
  if ValueType = vtFloat
  then
    Text := FloatToStrF(CheckValue(AValue), ffFixed, 15, FDecimal)
  else
    Text := IntToStr(Round(CheckValue(AValue)));
  StopCheck := False;
end;

procedure TbsSkinSpinEdit.SetValue;
var
  IsStopCheck: Boolean;
begin
  FValue := CheckValue(AValue);
  IsStopCheck := StopCheck;
  StopCheck := True;
  if IsStopCheck   
  then
    begin
      if ValueType = vtFloat
      then
        FEdit.Text := FloatToStrF(CheckValue(AValue), ffFixed, 15, FDecimal)
      else
        FEdit.Text := IntToStr(Round(CheckValue(AValue)));
    end
  else
  if ValueType = vtFloat
  then
    Text := FloatToStrF(CheckValue(AValue), ffFixed, 15, FDecimal)
  else
    Text := IntToStr(Round(CheckValue(AValue)));
  StopCheck := False;
  if not IsStopCheck then Change;
end;

procedure TbsSkinSpinEdit.CreateControlSkinImage;
var
  i: Integer;
  ClRct: TRect;
begin
  if not FUseSkinSize
  then
    begin
      ClRct := ClRect;
      InflateRect(ClRct, -2, -1);
      if (FEditFocused or FMouseIn) and not IsNullRect(ActiveSkinRect)
      then
        CreateStretchImage(B, Picture, ActiveSkinRect, ClRct, True)
      else
        CreateStretchImage(B, Picture, SkinRect, ClRct, True);
     end
  else
  if (FEditFocused or FMouseIn) and not IsNullRect(ActiveSkinRect)
  then
    CreateHSkinImage(LOffset, ROffset, B, Picture, ActiveSkinRect, Width,
          RectHeight(ActiveSkinRect), StretchEffect)
  else
    inherited;
  if FUseSkinSize
  then
    begin
      for i := 0 to 1 do DrawButton(B.Canvas, i);
    end
  else
    begin
      for i := 0 to 1 do DrawResizeButton(B.Canvas, i);
    end;
end;

procedure TbsSkinSpinEdit.DrawResizeButton(Cnvs: TCanvas; i: Integer);
var
  Buffer: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  BtnCLRect: TRect;
  BSR, ABSR, DBSR, R1: TRect;
  XO, YO: Integer;
  ArrowColor: TColor;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(Buttons[i].R);
  Buffer.Height := RectHeight(Buttons[i].R);
  //
  CIndex := SkinData.GetControlIndex('editbutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('combobutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('resizebutton');
  if CIndex = -1
  then
    begin
      Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
    XO := RectWidth(Buttons[i].R) - RectWidth(SkinRect);
    YO := RectHeight(Buttons[i].R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if Buttons[i].Down and Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := DownFontColor;
      end
    else
    if Buttons[i].MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := FontColor;
      end;
   end;
  //
  Cnvs.Draw(Buttons[i].R.Left, Buttons[i].R.Top, Buffer);
  //
  R1 := Buttons[i].R;
 { if Buttons[i].Down and Buttons[i].MouseIn
  then
    begin
      Inc(R1.Left, 2);
      Inc(R1.Top, 2);
    end;}  

  case i of
    0: DrawArrowImage(Cnvs, R1, ArrowColor, 3);
    1: DrawArrowImage(Cnvs, R1, ArrowColor, 4);
  end;
  //
  Buffer.Free;
end;


procedure TbsSkinSpinEdit.DrawButton;
var
  C: TColor;
  kf: Double;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Buttons[i] do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          Cnvs.Brush.Color := BS_BTNDOWNCOLOR;
          Cnvs.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            Cnvs.Brush.Color := BS_BTNACTIVECOLOR;
            Cnvs.FillRect(R1);
          end
        else
          begin
            Cnvs.Brush.Color := clBtnFace;
            Cnvs.FillRect(R1);
          end;
      C := clBlack;
      case i of
        0: DrawArrowImage(Cnvs, R1, C, 3);
        1: DrawArrowImage(Cnvs, R1, C, 4);
      end;
    end
  else
    with Buttons[i] do
    begin
      R1 := NullRect;
      case I of
        0:
          begin
            if Down and MouseIn
            then R1 := DownUpButtonRect
            else if MouseIn then R1 := ActiveUpButtonRect;
          end;
        1:
          begin
            if Down and MouseIn
            then R1 := DownDownButtonRect
            else if MouseIn then R1 := ActiveDownButtonRect;
          end
      end;
      if not IsNullRect(R1)
      then
        Cnvs.CopyRect(R, Picture.Canvas, R1);
    end;
end;

procedure TbsSkinSpinEdit.CreateControlDefaultImage;
var
  R: TRect;
  i: Integer;
begin
  with B.Canvas do
  begin
    R := Rect(0, 0, Width, Height);
    Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
    Frame3D(B.Canvas, R, FDefaultColor, FDefaultColor, 1);
  end;
  for i := 0 to 1 do DrawButton(B.Canvas, i);
end;

procedure TbsSkinSpinEdit.MouseDown;
begin
  TestActive(X, Y);
  if ActiveButton <> -1
  then
    begin
      CaptureButton := ActiveButton;
      ButtonDown(ActiveButton, X, Y);
    end;
  inherited;
end;

procedure TbsSkinSpinEdit.MouseUp;
begin
  if CaptureButton <> -1
  then ButtonUp(CaptureButton, X, Y);
  CaptureButton := -1;
  inherited;
end;

procedure TbsSkinSpinEdit.MouseMove;
begin
  inherited;
  TestActive(X, Y);
end;


constructor TbsPopupListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable,
    csAcceptsControls];
  Ctl3D := False;
  ParentCtl3D := False;
  Visible := False;
  FOldAlphaBlend := False;
  FOldAlphaBlendValue := 0;
end;

procedure TbsPopupListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do begin
    Style := WS_POPUP or WS_CLIPCHILDREN;
    ExStyle := WS_EX_TOOLWINDOW;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    if CheckWXP then
      WindowClass.Style := WindowClass.style or CS_DROPSHADOW_;
  end;
end;

procedure TbsPopupListBox.WMMouseActivate(var Message: TMessage);
begin
  Message.Result := MA_NOACTIVATE;
end;

procedure TbsPopupListBox.Hide;
begin
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Visible := False;
end;

procedure TbsPopupListBox.Show(Origin: TPoint);
var
  PLB: TbsSkinCustomComboBox;
  I: Integer;
  TickCount: Integer;
  AnimationStep: Integer;
begin
  PLB := nil;
  //
  if CheckW2KWXP and (Owner is TbsSkinCustomComboBox)
  then
    begin
      PLB := TbsSkinCustomComboBox(Owner);
      if PLB.AlphaBlend and not FOldAlphaBlend
      then
        begin
          SetWindowLong(Handle, GWL_EXSTYLE,
                        GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
        end
      else
      if not PLB.AlphaBlend and FOldAlphaBlend
      then
        begin
         SetWindowLong(Handle, GWL_EXSTYLE,
            GetWindowLong(Handle, GWL_EXSTYLE) and (not WS_EX_LAYERED));
        end;
      FOldAlphaBlend := PLB.AlphaBlend;
      if (FOldAlphaBlendValue <> PLB.AlphaBlendValue) and PLB.AlphaBlend
      then
        begin
          if PLB.AlphaBlendAnimation
          then
            begin
              SetAlphaBlendTransparent(Handle, 0);
              FOldAlphaBlendValue := 0;
            end
          else
            begin
              SetAlphaBlendTransparent(Handle, PLB.AlphaBlendValue);
              FOldAlphaBlendValue := PLB.AlphaBlendValue;
             end;
        end;
    end;
  //
  SetWindowPos(Handle, HWND_TOP, Origin.X, Origin.Y, 0, 0,
    SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOSIZE);
  Visible := True;
  if CheckW2KWXP and (PLB <> nil) and PLB.AlphaBlendAnimation and PLB.AlphaBlend 
  then
    begin
      Application.ProcessMessages;
      I := 0;
      TickCount := 0;
      AnimationStep := PLB.AlphaBlendValue div 15;
      if AnimationStep = 0 then AnimationStep := 1;
      repeat
        if (GetTickCount - TickCount > 5)
        then
          begin
            TickCount := GetTickCount;
            Inc(i, AnimationStep);
            if i > PLB.AlphaBlendValue then i := PLB.AlphaBlendValue;
            SetAlphaBlendTransparent(Handle, i);
          end;
        Application.ProcessMessages;  
      until i >= PLB.FAlphaBlendValue;
    end;
end;

constructor TbsCustomEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FEditTransparent := False;
  FSysPopupMenu := nil;
  FStopDraw := False;
  FDown := False;
end;

destructor TbsCustomEdit.Destroy;
begin
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;
  inherited;
end;

procedure TbsCustomEdit.WMSize(var Message: TWMSIZE);
begin
  inherited;
end;

procedure TbsCustomEdit.DoPaint2(DC: HDC); 
var
  MyDC: HDC;
  TempDC: HDC;
  OldBmp, TempBmp: HBITMAP;
begin
  if not HandleAllocated then Exit;
  FStopDraw := True;
  try
    MyDC := DC;
    try
      TempDC := CreateCompatibleDC(MyDC);
      try
        TempBmp := CreateCompatibleBitmap(MyDC, Succ(Width), Succ(Height));
        try
          OldBmp := SelectObject(TempDC, TempBmp);
          SendMessage(Handle, WM_ERASEBKGND, TempDC, 0);
          SendMessage(Handle, WM_PAINT, TempDC, 0);
          BitBlt(MyDC, 0, 0, Width, Height, TempDC, 0, 0, SRCCOPY);
          SelectObject(TempDC, OldBmp);
        finally
          DeleteObject(TempBmp);
        end;
      finally
        DeleteDC(TempDC);
      end;
    finally
      ReleaseDC(Handle, MyDC);
    end;
  finally
    FStopDraw := False;
  end;
end;

procedure TbsCustomEdit.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;

  if not FStopDraw and FEditTransparent
  then
    begin
      DC := Message.DC;
      if DC = 0 then DC := BeginPaint(Handle, PS);
      DoPaint2(DC);
      ShowCaret(Handle);
      if DC = 0 then EndPaint(Handle, PS);
    end
  else
    inherited;
end;

procedure TbsCustomEdit.DoPaint;
var
  MyDC: HDC;
  TempDC: HDC;
  OldBmp, TempBmp: HBITMAP;
begin
  if not HandleAllocated then Exit;
  FStopDraw := True;
  HideCaret(Handle);
  try
    MyDC := GetDC(Handle);
    try
      TempDC := CreateCompatibleDC(MyDC);
      try
        TempBmp := CreateCompatibleBitmap(MyDC, Succ(Width), Succ(Height));
        try
          OldBmp := SelectObject(TempDC, TempBmp);
          SendMessage(Handle, WM_ERASEBKGND, TempDC, 0);
          SendMessage(Handle, WM_PAINT, TempDC, 0);
          BitBlt(MyDC, 0, 0, Width, Height, TempDC, 0, 0, SRCCOPY);
          SelectObject(TempDC, OldBmp);
        finally
          DeleteObject(TempBmp);
        end;
      finally
        DeleteDC(TempDC);
      end;
    finally
      ReleaseDC(Handle, MyDC);
    end;
  finally
    ShowCaret(Handle);
    FStopDraw := False;
  end;
end;   

procedure TbsCustomEdit.WMAFTERDISPATCH;
begin
  if FSysPopupMenu <> nil
  then
    begin
      FSysPopupMenu.Free;
      FSysPopupMenu := nil;
    end;
end;

procedure TbsCustomEdit.DoUndo;
begin
  Undo;
end;

procedure TbsCustomEdit.DoCut;
begin
  CutToClipboard;
end;

procedure TbsCustomEdit.DoCopy;
begin
  CopyToClipboard;
end;

procedure TbsCustomEdit.DoPaste;
begin
  PasteFromClipboard;
end;

procedure TbsCustomEdit.DoDelete;
begin
  ClearSelection;
end;

procedure TbsCustomEdit.DoSelectAll;
begin
  SelectAll;
end;

procedure TbsCustomEdit.CreateSysPopupMenu;

function FindBSFComponent(AForm: TForm): TbsBusinessSkinForm;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to AForm.ComponentCount - 1 do
   if AForm.Components[i] is TbsBusinessSkinForm
   then
     begin
       Result := TbsBusinessSkinForm(AForm.Components[i]);
       Break;
     end;
end;

function GetResourceStrData: TbsResourceStrData;
var
  BSF: TbsBusinessSkinForm;
begin
  BSF := FindBSFComponent(TForm(GetParentForm(Self)));
  if (BSF <> nil) and (BSF.SkinData <> nil) and (BSF.SkinData.ResourceStrData <> nil)
  then
    Result :=  BSF.SkinData.ResourceStrData
  else
    Result := nil;  
end;

function IsSelected: Boolean;
var
  i, j: Integer;
begin
  GetSel(i, j);
  Result := (i < j);
end;

function IsFullSelected: Boolean;
var
  i, j: Integer;
begin
  GetSel(i, j);
  Result := (i = 0) and (j = Length(Text));
end;

var
  Item: TMenuItem;
  ResStrData: TbsResourceStrData;
begin
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;

  FSysPopupMenu := TbsSkinPopupMenu.Create(Self);
  if (TForm(GetParentForm(Self)) <> nil) and (TForm(GetParentForm(Self)).FormStyle = fsMDIChild)
  then
    FSysPopupMenu.ComponentForm := Application.MainForm
  else
    FSysPopupMenu.ComponentForm := TForm(GetParentForm(Self));

  ResStrData := GetResourceStrData;

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_UNDO')
    else
      Caption := BS_Edit_Undo;
    OnClick := DoUndo;
    Enabled := Self.CanUndo;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_CUT')
    else
      Caption := BS_Edit_Cut;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoCut;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_COPY')
    else
      Caption := BS_Edit_Copy;
    Enabled := IsSelected;
    OnClick := DoCopy;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_PASTE')
    else
      Caption := BS_Edit_Paste;
    Enabled := (ClipBoard.AsText <> '') and not ReadOnly;
    OnClick := DoPaste;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_DELETE')
    else
      Caption := BS_Edit_Delete;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoDelete;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if ResStrData <> nil
    then
      Caption := ResStrData.GetResStr('EDIT_SELECTALL')
    else
      Caption := BS_Edit_SelectAll;
    Enabled := not IsFullSelected;
    OnClick := DoSelectAll;
  end;
  FSysPopupMenu.Items.Add(Item);
end;

procedure TbsCustomEdit.CMCancelMode;
begin
  inherited;
  if Assigned(FOnEditCancelMode)
  then FOnEditCancelMode(Message.Sender);
end;

procedure TbsCustomEdit.SetEditTransparent(Value: Boolean);
begin
  FEditTransparent := Value;
  ReCreateWnd;
end;

procedure TbsCustomEdit.WMSetFont;
begin
  inherited;
  SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, MakeLong(2, 0));
end;

procedure TbsCustomEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_BORDER;
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    if PasswordChar <> #0
    then
      Style := Style or ES_PASSWORD and not ES_MULTILINE
    else
      Style := Style or ES_MULTILINE;
  end;
end;

procedure TbsCustomEdit.WMCHAR;
var
  Key: Char;
begin
  if Message.CharCode in [VK_ESCAPE]
  then
    begin
      Key := #27;
      if Assigned(OnKeyPress) then OnKeyPress(Self, Key);
      if GetParentForm(Self) <> nil
      then
        GetParentForm(Self).Perform(CM_DIALOGKEY, Message.CharCode, Message.KeyData);
    end
  else
  if Message.CharCode in [VK_RETURN]
  then
    begin
      Key := #13;
      if Assigned(OnKeyPress) then OnKeyPress(Self, Key);
      if GetParentForm(Self) <> nil
      then
        GetParentForm(Self).Perform(CM_DIALOGKEY, Message.CharCode, Message.KeyData);
    end
  else
  if (not ReadOnly) or (Message.CharCode = 3)
  then
    begin
      inherited;
      if FEditTransparent then DoPaint;
    end
end;

procedure TbsCustomEdit.CNCtlColorStatic;
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;

 if FEditTransparent
 then
   begin
     with Message do
     begin
       SetBkMode(ChildDC, Windows.Transparent);
       SetTextColor(ChildDC, ColorToRGB(Font.Color));
       Result := GetStockObject(NULL_BRUSH);
     end
   end
 else
  inherited;
end;

procedure TbsCustomEdit.CNCTLCOLOREDIT(var Message:TWMCTLCOLOREDIT);
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;

 if FEditTransparent
 then
   begin
     with Message do
     begin
       SetBkMode(ChildDC, Windows.Transparent);
       SetTextColor(ChildDC, ColorToRGB(Font.Color));
       Result := GetStockObject(NULL_BRUSH);
     end
   end
 else
  inherited;
end;

procedure TbsCustomEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var
  C: TCanvas;
  Buffer: TBitMap;
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  if FEditTransparent
  then
    begin
      if not FStopDraw
      then
        begin
          DoPaint;
        end
      else
        begin
          C := TCanvas.Create;
          C.Handle := Message.DC;
          Buffer := TBitMap.Create;
          Buffer.Width := Width;
          Buffer.Height := Height;
          GetParentImage(Self, Buffer.Canvas);
          C.Draw(0, 0, Buffer);
          Buffer.Free;
          C.Handle := 0;
          C.Free;
        end;  
    end
  else
    inherited;
end;

procedure TbsCustomEdit.Change;
begin
  inherited;
  if FEditTransparent then DoPaint;
end;

procedure TbsCustomEdit.WMKeyDown(var Message: TWMKeyDown);
begin
  if FReadOnly and (Message.CharCode = VK_DELETE) then Exit;
  inherited;
end;

procedure TbsCustomEdit.WMKeyUp;
begin
  inherited;
end;

procedure TbsCustomEdit.WMSetText(var Message:TWMSetText);
begin
  inherited;
end;

procedure TbsCustomEdit.WMMove(var Message: TMessage);
begin
  inherited;
end;

procedure TbsCustomEdit.WMCut(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
end;

procedure TbsCustomEdit.WMPaste(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
end;

procedure TbsCustomEdit.WMClear(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
end;

procedure TbsCustomEdit.WMUndo(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
end;

procedure TbsCustomEdit.WMCONTEXTMENU;
var
  X, Y: Integer;
  P: TPoint;
begin
  if PopupMenu <> nil
  then
    inherited
  else
    begin
      CreateSysPopupMenu;
      X := Message.XPos;
      Y := Message.YPos;
      if (X < 0) or (Y < 0)
      then
        begin
          X := Width div 2;
          Y := Height div 2;
          P := Point(0, 0);
          P := ClientToScreen(P);
          X := X + P.X;
          Y := Y + P.Y;
        end;
      if FSysPopupMenu <> nil
      then
        FSysPopupMenu.Popup2(Self, X, Y)
    end;
end;

procedure TbsCustomEdit.WMLButtonDown(var Message: TMessage);
begin
  inherited;
  FDown := True;
  if FDown and FEditTransparent
  then
    begin
      DoPaint;
    end;
end;

procedure TbsCustomEdit.WMSETFOCUS;
begin
  inherited;
  if FEditTransparent then DoPaint;
  if AutoSelect then SelectAll;
end;

procedure TbsCustomEdit.WMKILLFOCUS;
begin
  inherited;
  if FEditTransparent then DoPaint;
end;

procedure TbsCustomEdit.WMMOUSEMOVE;
begin
  inherited;
end;

procedure TbsCustomEdit.WMLButtonUp;
begin
  inherited;
  FDown := False;
  if FDown and FEditTransparent then DoPaint;
end;

constructor TbsSkinNumEdit.Create(AOwner: TComponent);
begin
  inherited;
  FEditorEnabled := True;
end;

procedure TbsSkinNumEdit.CMMouseEnter;
begin
  inherited;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TbsSkinNumEdit.CMMouseLeave;
begin
  inherited;
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TbsSkinNumEdit.WMMOUSEWHEEL;
begin
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    begin
      if Assigned(FOnDownClick) then FOnDownClick(Self);
    end
  else
    begin
      if Assigned(FOnUpClick) then FOnUpClick(Self);
    end;
end;

procedure TbsSkinNumEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP
  then
    begin
      if Assigned(FOnUpClick) then FOnUpClick(Self);
    end
  else
  if Key = VK_DOWN
  then
    begin
      if Assigned(FOnDownClick) then FOnDownClick(Self);
    end
  else
  inherited KeyDown(Key, Shift);
end;

procedure TbsSkinNumEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TbsSkinNumEdit.IsValidChar(Key: Char): Boolean;
begin
  if FLoat
  then
    Result := (Key in [{$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)))
  else
    Result := (Key in ['-', '0'..'9']) or
     ((Key < #32) and (Key <> Chr(VK_RETURN)));

  if not FEditorEnabled and Result and ((Key >= #32) or
     (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE)))
  then
    Result := False;

  if (Key = {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator) and (Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, Text) <> 0)
  then
    Result := False
  else
  if (Key = '-') and (SelStart = 0) and (SelLength > 0)
  then
    begin
      Result := True;
    end
  else
  if (Key = '-') and (SelStart <> 0) 
  then
    begin
      Result := False;
    end
  else
  if (Key = '-') and (Pos('-', Text) <> 0)
  then
    Result := False;
    
end;

const
  HTEDITBUTTON = HTSIZE + 2;
  HTEDITFRAME = HTSIZE + 3;
  HTEDITBUTTONL = HTSIZE + 100;
  HTEDITBUTTONR = HTSIZE + 101;

constructor TbsSkinCustomEdit.Create;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  AutoSize := False;
  FIndex := -1;
  Font.Name := 'Tahoma';
  Font.Color := clBlack;
  Font.Style := [];
  Font.Height := 13;
  Height := 20;
  BorderStyle := bsNone;
  Picture := nil;
  EditTransparent := True;
  FSkinDataName := 'edit';
  FDefaultColor := clWindow;
  FDefaultFont := TFont.Create;
  FDefaultFont.Assign(Font);
  FDefaultFont.OnChange := OnDefaultFontChange;
  FDefaultWidth := 0;
  FDefaultHeight := 0;
  FUseSkinFont := True;
  FImages := nil;
  FButtonImageIndex := -1;
  FLeftImageIndex := -1;
  FLeftImageHotIndex := -1;
  FLeftImageDownIndex := -1;
  FRightImageIndex := -1;
  FRightImageHotIndex := -1;
  FRightImageDownIndex := -1;
  LeftButton.R := NullRect;
  RightButton.R := NullRect;
  LeftButton.Down := False;
  RightButton.Down := False;
  LeftButton.MouseIn := False;
  RightButton.MouseIn := False;
end;

destructor TbsSkinCustomEdit.Destroy;
begin
  FDefaultFont.Free;
  inherited;
end;

procedure TbsSkinCustomEdit.DoPaint;
var
  MyDC: HDC;
  TempDC: HDC;
  OldBmp, TempBmp: HBITMAP;
begin
  if not HandleAllocated then Exit;

  FStopDraw := True;
  begin
    HideCaret(Handle);
    try
      MyDC := GetDC(Handle);
      try
        TempDC := CreateCompatibleDC(MyDC);
        try
          TempBmp := CreateCompatibleBitmap(MyDC, Succ(ClientWidth), Succ(ClientHeight));
          try
            OldBmp := SelectObject(TempDC, TempBmp);
            SendMessage(Handle, WM_ERASEBKGND, TempDC, 0);
            SendMessage(Handle, WM_PAINT, TempDC, 0);
            BitBlt(MyDC, 0, 0, ClientWidth, ClientHeight, TempDC, 0, 0, SRCCOPY);
            SelectObject(TempDC, OldBmp);
          finally
            DeleteObject(TempBmp);
          end;
        finally
          DeleteDC(TempDC);
        end;
      finally
        ReleaseDC(Handle, MyDC);
      end;
    finally
      ShowCaret(Handle);
    end;
 end;
 FStopDraw := False;
end;

procedure TbsSkinCustomEdit.WMNCPAINT;
var
  DC: HDC;
  C: TCanvas;
begin
  DC := GetWindowDC(Handle);
  C := TControlCanvas.Create;
  C.Handle := DC;
  ExcludeClipRect(C.Handle,
    FEditRect.lEft, FEditRect.Top,
    FEditRect.Right, FEditRect.Bottom);
  try
    if UseSkinFont or (FIndex = -1)
    then
      DrawSkinEdit(C, False, Text)
    else
      DrawSkinEdit2(C, False, Text);
  finally
    C.Free;
    ReleaseDC(Handle, DC);
   end;
  if not (csDesigning in ComponentState) then DoPaint;
end;

function TbsSkinCustomEdit.CheckActivation: Boolean;
begin
  Result := False;
  if FIndex <> -1
  then
    Result := FButtonMode or (Images <> nil) or not IsNullRect(ActiveSkinRect)
              or (FontColor <> ActiveFontColor)
  else
    Result := (FButtonMode) or (Images <> nil);
end;

procedure TbsSkinCustomEdit.SetImages(Value: TCustomImageList);
begin
  if Value <> FImages then
  begin
    FImages := Value;
    AdjustTextRect(True);
    if (FIndex = -1) or (not FUseSkinFont)
    then
      begin
        AdjustEditHeight;
        if (Align = alNone) and (csDesigning in ComponentState)
        then
          begin
            Width := Width - 1;
            Width := Width + 1;
          end;
      end;
  end;
end;

procedure TbsSkinCustomEdit.SetButtonImageIndex(Value: Integer);
begin
  if FButtonImageIndex <> Value
  then
    begin
      FButtonImageIndex := Value;
      Invalidate;
    end;  
end;

procedure TbsSkinCustomEdit.SetLeftImageIndex(Value: Integer);
begin
  FLeftImageIndex := Value;
  AdjustTextRect(True);
  if (Align = alNone) and (csDesigning in ComponentState)
  then
    begin
      Width := Width - 1;
      Width := Width + 1;
    end;
end;

procedure TbsSkinCustomEdit.SetLeftImageHotIndex(Value: Integer);
begin
  if Value <> FLeftImageHotIndex
  then
    begin
      FLeftImageHotIndex := Value;
    end;
end;

procedure TbsSkinCustomEdit.SetLeftImageDownIndex(Value: Integer);
begin
  if Value <> FLeftImageDownIndex
  then
    begin
      FLeftImageDownIndex := Value;
    end;
 end;

procedure TbsSkinCustomEdit.SetRightImageIndex(Value: Integer);
begin
  FRightImageIndex := Value;
  AdjustTextRect(True);
  if (Align = alNone) and (csDesigning in ComponentState)
  then
    begin
      Width := Width - 1;
      Width := Width + 1;
    end;
end;

procedure TbsSkinCustomEdit.SetRightImageHotIndex(Value: Integer);
begin
  if Value <> FRightImageHotIndex
  then
    begin
      FRightImageHotIndex := Value;
    end;
end;

procedure TbsSkinCustomEdit.SetRightImageDownIndex(Value: Integer);
begin
  if Value <> FRightImageDownIndex
  then
    begin
      FRightImageDownIndex := Value;
    end;
end;

procedure TbsSkinCustomEdit.WMSize(var Msg: TWMSize);
begin
  inherited;
  AdjustTextRect(True);
  InvalidateNC;
end;

procedure TbsSkinCustomEdit.SetDefaultColor(Value: TColor);
begin
  FDefaultColor := Value;
  if FIndex = -1 then Invalidate;
end;

procedure TbsSkinCustomEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if not FUseSkinFont and not ((csDesigning in ComponentState) and
         (csLoading in ComponentState))
  then
    begin
      AdjustEditHeight;
      if FIndex = -1 then RecreateWnd;
    end;
end;

procedure TbsSkinCustomEdit.DrawButtonImages(C: TCanvas);
var
  IX: Integer;
  Y: Integer;
begin
  if FImages = nil then Exit;
  AdjustTextRect(False);
  if (FLeftImageIndex >= 0) and (FLeftImageIndex < FImages.Count)
  then
    begin
      Y := LeftButton.R.Top + RectHeight(LeftButton.R) div 2 -
          FImages.Height div 2;
      if Y < LeftButton.R.Top then Y := LeftButton.R.Top;
      IX := FLeftImageIndex;
      if LeftButton.Down and LeftButton.MouseIn and
         (FLeftImageDownIndex >= 0) and (FLeftImageDownIndex < FImages.Count)
      then
        IX := FLeftImageDownIndex
      else
      if LeftButton.MouseIn and (FLeftImageHotIndex >= 0) and (FLeftImageHotIndex < FImages.Count)
      then
        IX := FLeftImageHotIndex;
      FImages.Draw(C, LeftButton.R.Left, Y, IX, Enabled);
    end;
  if (FRightImageIndex >= 0) and (FRightImageIndex < FImages.Count)
  then
    begin
      Y := RightButton.R.Top + RectHeight(RightButton.R) div 2 -
          FImages.Height div 2;
      if Y < RightButton.R.Top then Y := RightButton.R.Top;
      IX := FRightImageIndex;
      if RightButton.Down and RightButton.MouseIn and
         (FRightImageDownIndex >= 0) and (FRightImageDownIndex < FImages.Count)
      then
        IX := FRightImageDownIndex
      else
      if RightButton.MouseIn and (FRightImageHotIndex >= 0) and (FRightImageHotIndex < FImages.Count)
      then
        IX := FRightImageHotIndex;
      FImages.Draw(C, RightButton.R.Left, Y, IX, Enabled);
    end;
end;

procedure TbsSkinCustomEdit.WMEraseBkgnd;
var
  DC: HDC;
  C: TCanvas;
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      if FImages <> nil
      then
        begin
          DC := Message.DC;
          C := TControlCanvas.Create;
          C.Handle := DC;
          DrawButtonImages(C);
          C.Handle := 0;
          C.Free;
        end;  
      Exit;
    end;
  DC := Message.DC;
  C := TControlCanvas.Create;
  C.Handle := DC;
  try
    if not FStopDraw
    then
      DoPaint
    else
      begin
        DrawEditBackGround(C);
        DrawButtonImages(C);
      end;
  finally
    C.Handle := 0;
    C.Free;
  end;
end;

procedure TbsSkinCustomEdit.WMPaint(var Message: TWMPaint);
var
  S: string;
  FCanvas: TControlCanvas;
  DC: HDC;
  PS: TPaintStruct;
  TX, TY: Integer;
  R: TRect;
begin
  //
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  //
  if Enabled
  then
    begin
      inherited;
    end
  else
    begin
      S := Text;
      FCanvas := TControlCanvas.Create;
      FCanvas.Control := Self;
      DC := Message.DC;
      if DC = 0 then DC := BeginPaint(Handle, PS);
      FCanvas.Handle := DC;
      //
      DrawEditBackGround(FCanvas);
      //
      with FCanvas do
      begin
        if (FIndex = -1) or not FUseSkinFont
        then
          begin
            Font := DefaultFont;
            if FIndex = -1
            then Font.Color := clGrayText
            else Font.Color := DisabledFontColor;
          end
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := DisabledFontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;
      end;
      R := FEditRect;
      OffsetRect(R, - R.Left, - R.Top);
      TY := R.Top;
      TX := R.Left + 2;
      case Alignment of
        taCenter:
           TX := TX + RectWidth(R) div 2 - FCanvas.TextWidth(S) div 2 - 1;
        taRightJustify:
           TX := R.Right - 1 - FCanvas.TextWidth(S);
      end;
      FCanvas.Brush.Style := bsClear;
      FCanvas.TextRect(R, TX, TY, S);
      //
      FCanvas.Handle := 0;
      FCanvas.Free;
      if Message.DC = 0 then EndPaint(Handle, PS);
    end;
end;

procedure TbsSkinCustomEdit.CalcEditHeight(var AHeight: Integer);
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Self.Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  AHeight := Metrics.tmHeight;
  if FIndex = -1
  then
    begin
      AHeight := AHeight + 2;
      if (FImages <> nil) and (FImages.Height > AHeight)
      then
        AHeight := FImages.Height;
      AHeight := AHeight + 4;  
    end
  else
    begin
      if (FImages <> nil) and (FImages.Height > AHeight) then AHeight := FImages.Height;
      AHeight := AHeight + (RectHeight(SkinRect) - RectHeight(ClRect));
    end;
end;


procedure TbsSkinCustomEdit.AdjustEditHeight;
var
  EditH: Integer;
begin
  CalcEditHeight(EditH);
  Height := EditH;
end;

procedure TbsSkinCustomEdit.CreateWnd;
begin
  inherited;
  AdjustTextRect(True);
end;

procedure TbsSkinCustomEdit.Loaded;
begin
  inherited;
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinData.ResourceStrData.CharSet;
end;

procedure TbsSkinCustomEdit.CMEnabledChanged;
begin
  inherited;
  Invalidate;
end;

procedure TbsSkinCustomEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TbsSkinCustomEdit.SetDefaultWidth;
begin
  FDefaultWidth := Value;
  if (FIndex = -1) and (FDefaultWidth > 0) then Width := FDefaultWidth;
end;

procedure TbsSkinCustomEdit.SetDefaultHeight;
begin
  FDefaultHeight := Value;
  if (FIndex = -1) and (FDefaultHeight > 0) and UseSkinFont
  then
    Height := FDefaultHeight
  else
    AdjustEditHeight;
end;

procedure TbsSkinCustomEdit.SetDefaultFont;
begin
  FDefaultFont.Assign(Value);
  if FIndex = -1 then Font.Assign(Value);
end;

procedure TbsSkinCustomEdit.OnDefaultFontChange(Sender: TObject);
begin
  if FIndex = -1
  then
    begin
      Font.Assign(FDefaultFont);
      if (csDesigning in ComponentState)
      then
        begin
          Width := Width - 1;
          Width := Width + 1;
        end;
    end;  
end;

procedure TbsSkinCustomEdit.CalcRects;
var
  Off: Integer;
begin
  if FIndex = -1
  then
    begin
      if FButtonMode
      then
        begin
          FButtonRect := Rect(Width - Height, 0, Width, Height);
          FEditRect := Rect(2, 2, FButtonRect.Left - 2, Height - 2);
        end
      else
        FEditRect := Rect(2, 2, Width - 2, Height - 2);
    end
  else
    begin
      Off := Width - RectWidth(SkinRect);
      FEditRect := ClRect;
      Inc(FEditRect.Right, Off);
      FButtonRect := ButtonRect;
      if ButtonRect.Left >= RectWidth(SkinRect) - ROffset
      then OffsetRect(FButtonRect, Off, 0);
      if not FUseSkinFont
      then
        begin
          Off := Height - RectHeight(SkinRect);
          Inc(FEditRect.Bottom, Off);
          Inc(FButtonRect.Bottom, Off);
        end;
    end;
end;


procedure TbsSkinCustomEdit.WMMOUSEMOVE;
begin
  inherited;
  if FButtonMode and FButtonActive
  then
    begin
      FButtonActive := False;
      InvalidateNC;
    end;
end;

procedure TbsSkinCustomEdit.WMDESTROY(var Message: TMessage);
begin
  KillTimer(Handle, 1);
  FMouseIn := False;
  inherited;
end;

procedure TbsSkinCustomEdit.WMTimer(var Message: TWMTimer); 
var
  P: TPoint;
begin
  inherited;
  if Message.TimerID = 1
  then
    begin
      GetCursorPos(P);
      if WindowFromPoint(P) <> Handle
      then
        begin
          KillTimer(Handle, 1);
          CMMouseLeave;
        end;
    end;
end;

procedure TbsSkinCustomEdit.WMNCHITTEST;
var
  P: TPoint;
  BR: TRect;
  ER: TRect;
begin
  if csDesigning in ComponentState
  then
    begin
      inherited;
      Exit;
    end;
  //
  if not FMouseIn and not (csDesigning in ComponentState) then CMMouseEnter;
  //
  if (FImages <> nil) and not (csDesigning in ComponentState)
  then
    begin
      P.X := Message.XPos;
      P.Y := Message.YPos;
      P := ScreenToClient(P);
      if (FLeftImageIndex >= 0) and PtInRect(LeftButton.R, P)
      then
        begin
          Message.Result := HTEDITBUTTONL;
          if not LeftButton.MouseIn
          then
            begin
              LeftButton.MouseIn := True;
              Invalidate;
            end;
          Exit;
        end
      else
      if (FRightImageIndex >= 0) and PtInRect(RightButton.R, P)
      then
        begin
          Message.Result := HTEDITBUTTONR;
          if not RightButton.MouseIn
          then
            begin
              RightButton.MouseIn := True;
              Invalidate;
            end;
          Exit;
        end;
     end;

  if (FImages <> nil) and not (csDesigning in ComponentState)
  then
    begin
      if LeftButton.MouseIn
      then
        begin
          LeftButton.MouseIn := False;
          Invalidate;
        end;
      if  RightButton.MouseIn
      then
        begin
          RightButton.MouseIn := False;
          Invalidate;
        end;
    end;

  if FButtonMode and not (csDesigning in ComponentState)
  then
    begin
      P.X := Message.XPos;
      P.Y := Message.YPos;
      P := ScreenToClient(P);
      if FIndex = -1
      then
        begin
          Inc(P.X, 2);
          Inc(P.Y, 2);
        end
      else
        begin
          Inc(P.X, ClRect.Left);
          Inc(P.Y, ClRect.Top);
        end;
      CalcRects;
      BR := FButtonRect;
      ER := FEditRect;
      if PtInRect(BR, P)
      then
         Message.Result := HTEDITBUTTON
      else
        if not PtInRect(ER, P)
      then
        Message.Result := HTEDITFRAME
      else
        inherited;
   end
  else
    inherited;
end;

procedure TbsSkinCustomEdit.WMNCLBUTTONDBCLK;
begin
 if csDesigning in ComponentState
  then
    begin
      inherited;
      Exit;
    end;
  //
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONL)
  then
    begin
      LeftButton.Down := True;
      if not Focused then SetFocus;
      Invalidate;
    end
  else
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONR)
  then
    begin
      RightButton.Down := True;
      if not Focused then SetFocus;
      Invalidate;
    end
  else
  if FButtonMode and (Message.HitTest = HTEDITBUTTON) and
     not (csDesigning in ComponentState)
  then
    begin
      FButtonDown := True;
      InvalidateNC;
    end
  else
    inherited;
end;

procedure TbsSkinCustomEdit.WMNCLBUTTONDOWN;
begin
  if csDesigning in ComponentState
  then
    begin
      inherited;
      Exit;
    end;
  //
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONL)
  then
    begin
      LeftButton.Down := True;
      if not Focused then SetFocus;
      Invalidate;
    end
  else
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONR)
  then
    begin
      RightButton.Down := True;
      if not Focused then SetFocus;
      Invalidate;
    end
  else
  if FButtonMode and (Message.HitTest = HTEDITBUTTON) and
     not (csDesigning in ComponentState)
  then
    begin
      FButtonDown := True;
      InvalidateNC;
    end
  else
    inherited;
end;

procedure TbsSkinCustomEdit.WMNCLBUTTONUP;
begin
  if csDesigning in ComponentState
  then
    begin
      inherited;
      Exit;
    end;
  //
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONL) and LeftButton.Down
  then
    begin
      LeftButton.Down := False;
      Invalidate;
      if Assigned(FOnLeftButtonClick) then FOnLeftButtonClick(Self);
    end
  else
  if (FImages <> nil) and (Message.HitTest = HTEDITBUTTONR) and RightButton.Down
  then
    begin
      RightButton.Down := False;
      Invalidate;
      if Assigned(FOnRightButtonClick) then FOnRightButtonClick(Self);
    end
  else
  if FButtonMode and (Message.HitTest = HTEDITBUTTON) and
     not (csDesigning in ComponentState)
  then
    begin
      FButtonDown := False;
      InvalidateNC;
      if not Focused then SetFocus;
      if Assigned(FOnButtonClick) then FOnButtonClick(Self);
    end
  else
    inherited;
end;

procedure TbsSkinCustomEdit.WMNCMOUSEMOVE;
begin
  if csDesigning in ComponentState
  then
    begin
      inherited;
      Exit;
    end;
  //
  if FButtonMode and not (csDesigning in ComponentState)
  then
    begin
      if Message.HitTest = HTEDITBUTTON
      then
        begin
          if not FButtonActive
          then
             begin
               FButtonActive := True;
               InvalidateNC;
               Invalidate;
             end
        end
      else
        begin
          if FButtonActive
          then
           begin
             FButtonActive := False;
             InvalidateNC;
             Invalidate;
           end;
           inherited;
         end
    end
  else
    inherited;
end;

procedure TbsSkinCustomEdit.SetButtonMode;
begin
  FButtonMode := Value;
  ReCreateWnd;
  if (csDesigning in ComponentState) and not
     (csLoading in ComponentState)
  then
    begin
      if FButtonMode
      then FSkinDataName := 'buttonedit'
      else FSkinDataName := 'edit';
    end;
end;


procedure TbsSkinCustomEdit.InvalidateNC;
begin
  if Parent = nil then Exit;
  if (csLoading in ComponentState) then Exit;
  if not HandleAllocated then Exit;

  SendMessage(Handle, WM_NCPAINT, 0, 0);
  DoPaint;
end;

procedure TbsSkinCustomEdit.WMSETFOCUS;
begin
  inherited;
  InvalidateNC;
  if not FMouseIn and (FIndex <> -1) then Font.Color := ActiveFontColor;
  if FImages <> nil then AdjustTextRect(True);
  Invalidate;
end;

procedure TbsSkinCustomEdit.WMKILLFOCUS;
begin
  inherited;
  InvalidateNC;
  if not FMouseIn and (FIndex <> -1) then Font.Color := FontColor;
  if FImages <> nil then AdjustTextRect(True);
  Invalidate;
end;

procedure TbsSkinCustomEdit.CMMouseEnter;
begin
  FMouseIn := True;
  if not Focused and (FIndex <> -1)
  then
    begin
      Font.Color := ActiveFontColor;
      if FImages <> nil then AdjustTextRect(True);
      InvalidateNC;
    end;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
  if CheckActivation
  then
    begin
      KillTimer(Handle, 1);
      SetTimer(Handle, 1, 100, nil);
    end;  
end;

procedure TbsSkinCustomEdit.CMMouseLeave;
begin
  FMouseIn := False;
  if not Focused and (FIndex <> -1)
  then
    begin
      Font.Color := FontColor;
      if FImages <> nil then AdjustTextRect(True);
      InvalidateNC;
    end;
  if FButtonDown or FButtonActive
  then
    begin
      FButtonActive := False;
      FButtonDown := False;
      InvalidateNC;
    end;

  if (FImages <> nil)
  then
    begin
      if LeftButton.MouseIn
      then
        begin
          LeftButton.MouseIn := False;
          DoPaint;
        end;
      if  RightButton.MouseIn
      then
        begin
          RightButton.MouseIn := False;
          DoPaint;
        end;
    end;

  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TbsSkinCustomEdit.SetBounds;
var
  UpDate: Boolean;
  R: TRect;
begin
  GetSkinData;

  UpDate := ((Width <> AWidth) or (Height <> AHeight)) and
             ((FIndex <> -1) or not FUseSkinFont);

  if (FIndex = -1) and
     (Align <> alClient) and (Align <> alLeft) and (Align <> alRight)
  then
    begin
      CalcEditHeight(AHeight);
    end
  else
  if UpDate
  then
    if UseSkinFont
    then
      begin
        if FIndex <> -1 then  AHeight := RectHeight(SkinRect);
      end
    else
      CalcEditHeight(AHeight);

  if (Parent is TbsSkinToolbar) and (Align <> alNone)
  then
    begin
      if TbsSkinToolbar(Parent).AdjustControls
      then
        with TbsSkinToolbar(Parent) do
        begin
          R := GetSkinClientRect;
          ATop := R.Top + RectHeight(R) div 2 - AHeight div 2;
        end;
    end;

  inherited;
  InvalidateNC;
end;

procedure TbsSkinCustomEdit.WMNCCALCSIZE;
begin
  GetSkinData;
  if FIndex = -1
  then
    with Message.CalcSize_Params^.rgrc[0] do
    begin
      Inc(Left, 2);
      Inc(Top, 2);
      if FButtonMode
      then Dec(Right, Height + 2)
      else Dec(Right, 2);
      Dec(Bottom, 2);
    end
  else
    with Message.CalcSize_Params^.rgrc[0] do
    begin
      Inc(Left, ClRect.Left);
      Inc(Top, ClRect.Top);
      Dec(Right, RectWidth(SkinRect) - ClRect.Right);
      Dec(Bottom, RectHeight(SkinRect) - ClRect.Bottom);
    end;
end;

procedure TbsSkinCustomEdit.AdjustTextRect;
var
  R: TRect;
begin
  if not HandleAllocated then Exit;
  if FImages = nil then Exit;
  LeftButton.R := NullRect;
  RightButton.R := NullRect;
  R := ClientRect;
  if FLeftImageIndex >= 0
  then
     begin
       LeftButton.R := Rect(R.Left, R.Top, R.Left + FImages.Width, R.Bottom);
       Inc(R.Left, FImages.Width + 2);
     end;
  if FRightImageIndex >= 0
  then
    begin
      RightButton.R := Rect(R.Right - FImages.Width, R.Top, R.Right, R.Bottom);
      Dec(R.Right, FImages.Width + 2);
    end;
  if Update then Perform(EM_SETRECTNP, 0, Longint(@R));
end;

procedure TbsSkinCustomEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[TAlignment] of DWORD = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := Exstyle and not WS_EX_Transparent;
    Style := Style and not WS_BORDER or Alignments[FAlignment];
  end;
end;

procedure TbsSkinCustomEdit.DrawEditBackGround(C: TCanvas);
var
  B: TBitMap;
  R: TRect;
  LO, RO: Integer;
begin
  if RectWidth(FEditRect) <= 0 then Exit;
  if RectHeight(FEditRect) <= 0 then Exit;
  B := TBitMap.Create;
  B.Width := RectWidth(FEditRect);
  B.Height := RectWidth(FEditRect);
  GetSkinData;
  if FIndex = -1
  then
    begin
      B.Canvas.Brush.Color := FDefaultColor;
      R := Rect(0, 0, B.Width, B.Height);
      B.Canvas.FillRect(R);
      C.Draw(0, 0, B);
      B.Free;
      Exit;
    end;
  //
  if FMouseIn or Focused
  then
    R := ActiveSkinRect
  else
    R := SkinRect;
  R.Left := R.Left + ClRect.Left;
  R.Top :=  R.Top + ClRect.Top;
  R.Right := R.Left + RectWidth(ClRect);
  R.Bottom := R.Top + RectHeight(ClRect);
  LO := LOffset - ClRect.Left;
  if LO < 0 then LO := 0;
  RO := RectWidth(SkinRect) - ROffset;
  RO := ClRect.Right - RO;
  if RO < 0 then RO := 0;
  //
  CreateHSkinImage(LO, RO, B, Picture, R, B.Width, RectHeight(ClRect), StretchEffect);
  //
  if Self.FUseSkinFont
  then
    C.Draw(0, 0, B)
  else
    begin
      R := Rect(0, 0, RectWidth(FEditRect), RectHeight(FEditRect));
      C.StretchDraw(R, B);
    end;
  B.Free;
end;

procedure TbsSkinCustomEdit.PaintSkinTo2(C: TCanvas; X, Y: Integer; AText: String);
var
  R: TRect;
  TX, TY, Offset: Integer;
  BR, BR2: TRect;
  B: TBitMap;
begin
  if Width <= 0 then Exit;
  if Height <= 0 then Exit;
  GetSkinData;
  if FIndex = -1
  then
    begin
      Exit;
    end;
  CalcRects;
  if FButtonMode then Offset := Width - FButtonRect.Left else Offset := 0;
  B := TBitMap.Create;
  B.Width := Width;
  B.Height := Height;
  try
    if UseSkinFont
    then
      begin
        CreateHSkinImage(LOffset, ROffset, B, Picture, SkinRect, Width,
                          RectHeight(SkinRect), StretchEffect);
      end
    else
      begin
        CreateStretchImage(B, Picture, SkinRect, ClRect, False);
        if FButtonMode
        then
           DrawResizeButton(B.Canvas, FButtonRect);
      end;
    // Draw text
    with B.Canvas do
    begin
      Brush.Style := bsClear;
      if (FIndex = -1) or not FUseSkinFont
      then
       Font := DefaultFont
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := FontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;
         R := FEditRect;

        if (FImages <> nil) and (FLeftImageIndex >= 0)
        then
          R.Left := R.Left + FImages.Width + 2;
        if (FImages <> nil) and (FRightImageIndex >= 0)
        then
          R.Right := R.Right - (FImages.Width + 2);

        TY := R.Top - 1;
        TX := R.Left + 1;
        case Alignment of
          taCenter:
             TX := TX + RectWidth(R) div 2 - TextWidth(AText) div 2;
          taRightJustify:
             TX := R.Right - 1 - TextWidth(AText);
         end;
        TextRect(R, TX + 1, TY + 1, AText);
      end;
    //
    C.Draw(X, Y, B);
  finally
    B.Free;
  end;
end;

procedure TbsSkinCustomEdit.DrawResizeButton;
var
  Buffer: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  BtnCLRect: TRect;
  BSR, ABSR, DBSR: TRect;
  XO, YO, IX, IY: Integer;
  ArrowColor: TColor;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(ButtonR);
  Buffer.Height := RectHeight(ButtonR);
  //
  CIndex := SkinData.GetControlIndex('editbutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('combobutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('resizebutton');
  if CIndex = -1
  then
    begin
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
    XO := RectWidth(ButtonR) - RectWidth(SkinRect);
    YO := RectHeight(ButtonR) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if  (FButtonDown and FButtonActive)
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := DownFontColor;
      end
    else
    if FButtonActive
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := FontColor;
      end;
   end;
  //
  if (FImages <> nil) and (FButtonImageIndex >= 0) and (FButtonImageIndex < FImages.Count)
  then
    begin
      IX := Buffer.Width div 2 - FImages.Width div 2;
      IY := Buffer.Height div 2 - FImages.Height div 2;
      FImages.Draw(Buffer.Canvas, IX, IY, FButtonImageIndex, Self.Enabled);
    end;
  //
  C.Draw(ButtonR.Left, ButtonR.Top, Buffer);
  Buffer.Free;
end;


procedure TbsSkinCustomEdit.DrawSkinEdit2(C: TCanvas; ADrawText: Boolean; AText: String);
var
  R: TRect;
  TX, TY, Offset: Integer;
  B: TBitMap;
begin
  if Width <= 0 then Exit;
  if Height <= 0 then Exit;
  GetSkinData;
  CalcRects;
  if FButtonMode then Offset := Width - FButtonRect.Left else Offset := 0;
  B := TBitMap.Create;
  B.Width := Width;
  B.Height := Height;
  try
    if FMouseIn or Focused
    then
      CreateStretchImage(B, Picture, ActiveSkinRect, ClRect, False)
    else
      CreateStretchImage(B, Picture, SkinRect, ClRect, False);
    // draw button
    if FButtonMode
    then
      DrawResizeButton(B.Canvas, FButtonRect);
    // Draw text
    if ADrawText
    then
      with B.Canvas do
      begin
        Brush.Style := bsClear;
        if (FIndex = -1) or not FUseSkinFont
        then
          Font := DefaultFont
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := FontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;

        R := FEditRect;

        if (FImages <> nil) and (FLeftImageIndex >= 0)
        then
          R.Left := R.Left + FImages.Width + 2;
        if (FImages <> nil) and (FRightImageIndex >= 0)
        then
          R.Right := R.Right - (FImages.Width + 2);

        TY := R.Top - 1;
        TX := R.Left + 1;
        case Alignment of
          taCenter:
             TX := TX + RectWidth(R) div 2 - TextWidth(AText) div 2;
          taRightJustify:
             TX := R.Right - 1 - TextWidth(AText);
         end;
        TextRect(R, TX, TY, AText);
      end;
    //
    C.Draw(0, 0, B);
  finally
    B.Free;
  end;
end;


procedure TbsSkinCustomEdit.PaintSkinTo1;
var
  R: TRect;
  TX, TY, IX, IY, Offset: Integer;
  BR: TRect;
  B: TBitMap;
begin
  if Width <= 0 then Exit;
  if Height <= 0 then Exit;
  GetSkinData;
  CalcRects;
  if FButtonMode then Offset := Width - FButtonRect.Left else Offset := 0;
  B := TBitMap.Create;
  B.Width := Width;
  B.Height := Height;
  try
    if FIndex = -1
    then
      with B.Canvas do
      begin
        // draw frame
        R := Rect(0, 0, Width - Offset, Height);
        Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
        Frame3D(B.Canvas, R, clBtnFace, clBtnFace, 1);
        Brush.Color := FDefaultColor;
        FillRect(R);
        // draw button
        if FButtonMode
        then
          begin
            CalcRects;
            R := FButtonRect;
            if FButtonDown and FButtonActive
            then
              begin
                Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
                Brush.Color :=  BS_BTNDOWNCOLOR;
                FillRect(R);
              end
            else
            if FButtonActive
            then
              begin
                Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
                Brush.Color :=  BS_BTNACTIVECOLOR;
                FillRect(R);
              end
            else
              begin
                Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
                Brush.Color := clBtnFace;
                FillRect(R);
              end;
            if (FImages <> nil) and (FButtonImageIndex >= 0) and (FButtonImageIndex < FImages.Count)
            then
              begin
                IX := FButtonRect.Left + RectWidth(FButtonRect) div 2 - FImages.Width div 2;
                IY := FButtonRect.Top + RectHeight(FButtonRect) div 2 - FImages.Height div 2;
                FImages.Draw(B.Canvas, IX, IY, FButtonImageIndex, Self.Enabled);
              end;
          end;
      end
    else
      begin
        if FMouseIn or Focused
        then
          CreateHSkinImage(LOffset, ROffset, B, Picture, ActiveSkinRect, Width,
            RectHeight(ActiveSkinRect), StretchEffect)
        else
          CreateHSkinImage(LOffset, ROffset, B, Picture, SkinRect, Width,
                           RectHeight(SkinRect), StretchEffect);
        // draw button
        if FButtonMode
        then
          begin
            BR := NullRect;
            if not Enabled and not IsNullRect(UnEnabledButtonRect)
            then
              BR := UnEnabledButtonRect
            else  
            if FButtonDown and FButtonActive
            then
              BR := DownButtonRect
            else if FButtonActive then BR := ActiveButtonRect;
            if not IsNullRect(BR)
            then
              B.Canvas.CopyRect(FButtonRect, Picture.Canvas, BR);
            if (FImages <> nil) and (FButtonImageIndex >= 0) and (FButtonImageIndex < FImages.Count)
            then
              begin
                IX := FButtonRect.Left + RectWidth(FButtonRect) div 2 - FImages.Width div 2;
                IY := FButtonRect.Top + RectHeight(FButtonRect) div 2 - FImages.Height div 2;
                FImages.Draw(B.Canvas, IX, IY, FButtonImageIndex, Self.Enabled);
              end;
          end;
      end;

    // Draw text
      with B.Canvas do
      begin
        Brush.Style := bsClear;
        if (FIndex = -1) or not FUseSkinFont
        then
          Font := DefaultFont
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := FontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;

        R := FEditRect;

        if (FImages <> nil) and (FLeftImageIndex >= 0)
        then
          R.Left := R.Left + FImages.Width + 2;
        if (FImages <> nil) and (FRightImageIndex >= 0)
        then
          R.Right := R.Right - (FImages.Width + 2);

        R := FEditRect;

        if (FImages <> nil) and (FLeftImageIndex >= 0)
        then
          R.Left := R.Left + FImages.Width + 2;
        if (FImages <> nil) and (FRightImageIndex >= 0)
        then
          R.Right := R.Right - (FImages.Width + 2);

        TY := R.Top - 1;
        TX := R.Left + 1;
        case Alignment of
          taCenter:
             TX := TX + RectWidth(R) div 2 - TextWidth(AText) div 2;
          taRightJustify:
             TX := R.Right - 1 - TextWidth(AText);
         end;
        TextRect(R, TX + 1, TY + 1, AText);
      end;
    //
    C.Draw(X, Y, B);
  finally
    B.Free;
  end;
end;


procedure TbsSkinCustomEdit.PaintSkinTo;
begin
  GetskinData;
  if FIndex = -1
  then PaintSkinTo1(C, X, Y, AText)
  else PaintSkinTo2(C, X, Y, AText);
end;

procedure TbsSkinCustomEdit.DrawSkinEdit;
var
  R: TRect;
  TX, TY, IX, IY, Offset: Integer;
  BR: TRect;
  B: TBitMap;
begin
  if Width <= 0 then Exit;
  if Height <= 0 then Exit;

  GetSkinData;
  CalcRects;
  if FButtonMode then Offset := Width - FButtonRect.Left - 1 else Offset := 0;
  B := TBitMap.Create;
  B.Width := Width;
  B.Height := Height;
  try
    if FIndex = -1
    then
      with B.Canvas do
      begin
        // draw frame
        R := Rect(0, 0, Width - Offset, Height);
        Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
        Frame3D(B.Canvas, R, Color, Color, 1);
        Brush.Color := FDefaultColor;
        FillRect(R);
        //
        // draw button
        if FButtonMode
        then
          begin
            CalcRects;
            R := FButtonRect;
            if FButtonDown and FButtonActive
            then
              begin
                Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
                Brush.Color :=  BS_BTNDOWNCOLOR;
                FillRect(R);
              end
            else
            if FButtonActive
            then
              begin
                Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
                Brush.Color :=  BS_BTNACTIVECOLOR;
                FillRect(R);
              end
            else
              begin
                Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
                Brush.Color := clBtnFace;
                FillRect(R);
              end;
            if (FImages <> nil) and (FButtonImageIndex >= 0) and (FButtonImageIndex < FImages.Count)
            then
              begin
                IX := FButtonRect.Left + RectWidth(FButtonRect) div 2 - FImages.Width div 2;
                IY := FButtonRect.Top + RectHeight(FButtonRect) div 2 - FImages.Height div 2;
                FImages.Draw(B.Canvas, IX, IY, FButtonImageIndex, Self.Enabled);
              end;
          end;
      end
    else
      begin
        if FMouseIn or Focused
        then
          CreateHSkinImage(LOffset, ROffset, B, Picture, ActiveSkinRect, Width,
            RectHeight(ActiveSkinRect), StretchEffect)
        else
          CreateHSkinImage(LOffset, ROffset, B, Picture, SkinRect, Width,
                           RectHeight(SkinRect), StretchEffect);
        // draw button
        //
        if FButtonMode
        then
          begin
            BR := NullRect;
            if not Enabled and not IsNullRect(UnEnabledButtonRect)
            then
              BR := UnEnabledButtonRect
            else  
            if FButtonDown and FButtonActive
            then
              BR := DownButtonRect
            else if FButtonActive then BR := ActiveButtonRect;
            if not IsNullRect(BR)
            then
              B.Canvas.CopyRect(FButtonRect, Picture.Canvas, BR);
            if (FImages <> nil) and (FButtonImageIndex >= 0) and (FButtonImageIndex < FImages.Count)
            then
              begin
                IX := FButtonRect.Left + RectWidth(FButtonRect) div 2 - FImages.Width div 2;
                IY := FButtonRect.Top + RectHeight(FButtonRect) div 2 - FImages.Height div 2;
                FImages.Draw(B.Canvas, IX, IY, FButtonImageIndex, Self.Enabled);
              end;
          end;
        //
      end;

    // Draw text
    if ADrawText
    then
      with B.Canvas do
      begin
        Brush.Style := bsClear;
        if (FIndex = -1) or not FUseSkinFont
        then
          Font := DefaultFont
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := FontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;

        R := FEditRect;

        if (FImages <> nil) and (FLeftImageIndex >= 0)
        then
          R.Left := R.Left + FImages.Width + 2;
        if (FImages <> nil) and (FRightImageIndex >= 0)
        then
          R.Right := R.Right - (FImages.Width + 2);

        TY := R.Top - 1;
        TX := R.Left + 1;
        case Alignment of
          taCenter:
             TX := TX + RectWidth(R) div 2 - TextWidth(AText) div 2;
          taRightJustify:
             TX := R.Right - 1 - TextWidth(AText);
         end;
        TextRect(R, TX, TY, AText);
      end;
    //
    C.Draw(0, 0, B);
  finally
    B.Free;
  end;
end;


procedure TbsSkinCustomEdit.CMSENCPaint(var Message: TMessage);
var
  C: TCanvas;
begin
  if (Message.wParam <> 0)
  then
    begin
      C := TControlCanvas.Create;
      C.Handle := Message.wParam;
      try
       if UseSkinFont or (FIndex = -1)
       then
         DrawSkinEdit(C, False, Text)
       else
         DrawSkinEdit2(C, False, Text);
       finally
         C.Handle := 0;
         C.Free;
       end;
      Message.Result := SE_RESULT;
    end;
end;

procedure TbsSkinCustomEdit.CMBENCPAINT;
var
  C: TCanvas;
begin
  if (Message.LParam = BE_ID)
  then
    begin
      if (Message.wParam <> 0)
      then
      begin
        C := TControlCanvas.Create;
        C.Handle := Message.wParam;
        ExcludeClipRect(C.Handle,
        FEditRect.lEft, FEditRect.Top,
        FEditRect.Right, FEditRect.Bottom);
        try
          if UseSkinFont or (FIndex = -1)
        then
          DrawSkinEdit(C, False, Text)
        else
          DrawSkinEdit2(C, False, Text);
       finally
         C.Handle := 0;
         C.Free;
       end;
      end;
      Message.Result := BE_ID;
    end
  else
    inherited;
end;  

procedure TbsSkinCustomEdit.GetSkinData;
begin
  if FSD = nil
  then
    begin
      FIndex := -1;
      Exit;
    end;

  if FSD.Empty
  then
    FIndex := -1
  else
    FIndex := FSD.GetControlIndex(FSkinDataName);

  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinEditControl
    then
      with TbsDataSkinEditControl(FSD.CtrlList.Items[FIndex]) do
      begin
        if (PictureIndex <> -1) and (PictureIndex < FSD.FActivePictures.Count)
        then
          Picture := TBitMap(FSD.FActivePictures.Items[PictureIndex])
        else
          Picture := nil;
        Self.SkinRect := SkinRect;
        Self.ActiveSkinRect := ActiveSkinRect;
        if isNullRect(ActiveSkinRect)
        then
          Self.ActiveSkinRect := SkinRect;
        LOffset := LTPoint.X;
        ROffset := RectWidth(SkinRect) - RTPoint.X;
        Self.ClRect := ClRect;
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.DisabledFontColor := DisabledFontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.ButtonRect := ButtonRect;
        Self.ActiveButtonRect := ActiveButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.UnEnabledButtonRect := UnEnabledButtonRect;
        Self.StretchEffect := StretchEffect;
        if IsNullRect(Self.DownButtonRect)
        then Self.DownButtonRect := Self.ActiveButtonRect;
      end;

end;

procedure TbsSkinCustomEdit.SetSkinData;
begin
  FSD := Value;
  if (FSD <> nil) then
  if not FSD.Empty and not (csDesigning in ComponentState)
  then
    ChangeSkinData;
end;

procedure TbsSkinCustomEdit.Notification;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSD) then FSD := nil;
  if (Operation = opRemove) and (AComponent = FImages) then FImages := nil;
end;

procedure TbsSkinCustomEdit.ChangeSkinData;
var
  R: TRect;
begin
  GetSkinData;
  //
  if (FIndex <> -1)
  then
    begin
      if FUseSkinFont
      then
        begin
          Font.Name := FontName;
          Font.Style := FontStyle;
          if UseSkinFont
          then
            Height := RectHeight(SkinRect);
          Font.Height := FontHeight;
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end
      else
        begin
          Font.Assign(FDefaultFont);
          if FUseSkinFont
          then
            Height := RectHeight(SkinRect);
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end;
    end
  else
    begin
      Font.Assign(FDefaultFont);
      if FDefaultWidth > 0 then Width := FDefaultWidth;
      if FDefaultHeight > 0 then Height := FDefaultHeight;
    end;
  //
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinData.ResourceStrData.CharSet
  else
    Font.CharSet := FDefaultFont.CharSet;
  //
  ReCreateWnd;

  if FIndex = -1
  then
    Font.Color := FDefaultFont.Color
  else
  if Focused
  then
    Font.Color := ActiveFontColor
  else
    Font.Color := FontColor;

  if not UseSkinFont then AdjustEditHeight;
  InvalidateNC;
  if FImages <> nil
  then
    begin
      AdjustTextRect(True);
      Invalidate;
    end;
end;

constructor TbsSkinPopupMonthCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable];
end;

procedure TbsSkinPopupMonthCalendar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW;
    WindowClass.Style := CS_SAVEBITS;
    if CheckWXP then
      WindowClass.Style := WindowClass.style or CS_DROPSHADOW_;
  end;
end;

procedure TbsSkinPopupMonthCalendar.WMMouseActivate(var Message: TMessage);
begin
  Message.Result := MA_NOACTIVATE;
end;

procedure ScanBlanks(const S: string; var Pos: Integer);
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and (S[I] = ' ') do Inc(I);
  Pos := I;
end;

function ScanNumber(const S: string; MaxLength: Integer; var Pos: Integer;
  var Number: Longint): Boolean;
var
  I: Integer;
  N: Word;
begin
  Result := False;
  ScanBlanks(S, Pos);
  I := Pos;
  N := 0;
  while (I <= Length(S)) and (Longint(I - Pos) < MaxLength) and
    (S[I] in ['0'..'9']) and (N < 1000) do
  begin
    N := N * 10 + (Ord(S[I]) - Ord('0'));
    Inc(I);
  end;
  if I > Pos then begin
    Pos := I;
    Number := N;
    Result := True;
  end;
end;

function ScanChar(const S: string; var Pos: Integer; Ch: Char): Boolean;
begin
  Result := False;
  ScanBlanks(S, Pos);
  if (Pos <= Length(S)) and (S[Pos] = Ch) then begin
    Inc(Pos);
    Result := True;
  end;
end;


constructor TbsSkinDateEdit.Create(AOwner: TComponent);
begin
  inherited;
  FBlanksChar := ' ';
  EditMask := GetDateMask;
  ButtonMode := True;
  FSkinDataName := 'buttonedit';
  FMonthCalendar := TbsSkinPopupMonthCalendar.Create(Self);
  FMonthCalendar.Parent := Self;
  FMonthCalendar.Visible := False;
  FMonthCalendar.OnMouseUp := CalendarMouseUp;
  FMonthCalendar.OnNumberClick := CalendarClick;
  FMonthCalendar.Date := 0;
  FAlphaBlend := False;
  FAlphaBlendValue := 0;
  FAlphaBlendAnimation := False;
  OnButtonClick := ButtonClick;
  FTodayDefault := False;
end;

destructor TbsSkinDateEdit.Destroy;
begin
  FMonthCalendar.Free;
  inherited;
end;

function TbsSkinDateEdit.GetShowToday: Boolean;
begin
  Result := FMonthCalendar.ShowToday;
end;

procedure TbsSkinDateEdit.SetShowToday(Value: Boolean);
begin
  FMonthCalendar.ShowToday := Value;
end;

function TbsSkinDateEdit.GetWeekNumbers: Boolean;
begin
  Result := FMonthCalendar.WeekNumbers;
end;

procedure TbsSkinDateEdit.SetWeekNumbers(Value: Boolean);
begin
  FMonthCalendar.WeekNumbers := Value;
end;

function TbsSkinDateEdit.GetCalendarUseSkinFont: Boolean;
begin
  Result := FMonthCalendar.UseSkinFont;
end;

procedure TbsSkinDateEdit.SetCalendarUseSkinFont(Value: Boolean);
begin
  FMonthCalendar.UseSkinFont := Value;
end;

function TbsSkinDateEdit.GetCalendarSkinDataName: String;
begin
  Result := FMonthCalendar.SkinDataName;
end;

procedure TbsSkinDateEdit.SetCalendarSkinDataName(Value: String);
begin
  FMonthCalendar.SkinDataName := Value;
end;

function TbsSkinDateEdit.GetCalendarBoldDays: Boolean;
begin
  Result := FMonthCalendar.BoldDays;
end;

procedure TbsSkinDateEdit.SetCalendarBoldDays(Value: Boolean);
begin
  FMonthCalendar.BoldDays := Value;
end;

procedure TbsSkinDateEdit.ValidateEdit;
var
  Str: string;
  Pos: Integer;
begin
  Str := EditText;
  if IsMasked and Modified
  then
    begin
      if not Validate(Str, Pos) then
      begin
      end;
    end;
end;

function TbsSkinDateEdit.IsDateInput: Boolean;
begin
  Result := IsValidText(Text);
end;

function TbsSkinDateEdit.MonthFromName(const S: string; MaxLen: Byte): Byte;
begin
  if Length(S) > 0 then
    for Result := 1 to 12 do begin
      if (Length({$IFDEF VER240_UP}FormatSettings.{$ENDIF}LongMonthNames[Result]) > 0) and
        (AnsiCompareText(Copy(S, 1, MaxLen),
        Copy({$IFDEF VER240_UP}FormatSettings.{$ENDIF}LongMonthNames[Result], 1, MaxLen)) = 0) then Exit;
    end;
  Result := 0;
end;

procedure TbsSkinDateEdit.ExtractMask(const Format, S: string; Ch: Char; Cnt: Integer;
  var I: Integer; Blank, Default: Integer);
var
  Tmp: string[20];
  J, L: Integer;
  S1: String;
begin
  I := Default;
  Ch := UpCase(Ch);
  L := Length(Format);
  if Length(S) < L then L := Length(S)
  else if Length(S) > L then Exit;
  S1 := MakeStr(Ch, Cnt);
  J := Pos(S1, AnsiUpperCase(Format));
  if J <= 0 then Exit;
  Tmp := '';
  while (UpCase(Format[J]) = Ch) and (J <= L) do begin
    if S[J] <> ' ' then Tmp := Tmp + S[J];
    Inc(J);
  end;
  if Tmp = '' then I := Blank
  else if Cnt > 1 then begin
    I := MonthFromName(Tmp, Length(Tmp));
    if I = 0 then I := -1;
  end
  else I := StrToIntDef(Tmp, -1);
end;

function TbsSkinDateEdit.CurrentYear: Word;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTime.wYear;
end;

function TbsSkinDateEdit.ExpandYear(Year: Integer): Integer;
var
  N: Longint;
begin
  Result := Year;
  if Result < 100 then begin
    N := CurrentYear - CenturyOffset;
    Inc(Result, N div 100 * 100);
    if (CenturyOffset > 0) and (Result < N) then
      Inc(Result, 100);
  end;
end;

function TbsSkinDateEdit.IsValidDate(Y, M, D: Word): Boolean;
begin
  Result := (Y >= 1) and (Y <= 9999) and (M >= 1) and (M <= 12) and
    (D >= 1) and (D <= DaysPerMonth(Y, M));
end;

function TbsSkinDateEdit.ScanDate(const S, DateFormat: string; var Pos: Integer;
  var Y, M, D: Integer): Boolean;
var
  DateOrder: TbsDateOrder;
  N1, N2, N3: Longint;
begin
  Result := False;
  Y := 0; M := 0; D := 0;
  DateOrder := GetDateOrder(DateFormat);
  if not (ScanNumber(S, MaxInt, Pos, N1) and ScanChar(S, Pos, {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DateSeparator) and
    ScanNumber(S, MaxInt, Pos, N2)) then Exit;
  if ScanChar(S, Pos, {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DateSeparator) then begin
    if not ScanNumber(S, MaxInt, Pos, N3) then Exit;
    case DateOrder of
      bsdoMDY: begin Y := N3; M := N1; D := N2; end;
      bsdoDMY: begin Y := N3; M := N2; D := N1; end;
      bsdoYMD: begin Y := N1; M := N2; D := N3; end;
    end;
    Y := ExpandYear(Y);
  end
  else begin
    Y := CurrentYear;
    if DateOrder = bsdoDMY then begin
      D := N1; M := N2;
    end
    else begin
      M := N1; D := N2;
    end;
  end;
  ScanChar(S, Pos, {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DateSeparator);
  ScanBlanks(S, Pos);
  Result := IsValidDate(Y, M, D) and (Pos > Length(S));
end;

function TbsSkinDateEdit.ScanDateStr(const Format, S: string; var D, M, Y: Integer): Boolean;
var
  Pos: Integer;
begin
  ExtractMask(Format, S, 'm', 3, M, -1, 0); { short month name? }
  if M = 0 then ExtractMask(Format, S, 'm', 1, M, -1, 0);
  ExtractMask(Format, S, 'd', 1, D, -1, 1);
  ExtractMask(Format, S, 'y', 1, Y, -1, CurrentYear);
  Y := ExpandYear(Y);
  Result := IsValidDate(Y, M, D);
  if not Result then begin
    Pos := 1;
    Result := ScanDate(S, Format, Pos, Y, M, D);
  end;
end;

function TbsSkinDateEdit.MyStrToDate(S: String): TDate;
var
  D, M, Y: Integer;
  B: Boolean;
begin
  if S = ''
  then
    Result := 0
  else
    begin
      B := ScanDateStr(DefDateFormat(FourDigitYear), S, D, M, Y);
      if B then
      try
        Result := EncodeDate(Y, M, D);
      except
        Result := 0;
      end;
    end;
end;

function TbsSkinDateEdit.MyDateToStr(Date: TDate): String;
begin
  Result := FormatDateTime(DefDateFormat(FourDigitYear), Date);
end;

function TbsSkinDateEdit.IsOnlyNumbers;
const
  DateSymbols = '0123456789';
var
  i: Integer;
  S1: String;
begin
  Result := True;
  S1 := DateSymbols;
  S1 := S1 + FBlanksChar;
  for i := 1 to Length(S) do
  begin
    if (Pos(S[i], S1) = 0) and (S[i] <> {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DateSeparator)
    then
      begin
        Result := False;
        Break;
      end;
  end;
end;

function TbsSkinDateEdit.FourDigitYear: Boolean;
begin
  Result := Pos('YYYY', AnsiUpperCase({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ShortDateFormat)) > 0;
end;

function TbsSkinDateEdit.GetDateOrder(const DateFormat: string): TbsDateOrder;
var
  I: Integer;
begin
  Result := bsdoMDY;
  I := 1;
  while I <= Length(DateFormat) do begin
    case Chr(Ord(DateFormat[I]) and $DF) of
      'Y': Result := bsdoYMD;
      'M': Result := bsdoMDY;
      'D': Result := bsdoDMY;
    else
      Inc(I);
      Continue;
    end;
    Exit;
  end;
  Result := bsdoMDY; 
end;


function TbsSkinDateEdit.DefDateFormat(FourDigitYear: Boolean): string;
begin
  if FourDigitYear then begin
    case GetDateOrder({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ShortDateFormat) of
      bsdoMDY: Result := 'MM/DD/YYYY';
      bsdoDMY: Result := 'DD/MM/YYYY';
      bsdoYMD: Result := 'YYYY/MM/DD';
    end;
  end
  else begin
    case GetDateOrder({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ShortDateFormat) of
      bsdoMDY: Result := 'MM/DD/YY';
      bsdoDMY: Result := 'DD/MM/YY';
      bsdoYMD: Result := 'YY/MM/DD';
    end;
  end;
end;

function TbsSkinDateEdit.DefDateMask(BlanksChar: Char; FourDigitYear: Boolean): string;
begin
  if FourDigitYear then begin
    case GetDateOrder({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ShortDateFormat) of
      bsdoMDY, bsdoDMY: Result := '!99/99/9999;1;';
      bsdoYMD: Result := '!9999/99/99;1;';
    end;
  end
  else begin
    case GetDateOrder({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ShortDateFormat) of
      bsdoMDY, bsdoDMY: Result := '!99/99/99;1;';
      bsdoYMD: Result := '!99/99/99;1;';
    end;
  end;
  if Result <> '' then Result := Result + BlanksChar;
end;

function TbsSkinDateEdit.GetDateMask: String;
begin
  Result := DefDateMask(FBlanksChar, FourDigitYear);
end;

procedure TbsSkinDateEdit.Loaded;
begin
  inherited;
  EditMask := GetDateMask;
  if FTodayDefault then Date := Now;
end;

procedure TbsSkinDateEdit.SetTodayDefault;
begin
  FTodayDefault := Value;
  if FTodayDefault then Date := Now;
end;

function TbsSkinDateEdit.GetCalendarFont;
begin
  Result := FMonthCalendar.DefaultFont;
end;

procedure TbsSkinDateEdit.SetCalendarFont;
begin
  FMonthCalendar.DefaultFont.Assign(Value);
end;

function TbsSkinDateEdit.GetCalendarWidth: Integer;
begin
  Result := FMonthCalendar.Width;
end;

procedure TbsSkinDateEdit.SetCalendarWidth(Value: Integer);
begin
  FMonthCalendar.Width := Value;
end;

function TbsSkinDateEdit.GetCalendarHeight: Integer;
begin
  Result := FMonthCalendar.Height;
end;

procedure TbsSkinDateEdit.SetCalendarHeight(Value: Integer);
begin
  FMonthCalendar.Height := Value;
end;

function TbsSkinDateEdit.GetDate: TDate;
begin
  Result := FMonthCalendar.Date;
end;

procedure TbsSkinDateEdit.SetDate(Value: TDate);
begin
  FMonthCalendar.Date := Value;
  StopCheck := True;
  if not (csLoading in ComponentState) or FTodayDefault
  then
    begin
      Text := MyDateToStr(Value);
    end;
  StopCheck := False;
  if Assigned(FOnDateChange) then FOnDateChange(Self);
end;

function TbsSkinDateEdit.IsValidText;
var
  D, M, Y: Integer;
  DF: String;
begin
  Result := IsOnlyNumbers(S);
  if Result
  then
    begin
      DF := DefDateFormat(FourDigitYear);
      Result := ScanDateStr(DF, S, D, M, Y);
    end;
end;

procedure TbsSkinDateEdit.Change;
begin
  inherited;
  if not StopCheck
  then
    if IsValidText(Text)
    then CheckValidDate;
end;

procedure TbsSkinDateEdit.CheckValidDate;
begin
  if FMonthCalendar = nil then Exit;
  FMonthCalendar.Date := MyStrToDate(Text);
  if Assigned(FOnDateChange) then FOnDateChange(Self);
end;

procedure TbsSkinDateEdit.CMCancelMode;
begin
 if (Message.Sender <> FMonthCalendar) and
     not FMonthCalendar.ContainsControl(Message.Sender)
 then
   CloseUp(False);
end;

procedure TbsSkinDateEdit.WndProc;
begin
  inherited;
  case Message.Msg of
   WM_KILLFOCUS:
     begin
       if not FMonthCalendar.Visible and FTodayDefault 
       then
         begin
           StopCheck := True;
           Text := MyDateToStr(FMonthCalendar.Date);
           StopCheck := False;
         end
       else
       if Message.wParam <> FMonthCalendar.Handle
       then
         CloseUp(False);
     end;
   WM_KEYDOWN:
      CloseUp(False);
  end;
end;

procedure TbsSkinDateEdit.DropDown;
var
  P: TPoint;
  I, Y: Integer;
  TickCount: DWORD;
  AnimationStep: Integer;
begin
  FDateSelected := False;
  if not FTodayDefault
  then
    begin
      FOldDateValue := FMonthCalendar.Date;
      if (FMonthCalendar.Date = 0) and (Pos(' ', Text) <> 0) then FMonthCalendar.Date := Now;
    end;  
  P := Parent.ClientToScreen(Point(Left, Top));
  Y := P.Y + Height;
  if Y + FMonthCalendar.Height > Screen.Height then Y := P.Y - FMonthCalendar.Height;
  //
  if CheckW2KWXP and FAlphaBlend
  then
    begin
      SetWindowLong(FMonthCalendar.Handle, GWL_EXSTYLE,
                    GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
      SetAlphaBlendTransparent(FMonthCalendar.Handle, 0)
    end;
  //
  FMonthCalendar.SkinData := Self.SkinData;
  SetWindowPos(FMonthCalendar.Handle, HWND_TOP, P.X, Y,
   0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FMonthCalendar.Visible := True;
  if FAlphaBlend and not FAlphaBlendAnimation and CheckW2KWXP
  then
    begin
      Application.ProcessMessages;
      SetAlphaBlendTransparent(FMonthCalendar.Handle, FAlphaBlendValue)
    end
  else
  if FAlphaBlendAnimation and FAlphaBlend and CheckW2KWXP
  then
    begin
      Application.ProcessMessages;
      I := 0;
      TickCount := 0;
       AnimationStep := FAlphaBlendValue div 15;
      if AnimationStep = 0 then AnimationStep := 1;
      repeat
        if (GetTickCount - TickCount > 5)
        then
          begin
            TickCount := GetTickCount;
            Inc(i, AnimationStep);
            if i > FAlphaBlendValue then i := FAlphaBlendValue;
            SetAlphaBlendTransparent(FMonthCalendar.Handle, i);
          end;  
       until i >= FAlphaBlendValue;
    end;
end;

procedure TbsSkinDateEdit.CloseUp(AcceptValue: Boolean);
begin
  if (FMonthCalendar <> nil) and FMonthCalendar.Visible
  then
    begin
      SetWindowPos(FMonthCalendar.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
      FMonthCalendar.Visible := False;
      if CheckW2KWXP and FAlphaBlend
      then
        SetWindowLong(FMonthCalendar.Handle, GWL_EXSTYLE,
                      GetWindowLong(Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
      if AcceptValue
      then
        begin
          StopCheck := True;
          Text := MyDateToStr(FMonthCalendar.Date);
          if Assigned(FOnDateChange) then FOnDateChange(Self);
          StopCheck := False;
        end
      else
        if not FTodayDefault then FMonthCalendar.Date := FOldDateValue;
      SetFocus;
   end;
end;

procedure TbsSkinDateEdit.ButtonClick(Sender: TObject);
begin
  if FMonthCalendar.Visible
  then
    CloseUp(False)
  else
    DropDown;
end;

procedure TbsSkinDateEdit.CalendarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDateSelected then CloseUp(True);
end;

procedure TbsSkinDateEdit.CalendarClick;
begin
  FDateSelected := True;
end;


function TbsSkinDateEdit.GetFirstDayOfWeek: TbsDaysOfWeek;
begin
  Result := FMonthCalendar.FirstDayOfWeek;
end;

procedure TbsSkinDateEdit.SetFirstDayOfWeek(Value: TbsDaysOfWeek);
begin
  FMonthCalendar.FirstDayOfWeek := Value;
end;

constructor TbsSkinURLEdit.Create;
begin
  inherited;
  FExecute := True;
  TempLabel := TLabel.Create(Self);
  TempLabel.AutoSize := True;
  FCanExecute := False;
  FState := bsstOUT;
  FBtnDown := False;
  FLinkType := bsltHttp;
end;

destructor TbsSkinURLEdit.Destroy;
begin
  TempLabel.Free;
  inherited;
end;

function TbsSkinURLEdit.InText;
begin
  if X < TempLabel.Width then Result := True else Result := False;
end;

procedure TbsSkinURLEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FExecute
  then
    if InText(X)
    then
      begin
        if (FState = bsstOUT) and (FBtnDown = False)
        then
          begin
            Font.Style := Font.Style + [fsUnderline];
            Cursor := crHandPoint;
            FCanExecute := True;
            FState := bsstIN;
            Refresh;
         end;
      end
    else
      begin
         if FState = bsstIN
         then
          begin
             Font.Style := Font.Style - [fsUnderline];
             Cursor := crDefault;
             FCanExecute := False;
             FState := bsstOUT;
             Refresh;
          end;
      end;
end;

procedure TbsSkinURLEdit.CMMouseEnter;
begin
  inherited;
  if FExecute
  then
     begin
       TempLabel.Caption := Self.Text;
       TempLabel.Font := Font;
     end;
end;

procedure TbsSkinURLEdit.CMMouseLeave;
begin
  inherited;
  if FState = bsstIN
  then
    begin
      Font.Style := Font.Style - [fsUnderline];
      Cursor := crDefault;
      FCanExecute := False;
      FState := bsstOUT;
      Refresh;
    end;
end;

procedure TbsSkinURLEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  FURL: String;
begin
  inherited;
  if Button = mbLeft then FBtnDown := True;
  if FExecute and FCanExecute
  then
    begin
      FURL := Text;
      if (FLinkType = bsltMail) and (Pos('@', FURL) = 0) then Exit;
      if FLinkType = bsltMail then FURL := 'mailto:' + FURL;
      ShellExecute(ValidParentForm(Self).handle, 'Open', PChar(FURL), nil, nil, SW_SHOWNORMAL);
    end;
end;

procedure TbsSkinURLEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FBtnDown := False;
end;

constructor TbsSkinMemo.Create;
begin
  inherited Create(AOwner);
  FTransparent := False;
  FWallpaper := TBitMap.Create;
  FWallpaperStretch := False;
  FIsScroll := False;
  FIsDown := False;
  FIsCanScroll := False;
  FBitMapBG := True;
  FStopDraw := False;
  AutoSize := False;
  FIndex := -1;
  Font.Name := 'Tahoma';
  Font.Height := 13;
  Font.Color := clBlack;
  FHScrollBar := nil;
  FVScrollBar := nil;
  FSkinDataName := 'memo';
  FDefaultFont := TFont.Create;
  FDefaultFont.Assign(Font);
  FDefaultFont.OnChange := OnDefaultFontChange;
  ScrollBars := ssBoth;
  FUseSkinFont := True;
  FUseSkinFontColor := True;
  FSysPopupMenu := nil;
  StretchEffect := False;
  StretchType := bsstFull;
end;

procedure TbsSkinMemo.Loaded;
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.SetWallPaper(Value: TBitmap);
begin
  FWallpaper.Assign(Value);
  if Value <> nil then FTransparent := True;
  RePaint;
end;

procedure TbsSkinMemo.SetWallPaperStretch(Value: Boolean);
begin
  FWallpaperStretch := Value;
  if not FWallpaper.Empty then RePaint;
end;

procedure TbsSkinMemo.SetTransparent;
begin
  FTransparent := Value;
  if FBitMapBG then DoPaint;
end;

procedure TbsSkinMemo.WMCHECKPARENTBG(var Msg: TWMEraseBkgnd);
begin
  if FBitMapBG and FTransparent and FWallPaper.Empty then DoPaint; 
end;

function TbsSkinMemo.GetDisabledFontColor: TColor;
var
  i: Integer;
begin
  i := -1;
  if FIndex <> -1 then i := SkinData.GetControlIndex('edit');
  if i = -1
  then
    Result := clGrayText
  else
    Result := TbsDataSkinEditControl(SkinData.CtrlList[i]).DisabledFontColor;
end;

procedure TbsSkinMemo.CMSENCPaint(var Message: TMessage);
var
  C: TCanvas;
begin
  if (Message.wParam <> 0)
  then
    begin
      C := TControlCanvas.Create;
      C.Handle := Message.wParam;
      try
        DrawMemoBackGround(C);
       finally
         C.Handle := 0;
         C.Free;
       end;
      Message.Result := SE_RESULT;
    end;
end;

procedure TbsSkinMemo.DoPaint2(DC: HDC); 
var
  MyDC: HDC;
  TempDC: HDC;
  OldBmp, TempBmp: HBITMAP;
begin
  if not HandleAllocated then Exit;
  FStopDraw := True;
  try
    MyDC := DC;
    try
      TempDC := CreateCompatibleDC(MyDC);
      try
        TempBmp := CreateCompatibleBitmap(MyDC, Succ(Width), Succ(Height));
        try
          OldBmp := SelectObject(TempDC, TempBmp);
          SendMessage(Handle, WM_ERASEBKGND, TempDC, 0);
          SendMessage(Handle, WM_PAINT, TempDC, 0);
          BitBlt(MyDC, 0, 0, Width, Height, TempDC, 0, 0, SRCCOPY);
          SelectObject(TempDC, OldBmp);
        finally
          DeleteObject(TempBmp);
        end;
      finally              
        DeleteDC(TempDC);
      end;
    finally
      ReleaseDC(Handle, MyDC);
    end;
  finally
    FStopDraw := False;
  end;
end;

procedure TbsSkinMemo.DoPaint;
var
  MyDC: HDC;
  TempDC: HDC;
  OldBmp, TempBmp: HBITMAP;
begin
  if not HandleAllocated then Exit;
  FStopDraw := True;
  begin
    HideCaret(Handle);
    try
      MyDC := GetDC(Handle);
      try
        TempDC := CreateCompatibleDC(MyDC);
        try
          TempBmp := CreateCompatibleBitmap(MyDC, Succ(Width), Succ(Height));
          try
            OldBmp := SelectObject(TempDC, TempBmp);
            SendMessage(Handle, WM_ERASEBKGND, TempDC, 0);
            SendMessage(Handle, WM_PAINT, TempDC, 0);
            BitBlt(MyDC, 0, 0, Width, Height, TempDC, 0, 0, SRCCOPY);
            SelectObject(TempDC, OldBmp);
          finally
            DeleteObject(TempBmp);
          end;
        finally
          DeleteDC(TempDC);
        end;
      finally
        ReleaseDC(Handle, MyDC);
      end;
    finally
      ShowCaret(Handle);
    end;
  end;
  FStopDraw := False;
end;


procedure TbsSkinMemo.WMPaint(var Message: TWMPaint);
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  R: TRect;
  S: string;
  FCanvas: TControlCanvas;
  DC: HDC;
  PS: TPaintStruct;
  TX, TY: Integer;
  LinesCount: Integer;
  VisibleLines: Integer;
  i, P: Integer;
  LineHeight: Integer;

function GetVisibleLines: Integer;
var
  R: TRect;
  C: TCanvas;
  DC: HDC;
begin
  C := TCanvas.Create;
  C.Font.Assign(Font);
  DC := GetDC(0);
  C.Handle := DC;
  R := GetClientRect;
  LineHeight := C.TextHeight('Wq');
  if LineHeight <> 0
  then
    Result := RectHeight(R) div LineHeight
  else
    Result := 1;
  ReleaseDC(0, DC);
  C.Free;
end;

begin
  //
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  //
  if Enabled
  then
    begin
      if not FStopDraw and FBitmapBG
      then
        begin
          DC := Message.DC;
          if DC = 0 then DC := BeginPaint(Handle, PS);
          DoPaint2(DC);
          ShowCaret(Handle);
          if DC = 0 then EndPaint(Handle, PS);
        end
      else
       inherited;
    end
  else
    begin
      FCanvas := TControlCanvas.Create;
      FCanvas.Control := Self;
      DC := Message.DC;
      if DC = 0 then DC := BeginPaint(Handle, PS);
      FCanvas.Handle := DC;
      //
      with FCanvas do
      begin
        if (FIndex = -1) or not FUseSkinFont
        then
          begin
            Font := DefaultFont;
            if FIndex = -1
            then Font.Color := clGrayText
            else Font.Color := GetDisabledFontColor;
          end
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := GetDisabledFontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;
      end;
      FCanvas.Brush.Style := bsClear;
      // draw text
      VisibleLines := GetVisibleLines;
      LinesCount := SendMessage(Self.Handle, EM_GETLINECOUNT, 0, 0);
      P := SendMessage(Self.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
      R := FTextArea;
      for i := P  to P + VisibleLines - 2 do
       if i < Lines.Count
       then
         begin
           S := Lines[i];
           DrawText(FCanvas.Handle, PChar(S), Length(S), R, Alignments[Alignment]);
           Inc(R.Top, LineHeight);
         end;
      //
      FCanvas.Handle := 0;
      FCanvas.Free;
      if Message.DC = 0 then EndPaint(Handle, PS);
    end;
end;

procedure TbsSkinMemo.SkinFramePaint(C: TCanvas);
var
  NewLTPoint, NewRTPoint, NewLBPoint, NewRBPoint: TPoint;
  R, NewClRect: TRect;
  LeftB, TopB, RightB, BottomB: TBitMap;
  OffX, OffY: Integer;
begin
  GetSkinData;
  if FIndex = -1
  then
    with C do
    begin
      Brush.Style := bsClear;
      R := Rect(0, 0, Width, Height);
      Frame3D(C, R, clBtnShadow, clBtnShadow, 1);
      Frame3D(C, R, clBtnFace, clBtnFace, 1);
      Exit;
    end;

  LeftB := TBitMap.Create;
  TopB := TBitMap.Create;
  RightB := TBitMap.Create;
  BottomB := TBitMap.Create;

  OffX := Width - RectWidth(SkinRect);
  OffY := Height - RectHeight(SkinRect);

  NewLTPoint := LTPoint;
  NewRTPoint := Point(RTPoint.X + OffX, RTPoint.Y);
  NewLBPoint := Point(LBPoint.X, LBPoint.Y + OffY);
  NewRBPoint := Point(RBPoint.X + OffX, RBPoint.Y + OffY);
  NewClRect := Rect(ClRect.Left, ClRect.Top,
                    ClRect.Right + OffX, ClRect.Bottom + OffY);

  if FMouseIn or Focused
  then
    CreateSkinBorderImages(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
      NewLtPoint, NewRTPoint, NewLBPoint, NewRBPoint, NewCLRect,
      LeftB, TopB, RightB, BottomB, Picture, ActiveSkinRect, Width, Height,
      LeftStretch, TopStretch, RightStretch, BottomStretch)
  else
    CreateSkinBorderImages(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
      NewLtPoint, NewRTPoint, NewLBPoint, NewRBPoint, NewCLRect,
      LeftB, TopB, RightB, BottomB, Picture, SkinRect, Width, Height,
      LeftStretch, TopStretch, RightStretch, BottomStretch);

  C.Draw(0, 0, TopB);
  C.Draw(0, TopB.Height, LeftB);
  C.Draw(Width - RightB.Width, TopB.Height, RightB);
  C.Draw(0, Height - BottomB.Height, BottomB);

  TopB.Free;
  LeftB.Free;
  RightB.Free;
  BottomB.Free;
end;


procedure TbsSkinMemo.AdjustTextBorders;
var
  R: TRect;
  R1: TRect;
begin
  if Self.BorderStyle = bsNone then Exit;
  GetSkindata;
  R := ClientRect;
  if FIndex = -1
  then
    begin
      if FBitMapBG
      then
        Inc(R.Left, 3)
      else
        Inc(R.Left, 6);
      Inc(R.Top, 2);
      Dec(R.Right, 4);
      Dec(R.Bottom, 2);
    end
  else
    begin
      if FBitMapBG
      then
        begin
          Inc(R.Left, ClRect.Left + 1);
          Inc(R.Top, ClRect.Top + 1);
        end
      else
        begin
          Inc(R.Left, ClRect.Left + 3);
          Inc(R.Top, ClRect.Top + 2);
        end;
      Dec(R.Right, RectWidth(SkinRect) - ClRect.Right + 3);
      Dec(R.Bottom, RectHeight(SkinRect) - ClRect.Bottom  + 2);
      if R.Right < R.LEft
      then R.Right := R.Left;
      if R.Bottom < R.Top
      then R.Bottom := R.Top;
    end;
  FTextArea := R;
  Self.Perform(EM_SETRECTNP, 0, Longint(@R));
end;

procedure TbsSkinMemo.WMCONTEXTMENU;
var
  X, Y: Integer;
  P: TPoint;
begin
  if PopupMenu <> nil
  then
    inherited
  else
    begin
      CreateSysPopupMenu;
      X := Message.XPos;
      Y := Message.YPos;
      if (X < 0) or (Y < 0)
      then
        begin
          X := Width div 2;
          Y := Height div 2;
          P := Point(0, 0);
          P := ClientToScreen(P);
          X := X + P.X;
          Y := Y + P.Y;
        end;
      if FSysPopupMenu <> nil
      then
        FSysPopupMenu.Popup2(Self, X, Y)
    end;
end;

procedure TbsSkinMemo.DrawMemoBackGround(C: TCanvas);

procedure PaintWallPaper(C: TCanvas);
var
  X, Y, XCnt, YCnt: Integer;
begin
  if FWallPaperStretch and (FWallpaper.Width <> 0) and(FWallpaper.Height <> 0)
  then
    begin
      C.StretchDraw(Rect(0, 0, Width, Height), FWallPaper)
    end
  else
  if (FWallpaper.Width <> 0) and(FWallpaper.Height <> 0) then
  begin
    XCnt := Width div FWallpaper.Width;
    YCnt := Height div FWallpaper.Height;
    for X := 0 to XCnt do
    for Y := 0 to YCnt do
      C.Draw(X * FWallpaper.Width, Y * FWallpaper.Height,
                            FWallpaper);
  end;
end;

var
  B, B2: TBitMap;
  NewClRect: TRect;
begin
  if ClientWidth <= 0 then Exit;
  if ClientHeight <= 0 then Exit;

  GetSkinData;

  if FTransparent and not FWallPaper.Empty
  then
    begin
      PaintWallPaper(C);
      if FIndex <> -1
      then
        NewClRect := Rect(0, 0,  ClientWidth, ClientHeight);
      AdjustTextBorders;
      Exit;
    end
  else
  if FTransparent
  then
    begin
      B := TBitMap.Create;
      B.Width := Width;
      B.Height := Height;
      GetParentImage(Self, B.Canvas);
      C.Draw(0, 0, B);
      B.Free;
      if FIndex <> -1
      then
        NewClRect := Rect(0, 0,  ClientWidth, ClientHeight);
      AdjustTextBorders;
      Exit;
    end;

  if FIndex = -1
  then
    begin
      C.Brush.Color := clWindow;
      if Self.BorderStyle <> bsNone
      then
        C.FillRect(Rect(2, 2, Width - 2, Height - 2))
      else
        C.FillRect(Rect(0, 0, Width, Height));
      if Self.BorderStyle <> bsNone then SkinFramePaint(C);
    end
  else
    begin
      NewClRect := Rect(0, 0,  ClientWidth, ClientHeight);
      if FBitMapBG
      then
        begin
          B := TBitMap.Create;
          B.Width := ClientWidth;
          B.Height := ClientHeight;
          if FMouseIn or Focused
          then
            CreateSkinBG(ClRect, NewClRect, B, Picture, ActiveSkinRect, B.Width, B.Height, StretchEffect, StretchType)
          else
            CreateSkinBG(ClRect, NewClRect, B, Picture, SkinRect, B.Width, B.Height, StretchEffect, StretchType);
          if Self.BorderStyle <> bsNone then SkinFramePaint(B.Canvas);
          C.Draw(0, 0, B);
          B.Free;
        end
      else
        begin
          Inc(NewClRect.Left, ClRect.Left);
          Inc(NewClRect.Top, ClRect.Top);
          Dec(NewClRect.Right, RectWidth(SkinRect) - ClRect.Right);
          Dec(NewClRect.Bottom, RectHeight(SkinRect) - ClRect.Bottom);
          if NewClRect.Right < NewClRect.LEft then NewClRect.Right := NewClRect.Left;
          if NewClRect.Bottom < NewClRect.Top then NewClRect.Bottom := NewClRect.Top;
          C.Brush.Color := Self.Color;
          C.FillRect(NewClRect);
          if Self.BorderStyle <> bsNone then SkinFramePaint(C);
        end;
    end;
  AdjustTextBorders;
end;

procedure TbsSkinMemo.WMAFTERDISPATCH;
begin
  if FSysPopupMenu <> nil
  then
    begin
      FSysPopupMenu.Free;
      FSysPopupMenu := nil;
    end;
end;

procedure TbsSkinMemo.DoUndo;
begin
  Undo;
end;

procedure TbsSkinMemo.DoCut;
begin
  CutToClipboard;
end;

procedure TbsSkinMemo.DoCopy;
begin
  CopyToClipboard;
end;

procedure TbsSkinMemo.DoPaste;
begin
  PasteFromClipboard;
end;

procedure TbsSkinMemo.DoDelete;
begin
  ClearSelection;
end;

procedure TbsSkinMemo.DoSelectAll;
begin
  SelectAll;
end;

procedure TbsSkinMemo.CreateSysPopupMenu;

function IsSelected: Boolean;
begin
  Result := GetSelLength > 0;
end;

function IsFullSelected: Boolean;
begin
  Result := GetSelText = Text;
end;

var
  Item: TMenuItem;
begin
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;

  FSysPopupMenu := TbsSkinPopupMenu.Create(Self);

  if (TForm(GetParentForm(Self)) <> nil) and (TForm(GetParentForm(Self)).FormStyle = fsMDIChild)
  then
    FSysPopupMenu.ComponentForm := Application.MainForm
  else
    FSysPopupMenu.ComponentForm := TForm(GetParentForm(Self));

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_UNDO')
    else
      Caption := BS_Edit_Undo;
    OnClick := DoUndo;
    Enabled := Self.CanUndo;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
     if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_CUT')
    else
      Caption := BS_Edit_Cut;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoCut;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_COPY')
    else
      Caption := BS_Edit_Copy;
    Enabled := IsSelected;
    OnClick := DoCopy;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_PASTE')
    else
      Caption := BS_Edit_Paste;
    Enabled := (ClipBoard.AsText <> '') and not ReadOnly;
    OnClick := DoPaste;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_DELETE')
    else
      Caption := BS_Edit_Delete;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoDelete;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
     if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_SELECTALL')
    else
      Caption := BS_Edit_SelectAll;
    Enabled := not IsFullSelected;
    OnClick := DoSelectAll;
  end;
  FSysPopupMenu.Items.Add(Item);
end;


procedure TbsSkinMemo.SetDefaultFont;
begin
  FDefaultFont.Assign(Value);
  if FIndex = -1 then Font.Assign(Value);
end;

procedure TbsSkinMemo.CMEnabledChanged;
begin
  SendMessage(Handle, WM_HSCROLL, MakeWParam(SB_THUMBPOSITION, 0), 0);
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.OnDefaultFontChange(Sender: TObject);
begin
  if FIndex = -1 then Font.Assign(FDefaultFont);
end;                      

procedure TbsSkinMemo.SetBitMapBG;
begin
  FBitMapBG := Value;
  ReCreateWnd;
end;

procedure TbsSkinMemo.WMSize;
begin
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.Change;
begin
  FIsCanScroll := True;
  inherited;
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
  if FBitmapBG then DoPaint;
  UpDateScrollRange;
  FIsCanScroll := False;
end;

procedure TbsSkinMemo.WMVSCROLL;
begin
  if FBitmapBG then
    SendMessage(Handle, WM_SETREDRAW, 0, 0);
  inherited;
  if FBitmapBG then
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  if FBitmapBG then DoPaint;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMHSCROLL;
begin
  if FBitmapBG then
    SendMessage(Handle, WM_SETREDRAW, 0, 0);
  inherited;
  if FBitmapBG then
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  if FBitmapBG then DoPaint;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMLBUTTONDOWN;
begin
  FIsCanScroll := True;
  inherited;
  FIsDown := True;
  FIsCanScroll := False;
end;

procedure TbsSkinMemo.WMLBUTTONUP;
begin
  inherited;
  FIsDown := False;
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
  if FBitMapBG then DoPaint;
end;

procedure TbsSkinMemo.WMMOUSEMOVE;
begin
  if FIsDown then FIsCanScroll := True;
  inherited;
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
    DoPaint;
  end;
  if FIsCanScroll then FIsCanScroll := False;
end;

procedure TbsSkinMemo.SetVScrollBar;
begin
  FVScrollBar := Value;
  if Value <> nil
  then
    begin
      FVScrollBar.Min := 0;
      FVScrollBar.Max := 0;
      FVScrollBar.Position := 0;
      FVScrollBar.OnChange := OnVScrollBarChange;
    end;
end;

procedure TbsSkinMemo.SetHScrollBar;
begin
  FHScrollBar := Value;
  if Value <> nil
  then
    begin
      FHScrollBar.Min := 0;
      FHScrollBar.Max := 0;
      FHScrollBar.Position := 0;
      FHScrollBar.OnChange := OnHScrollBarChange;
    end;
end;

procedure TbsSkinMemo.OnVScrollBarChange(Sender: TObject);
begin
  SendMessage(Handle, WM_VSCROLL,
    MakeWParam(SB_THUMBPOSITION, FVScrollBar.Position), 0);
end;

procedure TbsSkinMemo.OnHScrollBarChange(Sender: TObject);
begin
  SendMessage(Handle, WM_HSCROLL,
    MakeWParam(SB_THUMBPOSITION, FHScrollBar.Position), 0);
end;

procedure TbsSkinMemo.UpDateScrollRange;
var
  SF: ScrollInfo;
  sMin, SMax, SPos, sPage: Integer;
begin
  if FVScrollBar <> nil
  then
  if not Enabled
  then
    FVScrollBar.Enabled := False
  else
  with FVScrollBar do
  begin
    SF.fMask := SIF_ALL;
    SF.cbSize := SizeOf(SF);
    GetScrollInfo(Self.Handle, SB_VERT, SF);
    SMin := SF.nMin;
    SMax := SF.nMax;
    SPos := SF.nPos;
    SPage := SF.nPage;
    if SMax + 1 > SPage
    then
      begin
        SetRange(0, SMax, SPos, SPage);
        if not Enabled then Enabled := True;
      end
    else
      begin
        SetRange(0, 0, 0, 0);
        if Enabled then Enabled := False;
      end;
  end;

   if FHScrollBar <> nil
   then
  if not Enabled
  then
    FHScrollBar.Enabled := False
  else
  with FHScrollBar do
  begin
    SF.fMask := SIF_ALL;
    SF.cbSize := SizeOf(SF);
    GetScrollInfo(Self.Handle, SB_HORZ, SF);
    SMin := SF.nMin;
    SMax := SF.nMax;
    SPos := SF.nPos;
    SPage := SF.nPage;
    if SMax > SPage
    then
      begin
        SetRange(0, SMax, SPos, SPage);
        if not Enabled then Enabled := True;
      end
    else
      begin
        SetRange(0, 0, 0, 0);
        if Enabled then Enabled := False;
      end;
  end;

end;

procedure TbsSkinMEmo.WMMove;
begin
  inherited;
end;

procedure TbsSkinMemo.WMCut(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMPaste(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMClear(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMUndo(var Message: TMessage);
begin
  if FReadOnly then Exit;
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMSetText(var Message:TWMSetText);
begin
  FIsCanScroll := True;
  inherited;
  UpDateScrollRange;
  FIsCanScroll := False;
end;

procedure TbsSkinMemo.WMMOUSEWHEEL;
var
  LParam, WParam: Integer;
begin
  LParam := 0;
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    WParam := MakeWParam(SB_LINEUP, 0)
  else
    WParam := MakeWParam(SB_LINEDOWN, 0);
  SendMessage(Handle, WM_VSCROLL, WParam, LParam);
end;

procedure TbsSkinMemo.WMCHAR(var Message:TMessage);
begin
  FIsCanScroll := True;
  if not FReadOnly or (FReadOnly and (TWMCHar(Message).CharCode = 3))
  then
    begin
      inherited;
      if FBitMapBG then DoPaint;
    end;
  UpDateScrollRange;
  FIsCanScroll := False;
end;

procedure TbsSkinMemo.WMCOMMAND;
begin
  inherited;
  if (Message.NotifyCode = EN_HSCROLL) or
     (Message.NotifyCode = EN_VSCROLL)
  then
    begin
      UpDateScrollRange;
      if FBitmapBG and FIsCanScroll then
      begin
        DoPaint;
        FIsScroll := True;
        SendMessage(Handle, WM_SETREDRAW, 0, 0);
      end;
    end;
end;

procedure TbsSkinMemo.WMKeyDown(var Message: TWMKeyDown);
begin
  if FReadOnly and (Message.CharCode = VK_DELETE) then Exit;
  FIsCanScroll := True;
  inherited;
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
  DoPaint;
  UpDateScrollRange;
  FIsCanScroll := False;
end;

procedure TbsSkinMemo.WMKeyUp(var Message: TWMKeyDown);
begin
  inherited;
  if FBitmapBG and FIsScroll then
  begin
    FIsScroll := False;
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
  DoPaint;
  UpDateScrollRange;
end;

procedure TbsSkinMemo.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var
  DC: HDC;
  C: TCanvas;
begin
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  //
  if FBitMapBG or (BorderStyle = bsSingle)
  then
    begin
      DC := Message.DC;
      C := TControlCanvas.Create;
      C.Handle := DC;
      try
        if not FStopDraw then DoPaint else DrawMemoBackGround(C);
      finally
       C.Handle := 0;
       C.Free;
     end;
    end
  else
    inherited;
end;

procedure TbsSkinMemo.CNCtlColorStatic;
begin
  //
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  //
  if FBitMapBG
  then
    with Message do
    begin
      SetBkMode(ChildDC, Windows.Transparent);
      SetTextColor(ChildDC, ColorToRGB(Font.Color));
      Result := GetStockObject(NULL_BRUSH);
    end
  else
    inherited;
end;

procedure TbsSkinMemo.CNCTLCOLOREDIT(var Message:TWMCTLCOLOREDIT);
begin
  //
  if (csDesigning in ComponentState)
  then
    begin
      inherited;
      Exit;
    end;
  //
  if FBitMapBG
  then
    with Message do
    begin
      SetBkMode(ChildDC, Windows.Transparent);
      SetTextColor(ChildDC, ColorToRGB(Font.Color));
      Result := GetStockObject(NULL_BRUSH);
    end
  else
    inherited;
end;

procedure TbsSkinMemo.WMNCCALCSIZE;
begin
end;

procedure TbsSkinMemo.WMNCHITTEST(var Message: TWMNCHITTEST);
begin
  Message.Result := HTCLIENT;
end;

procedure TbsSkinMemo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    ExStyle := Exstyle and not WS_EX_Transparent;
    Style := Style and not WS_BORDER or ES_MULTILINE;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TbsSkinMemo.WMNCPAINT(var Message: TMessage);
begin
  DoPaint;
end;


destructor TbsSkinMemo.Destroy;
begin
  FDefaultFont.Free;
  FWallpaper.Free;
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;
  inherited;
end;

procedure TbsSkinMemo.WMSETFOCUS;
begin
  inherited;
  if not FMouseIn and (FIndex <> -1)
  then
    begin
      if FUseSKinFontColor
      then
        Font.Color := ActiveFontColor;
      if not FBitMapBG then Color := ActiveBGColor;
    end;
  if not FMouseIn then DoPaint;
end;

procedure TbsSkinMemo.WMKILLFOCUS;
begin
  inherited;
  if not FMouseIn and (FIndex <> -1)
  then
    begin
      if FUseSKinFontColor
      then
        Font.Color := FontColor;
      if not FBitMapBG then Color := BGColor;
    end;
  if not FMouseIn then DoPaint;
end;

procedure TbsSkinMemo.CMMouseEnter;
begin
  inherited;
  FMouseIn := True;
  if not Focused and (FIndex <> -1)
  then
    begin
      if FUseSKinFontColor
      then
        Font.Color := ActiveFontColor;
      if not FBitMapBG then Color := ActiveBGColor;
    end;
  if not Focused then DoPaint;
end;

procedure TbsSkinMemo.CMMouseLeave;
begin
  inherited;
  FMouseIn := False;
  if not Focused and (FIndex <> -1)
  then
    begin
      if FUseSKinFontColor
      then
        Font.Color := FontColor;
      if not FBitMapBG then Color := BGColor;
    end;
  if not Focused then DoPaint;
end;

procedure TbsSkinMemo.GetSkinData;
begin
  if FSD = nil
  then
    begin
      FIndex := -1;
      Exit;
    end;

  if FSD.Empty
  then
    FIndex := -1
  else
    FIndex := FSD.GetControlIndex(FSkinDataName);

  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinMemoControl
    then
      with TbsDataSkinMemoControl(FSD.CtrlList.Items[FIndex]) do
      begin
        if (PictureIndex <> -1) and (PictureIndex < FSD.FActivePictures.Count)
        then
          Picture := TBitMap(FSD.FActivePictures.Items[PictureIndex])
        else
          Picture := nil;
        Self.SkinRect := SkinRect;
        Self.ActiveSkinRect := ActiveSkinRect;
        if isNullRect(ActiveSkinRect)
        then
          Self.ActiveSkinRect := SkinRect;
        Self.LTPoint := LTPoint;
        Self.RTPoint := RTPoint;
        Self.LBPoint := LBPoint;
        Self.RBPoint := RBPoint;
        Self.ClRect := ClRect;
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.BGColor := BGColor;
        Self.ActiveBGColor := ActiveBGColor;
        Self.LeftStretch := LeftStretch;
        Self.TopStretch := TopStretch;
        Self.RightStretch := RightStretch;
        Self.BottomStretch := BottomStretch;
        Self.StretchEffect := StretchEffect;
        Self.StretchType := StretchType;
      end;
end;

procedure TbsSkinMemo.SetSkinData;
begin
  FSD := Value;
  if (FSD <> nil) then
  if not FSD.Empty and not (csDesigning in ComponentState)
  then
    ChangeSkinData;
end;

procedure TbsSkinMemo.Notification;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSD) then FSD := nil;
  if (Operation = opRemove) and (AComponent = FVScrollBar)
  then FVScrollBar := nil;
  if (Operation = opRemove) and (AComponent = FHScrollBar)
  then FHScrollBar := nil;
end;

procedure TbsSkinMemo.ChangeSkinData;
begin
  GetSkinData;
  if FIndex <> -1
  then
    begin
      if FUseSkinFont
      then
        begin
          Font.Name := FontName;
          Font.Style := FontStyle;
          Font.Height := FontHeight;
          if FUSeSkinFontColor
          then 
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end
      else
        begin
          Font.Assign(FDefaultFont);
          if FUSeSkinFontColor
          then
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end;
      Color := BGColor;
    end
  else
    Font.Assign(FDefaultFont);
  //
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinData.ResourceStrData.CharSet
  else
    Font.CharSet := FDefaultFont.CharSet;
  //
  UpDateScrollRange;
  if FVScrollBar <> nil then FVScrollBar.Align := FVScrollBar.Align;
  if FHScrollBar <> nil then FHScrollBar.Align := FHScrollBar.Align;
  if Enabled
  then
    begin
      if FIndex = -1
      then Font.Color := FDefaultFont.Color
      else
      if FUSeSkinFontColor
      then
       if Focused
       then
         Font.Color := ActiveFontColor
       else
         Font.Color := FontColor;
    end
  else
    begin
      if FIndex = -1
      then Font.Color := clGrayText
      else Font.Color := clGrayText;
    end;
  AdjustTextBorders;
end;


constructor TbsSkinMemo2.Create;
begin
  inherited Create(AOwner);
  AutoSize := False;
  FIndex := -1;
  Font.Name := 'Tahoma';
  Font.Height := 13;
  Font.Color := clBlack;
  FVScrollBar := nil;
  FHScrollBar := nil;
  FSkinDataName := 'memo';
  FDefaultFont := TFont.Create;
  FDefaultFont.Assign(Font);
  FDefaultFont.OnChange := OnDefaultFontChange;
  ScrollBars := ssBoth;
  FUseSkinFont := True;
  FUseSkinFontColor := True;
  FSysPopupMenu := nil;
end;

procedure TbsSkinMemo2.WMCOMMAND;
begin
  inherited;
  if (Message.NotifyCode = EN_HSCROLL) or
     (Message.NotifyCode = EN_VSCROLL)
  then
    begin
      UpDateScrollRange;
    end;
end;

procedure TbsSkinMemo2.WMAFTERDISPATCH;
begin
  if FSysPopupMenu <> nil
  then
    begin
      FSysPopupMenu.Free;
      FSysPopupMenu := nil;
    end;
end;

function TbsSkinMemo2.GetDisabledFontColor: TColor;
var
  i: Integer;
begin
  i := -1;
  if FIndex <> -1 then i := SkinData.GetControlIndex('edit');
  if i = -1
  then
    Result := clGrayText
  else
    Result := TbsDataSkinEditControl(SkinData.CtrlList[i]).DisabledFontColor;
end;


procedure TbsSkinMemo2.CMSENCPaint(var Message: TMessage); 
begin
  Message.Result := SE_RESULT;
end;

procedure TbsSkinMemo2.WMPaint(var Message: TWMPaint);
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  R: TRect;
  S: string;
  FCanvas: TControlCanvas;
  DC: HDC;
  PS: TPaintStruct;
  TX, TY: Integer;
  LinesCount: Integer;
  VisibleLines: Integer;
  i, P: Integer;
  LineHeight: Integer;

function GetVisibleLines: Integer;
var
  R: TRect;
  C: TCanvas;
  DC: HDC;
begin
  C := TCanvas.Create;
  C.Font.Assign(Font);
  DC := GetDC(0);
  C.Handle := DC;
  R := GetClientRect;
  LineHeight := C.TextHeight('Wq');
  if LineHeight <> 0
  then
    Result := RectHeight(R) div LineHeight
  else
    Result := 1;
  ReleaseDC(0, DC);
  C.Free;
end;

begin
  if Enabled
  then
    inherited
  else
    begin
      FCanvas := TControlCanvas.Create;
      FCanvas.Control := Self;
      DC := Message.DC;
      if DC = 0 then DC := BeginPaint(Handle, PS);
      FCanvas.Handle := DC;
      //
      with FCanvas do
      begin
        if (FIndex = -1) or not FUseSkinFont
        then
          begin
            Font := DefaultFont;
            if FIndex = -1
            then Font.Color := clGrayText
            else Font.Color := GetDisabledFontColor;
          end
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            Font.Color := GetDisabledFontColor;
            Font.Style := FontStyle;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;
      end;
      FCanvas.Brush.Style := bsClear;
      // draw text
      VisibleLines := GetVisibleLines;
      LinesCount := SendMessage(Self.Handle, EM_GETLINECOUNT, 0, 0);
      P := SendMessage(Self.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
      Self.Perform(EM_GETRECT, 0, Longint(@R));
      for i := P  to P + VisibleLines - 2 do
       if i < Lines.Count
       then
         begin
           S := Lines[i];
           DrawText(FCanvas.Handle, PChar(S), Length(S), R, Alignments[Alignment]);
           Inc(R.Top, LineHeight);
         end;
      //
      FCanvas.Handle := 0;
      FCanvas.Free;
      if Message.DC = 0 then EndPaint(Handle, PS);
    end;
end;

procedure TbsSkinMemo2.WMCONTEXTMENU;
var
  X, Y: Integer;
  P: TPoint;
begin
  if PopupMenu <> nil
  then
    inherited
  else
    begin
      CreateSysPopupMenu;
      X := Message.XPos;
      Y := Message.YPos;
      if (X < 0) or (Y < 0)
      then
        begin
          X := Width div 2;
          Y := Height div 2;
          P := Point(0, 0);
          P := ClientToScreen(P);
          X := X + P.X;
          Y := Y + P.Y;
        end;
      if FSysPopupMenu <> nil
      then
        FSysPopupMenu.Popup2(Self, X, Y)
    end;
end;

procedure TbsSkinMemo2.DoUndo;
begin
  Undo;
end;

procedure TbsSkinMemo2.DoCut;
begin
  CutToClipboard;
end;

procedure TbsSkinMemo2.DoCopy;
begin
  CopyToClipboard;
end;

procedure TbsSkinMemo2.DoPaste;
begin
  PasteFromClipboard;
end;

procedure TbsSkinMemo2.DoDelete;
begin
  ClearSelection;
end;

procedure TbsSkinMemo2.DoSelectAll;
begin
  SelectAll;
end;

procedure TbsSkinMemo2.CreateSysPopupMenu;

function IsSelected: Boolean;
begin
  Result := GetSelLength > 0;
end;

function IsFullSelected: Boolean;
begin
  Result := GetSelText = Text;
end;

var
  Item: TMenuItem;
begin
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;

  FSysPopupMenu := TbsSkinPopupMenu.Create(Self);

  if (TForm(GetParentForm(Self)) <> nil) and (TForm(GetParentForm(Self)).FormStyle = fsMDIChild)
  then
    FSysPopupMenu.ComponentForm := Application.MainForm
  else
    FSysPopupMenu.ComponentForm := TForm(GetParentForm(Self));

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_UNDO')
    else
      Caption := BS_Edit_Undo;
    OnClick := DoUndo;
    Enabled := Self.CanUndo;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_CUT')
    else
      Caption := BS_Edit_Cut;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoCut;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_COPY')
    else
      Caption := BS_Edit_Copy;
    Enabled := IsSelected;
    OnClick := DoCopy;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_PASTE')
    else
      Caption := BS_Edit_Paste;
    Enabled := (ClipBoard.AsText <> '') and not ReadOnly;
    OnClick := DoPaste;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_DELETE')
    else
      Caption := BS_Edit_Delete;
    Enabled := IsSelected and not Self.ReadOnly;
    OnClick := DoDelete;
  end;
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  Item.Caption := '-';
  FSysPopupMenu.Items.Add(Item);

  Item := TMenuItem.Create(FSysPopupMenu);
  with Item do
  begin
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Caption := SkinData.ResourceStrData.GetResStr('EDIT_SELECTALL')
    else
      Caption := BS_Edit_SelectAll;
    Enabled := not IsFullSelected;
    OnClick := DoSelectAll;
  end;
  FSysPopupMenu.Items.Add(Item);
end;


procedure TbsSkinMemo2.CMEnabledChanged;
begin
  SendMessage(Handle, WM_HSCROLL, MakeWParam(SB_THUMBPOSITION, 0), 0);
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.SetDefaultFont;
begin
  FDefaultFont.Assign(Value);
  if FIndex = -1 then Font.Assign(Value);
end;

procedure TbsSkinMemo2.OnDefaultFontChange(Sender: TObject);
begin
  if FIndex = -1 then Font.Assign(FDefaultFont);
end;

procedure TbsSkinMemo2.WMSize;
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.Invalidate;
begin
  inherited;
end;

procedure TbsSkinMemo2.Change;
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMVSCROLL;
begin
  inherited;
  UpDateScrollRange;

end;

procedure TbsSkinMemo2.WMHSCROLL;
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMLBUTTONDOWN;
begin
  inherited;
end;

procedure TbsSkinMemo2.WMLBUTTONUP;
begin
  inherited;
end;

procedure TbsSkinMemo2.WMMOUSEMOVE;
begin
  inherited;
end;

procedure TbsSkinMemo2.SetVScrollBar;
begin
  FVScrollBar := Value;
  if FVScrollBar <> nil
  then
    begin
      FVScrollBar.Min := 0;
      FVScrollBar.Max := 0;
      FVScrollBar.Position := 0;
      FVScrollBar.OnChange := OnVScrollBarChange;
    end;
  UpDateScrollRange;    
end;

procedure TbsSkinMemo2.OnVScrollBarChange(Sender: TObject);
begin
  SendMessage(Handle, WM_VSCROLL,
    MakeWParam(SB_THUMBPOSITION, FVScrollBar.Position), 0);
  Invalidate;
end;

procedure TbsSkinMemo2.SetHScrollBar;
begin
  FHScrollBar := Value;
  if FHScrollBar <> nil
  then
    begin
      FHScrollBar.Min := 0;
      FHScrollBar.Max := 0;
      FHScrollBar.Position := 0;
      FHScrollBar.OnChange := OnHScrollBarChange;
    end;  
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.OnHScrollBarChange(Sender: TObject);
begin
  SendMessage(Handle, WM_HSCROLL,
    MakeWParam(SB_THUMBPOSITION, FHScrollBar.Position), 0);
  Invalidate;
end;

procedure TbsSkinMemo2.UpDateScrollRange;
var
  SMin, SMax, SPos, SPage: Integer;
  SF: TScrollInfo;
begin
  if FVScrollBar <> nil
  then
  if not Enabled
  then
    FVScrollBar.Enabled := False
  else
  with FVScrollBar do
  begin
    SF.fMask := SIF_ALL;
    SF.cbSize := SizeOf(SF);
    GetScrollInfo(Self.Handle, SB_VERT, SF);
    SMin := SF.nMin;
    SMax := SF.nMax;
    SPos := SF.nPos;
    SPage := SF.nPage;
    if SMax + 1 > SPage
    then
      begin
        SetRange(0, SMax, SPos, SPage);
        if not Enabled then Enabled := True;
      end
    else
      begin
        SetRange(0, 0, 0, 0);
        if Enabled then Enabled := False;
      end;
  end;

  if FHScrollBar <> nil
   then
  if not Enabled
  then
    FHScrollBar.Enabled := False
  else
  with FHScrollBar do
  begin
    SF.fMask := SIF_ALL;
    SF.cbSize := SizeOf(SF);
    GetScrollInfo(Self.Handle, SB_HORZ, SF);
    SMin := SF.nMin;
    SMax := SF.nMax;
    SPos := SF.nPos;
    SPage := SF.nPage;
    if SMax > SPage
    then
      begin
        SetRange(0, SMax, SPos, SPage);
        if not Enabled then Enabled := True;
      end
    else
      begin
        SetRange(0, 0, 0, 0);
        if Enabled then Enabled := False;
      end;
  end;
end;


procedure TbsSkinMemo2.WMMove;
begin
  inherited;
end;

procedure TbsSkinMemo2.WMCut(var Message: TMessage);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMPaste(var Message: TMessage);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMClear(var Message: TMessage);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMUndo(var Message: TMessage);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMSetText(var Message:TWMSetText);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMMOUSEWHEEL;
var
  LParam, WParam: Integer;
begin
  LParam := 0;
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    WParam := MakeWParam(SB_LINEUP, 0)
  else
    WParam := MakeWParam(SB_LINEDOWN, 0);
  SendMessage(Handle, WM_VSCROLL, WParam, LParam);
end;

procedure TbsSkinMemo2.WMCHAR(var Message:TMessage);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  UpDateScrollRange;
end;

procedure TbsSkinMemo2.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  inherited;
end;

procedure TbsSkinMemo2.CNCTLCOLOREDIT(var Message:TWMCTLCOLOREDIT);
begin
  inherited;
end;

procedure TbsSkinMemo2.WMNCCALCSIZE;
begin
 
end;

procedure TbsSkinMemo2.WMNCHITTEST(var Message: TWMNCHITTEST);
begin
  Message.Result := HTCLIENT;
end;

procedure TbsSkinMemo2.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    Style := Style and not WS_BORDER;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

destructor TbsSkinMemo2.Destroy;
begin
  FDefaultFont.Free;
  if FSysPopupMenu <> nil then FSysPopupMenu.Free;
  inherited;
end;

procedure TbsSkinMemo2.WMSETFOCUS;
begin
  inherited;
  if not FMouseIn and (FIndex <> -1)
  then
    begin
      if FUSeSkinFontColor
      then
        Font.Color := ActiveFontColor;
      Color := ActiveBGColor;
    end;
end;

procedure TbsSkinMemo2.WMKILLFOCUS;
begin
  inherited;
  if not FMouseIn and (FIndex <> -1)
  then
    begin
      if FUSeSkinFontColor
      then
        Font.Color := FontColor;
      Color := BGColor;
    end;
end;

procedure TbsSkinMemo2.CMMouseEnter;
begin
  inherited;
  FMouseIn := True;
  if not Focused and (FIndex <> -1)
  then
    begin
      if FUSeSkinFontColor
      then
        Font.Color := ActiveFontColor;
      Color := ActiveBGColor;
    end;
end;

procedure TbsSkinMemo2.CMMouseLeave;
begin
  inherited;
  FMouseIn := False;
  if not Focused and (FIndex <> -1)
  then
    begin
      if FUSeSkinFontColor
      then
        Font.Color := FontColor;
      Color := BGColor;
    end;
end;

procedure TbsSkinMemo2.GetSkinData;
begin
  if FSD = nil
  then
    begin
      FIndex := -1;
      Exit;
    end;

  if FSD.Empty
  then
    FIndex := -1
  else
    FIndex := FSD.GetControlIndex(FSkinDataName);

  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinMemoControl
    then
      with TbsDataSkinMemoControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.BGColor := BGColor;
        Self.ActiveBGColor := ActiveBGColor;
      end;
end;

procedure TbsSkinMemo2.SetSkinData;
begin
  FSD := Value;
  if (FSD <> nil) then
  if not FSD.Empty and not (csDesigning in ComponentState)
  then
    ChangeSkinData;
end;

procedure TbsSkinMemo2.Notification;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FSD) then FSD := nil;
  if (Operation = opRemove) and (AComponent = FVScrollBar)
  then FVScrollBar := nil;
  if (Operation = opRemove) and (AComponent = FHScrollBar)
  then FHScrollBar := nil;
end;

procedure TbsSkinMemo2.ChangeSkinData;
begin
  GetSkinData;
  //
  if FIndex <> -1
  then
    begin
      if FUseSkinFont
      then
        begin
          Font.Name := FontName;
          Font.Style := FontStyle;
          Font.Height := FontHeight;
          if FUSeSkinFontColor
          then
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end
      else
        begin
          Font.Assign(FDefaultFont);
          if FUSeSkinFontColor
          then
          if Focused
          then
            Font.Color := ActiveFontColor
          else
            Font.Color := FontColor;
        end;
      Color := BGColor;
    end
  else
    Font.Assign(FDefaultFont);
  //
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinData.ResourceStrData.CharSet
  else
    Font.CharSet := FDefaultFont.CharSet;
  //
  UpDateScrollRange;
  if FVScrollBar <> nil then FVScrollBar.Align := FVScrollBar.Align;
  if FHScrollBar <> nil then FHScrollBar.Align := FHScrollBar.Align;
end;

constructor TbsListBox.Create;
begin
  inherited;
  SkinListBox := nil;
  Ctl3D := False;
  BorderStyle := bsNone;
  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks];
  FHorizontalExtentValue := 0;
  {$IFDEF VER130}
  FAutoComplete := True;
  {$ENDIF}
end;

destructor TbsListBox.Destroy;
begin
  inherited;
end;

procedure TbsListBox.CMSENCPaint(var Message: TMessage);
begin
  Message.Result := SE_RESULT;
end;

procedure TbsListBox.SetBounds;
var
  OldWidth: Integer;
begin
  OldWidth := Width;
  inherited;
  if (OldWidth <> Width) and (FHorizontalExtentValue > 0)
  then
    begin
      FHorizontalExtentValue := FHorizontalExtentValue + (OldWidth - Width);
      if FHorizontalExtentValue < 0 then FHorizontalExtentValue := 0;
      RePaint;
    end;
end;

procedure TbsListBox.CreateWnd;
begin
  inherited;
  if SkinListBox <> nil then SkinListBox.ListBoxCreateWnd;
end;

procedure TbsListBox.WMNCCALCSIZE;
begin
end;

procedure TbsListBox.WMNCHITTEST(var Message: TWMNCHITTEST);
begin
  Message.Result := HTCLIENT;
end;

procedure TbsListBox.CMEnter;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxEnter;
  inherited;
end;

procedure TbsListBox.CMExit;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxExit;
  inherited;
end;

procedure TbsListBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxMouseDown(Button, Shift, X, Y);
  inherited;
end;

procedure TbsListBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxMouseUp(Button, Shift, X, Y);
  inherited;
end;

procedure TbsListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxMouseMove(Shift, X, Y);
  inherited;
end;

procedure TbsListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxKeyDown(Key, Shift);
  if (Key = VK_LEFT) and (SkinListBox.HScrollBar <> nil)
  then
    with SkinListBox.HScrollBar do
    begin
      Position := Position - SmallChange;
      Key := 0;
    end
  else
  if (Key = VK_RIGHT) and (SkinListBox.HScrollBar <> nil)
  then
    with SkinListBox.HScrollBar do
    begin
      Position := Position + SmallChange;
      Key := 0;
    end;
  inherited;
end;

procedure TbsListBox.KeyPress(var Key: Char);
  {$IFDEF VER130}
  procedure FindString;
  var
    Idx: Integer;
  begin
    if Length(FFilter) = 1
    then
      Idx := SendMessage(Handle, LB_FINDSTRING, ItemIndex, LongInt(PChar(FFilter)))
    else
      Idx := SendMessage(Handle, LB_FINDSTRING, -1, LongInt(PChar(FFilter)));
    if Idx <> LB_ERR then
    begin
      if MultiSelect then
      begin
        SendMessage(Handle, LB_SELITEMRANGE, 1, MakeLParam(Idx, Idx))
      end;
      ItemIndex := Idx;
      Click;
    end;
    if not Ord(Key) in [VK_RETURN, VK_BACK, VK_ESCAPE] then
      Key := #0;
  end;
  {$ENDIF}
begin
  if SkinListBox <> nil then SkinListBox.ListBoxKeyPress(Key);
  inherited;
  {$IFDEF VER130}
  if not FAutoComplete then Exit;
  if GetTickCount - FLastTime >= 500 then
    FFilter := '';
  FLastTime := GetTickCount;
  if Ord(Key) <> VK_BACK then
  begin
    FFilter := FFilter + Key;
    Key := #0;
  end
  else
    Delete(FFilter, Length(FFilter), 1);
  if Length(FFilter) > 0 then
    FindString
  else
  begin
    ItemIndex := 0;
    Click;
  end;
  {$ENDIF}
end;

procedure TbsListBox.Click;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxClick;
  inherited;
end;

procedure TbsListBox.PaintBGWH;
var
  X, Y, XCnt, YCnt, XO, YO, w, h, w1, h1: Integer;
  Buffer: TBitMap;
begin
  w1 := AW;
  h1 := AH;
  Buffer := TBitMap.Create;
  Buffer.Width := w1;
  Buffer.Height := h1;
  with Buffer.Canvas, SkinListBox do
  begin
    w := RectWidth(ClRect);
    h := RectHeight(ClRect);
    XCnt := w1 div w;
    YCnt := h1 div h;
    for X := 0 to XCnt do
    for Y := 0 to YCnt do
    begin
      if X * w + w > w1 then XO := X * w + w - w1 else XO := 0;
      if Y * h + h > h1 then YO := Y * h + h - h1 else YO := 0;
       CopyRect(Rect(X * w, Y * h, X * w + w - XO, Y * h + h - YO),
                Picture.Canvas,
                Rect(SkinRect.Left + ClRect.Left, SkinRect.Top + ClRect.Top,
                SkinRect.Left + ClRect.Right - XO,
                SkinRect.Top + ClRect.Bottom - YO));
    end;
  end;
  Cnvs.Draw(AX, AY, Buffer);
  Buffer.Free;
end;

function TbsListBox.GetState;
begin
  Result := [];
  if AItemID = ItemIndex
  then
    begin
      Result := Result + [odSelected];
      if Focused then Result := Result + [odFocused];
    end
  else
    if SelCount > 0
    then
      if Selected[AItemID] then Result := Result + [odSelected];
end;

procedure TbsListBox.PaintBG(DC: HDC);
var
  C: TControlCanvas;
begin
  C := TControlCanvas.Create;
  C.Handle := DC;
  SkinListBox.GetSkinData;
  if SkinListBox.FIndex <> -1
  then
    PaintBGWH(C, Width, Height, 0, 0)
  else
    with C do
    begin
      Brush.Color := clWindow;
      FillRect(Rect(0, 0, Width, Height));
    end;
  C.Handle := 0;
  C.Free;
end;

procedure TbsListBox.PaintColumnsList(DC: HDC);
var
  C: TCanvas;
  i, j, DrawCount: Integer;
  IR: TRect;
begin
  C := TCanvas.Create;
  C.Handle := DC;
  DrawCount := (Height div ItemHeight) * Columns;
  i := TopIndex;
  j := i + DrawCount;
  if j > Items.Count - 1 then j := Items.Count - 1;
  if Items.Count > 0
  then
    for i := TopIndex to j do
    begin
      IR := ItemRect(i);
      if SkinListBox.FIndex <> -1
      then
        begin
          if SkinListBox.UseSkinItemHeight
          then
            DrawSkinItem(C, i, IR, GetState(i))
          else
            DrawStretchSkinItem(C, i, IR, GetState(i));
         end
      else
        DrawDefaultItem(C, i, IR, GetState(i));
    end;
  C.Free;
end;

procedure TbsListBox.PaintList(DC: HDC);
var
  C: TCanvas;
  i, j, k, DrawCount: Integer;
  IR: TRect;
begin
  C := TCanvas.Create;
  C.Handle := DC;
  DrawCount := Height div ItemHeight;
  i := TopIndex;
  j := i + DrawCount;
  if j > Items.Count - 1 then j := Items.Count - 1;
  k := 0;
  if Items.Count > 0
  then
    for i := TopIndex to j do
    begin
      IR := ItemRect(i);
      if SkinListBox.FIndex <> -1
      then
        begin
          if SkinListBox.UseSkinItemHeight
          then
            DrawSkinItem(C, i, IR, GetState(i))
          else
            DrawStretchSkinItem(C, i, IR, GetState(i));
        end
      else
        DrawDefaultItem(C, i, IR, GetState(i));
      k := IR.Bottom;
    end;
  if k < Height
  then
    begin
      SkinListBox.GetSkinData;
      if SkinListBox.FIndex <> -1
      then
        PaintBGWH(C, Width, Height - k, 0, k)
      else
        with C do
        begin
          C.Brush.Color := clWindow;
          FillRect(Rect(0, k, Width, Height));
        end;
    end;  
  C.Free;
end;

procedure TbsListBox.PaintWindow;
var
  SaveIndex: Integer;
begin
  if (Width <= 0) or (Height <=0) then Exit;
  SaveIndex := SaveDC(DC);
  try
    if Columns > 0
    then
      PaintColumnsList(DC)
    else
      PaintList(DC);
  finally
    RestoreDC(DC, SaveIndex);
  end;
end;

procedure TbsListBox.WMPaint;
begin
  PaintHandler(Msg);
end;

procedure TbsListBox.WMEraseBkgnd;
begin
  if (Width > 0) and (Height > 0) then PaintBG(Message.DC);
  Message.Result := 1;
end;

procedure TbsListBox.DrawDefaultItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                                     State: TOwnerDrawState);
var
  Buffer: TBitMap;
  R, R1: TRect;
  IIndex, IX, IY, Off: Integer;
begin
  if (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(rcItem);
  Buffer.Height := RectHeight(rcItem);
  R := Rect(0, 0, Buffer.Width, Buffer.Height);
  with Buffer.Canvas do
  begin
    Font.Name := SkinListBox.Font.Name;
    Font.Style := SkinListBox.Font.Style;
    Font.Height := SkinListBox.Font.Height;
    if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := SkinListBox.DefaultFont.CharSet;
    if odSelected in State
    then
      begin
        Brush.Color := clHighLight;
        Font.Color := clHighLightText;
      end
    else
      begin
        Brush.Color := clWindow;
        Font.Color := SkinListBox.Font.Color;
      end;
    FillRect(R);
  end;

  R1 := Rect(R.Left + 2, R.Top, R.Right - 2, R.Bottom);

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID, Buffer.Width, Buffer.Height,
    R1, State)
  else
    begin
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R1.Left;
              IY := R1.Top + RectHeight(R1) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas, IX - FHorizontalExtentValue, IY, IIndex);
            end;
          Off := SkinListBox.Images.Width + 2
        end
      else
        Off := 0;
      Buffer.Canvas.Brush.Style := bsClear;
      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R1, Off);
        end
      else
        begin
          BSDrawText3(Buffer.Canvas, Items[ItemID], R1, -FHorizontalExtentValue + Off)
        end;
    end;
  if odFocused in State then DrawFocusRect(Buffer.Canvas.Handle, R);
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;

procedure TbsListBox.DrawStretchSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                                  State: TOwnerDrawState);
var
  Buffer: TBitMap;
  R: TRect;
  IX, IY, IIndex, Off: Integer;
  Offset, W, H: Integer;
begin
  if (SkinListBox.Picture = nil) or (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(rcItem);
  Buffer.Height := RectHeight(rcItem);
  W := RectWidth(rcItem);
  H := RectHeight(SkinListBox.SItemRect);
  R := SkinListBox.ItemTextRect;
  InflateRect(R, -1, -1);
  
  with SkinListBox do
  begin
    if odFocused in State
    then
      CreateStretchImage(Buffer, Picture, FocusItemRect, R, True)
    else
    if odSelected in State
    then
      CreateStretchImage(Buffer, Picture, ActiveItemRect, R, True)
    else
      CreateStretchImage(Buffer, Picture, SItemRect, R, True);

    R := ItemTextRect;
    Inc(R.Right, W - RectWidth(SItemRect));
    Inc(R.Bottom, RectHeight(rcItem) - RectHeight(SItemRect));
  end;


  with Buffer.Canvas do
  begin
    if SkinListBox.UseSkinFont
    then
      begin
        Font.Name := SkinListBox.FontName;
        Font.Style := SkinListBox.FontStyle;
        Font.Height := SkinListBox.FontHeight;
      end
    else
      Font.Assign(SkinListBox.DefaultFont);

    if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := SkinListBox.DefaultFont.CharSet;

    if odFocused in State
    then
      Font.Color := SkinListBox.FocusFontColor
    else
    if odSelected in State
    then
      Font.Color := SkinListBox.ActiveFontColor
    else
      Font.Color := SkinListBox.FontColor;
    Brush.Style := bsClear;
  end;

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID, W, H, R, State)
  else
    begin
      if (odFocused in State) and SkinListBox.ShowFocus
      then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := SkinListBox.SkinData.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R.Left;
              IY := R.Top + RectHeight(R) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas,
                IX - FHorizontalExtentValue, IY, IIndex);
            end;
          Off := SkinListBox.Images.Width + 2;
        end
      else
        Off := 0;
      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R, Off);
        end
      else
        begin
          BSDrawText3(Buffer.Canvas, Items[ItemID], R, -FHorizontalExtentValue + Off)
        end;
    end;
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;


procedure TbsListBox.DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);

function GetNum(AText: String): Integer;
const
  EditChars = '01234567890';
var
  i: Integer;
  S: String;
  IsNum: Boolean;
begin
  S := EditChars;
  Result := 0;
  if (AText = '') then Exit;
  IsNum := True;
  for i := 1 to Length(AText) do
  begin
    if Pos(AText[i], S) = 0
    then
      begin
        IsNum := False;
        Break;
      end;
  end;
  if IsNum then Result := StrToInt(AText) else Result := 0;
end;

var
  S1: String;
  i, Max: Integer;
  TWValue: array[0..9] of Integer;
  X, Y: Integer;
begin
  for i := 0 to TW.Count - 1 do
  begin
    if i < 10 then TWValue[i] := GetNum(TW[i]);
  end;
  Max := TW.Count;
  if Max > 10 then Max := 10;
  X := R.Left + Offset + 2;
  Y := R.Top + RectHeight(R) div 2 - C.TextHeight(S) div 2;
  //
  if (C.Font.Height div 2) <> (C.Font.Height / 2) then Dec(Y, 1);
  //
  TabbedTextOut(C.Handle, X, Y, PChar(S), Length(S), Max, TWValue, 0);
end;

procedure TbsListBox.DrawSkinItem(Cnvs: TCanvas; itemID: Integer; rcItem: TRect;
                                  State: TOwnerDrawState);
var
  Buffer: TBitMap;
  R: TRect;
  W, H: Integer;
  IX, IY, IIndex, Off: Integer;
begin
  if (SkinListBox.Picture = nil) or (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  Buffer := TBitMap.Create;
  with SkinListBox do
  begin
    W := RectWidth(rcItem);
    H := RectHeight(SItemRect);
    Buffer.Width := W;
    Buffer.Height := H;
    if odFocused in State
    then
      begin
        if not (odSelected in State)
        then
          begin
            CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
              SItemRect, W, H, StretchEffect);
            R := Rect(0, 0, Buffer.Width, Buffer.Height);
            DrawSkinFocusRect(Buffer.Canvas, R);
          end
        else
          CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
            FocusItemRect, W, H, StretchEffect)
      end
    else
    if odSelected in State
    then
      CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
      ActiveItemRect, W, H, StretchEffect)
    else
      CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
      SItemRect, W, H, False);

    R := ItemTextRect;
    Inc(R.Right, W - RectWidth(SItemRect));
  end;

  with Buffer.Canvas do
  begin
    if SkinListBox.UseSkinFont
    then
      begin
        Font.Name := SkinListBox.FontName;
        Font.Style := SkinListBox.FontStyle;
        Font.Height := SkinListBox.FontHeight;
      end
    else
      Font.Assign(SkinListBox.DefaultFont);

  if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
  else
    Font.CharSet := SkinListBox.DefaultFont.CharSet;

    if odFocused in State
    then
      begin
        if not (odSelected in State)
        then
          Font.Color := SkinListBox.FontColor
        else
          Font.Color := SkinListBox.FocusFontColor;
      end
    else
    if odSelected in State
    then
      Font.Color := SkinListBox.ActiveFontColor
    else
      Font.Color := SkinListBox.FontColor;
    Brush.Style := bsClear;
  end;

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID,
      Buffer.Width, Buffer.Height,  R, State)
  else
    begin
      if (odFocused in State) and SkinListBox.ShowFocus
      then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := SkinListBox.SkinData.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R.Left;
              IY := R.Top + RectHeight(R) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas,
                IX - FHorizontalExtentValue, IY, IIndex);
            end;
          Off := SkinListBox.Images.Width + 2;
        end
      else
        Off := 0;  
      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R, Off);
        end
      else
        begin
          BSDrawText3(Buffer.Canvas, Items[ItemID], R, -FHorizontalExtentValue + Off)
        end;
    end;
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;

procedure TbsListBox.CreateParams;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_BORDER;
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    WindowClass.style := CS_DBLCLKS;
    Style := Style or WS_TABSTOP;
  end;
end;

procedure TbsListBox.CNDrawItem;
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    {$IFDEF VER120}
      State := TOwnerDrawState(WordRec(LongRec(itemState).Lo).Lo);
    {$ELSE}
      {$IFDEF VER125}
        State := TOwnerDrawState(WordRec(LongRec(itemState).Lo).Lo);
      {$ELSE}
        State := TOwnerDrawState(LongRec(itemState).Lo);
      {$ENDIF}
    {$ENDIF}
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if SkinListBox.FIndex <> -1
    then
      begin
        if SkinListBox.UseSkinItemHeight
        then
          DrawSkinItem(Canvas, itemID, rcItem, State)
        else
          DrawStretchSkinItem(Canvas, itemID, rcItem, State);
      end
    else
      DrawDefaultItem(Canvas, itemID, rcItem, State);
    Canvas.Handle := 0;
  end;
end;

procedure TbsListBox.WndProc;
var
  LParam, WParam: Integer;
  Handled: Boolean;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxWProc(Message, Handled);

  if not Handled then Exit;

  inherited;

  case Message.Msg of
    CM_BEPAINT:
    if Items.Count = 0 then
      begin
        if (Message.LParam = BE_ID)
        then
          begin
            if (Message.wParam <> 0)
            then
              begin
                PaintBG(Message.wParam);
              end;
            Message.Result := BE_ID;
          end;
      end;
    WM_LBUTTONDBLCLK:
      begin
        if SkinListBox <> nil then SkinListBox.ListBoxDblClick;
      end;
    WM_MOUSEWHEEL:
      if (SkinListBox <> nil) and (SkinListBox.ScrollBar <> nil)
      then
        begin
          LParam := 0;
          if TWMMOUSEWHEEL(Message).WheelDelta > 0
          then
            WParam := MakeWParam(SB_LINEUP, 0)
          else
            WParam := MakeWParam(SB_LINEDOWN, 0);
          SendMessage(Handle, WM_VSCROLL, WParam, LParam);
          SkinListBox.UpDateScrollBar;
        end
      else
        if (SkinListBox <> nil) and (SkinListBox.HScrollBar <> nil)
        then
          begin
            with SkinListBox.HScrollBar do
            if Message.WParam > 0
            then
              Position := Position - SmallChange
            else
              Position := Position + SmallChange;
          end;
    WM_ERASEBKGND:
      SkinListBox.UpDateScrollBar;
    LB_ADDSTRING, LB_INSERTSTRING,
    LB_DELETESTRING:
      begin
        if SkinListBox <> nil
        then
          SkinListBox.UpDateScrollBar;
      end;
  end;
end;

constructor TbsSkinCustomListBox.Create;
begin
  inherited;
  ControlStyle := [csCaptureMouse, csClickEvents,
    csReplicatable, csOpaque, csDoubleClicks];
  ControlStyle := ControlStyle + [csAcceptsControls];
  Forcebackground := True;
  DrawBackground := False;
  FShowCaptionButtons := True;
  FUseSkinItemHeight := True;
  FRowCount := 0;
  FImageIndex := -1;
  FGlyph := TBitMap.Create;
  FNumGlyphs := 1;
  FSpacing := 2;
  FDefaultCaptionFont := TFont.Create;
  FDefaultCaptionFont.OnChange := OnDefaultCaptionFontChange;
  FDefaultCaptionFont.Name := 'Tahoma';
  FDefaultCaptionFont.Height := 13;
  FDefaultCaptionHeight := 20;
  ActiveButton := -1;
  OldActiveButton := -1;
  CaptureButton := -1;
  FCaptionMode := False;
  FDefaultItemHeight := 20;
  TimerMode := 0;
  WaitMode := False;
  Font.Name := 'Tahoma';
  Font.Height := 13;
  Font.Color := clWindowText;
  Font.Style := [];
  ScrollBar := nil;
  HScrollBar := nil;
  ListBox := TbsListBox.Create(Self);
  ListBox.SkinListBox := Self;
  ListBox.Style := lbOwnerDrawFixed;
  ListBox.ItemHeight := FDefaultItemHeight;
  ListBox.Parent := Self;
  ListBox.Visible := True;
  Height := 120;
  Width := 120;
  FSkinDataName := 'listbox';
  FHorizontalExtent := False;
  FStopUpDateHScrollBar := False;
  FTabWidths := TStringList.Create;
end;


{$IFDEF VER200_UP}
function TbsSkinCustomListBox.GetListBoxTouch: TTouchManager;
begin
  Result := ListBox.Touch;
end;

procedure TbsSkinCustomListBox.SetListBoxTouch(Value: TTouchManager);
begin
  ListBox.Touch := Value;
end;
{$ENDIF}

procedure TbsSkinCustomListBox.SetShowCaptionButtons;
begin
  if FShowCaptionButtons <> Value
  then
    begin
      FShowCaptionButtons := Value;
      RePaint;
    end;
end;

procedure TbsSkinCustomListBox.SetTabWidths(Value: TStrings);
begin
  FTabWidths.Assign(Value);
  if FTabWidths.Count <> 0 then ListBox.Invalidate;
end;

function TbsSkinCustomListBox.GetAutoComplete: Boolean;
begin
  Result := ListBox.AutoComplete;
end;

procedure TbsSkinCustomListBox.SetAutoComplete(Value: Boolean);
begin
  ListBox.AutoComplete := Value;
end;

function TbsSkinCustomListBox.GetOnListBoxEndDrag: TEndDragEvent;
begin
  Result := ListBox.OnEndDrag;
end;

procedure TbsSkinCustomListBox.SetOnListBoxEndDrag(Value: TEndDragEvent);
begin
  ListBox.OnEndDrag := Value;
end;

function TbsSkinCustomListBox.GetOnListBoxStartDrag: TStartDragEvent;
begin
  Result := ListBox.OnStartDrag;
end;

procedure TbsSkinCustomListBox.SetOnListBoxStartDrag(Value: TStartDragEvent);
begin
  ListBox.OnStartDrag := Value;
end;

function TbsSkinCustomListBox.GetOnListBoxDragOver: TDragOverEvent;
begin
  Result := ListBox.OnDragOver;
end;

procedure TbsSkinCustomListBox.SetOnListBoxDragOver(Value: TDragOverEvent);
begin
  ListBox.OnDragOver := Value;
end;

function TbsSkinCustomListBox.GetOnListBoxDragDrop: TDragDropEvent;
begin
  Result := ListBox.OnDragDrop;
end;

procedure TbsSkinCustomListBox.SetOnListBoxDragDrop(Value: TDragDropEvent);
begin
  ListBox.OnDragDrop := Value;
end;

procedure TbsSkinCustomListBox.SetHorizontalExtent(Value: Boolean);
begin
  FHorizontalExtent := Value;
  UpdateScrollBar;
end;

procedure TbsSkinCustomListBox.ListBoxCreateWnd;
begin

end;

function  TbsSkinCustomListBox.GetColumns;
begin
  Result := ListBox.Columns;
end;

procedure TbsSkinCustomListBox.SetColumns;
begin
  ListBox.Columns := Value;
  UpDateScrollBar;
end;

procedure TbsSkinCustomListBox.SetRowCount;
begin
  FRowCount := Value;
  if FRowCount <> 0
  then
    Height := Self.CalcHeight(FRowCount);
  UpDateScrollBar;
end;

procedure TbsSkinCustomListBox.SetNumGlyphs;
begin
  FNumGlyphs := Value;
  RePaint;
end;

procedure TbsSkinCustomListBox.SetGlyph;
begin
  FGlyph.Assign(Value);
  RePaint;
end;

procedure TbsSkinCustomListBox.SetSpacing;
begin
  FSpacing := Value;
  RePaint;
end;

procedure TbsSkinCustomListBox.SetImages(Value: TCustomImageList);
begin
  FImages := Value;
  ListBox.RePaint;
end;

procedure TbsSkinCustomListBox.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  ListBox.RePaint;
end;

procedure TbsSkinCustomListBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

procedure TbsSkinCustomListBox.ListBoxWProc(var Message: TMessage; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TbsSkinCustomListBox.DefaultFontChange;
begin
  if FIndex = -1 then Font.Assign(FDefaultFont);
end;

procedure TbsSkinCustomListBox.OnDefaultCaptionFontChange;
begin
  if (FIndex = -1) and FCaptionMode then RePaint;
end;

procedure TbsSkinCustomListBox.SetDefaultCaptionHeight;
begin
  FDefaultCaptionHeight := Value;
  if (FIndex = -1) and FCaptionMode
  then
    begin
      CalcRects;
      RePaint;
    end;
end;

procedure TbsSkinCustomListBox.SetDefaultCaptionFont;
begin
  FDefaultCaptionFont.Assign(Value);
end;

procedure TbsSkinCustomListBox.SetDefaultItemHeight;
begin
  FDefaultItemHeight := Value;
  if (FIndex = -1) or ((FIndex <> -1) and (not FUseSkinItemHeight))
  then
    ListBox.ItemHeight := FDefaultItemHeight;
end;

procedure TbsSkinCustomListBox.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 100, nil);
end;

procedure TbsSkinCustomListBox.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinCustomListBox.WMTimer;
begin
  inherited;
  if WaitMode
  then
    begin
      WaitMode := False;
      StartTimer;
      Exit;
    end;
  case TimerMode of
    1: if ItemIndex > 0 then ItemIndex := ItemIndex - 1;
    2: ItemIndex := ItemIndex + 1;
  end;
end;

procedure TbsSkinCustomListBox.CMMouseEnter;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons
  then
    TestActive(-1, -1);
end;

procedure TbsSkinCustomListBox.CMMouseLeave;
var
  i: Integer;
begin
  inherited;
  if FCaptionMode  and FShowCaptionButtons
  then
  for i := 0 to 1 do
    if Buttons[i].MouseIn
    then
       begin
         Buttons[i].MouseIn := False;
         RePaint;
       end;
end;

procedure TbsSkinCustomListBox.MouseDown;
begin
  if FCaptionMode and FShowCaptionButtons
  then
    begin
      TestActive(X, Y);
      if ActiveButton <> -1
      then
        begin
          CaptureButton := ActiveButton;
          ButtonDown(ActiveButton, X, Y);
      end;
    end;
  inherited;
end;

procedure TbsSkinCustomListBox.MouseUp;
begin
  if FCaptionMode  and FShowCaptionButtons
  then
    begin
      if CaptureButton <> -1
      then ButtonUp(CaptureButton, X, Y);
      CaptureButton := -1;
    end;  
  inherited;
end;

procedure TbsSkinCustomListBox.MouseMove;
begin
  inherited;
  if FCaptionMode  and FShowCaptionButtons then TestActive(X, Y);
end;

procedure TbsSkinCustomListBox.TestActive(X, Y: Integer);
var
  i, j: Integer;
begin
  if ((FIndex <> -1) and IsNullRect(UpButtonRect) and IsNullRect(DownButtonRect)) or
      not FShowCaptionButtons
  then Exit;

  j := -1;
  OldActiveButton := ActiveButton;
  for i := 0 to 2 do
  begin
    if PtInRect(Buttons[i].R, Point(X, Y))
    then
      begin
        j := i;
        Break;
      end;
  end;

  ActiveButton := j;

  if (CaptureButton <> -1) and
     (ActiveButton <> CaptureButton) and (ActiveButton <> -1)
  then
    ActiveButton := -1;

  if (OldActiveButton <> ActiveButton)
  then
    begin
      if OldActiveButton <> - 1
      then
        ButtonLeave(OldActiveButton);

      if ActiveButton <> -1
      then
        ButtonEnter(ActiveButton);
    end;
end;

procedure TbsSkinCustomListBox.ButtonDown;
begin
  Buttons[i].MouseIn := True;
  Buttons[i].Down := True;
  DrawButton(Canvas, i);

  case i of
    0: if Assigned(FOnUpButtonClick) then Exit;
    1: if Assigned(FOnDownButtonClick) then Exit;
    2: if Assigned(FOnCheckButtonClick) then Exit;
  end;

  TimerMode := 0;
  case i of
    0: TimerMode := 1;
    1: TimerMode := 2;
  end;

  if TimerMode <> 0
  then
    begin
      WaitMode := True;
      SetTimer(Handle, 1, 500, nil);
    end;
end;

procedure TbsSkinCustomListBox.ButtonUp;
begin
  Buttons[i].Down := False;
  if ActiveButton <> i then Buttons[i].MouseIn := False;
  DrawButton(Canvas, i);
  if Buttons[i].MouseIn
  then
  case i of
    0:
      if Assigned(FOnUpButtonClick)
      then
        begin
          FOnUpButtonClick(Self);
          Exit;
        end;
    1:
      if Assigned(FOnDownButtonClick)
      then
        begin
          FOnDownButtonClick(Self);
          Exit;
        end;
    2:
      if Assigned(FOnCheckButtonClick)
      then
        begin
          FOnCheckButtonClick(Self);
          Exit;
        end;
  end;
  case i of
    1: ItemIndex := ItemIndex + 1;
    0: if ItemIndex > 0 then ItemIndex := ItemIndex - 1;
    2: ListBox.Click;
  end;
  if TimerMode <> 0 then StopTimer;
end;

procedure TbsSkinCustomListBox.ButtonEnter(I: Integer);
begin
  Buttons[i].MouseIn := True;
  DrawButton(Canvas, i);
  if (TimerMode <> 0) and Buttons[i].Down
  then SetTimer(Handle, 1, 50, nil);
end;

procedure TbsSkinCustomListBox.ButtonLeave(I: Integer);
begin
  Buttons[i].MouseIn := False;
  DrawButton(Canvas, i);
  if (TimerMode <> 0) and Buttons[i].Down
  then KillTimer(Handle, 1);
end;

procedure TbsSkinCustomListBox.CMTextChanged;
begin
  inherited;
  if FCaptionMode then RePaint;
end;

procedure TbsSkinCustomListBox.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value
  then
    begin
      FAlignment := Value;
      if FCaptionMode then RePaint;
    end;
end;

procedure TbsSkinCustomListBox.DrawButton;
var
  C: TColor;
  kf: Double;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Buttons[i] do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          Cnvs.Brush.Color := BS_BTNDOWNCOLOR;
          Cnvs.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            Cnvs.Brush.Color := BS_BTNACTIVECOLOR;
            Cnvs.FillRect(R1);
          end
        else
          begin
            Cnvs.Brush.Color := clBtnShadow;
            Cnvs.FillRect(R1);
          end;

      C := clBlack;
      case i of
        0: DrawArrowImage(Cnvs, R, C, 3);
        1: DrawArrowImage(Cnvs, R, C, 4);
        2: DrawCheckImage(Cnvs, R.Left + 4, R.Top + 4, C);
      end;
    end
  else
    with Buttons[i] do
    if not IsNullRect(R) then
    begin
      R1 := NullRect;
      case I of
        0:
          begin
            if Down and MouseIn
            then R1 := DownUpButtonRect
            else if MouseIn then R1 := ActiveUpButtonRect;
          end;
        1:
          begin
            if Down and MouseIn
            then R1 := DownDownButtonRect
            else if MouseIn then R1 := ActiveDownButtonRect;
          end;
        2: begin
            if Down and MouseIn
            then R1 := DownCheckButtonRect
            else if MouseIn then R1 := ActiveCheckButtonRect;
           end;
      end;
      if not IsNullRect(R1)
      then
        Cnvs.CopyRect(R, Picture.Canvas, R1)
      else
        begin
          case I of
            0: R1 := UpButtonRect;
            1: R1 := DownButtonRect;
            2: R1 := CheckButtonRect;
          end;
          OffsetRect(R1, SkinRect.Left, SkinRect.Top);
          Cnvs.CopyRect(R, Picture.Canvas, R1);
        end;
    end;
end;

procedure TbsSkinCustomListBox.CreateControlSkinImage;
var
  GX, GY, GlyphNum, TX, TY, i, OffX, OffY: Integer;

function GetGlyphTextWidth: Integer;
begin
  Result := B.Canvas.TextWidth(Caption);
  if not FGlyph.Empty then Result := Result + FGlyph.Width div FNumGlyphs + FSpacing;
end;

function CalcBRect(BR: TRect): TRect;
var
  R: TRect;
begin
  R := BR;
  if BR.Top <= LTPt.Y
  then
    begin
      if BR.Left > RTPt.X then OffsetRect(R, OffX, 0);
    end
  else
    begin
      OffsetRect(R, 0, OffY);
      if BR.Left > RBPt.X then OffsetRect(R, OffX, 0);
    end;
  Result := R;
end;

var
  Buffer: TBitmap;
  R1: TRect;
begin
  inherited;
  OffX := Width - RectWidth(SkinRect);
  OffY := Height - RectHeight(SkinRect);
  // hide caption buttons
  if not FShowCaptionButtons and not IsNullRect(UpButtonRect)
  then
    if not IsNullRect(DisabledButtonsRect)
    then
      begin
        R1 := ButtonsArea;
        OffsetRect(R1, OffX, 0);
        B.Canvas.CopyRect(R1, Picture.Canvas, DisabledButtonsRect);
      end
    else
      begin
        R1 := Rect(NewLtPoint.X, 0, NewRTPoint.X, NewClRect.Top - 1);
        Buffer := TBitmap.Create;
        Buffer.Width := RectWidth(R1);
        Buffer.Height := RectHeight(R1);
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height),
         B.Canvas, R1);
        R1.Right := Width - (RectWidth(SkinRect) - UpButtonRect.Right);
        B.Canvas.StretchDraw(R1, Buffer);
        Buffer.Free;
      end;
  // calc rects
  NewClRect := ClRect;
  Inc(NewClRect.Right, OffX);
  Inc(NewClRect.Bottom, OffY);
  if FCaptionMode
  then
    begin
      NewCaptionRect := CaptionRect;
      if FShowCaptionButtons
      then
        begin
          if CaptionRect.Right >= RTPt.X
          then
            Inc(NewCaptionRect.Right, OffX);
          Buttons[0].R := CalcBRect(UpButtonRect);
          Buttons[1].R := CalcBRect(DownButtonRect);
          Buttons[2].R := CalcBRect(CheckButtonRect);
        end
      else
        begin
          NewCaptionRect := CaptionRect;
          NewCaptionRect.Right := Width - CaptionRect.Left;
          Buttons[0].R := NullRect;
          Buttons[1].R := NullRect;
          Buttons[2].R := NullRect;
        end;
    end;  
  // paint caption
  if not IsNullRect(CaptionRect)
  then
    with B.Canvas do
    begin
      Font.Name := CaptionFontName;
      Font.Height := CaptionFontHeight;
      Font.Color := CaptionFontColor;
      Font.Style := CaptionFontStyle;
      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        Font.Charset := SkinData.ResourceStrData.CharSet
      else
        Font.CharSet := DefaultCaptionFont.CharSet;
      TY := NewCaptionRect.Top + RectHeight(NewCaptionRect) div 2 -
            TextHeight(Caption) div 2;
      TX := NewCaptionRect.Left + 2;
      case Alignment of
        taCenter: TX := TX + RectWidth(NewCaptionRect) div 2 - GetGlyphTextWidth div 2;
        taRightJustify: TX := NewCaptionRect.Right - GetGlyphTextWidth - 2;
      end;
      Brush.Style := bsClear;

      if not FGlyph.Empty
      then
      begin
        GY := NewCaptionRect.Top + RectHeight(NewCaptionRect) div 2 - FGlyph.Height div 2;
        GX := TX;
        TX := GX + FGlyph.Width div FNumGlyphs + FSpacing;
        GlyphNum := 1;
        if not Enabled and (NumGlyphs = 2) then GlyphNum := 2;
       end;
      TextRect(NewCaptionRect, TX, TY, Caption);
      if not FGlyph.Empty
      then DrawGlyph(B.Canvas, GX, GY, FGlyph, NumGlyphs, GlyphNum);
    end;
  // paint buttons
  if FShowCaptionButtons
  then
    for i := 0 to 2 do DrawButton(B.Canvas, i);
end;

procedure TbsSkinCustomListBox.CreateControlDefaultImage;

function GetGlyphTextWidth: Integer;
begin
  Result := B.Canvas.TextWidth(Caption);
  if not FGlyph.Empty then Result := Result + FGlyph.Width div FNumGlyphs + FSpacing;
end;

var
  BW, i, TX, TY: Integer;
  R: TRect;
  GX, GY: Integer;
  GlyphNum: Integer;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons
  then
    begin
      BW := 17;
      if BW > FDefaultCaptionHeight - 3 then BW := FDefaultCaptionHeight - 3;
      Buttons[0].R := Rect(Width - BW - 2, 2, Width - 2, 1 + BW);
      Buttons[1].R := Rect(Buttons[0].R.Left - BW, 2, Buttons[0].R.Left, 1 + BW);
      Buttons[2].R := Rect(Buttons[1].R.Left - BW, 2, Buttons[1].R.Left, 1 + BW);
    end;  
  R := ClientRect;
  Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
  if ListBox <> nil
  then
    Frame3D(B.Canvas, R, ListBox.Color, ListBox.Color, 1);
  if FCaptionMode
  then
    with B.Canvas do
    begin
      //
      Brush.Color := clBtnShadow;
      FillRect(Rect(0, 0, Width, FDefaultCaptionHeight));
      //
      if FShowCaptionButtons
      then
        R := Rect(3, 2, Width - BW * 3 - 3, FDefaultCaptionHeight - 2)
      else
        R := Rect(3, 2, Width - 2, FDefaultCaptionHeight - 2);
      Font.Assign(FDefaultCaptionFont);
      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        Font.Charset := SkinData.ResourceStrData.CharSet;

      case Alignment of
        taLeftJustify: TX := R.Left;
        taCenter: TX := R.Left + RectWidth(R) div 2 - GetGlyphTextWidth div 2;
        taRightJustify: TX := R.Right - GetGlyphTextWidth;
      end;

      TY := (FDefaultCaptionHeight - 2) div 2 - TextHeight(Caption) div 2;

      if not FGlyph.Empty
      then
        begin
          GY := R.Top + RectHeight(R) div 2 - FGlyph.Height div 2 - 1;
          GX := TX;
          if FNumGlyphs = 0 then FNumGlyphs := 1;
          TX := GX + FGlyph.Width div FNumGlyphs + FSpacing;
          GlyphNum := 1;
          if not Enabled and (NumGlyphs = 2) then GlyphNum := 2;
        end;
      TextRect(R, TX, TY, Caption);
      if not FGlyph.Empty
      then DrawGlyph(B.Canvas, GX, GY, FGlyph, NumGlyphs, GlyphNum);
      if FShowCaptionButtons
      then
        for i := 0 to 2 do DrawButton(B.Canvas, i);
    end;
end;

procedure TbsSkinCustomListBox.SetCaptionMode;
begin
  FCaptionMode := Value;
  if FIndex = -1
  then
    begin
      CalcRects;
      RePaint;
    end;
end;

function TbsSkinCustomListBox.CalcHeight;
begin
  if FIndex = -1
  then
    begin
      Result := AitemsCount * ListBox.ItemHeight + 4;
      if CaptionMode then Result := Result + FDefaultCaptionHeight;
    end  
  else
    Result := ClRect.Top + AitemsCount * ListBox.ItemHeight +
              RectHeight(SkinRect) - ClRect.Bottom;
  if HScrollBar <> nil
  then
    Inc(Result, HScrollBar.Height);
end;

procedure TbsSkinCustomListBox.Clear;
begin
  ListBox.Clear;
  UpDateScrollBar;
end;

function TbsSkinCustomListBox.ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
begin
  Result := ListBox.ItemAtPos(Pos, Existing);
end;

function TbsSkinCustomListBox.ItemRect(Item: Integer): TRect;
begin
  Result := ListBox.ItemRect(Item);
end;

function TbsSkinCustomListBox.GetListBoxPopupMenu;
begin
  Result := ListBox.PopupMenu;
end;

procedure TbsSkinCustomListBox.SetListBoxPopupMenu;
begin
  ListBox.PopupMenu := Value;
end;


function TbsSkinCustomListBox.GetCanvas: TCanvas;
begin
  Result := ListBox.Canvas;
end;

function TbsSkinCustomListBox.GetListBoxDragMode: TDragMode;
begin
  Result := ListBox.DragMode;
end;

procedure TbsSkinCustomListBox.SetListBoxDragMode(Value: TDragMode);
begin
  ListBox.DragMode := Value;
end;

function TbsSkinCustomListBox.GetListBoxDragKind: TDragKind;
begin
  Result := ListBox.DragKind;
end;

procedure TbsSkinCustomListBox.SetListBoxDragKind(Value: TDragKind);
begin
  ListBox.DragKind := Value;
end;

function TbsSkinCustomListBox.GetListBoxDragCursor: TCursor;
begin
  Result := ListBox.DragCursor;
end;

procedure TbsSkinCustomListBox.SetListBoxDragCursor(Value: TCursor);
begin
  ListBox.DragCursor := Value;
end;

function TbsSkinCustomListBox.GetExtandedSelect: Boolean;
begin
  Result := ListBox.ExtendedSelect;
end;

procedure TbsSkinCustomListBox.SetExtandedSelect(Value: Boolean);
begin
  ListBox.ExtendedSelect := Value;
end;

function TbsSkinCustomListBox.GetSelCount: Integer;
begin
  Result := ListBox.SelCount;
end;

function TbsSkinCustomListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := ListBox.Selected[Index];
end;

procedure TbsSkinCustomListBox.SetSelected(Index: Integer; Value: Boolean);
begin
  ListBox.Selected[Index] := Value;
end;

function TbsSkinCustomListBox.GetSorted: Boolean;
begin
  Result := ListBox.Sorted;
end;

procedure TbsSkinCustomListBox.SetSorted(Value: Boolean);
begin
  if ScrollBar <> nil then HideScrollBar;
  ListBox.Sorted := Value;
end;

function TbsSkinCustomListBox.GetTopIndex: Integer;
begin
  Result := ListBox.TopIndex;
end;

procedure TbsSkinCustomListBox.SetTopIndex(Value: Integer);
begin
  ListBox.TopIndex := Value;
end;

function TbsSkinCustomListBox.GetMultiSelect: Boolean;
begin
  Result := ListBox.MultiSelect;
end;

procedure TbsSkinCustomListBox.SetMultiSelect(Value: Boolean);
begin
  ListBox.MultiSelect := Value;
end;

function TbsSkinCustomListBox.GetListBoxFont: TFont;
begin
  Result := ListBox.Font;
end;

procedure TbsSkinCustomListBox.SetListBoxFont(Value: TFont);
begin
  ListBox.Font.Assign(Value);
end;

function TbsSkinCustomListBox.GetListBoxTabOrder: TTabOrder;
begin
  Result := ListBox.TabOrder;
end;

procedure TbsSkinCustomListBox.SetListBoxTabOrder(Value: TTabOrder);
begin
  ListBox.TabOrder := Value;
end;

function TbsSkinCustomListBox.GetListBoxTabStop: Boolean;
begin
  Result := ListBox.TabStop;
end;

procedure TbsSkinCustomListBox.SetListBoxTabStop(Value: Boolean);
begin
  ListBox.TabStop := Value;
end;

procedure TbsSkinCustomListBox.ShowScrollBar;
begin
  ScrollBar := TbsSkinScrollBar.Create(Self);
  with ScrollBar do
  begin
    if Columns > 0
    then
      Kind := sbHorizontal
    else
      Kind := sbVertical;
    Height := 100;
    Width := 20;
    PageSize := 0;
    Min := 0;
    Position := 0;
    OnChange := SBChange;
    if Self.FIndex = -1
    then
      SkinDataName := ''
    else
      if Columns > 0
      then
        SkinDataName := HScrollBarName
      else
        SkinDataName := VScrollBarName;
    SkinData := Self.SkinData;
    //
    if HScrollBar <> nil
    then
    with HScrollBar do
    begin
      if Self.FIndex = -1
      then
        begin
          SkinDataName := '';
          FBoth := True;
          BothMarkerWidth := 19;
        end
      else
        begin
          BothSkinDataName := BothScrollBarName;
          SkinDataName := BothScrollBarName;
          FBoth := True;
        end;
      SkinData := Self.SkinData;
    end;
    //
    CalcRects;
    Parent := Self;
    Visible := True;
  end;
  RePaint;
end;

procedure TbsSkinCustomListBox.ShowHScrollBar;
begin
  HScrollBar := TbsSkinScrollBar.Create(Self);
  with HScrollBar do
  begin
    Kind := sbHorizontal;
    Height := 100;
    Width := 20;
    PageSize := 0;
    Min := 0;
    Position := 0;
    OnChange := HSBChange;
    if Self.FIndex = -1
    then
      begin
        SkinDataName := '';
        if ScrollBar <> nil
        then
          begin
            FBoth := True;
            BothMarkerWidth := 19;
          end;
      end
    else
      if ScrollBar <> nil
      then
        begin
          BothSkinDataName := BothScrollBarName;
          SkinDataName := BothScrollBarName;
          FBoth := True;
        end
      else
        begin
          BothSkinDataName := HScrollBarName;
          SkinDataName := HScrollBarName;
          FBoth := False;
        end;
    SkinData := Self.SkinData;
    CalcRects;
    Parent := Self;
    Visible := True;
  end;
  RePaint;
end;


procedure TbsSkinCustomListBox.ListBoxEnter;
begin
end;

procedure TbsSkinCustomListBox.ListBoxExit;
begin
end;

procedure TbsSkinCustomListBox.ListBoxKeyDown;
begin
  if Assigned(FOnListBoxKeyDown) then FOnListBoxKeyDown(Self, Key, Shift);
end;

procedure TbsSkinCustomListBox.ListBoxKeyUp;
begin
  if Assigned(FOnListBoxKeyUp) then FOnListBoxKeyUp(Self, Key, Shift);
end;

procedure TbsSkinCustomListBox.ListBoxKeyPress;
begin
  if Assigned(FOnListBoxKeyPress) then FOnListBoxKeyPress(Self, Key);
end;

procedure TbsSkinCustomListBox.ListBoxDblClick;
begin
  if Assigned(FOnListBoxDblClick) then FOnListBoxDblClick(Self);
end;

procedure TbsSkinCustomListBox.ListBoxClick;
begin
  if Assigned(FOnListBoxClick) then FOnListBoxClick(Self);
end;

procedure TbsSkinCustomListBox.ListBoxMouseDown;
begin
  if Assigned(FOnListBoxMouseDown) then FOnListBoxMouseDown(Self, Button, Shift, X, Y);
end;

procedure TbsSkinCustomListBox.ListBoxMouseMove;
begin
  if Assigned(FOnListBoxMouseMove) then FOnListBoxMouseMove(Self, Shift, X, Y);
end;

procedure TbsSkinCustomListBox.ListBoxMouseUp;
begin
  if Assigned(FOnListBoxMouseUp) then FOnListBoxMouseUp(Self, Button, Shift, X, Y);
end;

procedure TbsSkinCustomListBox.HideScrollBar;
begin
  ScrollBar.Visible := False;
  ScrollBar.Free;
  ScrollBar := nil;
  CalcRects;
end;

procedure TbsSkinCustomListBox.HideHScrollBar;
begin
  ListBox.HorizontalExtentValue := 0;
  HScrollBar.Visible := False;
  HScrollBar.Free;
  HScrollBar := nil;
  CalcRects;
  ListBox.Repaint;
end;

procedure TbsSkinCustomListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TbsSkinCustomListBox.HSBChange(Sender: TObject);
begin
  ListBox.HorizontalExtentValue := HScrollBar.Position;
  ListBox.Repaint;
end;

procedure TbsSkinCustomListBox.SBChange;
var
  LParam, WParam: Integer;
begin
  LParam := 0;
  WParam := MakeWParam(SB_THUMBPOSITION, ScrollBar.Position);
  if Columns > 0
  then
    SendMessage(ListBox.Handle, WM_HSCROLL, WParam, LParam)
  else
    begin
      SendMessage(ListBox.Handle, WM_VSCROLL, WParam, LParam);
    end;
end;


function TbsSkinCustomListBox.GetItemIndex;
begin
  Result := ListBox.ItemIndex;
end;

procedure TbsSkinCustomListBox.SetItemIndex;
begin
  ListBox.ItemIndex := Value;
end;

procedure TbsSkinCustomListBox.SetItems;
begin
  ListBox.Items.Assign(Value);
  UpDateScrollBar;
end;

function TbsSkinCustomListBox.GetItems;
begin
   Result := ListBox.Items;
end;

destructor TbsSkinCustomListBox.Destroy;
begin
  FTabWidths.Free;
  if ScrollBar <> nil then ScrollBar.Free;
  if ListBox <> nil then ListBox.Free;
  FDefaultCaptionFont.Free;
  FGlyph.Free;
  inherited;
end;

procedure TbsSkinCustomListBox.CalcRects;
var
  LTop: Integer;
  OffX, OffY: Integer;
  HSY: Integer;
begin
  if FIndex <> -1
  then
    begin
      OffX := Width - RectWidth(SkinRect);
      OffY := Height - RectHeight(SkinRect);
      NewClRect := ClRect;
      Inc(NewClRect.Right, OffX);
      Inc(NewClRect.Bottom, OffY);
    end
  else
    if FCaptionMode
    then
      LTop := FDefaultCaptionHeight
    else
      LTop := 1;

  if (Columns = 0) and (HScrollBar <> nil) and (HScrollBar.Visible)
  then
    begin
      if FIndex = -1
      then
        begin
          HScrollBar.SetBounds(1, Height - 20, Width - 2, 19);
          HSY := HScrollBar.Height - 1;
        end
      else
        begin
          HScrollBar.SetBounds(NewClRect.Left,
            NewClRect.Bottom - HScrollBar.Height,
            RectWidth(NewClRect), HScrollBar.Height);
          HSY := HScrollBar.Height;
        end;
    end
  else
    HSY := 0;
  if (ScrollBar <> nil) and ScrollBar.Visible
  then
    begin
      if FIndex = -1
      then
        begin
          if Columns > 0
          then
            begin
              ScrollBar.SetBounds(1, Height - 20, Width - 2, 19);
              ListRect := Rect(2, LTop + 1, Width - 2, ScrollBar.Top);
            end
          else
            begin
              ScrollBar.SetBounds(Width - 20, LTop, 19, Height - 1 - LTop - HSY);
              ListRect := Rect(2, LTop + 1, ScrollBar.Left, Height - 2 - HSY);
            end;
        end
      else
        begin
          if Columns > 0
          then
            begin
              ScrollBar.SetBounds(NewClRect.Left,
                NewClRect.Bottom - ScrollBar.Height,
                RectWidth(NewClRect), ScrollBar.Height);
              ListRect := NewClRect;
              Dec(ListRect.Bottom, ScrollBar.Height);
            end
          else
            begin
              ScrollBar.SetBounds(NewClRect.Right - ScrollBar.Width,
                NewClRect.Top, ScrollBar.Width, RectHeight(NewClRect) - HSY);
              ListRect := NewClRect;
              Dec(ListRect.Right, ScrollBar.Width);
              Dec(ListRect.Bottom, HSY);
            end;
        end;
    end
  else
    begin
      if FIndex = -1
      then
        ListRect := Rect(2, LTop + 1, Width - 2, Height - 2)
      else
        ListRect := NewClRect;
    end;
  if ListBox <> nil
  then
    ListBox.SetBounds(ListRect.Left, ListRect.Top,
      RectWidth(ListRect), RectHeight(ListRect));
end;

procedure TbsSkinCustomListBox.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinListBox
    then
      with TbsDataSkinListBox(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.SItemRect := SItemRect;
        Self.ActiveItemRect := ActiveItemRect;
        if isNullRect(ActiveItemRect)
        then
          Self.ActiveItemRect := SItemRect;
        Self.FocusItemRect := FocusItemRect;
        if isNullRect(FocusItemRect)
        then
          Self.FocusItemRect := SItemRect;

        Self.ItemLeftOffset := ItemLeftOffset;
        Self.ItemRightOffset := ItemRightOffset;
        Self.ItemTextRect := ItemTextRect;
        Self.FontColor := FontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.FocusFontColor := FocusFontColor;
        //
        Self.CaptionRect := CaptionRect;
        Self.CaptionFontName := CaptionFontName;
        Self.CaptionFontStyle := CaptionFontStyle;
        Self.CaptionFontHeight := CaptionFontHeight;
        Self.CaptionFontColor := CaptionFontColor;
        Self.UpButtonRect := UpButtonRect;
        Self.ActiveUpButtonRect := ActiveUpButtonRect;
        Self.DownUpButtonRect := DownUpButtonRect;
        if IsNullRect(Self.DownUpButtonRect)
        then Self.DownUpButtonRect := Self.ActiveUpButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.ActiveDownButtonRect := ActiveDownButtonRect;
        Self.DownDownButtonRect := DownDownButtonRect;
        if IsNullRect(Self.DownDownButtonRect)
        then Self.DownDownButtonRect := Self.ActiveDownButtonRect;
        Self.CheckButtonRect := CheckButtonRect;
        Self.ActiveCheckButtonRect := ActiveCheckButtonRect;
        Self.DownCheckButtonRect := DownCheckButtonRect;
        if IsNullRect(Self.DownCheckButtonRect)
        then Self.DownCheckButtonRect := Self.ActiveCheckButtonRect;
        //
        Self.VScrollBarName := VScrollBarName;
        Self.HScrollBarName := HScrollBarName;
        Self.BothScrollBarName := BothScrollBarName;
        Self.ShowFocus := ShowFocus;
        //
        Self.DisabledButtonsRect := DisabledButtonsRect;
        Self.ButtonsArea := ButtonsArea;
      end;
end;

procedure TbsSkinCustomListBox.ChangeSkinData;
begin
  inherited;
  //
  FStopUpDateHScrollBar := True;
  if (FIndex <> -1)
  then
    begin
      if FUseSkinItemHeight
      then
        ListBox.ItemHeight := RectHeight(sItemRect);
    end
  else
    begin
      ListBox.ItemHeight := FDefaultItemHeight;
      Font.Assign(FDefaultFont);
    end;

  if ScrollBar <> nil
  then
    with ScrollBar do
    begin
      if Self.FIndex = -1
      then
        SkinDataName := ''
      else
        if Columns > 0
        then
          SkinDataName := HScrollBarName
        else
          SkinDataName := VScrollBarName;
      SkinData := Self.SkinData;
    end;

  if HScrollBar <> nil
  then
    with HScrollBar do
    begin
      if Self.FIndex = -1
      then
        begin
          SkinDataName := '';
          if ScrollBar <> nil
          then
            begin
              FBoth := True;
              BothMarkerWidth := 19;
            end;
        end
      else
        if ScrollBar <> nil
        then
          begin
            SkinDataName := BothScrollBarName;
            BothSkinDataName := BothScrollBarName;
            FBoth := True;
          end
        else
          begin
            BothSkinDataName := HScrollBarName;
            SkinDataName := HScrollBarName;
            FBoth := False;
          end;
      SkinData := Self.SkinData;
    end;

  if FRowCount <> 0
  then
    Height := Self.CalcHeight(FRowCount);
  CalcRects;
  FStopUpDateHScrollBar := False;
  UpDateScrollBar;
  ListBox.RePaint;
end;

procedure TbsSkinCustomListBox.WMSIZE;
begin
  inherited;
  CalcRects;
  UpDateScrollBar;
  if ScrollBar <> nil then ScrollBar.RePaint;
end;

procedure TbsSkinCustomListBox.SetBounds;
begin
  inherited;
  if FIndex = -1 then RePaint;
end;

function TbsSkinCustomListBox.GetFullItemWidth(Index: Integer; ACnvs: TCanvas): Integer;
begin
  Result := ACnvs.TextWidth(Items[Index]);
end;

procedure TbsSkinCustomListBox.UpDateScrollBar;
var
  I, FMaxWidth, Min, Max, Pos, Page: Integer;

function GetPageSize: Integer;
begin
  if FIndex = -1
  then Result := ListBox.Width - 4
  else
    begin
      Result := RectWidth(SItemRect) - RectWidth(ItemTextRect);
      Result := ListBox.Width - Result;
    end;
  if Images <> nil then Result := Result - Images.Width - 4;
end;

begin
  if ListBox = nil then Exit;
  if Columns > 0
  then
    begin
      GetScrollRange(ListBox.Handle, SB_HORZ, Min, Max);
      Pos := GetScrollPos(ListBox.Handle, SB_HORZ);
      Page := ListBox.Columns;
      if (Max > Min) and (Pos <= Max) and (Page <= Max) and
         ((ListBox.Height div ListBox.ItemHeight) * Columns < ListBox.Items.Count)
      then
        begin
          if ScrollBar = nil
          then ShowScrollBar;
          ScrollBar.SetRange(Min, Max, Pos, Page);
        end
     else
       if (ScrollBar <> nil) and ScrollBar.Visible
       then HideScrollBar;
    end
  else
    begin
      if FHorizontalExtent and not FStopUpDateHScrollBar
      then
        begin
          FMaxWidth := 0;
          with ListBox.Canvas do
          begin
            if (FIndex = -1) or not FUseSkinFont
            then
              Font.Assign(ListBox.Font)
            else
              begin
                Font.Name := FontName;
                Font.Style := FontStyle;
                Font.Height := FontHeight;
              end;
          end;
          for I := 0 to Items.Count - 1 do
            FMaxWidth := bsUtils.Max(FMaxWidth, GetFullItemWidth(I, ListBox.Canvas));
          Page := GetPageSize;
          if FMaxWidth > Page
          then
            begin
             if HScrollBar = nil then ShowHScrollBar;
             HScrollBar.SetRange(0, FMaxWidth, HScrollBar.Position, Page);
             HScrollBar.SmallChange := ListBox.Canvas.TextWidth('0');
             HScrollBar.LargeChange := ListBox.Canvas.TextWidth('0');
           end
         else
          if (HScrollBar <> nil) and HScrollBar.Visible then HideHScrollBar;
       end
      else
        if (HScrollBar <> nil) and HScrollBar.Visible then HideHScrollBar;

      if not ((FRowCount > 0) and (RowCount = Items.Count))
      then
        begin
          GetScrollRange(ListBox.Handle, SB_VERT, Min, Max);
          Pos := GetScrollPos(ListBox.Handle, SB_VERT);
          Page := ListBox.Height div ListBox.ItemHeight;
          if (Max > Min) and (Pos <= Max) and (Page < Items.Count)
          then
            begin
              if ScrollBar = nil then ShowScrollBar;
              ScrollBar.SetRange(Min, Max, Pos, Page);
              ScrollBar.LargeChange := Page; 
            end
          else
            if (ScrollBar <> nil) and ScrollBar.Visible then HideScrollBar;
        end
      else
        if (ScrollBar <> nil) and ScrollBar.Visible then HideScrollBar;
    end;
end;

// combobox

constructor TbsSkinCustomComboBox.Create;
begin
  inherited Create(AOwner);
  FNumEdit := False;
  FDropDown := False;
  FToolButtonStyle := False;
  TabStop := True;
  ControlStyle := [csCaptureMouse, csReplicatable, csOpaque, csDoubleClicks, csAcceptsControls];
  FCharCase := ecNormal;
  FUseSkinSize := True;
  FLBDown := False;
  WasInLB := False;
  TimerMode := 0;
  FHideSelection := True;
  FDefaultColor := clWindow;
  FAutoComplete := True;
  FAlphaBlendAnimation := False;
  FAlphaBlend := False;
  Font.Name := 'Tahoma';
  Font.Color := clWindowText;
  Font.Style := [];
  Font.Height := 13;
  Width := 120;
  Height := 20;
  FromEdit := False;
  FEdit := nil;
  //
  FStyle := bscbFixedStyle;
  FOnListBoxDrawItem := nil;
  FListBox := TbsPopupListBox.Create(Self);
  FListBox.Visible := False;
  if not (csDesigning in ComponentState)
  then
    FlistBox.Parent := Self;
  FListBox.ListBox.TabStop := False;
  FListBox.ListBox.OnMouseMove := ListBoxMouseMove;
  FListBoxWindowProc := FlistBox.ListBox.WindowProc;
  FlistBox.ListBox.WindowProc := ListBoxWindowProcHook;
  FListBox.OnCheckButtonClick := CheckButtonClick;
  FLBDown := False;
  FDropDownCount := 8;
  //
  CalcRects;
  FSkinDataName := 'combobox';
  FLastTime := 0;
  FListBoxWidth := 0;
end;

{$IFDEF VER200_UP}
function TbsSkinCustomComboBox.GetListBoxTouch: TTouchManager;
begin
  Result :=  Self.FListBox.ListBoxTouch;
end;

procedure TbsSkinCustomComboBox.SetListBoxTouch(Value: TTouchManager);
begin
 Self.FListBox.ListBoxTouch := Value;
end;
{$ENDIF}

procedure TbsSkinCustomComboBox.DrawMenuMarker;
var
  Buffer: TBitMap;
  SR: TRect;
  X, Y: Integer;
begin
  with ButtonData do
  begin
    if ADown and not IsNullRect(MenuMarkerDownRect)
     then SR := MenuMarkerDownRect else
      if AActive and not IsNullRect(MenuMarkerActiveRect)
      then SR := MenuMarkerActiveRect else SR := MenuMarkerRect;

    if ADown and IsNullRect(MenuMarkerDownRect) and
        not IsNullRect(MenuMarkerActiveRect)
    then SR := MenuMarkerActiveRect;
    
  end;

  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(SR);
  Buffer.Height := RectHeight(SR);

  Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height),
    Picture.Canvas, SR);

  Buffer.Transparent := True;
  Buffer.TransparentMode := tmFixed;
  Buffer.TransparentColor := ButtonData.MenuMarkerTransparentColor;

  X := R.Left + RectWidth(R) div 2 - RectWidth(SR) div 2;
  Y := R.Top + RectHeight(R) div 2 - RectHeight(SR) div 2;

  C.Draw(X, Y, Buffer);

  Buffer.Free;
end;


procedure TbsSkinCustomComboBox.SetToolButtonStyle;
begin
  if FToolButtonStyle <> Value
  then
    begin
      FToolButtonStyle := Value;
      if FToolButtonStyle
      then
        begin
          Style := bscbFixedStyle;
          UseSkinSize := False;
        end;
      RePaint;  
    end;
end;

procedure TbsSkinCustomComboBox.SetCharCase;
begin
  FCharCase := Value;
  if FEdit <> nil then FEdit.CharCase := FCharCase;
end;

procedure TbsSkinCustomComboBox.SetTabWidths(Value: TStrings);
begin
  if FListBox <> nil then FListBox.TabWidths.Assign(Value);
end;

function TbsSkinCustomComboBox.GetTabWidths: TStrings;
begin
  if FListBox <> nil then Result := FListBox.TabWidths else Result := nil;
end;

procedure TbsSkinCustomComboBox.DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);

function GetNum(AText: String): Integer;
const
  EditChars = '01234567890';
var
  i: Integer;
  S: String;
  IsNum: Boolean;
begin
  S := EditChars;
  Result := 0;
  if (AText = '') then Exit;
  IsNum := True;
  for i := 1 to Length(AText) do
  begin
    if Pos(AText[i], S) = 0
    then
      begin
        IsNum := False;
        Break;
      end;
  end;
  if IsNum then Result := StrToInt(AText) else Result := 0;
end;

var
  S1: String;
  i, Max: Integer;
  TWValue: array[0..9] of Integer;
  X, Y: Integer;
begin
  for i := 0 to TW.Count - 1 do
  begin
    if i < 10 then TWValue[i] := GetNum(TW[i]);
  end;
  Max := TW.Count;
  if Max > 10 then Max := 10;
  X := R.Left + Offset + 2;
  Y := R.Top + RectHeight(R) div 2 - C.TextHeight(S) div 2;
  //
  if (C.Font.Height div 2) <> (C.Font.Height / 2) then Dec(Y, 1);
  //
  TabbedTextOut(C.Handle, X, Y, PChar(S), Length(S), Max, TWValue, 0);
end;

procedure TbsSkinCustomComboBox.SetDefaultColor(Value: TColor);
begin
  FDefaultColor := Value;
  if FIndex = -1 then Invalidate;
  if (FIndex = -1) and (FEdit <> nil) then FEdit.Color := FDefaultColor;
end;

procedure TbsSkinCustomComboBox.PaintSkinTo(C: TCanvas; X, Y: Integer; AText: String);
var
  B: TBitMap;
  R: TRect;
  S: String;
begin
  B := TBitmap.Create;
  B.Width := Width;
  B.Height := Height;
  GetSkinData;
  S := Self.Text;
  Text := AText;

  if FToolButtonStyle
  then
    begin
      if FIndex <> -1
      then
        CreateControlToolSkinImage(B, AText)
      else
        Self.CreateControlToolDefaultImage(B, AText);
    end
  else
  if Findex = -1
  then
    begin
      CreateControlDefaultImage2(B);
      with B.Canvas.Font do
      begin
        Name := Self.DefaultFont.Name;
        Style := Self.DefaultFont.Style;
        Color := Self.DefaultFont.Color;
        Height := Self.DefaultFont.Height;
      end;
    end
  else
    begin
      CreateControlSkinImage2(B);
      with B.Canvas.Font do
      begin
        Style := FontStyle;
        Color := FontColor;
        Height := FontHeight;
        Name := FontName;
      end;
    end;
  // draw item area

  if not FToolButtonStyle
  then
    begin
      B.Canvas.Brush.Style := bsClear;
      if (FListBox <> nil) and (TabWidths.Count > 0)
      then
        DrawTabbedString(AText, TabWidths, B.Canvas, CBItem.R, 0)
      else
        BSDrawText2(B.Canvas, AText, CBItem.R);
    end;
  C.Draw(X, Y, B);
  B.Free;
  Text := S;  
end;


procedure TbsSkinCustomComboBox.SetControlRegion;
begin
  if FUseSkinSize then inherited;
end;

procedure TbsSkinCustomComboBox.WMEraseBkgnd;
begin
  if not FromWMPaint
  then
    begin
      PaintWindow(Msg.DC);
    end;
end;

procedure TbsSkinCustomComboBox.CalcSize(var W, H: Integer);
var
  XO, YO: Integer;
begin
  if FUseSkinSize
  then
    inherited
  else
    begin
      XO := W - RectWidth(SkinRect);
      YO := H - RectHeight(SkinRect);
      NewLTPoint := LTPt;
      NewRTPoint := Point(RTPt.X + XO, RTPt.Y );
      NewClRect := ClRect;
      Inc(NewClRect.Right, XO);
    end;
end;

procedure TbsSkinCustomComboBox.FindLBItemFromEdit;
var
  I: Integer;
  S1, S2: String;
begin
  if (FListBox = nil) or (FListBox.ListBox = nil) then Exit;

  if GetTickCount - FLastTime <= 200
  then
    Exit
  else
    FLastTime := GetTickCount;

  if Length(Text) = 1
  then
    I := SendMessage(FListBox.ListBox.Handle, LB_FINDSTRING, ItemIndex, LongInt(PChar(Text)))
  else
    I := SendMessage(FListBox.ListBox.Handle, LB_FINDSTRING, -1, LongInt(PChar(Text)));
  if I >= 0
  then
    begin
      S1 := Text;
      ItemIndex := I;
      S2 := Text;
      SelStart := Length(S1);
      SelLength := Length(S2) - Length(S1);
    end;
end;

procedure TbsSkinCustomComboBox.FindLBItem(S: String);
var
  I: Integer;
  S1: String;
begin
  if (FListBox = nil) or (FListBox.ListBox = nil) then Exit;
  if FAutoComplete
  then
    begin
      if GetTickCount - FLastTime >= 500 then FFilter := '';
      FLastTime := GetTickCount;
      FFilter := FFilter + S;
      S := FFilter;
    end;
  if Length(S) > 0
  then
    begin
      if Length(S) = 1
      then
        I := SendMessage(FListBox.ListBox.Handle, LB_FINDSTRING, ItemIndex, LongInt(PChar(S)))
      else
        I := SendMessage(FListBox.ListBox.Handle, LB_FINDSTRING, -1, LongInt(PChar(S)));
    end
  else
    I := -1;
  if I >= 0 then ItemIndex := I;
end;

procedure TbsSkinCustomComboBox.KeyPress;
begin
  inherited;
  FindLBItem(Key);
end;

function TbsSkinCustomComboBox.GetSelStart: Integer;
begin
  if (FEdit <> nil) then Result := FEdit.SelStart else Result := 0;
end;

procedure TbsSkinCustomComboBox.SetSelStart(Value: Integer);
begin
  if (FEdit <> nil) then FEdit.SelStart := Value;
end;

function TbsSkinCustomComboBox.GetSelLength: Integer;
begin
  if (FEdit <> nil) then Result := FEdit.SelLength else Result := 0;
end;

procedure TbsSkinCustomComboBox.SetSelLength(Value: Integer);
begin
  if (FEdit <> nil) then FEdit.SelLength := Value;
end;

procedure TbsSkinCustomComboBox.EditKeyDown;
begin
  if Assigned(OnKeyDown) then OnKeyDown(Self, Key, Shift);
end;

procedure TbsSkinCustomComboBox.EditKeyUp;
begin
  if Assigned(OnKeyUp) then OnKeyUp(Self, Key, Shift);
end;

procedure TbsSkinCustomComboBox.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(OnKeyPress) then OnKeyPress(Self, Key);
end;

destructor TbsSkinCustomComboBox.Destroy;
begin
  if FEdit <> nil then FEdit.Free;
  FlistBox.Free;
  FlistBox := nil;
  inherited;
end;

procedure TbsSkinCustomComboBox.CMEnabledChanged;
begin
  inherited;
  if (FEdit <> nil)
  then
    if Enabled
    then
      begin
        if FIndex <> -1
        then FEdit.Font.Color := FontColor
        else FEdit.Font.Color := FDefaultFont.Color;
      end
    else
      FEdit.Font.Color := GetDisabledFontColor;
  RePaint;
end;

function TbsSkinCustomComboBox.GetListBoxUseSkinItemHeight: Boolean;
begin
  Result := FListBox.UseSkinItemHeight;
end;

procedure TbsSkinCustomComboBox.SetListBoxUseSkinItemHeight(Value: Boolean);
begin
  FListBox.UseSkinItemHeight := Value;
end;

function TbsSkinCustomComboBox.GetListBoxUseSkinFont: Boolean;
begin
  Result := FListBox.UseSkinFont;
end;

procedure TbsSkinCustomComboBox.SetListBoxUseSkinFont(Value: Boolean);
begin
  FListBox.UseSkinFont := Value;
end;

function TbsSkinCustomComboBox.GetHorizontalExtent: Boolean;
begin
  Result := FlistBox.HorizontalExtent;
end;

procedure TbsSkinCustomComboBox.SetHorizontalExtent(Value: Boolean);
begin
  FlistBox.HorizontalExtent := Value;
end;

procedure TbsSkinCustomComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

function TbsSkinCustomComboBox.GetImages: TCustomImageList;
begin
  if FListBox <> nil
  then
    Result := FListBox.Images
   else
    Result := nil;
end;

function TbsSkinCustomComboBox.GetImageIndex: Integer;
begin
  Result := FListBox.ImageIndex;
end;

procedure TbsSkinCustomComboBox.SetImages(Value: TCustomImageList);
begin
  FListBox.Images := Value;
  RePaint;
end;

procedure TbsSkinCustomComboBox.SetImageIndex(Value: Integer);
begin
  FListBox.ImageIndex := Value;
  RePaint;
end;

procedure TbsSkinCustomComboBox.EditCancelMode(C: TControl);
begin
  if (C = nil) or
     ((C <> Self) and
     (C <> Self.FListBox) and
     (C <> Self.FListBox.ScrollBar) and
     (C <> Self.FListBox.HScrollBar) and
     (C <> Self.FListBox.ListBox))
  then
    CloseUp(False);
end;

procedure TbsSkinCustomComboBox.CMCancelMode;
begin
  inherited;
  if (Message.Sender = nil) or (
     (Message.Sender <> Self) and
     (Message.Sender <> Self.FListBox) and
     (Message.Sender <> Self.FListBox.ScrollBar) and
     (Message.Sender <> Self.FListBox.HScrollBar) and
     (Message.Sender <> Self.FListBox.ListBox))
  then
    CloseUp(False);
end;

procedure TbsSkinCustomComboBox.Change;
begin
end;

function TbsSkinCustomComboBox.GetListBoxDefaultFont;
begin
  Result := FListBox.DefaultFont;
end;

procedure TbsSkinCustomComboBox.SetListBoxDefaultFont;
begin
  FListBox.DefaultFont.Assign(Value);
end;

function TbsSkinCustomComboBox.GetListBoxDefaultCaptionFont;
begin
  Result := FListBox.DefaultCaptionFont;
end;

procedure TbsSkinCustomComboBox.SetListBoxDefaultCaptionFont;
begin
  FListBox.DefaultCaptionFont.Assign(Value);
end;

function TbsSkinCustomComboBox.GetListBoxDefaultItemHeight;
begin
  Result := FListBox.DefaultItemHeight;
end;

procedure TbsSkinCustomComboBox.SetListBoxDefaultItemHeight;
begin
  FListBox.DefaultItemHeight := Value;
end;

function TbsSkinCustomComboBox.GetListBoxCaptionAlignment;
begin
  Result := FListBox.Alignment;
end;

procedure TbsSkinCustomComboBox.SetListBoxCaptionAlignment;
begin
  FListBox.Alignment := Value;
end;

procedure TbsSkinCustomComboBox.DefaultFontChange;
begin
  Font.Assign(FDefaultFont);
end;

procedure TbsSkinCustomComboBox.CheckButtonClick;
begin
  CloseUp(True);
end;

procedure TbsSkinCustomComboBox.SetListBoxCaption;
begin
  FListBox.Caption := Value;
end;

function  TbsSkinCustomComboBox.GetListBoxCaption;
begin
  Result := FListBox.Caption;
end;

procedure TbsSkinCustomComboBox.SetListBoxCaptionMode;
begin
  FListBox.CaptionMode := Value;
end;

function  TbsSkinCustomComboBox.GetListBoxCaptionMode;
begin
  Result := FListBox.CaptionMode;
end;

function TbsSkinCustomComboBox.GetSorted: Boolean;
begin
  Result := FListBox.Sorted;
end;

procedure TbsSkinCustomComboBox.SetSorted(Value: Boolean);
begin
  FListBox.Sorted := Value;
end;

procedure TbsSkinCustomComboBox.SetListBoxDrawItem;
begin
  FOnListboxDrawItem := Value;
  FListBox.OnDrawItem := FOnListboxDrawItem;
end;

procedure TbsSkinCustomComboBox.ListBoxDrawItem(Cnvs: TCanvas; Index: Integer;
            ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
begin
  if Assigned(FOnListBoxDrawItem)
  then FOnListBoxDrawItem(Cnvs, Index, ItemWidth, ItemHeight, TextRect, State);
end;

procedure TbsSkinCustomComboBox.SetStyle;
begin
  if (FStyle = Value) and
   ((csDesigning in ComponentState) or not (csLoading in ComponentState))
  then
    Exit;
  FStyle := Value;
  case FStyle of
    bscbFixedStyle:
      begin
        if FEdit <> nil then HideEditor;
      end;
    bscbEditStyle:
      begin
        ShowEditor;
        if not (csDesigning in ComponentState)
        then
          begin
            if Self.TabStop
            then
              begin
                Self.TabStop := False;
                FEdit.TabStop := True;
              end
            else
              FEdit.TabStop := Self.TabStop;
          end;    
        FEdit.Text := Text;
        if Focused and not (csLoading in ComponentState)
        then
          FEdit.SetFocus;
      end;
  end;
  CalcRects;
  ReCreateWnd;
  RePaint;
end;

procedure TbsSkinCustomComboBox.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  case Msg.CharCode of
    VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT:  Msg.Result := 1;
  end;
end;

procedure TbsSkinCustomComboBox.KeyDown;
var
  I: Integer;
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_UP, VK_LEFT:
      if ssAlt in Shift
      then
        begin
          if FListBox.Visible then CloseUp(False);
        end
      else
        EditUp1(True);
    VK_DOWN, VK_RIGHT:
      if ssAlt in Shift
      then
        begin
          if not FListBox.Visible then DropDown;
        end
      else
        EditDown1(True);

    VK_NEXT: EditPageDown1(True);
    VK_PRIOR: EditPageUp1(True);
    VK_ESCAPE: if FListBox.Visible then CloseUp(False);
    VK_RETURN: if FListBox.Visible then CloseUp(True);
  end;
end;

procedure TbsSkinCustomComboBox.WMMOUSEWHEEL;
begin
  if FEdit <> nil then Exit;
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    EditUp1(not FListBox.Visible)
  else
    EditDown1(not FListBox.Visible);
end;

procedure TbsSkinCustomComboBox.WMSETFOCUS;
begin
  if FEdit <> nil
  then
    begin
      FEDit.SetFocus;
      if (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
      then
        begin
          FEdit.Font.Color := ActiveFontColor;
          Invalidate;
        end;
    end
  else
    begin
      inherited;
      RePaint;
    end;  
end;

procedure TbsSkinCustomComboBox.WMKILLFOCUS;
begin
  inherited;
  if FListBox.Visible and (FEdit = nil)
  then CloseUp(False);
  RePaint;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) and (FEdit <> nil)
  then
    begin
      FEdit.Font.Color := FontColor;
      Invalidate;
    end;
end;

procedure TbsSkinCustomComboBox.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinComboBox
    then
      with TbsDataSkinComboBox(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.ActiveSkinRect := ActiveSkinRect;
        Self.ActiveFontColor := ActiveFontColor;
        Self.SItemRect := SItemRect;
        Self.ActiveItemRect := ActiveItemRect;
        Self.FocusItemRect := FocusItemRect;
        if isNullRect(FocusItemRect)
        then
          Self.FocusItemRect := SItemRect;
        Self.ItemLeftOffset := ItemLeftOffset;
        Self.ItemRightOffset := ItemRightOffset;
        Self.ItemTextRect := ItemTextRect;

        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.FocusFontColor := FocusFontColor;

        Self.ButtonRect := ButtonRect;
        Self.ActiveButtonRect := ActiveButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.UnEnabledButtonRect := UnEnabledButtonRect;
        Self.ListBoxName := ListBoxName;
        Self.ItemStretchEffect := ItemStretchEffect;
        Self.FocusItemStretchEffect := FocusItemStretchEffect;
        Self.ShowFocus := ShowFocus;
      end;
end;

procedure TbsSkinCustomComboBox.Invalidate;
begin
  inherited;
  if (FIndex <> -1) and (FEdit <> nil) then FEdit.DoPaint;
end;

function TbsSkinCustomComboBox.GetItemIndex;
begin
  Result := FListBox.ItemIndex;
end;

procedure TbsSkinCustomComboBox.SetItemIndex;
begin
  FListBox.ItemIndex := Value;
  if (FListBox.Items.Count > 0) and (FListBox.ItemIndex <> -1)
  then
    Text := FListBox.Items[FListBox.ItemIndex];
  FOldItemIndex := FListBox.ItemIndex;
  if FEdit = nil then RePaint;
  if not (csDesigning in ComponentState) and
     not (csLoading in ComponentState)
  then
    begin
      if Assigned(FOnClick) then FOnClick(Self);
      Change;
    end;
end;

function TbsSkinCustomComboBox.IsPopupVisible: Boolean;
begin
  Result := FListBox.Visible;
end;

function TbsSkinCustomComboBox.CanCancelDropDown;
begin
  Result := FListBox.Visible and not FMouseIn;
end;

procedure TbsSkinCustomComboBox.EditWindowProcHook(var Message: TMessage);

function GetCharSet: TFontCharSet;
begin
  if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    Result := SkinData.ResourceStrData.CharSet
  else
    Result := FDefaultFont.Charset;
end;

var
  FOld: Boolean;
  Index: Integer;
  CharSet: TFontCharSet;
begin
  FOld := True;
  case Message.Msg of

    WM_LBUTTONDOWN, WM_RBUTTONDOWN:
      begin
        if FListBox.Visible then CloseUp(False);
      end;

    WM_SETFOCUS:
      begin
        if (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
        then
          begin
            FEdit.Font.Color := ActiveFontColor;
            Invalidate;
         end;
      end;

    WM_KILLFOCUS:
      begin
        if FListBox.Visible then CloseUp(False);
        if (FIndex <> -1) and not IsNullRect(ActiveSkinRect)
        then
          begin
            FEdit.Font.Color := FontColor;
            Invalidate;
         end;
      end;

    WM_MOUSEWHEEL:
     begin
       if TWMMOUSEWHEEL(Message).WheelDelta > 0
       then
         EditUp(not FListBox.Visible)
       else
         EditDown(not FListBox.Visible);
     end;

    WM_SYSKEYUP:
      begin
        CharSet := GetCharSet;
        if (CharSet = SHIFTJIS_CHARSET) or (CharSet = GB2312_CHARSET) or
           (CharSet = SHIFTJIS_CHARSET) or (CharSet = CHINESEBIG5_CHARSET)
        then
          begin
            if not ((TWMKEYUP(Message).CharCode = 46) or
                   (TWMKEYUP(Message).CharCode =8))
            then
              begin
                FEdit.ClearSelection;
                FEditWindowProc(Message);
                FOld := False;
                if FAutoComplete then FindLBItemFromEdit;
              end;
          end;
      end;
    WM_KEYUP:
      begin
        CharSet := GetCharSet;
        if (CharSet = SHIFTJIS_CHARSET) or (CharSet = GB2312_CHARSET) or
           (CharSet = SHIFTJIS_CHARSET) or (CharSet = CHINESEBIG5_CHARSET)
        then
          begin
            if not ((TWMKEYUP(Message).CharCode = 46) or
                    (TWMKEYUP(Message).CharCode = 8))
            then
              begin
                FEdit.ClearSelection;
                FEditWindowProc(Message);
                FOld := False;
                if FAutoComplete then FindLBItemFromEdit;
              end;
          end
        else
        if TWMKEYUP(Message).CharCode > 47
        then
          begin
            FEditWindowProc(Message);
            FOld := False;
            if FAutoComplete then FindLBItemFromEdit;
          end;
      end;

    WM_KEYDOWN:
      begin
        case TWMKEYDOWN(Message).CharCode of
          VK_PRIOR:
            if FListBox.Visible
            then
              begin
                Index := FListBox.ItemIndex - DropDownCount - 1;
                if Index < 0
                then
                  Index := 0;
                FListBox.ItemIndex := Index;
              end;
          VK_NEXT:
            if FListBox.Visible
            then
              begin
                Index := FListBox.ItemIndex + DropDownCount - 1;
                if Index > FListBox.Items.Count - 1
                then
                  Index := FListBox.Items.Count - 1;
                FListBox.ItemIndex := Index;
              end;
          VK_RETURN:
            begin
              if FListBox.Visible then CloseUp(True);
            end;
          VK_ESCAPE:
            begin
              if FListBox.Visible then CloseUp(False);
            end;
          VK_UP:
            begin
              EditUp(True);
              FOld := False;
            end;
          VK_DOWN:
            begin
              EditDown(True);
              FOld := False;
            end;
        end;
      end;
  end;
  if FOld then FEditWindowProc(Message);
end;

procedure TbsSkinCustomComboBox.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 25, nil);
end;

procedure TbsSkinCustomComboBox.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinCustomComboBox.WMTimer;
begin
  inherited;
  case TimerMode of
    1: if FListBox.ItemIndex > 0
       then
         FListBox.ItemIndex := FListBox.ItemIndex - 1;
    2:
       if FListBox.ItemIndex < FListBox.Items.Count
       then
         FListBox.ItemIndex := FListBox.ItemIndex + 1;
  end;
end;

procedure TbsSkinCustomComboBox.ProcessListBox;
var
  R: TRect;
  P: TPoint;
  LBP: TPoint;
begin
  GetCursorPos(P);
  P := FListBox.ListBox.ScreenToClient(P);
  if (P.Y < 0) and (FListBox.ScrollBar <> nil) and WasInLB
  then
    begin
      if (TimerMode <> 1)
      then
        begin
          TimerMode := 1;
          StartTimer;
        end;
    end
  else
  if (P.Y > FListBox.ListBox.Height) and (FListBox.ScrollBar <> nil) and WasInLB
  then
    begin
      if (TimerMode <> 2)
      then
        begin
          TimerMode := 2;
          StartTimer;
        end
    end
  else
    if (P.Y >= 0) and (P.Y <= FListBox.ListBox.Height)
    then
      begin
        if TimerMode <> 0 then StopTimer;
        FListBox.ListBox.MouseMove([], 1, P.Y);
        WasInLB := True;
      end;
end;

procedure TbsSkinCustomComboBox.ListBoxWindowProcHook(var Message: TMessage);
var
  FOld: Boolean;
begin
  FOld := True;
  case Message.Msg of
     WM_LBUTTONDOWN:
       begin
         FOLd := False;
         FLBDown := True;
         WasInLB := True;
         SetCapture(Self.Handle);
       end;
     WM_LBUTTONUP,
     WM_RBUTTONDOWN, WM_RBUTTONUP,
     WM_MBUTTONDOWN, WM_MBUTTONUP:
       begin
         FOLd := False;
       end;
     WM_MOUSEACTIVATE:
      begin
        Message.Result := MA_NOACTIVATE;
      end;
  end;
  if FOld then FListBoxWindowProc(Message);
end;

procedure TbsSkinCustomComboBox.CMMouseEnter;
begin
  inherited;
  if (csDesigning in ComponentState) then Exit;
  FMouseIn := True;
  //
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) and (FEdit <> nil)
     and not FEDit.Focused
  then
    begin
      FEdit.Font.Color := ActiveFontColor;
    end;
  //
  if ((FIndex <> -1) and not IsNullRect(ActiveSkinRect)) or FToolButtonStyle
  then
    Invalidate;
end;

procedure TbsSkinCustomComboBox.CMMouseLeave;
begin
  inherited;
  if (csDesigning in ComponentState) then Exit;
  FMouseIn := False;
  if Button.MouseIn
  then
    begin
      Button.MouseIn := False;
      RePaint;
    end;
  //
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) and (FEdit <> nil)
     and not FEDit.Focused
  then
    begin
      FEdit.Font.Color := FontColor;
    end;
  //
 if ((FIndex <> -1) and not IsNullRect(ActiveSkinRect)) or FToolButtonStyle
 then
   Invalidate;
end;

procedure TbsSkinCustomComboBox.SetDropDownCount(Value: Integer);
begin
  if Value > 0
  then
    FDropDownCount := Value;
end;

procedure TbsSkinCustomComboBox.ListBoxMouseMove(Sender: TObject; Shift: TShiftState;
                          X, Y: Integer);

var
  Index: Integer;
begin
  Index := FListBox.ItemAtPos(Point (X, Y), True);
  if (Index >= 0) and (Index < Items.Count)
  then
    FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomComboBox.SetItems;
begin
  FListBox.Items.Assign(Value);
end;

function TbsSkinCustomComboBox.GetItems;
begin
  Result := FListBox.Items;
end;

procedure TbsSkinCustomComboBox.MouseDown;
begin
  inherited;
  if not Focused and (FEdit = nil) then SetFocus;
  if Button <> mbLeft then Exit;
  if Self.Button.MouseIn or
     (PtInRect(CBItem.R, Point(X, Y)) and (FEdit = nil)) or
     FToolButtonStyle
  then
    begin
      Self.Button.Down := True;
      RePaint;
      if FListBox.Visible then CloseUp(False)
      else
        begin
          WasInLB := False;
          FLBDown := True;
          DropDown;
        end;
    end
  else
    if FListBox.Visible then CloseUp(False);
end;

procedure TbsSkinCustomComboBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
var
  P: TPoint;
begin
  if FLBDown and WasInLB
  then
    begin
      ReleaseCapture;
      FLBDown := False;
      GetCursorPos(P);
      if WindowFromPoint(P) = FListBox.ListBox.Handle
      then
        CloseUp(True)
      else
        CloseUp(False);
    end
  else
     FLBDown := False;
  inherited;
  if Self.Button.Down
  then
    begin
      Self.Button.Down := False;
      RePaint;
    end;
end;

procedure TbsSkinCustomComboBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FLBDown
  then
    begin
      ProcessListBox;
    end
  else
  if PtInRect(Button.R, Point(X, Y)) and not Button.MouseIn
  then
    begin
      Button.MouseIn := True;
      RePaint;
    end
  else
  if not PtInRect(Button.R, Point(X, Y)) and Button.MouseIn
  then
    begin
      Button.MouseIn := False;
      RePaint;
    end;
end;

procedure TbsSkinCustomComboBox.CloseUp;
begin
  if TimerMode <> 0 then StopTimer;
  if not FListBox.Visible then Exit;
  FListBox.Hide;
  if (FListBox.ItemIndex >= 0) and
     (FListBox.ItemIndex < FListBox.Items.Count) and Value
  then
    begin
      if FEdit <> nil
      then
        begin
          FEdit.Text := FListBox.Items[FListBox.ItemIndex];
          FEdit.SelectAll;
        end
      else
        begin
          Text := FListBox.Items[FListBox.ItemIndex];
          RePaint;
        end;
       if Assigned(FOnClick) then FOnClick(Self);
       Change;
     end
  else
    FListBox.ItemIndex := FOldItemIndex;
  FDropDown := False;  
  RePaint;
  if Assigned(FOnCloseUp) then FOnCloseUp(Self);
end;

procedure TbsSkinCustomComboBox.DropDown;
function GetForm(AControl : TControl) : TForm;
  var
    temp : TControl;
  begin
    result := nil;
    temp := AControl;
    repeat
      if assigned(temp) then
      begin
        if temp is TForm then
        break;
      end;
      temp := temp.Parent;
    until temp = nil;
  end;

var
  P: TPoint;
  WorkArea: TRect;
begin
  if Items.Count = 0 then Exit;
  WasInLB := False;
  if TimerMode <> 0 then StopTimer;
  if Assigned(FOnDropDown) then FOnDropDown(Self);

  if FListBoxWidth = 0
  then
    FListBox.Width := Width
  else
    FListBox.Width := FListBoxWidth;

  if Items.Count < DropDownCount
  then
    FListBox.RowCount := Items.Count
  else
    FListBox.RowCount := DropDownCount;
  P := Point(Left, Top + Height);
  P := Parent.ClientToScreen (P);

  WorkArea := GetMonitorWorkArea(Handle, True);

  if P.Y + FListBox.Height > WorkArea.Bottom
  then
    P.Y := P.Y - Height - FListBox.Height;

  if FEdit <> nil then FEdit.SetFocus;

  FOldItemIndex := FListBox.ItemIndex;

  if (FListBox.ItemIndex = 0) and (FListBox.Items.Count > 1)
  then
    begin
      FListBox.ItemIndex := 1;
      FListBox.ItemIndex := 0;
    end;
  FDropDown := True;
  if Self.FToolButtonStyle then  RePaint;
  FListBox.TopIndex := FListBox.ItemIndex;
  FListBox.SkinData := SkinData;
  FListBox.Show(P);
end;

procedure TbsSkinCustomComboBox.EditPageUp1(AChange: Boolean);
var
  Index: Integer;
begin
  Index := FListBox.ItemIndex - DropDownCount - 1;
  if Index < 0 then Index := 0;
  if AChange
  then
    ItemIndex := Index
  else
    FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomComboBox.EditPageDown1(AChange: Boolean);
var
  Index: Integer;
begin
  Index := FListBox.ItemIndex + DropDownCount - 1;
  if Index > FListBox.Items.Count - 1
  then
    Index := FListBox.Items.Count - 1;
  if AChange
  then
    ItemIndex := Index
  else
    FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomComboBox.EditUp1;
begin
  if FListBox.ItemIndex > 0
  then
    begin
      if AChange
      then
        ItemIndex := ItemIndex - 1
      else
        FListBox.ItemIndex := FListBox.ItemIndex - 1;
    end;
end;

procedure TbsSkinCustomComboBox.EditDown1;
begin
  if FListBox.ItemIndex < FListBox.Items.Count - 1
  then
    begin
      if AChange
      then
        ItemIndex := ItemIndex + 1
      else
        FListBox.ItemIndex := FListBox.ItemIndex + 1;
    end;
end;

procedure TbsSkinCustomComboBox.EditUp;
begin
  if ItemIndex > 0
  then
    begin
      ItemIndex := ItemIndex - 1;
      if AChange
      then
        begin
          Text := Items[ItemIndex];
          FEdit.SelectAll;
          if Assigned(FOnClick) then FOnClick(Self);
        end;
    end;
end;

procedure TbsSkinCustomComboBox.EditDown;
begin
  if ItemIndex < Items.Count - 1
  then
    begin
      FListBox.ItemIndex := FListBox.ItemIndex + 1;
      if AChange
      then
        begin
          Text := FListBox.Items[FListBox.ItemIndex];
          FEdit.SelectAll;
          if Assigned(FOnClick) then FOnClick(Self);
        end;
    end;
end;

procedure TbsSkinCustomComboBox.EditChange(Sender: TObject);
var
  I: Integer;
begin
  FromEdit := True;
  if (FListBox <> nil) and (FEdit.Text <> '')
  then
    begin
      I := SendMessage(FListBox.ListBox.Handle, LB_FINDSTRING, -1, LongInt(PChar(FEdit.Text)));
      if I >= 0
      then
        if FAutoComplete
        then
          SendMessage(FListBox.ListBox.Handle, LB_SETCURSEL, I, 0)
        else
          SendMessage(FListBox.ListBox.Handle, LB_SETTOPINDEX, I, 0);
    end;
  Text := FEdit.Text;
  FromEdit := False;  
end;

procedure TbsSkinCustomComboBox.ShowEditor;
begin
  if not FNumEdit
  then
    FEdit := TbsCustomEdit.Create(Self)
  else
    FEdit := TbsSkinNumEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Color := FDefaultColor;
  FEdit.AutoSize := False;
  FEdit.HideSelection := FHideSelection;
  FEdit.Visible := True;
  FEdit.EditTransparent := False;
  FEdit.OnChange := EditChange;
  FEditWindowProc := FEdit.WindowProc;
  FEdit.WindowProc := EditWindowProcHook;
  FEdit.OnEditCancelMode := EditCancelMode;
  FEdit.OnKeyDown := EditKeyDown;
  FEdit.OnKeyPress := EditKeyPress;
  FEdit.OnKeyUp := EditKeyUp;
  FEdit.CharCase := FCharCase;
  //
  if FIndex <> -1
  then
    with FEdit.Font do
    begin
      Style := FontStyle;
      Color := FontColor;
      Height := FontHeight;
      Name := FontName;
    end
  else
    with FEdit.Font do
    begin
      Name := Self.Font.Name;
      Style := Self.Font.Style;
      Color := Self.Font.Color;
      Height := Self.Font.Height;
    end;
    if FIndex <> -1
    then FEdit.EditTransparent := True
    else FEdit.EditTransparent := False;
  //
  CalcRects;
end;

procedure TbsSkinCustomComboBox.HideEditor;
begin
  FEdit.Visible := False;
  FEdit.Free;
  FEdit := nil;
end;

procedure TbsSkinCustomComboBox.CMTextChanged;
begin
  inherited;
  if (FEdit <> nil) and not FromEdit then FEdit.Text := Text;
  if Assigned(FOnChange) then FOnChange(Self);
  if FromEdit then Change;
end;

procedure TbsSkinCustomComboBox.WMSIZE;
begin
  inherited;
  CalcRects;
  AdjustEditPos;
end;

procedure TbsSkinCustomComboBox.DrawResizeButton;
var
  Buffer, Buffer2: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  SR, BtnCLRect: TRect;
  BSR, ABSR, DBSR: TRect;
  XO, YO: Integer;
  ArrowColor: TColor;
  X, Y: Integer;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(Button.R);
  Buffer.Height := RectHeight(Button.R);
  //
  CIndex := SkinData.GetControlIndex('combobutton');
  if CIndex = -1
  then
    CIndex := SkinData.GetControlIndex('editbutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('resizebutton');
  if CIndex = -1
  then
    begin
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
    XO := RectWidth(Button.R) - RectWidth(SkinRect);
    YO := RectHeight(Button.R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if Button.Down and Button.MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := DownFontColor;
      end
    else
    if Button.MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := FontColor;
      end;
   end;
  //
  if not IsNullRect(ButtonData.MenuMarkerRect)
  then
    with ButtonData do
    begin
      if Button.Down and Button.MouseIn and not IsNullRect(MenuMarkerDownRect)
      then SR := MenuMarkerDownRect else
        if Button.MouseIn and not IsNullRect(MenuMarkerActiveRect)
          then SR := MenuMarkerActiveRect else SR := MenuMarkerRect;

      Buffer2 := TBitMap.Create;
      Buffer2.Width := RectWidth(SR);
      Buffer2.Height := RectHeight(SR);

      Buffer2.Canvas.CopyRect(Rect(0, 0, Buffer2.Width, Buffer2.Height),
       Picture.Canvas, SR);

      Buffer2.Transparent := True;
      Buffer2.TransparentMode := tmFixed;
      Buffer2.TransparentColor := MenuMarkerTransparentColor;

      X := RectWidth(Button.R) div 2 - RectWidth(SR) div 2;
      Y := RectHeight(Button.R) div 2 - RectHeight(SR) div 2;
      if Button.Down and Button.MouseIn then Y := Y + 1;
      Buffer.Canvas.Draw(X, Y, Buffer2);
      Buffer2.Free;
    end
  else
  if Enabled
  then
    begin
      if Button.Down and Button.MouseIn
      then
        DrawArrowImage(Buffer.Canvas, Rect(0, 2, Buffer.Width, Buffer.Height), ArrowColor, 4)
      else
        DrawArrowImage(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height), ArrowColor, 4);
    end;
  //
  C.Draw(Button.R.Left, Button.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomComboBox.DrawButton;
var
  ArrowColor: TColor;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Button do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(C, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          C.Brush.Color := BS_BTNDOWNCOLOR;
          C.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(C, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            C.Brush.Color := BS_BTNACTIVECOLOR;
            C.FillRect(R1);
          end
        else
          begin
            Frame3D(C, R1, clBtnShadow, clBtnShadow, 1);
            C.Brush.Color := clBtnFace;
            C.FillRect(R1);
          end;
      if Enabled
      then
        ArrowColor := clBlack
      else
        ArrowColor := clBtnShadow;
      DrawArrowImage(C, R, ArrowColor, 4);
    end
  else
    with Button do
    begin
      R1 := NullRect;
      if not Enabled and not IsNullRect(UnEnabledButtonRect)
      then
        R1 := UnEnabledButtonRect
      else
      if Down and MouseIn
      then R1 := DownButtonRect
      else if MouseIn then R1 := ActiveButtonRect;
      if not IsNullRect(R1)
      then
        C.CopyRect(R, Picture.Canvas, R1);
    end;
end;

procedure TbsSkinCustomComboBox.DrawDefaultItem;
var
  Buffer: TBitMap;
  R, R1: TRect;
  Index, IIndex, IX, IY: Integer;
begin
  if RectWidth(CBItem.R) <=0 then Exit;
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(CBItem.R);
  Buffer.Height := RectHeight(CBItem.R);
  R := Rect(0, 0, Buffer.Width, Buffer.Height);
  with Buffer.Canvas do
  begin
    Font.Name := Self.Font.Name;
    Font.Style := Self.Font.Style;
    Font.Height := Self.Font.Height;
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinData.ResourceStrData.CharSet
    else
      Font.Charset := FDefaultFont.Charset;
    if Focused
    then
      begin
        Brush.Color := clHighLight;
        Font.Color := clHighLightText;
      end
    else
      begin
        Brush.Color := FDefaultColor;
        Font.Color := FDefaultFont.Color;
      end;
    FillRect(R);
  end;

  if FListBox.Visible
  then Index := FOldItemIndex
  else Index := FListBox.ItemIndex;

  CBItem.State := [];

  if Focused then CBItem.State := [odFocused];

  R1 := Rect(R.Left + 2, R.Top, R.Right - 2, R.Bottom);
  if (Index > -1) and (Index < FListBox.Items.Count)
  then
    if Assigned(FOnComboBoxDrawItem)
    then
      FOnComboBoxDrawItem(Buffer.Canvas, Index, Buffer.Width, Buffer.Height,
                          R1, CBItem.State)
    else
      begin
        if Images <> nil
        then
          begin
            if ImageIndex > -1
            then IIndex := ImageIndex
            else IIndex := Index;
            if IIndex < Images.Count
            then
              begin
                IX := R1.Left;
                IY := R1.Top + RectHeight(R1) div 2 - Images.Height div 2;
                Images.Draw(Buffer.Canvas, IX, IY, IIndex);
              end;
            Inc(R1.Left, Images.Width + 2);
          end;
       if (FListBox <> nil) and (TabWidths.Count > 0)
       then
         DrawTabbedString(FListBox.Items[Index], TabWidths, Buffer.Canvas, R1, 0)
       else
         BSDrawText2(Buffer.Canvas, FListBox.Items[Index], R1);
      end;
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomComboBox.DrawResizeSkinItem(Cnvs: TCanvas);
var
  Buffer: TBitMap;
  R, R2: TRect;
  W, H: Integer;
  Index, IIndex, IX, IY: Integer;
  Offset: Integer;
begin
  W := RectWidth(CBItem.R);
  if W <= 0 then Exit;
  H := RectHeight(SItemRect);
  if H = 0 then H := RectHeight(FocusItemRect);
  if H = 0 then H := RectWidth(CBItem.R);
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(CBItem.R);
  Buffer.Height := RectHeight(CBItem.R);
  if Focused
  then
    begin
      if not IsNullRect(FocusItemRect)
      then
        begin
          R2 := ItemTextRect;
          InflateRect(R2, -1, -1);
          
          if RectWidth(SItemRect) > RectWidth(FocusItemRect)
          then
            Dec(R2.Right, RectWidth(SItemRect) - RectWidth(FocusItemRect));

          if RectHeight(SItemRect) > RectHeight(FocusItemRect)
          then
            Dec(R2.Top, RectHeight(SItemRect) - RectHeight(FocusItemRect));

          CreateStretchImage(Buffer, Picture, FocusItemRect, R2, True);
        end
      else
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height), Cnvs, CBItem.R);
    end
  else
    begin
      if not IsNullRect(ActiveItemRect) and not IsNullRect(ActiveSkinRect) and
         FMouseIn
      then
        begin
           R2 := ItemTextRect;
          if RectWidth(SItemRect) > RectWidth(ActiveItemRect)
          then
            Dec(R2.Right, RectWidth(SItemRect) - RectWidth(ActiveItemRect));

          if RectHeight(SItemRect) > RectHeight(ActiveItemRect)
          then
            Dec(R2.Top, RectHeight(SItemRect) - RectHeight(ActiveItemRect));

          CreateStretchImage(Buffer, Picture, ActiveItemRect, R2, True)
        end
      else
      if not IsNullRect(SItemRect)
      then
        CreateStretchImage(Buffer, Picture, SItemRect, ItemTextRect, True)
      else
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height), Cnvs, CBItem.R);
    end;

  R := ItemTextRect;
  if not IsNullRect(SItemRect)
  then
    Inc(R.Right, W - RectWidth(SItemRect))
  else
    Inc(R.Right, W - RectWidth(ClRect));
  Inc(ItemTextRect.Bottom, Height - RectHeight(SkinRect));
  Inc(R.Bottom, Height - RectHeight(SkinRect));
  with Buffer.Canvas do
  begin
    if FUseSkinFont
    then
      begin
        Font.Name := FontName;
        Font.Style := FontStyle;
        Font.Height := FontHeight;
      end
    else
      Font.Assign(FDefaultFont);

    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := FDefaultFont.CharSet;

    if Focused
    then
      Font.Color := FocusFontColor
    else
      if FMouseIn and not IsNullRect(ActiveSkinRect)
      then
        Font.Color := ActiveFontColor
      else
        Font.Color := FontColor;

    if not Enabled then Font.Color := GetDisabledFontColor;
    
    Brush.Style := bsClear;
  end;

  if FListBox.Visible
  then Index := FOldItemIndex
  else Index := FListBox.ItemIndex;

  if (Index > -1) and (Index < FListBox.Items.Count)
  then
    if Assigned(FOnComboBoxDrawItem)
    then
      FOnComboBoxDrawItem(Buffer.Canvas, Index, Buffer.Width, Buffer.Height,
                          R, CBItem.State)
    else
      begin
       if Focused and ShowFocus
       then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := FSD.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
        if Images <> nil
        then
          begin
            if ImageIndex > -1
            then IIndex := ImageIndex
            else IIndex := Index;
            if IIndex < Images.Count
            then
              begin
                IX := R.Left;
                IY := R.Top + RectHeight(R) div 2 - Images.Height div 2;
                Images.Draw(Buffer.Canvas, IX, IY, IIndex);
              end;
            Inc(R.Left, Images.Width + 2);
          end;
       if (FListBox <> nil) and (TabWidths.Count > 0)
       then
         DrawTabbedString(FListBox.Items[Index], TabWidths, Buffer.Canvas, R, 0)
       else
        BSDrawText2(Buffer.Canvas, FListBox.Items[Index], R);
      end;
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;


function TbsSkinCustomComboBox.GetDisabledFontColor: TColor;
var
  i: Integer;
begin
  i := -1;
  if FIndex <> -1 then i := SkinData.GetControlIndex('edit');
  if i = -1
  then
    Result := clGrayText
  else
    begin
      Result := TbsDataSkinEditControl(SkinData.CtrlList[i]).DisabledFontColor;
      if TbsDataSkinEditControl(SkinData.CtrlList[i]).FontColor = Result
      then
        Result := clGrayText;
    end;
end;

procedure TbsSkinCustomComboBox.DrawSkinItem;
var
  Buffer: TBitMap;
  R, R2: TRect;
  W, H: Integer;
  Index, IIndex, IX, IY: Integer;
begin
  W := RectWidth(CBItem.R);
  if W <= 0 then Exit;
  H := RectHeight(SItemRect);
  if H = 0 then H := RectHeight(FocusItemRect);
  if H = 0 then H := RectWidth(CBItem.R);
  Buffer := TBitMap.Create;
  if Focused
  then
    begin
      if not IsNullRect(FocusItemRect)
      then
        CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
          FocusItemRect, W, H, FocusItemStretchEffect)
      else
        begin
          Buffer.Width := W;
          BUffer.Height := H;
          Buffer.Canvas.CopyRect(Rect(0, 0, W, H), Cnvs, CBItem.R);
        end;
    end
  else
    begin
      if not IsNullRect(ActiveItemRect) and not IsNullRect(ActiveSkinRect) and
         FMouseIn
      then
        begin
          CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
            ActiveItemRect, W, H, ItemStretchEffect)
        end
      else
      if not IsNullRect(SItemRect)
      then
        CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
          SItemRect, W, H, ItemStretchEffect)
      else
        begin
          Buffer.Width := W;
          BUffer.Height := H;
          Buffer.Canvas.CopyRect(Rect(0, 0, W, H), Cnvs, CBItem.R);
        end;
    end;

  R := ItemTextRect;
  
  if not IsNullRect(SItemRect)
  then
    Inc(R.Right, W - RectWidth(SItemRect))
  else
    Inc(R.Right, W - RectWidth(ClRect));

  with Buffer.Canvas do
  begin
    if FUseSkinFont
    then
      begin
        Font.Name := FontName;
        Font.Style := FontStyle;
        Font.Height := FontHeight;
      end
    else
      Font.Assign(FDefaultFont);

    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := FDefaultFont.CharSet;

    if Focused
    then
      Font.Color := FocusFontColor
    else
      if FMouseIn and not IsNullRect(ActiveSkinRect)
      then
        Font.Color := ActiveFontColor
      else
        Font.Color := FontColor;
    if not Enabled then Font.Color := GetDisabledFontColor;
    Brush.Style := bsClear;
  end;

  if FListBox.Visible
  then Index := FOldItemIndex
  else Index := FListBox.ItemIndex;

  if (Index > -1) and (Index < FListBox.Items.Count)
  then
    if Assigned(FOnComboBoxDrawItem)
    then
      FOnComboBoxDrawItem(Buffer.Canvas, Index, Buffer.Width, Buffer.Height,
                          R, CBItem.State)
    else
      begin
       if Focused and ShowFocus
       then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := FSD.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
        if Images <> nil
        then
          begin
            if ImageIndex > -1
            then IIndex := ImageIndex
            else IIndex := Index;
            if IIndex < Images.Count
            then
              begin
                IX := R.Left;
                IY := R.Top + RectHeight(R) div 2 - Images.Height div 2;
                Images.Draw(Buffer.Canvas, IX, IY, IIndex);
              end;
            Inc(R.Left, Images.Width + 2);
          end;
       if (FListBox <> nil) and (TabWidths.Count > 0)
       then
         DrawTabbedString(FListBox.Items[Index], TabWidths, Buffer.Canvas, R, 0)
       else
        BSDrawText2(Buffer.Canvas, FListBox.Items[Index], R);
      end;
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomComboBox.AdjustEditHeight;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  if FEdit = nil then Exit;
  DC := GetDC(0);
  SaveFont := SelectObject(DC, FEdit.Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  FEdit.Height := Metrics.tmHeight;
end;

procedure TbsSkinCustomComboBox.CalcRects;
const
  ButtonW = 17;
var
  OX, OY: Integer;
begin
  if (FIndex = -1) or FToolButtonStyle
  then
    begin
      Button.R := Rect(Width - ButtonW - 2, 0, Width, Height);
      CBItem.R := Rect(2, 2, Button.R.Left - 1 , Height -  2);
    end
  else
    begin
      OX := Width - RectWidth(SkinRect);
      Button.R := ButtonRect;
      if ButtonRect.Left >= RectWidth(SkinRect) - RTPt.X
      then
        OffsetRect(Button.R, OX, 0);
      CBItem.R := ClRect;
      Inc(CBItem.R.Right, OX);
      if not UseSkinSize
      then
        begin
          OY := Height - RectHeight(SkinRect);
          Inc(CBItem.R.Bottom, OY);
          Inc(Button.R.Bottom, OY);
        end;
    end;
end;

procedure TbsSkinCustomComboBox.AdjustEditPos;
begin
  if (FEdit <> nil)
  then
    begin
      FEdit.Left := CBItem.R.Left;
      FEdit.Width := RectWidth(CBItem.R);
      AdjustEditHeight;
      FEdit.Top := CBItem.R.Top + RectHeight(CBItem.R) div 2 -
                   FEdit.Height div 2;
    end;
end;

procedure TbsSkinCustomComboBox.ChangeSkinData;
var
  W, H: Integer;
begin
  inherited;
  CalcRects;
  if FEdit <> nil
  then
    begin
      if (FIndex <> -1) and UseSkinFont
      then
        with FEdit.Font do
        begin
          Style := FontStyle;
          Height := FontHeight;
          Name := FontName;
          Color := FontColor;
        end
      else
        begin
          FEdit.Font.Assign(FDefaultFont);
          if FIndex <> -1
          then
            with FEdit.Font do
            begin
              Color := FontColor;
            end;
        end;

      if not IsNullRect(ActiveSkinRect) and (FEdit.Focused or FMouseIn)
      then
        begin
          FEdit.Font.Color := ActiveFontColor;
        end;

      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        FEdit.Font.Charset := SkinData.ResourceStrData.CharSet
      else
        FEdit.Font.CharSet := FDefaultFont.CharSet;

      if FIndex <> -1
      then FEdit.EditTransparent := True
      else FEdit.EditTransparent := False;

      if not Enabled then FEdit.Font.Color := GetDisabledFontColor;
    end;

  RePaint;

  if FIndex = -1
  then
    begin
      FListBox.SkinDataName := '';
    end  
  else
    FListBox.SkinDataName := ListBoxName;
  FListBox.SkinData := SkinData;
  FListBox.UpDateScrollBar;
  //
  CalcRects;
  AdjustEditPos;
  if FEdit <> nil
  then
    begin
      W := Width;
      H := Height;
      if FIndex <> -1
      then
        begin
          CalcSize(W, H);
          if W <> Width then Width := W;
          if H <> Height then Height := H;
        end;
   end;
end;


procedure TbsSkinCustomComboBox.CreateControlDefaultImage2;
var
  R: TRect;
begin
  CalcRects;
  with B.Canvas do
  begin
    Brush.Color := FDefaultColor;
    R := ClientRect;
    FillRect(R);
  end;
  Frame3D(B.Canvas, R, clbtnShadow, clbtnShadow, 1);
  DrawButton(B.Canvas);
end;


procedure TbsSkinCustomComboBox.CreateControlDefaultImage;
var
  R: TRect;
begin
  CalcRects;
  if FToolButtonStyle
  then
    begin
      CreateControlToolDefaultImage(B, '');
      Exit;
    end;
  with B.Canvas do
  begin
    Brush.Color := FDefaultColor;
    R := ClientRect;
    FillRect(R);
  end;
  Frame3D(B.Canvas, R, clbtnShadow, clbtnShadow, 1);
  DrawButton(B.Canvas);
  if FEdit = nil then  DrawDefaultItem(B.Canvas);
end;

procedure TbsSkinCustomComboBox.CreateControlToolDefaultImage(B: TBitMap; AText: String);
var
  XO, YO: Integer;
  R: TRect;
  IX, IY, Index, IIndex: Integer;
  S: String;
begin

  R := Rect(0, 0, Width, Height);
  //
  if FDropDown
  then
    begin
      Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
      B.Canvas.Brush.Color := BS_BTNDOWNCOLOR;
      B.Canvas.FillRect(R);
    end
  else
  if FMouseIn or Focused
  then
    begin
      Frame3D(B.Canvas, R, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
      B.Canvas.Brush.Color := BS_BTNACTIVECOLOR;
      B.Canvas.FillRect(R);
    end
  else
    begin
      Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
      B.Canvas.Brush.Color := clBtnFace;
      B.Canvas.FillRect(R);
    end;
  // draw item

  R := Rect(2, 2, Width - 17, Height - 2);
  if FDropDown
  then
    begin
      Inc(R.Top, 2);
      Inc(R.Left, 2);
    end;

  with B.Canvas do
  begin
    Font.Assign(FDefaultFont);
    Brush.Style := bsClear;
    if FListBox.Visible
    then Index := FOldItemIndex
    else Index := FListBox.ItemIndex;
    if (Index > -1) and (Index < FListBox.Items.Count)
    then
      if Assigned(FOnComboBoxDrawItem)
      then
        FOnComboBoxDrawItem(B.Canvas, Index, B.Width, B.Height,
          R, CBItem.State)
      else
        begin
          if Images <> nil
          then
            begin
              if ImageIndex > -1
              then IIndex := ImageIndex
              else IIndex := Index;
              if IIndex < Images.Count
              then
                begin
                  IX := R.Left;
                  IY := R.Top + RectHeight(R) div 2 - Images.Height div 2;
                  Images.Draw(B.Canvas, IX, IY, IIndex);
                 end;
                Inc(R.Left, Images.Width + 2);
              end;
              if AText <> ''
              then
                S := AText
              else
                S := FListBox.Items[Index];
              if (FListBox <> nil) and (TabWidths.Count > 0)
              then
                DrawTabbedString(S, TabWidths, B.Canvas, R, 0)
              else
                BSDrawText2(B.Canvas, S, R);
            end;
  end;

  R := Rect(Width - 15, 0, Width, Height);

  if FDropDown
  then
    begin
      Inc(R.Top, 2);
      Inc(R.Left, 2);
    end;

  DrawTrackArrowImage(B.Canvas, R, B.Canvas.Font.Color);
end;


procedure TbsSkinCustomComboBox.CreateControlToolSkinImage(B: TBitMap; AText: String);
var
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  BtnCLRect: TRect;
  XO, YO: Integer;
  SR: TRect;
  CIndex: Integer;
  R: TRect;
  IX, IY, Index, IIndex: Integer;
  S: String;
begin
  GetSkindata;
  if FIndex = -1 then Exit;

  CIndex := SkinData.GetControlIndex('resizetoolbutton');
  if CIndex = -1
  then
    begin
      CIndex := SkinData.GetControlIndex('resizebutton');
      if CIndex = -1 then Exit else
        ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);

  R := Rect(0, 0, Width, Height);

  with ButtonData do
  begin
    //
    if FDropDown then SR := DownSkinRect else
      if (FMouseIn or Focused) then SR := ActiveSkinRect else SR := SkinRect;
    if IsNullRect(SR) then SR := SkinRect;
    //

    XO := RectWidth(R) - RectWidth(SkinRect);
    YO := RectHeight(R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);
    if IsNullRect(SR) then SR := ActiveSkinRect;
    CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        B, BtnSkinPicture, SR, B.Width, B.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);

    // draw item
    R := Rect(2, 2, Width - 17, Height - 2);
   
    with B.Canvas do
    begin
      if FUseSkinFont
      then
       begin
          Font.Name := FontName;
          Font.Style := FontStyle;
          Font.Height := FontHeight;
        end
      else
        Font.Assign(FDefaultFont);
      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        Font.Charset := SkinData.ResourceStrData.CharSet
      else
        Font.CharSet := FDefaultFont.CharSet;

      if FDropDown then Font.Color := DownFontColor else
       if (FMouseIn or Focused) then Font.Color := ActiveFontColor else
         if not Enabled then Font.Color := DisabledFontColor else
           Font.Color := FontColor;
      Brush.Style := bsClear;
      if FListBox.Visible
      then Index := FOldItemIndex
      else Index := FListBox.ItemIndex;
      if (Index > -1) and (Index < FListBox.Items.Count)
      then
        if Assigned(FOnComboBoxDrawItem)
        then
          FOnComboBoxDrawItem(B.Canvas, Index, B.Width, B.Height,
           R, CBItem.State)
        else
          begin
            if Images <> nil
            then
              begin
                if ImageIndex > -1
                then IIndex := ImageIndex
                else IIndex := Index;
                 if IIndex < Images.Count
                then
                  begin
                    IX := R.Left;
                    IY := R.Top + RectHeight(R) div 2 - Images.Height div 2;
                    Images.Draw(B.Canvas, IX, IY, IIndex);
                  end;
                Inc(R.Left, Images.Width + 2);
              end;
              if AText <> ''
              then
                S := AText
              else
                S := FListBox.Items[Index];
              if (FListBox <> nil) and (TabWidths.Count > 0)
              then
                DrawTabbedString(S, TabWidths, B.Canvas, R, 0)
              else
                BSDrawText2(B.Canvas, S, R);
             end;
    end;

    //

    R := Rect(Width - 15, 0, Width, Height);

   if not IsNullRect(MenuMarkerRect)
   then
     begin
       DrawMenuMarker(B.Canvas, R, FMouseIn, FDropDown, ButtonData);
     end
   else
   if FDropDown
   then
     DrawTrackArrowImage(B.Canvas, R, DownFontColor)
   else
     DrawTrackArrowImage(B.Canvas, R, B.Canvas.Font.Color);
  end;
end;


procedure TbsSkinCustomComboBox.CreateControlSkinImage2;
var
  ClRct: TRect;
begin
  CalcRects;
  if FUseSkinSize
  then
    begin
      if not IsNullRect(ActiveSkinRect) and
        (FMouseIn or ((FEdit <> nil) and (FEdit.Focused)) or Focused)
      then
        CreateHSkinImage(LTPt.X, RectWidth(ActiveSkinRect) - RTPt.X,
          B, Picture, ActiveSkinRect, Width, RectHeight(ActiveSkinRect), StretchEffect)
      else
        inherited CreateControlSkinImage(B);
    end
  else
    begin
      ClRct := ClRect;
      InflateRect(ClRct, -3, -1);
      if not IsNullRect(ActiveSkinRect) and
        (FMouseIn or ((FEdit <> nil) and (FEdit.Focused)) or Focused)
      then
        CreateStretchImage(B, Picture, SkinRect, ClRct, True)
      else
        CreateStretchImage(B, Picture, SkinRect, ClRct, True);
    end;

  if (FUseSkinSize) or (FIndex = -1)
  then
    DrawButton(B.Canvas)
  else
    DrawResizeButton(B.Canvas);
end;


procedure TbsSkinCustomComboBox.CreateControlSkinImage;
var
  ClRct: TRect;
begin
  CalcRects;
  if FToolButtonStyle
  then
    begin
      Self.CreateControlToolSkinImage(B, '');
    end
  else
  if FUseSkinSize
  then
    begin
      if not IsNullRect(ActiveSkinRect) and
        (FMouseIn or ((FEdit <> nil) and (FEdit.Focused)) or Focused)
      then
        CreateHSkinImage(LTPt.X, RectWidth(ActiveSkinRect) - RTPt.X,
          B, Picture, ActiveSkinRect, Width, RectHeight(ActiveSkinRect), StretchEffect)
      else
        inherited;
    end
  else
    begin
      ClRct := ClRect;
      InflateRect(ClRct, -3, -1);
      if not IsNullRect(ActiveSkinRect) and
        (FMouseIn or ((FEdit <> nil) and (FEdit.Focused)) or Focused)
      then
        CreateStretchImage(B, Picture, ActiveSkinRect, ClRct, True)
      else
        CreateStretchImage(B, Picture, SkinRect, ClRct, True);
    end;


  if not FToolButtonStyle
  then
    begin
      if (FUseSkinSize) or (FIndex = -1)
      then
        DrawButton(B.Canvas)
      else
        DrawResizeButton(B.Canvas);
      if FEdit = nil
      then
        if FUseSkinSize
        then
          DrawSkinItem(B.Canvas)
        else
          DrawResizeSkinItem(B.Canvas);
    end;      
end;

// ==================== TbsSkinFontComboBox ======================= //

const
  WRITABLE_FONTTYPE = 256;

function IsValidFont(Box: TbsSkinFontComboBox; LogFont: TLogFont;
  FontType: Integer): Boolean;
begin
  Result := True;
  if (foAnsiOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = ANSI_CHARSET);
  if (foTrueTypeOnly in Box.Options) then
    Result := Result and (FontType and TRUETYPE_FONTTYPE = TRUETYPE_FONTTYPE);
  if (foFixedPitchOnly in Box.Options) then
    Result := Result and (LogFont.lfPitchAndFamily and FIXED_PITCH = FIXED_PITCH);
  if (foOEMFontsOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = OEM_CHARSET);
  if (foNoOEMFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> OEM_CHARSET);
  if (foNoSymbolFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> SYMBOL_CHARSET);
  if (foScalableOnly in Box.Options) then
    Result := Result and (FontType and RASTER_FONTTYPE = 0);
end;

function IsValidFont2(Box: TbsSkinFontListBox; LogFont: TLogFont;
  FontType: Integer): Boolean;
begin
  Result := True;
  if (foAnsiOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = ANSI_CHARSET);
  if (foTrueTypeOnly in Box.Options) then
    Result := Result and (FontType and TRUETYPE_FONTTYPE = TRUETYPE_FONTTYPE);
  if (foFixedPitchOnly in Box.Options) then
    Result := Result and (LogFont.lfPitchAndFamily and FIXED_PITCH = FIXED_PITCH);
  if (foOEMFontsOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = OEM_CHARSET);
  if (foNoOEMFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> OEM_CHARSET);
  if (foNoSymbolFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> SYMBOL_CHARSET);
  if (foScalableOnly in Box.Options) then
    Result := Result and (FontType and RASTER_FONTTYPE = 0);
end;
function EnumFontsProc(var EnumLogFont: TEnumLogFont;
  var TextMetric: TNewTextMetric; FontType: Integer; Data: LPARAM): Integer;
  export; stdcall;
var
  FaceName: string;
begin
  FaceName := StrPas(EnumLogFont.elfLogFont.lfFaceName);
  with TbsSkinFontComboBox(Data) do
    if (Items.IndexOf(FaceName) < 0) and
      IsValidFont(TbsSkinFontComboBox(Data), EnumLogFont.elfLogFont, FontType) then
    begin
      if EnumLogFont.elfLogFont.lfCharSet <> SYMBOL_CHARSET then
        FontType := FontType or WRITABLE_FONTTYPE;
      Items.AddObject(FaceName, TObject(FontType));
    end;
  Result := 1;
end;

function EnumFontsProc2(var EnumLogFont: TEnumLogFont;
  var TextMetric: TNewTextMetric; FontType: Integer; Data: LPARAM): Integer;
  export; stdcall;
var
  FaceName: string;
begin
  FaceName := StrPas(EnumLogFont.elfLogFont.lfFaceName);
  with TbsSkinFontListBox(Data) do
    if (Items.IndexOf(FaceName) < 0) and
      IsValidFont2(TbsSkinFontListBox(Data), EnumLogFont.elfLogFont, FontType) then
    begin
      if EnumLogFont.elfLogFont.lfCharSet <> SYMBOL_CHARSET then
        FontType := FontType or WRITABLE_FONTTYPE;
      Items.AddObject(FaceName, TObject(FontType));
    end;
  Result := 1;
end;

constructor TbsSkinFontComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnListBoxDrawItem := DrawLBFontItem;
  OnComboBoxDrawItem := DrawCBFontItem;
  FDevice := fdScreen;
  Sorted := True;
end;

procedure TbsSkinFontComboBox.DrawTT;
begin
  with Cnvs do
  begin
    Pen.Color := C;
    MoveTo(X, Y);
    LineTo(X + 7, Y);
    LineTo(X + 7, Y + 3);
    MoveTo(X, Y);
    LineTo(X, Y + 3);
    MoveTo(X + 1, Y);
    LineTo(X + 1, Y + 1);
    MoveTo(X + 6, Y);
    LineTo(X + 6, Y + 1);
    MoveTo(X + 3, Y);
    LineTo(X + 3, Y + 8);
    MoveTo(X + 4, Y);
    LineTo(X + 4, Y + 8);
    MoveTo(X + 2, Y + 8);
    LineTo(X + 6, Y + 8);
  end;
end;

procedure TbsSkinFontComboBox.Reset;
var
  SaveName: TFontName;
begin
  if HandleAllocated then begin
    FUpdate := True;
    try
      SaveName := FontName;
      PopulateList;
      FontName := SaveName;
    finally
      FUpdate := False;
      if FontName <> SaveName
      then
        begin
          if not (csReading in ComponentState) then
          if not FUpdate and Assigned(FOnChange) then FOnChange(Self);
        end;
    end;
  end;
end;

procedure TbsSkinFontComboBox.WMFontChange(var Message: TMessage);
begin
  inherited;
  Reset;
end;

procedure TbsSkinFontComboBox.SetFontName(const NewFontName: TFontName);
var
  Item: Integer;
begin
  if FontName <> NewFontName then begin
    if not (csLoading in ComponentState) then begin
      HandleNeeded;
      { change selected item }
      for Item := 0 to Items.Count - 1 do
        if AnsiCompareText(Items[Item], NewFontName) = 0 then begin
          ItemIndex := Item;
          //
          if not (csReading in ComponentState) then
            if not FUpdate and Assigned(FOnChange) then FOnChange(Self);
          //
          Exit;
        end;
      if Style = bscbFixedStyle then ItemIndex := -1
      else Text := NewFontName;
    end
    else inherited Text := NewFontName;
    //
    if not (csReading in ComponentState) then
    if not FUpdate and Assigned(FOnChange) then FOnChange(Self);
    //
  end;
end;

function TbsSkinFontComboBox.GetFontName: TFontName;
begin
  Result := inherited Text;
end;

function TbsSkinFontComboBox.GetTrueTypeOnly: Boolean;
begin
  Result := foTrueTypeOnly in FOptions;
end;

procedure TbsSkinFontComboBox.SetOptions;
begin
  if Value <> Options then begin
    FOptions := Value;
    Reset;
  end;
end;

procedure TbsSkinFontComboBox.SetTrueTypeOnly(Value: Boolean);
begin
  if Value <> TrueTypeOnly then begin
    if Value then FOptions := FOptions + [foTrueTypeOnly]
    else FOptions := FOptions - [foTrueTypeOnly];
    Reset;
  end;
end;

procedure TbsSkinFontComboBox.SetDevice;
begin
  if Value <> FDevice then begin
    FDevice := Value;
    Reset;
  end;
end;

procedure TbsSkinFontComboBox.SetUseFonts(Value: Boolean);
begin
  if Value <> FUseFonts then begin
    FUseFonts := Value;
    Invalidate;
  end;
end;

procedure TbsSkinFontComboBox.DrawCBFontItem;
var
  FName: array[0..255] of Char;
  R: TRect;
begin
  R := TextRect;
  R.Left := R.Left + 2;
  with Cnvs do
  begin
    StrPCopy(FName, Items[Index]);
    BSDrawText2(Cnvs, FName, R);
  end;
end;

procedure TbsSkinFontComboBox.DrawLBFontItem;
var
  FName: array[0..255] of Char;
  R: TRect;
  X, Y: Integer;
begin
  R := TextRect;
  if (Integer(Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0
  then
    begin
      X := TextRect.Left;
      Y := TextRect.Top + RectHeight(TextRect) div 2 - 7;
      DrawTT(Cnvs, X, Y, clGray);
      DrawTT(Cnvs, X + 4, Y + 4, clBlack);
    end;

  Inc(R.Left, 15);
  with Cnvs do
  begin
    Font.Name := Items[Index];
    Font.Style := [];
    StrPCopy(FName, Items[Index]);
    BSDrawText2(Cnvs, Items[Index], R);
  end;
end;

procedure TbsSkinFontComboBox.PopulateList;
var
  DC: HDC;
  Proc: TFarProc;
  OldItemIndex: Integer;
begin
  if not HandleAllocated then Exit;
  OldItemIndex := ItemIndex;
  Items.BeginUpdate;
  try
    Items.Clear;
    DC := GetDC(0);
    try
      if (FDevice = fdScreen) or (FDevice = fdBoth) then
        EnumFontFamilies(DC, nil, @EnumFontsProc, Longint(Self));
      if (FDevice = fdPrinter) or (FDevice = fdBoth) then
      try
        EnumFontFamilies(Printer.Handle, nil, @EnumFontsProc, Longint(Self));
      except
        { skip any errors }
      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    Items.EndUpdate;
  end;
  ItemIndex := OldItemIndex;
end;

procedure TbsSkinFontComboBox.CreateWnd;
var
  OldFont: TFontName;
begin
  OldFont := FontName;
  inherited CreateWnd;
  FUpdate := True;
  try
    PopulateList;
    inherited Text := '';
    SetFontName(OldFont);
  finally
    FUpdate := False;
  end;
end;

// ==================== TbsSkinColorComboBox ======================= //
const
  SColorBoxCustomCaption = 'Custom...';
  NoColorSelected = TColor($FF000000);
  StandardColorsCount = 16;
  ExtendedColorsCount = 4;

constructor TbsSkinColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := bscbFixedStyle;
  FExStyle := [bscbStandardColors, bscbExtendedColors, bscbSystemColors];
  FSelectedColor := clBlack;
  FDefaultColorColor := clBlack;
  FNoneColorColor := clBlack;
  OnListBoxDrawItem := DrawColorItem;
  OnComboBoxDrawItem := DrawColorItem;
  OnCloseUp := OnLBCloseUp;
  FShowNames := True;
end;

procedure TbsSkinColorComboBox.SetShowNames(Value: Boolean);
begin
  FShowNames := Value;
  RePaint;
end;

procedure TbsSkinColorComboBox.DrawColorItem;
var
  R: TRect;
  MarkerRect: TRect;
begin
  if FShowNames
  then
    MarkerRect := Rect(TextRect.Left + 2, TextRect.Top + 2,
      TextRect.Left + RectHeight(TextRect) - 2, TextRect.Bottom - 2)
  else
    MarkerRect := Rect(TextRect.Left + 2, TextRect.Top + 2,
      TextRect.Right - 2, TextRect.Bottom - 2);

  with Cnvs do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Colors[Index];
    FillRect(MarkerRect);
    Brush.Style := bsClear;
  end;

  if FShowNames
  then
    begin
      R := TextRect;
      R := Rect(R.Left + 5 + RectWidth(MarkerRect), R.Top, R.Right - 2, R.Bottom);
      BSDrawText2(Cnvs, FListBox.Items[Index], R);
    end;
end;

procedure TbsSkinColorComboBox.OnLBCloseUp;
begin
  if (bscbCustomColor in ExStyle) and (ItemIndex = 0) then
   PickCustomColor;
end;

function TbsSkinColorComboBox.PickCustomColor: Boolean;
var
  LColor: TColor;
begin
  with TbsSkinColorDialog.Create(nil) do
    try
      SkinData := Self.SkinData;
      CtrlSkinData := Self.SkinData;
      LColor := ColorToRGB(TColor(Items.Objects[0]));
      Color := LColor;
      Result := Execute;
      if Result then
      begin
        Items.Objects[0] := TObject(Color);
        Self.Invalidate;
        if Assigned(FOnClick) then FOnClick(Self);
        if Assigned(FOnChange) then FOnChange(Self);
      end;
    finally
      Free;
    end;
end;

procedure TbsSkinColorComboBox.KeyDown;
begin
  if (bscbCustomColor in ExStyle) and (Key = VK_RETURN) and (ItemIndex = 0)
  then
  begin
    PickCustomColor;
    Key := 0;
  end;
  inherited;
end;

procedure TbsSkinColorComboBox.CreateWnd;
begin
  inherited;
  PopulateList;
end;

procedure TbsSkinColorComboBox.Loaded;
var
  S: String;
begin
  inherited;
  if (bscbCustomColor in ExStyle) and
     (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
  then
    begin
      S := SkinData.ResourceStrData.GetResStr('CUSTOMCOLOR');
      if S = '' then S := BS_CUSTOMCOLOR;
      Items[0] := S;
    end;
end;


procedure TbsSkinColorComboBox.SetDefaultColorColor(const Value: TColor);
begin
  if Value <> FDefaultColorColor then
  begin
    FDefaultColorColor := Value;
    Invalidate;
  end;
end;

procedure TbsSkinColorComboBox.SetNoneColorColor(const Value: TColor);
begin
  if Value <> FNoneColorColor then
  begin
    FNoneColorColor := Value;
    Invalidate;
  end;
end;

procedure TbsSkinColorComboBox.ColorCallBack(const AName: String);
var
  I, LStart: Integer;
  LColor: TColor;
  LName: string;
begin
  LColor := StringToColor(AName);
  if bscbPrettyNames in ExStyle then
  begin
    if Copy(AName, 1, 2) = 'cl' then
      LStart := 3
    else
      LStart := 1;
    LName := '';
    for I := LStart to Length(AName) do
    begin
      case AName[I] of
        'A'..'Z':
          if LName <> '' then
            LName := LName + ' ';
      end;
      LName := LName + AName[I];
    end;
  end
  else
    LName := AName;
  Items.AddObject(LName, TObject(LColor));
end;

procedure TbsSkinColorComboBox.SetSelected(const AColor: TColor);
var
  I: Integer;
begin
  if HandleAllocated and (FListBox <> nil) then
  begin
    I := FListBox.Items.IndexOfObject(TObject(AColor));
    if (I = -1) and (bscbCustomColor in ExStyle) and (AColor <> NoColorSelected) then
    begin
      Items.Objects[0] := TObject(AColor);
      I := 0;
    end;
    ItemIndex := I;
  end;
  FSelectedColor := AColor;
end;

procedure TbsSkinColorComboBox.PopulateList;
  procedure DeleteRange(const AMin, AMax: Integer);
  var
    I: Integer;
  begin
    for I := AMax downto AMin do
      Items.Delete(I);
  end;
  procedure DeleteColor(const AColor: TColor);
  var
    I: Integer;
  begin
    I := Items.IndexOfObject(TObject(AColor));
    if I <> -1 then
      Items.Delete(I);
  end;
var
  LSelectedColor, LCustomColor: TColor;
  S: String;
begin
  if HandleAllocated then
  begin
    Items.BeginUpdate;
    try
      LCustomColor := clBlack;
      if (bscbCustomColor in ExStyle) and (Items.Count > 0) then
        LCustomColor := TColor(Items.Objects[0]);
      LSelectedColor := FSelectedColor;
      Items.Clear;
      GetColorValues(ColorCallBack);
      if not (bscbIncludeNone in ExStyle) then
        DeleteColor(clNone);
      if not (bscbIncludeDefault in ExStyle) then
        DeleteColor(clDefault);
      if not (bscbSystemColors in ExStyle) then
        DeleteRange(StandardColorsCount + ExtendedColorsCount, Items.Count - 1);
      if not (bscbExtendedColors in ExStyle) then
        DeleteRange(StandardColorsCount, StandardColorsCount + ExtendedColorsCount - 1);
      if not (bscbStandardColors in ExStyle) then
        DeleteRange(0, StandardColorsCount - 1);
      if bscbCustomColor in ExStyle
      then
        begin
          if (SkinData <> nil) and
             (SkinData.ResourceStrData <> nil)
          then
            S := SkinData.ResourceStrData.GetResStr('CUSTOMCOLOR')
          else
            S := BS_CUSTOMCOLOR;
          Items.InsertObject(0, S, TObject(LCustomColor));
        end;
      Self.Selected := LSelectedColor;
    finally
      Items.EndUpdate;
      FNeedToPopulate := False;
    end;
  end
  else
    FNeedToPopulate := True;
end;

procedure TbsSkinColorComboBox.SetExStyle(AStyle: TbsColorBoxStyle);
begin
  FExStyle := AStyle;
  Enabled := ([bscbStandardColors, bscbExtendedColors, bscbSystemColors, bscbCustomColor] * FExStyle) <> [];
  PopulateList;
  if (Items.Count > 0) and (ItemIndex = -1) then ItemIndex := 0;
end;

function TbsSkinColorComboBox.GetColor(Index: Integer): TColor;
begin
  Result := TColor(Items.Objects[Index]);
end;

function TbsSkinColorComboBox.GetColorName(Index: Integer): string;
begin
  Result := Items[Index];
end;

function TbsSkinColorComboBox.GetSelected: TColor;
begin
  if HandleAllocated then
    if ItemIndex <> -1 then
      Result := Colors[ItemIndex]
    else
      Result := NoColorSelected
  else
    Result := FSelectedColor;
end;

//================= check listbox ===================//

function MakeSaveState(State: TCheckBoxState; Disabled: Boolean): TObject;
begin
  Result := TObject((Byte(State) shl 16) or Byte(Disabled));
end;

function GetSaveState(AObject: TObject): TCheckBoxState;
begin
  Result := TCheckBoxState(Integer(AObject) shr 16);
end;

function GetSaveDisabled(AObject: TObject): Boolean;
begin
  Result := Boolean(Integer(AObject) and $FF);
end;

type

TbsCheckListBoxDataWrapper = class
private
  FData: LongInt;
  FState: TCheckBoxState;
  FDisabled: Boolean;
  procedure SetChecked(Check: Boolean);
  function GetChecked: Boolean;
public
  class function GetDefaultState: TCheckBoxState;
  property Checked: Boolean read GetChecked write SetChecked;
  property State: TCheckBoxState read FState write FState;
  property Disabled: Boolean read FDisabled write FDisabled;
end;

procedure TbsCheckListBoxDataWrapper.SetChecked(Check: Boolean);
begin
  if Check then FState := cbChecked else FState := cbUnchecked;
end;

function TbsCheckListBoxDataWrapper.GetChecked: Boolean;
begin
  Result := FState = cbChecked;
end;

class function TbsCheckListBoxDataWrapper.GetDefaultState: TCheckBoxState;
begin
  Result := cbUnchecked;
end;

constructor TbsCheckListBox.Create;
begin
  inherited;
  FAllowGrayed := False;
  SkinListBox := nil;
  Ctl3D := False;
  BorderStyle := bsNone;
  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks];
  FWrapperList := TList.Create;
  {$IFDEF VER130}
  FAutoComplete := True;
  {$ENDIF}
end;

destructor TbsCheckListBox.Destroy;
var
  I: Integer;
begin
  for I := 0 to FWrapperList.Count - 1 do
    TbsCheckListBoxDataWrapper(FWrapperList[I]).Free;
  FWrapperList.Free;
  if FSaveStates <>  nil then FSaveStates.Free;
  inherited;
end;

procedure TbsCheckListBox.SetItemEnabled(Index: Integer; const Value: Boolean);
begin
  if Value <> GetItemEnabled(Index) then
  begin
    TbsCheckListBoxDataWrapper(GetWrapper(Index)).Disabled := not Value;
    InvalidateCheck(Index);
  end;
end;

function TbsCheckListBox.GetItemEnabled(Index: Integer): Boolean;
begin
  if HaveWrapper(Index) then
    Result := not TbsCheckListBoxDataWrapper(GetWrapper(Index)).Disabled
  else
    Result := True;
end;

procedure TbsCheckListBox.CMSENCPaint(var Message: TMessage);
begin
  Message.Result := SE_RESULT;
end;

procedure TbsCheckListBox.DrawTabbedString(S: String; TW: TStrings; C: TCanvas; R: TRect; Offset: Integer);

function GetNum(AText: String): Integer;
const
  EditChars = '01234567890';
var
  i: Integer;
  S: String;
  IsNum: Boolean;
begin
  S := EditChars;
  Result := 0;
  if (AText = '') then Exit;
  IsNum := True;
  for i := 1 to Length(AText) do
  begin
    if Pos(AText[i], S) = 0
    then
      begin
        IsNum := False;
        Break;
      end;
  end;
  if IsNum then Result := StrToInt(AText) else Result := 0;
end;

var
  S1: String;
  i, Max: Integer;
  TWValue: array[0..9] of Integer;
  X, Y: Integer;
begin
  for i := 0 to TW.Count - 1 do
  begin
    if i < 10 then TWValue[i] := GetNum(TW[i]);
  end;
  Max := TW.Count;
  if Max > 10 then Max := 10;
  X := R.Left + Offset + 2;
  Y := R.Top + RectHeight(R) div 2 - C.TextHeight(S) div 2;
  //
  if (C.Font.Height div 2) <> (C.Font.Height / 2) then Dec(Y, 1);
  //
  TabbedTextOut(C.Handle, X, Y, PChar(S), Length(S), Max, TWValue, 0);
end;

procedure TbsCheckListBox.WMNCCALCSIZE;
begin
end;

procedure TbsCheckListBox.WMNCHITTEST(var Message: TWMNCHITTEST);
begin
  Message.Result := HTCLIENT;
end;

procedure TbsCheckListBox.CMEnter;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxEnter;
  inherited;
end;

procedure TbsCheckListBox.CMExit;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxExit;
  inherited;
end;

procedure TbsCheckListBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxMouseUp(Button, Shift, X, Y);
  inherited;
end;

procedure TbsCheckListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxMouseMove(Shift, X, Y);
  inherited;
end;

procedure TbsCheckListBox.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxKeyUp(Key, Shift);
  inherited;
  if (Key = 32) and (ItemIndex <> -1)
  then
    begin
      ToggleClickCheck(ItemIndex);
    end;
end;

procedure TbsCheckListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SkinListBox <> nil then SkinListBox.ListBoxKeyDown(Key, Shift);
  inherited;
end;

procedure TbsCheckListBox.Click;
begin
  if SkinListBox <> nil then SkinListBox.ListBoxClick;
  inherited;
end;
procedure TbsCheckListBox.PaintBGWH;
var
  X, Y, XCnt, YCnt, XO, YO, w, h, w1, h1: Integer;
  Buffer: TBitMap;
begin
  w1 := AW;
  h1 := AH;
  Buffer := TBitMap.Create;
  Buffer.Width := w1;
  Buffer.Height := h1;
  with Buffer.Canvas, SkinListBox do
  begin
    w := RectWidth(ClRect);
    h := RectHeight(ClRect);
    XCnt := w1 div w;
    YCnt := h1 div h;
    for X := 0 to XCnt do
    for Y := 0 to YCnt do
    begin
      if X * w + w > w1 then XO := X * w + w - w1 else XO := 0;
      if Y * h + h > h1 then YO := Y * h + h - h1 else YO := 0;
       CopyRect(Rect(X * w, Y * h, X * w + w - XO, Y * h + h - YO),
                Picture.Canvas,
                Rect(SkinRect.Left + ClRect.Left, SkinRect.Top + ClRect.Top,
                SkinRect.Left + ClRect.Right - XO,
                SkinRect.Top + ClRect.Bottom - YO));
    end;
  end;
  Cnvs.Draw(AX, AY, Buffer);
  Buffer.Free;
end;

function TbsCheckListBox.GetItemData;
begin
  Result := 0;
  if HaveWrapper(Index) then
    Result := TbsCheckListBoxDataWrapper(GetWrapper(Index)).FData;
end;

procedure TbsCheckListBox.SetItemData;
var
  Wrapper: TbsCheckListBoxDataWrapper;
  SaveState: TObject;
begin
  Wrapper := TbsCheckListBoxDataWrapper(GetWrapper(Index));
  Wrapper.FData := AData;
  if FSaveStates <> nil then
    if FSaveStates.Count > 0 then
    begin
      SaveState := FSaveStates[0];
      Wrapper.FState := GetSaveState(SaveState);
      Wrapper.FDisabled := GetSaveDisabled(SaveState);
      FSaveStates.Delete(0);
    end;
end;


function TbsCheckListBox.GetSkinDisabledColor;
begin
  Result := clGray;
end;

procedure TbsCheckListBox.ResetContent;
var
  I: Integer;
  LIndex: Integer;
  LWrapper: TbsCheckListBoxDataWrapper;
begin
  for I := 0 to Items.Count - 1 do
    if HaveWrapper(I) then
    begin
      LWrapper := TbsCheckListBoxDataWrapper(GetWrapper(I));
      LIndex := FWrapperList.IndexOf(LWrapper);
      if LIndex <> -1 then
        FWrapperList.Delete(LIndex);
      LWrapper.Free;
    end;
  inherited;
end;

procedure TbsCheckListBox.CreateWnd;
begin
  inherited CreateWnd;
  if FSaveStates <> nil then
  begin
    FSaveStates.Free;
    FSaveStates := nil;
  end;
end;

procedure TbsCheckListBox.DestroyWnd;
var
  I: Integer;
begin
  if Items.Count > 0 then
  begin
    FSaveStates := TList.Create;
    for I := 0 to Items.Count -1 do
      FSaveStates.Add(MakeSaveState(State[I], not ItemEnabled[I]));
  end;
  inherited DestroyWnd;
end;

procedure TbsCheckListBox.DeleteString(Index: Integer);
var
  LIndex: Integer;
  LWrapper: TbsCheckListBoxDataWrapper;
begin
  if HaveWrapper(Index) then
  begin
    LWrapper := TbsCheckListBoxDataWrapper(GetWrapper(Index));
    LIndex := FWrapperList.IndexOf(LWrapper);
    if LIndex <> -1 then
      FWrapperList.Delete(LIndex);
    LWrapper.Free;
  end;
  inherited;
end;

procedure TbsCheckListBox.KeyPress(var Key: Char);
  {$IFDEF VER130}
  procedure FindString;
  var
    Idx: Integer;
  begin
    if Length(FFilter) = 1
    then
      Idx := SendMessage(Handle, LB_FINDSTRING, ItemIndex, LongInt(PChar(FFilter)))
    else
      Idx := SendMessage(Handle, LB_FINDSTRING, -1, LongInt(PChar(FFilter)));
    if Idx <> LB_ERR then
    begin
      if MultiSelect then
      begin
        SendMessage(Handle, LB_SELITEMRANGE, 1, MakeLParam(Idx, Idx))
      end;
      ItemIndex := Idx;
      Click;
    end;
    if not Ord(Key) in [VK_RETURN, VK_BACK, VK_ESCAPE] then
      Key := #0;
  end;
  {$ENDIF}

begin
  inherited;
  if SkinListBox <> nil then SkinListBox.ListBoxKeyPress(Key);
  {$IFDEF VER130}
  if not FAutoComplete then Exit;
  if GetTickCount - FLastTime >= 500 then
    FFilter := '';
  FLastTime := GetTickCount;
  if Ord(Key) <> VK_BACK
  then
    begin
      FFilter := FFilter + Key;
      Key := #0;
    end
  else
    Delete(FFilter, Length(FFilter), 1);
  if Length(FFilter) > 0 then
    FindString
  else
  begin
    ItemIndex := 0;
    Click;
  end;
  {$ENDIF}
end;

procedure TbsCheckListBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);

function InCheckArea(IR: TRect): Boolean;
var
  R, R1: TRect;
  OX: Integer;
begin
  R := SkinListBox.ItemTextRect;
  OX :=  RectWidth(IR) - RectWidth(SkinListBox.SItemRect);
  Inc(R.Right, OX);
  R1 := SkinListBox.ItemCheckRect;
  if R1.Left >= SkinListBox.ItemTextRect.Right
  then OffsetRect(R1, OX, 0);
  OffsetRect(R1, IR.Left, IR.Top);

  if SkinListBox.UseSkinItemHeight = False
  then
    Inc(R1.Bottom, RectHeight(IR) - RectHeight(SkinListBox.SItemRect));

  Result := PtInRect(R1, Point(X, Y));
end;

var
  Index: Integer;
begin
  inherited;
  Index := ItemAtPos(Point(X,Y),True);
  if (Index <> -1) and GetItemEnabled(Index)
  then 
    if (SkinListBox <> nil) and (SkinListBox.FIndex <> -1)
    then
      begin
        if InCheckArea(ItemRect(Index)) then ToggleClickCheck(Index);
      end
    else
      begin
        if X - ItemRect(Index).Left < 20 then ToggleClickCheck(Index);
      end;
  if SkinListBox <> nil then SkinListBox.ListBoxMouseDown(Button, Shift, X, Y);    
end;

procedure TbsCheckListBox.ToggleClickCheck;
var
  State: TCheckBoxState;
begin
  if (Index >= 0) and (Index < Items.Count) and GetItemEnabled(Index) then
  begin
    State := Self.State[Index];

    case State of
      cbUnchecked:
        if AllowGrayed then State := cbGrayed else State := cbChecked;
      cbChecked: State := cbUnchecked;
      cbGrayed: State := cbChecked;
    end;

    Self.State[Index] := State;
    if Assigned(FOnClickCheck) then FOnClickCheck(Self);
  end;
end;

procedure TbsCheckListBox.InvalidateCheck(Index: Integer);
var
  R: TRect;
begin
  R := ItemRect(Index);
  InvalidateRect(Handle, @R, not (csOpaque in ControlStyle));
  UpdateWindow(Handle);
end;

function TbsCheckListBox.GetWrapper(Index: Integer): TObject;
begin
  Result := ExtractWrapper(Index);
  if Result = nil then
    Result := CreateWrapper(Index);
end;

function TbsCheckListBox.ExtractWrapper(Index: Integer): TObject;
begin
  Result := TbsCheckListBoxDataWrapper(inherited GetItemData(Index));
  if LB_ERR = Integer(Result) then
    raise EListError.CreateFmt('List index out of bounds (%d)', [Index]);
  if (Result <> nil) and (not (Result is TbsCheckListBoxDataWrapper)) then
    Result := nil;
end;

function TbsCheckListBox.CreateWrapper(Index: Integer): TObject;
begin
  FWrapperList.Expand;
  Result := TbsCheckListBoxDataWrapper.Create;
  FWrapperList.Add(Result);
  {$IFDEF VER230_UP}
  inherited SetItemData(Index, TListBoxItemData(Result));
  {$ELSE}
  inherited SetItemData(Index, LongInt(Result));
  {$ENDIF}
end;

function TbsCheckListBox.HaveWrapper(Index: Integer): Boolean;
begin
  Result := ExtractWrapper(Index) <> nil;
end;

procedure TbsCheckListBox.SetChecked(Index: Integer; Checked: Boolean);
begin
  if Checked <> GetChecked(Index) then
  begin
    TbsCheckListBoxDataWrapper(GetWrapper(Index)).SetChecked(Checked);
    InvalidateCheck(Index);
  end;
end;

procedure TbsCheckListBox.SetState(Index: Integer; AState: TCheckBoxState);
begin
  if AState <> GetState(Index) then
  begin
    TbsCheckListBoxDataWrapper(GetWrapper(Index)).State := AState;
    InvalidateCheck(Index);
  end;
end;

function TbsCheckListBox.GetChecked(Index: Integer): Boolean;
begin
  if HaveWrapper(Index) then
    Result := TbsCheckListBoxDataWrapper(GetWrapper(Index)).GetChecked
  else
    Result := False;
end;

function TbsCheckListBox.GetState(Index: Integer): TCheckBoxState;
begin
  if HaveWrapper(Index) then
    Result := TbsCheckListBoxDataWrapper(GetWrapper(Index)).State
  else
    Result := TbsCheckListBoxDataWrapper.GetDefaultState;
end;

function TbsCheckListBox.GetState1;
begin
  Result := [];
  if AItemID = ItemIndex
  then
    begin
      Result := Result + [odSelected];
      if Focused then Result := Result + [odFocused];
    end
  else
    if SelCount > 0
    then
      if Selected[AItemID] then Result := Result + [odSelected];
end;

procedure TbsCheckListBox.PaintBG(DC: HDC);
var
  C: TControlCanvas;
begin
  C := TControlCanvas.Create;
  C.Handle := DC;
  SkinListBox.GetSkinData;
  if SkinListBox.FIndex <> -1
  then
    PaintBGWH(C, Width, Height, 0, 0)
  else
    with C do
    begin
      C.Brush.Color := clWindow;
      FillRect(Rect(0, 0, Width, Height));
    end;
  C.Handle := 0;
  C.Free;
end;

procedure TbsCheckListBox.PaintColumnsList(DC: HDC);
var
  C: TCanvas;
  i, j, DrawCount: Integer;
  IR: TRect;
begin
  C := TCanvas.Create;
  C.Handle := DC;
  DrawCount := (Height div ItemHeight) * Columns;
  i := TopIndex;
  j := i + DrawCount;
  if j > Items.Count - 1 then j := Items.Count - 1;
  if Items.Count > 0
  then
    for i := TopIndex to j do
    begin
      IR := ItemRect(i);
      if SkinListBox.FIndex <> -1
      then
        begin
          if SkinListBox.UseSkinItemHeight
          then
            DrawSkinItem(C, i, IR, GetState1(i))
          else
            DrawStretchSkinItem(C, i, IR, GetState1(i));
        end
      else
        DrawDefaultItem(C, i, IR, GetState1(i));
    end;
  C.Free;
end;

procedure TbsCheckListBox.PaintList(DC: HDC);
var
  C: TCanvas;
  i, j, k, DrawCount: Integer;
  IR: TRect;
begin
  C := TCanvas.Create;
  C.Handle := DC;
  DrawCount := Height div ItemHeight;
  i := TopIndex;
  j := i + DrawCount;
  if j > Items.Count - 1 then j := Items.Count - 1;
  k := 0;
  if Items.Count > 0
  then
    for i := TopIndex to j do
    begin
      IR := ItemRect(i);
      if SkinListBox.FIndex <> -1
      then
        begin
          if SkinListBox.UseSkinItemHeight
          then
            DrawSkinItem(C, i, IR, GetState1(i))
          else
            DrawStretchSkinItem(C, i, IR, GetState1(i));
        end
      else
        DrawDefaultItem(C, i, IR, GetState1(i));
      k := IR.Bottom;
    end;
  if k < Height
  then
    begin
      SkinListBox.GetSkinData;
      if SkinListBox.FIndex <> -1
      then
        PaintBGWH(C, Width, Height - k, 0, k)
      else
        with C do
        begin
          C.Brush.Color := clWindow;
          FillRect(Rect(0, k, Width, Height));
        end;
    end;
  C.Free;
end;

procedure TbsCheckListBox.PaintWindow;
var
  SaveIndex: Integer;
begin
  if (Width <= 0) or (Height <=0) then Exit;
  SaveIndex := SaveDC(DC);
  try
    if Columns > 0
    then
      PaintColumnsList(DC)
    else
      PaintList(DC);
  finally
    RestoreDC(DC, SaveIndex);
  end;
end;

procedure TbsCheckListBox.WMPaint;
begin
  PaintHandler(Msg);
end;

procedure TbsCheckListBox.WMEraseBkgnd;
begin
  PaintBG(Message.DC);
  Message.Result := 1;
end;

procedure TbsCheckListBox.DrawDefaultItem;
var
  Buffer: TBitMap;
  R, R1, CR: TRect;
  AState: TCheckBoxState;
  IIndex, IX, IY: Integer;
  IEnabled: Boolean;
begin
  if (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  AState := GetState(itemID);
  IEnabled := GetItemEnabled(itemID);
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(rcItem);
  Buffer.Height := RectHeight(rcItem);
  R := Rect(20, 0, Buffer.Width, Buffer.Height);
  with Buffer.Canvas do
  begin
    Font.Name := SkinListBox.Font.Name;
    Font.Style := SkinListBox.Font.Style;
    Font.Height := SkinListBox.Font.Height;
    if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
    else
      Font.Charset := SkinListBox.DefaultFont.Charset;
    if odSelected in State1
    then
      begin
        Brush.Color := clHighLight;
        Font.Color := clHighLightText;
      end
    else
      begin
        Brush.Color := clWindow;
        Font.Color := SkinListBox.Font.Color;
      end;
    if not IEnabled then Font.Color := clGrayText;
    FillRect(R);
  end;

  R1 := Rect(R.Left + 2, R.Top, R.Right - 2, R.Bottom);

  CR := Rect(3, Buffer.Height div 2 - 6, 16, Buffer.Height div 2 + 7);
  Frame3D(Buffer.Canvas, CR, clBtnShadow, clBtnShadow, 1);

  if AState = cbGrayed
  then
    DrawCheckImage(Buffer.Canvas, 6, Buffer.Height div 2 - 4, clGrayText)
  else
  if IEnabled
  then
    begin
      if AState = cbChecked
      then
        DrawCheckImage(Buffer.Canvas, 6, Buffer.Height div 2 - 4, clWindowText);
    end
  else
    begin
      if AState = cbChecked
      then
        DrawCheckImage(Buffer.Canvas, 6, Buffer.Height div 2 - 4, clGrayText);
    end;

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID, Buffer.Width, Buffer.Height,
    R1, State1)
  else
    begin
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R1.Left;
              IY := R1.Top + RectHeight(R1) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas, IX, IY, IIndex);
            end;
          Inc(R1.Left, SkinListBox.Images.Width + 2);
        end;
      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R1, 0);
        end
      else
        BSDrawText2(Buffer.Canvas, Items[ItemID], R1);
    end;
  if odFocused in State1 then DrawSkinFocusRect(Buffer.Canvas, R);
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;

procedure TbsCheckListBox.SkinDrawGrayedCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
var
  B: TBitMap;
  Buffer: TbsEffectBmp;
  R: TRect;
begin
  B := TBitMap.Create;
  B.Width := RectWidth(IR);
  B.Height := RectHeight(IR);
  B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), Cnvs, IR);
  Buffer := TbsEffectBmp.CreateFromhWnd(B.Handle);
  Buffer.ChangeBrightness(0.5);
  Buffer.Draw(B.Canvas.Handle, 0, 0);
  Buffer.Free;
  B.Transparent := True;
  DestCnvs.Draw(X, Y, B);
  B.Free;
end;

procedure TbsCheckListBox.SkinDrawDisableCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
var
  B, B2: TBitMap;
  Buffer, Buffer2: TbsEffectBmp;
  R: TRect;
begin
  B := TBitMap.Create;
  B.Width := RectWidth(IR);
  B.Height := RectHeight(IR);
  B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), Cnvs, IR);
  B2 := TBitMap.Create;
  B2.Width := B.Width;
  B2.Height := B.Height;
  B2.Canvas.CopyRect(Rect(0, 0, B2.Width, B2.Height), DestCnvs,
    Rect(X, Y, X + B2.Width, Y + B2.Height));

  Buffer := TbsEffectBmp.CreateFromhWnd(B.Handle);
  Buffer2 := TbsEffectBmp.CreateFromhWnd(B2.Handle);

  Buffer2.Morph(Buffer, 0.4);

  Buffer2.Draw(B.Canvas.Handle, 0, 0);

  Buffer.Free;
  Buffer2.Free;
  B.Transparent := True;
  DestCnvs.Draw(X, Y, B);
  B.Free;
  B2.Free;
end;

procedure TbsCheckListBox.SkinDrawCheckImage(X, Y: Integer; Cnvs: TCanvas; IR: TRect; DestCnvs: TCanvas);
var
  B: TBitMap;
begin
  B := TBitMap.Create;
  B.Width := RectWidth(IR);
  B.Height := RectHeight(IR);
  B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), Cnvs, IR);
  B.Transparent := True;
  DestCnvs.Draw(X, Y, B);
  B.Free;
end;

procedure TbsCheckListBox.DrawSkinItem;
var
  Buffer: TBitMap;
  R, R1: TRect;
  W, H: Integer;
  OX: Integer;
  AState: TCheckBoxState;
  cw, ch, cx, cy: Integer;
  IIndex, IX, IY: Integer;
  IEnabled: Boolean;
begin
  if (SkinListBox.Picture = nil) or (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  AState := GetState(itemID);
  IEnabled := GetItemEnabled(itemID);
  Buffer := TBitMap.Create;
  with SkinListBox do
  begin
    W := RectWidth(rcItem);
    H := RectHeight(SItemRect);
    Buffer.Width := W;
    Buffer.Height := H;
    if odFocused in State1
    then
      begin
        if not (odSelected in State1)
        then
          begin
            CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
              SItemRect, W, H, StretchEffect);
            R := Rect(0, 0, Buffer.Width, Buffer.Height);
            DrawSkinFocusRect(Buffer.Canvas, R);
          end
        else
          CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
            FocusItemRect, W, H, StretchEffect)
      end
    else
    if odSelected in State1
    then
      CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
      ActiveItemRect, W, H, StretchEffect)
    else
      CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
      SItemRect, W, H, False);
    R := ItemTextRect;
    OX :=  W - RectWidth(SItemRect);
    Inc(R.Right, OX);
    R1 := ItemCheckRect;

    if R1.Left >= ItemTextRect.Right then OffsetRect(R1, OX, 0);
    cw := RectWidth(CheckImageRect);
    ch := RectHeight(CheckImageRect);
    cx := R1.Left + RectWidth(R1) div 2;
    cy := R1.Top + RectHeight(R1) div 2;
    R1 := Rect(cx - cw div 2, cy - ch div 2,
               cx - cw div 2 + cw, cy - ch div 2 + ch);
   if (AState = cbGrayed) and AllowGrayed
   then
     begin
       SkinDrawGrayedCheckImage(R1.Left, R1.Top, Picture.Canvas,
         CheckImageRect, Buffer.Canvas);
     end
   else
   if IEnabled
   then
     begin
       if AState = cbChecked
       then
         SkinDrawCheckImage(R1.Left, R1.Top, Picture.Canvas, CheckImageRect, Buffer.Canvas)
       else
         SkinDrawCheckImage(R1.Left, R1.Top, Picture.Canvas, UnCheckImageRect, Buffer.Canvas);
     end
    else
      begin
        if AState = cbChecked
        then
          SkinDrawDisableCheckImage(R1.Left, R1.Top, Picture.Canvas,
           CheckImageRect, Buffer.Canvas)
        else
          SkinDrawDisableCheckImage(R1.Left, R1.Top, Picture.Canvas,
           UnCheckImageRect, Buffer.Canvas);
      end;
  end;


  with Buffer.Canvas do
  begin
    if SkinListBox.UseSkinFont
    then
      begin
        Font.Name := SkinListBox.FontName;
        Font.Style := SkinListBox.FontStyle;
        Font.Height := SkinListBox.FontHeight;
      end
    else
      Font.Assign(SkinListBox.DefaultFont);

    if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := SkinListBox.DefaultFont.CharSet;

    if odFocused in State1
    then
      begin
        if not (odSelected in State1)
        then
          Font.Color := SkinListBox.FontColor
        else
          Font.Color := SkinListBox.FocusFontColor;
      end
    else
    if odSelected in State1
    then
      Font.Color := SkinListBox.ActiveFontColor
    else
      Font.Color := SkinListBox.FontColor;

    if not IEnabled then Font.Color := GetSkinDisabledColor;

    Brush.Style := bsClear;
  end;

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID, Buffer.Width, Buffer.Height,
    R, State1)
  else
    begin
      if (odFocused in State1) and SkinListBox.ShowFocus
      then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := SkinListBox.SkinData.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R.Left;
              IY := R.Top + RectHeight(R) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas, IX, IY, IIndex);
            end;
          Inc(R.Left, SkinListBox.Images.Width + 2);
        end;

      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R, 0);
        end
      else
        BSDrawText2(Buffer.Canvas, Items[ItemID], R);
    end;
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;

procedure TbsCheckListBox.DrawStretchSkinItem;
var
  Buffer: TBitMap;
  R, R1: TRect;
  W, H: Integer;
  OX, OY: Integer;
  AState: TCheckBoxState;
  Offset, cw, ch, cx, cy: Integer;
  IIndex, IX, IY: Integer;
  IEnabled: Boolean;
begin
  if (SkinListBox.Picture = nil) or (ItemID < 0) or (ItemID > Items.Count - 1) then Exit;
  AState := GetState(itemID);
  IEnabled := GetItemEnabled(itemID);
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(rcItem);
  Buffer.Height := RectHeight(rcItem);

  with SkinListBox do
  begin
    W := RectWidth(rcItem);
    H := RectHeight(SItemRect);
    R := SkinListBox.ItemTextRect;
    InflateRect(R, -1, -1);

    if odFocused in State1
    then
      CreateStretchImage(Buffer, Picture, FocusItemRect, R, True)
    else
    if odSelected in State1
    then
      CreateStretchImage(Buffer, Picture, ActiveItemRect, R, True)
    else
      CreateStretchImage(Buffer, Picture, SItemRect, R, True);

    R := ItemTextRect;
    OX :=  W - RectWidth(SItemRect);
    OY := RectHeight(rcItem) - RectHeight(SItemRect);
    Inc(R.Right, OX);
    Inc(R.Bottom, OY);
    R1 := ItemCheckRect;
    if R1.Left >= ItemTextRect.Right then OffsetRect(R1, OX, 0);
    Inc(R1.Bottom, OY);

    cw := RectWidth(CheckImageRect);
    ch := RectHeight(CheckImageRect);
    cx := R1.Left + RectWidth(R1) div 2;
    cy := R1.Top + RectHeight(R1) div 2;
    R1 := Rect(cx - cw div 2, cy - ch div 2,
               cx - cw div 2 + cw, cy - ch div 2 + ch);
  end;

  W := RectWidth(rcItem);
  H := RectHeight(rcItem);

  with SkinListBox do
  begin
     if (AState = cbGrayed) and AllowGrayed
   then
     begin
       SkinDrawGrayedCheckImage(R1.Left, R1.Top, Picture.Canvas,
         CheckImageRect, Buffer.Canvas);
     end
   else
   if IEnabled
   then
     begin
       if AState = cbChecked
       then
         SkinDrawCheckImage(R1.Left, R1.Top, Picture.Canvas, CheckImageRect, Buffer.Canvas)
       else
         SkinDrawCheckImage(R1.Left, R1.Top, Picture.Canvas, UnCheckImageRect, Buffer.Canvas);
     end
    else
      begin
        if AState = cbChecked
        then
          SkinDrawDisableCheckImage(R1.Left, R1.Top, Picture.Canvas,
           CheckImageRect, Buffer.Canvas)
        else
          SkinDrawDisableCheckImage(R1.Left, R1.Top, Picture.Canvas,
           UnCheckImageRect, Buffer.Canvas);
      end;
  end;

  
  with Buffer.Canvas do
  begin
    if SkinListBox.UseSkinFont
    then
      begin
        Font.Name := SkinListBox.FontName;
        Font.Style := SkinListBox.FontStyle;
        Font.Height := SkinListBox.FontHeight;
      end
    else
      Font.Assign(SkinListBox.DefaultFont);

  if (SkinListBox.SkinData <> nil) and (SkinListBox.SkinData.ResourceStrData <> nil)
  then
    Font.Charset := SkinListBox.SkinData.ResourceStrData.CharSet
  else
    Font.CharSet := SkinListBox.DefaultFont.CharSet;

    if odFocused in State1
    then
      Font.Color := SkinListBox.FocusFontColor
    else
    if odSelected in State1
    then
      Font.Color := SkinListBox.ActiveFontColor
    else
      Font.Color := SkinListBox.FontColor;

    if not IEnabled then Font.Color := GetSkinDisabledColor;
      
    Brush.Style := bsClear;
  end;

  if Assigned(SkinListBox.FOnDrawItem)
  then
    SkinListBox.FOnDrawItem(Buffer.Canvas, ItemID, Buffer.Width, Buffer.Height,
    R, State1)
  else
    begin
      if (odFocused in State1) and SkinListBox.ShowFocus
      then
        begin
          Buffer.Canvas.Brush.Style := bsSolid;
          Buffer.Canvas.Brush.Color := SkinListBox.SkinData.SkinColors.cBtnFace;
          DrawSkinFocusRect(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height));
          Buffer.Canvas.Brush.Style := bsClear;
        end;
      if (SkinListBox.Images <> nil)
      then
        begin
          if SkinListBox.ImageIndex > -1
          then IIndex := SkinListBox.FImageIndex
          else IIndex := itemID;
          if IIndex < SkinListBox.Images.Count
          then
            begin
              IX := R.Left;
              IY := R.Top + RectHeight(R) div 2 - SkinListBox.Images.Height div 2;
              SkinListBox.Images.Draw(Buffer.Canvas, IX, IY, IIndex);
            end;
          Inc(R.Left, SkinListBox.Images.Width + 2);
        end;
      if (SkinListBox <> nil) and (SkinListBox.TabWidths.Count <> 0) and (Columns = 0)
      then
        begin
          DrawTabbedString(Items[ItemID], SkinListBox.TabWidths, Buffer.Canvas, R, 0);
        end
      else
        BSDrawText2(Buffer.Canvas, Items[ItemID], R);
    end;
  Cnvs.Draw(rcItem.Left, rcItem.Top, Buffer);
  Buffer.Free;
end;

procedure TbsCheckListBox.CreateParams;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_BORDER;
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    WindowClass.style := CS_DBLCLKS;
    Style := Style or WS_TABSTOP;
  end;
end;

procedure TbsCheckListBox.CNDrawItem;
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
  begin
    {$IFDEF VER120}
      State := TOwnerDrawState(WordRec(LongRec(itemState).Lo).Lo);
    {$ELSE}
      {$IFDEF VER125}
        State := TOwnerDrawState(WordRec(LongRec(itemState).Lo).Lo);
      {$ELSE}
        State := TOwnerDrawState(LongRec(itemState).Lo);
      {$ENDIF}
    {$ENDIF}
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;
    if SkinListBox.FIndex <> -1
    then
      begin
        if SkinListBox.UseSkinItemHeight
        then
          DrawSkinItem(Canvas, itemID, rcItem, State)
        else
          DrawStretchSkinItem(Canvas, itemID, rcItem, State);
      end
    else
      DrawDefaultItem(Canvas, itemID, rcItem, State);
    Canvas.Handle := 0;
  end;
end;

procedure TbsCheckListBox.WndProc;
var
  LParam, WParam: Integer;
begin
  inherited;
  case Message.Msg of
    CM_BEPAINT:
    if Items.Count = 0 then
      begin
        if (Message.LParam = BE_ID)
        then
          begin
            if (Message.wParam <> 0)
            then
              begin
                PaintBG(Message.wParam);
              end;
            Message.Result := BE_ID;
          end;
      end;
    WM_LBUTTONDBLCLK:
      begin
        if SkinListBox <> nil then SkinListBox.ListBoxDblClick;
      end;
    WM_MOUSEWHEEL:
      if (SkinListBox <> nil) and (SkinListBox.ScrollBar <> nil)
      then
      begin
        LParam := 0;
        if TWMMOUSEWHEEL(Message).WheelDelta > 0
        then
          WParam := MakeWParam(SB_LINEUP, 0)
        else
          WParam := MakeWParam(SB_LINEDOWN, 0);
        SendMessage(Handle, WM_VSCROLL, WParam, LParam);
        SkinListBox.UpDateScrollBar;
      end;
   WM_ERASEBKGND:
      SkinListBox.UpDateScrollBar;
    LB_ADDSTRING, LB_INSERTSTRING,
    LB_DELETESTRING:
      begin
        if SkinListBox <> nil
        then
          SkinListBox.UpDateScrollBar;
      end;
  end;
end;

constructor TbsSkinCheckListBox.Create;
begin
  inherited;
  ControlStyle := [csCaptureMouse, csClickEvents,
    csOpaque, csDoubleClicks, csReplicatable, csAcceptsControls];
  FShowCaptionButtons := True;
  FUseSkinItemHeight := True;
  Forcebackground := True;
  DrawBackground := False;
  FRowCount := 0;
  FGlyph := TBitMap.Create;
  FNumGlyphs := 1;
  FSpacing := 2;
  FImageIndex := -1;
  FDefaultCaptionFont := TFont.Create;
  FDefaultCaptionFont.OnChange := OnDefaultCaptionFontChange;
  FDefaultCaptionFont.Name := 'Tahoma';
  FDefaultCaptionFont.Height := 13;
  FDefaultCaptionHeight := 20;
  ActiveButton := -1;
  OldActiveButton := -1;
  CaptureButton := -1;
  FCaptionMode := False;
  FDefaultItemHeight := 20;
  TimerMode := 0;
  WaitMode := False;
  Font.Name := 'Tahoma';
  Font.Height := 13;
  Font.Color := clWindowText;
  Font.Style := [];
  ScrollBar := nil;
  ListBox := TbsCheckListBox.Create(Self);
  ListBox.SkinListBox := Self;
  ListBox.Style := lbOwnerDrawFixed;
  ListBox.ItemHeight := FDefaultItemHeight;
  ListBox.Parent := Self;
  ListBox.Visible := True;
  Height := 120;
  Width := 120;
  FSkinDataName := 'checklistbox';
  FTabWidths := TStringList.Create;
end;

procedure TbsSkinCheckListBox.SetShowCaptionButtons;
begin
  if FShowCaptionButtons <> Value
  then
    begin
      FShowCaptionButtons := Value;
      RePaint;
    end;
end;

function TbsSkinCheckListBox.GetAutoComplete: Boolean;
begin
  Result := ListBox.AutoComplete;
end;

procedure TbsSkinCheckListBox.SetTabWidths(Value: TStrings);
begin
  FTabWidths.Assign(Value);
  if FTabWidths.Count <> 0 then ListBox.Invalidate;
end;

procedure TbsSkinCheckListBox.SetAutoComplete(Value: Boolean);
begin
  ListBox.AutoComplete := Value;
end;

function TbsSkinCheckListBox.GetOnListBoxEndDrag: TEndDragEvent;
begin
  Result := ListBox.OnEndDrag;
end;

procedure TbsSkinCheckListBox.SetOnListBoxEndDrag(Value: TEndDragEvent);
begin
  ListBox.OnEndDrag := Value;
end;

function TbsSkinCheckListBox.GetOnListBoxStartDrag: TStartDragEvent;
begin
  Result := ListBox.OnStartDrag;
end;

procedure TbsSkinCheckListBox.SetOnListBoxStartDrag(Value: TStartDragEvent);
begin
  ListBox.OnStartDrag := Value;
end;

function TbsSkinCheckListBox.GetOnListBoxDragOver: TDragOverEvent;
begin
  Result := ListBox.OnDragOver;
end;

procedure TbsSkinCheckListBox.SetOnListBoxDragOver(Value: TDragOverEvent);
begin
  ListBox.OnDragOver := Value;
end;

function TbsSkinCheckListBox.GetOnListBoxDragDrop: TDragDropEvent;
begin
  Result := ListBox.OnDragDrop;
end;

procedure TbsSkinCheckListBox.SetOnListBoxDragDrop(Value: TDragDropEvent);
begin
  ListBox.OnDragDrop := Value;
end;

procedure TbsSkinCheckListBox.SetOnClickCheck(const Value: TNotifyEvent);
begin
  FOnClickCheck := Value;
  Listbox.OnClickCheck := Value;
end;
 
function TbsSkinCheckListBox.GetListBoxDragMode: TDragMode;
begin
  Result := ListBox.DragMode;
end;

procedure TbsSkinCheckListBox.SetListBoxDragMode(Value: TDragMode);
begin
  ListBox.DragMode := Value;
end;

function TbsSkinCheckListBox.GetListBoxDragKind: TDragKind;
begin
  Result := ListBox.DragKind;
end;

procedure TbsSkinCheckListBox.SetListBoxDragKind(Value: TDragKind);
begin
  ListBox.DragKind := Value;
end;

function TbsSkinCheckListBox.GetListBoxDragCursor: TCursor;
begin
  Result := ListBox.DragCursor;
end;

procedure TbsSkinCheckListBox.SetListBoxDragCursor(Value: TCursor);
begin
  ListBox.DragCursor := Value;
end;

function  TbsSkinCheckListBox.GetColumns;
begin
  Result := ListBox.Columns;
end;

procedure TbsSkinCheckListBox.SetColumns;
begin
  ListBox.Columns := Value;
  UpDateScrollBar;
end;

procedure TbsSkinCheckListBox.SetRowCount;
begin
  FRowCount := Value;
  if FRowCount <> 0
  then
    Height := Self.CalcHeight(FRowCount);
  UpDateScrollBar;
end;

procedure TbsSkinCheckListBox.SetImages(Value: TCustomImageList);
begin
  FImages := Value;
  ListBox.RePaint;
end;

procedure TbsSkinCheckListBox.SetImageIndex(Value: Integer);
begin
  FImageIndex := Value;
  ListBox.RePaint;
end;

procedure TbsSkinCheckListBox.SetNumGlyphs;
begin
  FNumGlyphs := Value;
  RePaint;
end;

procedure TbsSkinCheckListBox.SetGlyph;
begin
  FGlyph.Assign(Value);
  RePaint;
end;

procedure TbsSkinCheckListBox.SetSpacing;
begin
  FSpacing := Value;
  RePaint;
end;


procedure TbsSkinCheckListBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

procedure TbsSkinCheckListBox.OnDefaultCaptionFontChange;
begin
  if (FIndex = -1) and FCaptionMode then RePaint;
end;

procedure TbsSkinCheckListBox.SetDefaultCaptionHeight;
begin
  FDefaultCaptionHeight := Value;
  if (FIndex = -1) and FCaptionMode
  then
    begin
      CalcRects;
      RePaint;
    end;
end;

procedure TbsSkinCheckListBox.SetDefaultCaptionFont;
begin
  FDefaultCaptionFont.Assign(Value);
end;

procedure TbsSkinCheckListBox.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 100, nil);
end;

procedure TbsSkinCheckListBox.SetDefaultItemHeight;
begin
  FDefaultItemHeight := Value;
  if (FIndex = -1) or ((FIndex <> -1) and (not FUseSkinItemHeight))
  then
    ListBox.ItemHeight := FDefaultItemHeight;
end;

procedure TbsSkinCheckListBox.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinCheckListBox.WMTimer;
begin
  inherited;
  if WaitMode
  then
    begin
      WaitMode := False;
      StartTimer;
      Exit;
    end;
  case TimerMode of
    1: if ItemIndex > 0 then ItemIndex := ItemIndex - 1;
    2: ItemIndex := ItemIndex + 1;
  end;
end;

procedure TbsSkinCheckListBox.CreateControlSkinImage;
var
  GX, GY, GlyphNum, TX, TY, i, OffX, OffY: Integer;

function GetGlyphTextWidth: Integer;
begin
  Result := B.Canvas.TextWidth(Caption);
  if not FGlyph.Empty then Result := Result + FGlyph.Width div FNumGlyphs + FSpacing;
end;

function CalcBRect(BR: TRect): TRect;
var
  R: TRect;
begin
  R := BR;
  if BR.Top <= LTPt.Y
  then
    begin
      if BR.Left > RTPt.X then OffsetRect(R, OffX, 0);
    end
  else
    begin
      OffsetRect(R, 0, OffY);
      if BR.Left > RBPt.X then OffsetRect(R, OffX, 0);
    end;
  Result := R;
end;

var
  Buffer: TBitmap;
  R1: TRect;
begin
  inherited;
  OffX := Width - RectWidth(SkinRect);
  OffY := Height - RectHeight(SkinRect);
  // hide caption buttons
  if not FShowCaptionButtons and not IsNullRect(UpButtonRect)
  then
    if not IsNullRect(DisabledButtonsRect)
    then
      begin
        R1 := ButtonsArea;
        OffsetRect(R1, OffX, 0);
        B.Canvas.CopyRect(R1, Picture.Canvas, DisabledButtonsRect);
      end
    else
      begin
        R1 := Rect(NewLtPoint.X, 0, NewRTPoint.X, NewClRect.Top - 1);
        Buffer := TBitmap.Create;
        Buffer.Width := RectWidth(R1);
        Buffer.Height := RectHeight(R1);
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height),
         B.Canvas, R1);
        R1.Right := Width - (RectWidth(SkinRect) - UpButtonRect.Right);
        B.Canvas.StretchDraw(R1, Buffer);
        Buffer.Free;
      end;
  // calc rects
  NewClRect := ClRect;
  Inc(NewClRect.Right, OffX);
  Inc(NewClRect.Bottom, OffY);
  if FCaptionMode
  then
    begin
       NewCaptionRect := CaptionRect;
      if FShowCaptionButtons
      then
        begin
          if CaptionRect.Right >= RTPt.X
          then
            Inc(NewCaptionRect.Right, OffX);
          Buttons[0].R := CalcBRect(UpButtonRect);
          Buttons[1].R := CalcBRect(DownButtonRect);
          Buttons[2].R := CalcBRect(CheckButtonRect);
        end
      else
        begin
          NewCaptionRect := CaptionRect;
          NewCaptionRect.Right := Width - CaptionRect.Left;
          Buttons[0].R := NullRect;
          Buttons[1].R := NullRect;
          Buttons[2].R := NullRect;
        end;
    end;  
  // paint caption
  if not IsNullRect(CaptionRect)
  then
    with B.Canvas do
    begin
      Font.Name := CaptionFontName;
      Font.Height := CaptionFontHeight;
      Font.Color := CaptionFontColor;
      Font.Style := CaptionFontStyle;
      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        Font.Charset := SkinData.ResourceStrData.CharSet
      else
        Font.CharSet := DefaultCaptionFont.CharSet;
      TY := NewCaptionRect.Top + RectHeight(NewCaptionRect) div 2 -
            TextHeight(Caption) div 2;
      TX := NewCaptionRect.Left + 2;
      case Alignment of
        taCenter: TX := TX + RectWidth(NewCaptionRect) div 2 - GetGlyphTextWidth div 2;
        taRightJustify: TX := NewCaptionRect.Right - GetGlyphTextWidth - 2;
      end;
      Brush.Style := bsClear;

      if not FGlyph.Empty
      then
      begin
        GY := NewCaptionRect.Top + RectHeight(NewCaptionRect) div 2 - FGlyph.Height div 2;
        GX := TX;
        TX := GX + FGlyph.Width div FNumGlyphs + FSpacing;
        GlyphNum := 1;
        if not Enabled and (NumGlyphs = 2) then GlyphNum := 2;
       end;
      TextRect(NewCaptionRect, TX, TY, Caption);
      if not FGlyph.Empty
      then DrawGlyph(B.Canvas, GX, GY, FGlyph, NumGlyphs, GlyphNum);
    end;
  // paint buttons
  if FShowCaptionButtons
  then
    for i := 0 to 2 do DrawButton(B.Canvas, i);
end;

procedure TbsSkinCheckListBox.CreateControlDefaultImage;

function GetGlyphTextWidth: Integer;
begin
  Result := B.Canvas.TextWidth(Caption);
  if not FGlyph.Empty then Result := Result + FGlyph.Width div FNumGlyphs + FSpacing;
end;

var
  BW, i, TX, TY: Integer;
  R: TRect;
  GX, GY: Integer;
  GlyphNum: Integer;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons
  then
    begin
      BW := 17;
      if BW > FDefaultCaptionHeight - 3 then BW := FDefaultCaptionHeight - 3;
      Buttons[0].R := Rect(Width - BW - 2, 2, Width - 2, 1 + BW);
      Buttons[1].R := Rect(Buttons[0].R.Left - BW, 2, Buttons[0].R.Left, 1 + BW);
      Buttons[2].R := Rect(Buttons[1].R.Left - BW, 2, Buttons[1].R.Left, 1 + BW);
    end;  
  R := ClientRect;
  Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
  if ListBox <> nil
  then
    Frame3D(B.Canvas, R, ListBox.Color, ListBox.Color, 1);
  if FCaptionMode
  then
    with B.Canvas do
    begin
      Brush.Color := clBtnShadow;
      FillRect(Rect(0, 0, Width, FDefaultCaptionHeight));
      //
      if FShowCaptionButtons
      then
        R := Rect(3, 2, Width - BW * 3 - 3, FDefaultCaptionHeight - 2)
      else
        R := Rect(3, 2, Width - 2, FDefaultCaptionHeight - 2);
      Font.Assign(FDefaultCaptionFont);
      if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
      then
        Font.Charset := SkinData.ResourceStrData.CharSet;
      case Alignment of
        taLeftJustify: TX := R.Left;
        taCenter: TX := R.Left + RectWidth(R) div 2 - GetGlyphTextWidth div 2;
        taRightJustify: TX := R.Right - GetGlyphTextWidth;
      end;

      TY := (FDefaultCaptionHeight - 2) div 2 - TextHeight(Caption) div 2;

      if not FGlyph.Empty
      then
        begin
          GY := R.Top + RectHeight(R) div 2 - FGlyph.Height div 2 - 1;
          GX := TX;
          if FNumGlyphs = 0 then FNumGlyphs := 1; 
          TX := GX + FGlyph.Width div FNumGlyphs + FSpacing;
          GlyphNum := 1;
          if not Enabled and (NumGlyphs = 2) then GlyphNum := 2;
        end;
      TextRect(R, TX, TY, Caption);
      if not FGlyph.Empty
      then DrawGlyph(B.Canvas, GX, GY, FGlyph, NumGlyphs, GlyphNum);
      if FShowCaptionButtons
      then
        for i := 0 to 2 do DrawButton(B.Canvas, i);
    end;
end;

procedure TbsSkinCheckListBox.CMMouseEnter;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons
  then
    TestActive(-1, -1);
end;

procedure TbsSkinCheckListBox.CMMouseLeave;
var
  i: Integer;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons
  then
  for i := 0 to 1 do
    if Buttons[i].MouseIn
    then
       begin
         Buttons[i].MouseIn := False;
         RePaint;
       end;
end;

procedure TbsSkinCheckListBox.MouseDown;
begin
  if FCaptionMode and FShowCaptionButtons
  then
    begin
      TestActive(X, Y);
      if ActiveButton <> -1
      then
        begin
          CaptureButton := ActiveButton;
          ButtonDown(ActiveButton, X, Y);
      end;
    end;
  inherited;
end;

procedure TbsSkinCheckListBox.MouseUp;
begin
  if FCaptionMode and FShowCaptionButtons
  then
    begin
      if CaptureButton <> -1
      then ButtonUp(CaptureButton, X, Y);
      CaptureButton := -1;
    end;  
  inherited;
end;

procedure TbsSkinCheckListBox.MouseMove;
begin
  inherited;
  if FCaptionMode and FShowCaptionButtons then TestActive(X, Y);
end;

procedure TbsSkinCheckListBox.TestActive(X, Y: Integer);
var
  i, j: Integer;
begin
  if ((FIndex <> -1) and IsNullRect(UpButtonRect) and IsNullRect(DownButtonRect)) or
      not FShowCaptionButtons
  then Exit;


  j := -1;
  OldActiveButton := ActiveButton;
  for i := 0 to 2 do
  begin
    if PtInRect(Buttons[i].R, Point(X, Y))
    then
      begin
        j := i;
        Break;
      end;
  end;

  ActiveButton := j;

  if (CaptureButton <> -1) and
     (ActiveButton <> CaptureButton) and (ActiveButton <> -1)
  then
    ActiveButton := -1;

  if (OldActiveButton <> ActiveButton)
  then
    begin
      if OldActiveButton <> - 1
      then
        ButtonLeave(OldActiveButton);

      if ActiveButton <> -1
      then
        ButtonEnter(ActiveButton);
    end;
end;

procedure TbsSkinCheckListBox.ButtonDown;
begin
  Buttons[i].MouseIn := True;
  Buttons[i].Down := True;
  DrawButton(Canvas, i);

  case i of
    0: if Assigned(FOnUpButtonClick) then Exit;
    1: if Assigned(FOnDownButtonClick) then Exit;
    2: if Assigned(FOnCheckButtonClick) then Exit;
  end;

  TimerMode := 0;
  case i of
    0: TimerMode := 1;
    1: TimerMode := 2;
  end;

  if TimerMode <> 0
  then
    begin
      WaitMode := True;
      SetTimer(Handle, 1, 500, nil);
    end;
end;

procedure TbsSkinCheckListBox.ButtonUp;
begin
  Buttons[i].Down := False;
  if ActiveButton <> i then Buttons[i].MouseIn := False;
  DrawButton(Canvas, i);
  if Buttons[i].MouseIn
  then
  case i of
    0:
      if Assigned(FOnUpButtonClick)
      then
        begin
          FOnUpButtonClick(Self);
          Exit;
        end;
    1:
      if Assigned(FOnDownButtonClick)
      then
        begin
          FOnDownButtonClick(Self);
          Exit;
        end;
    2:
      if Assigned(FOnCheckButtonClick)
      then
        begin
          FOnCheckButtonClick(Self);
          Exit;
        end;
  end;
  case i of
    1: ItemIndex := ItemIndex + 1;
    0: if ItemIndex > 0 then ItemIndex := ItemIndex - 1;
    2: if (ItemIndex > -1) and GetItemEnabled(ItemIndex)
       then
         begin
           if AllowGrayed
           then
             begin
               ListBox.ToggleClickCheck(ItemIndex);
             end
           else
             begin
               Checked[ItemIndex] := not Checked[ListBox.ItemIndex];
               ListBoxOnClickCheck(Self);
             end;
        end;
  end;
  if TimerMode <> 0 then StopTimer;
end;

procedure TbsSkinCheckListBox.ButtonEnter(I: Integer);
begin
  Buttons[i].MouseIn := True;
  DrawButton(Canvas, i);
  if (TimerMode <> 0) and Buttons[i].Down
  then SetTimer(Handle, 1, 50, nil);
end;

procedure TbsSkinCheckListBox.ButtonLeave(I: Integer);
begin
  Buttons[i].MouseIn := False;
  DrawButton(Canvas, i);
  if (TimerMode <> 0) and Buttons[i].Down
  then KillTimer(Handle, 1);
end;

procedure TbsSkinCheckListBox.CMTextChanged;
begin
  inherited;
  if FCaptionMode then RePaint;
end;

procedure TbsSkinCheckListBox.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value
  then
    begin
      FAlignment := Value;
      if FCaptionMode then RePaint;
    end;
end;

procedure TbsSkinCheckListBox.DrawButton;
var
  C: TColor;
  kf: Double;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Buttons[i] do
    begin
      R1 := R;
      if Down and MouseIn
      then
        begin
          Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          Cnvs.Brush.Color := BS_BTNDOWNCOLOR;
          Cnvs.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(Cnvs, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            Cnvs.Brush.Color := BS_BTNACTIVECOLOR;
            Cnvs.FillRect(R1);
          end
        else
          begin
            Cnvs.Brush.Color := clBtnShadow;
            Cnvs.FillRect(R1);
          end;
      C := clBlack;
      case i of
        0: DrawArrowImage(Cnvs, R, C, 3);
        1: DrawArrowImage(Cnvs, R, C, 4);
        2: DrawCheckImage(Cnvs, R.Left + 4, R.Top + 4, C);
      end;
    end
  else
    with Buttons[i] do
    if not IsNullRect(R) then
    begin
      R1 := NullRect;
      case I of
        0:
          begin
            if Down and MouseIn
            then R1 := DownUpButtonRect
            else if MouseIn then R1 := ActiveUpButtonRect;
          end;
        1:
          begin
            if Down and MouseIn
            then R1 := DownDownButtonRect
            else if MouseIn then R1 := ActiveDownButtonRect;
          end;
        2: begin
            if Down and MouseIn
            then R1 := DownCheckButtonRect
            else if MouseIn then R1 := ActiveCheckButtonRect;
           end;
      end;
      if not IsNullRect(R1)
      then
        Cnvs.CopyRect(R, Picture.Canvas, R1)
      else
        begin
          case I of
            0: R1 := UpButtonRect;
            1: R1 := DownButtonRect;
            2: R1 := CheckButtonRect;
          end;
          OffsetRect(R1, SkinRect.Left, SkinRect.Top);
          Cnvs.CopyRect(R, Picture.Canvas, R1);
        end;
    end;
end;

procedure TbsSkinCheckListBox.SetCaptionMode;
begin
  FCaptionMode := Value;
  if FIndex = -1
  then
    begin
      CalcRects;
      RePaint;
    end;
end;

procedure TbsSkinCheckListBox.ListBoxOnClickCheck(Sender: TObject);
begin
  if Assigned(FOnClickCheck) then FOnClickCheck(Self);
end;

procedure TbsSkinCheckListBox.SetChecked;
begin
  ListBox.Checked[Index] := Checked;
end;

function TbsSkinCheckListBox.GetChecked;
begin
  Result := ListBox.Checked[Index];
end;

procedure TbsSkinCheckListBox.SetState;
begin
  ListBox.State[Index] := AState;
end;

function TbsSkinCheckListBox.GetAllowGrayed: Boolean;
begin
  Result := ListBox.AllowGrayed;
end;

procedure TbsSkinCheckListBox.SetAllowGrayed(Value: Boolean);
begin
  ListBox.AllowGrayed := Value;
end;

function TbsSkinCheckListBox.GetState;
begin
  Result := ListBox.State[Index];
end;

function TbsSkinCheckListBox.GetItemEnabled;
begin
  Result := ListBox.GetItemEnabled(Index);
end;

procedure TbsSkinCheckListBox.SetItemEnabled;
begin
  ListBox.SetItemEnabled(Index, Value);
end;

function TbsSkinCheckListBox.CalcHeight;
begin
  if FIndex = -1
  then
    Result := AitemsCount * ListBox.ItemHeight + 4
  else
    Result := ClRect.Top + AitemsCount * ListBox.ItemHeight +
              RectHeight(SkinRect) - ClRect.Bottom;
end;

procedure TbsSkinCheckListBox.Clear;
begin
  ListBox.Clear;
end;

function TbsSkinCheckListBox.ItemAtPos(Pos: TPoint; Existing: Boolean): Integer;
begin
  Result := ListBox.ItemAtPos(Pos, Existing);
end;

function TbsSkinCheckListBox.ItemRect(Item: Integer): TRect;
begin
  Result := ListBox.ItemRect(Item);
end;

function TbsSkinCheckListBox.GetListBoxPopupMenu;
begin
  Result := ListBox.PopupMenu;
end;

procedure TbsSkinCheckListBox.SetListBoxPopupMenu;
begin
  ListBox.PopupMenu := Value;
end;


function TbsSkinCheckListBox.GetCanvas: TCanvas;
begin
  Result := ListBox.Canvas;
end;

function TbsSkinCheckListBox.GetExtandedSelect: Boolean;
begin
  Result := ListBox.ExtendedSelect;
end;

procedure TbsSkinCheckListBox.SetExtandedSelect(Value: Boolean);
begin
  ListBox.ExtendedSelect := Value;
end;

function TbsSkinCheckListBox.GetSelCount: Integer;
begin
  Result := ListBox.SelCount;
end;

function TbsSkinCheckListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := ListBox.Selected[Index];
end;

procedure TbsSkinCheckListBox.SetSelected(Index: Integer; Value: Boolean);
begin
  ListBox.Selected[Index] := Value;
end;

function TbsSkinCheckListBox.GetSorted: Boolean;
begin
  Result := ListBox.Sorted;
end;

procedure TbsSkinCheckListBox.SetSorted(Value: Boolean);
begin
  if ScrollBar <> nil then HideScrollBar;
  ListBox.Sorted := Value;
end;

function TbsSkinCheckListBox.GetTopIndex: Integer;
begin
  Result := ListBox.TopIndex;
end;

procedure TbsSkinCheckListBox.SetTopIndex(Value: Integer);
begin
  ListBox.TopIndex := Value;
end;

function TbsSkinCheckListBox.GetMultiSelect: Boolean;
begin
  Result := ListBox.MultiSelect;
end;

procedure TbsSkinCheckListBox.SetMultiSelect(Value: Boolean);
begin
  ListBox.MultiSelect := Value;
end;

function TbsSkinCheckListBox.GetListBoxFont: TFont;
begin
  Result := ListBox.Font;
end;

procedure TbsSkinCheckListBox.SetListBoxFont(Value: TFont);
begin
  ListBox.Font.Assign(Value);
end;

function TbsSkinCheckListBox.GetListBoxTabOrder: TTabOrder;
begin
  Result := ListBox.TabOrder;
end;

procedure TbsSkinCheckListBox.SetListBoxTabOrder(Value: TTabOrder);
begin
  ListBox.TabOrder := Value;
end;

function TbsSkinCheckListBox.GetListBoxTabStop: Boolean;
begin
  Result := ListBox.TabStop;
end;

procedure TbsSkinCheckListBox.SetListBoxTabStop(Value: Boolean);
begin
  ListBox.TabStop := Value;
end;

procedure TbsSkinCheckListBox.ShowScrollBar;
begin
  ScrollBar := TbsSkinScrollBar.Create(Self);
  with ScrollBar do
  begin
    if Columns > 0
    then
      Kind := sbHorizontal
    else
      Kind := sbVertical;
    Height := 100;
    Width := 20;
    Parent := Self;
    PageSize := 0;
    Min := 0;
    Position := 0;
    OnChange := SBChange;
    if Self.FIndex = -1
    then
      SkinDataName := ''
    else
      if Columns > 0
      then
        SkinDataName := HScrollBarName
      else
        SkinDataName := VScrollBarName;
    SkinData := Self.SkinData;
    CalcRects;
    Parent := Self;
    Visible := True;
  end;
  RePaint;
end;

procedure TbsSkinCheckListBox.ListBoxEnter;
begin
end;

procedure TbsSkinCheckListBox.ListBoxExit;
begin
end;

procedure TbsSkinCheckListBox.ListBoxKeyDown;
begin
  if Assigned(FOnListBoxKeyDown) then FOnListBoxKeyDown(Self, Key, Shift);
end;

procedure TbsSkinCheckListBox.ListBoxKeyUp;
begin
  if Assigned(FOnListBoxKeyUp) then FOnListBoxKeyUp(Self, Key, Shift);
end;

procedure TbsSkinCheckListBox.ListBoxKeyPress;
begin
  if Assigned(FOnListBoxKeyPress) then FOnListBoxKeyPress(Self, Key);
end;

procedure TbsSkinCheckListBox.ListBoxDblClick;
begin
  if Assigned(FOnListBoxDblClick) then FOnListBoxDblClick(Self);
end;

procedure TbsSkinCheckListBox.ListBoxClick;
begin
  if Assigned(FOnListBoxClick) then FOnListBoxClick(Self);
end;

procedure TbsSkinCheckListBox.ListBoxMouseDown;
begin
  if Assigned(FOnListBoxMouseDown) then FOnListBoxMouseDown(Self, Button, Shift, X, Y);
end;

procedure TbsSkinCheckListBox.ListBoxMouseMove;
begin
  if Assigned(FOnListBoxMouseMove) then FOnListBoxMouseMove(Self, Shift, X, Y);
end;

procedure TbsSkinCheckListBox.ListBoxMouseUp;
begin
  if Assigned(FOnListBoxMouseUp) then FOnListBoxMouseUp(Self, Button, Shift, X, Y);
end;

procedure TbsSkinCheckListBox.HideScrollBar;
begin
  ScrollBar.Visible := False;
  ScrollBar.Free;
  ScrollBar := nil;
  CalcRects;
end;

procedure TbsSkinCheckListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TbsSkinCheckListBox.SBChange;
var
  LParam, WParam: Integer;
begin
  LParam := 0;
  WParam := MakeWParam(SB_THUMBPOSITION, ScrollBar.Position);
  if Columns > 0
  then
    SendMessage(ListBox.Handle, WM_HSCROLL, WParam, LParam)
  else
    SendMessage(ListBox.Handle, WM_VSCROLL, WParam, LParam);
end;

function TbsSkinCheckListBox.GetItemIndex;
begin
  Result := ListBox.ItemIndex;
end;

procedure TbsSkinCheckListBox.SetItemIndex;
begin
  ListBox.ItemIndex := Value;
end;


procedure TbsSkinCheckListBox.SetItems;
begin
  ListBox.Items.Assign(Value);
  UpDateScrollBar;
end;

function TbsSkinCheckListBox.GetItems;
begin
  Result := ListBox.Items;
end;

destructor TbsSkinCheckListBox.Destroy;
begin
  FTabWidths.Free;
  if ScrollBar <> nil then ScrollBar.Free;
  if ListBox <> nil then ListBox.Free;
  FDefaultCaptionFont.Free;
  FGlyph.Free;
  inherited;
end;

procedure TbsSkinCheckListBox.CalcRects;
var
  LTop: Integer;
  OffX, OffY: Integer;
begin
  if FIndex <> -1
  then
    begin
      OffX := Width - RectWidth(SkinRect);
      OffY := Height - RectHeight(SkinRect);
      NewClRect := ClRect;
      Inc(NewClRect.Right, OffX);
      Inc(NewClRect.Bottom, OffY);
    end
  else
    if FCaptionMode
    then
      LTop := FDefaultCaptionHeight
    else
      LTop := 1;

  if (ScrollBar <> nil) and ScrollBar.Visible
  then
    begin
      if FIndex = -1
      then
        begin
          if Columns > 0
          then
            begin
              ScrollBar.SetBounds(1, Height - 20, Width - 2, 19);
              ListRect := Rect(2, LTop + 1, Width - 2, ScrollBar.Top);
            end
          else
            begin
              ScrollBar.SetBounds(Width - 20, LTop, 19, Height - 1 - LTop);
              ListRect := Rect(2, LTop + 1, ScrollBar.Left, Height - 2);
            end;
        end
      else
        begin
          if Columns > 0
          then
            begin
              ScrollBar.SetBounds(NewClRect.Left,
                NewClRect.Bottom - ScrollBar.Height,
                RectWidth(NewClRect), ScrollBar.Height);
              ListRect := NewClRect;
              Dec(ListRect.Bottom, ScrollBar.Height);
            end
          else
            begin
              ScrollBar.SetBounds(NewClRect.Right - ScrollBar.Width,
                NewClRect.Top, ScrollBar.Width, RectHeight(NewClRect));
              ListRect := NewClRect;
              Dec(ListRect.Right, ScrollBar.Width);
            end;
        end;
    end
  else
    begin
      if FIndex = -1
      then
        ListRect := Rect(2, LTop + 1, Width - 2, Height - 2)
      else
        ListRect := NewClRect;
    end;
  if ListBox <> nil
  then
    ListBox.SetBounds(ListRect.Left, ListRect.Top,
      RectWidth(ListRect), RectHeight(ListRect));
end;

procedure TbsSkinCheckListBox.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinListBox
    then
      with TbsDataSkinCheckListBox(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.SItemRect := SItemRect;
        Self.ActiveItemRect := ActiveItemRect;
        if isNullRect(ActiveItemRect)
        then
          Self.ActiveItemRect := SItemRect;
        Self.FocusItemRect := FocusItemRect;
        if isNullRect(FocusItemRect)
        then
          Self.FocusItemRect := SItemRect;

        Self.UnCheckImageRect := UnCheckImageRect;
        Self.CheckImageRect := CheckImageRect;

        Self.ItemLeftOffset := ItemLeftOffset;
        Self.ItemRightOffset := ItemRightOffset;
        Self.ItemTextRect := ItemTextRect;
        Self.ItemCheckRect := ItemCheckRect;
        Self.FontColor := FontColor;
        Self.ActiveFontColor := ActiveFontColor;
        Self.FocusFontColor := FocusFontColor;
        Self.VScrollBarName := VScrollBarName;
        Self.HScrollBarName := HScrollBarName;

        Self.CaptionRect := CaptionRect;
        Self.CaptionFontName := CaptionFontName;
        Self.CaptionFontStyle := CaptionFontStyle;
        Self.CaptionFontHeight := CaptionFontHeight;
        Self.CaptionFontColor := CaptionFontColor;
        Self.UpButtonRect := UpButtonRect;
        Self.ActiveUpButtonRect := ActiveUpButtonRect;
        Self.DownUpButtonRect := DownUpButtonRect;
        if IsNullRect(Self.DownUpButtonRect)
        then Self.DownUpButtonRect := Self.ActiveUpButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.ActiveDownButtonRect := ActiveDownButtonRect;
        Self.DownDownButtonRect := DownDownButtonRect;
        if IsNullRect(Self.DownDownButtonRect)
        then Self.DownDownButtonRect := Self.ActiveDownButtonRect;
        Self.CheckButtonRect := CheckButtonRect;
        Self.ActiveCheckButtonRect := ActiveCheckButtonRect;
        Self.DownCheckButtonRect := DownCheckButtonRect;
        if IsNullRect(Self.DownCheckButtonRect)
        then Self.DownCheckButtonRect := Self.ActiveCheckButtonRect;
        Self.ShowFocus := ShowFocus;
        //
        Self.DisabledButtonsRect := DisabledButtonsRect;
        Self.ButtonsArea := ButtonsArea;
      end;
end;

procedure TbsSkinCheckListBox.ChangeSkinData;
begin
  inherited;
  //
  if FIndex <> -1
  then
    begin
      if FUseSkinItemHeight
      then
        ListBox.ItemHeight := RectHeight(sItemRect);
    end
  else
    begin
      ListBox.ItemHeight := FDefaultItemHeight;
      Font.Assign(FDefaultFont);
    end;

  if ScrollBar <> nil
  then
    with ScrollBar do
    begin
      if Self.FIndex = -1
      then
        SkinDataName := ''
      else
        if Columns > 0
        then
          SkinDataName := HScrollBarName
        else
          SkinDataName := VScrollBarName;
      SkinData := Self.SkinData;
    end;

  if FRowCount <> 0
  then
    Height := Self.CalcHeight(FRowCount);
  CalcRects;
  UpDateScrollBar;
  ListBox.RePaint;
end;

procedure TbsSkinCheckListBox.WMSIZE;
begin
  inherited;
  CalcRects;
  UpDateScrollBar;
  if ScrollBar <> nil then ScrollBar.Repaint;
end;

procedure TbsSkinCheckListBox.SetBounds;
begin
  inherited;
  if FIndex = -1 then RePaint;
end;

procedure TbsSkinCheckListBox.UpDateScrollBar;
var
  Min, Max, Pos, Page: Integer;
begin
  if ListBox = nil then Exit;
  if Columns > 0
  then
    begin
      GetScrollRange(ListBox.Handle, SB_HORZ, Min, Max);
      Pos := GetScrollPos(ListBox.Handle, SB_HORZ);
      Page := ListBox.Columns;
      if (Max > Min) and (Pos <= Max) and (Page <= Max)
      then
        begin
          if ScrollBar = nil
          then ShowScrollBar;
          ScrollBar.SetRange(Min, Max, Pos, Page);
        end
     else
       if (ScrollBar <> nil) and (ScrollBar.Visible) then HideScrollBar;
    end
  else
    begin
      if not ((FRowCount > 0) and (RowCount = Items.Count))
      then
        begin
          GetScrollRange(ListBox.Handle, SB_VERT, Min, Max);
          Pos := GetScrollPos(ListBox.Handle, SB_VERT);
          Page := ListBox.Height div ListBox.ItemHeight;
          if (Max > Min) and (Pos <= Max) and (Page < Items.Count)
          then
            begin
              if ScrollBar = nil then ShowScrollBar;
              ScrollBar.SetRange(Min, Max, Pos, Page);
              ScrollBar.LargeChange := Page;
            end
          else
            if (ScrollBar <> nil) and ScrollBar.Visible then HideScrollBar;
        end
      else
        if (ScrollBar <> nil) and ScrollBar.Visible
        then HideScrollBar;
    end;
end;

constructor TbsSkinScrollBox.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls];
  FCanFocused := False;
  FClicksDisabled := False;
  FInCheckScrollBars := False;
  FVSizeOffset := 0;
  FHSizeOffset := 0;
  FVScrollBar := nil;
  FHScrollBar := nil;
  FOldVScrollBarPos := 0;
  FOldHScrollBarPos := 0;
  FDown := False;
  FSkinDataName := 'scrollbox';
  BGPictureIndex := -1;
  Width := 150;
  Height := 150;
end;

destructor TbsSkinScrollBox.Destroy;
begin
  inherited;
end;

procedure TbsSkinScrollBox.CMSENCPaint(var Message: TMessage); var
  C: TCanvas;
begin
   if (Message.wParam <> 0) and not ((BGPictureIndex <> -1) or (FBorderStyle = bvNone))
  then
    begin
      C := TControlCanvas.Create;
      C.Handle := Message.wParam;
      PaintFrame(C);
      C.Handle := 0;
      C.Free;
      Message.Result := SE_RESULT;
    end
  else
    Message.Result := 0;
end;

procedure TbsSkinScrollBox.CMBENCPAINT;
var
  C: TCanvas;
begin
  if (Message.LParam = BE_ID)
  then
    begin
      if (Message.wParam <> 0) and not ((BGPictureIndex <> -1) or (FBorderStyle = bvNone))
      then
        begin
          C := TControlCanvas.Create;
          C.Handle := Message.wParam;
          PaintFrame(C);
          C.Handle := 0;
          C.Free;
        end;
      Message.Result := BE_ID;
    end
  else
    inherited;
end;

procedure TbsSkinScrollBox.WndProc;
begin
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
    begin
      if FCanFocused and not (csDesigning in ComponentState) and not Focused
      then
        begin
          FClicksDisabled := True;
          Windows.SetFocus(Handle);
          FClicksDisabled := False;
          if not Focused then Exit;
        end;
    end;
    CN_COMMAND:
      if FClicksDisabled then Exit;
  end;
  inherited;
end;

procedure TbsSkinScrollBox.UpDateScrollRange;
begin
  GetHRange;
  GetVRange;
end;

procedure TbsSkinScrollBox.CMVisibleChanged;
begin
  inherited;
  if FVScrollBar <> nil then FVScrollBar.Visible := Self.Visible;
  if FHScrollBar <> nil then FHScrollBar.Visible := Self.Visible;
end;

procedure TbsSkinScrollBox.OnHScrollBarChange(Sender: TObject);
begin
  HScrollControls(FHScrollBar.Position - FOldHScrollBarPos);
  FOldHScrollBarPos := HScrollBar.Position;
end;

procedure TbsSkinScrollBox.OnVScrollBarChange(Sender: TObject);
begin
  VScrollControls(FVScrollBar.Position - FOldVScrollBarPos);
  FOldVScrollBarPos := VScrollBar.Position;
end;

procedure TbsSkinScrollBox.OnHScrollBarLastChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TbsSkinScrollBox.OnVScrollBarLastChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TbsSkinScrollBox.ChangeSkinData;
begin
  inherited;
  ReCreateWnd;
  if FVScrollBar <> nil then FVScrollBar.Align := FVScrollBar.Align;
  if FHScrollBar <> nil then FHScrollBar.Align := FHScrollBar.Align;
end;

procedure TbsSkinScrollBox.HScroll;
begin
  FUpdatingScrollInfo := True;
  if (FHScrollBar <> nil) and (FHScrollBar.PageSize <> 0)
  then
    with FHScrollBar do
    begin
      HScrollControls(APosition - Position);
      Position := APosition;
    end;
  FUpdatingScrollInfo := False;  
end;

procedure TbsSkinScrollBox.VScroll;
begin
  FUpdatingScrollInfo := True;
  if (FVScrollBar <> nil) and (FVScrollBar.PageSize <> 0)
  then
    with FVScrollBar do
    begin
      if APosition > Max - PageSize then APosition := Max - PageSize;
      VScrollControls(APosition - Position);
      Position := APosition;
    end;
  FUpdatingScrollInfo := False;  
end;

procedure TbsSkinScrollBox.ScrollToControl(C: TControl);
var
  HOff: Integer;
  VOff: Integer;
begin
  if C.Parent = nil then Exit;
  if C.Parent <> Self then Exit;

  if C.Top < 0
  then
    VOff := C.Top - FVSizeOffset
  else
    VOff := C.Top + C.Height - FVSizeOffset;

  if C.Left < 0
  then
    HOff := C.Left - FHSizeOffset
  else
    HOff := C.Left + C.Width - FHSizeOffset;


  if (FHScrollBar <> nil) and (FHScrollBar.Visible) and
     ((C.Left < 0) or (C.Left + C.Width > Self.Width))
  then
    FHScrollBar.Position := FHScrollBar.Position + HOff;

  if (FVScrollBar <> nil) and (FVScrollBar.Visible) and
     ((C.Top < 0) or (C.Top + C.Height > Self.Height))
  then
    FVScrollBar.Position := FVScrollBar.Position + VOff;
end;

procedure TbsSkinScrollBox.SetBorderStyle;
begin
  FBorderStyle := Value;
  ReCreateWnd;
end;

procedure TbsSkinScrollBox.GetSkinData;
begin
  inherited;
  BGPictureIndex := -1;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinScrollBoxControl
    then
      with TbsDataSkinScrollBoxControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.BGPictureIndex := BGPictureIndex;
      end;
end;

procedure TbsSkinScrollBox.Notification;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FHScrollBar)
  then FHScrollBar := nil;
  if (Operation = opRemove) and (AComponent = FVScrollBar)
  then FVScrollBar := nil;
end;

procedure TbsSkinScrollBox.SetVScrollBar;
begin
  FVScrollBar := Value;
  if FVScrollBar <> nil
  then
    with FVScrollBar do
    begin
      CanFocused := False;
      OnChange := OnVScrollBarChange;
      OnLastChange := OnVScrollBarLastChange;
      Enabled := True;
      Visible := False;
    end;
  GetVRange;
end;

procedure TbsSkinScrollBox.SetHScrollBar;
begin
  FHScrollBar := Value;
  if FHScrollBar <> nil
  then
    with FHScrollBar do
    begin
      CanFocused := False;
      Enabled := True;
      Visible := False;
      OnChange := OnHScrollBarChange;
      OnLastChange := OnHScrollBarLastChange;
    end;
  GetHRange;
end;

procedure TbsSkinScrollBox.CreateControlDefaultImage;
var
  R: TRect;
begin
  with B.Canvas do
  begin
    Brush.Color := Color;
    R := ClientRect;
    FillRect(R);
  end;
end;

type
  TParentControl = class(TWinControl);

procedure TbsSkinScrollBox.GetVRange;
var
  i, MaxBottom, H, Offset: Integer;
  FMax: Integer;
  VisibleChanged, IsVisible: Boolean;
  R: TRect;
begin
  if (FVScrollBar = nil) or FInCheckScrollBars or (Parent = nil) then Exit;
  VisibleChanged := False;
  H := ClientHeight;
  MaxBottom := 0;
  for i := 0 to ControlCount - 1 do
  with Controls[i] do
  begin
   if Visible
   then
     if Top + Height > MaxBottom then MaxBottom := Top + Height;
  end;
  with FVScrollBar do
  begin
    FMax := MaxBottom + Position;
    if FMax > H
    then
      begin
        if not Visible
        then
          begin
            IsVisible := True;
            VisibleChanged := True;
          end;

        if (Position > 0) and (MaxBottom < H) and (FVSizeOffset > 0)
        then
          begin
            if FVSizeOffset > Position then FVSizeOffset := Position;
            SetRange(0, FMax - 1, Position - FVSizeOffset, H);
            VScrollControls(- FVSizeOffset);
            FVSizeOffset := 0;
            FOldVScrollBarPos := Position;
          end
        else
          begin
            if (FVSizeOffset = 0) and ((FMax - 1) < Max) and (Position > 0) and
               (MaxBottom < H)
            then
              begin
                Offset := H - MaxBottom;
                if Offset > Position then  Offset := Position;
                VScrollControls(-Offset);
                SetRange(0, FMax - 1, Position - OffSet, H);
              end
            else
              SetRange(0, FMax - 1, Position, H);
            FVSizeOffset := 0;
            FOldVScrollBarPos := Position;
          end;
      end
    else
      begin
        if Position > 0
        then VScrollControls(-Position);
        FVSizeOffset := 0;
        FOldVScrollBarPos := 0;
        SetRange(0, 0, 0, 0);
        if Visible
        then
          begin
            IsVisible := False;
            VisibleChanged := True;
          end;
      end;
   end;

   if (FVScrollBar <> nil) and (FHScrollBar <> nil)
   then
    begin
      if not FVScrollBar.Visible and FHScrollBar.Both
      then
        FHScrollBar.Both := False
      else
      if FVScrollBar.Visible and not FHScrollBar.Both
      then
        FHScrollBar.Both := True;
    end;

  if VisibleChanged
  then
    begin
      FInCheckScrollBars := True;
      FVScrollBar.Visible := IsVisible;
      FInCheckScrollBars := False;
      if (Align <> alNone)
      then
        begin
          FInCheckScrollBars := True;
          R := Parent.ClientRect;
          TParentControl(Parent).AlignControls(nil, R);
          R := ClientRect;
          AlignControls(nil, R);
          FInCheckScrollBars := False;
        end;
    end;
end;

procedure TbsSkinScrollBox.VScrollControls;
begin
  ScrollBy(0,  -AOffset);
  if (FIndex <> -1) and StretchEffect then RePaint;
end;

procedure TbsSkinScrollBox.AdjustClientRect(var Rect: TRect);
var
  RLeft, RTop, VMax, HMax: Integer;
begin
  if (VScrollbar <> nil) and VScrollbar.Visible
  then
    begin
      RTop := -VScrollbar.Position;
      VMax := Max(VScrollBar.Max, ClientHeight);
    end
  else
    begin
      RTop := 0;
      VMax := ClientHeight;
    end;
  if (HScrollbar <> nil) and HScrollbar.Visible
  then
    begin
      RLeft := -HScrollbar.Position;
      HMax := Max(HScrollBar.Max, ClientWidth);
    end
  else
    begin
      RLeft := 0;
      HMax := ClientWidth;
    end;
  Rect := Bounds(RLeft, RTop,  HMax, VMax);
  inherited AdjustClientRect(Rect);
end;

procedure TbsSkinScrollBox.GetHRange;
var
  i, MaxRight, W, Offset: Integer;
  FMax: Integer;
  VisibleChanged, IsVisible: Boolean;
  R: TRect;
begin
  if (FHScrollBar = nil) or FInCheckScrollBars or (Parent = nil)  then Exit;
  VisibleChanged := False;
  W := ClientWidth;
  MaxRight := 0;
  for i := 0 to ControlCount - 1 do
  with Controls[i] do
  begin
   if Visible
   then
     if Left + Width > MaxRight then MaxRight := left + Width;
  end;
  with FHScrollBar do
  begin
    FMax := MaxRight + Position;
    if FMax > W
    then
      begin
        if not Visible
        then
          begin
            IsVisible := True;
            VisibleChanged := True;
          end;
        if (Position > 0) and (MaxRight < W) and (FHSizeOffset > 0)
        then
          begin
            if FHSizeOffset > Position
            then FHSizeOffset := Position;
            SetRange(0, FMax - 1, Position - FHSizeOffset , W);
            HScrollControls(-FHSizeOffset);
            FOldHScrollBarPos := Position;
          end
        else
          begin
            if (FHSizeOffset = 0) and ((FMax - 1) < Max) and (Position > 0) and
               (MaxRight < W)
            then
              begin
                Offset := W - MaxRight;
                if Offset > Position then  Offset := Position;
                HScrollControls(-Offset);
                SetRange(0, FMax - 1, Position - OffSet, W);
              end
            else
              SetRange(0, FMax - 1, Position, W);
            FHSizeOffset := 0;
            FOldHScrollBarPos := Position;
          end;
      end
    else
      begin
        if Position > 0
        then HScrollControls(-Position);
        FHSizeOffset := 0;
        FOldHScrollBarPos := 0;
        SetRange(0, 0, 0, 0);
        if Visible
        then
          begin
            IsVisible := False;
            VisibleChanged := True;
          end;
      end;
   end;

  if (FVScrollBar <> nil) and (FHScrollBar <> nil)
  then
    begin
      if not FVScrollBar.Visible and FHScrollBar.Both
      then
        FHScrollBar.Both := False
      else
      if FVScrollBar.Visible and not FHScrollBar.Both
      then
        FHScrollBar.Both := True;
    end;

  if VisibleChanged
  then
    begin
      FInCheckScrollBars := True;
      FHScrollBar.Visible := IsVisible;
      FInCheckScrollBars := False;
      if (Align <> alNone)
      then
        begin
          FInCheckScrollBars := True;
          R := Parent.ClientRect;
          TParentControl(Parent).AlignControls(nil, R);
          R := ClientRect;
          AlignControls(nil, R);
          FInCheckScrollBars := False;
        end;
    end;
end;

procedure TbsSkinScrollBox.HScrollControls;
begin
  ScrollBy(-AOffset, 0);
  if (FIndex <> -1) and StretchEffect then RePaint;
end;

procedure TbsSkinScrollBox.AlignControls(AControl: TControl; var Rect: TRect); 
begin
  inherited;
  GetVRange;
  GetHRange;
end;

procedure TbsSkinScrollBox.SetBounds;
var
  OldHeight, OldWidth: Integer;
begin
  OldWidth := Width;
  OldHeight := Height;
  FUpdatingScrollInfo := True;
  inherited;
  if (OldWidth <> Width)
  then
    begin
      if (OldWidth < Width) and (OldWidth <> 0)
      then FHSizeOffset := Width - OldWidth
      else FHSizeOffset := 0;
    end
  else
    FHSizeOffset := 0;
  if Align <> alNone then GetHRange;
  if (OldHeight <> Height)
  then
    begin
      if (OldHeight < Height) and (OldHeight <> 0)
      then FVSizeOffset := Height - OldHeight
      else FVSizeOffset := 0;
    end
  else
    FVSizeOffset := 0;
  if Align <> alNone then GetVRange;
  FUpdatingScrollInfo := False;
end;

procedure TbsSkinScrollBox.WMNCHITTEST(var Message: TWMNCHITTEST);
begin
  Message.Result := HTCLIENT;
end;

procedure TbsSkinScrollBox.WMNCCALCSIZE;
begin
  GetSkinData;
  if (FIndex = -1) and (FBorderStyle <> bvNone) 
  then
    with Message.CalcSize_Params^.rgrc[0] do
    begin
      if FBorderStyle <> bvNone
      then
        begin
          Inc(Left, 1);
          Inc(Top, 1);
          Dec(Right, 1);
          Dec(Bottom, 1);
        end;
    end
  else
    if (BGPictureIndex = -1) and (FBorderStyle <> bvNone) then
    with Message.CalcSize_Params^.rgrc[0] do
    begin
      Inc(Left, ClRect.Left);
      Inc(Top, ClRect.Top);
      Dec(Right, RectWidth(SkinRect) - ClRect.Right);
      Dec(Bottom, RectHeight(SkinRect) - ClRect.Bottom);
    end;
end;

procedure TbsSkinScrollBox.WMNCPAINT;
var
  DC: HDC;
  C: TCanvas;
  R: TRect;
begin
  if (BGPictureIndex <> -1) or (FBorderStyle = bvNone) then Exit;
  DC := GetWindowDC(Handle);
  C := TControlCanvas.Create;
  C.Handle := DC;
  try
    PaintFrame(C);
  finally
    C.Free;
    ReleaseDC(Handle, DC);
  end;
end;

procedure TbsSkinScrollBox.PaintFrame;
var
  NewLTPoint, NewRTPoint, NewLBPoint, NewRBPoint: TPoint;
  R, NewClRect: TRect;
  LeftB, TopB, RightB, BottomB: TBitMap;
  OffX, OffY: Integer;
  AW, AH: Integer;
begin
  GetSkinData;

  if (FIndex = -1)
  then
    with C do
    begin
      if FBorderStyle <> bvNone
      then
        begin
          Brush.Style := bsClear;
          R := Rect(0, 0, Width, Height);
          case FBorderStyle of
            bvLowered: Frame3D(C, R, clBtnHighLight, clBtnShadow, 1);
            bvRaised: Frame3D(C, R, clBtnShadow, clBtnHighLight, 1);
            bvFrame: Frame3D(C, R, clBtnShadow, clBtnShadow, 1);
          end;
        end;
      Exit;
    end;

  LeftB := TBitMap.Create;
  TopB := TBitMap.Create;
  RightB := TBitMap.Create;
  BottomB := TBitMap.Create;

  OffX := Width - RectWidth(SkinRect);
  OffY := Height - RectHeight(SkinRect);
  AW := Width;
  AH := Height;

  NewLTPoint := LTPt;
  NewRTPoint := Point(RTPt.X + OffX, RTPt.Y);
  NewLBPoint := Point(LBPt.X, LBPt.Y + OffY);
  NewRBPoint := Point(RBPt.X + OffX, RBPt.Y + OffY);
  NewClRect := Rect(ClRect.Left, ClRect.Top,
                    ClRect.Right + OffX, ClRect.Bottom + OffY);

  CreateSkinBorderImages(LTPt, RTPt, LBPt, RBPt, CLRect,
      NewLtPoint, NewRTPoint, NewLBPoint, NewRBPoint, NewCLRect,
      LeftB, TopB, RightB, BottomB, Picture, SkinRect, Width, Height,
      LeftStretch, TopStretch, RightStretch, BottomStretch);

  C.Draw(0, 0, TopB);
  C.Draw(0, TopB.Height, LeftB);
  C.Draw(Width - RightB.Width, TopB.Height, RightB);
  C.Draw(0, Height - BottomB.Height, BottomB);

  TopB.Free;
  LeftB.Free;
  RightB.Free;
  BottomB.Free;
end;

procedure TbsSkinScrollBox.Paint;
var
  X, Y, XCnt, YCnt, w, h,
  rw, rh, XO, YO: Integer;
  Buffer, Buffer2: TBitMap;
  R: TRect;
  SaveIndex: Integer;
begin
  GetSkinData;
  if FIndex = -1
  then
    begin
      inherited;
      Exit;
    end;
  if (ClientWidth > 0) and (ClientHeight > 0) then
  if BGPictureIndex <> -1
  then
    begin
      Buffer := TBitMap(FSD.FActivePictures.Items[BGPictureIndex]);
      SaveIndex := SaveDC(Canvas.Handle);
      IntersectClipRect(Canvas.Handle, 0, 0, ClientWidth, ClientHeight);
      if StretchEffect
      then
        begin
          case StretchType of
            bsstFull:
              begin
                Canvas.StretchDraw(Rect(0, 0, Width, Height), Buffer);
              end;
            bsstVert:
              begin
                Buffer2 := TBitMap.Create;
                Buffer2.Width := Width;
                Buffer2.Height := Buffer.Height;
                Buffer2.Canvas.StretchDraw(Rect(0, 0, Buffer2.Width, Buffer2.Height), Buffer);
                YCnt := Height div Buffer2.Height;
                for Y := 0 to YCnt do
                  Canvas.Draw(0, Y * Buffer2.Height, Buffer2);
                Buffer2.Free;
              end;
           bsstHorz:
             begin
               Buffer2 := TBitMap.Create;
               Buffer2.Width :=  Buffer.Width;
               Buffer2.Height := Height;
               Buffer2.Canvas.StretchDraw(Rect(0, 0, Buffer2.Width, Buffer2.Height), Buffer);
               XCnt := Width div Buffer2.Width;
               for X := 0 to XCnt do
                 Canvas.Draw(X * Buffer2.Width, 0, Buffer2);
               Buffer2.Free;
             end;
          end;
        end
      else
       begin
          XCnt := Width div Buffer.Width;
          YCnt := Height div Buffer.Height;
          for X := 0 to XCnt do
          for Y := 0 to YCnt do
            Canvas.Draw(X * Buffer.Width, Y * Buffer.Height, Buffer);
        end;
      RestoreDC(Canvas.Handle, SaveIndex);
    end
  else
    begin
      SaveIndex := SaveDC(Canvas.Handle);
      IntersectClipRect(Canvas.Handle, 0, 0, ClientWidth, ClientHeight);
      Buffer := TBitMap.Create;
      Buffer.Width := RectWidth(ClRect);
      Buffer.Height := RectHeight(ClRect);
      Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height),
        Picture.Canvas,
          Rect(SkinRect.Left + ClRect.Left, SkinRect.Top + ClRect.Top,
               SkinRect.Left + ClRect.Right,
               SkinRect.Top + ClRect.Bottom));
     if StretchEffect and (Width > 0) and (Height > 0)
      then
        begin
          case StretchType of
            bsstFull:
              begin
                Canvas.StretchDraw(Rect(0, 0, Width, Height), Buffer);
              end;
            bsstVert:
              begin
                Buffer2 := TBitMap.Create;
                Buffer2.Width := Width;
                Buffer2.Height := Buffer.Height;
                Buffer2.Canvas.StretchDraw(Rect(0, 0, Buffer2.Width, Buffer2.Height), Buffer);
                YCnt := Height div Buffer2.Height;
                for Y := 0 to YCnt do
                  Canvas.Draw(0, Y * Buffer2.Height, Buffer2);
                Buffer2.Free;
              end;
           bsstHorz:
             begin
               Buffer2 := TBitMap.Create;
               Buffer2.Width := Buffer.Width;
               Buffer2.Height := Height;
               Buffer2.Canvas.StretchDraw(Rect(0, 0, Buffer2.Width, Buffer2.Height), Buffer);
               XCnt := Width div Buffer2.Width;
               for X := 0 to XCnt do
                 Canvas.Draw(X * Buffer2.Width, 0, Buffer2);
               Buffer2.Free;
             end;
          end;
        end
      else
        begin
          rw := ClientWidth;
          rh := ClientHeight;
          w := RectWidth(ClRect);
          h := RectHeight(ClRect);
          XCnt := rw div w;
          YCnt := rh div h;
          for X := 0 to XCnt do
          for Y := 0 to YCnt do
           Canvas.Draw(X * w, Y * h, Buffer);
        end;
     Buffer.Free;
     RestoreDC(Canvas.Handle, SaveIndex);
   end;
end;

procedure TbsSkinScrollBox.WMSIZE;
begin
  FUpdatingScrollInfo := True;
  inherited;
  SendMessage(Handle, WM_NCPAINT, 0, 0);
  FUpdatingScrollInfo := False;
end;

procedure TbsSkinScrollBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;


constructor TbsSkinTrackEdit.Create(AOwner: TComponent);
begin
  inherited;
  FDblClickShowTrackBar := False;
  FSupportUpdownKeys := True;
  FIncrement := 1;
  FPopupKind := tbpRight;
  FTrackBarWidth := 0;
  FTrackBarSkinDataName := 'htrackbar';
  ButtonMode := True;
  FMinValue := 0;
  FMaxValue := 100;
  FValue := 0;
  StopCheck := True;
  Text := '0';
  StopCheck := False;
  FromEdit := False;
  Width := 120;
  Height := 20;
  FSkinDataName := 'buttonedit';
  OnButtonClick := ButtonClick;
  FAlphaBlend := False;
  FAlphaBlendValue := 0;
  FPopupTrackBar := TbsSkinPopupTrackBar.Create(Self);
  FPopupTrackBar.Visible := False;
  FPopupTrackBar.TrackEdit := Self;
  FPopupTrackBar.Parent := Self;
  FPopupTrackBar.OnChange := TrackBarChange;
end;

destructor TbsSkinTrackEdit.Destroy;
begin
  FPopupTrackBar.Free;
  inherited;
end;

function TbsSkinTrackEdit.GetJumpWhenClick: Boolean;
begin
  Result := FPopupTrackBar.JumpWhenClick;
end;

procedure TbsSkinTrackEdit.SetJumpWhenClick(Value: Boolean);
begin
  FPopupTrackBar.JumpWhenClick := Value;
end;

procedure TbsSkinTrackEdit.WMMOUSEWHEEL;
begin
  if not FPopupTrackBar.Visible
  then
    begin
      if TWMMOUSEWHEEL(Message).WheelDelta > 0
      then
        Value := Value - FIncrement
      else
        Value := Value + FIncrement;
    end
  else
    begin
      if TWMMOUSEWHEEL(Message).WheelDelta > 0
      then
        FPopupTrackBar.Value := FPopupTrackBar.Value - FIncrement
      else
        FPopupTrackBar.Value := FPopupTrackBar.Value + FIncrement;
    end;
end;


procedure TbsSkinTrackEdit.CMCancelMode(var Message: TCMCancelMode);
begin
 if (Message.Sender <> FPopupTrackBar) then CloseUp;
end;

procedure TbsSkinTrackEdit.CloseUp;
begin
  if FPopupTrackbar.Visible
  then
    begin
      SetWindowPos(FPopupTrackBar.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
                   SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
      FPopupTrackBar.Visible := False;
      if CheckW2KWXP and FAlphaBlend
      then
        SetWindowLong(FPopupTrackBar.Handle, GWL_EXSTYLE,
                      GetWindowLong(Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
    end;                  
end;

procedure TbsSkinTrackEdit.DropDown;
var
  P: TPoint;
  I, X, Y: Integer;
  R: TRect;
  TickCount: DWORD;
  AnimationStep: Integer;
begin
  with FPopupTrackBar do
  begin
    if FTrackBarWidth = 0
    then
      Width := Self.Width
    else
      Width := FTrackBarWidth;
    DefaultHeight := Self.Height;
    SkinDataName := FTrackBarSkinDataName;
    SkinData := Self.SkinData;
    MinValue := Self.MinValue;
    MaxValue := Self.MaxValue;
    Value := Self.Value;
  end;

  if (PopupKind = tbpRight) or (FPopupTrackBar.Width = Self.Width)
  then
    P := Parent.ClientToScreen(Point(Left, Top))
  else
    P := Parent.ClientToScreen(Point(Left + Width - FPopupTrackBar.Width, Top));

  Y := P.Y + Height;

  R := GetMonitorWorkArea(Handle, True);

  if P.X + FPopupTrackBar.Width > R.Right
  then
    P.X := P.X - ((P.X + FPopupTrackBar.Width) - R.Right)
  else
  if P.X < R.Left then P.X := R.Left;

  if Y + FPopupTrackBar.Height > R.Bottom
  then
    Y := P.Y - FPopupTrackBar.Height;
  //
  if CheckW2KWXP and FAlphaBlend
  then
    begin
      SetWindowLong(FPopupTrackBar.Handle, GWL_EXSTYLE,
                    GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
      if FAlphaBlendAnimation
      then
        SetAlphaBlendTransparent(FPopupTrackBar.Handle, 0)
      else
        SetAlphaBlendTransparent(FPopupTrackBar.Handle, FAlphaBlendValue);
    end;
  //
  SetWindowPos(FPopupTrackBar.Handle, HWND_TOP, P.X, Y, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

  FPopupTrackBar.Visible := True;

  if FAlphaBlendAnimation and FAlphaBlend and CheckW2KWXP
  then
    begin
      Application.ProcessMessages;
      I := 0;
      TickCount := 0;
      AnimationStep := FAlphaBlendValue div 15;
      if AnimationStep = 0 then AnimationStep := 1;
      repeat
        if (GetTickCount - TickCount > 5)
        then
          begin
            TickCount := GetTickCount;
            Inc(i, AnimationStep);
            if i > FAlphaBlendValue then i := FAlphaBlendValue;
            SetAlphaBlendTransparent(FPopupTrackBar.Handle, i);
          end;
      until i >= FAlphaBlendValue;
    end;
    
end;

procedure TbsSkinTrackEdit.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  if FDblClickShowTrackBar then
    if not FPopupTrackBar.Visible then DropDown;
end;

procedure TbsSkinTrackEdit.ButtonClick(Sender: TObject);
begin
  SetFocus;
  if not FPopupTrackBar.Visible then DropDown else CloseUp;
end;

function TbsSkinTrackEdit.CheckValue;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue)
  then
    begin
      if NewValue < FMinValue then
      Result := FMinValue
      else if NewValue > FMaxValue then
      Result := FMaxValue;
    end;
end;

procedure TbsSkinTrackEdit.SetMinValue;
begin
  FMinValue := AValue;
end;

procedure TbsSkinTrackEdit.SetMaxValue;
begin
  FMaxValue := AValue;
end;

function TbsSkinTrackEdit.IsNumText;

function GetMinus: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  i := Pos('-', S);
  if i > 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos('-', S) = 0;
    end;
end;

const
  EditChars = '01234567890-';
var
  i: Integer;
  S: String;
begin
  S := EditChars;
  Result := True;
  if (Text = '') or (Text = '-')
  then
    begin
      Result := False;
      Exit;
    end;

  for i := 1 to Length(Text) do
  begin
    if Pos(Text[i], S) = 0
    then
      begin
        Result := False;
        Break;
      end;
  end;

  Result := Result and GetMinus;
end;

procedure TbsSkinTrackEdit.Change;
var
  NewValue, TmpValue: Integer;

function CheckInput: Boolean;
begin
  if (NewValue < 0) and (TmpValue < 0)
  then
    Result := NewValue > TmpValue
  else
    Result := NewValue < TmpValue;

  if not Result and ( ((FMinValue > 0) and (TmpValue < 0))
    or ((FMinValue < 0) and (TmpValue > 0)))
  then
    Result := True;
end;

begin
  if FromEdit then Exit;
  if not StopCheck and IsNumText(Text)
  then
    begin
      TmpValue := StrToInt(Text);
      NewValue := CheckValue(TmpValue);
      if NewValue <> FValue
      then
        begin
          FValue := NewValue;
        end;
      if CheckInput
      then
        begin
           FromEdit := True;
           Text := IntToStr(Round(NewValue));
           FromEdit := False; 
        end;
    end;
  inherited;  
end;

procedure TbsSkinTrackEdit.SetValue;
begin
  FValue := CheckValue(AValue);
  StopCheck := True;
  Text := IntToStr(Round(CheckValue(AValue)));
  if FPopupTrackBar.Visible then FPopupTrackBar.Value := FValue;
  StopCheck := False;
end;

procedure TbsSkinTrackEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if FSupportUpDownKeys then 
  if not FPopupTrackBar.Visible
  then
    begin
      if Key = VK_UP
      then
        Value := Value + FIncrement
      else
      if Key = VK_DOWN
      then
        Value := Value - FIncrement;
     end
  else
    begin
       if Key = VK_UP
      then
        FPopupTrackBar.Value := FPopupTrackBar.Value + FIncrement
      else
      if Key = VK_DOWN
      then
        FPopupTrackBar.Value := FPopupTrackBar.Value - FIncrement
    end;
end;

procedure TbsSkinTrackEdit.KeyPress(var Key: Char);
begin
  if Key = Char(VK_ESCAPE)
  then
    begin
      if FPopupTrackBar.Visible then CloseUp; 
    end
  else  
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  inherited KeyPress(Key);
end;

function TbsSkinTrackEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in ['-', '0'..'9']) or
            ((Key < #32) and (Key <> Chr(VK_RETURN)));

  if (Key = '-') and (Pos('-', Text) <> 0)
  then
    Result := False;

  if ReadOnly and Result and ((Key >= #32) or
     (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE)))
  then                
    Result := False;
end;

procedure TbsSkinTrackEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  CloseUp;
  //
  StopCheck := True;
  Text := IntToStr(FValue);
  StopCheck := False;
  //
end;

procedure TbsSkinTrackEdit.TrackBarChange(Sender: TObject);
begin
  if Value <> FPopupTrackBar.Value
  then
    Value := FPopupTrackBar.Value;
end;

constructor TbsSkinPopupTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable];
  SkinDataName := 'htrackbar';
end;

procedure TbsSkinPopupTrackBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW;
    WindowClass.Style := CS_SAVEBITS;
    if CheckWXP then
      WindowClass.Style := WindowClass.style or CS_DROPSHADOW_;
  end;
end;

procedure TbsSkinPopupTrackBar.WMMouseActivate(var Message: TMessage);
begin
  Message.Result := MA_NOACTIVATE;
end;

constructor TbsSkinTimeEdit.Create(AOwner: TComponent);
begin
  inherited;
  FUpDown := nil;
  FShowUpDown := False;
  FShowMSec := False;
  FShowSec := True;
  EditMask := '!90:00:00;1; ';
  Text := '00' + {$IFDEF VER240_UP}FormatSettings.{$ENDIF}TimeSeparator + '00' + {$IFDEF VER240_UP}FormatSettings.{$ENDIF}TimeSeparator + '00';
  OnKeyPress := HandleOnKeyPress;
end;

destructor TbsSkinTimeEdit.Destroy;
begin
  if FUpDown <> nil then FreeAndNil(FUpDown);
  inherited;
end;

procedure TbsSkinTimeEdit.WMMOUSEWHEEL(var Message: TMessage); 
begin
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    UpButtonClick(Self)
  else
    DownButtonClick(Self);
end;

function TbsSkinTimeEdit.GetIncIndex: Integer;
var
  i, j, k: Integer;
  S: String;
begin
  j := Self.SelStart;
  k := 0;
  S := Text;
  for i := 1 to j do
  begin
    if S[i] = {$IFDEF VER240_UP}FormatSettings.{$ENDIF}TimeSeparator then inc(k);
  end;
  Result := k;
end;


procedure TbsSkinTimeEdit.UpButtonClick(Sender: TObject);
var
  k, i: Integer;
  Hour, Min, Sec, MSec: Word;
begin
  if not Focused then SetFocus;
  DecodeTime(Hour, Min, Sec, MSec);
  k := GetIncIndex;
  i := SelStart;
  case k of
    0:
      begin
        if Hour = 23 then Hour := 0 else Inc(Hour);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    1:
      begin
        if Min = 59 then Min := 0 else Inc(Min);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    2:
      if FShowSec then
      begin
        if Sec = 59 then Sec := 0 else Inc(Sec);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    3:
      if FShowMSec then
      begin
        if MSec = 99 then MSec := 0 else Inc(MSec);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
  end;
  SelStart := i;
end;

procedure TbsSkinTimeEdit.DownButtonClick(Sender: TObject);
var
  k, i: Integer;
  Hour, Min, Sec, MSec: Word;
begin
  if not Focused then SetFocus;
  DecodeTime(Hour, Min, Sec, MSec);
  k := GetIncIndex;
  i := SelStart;
  case k of
    0:
      begin
        if Hour = 0 then Hour := 23 else  Dec(Hour);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    1:
      begin
        if Min = 0 then Min := 59 else Dec(Min);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    2:
      if FShowSec then
      begin
        if Sec = 0 then Sec := 59 else Dec(Sec);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
    3:
      if FShowMSec then
      begin
        if MSec = 0 then MSec := 99 else Dec(MSec);
        EncodeTime(Hour, Min, Sec, MSec);
      end;
  end;
  SelStart := i;
end;

procedure TbsSkinTimeEdit.ChangeSkinData;
begin
  inherited;
  if FUpDown <> nil
  then
    begin
      FUpDown.SkinData := Self.SkinData;
      AdjustUpDown;
    end;
end;

procedure TbsSkinTimeEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  AdjustUpDown;
end;

procedure TbsSkinTimeEdit.AdjustUpDown;
begin
  if FUpDown = nil then Exit;
  FUpDown.SetBounds(Self.ClientWidth - Self.ClientHeight, 0,
    Self.ClientHeight, Self.ClientHeight);
end;


procedure TbsSkinTimeEdit.ShowUpDownControl;
begin
  if FUpDown <> nil then Exit;
  ControlStyle := ControlStyle + [csAcceptsControls];
  FUpDown := TbsSkinIntUpDown.Create(Self);
  with FUpDown do
  begin
    OnUpButtonClick := UpButtonClick;
    OnDownButtonClick := DownButtonClick;
    FOnUpChange := UpButtonClick;
    FOnDownChange := DownButtonClick;
    SkinDataName := 'resizetoolbutton';
    SkinData := Self.Skindata;
    Orientation := udVertical;
    UseSkinSize := False;
    AdjustUpDown;
    Parent := Self;
  end;
end;

procedure TbsSkinTimeEdit.HideUpDownControl;
begin
  if FUpDown = nil then Exit;
  ControlStyle := ControlStyle - [csAcceptsControls];
  FUpDown.Visible := False;
  FreeAndNil(FUpDown);
end;

procedure TbsSkinTimeEdit.SetShowUpDown;
begin
  FShowUpDown := Value;
  if FShowUpDown then ShowUpDownControl else HideUpDownControl;
end;


procedure TbsSkinTimeEdit.ValidateEdit;
var
  Str: string;
  Pos: Integer;
begin
  Str := EditText;
  if IsMasked and Modified then
  begin
    if not Validate(Str, Pos) then
    begin
    end;
  end;  
end;

procedure TbsSkinTimeEdit.CheckSpace(var S: String);
var
  i: Integer;
begin
  for i := 0 to Length(S) do
  begin
    if S[i] = ' ' then S[i] := '0';
  end;
end;

procedure TbsSkinTimeEdit.HandleOnKeyPress(Sender: TObject; var Key: Char);
var
  TimeStr: string;
  aHour, aMinute, aSecond, aMillisecond: Word;
  aHourSt, aMinuteSt, aSecondSt, aMillisecondSt: string;
begin
   if (Key <> #13) and (Key <> #8)
   then
   begin
   TimeStr := Text;
   if SelLength > 1 then SelLength := 1;
   if IsValidChar(Key)
   then
     begin
       Delete(TimeStr,SelStart + 1, 1);
       Insert(string(Key), TimeStr, SelStart + 1);
     end;
      try
         aHourSt := Copy(TimeStr, 1, 2);
         CheckSpace(aHourSt);

         aMinuteSt := Copy(TimeStr, 4, 2);
         CheckSpace(aMinuteSt);

         if FShowSec
         then
           aSecondSt := Copy(TimeStr, 7, 2)
         else
           aSecondSt := '0';
         CheckSpace(aSecondSt);

         if fShowMSec then begin
            aMillisecondSt := Copy(TimeStr, 10, 3);
         end else begin
            aMillisecondSt := '0';
         end;
         CheckSpace(aMillisecondSt);

         aHour := StrToInt(aHourSt);
         aMinute := StrToInt(aMinuteSt);
         aSecond := StrToInt(aSecondSt);
         aMillisecond := StrToInt(aMillisecondSt);
         if not IsValidTime(aHour, aMinute, aSecond, aMillisecond) then begin
            Key := #0;
         end;
      except
         Key := #0;
      end;
   end;
end;

procedure TbsSkinTimeEdit.SetShowSeconds(const Value: Boolean);
begin
  if FShowSec <> Value
  then
    begin
      FShowSec := Value;
      if FShowSec
      then
        begin
          if FShowMSec
          then
            begin
              EditMask := '!90:00:00.000;1; ';
              Text := '00:00:00.000';
            end
          else
           begin
             EditMask := '!90:00:00;1; ';
             Text := '00:00:00';
           end;
        end
      else
        begin
          EditMask := '!90:00;1; ';
          Text := '00:00';
        end;
    end;    
end;

procedure TbsSkinTimeEdit.SetShowMilliseconds(const Value: Boolean);
begin
   if FShowMSec <> Value
   then
     begin
       FShowMSec := Value;
       if fShowMSec
       then
         begin
           EditMask := '!90:00:00.000;1; ';
           Text := '00:00:00.000';
         end
       else
         begin
           EditMask := '!90:00:00;1; ';
           Text := '00:00:00';
         end;
   end;
end;

procedure TbsSkinTimeEdit.SetMilliseconds(const Value: Integer);
var
   aHour, aMinute, aSecond, aMillisecond: Integer;
   St: string;
begin
   aSecond := Value div 1000;
   aMillisecond := Value mod 1000;
   aMinute := aSecond div 60;
   aSecond := aSecond mod 60;
   aHour := aMinute div 60;
   aMinute := aMinute mod 60;
   St := Format('%2.2d:%2.2d:%2.2d.%3.3d', [aHour, aMinute, aSecond, aMillisecond]);
   try
     Text := St;
   except
      Text := '00:00:00.000';
   end;
end;

function TbsSkinTimeEdit.GetMilliseconds: Integer;
var
   TimeStr: string;
   aHour, aMinute, aSecond, aMillisecond: Integer;
   aHourSt, aMinuteSt, aSecondSt, aMillisecondSt: string;
begin
   TimeStr := Text;
   try
      aHourSt := Copy(TimeStr, 1, 2);
      CheckSpace(aHourSt);
      aMinuteSt := Copy(TimeStr, 4, 2);
      CheckSpace(aMinuteSt);
      aSecondSt := Copy(TimeStr, 7, 2);
      CheckSpace(aSecondSt);
      aMillisecondSt := Copy(TimeStr, 10, 3);
      CheckSpace(aMillisecondSt);
      aHour := StrToInt(aHourSt);
      aMinute := StrToInt(aMinuteSt);
      aSecond := StrToInt(aSecondSt);
      aMillisecond := StrToInt(aMillisecondSt);
      Result := ((((aHour * 60) + aMinute) * 60) + aSecond) * 1000 + aMillisecond;
   except
      Result := 0;
   end;
end;

procedure TbsSkinTimeEdit.SetTime(const Value: string);
var
   TimeStr: string;
   aHour, aMinute, aSecond, aMillisecond: Integer;
   aHourSt, aMinuteSt, aSecondSt, aMillisecondSt: string;
begin

   TimeStr := Value;
   try
      aHourSt := Copy(TimeStr, 1, 2);
      CheckSpace(aHourSt);
      aMinuteSt := Copy(TimeStr, 4, 2);
      CheckSpace(aMinuteSt);
      if FShowSec
      then
        begin
          aSecondSt := Copy(TimeStr, 7, 2);
          CheckSpace(aSecondSt);
        end
      else
        aSecondSt := '0';

      aHour := StrToInt(aHourSt);
      aMinute := StrToInt(aMinuteSt);
      aSecond := StrToInt(aSecondSt);

      if fShowMSec
      then
        begin
          aMillisecondSt := Copy(TimeStr, 10, 3);
          CheckSpace(aMillisecondSt);
          aMillisecond := StrToInt(aMillisecondSt);
          Text := Format('%2.2d:%2.2d:%2.2d.%3.3d', [aHour, aMinute, aSecond, aMillisecond]);
        end
      else
        begin
          if FShowSec
          then
            Text := Format('%2.2d:%2.2d:%2.2d', [aHour, aMinute, aSecond])
          else
            Text := Format('%2.2d:%2.2d', [aHour, aMinute]);
        end;
   except
      if fShowMSec
      then
        begin
          Text := '00:00:00.000';
        end
      else
        begin
          if FShowSec
          then
            Text := '00:00:00'
          else
            Text := '00:00';
        end;
   end;
end;

function TbsSkinTimeEdit.GetTime: string;
begin
  Result := Text;
end;

function TbsSkinTimeEdit.IsValidTime(const AHour, AMinute, ASecond, AMilliSecond: Word): Boolean;
begin
  Result := ((AHour < 24) and (AMinute < 60) and
             (ASecond < 60) and (AMilliSecond < 1000)) or
            ((AHour = 24) and (AMinute = 0) and
             (ASecond = 0) and (AMilliSecond = 0));
end;

function TbsSkinTimeEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := Key in ['0'..'9'];
end;

procedure TbsSkinTimeEdit.SetValidTime(var H, M, S, MS: Word);
begin
  if H > 23 then H := 23;
  if M > 59 then M := 59;
  if S > 59 then S := 59;
  if MS > 999 then MS := 999;
end;

function TbsSkinTimeEdit.ValidateParameter;
var
  I: Integer;

begin
  Result := S;
  if Length(S) <> MustLen
  then
    begin
      for i := 1 to MustLen do S[i] := '0';
      Exit;
    end;
  for I := 1 to Length(s) do
    if not IsValidChar(S[I])
    then
      begin
        Result := '00';
        Break;
      end;
end;

procedure TbsSkinTimeEdit.DecodeTime(var Hour, Min, Sec, MSec: Word);
var
  TimeStr: string;
  aHourSt, aMinuteSt, aSecondSt, aMillisecondSt: string;
begin
  TimeStr := Text;
  aHourSt := Copy(TimeStr, 1, 2);
  CheckSpace(aHourSt);
  aMinuteSt := Copy(TimeStr, 4, 2);
  CheckSpace(aMinuteSt);
  if FShowSec
  then
    aSecondSt := Copy(TimeStr, 7, 2)
  else
    aSecondSt := '00';

  CheckSpace(aSecondSt);

  aHourSt := ValidateParameter(aHourSt, 2);
  aMinuteSt := ValidateParameter(aMinuteSt, 2);
  aSecondSt := ValidateParameter(aSecondSt, 2);

  Hour := StrToInt(aHourSt);
  Min := StrToInt(aMinuteSt);
  Sec := StrToInt(aSecondSt);

  if fShowMSec
  then
    aMillisecondSt := Copy(TimeStr, 10, 3)
  else
    aMillisecondSt := '000';

  CheckSpace(aMillisecondSt);
  aMillisecondSt := ValidateParameter(aMillisecondSt, 3);
  Msec := StrToInt(aMillisecondSt);
  SetValidTime(Hour, Min, Sec, MSec);
end;


procedure TbsSkinTimeEdit.EncodeTime(Hour, Min, Sec, MSec: Word);
begin
  if not IsValidTime(Hour, Min, Sec, MSec) then Exit;
  try
    if fShowMSec
    then
      Text := Format('%2.2d:%2.2d:%2.2d.%3.3d', [Hour, Min, Sec, MSec])
    else
      if FShowSec
      then
        Text := Format('%2.2d:%2.2d:%2.2d', [Hour, Min, Sec])
      else
        Text := Format('%2.2d:%2.2d', [Hour, Min]);
  except
    if fShowMSec
    then
      Text := '00:00:00.000'
    else
      if FShowSec
      then
        Text := '00:00:00'
      else
        Text := '00:00';
  end;
end;

constructor TbsSkinPasswordEdit.Create(AOwner: TComponent); 
begin
  inherited;
  FDefaultColor := clWindow;
  Text := '';
  FMouseIn := False;
  SkinDataName := 'edit';
  Width := 121;
  Height := 21;
  TabStop := True;
  FTextAlignment := taLeftJustify;
  FAutoSelect := True;
  FCharCase := ecNormal;
  FHideSelection := True;
  FMaxLength := 0;
  FReadOnly := False;
  FLMouseSelecting := False;
  FCaretPosition := 0;
  FSelStart := 0;
  FSelLength := 0;
  FFVChar := 1;
  ControlStyle := ControlStyle + [csCaptureMouse] - [csSetCaption];
  Cursor := Cursor;
end;

destructor TbsSkinPasswordEdit.Destroy;
begin
  inherited;
end;

procedure TbsSkinPasswordEdit.SetDefaultColor(Value: TColor);
begin
  FDefaultColor := Value;
  if FIndex = -1 then Invalidate;
end;

function TbsSkinPasswordEdit.GetPaintText;
begin
  Result := Text;
end;

procedure TbsSkinPasswordEdit.CalcSize(var W, H: Integer);
var
  H1: Integer;
begin
  H1 := H;
  inherited;
  if not FUseSkinFont then H := H1; 
end;

procedure TbsSkinPasswordEdit.PasteFromClipboard;
var
  Data: THandle;
  Insertion: WideString;
begin
  if ReadOnly then Exit;

  if Clipboard.HasFormat(CF_UNICODETEXT)
  then
    begin
      Data := Clipboard.GetAsHandle(CF_UNICODETEXT);
      try
        if Data <> 0
        then
          Insertion := PWideChar(GlobalLock(Data));
      finally
        if Data <> 0 then GlobalUnlock(Data);
      end;
    end
  else
    Insertion := Clipboard.AsText;

  InsertText(Insertion);
end;

procedure TbsSkinPasswordEdit.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinEditControl
    then
      with TbsDataSkinEditControl(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.SkinRect := SkinRect;
        Self.ActiveSkinRect := ActiveSkinRect;
        if IsNullRect(ActiveSkinRect)
        then
          Self.ActiveSkinRect := SkinRect;
        LOffset := LTPoint.X;
        ROffset := RectWidth(SkinRect) - RTPoint.X;
        CharColor := FontColor;
        CharDisabledColor := DisabledFontColor;
        CharActiveColor := ActiveFontColor;
      end;
end;

procedure TbsSkinPasswordEdit.CreateControlSkinImage(B: TBitMap);
var
  Buffer: TBitMap;
begin

  if FUseSkinFont
  then
    begin
      if FMouseIn or Focused
      then
        CreateHSkinImage(LOffset, ROffset, B, Picture, ActiveSkinRect, Width,
          RectHeight(ActiveSkinRect), StretchEffect)
      else
        CreateHSkinImage(LOffset, ROffset, B, Picture, SkinRect, Width,
          RectHeight(SkinRect), StretchEffect);
    end
  else
    begin
      Buffer := TBitMap.Create;
      Buffer.Width := Self.Width;
      Buffer.Height := RectHeight(SkinRect);
      if FMouseIn or Focused
      then
        CreateHSkinImage(LOffset, ROffset, Buffer, Picture, ActiveSkinRect, Width,
          RectHeight(ActiveSkinRect), StretchEffect)
      else
        CreateHSkinImage(LOffset, ROffset, Buffer, Picture, SkinRect, Width,
          RectHeight(SkinRect), StretchEffect);
      B.Canvas.StretchDraw(Rect(0, 0, B.Width, B.Height), Buffer);
      Buffer.Free;
    end;


  if Focused or not HideSelection
  then
    with B.Canvas do
    begin
      Brush.Color := clHighlight;
      FillRect(GetSelRect);
    end;

  PaintText(B.Canvas);

  if Focused or not HideSelection
  then
    PaintSelectedText(B.Canvas);
end;

procedure TbsSkinPasswordEdit.CreateControlDefaultImage(B: TBitMap);
var
  R: TRect;
begin
  R := Rect(0, 0, Width, Height);
  with B.Canvas do
  begin
    Brush.Color := FDefaultColor;
    FillRect(R);
    Frame3D(B.Canvas, R, clBtnShadow, clBtnShadow, 1);
    Frame3D(B.Canvas, R, FDefaultColor, FDefaultColor, 1);
  end;

  if Focused or not HideSelection
  then
    with B.Canvas do
    begin
      Brush.Color := clHighlight;
      FillRect(GetSelRect);
    end;

  PaintText(B.Canvas);

  if Focused or not HideSelection
  then
    PaintSelectedText(B.Canvas);
end;

procedure TbsSkinPasswordEdit.Loaded;
begin
  inherited;
end;

procedure TbsSkinPasswordEdit.WMSETFOCUS(var Message: TWMSETFOCUS);
begin
  inherited;
  UpdateCarete;
  CaretPosition := 0;
  if AutoSelect then SelectAll;
end;

procedure TbsSkinPasswordEdit.WMKILLFOCUS(var Message: TWMKILLFOCUS);
begin
  inherited;
  DestroyCaret;
  Invalidate;
end;

function TbsSkinPasswordEdit.GetCharX(a: Integer): Integer;
var
  WTextWidth : Integer;
  ERWidth : Integer;
begin
  Result := GetEditRect.Left;
  WTextWidth := Length(Text) * GetPasswordFigureWidth;
  if a > 0
  then
    begin
      if a <= Length(Text)
      then Result := Result + (a - FFVChar + 1) * GetPasswordFigureWidth
      else Result := Result + (Length(Text) - FFVChar + 1) * GetPasswordFigureWidth;
  end;
  ERWidth := GetEditRect.Right - GetEditRect.Left;
  if WTextWidth < ERWidth
  then
    case TextAlignment of
      taRightJustify : Result := Result + (ERWidth - WTextWidth);
      taCenter : Result := Result + ((ERWidth - WTextWidth) div 2);
    end;
end;

function TbsSkinPasswordEdit.GetCPos(x: Integer): Integer;
var
  TmpX,
  WTextWidth,
  ERWidth : Integer;
begin
  Result := FFVChar - 1;
  if Length(Text) = 0 then  Exit;
  WTextWidth := Length(Text) * GetPasswordFigureWidth;

  ERWidth := GetEditRect.Right - GetEditRect.Left;
  TmpX := x;

  if WTextWidth < ERWidth
  then
    case TextAlignment of
      taRightJustify : TmpX := x - (ERWidth - WTextWidth);
      taCenter : TmpX := x - ((ERWidth - WTextWidth) div 2);
    end;

  Result := Result + (TmpX - GetEditRect.Left) div GetPasswordFigureWidth;
  if Result < 0
  then
    Result := 0
  else
    if Result > Length(Text)
    then
      Result := Length(Text);
end;

function TbsSkinPasswordEdit.GetEditRect: TRect;
begin
  if FIndex = -1
  then
    Result := Rect(2, 2, Width - 2, Height - 2)
  else
    begin
      Result := NewClRect;
      Result.Left := Result.Left + 2;
      if not FUseSkinFont
      then
        Inc(Result.Bottom, Height - RectHeight(SkinRect));
    end;
end;

function TbsSkinPasswordEdit.GetAlignmentFlags: Integer;
begin
  case FTextAlignment of
    taCenter: Result := DT_CENTER;
    taRightJustify: Result := DT_RIGHT;
  else
    Result := DT_LEFT;
  end;
end;

procedure TbsSkinPasswordEdit.KeyDown(var Key: word; Shift: TShiftState);
var
  TmpS: String;
  OldCaretPosition: Integer;
begin
  inherited KeyDown(Key, Shift);
  OldCaretPosition := CaretPosition;
  case Key of

    Ord('v'), Ord('V'):
      if Shift = [ssCtrl] then PasteFromClipboard;

    VK_INSERT:
      if Shift = [ssShift] then PasteFromClipboard;

    VK_END: CaretPosition := Length(Text);

    VK_HOME: CaretPosition := 0;

    VK_LEFT:
      if ssCtrl in Shift then
        CaretPosition := GetPrivWPos(CaretPosition)
      else
        CaretPosition := CaretPosition - 1;

    VK_RIGHT:
      if ssCtrl in Shift
      then
        CaretPosition := GetNextWPos(CaretPosition)
      else
        CaretPosition := CaretPosition + 1;

    VK_DELETE, 8:
      if not ReadOnly
      then
        begin
          if SelLength <> 0
          then
            ClearSelection
          else
            begin
              TmpS := Text;
              if TmpS <> ''
              then
                if Key = VK_DELETE
                then
                  Delete(TmpS, CaretPosition + 1, 1)
                else
                  begin
                    Delete(TmpS, CaretPosition, 1);
                    CaretPosition := CaretPosition - 1;
                  end;
               Text := TmpS;
            end;
        end;
  end;

  if Key in [VK_END, VK_HOME, VK_LEFT, VK_RIGHT]
  then
    begin
      if ssShift in Shift
      then
        begin
          if SelLength = 0
          then
            FSelStart := OldCaretPosition;
          FSelStart := CaretPosition;
          FSelLength := FSelLength - (CaretPosition - OldCaretPosition);
        end
      else
        FSelLength := 0;
     Invalidate;
   end;
  UpdateCaretePosition;
end;

procedure TbsSkinPasswordEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Ord(Key) >= 32) and not ReadOnly then InsertChar(Key);
end;

procedure TbsSkinPasswordEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft
  then
    FLMouseSelecting := True;
  SetFocus;
  if Button = mbLeft
  then
    begin
      CaretPosition := GetCPos(x);
      SelLength := 0;
    end;
end;

procedure TbsSkinPasswordEdit.PaintText;
var
  TmpRect, CR: TRect;
  CurChar: Integer;
  LPWCharWidth: Integer;
  S: String;
begin
  TmpRect := GetEditRect;
  LPWCharWidth := GetPasswordFigureWidth;
  if csPaintCopy in ControlState
  then
    begin
      S := GetPaintText
    end
  else
    S := Text;
  for CurChar := 0 to Length(S) - FFVChar do
  begin
    CR := Rect(CurChar * LPWCharWidth + GetCharX(0), TmpRect.Top,
     (CurChar + 1) * LPWCharWidth + GetCharX(0), TmpRect.Bottom);
    if CR.Right <= TmpRect.Right
    then
      DrawPasswordChar(CR, False, Cnv);
  end;
end;

procedure TbsSkinPasswordEdit.UpdateFVC;
var
  LEditRect: TRect;
begin
  if FFVChar >= (FCaretPosition + 1)
  then
    begin
      FFVChar := FCaretPosition;
      if FFVChar < 1 then FFVChar := 1;
    end
  else
    begin
      LEditRect := GetEditRect;
      while ((FCaretPosition - FFVChar + 1) * GetPasswordFigureWidth >
        LEditRect.Right - LEditRect.Left) and (FFVChar < Length(Text)) do
        Inc(FFVChar)
      end;
  Invalidate;
end;

procedure TbsSkinPasswordEdit.MouseMove(Shift: TShiftState; x, y: Integer);
var
  OldCaretPosition: Integer;
  TmpNewPosition : Integer;
begin
  inherited;
  if FLMouseSelecting
  then
    begin
      TmpNewPosition := GetCPos(x);
      OldCaretPosition := CaretPosition;
      if (x > GetEditRect.Right)
      then
        CaretPosition := TmpNewPosition +1
      else
        CaretPosition := TmpNewPosition;
      if SelLength = 0 then FSelStart := OldCaretPosition;
      FSelStart := CaretPosition;
      FSelLength := FSelLength - (CaretPosition - OldCaretPosition);
    end;
end;

procedure TbsSkinPasswordEdit.MouseUp(Button: TMouseButton; Shift: TShiftState;
  x, y: Integer);
begin
  inherited;
  FLMouseSelecting := false;
end;

procedure TbsSkinPasswordEdit.PaintSelectedText;
var
  TmpRect, CR: TRect;
  CurChar: Integer;
  LPWCharWidth: Integer;
begin
  TmpRect := GetSelRect;
  LPWCharWidth := GetPasswordFigureWidth;
  for CurChar := 0 to Length(GetVisibleSelText) - 1 do
  begin
    CR := Rect(CurChar * LPWCharWidth + TmpRect.Left,
     TmpRect.Top, (CurChar + 1) * LPWCharWidth + TmpRect.Left, TmpRect.Bottom);
    if CR.Right <= TmpRect.Right
    then
      DrawPasswordChar(CR, True, Cnv);
  end;
end;

function TbsSkinPasswordEdit.GetVisibleSelText: String;
begin
  if SelStart + 1 >= FFVChar
  then Result := SelText
  else Result := Copy(SelText, FFVChar - SelStart, Length(SelText) - (FFVChar - SelStart) + 1);
end;

function TbsSkinPasswordEdit.GetNextWPos(StartPosition: Integer): Integer;
var
  SpaceFound,
    WordFound: Boolean;
begin
  Result := StartPosition;
  SpaceFound := false;
  WordFound := false;
  while (Result + 2 <= Length(Text)) and
    ((not ((Text[Result + 1] <> ' ') and SpaceFound))
    or not WordFound) do
  begin
    if Text[Result + 1] = ' ' then
      SpaceFound := true;
    if Text[Result + 1] <> ' ' then begin
      WordFound := true;
      SpaceFound := false;
    end;

    Result := Result + 1;
  end;
  if not SpaceFound then
    Result := Result + 1;
end;

function TbsSkinPasswordEdit.GetPrivWPos(StartPosition: Integer): Integer;
var
  WordFound: Boolean;
begin
  Result := StartPosition;
  WordFound := false;
  while (Result > 0) and
    ((Text[Result] <> ' ') or not WordFound) do
  begin
    if Text[Result] <> ' ' then
      WordFound := true;
    Result := Result - 1;
  end;
end;

procedure TbsSkinPasswordEdit.ClearSelection;
var
  TmpS: String;
begin
  if ReadOnly then Exit;
  TmpS := Text;
  Delete(TmpS, SelStart + 1, SelLength);
  Text := TmpS;
  CaretPosition := SelStart;
  SelLength := 0;
end;

procedure TbsSkinPasswordEdit.SelectAll;
begin
  SetCaretPosition(Length(Text));
  SelStart := 0;
  SelLength := Length(Text);
  Invalidate;
end;

procedure TbsSkinPasswordEdit.DrawPasswordChar(SymbolRect: TRect; Selected: Boolean; Cnv: TCanvas);
var
  R: TRect;
  C: TColor;
begin

  if not Enabled
  then
    begin
      if FIndex = -1
      then C := clGrayText
      else C := CharDisabledColor; 
    end
  else
  if Selected
  then
    C := clHighlightText
  else
    if FIndex = -1
    then
      C := DefaultFont.Color
    else
      begin
        if FMouseIn or Focused
        then
          C := CharActiveColor
        else
          C := CharColor;
      end;
  R := SymbolRect;

  InflateRect(R, -2, - (RectHeight(R) - RectWidth(R)) div 2 - 2);
  with Cnv do
  case FPasswordKind of
    pkRect:
      begin
        Brush.Color := C;
        FillRect(R);
      end;
    pkRoundRect:
      begin
        Brush.Color := C;
        Pen.Color := C;
        RoundRect(R.Left, R.Top + 1, R.Right, R.Bottom, RectWidth(R) div 2, Font.Color);
      end;
    pkTriangle:
      begin
        R := Rect(0, 0, RectWidth(R), RectWidth(R));
        if not Odd(RectWidth(R)) then R.Right := R.Right + 1;
        RectToCenter(R, SymbolRect);
        Pen.Color := C;
        Brush.Color := C;
        Polygon([
          Point(R.Left + RectWidth(R) div 2 + 1, R.Top),
          Point(R.Right, R.Bottom),
          Point(R.Left, R.Bottom)]);
      end;
    end;
end;

procedure TbsSkinPasswordEdit.SelectWord;
begin
  SelStart := GetPrivWPos(CaretPosition);
  SelLength := GetNextWPos(SelStart) - SelStart;
  CaretPosition := SelStart + SelLength;
end;

procedure TbsSkinPasswordEdit.UpdateCarete;
var
  R: TRect;
begin
  GetSkinData;
  if FIndex = -1
  then
    CreateCaret(Handle, 0, 0, Height - 4)
  else
    begin
      if FUseSkinFont
      then
        CreateCaret(Handle, 0, 0, RectHeight(NewClRect))
      else
        begin
          R := NewClRect;
          Inc(R.Bottom, Height - RectHeight(SkinRect));
          CreateCaret(Handle, 0, 0, RectHeight(R))
        end;  
    end;
  CaretPosition := FCaretPosition;
  ShowCaret;
end;

procedure TbsSkinPasswordEdit.HideCaret;
begin
  Windows.HideCaret(Handle);
end;

procedure TbsSkinPasswordEdit.ShowCaret;
begin
  if not (csDesigning in ComponentState) and Focused
  then
    Windows.ShowCaret(Handle);
end;

function TbsSkinPasswordEdit.GetPasswordFigureWidth: Integer;
begin
  Result := RectHeight(GetEditRect) div 2 + 3;
end;

procedure TbsSkinPasswordEdit.Change;
begin
  inherited Changed;
  if Enabled and HandleAllocated then SetCaretPosition(CaretPosition);
  if Assigned(FOnChange) then  FOnChange(Self);
end;

procedure TbsSkinPasswordEdit.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TbsSkinPasswordEdit.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  FLMouseSelecting := false;
  SelectWord;
end;

procedure TbsSkinPasswordEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Font.Assign(Font);
  UpdateCarete;
end;

function TbsSkinPasswordEdit.GetText: String;
begin
  Result := FText;
end;

procedure TbsSkinPasswordEdit.SetText(const Value: String);
var
  S, S1: String;
begin
  if not ValidText(Value) then Exit;
  S := Value;
  S1 := Text;
  if (Value <> '') and (CharCase <> ecNormal)
  then
    case CharCase of
      ecUpperCase: FText := AnsiUpperCase(S);
      ecLowerCase: FText := AnsiLowerCase(S);
    end
  else
    FText := S;
  Invalidate;
  if S <> S1 then Change;
end;

procedure TbsSkinPasswordEdit.SetCaretPosition(const Value: Integer);
begin
  if Value < 0
  then
    FCaretPosition := 0
  else
    if Value > Length(Text)
    then
      FCaretPosition := Length(Text)
    else
      FCaretPosition := Value;
  UpdateFVC;
  if SelLength <= 0 then FSelStart := Value;
  if Focused then SetCaretPos(GetCharX(FCaretPosition), GetEditRect.Top);
end;

procedure TbsSkinPasswordEdit.SetSelLength(const Value: Integer);
begin
  if FSelLength <> Value
  then
    begin
      FSelLength := Value;
      Invalidate;
    end;
end;

procedure TbsSkinPasswordEdit.SetSelStart(const Value: Integer);
begin
  if FSelStart <> Value
  then
    begin
      SelLength := 0;
      FSelStart := Value;
      CaretPosition := FSelStart;
      Invalidate;
    end;
end;

procedure TbsSkinPasswordEdit.SetAutoSelect(const Value: Boolean);
begin
  if FAutoSelect <> Value then FAutoSelect := Value;
end;

function TbsSkinPasswordEdit.GetSelStart: Integer;
begin
  if FSelLength > 0
  then
    Result := FSelStart
  else
    if FSelLength < 0
    then Result := FSelStart + FSelLength
    else Result := CaretPosition;
end;

function TbsSkinPasswordEdit.GetSelRect: TRect;
begin
  Result := GetEditRect;
  Result.Left := GetCharX(SelStart);
  Result.Right := GetCharX(SelStart + SelLength);
  IntersectRect(Result, Result, GetEditRect);
end;

function TbsSkinPasswordEdit.GetSelLength: Integer;
begin
  Result := Abs(FSelLength);
end;

function TbsSkinPasswordEdit.GetSelText: String;
begin
  Result := Copy(Text, SelStart + 1, SelLength);
end;

procedure TbsSkinPasswordEdit.SetCharCase(const Value: TEditCharCase);
var
  S: String;
begin
  if FCharCase <> Value
  then
    begin
      FCharCase := Value;
      if Text <> ''
      then
        begin
          S := Text;
          case Value of
            ecUpperCase: Text := AnsiUpperCase(S);
            ecLowerCase: Text := AnsiLowerCase(S);
          end;
        end;
    end;
end;

procedure TbsSkinPasswordEdit.SetHideSelection(const Value: Boolean);
begin
  if FHideSelection <> Value
  then
    begin
      FHideSelection := Value;
      Invalidate;
    end;
end;

procedure TbsSkinPasswordEdit.SetMaxLength(const Value: Integer);
begin
  if FMaxLength <> Value then FMaxLength := Value;
end;

procedure TbsSkinPasswordEdit.SetCursor(const Value: TCursor);
begin
  if Value = crDefault
  then inherited Cursor := crIBeam
  else inherited Cursor := Value;
end;

function TbsSkinPasswordEdit.ValidText(NewText: String): Boolean;
begin
  Result := true;
end;

procedure TbsSkinPasswordEdit.SetTextAlignment(const Value: TAlignment);
begin
  if FTextAlignment <> Value
  then
    begin
      FTextAlignment := Value;
      Invalidate;
    end;
end;

procedure TbsSkinPasswordEdit.UpdateCaretePosition;
begin
  SetCaretPosition(CaretPosition);
end;

procedure TbsSkinPasswordEdit.InsertText(AText: String);
var
  S: String;
begin
  if ReadOnly then Exit;
  S := Text;
  Delete(S, SelStart + 1, SelLength);
  Insert(AText, S, SelStart + 1);
  if (MaxLength <= 0) or (Length(S) <= MaxLength)
  then
    begin
      Text := S;
      CaretPosition := SelStart + Length(AText);
    end;
  SelLength := 0;
end;

procedure TbsSkinPasswordEdit.InsertChar(Ch: Char);
begin
  if ReadOnly then Exit;
  InsertText(Ch);
end;

procedure TbsSkinPasswordEdit.InsertAfter(Position: Integer; S: String;
  Selected: Boolean);
var
  S1: String;
  Insertion : String;
begin
  S := Text;
  Insertion := S;
  if MaxLength > 0
  then
    Insertion := Copy(Insertion, 1, MaxLength - Length(S1));
  Insert(Insertion, S1, Position+1);
  Text := S1;
  if Selected
  then
    begin
      SelStart := Position;
      SelLength := Length(Insertion);
      CaretPosition := SelStart + SelLength;
    end;
end;

procedure TbsSkinPasswordEdit.DeleteFrom(Position, Length: Integer; MoveCaret : Boolean);
var
  TmpS: String;
begin
  TmpS := Text;
  Delete(TmpS,Position,Length);
  Text := TmpS;
  if MoveCaret
  then
    begin
      SelLength := 0;
      SelStart := Position-1;
    end;
end;

procedure TbsSkinPasswordEdit.SetPasswordKind(const Value: TbsPasswordKind);
begin
  if FPasswordKind <> Value
  then
    begin
      FPasswordKind := Value;
      Invalidate;
    end;
end;

procedure TbsSkinPasswordEdit.CMTextChanged(var Msg: TMessage);
begin
  inherited;
  FText := inherited Text;
  SelLength := 0;
  Invalidate;
end;

procedure TbsSkinPasswordEdit.Clear;
begin
  Text := '';
end;

procedure TbsSkinPasswordEdit.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if HandleAllocated then Invalidate;
end;

procedure TbsSkinPasswordEdit.CMMouseEnter;
begin
  inherited;
  FMouseIn := True;
  if (not Focused) then Invalidate;
end;

procedure TbsSkinPasswordEdit.CMMouseLeave;
begin
  inherited;
  FMouseIn := False;
  if not Focused then Invalidate;
end;

// TbsSkinNumericEdit

constructor TbsSkinNumericEdit.Create(AOwner: TComponent);
begin
  inherited;
  FSupportUpdownKeys := False;
  FIncrement := 1;
  FMinValue := 0;
  FMaxValue := 0;
  FValue := 0;
  StopCheck := True;
  FromEdit := False;
  Text := '0';
  StopCheck := False;
  Width := 120;
  Height := 20;
  FDecimal := 2;
  FSkinDataName := 'edit';
end;

destructor TbsSkinNumericEdit.Destroy;
begin
  inherited;
end;

procedure TbsSkinNumericEdit.WMKILLFOCUS(var Message: TMessage);
begin
  inherited;
  StopCheck := True;
  if ValueType = vtFloat
  then Text := FloatToStrF(FValue, ffFixed, 15, FDecimal)
  else Text := IntToStr(Round(FValue));
  StopCheck := False;
  if (ValueType = vtFloat) and (FValue <> StrToFloat(Text))
  then
    begin
      FValue := StrToFloat(Text);
      if Assigned(OnChange) then OnChange(Self);
    end;
end;

procedure TbsSkinNumericEdit.SetValueType(NewType: TbsValueType);
begin
  if FValueType <> NewType
  then
    begin
      FValueType := NewType;
    end;
end;

procedure TbsSkinNumericEdit.SetDecimal(NewValue: Byte);
begin
  if FDecimal <> NewValue then begin
    FDecimal := NewValue;
  end;
end;

function TbsSkinNumericEdit.CheckValue;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue)
  then
    begin
      if NewValue < FMinValue then
      Result := FMinValue
      else if NewValue > FMaxValue then
      Result := FMaxValue;
    end;
end;

procedure TbsSkinNumericEdit.SetMinValue;
begin
  FMinValue := AValue;
end;

procedure TbsSkinNumericEdit.SetMaxValue;
begin
  FMaxValue := AValue;
end;

function TbsSkinNumericEdit.IsNumText;

function GetMinus: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  i := Pos('-', S);
  if i > 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos('-', S) = 0;
    end;
end;

function GetP: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  i := Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, S);
  if i = 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, S) = 0;
    end;
end;

const
  EditChars = '01234567890-';
var
  i: Integer;
  S: String;
begin
  S := EditChars;
  Result := True;
  if ValueType = vtFloat
  then
    S := S + {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator;
  if (Text = '') or (Text = '-')
  then
    begin
      Result := False;
      Exit;
    end;

  for i := 1 to Length(Text) do
  begin
    if Pos(Text[i], S) = 0
    then
      begin
        Result := False;
        Break;
      end;
  end;

  Result := Result and GetMinus;

  if ValueType = vtFloat
  then
    Result := Result and GetP;

end;

procedure TbsSkinNumericEdit.Change;
var
  NewValue, TmpValue: Double;

function CheckInput: Boolean;
begin
  if (NewValue < 0) and (TmpValue < 0)
  then
    Result := NewValue > TmpValue
  else
    Result := NewValue < TmpValue;

  if not Result and ( ((FMinValue > 0) and (TmpValue < 0))
    or ((FMaxValue < 0) and (TmpValue > 0)))
  then
    Result := True;
end;

begin
  if FromEdit then Exit;
  if not StopCheck and IsNumText(Text)
  then
    begin
      if ValueType = vtFloat
      then TmpValue := StrToFloat(Text)
      else TmpValue := StrToInt(Text);
      NewValue := CheckValue(TmpValue);
      if NewValue <> FValue
      then
        begin
          FValue := NewValue;
        end;
      if CheckInput
      then
        begin
          FromEdit := True;
          if ValueType = vtFloat
          then Text := FloatToStrF(NewValue, ffFixed, 15, FDecimal)
          else Text := IntToStr(Round(FValue));
          FromEdit := False;
        end;
    end;
  inherited;
end;

procedure TbsSkinNumericEdit.SetValue;
begin
  FValue := CheckValue(AValue);
  StopCheck := True;
  if ValueType = vtFloat
  then
    Text := FloatToStrF(CheckValue(AValue), ffFixed, 15, FDecimal)
  else
    Text := IntToStr(Round(CheckValue(AValue)));
  StopCheck := False;
end;

procedure TbsSkinNumericEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if FSupportUpDownKeys
  then
    begin
      if Key = VK_UP
      then
        Value := Value + FIncrement
      else
      if Key = VK_DOWN
      then
        Value := Value - FIncrement;
     end
end;

procedure TbsSkinNumericEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key)
  then
    begin
      Key := #0;
      MessageBeep(0)
    end;
  inherited KeyPress(Key);
end;

function TbsSkinNumericEdit.IsValidChar(Key: Char): Boolean;
begin
  if ValueType = vtFloat 
  then
    Result := (Key in [{$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)))
  else
    Result := (Key in ['-', '0'..'9']) or
     ((Key < #32) and (Key <> Chr(VK_RETURN)));

  if (Key = {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator) and (Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, Text) <> 0)
  then
    Result := False
  else
  if (Key = '-') and (SelStart = 0) and (SelLength > 0)
  then
    begin
      Result := True;
    end
  else
  if (Key = '-') and (SelStart <> 0) 
  then
    begin
      Result := False;
    end
  else
  if (Key = '-') and (Pos('-', Text) <> 0)
  then
    Result := False;

  if ReadOnly and Result and ((Key >= #32) or
     (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE)))
  then
    Result := False;
end;

// TbsSkinCheckComboBox

constructor TbsPopupCheckListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable,
    csAcceptsControls];
  Ctl3D := False;
  ParentCtl3D := False;
  Visible := False;
  FOldAlphaBlend := False;
  FOldAlphaBlendValue := 0;
end;

procedure TbsPopupCheckListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do begin
    Style := WS_POPUP or WS_CLIPCHILDREN;
    ExStyle := WS_EX_TOOLWINDOW;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    if CheckWXP then
      WindowClass.Style := WindowClass.style or CS_DROPSHADOW_;
  end;
end;

procedure TbsPopupCheckListBox.WMMouseActivate(var Message: TMessage);
begin
  Message.Result := MA_NOACTIVATE;
end;

procedure TbsPopupCheckListBox.Hide;
begin
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Visible := False;
end;

procedure TbsPopupCheckListBox.Show(Origin: TPoint);
var
  PLB: TbsSkinCustomCheckComboBox;
  I: Integer;
  TickCount: DWORD;
  AnimationStep: Integer;
begin
  PLB := nil;
  //
  if CheckW2KWXP and (Owner is TbsSkinCustomCheckComboBox)
  then
    begin
      PLB := TbsSkinCustomCheckComboBox(Owner);
      if PLB.AlphaBlend and not FOldAlphaBlend
      then
        begin
          SetWindowLong(Handle, GWL_EXSTYLE,
                        GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
        end
      else
      if not PLB.AlphaBlend and FOldAlphaBlend
      then
        begin
         SetWindowLong(Handle, GWL_EXSTYLE,
            GetWindowLong(Handle, GWL_EXSTYLE) and (not WS_EX_LAYERED));
        end;
      FOldAlphaBlend := PLB.AlphaBlend;
      if (FOldAlphaBlendValue <> PLB.AlphaBlendValue) and PLB.AlphaBlend
      then
        begin
          if PLB.AlphaBlendAnimation
          then
            begin
              SetAlphaBlendTransparent(Handle, 0);
              FOldAlphaBlendValue := 0;
            end
          else
            begin
              SetAlphaBlendTransparent(Handle, PLB.AlphaBlendValue);
              FOldAlphaBlendValue := PLB.AlphaBlendValue;
             end;
        end;
    end;
  //
  SetWindowPos(Handle, HWND_TOP, Origin.X, Origin.Y, 0, 0,
    SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOSIZE);
  Visible := True;
  if CheckW2KWXP and (PLB <> nil) and PLB.AlphaBlendAnimation and PLB.AlphaBlend 
  then
    begin
      Application.ProcessMessages;
      I := 0;
      TickCount := 0;
      AnimationStep := PLB.AlphaBlendValue div 15;
      if AnimationStep = 0 then AnimationStep := 1;
      repeat
        if (GetTickCount - TickCount > 5)
        then
          begin
            TickCount := GetTickCount;
            Inc(i, AnimationStep);
            if i > PLB.AlphaBlendValue then i := PLB.AlphaBlendValue;
            SetAlphaBlendTransparent(Handle, i);
          end;  
      until i >= PLB.FAlphaBlendValue;
    end;
end;

// checkcombobox

constructor TbsSkinCustomCheckComboBox.Create;
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csReplicatable, csOpaque, csDoubleClicks, csAcceptsControls];
  FDefaultColor := clWindow;
  FListBoxWidth := 0;
  FAlphaBlendAnimation := False;
  FAlphaBlend := False;
  FUseSkinSize := True;
  TabStop := True;
  Font.Name := 'Tahoma';
  Font.Color := clWindowText;
  Font.Style := [];
  Font.Height := 13;
  Width := 120;
  Height := 20;
  FOnListBoxDrawItem := nil;
  FListBox := TbsPopupCheckListBox.Create(Self);
  FListBox.Visible := False;
  if not (csDesigning in ComponentState)
  then
    FlistBox.Parent := Self;
  FListBox.ListBox.TabStop := False;
  FListBox.ListBox.OnMouseMove := ListBoxMouseMove;
  FListBoxWindowProc := FlistBox.ListBox.WindowProc;
  FlistBox.ListBox.WindowProc := ListBoxWindowProcHook;
  FLBDown := False;
  WasInLB := False;
  FDropDownCount := 8;
  CalcRects;
  FSkinDataName := 'combobox';
end;

destructor TbsSkinCustomCheckComboBox.Destroy;
begin
  FlistBox.Free;
  FlistBox := nil;
  inherited;
end;

procedure TbsSkinCustomCheckComboBox.SetDefaultColor(Value: TColor);
begin
  FDefaultColor := Value;
  if FIndex = -1 then Invalidate;
end;


function TbsSkinCustomCheckComboBox.GetDisabledFontColor: TColor;
var
  i: Integer;
begin
  i := -1;
  if FIndex <> -1 then i := SkinData.GetControlIndex('edit');
  if i = -1
  then
    Result := clGrayText
  else
  begin
    Result := TbsDataSkinEditControl(SkinData.CtrlList[i]).DisabledFontColor;
    if TbsDataSkinEditControl(SkinData.CtrlList[i]).FontColor = Result
    then
      Result := clGrayText;
  end;
end;

procedure TbsSkinCustomCheckComboBox.WMEraseBkgnd;
begin
  if not FromWMPaint
  then
    begin
      PaintWindow(Msg.DC);
    end;
end;


procedure TbsSkinCustomCheckComboBox.StartTimer;
begin
  KillTimer(Handle, 1);
  SetTimer(Handle, 1, 25, nil);
end;

procedure TbsSkinCustomCheckComboBox.StopTimer;
begin
  KillTimer(Handle, 1);
  TimerMode := 0;
end;

procedure TbsSkinCustomCheckComboBox.WMTimer;
begin
  inherited;
  case TimerMode of
    1: if FListBox.ItemIndex > 0
       then
         FListBox.ItemIndex := FListBox.ItemIndex - 1;
    2:
       if FListBox.ItemIndex < FListBox.Items.Count
       then
         FListBox.ItemIndex := FListBox.ItemIndex + 1;
  end;
end;

procedure TbsSkinCustomCheckComboBox.ProcessListBox;
var
  R: TRect;
  P: TPoint;
  LBP: TPoint;
begin
  GetCursorPos(P);
  P := FListBox.ListBox.ScreenToClient(P);
  if (P.Y < 0) and (FListBox.ScrollBar <> nil) and WasInLB
  then
    begin
      if (TimerMode <> 1)
      then
        begin
          TimerMode := 1;
          StartTimer;
        end;
    end
  else
  if (P.Y > FListBox.ListBox.Height) and (FListBox.ScrollBar <> nil) and WasInLB
  then
    begin
      if (TimerMode <> 2)
      then
        begin
          TimerMode := 2;
          StartTimer;
        end
    end
  else
    if (P.Y >= 0) and (P.Y <= FListBox.ListBox.Height)
    then
      begin
        if TimerMode <> 0 then StopTimer;
        FListBox.ListBox.MouseMove([], 1, P.Y);
        WasInLB := True;
      end;
end;

procedure TbsSkinCustomCheckComboBox.CheckText;
var
  i: Integer;
  S: String;
begin
  if Items.Count = 0
  then
    Text := ''
  else
    begin
      S := '';
      for i := 0 to Items.Count - 1 do
      begin
        if Checked[I] then
          if S = '' then S := Items[I] else S := S + ',' + Items[I];
      end;
      Text := S;
    end;
end;


procedure TbsSkinCustomCheckComboBox.SetChecked;
begin
  FListBox.Checked[Index] := Checked;
  CheckText;
  RePaint;
end;

function TbsSkinCustomCheckComboBox.GetChecked;
begin
  Result := FListBox.Checked[Index];
end;

procedure TbsSkinCustomCheckComboBox.CMEnabledChanged;
begin
  inherited;
  RePaint;
  Change;
end;

function TbsSkinCustomCheckComboBox.GetListBoxUseSkinItemHeight: Boolean;
begin
  Result := FListBox.UseSkinItemHeight;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxUseSkinItemHeight(Value: Boolean);
begin
  FListBox.UseSkinItemHeight := Value;
end;

function TbsSkinCustomCheckComboBox.GetListBoxUseSkinFont: Boolean;
begin
  Result := FListBox.UseSkinFont;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxUseSkinFont(Value: Boolean);
begin
  FListBox.UseSkinFont := Value;
end;

procedure TbsSkinCustomCheckComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

function TbsSkinCustomCheckComboBox.GetImages: TCustomImageList;
begin
  if FListBox <> nil
  then
    Result := FListBox.Images
  else
    Result := nil;
end;

function TbsSkinCustomCheckComboBox.GetImageIndex: Integer;
begin
  Result := FListBox.ImageIndex;
end;

procedure TbsSkinCustomCheckComboBox.SetImages(Value: TCustomImageList);
begin
  FListBox.Images := Value;
  RePaint;
end;

procedure TbsSkinCustomCheckComboBox.SetImageIndex(Value: Integer);
begin
  FListBox.ImageIndex := Value;
  RePaint;
end;

procedure TbsSkinCustomCheckComboBox.CMCancelMode;
begin
  inherited;
  if (Message.Sender = nil) or (
     (Message.Sender <> Self) and
     (Message.Sender <> Self.FListBox) and
     (Message.Sender <> Self.FListBox.ScrollBar) and
     (Message.Sender <> Self.FListBox.ListBox))
  then
    CloseUp(False);
end;

procedure TbsSkinCustomCheckComboBox.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TbsSkinCustomCheckComboBox.GetListBoxDefaultFont;
begin
  Result := FListBox.DefaultFont;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxDefaultFont;
begin
  FListBox.DefaultFont.Assign(Value);
end;

function TbsSkinCustomCheckComboBox.GetListBoxDefaultCaptionFont;
begin
  Result := FListBox.DefaultCaptionFont;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxDefaultCaptionFont;
begin
  FListBox.DefaultCaptionFont.Assign(Value);
end;

function TbsSkinCustomCheckComboBox.GetListBoxDefaultItemHeight;
begin
  Result := FListBox.DefaultItemHeight;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxDefaultItemHeight;
begin
  FListBox.DefaultItemHeight := Value;
end;

function TbsSkinCustomCheckComboBox.GetListBoxCaptionAlignment;
begin
  Result := FListBox.Alignment;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxCaptionAlignment;
begin
  FListBox.Alignment := Value;
end;

procedure TbsSkinCustomCheckComboBox.DefaultFontChange;
begin
  Font.Assign(FDefaultFont);
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxCaption;
begin
  FListBox.Caption := Value;
end;

function  TbsSkinCustomCheckComboBox.GetListBoxCaption;
begin
  Result := FListBox.Caption;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxCaptionMode;
begin
  FListBox.CaptionMode := Value;
end;

function  TbsSkinCustomCheckComboBox.GetListBoxCaptionMode;
begin
  Result := FListBox.CaptionMode;
end;

function TbsSkinCustomCheckComboBox.GetSorted: Boolean;
begin
  Result := FListBox.Sorted;
end;

procedure TbsSkinCustomCheckComboBox.SetSorted(Value: Boolean);
begin
  FListBox.Sorted := Value;
end;

procedure TbsSkinCustomCheckComboBox.SetListBoxDrawItem;
begin
  FOnListboxDrawItem := Value;
  FListBox.OnDrawItem := FOnListboxDrawItem;
end;

procedure TbsSkinCustomCheckComboBox.ListBoxDrawItem(Cnvs: TCanvas; Index: Integer;
            ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
begin
  if Assigned(FOnListBoxDrawItem)
  then FOnListBoxDrawItem(Cnvs, Index, ItemWidth, ItemHeight, TextRect, State);
end;

procedure TbsSkinCustomCheckComboBox.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  case Msg.CharCode of
    VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT:  Msg.Result := 1;
  end;
end;

procedure TbsSkinCustomCheckComboBox.KeyDown;
var
  I: Integer;
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_SPACE:
      if FListBox.ItemIndex >= 0 then
      begin
        Checked[FListBox.ItemIndex] := not Checked[FListBox.ItemIndex];
        Change;
        if Assigned(OnClick) then OnClick(Self);
       end;
    VK_UP, VK_LEFT:
      if ssAlt in Shift
      then
        begin
          if FListBox.Visible then CloseUp(False);
        end
      else
        EditUp1(True);
    VK_DOWN, VK_RIGHT:
      if ssAlt in Shift
      then
        begin
          if not FListBox.Visible then DropDown;
        end
      else
        EditDown1(True);
    VK_NEXT: EditPageDown1(True);
    VK_PRIOR: EditPageUp1(True);
    VK_ESCAPE: if FListBox.Visible then CloseUp(False);
    VK_RETURN: if FListBox.Visible then CloseUp(True);
  end;
end;

procedure TbsSkinCustomCheckComboBox.WMMOUSEWHEEL;
begin
  if TWMMOUSEWHEEL(Message).WheelDelta > 0
  then
    EditUp1(not FListBox.Visible)
  else
    EditDown1(not FListBox.Visible);
end;

procedure TbsSkinCustomCheckComboBox.WMSETFOCUS;
begin
  inherited;
  RePaint;
end;

procedure TbsSkinCustomCheckComboBox.WMKILLFOCUS;
begin
  inherited;
  if FListBox.Visible then CloseUp(False);
  RePaint;
end;

procedure TbsSkinCustomCheckComboBox.GetSkinData;
begin
  inherited;
  if FIndex <> -1
  then
    if TbsDataSkinControl(FSD.CtrlList.Items[FIndex]) is TbsDataSkinComboBox
    then
      with TbsDataSkinComboBox(FSD.CtrlList.Items[FIndex]) do
      begin
        Self.ActiveSkinRect := ActiveSkinRect;
        Self.SItemRect := SItemRect;
        Self.ActiveItemRect := ActiveItemRect;
        Self.FocusItemRect := FocusItemRect;
        if isNullRect(FocusItemRect)
        then
          Self.FocusItemRect := SItemRect;
        Self.ItemLeftOffset := ItemLeftOffset;
        Self.ItemRightOffset := ItemRightOffset;
        Self.ItemTextRect := ItemTextRect;

        Self.FontName := FontName;
        Self.FontStyle := FontStyle;
        Self.FontHeight := FontHeight;
        Self.FontColor := FontColor;
        Self.FocusFontColor := FocusFontColor;
        Self.ActiveFontColor := ActiveFontColor;

        Self.ButtonRect := ButtonRect;
        Self.ActiveButtonRect := ActiveButtonRect;
        Self.DownButtonRect := DownButtonRect;
        Self.UnEnabledButtonRect := UnEnabledButtonRect;

        Self.StretchEffect := StretchEffect;
        Self.ItemStretchEffect := ItemStretchEffect;
        Self.FocusItemStretchEffect := FocusItemStretchEffect;

        Self.ListBoxName := 'checklistbox';
      end;
end;

procedure TbsSkinCustomCheckComboBox.Invalidate;
begin
  inherited;
end;

function TbsSkinCustomCheckComboBox.IsPopupVisible: Boolean;
begin
  Result := FListBox.Visible;
end;

function TbsSkinCustomCheckComboBox.CanCancelDropDown;
begin
  Result := FListBox.Visible and not FMouseIn;
end;

procedure TbsSkinCustomCheckComboBox.ListBoxWindowProcHook(var Message: TMessage);
var
  FOld: Boolean;
begin
  FOld := True;
  case Message.Msg of
     WM_LBUTTONDOWN:
       begin
         FOLd := False;
         FLBDown := True;
         WasInLB := True;
         SetCapture(Self.Handle);
       end;
     WM_LBUTTONUP, WM_RBUTTONDOWN, WM_RBUTTONUP,
     WM_MBUTTONDOWN, WM_MBUTTONUP,
     WM_LBUTTONDBLCLK:
      begin
         FOLd := False;
       end;
  end;
  if FOld then FListBoxWindowProc(Message);
end;

procedure TbsSkinCustomCheckComboBox.CMMouseEnter;
begin
  inherited;
  FMouseIn := True;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) then Invalidate;
end;

procedure TbsSkinCustomCheckComboBox.CMMouseLeave;
begin
  inherited;
  FMouseIn := False;
  if Button.MouseIn
  then
    begin
      Button.MouseIn := False;
      RePaint;
    end;
  if (FIndex <> -1) and not IsNullRect(ActiveSkinRect) then Invalidate;
end;

procedure TbsSkinCustomCheckComboBox.SetDropDownCount(Value: Integer);
begin
  if Value > 0
  then
    FDropDownCount := Value;
end;

procedure TbsSkinCustomCheckComboBox.ListBoxMouseMove(Sender: TObject; Shift: TShiftState;
                           X, Y: Integer);

var
  Index: Integer;
begin
  Index := FListBox.ItemAtPos(Point (X, Y), True);
  if (Index >= 0) and (Index < Items.Count)
  then
    FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomCheckComboBox.SetItems;
begin
  FListBox.Items.Assign(Value);
end;

function TbsSkinCustomCheckComboBox.GetItems;
begin
  Result := FListBox.Items;
end;

procedure TbsSkinCustomCheckComboBox.MouseDown;
begin
  inherited;
  if not Focused then SetFocus;
  if Button <> mbLeft then Exit;
  if Self.Button.MouseIn or PtInRect(CBItem.R, Point(X, Y))
  then
    begin
      Self.Button.Down := True;
      RePaint;
      if FListBox.Visible
      then
        CloseUp(False)
      else
        begin
          WasInLB := False;
          FLBDown := True;
          DropDown;
        end;
    end
  else
    if FListBox.Visible then CloseUp(False);
end;

procedure TbsSkinCustomCheckComboBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);

var
  P: TPoint;
begin
  inherited;
  if FLBDown and WasInLB
  then
    begin
      ReleaseCapture;
      FLBDown := False;
      if TimerMode <> 0 then StopTimer;
      GetCursorPos(P);
      if WindowFromPoint(P) = FListBox.ListBox.Handle
      then
        begin
          Checked[FListBox.ItemIndex] := not Checked[FListBox.ItemIndex];
          Change;
          if Assigned(OnClick) then OnClick(Self);
        end;  
    end
  else
    FLBDown := False;
  if Self.Button.Down
  then
    begin
      Self.Button.Down := False;
      RePaint;
    end;
end;

procedure TbsSkinCustomCheckComboBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FLBDown
  then
    begin
      ProcessListBox;
    end
  else
  if PtInRect(Button.R, Point(X, Y)) and not Button.MouseIn
  then
    begin
      Button.MouseIn := True;
      RePaint;
    end
  else
  if not PtInRect(Button.R, Point(X, Y)) and Button.MouseIn
  then
    begin
      Button.MouseIn := False;
      RePaint;
    end;
end;

procedure TbsSkinCustomCheckComboBox.CloseUp;
begin
  if TimerMode <> 0 then StopTimer;
  if not FListBox.Visible then Exit;
  FListBox.Hide;
  if Value
  then
    begin
      RePaint;
      if Assigned(FOnClick) then FOnClick(Self);
    end;
  if Assigned(FOnCloseUp) then FOnCloseUp(Self);  
end;

procedure TbsSkinCustomCheckComboBox.DropDown;
function GetForm(AControl : TControl) : TForm;
  var
    temp : TControl;
  begin
    result := nil;
    temp := AControl;
    repeat
      if assigned(temp) then
      begin
        if temp is TForm then
        break;
      end;
      temp := temp.Parent;
    until temp = nil;
  end;

var
  P: TPoint;
  WorkArea: TRect;
begin
  if Items.Count = 0 then Exit;

  WasInLB := False;
  if TimerMode <> 0 then StopTimer;

  if Assigned(FOnDropDown) then FOnDropDown(Self);

  if FListBoxWidth = 0
  then
    FListBox.Width := Width
  else
    FListBox.Width := FListBoxWidth;

  if Items.Count < DropDownCount
  then
    FListBox.RowCount := Items.Count
  else
    FListBox.RowCount := DropDownCount;
  P := Point(Left, Top + Height);
  P := Parent.ClientToScreen (P);

  WorkArea := GetMonitorWorkArea(Handle, True);

  if P.Y + FListBox.Height > WorkArea.Bottom
  then
    P.Y := P.Y - Height - FListBox.Height;

  if (FListBox.ItemIndex = 0) and (FListBox.Items.Count > 1)
  then
    begin
      FListBox.ItemIndex := 1;
      FListBox.ItemIndex := 0;
    end;

  FListBox.TopIndex := FListBox.ItemIndex;
  FListBox.SkinData := SkinData;
  FListBox.Show(P);
end;

procedure TbsSkinCustomCheckComboBox.EditPageUp1(AChange: Boolean);
var
  Index: Integer;
begin
  Index := FListBox.ItemIndex - DropDownCount - 1;
  if Index < 0 then Index := 0;
  FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomCheckComboBox.EditPageDown1(AChange: Boolean);
var
  Index: Integer;
begin
  Index := FListBox.ItemIndex + DropDownCount - 1;
  if Index > FListBox.Items.Count - 1
  then
    Index := FListBox.Items.Count - 1;
  FListBox.ItemIndex := Index;
end;

procedure TbsSkinCustomCheckComboBox.EditUp1;
begin
  if FListBox.ItemIndex > 0
  then
    begin
      FListBox.ItemIndex := FListBox.ItemIndex - 1;
    end;
end;

procedure TbsSkinCustomCheckComboBox.EditDown1;
begin
  if FListBox.ItemIndex < FListBox.Items.Count - 1
  then
    begin
      FListBox.ItemIndex := FListBox.ItemIndex + 1;
    end;
end;

procedure TbsSkinCustomCheckComboBox.WMSIZE;
begin
  inherited;
  CalcRects;
end;

procedure TbsSkinCustomCheckComboBox.DrawResizeButton;
var
  Buffer, Buffer2: TBitMap;
  CIndex: Integer;
  ButtonData: TbsDataSkinButtonControl;
  BtnSkinPicture: TBitMap;
  BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint: TPoint;
  SR, BtnCLRect: TRect;
  BSR, ABSR, DBSR: TRect;
  XO, YO: Integer;
  ArrowColor: TColor;
  X, Y: Integer;
begin
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(Button.R);
  Buffer.Height := RectHeight(Button.R);
  //
  CIndex := SkinData.GetControlIndex('combobutton');
  if CIndex = -1
  then
    CIndex := SkinData.GetControlIndex('editbutton');
  if CIndex = -1 then CIndex := SkinData.GetControlIndex('resizebutton');
  if CIndex = -1
  then
    begin
      Buffer.Free;
      Exit;
    end
  else
    ButtonData := TbsDataSkinButtonControl(SkinData.CtrlList[CIndex]);
  //
  with ButtonData do
  begin
    XO := RectWidth(Button.R) - RectWidth(SkinRect);
    YO := RectHeight(Button.R) - RectHeight(SkinRect);
    BtnLTPoint := LTPoint;
    BtnRTPoint := Point(RTPoint.X + XO, RTPoint.Y);
    BtnLBPoint := Point(LBPoint.X, LBPoint.Y + YO);
    BtnRBPoint := Point(RBPoint.X + XO, RBPoint.Y + YO);
    BtnClRect := Rect(CLRect.Left, ClRect.Top,
      CLRect.Right + XO, ClRect.Bottom + YO);
    BtnSkinPicture := TBitMap(SkinData.FActivePictures.Items[ButtonData.PictureIndex]);

    BSR := SkinRect;
    ABSR := ActiveSkinRect;
    DBSR := DownSkinRect;
    if IsNullRect(ABSR) then ABSR := BSR;
    if IsNullRect(DBSR) then DBSR := ABSR;
    //
    if Button.Down and Button.MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, DBSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := DownFontColor;
      end
    else
    if Button.MouseIn
    then
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, ABSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := ActiveFontColor;
      end
    else
      begin
        CreateSkinImage(LTPoint, RTPoint, LBPoint, RBPoint, CLRect,
        BtnLtPoint, BtnRTPoint, BtnLBPoint, BtnRBPoint, BtnCLRect,
        Buffer, BtnSkinPicture, BSR, Buffer.Width, Buffer.Height, True,
        LeftStretch, TopStretch, RightStretch, BottomStretch,
        StretchEffect, StretchType);
        ArrowColor := FontColor;
      end;
   end;
  //
  if not IsNullRect(ButtonData.MenuMarkerRect)
  then
    with ButtonData do
    begin
      if Button.Down and Button.MouseIn and not IsNullRect(MenuMarkerDownRect)
      then SR := MenuMarkerDownRect else
        if Button.MouseIn and not IsNullRect(MenuMarkerActiveRect)
          then SR := MenuMarkerActiveRect else SR := MenuMarkerRect;

      Buffer2 := TBitMap.Create;
      Buffer2.Width := RectWidth(SR);
      Buffer2.Height := RectHeight(SR);

      Buffer2.Canvas.CopyRect(Rect(0, 0, Buffer2.Width, Buffer2.Height),
       Picture.Canvas, SR);

      Buffer2.Transparent := True;
      Buffer2.TransparentMode := tmFixed;
      Buffer2.TransparentColor := MenuMarkerTransparentColor;

      X := RectWidth(Button.R) div 2 - RectWidth(SR) div 2;
      Y := RectHeight(Button.R) div 2 - RectHeight(SR) div 2;
      if Button.Down and Button.MouseIn then Y := Y + 1;
      Buffer.Canvas.Draw(X, Y, Buffer2);
      Buffer2.Free;
    end
  else
  if Enabled
  then
    begin
      if Button.Down and Button.MouseIn
      then
        DrawArrowImage(Buffer.Canvas, Rect(0, 2, Buffer.Width, Buffer.Height), ArrowColor, 4)
      else
        DrawArrowImage(Buffer.Canvas, Rect(0, 0, Buffer.Width, Buffer.Height), ArrowColor, 4);
    end;
  //
  C.Draw(Button.R.Left, Button.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomCheckComboBox.DrawButton;
var
  ArrowColor: TColor;
  R1: TRect;
begin
  if FIndex = -1
  then
    with Button do
    begin
      R1 := R;  
      if Down and MouseIn
      then
        begin
          Frame3D(C, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
          C.Brush.Color := BS_BTNDOWNCOLOR;
          C.FillRect(R1);
        end
      else
        if MouseIn
        then
          begin
            Frame3D(C, R1, BS_BTNFRAMECOLOR, BS_BTNFRAMECOLOR, 1);
            C.Brush.Color := BS_BTNACTIVECOLOR;
            C.FillRect(R1);
          end
        else
          begin
            Frame3D(C, R1, clBtnShadow, clBtnShadow, 1);
            C.Brush.Color := clBtnFace;
            C.FillRect(R1);
          end;
      if Enabled
      then
        ArrowColor := clBlack
      else
        ArrowColor := clBtnShadow;
      DrawArrowImage(C, R, ArrowColor, 4);
    end
  else
    with Button do
    begin
      R1 := NullRect;
      if not Enabled and not IsNullRect(UnEnabledButtonRect)
      then
        R1 := UnEnabledButtonRect
      else
      if Down and MouseIn
      then R1 := DownButtonRect
      else if MouseIn then R1 := ActiveButtonRect;
      if not IsNullRect(R1)
      then
        C.CopyRect(R, Picture.Canvas, R1);
    end;
end;

procedure TbsSkinCustomCheckComboBox.DrawDefaultItem;
var
  Buffer: TBitMap;
  R, R1: TRect;
  IX, IY: Integer;
begin
  if RectWidth(CBItem.R) <=0 then Exit;
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(CBItem.R);
  Buffer.Height := RectHeight(CBItem.R);
  R := Rect(0, 0, Buffer.Width, Buffer.Height);
  with Buffer.Canvas do
  begin
    Font.Name := Self.Font.Name;
    Font.Style := Self.Font.Style;
    Font.Height := Self.Font.Height;
    if Focused
    then
      begin
        Brush.Color := clHighLight;
        Font.Color := clHighLightText;
      end
    else
      begin
        Brush.Color := FDefaultColor;
        Font.Color := FDefaultFont.Color;
      end;
    FillRect(R);
  end;

  CBItem.State := [];

  if Focused then CBItem.State := [odFocused];

  R1 := Rect(R.Left + 2, R.Top, R.Right - 2, R.Bottom);

  BSDrawText2(Buffer.Canvas, Text, R1);
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomCheckComboBox.DrawResizeSkinItem;
var
  Buffer: TBitMap;
  R, R2: TRect;
  W, H: Integer;
  IX, IY: Integer;
begin
  W := RectWidth(CBItem.R);
  if W <= 0 then Exit;
  H := RectHeight(SItemRect);
  if H = 0 then H := RectHeight(FocusItemRect);
  if H = 0 then H := RectWidth(CBItem.R);
  Buffer := TBitMap.Create;
  Buffer.Width := RectWidth(CBItem.R);
  Buffer.Height := RectHeight(CBItem.R);
  if Focused
  then
    begin
      if not IsNullRect(FocusItemRect)
      then
        begin
          R2 := ItemTextRect;
          InflateRect(R2, -1, -1);
          
          if RectWidth(SItemRect) > RectWidth(FocusItemRect)
          then
            Dec(R2.Right, RectWidth(SItemRect) - RectWidth(FocusItemRect));

          if RectHeight(SItemRect) > RectHeight(FocusItemRect)
          then
            Dec(R2.Top, RectHeight(SItemRect) - RectHeight(FocusItemRect));

          CreateStretchImage(Buffer, Picture, FocusItemRect, R2, True);
        end
      else
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height), Cnvs, CBItem.R);
    end
  else
    begin
      if not IsNullRect(ActiveItemRect) and not IsNullRect(ActiveSkinRect) and
         FMouseIn
      then
        begin
           R2 := ItemTextRect;
          if RectWidth(SItemRect) > RectWidth(ActiveItemRect)
          then
            Dec(R2.Right, RectWidth(SItemRect) - RectWidth(ActiveItemRect));

          if RectHeight(SItemRect) > RectHeight(ActiveItemRect)
          then
            Dec(R2.Top, RectHeight(SItemRect) - RectHeight(ActiveItemRect));

          CreateStretchImage(Buffer, Picture, ActiveItemRect, R2, True)
        end
      else
      if not IsNullRect(SItemRect)
      then
        CreateStretchImage(Buffer, Picture, SItemRect, ItemTextRect, True)
      else
        Buffer.Canvas.CopyRect(Rect(0, 0, Buffer.Width, Buffer.Height), Cnvs, CBItem.R);
    end;

  R := ItemTextRect;
  if not IsNullRect(SItemRect)
  then
    Inc(R.Right, W - RectWidth(SItemRect))
  else
    Inc(R.Right, W - RectWidth(ClRect));
  Inc(ItemTextRect.Bottom, Height - RectHeight(SkinRect));
  Inc(R.Bottom, Height - RectHeight(SkinRect));

  with Buffer.Canvas do
  begin
    if FUseSkinFont
    then
      begin
        Font.Name := FontName;
        Font.Style := FontStyle;
        Font.Height := FontHeight;
      end
    else
      Font.Assign(FDefaultFont);
    //
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := FDefaultFont.CharSet;
    //
    if Focused
    then
      Font.Color := FocusFontColor
    else
      if FMouseIn and not IsNullRect(ActiveSkinRect)
      then
        Font.Color := ActiveFontColor
      else
        Font.Color := FontColor;
    Brush.Style := bsClear;
  end;
  if not Enabled then Buffer.Canvas.Font.Color := GetDisabledFontColor;
  BSDrawText2(Buffer.Canvas, Text, R);
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;


procedure TbsSkinCustomCheckComboBox.DrawSkinItem;
var
  Buffer: TBitMap;
  R, R2: TRect;
  W, H: Integer;
  IX, IY: Integer;
begin
  W := RectWidth(CBItem.R);
  if W <= 0 then Exit;
  H := RectHeight(SItemRect);
  if H = 0 then H := RectHeight(FocusItemRect);
  if H = 0 then H := RectWidth(CBItem.R);
  Buffer := TBitMap.Create;
  if Focused
  then
    begin
      if not IsNullRect(FocusItemRect)
      then
        CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
          FocusItemRect, W, H, FocusItemStretchEffect)
      else
        begin
          Buffer.Width := W;
          BUffer.Height := H;
          Buffer.Canvas.CopyRect(Rect(0, 0, W, H), Cnvs, CBItem.R);
        end;
    end
  else
    begin
      if not IsNullRect(ActiveItemRect) and not IsNullRect(ActiveSkinRect) and
         FMouseIn
      then
        begin
          CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
            ActiveItemRect, W, H, ItemStretchEffect)
        end
      else
      if not IsNullRect(SItemRect)
      then
        CreateHSkinImage(ItemLeftOffset, ItemRightOffset, Buffer, Picture,
          SItemRect, W, H, ItemStretchEffect)
      else
        begin
          Buffer.Width := W;
          BUffer.Height := H;
          Buffer.Canvas.CopyRect(Rect(0, 0, W, H), Cnvs, CBItem.R);
        end;
    end;

  R := ItemTextRect;
  if not IsNullRect(SItemRect)
  then
    Inc(R.Right, W - RectWidth(SItemRect))
  else
    Inc(R.Right, W - RectWidth(ClRect));

  with Buffer.Canvas do
  begin
    if FUseSkinFont
    then
      begin
        Font.Name := FontName;
        Font.Style := FontStyle;
        Font.Height := FontHeight;
      end
    else
      Font.Assign(FDefaultFont);
    //
    if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
    then
      Font.Charset := SkinData.ResourceStrData.CharSet
    else
      Font.CharSet := FDefaultFont.CharSet;
    //
    if Focused
    then
      Font.Color := FocusFontColor
    else
      if FMouseIn and not IsNullRect(ActiveSkinRect)
      then
        Font.Color := ActiveFontColor
      else
        Font.Color := FontColor;
    Brush.Style := bsClear;
  end;
  if not Enabled then Buffer.Canvas.Font.Color := GetDisabledFontColor;
  BSDrawText2(Buffer.Canvas, Text, R);
  Cnvs.Draw(CBItem.R.Left, CBItem.R.Top, Buffer);
  Buffer.Free;
end;

procedure TbsSkinCustomCheckComboBox.CalcSize(var W, H: Integer);
var
  XO, YO: Integer;
begin
  if FUseSkinSize
  then
    inherited
  else
    begin
      XO := W - RectWidth(SkinRect);
      YO := H - RectHeight(SkinRect);
      NewLTPoint := LTPt;
      NewRTPoint := Point(RTPt.X + XO, RTPt.Y );
      NewClRect := ClRect;
      Inc(NewClRect.Right, XO);
    end;
end;

procedure TbsSkinCustomCheckComboBox.CalcRects;
const
  ButtonW = 17;
var
  OX, OY: Integer;
begin
  if FIndex = -1
  then
    begin
      Button.R := Rect(Width - ButtonW - 2, 0, Width, Height);
      CBItem.R := Rect(2, 2, Button.R.Left - 1 , Height -  2);
    end
  else
    begin
      OX := Width - RectWidth(SkinRect);
      Button.R := ButtonRect;
      if ButtonRect.Left >= RectWidth(SkinRect) - RTPt.X
      then
        OffsetRect(Button.R, OX, 0);
      CBItem.R := ClRect;
      Inc(CBItem.R.Right, OX);
      if not UseSkinSize
      then
        begin
          OY := Height - RectHeight(SkinRect);
          Inc(CBItem.R.Bottom, OY);
          Inc(Button.R.Bottom, OY);
        end;
    end;
end;

procedure TbsSkinCustomCheckComboBox.ChangeSkinData;
begin
  inherited;
  CalcRects;
  RePaint;
  if FIndex = -1
  then
    begin
      FListBox.SkinDataName := '';
    end
  else
    if ListBoxCaptionMode
    then
      FListBox.SkinDataName := 'captionchecklistbox'
    else
      FListBox.SkinDataName := 'checklistbox';
  FListBox.SkinData := SkinData;
  FListBox.UpDateScrollBar;
end;

procedure TbsSkinCustomCheckComboBox.CreateControlDefaultImage;
var
  R: TRect;
begin
  CalcRects;
  with B.Canvas do
  begin
    Brush.Color := FDefaultColor;
    R := ClientRect;
    FillRect(R);
  end;
  Frame3D(B.Canvas, R, clbtnShadow, clbtnShadow, 1);
  DrawButton(B.Canvas);
  DrawDefaultItem(B.Canvas);
end;

procedure TbsSkinCustomCheckComboBox.CreateControlSkinImage;
var
  ClRct: TRect;
begin
  CalcRects;
  if FUseSkinSize then
  begin
    if not IsNullRect(ActiveSkinRect) and (FMouseIn or Focused)
    then
      CreateHSkinImage(LTPt.X, RectWidth(ActiveSkinRect) - RTPt.X,
            B, Picture, ActiveSkinRect, Width, RectHeight(ActiveSkinRect), StretchEffect)
    else
      inherited;
  end
  else
  begin
    ClRct := ClRect;
    InflateRect(ClRct, -3, -1);
    if not IsNullRect(ActiveSkinRect) and
      (FMouseIn or Focused)
    then
      CreateStretchImage(B, Picture, ActiveSkinRect, ClRct, True)
    else
      CreateStretchImage(B, Picture, SkinRect, ClRct, True);
  end;
  if FUseSkinSize
  then
  begin
    DrawButton(B.Canvas);
    DrawSkinItem(B.Canvas);
  end
  else
  begin
    DrawResizeButton(B.Canvas);
    DrawResizeSkinItem(B.Canvas);
  end;
end;


// TbsSkinFontSizeComboBox

function EnumFontSizes(var EnumLogFont: TEnumLogFont;
  PTextMetric: PNewTextMetric; FontType: Integer; Data: LPARAM): Integer;
  export; stdcall;
var s: String;
    i,v,v2: Integer;
begin
  if (FontType and TRUETYPE_FONTTYPE) <> 0
  then
    begin
      TbsSkinFontSizeComboBox(Data).Items.Add('8');
      TbsSkinFontSizeComboBox(Data).Items.Add('9');
      TbsSkinFontSizeComboBox(Data).Items.Add('10');
      TbsSkinFontSizeComboBox(Data).Items.Add('11');
      TbsSkinFontSizeComboBox(Data).Items.Add('12');
      TbsSkinFontSizeComboBox(Data).Items.Add('14');
      TbsSkinFontSizeComboBox(Data).Items.Add('16');
      TbsSkinFontSizeComboBox(Data).Items.Add('18');
      TbsSkinFontSizeComboBox(Data).Items.Add('20');
      TbsSkinFontSizeComboBox(Data).Items.Add('22');
      TbsSkinFontSizeComboBox(Data).Items.Add('24');
      TbsSkinFontSizeComboBox(Data).Items.Add('26');
      TbsSkinFontSizeComboBox(Data).Items.Add('28');
      TbsSkinFontSizeComboBox(Data).Items.Add('36');
      TbsSkinFontSizeComboBox(Data).Items.Add('48');
      TbsSkinFontSizeComboBox(Data).Items.Add('72');
      Result := 0;
    end
  else
    begin
      v := Round((EnumLogFont.elfLogFont.lfHeight-PTextMetric.tmInternalLeading)*72 /
      TbsSkinFontSizeComboBox(Data).PixelsPerInch);
      s := IntToStr(v);
      Result := 1;
      for i := 0 to TbsSkinFontSizeComboBox(Data).Items.Count-1 do
      begin
        v2 := StrToInt(TbsSkinFontSizeComboBox(Data).Items[i]);
        if v2 = v then Exit;
        if v2 > v
        then
          begin
            TbsSkinFontSizeComboBox(Data).Items.Insert(i,s);
            Exit;
          end;
    end;
    TbsSkinFontSizeComboBox(Data).Items.Add(S);
  end;
end;

constructor TbsSkinFontSizeComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FNumEdit := True;
end;

procedure TbsSkinFontSizeComboBox.ShowEditor;
begin
  inherited;
  FEdit.MaxLength := 4;
end;

procedure TbsSkinFontSizeComboBox.Build;
var
  DC: HDC;
  OC: TNotifyEvent;
begin
  DC := GetDC(0);
  Items.BeginUpdate;
  try
    Items.Clear;
    if FontName<>'' then begin
      PixelsPerInch := GetDeviceCaps(DC, LOGPIXELSY);
      EnumFontFamilies(DC, PChar(FontName), @EnumFontSizes, Longint(Self));
      OC := OnClick;
      OnClick := nil;
      ItemIndex := Items.IndexOf(Text);
      OnClick := OC;
      if Assigned(OnClick) then
        OnClick(Self);
    end;
  finally
    Items.EndUpdate;
    ReleaseDC(0, DC);
  end;
end;

procedure TbsSkinFontSizeComboBox.SetFontName(const Value: TFontName);
begin
  FFontName := Value;
  Build;
end;

function TbsSkinFontSizeComboBox.GetSizeValue: Integer;

function IsNumText(AText: String): Boolean;

function GetMinus: Boolean;
var
  i: Integer;
  S: String;
begin
  S := AText;
  i := Pos('-', S);
  if i > 1
  then
    Result := False
  else
    begin
      Delete(S, i, 1);
      Result := Pos('-', S) = 0;
    end;
end;

const
  EditChars = '01234567890-';
var
  i: Integer;
  S: String;
begin
  S := EditChars;
  Result := True;
  if (Text = '') or (Text = '-')
  then
    begin
      Result := False;
      Exit;
    end;

  for i := 1 to Length(Text) do
  begin
    if Pos(Text[i], S) = 0
    then
      begin
        Result := False;
        Break;
      end;
  end;

  Result := Result and GetMinus;
end;


begin
  if Style = bscbFixedStyle
  then
    begin
      if ItemIndex = -1
      then
        Result := 0
      else
        if Items[ItemIndex] <> ''
        then
          Result := StrToInt(Items[ItemIndex])
        else
          Result := 0;
    end
  else
    begin
      if (Text <> '') and (IsNumText(Text))
      then
        Result := StrToInt(Text)
      else
        Result := 0;
    end;
end;

// ==================== TbsSkinFontListBox ======================= //
constructor TbsSkinFontListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnDrawItem := DrawLBFontItem;
  FDevice := fdScreen;
  Sorted := True;
end;

procedure TbsSkinFontListBox.DrawTT;
begin
  with Cnvs do
  begin
    Pen.Color := C;
    MoveTo(X, Y);
    LineTo(X + 7, Y);
    LineTo(X + 7, Y + 3);
    MoveTo(X, Y);
    LineTo(X, Y + 3);
    MoveTo(X + 1, Y);
    LineTo(X + 1, Y + 1);
    MoveTo(X + 6, Y);
    LineTo(X + 6, Y + 1);
    MoveTo(X + 3, Y);
    LineTo(X + 3, Y + 8);
    MoveTo(X + 4, Y);
    LineTo(X + 4, Y + 8);
    MoveTo(X + 2, Y + 8);
    LineTo(X + 6, Y + 8);
  end;
end;

procedure TbsSkinFontListBox.Reset;
var
  SaveName: TFontName;
begin
  if HandleAllocated
  then
    begin
      FUpdate := True;
      try
        SaveName := FontName;
        PopulateList;
        FontName := SaveName;
      finally
        FUpdate := False;
        if FontName <> SaveName
        then
          begin
            if not (csReading in ComponentState) then
            if not FUpdate and Assigned(OnListBoxClick) then OnListBoxClick(Self);
          end;
      end;
    end;
end;

procedure TbsSkinFontListBox.SetFontName(const NewFontName: TFontName);
var
  Item: Integer;
begin
  if FontName <> NewFontName
  then
  begin
    if not (csLoading in ComponentState)
    then
      begin
        ListBox.HandleNeeded;
        for Item := 0 to Items.Count - 1 do
          if AnsiCompareText(ListBox.Items[Item], NewFontName) = 0
          then
            begin
              ItemIndex := Item;
              if not (csReading in ComponentState) then
              if not FUpdate and Assigned(OnListBoxClick) then OnListBoxClick(Self);
              Exit;
            end;
      end;
    if not (csReading in ComponentState) then
    if not FUpdate and Assigned(OnListBoxClick) then OnListBoxClick(Self);
  end;      
end;

function TbsSkinFontListBox.GetFontName: TFontName;
begin
  if ItemIndex <> -1
  then
    Result := ListBox.Items[ItemIndex]
  else
    Result := '';
end;

function TbsSkinFontListBox.GetTrueTypeOnly: Boolean;
begin
  Result := foTrueTypeOnly in FOptions;
end;

procedure TbsSkinFontListBox.SetOptions;
begin
  if Value <> Options
  then
    begin
      FOptions := Value;
      Reset;
    end;
end;

procedure TbsSkinFontListBox.SetTrueTypeOnly(Value: Boolean);
begin
  if Value <> TrueTypeOnly
  then
    begin
      if Value then FOptions := FOptions + [foTrueTypeOnly]
      else FOptions := FOptions - [foTrueTypeOnly];
      Reset;
    end;
end;

procedure TbsSkinFontListBox.SetDevice;
begin
  if Value <> FDevice
  then
    begin
      FDevice := Value;
      Reset;
    end;
end;

procedure TbsSkinFontListBox.SetUseFonts(Value: Boolean);
begin
  if Value <> FUseFonts
  then
    begin
      FUseFonts := Value;
      ListBox.Invalidate;
    end;
end;

procedure TbsSkinFontListBox.DrawLBFontItem;
var
  FName: array[0..255] of Char;
  R: TRect;
  X, Y: Integer;
begin
  R := TextRect;
  if (Integer(Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0
  then
    begin
      X := TextRect.Left;
      Y := TextRect.Top + RectHeight(TextRect) div 2 - 7;
      DrawTT(Cnvs, X, Y, clGray);
      DrawTT(Cnvs, X + 4, Y + 4, clBlack);
    end;
  Inc(R.Left, 15);
  with Cnvs do
  begin
    Font.Name := Items[Index];
    Font.Style := [];
    StrPCopy(FName, Items[Index]);
    BSDrawText2(Cnvs, Items[Index], R);
  end;
end;

procedure TbsSkinFontListBox.Loaded;
begin
  inherited;
  FUpdate := True;
  try
    PopulateList;
  finally
    FUpdate := False;
  end;
end;

procedure TbsSkinFontListBox.ListBoxCreateWnd;
begin
  if (csDesigning in ComponentState) or
     (SkinData = nil) or
     ((SkinData <> nil) and (SkinData.Empty))
  then
    begin
      FUpdate := True;
      try
        PopulateList;
      finally
       FUpdate := False;
      end;
    end;
end;

procedure TbsSkinFontListBox.PopulateList;
var
  DC: HDC;
  Proc: TFarProc;
  OldItemIndex: Integer;
begin
  if not HandleAllocated then Exit;
  OldItemIndex := ItemIndex;
  ListBox.Items.BeginUpdate;
  try
    ListBox.Items.Clear;
    DC := GetDC(0);
    try
      if (FDevice = fdScreen) or (FDevice = fdBoth) then
        EnumFontFamilies(DC, nil, @EnumFontsProc2, Longint(Self));
      if (FDevice = fdPrinter) or (FDevice = fdBoth) then
      try
        EnumFontFamilies(Printer.Handle, nil, @EnumFontsProc2, Longint(Self));
      except

      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    ListBox.Items.EndUpdate;
  end;
  ItemIndex := OldItemIndex;     
end;


// ==================== TbsSkinColorListBox ======================= //

constructor TbsSkinColorListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExStyle := [bscbStandardColors, bscbExtendedColors, bscbSystemColors];
  FSelectedColor := clBlack;
  FDefaultColorColor := clBlack;
  FNoneColorColor := clBlack;
  OnDrawItem := DrawColorItem;
  FShowNames := True;
end;

procedure TbsSkinColorListBox.ListBoxDblClick;
begin
  inherited;
  if (bscbCustomColor in ExStyle) and (ItemIndex = 0)
  then
    PickCustomColor;
end;

procedure TbsSkinColorListBox.ListBoxKeyDown;
begin
  if (bscbCustomColor in ExStyle) and (Key = VK_RETURN) and (ItemIndex = 0)
  then
  begin
    PickCustomColor;
    Key := 0;
  end;
  inherited;
end;

procedure TbsSkinColorListBox.SetShowNames(Value: Boolean);
begin
  FShowNames := Value;
  ListBox.RePaint;
end;

procedure TbsSkinColorListBox.DrawColorItem;
var
  R: TRect;
  MarkerRect: TRect;
begin
  if FShowNames
  then
    MarkerRect := Rect(TextRect.Left + 2, TextRect.Top + 2,
      TextRect.Left + RectHeight(TextRect) - 2, TextRect.Bottom - 2)
  else
    MarkerRect := Rect(TextRect.Left + 2, TextRect.Top + 2,
      TextRect.Right - 2, TextRect.Bottom - 2);

  with Cnvs do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Colors[Index];
    FillRect(MarkerRect);
    Brush.Style := bsClear;
  end;

  if FShowNames
  then
    begin
      R := TextRect;
      R := Rect(R.Left + 5 + RectWidth(MarkerRect), R.Top, R.Right - 2, R.Bottom);
      BSDrawText2(Cnvs, ListBox.Items[Index], R);
    end;
end;

function TbsSkinColorListBox.PickCustomColor: Boolean;
var
  LColor: TColor;
begin
  with TbsSkinColorDialog.Create(nil) do
    try
      SkinData := Self.SkinData;
      CtrlSkinData := Self.SkinData;
      LColor := ColorToRGB(TColor(Items.Objects[0]));
      Color := LColor;
      Result := Execute;
      if Result then
      begin
        Items.Objects[0] := TObject(Color);
        Self.ListBox.Invalidate;
        if Assigned(FOnListBoxClick) then FOnListBoxClick(Self);
      end;
    finally
      Free;
    end;
end;

procedure TbsSkinColorListBox.Loaded;
begin
  inherited;
  PopulateList;
end;

procedure TbsSkinColorListBox.CreateWnd;
begin
  inherited;
  if HandleAllocated then PopulateList;
end;


procedure TbsSkinColorListBox.SetDefaultColorColor(const Value: TColor);
begin
  if Value <> FDefaultColorColor then
  begin
    FDefaultColorColor := Value;
    ListBox.Invalidate;
  end;
end;

procedure TbsSkinColorListBox.SetNoneColorColor(const Value: TColor);
begin
  if Value <> FNoneColorColor then
  begin
    FNoneColorColor := Value;
    ListBox.Invalidate;
  end;
end;

procedure TbsSkinColorListBox.ColorCallBack(const AName: String);
var
  I, LStart: Integer;
  LColor: TColor;
  LName: string;
begin
  LColor := StringToColor(AName);
  if bscbPrettyNames in ExStyle then
  begin
    if Copy(AName, 1, 2) = 'cl' then
      LStart := 3
    else
      LStart := 1;
    LName := '';
    for I := LStart to Length(AName) do
    begin
      case AName[I] of
        'A'..'Z':
          if LName <> '' then
            LName := LName + ' ';
      end;
      LName := LName + AName[I];
    end;
  end
  else
    LName := AName;
  Items.AddObject(LName, TObject(LColor));
end;

procedure TbsSkinColorListBox.SetSelected(const AColor: TColor);
var
  I: Integer;
begin
  if HandleAllocated then
  begin
    I := ListBox.Items.IndexOfObject(TObject(AColor));
    if (I = -1) and (bscbCustomColor in ExStyle) and (AColor <> NoColorSelected) then
    begin
      ListBox.Items.Objects[0] := TObject(AColor);
      I := 0;
    end;
    ItemIndex := I;
  end;
  FSelectedColor := AColor;
end;

procedure TbsSkinColorListBox.PopulateList;
  procedure DeleteRange(const AMin, AMax: Integer);
  var
    I: Integer;
  begin
    for I := AMax downto AMin do
      ListBox.Items.Delete(I);
  end;
  procedure DeleteColor(const AColor: TColor);
  var
    I: Integer;
  begin
    I := ListBox.Items.IndexOfObject(TObject(AColor));
    if I <> -1 then
      ListBox.Items.Delete(I);
  end;
var
  LSelectedColor, LCustomColor: TColor;
  S: String;
begin
  if HandleAllocated then
  begin
    ListBox.Items.BeginUpdate;
    try
      LCustomColor := clBlack;
      if (bscbCustomColor in ExStyle) and (ListBox.Items.Count > 0) then
        LCustomColor := TColor(ListBox.Items.Objects[0]);
      LSelectedColor := FSelectedColor;
      ListBox.Items.Clear;
      GetColorValues(ColorCallBack);
      if not (bscbIncludeNone in ExStyle) then
        DeleteColor(clNone);
      if not (bscbIncludeDefault in ExStyle) then
        DeleteColor(clDefault);
      if not (bscbSystemColors in ExStyle) then
        DeleteRange(StandardColorsCount + ExtendedColorsCount, Items.Count - 1);
      if not (bscbExtendedColors in ExStyle) then
        DeleteRange(StandardColorsCount, StandardColorsCount + ExtendedColorsCount - 1);
      if not (bscbStandardColors in ExStyle) then
        DeleteRange(0, StandardColorsCount - 1);
      if bscbCustomColor in ExStyle
      then
         begin
          if (SkinData <> nil) and
             (SkinData.ResourceStrData <> nil)
          then
            S := SkinData.ResourceStrData.GetResStr('CUSTOMCOLOR')
          else
            S := BS_CUSTOMCOLOR;
           ListBox.Items.InsertObject(0, S, TObject(LCustomColor));
         end;
      Self.Selected := LSelectedColor;
    finally
      ListBox.Items.EndUpdate;
    end;
  end;
end;

procedure TbsSkinColorListBox.SetExStyle(AStyle: TbsColorBoxStyle);
begin
  FExStyle := AStyle;
  Enabled := ([bscbStandardColors, bscbExtendedColors, bscbSystemColors, bscbCustomColor] * FExStyle) <> [];
  PopulateList;
  if (ListBox.Items.Count > 0) and (ItemIndex = -1) then ItemIndex := 0;
end;

function TbsSkinColorListBox.GetColor(Index: Integer): TColor;
begin
  Result := TColor(ListBox.Items.Objects[Index]);
end;

function TbsSkinColorListBox.GetColorName(Index: Integer): string;
begin
  Result := ListBox.Items[Index];
end;

function TbsSkinColorListBox.GetSelected: TColor;
begin
  if HandleAllocated then
    if ItemIndex <> -1 then
      Result := Colors[ItemIndex]
    else
      Result := NoColorSelected
  else
    Result := FSelectedColor;
end;

procedure TbsSkinMRUComboBox.AddMRUItem(Value: String);
var
  I: Integer;
begin
  if Value = '' then Exit;
  I := Items.IndexOf(Value);
  if I <> -1
  then
    Items.Move(I, 0)
  else
    Items.Insert(0, Value);
end;

// CurrencyEdit

function IsValidFloat(const Value: string; var RetValue: Extended): Boolean;
var
  I: Integer;
  Buffer: array[0..63] of Char;
begin
  Result := False;
  for I := 1 to Length(Value) do
    if not (Value[I] in [{$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, '-', '+', '0'..'9', 'e', 'E']) then
      Exit;
  Result := TextToFloat(StrPLCopy(Buffer, Value,
    SizeOf(Buffer) - 1), RetValue {$IFDEF WIN32}, fvExtended {$ENDIF});
end;

function FormatFloatStr(const S: string; Thousands: Boolean): string;
var
  I, MaxSym, MinSym, Group: Integer;
  IsSign: Boolean;
begin
  Result := '';
  MaxSym := Length(S);
  IsSign := (MaxSym > 0) and (S[1] in ['-', '+']);
  if IsSign then MinSym := 2
  else MinSym := 1;
  I := Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, S);
  if I > 0 then MaxSym := I - 1;
  I := Pos('E', AnsiUpperCase(S));
  if I > 0 then MaxSym := Min(I - 1, MaxSym);
  Result := Copy(S, MaxSym + 1, MaxInt);
  Group := 0;
  for I := MaxSym downto MinSym do begin
    Result := S[I] + Result;
    Inc(Group);
    if (Group = 3) and Thousands and (I > MinSym) then begin
      Group := 0;
      Result := {$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator + Result;
    end;
  end;
  if IsSign then Result := S[1] + Result;
end;

{ TbsSkinCustomCurrencyEdit }

function DelBSpace(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] = ' ') do Inc(I);
  Result := Copy(S, I, MaxInt);
end;

function DelESpace(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function DelRSpace(const S: string): string;
begin
  Result := DelBSpace(DelESpace(S));
end;

function DelChars(const S: string; Chr: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do begin
    if Result[I] = Chr then Delete(Result, I, 1);
  end;
end;

constructor TbsSkinCustomCurrencyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  MaxLength := 0;
  FBeepOnError := True;
  FAlignment := taRightJustify;
  FDisplayFormat := DefaultDisplayFormat;
  FDecimalPlaces := 2;
  FZeroEmpty := True;
  inherited Text := '';
  inherited Alignment := taLeftJustify;
  { forces update }
  DataChanged;
end;

destructor TbsSkinCustomCurrencyEdit.Destroy;
begin
  inherited Destroy;
end;

function TbsSkinCustomCurrencyEdit.DefaultDisplayFormat: string;
begin
  Result := ',0.##';
end;

function TbsSkinCustomCurrencyEdit.IsFormatStored: Boolean;
begin
  Result := (DisplayFormat <> DefaultDisplayFormat);
end;

function TbsSkinCustomCurrencyEdit.IsValidChar(Key: Char): Boolean;
var
  S: string;
  SelStart, SelStop, DecPos: Integer;
  RetValue: Extended;
begin
  Result := False;
  S := EditText;
  GetSel(SelStart, SelStop);
  System.Delete(S, SelStart + 1, SelStop - SelStart);
  System.Insert(Key, S, SelStart + 1);
  S := TextToValText(S);
  DecPos := Pos({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator, S);
  if (DecPos > 0) then begin
    SelStart := Pos('E', UpperCase(S));
    if (SelStart > DecPos) then DecPos := SelStart - DecPos
    else DecPos := Length(S) - DecPos;
    if DecPos > Integer(FDecimalPlaces) then Exit;
  end;
  Result := IsValidFloat(S, RetValue);
  if Result and (FMinValue >= 0) and (FMaxValue > 0) and (RetValue < 0) then
    Result := False;
end;

procedure TbsSkinCustomCurrencyEdit.KeyPress(var Key: Char);
begin
  if Key in (['.', ','] - [{$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator]) then
    Key := {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator;
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and not IsValidChar(Key) then begin
    if BeepOnError then MessageBeep(0);
    Key := #0;
  end
  else if Key = #27 then begin
    Reset;
    Key := #0;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.Reset;
begin
  DataChanged;
  SelectAll;
end;

procedure TbsSkinCustomCurrencyEdit.SetZeroEmpty(Value: Boolean);
begin
  if FZeroEmpty <> Value then begin
    FZeroEmpty := Value;
    DataChanged;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetBeepOnError(Value: Boolean);
begin
  if FBeepOnError <> Value then begin
    FBeepOnError := Value;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    Invalidate;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetDisplayFormat(const Value: string);
begin
  if DisplayFormat <> Value then begin
    FDisplayFormat := Value;
    Invalidate;
    DataChanged;
  end;
end;

function TbsSkinCustomCurrencyEdit.GetDisplayFormat: string;
begin
  Result := FDisplayFormat;
end;

procedure TbsSkinCustomCurrencyEdit.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then begin
    FFocused := Value;
    Invalidate;
    FFormatting := True;
    try
      DataChanged;
    finally
      FFormatting := False;
    end;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetFormatOnEditing(Value: Boolean);
begin
  if FFormatOnEditing <> Value then begin
    FFormatOnEditing := Value;
    if FFormatOnEditing then inherited Alignment := Alignment
    else inherited Alignment := taLeftJustify;
    if FFormatOnEditing and FFocused then ReformatEditText
    else if FFocused then begin
      UpdateData;
      DataChanged;
    end;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetDecimalPlaces(Value: Cardinal);
begin
  if FDecimalPlaces <> Value then begin
    FDecimalPlaces := Value;
    DataChanged;
    Invalidate;
  end;
end;

function TbsSkinCustomCurrencyEdit.FormatDisplayText(Value: Extended): string;
begin
  if DisplayFormat <> '' then
    Result := FormatFloat(DisplayFormat, Value)
  else
    Result := FloatToStr(Value);
end;

function TbsSkinCustomCurrencyEdit.GetDisplayText: string;
begin
  Result := FormatDisplayText(FValue);
end;

procedure TbsSkinCustomCurrencyEdit.Clear;
begin
  Text := '';
end;

procedure TbsSkinCustomCurrencyEdit.DataChanged;
var
  EditFormat: string;
begin
  EditFormat := '0';
  if FDecimalPlaces > 0 then
    EditFormat := EditFormat + '.' + MakeStr('#', FDecimalPlaces);
  if (FValue = 0.0) and FZeroEmpty then
    EditText := ''
  else
    EditText := FormatFloat(EditFormat, FValue);
end;

function TbsSkinCustomCurrencyEdit.CheckValue(NewValue: Extended;
  RaiseOnError: Boolean): Extended;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then begin
    if (FMaxValue > FMinValue) then begin
      if NewValue < FMinValue then Result := FMinValue
      else if NewValue > FMaxValue then Result := FMaxValue;
    end
    else begin
      if FMaxValue = 0 then begin
        if NewValue < FMinValue then Result := FMinValue;
      end
      else if FMinValue = 0 then begin
        if NewValue > FMaxValue then Result := FMaxValue;
      end;
    end;
 end;
end;

procedure TbsSkinCustomCurrencyEdit.CheckRange;
begin
  if not (csDesigning in ComponentState) and CheckOnExit then
    CheckValue(StrToFloat(TextToValText(EditText)), True);
end;

procedure TbsSkinCustomCurrencyEdit.UpdateData;
begin
  ValidateEdit;
  FValue := CheckValue(StrToFloat(TextToValText(EditText)), False);
end;

function TbsSkinCustomCurrencyEdit.GetValue: Extended;
begin
  if not (csDesigning in ComponentState) then
    try
      UpdateData;
    except
      FValue := FMinValue;
    end;
  Result := FValue;
end;

procedure TbsSkinCustomCurrencyEdit.SetValue(AValue: Extended);
begin
  FValue := CheckValue(AValue, False);
  DataChanged;
  Invalidate;
end;

function TbsSkinCustomCurrencyEdit.GetAsInteger: Longint;
begin
  Result := Trunc(Value);
end;

procedure TbsSkinCustomCurrencyEdit.SetAsInteger(AValue: Longint);
begin
  SetValue(AValue);
end;

procedure TbsSkinCustomCurrencyEdit.SetMinValue(AValue: Extended);
begin
  if FMinValue <> AValue then begin
    FMinValue := AValue;
    Value := FValue;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.SetMaxValue(AValue: Extended);
begin
  if FMaxValue <> AValue then begin
    FMaxValue := AValue;
    Value := FValue;
  end;
end;

function TbsSkinCustomCurrencyEdit.GetText: string;
begin
  Result := inherited Text;
end;

function TbsSkinCustomCurrencyEdit.TextToValText(const AValue: string): string;
begin
  Result := DelRSpace(AValue);
  if {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator <> {$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator then begin
    Result := DelChars(Result, {$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator);
  end;
  if ({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator <> '.') and ({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator <> '.') then
    Result := ReplaceStr(Result, '.', {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator);
  if ({$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator <> ',') and ({$IFDEF VER240_UP}FormatSettings.{$ENDIF}ThousandSeparator <> ',') then
    Result := ReplaceStr(Result, ',', {$IFDEF VER240_UP}FormatSettings.{$ENDIF}DecimalSeparator);
  if Result = '' then Result := '0'
  else if Result = '-' then Result := '-0';
end;

procedure TbsSkinCustomCurrencyEdit.SetText(const AValue: string);
begin
  if not (csReading in ComponentState) then begin
    FValue := CheckValue(StrToFloat(TextToValText(AValue)), False);
    DataChanged;
    Invalidate;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.ReformatEditText;
var
  S: string;
  IsEmpty: Boolean;
  OldLen, SelStart, SelStop: Integer;
begin
  FFormatting := True;
  try
    S := inherited Text;
    OldLen := Length(S);
    IsEmpty := (OldLen = 0) or (S = '-');
    if HandleAllocated then GetSel(SelStart, SelStop);
    if not IsEmpty then S := TextToValText(S);
    S := FormatFloatStr(S, Pos(',', DisplayFormat) > 0);
    inherited Text := S;
    if HandleAllocated and (GetFocus = Handle) and not
      (csDesigning in ComponentState) then
    begin
      Inc(SelStart, Length(S) - OldLen);
      SetCursor(SelStart);
    end;
  finally
    FFormatting := False;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.Change;
begin
  if not FFormatting then begin
    if FFormatOnEditing and FFocused then ReformatEditText;
    inherited Change;
  end;
end;

procedure TbsSkinCustomCurrencyEdit.WMPaste(var Message: TMessage);
var
  S: string;
begin
  S := EditText;
  try
    inherited;
    UpdateData;
  except
    EditText := S;
    SelectAll;
    if CanFocus then SetFocus;
    if BeepOnError then MessageBeep(0);
  end;
end;

procedure TbsSkinCustomCurrencyEdit.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  if FFormatOnEditing then ReformatEditText;
  inherited;
end;

procedure TbsSkinCustomCurrencyEdit.CMExit(var Message: TCMExit);
begin
  try
    CheckRange;
    UpdateData;
  except
    SelectAll;
    if CanFocus then SetFocus;
    raise;
  end;
  SetFocused(False);
  SetCursor(0);
  DoExit;
end;

procedure TbsSkinCustomCurrencyEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if NewStyleControls and not FFocused then Invalidate;
end;

procedure TbsSkinCustomCurrencyEdit.WMPaint(var Message: TWMPaint);
var
  S: string;
  FCanvas: TControlCanvas;
  DC: HDC;
  PS: TPaintStruct;
  TX, TY: Integer;
  R: TRect;
begin
  if FFocused
  then
    inherited
  else
    begin
      S := GetDisplayText;
      FCanvas := TControlCanvas.Create;
      FCanvas.Control := Self;
      DC := Message.DC;
      if DC = 0 then DC := BeginPaint(Handle, PS);
      FCanvas.Handle := DC;
      DrawEditBackGround(FCanvas);
      //
      with FCanvas do
      begin
        if (FIndex = -1) or not FUseSkinFont
        then
          begin
            Font := DefaultFont;
            if not Enabled then Font.Color := clGrayText;
            if FMouseIn
            then Font.Color := ActiveFontColor
            else Font.Color := FontColor;
            if not Enabled then Font.Color := DisabledFontColor;
          end
        else
          begin
            Font.Name := FontName;
            Font.Height := FontHeight;
            if FMouseIn
            then Font.Color := ActiveFontColor
            else Font.Color := FontColor;
            Font.Style := FontStyle;
            if not Enabled then Font.Color := DisabledFontColor;
          end;
        if (SkinData <> nil) and (SkinData.ResourceStrData <> nil)
        then
          Font.Charset := SkinData.ResourceStrData.CharSet
        else
          Font.CharSet := FDefaultFont.CharSet;
      end;
      R := FEditRect;
      OffsetRect(R, - R.Left, - R.Top);
      TY := R.Top;
      TX := R.Left;
      case Alignment of
        taCenter:
           TX := TX + RectWidth(R) div 2 - FCanvas.TextWidth(S) div 2;
        taRightJustify:
           TX := R.Right - 1 - FCanvas.TextWidth(S);
      end;
      FCanvas.Brush.Style := bsClear;
      FCanvas.TextRect(R, TX, TY, S);
      //
      FCanvas.Handle := 0;
      FCanvas.Free;
      if Message.DC = 0 then EndPaint(Handle, PS);
    end;
end;

procedure TbsSkinCustomCurrencyEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

constructor TbsSkinCurrencyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TbsSkinCurrencyEdit.DefaultDisplayFormat: string;
var
  CurrStr: string;
  I: Integer;
  C: Char;
begin
  Result := ',0.' + MakeStr('0', {$IFDEF VER240_UP}FormatSettings.{$ENDIF}CurrencyDecimals);
  CurrStr := '';
  for I := 1 to Length({$IFDEF VER240_UP}FormatSettings.{$ENDIF}CurrencyString) do begin
    C := {$IFDEF VER240_UP}FormatSettings.{$ENDIF}CurrencyString[I];
    if C in [',', '.'] then CurrStr := CurrStr + '''' + C + ''''
    else CurrStr := CurrStr + C;
  end;
  if Length(CurrStr) > 0 then
    case {$IFDEF VER240_UP}FormatSettings.{$ENDIF}CurrencyFormat of
      0: Result := CurrStr + Result; { '$1' }
      1: Result := Result + CurrStr; { '1$' }
      2: Result := CurrStr + ' ' + Result; { '$ 1' }
      3: Result := Result + ' ' + CurrStr; { '1 $' }
    end;
  Result := Format('%s;-%s', [Result, Result]);
end;

// TbsSkinComboBoxEx ==========================================================

constructor TbsComboExItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FIndent := -1;
  FImageIndex := -1;
  FSelectedImageIndex := -1;
  FCaption := '';
end;

procedure TbsComboExItem.Assign(Source: TPersistent);
begin
  if Source is TbsComboExItem then
  begin
    FSelectedImageIndex := TbsComboExItem(Source).SelectedImageIndex;
    FIndent := TbsComboExItem(Source).Indent;
    FImageIndex := TbsComboExItem(Source).ImageIndex;
    FCaption := TbsComboExItem(Source).Caption;
  end
  else
    inherited Assign(Source);
end;

procedure TbsComboExItem.SetSelectedImageIndex(const Value: TImageIndex);
begin
  FSelectedImageIndex := Value;
end;

procedure TbsComboExItem.SetImageIndex(const Value: TImageIndex);
begin
  FImageIndex := Value;
end;

procedure TbsComboExItem.SetCaption(const Value: String);
begin
  FCaption := Value;
  TbsComboExItems(Collection).SetComboBoxItem(Index);
end;

procedure TbsComboExItem.SetData(const Value: Pointer);
begin
  FData := Value;
end;

procedure TbsComboExItem.SetIndex(Value: Integer);
begin
  inherited SetIndex(Value);
  TbsComboExItems(Collection).SetComboBoxItem(Value);
end;

constructor TbsComboExItems.Create;
begin
  inherited Create(TbsComboExItem);
  ComboBoxEx := AComboBoxEx;
end;

function TbsComboExItems.GetOwner: TPersistent;
begin
  Result := ComboBoxEx;
end;

procedure TbsComboExItems.SetComboBoxItem(Index: Integer);
begin
  if Index < ComboBoxEx.Items.Count
  then
    ComboBoxEx.Items[Index] := Self.Items[Index].Caption;
end;

function TbsComboExItems.GetItem(Index: Integer):  TbsComboExItem;
begin
  Result := TbsComboExItem(inherited GetItem(Index));
end;

procedure TbsComboExItems.SetItem(Index: Integer; Value:  TbsComboExItem);
begin
  inherited SetItem(Index, Value);
  if Index < ComboBoxEx.Items.Count
  then
    ComboBoxEx.Items[Index] := Value.Caption;
end;

function TbsComboExItems.Add: TbsComboExItem;
begin
  Result := TbsComboExItem(inherited Add);
  ComboBoxEx.Items.Add(Result.Caption);
end;

function TbsComboExItems.Insert(Index: Integer): TbsComboExItem;
begin
  Result := TbsComboExItem(inherited Insert(Index));
  if Index < ComboBoxEx.Items.Count
  then
    ComboBoxEx.Items.Insert(Index, Result.Caption);
end;

procedure TbsComboExItems.Delete(Index: Integer);
begin
  inherited Delete(Index);
  if Index < ComboBoxEx.Items.Count
  then
    ComboBoxEx.Items.Delete(Index);
end;

procedure TbsComboExItems.Clear;
begin
  inherited Clear;
  ComboBoxEx.Items.Clear;
end;

constructor TbsSkinComboBoxEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItemsEx := TbsComboExItems.Create(Self);
  OnListBoxDrawItem := DrawItem;
  OnComboBoxDrawItem := ComboDrawItem;
end;

destructor TbsSkinComboBoxEx.Destroy;
begin
  FItemsEx.Free;
  inherited Destroy;
end;

procedure TbsSkinComboBoxEx.Loaded;
begin
  inherited;
  { if HandleAllocated then } LoadItems;
end;

procedure TbsSkinComboBoxEx.LoadItems;
var
  I: Integer;
begin
  Items.Clear;
  for I := 0 to ItemsEx.Count - 1 do Items.Add(ItemsEx[I].Caption);
end;

procedure TbsSkinComboBoxEx.SetItemsEx(Value: TbsComboExItems);
begin
  FItemsEx.Assign(Value);
end;

procedure TbsSkinComboBoxEx.ClearItemsEx;
begin
  FItemsEx.Clear;
end;

procedure TbsSkinComboBoxEx.DrawItem(Cnvs: TCanvas; Index: Integer;
      ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
var
  ImageTop: Integer;
  Offset: Integer;
  IIndex: Integer;
  TX, TY: Integer;
begin
  if ItemsEx[Index].Indent = -1
  then
    Offset := 0
  else
  if Images <> nil
  then
    Offset := ItemsEx[Index].Indent * Images.Width div 2
  else
    Offset := ItemsEx[Index].Indent * 10;
  TextRect.Left := TextRect.Left + Offset;
  if Images <> nil
  then
    begin
      IIndex := ItemsEx[Index].ImageIndex;
      if (Index = Self.FOldItemIndex) and (IIndex <> -1)
      then
        begin
          IIndex := ItemsEx[Index].SelectedImageIndex;
          if IIndex = -1 then IIndex := ItemsEx[Index].ImageIndex;
        end;
      if IIndex <> -1
      then
        begin
          ImageTop := TextRect.Top + ((TextRect.Bottom - TextRect.Top - Images.Height) div 2);
          Images.Draw(Cnvs, TextRect.Left, ImageTop, IIndex, True);
          TextRect.Left := TextRect.Left + Images.Width + 3;
        end;  
    end;
  TX := TextRect.Left;
  TY := TextRect.Top + (TextRect.Bottom - TextRect.Top) div 2 - Cnvs.TextHeight('Wg') div 2;
  //
  if (Cnvs.Font.Height div 2) <> (Cnvs.Font.Height / 2) then Dec(TY, 1);
  //
  Cnvs.TextOut(TX, TY, Items[Index]);
end;

procedure TbsSkinComboBoxEx.ComboDrawItem(Cnvs: TCanvas; Index: Integer;
          ItemWidth, ItemHeight: Integer; TextRect: TRect; State: TOwnerDrawState);
var
  ImageTop: Integer;
  IIndex: Integer;
  TX, TY: Integer;
begin
  Inc(TextRect.Left, 2);
  if Images <> nil
  then
    begin
      IIndex := ItemsEx[Index].SelectedImageIndex;
      if Index = -1 then IIndex := ItemsEx[Index].ImageIndex;
      if IIndex <> -1
      then
        begin
          ImageTop := TextRect.Top + ((TextRect.Bottom - TextRect.Top - Images.Height) div 2);
          Images.Draw(Cnvs, TextRect.Left, ImageTop, IIndex, True);
          TextRect.Left := TextRect.Left + Images.Width + 3;
        end;
    end;
  TX := TextRect.Left;
  TY := TextRect.Top + (TextRect.Bottom - TextRect.Top) div 2 - Cnvs.TextHeight('Wg') div 2;
  //
  if (Cnvs.Font.Height div 2) <> (Cnvs.Font.Height / 2) then Dec(TY, 1);
  //
  Cnvs.TextOut(TX, TY, Items[Index]);
end;

end.



