unit DXUnreal3DView;

interface

uses
    Winapi.Windows,
    Winapi.Messages,
    Winapi.OpenGL,
    System.SysUtils,
    System.Classes,
    System.Math,
    Vcl.Controls,
    Vcl.Graphics,
    Vcl.Menus,
    DXUnreal3DModel;

type
    PRGBTripleArray = ^TRGBTripleArray;
    TRGBTripleArray = array[0..(MaxInt div SizeOf(TRGBTriple)) - 1] of TRGBTriple;

    TDXTriangleSelectedEvent = procedure(Sender: TObject; TriangleIndex: Integer) of object;
    TDXRectSelectionMode = (
        rsmAnyVisiblePixel,
        rsmTriangleCenter,
        rsmTwoVerticesInside,
        rsmAllVerticesInside
    );
    TDXMeshDisplayMode = (
        mdWireframe,
        mdWireframeSolid,
        mdFlatShaded,
        mdSmoothShaded,
        mdTextured
    );
    TDXBoundingBoxFrameMode = (
        bbfmCurrentFrame,
        bbfmAllFrames
    );
    TDXMeshViewerColors = record
        BackgroundColor: TColor;
        BackgroundTopColor: TColor;
        BackgroundBottomColor: TColor;
        SolidColorNormal: TColor;
        SolidColorTwoSided: TColor;
        SolidColorInvisible: TColor;
        WireframeColor: TColor;
        WireframeModeColor: TColor;
        SelectedFillColor: TColor;
        ActiveSelectedFillColor: TColor;
        SelectedLineColor: TColor;
        ActiveSelectedLineColor: TColor;
        PickingBackgroundColor: TColor;
        BoundingBoxColor: TColor;
        BoundingSphereColor: TColor;
        WarningTextColor: TColor;
        OriginMarkerColor: TColor;
        OriginLabelColor: TColor;
        ExceededVertexColor: TColor;
        AxisXColor: TColor;
        AxisYColor: TColor;
        AxisZColor: TColor;
        AxisLabelColor: TColor;
        SelectionRectBorderColor: TColor;
        SelectionRectFillColor: TColor;
        BoundingBoxLabelColor: TColor;
    end;
var
    DXDefaultMeshViewerColors: TDXMeshViewerColors;
type
    TDXLoadedTexture = record
        textureId: GLuint;
        bLoaded: Boolean;
        bTried: Boolean;
        width: Integer;
        height: Integer;
        fileName: string;
    end;

    TDXMeshViewer = class(TCustomControl)
    private
        dcHandleValue: HDC;
        rcHandleValue: HGLRC;
        modelValue: TDXUnreal3DModel;
        currentFrameValue: Integer;
        yawValue: Single;
        pitchValue: Single;
        distanceValue: Single;
        panXValue: Single;
        panYValue: Single;
        scaleValue: Single;
        centerXValue: Single;
        centerYValue: Single;
        centerZValue: Single;
        lastMouseXValue: Integer;
        lastMouseYValue: Integer;
        mouseDownXValue: Integer;
        mouseDownYValue: Integer;
        selectedTriangleIndexValue: Integer;
        selectedTrianglesValue: TArray<Boolean>;
        selectedCountValue: Integer;
        colorsValue: TDXMeshViewerColors;
        bGradientBackgroundValue: Boolean;
        bOpenGLReadyValue: Boolean;
        displayModeValue: TDXMeshDisplayMode;
        bWireframeValue: Boolean;
        bShadedValue: Boolean;
        bSmoothShadedValue: Boolean;
        shadeAmbientValue: Single;
        shadeDiffuseValue: Single;
        bLeftClickCandidateValue: Boolean;
        bRightClickMenuCandidateValue: Boolean;
        bRightMouseMovedValue: Boolean;
        bShowBoundingBoxValue: Boolean;
        bShowBoundingBoxVertexLabelsValue: Boolean;
        bShowBoundingSphereValue: Boolean;
        bShowAxisIndicatorValue: Boolean;
        bCullBackFacesValue: Boolean;
        bRespectTwoSidedValue: Boolean;
        bRectSelectActiveValue: Boolean;
        rectSelectionModeValue: TDXRectSelectionMode;
        boundingBoxFrameModeValue: TDXBoundingBoxFrameMode;
        bShowDecodedBoundingBoxInfoValue: Boolean;
        bShowRawBoundingBoxInfoValue: Boolean;
        bShowMeshWarningsValue: Boolean;
        bShowArtistSpaceDebugValue: Boolean;
        maxDecodedDistanceAllFramesValue: Single;
        bMaxDecodedDistanceAllFramesReadyValue: Boolean;
        maxDecodedDistanceCurrentFrameValue: Single;
        cachedMaxDecodedDistanceFrameIndexValue: Integer;
        bMaxDecodedDistanceCurrentFrameReadyValue: Boolean;
        rectSelectStartXValue: Integer;
        rectSelectStartYValue: Integer;
        rectSelectCurrentXValue: Integer;
        rectSelectCurrentYValue: Integer;
        axisFontBaseValue: Cardinal;
        axisFontHandleValue: HFONT;
        axisFontOldHandleValue: HGDIOBJ;
        axisFontNameValue: string;
        axisFontHeightValue: Integer;
        bAxisFontReadyValue: Boolean;
        onTriangleSelectedValue: TDXTriangleSelectedEvent;
        onSelectionChangedValue: TNotifyEvent;
        loadedTexturesValue: TArray<TDXLoadedTexture>;
        envMapTextureValue: TDXLoadedTexture;
        procedure InitializeOpenGL();
        procedure ReleaseLoadedTextures();
        procedure InvalidateLoadedTextures();
        function TryLoadTextureBitmap(const TextureIndex: Integer): Boolean;
        function TryLoadEnvironmentTextureBitmap(): Boolean;
        procedure ResetLoadedTexture(var TextureEntry: TDXLoadedTexture);
        procedure ReleaseLoadedTexture(var TextureEntry: TDXLoadedTexture);
        procedure FinalizeOpenGL();
        procedure SetupViewport();
        procedure SetupViewTransform();
        procedure DrawModel();
        procedure DrawModelForPicking();
        procedure DrawViewportBackground();
        procedure DrawSelectedTriangles();
        procedure DrawBoundingBox();
        procedure DrawBoundingSphere();
        procedure DrawAxisIndicator();
        procedure DrawSelectionRectangle();
        procedure ConfigureBackFaceCulling(const bEnable: Boolean);
        procedure BuildAxisFont();
        procedure ReleaseAxisFont();
        procedure RebuildView();
        procedure EnsureSelectionCapacity();
        procedure ResetSelectionState();
        procedure DoSelectionChanged();
        procedure DoTriangleSelected();
        procedure SetModel(const AModel: TDXUnreal3DModel);
        procedure SetCurrentFrame(AFrame: Integer);
        procedure SetDistance(const AValue: Single);
        procedure SetDisplayMode(const AValue: TDXMeshDisplayMode);
        procedure SetWireframe(const bValue: Boolean);
        procedure SetShaded(const bValue: Boolean);
        procedure SetSmoothShaded(const bValue: Boolean);
        procedure SetShadeAmbient(const AValue: Single);
        procedure SetShadeDiffuse(const AValue: Single);
        procedure SetColors(const AValue: TDXMeshViewerColors);
        procedure SetGradientBackground(const bValue: Boolean);
        procedure SetSelectedTriangleIndex(AValue: Integer);
        procedure SetShowBoundingBox(const bValue: Boolean);
        procedure SetShowBoundingBoxVertexLabels(const bValue: Boolean);
        procedure SetShowBoundingSphere(const bValue: Boolean);
        procedure SetShowAxisIndicator(const bValue: Boolean);
        procedure SetCullBackFaces(const bValue: Boolean);
        procedure SetRespectTwoSided(const bValue: Boolean);
        procedure SetAxisFontName(const AValue: string);
        procedure SetAxisFontHeight(AValue: Integer);
        procedure SetTriangleSelected(Index: Integer; bValue: Boolean);
        procedure InternalSetSingleSelection(TriangleIndex: Integer);
        procedure InternalAddSelection(TriangleIndex: Integer);
        procedure InternalRemoveSelection(TriangleIndex: Integer);
        procedure InternalToggleSelection(TriangleIndex: Integer);
        procedure ApplySelectionClick(TriangleIndex: Integer; Shift: TShiftState);
        function GetSafeFrame(): Integer;
        function BuildPerspectiveHalfSize(const NearPlane, FovYDegrees, AspectRatio: Double): Double;
        function IsTriangleIndexValid(AValue: Integer): Boolean;
        function EncodeTriangleIndexToColor(Index: Integer): Cardinal;
        function DecodeTriangleIndexFromColor(ColorValue: Cardinal): Integer;
        function SelectTriangleAt(X, Y: Integer): Integer;
        procedure SelectTrianglesInRect(const SelectionRect: TRect; Shift: TShiftState);
        procedure SelectTrianglesInRectByVisiblePixels(const SelectionRect: TRect; Shift: TShiftState);
        procedure SelectTrianglesInRectByGeometry(const SelectionRect: TRect; Shift: TShiftState);
        function GetTriangleSelected(Index: Integer): Boolean;
        function GetRectSelectionMode(): TDXRectSelectionMode;
        procedure SetRectSelectionMode(AValue: TDXRectSelectionMode);
        function BuildCurrentFrameBounds(out Bounds: TDXMeshBounds): Boolean;
        function GetActiveBoundingBoxRawBounds(out Bounds: TDXMeshBounds): Boolean;
        function GetDecodedVertexScale(): Single;
        function GetArtistSpaceScale(): Single;
        function GetMaxDecodedDistanceForCurrentFrame(FrameIndex: Integer): Single;
        function GetMaxDecodedDistanceForAllFrames(): Single;
        function GetActiveMaxDecodedDistance(): Single;
        function GetActiveBoundingSphereRadiusRaw(): Single;
        procedure ResetDebugCaches();
        procedure SetBoundingBoxFrameMode(AValue: TDXBoundingBoxFrameMode);
        procedure SetShowDecodedBoundingBoxInfo(const bValue: Boolean);
        procedure SetShowRawBoundingBoxInfo(const bValue: Boolean);
        procedure SetShowMeshWarnings(const bValue: Boolean);
        procedure SetShowArtistSpaceDebug(const bValue: Boolean);
        function ProjectModelPointToScreen(const PointValue: TDXMeshPoint; out ScreenX, ScreenY: Double): Boolean;
        function TriangleCenterInsideRect(const SelectionRect: TRect; FrameIndex, TriangleIndex: Integer): Boolean;
        function TriangleHasAtLeastNVerticesInsideRect(const SelectionRect: TRect; FrameIndex, TriangleIndex, RequiredCount: Integer): Boolean;
        function GetSelectionCount(): Integer;
        function TriangleIsTwoSided(const Triangle: TDXMeshTriangle): Boolean;
        procedure SetGLColor(const AColor: TColor);
        procedure SetGLClearColor(const AColor: TColor);

    protected
        procedure CreateParams(var Params: TCreateParams); override;
        procedure CreateWnd(); override;
        procedure DestroyWnd(); override;
        procedure Paint(); override;
        procedure Resize(); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
        procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
        procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;

    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy(); override;
        procedure ResetView();
        procedure NextFrame();
        procedure PrevFrame();
        procedure RenderNow();
        procedure ResetColorsToDefaults();
        procedure ClearSelection();
        procedure SelectAllTriangles();
        procedure InvertSelection();
        procedure SelectTriangle(TriangleIndex: Integer; const bAddToSelection: Boolean = False);
        procedure ToggleTriangle(TriangleIndex: Integer);
        procedure SelectTrianglesByTextureIndex(TextureIndex: Integer; const bAddToSelection: Boolean = False);
        procedure SelectTrianglesByPolyFlags(RequiredFlags: Cardinal; const bAddToSelection: Boolean = False);
        procedure SelectTrianglesByRawTypeByte(TypeByte: Byte; const bAddToSelection: Boolean = False);
        procedure AssignSelection(const SelectedIndices: TArray<Integer>; ActiveTriangleIndex: Integer = -1);
        function IsTriangleSelected(TriangleIndex: Integer): Boolean;
        property Model: TDXUnreal3DModel read modelValue write SetModel;
        property CurrentFrame: Integer read currentFrameValue write SetCurrentFrame;
        property Distance: Single read distanceValue write SetDistance;
        property DisplayMode: TDXMeshDisplayMode read displayModeValue write SetDisplayMode;
        property Wireframe: Boolean read bWireframeValue write SetWireframe;
        property Shaded: Boolean read bShadedValue write SetShaded;
        property SmoothShaded: Boolean read bSmoothShadedValue write SetSmoothShaded;
        property ShadeAmbient: Single read shadeAmbientValue write SetShadeAmbient;
        property ShadeDiffuse: Single read shadeDiffuseValue write SetShadeDiffuse;
        property Colors: TDXMeshViewerColors read colorsValue write SetColors;
        property GradientBackground: Boolean read bGradientBackgroundValue write SetGradientBackground;
        property SelectedTriangleIndex: Integer read selectedTriangleIndexValue write SetSelectedTriangleIndex;
        property SelectionCount: Integer read GetSelectionCount;
        property TriangleSelected[Index: Integer]: Boolean read GetTriangleSelected write SetTriangleSelected;
        property OnTriangleSelected: TDXTriangleSelectedEvent read onTriangleSelectedValue write onTriangleSelectedValue;
        property OnSelectionChanged: TNotifyEvent read onSelectionChangedValue write onSelectionChangedValue;
        property ShowBoundingBox: Boolean read bShowBoundingBoxValue write SetShowBoundingBox;
        property ShowBoundingBoxVertexLabels: Boolean read bShowBoundingBoxVertexLabelsValue write SetShowBoundingBoxVertexLabels;
        property ShowBoundingSphere: Boolean read bShowBoundingSphereValue write SetShowBoundingSphere;
        property BoundingBoxFrameMode: TDXBoundingBoxFrameMode read boundingBoxFrameModeValue write SetBoundingBoxFrameMode;
        property ShowDecodedBoundingBoxInfo: Boolean read bShowDecodedBoundingBoxInfoValue write SetShowDecodedBoundingBoxInfo;
        property ShowRawBoundingBoxInfo: Boolean read bShowRawBoundingBoxInfoValue write SetShowRawBoundingBoxInfo;
        property ShowMeshWarnings: Boolean read bShowMeshWarningsValue write SetShowMeshWarnings;
        property ShowArtistSpaceDebug: Boolean read bShowArtistSpaceDebugValue write SetShowArtistSpaceDebug;
        property ShowAxisIndicator: Boolean read bShowAxisIndicatorValue write SetShowAxisIndicator;
        property CullBackFaces: Boolean read bCullBackFacesValue write SetCullBackFaces;
        property RespectTwoSided: Boolean read bRespectTwoSidedValue write SetRespectTwoSided;
        property RectSelectionMode: TDXRectSelectionMode read GetRectSelectionMode write SetRectSelectionMode;
        property AxisFontName: string read axisFontNameValue write SetAxisFontName;
        property AxisFontHeight: Integer read axisFontHeightValue write SetAxisFontHeight;
        property PopupMenu;
    end;

implementation

type
    TDXViewerVec3 = record
        X: Single;
        Y: Single;
        Z: Single;


    end;

const
    OrbitSpeed = 0.50;
    PanDragSpeed = 0.0035;
    ZoomWheelStep = 0.25;
    MinDistance = 0.25;
    MaxDistance = 50.0;
    DefaultDistance = 3.0;
    ClickMoveThreshold = 3;
    MinShadeAmbient = 0.0;
    MaxShadeAmbient = 1.0;
    MinShadeDiffuse = 0.0;
    MaxShadeDiffuse = 1.0;

procedure TDXMeshViewer.SetGLColor(const AColor: TColor);
var
    rgbColor: Cardinal;
begin
    rgbColor := ColorToRGB(AColor);
    glColor3f(
        GetRValue(rgbColor) / 255.0,
        GetGValue(rgbColor) / 255.0,
        GetBValue(rgbColor) / 255.0
    );
end;

procedure TDXMeshViewer.SetGLClearColor(const AColor: TColor);
var
    rgbColor: Cardinal;
begin
    rgbColor := ColorToRGB(AColor);
    glClearColor(
        GetRValue(rgbColor) / 255.0,
        GetGValue(rgbColor) / 255.0,
        GetBValue(rgbColor) / 255.0,
        1.0
    );
end;

procedure TDXMeshViewer.SetColors(const AValue: TDXMeshViewerColors);
begin
    colorsValue := AValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetGradientBackground(const bValue: Boolean);
begin
    if bGradientBackgroundValue = bValue then
    begin
        Exit;
    end;
    bGradientBackgroundValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowBoundingBox(const bValue: Boolean);
begin
    bShowBoundingBoxValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowBoundingBoxVertexLabels(const bValue: Boolean);
begin
    if bShowBoundingBoxVertexLabelsValue <> bValue then
    begin
        bShowBoundingBoxVertexLabelsValue := bValue;
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SetShowBoundingSphere(const bValue: Boolean);
begin
    if bShowBoundingSphereValue = bValue then
    begin
        Exit;
    end;
    bShowBoundingSphereValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetBoundingBoxFrameMode(AValue: TDXBoundingBoxFrameMode);
begin
    if boundingBoxFrameModeValue = AValue then
    begin
        Exit;
    end;
    boundingBoxFrameModeValue := AValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowDecodedBoundingBoxInfo(const bValue: Boolean);
begin
    if bShowDecodedBoundingBoxInfoValue = bValue then
    begin
        Exit;
    end;
    bShowDecodedBoundingBoxInfoValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowRawBoundingBoxInfo(const bValue: Boolean);
begin
    if bShowRawBoundingBoxInfoValue = bValue then
    begin
        Exit;
    end;
    bShowRawBoundingBoxInfoValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowMeshWarnings(const bValue: Boolean);
begin
    if bShowMeshWarningsValue = bValue then
    begin
        Exit;
    end;
    bShowMeshWarningsValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowArtistSpaceDebug(const bValue: Boolean);
begin
    if bShowArtistSpaceDebugValue = bValue then
    begin
        Exit;
    end;
    bShowArtistSpaceDebugValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetShowAxisIndicator(const bValue: Boolean);
begin
    bShowAxisIndicatorValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetCullBackFaces(const bValue: Boolean);
begin
    if bCullBackFacesValue = bValue then
    begin
        Exit;
    end;
    bCullBackFacesValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetRespectTwoSided(const bValue: Boolean);
begin
    if bRespectTwoSidedValue = bValue then
    begin
        Exit;
    end;
    bRespectTwoSidedValue := bValue;
    RenderNow();
end;

procedure TDXMeshViewer.SetAxisFontName(const AValue: string);
var
    newValue: string;
begin
    newValue := Trim(AValue);
    if newValue = '' then
    begin
        newValue := 'Verdana';
    end;
    if SameText(axisFontNameValue, newValue) = True then
    begin
        Exit;
    end;
    axisFontNameValue := newValue;
    ReleaseAxisFont();
    if bOpenGLReadyValue = True then
    begin
        BuildAxisFont();
    end;
    RenderNow();
end;

procedure TDXMeshViewer.SetAxisFontHeight(AValue: Integer);
begin
    if AValue < 8 then
    begin
        AValue := 8;
    end;
    if axisFontHeightValue = AValue then
    begin
        Exit;
    end;
    axisFontHeightValue := AValue;
    ReleaseAxisFont();
    if bOpenGLReadyValue = True then
    begin
        BuildAxisFont();
    end;
    RenderNow();
end;

procedure TDXMeshViewer.ResetColorsToDefaults();
begin
    colorsValue := DXDefaultMeshViewerColors;
    RenderNow();
end;

procedure TDXMeshViewer.ResetDebugCaches();
begin
    maxDecodedDistanceAllFramesValue := 0.0;
    bMaxDecodedDistanceAllFramesReadyValue := False;
    maxDecodedDistanceCurrentFrameValue := 0.0;
    cachedMaxDecodedDistanceFrameIndexValue := -1;
    bMaxDecodedDistanceCurrentFrameReadyValue := False;
end;

constructor TDXMeshViewer.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    Width := 640;
    Height := 480;
    TabStop := True;
    DoubleBuffered := False;
    dcHandleValue := 0;
    rcHandleValue := 0;
    modelValue := nil;
    currentFrameValue := 0;
    yawValue := 30.0;
    pitchValue := -20.0;
    distanceValue := DefaultDistance;
    panXValue := 0.0;
    panYValue := 0.0;
    scaleValue := 1.0;
    centerXValue := 0.0;
    centerYValue := 0.0;
    centerZValue := 0.0;
    lastMouseXValue := 0;
    lastMouseYValue := 0;
    mouseDownXValue := 0;
    mouseDownYValue := 0;
    selectedTriangleIndexValue := -1;
    SetLength(selectedTrianglesValue, 0);
    selectedCountValue := 0;
    colorsValue := DXDefaultMeshViewerColors;
    bGradientBackgroundValue := True;
    bOpenGLReadyValue := False;
    displayModeValue := mdWireframeSolid;
    bWireframeValue := False;
    bShadedValue := False;
    bSmoothShadedValue := False;
    shadeAmbientValue := 0.78;
    shadeDiffuseValue := 0.22;
    bLeftClickCandidateValue := False;
    bRightClickMenuCandidateValue := False;
    bRightMouseMovedValue := False;
    bShowBoundingBoxValue := True;
    bShowBoundingBoxVertexLabelsValue := True;
    bShowBoundingSphereValue := True;
    boundingBoxFrameModeValue := bbfmAllFrames;
    bShowDecodedBoundingBoxInfoValue := True;
    bShowRawBoundingBoxInfoValue := False;
    bShowMeshWarningsValue := True;
    bShowArtistSpaceDebugValue := True;
    maxDecodedDistanceAllFramesValue := 0.0;
    bMaxDecodedDistanceAllFramesReadyValue := False;
    maxDecodedDistanceCurrentFrameValue := 0.0;
    cachedMaxDecodedDistanceFrameIndexValue := -1;
    bMaxDecodedDistanceCurrentFrameReadyValue := False;
    bShowAxisIndicatorValue := True;
    bCullBackFacesValue := False;
    bRespectTwoSidedValue := True;
    rectSelectionModeValue := rsmAnyVisiblePixel;
    bRectSelectActiveValue := False;
    rectSelectStartXValue := 0;
    rectSelectStartYValue := 0;
    rectSelectCurrentXValue := 0;
    rectSelectCurrentYValue := 0;
    axisFontBaseValue := 0;
    axisFontHandleValue := 0;
    axisFontOldHandleValue := 0;
    axisFontNameValue := 'Verdana';
    axisFontHeightValue := 14;
    bAxisFontReadyValue := False;
    onTriangleSelectedValue := nil;
    onSelectionChangedValue := nil;
    SetLength(loadedTexturesValue, 0);
    ResetLoadedTexture(envMapTextureValue);
    ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csDoubleClicks];
end;

destructor TDXMeshViewer.Destroy();
begin
    ReleaseAxisFont();
    FinalizeOpenGL();
    inherited Destroy();
end;

procedure TDXMeshViewer.CreateParams(var Params: TCreateParams);
begin
    inherited CreateParams(Params);
    Params.WindowClass.style := Params.WindowClass.style or CS_OWNDC;
end;

procedure TDXMeshViewer.CreateWnd();
begin
    inherited CreateWnd();
    InitializeOpenGL();
end;

procedure TDXMeshViewer.DestroyWnd();
begin
    FinalizeOpenGL();
    inherited DestroyWnd();
end;

procedure TDXMeshViewer.InitializeOpenGL();
var
    pixelFormatDescriptor: TPixelFormatDescriptor;
    pixelFormatIndex: Integer;
begin
    if bOpenGLReadyValue = True then
    begin
        Exit;
    end;
    dcHandleValue := GetDC(Handle);
    if dcHandleValue = 0 then
    begin
        Exit;
    end;
    ZeroMemory(@pixelFormatDescriptor, SizeOf(pixelFormatDescriptor));
    pixelFormatDescriptor.nSize := SizeOf(pixelFormatDescriptor);
    pixelFormatDescriptor.nVersion := 1;
    pixelFormatDescriptor.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    pixelFormatDescriptor.iPixelType := PFD_TYPE_RGBA;
    pixelFormatDescriptor.cColorBits := 24;
    pixelFormatDescriptor.cDepthBits := 24;
    pixelFormatDescriptor.iLayerType := PFD_MAIN_PLANE;
    pixelFormatIndex := ChoosePixelFormat(dcHandleValue, @pixelFormatDescriptor);
    if pixelFormatIndex = 0 then
    begin
        ReleaseDC(Handle, dcHandleValue);
        dcHandleValue := 0;
        Exit;
    end;
    if SetPixelFormat(dcHandleValue, pixelFormatIndex, @pixelFormatDescriptor) = False then
    begin
        ReleaseDC(Handle, dcHandleValue);
        dcHandleValue := 0;
        Exit;
    end;
    rcHandleValue := wglCreateContext(dcHandleValue);
    if rcHandleValue = 0 then
    begin
        ReleaseDC(Handle, dcHandleValue);
        dcHandleValue := 0;
        Exit;
    end;
    if wglMakeCurrent(dcHandleValue, rcHandleValue) = False then
    begin
        wglDeleteContext(rcHandleValue);
        rcHandleValue := 0;
        ReleaseDC(Handle, dcHandleValue);
        dcHandleValue := 0;
        Exit;
    end;
    BuildAxisFont();
    SetGLClearColor(colorsValue.BackgroundColor);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glDisable(GL_CULL_FACE);
    glShadeModel(GL_SMOOTH);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    wglMakeCurrent(0, 0);
    bOpenGLReadyValue := True;
    Invalidate();
end;

procedure TDXMeshViewer.FinalizeOpenGL();
begin
    ReleaseAxisFont();
    if rcHandleValue <> 0 then
    begin
        if (dcHandleValue <> 0) and (wglMakeCurrent(dcHandleValue, rcHandleValue) = True) then
        begin
            ReleaseLoadedTextures();
            ReleaseLoadedTexture(envMapTextureValue);
            wglMakeCurrent(0, 0);
        end;
        wglDeleteContext(rcHandleValue);
        rcHandleValue := 0;
    end;
    if dcHandleValue <> 0 then
    begin
        ReleaseDC(Handle, dcHandleValue);
        dcHandleValue := 0;
    end;
    bOpenGLReadyValue := False;
end;

procedure TDXMeshViewer.InvalidateLoadedTextures();
var
    textureIndex: Integer;
begin
    for textureIndex := 0 to High(loadedTexturesValue) do
    begin
        ResetLoadedTexture(loadedTexturesValue[textureIndex]);
    end;
    SetLength(loadedTexturesValue, 0);
    ResetLoadedTexture(envMapTextureValue);
end;

//type
//    PRGBTripleArray = ^TRGBTripleArray;
//    TRGBTripleArray = array[0..(MaxInt div SizeOf(TRGBTriple)) - 1] of TRGBTriple;

procedure TDXMeshViewer.ResetLoadedTexture(var TextureEntry: TDXLoadedTexture);
begin
    TextureEntry.textureId := 0;
    TextureEntry.bLoaded := False;
    TextureEntry.bTried := False;
    TextureEntry.width := 0;
    TextureEntry.height := 0;
    TextureEntry.fileName := '';
end;

procedure TDXMeshViewer.ReleaseLoadedTexture(var TextureEntry: TDXLoadedTexture);
var
    textureId: GLuint;
begin
    textureId := TextureEntry.textureId;
    if textureId <> 0 then
    begin
        glDeleteTextures(1, @textureId);
        TextureEntry.textureId := 0;
    end;
    ResetLoadedTexture(TextureEntry);
end;

procedure TDXMeshViewer.ReleaseLoadedTextures();
var
    textureIndex: Integer;
begin
    for textureIndex := 0 to High(loadedTexturesValue) do
    begin
        ReleaseLoadedTexture(loadedTexturesValue[textureIndex]);
    end;
    SetLength(loadedTexturesValue, 0);
end;

function TDXMeshViewer.TryLoadTextureBitmap(const TextureIndex: Integer): Boolean;
var
    textureFileName: string;
    bitmap: TBitmap;
    pixelData: TBytes;
    srcLine: PRGBTripleArray;
    uploadWidth: Integer;
    uploadHeight: Integer;
    x: Integer;
    y: Integer;
    dstIndex: Integer;
    textureId: GLuint;
begin
    Result := False;
    if modelValue = nil then
    begin
        Exit;
    end;
    if TextureIndex < 0 then
    begin
        Exit;
    end;
    if TextureIndex >= Length(loadedTexturesValue) then
    begin
        SetLength(loadedTexturesValue, TextureIndex + 1);
    end;
    if loadedTexturesValue[TextureIndex].bLoaded = True then
    begin
        Result := True;
        Exit;
    end;
    if loadedTexturesValue[TextureIndex].bTried = True then
    begin
        Exit;
    end;
    loadedTexturesValue[TextureIndex].bTried := True;
    textureFileName := modelValue.BaseFileName + '_' + IntToStr(TextureIndex) + '.bmp';
    loadedTexturesValue[TextureIndex].fileName := textureFileName;
    if FileExists(textureFileName) = False then
    begin
        Exit;
    end;
    bitmap := TBitmap.Create();
    try
        bitmap.LoadFromFile(textureFileName);
        bitmap.PixelFormat := pf24bit;
        uploadWidth := bitmap.Width;
        uploadHeight := bitmap.Height;
        if (uploadWidth <= 0) or (uploadHeight <= 0) then
        begin
            Exit;
        end;
        SetLength(pixelData, uploadWidth * uploadHeight * 3);
        dstIndex := 0;
        for y := uploadHeight - 1 downto 0 do
        begin
            srcLine := bitmap.ScanLine[y];
            for x := 0 to uploadWidth - 1 do
            begin
                pixelData[dstIndex + 0] := srcLine[x].rgbtRed;
                pixelData[dstIndex + 1] := srcLine[x].rgbtGreen;
                pixelData[dstIndex + 2] := srcLine[x].rgbtBlue;
                Inc(dstIndex, 3);
            end;
        end;
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glGenTextures(1, @textureId);
        if textureId = 0 then
        begin
            Exit;
        end;
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            GL_RGB,
            uploadWidth,
            uploadHeight,
            0,
            GL_RGB,
            GL_UNSIGNED_BYTE,
            @pixelData[0]
        );
        glBindTexture(GL_TEXTURE_2D, 0);
        loadedTexturesValue[TextureIndex].textureId := textureId;
        loadedTexturesValue[TextureIndex].bLoaded := True;
        loadedTexturesValue[TextureIndex].width := uploadWidth;
        loadedTexturesValue[TextureIndex].height := uploadHeight;
        Result := True;
    finally
        bitmap.Free();
    end;
end;

function TDXMeshViewer.TryLoadEnvironmentTextureBitmap(): Boolean;
var
    textureFileName: string;
    bitmap: TBitmap;
    pixelData: TBytes;
    srcLine: PRGBTripleArray;
    uploadWidth: Integer;
    uploadHeight: Integer;
    x: Integer;
    y: Integer;
    dstIndex: Integer;
    textureId: GLuint;
begin
    Result := False;
    if envMapTextureValue.bLoaded = True then
    begin
        Result := True;
        Exit;
    end;
    if envMapTextureValue.bTried = True then
    begin
        Exit;
    end;
    envMapTextureValue.bTried := True;
    textureFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'envmap.bmp';
    envMapTextureValue.fileName := textureFileName;
    if FileExists(textureFileName) = False then
    begin
        Exit;
    end;
    bitmap := TBitmap.Create();
    try
        bitmap.LoadFromFile(textureFileName);
        bitmap.PixelFormat := pf24bit;
        uploadWidth := bitmap.Width;
        uploadHeight := bitmap.Height;
        if (uploadWidth <= 0) or (uploadHeight <= 0) then
        begin
            Exit;
        end;
        SetLength(pixelData, uploadWidth * uploadHeight * 3);
        dstIndex := 0;
        for y := uploadHeight - 1 downto 0 do
        begin
            srcLine := bitmap.ScanLine[y];
            for x := 0 to uploadWidth - 1 do
            begin
                pixelData[dstIndex + 0] := srcLine[x].rgbtRed;
                pixelData[dstIndex + 1] := srcLine[x].rgbtGreen;
                pixelData[dstIndex + 2] := srcLine[x].rgbtBlue;
                Inc(dstIndex, 3);
            end;
        end;
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glGenTextures(1, @textureId);
        if textureId = 0 then
        begin
            Exit;
        end;
        glBindTexture(GL_TEXTURE_2D, textureId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            GL_RGB,
            uploadWidth,
            uploadHeight,
            0,
            GL_RGB,
            GL_UNSIGNED_BYTE,
            @pixelData[0]
        );
        glBindTexture(GL_TEXTURE_2D, 0);
        envMapTextureValue.textureId := textureId;
        envMapTextureValue.bLoaded := True;
        envMapTextureValue.width := uploadWidth;
        envMapTextureValue.height := uploadHeight;
        Result := True;
    finally
        bitmap.Free();
    end;
end;

function TDXMeshViewer.BuildPerspectiveHalfSize(const NearPlane, FovYDegrees, AspectRatio: Double): Double;
var
    halfAngleRadians: Double;
begin
    halfAngleRadians := DegToRad(FovYDegrees * 0.5);
    Result := NearPlane * Tan(halfAngleRadians);
    if AspectRatio <= 0.0 then
    begin
        Result := NearPlane;
    end;
end;

procedure TDXMeshViewer.SetupViewport();
var
    widthValue: Integer;
    heightValue: Integer;
    aspectRatio: Double;
    nearPlane: Double;
    farPlane: Double;
    topValue: Double;
    rightValue: Double;
begin
    widthValue := Max(ClientWidth, 1);
    heightValue := Max(ClientHeight, 1);
    aspectRatio := widthValue / heightValue;
    nearPlane := 0.1;
    farPlane := 100.0;
    topValue := BuildPerspectiveHalfSize(nearPlane, 45.0, aspectRatio);
    rightValue := topValue * aspectRatio;
    glViewport(0, 0, widthValue, heightValue);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-rightValue, rightValue, -topValue, topValue, nearPlane, farPlane);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
end;

procedure TDXMeshViewer.SetupViewTransform();
begin
    glTranslatef(panXValue, panYValue, -distanceValue);
    glRotatef(pitchValue, 1.0, 0.0, 0.0);
    glRotatef(yawValue, 0.0, 1.0, 0.0);
    glRotatef(-90.0, 1.0, 0.0, 0.0);
    glScalef(scaleValue, scaleValue, scaleValue);
    glTranslatef(-centerXValue, -centerYValue, -centerZValue);
end;

function TDXMeshViewer.GetSafeFrame(): Integer;
begin
    Result := 0;
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    Result := EnsureRange(currentFrameValue, 0, modelValue.FrameCount - 1);
end;

function TDXMeshViewer.IsTriangleIndexValid(AValue: Integer): Boolean;
begin
    Result := False;
    if modelValue = nil then
    begin
        Exit;
    end;
    if AValue < 0 then
    begin
        Exit;
    end;
    if AValue >= modelValue.TriangleCount then
    begin
        Exit;
    end;
    Result := True;
end;

procedure TDXMeshViewer.EnsureSelectionCapacity();
var
    triangleCountValue: Integer;
begin
    if modelValue = nil then
    begin
        SetLength(selectedTrianglesValue, 0);
        selectedCountValue := 0;
        selectedTriangleIndexValue := -1;
        Exit;
    end;
    triangleCountValue := modelValue.TriangleCount;
    if triangleCountValue < 0 then
    begin
        triangleCountValue := 0;
    end;
    if Length(selectedTrianglesValue) <> triangleCountValue then
    begin
        SetLength(selectedTrianglesValue, triangleCountValue);
        ResetSelectionState();
    end;
end;

procedure TDXMeshViewer.ResetSelectionState();
var
    i: Integer;
begin
    for i := 0 to High(selectedTrianglesValue) do
    begin
        selectedTrianglesValue[i] := False;
    end;
    selectedCountValue := 0;
    selectedTriangleIndexValue := -1;
end;

procedure TDXMeshViewer.DoSelectionChanged();
begin
    if Assigned(onSelectionChangedValue) = True then
    begin
        onSelectionChangedValue(Self);
    end;
end;

procedure TDXMeshViewer.DoTriangleSelected();
begin
    if Assigned(onTriangleSelectedValue) = True then
    begin
        onTriangleSelectedValue(Self, selectedTriangleIndexValue);
    end;
end;

function TDXMeshViewer.EncodeTriangleIndexToColor(Index: Integer): Cardinal;
var
    colorIndex: Cardinal;
begin
    colorIndex := Cardinal(Index + 1);
    Result := colorIndex and $00FFFFFF;
end;

function TDXMeshViewer.DecodeTriangleIndexFromColor(ColorValue: Cardinal): Integer;
var
    colorIndex: Cardinal;
begin
    Result := -1;
    colorIndex := ColorValue and $00FFFFFF;
    if colorIndex = 0 then
    begin
        Exit;
    end;
    Result := Integer(colorIndex) - 1;
end;

function TDXMeshViewer.TriangleIsTwoSided(const Triangle: TDXMeshTriangle): Boolean;
begin
    Result := False;
    if (Triangle.PolyFlags and Cardinal($00000100)) <> 0 then
    begin
        Result := True;
    end;
end;

procedure TDXMeshViewer.ConfigureBackFaceCulling(const bEnable: Boolean);
begin
    if bEnable = True then
    begin
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glFrontFace(GL_CCW);
    end
    else
    begin
        glDisable(GL_CULL_FACE);
    end;
end;

procedure TDXMeshViewer.DrawModel();
var
    frameIndex: Integer;
    vertexNormals: TArray<TDXViewerVec3>;
    bTexturedMode: Boolean;
    function MakeVec3(const X, Y, Z: Single): TDXViewerVec3;
    begin
        Result.X := X;
        Result.Y := Y;
        Result.Z := Z;
    end;
    function SubVec3(const A, B: TDXViewerVec3): TDXViewerVec3;
    begin
        Result.X := A.X - B.X;
        Result.Y := A.Y - B.Y;
        Result.Z := A.Z - B.Z;
    end;
    function AddVec3(const A, B: TDXViewerVec3): TDXViewerVec3;
    begin
        Result.X := A.X + B.X;
        Result.Y := A.Y + B.Y;
        Result.Z := A.Z + B.Z;
    end;
    function CrossVec3(const A, B: TDXViewerVec3): TDXViewerVec3;
    begin
        Result.X := (A.Y * B.Z) - (A.Z * B.Y);
        Result.Y := (A.Z * B.X) - (A.X * B.Z);
        Result.Z := (A.X * B.Y) - (A.Y * B.X);
    end;
    function NormalizeVec3(const A: TDXViewerVec3): TDXViewerVec3;
    var
        vecLen: Single;
    begin
        vecLen := Sqrt((A.X * A.X) + (A.Y * A.Y) + (A.Z * A.Z));
        if vecLen <= 0.00001 then
        begin
            Result := MakeVec3(0.0, 0.0, 1.0);
            Exit;
        end;
        Result.X := A.X / vecLen;
        Result.Y := A.Y / vecLen;
        Result.Z := A.Z / vecLen;
    end;
    function RotateX(const V: TDXViewerVec3; const AngleDegrees: Single): TDXViewerVec3;
    var
        angleRadians: Single;
        sinValue: Single;
        cosValue: Single;
    begin
        angleRadians := DegToRad(AngleDegrees);
        SinCos(angleRadians, sinValue, cosValue);
        Result.X := V.X;
        Result.Y := (V.Y * cosValue) - (V.Z * sinValue);
        Result.Z := (V.Y * sinValue) + (V.Z * cosValue);
    end;
    function RotateY(const V: TDXViewerVec3; const AngleDegrees: Single): TDXViewerVec3;
    var
        angleRadians: Single;
        sinValue: Single;
        cosValue: Single;
    begin
        angleRadians := DegToRad(AngleDegrees);
        SinCos(angleRadians, sinValue, cosValue);
        Result.X := (V.X * cosValue) + (V.Z * sinValue);
        Result.Y := V.Y;
        Result.Z := (-V.X * sinValue) + (V.Z * cosValue);
    end;
    function CalculateFaceNormal(const P0, P1, P2: TDXMeshPoint): TDXViewerVec3;
    var
        v0: TDXViewerVec3;
        v1: TDXViewerVec3;
        v2: TDXViewerVec3;
        edge1: TDXViewerVec3;
        edge2: TDXViewerVec3;
    begin
        v0 := MakeVec3(P0.X, P0.Y, P0.Z);
        v1 := MakeVec3(P1.X, P1.Y, P1.Z);
        v2 := MakeVec3(P2.X, P2.Y, P2.Z);
        edge1 := SubVec3(v1, v0);
        edge2 := SubVec3(v2, v0);
        Result := NormalizeVec3(CrossVec3(edge1, edge2));
    end;
    function RotateNormalToView(const Normal: TDXViewerVec3): TDXViewerVec3;
    begin
        Result := RotateX(Normal, -90.0);
        Result := RotateY(Result, yawValue);
        Result := RotateX(Result, pitchValue);
        Result := NormalizeVec3(Result);
    end;
    procedure SetEnvironmentTexCoord(const Position: TDXMeshPoint; const Normal: TDXViewerVec3);
    var
        viewPosition: TDXViewerVec3;
        viewNormal: TDXViewerVec3;
        eyeToPoint: TDXViewerVec3;
        reflected: TDXViewerVec3;
        dotValue: Single;
        texU: Single;
        texV: Single;
    begin
        viewPosition := MakeVec3(
            Position.X - centerXValue,
            Position.Y - centerYValue,
            Position.Z - centerZValue
        );
        viewPosition.X := viewPosition.X * scaleValue;
        viewPosition.Y := viewPosition.Y * scaleValue;
        viewPosition.Z := viewPosition.Z * scaleValue;
        viewPosition := RotateX(viewPosition, -90.0);
        viewPosition := RotateY(viewPosition, yawValue);
        viewPosition := RotateX(viewPosition, pitchValue);
        viewPosition.X := viewPosition.X + panXValue;
        viewPosition.Y := viewPosition.Y + panYValue;
        viewPosition.Z := viewPosition.Z - distanceValue;
        eyeToPoint := NormalizeVec3(viewPosition);
        viewNormal := RotateNormalToView(Normal);
        dotValue := (eyeToPoint.X * viewNormal.X) + (eyeToPoint.Y * viewNormal.Y) + (eyeToPoint.Z * viewNormal.Z);
        reflected.X := eyeToPoint.X - (2.0 * dotValue * viewNormal.X);
        reflected.Y := eyeToPoint.Y - (2.0 * dotValue * viewNormal.Y);
        reflected.Z := eyeToPoint.Z - (2.0 * dotValue * viewNormal.Z);
        reflected := NormalizeVec3(reflected);
        texU := (reflected.X + 1.0) * 0.5;
        texV := 1.0 - ((reflected.Y + 1.0) * 0.5);
        texU := EnsureRange(texU, 0.0, 1.0);
        texV := EnsureRange(texV, 0.0, 1.0);
        glTexCoord2f(texU, texV);
    end;
    function GetTriangleBaseColor(const Triangle: TDXMeshTriangle; const bTriangleTwoSided: Boolean): TColor;
    begin
        if (Triangle.PolyFlags and PF_Invisible) <> 0 then
        begin
            Result := colorsValue.SolidColorInvisible;
        end
        else if bTriangleTwoSided = True then
        begin
            Result := colorsValue.SolidColorTwoSided;
        end
        else
        begin
            Result := colorsValue.SolidColorNormal;
        end;
    end;
    function TriangleIsUnlit(const Triangle: TDXMeshTriangle): Boolean;
    begin
        Result := (Triangle.PolyFlags and PF_Unlit) <> 0;
    end;
    function TriangleIsTranslucent(const Triangle: TDXMeshTriangle): Boolean;
    begin
        Result := (Triangle.PolyFlags and PF_Translucent) <> 0;
    end;
    function TriangleIsModulated(const Triangle: TDXMeshTriangle): Boolean;
    begin
        Result := (Triangle.PolyFlags and PF_Modulated) <> 0;
    end;
    function TriangleHasEnvironment(const Triangle: TDXMeshTriangle): Boolean;
    begin
        Result := (Triangle.PolyFlags and PF_Environment) <> 0;
    end;
    function TriangleUsesSmoothNormals(const Triangle: TDXMeshTriangle): Boolean;
    begin
        Result := False;
        if bSmoothShadedValue = False then
        begin
            Exit;
        end;
        if (Triangle.PolyFlags and PF_Flat) <> 0 then
        begin
            Exit;
        end;
        Result := True;
    end;
    function GetNormalIntensity(const Normal: TDXViewerVec3): Single;
    var
        viewNormal: TDXViewerVec3;
        diffuseValue: Single;
    begin
        viewNormal := RotateNormalToView(Normal);
        diffuseValue := viewNormal.Z;
        if diffuseValue < 0.0 then
        begin
            diffuseValue := 0.0;
        end;
        Result := shadeAmbientValue + (shadeDiffuseValue * diffuseValue);
        Result := EnsureRange(Result, 0.0, 1.0);
    end;
    procedure SetFlatShadedColor(const BaseColor: TColor; const P0, P1, P2: TDXMeshPoint; const bUnlit: Boolean);
    var
        rgbColor: Cardinal;
        faceNormal: TDXViewerVec3;
        intensityValue: Single;
    begin
        if bUnlit = True then
        begin
            SetGLColor(BaseColor);
            Exit;
        end;
        rgbColor := ColorToRGB(BaseColor);
        faceNormal := CalculateFaceNormal(P0, P1, P2);
        intensityValue := GetNormalIntensity(faceNormal);
        glColor3f(
            (GetRValue(rgbColor) / 255.0) * intensityValue,
            (GetGValue(rgbColor) / 255.0) * intensityValue,
            (GetBValue(rgbColor) / 255.0) * intensityValue
        );
    end;
    procedure SetSmoothVertexColor(const BaseColor: TColor; const VertexNormal: TDXViewerVec3; const bUnlit: Boolean);
    var
        rgbColor: Cardinal;
        intensityValue: Single;
    begin
        if bUnlit = True then
        begin
            SetGLColor(BaseColor);
            Exit;
        end;
        rgbColor := ColorToRGB(BaseColor);
        intensityValue := GetNormalIntensity(VertexNormal);
        glColor3f(
            (GetRValue(rgbColor) / 255.0) * intensityValue,
            (GetGValue(rgbColor) / 255.0) * intensityValue,
            (GetBValue(rgbColor) / 255.0) * intensityValue
        );
    end;
    procedure BuildSmoothNormals();
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        faceNormal: TDXViewerVec3;
        vertexIndex: Integer;
    begin
        SetLength(vertexNormals, modelValue.VertexCountPerFrame);
        for vertexIndex := 0 to High(vertexNormals) do
        begin
            vertexNormals[vertexIndex] := MakeVec3(0.0, 0.0, 0.0);
        end;
        for triangleIndex := 0 to modelValue.TriangleCount - 1 do
        begin
            triangle := modelValue.Triangles[triangleIndex];
            pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
            pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
            pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
            faceNormal := CalculateFaceNormal(pt0, pt1, pt2);
            vertexNormals[triangle.iVertex[0]] := AddVec3(vertexNormals[triangle.iVertex[0]], faceNormal);
            vertexNormals[triangle.iVertex[1]] := AddVec3(vertexNormals[triangle.iVertex[1]], faceNormal);
            vertexNormals[triangle.iVertex[2]] := AddVec3(vertexNormals[triangle.iVertex[2]], faceNormal);
        end;
        for vertexIndex := 0 to High(vertexNormals) do
        begin
            vertexNormals[vertexIndex] := NormalizeVec3(vertexNormals[vertexIndex]);
        end;
    end;
    procedure DrawBasePass(const bOnlyTwoSided: Boolean);
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        bTriangleTwoSided: Boolean;
        bTriangleUnlit: Boolean;
        bUseSmoothNormals: Boolean;
        baseColor: TColor;
    begin
        glBegin(GL_TRIANGLES);
        try
            for triangleIndex := 0 to modelValue.TriangleCount - 1 do
            begin
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                begin
                    Continue;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                if bWireframeValue = True then
                begin
                    SetGLColor(colorsValue.WireframeModeColor);
                    glVertex3f(pt0.X, pt0.Y, pt0.Z);
                    glVertex3f(pt1.X, pt1.Y, pt1.Z);
                    glVertex3f(pt2.X, pt2.Y, pt2.Z);
                    Continue;
                end;
                baseColor := GetTriangleBaseColor(triangle, bTriangleTwoSided);
                bTriangleUnlit := TriangleIsUnlit(triangle);
                bUseSmoothNormals := TriangleUsesSmoothNormals(triangle);
                if bUseSmoothNormals = True then
                begin
                    SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[0]], bTriangleUnlit);
                    glVertex3f(pt0.X, pt0.Y, pt0.Z);
                    SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[1]], bTriangleUnlit);
                    glVertex3f(pt1.X, pt1.Y, pt1.Z);
                    SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[2]], bTriangleUnlit);
                    glVertex3f(pt2.X, pt2.Y, pt2.Z);
                end
                else
                begin
                    if (bShadedValue = True) or (bSmoothShadedValue = True) then
                    begin
                        SetFlatShadedColor(baseColor, pt0, pt1, pt2, bTriangleUnlit);
                    end
                    else
                    begin
                        SetGLColor(baseColor);
                    end;
                    glVertex3f(pt0.X, pt0.Y, pt0.Z);
                    glVertex3f(pt1.X, pt1.Y, pt1.Z);
                    glVertex3f(pt2.X, pt2.Y, pt2.Z);
                end;
            end;
        finally
            glEnd();
        end;
    end;
    type
        TTexturedPassKind = (
            tpkOpaque,
            tpkTranslucent,
            tpkModulated
        );
    procedure DrawTexturedPass(const bOnlyTwoSided: Boolean; const PassKind: TTexturedPassKind);
    const
        MeshSkinPageSize = 256.0;
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        bTriangleTwoSided: Boolean;
        bTriangleUnlit: Boolean;
        bUseSmoothNormals: Boolean;
        bHasTexture: Boolean;
        bHasEnvironment: Boolean;
        baseColor: TColor;
        texU: Single;
        texV: Single;
        bTriangleTranslucent: Boolean;
        bTriangleModulated: Boolean;
        faceNormal: TDXViewerVec3;
    begin
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        try
            for triangleIndex := 0 to modelValue.TriangleCount - 1 do
            begin
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                begin
                    Continue;
                end;
                bTriangleTranslucent := TriangleIsTranslucent(triangle);
                bTriangleModulated := TriangleIsModulated(triangle);
                bHasEnvironment := TriangleHasEnvironment(triangle);
                case PassKind of
                    tpkOpaque:
                        begin
                            if (bTriangleTranslucent = True) or (bTriangleModulated = True) then
                            begin
                                Continue;
                            end;
                        end;
                    tpkTranslucent:
                        begin
                            if bTriangleTranslucent = False then
                            begin
                                Continue;
                            end;
                        end;
                    tpkModulated:
                        begin
                            if bTriangleModulated = False then
                            begin
                                Continue;
                            end;
                        end;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                baseColor := GetTriangleBaseColor(triangle, bTriangleTwoSided);
                bTriangleUnlit := TriangleIsUnlit(triangle);
                bUseSmoothNormals := TriangleUsesSmoothNormals(triangle);
                if bHasEnvironment = True then
                begin
                    bHasTexture := TryLoadEnvironmentTextureBitmap();
                end
                else
                begin
                    bHasTexture := TryLoadTextureBitmap(triangle.TextureIndex);
                end;
                if bHasTexture = True then
                begin
                    glEnable(GL_TEXTURE_2D);
                    if bHasEnvironment = True then
                    begin
                        glBindTexture(GL_TEXTURE_2D, envMapTextureValue.textureId);
                    end
                    else
                    begin
                        glBindTexture(GL_TEXTURE_2D, loadedTexturesValue[triangle.TextureIndex].textureId);
                    end;
                end
                else
                begin
                    glBindTexture(GL_TEXTURE_2D, 0);
                    glDisable(GL_TEXTURE_2D);
                end;
                if bUseSmoothNormals = False then
                begin
                    faceNormal := CalculateFaceNormal(pt0, pt1, pt2);
                end
                else
                begin
                    faceNormal := MakeVec3(0.0, 0.0, 1.0);
                end;
                glBegin(GL_TRIANGLES);
                try
                    if bUseSmoothNormals = False then
                    begin
                        SetFlatShadedColor(baseColor, pt0, pt1, pt2, bTriangleUnlit);
                    end;
                    if bHasTexture = True then
                    begin
                        if bHasEnvironment = True then
                        begin
                            if bUseSmoothNormals = True then
                            begin
                                SetEnvironmentTexCoord(pt0, vertexNormals[triangle.iVertex[0]]);
                            end
                            else
                            begin
                                SetEnvironmentTexCoord(pt0, faceNormal);
                            end;
                        end
                        else
                        begin
                            texU := triangle.Tex[0].U / MeshSkinPageSize;
                            texV := 1.0 - (triangle.Tex[0].V / MeshSkinPageSize);
                            glTexCoord2f(texU, texV);
                        end;
                    end;
                    if bUseSmoothNormals = True then
                    begin
                        SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[0]], bTriangleUnlit);
                    end;
                    glVertex3f(pt0.X, pt0.Y, pt0.Z);
                    if bHasTexture = True then
                    begin
                        if bHasEnvironment = True then
                        begin
                            if bUseSmoothNormals = True then
                            begin
                                SetEnvironmentTexCoord(pt1, vertexNormals[triangle.iVertex[1]]);
                            end
                            else
                            begin
                                SetEnvironmentTexCoord(pt1, faceNormal);
                            end;
                        end
                        else
                        begin
                            texU := triangle.Tex[1].U / MeshSkinPageSize;
                            texV := 1.0 - (triangle.Tex[1].V / MeshSkinPageSize);
                            glTexCoord2f(texU, texV);
                        end;
                    end;
                    if bUseSmoothNormals = True then
                    begin
                        SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[1]], bTriangleUnlit);
                    end;
                    glVertex3f(pt1.X, pt1.Y, pt1.Z);
                    if bHasTexture = True then
                    begin
                        if bHasEnvironment = True then
                        begin
                            if bUseSmoothNormals = True then
                            begin
                                SetEnvironmentTexCoord(pt2, vertexNormals[triangle.iVertex[2]]);
                            end
                            else
                            begin
                                SetEnvironmentTexCoord(pt2, faceNormal);
                            end;
                        end
                        else
                        begin
                            texU := triangle.Tex[2].U / MeshSkinPageSize;
                            texV := 1.0 - (triangle.Tex[2].V / MeshSkinPageSize);
                            glTexCoord2f(texU, texV);
                        end;
                    end;
                    if bUseSmoothNormals = True then
                    begin
                        SetSmoothVertexColor(baseColor, vertexNormals[triangle.iVertex[2]], bTriangleUnlit);
                    end;
                    glVertex3f(pt2.X, pt2.Y, pt2.Z);
                finally
                    glEnd();
                end;
            end;
        finally
            glBindTexture(GL_TEXTURE_2D, 0);
            glDisable(GL_TEXTURE_2D);
        end;
    end;
    procedure DrawWireOverlayPass(const bOnlyTwoSided: Boolean);
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        bTriangleTwoSided: Boolean;
    begin
        glBegin(GL_TRIANGLES);
        try
            for triangleIndex := 0 to modelValue.TriangleCount - 1 do
            begin
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                begin
                    Continue;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                glVertex3f(pt0.X, pt0.Y, pt0.Z);
                glVertex3f(pt1.X, pt1.Y, pt1.Z);
                glVertex3f(pt2.X, pt2.Y, pt2.Z);
            end;
        finally
            glEnd();
        end;
    end;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.TriangleCount <= 0 then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    frameIndex := GetSafeFrame();
    bTexturedMode := displayModeValue = mdTextured;
    if bSmoothShadedValue = True then
    begin
        BuildSmoothNormals();
    end
    else
    begin
        SetLength(vertexNormals, 0);
    end;
    if bWireframeValue = True then
    begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    end
    else
    begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    end;
    if bWireframeValue = True then
    begin
        glShadeModel(GL_SMOOTH);
    end
    else if bTexturedMode = True then
    begin
        glShadeModel(GL_SMOOTH);
    end
    else if bShadedValue = True then
    begin
        glShadeModel(GL_FLAT);
    end
    else if bSmoothShadedValue = True then
    begin
        glShadeModel(GL_SMOOTH);
    end
    else
    begin
        glShadeModel(GL_SMOOTH);
    end;
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDepthMask(GL_TRUE);
    ConfigureBackFaceCulling(bCullBackFacesValue);
    if bTexturedMode = True then
    begin
        DrawTexturedPass(False, tpkOpaque);
    end
    else
    begin
        DrawBasePass(False);
    end;
    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
    begin
        ConfigureBackFaceCulling(False);
        if bTexturedMode = True then
        begin
            DrawTexturedPass(True, tpkOpaque);
        end
        else
        begin
            DrawBasePass(True);
        end;
    end;
    if bTexturedMode = True then
    begin
        glEnable(GL_BLEND);
        glDepthMask(GL_FALSE);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
        ConfigureBackFaceCulling(bCullBackFacesValue);
        DrawTexturedPass(False, tpkTranslucent);
        if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
        begin
            ConfigureBackFaceCulling(False);
            DrawTexturedPass(True, tpkTranslucent);
        end;
        glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
        ConfigureBackFaceCulling(bCullBackFacesValue);
        DrawTexturedPass(False, tpkModulated);
        if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
        begin
            ConfigureBackFaceCulling(False);
            DrawTexturedPass(True, tpkModulated);
        end;
        glDisable(GL_BLEND);
        glDepthMask(GL_TRUE);
    end;
    if (bWireframeValue = False) and (bShadedValue = False) and (bSmoothShadedValue = False) then
    begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glDisable(GL_DEPTH_TEST);
        SetGLColor(colorsValue.WireframeColor);
        ConfigureBackFaceCulling(bCullBackFacesValue);
        DrawWireOverlayPass(False);
        if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
        begin
            ConfigureBackFaceCulling(False);
            DrawWireOverlayPass(True);
        end;
        glEnable(GL_DEPTH_TEST);
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    end;
    glDisable(GL_TEXTURE_2D);
    glShadeModel(GL_SMOOTH);
    ConfigureBackFaceCulling(False);
    DrawBoundingSphere();
    DrawBoundingBox();
    DrawSelectedTriangles();
end;

procedure TDXMeshViewer.DrawModelForPicking();
var
    frameIndex: Integer;
    procedure DrawPickingPass(const bOnlyTwoSided: Boolean);
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        colorValue: Cardinal;
        redValue: Byte;
        greenValue: Byte;
        blueValue: Byte;
        bTriangleTwoSided: Boolean;
    begin
        glBegin(GL_TRIANGLES);
        try
            for triangleIndex := 0 to modelValue.TriangleCount - 1 do
            begin
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else
                begin
                    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                    begin
                        Continue;
                    end;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                colorValue := EncodeTriangleIndexToColor(triangleIndex);
                redValue := Byte(colorValue and $FF);
                greenValue := Byte((colorValue shr 8) and $FF);
                blueValue := Byte((colorValue shr 16) and $FF);
                glColor3ub(redValue, greenValue, blueValue);
                glVertex3f(pt0.X, pt0.Y, pt0.Z);
                glVertex3f(pt1.X, pt1.Y, pt1.Z);
                glVertex3f(pt2.X, pt2.Y, pt2.Z);
            end;
        finally
            glEnd();
        end;
    end;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.TriangleCount <= 0 then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    frameIndex := GetSafeFrame();
    glDisable(GL_DITHER);
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    ConfigureBackFaceCulling(bCullBackFacesValue);
    DrawPickingPass(False);
    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
    begin
        ConfigureBackFaceCulling(False);
        DrawPickingPass(True);
    end;
    ConfigureBackFaceCulling(False);
    glEnable(GL_DITHER);
end;

procedure TDXMeshViewer.DrawSelectedTriangles();
var
    frameIndex: Integer;
    procedure DrawSelectionFillPass(const bOnlyTwoSided: Boolean);
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        bTriangleTwoSided: Boolean;
    begin
        glBegin(GL_TRIANGLES);
        try
            for triangleIndex := 0 to High(selectedTrianglesValue) do
            begin
                if selectedTrianglesValue[triangleIndex] = False then
                begin
                    Continue;
                end;
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else
                begin
                    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                    begin
                        Continue;
                    end;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                if triangleIndex = selectedTriangleIndexValue then
                begin
                    SetGLColor(colorsValue.ActiveSelectedFillColor);
                end
                else
                begin
                    SetGLColor(colorsValue.SelectedFillColor);
                end;
                glVertex3f(pt0.X, pt0.Y, pt0.Z);
                glVertex3f(pt1.X, pt1.Y, pt1.Z);
                glVertex3f(pt2.X, pt2.Y, pt2.Z);
            end;
        finally
            glEnd();
        end;
    end;
    procedure DrawSelectionLinePass(const bOnlyTwoSided: Boolean);
    var
        triangleIndex: Integer;
        triangle: TDXMeshTriangle;
        pt0: TDXMeshPoint;
        pt1: TDXMeshPoint;
        pt2: TDXMeshPoint;
        bTriangleTwoSided: Boolean;
    begin
        glBegin(GL_TRIANGLES);
        try
            for triangleIndex := 0 to High(selectedTrianglesValue) do
            begin
                if selectedTrianglesValue[triangleIndex] = False then
                begin
                    Continue;
                end;
                triangle := modelValue.Triangles[triangleIndex];
                bTriangleTwoSided := TriangleIsTwoSided(triangle);
                if bOnlyTwoSided = True then
                begin
                    if bTriangleTwoSided = False then
                    begin
                        Continue;
                    end;
                end
                else
                begin
                    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) and (bTriangleTwoSided = True) then
                    begin
                        Continue;
                    end;
                end;
                pt0 := modelValue.Vertices[frameIndex, triangle.iVertex[0]];
                pt1 := modelValue.Vertices[frameIndex, triangle.iVertex[1]];
                pt2 := modelValue.Vertices[frameIndex, triangle.iVertex[2]];
                if triangleIndex = selectedTriangleIndexValue then
                begin
                    SetGLColor(colorsValue.ActiveSelectedLineColor);
                end
                else
                begin
                    SetGLColor(colorsValue.SelectedLineColor);
                end;
                glVertex3f(pt0.X, pt0.Y, pt0.Z);
                glVertex3f(pt1.X, pt1.Y, pt1.Z);
                glVertex3f(pt2.X, pt2.Y, pt2.Z);
            end;
        finally
            glEnd();
        end;
    end;
begin
    if selectedCountValue <= 0 then
    begin
        Exit;
    end;
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    frameIndex := GetSafeFrame();
    if bWireframeValue = False then
    begin
        glEnable(GL_POLYGON_OFFSET_FILL);
        glPolygonOffset(-1.0, -1.0);
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        ConfigureBackFaceCulling(bCullBackFacesValue);
        DrawSelectionFillPass(False);
        if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
        begin
            ConfigureBackFaceCulling(False);
            DrawSelectionFillPass(True);
        end;
        glDisable(GL_POLYGON_OFFSET_FILL);
    end;
    glDisable(GL_DEPTH_TEST);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glLineWidth(3.0);
    ConfigureBackFaceCulling(bCullBackFacesValue);
    DrawSelectionLinePass(False);
    if (bCullBackFacesValue = True) and (bRespectTwoSidedValue = True) then
    begin
        ConfigureBackFaceCulling(False);
        DrawSelectionLinePass(True);
    end;
    glLineWidth(1.0);
    glEnable(GL_DEPTH_TEST);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    ConfigureBackFaceCulling(False);
end;

function TDXMeshViewer.GetDecodedVertexScale(): Single;
begin
    Result := 1.0;
end;

function TDXMeshViewer.GetArtistSpaceScale(): Single;
begin
    Result := 1.0 / 256.0;
end;

function TDXMeshViewer.BuildCurrentFrameBounds(out Bounds: TDXMeshBounds): Boolean;
var
    frameIndex: Integer;
    vertexIndex: Integer;
    pointValue: TDXMeshPoint;
    bFirst: Boolean;
begin
    Result := False;
    FillChar(Bounds, SizeOf(Bounds), 0);
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    if modelValue.VertexCountPerFrame <= 0 then
    begin
        Exit;
    end;
    frameIndex := GetSafeFrame();
    bFirst := True;
    for vertexIndex := 0 to modelValue.VertexCountPerFrame - 1 do
    begin
        pointValue := modelValue.Vertices[frameIndex, vertexIndex];
        if bFirst = True then
        begin
            Bounds.MinX := pointValue.X;
            Bounds.MinY := pointValue.Y;
            Bounds.MinZ := pointValue.Z;
            Bounds.MaxX := pointValue.X;
            Bounds.MaxY := pointValue.Y;
            Bounds.MaxZ := pointValue.Z;
            bFirst := False;
        end
        else
        begin
            Bounds.MinX := Min(Bounds.MinX, pointValue.X);
            Bounds.MinY := Min(Bounds.MinY, pointValue.Y);
            Bounds.MinZ := Min(Bounds.MinZ, pointValue.Z);
            Bounds.MaxX := Max(Bounds.MaxX, pointValue.X);
            Bounds.MaxY := Max(Bounds.MaxY, pointValue.Y);
            Bounds.MaxZ := Max(Bounds.MaxZ, pointValue.Z);
        end;
    end;
    Bounds.bValid := bFirst = False;
    Result := Bounds.bValid;
end;

function TDXMeshViewer.GetActiveBoundingBoxRawBounds(out Bounds: TDXMeshBounds): Boolean;
begin
    Result := False;
    FillChar(Bounds, SizeOf(Bounds), 0);
    if modelValue = nil then
    begin
        Exit;
    end;
    case boundingBoxFrameModeValue of
        bbfmCurrentFrame:
            Result := BuildCurrentFrameBounds(Bounds);
        bbfmAllFrames:
            begin
                Bounds := modelValue.AllFramesBounds;
                Result := Bounds.bValid;
            end;
    else
        begin
            Bounds := modelValue.AllFramesBounds;
            Result := Bounds.bValid;
        end;
    end;
end;

function TDXMeshViewer.GetMaxDecodedDistanceForCurrentFrame(FrameIndex: Integer): Single;
var
    vertexIndex: Integer;
    pointValue: TDXMeshPoint;
    distanceSquared: Double;
    maxDistanceSquared: Double;
    decodedScale: Double;
begin
    Result := 0.0;
    if modelValue = nil then
    begin
        Exit;
    end;
    if (bMaxDecodedDistanceCurrentFrameReadyValue = True) and
        (cachedMaxDecodedDistanceFrameIndexValue = FrameIndex) then
    begin
        Result := maxDecodedDistanceCurrentFrameValue;
        Exit;
    end;
    decodedScale := GetDecodedVertexScale();
    maxDistanceSquared := 0.0;
    for vertexIndex := 0 to modelValue.VertexCountPerFrame - 1 do
    begin
        pointValue := modelValue.Vertices[FrameIndex, vertexIndex];
        distanceSquared :=
            Sqr(pointValue.X * decodedScale) +
            Sqr(pointValue.Y * decodedScale) +
            Sqr(pointValue.Z * decodedScale);
        if distanceSquared > maxDistanceSquared then
        begin
            maxDistanceSquared := distanceSquared;
        end;
    end;
    maxDecodedDistanceCurrentFrameValue := Sqrt(maxDistanceSquared);
    cachedMaxDecodedDistanceFrameIndexValue := FrameIndex;
    bMaxDecodedDistanceCurrentFrameReadyValue := True;
    Result := maxDecodedDistanceCurrentFrameValue;
end;

function TDXMeshViewer.GetMaxDecodedDistanceForAllFrames(): Single;
var
    frameIndex: Integer;
    vertexIndex: Integer;
    pointValue: TDXMeshPoint;
    distanceSquared: Double;
    maxDistanceSquared: Double;
    decodedScale: Double;
begin
    Result := 0.0;
    if modelValue = nil then
    begin
        Exit;
    end;
    if bMaxDecodedDistanceAllFramesReadyValue = True then
    begin
        Result := maxDecodedDistanceAllFramesValue;
        Exit;
    end;
    decodedScale := GetDecodedVertexScale();
    maxDistanceSquared := 0.0;
    for frameIndex := 0 to modelValue.FrameCount - 1 do
    begin
        for vertexIndex := 0 to modelValue.VertexCountPerFrame - 1 do
        begin
            pointValue := modelValue.Vertices[frameIndex, vertexIndex];
            distanceSquared :=
                Sqr(pointValue.X * decodedScale) +
                Sqr(pointValue.Y * decodedScale) +
                Sqr(pointValue.Z * decodedScale);
            if distanceSquared > maxDistanceSquared then
            begin
                maxDistanceSquared := distanceSquared;
            end;
        end;
    end;
    maxDecodedDistanceAllFramesValue := Sqrt(maxDistanceSquared);
    bMaxDecodedDistanceAllFramesReadyValue := True;
    Result := maxDecodedDistanceAllFramesValue;
end;

function TDXMeshViewer.GetActiveMaxDecodedDistance(): Single;
var
    frameIndex: Integer;
begin
    Result := 0.0;
    if modelValue = nil then
    begin
        Exit;
    end;
    case boundingBoxFrameModeValue of
        bbfmCurrentFrame:
            begin
                frameIndex := GetSafeFrame();
                Result := GetMaxDecodedDistanceForCurrentFrame(frameIndex);
            end;
        bbfmAllFrames:
            begin
                Result := GetMaxDecodedDistanceForAllFrames();
            end;
    else
        begin
            Result := GetMaxDecodedDistanceForAllFrames();
        end;
    end;
end;

function TDXMeshViewer.GetActiveBoundingSphereRadiusRaw(): Single;
var
    decodedRadius: Single;
    decodedScale: Single;
begin
    decodedRadius := GetActiveMaxDecodedDistance();
    decodedScale := GetDecodedVertexScale();
    if Abs(decodedScale) < 0.000001 then
    begin
        Result := decodedRadius;
    end
    else
    begin
        Result := decodedRadius / decodedScale;
    end;
end;

procedure TDXMeshViewer.DrawBoundingSphere();
const
    SphereSegments = 64;
var
    rawRadius: Single;
    angleStep: Double;
    angleValue: Double;
    i: Integer;
begin
    if bShowBoundingSphereValue = False then
    begin
        Exit;
    end;
    if modelValue = nil then
    begin
        Exit;
    end;
    rawRadius := GetActiveBoundingSphereRadiusRaw();
    if rawRadius <= 0.0 then
    begin
        Exit;
    end;
    angleStep := (2.0 * Pi) / SphereSegments;
    glDisable(GL_DEPTH_TEST);
    glLineWidth(1.2);
    SetGLColor(colorsValue.BoundingSphereColor);
    glBegin(GL_LINE_LOOP);
    try
        for i := 0 to SphereSegments - 1 do
        begin
            angleValue := i * angleStep;
            glVertex3f(Cos(angleValue) * rawRadius, Sin(angleValue) * rawRadius, 0.0);
        end;
    finally
        glEnd();
    end;
    glBegin(GL_LINE_LOOP);
    try
        for i := 0 to SphereSegments - 1 do
        begin
            angleValue := i * angleStep;
            glVertex3f(Cos(angleValue) * rawRadius, 0.0, Sin(angleValue) * rawRadius);
        end;
    finally
        glEnd();
    end;
    glBegin(GL_LINE_LOOP);
    try
        for i := 0 to SphereSegments - 1 do
        begin
            angleValue := i * angleStep;
            glVertex3f(0.0, Cos(angleValue) * rawRadius, Sin(angleValue) * rawRadius);
        end;
    finally
        glEnd();
    end;
    glLineWidth(1.0);
    glEnable(GL_DEPTH_TEST);
end;

procedure TDXMeshViewer.DrawBoundingBox();
var
    rawBounds: TDXMeshBounds;
    minX: Single;
    minY: Single;
    minZ: Single;
    maxX: Single;
    maxY: Single;
    maxZ: Single;
    rawSizeX: Single;
    rawSizeY: Single;
    rawSizeZ: Single;
    decodedSizeX: Single;
    decodedSizeY: Single;
    decodedSizeZ: Single;
    artistMinX: Single;
    artistMinY: Single;
    artistMinZ: Single;
    artistMaxX: Single;
    artistMaxY: Single;
    artistMaxZ: Single;
    artistSizeX: Single;
    artistSizeY: Single;
    artistSizeZ: Single;
    maxAbsArtistX: Single;
    maxAbsArtistY: Single;
    maxAbsArtistZ: Single;
    exceededVertexCount: Integer;
    originMarkerSize: Single;
    frameIndex: Integer;
    vertexIndex: Integer;
    pointValue: TDXMeshPoint;
    artistX: Single;
    artistY: Single;
    artistZ: Single;
    decodedScale: Single;
    artistScale: Single;
    vertices: array[0..7] of TDXMeshPoint;
    i: Integer;
    screenX: Double;
    screenY: Double;
    labelText: string;
    labelPosX: Integer;
    labelPosY: Integer;
    infoLines: TStringList;
    lineIndex: Integer;
    maxDecodedDistance: Single;
    boundingSphereRadius: Single;
    modeText: string;
    warningText: string;
    originPoint: TDXMeshPoint;
    procedure DrawText2D(const X, Y: Integer; const AText: string);
    begin
        if (bAxisFontReadyValue = False) or (axisFontBaseValue = 0) then
        begin
            Exit;
        end;
        glRasterPos2i(X, Y);
        glCallLists(Length(AText), GL_UNSIGNED_BYTE, PAnsiChar(AnsiString(AText)));
    end;
    function FormatDecodedValue(const AValue: Single): string;
    begin
        Result := FormatFloat('0.##', AValue);
    end;
    function BuildVertexLabelText(const PointValue: TDXMeshPoint): string;
    begin
        Result := Format('(%d, %d, %d)', [PointValue.X, PointValue.Y, PointValue.Z]);
    end;
begin
    if (bShowBoundingBoxValue = False) and
       (bShowBoundingBoxVertexLabelsValue = False) and
       (bShowDecodedBoundingBoxInfoValue = False) and
       (bShowRawBoundingBoxInfoValue = False) and
       (bShowArtistSpaceDebugValue = False) and
       (bShowMeshWarningsValue = False) then
    begin
        Exit;
    end;
    if modelValue = nil then
    begin
        Exit;
    end;
    if GetActiveBoundingBoxRawBounds(rawBounds) = False then
    begin
        Exit;
    end;
    decodedScale := GetDecodedVertexScale();
    artistScale := GetArtistSpaceScale();
    minX := rawBounds.MinX;
    minY := rawBounds.MinY;
    minZ := rawBounds.MinZ;
    maxX := rawBounds.MaxX;
    maxY := rawBounds.MaxY;
    maxZ := rawBounds.MaxZ;
    rawSizeX := maxX - minX;
    rawSizeY := maxY - minY;
    rawSizeZ := maxZ - minZ;
    decodedSizeX := rawSizeX * decodedScale;
    decodedSizeY := rawSizeY * decodedScale;
    decodedSizeZ := rawSizeZ * decodedScale;
    artistMinX := minX * artistScale;
    artistMinY := minY * artistScale;
    artistMinZ := minZ * artistScale;
    artistMaxX := maxX * artistScale;
    artistMaxY := maxY * artistScale;
    artistMaxZ := maxZ * artistScale;
    artistSizeX := rawSizeX * artistScale;
    artistSizeY := rawSizeY * artistScale;
    artistSizeZ := rawSizeZ * artistScale;
    maxAbsArtistX := Max(Abs(artistMinX), Abs(artistMaxX));
    maxAbsArtistY := Max(Abs(artistMinY), Abs(artistMaxY));
    maxAbsArtistZ := Max(Abs(artistMinZ), Abs(artistMaxZ));
    boundingSphereRadius := GetActiveMaxDecodedDistance();
    warningText := '';
    exceededVertexCount := 0;
    originMarkerSize := Max(rawSizeX, Max(rawSizeY, rawSizeZ)) * 0.03;
    originMarkerSize := EnsureRange(originMarkerSize, 32.0, 768.0);
    vertices[0].X := Round(minX); vertices[0].Y := Round(minY); vertices[0].Z := Round(minZ);
    vertices[1].X := Round(maxX); vertices[1].Y := Round(minY); vertices[1].Z := Round(minZ);
    vertices[2].X := Round(minX); vertices[2].Y := Round(maxY); vertices[2].Z := Round(minZ);
    vertices[3].X := Round(maxX); vertices[3].Y := Round(maxY); vertices[3].Z := Round(minZ);
    vertices[4].X := Round(minX); vertices[4].Y := Round(minY); vertices[4].Z := Round(maxZ);
    vertices[5].X := Round(maxX); vertices[5].Y := Round(minY); vertices[5].Z := Round(maxZ);
    vertices[6].X := Round(minX); vertices[6].Y := Round(maxY); vertices[6].Z := Round(maxZ);
    vertices[7].X := Round(maxX); vertices[7].Y := Round(maxY); vertices[7].Z := Round(maxZ);
    glDisable(GL_DEPTH_TEST);
    if bShowBoundingBoxValue = True then
    begin
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glLineWidth(1.5);
        SetGLColor(colorsValue.BoundingBoxColor);
        glBegin(GL_LINES);
        try
            glVertex3f(minX, minY, minZ); glVertex3f(maxX, minY, minZ);
            glVertex3f(minX, maxY, minZ); glVertex3f(maxX, maxY, minZ);
            glVertex3f(minX, minY, maxZ); glVertex3f(maxX, minY, maxZ);
            glVertex3f(minX, maxY, maxZ); glVertex3f(maxX, maxY, maxZ);
            glVertex3f(minX, minY, minZ); glVertex3f(minX, maxY, minZ);
            glVertex3f(maxX, minY, minZ); glVertex3f(maxX, maxY, minZ);
            glVertex3f(minX, minY, maxZ); glVertex3f(minX, maxY, maxZ);
            glVertex3f(maxX, minY, maxZ); glVertex3f(maxX, maxY, maxZ);
            glVertex3f(minX, minY, minZ); glVertex3f(minX, minY, maxZ);
            glVertex3f(maxX, minY, minZ); glVertex3f(maxX, minY, maxZ);
            glVertex3f(minX, maxY, minZ); glVertex3f(minX, maxY, maxZ);
            glVertex3f(maxX, maxY, minZ); glVertex3f(maxX, maxY, maxZ);
        finally
            glEnd();
        end;
        glPointSize(5.0);
        SetGLColor(colorsValue.BoundingBoxColor);
        glBegin(GL_POINTS);
        try
            for i := 0 to High(vertices) do
            begin
                glVertex3f(vertices[i].X, vertices[i].Y, vertices[i].Z);
            end;
        finally
            glEnd();
            glPointSize(1.0);
            glLineWidth(1.0);
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        end;
    end;
    if bShowArtistSpaceDebugValue = True then
    begin
        glLineWidth(2.0);
        SetGLColor(colorsValue.OriginMarkerColor);
        glBegin(GL_LINES);
        try
            glVertex3f(-originMarkerSize, 0.0, 0.0); glVertex3f(originMarkerSize, 0.0, 0.0);
            glVertex3f(0.0, -originMarkerSize, 0.0); glVertex3f(0.0, originMarkerSize, 0.0);
            glVertex3f(0.0, 0.0, -originMarkerSize); glVertex3f(0.0, 0.0, originMarkerSize);
        finally
            glEnd();
            glLineWidth(1.0);
        end;
        glPointSize(6.0);
        SetGLColor(colorsValue.ExceededVertexColor);
        glBegin(GL_POINTS);
        try
            case boundingBoxFrameModeValue of
                bbfmCurrentFrame:
                    begin
                        frameIndex := GetSafeFrame();
                        for vertexIndex := 0 to modelValue.VertexCountPerFrame - 1 do
                        begin
                            pointValue := modelValue.Vertices[frameIndex, vertexIndex];
                            artistX := pointValue.X * artistScale;
                            artistY := pointValue.Y * artistScale;
                            artistZ := pointValue.Z * artistScale;
                            if (Abs(artistX) > 128.0) or (Abs(artistY) > 128.0) or (Abs(artistZ) > 128.0) then
                            begin
                                glVertex3f(pointValue.X, pointValue.Y, pointValue.Z);
                                Inc(exceededVertexCount);
                            end;
                        end;
                    end;
                bbfmAllFrames:
                    begin
                        for frameIndex := 0 to modelValue.FrameCount - 1 do
                        begin
                            for vertexIndex := 0 to modelValue.VertexCountPerFrame - 1 do
                            begin
                                pointValue := modelValue.Vertices[frameIndex, vertexIndex];
                                artistX := pointValue.X * artistScale;
                                artistY := pointValue.Y * artistScale;
                                artistZ := pointValue.Z * artistScale;
                                if (Abs(artistX) > 128.0) or (Abs(artistY) > 128.0) or (Abs(artistZ) > 128.0) then
                                begin
                                    glVertex3f(pointValue.X, pointValue.Y, pointValue.Z);
                                    Inc(exceededVertexCount);
                                end;
                            end;
                        end;
                    end;
            else
                begin
                end;
            end;
        finally
            glEnd();
            glPointSize(1.0);
        end;
    end;
    if (bAxisFontReadyValue = True) and (axisFontBaseValue <> 0) then
    begin
        infoLines := TStringList.Create();
        try
            if boundingBoxFrameModeValue = bbfmCurrentFrame then
            begin
                modeText := 'Current frame';
            end
            else
            begin
                modeText := 'All frames';
            end;
            if bShowDecodedBoundingBoxInfoValue = True then
            begin
                infoLines.Add(
                    Format(
                        'Compiler BBox [%s]: (%.0f, %.0f, %.0f) - (%.0f, %.0f, %.0f)',
                        [modeText, minX, minY, minZ, maxX, maxY, maxZ]
                    )
                );
                infoLines.Add(
                    Format(
                        'Compiler BoundingSphere [%s]: (0, 0, 0)  %s',
                        [
                            modeText,
                            FormatDecodedValue(boundingSphereRadius)
                        ]
                    )
                );
            end;
            if bShowRawBoundingBoxInfoValue = True then
            begin
                infoLines.Add(
                    Format(
                        'Compiler BBox Size [%s]: X=%.0f  Y=%.0f  Z=%.0f',
                        [modeText, rawSizeX, rawSizeY, rawSizeZ]
                    )
                );
            end;
            if bShowArtistSpaceDebugValue = True then
            begin
                infoLines.Add(
                    Format(
                        'Artist-space BBox [%s]: (%s, %s, %s) - (%s, %s, %s)',
                        [
                            modeText,
                            FormatDecodedValue(artistMinX),
                            FormatDecodedValue(artistMinY),
                            FormatDecodedValue(artistMinZ),
                            FormatDecodedValue(artistMaxX),
                            FormatDecodedValue(artistMaxY),
                            FormatDecodedValue(artistMaxZ)
                        ]
                    )
                );
                infoLines.Add(
                    Format(
                        'Artist-space BBox Size [%s]: X=%s  Y=%s  Z=%s',
                        [
                            modeText,
                            FormatDecodedValue(artistSizeX),
                            FormatDecodedValue(artistSizeY),
                            FormatDecodedValue(artistSizeZ)
                        ]
                    )
                );
                infoLines.Add(
                    Format(
                        'Artist-space limit: -128..128 (max abs: X=%s Y=%s Z=%s)',
                        [
                            FormatDecodedValue(maxAbsArtistX),
                            FormatDecodedValue(maxAbsArtistY),
                            FormatDecodedValue(maxAbsArtistZ)
                        ]
                    )
                );
            end;
            if bShowMeshWarningsValue = True then
            begin
                maxDecodedDistance := GetActiveMaxDecodedDistance();
                if bShowArtistSpaceDebugValue = True then
                begin
                    if (maxAbsArtistX > 128.0) or (maxAbsArtistY > 128.0) or (maxAbsArtistZ > 128.0) then
                    begin
                        warningText := Format(
                            'Artist-space warning: mesh exceeds -128..128 cube. Exceeded vertices: %d  MaxAbs X=%s Y=%s Z=%s',
                            [
                                exceededVertexCount,
                                FormatDecodedValue(maxAbsArtistX),
                                FormatDecodedValue(maxAbsArtistY),
                                FormatDecodedValue(maxAbsArtistZ)
                            ]
                        );
                    end;
                end;
            end;
            glMatrixMode(GL_PROJECTION);
            glPushMatrix();
            glLoadIdentity();
            glOrtho(0.0, ClientWidth, ClientHeight, 0.0, -1.0, 1.0);
            glMatrixMode(GL_MODELVIEW);
            glPushMatrix();
            glLoadIdentity();
            glDisable(GL_DEPTH_TEST);
            glListBase(axisFontBaseValue);
            SetGLColor(colorsValue.BoundingBoxLabelColor);
            if bShowBoundingBoxVertexLabelsValue = True then
            begin
                for i := 0 to High(vertices) do
                begin
                    if ProjectModelPointToScreen(vertices[i], screenX, screenY) = True then
                    begin
                        labelText := BuildVertexLabelText(vertices[i]);
                        if labelText <> '' then
                        begin
                            labelPosX := EnsureRange(Round(screenX) + 6, 0, Max(ClientWidth - 1, 0));
                            labelPosY := EnsureRange(Round(screenY) - 6, 0, Max(ClientHeight - 1, 0));
                            DrawText2D(labelPosX, labelPosY, labelText);
                        end;
                    end;
                end;
            end;
            if bShowArtistSpaceDebugValue = True then
            begin
                originPoint.X := 0;
                originPoint.Y := 0;
                originPoint.Z := 0;
                if ProjectModelPointToScreen(originPoint, screenX, screenY) = True then
                begin
                    SetGLColor(colorsValue.OriginLabelColor);
                    DrawText2D(
                        EnsureRange(Round(screenX) + 8, 0, Max(ClientWidth - 1, 0)),
                        EnsureRange(Round(screenY) + 8, 0, Max(ClientHeight - 1, 0)),
                        'Origin (0, 0, 0)'
                    );
                    SetGLColor(colorsValue.BoundingBoxLabelColor);
                end;
            end;
            for lineIndex := 0 to infoLines.Count - 1 do
            begin
                //DrawText2D(8, 18 + (lineIndex * (axisFontHeightValue + 2)), infoLines[lineIndex]);
                DrawText2D(8, 18 + (lineIndex * (axisFontHeightValue + 8)), infoLines[lineIndex]);
            end;
            if warningText <> '' then
            begin
                SetGLColor(colorsValue.WarningTextColor);
                DrawText2D(8, Max(ClientHeight - axisFontHeightValue - 8, 0), warningText);
                SetGLColor(colorsValue.BoundingBoxLabelColor);
            end;
            glPopMatrix();
            glMatrixMode(GL_PROJECTION);
            glPopMatrix();
            glMatrixMode(GL_MODELVIEW);
        finally
            infoLines.Free();
        end;
    end;
    glEnable(GL_DEPTH_TEST);
end;

procedure TDXMeshViewer.DrawAxisIndicator();
var
    oldViewport: array[0..3] of GLint;
    oldMatrixMode: GLint;
    axisViewportSize: Integer;
    axisMargin: Integer;
    nearPlane: Double;
    farPlane: Double;
    topValue: Double;
    rightValue: Double;
    axisLength: Single;
    labelOffset: Single;
    labelPosX: Double;
    labelPosY: Double;
    procedure RotateX(var X, Y, Z: Double; const AngleDeg: Double);
    var
        angleRad: Double;
        c: Double;
        s: Double;
        newY: Double;
        newZ: Double;
    begin
        angleRad := DegToRad(AngleDeg);
        c := Cos(angleRad);
        s := Sin(angleRad);
        newY := (Y * c) - (Z * s);
        newZ := (Y * s) + (Z * c);
        Y := newY;
        Z := newZ;
    end;
    procedure RotateY(var X, Y, Z: Double; const AngleDeg: Double);
    var
        angleRad: Double;
        c: Double;
        s: Double;
        newX: Double;
        newZ: Double;
    begin
        angleRad := DegToRad(AngleDeg);
        c := Cos(angleRad);
        s := Sin(angleRad);
        newX := (X * c) + (Z * s);
        newZ := (-X * s) + (Z * c);
        X := newX;
        Z := newZ;
    end;
    function ProjectAxisPoint(const PX, PY, PZ: Double; out SX, SY: Double): Boolean;
    var
        viewX: Double;
        viewY: Double;
        viewZ: Double;
        ndcX: Double;
        ndcY: Double;
    begin
        Result := False;
        viewX := PX;
        viewY := PY;
        viewZ := PZ;
        RotateX(viewX, viewY, viewZ, -90.0);
        RotateY(viewX, viewY, viewZ, yawValue);
        RotateX(viewX, viewY, viewZ, pitchValue);
        viewZ := viewZ - 3.2;
        if viewZ >= -nearPlane then
        begin
            Exit;
        end;
        ndcX := (viewX * nearPlane) / (rightValue * -viewZ);
        ndcY := (viewY * nearPlane) / (topValue * -viewZ);
        SX := axisMargin + ((ndcX + 1.0) * 0.5 * axisViewportSize);
        SY := axisMargin + ((ndcY + 1.0) * 0.5 * axisViewportSize);
        if SX < axisMargin + 2 then
        begin
            SX := axisMargin + 2;
        end;
        if SX > (axisMargin + axisViewportSize - 14) then
        begin
            SX := axisMargin + axisViewportSize - 14;
        end;
        if SY < axisMargin + 2 then
        begin
            SY := axisMargin + 2;
        end;
        if SY > (axisMargin + axisViewportSize - 14) then
        begin
            SY := axisMargin + axisViewportSize - 14;
        end;
        Result := True;
    end;
begin
    if bShowAxisIndicatorValue = False then
    begin
        Exit;
    end;
    if bOpenGLReadyValue = False then
    begin
        Exit;
    end;
    glGetIntegerv(GL_VIEWPORT, @oldViewport[0]);
    glGetIntegerv(GL_MATRIX_MODE, @oldMatrixMode);
    glPushAttrib(GL_ENABLE_BIT or GL_LINE_BIT or GL_POLYGON_BIT or GL_CURRENT_BIT or GL_VIEWPORT_BIT);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    try
        axisViewportSize := Min(ClientWidth, ClientHeight) div 5;
        if axisViewportSize < 72 then
        begin
            axisViewportSize := 72;
        end;
        if axisViewportSize > 160 then
        begin
            axisViewportSize := 160;
        end;
        axisMargin := 12;
        glViewport(
            axisMargin,
            axisMargin,
            axisViewportSize,
            axisViewportSize
        );
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        nearPlane := 0.1;
        farPlane := 10.0;
        topValue := BuildPerspectiveHalfSize(nearPlane, 35.0, 1.0);
        rightValue := topValue;
        glFrustum(-rightValue, rightValue, -topValue, topValue, nearPlane, farPlane);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glTranslatef(0.0, 0.0, -3.2);
        glRotatef(pitchValue, 1.0, 0.0, 0.0);
        glRotatef(yawValue, 0.0, 1.0, 0.0);
        glRotatef(-90.0, 1.0, 0.0, 0.0);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_TEXTURE_2D);
        glDisable(GL_BLEND);
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glLineWidth(2.0);
        axisLength := 1.0;
        labelOffset := 0.18;
        glBegin(GL_LINES);
        try
            SetGLColor(colorsValue.AxisXColor);
            glVertex3f(0.0, 0.0, 0.0);
            glVertex3f(axisLength, 0.0, 0.0);
            SetGLColor(colorsValue.AxisYColor);
            glVertex3f(0.0, 0.0, 0.0);
            glVertex3f(0.0, axisLength, 0.0);
            SetGLColor(colorsValue.AxisZColor);
            glVertex3f(0.0, 0.0, 0.0);
            glVertex3f(0.0, 0.0, axisLength);
        finally
            glEnd();
            glLineWidth(1.0);
        end;
        glViewport(oldViewport[0], oldViewport[1], oldViewport[2], oldViewport[3]);
        if (bAxisFontReadyValue = True) and (axisFontBaseValue <> 0) then
        begin
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glOrtho(0.0, ClientWidth, 0.0, ClientHeight, -1.0, 1.0);
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity();
            glDisable(GL_DEPTH_TEST);
            glListBase(axisFontBaseValue);
            if ProjectAxisPoint(axisLength + labelOffset, 0.0, 0.0, labelPosX, labelPosY) = True then
            begin
                SetGLColor(colorsValue.AxisLabelColor);
                glRasterPos2i(Round(labelPosX), Round(labelPosY));
                glCallLists(1, GL_UNSIGNED_BYTE, PAnsiChar(AnsiString('X')));
            end;
            if ProjectAxisPoint(0.0, axisLength + labelOffset, 0.0, labelPosX, labelPosY) = True then
            begin
                SetGLColor(colorsValue.AxisLabelColor);
                glRasterPos2i(Round(labelPosX), Round(labelPosY));
                glCallLists(1, GL_UNSIGNED_BYTE, PAnsiChar(AnsiString('Y')));
            end;
            if ProjectAxisPoint(0.0, 0.0, axisLength + labelOffset, labelPosX, labelPosY) = True then
            begin
                SetGLColor(colorsValue.AxisLabelColor);
                glRasterPos2i(Round(labelPosX), Round(labelPosY));
                glCallLists(1, GL_UNSIGNED_BYTE, PAnsiChar(AnsiString('Z')));
            end;
        end;
    finally
        glMatrixMode(GL_MODELVIEW);
        glPopMatrix();
        glMatrixMode(GL_PROJECTION);
        glPopMatrix();
        glMatrixMode(oldMatrixMode);
        glPopAttrib();
    end;
end;

procedure TDXMeshViewer.DrawSelectionRectangle();
var
    drawRect: TRect;
    leftValue: Integer;
    topValue: Integer;
    rightValue: Integer;
    bottomValue: Integer;
begin
    if bRectSelectActiveValue = False then
    begin
        Exit;
    end;
    leftValue := Min(rectSelectStartXValue, rectSelectCurrentXValue);
    topValue := Min(rectSelectStartYValue, rectSelectCurrentYValue);
    rightValue := Max(rectSelectStartXValue, rectSelectCurrentXValue);
    bottomValue := Max(rectSelectStartYValue, rectSelectCurrentYValue);
    if (Abs(rightValue - leftValue) <= 1) and (Abs(bottomValue - topValue) <= 1) then
    begin
        Exit;
    end;
    drawRect := Rect(leftValue, topValue, rightValue, bottomValue);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0.0, ClientWidth, ClientHeight, 0.0, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(
        GetRValue(ColorToRGB(colorsValue.SelectionRectFillColor)) / 255.0,
        GetGValue(ColorToRGB(colorsValue.SelectionRectFillColor)) / 255.0,
        GetBValue(ColorToRGB(colorsValue.SelectionRectFillColor)) / 255.0,
        0.18
    );
    glBegin(GL_QUADS);
    try
        glVertex2i(drawRect.Left, drawRect.Top);
        glVertex2i(drawRect.Right, drawRect.Top);
        glVertex2i(drawRect.Right, drawRect.Bottom);
        glVertex2i(drawRect.Left, drawRect.Bottom);
    finally
        glEnd();
    end;
    glDisable(GL_BLEND);
    SetGLColor(colorsValue.SelectionRectBorderColor);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glLineWidth(1.0);
    glBegin(GL_LINE_LOOP);
    try
        glVertex2i(drawRect.Left, drawRect.Top);
        glVertex2i(drawRect.Right, drawRect.Top);
        glVertex2i(drawRect.Right, drawRect.Bottom);
        glVertex2i(drawRect.Left, drawRect.Bottom);
    finally
        glEnd();
    end;
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_DEPTH_TEST);
    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
end;

procedure TDXMeshViewer.SelectTrianglesInRect(const SelectionRect: TRect; Shift: TShiftState);
begin
    case rectSelectionModeValue of
        rsmAnyVisiblePixel:
            SelectTrianglesInRectByVisiblePixels(SelectionRect, Shift);
        rsmTriangleCenter,
        rsmTwoVerticesInside,
        rsmAllVerticesInside:
            SelectTrianglesInRectByGeometry(SelectionRect, Shift);
    else
        SelectTrianglesInRectByVisiblePixels(SelectionRect, Shift);
    end;
end;

function TDXMeshViewer.GetRectSelectionMode(): TDXRectSelectionMode;
begin
    Result := rectSelectionModeValue;
end;

procedure TDXMeshViewer.SetRectSelectionMode(AValue: TDXRectSelectionMode);
begin
    if rectSelectionModeValue = AValue then
    begin
        Exit;
    end;
    rectSelectionModeValue := AValue;
end;

function TDXMeshViewer.ProjectModelPointToScreen(const PointValue: TDXMeshPoint; out ScreenX, ScreenY: Double): Boolean;
var
    aspectRatio: Double;
    nearPlane: Double;
    topValue: Double;
    rightValue: Double;
    viewX: Double;
    viewY: Double;
    viewZ: Double;
    ndcX: Double;
    ndcY: Double;
    rotatedX: Double;
    rotatedY: Double;
    rotatedZ: Double;
    angleRad: Double;
    cosValue: Double;
    sinValue: Double;
begin
    Result := False;
    ScreenX := 0.0;
    ScreenY := 0.0;
    if ClientWidth <= 0 then
    begin
        Exit;
    end;
    if ClientHeight <= 0 then
    begin
        Exit;
    end;
    aspectRatio := ClientWidth / ClientHeight;
    nearPlane := 0.1;
    topValue := BuildPerspectiveHalfSize(nearPlane, 45.0, aspectRatio);
    rightValue := topValue * aspectRatio;
    viewX := PointValue.X - centerXValue;
    viewY := PointValue.Y - centerYValue;
    viewZ := PointValue.Z - centerZValue;
    viewX := viewX * scaleValue;
    viewY := viewY * scaleValue;
    viewZ := viewZ * scaleValue;
    rotatedX := viewX;
    rotatedY := viewY;
    rotatedZ := viewZ;
    angleRad := DegToRad(-90.0);
    cosValue := Cos(angleRad);
    sinValue := Sin(angleRad);
    viewY := (rotatedY * cosValue) - (rotatedZ * sinValue);
    viewZ := (rotatedY * sinValue) + (rotatedZ * cosValue);
    viewX := rotatedX;
    rotatedX := viewX;
    rotatedY := viewY;
    rotatedZ := viewZ;
    angleRad := DegToRad(yawValue);
    cosValue := Cos(angleRad);
    sinValue := Sin(angleRad);
    viewX := (rotatedX * cosValue) + (rotatedZ * sinValue);
    viewZ := (-rotatedX * sinValue) + (rotatedZ * cosValue);
    viewY := rotatedY;
    rotatedX := viewX;
    rotatedY := viewY;
    rotatedZ := viewZ;
    angleRad := DegToRad(pitchValue);
    cosValue := Cos(angleRad);
    sinValue := Sin(angleRad);
    viewY := (rotatedY * cosValue) - (rotatedZ * sinValue);
    viewZ := (rotatedY * sinValue) + (rotatedZ * cosValue);
    viewX := rotatedX;
    viewX := viewX + panXValue;
    viewY := viewY + panYValue;
    viewZ := viewZ - distanceValue;
    if viewZ >= -nearPlane then
    begin
        Exit;
    end;
    ndcX := (viewX * nearPlane) / (rightValue * -viewZ);
    ndcY := (viewY * nearPlane) / (topValue * -viewZ);
    ScreenX := (ndcX + 1.0) * 0.5 * ClientWidth;
    ScreenY := (1.0 - ((ndcY + 1.0) * 0.5)) * ClientHeight;
    Result := True;
end;

function TDXMeshViewer.TriangleCenterInsideRect(const SelectionRect: TRect; FrameIndex, TriangleIndex: Integer): Boolean;
var
    triangle: TDXMeshTriangle;
    p0: TDXMeshPoint;
    p1: TDXMeshPoint;
    p2: TDXMeshPoint;
    centerPoint: TDXMeshPoint;
    screenX: Double;
    screenY: Double;
    normalizedRect: TRect;
begin
    Result := False;
    if (modelValue = nil) or (IsTriangleIndexValid(TriangleIndex) = False) then
    begin
        Exit;
    end;
    triangle := modelValue.Triangles[TriangleIndex];
    p0 := modelValue.Vertices[FrameIndex, triangle.iVertex[0]];
    p1 := modelValue.Vertices[FrameIndex, triangle.iVertex[1]];
    p2 := modelValue.Vertices[FrameIndex, triangle.iVertex[2]];
    centerPoint.X := Round((p0.X + p1.X + p2.X) / 3.0);
    centerPoint.Y := Round((p0.Y + p1.Y + p2.Y) / 3.0);
    centerPoint.Z := Round((p0.Z + p1.Z + p2.Z) / 3.0);
    if ProjectModelPointToScreen(centerPoint, screenX, screenY) = False then
    begin
        Exit;
    end;
    normalizedRect.Left := Min(SelectionRect.Left, SelectionRect.Right);
    normalizedRect.Right := Max(SelectionRect.Left, SelectionRect.Right);
    normalizedRect.Top := Min(SelectionRect.Top, SelectionRect.Bottom);
    normalizedRect.Bottom := Max(SelectionRect.Top, SelectionRect.Bottom);
    if (screenX >= normalizedRect.Left) and (screenX <= normalizedRect.Right) and
       (screenY >= normalizedRect.Top) and (screenY <= normalizedRect.Bottom) then
    begin
        Result := True;
    end;
end;

function TDXMeshViewer.TriangleHasAtLeastNVerticesInsideRect(const SelectionRect: TRect; FrameIndex, TriangleIndex, RequiredCount: Integer): Boolean;
var
    triangle: TDXMeshTriangle;
    vertexIndex: Integer;
    screenX: Double;
    screenY: Double;
    insideCount: Integer;
    normalizedRect: TRect;
    pointValue: TDXMeshPoint;
begin
    Result := False;
    if (modelValue = nil) or (IsTriangleIndexValid(TriangleIndex) = False) then
    begin
        Exit;
    end;
    normalizedRect.Left := Min(SelectionRect.Left, SelectionRect.Right);
    normalizedRect.Right := Max(SelectionRect.Left, SelectionRect.Right);
    normalizedRect.Top := Min(SelectionRect.Top, SelectionRect.Bottom);
    normalizedRect.Bottom := Max(SelectionRect.Top, SelectionRect.Bottom);
    triangle := modelValue.Triangles[TriangleIndex];
    insideCount := 0;
    for vertexIndex := 0 to 2 do
    begin
        pointValue := modelValue.Vertices[FrameIndex, triangle.iVertex[vertexIndex]];
        if ProjectModelPointToScreen(pointValue, screenX, screenY) = True then
        begin
            if (screenX >= normalizedRect.Left) and (screenX <= normalizedRect.Right) and
               (screenY >= normalizedRect.Top) and (screenY <= normalizedRect.Bottom) then
            begin
                Inc(insideCount);
                if insideCount >= RequiredCount then
                begin
                    Result := True;
                    Exit;
                end;
            end;
        end;
    end;
end;

procedure TDXMeshViewer.SelectTrianglesInRectByGeometry(const SelectionRect: TRect; Shift: TShiftState);
var
    frameIndex: Integer;
    triangleIndex: Integer;
    hitFlags: TArray<Boolean>;
    activeTriangleIndex: Integer;
    bShiftSelect: Boolean;
    bCtrlSelect: Boolean;
    bChanged: Boolean;
    i: Integer;
    bHit: Boolean;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.TriangleCount <= 0 then
    begin
        Exit;
    end;
    frameIndex := GetSafeFrame();
    SetLength(hitFlags, modelValue.TriangleCount);
    activeTriangleIndex := -1;
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        bHit := False;
        case rectSelectionModeValue of
            rsmTriangleCenter:
                bHit := TriangleCenterInsideRect(SelectionRect, frameIndex, triangleIndex);
            rsmTwoVerticesInside:
                bHit := TriangleHasAtLeastNVerticesInsideRect(SelectionRect, frameIndex, triangleIndex, 2);
            rsmAllVerticesInside:
                bHit := TriangleHasAtLeastNVerticesInsideRect(SelectionRect, frameIndex, triangleIndex, 3);
        else
            bHit := TriangleCenterInsideRect(SelectionRect, frameIndex, triangleIndex);
        end;
        if bHit = True then
        begin
            hitFlags[triangleIndex] := True;
            if activeTriangleIndex < 0 then
            begin
                activeTriangleIndex := triangleIndex;
            end;
        end;
    end;
    bShiftSelect := ssShift in Shift;
    bCtrlSelect := ssCtrl in Shift;
    bChanged := False;
    EnsureSelectionCapacity();
    if (bShiftSelect = False) and (bCtrlSelect = False) then
    begin
        ResetSelectionState();
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                selectedTrianglesValue[i] := True;
                Inc(selectedCountValue);
                bChanged := True;
            end;
        end;
        if selectedCountValue > 0 then
        begin
            selectedTriangleIndexValue := activeTriangleIndex;
        end
        else
        begin
            selectedTriangleIndexValue := -1;
            bChanged := True;
        end;
    end
    else if bCtrlSelect = True then
    begin
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                InternalToggleSelection(i);
                bChanged := True;
            end;
        end;
        if (activeTriangleIndex >= 0) and (GetTriangleSelected(activeTriangleIndex) = True) then
        begin
            selectedTriangleIndexValue := activeTriangleIndex;
        end;
    end
    else
    begin
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                if GetTriangleSelected(i) = False then
                begin
                    InternalAddSelection(i);
                    bChanged := True;
                end;
            end;
        end;
        if activeTriangleIndex >= 0 then
        begin
            if selectedTriangleIndexValue <> activeTriangleIndex then
            begin
                selectedTriangleIndexValue := activeTriangleIndex;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SelectTrianglesInRectByVisiblePixels(const SelectionRect: TRect; Shift: TShiftState);
var
    normalizedRect: TRect;
    readWidth: Integer;
    readHeight: Integer;
    pixelX: Integer;
    pixelY: Integer;
    startY: Integer;
    pixelBuffer: TBytes;
    bufferIndex: Integer;
    colorValue: Cardinal;
    triangleIndex: Integer;
    hitFlags: TArray<Boolean>;
    i: Integer;
    bShiftSelect: Boolean;
    bCtrlSelect: Boolean;
    bChanged: Boolean;
    activeTriangleIndex: Integer;
begin
    if bOpenGLReadyValue = False then
    begin
        Exit;
    end;
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.TriangleCount <= 0 then
    begin
        Exit;
    end;
    normalizedRect.Left := EnsureRange(Min(SelectionRect.Left, SelectionRect.Right), 0, Max(ClientWidth - 1, 0));
    normalizedRect.Right := EnsureRange(Max(SelectionRect.Left, SelectionRect.Right), 0, Max(ClientWidth - 1, 0));
    normalizedRect.Top := EnsureRange(Min(SelectionRect.Top, SelectionRect.Bottom), 0, Max(ClientHeight - 1, 0));
    normalizedRect.Bottom := EnsureRange(Max(SelectionRect.Top, SelectionRect.Bottom), 0, Max(ClientHeight - 1, 0));
    readWidth := (normalizedRect.Right - normalizedRect.Left) + 1;
    readHeight := (normalizedRect.Bottom - normalizedRect.Top) + 1;
    if (readWidth <= 0) or (readHeight <= 0) then
    begin
        Exit;
    end;
    SetLength(hitFlags, modelValue.TriangleCount);
    SetLength(pixelBuffer, readWidth * readHeight * 3);
    if wglMakeCurrent(dcHandleValue, rcHandleValue) = False then
    begin
        Exit;
    end;
    try
        SetupViewport();
        SetGLClearColor(colorsValue.PickingBackgroundColor);
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        SetupViewTransform();
        DrawModelForPicking();
        glFlush();
        startY := ClientHeight - 1 - normalizedRect.Bottom;
        if startY < 0 then
        begin
            startY := 0;
        end;
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glReadPixels(
            normalizedRect.Left,
            startY,
            readWidth,
            readHeight,
            GL_RGB,
            GL_UNSIGNED_BYTE,
            @pixelBuffer[0]
        );
    finally
        SetGLClearColor(colorsValue.BackgroundColor);
        wglMakeCurrent(0, 0);
    end;
    activeTriangleIndex := -1;
    for pixelY := 0 to readHeight - 1 do
    begin
        for pixelX := 0 to readWidth - 1 do
        begin
            bufferIndex := ((pixelY * readWidth) + pixelX) * 3;
            colorValue := Cardinal(pixelBuffer[bufferIndex]) or
                          (Cardinal(pixelBuffer[bufferIndex + 1]) shl 8) or
                          (Cardinal(pixelBuffer[bufferIndex + 2]) shl 16);
            triangleIndex := DecodeTriangleIndexFromColor(colorValue);
            if IsTriangleIndexValid(triangleIndex) = True then
            begin
                hitFlags[triangleIndex] := True;
                if activeTriangleIndex < 0 then
                begin
                    activeTriangleIndex := triangleIndex;
                end;
            end;
        end;
    end;
    bShiftSelect := ssShift in Shift;
    bCtrlSelect := ssCtrl in Shift;
    bChanged := False;
    EnsureSelectionCapacity();
    if (bShiftSelect = False) and (bCtrlSelect = False) then
    begin
        ResetSelectionState();
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                selectedTrianglesValue[i] := True;
                Inc(selectedCountValue);
                bChanged := True;
            end;
        end;
        if selectedCountValue > 0 then
        begin
            selectedTriangleIndexValue := activeTriangleIndex;
        end
        else
        begin
            selectedTriangleIndexValue := -1;
            bChanged := True;
        end;
    end
    else if bCtrlSelect = True then
    begin
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                InternalToggleSelection(i);
                bChanged := True;
            end;
        end;
        if (activeTriangleIndex >= 0) and (GetTriangleSelected(activeTriangleIndex) = True) then
        begin
            selectedTriangleIndexValue := activeTriangleIndex;
        end;
    end
    else
    begin
        for i := 0 to High(hitFlags) do
        begin
            if hitFlags[i] = True then
            begin
                if GetTriangleSelected(i) = False then
                begin
                    InternalAddSelection(i);
                    bChanged := True;
                end;
            end;
        end;
        if activeTriangleIndex >= 0 then
        begin
            if selectedTriangleIndexValue <> activeTriangleIndex then
            begin
                selectedTriangleIndexValue := activeTriangleIndex;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

function TDXMeshViewer.SelectTriangleAt(X, Y: Integer): Integer;
var
    pixelY: Integer;
    pixelData: array[0..3] of Byte;
    colorValue: Cardinal;
begin
    Result := -1;
    if bOpenGLReadyValue = False then
    begin
        Exit;
    end;
    if modelValue = nil then
    begin
        Exit;
    end;
    if wglMakeCurrent(dcHandleValue, rcHandleValue) = False then
    begin
        Exit;
    end;
    try
        SetupViewport();
        SetGLClearColor(colorsValue.PickingBackgroundColor);
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        SetupViewTransform();
        DrawModelForPicking();
        glFlush();
        pixelY := ClientHeight - 1 - Y;
        if pixelY < 0 then
        begin
            pixelY := 0;
        end;
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glReadPixels(X, pixelY, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, @pixelData[0]);
        colorValue := Cardinal(pixelData[0]) or (Cardinal(pixelData[1]) shl 8) or (Cardinal(pixelData[2]) shl 16);
        Result := DecodeTriangleIndexFromColor(colorValue);
    finally
        SetGLClearColor(colorsValue.BackgroundColor);
        wglMakeCurrent(0, 0);
    end;
end;

procedure TDXMeshViewer.Paint();
begin
    inherited Paint();
    RenderNow();
end;

procedure TDXMeshViewer.DrawViewportBackground();
var
    previousMatrixMode: GLint;
begin
    if bGradientBackgroundValue = False then
    begin
        SetGLClearColor(colorsValue.BackgroundColor);
        glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        Exit;
    end;

    glClear(GL_DEPTH_BUFFER_BIT);
    glGetIntegerv(GL_MATRIX_MODE, @previousMatrixMode);

    glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_DEPTH_BUFFER_BIT);
    try
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glDisable(GL_TEXTURE_2D);
        glDisable(GL_BLEND);
        glDepthMask(GL_FALSE);

        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        try
            glLoadIdentity();
            glOrtho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0);

            glMatrixMode(GL_MODELVIEW);
            glPushMatrix();
            try
                glLoadIdentity();
                glBegin(GL_QUADS);
                    SetGLColor(colorsValue.BackgroundBottomColor);
                    glVertex2f(0.0, 0.0);
                    glVertex2f(1.0, 0.0);
                    SetGLColor(colorsValue.BackgroundTopColor);
                    glVertex2f(1.0, 1.0);
                    glVertex2f(0.0, 1.0);
                glEnd();
            finally
                glPopMatrix();
            end;
        finally
            glMatrixMode(GL_PROJECTION);
            glPopMatrix();
        end;
    finally
        glDepthMask(GL_TRUE);
        glPopAttrib();
        glMatrixMode(previousMatrixMode);
    end;
end;

procedure TDXMeshViewer.RenderNow();
begin
    if bOpenGLReadyValue = False then
    begin
        Canvas.Brush.Color := colorsValue.BackgroundColor;
        Canvas.FillRect(ClientRect);
        Exit;
    end;
    if wglMakeCurrent(dcHandleValue, rcHandleValue) = False then
    begin
        Exit;
    end;
    try
        SetupViewport();
        DrawViewportBackground();
        SetupViewTransform();
        DrawModel();
        DrawAxisIndicator();
        DrawSelectionRectangle();
        SwapBuffers(dcHandleValue);
    finally
        wglMakeCurrent(0, 0);
    end;
end;

procedure TDXMeshViewer.Resize();
begin
    inherited Resize();
    Invalidate();
end;

procedure TDXMeshViewer.ResetView();
begin
    yawValue := 30.0;
    pitchValue := -20.0;
    distanceValue := DefaultDistance;
    panXValue := 0.0;
    panYValue := 0.0;
    RebuildView();
    Invalidate();
end;

procedure TDXMeshViewer.ReleaseAxisFont();
begin
    if dcHandleValue <> 0 then
    begin
        if axisFontOldHandleValue <> 0 then
        begin
            SelectObject(dcHandleValue, axisFontOldHandleValue);
            axisFontOldHandleValue := 0;
        end;
    end;
    if axisFontHandleValue <> 0 then
    begin
        DeleteObject(axisFontHandleValue);
        axisFontHandleValue := 0;
    end;
    if axisFontBaseValue <> 0 then
    begin
        if (rcHandleValue <> 0) and (dcHandleValue <> 0) then
        begin
            if wglMakeCurrent(dcHandleValue, rcHandleValue) = True then
            begin
                glDeleteLists(axisFontBaseValue, 256);
                wglMakeCurrent(0, 0);
            end;
        end;
        axisFontBaseValue := 0;
    end;
    bAxisFontReadyValue := False;
end;

procedure TDXMeshViewer.BuildAxisFont();
var
    fontName: string;
    fontHandle: HFONT;
    oldHandle: HGDIOBJ;
    listBase: Cardinal;
begin
    if (dcHandleValue = 0) or (rcHandleValue = 0) then
    begin
        Exit;
    end;
    ReleaseAxisFont();
    if wglMakeCurrent(dcHandleValue, rcHandleValue) = False then
    begin
        Exit;
    end;
    fontName := axisFontNameValue;
    if fontName = '' then
    begin
        fontName := 'Verdana';
    end;
    fontHandle := CreateFont(
        -MulDiv(axisFontHeightValue, GetDeviceCaps(dcHandleValue, LOGPIXELSY), 72),
        0,
        0,
        0,
        FW_BOLD,
        0,
        0,
        0,
        DEFAULT_CHARSET,
        OUT_TT_PRECIS,
        CLIP_DEFAULT_PRECIS,
        ANTIALIASED_QUALITY,
        FF_DONTCARE or DEFAULT_PITCH,
        PChar(fontName)
    );
    if fontHandle = 0 then
    begin
        wglMakeCurrent(0, 0);
        Exit;
    end;
    oldHandle := SelectObject(dcHandleValue, fontHandle);
    listBase := glGenLists(256);
    if listBase = 0 then
    begin
        SelectObject(dcHandleValue, oldHandle);
        DeleteObject(fontHandle);
        wglMakeCurrent(0, 0);
        Exit;
    end;
    if wglUseFontBitmaps(dcHandleValue, 0, 255, listBase) = False then
    begin
        glDeleteLists(listBase, 256);
        SelectObject(dcHandleValue, oldHandle);
        DeleteObject(fontHandle);
        wglMakeCurrent(0, 0);
        Exit;
    end;
    axisFontHandleValue := fontHandle;
    axisFontOldHandleValue := oldHandle;
    axisFontBaseValue := listBase;
    bAxisFontReadyValue := True;
    wglMakeCurrent(0, 0);
end;

procedure TDXMeshViewer.RebuildView();
var
    bounds: TDXMeshBounds;
    sizeX: Double;
    sizeY: Double;
    sizeZ: Double;
    maxSize: Double;
begin
    centerXValue := 0.0;
    centerYValue := 0.0;
    centerZValue := 0.0;
    panXValue := 0.0;
    panYValue := 0.0;
    scaleValue := 1.0;
    distanceValue := DefaultDistance;
    ResetSelectionState();
    if modelValue = nil then
    begin
        SetLength(selectedTrianglesValue, 0);
        Exit;
    end;
    SetLength(selectedTrianglesValue, modelValue.TriangleCount);
    ResetSelectionState();
    bounds := modelValue.AllFramesBounds;
    if bounds.bValid = False then
    begin
        Exit;
    end;
    centerXValue := (bounds.MinX + bounds.MaxX) * 0.5;
    centerYValue := (bounds.MinY + bounds.MaxY) * 0.5;
    centerZValue := (bounds.MinZ + bounds.MaxZ) * 0.5;
    sizeX := bounds.MaxX - bounds.MinX;
    sizeY := bounds.MaxY - bounds.MinY;
    sizeZ := bounds.MaxZ - bounds.MinZ;
    maxSize := Max(sizeX, Max(sizeY, sizeZ));
    if maxSize <= 0.0 then
    begin
        maxSize := 1.0;
    end;
    scaleValue := 2.0 / maxSize;
    distanceValue := DefaultDistance;
end;

procedure TDXMeshViewer.SetModel(const AModel: TDXUnreal3DModel);
var
    oldContext: HGLRC;
    oldDC: HDC;
    bContextSwitched: Boolean;
    bNeedRestoreContext: Boolean;
begin
    bContextSwitched := False;
    bNeedRestoreContext := False;
    if (rcHandleValue <> 0) and (dcHandleValue <> 0) then
    begin
        oldContext := wglGetCurrentContext();
        oldDC := wglGetCurrentDC();
        bNeedRestoreContext := (oldContext <> rcHandleValue) or (oldDC <> dcHandleValue);
        if bNeedRestoreContext = True then
        begin
            bContextSwitched := wglMakeCurrent(dcHandleValue, rcHandleValue) = True;
        end
        else
        begin
            bContextSwitched := True;
        end;
        if bContextSwitched = True then
        begin
            ReleaseLoadedTextures();
            ReleaseLoadedTexture(envMapTextureValue);
            if bNeedRestoreContext = True then
            begin
                if (oldContext <> 0) and (oldDC <> 0) then
                begin
                    wglMakeCurrent(oldDC, oldContext);
                end
                else
                begin
                    wglMakeCurrent(0, 0);
                end;
            end;
        end
        else
        begin
            InvalidateLoadedTextures();
        end;
    end
    else
    begin
        InvalidateLoadedTextures();
    end;
    modelValue := AModel;
    currentFrameValue := 0;
    ResetDebugCaches();
    RebuildView();
    DoSelectionChanged();
    DoTriangleSelected();
    Invalidate();
end;

procedure TDXMeshViewer.SetCurrentFrame(AFrame: Integer);
begin
    currentFrameValue := AFrame;
    bMaxDecodedDistanceCurrentFrameReadyValue := False;
    cachedMaxDecodedDistanceFrameIndexValue := -1;
    Invalidate();
end;

procedure TDXMeshViewer.SetDistance(const AValue: Single);
begin
    distanceValue := EnsureRange(AValue, MinDistance, MaxDistance);
    Invalidate();
end;

procedure TDXMeshViewer.SetDisplayMode(const AValue: TDXMeshDisplayMode);
begin
    if displayModeValue = AValue then
    begin
        Exit;
    end;
    displayModeValue := AValue;
    case displayModeValue of
        mdWireframe:
            begin
                bWireframeValue := True;
                bShadedValue := False;
                bSmoothShadedValue := False;
            end;
        mdWireframeSolid:
            begin
                bWireframeValue := False;
                bShadedValue := False;
                bSmoothShadedValue := False;
            end;
        mdFlatShaded:
            begin
                bWireframeValue := False;
                bShadedValue := True;
                bSmoothShadedValue := False;
            end;
        mdSmoothShaded:
            begin
                bWireframeValue := False;
                bShadedValue := False;
                bSmoothShadedValue := True;
            end;
        mdTextured:
            begin
                bWireframeValue := False;
                bShadedValue := False;
                bSmoothShadedValue := True;
            end;
    end;
    RenderNow();
end;

procedure TDXMeshViewer.SetWireframe(const bValue: Boolean);
begin
    if bWireframeValue = bValue then
    begin
        Exit;
    end;
    bWireframeValue := bValue;
    if bWireframeValue = True then
    begin
        bShadedValue := False;
        bSmoothShadedValue := False;
    end;
    Invalidate();
end;

procedure TDXMeshViewer.SetShaded(const bValue: Boolean);
begin
    if bShadedValue = bValue then
    begin
        Exit;
    end;
    bShadedValue := bValue;
    if bShadedValue = True then
    begin
        bWireframeValue := False;
        bSmoothShadedValue := False;
    end;
    Invalidate();
end;

procedure TDXMeshViewer.SetSmoothShaded(const bValue: Boolean);
begin
    if bSmoothShadedValue = bValue then
    begin
        Exit;
    end;
    bSmoothShadedValue := bValue;
    if bSmoothShadedValue = True then
    begin
        bWireframeValue := False;
        bShadedValue := False;
    end;
    Invalidate();
end;

procedure TDXMeshViewer.SetShadeAmbient(const AValue: Single);
begin
    shadeAmbientValue := EnsureRange(AValue, MinShadeAmbient, MaxShadeAmbient);
    if (bShadedValue = True) or (bSmoothShadedValue = True) then
    begin
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SetShadeDiffuse(const AValue: Single);
begin
    shadeDiffuseValue := EnsureRange(AValue, MinShadeDiffuse, MaxShadeDiffuse);
    if (bShadedValue = True) or (bSmoothShadedValue = True) then
    begin
        Invalidate();
    end;
end;

procedure TDXMeshViewer.InternalSetSingleSelection(TriangleIndex: Integer);
begin
    ResetSelectionState();
    if IsTriangleIndexValid(TriangleIndex) = False then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    selectedTrianglesValue[TriangleIndex] := True;
    selectedTriangleIndexValue := TriangleIndex;
    selectedCountValue := 1;
end;

procedure TDXMeshViewer.InternalAddSelection(TriangleIndex: Integer);
begin
    if IsTriangleIndexValid(TriangleIndex) = False then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    if selectedTrianglesValue[TriangleIndex] = False then
    begin
        selectedTrianglesValue[TriangleIndex] := True;
        Inc(selectedCountValue);
    end;
    selectedTriangleIndexValue := TriangleIndex;
end;

procedure TDXMeshViewer.InternalRemoveSelection(TriangleIndex: Integer);
var
    i: Integer;
begin
    if IsTriangleIndexValid(TriangleIndex) = False then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    if selectedTrianglesValue[TriangleIndex] = True then
    begin
        selectedTrianglesValue[TriangleIndex] := False;
        Dec(selectedCountValue);
        if selectedCountValue < 0 then
        begin
            selectedCountValue := 0;
        end;
    end;
    if selectedTriangleIndexValue = TriangleIndex then
    begin
        selectedTriangleIndexValue := -1;
        for i := 0 to High(selectedTrianglesValue) do
        begin
            if selectedTrianglesValue[i] = True then
            begin
                selectedTriangleIndexValue := i;
                Break;
            end;
        end;
    end;
end;

procedure TDXMeshViewer.InternalToggleSelection(TriangleIndex: Integer);
begin
    if IsTriangleIndexValid(TriangleIndex) = False then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    if selectedTrianglesValue[TriangleIndex] = True then
    begin
        InternalRemoveSelection(TriangleIndex);
    end
    else
    begin
        InternalAddSelection(TriangleIndex);
    end;
end;

procedure TDXMeshViewer.ApplySelectionClick(TriangleIndex: Integer; Shift: TShiftState);
var
    bChanged: Boolean;
    bShiftSelect: Boolean;
    bCtrlSelect: Boolean;
begin
    bChanged := False;
    bShiftSelect := ssShift in Shift;
    bCtrlSelect := ssCtrl in Shift;
    if (bShiftSelect = False) and (bCtrlSelect = False) then
    begin
        if IsTriangleIndexValid(TriangleIndex) = True then
        begin
            if (selectedCountValue <> 1) or (selectedTriangleIndexValue <> TriangleIndex) or (GetTriangleSelected(TriangleIndex) = False) then
            begin
                InternalSetSingleSelection(TriangleIndex);
                bChanged := True;
            end;
        end
        else
        begin
            if (selectedCountValue > 0) or (selectedTriangleIndexValue <> -1) then
            begin
                ResetSelectionState();
                bChanged := True;
            end;
        end;
    end
    else if bCtrlSelect = True then
    begin
        if IsTriangleIndexValid(TriangleIndex) = True then
        begin
            InternalToggleSelection(TriangleIndex);
            bChanged := True;
        end;
    end
    else if bShiftSelect = True then
    begin
        if IsTriangleIndexValid(TriangleIndex) = True then
        begin
            if GetTriangleSelected(TriangleIndex) = False then
            begin
                InternalAddSelection(TriangleIndex);
                bChanged := True;
            end
            else if selectedTriangleIndexValue <> TriangleIndex then
            begin
                selectedTriangleIndexValue := TriangleIndex;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SetSelectedTriangleIndex(AValue: Integer);
var
    bChanged: Boolean;
begin
    bChanged := False;
    if IsTriangleIndexValid(AValue) = False then
    begin
        AValue := -1;
    end;
    if AValue < 0 then
    begin
        if (selectedCountValue > 0) or (selectedTriangleIndexValue <> -1) then
        begin
            ResetSelectionState();
            bChanged := True;
        end;
    end
    else
    begin
        if (selectedCountValue <> 1) or (selectedTriangleIndexValue <> AValue) or (GetTriangleSelected(AValue) = False) then
        begin
            InternalSetSingleSelection(AValue);
            bChanged := True;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SetTriangleSelected(Index: Integer; bValue: Boolean);
var
    bChanged: Boolean;
begin
    bChanged := False;
    if IsTriangleIndexValid(Index) = False then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    if bValue = True then
    begin
        if selectedTrianglesValue[Index] = False then
        begin
            InternalAddSelection(Index);
            bChanged := True;
        end;
    end
    else
    begin
        if selectedTrianglesValue[Index] = True then
        begin
            InternalRemoveSelection(Index);
            bChanged := True;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

function TDXMeshViewer.GetTriangleSelected(Index: Integer): Boolean;
begin
    Result := False;
    if IsTriangleIndexValid(Index) = False then
    begin
        Exit;
    end;
    if Index >= Length(selectedTrianglesValue) then
    begin
        Exit;
    end;
    Result := selectedTrianglesValue[Index];
end;

function TDXMeshViewer.GetSelectionCount(): Integer;
begin
    Result := selectedCountValue;
end;

procedure TDXMeshViewer.NextFrame();
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    currentFrameValue := currentFrameValue + 1;
    if currentFrameValue >= modelValue.FrameCount then
    begin
        currentFrameValue := 0;
    end;
    Invalidate();
end;

procedure TDXMeshViewer.PrevFrame();
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    if modelValue.FrameCount <= 0 then
    begin
        Exit;
    end;
    currentFrameValue := currentFrameValue - 1;
    if currentFrameValue < 0 then
    begin
        currentFrameValue := modelValue.FrameCount - 1;
    end;
    Invalidate();
end;

procedure TDXMeshViewer.ClearSelection();
begin
    SetSelectedTriangleIndex(-1);
end;

procedure TDXMeshViewer.SelectTriangle(TriangleIndex: Integer; const bAddToSelection: Boolean = False);
begin
    if bAddToSelection = True then
    begin
        if IsTriangleIndexValid(TriangleIndex) = True then
        begin
            EnsureSelectionCapacity();
            if selectedTrianglesValue[TriangleIndex] = False then
            begin
                InternalAddSelection(TriangleIndex);
                DoSelectionChanged();
                DoTriangleSelected();
                Invalidate();
            end
            else if selectedTriangleIndexValue <> TriangleIndex then
            begin
                selectedTriangleIndexValue := TriangleIndex;
                DoSelectionChanged();
                DoTriangleSelected();
                Invalidate();
            end;
        end;
    end
    else
    begin
        SetSelectedTriangleIndex(TriangleIndex);
    end;
end;

procedure TDXMeshViewer.ToggleTriangle(TriangleIndex: Integer);
begin
    if IsTriangleIndexValid(TriangleIndex) = False then
    begin
        Exit;
    end;
    InternalToggleSelection(TriangleIndex);
    DoSelectionChanged();
    DoTriangleSelected();
    Invalidate();
end;

procedure TDXMeshViewer.AssignSelection(const SelectedIndices: TArray<Integer>; ActiveTriangleIndex: Integer = -1);
var
    i: Integer;
    triangleIndex: Integer;
    bHasActiveTriangle: Boolean;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    ResetSelectionState();
    for i := 0 to High(SelectedIndices) do
    begin
        triangleIndex := SelectedIndices[i];
        if IsTriangleIndexValid(triangleIndex) = True then
        begin
            if selectedTrianglesValue[triangleIndex] = False then
            begin
                selectedTrianglesValue[triangleIndex] := True;
                Inc(selectedCountValue);
            end;
        end;
    end;
    bHasActiveTriangle := False;
    if IsTriangleIndexValid(ActiveTriangleIndex) = True then
    begin
        if selectedTrianglesValue[ActiveTriangleIndex] = True then
        begin
            selectedTriangleIndexValue := ActiveTriangleIndex;
            bHasActiveTriangle := True;
        end;
    end;
    if bHasActiveTriangle = False then
    begin
        selectedTriangleIndexValue := -1;
        for triangleIndex := 0 to High(selectedTrianglesValue) do
        begin
            if selectedTrianglesValue[triangleIndex] = True then
            begin
                selectedTriangleIndexValue := triangleIndex;
                Break;
            end;
        end;
    end;
    DoSelectionChanged();
    DoTriangleSelected();
    Invalidate();
end;

function TDXMeshViewer.IsTriangleSelected(TriangleIndex: Integer): Boolean;
begin
    Result := GetTriangleSelected(TriangleIndex);
end;

procedure TDXMeshViewer.SelectAllTriangles();
var
    triangleIndex: Integer;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    ResetSelectionState();
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        selectedTrianglesValue[triangleIndex] := True;
    end;
    selectedCountValue := modelValue.TriangleCount;
    if selectedCountValue > 0 then
    begin
        selectedTriangleIndexValue := 0;
    end;
    DoSelectionChanged();
    DoTriangleSelected();
    Invalidate();
end;

procedure TDXMeshViewer.InvertSelection();
var
    triangleIndex: Integer;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        if selectedTrianglesValue[triangleIndex] = True then
        begin
            selectedTrianglesValue[triangleIndex] := False;
        end
        else
        begin
            selectedTrianglesValue[triangleIndex] := True;
        end;
    end;
    selectedCountValue := 0;
    selectedTriangleIndexValue := -1;
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        if selectedTrianglesValue[triangleIndex] = True then
        begin
            Inc(selectedCountValue);
            if selectedTriangleIndexValue < 0 then
            begin
                selectedTriangleIndexValue := triangleIndex;
            end;
        end;
    end;
    DoSelectionChanged();
    DoTriangleSelected();
    Invalidate();
end;

procedure TDXMeshViewer.SelectTrianglesByTextureIndex(TextureIndex: Integer; const bAddToSelection: Boolean = False);
var
    triangleIndex: Integer;
    bChanged: Boolean;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    bChanged := False;
    if bAddToSelection = False then
    begin
        ResetSelectionState();
        bChanged := True;
    end;
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        if modelValue.Triangles[triangleIndex].TextureIndex = TextureIndex then
        begin
            if selectedTrianglesValue[triangleIndex] = False then
            begin
                selectedTrianglesValue[triangleIndex] := True;
                Inc(selectedCountValue);
                if selectedTriangleIndexValue < 0 then
                begin
                    selectedTriangleIndexValue := triangleIndex;
                end;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SelectTrianglesByPolyFlags(RequiredFlags: Cardinal; const bAddToSelection: Boolean = False);
var
    triangleIndex: Integer;
    bChanged: Boolean;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    bChanged := False;
    if bAddToSelection = False then
    begin
        ResetSelectionState();
        bChanged := True;
    end;
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        if (modelValue.Triangles[triangleIndex].PolyFlags and RequiredFlags) = RequiredFlags then
        begin
            if selectedTrianglesValue[triangleIndex] = False then
            begin
                selectedTrianglesValue[triangleIndex] := True;
                Inc(selectedCountValue);
                if selectedTriangleIndexValue < 0 then
                begin
                    selectedTriangleIndexValue := triangleIndex;
                end;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.SelectTrianglesByRawTypeByte(TypeByte: Byte; const bAddToSelection: Boolean = False);
var
    triangleIndex: Integer;
    bChanged: Boolean;
begin
    if modelValue = nil then
    begin
        Exit;
    end;
    EnsureSelectionCapacity();
    bChanged := False;
    if bAddToSelection = False then
    begin
        ResetSelectionState();
        bChanged := True;
    end;
    for triangleIndex := 0 to modelValue.TriangleCount - 1 do
    begin
        if modelValue.Triangles[triangleIndex].RawTypeByte = TypeByte then
        begin
            if selectedTrianglesValue[triangleIndex] = False then
            begin
                selectedTrianglesValue[triangleIndex] := True;
                Inc(selectedCountValue);
                if selectedTriangleIndexValue < 0 then
                begin
                    selectedTriangleIndexValue := triangleIndex;
                end;
                bChanged := True;
            end;
        end;
    end;
    if bChanged = True then
    begin
        DoSelectionChanged();
        DoTriangleSelected();
        Invalidate();
    end;
end;

procedure TDXMeshViewer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    bLeftDown: Boolean;
    bRightDown: Boolean;
begin
    inherited MouseDown(Button, Shift, X, Y);
    lastMouseXValue := X;
    lastMouseYValue := Y;
    mouseDownXValue := X;
    mouseDownYValue := Y;
    bLeftDown := ssLeft in Shift;
    bRightDown := ssRight in Shift;
    bLeftClickCandidateValue := False;
    bRectSelectActiveValue := False;
    rectSelectStartXValue := X;
    rectSelectStartYValue := Y;
    rectSelectCurrentXValue := X;
    rectSelectCurrentYValue := Y;
    if (Button = mbLeft) and (bRightDown = False) then
    begin
        bLeftClickCandidateValue := True;
    end
    else if (Button = mbRight) and (bLeftDown = True) then
    begin
        bLeftClickCandidateValue := False;
    end;
    bRightClickMenuCandidateValue := False;
    bRightMouseMovedValue := False;
    if (Button = mbRight) and (bLeftDown = False) then
    begin
        bRightClickMenuCandidateValue := True;
    end;
    SetFocus();
    MouseCapture := True;
end;

procedure TDXMeshViewer.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    deltaX: Integer;
    deltaY: Integer;
    bLeftDown: Boolean;
    bRightDown: Boolean;
begin
    inherited MouseMove(Shift, X, Y);
    deltaX := X - lastMouseXValue;
    deltaY := Y - lastMouseYValue;
    bLeftDown := ssLeft in Shift;
    bRightDown := ssRight in Shift;
    if bLeftClickCandidateValue = True then
    begin
        if (Abs(X - mouseDownXValue) > ClickMoveThreshold) or (Abs(Y - mouseDownYValue) > ClickMoveThreshold) then
        begin
            bLeftClickCandidateValue := False;
        end;
    end;
    if bRightClickMenuCandidateValue = True then
    begin
        if (X <> mouseDownXValue) or (Y <> mouseDownYValue) then
        begin
            bRightMouseMovedValue := True;
        end;
    end;
    if (bLeftDown = True) and (bRightDown = False) then
    begin
        if bLeftClickCandidateValue = False then
        begin
            if bRectSelectActiveValue = False then
            begin
                bRectSelectActiveValue := True;
            end;
            rectSelectCurrentXValue := X;
            rectSelectCurrentYValue := Y;
            Invalidate();
        end;
    end
    else if (bRightDown = True) and (bLeftDown = True) then
    begin
        bRectSelectActiveValue := False;
        panXValue := panXValue + (deltaX * PanDragSpeed);
        panYValue := panYValue - (deltaY * PanDragSpeed);
        Invalidate();
    end
    else if bRightDown = True then
    begin
        bRectSelectActiveValue := False;
        yawValue := yawValue + (deltaX * OrbitSpeed);
        pitchValue := pitchValue + (deltaY * OrbitSpeed);
        Invalidate();
    end;
    lastMouseXValue := X;
    lastMouseYValue := Y;
end;

procedure TDXMeshViewer.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    hitTriangleIndex: Integer;
    bSelectClick: Boolean;
    bShowPopupMenu: Boolean;
    bRectSelect: Boolean;
    bHadRectSelect: Boolean;
    screenPoint: TPoint;
    selectionRect: TRect;
begin
    inherited MouseUp(Button, Shift, X, Y);
    lastMouseXValue := X;
    lastMouseYValue := Y;
    bSelectClick := False;
    if Button = mbLeft then
    begin
        if bLeftClickCandidateValue = True then
        begin
            if (ssRight in Shift) = False then
            begin
                bSelectClick := True;
            end;
        end;
    end;
    bShowPopupMenu := False;
    if Button = mbRight then
    begin
        if (bRightClickMenuCandidateValue = True) and (bRightMouseMovedValue = False) then
        begin
            if (ssLeft in Shift) = False then
            begin
                bShowPopupMenu := Assigned(PopupMenu);
            end;
        end;
    end;
    bHadRectSelect := bRectSelectActiveValue;
    bRectSelect := False;
    if Button = mbLeft then
    begin
        if bRectSelectActiveValue = True then
        begin
            selectionRect := Rect(rectSelectStartXValue, rectSelectStartYValue, X, Y);
            if (Abs(selectionRect.Right - selectionRect.Left) > ClickMoveThreshold) or
               (Abs(selectionRect.Bottom - selectionRect.Top) > ClickMoveThreshold) then
            begin
                bRectSelect := True;
            end;
        end;
    end;
    bLeftClickCandidateValue := False;
    bRightClickMenuCandidateValue := False;
    bRightMouseMovedValue := False;
    bRectSelectActiveValue := False;
    if bHadRectSelect = True then
    begin
        Invalidate();
    end;
    if bRectSelect = True then
    begin
        SelectTrianglesInRect(selectionRect, Shift);
    end
    else if bSelectClick = True then
    begin
        hitTriangleIndex := SelectTriangleAt(X, Y);
        ApplySelectionClick(hitTriangleIndex, Shift);
    end;
    if (ssLeft in Shift) = False then
    begin
        if (ssRight in Shift) = False then
        begin
            MouseCapture := False;
        end;
    end;
    if bShowPopupMenu = True then
    begin
        screenPoint := ClientToScreen(Point(X, Y));
        PopupMenu.Popup(screenPoint.X, screenPoint.Y);
    end;
end;

procedure TDXMeshViewer.CMMouseWheel(var Message: TCMMouseWheel);
begin
    SetDistance(distanceValue - ((Message.WheelDelta / WHEEL_DELTA) * ZoomWheelStep));
    Message.Result := 1;
end;

procedure TDXMeshViewer.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
    Message.Result := 1;
end;

procedure TDXMeshViewer.WMContextMenu(var Message: TWMContextMenu);
begin
    Message.Result := 1;
end;

initialization

    DXDefaultMeshViewerColors.BackgroundColor := RGB(26, 26, 31);
    DXDefaultMeshViewerColors.BackgroundTopColor := RGB(38, 42, 54);
    DXDefaultMeshViewerColors.BackgroundBottomColor := RGB(13, 14, 18);
    DXDefaultMeshViewerColors.SolidColorNormal := RGB(184, 184, 199);
    DXDefaultMeshViewerColors.SolidColorTwoSided := RGB(204, 204, 219);
    DXDefaultMeshViewerColors.SolidColorInvisible := RGB(153, 64, 64);
    DXDefaultMeshViewerColors.WireframeColor := RGB(20, 20, 26);
    DXDefaultMeshViewerColors.WireframeModeColor := RGB(210, 210, 224);
    DXDefaultMeshViewerColors.SelectedFillColor := RGB(255, 115, 31);
    DXDefaultMeshViewerColors.ActiveSelectedFillColor := RGB(255, 217, 38);
    DXDefaultMeshViewerColors.SelectedLineColor := RGB(26, 217, 255);
    DXDefaultMeshViewerColors.ActiveSelectedLineColor := RGB(38, 242, 51);
    DXDefaultMeshViewerColors.PickingBackgroundColor := clBlack;
    DXDefaultMeshViewerColors.BoundingBoxColor := RGB(255, 230, 140);
    DXDefaultMeshViewerColors.BoundingSphereColor := RGB(255, 196, 96);
    DXDefaultMeshViewerColors.WarningTextColor := RGB(255, 160, 32);
    DXDefaultMeshViewerColors.OriginMarkerColor := RGB(255, 96, 96);
    DXDefaultMeshViewerColors.OriginLabelColor := clWhite;
    DXDefaultMeshViewerColors.ExceededVertexColor := RGB(255, 64, 64);
    DXDefaultMeshViewerColors.AxisXColor := clRed;
    DXDefaultMeshViewerColors.AxisYColor := clGreen;
    DXDefaultMeshViewerColors.AxisZColor := clBlue;
    DXDefaultMeshViewerColors.AxisLabelColor := clWhite;
    DXDefaultMeshViewerColors.SelectionRectBorderColor := RGB(120, 180, 255);
    DXDefaultMeshViewerColors.SelectionRectFillColor := RGB(120, 180, 255);
    DXDefaultMeshViewerColors.BoundingBoxLabelColor := clWhite;
end.


