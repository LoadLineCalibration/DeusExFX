unit DXUnreal3DFlagsEditor;

interface

uses
    Winapi.Windows,
    System.SysUtils,
    Vcl.StdCtrls,
    Vcl.Controls,
    System.Classes,
    DXUnreal3DModel,
    DXUnreal3DView;

type
    TDXMeshFlagsEditor = class
    private
        modelValue: TDXUnreal3DModel;
        viewerValue: TDXMeshViewer;

        rbNormalValue: TRadioButton;
        rbTwoSidedValue: TRadioButton;
        rbTranslucentValue: TRadioButton;
        rbMaskedValue: TRadioButton;
        rbModulatedValue: TRadioButton;
        rbWeaponTriangleValue: TRadioButton;

        cbUnlitValue: TCheckBox;
        cbFlatValue: TCheckBox;
        cbEnvironmentValue: TCheckBox;
        cbNoSmoothingValue: TCheckBox;

        materialEditValue: TCustomEdit;
        applyNowButtonValue: TButton;
        applyImmediatelyCheckBoxValue: TCheckBox;
        bPendingApplyValue: Boolean;

        updateLockCountValue: Integer;
        lastErrorValue: string;

        function GetSelectedTriangleIndices(): TArray<Integer>;
        procedure BeginUpdateControls();
        procedure EndUpdateControls();
        function IsUpdatingControls(): Boolean;
        procedure SetControlsEnabled(const bEnabled: Boolean);
        procedure SetRadioButtonsFromBaseType(BaseType: Integer; const bMixed: Boolean);
        function GetSelectedBaseType(out BaseType: Byte): Boolean;
        procedure SetCheckBoxState(CheckBox: TCheckBox; State: TCheckBoxState);
        procedure UpdateBitState(var StateValue: Integer; const bBitSet: Boolean);
        procedure ApplyCheckBoxBit(CheckBox: TCheckBox; BitMask: Byte; var TypeByte: Byte);
        procedure UpdateMaterialEditFromSelection(const SelectedIndices: TArray<Integer>);
        procedure WireClickHandler(const RadioButton: TRadioButton; const bAssign: Boolean);
        procedure WireCheckBoxHandler(const CheckBox: TCheckBox; const bAssign: Boolean);

        function GetApplyImmediately(): Boolean;
        procedure UpdateApplyControlsState();
        procedure MarkPendingOrApply();
        procedure ApplyNowButtonClick(Sender: TObject);
        procedure ApplyImmediatelyCheckBoxClick(Sender: TObject);

    public
        constructor Create();

        procedure Attach(AModel: TDXUnreal3DModel; AViewer: TDXMeshViewer);
        procedure AssignControls(
            ARbNormal: TRadioButton;
            ARbTwoSided: TRadioButton;
            ARbTranslucent: TRadioButton;
            ARbMasked: TRadioButton;
            ARbModulated: TRadioButton;
            ARbWeaponTriangle: TRadioButton;
            ACbUnlit: TCheckBox;
            ACbFlat: TCheckBox;
            ACbEnvironment: TCheckBox;
            ACbNoSmoothing: TCheckBox;
            AMaterialEdit: TCustomEdit;
            AApplyNowButton: TButton;
            AApplyImmediatelyCheckBox: TCheckBox;
            const bAssignHandlers: Boolean = True
        );

        procedure RefreshControlsFromSelection();
        procedure ApplyControlsToSelection();
        procedure ApplyMaterialFromEdit();
        procedure EditorControlClick(Sender: TObject);
        procedure MaterialEditChange(Sender: TObject);
        procedure ViewerSelectionChanged(Sender: TObject);
        procedure ViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
        function SaveModel(): Boolean;
        function SaveModelAs(const FileName: string): Boolean;

        property LastError: string read lastErrorValue;
    end;

implementation

type
    TCustomEditAccess = class(TCustomEdit);

const
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

constructor TDXMeshFlagsEditor.Create();
begin
    inherited Create();
    modelValue := nil;
    viewerValue := nil;

    rbNormalValue := nil;
    rbTwoSidedValue := nil;
    rbTranslucentValue := nil;
    rbMaskedValue := nil;
    rbModulatedValue := nil;
    rbWeaponTriangleValue := nil;

    cbUnlitValue := nil;
    cbFlatValue := nil;
    cbEnvironmentValue := nil;
    cbNoSmoothingValue := nil;

    materialEditValue := nil;
    applyNowButtonValue := nil;
    applyImmediatelyCheckBoxValue := nil;
    bPendingApplyValue := False;

    updateLockCountValue := 0;
    lastErrorValue := '';
end;

procedure TDXMeshFlagsEditor.Attach(AModel: TDXUnreal3DModel; AViewer: TDXMeshViewer);
begin
    modelValue := AModel;
    viewerValue := AViewer;
end;

procedure TDXMeshFlagsEditor.WireClickHandler(const RadioButton: TRadioButton; const bAssign: Boolean);
begin
    if RadioButton = nil then
    begin
        Exit;
    end;

    if bAssign = True then
    begin
        RadioButton.OnClick := EditorControlClick;
    end;
end;

procedure TDXMeshFlagsEditor.WireCheckBoxHandler(const CheckBox: TCheckBox; const bAssign: Boolean);
begin
    if CheckBox = nil then
    begin
        Exit;
    end;

    CheckBox.AllowGrayed := False;
    if bAssign = True then
    begin
        CheckBox.OnClick := EditorControlClick;
    end;
end;

function TDXMeshFlagsEditor.GetApplyImmediately(): Boolean;
begin
    Result := True;
    if applyImmediatelyCheckBoxValue <> nil then
    begin
        Result := applyImmediatelyCheckBoxValue.Checked;
    end;
end;

procedure TDXMeshFlagsEditor.UpdateApplyControlsState();
var
    bHasSelection: Boolean;
begin
    bHasSelection := False;

    if viewerValue <> nil then
    begin
        if viewerValue.SelectionCount > 0 then
        begin
            bHasSelection := True;
        end
        else if viewerValue.SelectedTriangleIndex >= 0 then
        begin
            bHasSelection := True;
        end;
    end;

    if applyNowButtonValue <> nil then
    begin
        applyNowButtonValue.Enabled :=
            (bHasSelection = True) and
            (bPendingApplyValue = True) and
            (GetApplyImmediately() = False);
    end;
end;

procedure TDXMeshFlagsEditor.MarkPendingOrApply();
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    if GetApplyImmediately() = True then
    begin
        ApplyControlsToSelection();
    end
    else
    begin
        bPendingApplyValue := True;
        UpdateApplyControlsState();
    end;
end;

procedure TDXMeshFlagsEditor.ApplyNowButtonClick(Sender: TObject);
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    ApplyControlsToSelection();
end;

procedure TDXMeshFlagsEditor.ApplyImmediatelyCheckBoxClick(Sender: TObject);
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    if GetApplyImmediately() = True then
    begin
        if bPendingApplyValue = True then
        begin
            ApplyControlsToSelection();
        end
        else
        begin
            UpdateApplyControlsState();
        end;
    end
    else
    begin
        UpdateApplyControlsState();
    end;
end;

procedure TDXMeshFlagsEditor.AssignControls(
    ARbNormal: TRadioButton;
    ARbTwoSided: TRadioButton;
    ARbTranslucent: TRadioButton;
    ARbMasked: TRadioButton;
    ARbModulated: TRadioButton;
    ARbWeaponTriangle: TRadioButton;
    ACbUnlit: TCheckBox;
    ACbFlat: TCheckBox;
    ACbEnvironment: TCheckBox;
    ACbNoSmoothing: TCheckBox;
    AMaterialEdit: TCustomEdit;
    AApplyNowButton: TButton;
    AApplyImmediatelyCheckBox: TCheckBox;
    const bAssignHandlers: Boolean
);
begin
    if AMaterialEdit = nil then
    begin
        raise Exception.Create('AMaterialEdit must not be nil.');
    end;

    rbNormalValue := ARbNormal;
    rbTwoSidedValue := ARbTwoSided;
    rbTranslucentValue := ARbTranslucent;
    rbMaskedValue := ARbMasked;
    rbModulatedValue := ARbModulated;
    rbWeaponTriangleValue := ARbWeaponTriangle;

    cbUnlitValue := ACbUnlit;
    cbFlatValue := ACbFlat;
    cbEnvironmentValue := ACbEnvironment;
    cbNoSmoothingValue := ACbNoSmoothing;

    materialEditValue := AMaterialEdit;
    applyNowButtonValue := AApplyNowButton;
    applyImmediatelyCheckBoxValue := AApplyImmediatelyCheckBox;

    WireClickHandler(rbNormalValue, bAssignHandlers);
    WireClickHandler(rbTwoSidedValue, bAssignHandlers);
    WireClickHandler(rbTranslucentValue, bAssignHandlers);
    WireClickHandler(rbMaskedValue, bAssignHandlers);
    WireClickHandler(rbModulatedValue, bAssignHandlers);
    WireClickHandler(rbWeaponTriangleValue, bAssignHandlers);

    WireCheckBoxHandler(cbUnlitValue, bAssignHandlers);
    WireCheckBoxHandler(cbFlatValue, bAssignHandlers);
    WireCheckBoxHandler(cbEnvironmentValue, bAssignHandlers);
    WireCheckBoxHandler(cbNoSmoothingValue, bAssignHandlers);

    if bAssignHandlers = True then
    begin
        TCustomEditAccess(materialEditValue).OnChange := MaterialEditChange;

        if applyNowButtonValue <> nil then
        begin
            applyNowButtonValue.OnClick := ApplyNowButtonClick;
        end;

        if applyImmediatelyCheckBoxValue <> nil then
        begin
            applyImmediatelyCheckBoxValue.OnClick := ApplyImmediatelyCheckBoxClick;
        end;
    end;

    bPendingApplyValue := False;
    RefreshControlsFromSelection();
end;

procedure TDXMeshFlagsEditor.BeginUpdateControls();
begin
    Inc(updateLockCountValue);
end;

procedure TDXMeshFlagsEditor.EndUpdateControls();
begin
    if updateLockCountValue > 0 then
    begin
        Dec(updateLockCountValue);
    end;
end;

function TDXMeshFlagsEditor.IsUpdatingControls(): Boolean;
begin
    Result := updateLockCountValue > 0;
end;

procedure TDXMeshFlagsEditor.SetControlsEnabled(const bEnabled: Boolean);
begin
    if rbNormalValue <> nil then
    begin
        rbNormalValue.Enabled := bEnabled;
    end;

    if rbTwoSidedValue <> nil then
    begin
        rbTwoSidedValue.Enabled := bEnabled;
    end;

    if rbTranslucentValue <> nil then
    begin
        rbTranslucentValue.Enabled := bEnabled;
    end;

    if rbMaskedValue <> nil then
    begin
        rbMaskedValue.Enabled := bEnabled;
    end;

    if rbModulatedValue <> nil then
    begin
        rbModulatedValue.Enabled := bEnabled;
    end;

    if rbWeaponTriangleValue <> nil then
    begin
        rbWeaponTriangleValue.Enabled := bEnabled;
    end;

    if cbUnlitValue <> nil then
    begin
        cbUnlitValue.Enabled := bEnabled;
    end;

    if cbFlatValue <> nil then
    begin
        cbFlatValue.Enabled := bEnabled;
    end;

    if cbEnvironmentValue <> nil then
    begin
        cbEnvironmentValue.Enabled := bEnabled;
    end;

    if cbNoSmoothingValue <> nil then
    begin
        cbNoSmoothingValue.Enabled := bEnabled;
    end;

    if materialEditValue <> nil then
    begin
        materialEditValue.Enabled := bEnabled;
    end;

    UpdateApplyControlsState();
end;

function TDXMeshFlagsEditor.GetSelectedTriangleIndices(): TArray<Integer>;
var
    i: Integer;
    writeIndex: Integer;
begin
    SetLength(Result, 0);

    if (modelValue = nil) or (viewerValue = nil) then
    begin
        Exit;
    end;

    if modelValue.TriangleCount <= 0 then
    begin
        Exit;
    end;

    SetLength(Result, viewerValue.SelectionCount);
    writeIndex := 0;

    for i := 0 to modelValue.TriangleCount - 1 do
    begin
        if viewerValue.TriangleSelected[i] = True then
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
end;

procedure TDXMeshFlagsEditor.SetRadioButtonsFromBaseType(BaseType: Integer; const bMixed: Boolean);
begin
    if rbNormalValue <> nil then
    begin
        rbNormalValue.Checked := False;
    end;

    if rbTwoSidedValue <> nil then
    begin
        rbTwoSidedValue.Checked := False;
    end;

    if rbTranslucentValue <> nil then
    begin
        rbTranslucentValue.Checked := False;
    end;

    if rbMaskedValue <> nil then
    begin
        rbMaskedValue.Checked := False;
    end;

    if rbModulatedValue <> nil then
    begin
        rbModulatedValue.Checked := False;
    end;

    if rbWeaponTriangleValue <> nil then
    begin
        rbWeaponTriangleValue.Checked := False;
    end;

    if bMixed = True then
    begin
        Exit;
    end;

    if (BaseType = MTT_Normal) and (rbNormalValue <> nil) then
    begin
        rbNormalValue.Checked := True;
    end
    else if (BaseType = MTT_NormalTwoSided) and (rbTwoSidedValue <> nil) then
    begin
        rbTwoSidedValue.Checked := True;
    end
    else if (BaseType = MTT_Translucent) and (rbTranslucentValue <> nil) then
    begin
        rbTranslucentValue.Checked := True;
    end
    else if (BaseType = MTT_Masked) and (rbMaskedValue <> nil) then
    begin
        rbMaskedValue.Checked := True;
    end
    else if (BaseType = MTT_Modulate) and (rbModulatedValue <> nil) then
    begin
        rbModulatedValue.Checked := True;
    end
    else if (BaseType = MTT_Placeholder) and (rbWeaponTriangleValue <> nil) then
    begin
        rbWeaponTriangleValue.Checked := True;
    end;
end;

function TDXMeshFlagsEditor.GetSelectedBaseType(out BaseType: Byte): Boolean;
begin
    Result := True;
    BaseType := MTT_Normal;

    if (rbNormalValue <> nil) and (rbNormalValue.Checked = True) then
    begin
        BaseType := MTT_Normal;
        Exit;
    end;

    if (rbTwoSidedValue <> nil) and (rbTwoSidedValue.Checked = True) then
    begin
        BaseType := MTT_NormalTwoSided;
        Exit;
    end;

    if (rbTranslucentValue <> nil) and (rbTranslucentValue.Checked = True) then
    begin
        BaseType := MTT_Translucent;
        Exit;
    end;

    if (rbMaskedValue <> nil) and (rbMaskedValue.Checked = True) then
    begin
        BaseType := MTT_Masked;
        Exit;
    end;

    if (rbModulatedValue <> nil) and (rbModulatedValue.Checked = True) then
    begin
        BaseType := MTT_Modulate;
        Exit;
    end;

    if (rbWeaponTriangleValue <> nil) and (rbWeaponTriangleValue.Checked = True) then
    begin
        BaseType := MTT_Placeholder;
        Exit;
    end;

    Result := False;
end;

procedure TDXMeshFlagsEditor.SetCheckBoxState(CheckBox: TCheckBox; State: TCheckBoxState);
begin
    if CheckBox = nil then
    begin
        Exit;
    end;

    if State = cbGrayed then
    begin
        CheckBox.AllowGrayed := True;
        CheckBox.State := cbGrayed;
    end
    else
    begin
        CheckBox.AllowGrayed := False;
        CheckBox.State := State;
    end;
end;

procedure TDXMeshFlagsEditor.UpdateBitState(var StateValue: Integer; const bBitSet: Boolean);
begin
    if StateValue < 0 then
    begin
        if bBitSet = True then
        begin
            StateValue := 1;
        end
        else
        begin
            StateValue := 0;
        end;
        Exit;
    end;

    if StateValue >= 2 then
    begin
        Exit;
    end;

    if (bBitSet = True) and (StateValue = 0) then
    begin
        StateValue := 2;
    end
    else if (bBitSet = False) and (StateValue = 1) then
    begin
        StateValue := 2;
    end;
end;

procedure TDXMeshFlagsEditor.UpdateMaterialEditFromSelection(const SelectedIndices: TArray<Integer>);
var
    i: Integer;
    materialValue: Integer;
    bMixed: Boolean;
begin
    if materialEditValue = nil then
    begin
        Exit;
    end;

    if Length(SelectedIndices) <= 0 then
    begin
        materialEditValue.Text := '';
        Exit;
    end;

    materialValue := modelValue.Triangles[SelectedIndices[0]].TextureIndex;
    bMixed := False;

    for i := 1 to High(SelectedIndices) do
    begin
        if modelValue.Triangles[SelectedIndices[i]].TextureIndex <> materialValue then
        begin
            bMixed := True;
            Break;
        end;
    end;

    if bMixed = True then
    begin
        materialEditValue.Text := '';
    end
    else
    begin
        materialEditValue.Text := IntToStr(materialValue);
    end;
end;

procedure TDXMeshFlagsEditor.RefreshControlsFromSelection();
var
    selectedIndices: TArray<Integer>;
    i: Integer;
    triangleIndex: Integer;
    baseTypeValue: Integer;
    firstBaseTypeValue: Integer;
    bBaseTypeMixed: Boolean;
    unlitState: Integer;
    flatState: Integer;
    environmentState: Integer;
    noSmoothState: Integer;
    typeByteValue: Byte;
begin
    BeginUpdateControls();
    try
        selectedIndices := GetSelectedTriangleIndices();
        SetControlsEnabled(Length(selectedIndices) > 0);

        if Length(selectedIndices) <= 0 then
        begin
            SetRadioButtonsFromBaseType(0, True);
            SetCheckBoxState(cbUnlitValue, cbGrayed);
            SetCheckBoxState(cbFlatValue, cbGrayed);
            SetCheckBoxState(cbEnvironmentValue, cbGrayed);
            SetCheckBoxState(cbNoSmoothingValue, cbGrayed);
            if materialEditValue <> nil then
            begin
                materialEditValue.Text := '';
            end;
            Exit;
        end;

        firstBaseTypeValue := -1;
        bBaseTypeMixed := False;
        unlitState := -1;
        flatState := -1;
        environmentState := -1;
        noSmoothState := -1;

        for i := 0 to High(selectedIndices) do
        begin
            triangleIndex := selectedIndices[i];
            typeByteValue := modelValue.Triangles[triangleIndex].RawTypeByte;
            baseTypeValue := typeByteValue and $0F;

            if firstBaseTypeValue < 0 then
            begin
                firstBaseTypeValue := baseTypeValue;
            end
            else if firstBaseTypeValue <> baseTypeValue then
            begin
                bBaseTypeMixed := True;
            end;

            UpdateBitState(unlitState, (typeByteValue and MTT_Unlit) <> 0);
            UpdateBitState(flatState, (typeByteValue and MTT_Flat) <> 0);
            UpdateBitState(environmentState, (typeByteValue and MTT_Environment) <> 0);
            UpdateBitState(noSmoothState, (typeByteValue and MTT_NoSmooth) <> 0);
        end;

        SetRadioButtonsFromBaseType(firstBaseTypeValue, bBaseTypeMixed);

        if unlitState = 0 then
        begin
            SetCheckBoxState(cbUnlitValue, cbUnchecked);
        end
        else if unlitState = 1 then
        begin
            SetCheckBoxState(cbUnlitValue, cbChecked);
        end
        else
        begin
            SetCheckBoxState(cbUnlitValue, cbGrayed);
        end;

        if flatState = 0 then
        begin
            SetCheckBoxState(cbFlatValue, cbUnchecked);
        end
        else if flatState = 1 then
        begin
            SetCheckBoxState(cbFlatValue, cbChecked);
        end
        else
        begin
            SetCheckBoxState(cbFlatValue, cbGrayed);
        end;

        if environmentState = 0 then
        begin
            SetCheckBoxState(cbEnvironmentValue, cbUnchecked);
        end
        else if environmentState = 1 then
        begin
            SetCheckBoxState(cbEnvironmentValue, cbChecked);
        end
        else
        begin
            SetCheckBoxState(cbEnvironmentValue, cbGrayed);
        end;

        if noSmoothState = 0 then
        begin
            SetCheckBoxState(cbNoSmoothingValue, cbUnchecked);
        end
        else if noSmoothState = 1 then
        begin
            SetCheckBoxState(cbNoSmoothingValue, cbChecked);
        end
        else
        begin
            SetCheckBoxState(cbNoSmoothingValue, cbGrayed);
        end;

        UpdateMaterialEditFromSelection(selectedIndices);
        bPendingApplyValue := False;
        UpdateApplyControlsState();
    finally
        EndUpdateControls();
    end;
end;

procedure TDXMeshFlagsEditor.ApplyCheckBoxBit(CheckBox: TCheckBox; BitMask: Byte; var TypeByte: Byte);
begin
    if CheckBox = nil then
    begin
        Exit;
    end;

    if CheckBox.State = cbGrayed then
    begin
        Exit;
    end;

    if CheckBox.State = cbChecked then
    begin
        TypeByte := TypeByte or BitMask;
    end
    else
    begin
        TypeByte := TypeByte and Byte(not BitMask);
    end;
end;

procedure TDXMeshFlagsEditor.ApplyControlsToSelection();
var
    selectedIndices: TArray<Integer>;
    i: Integer;
    triangleIndex: Integer;
    currentTypeByte: Byte;
    newTypeByte: Byte;
    baseTypeValue: Byte;
    bBaseTypeSelected: Boolean;
    materialIndexValue: Integer;
    bMaterialAssigned: Boolean;
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    if (modelValue = nil) or (viewerValue = nil) then
    begin
        Exit;
    end;

    selectedIndices := GetSelectedTriangleIndices();
    if Length(selectedIndices) <= 0 then
    begin
        Exit;
    end;

    bBaseTypeSelected := GetSelectedBaseType(baseTypeValue);

    bMaterialAssigned := False;
    if materialEditValue <> nil then
    begin
        if Trim(materialEditValue.Text) <> '' then
        begin
            bMaterialAssigned := TryStrToInt(Trim(materialEditValue.Text), materialIndexValue);
        end;
    end;

    modelValue.BeginUpdate();
    try
        for i := 0 to High(selectedIndices) do
        begin
            triangleIndex := selectedIndices[i];
            currentTypeByte := modelValue.Triangles[triangleIndex].RawTypeByte;
            newTypeByte := currentTypeByte;

            if bBaseTypeSelected = True then
            begin
                newTypeByte := (newTypeByte and $F0) or (baseTypeValue and $0F);
            end;

            ApplyCheckBoxBit(cbUnlitValue, MTT_Unlit, newTypeByte);
            ApplyCheckBoxBit(cbFlatValue, MTT_Flat, newTypeByte);
            ApplyCheckBoxBit(cbEnvironmentValue, MTT_Environment, newTypeByte);
            ApplyCheckBoxBit(cbNoSmoothingValue, MTT_NoSmooth, newTypeByte);

            if newTypeByte <> currentTypeByte then
            begin
                modelValue.SetTriangleRawTypeByte(triangleIndex, newTypeByte);
            end;

            if bMaterialAssigned = True then
            begin
                modelValue.SetTriangleTextureIndex(triangleIndex, materialIndexValue);
            end;
        end;
    finally
        modelValue.EndUpdate();
    end;

    bPendingApplyValue := False;
    UpdateApplyControlsState();

    if viewerValue <> nil then
    begin
        viewerValue.RenderNow();
    end;

    RefreshControlsFromSelection();
end;

procedure TDXMeshFlagsEditor.ApplyMaterialFromEdit();
begin
    ApplyControlsToSelection();
end;

procedure TDXMeshFlagsEditor.EditorControlClick(Sender: TObject);
var
    checkBox: TCheckBox;
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    if Sender is TCheckBox then
    begin
        checkBox := TCheckBox(Sender);
        if checkBox.State = cbGrayed then
        begin
            checkBox.AllowGrayed := False;
            checkBox.State := cbChecked;
        end;
    end;

    MarkPendingOrApply();
end;

procedure TDXMeshFlagsEditor.MaterialEditChange(Sender: TObject);
begin
    if IsUpdatingControls() = True then
    begin
        Exit;
    end;

    MarkPendingOrApply();
end;

procedure TDXMeshFlagsEditor.ViewerSelectionChanged(Sender: TObject);
begin
    RefreshControlsFromSelection();
end;

procedure TDXMeshFlagsEditor.ViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
begin
    RefreshControlsFromSelection();
end;

function TDXMeshFlagsEditor.SaveModel(): Boolean;
begin
    lastErrorValue := '';

    if modelValue = nil then
    begin
        lastErrorValue := 'Модель не подключена';
        Result := False;
        Exit;
    end;

    if (GetApplyImmediately() = False) and (bPendingApplyValue = True) then
    begin
        ApplyControlsToSelection();
    end;

    Result := modelValue.SaveData();
    if Result = False then
    begin
        lastErrorValue := modelValue.LastError;
    end;
end;

function TDXMeshFlagsEditor.SaveModelAs(const FileName: string): Boolean;
begin
    lastErrorValue := '';

    if modelValue = nil then
    begin
        lastErrorValue := 'Модель не подключена';
        Result := False;
        Exit;
    end;

    if (GetApplyImmediately() = False) and (bPendingApplyValue = True) then
    begin
        ApplyControlsToSelection();
    end;

    Result := modelValue.SaveDataToFile(FileName);
    if Result = False then
    begin
        lastErrorValue := modelValue.LastError;
    end;
end;

end.


