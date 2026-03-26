# win-dev-setup

Simple Windows bootstrap script for common developer tools.

## Included

- Git
- GitHub CLI
- Node.js LTS
- Python 3.12
- FFmpeg
- Optional CLI tool via npm

## Quick Start

Download `windows_dev_tools_setup.bat` and run it in Command Prompt or PowerShell.

GitHub file:

`https://github.com/JaeHyukSuk/win-dev-setup/blob/master/windows_dev_tools_setup.bat`

Raw file:

`https://raw.githubusercontent.com/JaeHyukSuk/win-dev-setup/master/windows_dev_tools_setup.bat`

## PowerShell Download

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JaeHyukSuk/win-dev-setup/master/windows_dev_tools_setup.bat" -OutFile "windows_dev_tools_setup.bat"
.\windows_dev_tools_setup.bat
```

## Notes

- Some tools may need a new terminal window before commands are available.
- The script uses `winget` where possible.
- The optional npm CLI install is included but immediate verification is skipped on purpose.
