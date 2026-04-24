unit RuntimeMainMenuClone;

interface
uses
    Winapi.Windows,
    Winapi.Messages,
    Winapi.GDIPAPI,
    Winapi.GDIPOBJ,
    Winapi.GDIPUTIL,
    System.Classes,
    System.SysUtils,
    System.UITypes,
    System.Types,
    System.Generics.Collections,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Graphics,
    Vcl.ImgList,
    Vcl.Menus,
    Vcl.ExtCtrls,
    Vcl.GraphUtil;
type
    TRuntimeMenuMetrics = record
        PopupWidthMin: Integer;
        PopupItemHeight: Integer;
        PopupSeparatorHeight: Integer;
        PopupSplitX: Integer;
        PopupTextPaddingLeft: Integer;
        PopupTextPaddingRight: Integer;
        PopupShortcutGap: Integer;
        PopupSystemArrowReserveWidth: Integer;
        MenuBarItemHeight: Integer;
        MenuBarPaddingX: Integer;
        MenuBarPaddingY: Integer;
        CheckAreaSize: Integer;
        PopupBorderSize: Integer;
    end;
    TRuntimeMenuColors = record
        MenuBarFace: TColor;
        PopupGutterLeft: TColor;
        PopupGutterRight: TColor;
        PopupMainLeft: TColor;
        PopupMainRight: TColor;
        PopupBorderOuterLight: TColor;
        PopupBorderInnerLight: TColor;
        PopupBorderInnerShadow: TColor;
        PopupBorderOuterShadow: TColor;
        PopupSeparatorLeft: TColor;
        PopupSeparatorRight: TColor;
        SelectionFill: TColor;
        SelectionBorder: TColor;
        TextEnabled: TColor;
        TextDisabled: TColor;
        TextDisabledLight: TColor;
    end;
    TRuntimeMenuPainter = class
    private
        colorsValue: TRuntimeMenuColors;
        metricsValue: TRuntimeMenuMetrics;
        menuFontValue: TFont;
        radioDotSizeValue: Single;
        checkMarkSizeValue: Single;
        function ColorToArgb(const AColor: TColor; const AAlpha: Byte = $FF): ARGB;
        function RectWidth(const ARect: TRect): Integer;
        function RectHeight(const ARect: TRect): Integer;
        function GetCaptionText(Item: TMenuItem): string;
        function GetShortCutText(Item: TMenuItem): string;
        function MeasureTextWidth(ACanvas: TCanvas; const AText: string): Integer;
        procedure FillPopupGutterBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillPopupMainBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillPopupRowBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillMenuBarBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawPopupWindowBorder(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawPopupWindowBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawPopupSelection(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawSeparator(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawMenuText(ACanvas: TCanvas; const AText: string; const ARect: TRect; Alignment: TAlignment; bEnabled: Boolean);
        procedure DrawCheckMark(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
        procedure DrawSubMenuArrow(ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
        procedure DrawImageArea(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; Images: TCustomImageList);
    public
        constructor Create();
        destructor Destroy(); override;
        procedure AssignSystemFont();
        function MeasureMenuBarItemWidth(ACanvas: TCanvas; Item: TMenuItem): Integer;
        function MeasurePopupWidth(ACanvas: TCanvas; ParentItem: TMenuItem; Images: TCustomImageList): Integer;
        procedure PaintMenuBarItem(ACanvas: TCanvas; const ARect: TRect; Item: TMenuItem; bHot: Boolean);
        procedure PaintPopupItem(
            ACanvas: TCanvas;
            const ARect: TRect;
            Item: TMenuItem;
            Images: TCustomImageList;
            bHot: Boolean;
            bFirst: Boolean;
            bLast: Boolean
        );
        property Colors: TRuntimeMenuColors read colorsValue write colorsValue;
        property Metrics: TRuntimeMenuMetrics read metricsValue write metricsValue;
        property MenuFont: TFont read menuFontValue;
        property RadioDotSize: Single read radioDotSizeValue write radioDotSizeValue;
        property CheckMarkSize: Single read checkMarkSizeValue write checkMarkSizeValue;
    end;
    TRuntimeMenuFadeState = (mfsNone, mfsShowing, mfsHiding);
    TRuntimeMenuPopupForm = class;
    TRuntimeMainMenuBar = class;
    TRuntimeMenuPopupForm = class(TCustomForm)
    private
        ownerBarRef: TRuntimeMainMenuBar;
        painterRef: TRuntimeMenuPainter;
        parentItemRef: TMenuItem;
        ownerPopupRef: TRuntimeMenuPopupForm;
        childPopupRef: TRuntimeMenuPopupForm;
        imagesRef: TCustomImageList;
        hoveredIndex: Integer;
        pressedIndex: Integer;
        itemRects: TList<TRect>;
        closeTimerRef: TTimer;
        submenuTimerRef: TTimer;
        fadeTimerRef: TTimer;
        pendingOpenIndex: Integer;
        submenuShowDelayValue: Integer;
        fadeStateValue: TRuntimeMenuFadeState;
        fadeStartTickValue: Cardinal;
        fadeStartAlphaValue: Integer;
        fadeTargetAlphaValue: Integer;
        currentAlphaValue: Integer;
        afterCloseProc: TProc;
        hostFormRef: TCustomForm;
        procedure CloseTimerTick(Sender: TObject);
        procedure SubmenuTimerTick(Sender: TObject);
        procedure FadeTimerTick(Sender: TObject);
        procedure ApplyWindowAlpha(AAlpha: Integer);
        procedure StartFadeIn();
        procedure StartFadeOut(const AAfterClose: TProc; const bAnimate: Boolean);
        function ShouldUseFadeAnimation(): Boolean;
        procedure CloseChildPopup();
        procedure HideBranchWindows();
        procedure OpenChildPopup(Index: Integer);
        procedure StartPendingOpen(Index: Integer);
        procedure CancelPendingOpen();
        procedure SetHoveredIndex(Index: Integer; bOpenChild: Boolean);
        function GetVisibleItem(Index: Integer): TMenuItem;
        function GetVisibleCount(): Integer;
        function FindItemAt(const Pt: TPoint): Integer;
        function GetItemRect(Index: Integer): TRect;
        function GetScreenRectForChild(Index: Integer): TRect;
        function ContainsScreenPoint(const ScreenPt: TPoint): Boolean;
        function GetSystemMenuShowDelay: Integer;
        procedure TriggerItem(Index: Integer);
        procedure RebuildSize();
        function IsSelectableIndex(Index: Integer): Boolean;
        function FindFirstSelectableIndex(): Integer;
        function FindLastSelectableIndex(): Integer;
        function FindNextSelectableIndex(StartIndex, Delta: Integer): Integer;
        function FindMnemonicIndex(const AChar: Char): Integer;
    protected
        procedure CreateParams(var Params: TCreateParams); override;
        procedure Paint(); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
        procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
        procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
        procedure WMCancelMode(var Message: TMessage); message WM_CANCELMODE;
    public
        constructor CreatePopup(
            AOwner: TComponent;
            AOwnerBar: TRuntimeMainMenuBar;
            APainter: TRuntimeMenuPainter;
            AParentItem: TMenuItem;
            AImages: TCustomImageList;
            AOwnerPopup: TRuntimeMenuPopupForm
        );
        destructor Destroy(); override;
        procedure PopupAt(const ScreenPos: TPoint);
        procedure CloseBranch(const AAfterClose: TProc = nil; const bAnimate: Boolean = True);
        procedure SelectFirstKeyboard();
        procedure SelectLastKeyboard();
        procedure NavigateVertical(Delta: Integer);
        function TryOpenHoveredChild(): Boolean;
        procedure ActivateCurrent();
        procedure CloseOwnedChildPopup();
        function GetDeepestPopup(): TRuntimeMenuPopupForm;
        procedure ActivateMnemonic(const AChar: Char);
        property ParentItem: TMenuItem read parentItemRef;
        property OwnerPopup: TRuntimeMenuPopupForm read ownerPopupRef;
        property HoveredIndexValue: Integer read hoveredIndex;
        property ChildPopup: TRuntimeMenuPopupForm read childPopupRef;
    end;
    TRuntimeMainMenuBar = class(TCustomControl)
    private
        sourceMenuRef: TMainMenu;
        painterRef: TRuntimeMenuPainter;
        menuBarRects: TList<TRect>;
        visibleTopItems: TList<TMenuItem>;
        activePopupRef: TRuntimeMenuPopupForm;
        activeTopIndex: Integer;
        hoveredTopIndex: Integer;
        imagesRef: TCustomImageList;
        bTrackingMouse: Boolean;
        bMenuModeHooked: Boolean;
        bMenuFadeEnabled: Boolean;
        bRespectSystemMenuAnimation: Boolean;
        bRespectSystemMenuFade: Boolean;
        menuFadeDurationValue: Integer;
        savedAppOnMessage: TMessageEvent;
        bPendingAltToggle: Boolean;
        procedure SetSourceMenu(const Value: TMainMenu);
        procedure SetPainter(const Value: TRuntimeMenuPainter);
        procedure SetMenuFadeDuration(const Value: Integer);
        procedure ClosePopupBranch(const AAfterClose: TProc = nil; const bAnimate: Boolean = True);
        procedure OpenTopPopup(Index: Integer);
        function GetTopItem(Index: Integer): TMenuItem;
        function GetTopVisibleCount(): Integer;
        function FindTopItemAt(const Pt: TPoint): Integer;
        function GetTopItemRect(Index: Integer): TRect;
        procedure RebuildLayout();
        procedure StartMouseTracking();
        function FindImages(): TCustomImageList;
        procedure BeginMenuMode();
        procedure EndMenuMode();
        procedure AppMessageHook(var Message: TMsg; var Handled: Boolean);
        function PointInMenuHierarchy(const ScreenPt: TPoint): Boolean;
        function ShouldUseFadeAnimation(): Boolean;
        function FindNextTopIndex(StartIndex, Delta: Integer): Integer;
        function FindMnemonicTopIndex(const AChar: Char): Integer;
        procedure OpenTopPopupKeyboard(Index: Integer);
        procedure ToggleKeyboardMenu();
    protected
        procedure Paint(); override;
        procedure Resize(); override;
        procedure Loaded(); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy(); override;
        procedure AttachMenu(AMenu: TMainMenu);
        procedure RefreshMenu();
        property SourceMenu: TMainMenu read sourceMenuRef write SetSourceMenu;
        property Painter: TRuntimeMenuPainter read painterRef write SetPainter;
        property ActivePopup: TRuntimeMenuPopupForm read activePopupRef;
    published
        property MenuFadeEnabled: Boolean read bMenuFadeEnabled write bMenuFadeEnabled default True;
        property MenuFadeDuration: Integer read menuFadeDurationValue write SetMenuFadeDuration default 220;
        property RespectSystemMenuAnimation: Boolean read bRespectSystemMenuAnimation write bRespectSystemMenuAnimation default False;
        property RespectSystemMenuFade: Boolean read bRespectSystemMenuFade write bRespectSystemMenuFade default False;
        property Align;
        property Anchors;
        property Font;
        property ParentFont;
        property Visible;
        property Height default 24;
    end;
procedure ReplaceMainMenuWithRuntimeBar(AForm: TCustomForm; AMenu: TMainMenu; out ABar: TRuntimeMainMenuBar);
implementation
function GetMenuMnemonic(const ACaption: string): Char;
var
    i: Integer;
begin
    Result := #0;
    i := 1;
    while i <= Length(ACaption) do
    begin
        if ACaption[i] = '&' then
        begin
            if i < Length(ACaption) then
            begin
                if ACaption[i + 1] = '&' then
                begin
                    Inc(i);
                end
                else
                begin
                    Result := UpCase(ACaption[i + 1]);
                    Exit();
                end;
            end;
        end;
        Inc(i);
    end;
end;
procedure ReplaceMainMenuWithRuntimeBar(AForm: TCustomForm; AMenu: TMainMenu; out ABar: TRuntimeMainMenuBar);
begin
    if AForm = nil then
    begin
        raise Exception.Create('AForm is nil');
    end;
    if AMenu = nil then
    begin
        raise Exception.Create('AMenu is nil');
    end;
    AForm.Menu := nil;
    ABar := TRuntimeMainMenuBar.Create(AForm);
    ABar.Parent := AForm;
    ABar.Align := alTop;
    ABar.AttachMenu(AMenu);
    ABar.BringToFront();
end;
{ TRuntimeMenuPainter }
constructor TRuntimeMenuPainter.Create();
begin
    inherited Create();
    menuFontValue := TFont.Create();
    metricsValue.PopupWidthMin := 100;
    metricsValue.PopupItemHeight := 22;
    metricsValue.PopupSeparatorHeight := 8;
    metricsValue.PopupSplitX := 25;
    metricsValue.PopupTextPaddingLeft := 8;
    metricsValue.PopupTextPaddingRight := 8;
    metricsValue.PopupShortcutGap := 24;
    metricsValue.PopupSystemArrowReserveWidth := 14;
    metricsValue.MenuBarItemHeight := 24;
    metricsValue.MenuBarPaddingX := 6;
    metricsValue.MenuBarPaddingY := 3;
    metricsValue.CheckAreaSize := 16;
    metricsValue.PopupBorderSize := 2;
    colorsValue.MenuBarFace := RGB(212, 208, 200);
    colorsValue.PopupGutterLeft := $00C8D0D4;
    colorsValue.PopupGutterRight := $00BAC1C5;
    colorsValue.PopupMainLeft := $00DCE4E9;
    colorsValue.PopupMainRight := $00C8D0D4;
    colorsValue.PopupBorderOuterLight := clWhite;
    colorsValue.PopupBorderInnerLight := RGB(212, 208, 200);
    colorsValue.PopupBorderInnerShadow := RGB(128, 128, 128);
    colorsValue.PopupBorderOuterShadow := RGB(64, 64, 64);
    colorsValue.PopupSeparatorLeft := $00A0A6A9;
    colorsValue.PopupSeparatorRight := $00C8D0D4;
    colorsValue.SelectionFill := RGB(182, 190, 211);
    colorsValue.SelectionBorder := RGB(10, 36, 106);
    colorsValue.TextEnabled := clBlack;
    colorsValue.TextDisabled := RGB(128, 128, 128);
    colorsValue.TextDisabledLight := clWhite;
    radioDotSizeValue := 10.0;
    checkMarkSizeValue := 10.0;
    AssignSystemFont();
end;
destructor TRuntimeMenuPainter.Destroy();
begin
    menuFontValue.Free();
    inherited Destroy();
end;
procedure TRuntimeMenuPainter.AssignSystemFont();
begin
    menuFontValue.Assign(Screen.MenuFont);
end;
function TRuntimeMenuPainter.ColorToArgb(const AColor: TColor; const AAlpha: Byte): ARGB;
var
    rgbColor: COLORREF;
begin
    rgbColor := ColorToRGB(AColor);
    Result := MakeColor(AAlpha, GetRValue(rgbColor), GetGValue(rgbColor), GetBValue(rgbColor));
end;
function TRuntimeMenuPainter.RectWidth(const ARect: TRect): Integer;
begin
    Result := ARect.Right - ARect.Left;
end;
function TRuntimeMenuPainter.RectHeight(const ARect: TRect): Integer;
begin
    Result := ARect.Bottom - ARect.Top;
end;
function TRuntimeMenuPainter.GetCaptionText(Item: TMenuItem): string;
var
    tabPos: Integer;
begin
    Result := '';
    if Item = nil then
    begin
        Exit();
    end;
    if Trim(Item.Caption) = '-' then
    begin
        Exit();
    end;
    Result := Item.Caption;
    tabPos := Pos(#9, Result);
    if tabPos > 0 then
    begin
        Result := Copy(Result, 1, tabPos - 1);
    end;
end;
function TRuntimeMenuPainter.GetShortCutText(Item: TMenuItem): string;
var
    captionText: string;
    tabPos: Integer;
begin
    Result := '';
    if Item = nil then
    begin
        Exit();
    end;
    if Trim(Item.Caption) = '-' then
    begin
        Exit();
    end;
    Result := ShortCutToText(Item.ShortCut);
    if Result = '' then
    begin
        captionText := Item.Caption;
        tabPos := Pos(#9, captionText);
        if tabPos > 0 then
        begin
            Result := Copy(captionText, tabPos + 1, MaxInt);
        end;
    end;
end;
function TRuntimeMenuPainter.MeasureTextWidth(ACanvas: TCanvas; const AText: string): Integer;
var
    textRect: TRect;
begin
    if AText = '' then
    begin
        Result := 0;
        Exit();
    end;
    textRect := Rect(0, 0, 0, 0);
    DrawText(
        ACanvas.Handle,
        PChar(AText),
        Length(AText),
        textRect,
        DT_SINGLELINE or DT_VCENTER or DT_CALCRECT
    );
    Result := textRect.Right - textRect.Left;
end;
procedure TRuntimeMenuPainter.FillPopupGutterBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    if RectWidth(ARect) <= 0 then
    begin
        Exit();
    end;
    GradientFillCanvas(
        ACanvas,
        colorsValue.PopupGutterLeft,
        colorsValue.PopupGutterRight,
        ARect,
        gdHorizontal
    );
end;
procedure TRuntimeMenuPainter.FillPopupMainBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    if RectWidth(ARect) <= 0 then
    begin
        Exit();
    end;
    GradientFillCanvas(
        ACanvas,
        colorsValue.PopupMainLeft,
        colorsValue.PopupMainRight,
        ARect,
        gdHorizontal
    );
end;
procedure TRuntimeMenuPainter.FillPopupRowBackground(ACanvas: TCanvas; const ARect: TRect);
var
    splitX: Integer;
    gutterRect: TRect;
    mainRect: TRect;
begin
    splitX := ARect.Left + metricsValue.PopupSplitX;
    gutterRect := Rect(ARect.Left, ARect.Top, splitX, ARect.Bottom);
    mainRect := Rect(splitX, ARect.Top, ARect.Right, ARect.Bottom);
    FillPopupGutterBackground(ACanvas, gutterRect);
    FillPopupMainBackground(ACanvas, mainRect);
end;
procedure TRuntimeMenuPainter.FillMenuBarBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := colorsValue.MenuBarFace;
    ACanvas.FillRect(ARect);
end;
procedure TRuntimeMenuPainter.DrawPopupWindowBackground(ACanvas: TCanvas; const ARect: TRect);
var
    splitX: Integer;
    gutterRect: TRect;
    mainRect: TRect;
begin
    splitX := ARect.Left + metricsValue.PopupSplitX;
    gutterRect := Rect(ARect.Left, ARect.Top, splitX, ARect.Bottom);
    mainRect := Rect(splitX, ARect.Top, ARect.Right, ARect.Bottom);
    FillPopupGutterBackground(ACanvas, gutterRect);
    FillPopupMainBackground(ACanvas, mainRect);
end;
procedure TRuntimeMenuPainter.DrawPopupWindowBorder(ACanvas: TCanvas; const ARect: TRect);
var
    leftX: Integer;
    rightX: Integer;
    topY: Integer;
    bottomY: Integer;
begin
    leftX := ARect.Left;
    rightX := ARect.Right - 1;
    topY := ARect.Top;
    bottomY := ARect.Bottom - 1;
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := colorsValue.PopupBorderOuterLight;
    ACanvas.MoveTo(leftX, topY);
    ACanvas.LineTo(leftX, bottomY + 1);
    ACanvas.MoveTo(leftX, topY);
    ACanvas.LineTo(rightX + 1, topY);
    ACanvas.Pen.Color := colorsValue.PopupBorderInnerLight;
    ACanvas.MoveTo(leftX + 1, topY + 1);
    ACanvas.LineTo(leftX + 1, bottomY);
    ACanvas.MoveTo(leftX + 1, topY + 1);
    ACanvas.LineTo(rightX, topY + 1);
    ACanvas.Pen.Color := colorsValue.PopupBorderInnerShadow;
    ACanvas.MoveTo(rightX - 1, topY + 1);
    ACanvas.LineTo(rightX - 1, bottomY);
    ACanvas.MoveTo(leftX + 1, bottomY - 1);
    ACanvas.LineTo(rightX, bottomY - 1);
    ACanvas.Pen.Color := colorsValue.PopupBorderOuterShadow;
    ACanvas.MoveTo(rightX, topY);
    ACanvas.LineTo(rightX, bottomY + 1);
    ACanvas.MoveTo(leftX, bottomY);
    ACanvas.LineTo(rightX + 1, bottomY);
end;
procedure TRuntimeMenuPainter.DrawPopupSelection(ACanvas: TCanvas; const ARect: TRect);
var
    selRect: TRect;
begin
    selRect := ARect;
    InflateRect(selRect, -metricsValue.PopupBorderSize, -1);
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := colorsValue.SelectionFill;
    ACanvas.FillRect(selRect);
    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Color := colorsValue.SelectionBorder;
    ACanvas.Rectangle(selRect.Left, selRect.Top, selRect.Right, selRect.Bottom);
    ACanvas.Brush.Style := bsSolid;
end;
procedure TRuntimeMenuPainter.DrawSeparator(ACanvas: TCanvas; const ARect: TRect);
var
    bandTop: Integer;
    bandRect: TRect;
begin
    FillPopupRowBackground(ACanvas, ARect);
    bandTop := ARect.Top + ((RectHeight(ARect) - 2) div 2);
    bandRect := Rect(
        ARect.Left + metricsValue.PopupSplitX,
        bandTop,
        ARect.Right,
        bandTop + 2
    );
    GradientFillCanvas(
        ACanvas,
        colorsValue.PopupSeparatorLeft,
        colorsValue.PopupSeparatorRight,
        bandRect,
        gdHorizontal
    );
end;
procedure TRuntimeMenuPainter.DrawMenuText(ACanvas: TCanvas; const AText: string; const ARect: TRect; Alignment: TAlignment; bEnabled: Boolean);
var
    textRect: TRect;
    flags: Cardinal;
begin
    if AText = '' then
    begin
        Exit();
    end;
    textRect := ARect;
    flags := DT_SINGLELINE or DT_VCENTER;
    case Alignment of
        taLeftJustify:
            flags := flags or DT_LEFT;
        taRightJustify:
            flags := flags or DT_RIGHT;
        taCenter:
            flags := flags or DT_CENTER;
    end;
    SetBkMode(ACanvas.Handle, TRANSPARENT);
    if bEnabled = False then
    begin
        OffsetRect(textRect, 1, 1);
        SetTextColor(ACanvas.Handle, ColorToRGB(colorsValue.TextDisabledLight));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
        OffsetRect(textRect, -1, -1);
        SetTextColor(ACanvas.Handle, ColorToRGB(colorsValue.TextDisabled));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
    end
    else
    begin
        SetTextColor(ACanvas.Handle, ColorToRGB(colorsValue.TextEnabled));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
    end;
end;
procedure TRuntimeMenuPainter.DrawCheckMark(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
var
    oldPenColor: TColor;
    oldBrushColor: TColor;
    oldBrushStyle: TBrushStyle;
    oldPenStyle: TPenStyle;
    oldPenWidth: Integer;
    procedure DrawRadioAt(dx, dy: Integer; AColor: TColor);
    var
        gp: TGPGraphics;
        brush: TGPSolidBrush;
        dotSize: Single;
        x: Single;
        y: Single;
    begin
        dotSize := radioDotSizeValue;
        if dotSize < 2.0 then
        begin
            dotSize := 2.0;
        end;
        x := ARect.Left + ((RectWidth(ARect) - dotSize) / 2.0) + dx;
        y := ARect.Top + ((RectHeight(ARect) - dotSize) / 2.0) + dy;
        gp := TGPGraphics.Create(ACanvas.Handle);
        brush := TGPSolidBrush.Create(ColorToArgb(AColor));
        try
            gp.SetSmoothingMode(SmoothingModeAntiAlias);
            gp.SetPixelOffsetMode(PixelOffsetModeHalf);
            gp.FillEllipse(brush, x, y, dotSize, dotSize);
        finally
            brush.Free();
            gp.Free();
        end;
    end;
    procedure DrawCheckAt(dx, dy: Integer; AColor: TColor);
    var
        gp: TGPGraphics;
        pen: TGPPen;
        markSize: Single;
        cx: Single;
        cy: Single;
        p1: TGPPointF;
        p2: TGPPointF;
        p3: TGPPointF;
        strokeWidth: Single;
    begin
        markSize := checkMarkSizeValue;
        if markSize < 6.0 then
        begin
            markSize := 6.0;
        end;
        cx := ARect.Left + (RectWidth(ARect) / 2.0) + dx;
        cy := ARect.Top + (RectHeight(ARect) / 2.0) + dy;
        strokeWidth := markSize / 5.0;
        if strokeWidth < 1.6 then
        begin
            strokeWidth := 1.6;
        end;
        p1.X := cx - (markSize * 0.33);
        p1.Y := cy + (markSize * 0.02);
        p2.X := cx - (markSize * 0.08);
        p2.Y := cy + (markSize * 0.28);
        p3.X := cx + (markSize * 0.34);
        p3.Y := cy - (markSize * 0.26);
        gp := TGPGraphics.Create(ACanvas.Handle);
        pen := TGPPen.Create(ColorToArgb(AColor), strokeWidth);
        try
            gp.SetSmoothingMode(SmoothingModeAntiAlias);
            gp.SetPixelOffsetMode(PixelOffsetModeHalf);
            pen.SetLineJoin(LineJoinRound);
            pen.SetStartCap(LineCapRound);
            pen.SetEndCap(LineCapRound);
            gp.DrawLine(pen, p1, p2);
            gp.DrawLine(pen, p2, p3);
        finally
            pen.Free();
            gp.Free();
        end;
    end;
begin
    oldPenColor := ACanvas.Pen.Color;
    oldBrushColor := ACanvas.Brush.Color;
    oldBrushStyle := ACanvas.Brush.Style;
    oldPenStyle := ACanvas.Pen.Style;
    oldPenWidth := ACanvas.Pen.Width;
    try
        if bEnabled = False then
        begin
            if Item.RadioItem = True then
            begin
                DrawRadioAt(1, 1, colorsValue.TextDisabledLight);
                DrawRadioAt(0, 0, colorsValue.TextDisabled);
            end
            else
            begin
                DrawCheckAt(1, 1, colorsValue.TextDisabledLight);
                DrawCheckAt(0, 0, colorsValue.TextDisabled);
            end;
        end
        else
        begin
            if Item.RadioItem = True then
            begin
                DrawRadioAt(0, 0, colorsValue.TextEnabled);
            end
            else
            begin
                DrawCheckAt(0, 0, colorsValue.TextEnabled);
            end;
        end;
    finally
        ACanvas.Pen.Color := oldPenColor;
        ACanvas.Brush.Color := oldBrushColor;
        ACanvas.Brush.Style := oldBrushStyle;
        ACanvas.Pen.Style := oldPenStyle;
        ACanvas.Pen.Width := oldPenWidth;
    end;
end;
procedure TRuntimeMenuPainter.DrawSubMenuArrow(ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
var
    gp: TGPGraphics;
    brush: TGPSolidBrush;
    points: array[0..2] of TGPPointF;
    centerX: Single;
    centerY: Single;
    arrowWidthValue: Single;
    arrowHeightValue: Single;
    arrowColor: TColor;
begin
    if RectWidth(ARect) <= 0 then
    begin
        Exit();
    end;
    if RectHeight(ARect) <= 0 then
    begin
        Exit();
    end;
    if bEnabled = True then
    begin
        arrowColor := colorsValue.TextEnabled;
    end
    else
    begin
        arrowColor := colorsValue.TextDisabled;
    end;
    centerX := ARect.Left + (RectWidth(ARect) / 2.0);
    centerY := ARect.Top + (RectHeight(ARect) / 2.0);
    arrowWidthValue := 5.0;
    arrowHeightValue := 8.0;
    points[0] := MakePoint(centerX - (arrowWidthValue / 2.0), centerY - (arrowHeightValue / 2.0));
    points[1] := MakePoint(centerX - (arrowWidthValue / 2.0), centerY + (arrowHeightValue / 2.0));
    points[2] := MakePoint(centerX + (arrowWidthValue / 2.0), centerY);
    gp := TGPGraphics.Create(ACanvas.Handle);
    brush := TGPSolidBrush.Create(ColorToArgb(arrowColor));
    try
        gp.SetSmoothingMode(SmoothingModeAntiAlias);
        gp.SetPixelOffsetMode(PixelOffsetModeHalf);
        gp.FillPolygon(brush, PGPPointF(@points[0]), Length(points));
    finally
        brush.Free();
        gp.Free();
    end;
end;
procedure TRuntimeMenuPainter.DrawImageArea(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; Images: TCustomImageList);
var
    drawX: Integer;
    drawY: Integer;
begin
    if Item = nil then
    begin
        Exit();
    end;
    if Item.Checked = True then
    begin
        DrawCheckMark(Item, ACanvas, ARect, Item.Enabled);
        Exit();
    end;
    if Item.Bitmap.Empty = False then
    begin
        drawX := ARect.Left + ((RectWidth(ARect) - Item.Bitmap.Width) div 2);
        drawY := ARect.Top + ((RectHeight(ARect) - Item.Bitmap.Height) div 2);
        if Item.Enabled = True then
        begin
            ACanvas.Draw(drawX, drawY, Item.Bitmap);
        end
        else
        begin
            DrawState(
                ACanvas.Handle,
                0,
                nil,
                LPARAM(Item.Bitmap.Handle),
                0,
                drawX,
                drawY,
                Item.Bitmap.Width,
                Item.Bitmap.Height,
                DST_BITMAP or DSS_DISABLED
            );
        end;
        Exit();
    end;
    if (Images <> nil) and (Item.ImageIndex >= 0) then
    begin
        drawX := ARect.Left + ((RectWidth(ARect) - Images.Width) div 2);
        drawY := ARect.Top + ((RectHeight(ARect) - Images.Height) div 2);
        Images.Draw(ACanvas, drawX, drawY, Item.ImageIndex, Item.Enabled);
    end;
end;
function TRuntimeMenuPainter.MeasureMenuBarItemWidth(ACanvas: TCanvas; Item: TMenuItem): Integer;
var
    oldStyle: TFontStyles;
begin
    ACanvas.Font.Assign(menuFontValue);
    if Item = nil then
    begin
        Result := (metricsValue.MenuBarPaddingX * 2) + 10;
        Exit();
    end;
    oldStyle := ACanvas.Font.Style;
    try
        if Item.Default = True then
        begin
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end;
        Result := MeasureTextWidth(ACanvas, GetCaptionText(Item)) + (metricsValue.MenuBarPaddingX * 2) + 10;
    finally
        ACanvas.Font.Style := oldStyle;
    end;
end;
function TRuntimeMenuPainter.MeasurePopupWidth(ACanvas: TCanvas; ParentItem: TMenuItem; Images: TCustomImageList): Integer;
var
    maxWidthValue: Integer;
    oldStyle: TFontStyles;
begin
    Result := metricsValue.PopupWidthMin;
    if ParentItem = nil then
    begin
        Exit();
    end;
    ACanvas.Font.Assign(menuFontValue);
    maxWidthValue := metricsValue.PopupWidthMin;
    for var i := 0 to ParentItem.Count - 1 do
    begin
        var item := ParentItem.Items[i];
        if item.Visible = False then
        begin
            Continue;
        end;
        if Trim(item.Caption) = '-' then
        begin
            Continue;
        end;
        oldStyle := ACanvas.Font.Style;
        try
            if item.Default = True then
            begin
                ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
            end;
            var currentWidth := metricsValue.PopupSplitX + metricsValue.PopupTextPaddingLeft + metricsValue.PopupTextPaddingRight;
            Inc(currentWidth, MeasureTextWidth(ACanvas, GetCaptionText(item)));
            var shortCutText := GetShortCutText(item);
            if shortCutText <> '' then
            begin
                Inc(currentWidth, metricsValue.PopupShortcutGap + MeasureTextWidth(ACanvas, shortCutText));
            end;
            if item.Count > 0 then
            begin
                Inc(currentWidth, metricsValue.PopupSystemArrowReserveWidth);
            end;
            if currentWidth > maxWidthValue then
            begin
                maxWidthValue := currentWidth;
            end;
        finally
            ACanvas.Font.Style := oldStyle;
        end;
    end;
    Result := maxWidthValue;
end;
procedure TRuntimeMenuPainter.PaintMenuBarItem(ACanvas: TCanvas; const ARect: TRect; Item: TMenuItem; bHot: Boolean);
var
    textRect: TRect;
    oldStyle: TFontStyles;
begin
    if Item = nil then
    begin
        FillMenuBarBackground(ACanvas, ARect);
        Exit();
    end;
    FillMenuBarBackground(ACanvas, ARect);
    if bHot = True then
    begin
        ACanvas.Pen.Style := psSolid;
        ACanvas.Pen.Color := colorsValue.PopupBorderInnerShadow;
        ACanvas.MoveTo(ARect.Left, ARect.Bottom - 1);
        ACanvas.LineTo(ARect.Left, ARect.Top);
        ACanvas.LineTo(ARect.Right - 1, ARect.Top);
        ACanvas.Pen.Color := colorsValue.PopupBorderOuterLight;
        ACanvas.MoveTo(ARect.Right - 1, ARect.Top + 1);
        ACanvas.LineTo(ARect.Right - 1, ARect.Bottom - 1);
        ACanvas.LineTo(ARect.Left + 1, ARect.Bottom - 1);
    end;
    textRect := ARect;
    Inc(textRect.Left, 2);
    Dec(textRect.Right, 2);
    Inc(textRect.Top, metricsValue.MenuBarPaddingY);
    Dec(textRect.Bottom, metricsValue.MenuBarPaddingY);
    oldStyle := ACanvas.Font.Style;
    try
        if Item.Default = True then
        begin
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end;
        DrawMenuText(ACanvas, GetCaptionText(Item), textRect, taCenter, Item.Enabled);
    finally
        ACanvas.Font.Style := oldStyle;
    end;
end;
procedure TRuntimeMenuPainter.PaintPopupItem(
    ACanvas: TCanvas;
    const ARect: TRect;
    Item: TMenuItem;
    Images: TCustomImageList;
    bHot: Boolean;
    bFirst: Boolean;
    bLast: Boolean
);
var
    splitX: Integer;
    iconRect: TRect;
    captionRect: TRect;
    shortCutRect: TRect;
    arrowRect: TRect;
    rightLimit: Integer;
    shortCutText: string;
    shortCutWidth: Integer;
    oldStyle: TFontStyles;
begin
    if Trim(Item.Caption) = '-' then
    begin
        DrawSeparator(ACanvas, ARect);
        Exit();
    end;
    if bHot = True then
    begin
        DrawPopupSelection(ACanvas, ARect);
    end
    else
    begin
        FillPopupRowBackground(ACanvas, ARect);
    end;
    splitX := ARect.Left + metricsValue.PopupSplitX;
    iconRect := Rect(ARect.Left, ARect.Top, splitX, ARect.Bottom);
    DrawImageArea(Item, ACanvas, iconRect, Images);
    rightLimit := ARect.Right - metricsValue.PopupTextPaddingRight;
    if Item.Count > 0 then
    begin
        Dec(rightLimit, metricsValue.PopupSystemArrowReserveWidth);
    end;
    oldStyle := ACanvas.Font.Style;
    try
        if Item.Default = True then
        begin
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end;
        shortCutText := GetShortCutText(Item);
        shortCutWidth := 0;
        if shortCutText <> '' then
        begin
            shortCutWidth := MeasureTextWidth(ACanvas, shortCutText);
            shortCutRect := Rect(rightLimit - shortCutWidth, ARect.Top, rightLimit, ARect.Bottom);
            DrawMenuText(ACanvas, shortCutText, shortCutRect, taRightJustify, Item.Enabled);
            rightLimit := shortCutRect.Left - metricsValue.PopupShortcutGap;
        end;
        captionRect := Rect(splitX + metricsValue.PopupTextPaddingLeft, ARect.Top, rightLimit, ARect.Bottom);
        DrawMenuText(ACanvas, GetCaptionText(Item), captionRect, taLeftJustify, Item.Enabled);
    finally
        ACanvas.Font.Style := oldStyle;
    end;
    if Item.Count > 0 then
    begin
        arrowRect := Rect(
            ARect.Right - metricsValue.PopupSystemArrowReserveWidth,
            ARect.Top,
            ARect.Right - metricsValue.PopupTextPaddingRight,
            ARect.Bottom
        );
        DrawSubMenuArrow(ACanvas, arrowRect, Item.Enabled);
    end;
end;
{ TRuntimeMenuPopupForm }
{ TRuntimeMenuPopupForm }
constructor TRuntimeMenuPopupForm.CreatePopup(
    AOwner: TComponent;
    AOwnerBar: TRuntimeMainMenuBar;
    APainter: TRuntimeMenuPainter;
    AParentItem: TMenuItem;
    AImages: TCustomImageList;
    AOwnerPopup: TRuntimeMenuPopupForm
);
begin
    inherited CreateNew(AOwner);
    BorderStyle := bsNone;
    Position := poDesigned;
    Visible := False;
    DoubleBuffered := True;
    ParentFont := False;
    Font.Assign(APainter.MenuFont);
    Color := clBtnFace;
    ownerBarRef := AOwnerBar;
    hostFormRef := GetParentForm(AOwnerBar);
    PopupMode := pmExplicit;
    if hostFormRef <> nil then
    begin
        PopupParent := hostFormRef;
    end;
    painterRef := APainter;
    parentItemRef := AParentItem;
    ownerPopupRef := AOwnerPopup;
    imagesRef := AImages;
    hoveredIndex := -1;
    itemRects := TList<TRect>.Create();
    closeTimerRef := TTimer.Create(Self);
    closeTimerRef.Enabled := False;
    closeTimerRef.Interval := 120;
    closeTimerRef.OnTimer := CloseTimerTick;
    submenuShowDelayValue := GetSystemMenuShowDelay();
    pendingOpenIndex := -1;
    submenuTimerRef := TTimer.Create(Self);
    submenuTimerRef.Enabled := False;
    submenuTimerRef.Interval := submenuShowDelayValue;
    submenuTimerRef.OnTimer := SubmenuTimerTick;
    fadeTimerRef := TTimer.Create(Self);
    fadeTimerRef.Enabled := False;
    fadeTimerRef.Interval := 10;
    fadeTimerRef.OnTimer := FadeTimerTick;
    pressedIndex := -1;
    fadeStateValue := mfsNone;
    fadeStartTickValue := 0;
    fadeStartAlphaValue := 255;
    fadeTargetAlphaValue := 255;
    currentAlphaValue := 255;
    afterCloseProc := nil;
    RebuildSize();
end;
destructor TRuntimeMenuPopupForm.Destroy();
begin
    CancelPendingOpen();
    CloseChildPopup();
    itemRects.Free();
    inherited Destroy();
end;
procedure TRuntimeMenuPopupForm.CreateParams(var Params: TCreateParams);
begin
    inherited CreateParams(Params);
    Params.Style := WS_POPUP or WS_CLIPSIBLINGS;
    Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;
    if hostFormRef <> nil then
    begin
        Params.WndParent := hostFormRef.Handle;
    end;
    Params.WindowClass.Style := Params.WindowClass.Style or CS_SAVEBITS or CS_DROPSHADOW;
end;
procedure TRuntimeMenuPopupForm.ApplyWindowAlpha(AAlpha: Integer);
begin
    if AAlpha < 0 then
    begin
        AAlpha := 0;
    end
    else
    if AAlpha > 255 then
    begin
        AAlpha := 255;
    end;
    currentAlphaValue := AAlpha;
end;
function TRuntimeMenuPopupForm.ShouldUseFadeAnimation(): Boolean;
begin
    Result := False;
    if ownerBarRef = nil then
    begin
        Exit();
    end;
    Result := ownerBarRef.ShouldUseFadeAnimation();
end;
function TRuntimeMenuPopupForm.GetSystemMenuShowDelay: Integer;
var
    delayValue: UINT;
begin
    delayValue := 0;
    if SystemParametersInfo(SPI_GETMENUSHOWDELAY, 0, @delayValue, 0) = True then
    begin
        Result := Integer(delayValue);
    end
    else
    begin
        Result := 400;
    end;
    if Result < 0 then
    begin
        Result := 0;
    end;
end;
procedure TRuntimeMenuPopupForm.CancelPendingOpen();
begin
    pendingOpenIndex := -1;
    submenuTimerRef.Enabled := False;
end;
procedure TRuntimeMenuPopupForm.StartPendingOpen(Index: Integer);
begin
    CancelPendingOpen();
    if Index < 0 then
    begin
        Exit();
    end;
    pendingOpenIndex := Index;
    if submenuShowDelayValue <= 0 then
    begin
        OpenChildPopup(Index);
        Exit();
    end;
    submenuTimerRef.Interval := submenuShowDelayValue;
    submenuTimerRef.Enabled := True;
end;
procedure TRuntimeMenuPopupForm.SubmenuTimerTick(Sender: TObject);
var
    index: Integer;
begin
    submenuTimerRef.Enabled := False;
    index := pendingOpenIndex;
    pendingOpenIndex := -1;
    if index < 0 then
    begin
        Exit();
    end;
    if hoveredIndex <> index then
    begin
        Exit();
    end;
    OpenChildPopup(index);
end;
procedure TRuntimeMenuPopupForm.StartFadeIn();
var
    durationValue: Integer;
begin
    fadeTimerRef.Enabled := False;
    afterCloseProc := nil;
    fadeStateValue := mfsNone;
    currentAlphaValue := 255;
    if ShouldUseFadeAnimation() = False then
    begin
        Exit();
    end;
    if ownerBarRef <> nil then
    begin
        durationValue := ownerBarRef.MenuFadeDuration;
    end
    else
    begin
        durationValue := 0;
    end;
    if durationValue <= 0 then
    begin
        Exit();
    end;
    AnimateWindow(Handle, Cardinal(durationValue), AW_BLEND);
end;
procedure TRuntimeMenuPopupForm.StartFadeOut(const AAfterClose: TProc; const bAnimate: Boolean);
var
    localProc: TProc;
begin
    fadeTimerRef.Enabled := False;
    afterCloseProc := AAfterClose;
    fadeStateValue := mfsNone;
    Hide();
    currentAlphaValue := 255;
    localProc := afterCloseProc;
    afterCloseProc := nil;
    if Assigned(localProc) then
    begin
        localProc();
    end;
end;
procedure TRuntimeMenuPopupForm.FadeTimerTick(Sender: TObject);
begin
end;
procedure TRuntimeMenuPopupForm.CloseTimerTick(Sender: TObject);
begin
    closeTimerRef.Enabled := False;
    var cursorPos: TPoint;
    GetCursorPos(cursorPos);
    if PtInRect(BoundsRect, cursorPos) = False then
    begin
        if (childPopupRef = nil) or (PtInRect(childPopupRef.BoundsRect, cursorPos) = False) then
        begin
            CloseChildPopup();
            hoveredIndex := -1;
            Invalidate();
        end;
    end;
end;
procedure TRuntimeMenuPopupForm.CloseChildPopup();
begin
    CancelPendingOpen();
    if childPopupRef <> nil then
    begin
        childPopupRef.CloseBranch(nil, False);
        FreeAndNil(childPopupRef);
    end;
end;
procedure TRuntimeMenuPopupForm.HideBranchWindows();
begin
    closeTimerRef.Enabled := False;
    submenuTimerRef.Enabled := False;
    CancelPendingOpen();
    pressedIndex := -1;
    if GetCapture = Handle then
    begin
        ReleaseCapture();
    end;
    if childPopupRef <> nil then
    begin
        childPopupRef.HideBranchWindows();
    end;
    if HandleAllocated = True then
    begin
        ShowWindow(Handle, SW_HIDE);
    end;
end;
procedure TRuntimeMenuPopupForm.CloseBranch(const AAfterClose: TProc; const bAnimate: Boolean);
begin
    closeTimerRef.Enabled := False;
    submenuTimerRef.Enabled := False;
    CancelPendingOpen();
    pressedIndex := -1;
    if GetCapture = Handle then
    begin
        ReleaseCapture();
    end;
    if bAnimate = False then
    begin
        HideBranchWindows();
        CloseChildPopup();
        StartFadeOut(AAfterClose, False);
        Exit();
    end;
    CloseChildPopup();
    StartFadeOut(AAfterClose, bAnimate);
end;
function TRuntimeMenuPopupForm.GetVisibleCount(): Integer;
begin
    Result := 0;
    if parentItemRef = nil then
    begin
        Exit();
    end;
    for var i := 0 to parentItemRef.Count - 1 do
    begin
        if parentItemRef.Items[i].Visible = True then
        begin
            Inc(Result);
        end;
    end;
end;
function TRuntimeMenuPopupForm.GetVisibleItem(Index: Integer): TMenuItem;
var
    visibleIndex: Integer;
begin
    Result := nil;
    if parentItemRef = nil then
    begin
        Exit();
    end;
    visibleIndex := -1;
    for var i := 0 to parentItemRef.Count - 1 do
    begin
        var item := parentItemRef.Items[i];
        if item.Visible = False then
        begin
            Continue;
        end;
        Inc(visibleIndex);
        if visibleIndex = Index then
        begin
            Result := item;
            Exit();
        end;
    end;
end;
function TRuntimeMenuPopupForm.GetItemRect(Index: Integer): TRect;
begin
    if (Index < 0) or (Index >= itemRects.Count) then
    begin
        Result := Rect(0, 0, 0, 0);
        Exit();
    end;
    Result := itemRects[Index];
end;
function TRuntimeMenuPopupForm.GetScreenRectForChild(Index: Integer): TRect;
var
    itemRect: TRect;
    topLeftPt: TPoint;
begin
    itemRect := GetItemRect(Index);
    topLeftPt := ClientToScreen(Point(itemRect.Right - 3, itemRect.Top));
    Result := Rect(topLeftPt.X, topLeftPt.Y, topLeftPt.X + Width, topLeftPt.Y + itemRect.Height);
end;
function TRuntimeMenuPopupForm.ContainsScreenPoint(const ScreenPt: TPoint): Boolean;
begin
    Result := PtInRect(BoundsRect, ScreenPt);
    if (Result = False) and (childPopupRef <> nil) then
    begin
        Result := childPopupRef.ContainsScreenPoint(ScreenPt);
    end;
end;
function TRuntimeMenuPopupForm.FindItemAt(const Pt: TPoint): Integer;
begin
    Result := -1;
    for var i := 0 to itemRects.Count - 1 do
    begin
        if PtInRect(itemRects[i], Pt) = True then
        begin
            Result := i;
            Exit();
        end;
    end;
end;
procedure TRuntimeMenuPopupForm.RebuildSize();
var
    canvasRef: TControlCanvas;
    visibleCount: Integer;
    y: Integer;
begin
    itemRects.Clear();
    visibleCount := GetVisibleCount();
    canvasRef := TControlCanvas.Create();
    try
        canvasRef.Control := Self;
        canvasRef.Font.Assign(painterRef.MenuFont);
        Width := painterRef.MeasurePopupWidth(canvasRef, parentItemRef, imagesRef) + (painterRef.Metrics.PopupBorderSize * 2);
        y := painterRef.Metrics.PopupBorderSize;
        for var i := 0 to visibleCount - 1 do
        begin
            var item := GetVisibleItem(i);
            var itemHeightValue := painterRef.Metrics.PopupItemHeight;
            if Trim(item.Caption) = '-' then
            begin
                itemHeightValue := painterRef.Metrics.PopupSeparatorHeight;
            end;
            itemRects.Add(
                Rect(
                    painterRef.Metrics.PopupBorderSize,
                    y,
                    Width - painterRef.Metrics.PopupBorderSize,
                    y + itemHeightValue
                )
            );
            Inc(y, itemHeightValue);
        end;
        Height := y + painterRef.Metrics.PopupBorderSize;
    finally
        canvasRef.Free();
    end;
end;
procedure TRuntimeMenuPopupForm.PopupAt(const ScreenPos: TPoint);
begin
    RebuildSize();
    SetBounds(ScreenPos.X, ScreenPos.Y, Width, Height);
    HandleNeeded();
    SetWindowPos(
        Handle,
        HWND_TOP,
        Left,
        Top,
        Width,
        Height,
        SWP_NOACTIVATE or SWP_NOOWNERZORDER
    );
    if ShouldUseFadeAnimation() = True then
    begin
        StartFadeIn();
    end
    else
    begin
        SetWindowPos(
            Handle,
            HWND_TOP,
            Left,
            Top,
            Width,
            Height,
            SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_SHOWWINDOW
        );
    end;
    Invalidate();
end;
procedure TRuntimeMenuPopupForm.SetHoveredIndex(Index: Integer; bOpenChild: Boolean);
var
    item: TMenuItem;
begin
    if hoveredIndex = Index then
    begin
        if (Index >= 0) and (bOpenChild = True) then
        begin
            item := GetVisibleItem(Index);
            if (item <> nil) and (item.Count > 0) then
            begin
                if (childPopupRef = nil) or (childPopupRef.ParentItem <> item) then
                begin
                    StartPendingOpen(Index);
                end;
            end;
        end;
        Exit();
    end;
    hoveredIndex := Index;
    Invalidate();
    Update();
    if Index < 0 then
    begin
        CancelPendingOpen();
        closeTimerRef.Enabled := True;
        Exit();
    end;
    closeTimerRef.Enabled := False;
    item := GetVisibleItem(Index);
    if (item <> nil) and (item.Count > 0) and (bOpenChild = True) then
    begin
        StartPendingOpen(Index);
    end
    else
    begin
        CancelPendingOpen();
        CloseChildPopup();
    end;
end;
procedure TRuntimeMenuPopupForm.OpenChildPopup(Index: Integer);
var
    item: TMenuItem;
    popupPos: TPoint;
    childRect: TRect;
begin
    CancelPendingOpen();
    item := GetVisibleItem(Index);
    if item = nil then
    begin
        CloseChildPopup();
        Exit();
    end;
    if item.Count = 0 then
    begin
        CloseChildPopup();
        Exit();
    end;
    if childPopupRef <> nil then
    begin
        if childPopupRef.ParentItem = item then
        begin
            Exit();
        end;
        CloseChildPopup();
    end;
    if Assigned(item.OnClick) then
    begin
        // no-op
    end;
    childPopupRef := TRuntimeMenuPopupForm.CreatePopup(Owner, ownerBarRef, painterRef, item, imagesRef, Self);
    childRect := GetScreenRectForChild(Index);
    popupPos := childRect.TopLeft;
    childPopupRef.PopupAt(popupPos);
end;
procedure TRuntimeMenuPopupForm.TriggerItem(Index: Integer);
var
    item: TMenuItem;
    clickItem: TMenuItem;
begin
    item := GetVisibleItem(Index);
    if item = nil then
    begin
        Exit();
    end;
    if Trim(item.Caption) = '-' then
    begin
        Exit();
    end;
    if item.Enabled = False then
    begin
        Exit();
    end;
    if item.Count > 0 then
    begin
        OpenChildPopup(Index);
        Exit();
    end;
    clickItem := item;
    ownerBarRef.ClosePopupBranch(
        procedure()
        begin
            TThread.Queue(nil,
                procedure()
                begin
                    if clickItem <> nil then
                    begin
                        clickItem.Click();
                    end;
                end
            );
        end,
        False
    );
end;
procedure TRuntimeMenuPopupForm.Paint();
begin
    Canvas.Font.Assign(painterRef.MenuFont);
    painterRef.DrawPopupWindowBackground(Canvas, ClientRect);
    for var i := 0 to itemRects.Count - 1 do
    begin
        var item := GetVisibleItem(i);
        painterRef.PaintPopupItem(
            Canvas,
            itemRects[i],
            item,
            imagesRef,
            i = hoveredIndex,
            i = 0,
            i = itemRects.Count - 1
        );
    end;
    painterRef.DrawPopupWindowBorder(Canvas, ClientRect);
end;
procedure TRuntimeMenuPopupForm.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseMove(Shift, X, Y);
    SetHoveredIndex(FindItemAt(Point(X, Y)), True);
end;
procedure TRuntimeMenuPopupForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    hitIndex: Integer;
    item: TMenuItem;
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button <> mbLeft then
    begin
        Exit();
    end;
    hitIndex := FindItemAt(Point(X, Y));
    pressedIndex := -1;
    if hitIndex < 0 then
    begin
        Exit();
    end;
    item := GetVisibleItem(hitIndex);
    if item = nil then
    begin
        Exit();
    end;
    SetHoveredIndex(hitIndex, True);
    if (Trim(item.Caption) = '-') or (item.Enabled = False) then
    begin
        Exit();
    end;
    if item.Count > 0 then
    begin
        OpenChildPopup(hitIndex);
        Exit();
    end;
    pressedIndex := hitIndex;
    SetCapture(Handle);
end;
procedure TRuntimeMenuPopupForm.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    hitIndex: Integer;
    triggerIndex: Integer;
begin
    inherited MouseUp(Button, Shift, X, Y);
    if Button <> mbLeft then
    begin
        Exit();
    end;
    triggerIndex := -1;
    if GetCapture = Handle then
    begin
        ReleaseCapture();
    end;
    if pressedIndex >= 0 then
    begin
        hitIndex := FindItemAt(Point(X, Y));
        if hitIndex = pressedIndex then
        begin
            triggerIndex := pressedIndex;
        end;
    end;
    pressedIndex := -1;
    if triggerIndex >= 0 then
    begin
        TriggerItem(triggerIndex);
    end;
end;
procedure TRuntimeMenuPopupForm.MouseLeave(var Message: TMessage);
begin
    inherited;
    closeTimerRef.Enabled := True;
end;
procedure TRuntimeMenuPopupForm.WMActivate(var Message: TWMActivate);
begin
    inherited;
    if Message.Active = WA_INACTIVE then
    begin
        var cursorPos: TPoint;
        GetCursorPos(cursorPos);
        if PtInRect(BoundsRect, cursorPos) = False then
        begin
            if (childPopupRef = nil) or (PtInRect(childPopupRef.BoundsRect, cursorPos) = False) then
            begin
                ownerBarRef.ClosePopupBranch();
            end;
        end;
    end;
end;
procedure TRuntimeMenuPopupForm.WMMouseActivate(var Message: TWMMouseActivate);
begin
    Message.Result := MA_NOACTIVATE;
end;
procedure TRuntimeMenuPopupForm.WMCancelMode(var Message: TMessage);
begin
    inherited;
    closeTimerRef.Enabled := False;
    pressedIndex := -1;
    if GetCapture = Handle then
    begin
        ReleaseCapture();
    end;
end;
function TRuntimeMenuPopupForm.IsSelectableIndex(Index: Integer): Boolean;
var
    item: TMenuItem;
begin
    item := GetVisibleItem(Index);
    Result := (item <> nil) and (Trim(item.Caption) <> '-') and (item.Enabled = True);
end;
function TRuntimeMenuPopupForm.FindFirstSelectableIndex(): Integer;
begin
    Result := -1;
    for var i := 0 to GetVisibleCount() - 1 do
    begin
        if IsSelectableIndex(i) = True then
        begin
            Result := i;
            Exit();
        end;
    end;
end;
function TRuntimeMenuPopupForm.FindLastSelectableIndex(): Integer;
begin
    Result := -1;
    for var i := GetVisibleCount() - 1 downto 0 do
    begin
        if IsSelectableIndex(i) = True then
        begin
            Result := i;
            Exit();
        end;
    end;
end;
function TRuntimeMenuPopupForm.FindNextSelectableIndex(StartIndex, Delta: Integer): Integer;
var
    countValue: Integer;
    index: Integer;
begin
    Result := -1;
    countValue := GetVisibleCount();
    if countValue <= 0 then
    begin
        Exit();
    end;
    index := StartIndex;
    for var i := 1 to countValue do
    begin
        index := (index + Delta + countValue) mod countValue;
        if IsSelectableIndex(index) = True then
        begin
            Result := index;
            Exit();
        end;
    end;
end;
function TRuntimeMenuPopupForm.FindMnemonicIndex(const AChar: Char): Integer;
var
    matchChar: Char;
begin
    Result := -1;
    matchChar := UpCase(AChar);
    for var i := 0 to GetVisibleCount() - 1 do
    begin
        if IsSelectableIndex(i) = True then
        begin
            var item := GetVisibleItem(i);
            if item <> nil then
            begin
                if GetMenuMnemonic(item.Caption) = matchChar then
                begin
                    Result := i;
                    Exit();
                end;
            end;
        end;
    end;
end;
procedure TRuntimeMenuPopupForm.SelectFirstKeyboard();
begin
    var index := FindFirstSelectableIndex();
    if index >= 0 then
    begin
        SetHoveredIndex(index, False);
    end;
end;
procedure TRuntimeMenuPopupForm.SelectLastKeyboard();
begin
    var index := FindLastSelectableIndex();
    if index >= 0 then
    begin
        SetHoveredIndex(index, False);
    end;
end;
procedure TRuntimeMenuPopupForm.NavigateVertical(Delta: Integer);
var
    index: Integer;
begin
    if Delta = 0 then
    begin
        Exit();
    end;
    if hoveredIndex < 0 then
    begin
        if Delta > 0 then
        begin
            index := FindFirstSelectableIndex();
        end
        else
        begin
            index := FindLastSelectableIndex();
        end;
    end
    else
    begin
        index := FindNextSelectableIndex(hoveredIndex, Delta);
    end;
    if index >= 0 then
    begin
        SetHoveredIndex(index, False);
    end;
end;
function TRuntimeMenuPopupForm.TryOpenHoveredChild(): Boolean;
var
    item: TMenuItem;
begin
    Result := False;
    if hoveredIndex < 0 then
    begin
        Exit();
    end;
    item := GetVisibleItem(hoveredIndex);
    if (item <> nil) and (item.Enabled = True) and (item.Count > 0) then
    begin
        OpenChildPopup(hoveredIndex);
        if childPopupRef <> nil then
        begin
            childPopupRef.SelectFirstKeyboard();
        end;
        Result := True;
    end;
end;
procedure TRuntimeMenuPopupForm.ActivateCurrent();
begin
    if hoveredIndex < 0 then
    begin
        SelectFirstKeyboard();
    end;
    if hoveredIndex >= 0 then
    begin
        TriggerItem(hoveredIndex);
    end;
end;
procedure TRuntimeMenuPopupForm.CloseOwnedChildPopup();
begin
    CloseChildPopup();
end;
function TRuntimeMenuPopupForm.GetDeepestPopup(): TRuntimeMenuPopupForm;
begin
    Result := Self;
    while Result.childPopupRef <> nil do
    begin
        Result := Result.childPopupRef;
    end;
end;
procedure TRuntimeMenuPopupForm.ActivateMnemonic(const AChar: Char);
var
    index: Integer;
    item: TMenuItem;
begin
    index := FindMnemonicIndex(AChar);
    if index < 0 then
    begin
        Exit();
    end;
    SetHoveredIndex(index, False);
    item := GetVisibleItem(index);
    if item = nil then
    begin
        Exit();
    end;
    if item.Count > 0 then
    begin
        OpenChildPopup(index);
        if childPopupRef <> nil then
        begin
            childPopupRef.SelectFirstKeyboard();
        end;
    end
    else
    begin
        TriggerItem(index);
    end;
end;
{ TRuntimeMainMenuBar }
constructor TRuntimeMainMenuBar.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle + [csOpaque];
    DoubleBuffered := True;
    Height := 24;
    menuBarRects := TList<TRect>.Create();
    visibleTopItems := TList<TMenuItem>.Create();
    activeTopIndex := -1;
    hoveredTopIndex := -1;
    bTrackingMouse := False;
    bMenuModeHooked := False;
    bPendingAltToggle := False;
    bMenuFadeEnabled := True;
    bRespectSystemMenuAnimation := False;
    bRespectSystemMenuFade := False;
    menuFadeDurationValue := 220;
    painterRef := TRuntimeMenuPainter.Create();
    Font.Assign(Screen.MenuFont);
end;
destructor TRuntimeMainMenuBar.Destroy();
begin
    EndMenuMode();
    ClosePopupBranch();
    visibleTopItems.Free();
    menuBarRects.Free();
    painterRef.Free();
    inherited Destroy();
end;
procedure TRuntimeMainMenuBar.SetMenuFadeDuration(const Value: Integer);
begin
    if Value < 0 then
    begin
        menuFadeDurationValue := 0;
    end
    else
    begin
        menuFadeDurationValue := Value;
    end;
end;
function TRuntimeMainMenuBar.ShouldUseFadeAnimation(): Boolean;
var
    bEnabled: BOOL;
begin
    Result := bMenuFadeEnabled;
    if Result = False then
    begin
        Exit();
    end;
    if bRespectSystemMenuAnimation = True then
    begin
        bEnabled := False;
        if SystemParametersInfo(SPI_GETMENUANIMATION, 0, @bEnabled, 0) = True then
        begin
            if bEnabled = False then
            begin
                Exit(False);
            end;
        end;
    end;
    if bRespectSystemMenuFade = True then
    begin
        bEnabled := False;
        if SystemParametersInfo(SPI_GETMENUFADE, 0, @bEnabled, 0) = True then
        begin
            if bEnabled = False then
            begin
                Exit(False);
            end;
        end;
    end;
end;
procedure TRuntimeMainMenuBar.Loaded();
begin
    inherited Loaded();
    RebuildLayout();
end;
procedure TRuntimeMainMenuBar.SetSourceMenu(const Value: TMainMenu);
begin
    sourceMenuRef := Value;
    imagesRef := FindImages();
    RebuildLayout();
    Invalidate();
    if sourceMenuRef <> nil then
    begin
        BeginMenuMode();
    end;
end;
procedure TRuntimeMainMenuBar.SetPainter(const Value: TRuntimeMenuPainter);
begin
    if Value = nil then
    begin
        Exit();
    end;
    painterRef.AssignSystemFont();
    painterRef.Colors := Value.Colors;
    painterRef.Metrics := Value.Metrics;
    painterRef.RadioDotSize := Value.RadioDotSize;
    painterRef.CheckMarkSize := Value.CheckMarkSize;
    RebuildLayout();
    Invalidate();
end;
procedure TRuntimeMainMenuBar.AttachMenu(AMenu: TMainMenu);
begin
    SourceMenu := AMenu;
end;
procedure TRuntimeMainMenuBar.RefreshMenu();
begin
    imagesRef := FindImages();
    RebuildLayout();
    Invalidate();
end;
function TRuntimeMainMenuBar.FindImages(): TCustomImageList;
begin
    Result := nil;
    if sourceMenuRef <> nil then
    begin
        Result := sourceMenuRef.Images;
    end;
end;
function TRuntimeMainMenuBar.GetTopVisibleCount(): Integer;
begin
    Result := visibleTopItems.Count;
end;
function TRuntimeMainMenuBar.GetTopItem(Index: Integer): TMenuItem;
begin
    Result := nil;
    if (Index < 0) or (Index >= visibleTopItems.Count) then
    begin
        Exit();
    end;
    Result := visibleTopItems[Index];
end;
function TRuntimeMainMenuBar.GetTopItemRect(Index: Integer): TRect;
begin
    if (Index < 0) or (Index >= menuBarRects.Count) then
    begin
        Result := Rect(0, 0, 0, 0);
        Exit();
    end;
    Result := menuBarRects[Index];
end;
function TRuntimeMainMenuBar.FindTopItemAt(const Pt: TPoint): Integer;
begin
    Result := -1;
    for var i := 0 to menuBarRects.Count - 1 do
    begin
        if PtInRect(menuBarRects[i], Pt) = True then
        begin
            Result := i;
            Exit();
        end;
    end;
end;
procedure TRuntimeMainMenuBar.RebuildLayout();
var
    canvasRef: TControlCanvas;
    x: Integer;
begin
    menuBarRects.Clear();
    visibleTopItems.Clear();
    if sourceMenuRef = nil then
    begin
        Exit();
    end;
    for var i := 0 to sourceMenuRef.Items.Count - 1 do
    begin
        var item := sourceMenuRef.Items[i];
        if (item <> nil) and (item.Visible = True) then
        begin
            visibleTopItems.Add(item);
        end;
    end;
    canvasRef := TControlCanvas.Create();
    try
        canvasRef.Control := Self;
        canvasRef.Font.Assign(painterRef.MenuFont);
        x := 0;
        for var i := 0 to visibleTopItems.Count - 1 do
        begin
            var item := visibleTopItems[i];
            var itemWidth := painterRef.MeasureMenuBarItemWidth(canvasRef, item);
            menuBarRects.Add(Rect(x, 0, x + itemWidth, Height));
            Inc(x, itemWidth);
        end;
    finally
        canvasRef.Free();
    end;
end;
procedure TRuntimeMainMenuBar.StartMouseTracking();
var
    trackData: TTrackMouseEvent;
begin
    if bTrackingMouse = True then
    begin
        Exit();
    end;
    trackData.cbSize := SizeOf(trackData);
    trackData.dwFlags := TME_LEAVE;
    trackData.hwndTrack := Handle;
    trackData.dwHoverTime := 0;
    TrackMouseEvent(trackData);
    bTrackingMouse := True;
end;
procedure TRuntimeMainMenuBar.BeginMenuMode();
begin
    if bMenuModeHooked = True then
    begin
        Exit();
    end;
    savedAppOnMessage := Application.OnMessage;
    Application.OnMessage := AppMessageHook;
    bMenuModeHooked := True;
end;
procedure TRuntimeMainMenuBar.EndMenuMode();
var
    hookEvent: TMessageEvent;
begin
    if bMenuModeHooked = False then
    begin
        Exit();
    end;
    hookEvent := AppMessageHook;
    if (TMethod(Application.OnMessage).Code = TMethod(hookEvent).Code) and
       (TMethod(Application.OnMessage).Data = TMethod(hookEvent).Data) then
    begin
        Application.OnMessage := savedAppOnMessage;
    end;
    bMenuModeHooked := False;
end;
function TRuntimeMainMenuBar.PointInMenuHierarchy(const ScreenPt: TPoint): Boolean;
var
    barRect: TRect;
begin
    barRect := ClientRect;
    barRect.TopLeft := ClientToScreen(barRect.TopLeft);
    barRect.BottomRight := ClientToScreen(barRect.BottomRight);
    Result := PtInRect(barRect, ScreenPt);
    if (Result = False) and (activePopupRef <> nil) then
    begin
        Result := activePopupRef.ContainsScreenPoint(ScreenPt);
    end;
end;
procedure TRuntimeMainMenuBar.AppMessageHook(var Message: TMsg; var Handled: Boolean);
var
    cursorPos: TPoint;
    notifyMsg: UINT;
    popupRef: TRuntimeMenuPopupForm;
    nextIndex: Integer;
    mnemonicIndex: Integer;
    ch: Char;
begin
    Handled := False;
    case Message.Message of
        WM_SYSKEYDOWN:
            begin
                if Message.WParam = VK_MENU then
                begin
                    bPendingAltToggle := True;
                    Handled := True;
                    Exit();
                end;
                bPendingAltToggle := False;
            end;
        WM_SYSCHAR:
            begin
                bPendingAltToggle := False;
                if Message.WParam <> 0 then
                begin
                    ch := UpCase(Char(Message.WParam));
                    if activePopupRef <> nil then
                    begin
                        popupRef := activePopupRef.GetDeepestPopup();
                        popupRef.ActivateMnemonic(ch);
                        Handled := True;
                        Exit();
                    end;
                    mnemonicIndex := FindMnemonicTopIndex(ch);
                    if mnemonicIndex >= 0 then
                    begin
                        OpenTopPopupKeyboard(mnemonicIndex);
                        Handled := True;
                        Exit();
                    end;
                end;
            end;
        WM_SYSKEYUP:
            begin
                if Message.WParam = VK_MENU then
                begin
                    if bPendingAltToggle = True then
                    begin
                        ToggleKeyboardMenu();
                    end;
                    bPendingAltToggle := False;
                    Handled := True;
                    Exit();
                end;
            end;
    end;
    if activePopupRef <> nil then
    begin
        case Message.Message of
            WM_PARENTNOTIFY:
                begin
                    notifyMsg := LOWORD(Message.WParam);
                    if (notifyMsg = WM_LBUTTONDOWN) or
                       (notifyMsg = WM_RBUTTONDOWN) or
                       (notifyMsg = WM_MBUTTONDOWN) then
                    begin
                        GetCursorPos(cursorPos);
                        if PointInMenuHierarchy(cursorPos) = False then
                        begin
                            ClosePopupBranch();
                            Handled := True;
                            Exit();
                        end;
                    end;
                end;
            WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN,
            WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN:
                begin
                    GetCursorPos(cursorPos);
                    if PointInMenuHierarchy(cursorPos) = False then
                    begin
                        ClosePopupBranch();
                        Handled := True;
                        Exit();
                    end;
                end;
            WM_CANCELMODE:
                begin
                    ClosePopupBranch();
                    Exit();
                end;
            WM_ACTIVATEAPP:
                begin
                    if Message.WParam = 0 then
                    begin
                        ClosePopupBranch();
                    end;
                    Exit();
                end;
            WM_KEYDOWN, WM_SYSKEYDOWN:
                begin
                    popupRef := activePopupRef.GetDeepestPopup();
                    case Message.WParam of
                        VK_ESCAPE:
                            begin
                                ClosePopupBranch();
                                Handled := True;
                                Exit();
                            end;
                        VK_LEFT:
                            begin
                                if popupRef.OwnerPopup <> nil then
                                begin
                                    popupRef.OwnerPopup.CloseOwnedChildPopup();
                                    popupRef.OwnerPopup.Invalidate();
                                end
                                else
                                begin
                                    nextIndex := FindNextTopIndex(activeTopIndex, -1);
                                    if nextIndex >= 0 then
                                    begin
                                        OpenTopPopupKeyboard(nextIndex);
                                    end;
                                end;
                                Handled := True;
                                Exit();
                            end;
                        VK_RIGHT:
                            begin
                                if popupRef.TryOpenHoveredChild() = False then
                                begin
                                    nextIndex := FindNextTopIndex(activeTopIndex, 1);
                                    if nextIndex >= 0 then
                                    begin
                                        OpenTopPopupKeyboard(nextIndex);
                                    end;
                                end;
                                Handled := True;
                                Exit();
                            end;
                        VK_UP:
                            begin
                                popupRef.NavigateVertical(-1);
                                Handled := True;
                                Exit();
                            end;
                        VK_DOWN:
                            begin
                                popupRef.NavigateVertical(1);
                                Handled := True;
                                Exit();
                            end;
                        VK_HOME:
                            begin
                                popupRef.SelectFirstKeyboard();
                                Handled := True;
                                Exit();
                            end;
                        VK_END:
                            begin
                                popupRef.SelectLastKeyboard();
                                Handled := True;
                                Exit();
                            end;
                        VK_RETURN, VK_SPACE:
                            begin
                                popupRef.ActivateCurrent();
                                Handled := True;
                                Exit();
                            end;
                        VK_F10:
                            begin
                                ToggleKeyboardMenu();
                                Handled := True;
                                Exit();
                            end;
                    end;
                end;
        end;
    end
    else
    begin
        case Message.Message of
            WM_KEYDOWN:
                begin
                    if Message.WParam = VK_F10 then
                    begin
                        ToggleKeyboardMenu();
                        Handled := True;
                        Exit();
                    end;
                end;
        end;
    end;
    if Assigned(savedAppOnMessage) then
    begin
        savedAppOnMessage(Message, Handled);
    end;
end;
procedure TRuntimeMainMenuBar.ClosePopupBranch(const AAfterClose: TProc; const bAnimate: Boolean);
var
    popupToClose: TRuntimeMenuPopupForm;
begin
    popupToClose := activePopupRef;
    activePopupRef := nil;
    activeTopIndex := -1;
    hoveredTopIndex := -1;
    Invalidate();
    if popupToClose <> nil then
    begin
        popupToClose.CloseBranch(
            procedure()
            begin
                popupToClose.Free();
                if Assigned(AAfterClose) then
                begin
                    AAfterClose();
                end;
            end,
            bAnimate
        );
    end
    else
    begin
        if Assigned(AAfterClose) then
        begin
            AAfterClose();
        end;
    end;
end;
procedure TRuntimeMainMenuBar.OpenTopPopup(Index: Integer);
var
    item: TMenuItem;
    itemRect: TRect;
    popupPos: TPoint;
begin
    item := GetTopItem(Index);
    if item = nil then
    begin
        ClosePopupBranch();
        Exit();
    end;
    if item.Count = 0 then
    begin
        item.Click();
        ClosePopupBranch();
        Exit();
    end;
    if (activePopupRef <> nil) and (activeTopIndex = Index) then
    begin
        Exit();
    end;
    ClosePopupBranch(nil, False);
    activeTopIndex := Index;
    hoveredTopIndex := Index;
    activePopupRef := TRuntimeMenuPopupForm.CreatePopup(Owner, Self, painterRef, item, imagesRef, nil);
    itemRect := GetTopItemRect(Index);
    popupPos := ClientToScreen(Point(itemRect.Left, itemRect.Bottom - 1));
    activePopupRef.PopupAt(popupPos);
    Invalidate();
end;
function TRuntimeMainMenuBar.FindNextTopIndex(StartIndex, Delta: Integer): Integer;
var
    countValue: Integer;
    index: Integer;
begin
    Result := -1;
    countValue := GetTopVisibleCount();
    if countValue <= 0 then
    begin
        Exit();
    end;
    index := StartIndex;
    for var i := 1 to countValue do
    begin
        index := (index + Delta + countValue) mod countValue;
        if GetTopItem(index) <> nil then
        begin
            Result := index;
            Exit();
        end;
    end;
end;
function TRuntimeMainMenuBar.FindMnemonicTopIndex(const AChar: Char): Integer;
var
    matchChar: Char;
begin
    Result := -1;
    matchChar := UpCase(AChar);
    for var i := 0 to GetTopVisibleCount() - 1 do
    begin
        var item := GetTopItem(i);
        if item <> nil then
        begin
            if GetMenuMnemonic(item.Caption) = matchChar then
            begin
                Result := i;
                Exit();
            end;
        end;
    end;
end;
procedure TRuntimeMainMenuBar.OpenTopPopupKeyboard(Index: Integer);
begin
    if Index < 0 then
    begin
        Exit();
    end;
    OpenTopPopup(Index);
    if activePopupRef <> nil then
    begin
        activePopupRef.SelectFirstKeyboard();
    end;
end;
procedure TRuntimeMainMenuBar.ToggleKeyboardMenu();
var
    index: Integer;
begin
    if activePopupRef <> nil then
    begin
        ClosePopupBranch();
        Exit();
    end;
    index := FindNextTopIndex(-1, 1);
    if index >= 0 then
    begin
        OpenTopPopupKeyboard(index);
    end;
end;
procedure TRuntimeMainMenuBar.Paint();
begin
    Canvas.Font.Assign(painterRef.MenuFont);
    Canvas.Brush.Color := painterRef.Colors.MenuBarFace;
    Canvas.FillRect(ClientRect);
    for var i := 0 to menuBarRects.Count - 1 do
    begin
        var item := GetTopItem(i);
        if item = nil then
        begin
            Continue;
        end;
        var bHot := (i = hoveredTopIndex) or (i = activeTopIndex);
        painterRef.PaintMenuBarItem(Canvas, menuBarRects[i], item, bHot);
    end;
end;
procedure TRuntimeMainMenuBar.Resize();
begin
    inherited Resize();
    RebuildLayout();
end;
procedure TRuntimeMainMenuBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    hitIndex: Integer;
begin
    inherited MouseMove(Shift, X, Y);
    StartMouseTracking();
    hitIndex := FindTopItemAt(Point(X, Y));
    hoveredTopIndex := hitIndex;
    Invalidate();
    if (activePopupRef <> nil) and (hitIndex >= 0) and (hitIndex <> activeTopIndex) then
    begin
        OpenTopPopup(hitIndex);
    end;
end;
procedure TRuntimeMainMenuBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    hitIndex: Integer;
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button <> mbLeft then
    begin
        Exit();
    end;
    hitIndex := FindTopItemAt(Point(X, Y));
    if hitIndex < 0 then
    begin
        ClosePopupBranch();
        Exit();
    end;
    if (activePopupRef <> nil) and (activeTopIndex = hitIndex) then
    begin
        ClosePopupBranch();
        Exit();
    end;
    OpenTopPopup(hitIndex);
end;
procedure TRuntimeMainMenuBar.MouseLeave(var Message: TMessage);
begin
    inherited;
    bTrackingMouse := False;
    if activePopupRef = nil then
    begin
        hoveredTopIndex := -1;
        Invalidate();
    end;
end;
end.

