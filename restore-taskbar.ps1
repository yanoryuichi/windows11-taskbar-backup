# Windows 11 taskbar pinned-item restore (current user).
# Explorer is never stopped or restarted by this script.
$ErrorActionPreference = 'Stop'

$backupDir = Join-Path $PSScriptRoot 'TaskbarBackup'
$shortcutBackupDir = Join-Path $backupDir 'Shortcuts'
$taskbarShortcutDir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
$taskbandKey = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
$taskbandProviderPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
$regFile = Join-Path $backupDir 'Taskband.reg'

if (-not (Test-Path -LiteralPath $regFile -PathType Leaf)) {
    throw "バックアップが見つかりません: $regFile"
}
if (-not (Test-Path -LiteralPath $shortcutBackupDir -PathType Container)) {
    throw "バックアップが見つかりません: $shortcutBackupDir"
}

# Read the backup before modifying the current pinned items.
$backupFiles = @(Get-ChildItem -LiteralPath $shortcutBackupDir -File -Force)
$regContent = Get-Content -LiteralPath $regFile -Raw
if ($regContent -notmatch '(?m)^\[HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Taskband\]\s*$') {
    throw 'バックアップに Taskband レジストリが含まれていません。'
}

Write-Host '現在のタスクバーピン留め情報をバックアップの内容で置き換えます。'
Write-Host "バックアップ元: $backupDir"

New-Item -ItemType Directory -Path $taskbarShortcutDir -Force | Out-Null
Get-ChildItem -LiteralPath $taskbarShortcutDir -File -Force | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Force
}
foreach ($file in $backupFiles) {
    Copy-Item -LiteralPath $file.FullName -Destination $taskbarShortcutDir -Force
}

if (Test-Path -LiteralPath $taskbandProviderPath) {
    & reg.exe delete $taskbandKey /f
    if ($LASTEXITCODE -ne 0) {
        throw '現在の Taskband レジストリの削除に失敗しました。'
    }
}

& reg.exe import $regFile
if ($LASTEXITCODE -ne 0) {
    throw 'Taskband レジストリの復元に失敗しました。'
}

Write-Host
Write-Host 'タスクバーのピン留め情報を復元しました。' -ForegroundColor Green
Write-Host '表示に反映するため、次の操作を行ってください。'
Write-Host '1. Ctrl + Shift + Esc でタスクマネージャーを開きます。'
Write-Host '2. 「プロセス」で「Windows Explorer」（日本語表示では「エクスプローラー」）を探します。'
Write-Host '3. 右クリックして「再起動」を選びます。'
Write-Host 'このスクリプトは Explorer を自動再起動しません。'
