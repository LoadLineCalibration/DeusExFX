unit DXUnreal3DModel;

interface

uses
    System.SysUtils,
    System.Classes;

const
    PF_Invisible        = Cardinal($00000001);
    PF_Masked           = Cardinal($00000002);
    PF_Translucent      = Cardinal($00000004);
    PF_NotSolid         = Cardinal($00000008);
    PF_Environment      = Cardinal($00000010);
    PF_Semisolid        = Cardinal($00000020);
    PF_Modulated        = Cardinal($00000040);
    PF_FakeBackdrop     = Cardinal($00000080);
    PF_TwoSided         = Cardinal($00000100);
    PF_AutoUPan         = Cardinal($00000200);
    PF_AutoVPan         = Cardinal($00000400);
    PF_NoSmooth         = Cardinal($00000800);
    PF_BigWavy          = Cardinal($00001000);
    PF_SmallWavy        = Cardinal($00002000);
    PF_Flat             = Cardinal($00004000);
    PF_LowShadowDetail  = Cardinal($00008000);
    PF_NoMerge          = Cardinal($00010000);
    PF_CloudWavy        = Cardinal($00020000);
    PF_DirtyShadows     = Cardinal($00040000);
    PF_BrightCorners    = Cardinal($00080000);
    PF_SpecialLit       = Cardinal($00100000);
    PF_Gouraud          = Cardinal($00200000);
    PF_Unlit            = Cardinal($00400000);
    PF_HighShadowDetail = Cardinal($00800000);
    PF_Memorized        = Cardinal($01000000);
    PF_Selected         = Cardinal($02000000);
    PF_Portal           = Cardinal($04000000);
    PF_Mirrored         = Cardinal($08000000);
    PF_Highlighted      = Cardinal($10000000);
    PF_FlatShaded       = Cardinal($40000000);
    PF_EdCut            = Cardinal($80000000);

    MTT_Normal          = Byte(0);
    MTT_NormalTwoSided  = Byte(1);
    MTT_Translucent     = Byte(2);
    MTT_Masked          = Byte(3);
    MTT_Modulate        = Byte(4);
    MTT_Placeholder     = Byte(8);
    MTT_Unlit           = Byte(16);
    MTT_Flat            = Byte(32);
    MTT_Environment     = Byte(64);
    MTT_NoSmooth        = Byte(128);


type
    TDXMeshFileKind = (mfUnknown, mfAnimation, mfData);
    TDXMeshTriangleLayout = (tlUnknown, tlEngine20, tlCompact16);
    TDXMeshDataHeaderLayout = (dhlUnknown, dhlWord4, dhlLegacy48);

    TDXMeshUV = packed record
        U: Byte;
        V: Byte;
    end;

    TDXMeshDataHeader = packed record
        NumPolys: Word;
        NumVertices: Word;
    end;

    TDXMeshAnimHeader = packed record
        NumFrames: Word;
        FrameSize: Word;
    end;

    TDXJSMeshDataHeader = packed record
        NumPolys: Word;
        NumVertices: Word;
        BogusRot: Word;
        BogusFrame: Word;
        BogusNormX: Cardinal;
        BogusNormY: Cardinal;
        BogusNormZ: Cardinal;
        FixScale: Cardinal;
        Unused1: Cardinal;
        Unused2: Cardinal;
        Unused3: Cardinal;
    end;

    TDXMeshTri16 = packed record
        iVertex: array[0..2] of Word;
        TypeByte: Byte;
        ColorByte: Byte;
        Tex: array[0..2] of TDXMeshUV;
        TextureNum: Byte;
        FlagsByte: Byte;
    end;

    TDXMeshTri20 = packed record
        iVertex: array[0..2] of Word;
        Tex: array[0..2] of TDXMeshUV;
        PolyFlags: Cardinal;
        TextureIndex: Integer;
    end;

    TDXMeshVertHigh = packed record
        X: SmallInt;
        Y: SmallInt;
        Z: SmallInt;
        Pad: SmallInt;
    end;

    TDXMeshPoint = packed record
        X: SmallInt;
        Y: SmallInt;
        Z: SmallInt;
    end;

    TDXMeshTriangle = record
        iVertex: array[0..2] of Word;
        Tex: array[0..2] of TDXMeshUV;
        PolyFlags: Cardinal;
        TextureIndex: Integer;
        RawTypeByte: Byte;
        RawColorByte: Byte;
        RawFlagsByte: Byte;
    end;

    TDXMeshBounds = record
        MinX: Integer;
        MinY: Integer;
        MinZ: Integer;
        MaxX: Integer;
        MaxY: Integer;
        MaxZ: Integer;
        bValid: Boolean;
    end;

    TDXUnreal3DModel = class
    private
        sourceFileNameValue: string;
        baseFileNameValue: string;
        dataFileNameValue: string;
        animFileNameValue: string;
        fileKindValue: TDXMeshFileKind;

        dataHeaderValue: TDXMeshDataHeader;
        legacyDataHeaderValue: TDXJSMeshDataHeader;
        animHeaderValue: TDXMeshAnimHeader;

        dataHeaderLayoutValue: TDXMeshDataHeaderLayout;
        triangleLayoutValue: TDXMeshTriangleLayout;
        dataHeaderSizeValue: Integer;
        trianglesOffsetValue: Integer;

        dataFileHeaderBytesValue: TBytes;
        trianglesValue: TArray<TDXMeshTriangle>;
        framesValue: TArray<TArray<TDXMeshPoint>>;

        firstFrameBoundsValue: TDXMeshBounds;
        allFramesBoundsValue: TDXMeshBounds;

        lastErrorValue: string;
        lastWarningValue: string;
        bHighPrecisionModelsValue: Boolean;
        bDataModifiedValue: Boolean;
        updateLockCountValue: Integer;
        bPendingChangedValue: Boolean;
        bFullRefreshRequiredValue: Boolean;
        dirtyTrianglesValue: TArray<Boolean>;
        dirtyTriangleCountValue: Integer;
        onChangedValue: TNotifyEvent;

        procedure Clear();
        procedure DoChanged();
        function ResolveInputFiles(const FileName: string): Boolean;
        function DetectDataLayout(const StreamSize: Int64): Boolean;
        procedure ResetBounds(out Bounds: TDXMeshBounds);
        procedure IncludePointInBounds(var Bounds: TDXMeshBounds; const Pt: TDXMeshPoint);
        function LoadDataFile(): Boolean;
        function LoadAnimFile(): Boolean;
        function GetTriangleCount(): Integer;
        function GetFrameCount(): Integer;
        function GetVertexCountPerFrame(): Integer;
        function GetTriangle(Index: Integer): TDXMeshTriangle;
        function GetVertex(FrameIndex, VertexIndex: Integer): TDXMeshPoint;
        procedure MarkTriangleDirty(TriangleIndex: Integer);
        procedure ClearDirtyTriangles();
        procedure MarkDataModified(TriangleIndex: Integer = -1);
        function BuildOutputBaseFileName(const FileName: string): string;
    public
        constructor Create();

        function LoadFromFile(const FileName: string): Boolean;
        function SaveData(): Boolean;
        function SaveDataToFile(const FileName: string): Boolean;
        procedure BuildInfoStrings(const Lines: TStrings);
        procedure BeginUpdate();
        procedure EndUpdate();
        procedure SetTriangleRawTypeByte(TriangleIndex: Integer; AValue: Byte);
        procedure SetTriangleRawColorByte(TriangleIndex: Integer; AValue: Byte);
        procedure SetTriangleRawFlagsByte(TriangleIndex: Integer; AValue: Byte);
        procedure SetTriangleTextureIndex(TriangleIndex: Integer; AValue: Integer);
        procedure SetTrianglePolyFlags(TriangleIndex: Integer; AValue: Cardinal);
        procedure SetTriangleLegacyTypeParts(TriangleIndex: Integer; BaseType, ExtraBits: Byte);
        function GetTriangleBaseType(TriangleIndex: Integer): Byte;
        function GetTriangleExtraTypeBits(TriangleIndex: Integer): Byte;
        function ConsumeDirtyTriangleIndices(): TArray<Integer>;
        function ConsumeFullRefreshRequired(): Boolean;

        property SourceFileName: string read sourceFileNameValue;
        property BaseFileName: string read baseFileNameValue;
        property DataFileName: string read dataFileNameValue;
        property AnimFileName: string read animFileNameValue;
        property FileKind: TDXMeshFileKind read fileKindValue;
        property TriangleCount: Integer read GetTriangleCount;
        property FrameCount: Integer read GetFrameCount;
        property VertexCountPerFrame: Integer read GetVertexCountPerFrame;
        property TriangleLayout: TDXMeshTriangleLayout read triangleLayoutValue;
        property DataHeaderLayout: TDXMeshDataHeaderLayout read dataHeaderLayoutValue;
        property LastError: string read lastErrorValue;
        property LastWarning: string read lastWarningValue;
        property FirstFrameBounds: TDXMeshBounds read firstFrameBoundsValue;
        property AllFramesBounds: TDXMeshBounds read allFramesBoundsValue;
        property bDataModified: Boolean read bDataModifiedValue;
        property OnChanged: TNotifyEvent read onChangedValue write onChangedValue;
        property Triangles[Index: Integer]: TDXMeshTriangle read GetTriangle;
        property Vertices[FrameIndex, VertexIndex: Integer]: TDXMeshPoint read GetVertex;
    end;

procedure LoadUnreal3DModelInfoToStrings(const FileName: string; Lines: TStrings);
function PolyFlagsToText(Flags: Cardinal): string;

implementation

uses
    Winapi.Windows,
    System.StrUtils;


type
    TPolyFlagName = record
        Value: Cardinal;
        Name: string;
    end;

const
    PolyFlagNames: array[0..30] of TPolyFlagName = (
        (Value: PF_Invisible; Name: 'PF_Invisible'),
        (Value: PF_Masked; Name: 'PF_Masked'),
        (Value: PF_Translucent; Name: 'PF_Translucent'),
        (Value: PF_NotSolid; Name: 'PF_NotSolid'),
        (Value: PF_Environment; Name: 'PF_Environment'),
        (Value: PF_Semisolid; Name: 'PF_Semisolid'),
        (Value: PF_Modulated; Name: 'PF_Modulated'),
        (Value: PF_FakeBackdrop; Name: 'PF_FakeBackdrop'),
        (Value: PF_TwoSided; Name: 'PF_TwoSided'),
        (Value: PF_AutoUPan; Name: 'PF_AutoUPan'),
        (Value: PF_AutoVPan; Name: 'PF_AutoVPan'),
        (Value: PF_NoSmooth; Name: 'PF_NoSmooth'),
        (Value: PF_BigWavy; Name: 'PF_BigWavy / PF_SpecialPoly'),
        (Value: PF_SmallWavy; Name: 'PF_SmallWavy'),
        (Value: PF_Flat; Name: 'PF_Flat'),
        (Value: PF_LowShadowDetail; Name: 'PF_LowShadowDetail'),
        (Value: PF_NoMerge; Name: 'PF_NoMerge'),
        (Value: PF_CloudWavy; Name: 'PF_CloudWavy'),
        (Value: PF_DirtyShadows; Name: 'PF_DirtyShadows'),
        (Value: PF_BrightCorners; Name: 'PF_BrightCorners'),
        (Value: PF_SpecialLit; Name: 'PF_SpecialLit'),
        (Value: PF_Gouraud; Name: 'PF_Gouraud'),
        (Value: PF_Unlit; Name: 'PF_Unlit'),
        (Value: PF_HighShadowDetail; Name: 'PF_HighShadowDetail'),
        (Value: PF_Memorized; Name: 'PF_Memorized / PF_RenderHint'),
        (Value: PF_Selected; Name: 'PF_Selected'),
        (Value: PF_Portal; Name: 'PF_Portal'),
        (Value: PF_Mirrored; Name: 'PF_Mirrored'),
        (Value: PF_Highlighted; Name: 'PF_Highlighted'),
        (Value: PF_FlatShaded; Name: 'PF_FlatShaded'),
        (Value: PF_EdCut; Name: 'PF_EdCut')
    );

function MeshFileKindToText(const Kind: TDXMeshFileKind): string;
begin
    case Kind of
        mfAnimation:
            Result := '_a.3d';
        mfData:
            Result := '_d.3d';
    else
        Result := 'unknown';
    end;
end;

function DataHeaderLayoutToText(const Layout: TDXMeshDataHeaderLayout): string;
begin
    case Layout of
        dhlWord4:
            Result := '4-byte simple header';
        dhlLegacy48:
            Result := 'legacy James mesh header (36-byte FJSDataHeader + 12 extra bytes before trianglesValue)';
    else
        Result := 'unknown';
    end;
end;

function TriangleLayoutToText(const Layout: TDXMeshTriangleLayout): string;
begin
    case Layout of
        tlEngine20:
            Result := '20 bytes (FMeshTri: full PolyFlags + TextureIndex)';
        tlCompact16:
            Result := '16 bytes (legacy compact tri: Type/Color/TextureNum/Flags as bytes)';
    else
        Result := 'unknown';
    end;
end;

function DecodeLegacyTriTypeToPolyFlags(TypeByte: Byte): Cardinal;
var
    BaseType: Byte;
begin
    Result := 0;
    BaseType := TypeByte and 15;

    if BaseType = MTT_NormalTwoSided then
    begin
        Result := Result or PF_TwoSided;
    end
    else if BaseType = MTT_Modulate then
    begin
        Result := Result or PF_TwoSided or PF_Modulated;
    end
    else if BaseType = MTT_Translucent then
    begin
        Result := Result or PF_TwoSided or PF_Translucent;
    end
    else if BaseType = MTT_Masked then
    begin
        Result := Result or PF_TwoSided or PF_Masked;
    end
    else if BaseType = MTT_Placeholder then
    begin
        Result := Result or PF_TwoSided or PF_Invisible;
    end;

    if (TypeByte and MTT_Unlit) <> 0 then
    begin
        Result := Result or PF_Unlit;
    end;

    if (TypeByte and MTT_Flat) <> 0 then
    begin
        Result := Result or PF_Flat;
    end;

    if (TypeByte and MTT_Environment) <> 0 then
    begin
        Result := Result or PF_Environment;
    end;

    if (TypeByte and MTT_NoSmooth) <> 0 then
    begin
        Result := Result or PF_NoSmooth;
    end;
end;

function BuildLegacyTypeByte(const BaseType, ExtraBits: Byte): Byte;
begin
    Result := (BaseType and $0F) or (ExtraBits and $F0);
end;

function PolyFlagsToText(Flags: Cardinal): string;
var
    i: Integer;
begin
    Result := '';

    for i := Low(PolyFlagNames) to High(PolyFlagNames) do
    begin
        if (Flags and PolyFlagNames[i].Value) <> 0 then
        begin
            if Result <> '' then
            begin
                Result := Result + ', ';
            end;

            Result := Result + PolyFlagNames[i].Name;
        end;
    end;

    if Result = '' then
    begin
        Result := '(нет флагов)';
    end;
end;

constructor TDXUnreal3DModel.Create();
begin
    inherited Create();
    bHighPrecisionModelsValue := True;
    bDataModifiedValue := False;
    updateLockCountValue := 0;
    bPendingChangedValue := False;
    onChangedValue := nil;
    Clear();
end;

procedure TDXUnreal3DModel.Clear();
begin
    sourceFileNameValue := '';
    baseFileNameValue := '';
    dataFileNameValue := '';
    animFileNameValue := '';
    fileKindValue := mfUnknown;

    FillChar(dataHeaderValue, SizeOf(dataHeaderValue), 0);
    FillChar(legacyDataHeaderValue, SizeOf(legacyDataHeaderValue), 0);
    FillChar(animHeaderValue, SizeOf(animHeaderValue), 0);

    dataHeaderLayoutValue := dhlUnknown;
    triangleLayoutValue := tlUnknown;
    dataHeaderSizeValue := 0;
    trianglesOffsetValue := 0;

    SetLength(dataFileHeaderBytesValue, 0);
    SetLength(trianglesValue, 0);
    SetLength(framesValue, 0);

    ResetBounds(firstFrameBoundsValue);
    ResetBounds(allFramesBoundsValue);

    lastErrorValue := '';
    lastWarningValue := '';
    bDataModifiedValue := False;
    updateLockCountValue := 0;
    bPendingChangedValue := False;
    bFullRefreshRequiredValue := False;
    SetLength(dirtyTrianglesValue, 0);
    dirtyTriangleCountValue := 0;
end;

procedure TDXUnreal3DModel.DoChanged();
begin
    if updateLockCountValue > 0 then
    begin
        bPendingChangedValue := True;
        Exit;
    end;

    bPendingChangedValue := False;
    if Assigned(onChangedValue) = True then
    begin
        onChangedValue(Self);
    end;
end;

procedure TDXUnreal3DModel.BeginUpdate();
begin
    Inc(updateLockCountValue);
end;

procedure TDXUnreal3DModel.EndUpdate();
begin
    if updateLockCountValue > 0 then
    begin
        Dec(updateLockCountValue);
    end;

    if (updateLockCountValue = 0) and (bPendingChangedValue = True) then
    begin
        DoChanged();
    end;
end;


procedure TDXUnreal3DModel.MarkTriangleDirty(TriangleIndex: Integer);
begin
    if TriangleIndex < 0 then
    begin
        Exit;
    end;

    if Length(dirtyTrianglesValue) <> Length(trianglesValue) then
    begin
        SetLength(dirtyTrianglesValue, Length(trianglesValue));
        dirtyTriangleCountValue := 0;
    end;

    if TriangleIndex >= Length(dirtyTrianglesValue) then
    begin
        Exit;
    end;

    if dirtyTrianglesValue[TriangleIndex] = False then
    begin
        dirtyTrianglesValue[TriangleIndex] := True;
        Inc(dirtyTriangleCountValue);
    end;
end;

procedure TDXUnreal3DModel.ClearDirtyTriangles();
begin
    if Length(dirtyTrianglesValue) <> 0 then
    begin
        FillChar(dirtyTrianglesValue[0], Length(dirtyTrianglesValue) * SizeOf(Boolean), 0);
    end;
    dirtyTriangleCountValue := 0;
end;

function TDXUnreal3DModel.ConsumeDirtyTriangleIndices(): TArray<Integer>;
var
    i: Integer;
    writeIndex: Integer;
begin
    if dirtyTriangleCountValue <= 0 then
    begin
        SetLength(Result, 0);
        Exit;
    end;

    SetLength(Result, dirtyTriangleCountValue);
    writeIndex := 0;

    for i := 0 to High(dirtyTrianglesValue) do
    begin
        if dirtyTrianglesValue[i] = True then
        begin
            if writeIndex < Length(Result) then
            begin
                Result[writeIndex] := i;
                Inc(writeIndex);
            end;
        end;
    end;

    if writeIndex <> Length(Result) then
    begin
        SetLength(Result, writeIndex);
    end;

    ClearDirtyTriangles();
end;

function TDXUnreal3DModel.ConsumeFullRefreshRequired(): Boolean;
begin
    Result := bFullRefreshRequiredValue;
    bFullRefreshRequiredValue := False;
end;

procedure TDXUnreal3DModel.ResetBounds(out Bounds: TDXMeshBounds);
begin
    Bounds.MinX := 0;
    Bounds.MinY := 0;
    Bounds.MinZ := 0;
    Bounds.MaxX := 0;
    Bounds.MaxY := 0;
    Bounds.MaxZ := 0;
    Bounds.bValid := False;
end;

procedure TDXUnreal3DModel.IncludePointInBounds(var Bounds: TDXMeshBounds; const Pt: TDXMeshPoint);
begin
    if Bounds.bValid = False then
    begin
        Bounds.MinX := Pt.X;
        Bounds.MinY := Pt.Y;
        Bounds.MinZ := Pt.Z;
        Bounds.MaxX := Pt.X;
        Bounds.MaxY := Pt.Y;
        Bounds.MaxZ := Pt.Z;
        Bounds.bValid := True;
        Exit;
    end;

    if Pt.X < Bounds.MinX then
    begin
        Bounds.MinX := Pt.X;
    end;

    if Pt.Y < Bounds.MinY then
    begin
        Bounds.MinY := Pt.Y;
    end;

    if Pt.Z < Bounds.MinZ then
    begin
        Bounds.MinZ := Pt.Z;
    end;

    if Pt.X > Bounds.MaxX then
    begin
        Bounds.MaxX := Pt.X;
    end;

    if Pt.Y > Bounds.MaxY then
    begin
        Bounds.MaxY := Pt.Y;
    end;

    if Pt.Z > Bounds.MaxZ then
    begin
        Bounds.MaxZ := Pt.Z;
    end;
end;

function TDXUnreal3DModel.ResolveInputFiles(const FileName: string): Boolean;
var
    LowerName: string;
begin
    Result := False;
    LowerName := AnsiLowerCase(FileName);

    sourceFileNameValue := FileName;

    if EndsText('_a.3d', LowerName) = True then
    begin
        fileKindValue := mfAnimation;
        baseFileNameValue := Copy(FileName, 1, Length(FileName) - Length('_a.3d'));
    end
    else if EndsText('_d.3d', LowerName) = True then
    begin
        fileKindValue := mfData;
        baseFileNameValue := Copy(FileName, 1, Length(FileName) - Length('_d.3d'));
    end
    else
    begin
        lastErrorValue := 'Ожидался файл *_a.3d или *_d.3d';
        Exit;
    end;

    animFileNameValue := baseFileNameValue + '_a.3d';
    dataFileNameValue := baseFileNameValue + '_d.3d';

    if FileExists(animFileNameValue) = False then
    begin
        lastErrorValue := 'Не найден файл анимации: ' + animFileNameValue;
        Exit;
    end;

    if FileExists(dataFileNameValue) = False then
    begin
        lastErrorValue := 'Не найден файл данных: ' + dataFileNameValue;
        Exit;
    end;

    Result := True;
end;

function TDXUnreal3DModel.DetectDataLayout(const StreamSize: Int64): Boolean;
var
    PayloadSize: Int64;
begin
    Result := False;
    dataHeaderLayoutValue := dhlUnknown;
    triangleLayoutValue := tlUnknown;
    dataHeaderSizeValue := 0;
    trianglesOffsetValue := 0;

    PayloadSize := StreamSize - 48;
    if (PayloadSize >= 0) and (dataHeaderValue.NumPolys > 0) then
    begin
        if PayloadSize = Int64(dataHeaderValue.NumPolys) * SizeOf(TDXMeshTri16) then
        begin
            dataHeaderLayoutValue := dhlLegacy48;
            triangleLayoutValue := tlCompact16;
            dataHeaderSizeValue := SizeOf(TDXJSMeshDataHeader);
            trianglesOffsetValue := 48;
            Result := True;
            Exit;
        end;

        if PayloadSize = Int64(dataHeaderValue.NumPolys) * SizeOf(TDXMeshTri20) then
        begin
            dataHeaderLayoutValue := dhlLegacy48;
            triangleLayoutValue := tlEngine20;
            dataHeaderSizeValue := SizeOf(TDXJSMeshDataHeader);
            trianglesOffsetValue := 48;
            Result := True;
            Exit;
        end;
    end;

    PayloadSize := StreamSize - 4;
    if (PayloadSize >= 0) and (dataHeaderValue.NumPolys > 0) then
    begin
        if PayloadSize = Int64(dataHeaderValue.NumPolys) * SizeOf(TDXMeshTri16) then
        begin
            dataHeaderLayoutValue := dhlWord4;
            triangleLayoutValue := tlCompact16;
            dataHeaderSizeValue := SizeOf(TDXMeshDataHeader);
            trianglesOffsetValue := 4;
            Result := True;
            Exit;
        end;

        if PayloadSize = Int64(dataHeaderValue.NumPolys) * SizeOf(TDXMeshTri20) then
        begin
            dataHeaderLayoutValue := dhlWord4;
            triangleLayoutValue := tlEngine20;
            dataHeaderSizeValue := SizeOf(TDXMeshDataHeader);
            trianglesOffsetValue := 4;
            Result := True;
            Exit;
        end;
    end;
end;

function TDXUnreal3DModel.LoadDataFile(): Boolean;
var
    Stream: TFileStream;
    i: Integer;
    Tri16: TDXMeshTri16;
    Tri20: TDXMeshTri20;
    PolyFlagsOr: Cardinal;
    PolyFlagsAnd: Cardinal;
    bHasAnyTri: Boolean;
begin
    Result := False;
    Stream := nil;

    try
        Stream := TFileStream.Create(dataFileNameValue, fmOpenRead or fmShareDenyWrite);

        if Stream.Size < SizeOf(TDXMeshDataHeader) then
        begin
            lastErrorValue := 'Файл слишком короткий: ' + dataFileNameValue;
            Exit;
        end;

        Stream.ReadBuffer(dataHeaderValue, SizeOf(dataHeaderValue));

        if Stream.Size >= SizeOf(TDXJSMeshDataHeader) then
        begin
            Stream.Position := 0;
            Stream.ReadBuffer(legacyDataHeaderValue, SizeOf(legacyDataHeaderValue));
            dataHeaderValue.NumPolys := legacyDataHeaderValue.NumPolys;
            dataHeaderValue.NumVertices := legacyDataHeaderValue.NumVertices;
        end;

        if DetectDataLayout(Stream.Size) = False then
        begin
            lastErrorValue := 'Не удалось распознать layout *_d.3d';
            Exit;
        end;

        SetLength(dataFileHeaderBytesValue, trianglesOffsetValue);
        Stream.Position := 0;
        if trianglesOffsetValue > 0 then
        begin
            Stream.ReadBuffer(dataFileHeaderBytesValue[0], trianglesOffsetValue);
        end;

        SetLength(trianglesValue, dataHeaderValue.NumPolys);
        Stream.Position := trianglesOffsetValue;

        PolyFlagsOr := 0;
        PolyFlagsAnd := 0;
        bHasAnyTri := False;

        for i := 0 to High(trianglesValue) do
        begin
            if triangleLayoutValue = tlCompact16 then
            begin
                Stream.ReadBuffer(Tri16, SizeOf(Tri16));

                trianglesValue[i].iVertex[0] := Tri16.iVertex[0];
                trianglesValue[i].iVertex[1] := Tri16.iVertex[1];
                trianglesValue[i].iVertex[2] := Tri16.iVertex[2];
                trianglesValue[i].Tex[0] := Tri16.Tex[0];
                trianglesValue[i].Tex[1] := Tri16.Tex[1];
                trianglesValue[i].Tex[2] := Tri16.Tex[2];
                trianglesValue[i].TextureIndex := Tri16.TextureNum;
                trianglesValue[i].PolyFlags := DecodeLegacyTriTypeToPolyFlags(Tri16.TypeByte);
                trianglesValue[i].RawTypeByte := Tri16.TypeByte;
                trianglesValue[i].RawColorByte := Tri16.ColorByte;
                trianglesValue[i].RawFlagsByte := Tri16.FlagsByte;
            end
            else
            begin
                Stream.ReadBuffer(Tri20, SizeOf(Tri20));

                trianglesValue[i].iVertex[0] := Tri20.iVertex[0];
                trianglesValue[i].iVertex[1] := Tri20.iVertex[1];
                trianglesValue[i].iVertex[2] := Tri20.iVertex[2];
                trianglesValue[i].Tex[0] := Tri20.Tex[0];
                trianglesValue[i].Tex[1] := Tri20.Tex[1];
                trianglesValue[i].Tex[2] := Tri20.Tex[2];
                trianglesValue[i].TextureIndex := Tri20.TextureIndex;
                trianglesValue[i].PolyFlags := Tri20.PolyFlags;
                trianglesValue[i].RawTypeByte := 0;
                trianglesValue[i].RawColorByte := 0;
                trianglesValue[i].RawFlagsByte := 0;
            end;

            if bHasAnyTri = False then
            begin
                PolyFlagsAnd := trianglesValue[i].PolyFlags;
                bHasAnyTri := True;
            end
            else
            begin
                PolyFlagsAnd := PolyFlagsAnd and trianglesValue[i].PolyFlags;
            end;

            PolyFlagsOr := PolyFlagsOr or trianglesValue[i].PolyFlags;
        end;

        if bHasAnyTri = True then
        begin
            if (PolyFlagsOr and PF_Invisible) <> 0 then
            begin
                lastWarningValue := 'Есть placeholder/invisible-полигоны. Для viewer''а это нормально, просто учти.';
            end;
        end;

        Result := True;
    except
        on E: Exception do
        begin
            lastErrorValue := 'Ошибка чтения *_d.3d: ' + E.Message;
            Result := False;
        end;
    end;

    Stream.Free();
end;

function TDXUnreal3DModel.LoadAnimFile(): Boolean;
var
    Stream: TFileStream;
    FrameIndex: Integer;
    VertexIndex: Integer;
    RawVert: TDXMeshVertHigh;
    FrameBytesUsed: Integer;
    FramePadding: Integer;
begin
    Result := False;
    Stream := nil;

    try
        Stream := TFileStream.Create(animFileNameValue, fmOpenRead or fmShareDenyWrite);

        if Stream.Size < SizeOf(TDXMeshAnimHeader) then
        begin
            lastErrorValue := 'Файл слишком короткий: ' + animFileNameValue;
            Exit;
        end;

        Stream.ReadBuffer(animHeaderValue, SizeOf(animHeaderValue));

        SetLength(framesValue, animHeaderValue.NumFrames);
        ResetBounds(firstFrameBoundsValue);
        ResetBounds(allFramesBoundsValue);

        for FrameIndex := 0 to animHeaderValue.NumFrames - 1 do
        begin
            SetLength(framesValue[FrameIndex], dataHeaderValue.NumVertices);

            for VertexIndex := 0 to dataHeaderValue.NumVertices - 1 do
            begin
                Stream.ReadBuffer(RawVert, SizeOf(RawVert));
                framesValue[FrameIndex][VertexIndex].X := RawVert.X;
                framesValue[FrameIndex][VertexIndex].Y := RawVert.Y;
                framesValue[FrameIndex][VertexIndex].Z := RawVert.Z;

                IncludePointInBounds(allFramesBoundsValue, framesValue[FrameIndex][VertexIndex]);
                if FrameIndex = 0 then
                begin
                    IncludePointInBounds(firstFrameBoundsValue, framesValue[FrameIndex][VertexIndex]);
                end;
            end;

            FrameBytesUsed := dataHeaderValue.NumVertices * SizeOf(TDXMeshVertHigh);
            FramePadding := Integer(animHeaderValue.FrameSize) - FrameBytesUsed;
            if FramePadding < 0 then
            begin
                lastErrorValue := 'FrameSize меньше чем число вершин * sizeof(FMeshVert)';
                Exit;
            end;

            if FramePadding > 0 then
            begin
                Stream.Seek(FramePadding, soCurrent);
            end;
        end;

        Result := True;
    except
        on E: Exception do
        begin
            lastErrorValue := 'Ошибка чтения *_a.3d: ' + E.Message;
            Result := False;
        end;
    end;

    Stream.Free();
end;

procedure TDXUnreal3DModel.MarkDataModified(TriangleIndex: Integer);
begin
    bDataModifiedValue := True;
    MarkTriangleDirty(TriangleIndex);
    DoChanged();
end;

function TDXUnreal3DModel.BuildOutputBaseFileName(const FileName: string): string;
var
    LowerName: string;
begin
    LowerName := AnsiLowerCase(FileName);

    if EndsText('_a.3d', LowerName) = True then
    begin
        Result := Copy(FileName, 1, Length(FileName) - Length('_a.3d'));
        Exit;
    end;

    if EndsText('_d.3d', LowerName) = True then
    begin
        Result := Copy(FileName, 1, Length(FileName) - Length('_d.3d'));
        Exit;
    end;

    if EndsText('.3d', LowerName) = True then
    begin
        Result := Copy(FileName, 1, Length(FileName) - Length('.3d'));
        Exit;
    end;

    Result := ChangeFileExt(FileName, '');
    if Result = '' then
    begin
        Result := FileName;
    end;
end;

function TDXUnreal3DModel.LoadFromFile(const FileName: string): Boolean;
begin
    Clear();
    Result := False;

    if ResolveInputFiles(FileName) = False then
    begin
        Exit;
    end;

    if LoadDataFile() = False then
    begin
        Exit;
    end;

    if LoadAnimFile() = False then
    begin
        Exit;
    end;

    Result := True;
    ClearDirtyTriangles();
    bFullRefreshRequiredValue := True;
    DoChanged();
end;

function TDXUnreal3DModel.SaveData(): Boolean;
begin
    Result := SaveDataToFile(dataFileNameValue);
end;

function TDXUnreal3DModel.SaveDataToFile(const FileName: string): Boolean;
var
    Stream: TFileStream;
    i: Integer;
    Tri16: TDXMeshTri16;
    Tri20: TDXMeshTri20;
    outputBaseFileName: string;
    outputDataFileName: string;
    outputAnimFileName: string;
    outputSourceFileName: string;
begin
    Result := False;
    lastErrorValue := '';

    if FileName = '' then
    begin
        lastErrorValue := 'Не задано имя файла для сохранения';
        Exit;
    end;

    if Length(dataFileHeaderBytesValue) <> trianglesOffsetValue then
    begin
        lastErrorValue := 'Нет исходного заголовка *_d.3d для сохранения';
        Exit;
    end;

    if animFileNameValue = '' then
    begin
        lastErrorValue := 'Не задан исходный файл анимации *_a.3d';
        Exit;
    end;

    if FileExists(animFileNameValue) = False then
    begin
        lastErrorValue := 'Не найден исходный файл анимации: ' + animFileNameValue;
        Exit;
    end;

    outputBaseFileName := BuildOutputBaseFileName(FileName);
    if outputBaseFileName = '' then
    begin
        lastErrorValue := 'Не удалось определить базовое имя для сохранения';
        Exit;
    end;

    outputDataFileName := outputBaseFileName + '_d.3d';
    outputAnimFileName := outputBaseFileName + '_a.3d';

    Stream := nil;
    try
        Stream := TFileStream.Create(outputDataFileName, fmCreate);

        if trianglesOffsetValue > 0 then
        begin
            Stream.WriteBuffer(dataFileHeaderBytesValue[0], trianglesOffsetValue);
        end;

        for i := 0 to High(trianglesValue) do
        begin
            if triangleLayoutValue = tlCompact16 then
            begin
                FillChar(Tri16, SizeOf(Tri16), 0);
                Tri16.iVertex[0] := trianglesValue[i].iVertex[0];
                Tri16.iVertex[1] := trianglesValue[i].iVertex[1];
                Tri16.iVertex[2] := trianglesValue[i].iVertex[2];
                Tri16.TypeByte := trianglesValue[i].RawTypeByte;
                Tri16.ColorByte := trianglesValue[i].RawColorByte;
                Tri16.Tex[0] := trianglesValue[i].Tex[0];
                Tri16.Tex[1] := trianglesValue[i].Tex[1];
                Tri16.Tex[2] := trianglesValue[i].Tex[2];
                Tri16.TextureNum := Byte(trianglesValue[i].TextureIndex and $FF);
                Tri16.FlagsByte := trianglesValue[i].RawFlagsByte;
                Stream.WriteBuffer(Tri16, SizeOf(Tri16));
            end
            else
            begin
                FillChar(Tri20, SizeOf(Tri20), 0);
                Tri20.iVertex[0] := trianglesValue[i].iVertex[0];
                Tri20.iVertex[1] := trianglesValue[i].iVertex[1];
                Tri20.iVertex[2] := trianglesValue[i].iVertex[2];
                Tri20.Tex[0] := trianglesValue[i].Tex[0];
                Tri20.Tex[1] := trianglesValue[i].Tex[1];
                Tri20.Tex[2] := trianglesValue[i].Tex[2];
                Tri20.PolyFlags := trianglesValue[i].PolyFlags;
                Tri20.TextureIndex := trianglesValue[i].TextureIndex;
                Stream.WriteBuffer(Tri20, SizeOf(Tri20));
            end;
        end;
        FreeAndNil(Stream);

        if SameText(ExpandFileName(animFileNameValue), ExpandFileName(outputAnimFileName)) = False then
        begin
            if CopyFile(PChar(animFileNameValue), PChar(outputAnimFileName), False) = False then
            begin
                RaiseLastOSError();
            end;
        end;

        baseFileNameValue := outputBaseFileName;
        dataFileNameValue := outputDataFileName;
        animFileNameValue := outputAnimFileName;

        if fileKindValue = mfAnimation then
        begin
            outputSourceFileName := outputAnimFileName;
        end
        else
        begin
            outputSourceFileName := outputDataFileName;
        end;
        sourceFileNameValue := outputSourceFileName;

        bDataModifiedValue := False;
        Result := True;
    except
        on E: Exception do
        begin
            lastErrorValue := 'Ошибка сохранения пары *_a.3d / *_d.3d: ' + E.Message;
            Result := False;
        end;
    end;

    Stream.Free();
end;

function TDXUnreal3DModel.GetTriangleCount(): Integer;
begin
    Result := Length(trianglesValue);
end;

function TDXUnreal3DModel.GetFrameCount(): Integer;
begin
    Result := Length(framesValue);
end;

function TDXUnreal3DModel.GetVertexCountPerFrame(): Integer;
begin
    Result := dataHeaderValue.NumVertices;
end;

function TDXUnreal3DModel.GetTriangle(Index: Integer): TDXMeshTriangle;
begin
    FillChar(Result, SizeOf(Result), 0);

    if (Index >= 0) and (Index < Length(trianglesValue)) then
    begin
        Result := trianglesValue[Index];
    end;
end;

function TDXUnreal3DModel.GetVertex(FrameIndex, VertexIndex: Integer): TDXMeshPoint;
begin
    FillChar(Result, SizeOf(Result), 0);

    if (FrameIndex < 0) or (FrameIndex >= Length(framesValue)) then
    begin
        Exit;
    end;

    if (VertexIndex < 0) or (VertexIndex >= Length(framesValue[FrameIndex])) then
    begin
        Exit;
    end;

    Result := framesValue[FrameIndex][VertexIndex];
end;

procedure TDXUnreal3DModel.SetTriangleRawTypeByte(TriangleIndex: Integer; AValue: Byte);
begin
    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    trianglesValue[TriangleIndex].RawTypeByte := AValue;
    trianglesValue[TriangleIndex].PolyFlags := DecodeLegacyTriTypeToPolyFlags(AValue);
    MarkDataModified(TriangleIndex);
end;

procedure TDXUnreal3DModel.SetTriangleRawColorByte(TriangleIndex: Integer; AValue: Byte);
begin
    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    trianglesValue[TriangleIndex].RawColorByte := AValue;
    MarkDataModified(TriangleIndex);
end;

procedure TDXUnreal3DModel.SetTriangleRawFlagsByte(TriangleIndex: Integer; AValue: Byte);
begin
    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    trianglesValue[TriangleIndex].RawFlagsByte := AValue;
    MarkDataModified(TriangleIndex);
end;

procedure TDXUnreal3DModel.SetTriangleTextureIndex(TriangleIndex: Integer; AValue: Integer);
begin
    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    if triangleLayoutValue = tlCompact16 then
    begin
        if AValue < 0 then
        begin
            AValue := 0;
        end
        else if AValue > 255 then
        begin
            AValue := 255;
        end;
    end;

    trianglesValue[TriangleIndex].TextureIndex := AValue;
    MarkDataModified(TriangleIndex);
end;

procedure TDXUnreal3DModel.SetTrianglePolyFlags(TriangleIndex: Integer; AValue: Cardinal);
begin
    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    trianglesValue[TriangleIndex].PolyFlags := AValue;
    MarkDataModified(TriangleIndex);
end;

procedure TDXUnreal3DModel.SetTriangleLegacyTypeParts(TriangleIndex: Integer; BaseType, ExtraBits: Byte);
begin
    SetTriangleRawTypeByte(TriangleIndex, BuildLegacyTypeByte(BaseType, ExtraBits));
end;

function TDXUnreal3DModel.GetTriangleBaseType(TriangleIndex: Integer): Byte;
begin
    Result := 0;

    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    Result := trianglesValue[TriangleIndex].RawTypeByte and $0F;
end;

function TDXUnreal3DModel.GetTriangleExtraTypeBits(TriangleIndex: Integer): Byte;
begin
    Result := 0;

    if (TriangleIndex < 0) or (TriangleIndex >= Length(trianglesValue)) then
    begin
        Exit;
    end;

    Result := trianglesValue[TriangleIndex].RawTypeByte and $F0;
end;

procedure TDXUnreal3DModel.BuildInfoStrings(const Lines: TStrings);
var
    i: Integer;
    Tri: TDXMeshTriangle;
begin
    Lines.BeginUpdate();
    try
        Lines.Clear();
        Lines.Add('DX / Unreal 1 loaded mesh');
        Lines.Add('=========================');
        Lines.Add('');
        Lines.Add('Исходный файл: ' + sourceFileNameValue);
        Lines.Add('Тип входа: ' + MeshFileKindToText(fileKindValue));
        Lines.Add('Базовое имя: ' + baseFileNameValue);
        Lines.Add('');
        Lines.Add('HIGH_PRECISION_MODELS: ' + BoolToStr(bHighPrecisionModelsValue, True));
        Lines.Add('');
        Lines.Add('[DATA / *_d.3d]');
        Lines.Add('Файл: ' + dataFileNameValue);
        Lines.Add('NumPolys: ' + IntToStr(dataHeaderValue.NumPolys));
        Lines.Add('NumVertices: ' + IntToStr(dataHeaderValue.NumVertices));
        Lines.Add('Header layout: ' + DataHeaderLayoutToText(dataHeaderLayoutValue));
        Lines.Add('Header size: ' + IntToStr(dataHeaderSizeValue) + ' bytes');
        Lines.Add('Triangles offset: ' + IntToStr(trianglesOffsetValue) + ' bytes');
        Lines.Add('Triangle layout: ' + TriangleLayoutToText(triangleLayoutValue));

        if dataHeaderLayoutValue = dhlLegacy48 then
        begin
            Lines.Add('Legacy BogusRot: ' + IntToStr(legacyDataHeaderValue.BogusRot));
            Lines.Add('Legacy BogusFrame: ' + IntToStr(legacyDataHeaderValue.BogusFrame));
            Lines.Add('Legacy FixScale: $' + IntToHex(legacyDataHeaderValue.FixScale, 8));
        end;

        Lines.Add('');
        Lines.Add('[ANIM / *_a.3d]');
        Lines.Add('Файл: ' + animFileNameValue);
        Lines.Add('NumFrames: ' + IntToStr(animHeaderValue.NumFrames));
        Lines.Add('FrameSize: ' + IntToStr(animHeaderValue.FrameSize) + ' bytes');
        Lines.Add('');
        Lines.Add('[SUMMARY]');
        Lines.Add('Modified: ' + BoolToStr(bDataModifiedValue, True));
        Lines.Add('Triangles: ' + IntToStr(TriangleCount));
        Lines.Add('Frames: ' + IntToStr(FrameCount));
        Lines.Add('Vertices per frame: ' + IntToStr(VertexCountPerFrame));
        Lines.Add('');

        if firstFrameBoundsValue.bValid = True then
        begin
            Lines.Add('Bounds первого кадра: Min=(' + IntToStr(firstFrameBoundsValue.MinX) + ', ' + IntToStr(firstFrameBoundsValue.MinY) + ', ' + IntToStr(firstFrameBoundsValue.MinZ) + '), Max=(' + IntToStr(firstFrameBoundsValue.MaxX) + ', ' + IntToStr(firstFrameBoundsValue.MaxY) + ', ' + IntToStr(firstFrameBoundsValue.MaxZ) + ')');
        end;

        if allFramesBoundsValue.bValid = True then
        begin
            Lines.Add('Bounds всех кадров: Min=(' + IntToStr(allFramesBoundsValue.MinX) + ', ' + IntToStr(allFramesBoundsValue.MinY) + ', ' + IntToStr(allFramesBoundsValue.MinZ) + '), Max=(' + IntToStr(allFramesBoundsValue.MaxX) + ', ' + IntToStr(allFramesBoundsValue.MaxY) + ', ' + IntToStr(allFramesBoundsValue.MaxZ) + ')');
        end;

        Lines.Add('');
        Lines.Add('[FIRST TRIANGLES]');
        for i := 0 to TriangleCount - 1 do
        begin
            if i >= 8 then
            begin
                Break;
            end;

            Tri := trianglesValue[i];
            Lines.Add(
                Format(
                    '#%d: V=(%d,%d,%d), Tex=(%d,%d | %d,%d | %d,%d), TexIndex=%d, Flags=$%8.8x [%s], RawType=$%2.2x, RawColor=%d, RawFlags=$%2.2x',
                    [
                        i,
                        Tri.iVertex[0], Tri.iVertex[1], Tri.iVertex[2],
                        Tri.Tex[0].U, Tri.Tex[0].V,
                        Tri.Tex[1].U, Tri.Tex[1].V,
                        Tri.Tex[2].U, Tri.Tex[2].V,
                        Tri.TextureIndex,
                        Tri.PolyFlags,
                        PolyFlagsToText(Tri.PolyFlags),
                        Tri.RawTypeByte,
                        Tri.RawColorByte,
                        Tri.RawFlagsByte
                    ]
                )
            );
        end;

        if lastWarningValue <> '' then
        begin
            Lines.Add('');
            Lines.Add('[WARNING]');
            Lines.Add(lastWarningValue);
        end;

        if lastErrorValue <> '' then
        begin
            Lines.Add('');
            Lines.Add('[ERROR]');
            Lines.Add(lastErrorValue);
        end;
    finally
        Lines.EndUpdate();
    end;
end;

procedure LoadUnreal3DModelInfoToStrings(const FileName: string; Lines: TStrings);
var
    Model: TDXUnreal3DModel;
begin
    Model := TDXUnreal3DModel.Create();
    try
        if Model.LoadFromFile(FileName) = True then
        begin
            Model.BuildInfoStrings(Lines);
        end
        else
        begin
            Lines.Text := Model.LastError;
        end;
    finally
        Model.Free();
    end;
end;

end.
