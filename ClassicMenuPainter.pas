unit ClassicMenuPainter;

interface
uses
    Winapi.Windows,
    Winapi.Messages,
    System.Classes,
    System.SysUtils,
    System.Types,
    System.UITypes,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Graphics,
    Vcl.ImgList,
    Vcl.Menus,
    Vcl.GraphUtil,
    Winapi.GDIPAPI,
    Winapi.GDIPOBJ;
type
    TClassicMenuPainter = class(TComponent)
    private
        menuRef: TMenu;
        bMenuOwnerDrawBeforeApply: Boolean;
        imagesRef: TCustomImageList;
        menuFont: TFont;
        clrMenuBarFace: TColor;
        clrPopupGutterLeft: TColor;
        clrPopupGutterRight: TColor;
        clrPopupMainLeft: TColor;
        clrPopupMainRight: TColor;
        clrSeparatorLeft: TColor;
        clrSeparatorRight: TColor;
        clrMenuText: TColor;
        clrDisabledText: TColor;
        clrDisabledLight: TColor;
        clrSelectionBorder: TColor;
        clrSelectionFill: TColor;
        clrTopLevelFrameLight: TColor;
        clrTopLevelFrameShadow: TColor;
        gutterWidth: Integer;
        textPaddingLeft: Integer;
        textPaddingRight: Integer;
        shortcutGap: Integer;
        systemArrowReserveWidth: Integer;
        minItemHeight: Integer;
        topLevelPaddingX: Integer;
        topLevelPaddingY: Integer;
        separatorRowHeight: Integer;
        separatorBandHeight: Integer;
        radioDotSizeValue: Single;
        checkMarkSizeValue: Single;
        procedure SetMenu(const Value: TMenu);
        procedure SetImages(const Value: TCustomImageList);
        procedure SetRadioDotSize(const Value: Single);
        procedure SetCheckMarkSize(const Value: Single);
        procedure LoadMenuFont();
        procedure HookBranch(Item: TMenuItem);
        procedure UnhookBranch(Item: TMenuItem);
        procedure ItemMeasure(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
        procedure ItemDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
        procedure FillMenuBarBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillPopupGutterBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillPopupMainBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure FillPopupRowBackground(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawTopLevelItem(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bSelected: Boolean);
        procedure DrawPopupItem(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bSelected: Boolean);
        procedure DrawSeparator(ACanvas: TCanvas; const ARect: TRect; bTopLevel: Boolean);
        procedure DrawPopupSelection(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawTopLevelSelection(ACanvas: TCanvas; const ARect: TRect);
        procedure DrawImageArea(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
        procedure DrawCheckMark(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
        procedure DrawMenuText(
            ACanvas: TCanvas;
            const AText: string;
            const ARect: TRect;
            Alignment: TAlignment;
            bEnabled: Boolean
        );
        function IsTopLevelItem(Item: TMenuItem): Boolean;
        function IsSeparator(Item: TMenuItem): Boolean;
        function IsSeparatorCaption(const ACaption: string): Boolean;
        function GetShortCutText(Item: TMenuItem): string;
        function GetCaptionText(Item: TMenuItem): string;
        function GetImageListFor(Item: TMenuItem): TCustomImageList;
        function GetGlyphSizeFor(Item: TMenuItem): TSize;
        function MeasureTextWidth(ACanvas: TCanvas; const AText: string): Integer;
        function RectWidth(const ARect: TRect): Integer;
        function RectHeight(const ARect: TRect): Integer;
        function GetPopupSplitX(const ARect: TRect): Integer;
    protected
        procedure Loaded(); override;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy(); override;
        procedure Apply();
        procedure Remove();
        procedure RefreshMainMenuLayout();
    published
        property Menu: TMenu read menuRef write SetMenu;
        property Images: TCustomImageList read imagesRef write SetImages;
        property RadioDotSize: Single read radioDotSizeValue write SetRadioDotSize;
        property CheckMarkSize: Single read checkMarkSizeValue write SetCheckMarkSize;
    end;
procedure Register();
implementation
procedure Register();
begin
    RegisterComponents('Samples', [TClassicMenuPainter]);
end;
constructor TClassicMenuPainter.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    menuFont := TFont.Create();
    clrMenuBarFace := RGB(212, 208, 200);
    clrPopupGutterLeft := $00C8D0D4;
    clrPopupGutterRight := $00BAC1C5;
    clrPopupMainLeft := $00DCE4E9;
    clrPopupMainRight :=  $00C8D0D4;
    clrSeparatorLeft := $00A0A6A9;
    clrSeparatorRight := $00C8D0D4;
    clrMenuText := RGB(0, 0, 0);
    clrDisabledText := RGB(128, 128, 128);
    clrDisabledLight := RGB(255, 255, 255);
    clrSelectionBorder := RGB(10, 36, 106);
    clrSelectionFill := RGB(182, 190, 211);
    clrTopLevelFrameLight := RGB(255, 255, 255);
    clrTopLevelFrameShadow := RGB(128, 128, 128);
    gutterWidth := 24;
    textPaddingLeft := 8;
    textPaddingRight := 8;
    shortcutGap := 24;
    systemArrowReserveWidth := 16;
    minItemHeight := 20;
    topLevelPaddingX := 2; //8;
    topLevelPaddingY := 4;
    separatorRowHeight := 8;
    separatorBandHeight := 2;
    radioDotSizeValue := 12.0;
    checkMarkSizeValue := 12.0;
    LoadMenuFont();
end;
destructor TClassicMenuPainter.Destroy();
begin
    Remove();
    menuFont.Free();
    inherited Destroy();
end;
procedure TClassicMenuPainter.SetRadioDotSize(const Value: Single);
begin
    if Value < 2.0 then
    begin
        radioDotSizeValue := 2.0;
    end
    else
    begin
        radioDotSizeValue := Value;
    end;
end;
procedure TClassicMenuPainter.SetCheckMarkSize(const Value: Single);
begin
    if Value < 6.0 then
    begin
        checkMarkSizeValue := 6.0;
    end
    else
    begin
        checkMarkSizeValue := Value;
    end;
end;
procedure TClassicMenuPainter.Loaded();
begin
    inherited Loaded();
    Apply();
end;
procedure TClassicMenuPainter.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Operation = opRemove then
    begin
        if AComponent = menuRef then
        begin
            Remove();
            menuRef := nil;
        end;
        if AComponent = imagesRef then
        begin
            imagesRef := nil;
        end;
    end;
end;
procedure TClassicMenuPainter.SetMenu(const Value: TMenu);
begin
    if menuRef = Value then
    begin
        Exit();
    end;
    if menuRef <> nil then
    begin
        Remove();
        menuRef.RemoveFreeNotification(Self);
    end;
    menuRef := Value;
    if menuRef <> nil then
    begin
        menuRef.FreeNotification(Self);
        Apply();
    end;
end;
procedure TClassicMenuPainter.SetImages(const Value: TCustomImageList);
begin
    if imagesRef = Value then
    begin
        Exit();
    end;
    if imagesRef <> nil then
    begin
        imagesRef.RemoveFreeNotification(Self);
    end;
    imagesRef := Value;
    if imagesRef <> nil then
    begin
        imagesRef.FreeNotification(Self);
    end;
end;
procedure TClassicMenuPainter.LoadMenuFont();
begin
    menuFont.Assign(Screen.MenuFont);
end;
procedure TClassicMenuPainter.Apply();
begin
    if menuRef = nil then
    begin
        Exit();
    end;
    bMenuOwnerDrawBeforeApply := menuRef.OwnerDraw;
    menuRef.OwnerDraw := True;
    HookBranch(menuRef.Items);
    RefreshMainMenuLayout();
end;
procedure TClassicMenuPainter.Remove();
begin
    if menuRef = nil then
    begin
        Exit();
    end;
    UnhookBranch(menuRef.Items);
    menuRef.OwnerDraw := bMenuOwnerDrawBeforeApply;
    RefreshMainMenuLayout();
end;
procedure TClassicMenuPainter.RefreshMainMenuLayout();
var
    formRef: TCustomForm;
    mainMenuRef: TMainMenu;
begin
    if menuRef = nil then
    begin
        Exit();
    end;
    if (menuRef is TMainMenu) = False then
    begin
        Exit();
    end;
    mainMenuRef := TMainMenu(menuRef);
    if (mainMenuRef.Owner is TCustomForm) = False then
    begin
        Exit();
    end;
    formRef := TCustomForm(mainMenuRef.Owner);
    if formRef.HandleAllocated = False then
    begin
        Exit();
    end;
    if formRef.Menu <> mainMenuRef then
    begin
        Exit();
    end;
end;
procedure TClassicMenuPainter.HookBranch(Item: TMenuItem);
begin
    if Item = nil then
    begin
        Exit();
    end;
    if Item.Parent <> nil then
    begin
        if Assigned(Item.OnMeasureItem) = False then
        begin
            Item.OnMeasureItem := ItemMeasure;
        end;
        if Assigned(Item.OnDrawItem) = False then
        begin
            Item.OnDrawItem := ItemDraw;
        end;
    end;
    for var i := 0 to Item.Count - 1 do
    begin
        HookBranch(Item.Items[i]);
    end;
end;
procedure TClassicMenuPainter.UnhookBranch(Item: TMenuItem);
var
    measureHandler: TMenuMeasureItemEvent;
    drawHandler: TMenuDrawItemEvent;
begin
    if Item = nil then
    begin
        Exit();
    end;
    if Item.Parent <> nil then
    begin
        measureHandler := ItemMeasure;
        if Assigned(Item.OnMeasureItem) = True then
        begin
            if TMethod(Item.OnMeasureItem).Code = TMethod(measureHandler).Code then
            begin
                if TMethod(Item.OnMeasureItem).Data = TMethod(measureHandler).Data then
                begin
                    Item.OnMeasureItem := nil;
                end;
            end;
        end;
        drawHandler := ItemDraw;
        if Assigned(Item.OnDrawItem) = True then
        begin
            if TMethod(Item.OnDrawItem).Code = TMethod(drawHandler).Code then
            begin
                if TMethod(Item.OnDrawItem).Data = TMethod(drawHandler).Data then
                begin
                    Item.OnDrawItem := nil;
                end;
            end;
        end;
    end;
    for var i := 0 to Item.Count - 1 do
    begin
        UnhookBranch(Item.Items[i]);
    end;
end;
function TClassicMenuPainter.RectWidth(const ARect: TRect): Integer;
begin
    Result := ARect.Right - ARect.Left;
end;
function TClassicMenuPainter.RectHeight(const ARect: TRect): Integer;
begin
    Result := ARect.Bottom - ARect.Top;
end;
function TClassicMenuPainter.GetPopupSplitX(const ARect: TRect): Integer;
begin
    Result := ARect.Left + gutterWidth + 1;
    if Result > ARect.Right then
    begin
        Result := ARect.Right;
    end;
end;
function TClassicMenuPainter.IsTopLevelItem(Item: TMenuItem): Boolean;
begin
    Result :=
        (Item <> nil) and
        (Item.Parent <> nil) and
        (Item.Parent.Parent = nil) and
        (Item.GetParentMenu() is TMainMenu);
end;
function TClassicMenuPainter.IsSeparatorCaption(const ACaption: string): Boolean;
begin
    Result := Trim(ACaption) = '-';
end;
function TClassicMenuPainter.IsSeparator(Item: TMenuItem): Boolean;
begin
    Result := False;
    if Item = nil then
    begin
        Exit();
    end;
    Result := IsSeparatorCaption(Item.Caption);
end;
function TClassicMenuPainter.GetCaptionText(Item: TMenuItem): string;
var
    tabPos: Integer;
begin
    Result := '';
    if Item = nil then
    begin
        Exit();
    end;
    if IsSeparator(Item) = True then
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
function TClassicMenuPainter.GetShortCutText(Item: TMenuItem): string;
var
    captionText: string;
    tabPos: Integer;
begin
    Result := '';
    if Item = nil then
    begin
        Exit();
    end;
    if IsSeparator(Item) = True then
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
function TClassicMenuPainter.GetImageListFor(Item: TMenuItem): TCustomImageList;
begin
    Result := imagesRef;
    if Result <> nil then
    begin
        Exit();
    end;
    if (Item <> nil) and (Item.GetParentMenu() <> nil) then
    begin
        Result := Item.GetParentMenu().Images;
    end;
end;
function TClassicMenuPainter.GetGlyphSizeFor(Item: TMenuItem): TSize;
var
    imageList: TCustomImageList;
begin
    Result.cx := 16;
    Result.cy := 16;
    if Item = nil then
    begin
        Exit();
    end;
    if Item.Bitmap.Empty = False then
    begin
        Result.cx := Item.Bitmap.Width;
        Result.cy := Item.Bitmap.Height;
        Exit();
    end;
    imageList := GetImageListFor(Item);
    if (imageList <> nil) and (Item.ImageIndex >= 0) then
    begin
        Result.cx := imageList.Width;
        Result.cy := imageList.Height;
        Exit();
    end;
    Result.cx := GetSystemMetrics(SM_CXMENUCHECK);
    Result.cy := GetSystemMetrics(SM_CYMENUCHECK);
    if Result.cx < 16 then
    begin
        Result.cx := 16;
    end;
    if Result.cy < 16 then
    begin
        Result.cy := 16;
    end;
end;
function TClassicMenuPainter.MeasureTextWidth(ACanvas: TCanvas; const AText: string): Integer;
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
procedure TClassicMenuPainter.FillMenuBarBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := clrMenuBarFace;
    ACanvas.FillRect(ARect);
end;
procedure TClassicMenuPainter.FillPopupGutterBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    if RectWidth(ARect) <= 0 then
    begin
        Exit();
    end;
    GradientFillCanvas(
        ACanvas,
        clrPopupGutterLeft,
        clrPopupGutterRight,
        ARect,
        gdHorizontal
    );
end;
procedure TClassicMenuPainter.FillPopupMainBackground(ACanvas: TCanvas; const ARect: TRect);
begin
    if RectWidth(ARect) <= 0 then
    begin
        Exit();
    end;
    GradientFillCanvas(
        ACanvas,
        clrPopupMainLeft,
        clrPopupMainRight,
        ARect,
        gdHorizontal
    );
end;
procedure TClassicMenuPainter.FillPopupRowBackground(ACanvas: TCanvas; const ARect: TRect);
var
    splitX: Integer;
    gutterRect: TRect;
    mainRect: TRect;
begin
    splitX := GetPopupSplitX(ARect);
    gutterRect := Rect(ARect.Left, ARect.Top, splitX, ARect.Bottom);
    mainRect := Rect(splitX, ARect.Top, ARect.Right, ARect.Bottom);
    FillPopupGutterBackground(ACanvas, gutterRect);
    FillPopupMainBackground(ACanvas, mainRect);
end;
procedure TClassicMenuPainter.ItemMeasure(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
    item: TMenuItem;
    bTopLevel: Boolean;
    captionText: string;
    shortCutText: string;
    glyphSize: TSize;
begin
    ACanvas.Font.Assign(menuFont);
    item := Sender as TMenuItem;
    bTopLevel := IsTopLevelItem(item);
    if IsSeparator(item) = True then
    begin
        if bTopLevel = True then
        begin
            Width := 8;
            Height := minItemHeight;
        end
        else
        begin
            Width := 24;
            Height := separatorRowHeight;
        end;
        Exit();
    end;
    captionText := GetCaptionText(item);
    shortCutText := GetShortCutText(item);
    glyphSize := GetGlyphSizeFor(item);
    var oldFontStyle := ACanvas.Font.Style;
    try
        if item.Default = True then
        begin
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end;
        if bTopLevel = True then
        begin
            Width := MeasureTextWidth(ACanvas, captionText) + (topLevelPaddingX * 2) + 0; //6;
            Height := ACanvas.TextHeight('Wg') + (topLevelPaddingY * 2);
            if Height < (minItemHeight - 1) then
            begin
                Height := minItemHeight - 1;
            end;
            Exit();
        end;
        Width :=
            gutterWidth + 1 +
            textPaddingLeft +
            MeasureTextWidth(ACanvas, captionText) +
            textPaddingRight;
        ACanvas.Font.Style := oldFontStyle;
        if shortCutText <> '' then
        begin
            Inc(Width, shortcutGap + MeasureTextWidth(ACanvas, shortCutText));
        end;
        if item.Count > 0 then
        begin
            Inc(Width, systemArrowReserveWidth);
        end;
        Height := ACanvas.TextHeight('Wg') + 6;
        if Height < (glyphSize.cy + 4) then
        begin
            Height := glyphSize.cy + 4;
        end;
        if Height < minItemHeight then
        begin
            Height := minItemHeight;
        end;
    finally
        ACanvas.Font.Style := oldFontStyle;
    end;
end;
procedure TClassicMenuPainter.ItemDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
    item: TMenuItem;
    bTopLevel: Boolean;
begin
    ACanvas.Font.Assign(menuFont);
    ACanvas.Brush.Style := bsSolid;
    item := Sender as TMenuItem;
    bTopLevel := IsTopLevelItem(item);
    if IsSeparator(item) = True then
    begin
        DrawSeparator(ACanvas, ARect, bTopLevel);
        Exit();
    end;
    if bTopLevel = True then
    begin
        DrawTopLevelItem(item, ACanvas, ARect, Selected);
    end
    else
    begin
        DrawPopupItem(item, ACanvas, ARect, Selected);
    end;
end;
procedure TClassicMenuPainter.DrawSeparator(ACanvas: TCanvas; const ARect: TRect; bTopLevel: Boolean);
var
    splitX: Integer;
    bandTop: Integer;
    bandRect: TRect;
begin
    if bTopLevel = True then
    begin
        FillMenuBarBackground(ACanvas, ARect);
        Exit();
    end;
    FillPopupRowBackground(ACanvas, ARect);
    splitX := GetPopupSplitX(ARect);
    bandTop := ARect.Top + ((RectHeight(ARect) - separatorBandHeight) div 2);
    bandRect := Rect(
        splitX,
        bandTop,
        ARect.Right,
        bandTop + separatorBandHeight
    );
    if RectWidth(bandRect) > 0 then
    begin
        GradientFillCanvas(
            ACanvas,
            clrSeparatorLeft,
            clrSeparatorRight,
            bandRect,
            gdHorizontal
        );
    end;
end;
procedure TClassicMenuPainter.DrawPopupSelection(ACanvas: TCanvas; const ARect: TRect);
var
    oldPenColor: TColor;
    oldPenStyle: TPenStyle;
    oldBrushColor: TColor;
    oldBrushStyle: TBrushStyle;
begin
    oldPenColor := ACanvas.Pen.Color;
    oldPenStyle := ACanvas.Pen.Style;
    oldBrushColor := ACanvas.Brush.Color;
    oldBrushStyle := ACanvas.Brush.Style;
    try
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Brush.Color := clrSelectionFill;
        ACanvas.FillRect(ARect);
        ACanvas.Brush.Style := bsClear;
        ACanvas.Pen.Style := psSolid;
        ACanvas.Pen.Color := clrSelectionBorder;
        ACanvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    finally
        ACanvas.Pen.Color := oldPenColor;
        ACanvas.Pen.Style := oldPenStyle;
        ACanvas.Brush.Color := oldBrushColor;
        ACanvas.Brush.Style := oldBrushStyle;
    end;
end;
procedure TClassicMenuPainter.DrawTopLevelSelection(ACanvas: TCanvas; const ARect: TRect);
var
    oldPenColor: TColor;
    oldBrushColor: TColor;
    oldBrushStyle: TBrushStyle;
    oldPenStyle: TPenStyle;
begin
    oldPenColor := ACanvas.Pen.Color;
    oldBrushColor := ACanvas.Brush.Color;
    oldBrushStyle := ACanvas.Brush.Style;
    oldPenStyle := ACanvas.Pen.Style;
    try
        FillMenuBarBackground(ACanvas, ARect);
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Pen.Style := psSolid;
        { Sunken frame: пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ/пїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ/пїЅпїЅпїЅпїЅпїЅ }
        ACanvas.Pen.Color := clrTopLevelFrameShadow;
        ACanvas.MoveTo(ARect.Left, ARect.Bottom - 1);
        ACanvas.LineTo(ARect.Left, ARect.Top);
        ACanvas.LineTo(ARect.Right - 1, ARect.Top);
        ACanvas.Pen.Color := clrTopLevelFrameLight;
        ACanvas.MoveTo(ARect.Right - 1, ARect.Top + 1);
        ACanvas.LineTo(ARect.Right - 1, ARect.Bottom - 1);
        ACanvas.LineTo(ARect.Left, ARect.Bottom - 1);
    finally
        ACanvas.Pen.Color := oldPenColor;
        ACanvas.Brush.Color := oldBrushColor;
        ACanvas.Brush.Style := oldBrushStyle;
        ACanvas.Pen.Style := oldPenStyle;
    end;
end;
procedure TClassicMenuPainter.DrawMenuText(
    ACanvas: TCanvas;
    const AText: string;
    const ARect: TRect;
    Alignment: TAlignment;
    bEnabled: Boolean
);
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
        SetTextColor(ACanvas.Handle, ColorToRGB(clrDisabledLight));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
        OffsetRect(textRect, -1, -1);
        SetTextColor(ACanvas.Handle, ColorToRGB(clrDisabledText));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
    end
    else
    begin
        SetTextColor(ACanvas.Handle, ColorToRGB(clrMenuText));
        DrawText(ACanvas.Handle, PChar(AText), Length(AText), textRect, flags);
    end;
end;
procedure TClassicMenuPainter.DrawCheckMark(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
var
    oldPenColor: TColor;
    oldBrushColor: TColor;
    oldBrushStyle: TBrushStyle;
    oldPenStyle: TPenStyle;
    oldPenWidth: Integer;
    function ColorToArgb(const AColor: TColor; const AAlpha: Byte = $FF): ARGB;
    var
        rgbColor: COLORREF;
    begin
        rgbColor := ColorToRGB(AColor);
        Result := MakeColor(AAlpha, GetRValue(rgbColor), GetGValue(rgbColor), GetBValue(rgbColor));
    end;
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
                DrawRadioAt(1, 1, clrDisabledLight);
                DrawRadioAt(0, 0, clrDisabledText);
            end
            else
            begin
                DrawCheckAt(1, 1, clrDisabledLight);
                DrawCheckAt(0, 0, clrDisabledText);
            end;
        end
        else
        begin
            if Item.RadioItem = True then
            begin
                DrawRadioAt(0, 0, clrMenuText);
            end
            else
            begin
                DrawCheckAt(0, 0, clrMenuText);
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
procedure TClassicMenuPainter.DrawImageArea(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bEnabled: Boolean);
var
    imageList: TCustomImageList;
    drawX: Integer;
    drawY: Integer;
begin
    if Item.Bitmap.Empty = False then
    begin
        drawX := ARect.Left + ((RectWidth(ARect) - Item.Bitmap.Width) div 2);
        drawY := ARect.Top + ((RectHeight(ARect) - Item.Bitmap.Height) div 2);
        if bEnabled = True then
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
    imageList := GetImageListFor(Item);
    if (imageList <> nil) and (Item.ImageIndex >= 0) then
    begin
        drawX := ARect.Left + ((RectWidth(ARect) - imageList.Width) div 2);
        drawY := ARect.Top + ((RectHeight(ARect) - imageList.Height) div 2);
        imageList.Draw(ACanvas, drawX, drawY, Item.ImageIndex, bEnabled);
        Exit();
    end;
    if Item.Checked = True then
    begin
        DrawCheckMark(Item, ACanvas, ARect, bEnabled);
    end;
end;
procedure TClassicMenuPainter.DrawTopLevelItem(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bSelected: Boolean);
var
    textRect: TRect;
    oldFontStyle: TFontStyles;
begin
    if bSelected = True then
    begin
        DrawTopLevelSelection(ACanvas, ARect);
    end
    else
    begin
        FillMenuBarBackground(ACanvas, ARect);
    end;
    textRect := ARect;
    Inc(textRect.Left, 2);
    Dec(textRect.Right, 2);
    Inc(textRect.Top, topLevelPaddingY);
    Dec(textRect.Bottom, topLevelPaddingY);
    if bSelected = True then
    begin
        OffsetRect(textRect, 1, 1);
    end;
    oldFontStyle := ACanvas.Font.Style;
    try
        if Item.Default = True then
        begin
            ACanvas.Font.Style := oldFontStyle + [fsBold];
        end;
        DrawMenuText(ACanvas, GetCaptionText(Item), textRect, taCenter, Item.Enabled);
    finally
        ACanvas.Font.Style := oldFontStyle;
    end;
end;
procedure TClassicMenuPainter.DrawPopupItem(Item: TMenuItem; ACanvas: TCanvas; const ARect: TRect; bSelected: Boolean);
var
    splitX: Integer;
    iconRect: TRect;
    captionRect: TRect;
    shortCutRect: TRect;
    rightLimit: Integer;
    shortCutText: string;
    shortCutWidth: Integer;
    oldFontStyle: TFontStyles;
begin
    if bSelected = True then
    begin
        DrawPopupSelection(ACanvas, ARect);
    end
    else
    begin
        FillPopupRowBackground(ACanvas, ARect);
    end;
    splitX := GetPopupSplitX(ARect);
    iconRect := Rect(ARect.Left, ARect.Top, splitX, ARect.Bottom);
    DrawImageArea(Item, ACanvas, iconRect, Item.Enabled);
    rightLimit := ARect.Right - textPaddingRight;
    if Item.Count > 0 then
    begin
        Dec(rightLimit, systemArrowReserveWidth);
    end;
    shortCutText := GetShortCutText(Item);
    shortCutWidth := 0;
    if shortCutText <> '' then
    begin
        shortCutWidth := MeasureTextWidth(ACanvas, shortCutText);
        shortCutRect := Rect(rightLimit - shortCutWidth, ARect.Top, rightLimit, ARect.Bottom);
        DrawMenuText(ACanvas, shortCutText, shortCutRect, taRightJustify, Item.Enabled);
        rightLimit := shortCutRect.Left - shortcutGap;
    end;
    captionRect := Rect(
        splitX + textPaddingLeft,
        ARect.Top,
        rightLimit,
        ARect.Bottom
    );
    oldFontStyle := ACanvas.Font.Style;
    try
        if Item.Default = True then
        begin
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end;
        DrawMenuText(ACanvas, GetCaptionText(Item), captionRect, taLeftJustify, Item.Enabled);
    finally
        ACanvas.Font.Style := oldFontStyle;
    end;
end;

end.

