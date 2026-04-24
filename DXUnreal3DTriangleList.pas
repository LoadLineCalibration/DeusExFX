unit DXUnreal3DTriangleList;

interface

uses
    Winapi.Windows,
    Winapi.Messages,
    Winapi.CommCtrl,
    System.SysUtils,
    System.Classes,
    Vcl.Graphics,
    Vcl.ComCtrls,
    Vcl.ExtCtrls,
    DXUnreal3DModel,
    DXUnreal3DView;

type
    TDXMeshTriangleListBinder = class
    private
        modelValue: TDXUnreal3DModel;
        viewerValue: TDXMeshViewer;
        listViewValue: TListView;

        updateLockCountValue: Integer;
        lastViewerSelectionValue: TArray<Boolean>;
        lastActiveTriangleIndexValue: Integer;
        selectionApplyTimerValue: TTimer;
        bSelectionApplyPendingValue: Boolean;

        columnColorsValue: array[0..6] of TColor;
        columnAlignmentsValue: array[0..6] of TAlignment;

        normalTextColorValue: TColor;
        selectedFocusedBackColorValue: TColor;
        selectedFocusedTextColorValue: TColor;
        selectedUnfocusedBackColorValue: TColor;
        selectedUnfocusedTextColorValue: TColor;
        separatorColorValue: TColor;

        previousViewerSelectionChangedValue: TNotifyEvent;
        previousViewerTriangleSelectedValue: TDXTriangleSelectedEvent;
        previousListViewSelectItemValue: TLVSelectItemEvent;
        previousModelChangedValue: TNotifyEvent;

        procedure BeginUpdate();
        procedure EndUpdate();
        function IsUpdating(): Boolean;
        procedure SetListViewRedraw(const bEnabled: Boolean);
        procedure EnsureSelectionCacheSize();
        procedure FillItemFromTriangle(Item: TListItem; TriangleIndex: Integer; const Triangle: TDXMeshTriangle);
        procedure RefreshRows();
        procedure RefreshChangedRows(const ChangedIndices: TArray<Integer>);
        procedure ScheduleApplySelectionToViewer();
        procedure SelectionApplyTimer(Sender: TObject);

        procedure ApplyDefaultColumnColors();
        procedure ApplyDefaultColumnAlignments();
        procedure ApplyDefaultDrawColors();

        procedure GetColumnRect(Item: TListItem; ColumnIndex: Integer; out cellRect: TRect);
        function IsListViewActuallyFocused(): Boolean;
        procedure GetCellColors(Item: TListItem; out backColor: TColor; out textColor: TColor; ColumnIndex: Integer);
        function GetColumnDrawFlags(ColumnIndex: Integer): Cardinal;
        procedure DrawColumnSeparator(const cellRect: TRect);
        procedure DrawColumnCell(Item: TListItem; ColumnIndex: Integer; const Text: string; State: TCustomDrawState);
        procedure DrawItemRow(Item: TListItem; State: TCustomDrawState);

        procedure InternalAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
        procedure InternalAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);

        procedure InternalViewerSelectionChanged(Sender: TObject);
        procedure InternalViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
        procedure InternalListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
        procedure InternalModelChanged(Sender: TObject);

        function BuildStyleTypeText(const Triangle: TDXMeshTriangle): string;
        function BuildFlagsText(const Triangle: TDXMeshTriangle): string;
        function GetActiveTriangleIndexFromListView(): Integer;

        procedure SetColumnColor(ColumnIndex: Integer; AColor: TColor);
        function GetColumnColor(ColumnIndex: Integer): TColor;
        procedure SetColumnAlignment(ColumnIndex: Integer; AAlignment: TAlignment);
        function GetColumnAlignment(ColumnIndex: Integer): TAlignment;

        procedure SetNormalTextColor(AColor: TColor);
        procedure SetSelectedFocusedBackColor(AColor: TColor);
        procedure SetSelectedFocusedTextColor(AColor: TColor);
        procedure SetSelectedUnfocusedBackColor(AColor: TColor);
        procedure SetSelectedUnfocusedTextColor(AColor: TColor);
        procedure SetSeparatorColor(AColor: TColor);
    public
        constructor Create();
        destructor Destroy(); override;

        procedure Attach(AModel: TDXUnreal3DModel; AViewer: TDXMeshViewer; AListView: TListView);
        procedure SetupColumns();
        procedure RefreshAll();
        procedure RefreshSelectionFromViewer();
        procedure ApplySelectionToViewer();

        property ColumnColor[ColumnIndex: Integer]: TColor read GetColumnColor write SetColumnColor;
        property ColumnAlignment[ColumnIndex: Integer]: TAlignment read GetColumnAlignment write SetColumnAlignment;

        property NormalTextColor: TColor read normalTextColorValue write SetNormalTextColor;
        property SelectedFocusedBackColor: TColor read selectedFocusedBackColorValue write SetSelectedFocusedBackColor;
        property SelectedFocusedTextColor: TColor read selectedFocusedTextColorValue write SetSelectedFocusedTextColor;
        property SelectedUnfocusedBackColor: TColor read selectedUnfocusedBackColorValue write SetSelectedUnfocusedBackColor;
        property SelectedUnfocusedTextColor: TColor read selectedUnfocusedTextColorValue write SetSelectedUnfocusedTextColor;
        property SeparatorColor: TColor read separatorColorValue write SetSeparatorColor;
    end;

implementation

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

constructor TDXMeshTriangleListBinder.Create();
begin
    inherited Create();
    modelValue := nil;
    viewerValue := nil;
    listViewValue := nil;

    updateLockCountValue := 0;
    SetLength(lastViewerSelectionValue, 0);
    lastActiveTriangleIndexValue := -1;

    previousViewerSelectionChangedValue := nil;
    previousViewerTriangleSelectedValue := nil;
    previousListViewSelectItemValue := nil;
    previousModelChangedValue := nil;

    selectionApplyTimerValue := TTimer.Create(nil);
    selectionApplyTimerValue.Enabled := False;
    selectionApplyTimerValue.Interval := 1;
    selectionApplyTimerValue.OnTimer := SelectionApplyTimer;
    bSelectionApplyPendingValue := False;

    ApplyDefaultColumnColors();
    ApplyDefaultColumnAlignments();
    ApplyDefaultDrawColors();
end;

destructor TDXMeshTriangleListBinder.Destroy();
begin
    selectionApplyTimerValue.Free();
    inherited Destroy();
end;

procedure TDXMeshTriangleListBinder.ApplyDefaultColumnColors();
begin
    columnColorsValue[0] := $F8F8FF;
    columnColorsValue[1] := $FFF8F2;
    columnColorsValue[2] := $F4FFF4;
    columnColorsValue[3] := $F6FAFF;
    columnColorsValue[4] := $FFFDF0;
    columnColorsValue[5] := $F8F4FF;
    columnColorsValue[6] := $F2FFFF;
end;

procedure TDXMeshTriangleListBinder.ApplyDefaultColumnAlignments();
begin
    columnAlignmentsValue[0] := taCenter;
    columnAlignmentsValue[1] := taCenter;
    columnAlignmentsValue[2] := taCenter;
    columnAlignmentsValue[3] := taCenter;
    columnAlignmentsValue[4] := taCenter;
    columnAlignmentsValue[5] := taLeftJustify;
    columnAlignmentsValue[6] := taLeftJustify;
end;

procedure TDXMeshTriangleListBinder.ApplyDefaultDrawColors();
begin
    normalTextColorValue := clWindowText;
    selectedFocusedBackColorValue := clHighlight;
    selectedFocusedTextColorValue := clHighlightText;
    selectedUnfocusedBackColorValue := $00D8D8D8;
    selectedUnfocusedTextColorValue := clWindowText;
    separatorColorValue := $00E7E7E7;
end;

procedure TDXMeshTriangleListBinder.SetColumnColor(ColumnIndex: Integer; AColor: TColor);
begin
    if (ColumnIndex < Low(columnColorsValue)) or (ColumnIndex > High(columnColorsValue)) then
    begin
        Exit;
    end;

    columnColorsValue[ColumnIndex] := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

function TDXMeshTriangleListBinder.GetColumnColor(ColumnIndex: Integer): TColor;
begin
    if (ColumnIndex < Low(columnColorsValue)) or (ColumnIndex > High(columnColorsValue)) then
    begin
        Result := clWhite;
        Exit;
    end;

    Result := columnColorsValue[ColumnIndex];
end;

procedure TDXMeshTriangleListBinder.SetColumnAlignment(ColumnIndex: Integer; AAlignment: TAlignment);
begin
    if (ColumnIndex < Low(columnAlignmentsValue)) or (ColumnIndex > High(columnAlignmentsValue)) then
    begin
        Exit;
    end;

    columnAlignmentsValue[ColumnIndex] := AAlignment;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

function TDXMeshTriangleListBinder.GetColumnAlignment(ColumnIndex: Integer): TAlignment;
begin
    if (ColumnIndex < Low(columnAlignmentsValue)) or (ColumnIndex > High(columnAlignmentsValue)) then
    begin
        Result := taLeftJustify;
        Exit;
    end;

    Result := columnAlignmentsValue[ColumnIndex];
end;

procedure TDXMeshTriangleListBinder.SetNormalTextColor(AColor: TColor);
begin
    normalTextColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.SetSelectedFocusedBackColor(AColor: TColor);
begin
    selectedFocusedBackColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.SetSelectedFocusedTextColor(AColor: TColor);
begin
    selectedFocusedTextColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.SetSelectedUnfocusedBackColor(AColor: TColor);
begin
    selectedUnfocusedBackColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.SetSelectedUnfocusedTextColor(AColor: TColor);
begin
    selectedUnfocusedTextColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.SetSeparatorColor(AColor: TColor);
begin
    separatorColorValue := AColor;
    if listViewValue <> nil then
    begin
        listViewValue.Invalidate();
    end;
end;

procedure TDXMeshTriangleListBinder.GetColumnRect(Item: TListItem; ColumnIndex: Integer; out cellRect: TRect);
var
    rowRect: TRect;
    leftPosValue: Integer;
    i: Integer;
    bResult: Boolean;
begin
    cellRect := Rect(0, 0, 0, 0);

    if (listViewValue = nil) or (Item = nil) then
    begin
        Exit;
    end;

    if ColumnIndex <= 0 then
    begin
        cellRect := Item.DisplayRect(drBounds);
        if listViewValue.Columns.Count > 0 then
        begin
            cellRect.Right := cellRect.Left + listViewValue.Columns[0].Width;
        end;
        Exit;
    end;

    cellRect.Top := ColumnIndex;
    cellRect.Left := LVIR_BOUNDS;
    bResult := SendMessage(listViewValue.Handle, LVM_GETSUBITEMRECT, WPARAM(Item.Index), LPARAM(@cellRect)) <> 0;
    if bResult = True then
    begin
        Exit;
    end;

    rowRect := Item.DisplayRect(drBounds);
    leftPosValue := rowRect.Left;

    for i := 0 to ColumnIndex - 1 do
    begin
        if i < listViewValue.Columns.Count then
        begin
            Inc(leftPosValue, listViewValue.Columns[i].Width);
        end;
    end;

    cellRect := rowRect;
    cellRect.Left := leftPosValue;

    if ColumnIndex < listViewValue.Columns.Count then
    begin
        cellRect.Right := cellRect.Left + listViewValue.Columns[ColumnIndex].Width;
    end
    else
    begin
        cellRect.Right := cellRect.Left;
    end;
end;

function TDXMeshTriangleListBinder.IsListViewActuallyFocused(): Boolean;
begin
    Result := False;

    if (listViewValue <> nil) and (listViewValue.HandleAllocated = True) then
    begin
        Result := GetFocus() = listViewValue.Handle;
    end;
end;

procedure TDXMeshTriangleListBinder.GetCellColors(Item: TListItem; out backColor: TColor; out textColor: TColor; ColumnIndex: Integer);
var
    bItemSelectedValue: Boolean;
    bListFocusedValue: Boolean;
begin
    bItemSelectedValue := False;
    if Item <> nil then
    begin
        bItemSelectedValue := Item.Selected;
    end;

    bListFocusedValue := IsListViewActuallyFocused();

    if bItemSelectedValue = True then
    begin
        if bListFocusedValue = True then
        begin
            backColor := selectedFocusedBackColorValue;
            textColor := selectedFocusedTextColorValue;
        end
        else
        begin
            backColor := selectedUnfocusedBackColorValue;
            textColor := selectedUnfocusedTextColorValue;
        end;
    end
    else
    begin
        if (ColumnIndex >= Low(columnColorsValue)) and (ColumnIndex <= High(columnColorsValue)) then
        begin
            backColor := columnColorsValue[ColumnIndex];
        end
        else
        begin
            backColor := clWhite;
        end;

        textColor := normalTextColorValue;
    end;
end;

function TDXMeshTriangleListBinder.GetColumnDrawFlags(ColumnIndex: Integer): Cardinal;
begin
    Result := DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;

    case GetColumnAlignment(ColumnIndex) of
        taLeftJustify:
            Result := Result or DT_LEFT;
        taRightJustify:
            Result := Result or DT_RIGHT;
    else
        Result := Result or DT_CENTER;
    end;
end;

procedure TDXMeshTriangleListBinder.DrawColumnSeparator(const cellRect: TRect);
var
    xValue: Integer;
begin
    if listViewValue = nil then
    begin
        Exit;
    end;

    xValue := cellRect.Right - 1;
    if xValue < cellRect.Left then
    begin
        Exit;
    end;

    listViewValue.Canvas.Pen.Color := separatorColorValue;
    listViewValue.Canvas.MoveTo(xValue, cellRect.Top);
    listViewValue.Canvas.LineTo(xValue, cellRect.Bottom);
end;

procedure TDXMeshTriangleListBinder.DrawColumnCell(Item: TListItem; ColumnIndex: Integer; const Text: string; State: TCustomDrawState);
var
    cellRect: TRect;
    textRect: TRect;
    drawFlagsValue: Cardinal;
    backColorValue: TColor;
    textColorValue: TColor;
begin
    if (listViewValue = nil) or (Item = nil) then
    begin
        Exit;
    end;

    GetColumnRect(Item, ColumnIndex, cellRect);
    if IsRectEmpty(cellRect) = True then
    begin
        Exit;
    end;

    GetCellColors(Item, backColorValue, textColorValue, ColumnIndex);

    listViewValue.Canvas.Brush.Color := backColorValue;
    listViewValue.Canvas.Font.Color := textColorValue;
    listViewValue.Canvas.FillRect(cellRect);

    textRect := cellRect;
    InflateRect(textRect, -4, 0);

    SetBkMode(listViewValue.Canvas.Handle, TRANSPARENT);

    drawFlagsValue := GetColumnDrawFlags(ColumnIndex);
    DrawText(listViewValue.Canvas.Handle, PChar(Text), Length(Text), textRect, drawFlagsValue);

    DrawColumnSeparator(cellRect);
end;

procedure TDXMeshTriangleListBinder.DrawItemRow(Item: TListItem; State: TCustomDrawState);
var
    columnIndexValue: Integer;
    textValue: string;
    bDrawFocusedRectValue: Boolean;
    focusRectValue: TRect;
begin
    if (listViewValue = nil) or (Item = nil) then
    begin
        Exit;
    end;

    for columnIndexValue := 0 to listViewValue.Columns.Count - 1 do
    begin
        if columnIndexValue = 0 then
        begin
            textValue := Item.Caption;
        end
        else if (columnIndexValue - 1 >= 0) and (columnIndexValue - 1 < Item.SubItems.Count) then
        begin
            textValue := Item.SubItems[columnIndexValue - 1];
        end
        else
        begin
            textValue := '';
        end;

        DrawColumnCell(Item, columnIndexValue, textValue, State);
    end;

    bDrawFocusedRectValue := False;
    if (Item.Focused = True) and (IsListViewActuallyFocused() = True) then
    begin
        bDrawFocusedRectValue := True;
    end;

    if bDrawFocusedRectValue = True then
    begin
        focusRectValue := Item.DisplayRect(drBounds);
        if (listViewValue.Columns.Count > 0) and (listViewValue.Columns[listViewValue.Columns.Count - 1].Width > 0) then
        begin
            GetColumnRect(Item, listViewValue.Columns.Count - 1, focusRectValue);
            focusRectValue.Left := Item.DisplayRect(drBounds).Left;
        end;
        DrawFocusRect(listViewValue.Canvas.Handle, focusRectValue);
    end;
end;

procedure TDXMeshTriangleListBinder.InternalAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
    if (Stage <> cdPrePaint) or (listViewValue = nil) or (Item = nil) then
    begin
        Exit;
    end;

    DrawItemRow(Item, State);
    DefaultDraw := False;
end;

procedure TDXMeshTriangleListBinder.InternalAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
    DefaultDraw := False;
end;

procedure TDXMeshTriangleListBinder.BeginUpdate();
begin
    Inc(updateLockCountValue);
end;

procedure TDXMeshTriangleListBinder.EndUpdate();
begin
    if updateLockCountValue > 0 then
    begin
        Dec(updateLockCountValue);
    end;
end;

function TDXMeshTriangleListBinder.IsUpdating(): Boolean;
begin
    Result := updateLockCountValue > 0;
end;

procedure TDXMeshTriangleListBinder.SetListViewRedraw(const bEnabled: Boolean);
begin
    if (listViewValue <> nil) and (listViewValue.HandleAllocated = True) then
    begin
        if bEnabled = True then
        begin
            SendMessage(listViewValue.Handle, WM_SETREDRAW, WPARAM(1), 0);
            RedrawWindow(listViewValue.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_ERASE);
        end
        else
        begin
            SendMessage(listViewValue.Handle, WM_SETREDRAW, WPARAM(0), 0);
        end;
    end;
end;

procedure TDXMeshTriangleListBinder.EnsureSelectionCacheSize();
var
    itemCountValue: Integer;
begin
    if listViewValue <> nil then
    begin
        itemCountValue := listViewValue.Items.Count;
    end
    else
    begin
        itemCountValue := 0;
    end;

    if Length(lastViewerSelectionValue) <> itemCountValue then
    begin
        SetLength(lastViewerSelectionValue, itemCountValue);
        if Length(lastViewerSelectionValue) > 0 then
        begin
            FillChar(lastViewerSelectionValue[0], Length(lastViewerSelectionValue) * SizeOf(Boolean), 0);
        end;
    end;

    if itemCountValue = 0 then
    begin
        lastActiveTriangleIndexValue := -1;
    end;
end;

procedure TDXMeshTriangleListBinder.Attach(AModel: TDXUnreal3DModel; AViewer: TDXMeshViewer; AListView: TListView);
begin
    modelValue := AModel;
    viewerValue := AViewer;
    listViewValue := AListView;

    if listViewValue <> nil then
    begin
        listViewValue.ViewStyle := vsReport;
        listViewValue.MultiSelect := True;
        listViewValue.ReadOnly := True;
        listViewValue.RowSelect := True;
        listViewValue.HideSelection := False;
        listViewValue.ColumnClick := False;
        listViewValue.DoubleBuffered := True;

        previousListViewSelectItemValue := listViewValue.OnSelectItem;
        listViewValue.OnSelectItem := InternalListViewSelectItem;
        listViewValue.OnAdvancedCustomDrawItem := InternalAdvancedCustomDrawItem;
        listViewValue.OnAdvancedCustomDrawSubItem := InternalAdvancedCustomDrawSubItem;
    end;

    if viewerValue <> nil then
    begin
        previousViewerSelectionChangedValue := viewerValue.OnSelectionChanged;
        previousViewerTriangleSelectedValue := viewerValue.OnTriangleSelected;
        viewerValue.OnSelectionChanged := InternalViewerSelectionChanged;
        viewerValue.OnTriangleSelected := InternalViewerTriangleSelected;
    end;

    if modelValue <> nil then
    begin
        previousModelChangedValue := modelValue.OnChanged;
        modelValue.OnChanged := InternalModelChanged;
    end;

    SetupColumns();
    RefreshAll();
end;

procedure TDXMeshTriangleListBinder.SetupColumns();
var
    columnValue: TListColumn;
begin
    if listViewValue = nil then
    begin
        Exit;
    end;

    listViewValue.Columns.BeginUpdate();
    try
        listViewValue.Columns.Clear();

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'Poly num.';
        columnValue.Width := 80;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'vert A';
        columnValue.Width := 60;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'vert B';
        columnValue.Width := 60;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'vert C';
        columnValue.Width := 60;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'Mat. num';
        columnValue.Width := 70;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'Style/Type';
        columnValue.Width := 190;

        columnValue := listViewValue.Columns.Add();
        columnValue.Caption := 'Flags';
        columnValue.Width := 420;
    finally
        listViewValue.Columns.EndUpdate();
    end;
end;

function TDXMeshTriangleListBinder.BuildStyleTypeText(const Triangle: TDXMeshTriangle): string;
var
    baseTypeValue: Byte;
    extraText: string;

    procedure AppendExtra(const S: string);
    begin
        if extraText <> '' then
        begin
            extraText := extraText + ', ';
        end;

        extraText := extraText + S;
    end;

begin
    baseTypeValue := Triangle.RawTypeByte and $0F;

    case baseTypeValue of
        MTT_Normal:
            Result := 'Normal';
        MTT_NormalTwoSided:
            Result := 'Two sided';
        MTT_Translucent:
            Result := 'Translucent and two sided';
        MTT_Masked:
            Result := 'Masked and two sided';
        MTT_Modulate:
            Result := 'Modulated and two sided';
        MTT_Placeholder:
            Result := 'Weapon triangle';
    else
        Result := 'Unknown(' + IntToStr(baseTypeValue) + ')';
    end;

    extraText := '';

    if (Triangle.RawTypeByte and MTT_Unlit) <> 0 then
    begin
        AppendExtra('Unlit');
    end;

    if (Triangle.RawTypeByte and MTT_Flat) <> 0 then
    begin
        AppendExtra('Flat');
    end;

    if (Triangle.RawTypeByte and MTT_Environment) <> 0 then
    begin
        AppendExtra('Environment mapped');
    end;

    if (Triangle.RawTypeByte and MTT_NoSmooth) <> 0 then
    begin
        AppendExtra('No smoothing');
    end;

    if extraText <> '' then
    begin
        Result := Result + ' [' + extraText + ']';
    end;

    Result := Result + '  ($' + IntToHex(Triangle.RawTypeByte, 2) + ')';
end;

function TDXMeshTriangleListBinder.BuildFlagsText(const Triangle: TDXMeshTriangle): string;
begin
    Result := '$' + IntToHex(Triangle.PolyFlags, 8) + '  ' + PolyFlagsToText(Triangle.PolyFlags);
end;

procedure TDXMeshTriangleListBinder.FillItemFromTriangle(Item: TListItem; TriangleIndex: Integer; const Triangle: TDXMeshTriangle);
begin
    if Item = nil then
    begin
        Exit;
    end;

    Item.Caption := IntToStr(TriangleIndex);

    while Item.SubItems.Count < 6 do
    begin
        Item.SubItems.Add('');
    end;

    Item.SubItems[0] := IntToStr(Triangle.iVertex[0]);
    Item.SubItems[1] := IntToStr(Triangle.iVertex[1]);
    Item.SubItems[2] := IntToStr(Triangle.iVertex[2]);
    Item.SubItems[3] := IntToStr(Triangle.TextureIndex);
    Item.SubItems[4] := BuildStyleTypeText(Triangle);
    Item.SubItems[5] := BuildFlagsText(Triangle);
    Item.Data := Pointer(NativeInt(TriangleIndex));
end;

procedure TDXMeshTriangleListBinder.RefreshRows();
var
    triangleIndex: Integer;
    triangleValue: TDXMeshTriangle;
    itemValue: TListItem;
begin
    if listViewValue = nil then
    begin
        Exit;
    end;

    BeginUpdate();
    listViewValue.Items.BeginUpdate();
    SetListViewRedraw(False);
    try
        if modelValue = nil then
        begin
            listViewValue.Items.Clear();
        end
        else
        begin
            if listViewValue.Items.Count <> modelValue.TriangleCount then
            begin
                listViewValue.Items.Clear();
                for triangleIndex := 0 to modelValue.TriangleCount - 1 do
                begin
                    triangleValue := modelValue.Triangles[triangleIndex];
                    itemValue := listViewValue.Items.Add();
                    FillItemFromTriangle(itemValue, triangleIndex, triangleValue);
                end;
            end
            else
            begin
                for triangleIndex := 0 to modelValue.TriangleCount - 1 do
                begin
                    triangleValue := modelValue.Triangles[triangleIndex];
                    itemValue := listViewValue.Items[triangleIndex];
                    FillItemFromTriangle(itemValue, triangleIndex, triangleValue);
                end;
            end;
        end;
    finally
        SetListViewRedraw(True);
        listViewValue.Items.EndUpdate();
        EndUpdate();
    end;
end;

procedure TDXMeshTriangleListBinder.RefreshChangedRows(const ChangedIndices: TArray<Integer>);
var
    i: Integer;
    triangleIndex: Integer;
    itemValue: TListItem;
    triangleValue: TDXMeshTriangle;
begin
    if (listViewValue = nil) or (modelValue = nil) then
    begin
        Exit;
    end;

    if Length(ChangedIndices) <= 0 then
    begin
        Exit;
    end;

    if listViewValue.Items.Count <> modelValue.TriangleCount then
    begin
        RefreshRows();
        Exit;
    end;

    BeginUpdate();
    listViewValue.Items.BeginUpdate();
    SetListViewRedraw(False);
    try
        for i := 0 to High(ChangedIndices) do
        begin
            triangleIndex := ChangedIndices[i];
            if (triangleIndex >= 0) and (triangleIndex < listViewValue.Items.Count) then
            begin
                itemValue := listViewValue.Items[triangleIndex];
                triangleValue := modelValue.Triangles[triangleIndex];
                FillItemFromTriangle(itemValue, triangleIndex, triangleValue);
            end;
        end;
    finally
        SetListViewRedraw(True);
        listViewValue.Items.EndUpdate();
        EndUpdate();
    end;
end;

procedure TDXMeshTriangleListBinder.RefreshAll();
begin
    RefreshRows();
    EnsureSelectionCacheSize();
    RefreshSelectionFromViewer();
end;

function TDXMeshTriangleListBinder.GetActiveTriangleIndexFromListView(): Integer;
begin
    Result := -1;

    if listViewValue = nil then
    begin
        Exit;
    end;

    if listViewValue.ItemIndex >= 0 then
    begin
        if listViewValue.ItemIndex < listViewValue.Items.Count then
        begin
            Result := listViewValue.ItemIndex;
            Exit;
        end;
    end;

    if listViewValue.Selected <> nil then
    begin
        Result := listViewValue.Selected.Index;
    end;
end;

procedure TDXMeshTriangleListBinder.RefreshSelectionFromViewer();
var
    itemIndex: Integer;
    activeTriangleIndexValue: Integer;
    itemValue: TListItem;
    bSelected: Boolean;
begin
    if (listViewValue = nil) or (viewerValue = nil) then
    begin
        Exit;
    end;

    EnsureSelectionCacheSize();

    BeginUpdate();
    listViewValue.Items.BeginUpdate();
    SetListViewRedraw(False);
    try
        activeTriangleIndexValue := viewerValue.SelectedTriangleIndex;

        for itemIndex := 0 to listViewValue.Items.Count - 1 do
        begin
            bSelected := viewerValue.TriangleSelected[itemIndex];
            if lastViewerSelectionValue[itemIndex] <> bSelected then
            begin
                itemValue := listViewValue.Items[itemIndex];
                itemValue.Selected := bSelected;
                lastViewerSelectionValue[itemIndex] := bSelected;
            end;
        end;

        if (lastActiveTriangleIndexValue >= 0) and (lastActiveTriangleIndexValue < listViewValue.Items.Count) then
        begin
            if lastActiveTriangleIndexValue <> activeTriangleIndexValue then
            begin
                listViewValue.Items[lastActiveTriangleIndexValue].Focused := False;
            end;
        end;

        if (activeTriangleIndexValue >= 0) and (activeTriangleIndexValue < listViewValue.Items.Count) then
        begin
            listViewValue.Items[activeTriangleIndexValue].Focused := True;
            listViewValue.ItemFocused := listViewValue.Items[activeTriangleIndexValue];
            listViewValue.ItemIndex := activeTriangleIndexValue;
        end
        else
        begin
            listViewValue.ItemIndex := -1;
        end;

        lastActiveTriangleIndexValue := activeTriangleIndexValue;
    finally
        SetListViewRedraw(True);
        listViewValue.Items.EndUpdate();
        EndUpdate();
    end;
end;

procedure TDXMeshTriangleListBinder.ScheduleApplySelectionToViewer();
begin
    if selectionApplyTimerValue = nil then
    begin
        ApplySelectionToViewer();
        Exit;
    end;

    bSelectionApplyPendingValue := True;
    selectionApplyTimerValue.Enabled := False;
    selectionApplyTimerValue.Enabled := True;
end;

procedure TDXMeshTriangleListBinder.SelectionApplyTimer(Sender: TObject);
begin
    selectionApplyTimerValue.Enabled := False;

    if bSelectionApplyPendingValue = True then
    begin
        bSelectionApplyPendingValue := False;
        ApplySelectionToViewer();
    end;
end;

procedure TDXMeshTriangleListBinder.ApplySelectionToViewer();
var
    selectedIndices: TArray<Integer>;
    itemIndex: Integer;
    writeIndex: Integer;
    activeTriangleIndexValue: Integer;
begin
    if (listViewValue = nil) or (viewerValue = nil) or (modelValue = nil) then
    begin
        Exit;
    end;

    SetLength(selectedIndices, listViewValue.SelCount);
    writeIndex := 0;

    for itemIndex := 0 to listViewValue.Items.Count - 1 do
    begin
        if listViewValue.Items[itemIndex].Selected = True then
        begin
            if writeIndex < Length(selectedIndices) then
            begin
                selectedIndices[writeIndex] := itemIndex;
                Inc(writeIndex);
            end;
        end;
    end;

    if writeIndex <> Length(selectedIndices) then
    begin
        SetLength(selectedIndices, writeIndex);
    end;

    activeTriangleIndexValue := GetActiveTriangleIndexFromListView();
    viewerValue.AssignSelection(selectedIndices, activeTriangleIndexValue);
end;

procedure TDXMeshTriangleListBinder.InternalViewerSelectionChanged(Sender: TObject);
begin
    RefreshSelectionFromViewer();

    if Assigned(previousViewerSelectionChangedValue) = True then
    begin
        previousViewerSelectionChangedValue(Sender);
    end;
end;

procedure TDXMeshTriangleListBinder.InternalViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
begin
    RefreshSelectionFromViewer();

    if Assigned(previousViewerTriangleSelectedValue) = True then
    begin
        previousViewerTriangleSelectedValue(Sender, TriangleIndex);
    end;
end;

procedure TDXMeshTriangleListBinder.InternalListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
    if IsUpdating() = False then
    begin
        ScheduleApplySelectionToViewer();
    end;

    if Assigned(previousListViewSelectItemValue) = True then
    begin
        previousListViewSelectItemValue(Sender, Item, Selected);
    end;
end;

procedure TDXMeshTriangleListBinder.InternalModelChanged(Sender: TObject);
var
    changedIndices: TArray<Integer>;
    bFullRefresh: Boolean;
begin
    bFullRefresh := False;
    SetLength(changedIndices, 0);

    if modelValue <> nil then
    begin
        bFullRefresh := modelValue.ConsumeFullRefreshRequired();
        changedIndices := modelValue.ConsumeDirtyTriangleIndices();
    end;

    if bFullRefresh = True then
    begin
        RefreshRows();
        RefreshSelectionFromViewer();
    end
    else if Length(changedIndices) > 0 then
    begin
        RefreshChangedRows(changedIndices);
    end
    else if (modelValue <> nil) and (listViewValue <> nil) and (listViewValue.Items.Count <> modelValue.TriangleCount) then
    begin
        RefreshRows();
        RefreshSelectionFromViewer();
    end;

    if Assigned(previousModelChangedValue) = True then
    begin
        previousModelChangedValue(Sender);
    end;
end;

end.

