# Windows 11 Taskbar Backup

PowerShell scripts to back up and restore taskbar pinned items for the current user.

## Usage

Keep both scripts in the same folder. Open PowerShell in that folder and run them as the Windows user whose pinned items you want to manage.

### Back up

```powershell
.\backup-taskbar.ps1
```

The backup is saved beside the scripts:

```text
TaskbarBackup/
├── Shortcuts/
└── Taskband.reg
```

Running the backup again replaces the previous backup.

### Restore

```powershell
.\restore-taskbar.ps1
```

This replaces the current taskbar shortcut files and the registry key:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband
```

After restoring, open Task Manager with **Ctrl + Shift + Esc**, right-click **Windows Explorer**, and select **Restart**. The script displays these instructions and does not restart Explorer automatically.

## Notes

- Intended for restoring pinned items for the same Windows user on the same PC. Applications must still be installed at the expected paths.
- These scripts back up pinned items, not all taskbar settings.
- Backups can contain personal paths and application information. Consider adding `TaskbarBackup/` to your `.gitignore` before committing.
