Write-Output "Checking for updates"
wuauclt /detectnow /updatenow

$yesno='&Yes','&No'

$confirmation = $Host.UI.PromptForChoice("Restore point", "Do you wish to create a system restore point?", $yesno, 0)
if ($confirmation -eq 0) {
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "WinInstaller Restore Point" -RestorePointType "MODIFY_SETTINGS"
}

$GIT_URL='https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe'
$GIT_PATH='C:\Program Files\Git\bin\git.exe'

# TODO: Use a hashmap
$FIREFOX_URL = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$ALTDRAG_URL='https://github.com/stefansundin/altdrag/releases/download/v1.1/AltDrag-1.1.exe'
$IRFANVIEW_URL='https://download.betanews.com/download/967963863-1/iview459_x64_setup.exe'
$VSCODE_URL='https://code.visualstudio.com/sha/download?build=stable&os=win32-x64'
$STEAM_URL='https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
$OCULUS_URL='https://www.oculus.com/download_app/?id=1582076955407037'

Write-Output " -> Applying performance options"
reg import .\perf.reg
net stop themes
net start themes

Write-Output " -> Installing Git"
Invoke-WebRequest -Uri $GIT_URL -OutFile $env:TEMP\git.exe
Start-Process -Filepath "$env:TEMP\git.exe" -ArgumentList @('/VERYSILENT', '/NORESTART') -Wait

if (![System.IO.File]::Exists($GIT_PATH)) {
    Write-Output " -> Git instalation failed!"
    exit
}

Write-Output " -> Grabbing Windows 10 Debloater scripts"
Start-Process -Filepath "$GIT_PATH" -ArgumentList @('clone', 'https://github.com/Sycnex/Windows10Debloater', "$env:TEMP\win10deb") -Wait
Start-Process powershell.exe -ArgumentList @("$env:TEMP\win10deb\Windows10DebloaterGUI.ps1") -Wait

Write-Output " -> Disabling (some) of the telemetry"
Get-Service DiagTrack | Set-Service -StartupType Disabled
Get-Service dmwappushservice | Set-Service -StartupType Disabled
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\ /v AllowTelemetry /t REG_DWORD /d 0 /f

Write-Output " -> Installing Firefox"
Invoke-WebRequest -Uri $FIREFOX_URL -OutFile $env:TEMP\firefox.exe
Start-Process -Filepath "$env:TEMP\firefox.exe" -ArgumentList @('/S') -Wait

Write-Output " -> Installing AltDrag"
Invoke-WebRequest -Uri $ALTDRAG_URL -OutFile $env:TEMP\altdrag.exe
Start-Process -Filepath "$env:TEMP\altdrag.exe" -ArgumentList @('/S') -Wait

Write-Output " -> Installing IrfanView"
Invoke-WebRequest -Uri $IRFANVIEW_URL -OutFile $env:TEMP\irfanview.exe
Start-Process -Filepath "$env:TEMP\irfanview.exe" -ArgumentList @('/silent', '/group=1', '/allusers=1') -Wait

Write-Output " -> Installing Visual Studio Code"
Invoke-WebRequest -Uri $VSCODE_URL -OutFile $env:TEMP\vscode.exe
Start-Process -Filepath "$env:TEMP\vscode.exe" -ArgumentList @('/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode') -Wait

Write-Output " -> Installing Steam"
Invoke-WebRequest -Uri $STEAM_URL -OutFile $env:TEMP\steam.exe
Start-Process -Filepath "$env:TEMP\steam.exe" -ArgumentList @('/S') -Wait

Write-Output " -> Installing Oculus PC App"
Invoke-WebRequest -Uri $OCULUS_URL -OutFile $env:TEMP\OculusSetup.exe
Start-Process -Filepath "$env:TEMP\OculusSetup.exe" -ArgumentList @('/unattended') -Wait

Write-Output " -> DONE!"

