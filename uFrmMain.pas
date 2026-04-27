unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  DXUnreal3DView, DXUnreal3DModel, DXUnreal3DFlagsEditor, DXUnreal3DTriangleList,
  Vcl.Samples.Spin, Vcl.ComCtrls, ES.Layouts, ClassicMenuPainter, System.ImageList, Vcl.ImgList,
  RuntimeMainMenuClone, System.Generics.Collections;


type
  TfrmMain = class(TForm)
    pnlContainer: TPanel;
    btnNextFrame: TButton;
    btnPrevFrame: TButton;
    ViewportPopup: TPopupMenu;
    Clearselection1: TMenuItem;
    Selectalltriangles1: TMenuItem;
    Invertselection1: TMenuItem;
    mnuSelectPolysByMatNum: TMenuItem;
    Texture01: TMenuItem;
    Texture1: TMenuItem;
    Texture2: TMenuItem;
    Texture3: TMenuItem;
    Texture4: TMenuItem;
    Texture5: TMenuItem;
    Texture6: TMenuItem;
    Texture7: TMenuItem;
    lblSelectedNum: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    rbNormal: TRadioButton;
    rbTwoSided: TRadioButton;
    rbTranslucent: TRadioButton;
    rbMasked: TRadioButton;
    rbModulated: TRadioButton;
    rbWeaponTriangle: TRadioButton;
    chkUnlit: TCheckBox;
    chkFlat: TCheckBox;
    chkEnviroMap: TCheckBox;
    chkNoSmooth: TCheckBox;
    seMaterial: TSpinEdit;
    Label1: TLabel;
    pnlList: TPanel;
    pnlViewport: TPanel;
    lvMeshTriangles: TListView;
    List_Viewport_Splitter: TEsTransparentSplitter;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    OpenDeusEx3dmodel1: TMenuItem;
    Savecurrentmesh1: TMenuItem;
    Savecurrentmeshas1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    GroupBox3: TGroupBox;
    chkAxisGizmo: TCheckBox;
    chkBoundingBox: TCheckBox;
    lbAnimFrames: TListBox;
    EsTransparentSplitter1: TEsTransparentSplitter;
    chkCullBackFaces: TCheckBox;
    chkRespectTwoSided: TCheckBox;
    tbShadeAmbient: TTrackBar;
    tbShadeDiffuse: TTrackBar;
    lblShadeControls: TLabel;
    N2: TMenuItem;
    Rectselectionmode1: TMenuItem;
    AnyVisiblePixel1: TMenuItem;
    TriangleCenter1: TMenuItem;
    TwoVerticesInside1: TMenuItem;
    AllVerticesInside1: TMenuItem;
    N3: TMenuItem;
    Wireframe1: TMenuItem;
    Wireframesolid1: TMenuItem;
    Flatshaded1: TMenuItem;
    Smoothshaded1: TMenuItem;
    pnlAnimFrames: TPanel;
    Label2: TLabel;
    estmenu1: TMenuItem;
    chkApplyImmediately: TCheckBox;
    btnApplyNow: TButton;
    ImageList1: TImageList;
    N10: TMenuItem;
    Boundingboxmode1: TMenuItem;
    Allframes1: TMenuItem;
    Currentframe1: TMenuItem;
    N11: TMenuItem;
    Showinfo1: TMenuItem;
    chkBoundingSphere: TCheckBox;
    Controls1: TMenuItem;
    ItemsCount1: TMenuItem;
    exturedSmoothshaded1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TestLoadModel(Sender: TObject);
    procedure btnNextFrameClick(Sender: TObject);
    procedure btnPrevFrameClick(Sender: TObject);
    procedure Clearselection1Click(Sender: TObject);
    procedure Selectalltriangles1Click(Sender: TObject);
    procedure Invertselection1Click(Sender: TObject);
    procedure SelectByTextureNum(Sender: TObject);

    procedure Exit1Click(Sender: TObject);
    procedure OpenDeusEx3dmodel1Click(Sender: TObject);
    procedure Savecurrentmesh1Click(Sender: TObject);
    procedure Savecurrentmeshas1Click(Sender: TObject);

    // LLC: viewport event handlers
    procedure ViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
    procedure ViewerSelectionChanged(Sender: TObject);

    // New procedures
    procedure FillAnimFrames();
    procedure EnableShadeControls(bEnable: Boolean);
    procedure SetMenuMaterialsNum();

    procedure chkAxisGizmoClick(Sender: TObject);
    procedure chkBoundingBoxClick(Sender: TObject);
    procedure lbAnimFramesDblClick(Sender: TObject);
    procedure chkCullBackFacesClick(Sender: TObject);
    procedure chkRespectTwoSidedClick(Sender: TObject);
    procedure tbShadeDiffuseChange(Sender: TObject);
    procedure tbShadeAmbientChange(Sender: TObject);
    procedure SwitchRectSelMode(Sender: TObject);
    procedure SwitchDisplayMode(Sender: TObject);
    procedure Allframes1Click(Sender: TObject);
    procedure Currentframe1Click(Sender: TObject);
    procedure chkBoundingSphereClick(Sender: TObject);
    procedure Showinfo1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Controls1Click(Sender: TObject);
    procedure ItemsCount1Click(Sender: TObject);
    procedure ViewportPopupPopup(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses uFrmAbout, uFrmControls;

var
    model: TDXUnreal3DModel;
    viewer: TDXMeshViewer;
    flagsEditor: TDXMeshFlagsEditor;
    triangleListBinder: TDXMeshTriangleListBinder;


{$R *.dfm}

function GetMaterialCount(Model: TDXUnreal3DModel): Integer;
var
    i: Integer;
    TextureIndices: TList<Integer>;
    TexIdx: Integer;
begin
    Result := 0;
    if not Assigned(Model) then Exit;
    TextureIndices := TList<Integer>.Create;
    try
        for i := 0 to Model.TriangleCount - 1 do
        begin
            TexIdx := Model.Triangles[i].TextureIndex;
            if TextureIndices.IndexOf(TexIdx) = -1 then
                TextureIndices.Add(TexIdx);
        end;
        Result := TextureIndices.Count;
    finally
        TextureIndices.Free();
    end;
end;


procedure TfrmMain.ViewerTriangleSelected(Sender: TObject; TriangleIndex: Integer);
begin
    flagsEditor.RefreshControlsFromSelection();
end;

procedure TfrmMain.ViewportPopupPopup(Sender: TObject);
begin
    SetMenuMaterialsNum();
end;

procedure TfrmMain.ViewerSelectionChanged(Sender: TObject);
begin
    flagsEditor.RefreshControlsFromSelection();
    lblSelectedNum.Caption := 'Triangles selected: ' + IntToStr(viewer.SelectionCount);
end;

procedure TfrmMain.About1Click(Sender: TObject);
begin
    frmAbout.ShowModal();
end;

procedure TfrmMain.Allframes1Click(Sender: TObject);
begin
    viewer.BoundingBoxFrameMode := bbfmAllFrames;
end;

procedure TfrmMain.btnNextFrameClick(Sender: TObject);
begin
    viewer.NextFrame();
end;

procedure TfrmMain.btnPrevFrameClick(Sender: TObject);
begin
    viewer.PrevFrame();
end;

procedure TfrmMain.chkBoundingSphereClick(Sender: TObject);
begin
    viewer.ShowBoundingSphere := chkBoundingSphere.Checked;
end;

procedure TfrmMain.TestLoadModel(Sender: TObject);
begin
    if model.LoadFromFile('C:\LANG\DelphiProjects\DeusExFX\UNATCO_a.3d') = True then
    begin
        viewer.Model := model;
        viewer.CurrentFrame := 0;
        Self.Caption := model.SourceFileName;
        flagsEditor.RefreshControlsFromSelection();
        FillAnimFrames();
    end
    else
    begin
        Application.MessageBox(PChar(model.LastError),'Error!', MB_OK + MB_ICONSTOP + MB_TOPMOST);
    end;
end;

procedure TfrmMain.chkAxisGizmoClick(Sender: TObject);
begin
    viewer.ShowAxisIndicator := chkAxisGizmo.Checked;
end;

procedure TfrmMain.chkBoundingBoxClick(Sender: TObject);
begin
    viewer.ShowBoundingBox := chkBoundingBox.Checked;
end;

procedure TfrmMain.chkCullBackFacesClick(Sender: TObject);
begin
    viewer.CullBackFaces := chkCullBackFaces.Checked;
    chkRespectTwoSided.Enabled := chkCullBackFaces.Checked;
    chkRespectTwoSided.Checked := viewer.RespectTwoSided;
end;

procedure TfrmMain.chkRespectTwoSidedClick(Sender: TObject);
begin
    viewer.RespectTwoSided := chkRespectTwoSided.Checked;
end;

procedure TfrmMain.Clearselection1Click(Sender: TObject);
begin
    viewer.ClearSelection();
end;

procedure TfrmMain.Controls1Click(Sender: TObject);
begin
    frmControls.ShowModal();
end;

procedure TfrmMain.Currentframe1Click(Sender: TObject);
begin
    viewer.BoundingBoxFrameMode := bbfmCurrentFrame;
end;

procedure TfrmMain.EnableShadeControls(bEnable: Boolean);
begin
    lblShadeControls.Enabled := bEnable;
    tbShadeDiffuse.Enabled := bEnable;
    tbShadeAmbient.Enabled := bEnable;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
    Application.Terminate();
end;

procedure TfrmMain.FillAnimFrames();
begin
    for var i := 0 to model.FrameCount do
    begin
        lbAnimFrames.Items.Add(i.ToString());
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
//    var menuPainter := TClassicMenuPainter.Create(Self);
//    menuPainter.Menu := MainMenu;

    var menuPainter2 := TClassicMenuPainter.Create(Self);
    menuPainter2.Menu := ViewportPopup;

//    MainMenu.OwnerDraw := True;

    var runtimeBar: TRuntimeMainMenuBar;
    ReplaceMainMenuWithRuntimeBar(Self, MainMenu, runtimeBar);

    model := TDXUnreal3DModel.Create();

    DXDefaultMeshViewerColors.BackgroundColor := RGB(20,20,20);
    //DXDefaultMeshViewerColors.BackgroundColor := clGray;
    DXDefaultMeshViewerColors.SolidColorNormal:= clMoneyGreen; // Обычные полигоны (односторонние)
    DXDefaultMeshViewerColors.SolidColorTwoSided:= clMoneyGreen; // TwoSided полигоны
    DXDefaultMeshViewerColors.SolidColorInvisible:= clRed; // Невидимые (weapon triangle)
    DXDefaultMeshViewerColors.WireframeColor:= $00297AA9; // цвет сетки (контуры полигонов)
    DXDefaultMeshViewerColors.WireframeModeColor := $00297AA9; // Цвет сетки для режима Wireframe
    DXDefaultMeshViewerColors.SelectedFillColor:= clLime; // Выбранные полигоны
    DXDefaultMeshViewerColors.ActiveSelectedFillColor:= clAqua; // Текущий выбранный полигон, если несколько
    DXDefaultMeshViewerColors.SelectedLineColor:= $007DA8FF; // Края выделенного полигона
    DXDefaultMeshViewerColors.ActiveSelectedLineColor:= clRed; // Края активного выделенного полигона

    DXDefaultMeshViewerColors.BackgroundTopColor := clGray;
    DXDefaultMeshViewerColors.BackgroundBottomColor := clBlack;

    viewer := TDXMeshViewer.Create(pnlViewport);
    viewer.Parent := pnlViewport;
    viewer.Align := alClient;
    viewer.PopupMenu := ViewportPopup;
    viewer.AxisFontHeight := 10;
    viewer.GradientBackground := True;

    flagsEditor := TDXMeshFlagsEditor.Create();
    flagsEditor.Attach(model, viewer);
    flagsEditor.AssignControls(
        rbNormal,
        rbTwoSided,
        rbTranslucent,
        rbMasked,
        rbModulated,
        rbWeaponTriangle,
        chkUnlit,
        chkFlat,
        chkEnviroMap,
        chkNoSmooth,
        seMaterial,
        btnApplyNow,
        chkApplyImmediately
    );

    viewer.OnTriangleSelected := ViewerTriangleSelected;
    viewer.OnSelectionChanged := ViewerSelectionChanged;

    triangleListBinder := TDXMeshTriangleListBinder.Create();
    triangleListBinder.Attach(model, viewer, lvMeshTriangles);

    chkAxisGizmo.Checked := viewer.ShowAxisIndicator;
    chkBoundingBox.Checked := viewer.ShowBoundingBox;
    chkBoundingSphere.Checked := viewer.ShowBoundingSphere;

    tbShadeAmbient.Position := Round(viewer.ShadeAmbient * 100.0);
    tbShadeDiffuse.Position := Round(viewer.ShadeDiffuse * 100.0);

    case viewer.RectSelectionMode of
        rsmAnyVisiblePixel:   AnyVisiblePixel1.Checked := True;
        rsmTriangleCenter:    TriangleCenter1.Checked := True;
        rsmTwoVerticesInside: TwoVerticesInside1.Checked := True;
        rsmAllVerticesInside: AllVerticesInside1.Checked := True;
    end;

    case viewer.DisplayMode of
        mdWireframe:      Wireframe1.Checked := True;
        mdWireframeSolid: Wireframesolid1.Checked := True;
        mdFlatShaded:     Flatshaded1.Checked := True;
        mdSmoothShaded:   Smoothshaded1.Checked := True;
    end;

    case viewer.BoundingBoxFrameMode of
        bbfmCurrentFrame: Currentframe1.Checked := True;
        bbfmAllFrames:    Allframes1.Checked := True;
    end;

    Showinfo1.Checked := viewer.ShowBoundingBoxVertexLabels;

    if (viewer.DisplayMode = mdFlatShaded) or (viewer.DisplayMode = mdSmoothShaded) then
        EnableShadeControls(true)
    else
        EnableShadeControls(False);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
    viewer.Free();
    model.Free();
    triangleListBinder.Free();
    flagsEditor.Free();
    //menuPainter.Free();
end;

procedure TfrmMain.Invertselection1Click(Sender: TObject);
begin
    viewer.InvertSelection();
end;

procedure TfrmMain.ItemsCount1Click(Sender: TObject);
begin
    SetMenuMaterialsNum();
end;

procedure TfrmMain.lbAnimFramesDblClick(Sender: TObject);
begin
    if lbAnimFrames.ItemIndex <> -1 then
    begin
        viewer.CurrentFrame := lbAnimFrames.ItemIndex;
    end;
end;

procedure TfrmMain.OpenDeusEx3dmodel1Click(Sender: TObject);
begin
    if OpenDialog.Execute() = True then
    begin
        if model.LoadFromFile(OpenDialog.FileName) = True then
        begin
            viewer.Model := model;
            viewer.CurrentFrame := 0;
            flagsEditor.RefreshControlsFromSelection();
            lbAnimFrames.Clear();
            FillAnimFrames(); // кадры анимации
            Self.Caption := 'DeusExFX - ' + OpenDialog.FileName;
        end
        else
        begin
            Application.MessageBox(PChar(model.LastError),'Error!', MB_OK + MB_ICONSTOP + MB_TOPMOST);
        end;
    end;
end;

procedure TfrmMain.Savecurrentmesh1Click(Sender: TObject);
begin
    if flagsEditor.SaveModel() = False then
        Application.MessageBox(PChar(flagsEditor.LastError),'Error!', MB_OK + MB_ICONSTOP + MB_TOPMOST);
end;

procedure TfrmMain.Savecurrentmeshas1Click(Sender: TObject);
begin
    if SaveDialog.Execute() = True then
    begin
        if flagsEditor.SaveModelAs(SaveDialog.FileName) = False then
            Application.MessageBox(PChar(flagsEditor.LastError),'Error!', MB_OK + MB_ICONSTOP + MB_TOPMOST);
    end;
end;

procedure TfrmMain.Selectalltriangles1Click(Sender: TObject);
begin
    viewer.SelectAllTriangles();
end;

procedure TfrmMain.SelectByTextureNum(Sender: TObject);
begin
    var TextureNum := (Sender as TMenuItem).tag; // LLC: tag от 0 до 7 в элементах меню, возможность использовать один обработчик события

    viewer.SelectTrianglesByTextureIndex(TextureNum);
end;

procedure TfrmMain.SetMenuMaterialsNum();
begin
    var MatCount := GetMaterialCount(model);

    for var i:= 0 to MatCount -1 do
        mnuSelectPolysByMatNum.Items[i].Visible := True;
end;

procedure TfrmMain.Showinfo1Click(Sender: TObject);
begin
    viewer.ShowBoundingBoxVertexLabels := Showinfo1.Checked;
    viewer.ShowArtistSpaceDebug := Showinfo1.Checked;
    viewer.ShowMeshWarnings := Showinfo1.Checked;
end;

procedure TfrmMain.SwitchDisplayMode(Sender: TObject);
begin
    var DisplayModeNum := (Sender as TMenuItem).tag; // LLC: tag от 21 до 24 в элементах меню, возможность использовать один обработчик события

    case DisplayModeNum of
        21: begin
            viewer.DisplayMode := mdWireframe;
            EnableShadeControls(False);
        end;
        22: begin
            viewer.DisplayMode := mdWireframeSolid;
            EnableShadeControls(False);
        end;
        23: begin
            viewer.DisplayMode := mdFlatShaded;
            EnableShadeControls(True);
        end;
        24: begin
            viewer.DisplayMode := mdSmoothShaded;
            EnableShadeControls(True);
        end;
        25: begin
            viewer.DisplayMode := mdTextured;
            EnableShadeControls(True);
        end;
    end;

    (Sender as TMenuItem).Checked := True;
end;

procedure TfrmMain.SwitchRectSelMode(Sender: TObject);
begin
    var ModeNum := (Sender as TMenuItem).tag; // LLC: tag от 11 до 14 в элементах меню, возможность использовать один обработчик события

    case ModeNum of
        11: viewer.RectSelectionMode := rsmAnyVisiblePixel;
        12: viewer.RectSelectionMode := rsmTriangleCenter;
        13: viewer.RectSelectionMode := rsmTwoVerticesInside;
        14: viewer.RectSelectionMode := rsmAllVerticesInside;
    end;

    (Sender as TMenuItem).Checked := True;
end;

procedure TfrmMain.tbShadeAmbientChange(Sender: TObject);
begin
    viewer.ShadeAmbient := tbShadeAmbient.Position / 100.0;
end;

procedure TfrmMain.tbShadeDiffuseChange(Sender: TObject);
begin
    viewer.ShadeDiffuse := tbShadeDiffuse.Position / 100.0;
end;

end.
