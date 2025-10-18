#define AppName "Boder"
#define AppVersion "1.0.0"
#define AppExeName "boder.exe"

[Setup]
AppId={{2C2B2C3F-7A7B-4D2E-A5A1-123456789ABC}}   ; generate your own GUID
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=installer
OutputBaseFilename=BoderSetup
ArchitecturesInstallIn64BitMode=x64
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
SetupIconFile=windows\runner\resources\app_icon.ico

[Files]
; *** Ship EVERYTHING from the Release folder ***
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}";
Flags: recursesubdirs createallsubdirs ignoreversion

; Optional: include VC++ redistributable if you want to be safe
; Put the file at vendor\VC_redist.x64.exe
Source: "vendor\VC_redist.x64.exe"; DestDir: "{tmp}";
Flags: deleteafterinstall; Check: not VCInstalled

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{desktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; Flags: unchecked

[Run]
; Optional: install VC++ redist quietly if missing
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; Check: not VCInstalled
; Launch app after install
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[Code]
function VCInstalled: Boolean;
var key: string;
begin
  key := 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64';
  Result := RegValueExists(HKLM, key, 'Installed') and (RegReadDWordValue(HKLM, key, 'Installed') = 1);
end;
