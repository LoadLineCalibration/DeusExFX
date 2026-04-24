program DeusExFX;

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {frmMain},
  DXUnreal3DModel in 'DXUnreal3DModel.pas',
  DXUnreal3DView in 'DXUnreal3DView.pas',
  DXUnreal3DFlagsEditor in 'DXUnreal3DFlagsEditor.pas',
  DXUnreal3DTriangleList in 'DXUnreal3DTriangleList.pas',
  ClassicMenuPainter in 'ClassicMenuPainter.pas',
  RuntimeMainMenuClone in 'RuntimeMainMenuClone.pas',
  uFrmAbout in 'uFrmAbout.pas' {frmAbout},
  uFrmControls in 'uFrmControls.pas' {frmControls};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmControls, frmControls);
  Application.Run;

  ReportMemoryLeaksOnShutdown := True;
end.
