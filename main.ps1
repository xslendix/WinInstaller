Write-Output "Checking for updates"
wuauclt /detectnow /updatenow

$GIT_URL='https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe'
$GIT_PATH='C:\Program Files\Git\bin\git.exe'

# TODO: Use a hashmap
$CHROME_URL='https://download-chromium.appspot.com/dl/Win_x64?type=snapshots'
$ALTDRAG_URL='https://github.com/stefansundin/altdrag/releases/download/v1.1/AltDrag-1.1.exe'
$IRFANVIEW_URL='https://www.fosshub.com/IrfanView.html?dwl=iview459_x64_setup.exe'
$VSCODE_URL='https://code.visualstudio.com/sha/download?build=stable&os=win32-x64'
$STEAM_URL='https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
$OCULUS_URL='https://www.oculus.com/download_app/?id=1582076955407037'

Write-Output " -> Applying performance options"
reg import .\perf.reg
net stop themes
net start themes

Write-Output " -> Installing Git"
Invoke-WebRequest -Uri $GIT_URL -OutFile $env:TEMP\git.exe
$env:TEMP\git.exe /VERYSILENT /NORESTART

if (!exist $GIT_PATH) {
    Write-Output "Git download failed!"
    exit
}

Write-Output " -> Grabbing Windows 10 Debloater scripts"
$GIT_PATH clone 'https://github.com/Sycnex/Windows10Debloater' $env:TEMP\win10deb
$env:TEMP\win10deb\Windows10DebloaterGUI.ps1

Write-Output " -> Disabling (some) of the telemetry"
Get-Service DiagTrack | Set-Service -StartupType Disabled
Get-Service dmwappushservice | Set-Service -StartupType Disabled
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /v AllowTelemetry /t REG_DWORD /d 0 /f

Write-Output " -> Installing Chromium"
Invoke-WebRequest -Uri $CHROME_URL -OutFile $env:TEMP\chromium.exe
$env:TEMP\chromium.exe /silent /install

Write-Output " -> Installing AltDrag"
Invoke-WebRequest -Uri $ALTDRAG_URL -OutFile $env:TEMP\altdrag.exe
$env:TEMP\altdrag.exe /S

Write-Output " -> Installing IrfanView"
Invoke-WebRequest -Uri $IRFANVIEW_URL -OutFile $env:TEMP\irfanview.exe
$env:TEMP\irfanview.exe /silent /group=1 /allusers=1

Write-Output " -> Installing Visual Studio Code"
Invoke-WebRequest -Uri $VSCODE_URL -OutFile $env:TEMP\vscode.exe
$env:TEMP\vscode.exe /VERYSILENT /NORESTART /MERGETASKS=!runcode

Write-Output " -> Installing Steam"
Invoke-WebRequest -Uri $STEAM_URL -OutFile $env:TEMP\steam.exe
$env:TEMP\steam.exe /S

Write-Output " -> Installing Oculus PC App"
Invoke-WebRequest -Uri $OCULUS_URL -OutFile $env:TEMP\OculusSetup.exe
$env:TEMP\OculusSetup.exe /unattended

Write-Output " -> DONE!"

