# Windows 11 taskbar pinned-item backup (current user).
$ErrorActionPreference = 'Stop'

$backupDir = Join-Path $PSScriptRoot 'TaskbarBackup'
$shortcutBackupDir = Join-Path $backupDir 'Shortcuts'
$taskbarShortcutDir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
$taskbandKey = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
$taskbandProviderPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
$regFile = Join-Path $backupDir 'Taskband.reg'

if (-not (Test-Path -LiteralPath $taskbandProviderPath)) {
    throw 'Taskband レジストリが見つかりません。バックアップを中止します。'
}

New-Item -ItemType Directory -Path $shortcutBackupDir -Force | Out-Null

& reg.exe export $taskbandKey $regFile /y
if ($LASTEXITCODE -ne 0) {
    throw 'Taskband レジストリのバックアップに失敗しました。'
}

# Remove old backup files so unpinned shortcuts do not remain in the backup.
Get-ChildItem -LiteralPath $shortcutBackupDir -File -Force | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Force
}

# An absent or empty shortcut folder is valid for some pinned applications.
if (Test-Path -LiteralPath $taskbarShortcutDir -PathType Container) {
    Get-ChildItem -LiteralPath $taskbarShortcutDir -File -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $shortcutBackupDir -Force
    }
}

Write-Host
Write-Host 'タスクバーのピン留め情報をバックアップしました。' -ForegroundColor Green
Write-Host "保存先: $backupDir"
