object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Zboar'#259', zboar'#259' '#238'n cer cocoarele, Ating'#226'nd cu aripa soarele.'
  ClientHeight = 820
  ClientWidth = 576
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    576
    820)
  TextHeight = 17
  object lblSelectedNum: TLabel
    Left = 8
    Top = 784
    Width = 193
    Height = 16
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 686
  end
  object Label1: TLabel
    Left = 211
    Top = 732
    Width = 87
    Height = 27
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Caption = 'Material num:'
    Layout = tlCenter
    ExplicitTop = 634
  end
  object pnlContainer: TPanel
    Left = 0
    Top = 0
    Width = 576
    Height = 561
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object List_Viewport_Splitter: TEsTransparentSplitter
      Left = 285
      Top = 1
      Width = 4
      Height = 559
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 119
      ExplicitTop = 2
      ExplicitHeight = 379
    end
    object pnlList: TPanel
      Left = 1
      Top = 1
      Width = 284
      Height = 559
      Align = alLeft
      Caption = 'List'
      TabOrder = 0
      object EsTransparentSplitter1: TEsTransparentSplitter
        Left = 141
        Top = 1
        Width = 4
        Height = 557
        Beveled = True
        Color = clBtnFace
        ParentColor = False
        ExplicitLeft = 188
        ExplicitTop = 12
        ExplicitHeight = 468
      end
      object lvMeshTriangles: TListView
        Left = 145
        Top = 1
        Width = 138
        Height = 557
        Align = alClient
        Columns = <>
        HideSelection = False
        TabOrder = 0
      end
      object pnlAnimFrames: TPanel
        Left = 1
        Top = 1
        Width = 140
        Height = 557
        Align = alLeft
        Caption = 'pnlAnimFrames'
        TabOrder = 1
        DesignSize = (
          140
          557)
        object Label2: TLabel
          Left = 1
          Top = 1
          Width = 138
          Height = 16
          Align = alTop
          Alignment = taCenter
          Caption = 'Anim frames'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Verdana'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
          Layout = tlCenter
          ExplicitWidth = 92
        end
        object lbAnimFrames: TListBox
          Left = 1
          Top = 17
          Width = 138
          Height = 500
          Align = alTop
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 17
          TabOrder = 0
          OnDblClick = lbAnimFramesDblClick
        end
        object btnNextFrame: TButton
          Left = 81
          Top = 523
          Width = 50
          Height = 25
          Hint = 'GoTo next animation frame'
          Anchors = [akLeft, akBottom]
          Caption = '>>'
          TabOrder = 1
          OnClick = btnNextFrameClick
        end
        object btnPrevFrame: TButton
          Left = 6
          Top = 523
          Width = 50
          Height = 25
          Hint = 'GoTo prevoius animation frame'
          Anchors = [akLeft, akBottom]
          Caption = '<< '
          TabOrder = 2
          OnClick = btnPrevFrameClick
        end
      end
    end
    object pnlViewport: TPanel
      Left = 289
      Top = 1
      Width = 286
      Height = 559
      Align = alClient
      Caption = 'Viewport'
      TabOrder = 1
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 613
    Width = 197
    Height = 165
    Anchors = [akLeft, akBottom]
    Caption = 'Type'
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -13
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    TabOrder = 1
    object rbNormal: TRadioButton
      Left = 12
      Top = 21
      Width = 113
      Height = 17
      Caption = 'Normal'
      TabOrder = 0
    end
    object rbTwoSided: TRadioButton
      Left = 12
      Top = 44
      Width = 113
      Height = 17
      Caption = 'Two sided'
      TabOrder = 1
    end
    object rbTranslucent: TRadioButton
      Left = 12
      Top = 67
      Width = 181
      Height = 17
      Caption = 'Translucent and two sided'
      TabOrder = 2
    end
    object rbMasked: TRadioButton
      Left = 12
      Top = 90
      Width = 173
      Height = 17
      Caption = 'Masked and two sided'
      TabOrder = 3
    end
    object rbModulated: TRadioButton
      Left = 12
      Top = 113
      Width = 173
      Height = 17
      Caption = 'Modulated and two sided'
      TabOrder = 4
    end
    object rbWeaponTriangle: TRadioButton
      Left = 12
      Top = 136
      Width = 113
      Height = 17
      Caption = 'Weapon triangle'
      TabOrder = 5
    end
  end
  object GroupBox2: TGroupBox
    Left = 211
    Top = 613
    Width = 166
    Height = 113
    Anchors = [akLeft, akBottom]
    Caption = 'Flags'
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -13
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    TabOrder = 2
    object chkUnlit: TCheckBox
      Left = 12
      Top = 20
      Width = 109
      Height = 17
      AllowGrayed = True
      Caption = 'Unlit'
      TabOrder = 0
    end
    object chkFlat: TCheckBox
      Left = 12
      Top = 43
      Width = 109
      Height = 17
      AllowGrayed = True
      Caption = 'Flat'
      TabOrder = 1
    end
    object chkEnviroMap: TCheckBox
      Left = 12
      Top = 65
      Width = 149
      Height = 17
      AllowGrayed = True
      Caption = 'Environment mapped'
      TabOrder = 2
    end
    object chkNoSmooth: TCheckBox
      Left = 12
      Top = 88
      Width = 109
      Height = 17
      AllowGrayed = True
      Caption = 'No smoothing'
      TabOrder = 3
    end
  end
  object seMaterial: TSpinEdit
    Left = 304
    Top = 732
    Width = 73
    Height = 27
    Anchors = [akLeft, akBottom]
    AutoSize = False
    EditorEnabled = False
    MaxValue = 10
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object GroupBox3: TGroupBox
    Left = 383
    Top = 613
    Width = 186
    Height = 206
    Anchors = [akLeft, akBottom]
    Caption = 'Viewport options'
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -13
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    TabOrder = 4
    object lblShadeControls: TLabel
      Left = 12
      Top = 132
      Width = 239
      Height = 22
      AutoSize = False
      Caption = 'ShadeDiffuse/ShadeAmbient'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object chkAxisGizmo: TCheckBox
      Left = 12
      Top = 20
      Width = 97
      Height = 17
      Caption = 'Axis Gizmo?'
      TabOrder = 0
      OnClick = chkAxisGizmoClick
    end
    object chkBoundingBox: TCheckBox
      Left = 12
      Top = 43
      Width = 153
      Height = 17
      Caption = 'Mesh bounding box?'
      TabOrder = 1
      OnClick = chkBoundingBoxClick
    end
    object chkCullBackFaces: TCheckBox
      Left = 12
      Top = 88
      Width = 145
      Height = 17
      Caption = 'Cull backfaces?'
      TabOrder = 2
      OnClick = chkCullBackFacesClick
    end
    object chkRespectTwoSided: TCheckBox
      Left = 24
      Top = 109
      Width = 153
      Height = 17
      Caption = 'Respect two-sided?'
      Enabled = False
      TabOrder = 3
      OnClick = chkRespectTwoSidedClick
    end
    object tbShadeAmbient: TTrackBar
      Left = 3
      Top = 177
      Width = 180
      Height = 22
      Max = 100
      PositionToolTip = ptLeft
      TabOrder = 4
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = tbShadeAmbientChange
    end
    object tbShadeDiffuse: TTrackBar
      Left = 3
      Top = 149
      Width = 180
      Height = 22
      Max = 100
      PositionToolTip = ptLeft
      TabOrder = 5
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = tbShadeDiffuseChange
    end
    object chkBoundingSphere: TCheckBox
      Left = 12
      Top = 65
      Width = 165
      Height = 17
      Caption = 'Mesh bounding sphere?'
      TabOrder = 6
      OnClick = chkBoundingSphereClick
    end
  end
  object chkApplyImmediately: TCheckBox
    Left = 180
    Top = 593
    Width = 166
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Apply automatically'
    TabOrder = 5
  end
  object btnApplyNow: TButton
    Left = 8
    Top = 591
    Width = 166
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Apply changes'
    TabOrder = 6
  end
  object ViewportPopup: TPopupMenu
    OnPopup = ViewportPopupPopup
    Left = 160
    Top = 288
    object Wireframe1: TMenuItem
      Tag = 21
      Caption = 'Wireframe'
      GroupIndex = 20
      RadioItem = True
      OnClick = SwitchDisplayMode
    end
    object Wireframesolid1: TMenuItem
      Tag = 22
      Caption = 'Wireframe + solid'
      GroupIndex = 20
      RadioItem = True
      OnClick = SwitchDisplayMode
    end
    object Flatshaded1: TMenuItem
      Tag = 23
      Caption = 'Flat shaded'
      GroupIndex = 20
      RadioItem = True
      OnClick = SwitchDisplayMode
    end
    object Smoothshaded1: TMenuItem
      Tag = 24
      Caption = 'Smooth shaded'
      GroupIndex = 20
      RadioItem = True
      OnClick = SwitchDisplayMode
    end
    object exturedSmoothshaded1: TMenuItem
      Tag = 25
      Caption = 'Textured + Smooth shaded'
      GroupIndex = 20
      RadioItem = True
      OnClick = SwitchDisplayMode
    end
    object N3: TMenuItem
      Caption = '-'
      GroupIndex = 30
    end
    object Clearselection1: TMenuItem
      Caption = 'Clear selection'
      GroupIndex = 30
      OnClick = Clearselection1Click
    end
    object Selectalltriangles1: TMenuItem
      Caption = 'Select all triangles'
      GroupIndex = 30
      OnClick = Selectalltriangles1Click
    end
    object Invertselection1: TMenuItem
      Caption = 'Invert selection'
      GroupIndex = 30
      OnClick = Invertselection1Click
    end
    object mnuSelectPolysByMatNum: TMenuItem
      Caption = 'Select polys by texture num'
      GroupIndex = 30
      object Texture01: TMenuItem
        Caption = 'Texture0'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture1: TMenuItem
        Tag = 1
        Caption = 'Texture1'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture2: TMenuItem
        Tag = 2
        Caption = 'Texture2'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture3: TMenuItem
        Tag = 3
        Caption = 'Texture3'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture4: TMenuItem
        Tag = 4
        Caption = 'Texture4'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture5: TMenuItem
        Tag = 5
        Caption = 'Texture5'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture6: TMenuItem
        Tag = 6
        Caption = 'Texture6'
        Visible = False
        OnClick = SelectByTextureNum
      end
      object Texture7: TMenuItem
        Tag = 7
        Caption = 'Texture7'
        Visible = False
        OnClick = SelectByTextureNum
      end
    end
    object N2: TMenuItem
      Caption = '-'
      GroupIndex = 30
    end
    object Rectselectionmode1: TMenuItem
      Caption = 'Rect. selection mode'
      GroupIndex = 30
      object AnyVisiblePixel1: TMenuItem
        Tag = 11
        Caption = 'Any Visible Pixel'
        GroupIndex = 10
        RadioItem = True
        OnClick = SwitchRectSelMode
      end
      object TriangleCenter1: TMenuItem
        Tag = 12
        Caption = 'Triangle Center'
        GroupIndex = 10
        RadioItem = True
        OnClick = SwitchRectSelMode
      end
      object TwoVerticesInside1: TMenuItem
        Tag = 13
        Caption = 'Two Vertices Inside'
        GroupIndex = 10
        RadioItem = True
        OnClick = SwitchRectSelMode
      end
      object AllVerticesInside1: TMenuItem
        Tag = 14
        Caption = 'All Vertices Inside'
        GroupIndex = 10
        RadioItem = True
        OnClick = SwitchRectSelMode
      end
    end
    object N10: TMenuItem
      Caption = '-'
      GroupIndex = 30
    end
    object Boundingboxmode1: TMenuItem
      Caption = 'Bounding box mode'
      GroupIndex = 30
      object Allframes1: TMenuItem
        AutoCheck = True
        Caption = 'All frames'
        GroupIndex = 30
        RadioItem = True
        OnClick = Allframes1Click
      end
      object Currentframe1: TMenuItem
        AutoCheck = True
        Caption = 'Current frame'
        GroupIndex = 30
        RadioItem = True
        OnClick = Currentframe1Click
      end
      object N11: TMenuItem
        Caption = '-'
        GroupIndex = 30
      end
      object Showinfo1: TMenuItem
        AutoCheck = True
        Caption = 'Show extra info?'
        GroupIndex = 30
        OnClick = Showinfo1Click
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 204
    Top = 80
    object File1: TMenuItem
      Caption = 'File'
      object OpenDeusEx3dmodel1: TMenuItem
        Caption = 'Open DeusEx .3d mesh...'
        Hint = 'C:\LANG\DelphiProjects\DeusExFX\UNATCO_a.3d'
        OnClick = OpenDeusEx3dmodel1Click
      end
      object Savecurrentmesh1: TMenuItem
        Caption = 'Save current mesh'
        OnClick = Savecurrentmesh1Click
      end
      object Savecurrentmeshas1: TMenuItem
        Caption = 'Save current mesh as...'
        OnClick = Savecurrentmeshas1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Controls1: TMenuItem
        Caption = 'Controls..'
        OnClick = Controls1Click
      end
      object About1: TMenuItem
        Caption = 'About...'
        OnClick = About1Click
      end
    end
    object estmenu1: TMenuItem
      Caption = 'Test menu'
      object ItemsCount1: TMenuItem
        Caption = 'Items.Count'
        OnClick = ItemsCount1Click
      end
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Deus Ex .3d models|*_a.3d;*_d.3d'
    Left = 292
    Top = 76
  end
  object SaveDialog: TSaveDialog
    Filter = 'Deus Ex .3d models|*_d.3d'
    Left = 365
    Top = 77
  end
  object ImageList1: TImageList
    Left = 185
    Top = 193
  end
end
