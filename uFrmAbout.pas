unit uFrmAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ES.Labels;

type
  TfrmAbout = class(TForm)
    Button1: TButton;
    memoAboutText: TMemo;
    imgAppIcon: TImage;
    edtVersion: TEdit;
    EsLinkLabel1: TEsLinkLabel;

    function GetAppVersionStr(): string; //https://delphihaven.wordpress.com/2012/12/08/retrieving-the-applications-version-string/

    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

function TfrmAbout.GetAppVersionStr(): string;
var
    Size, Handle: DWORD;
    Buffer: TBytes;
    FixedPtr: PVSFixedFileInfo;
begin
    var Exe := ParamStr(0);

    Size := GetFileVersionInfoSize(PChar(Exe), Handle);
    if Size = 0 then
        RaiseLastOSError;

    SetLength(Buffer, Size);
    if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
        RaiseLastOSError;

    if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
        RaiseLastOSError;

    Result := Format('%d.%d.%d.%d',
      [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
       LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
       LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
       LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
end;

procedure LoadMainIconToImage(const image: TImage);
begin
    var hIcon: HICON;
    hIcon := LoadImage(
        HInstance,
        'MAINICON',
        IMAGE_ICON,
        64,
        64,
        LR_DEFAULTCOLOR
    );

    if hIcon = 0 then
        RaiseLastOSError();

    var icon: TIcon;
    icon := TIcon.Create();
    try
        icon.Handle := hIcon;
        image.Picture.Assign(icon);
    finally
        icon.Free();
    end;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
    LoadMainIconToImage(imgAppIcon);
    edtVersion.Text := ' [version ' + GetAppVersionStr() +']';
end;

end.
