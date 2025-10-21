; Inno Setup Script for weblser
; Creates an installer for the weblser Flutter Windows application

[Setup]
AppName=weblser
AppVersion=1.1.0
AppPublisher=Jumoki Agency LLC
AppPublisherURL=https://jumoki.agency
DefaultDirName={autopf}\weblser
DefaultGroupName=weblser
AllowNoIcons=yes
OutputDir=C:\Users\Ntro\weblser\weblser_app\installers
OutputBaseFilename=weblser-1.1.0-installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\weblser"; Filename: "{app}\weblser_app.exe"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,weblser}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\weblser"; Filename: "{app}\weblser_app.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\weblser_app.exe"; Description: "{cm:LaunchProgram,weblser}"; Flags: nowait postinstall skipifsilent
