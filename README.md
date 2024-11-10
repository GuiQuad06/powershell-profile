# powershell-profile
Config file for my Powershell Profile for Win 11 sessions

## Clone the file
Go to this location : $HOME/.config
```
git clone git@github.com:GuiQuad06/powershell-profile.git powershell_profile
```

## Source the env in the master profile file
Open up Microsoft.PowerShell_profile.ps1 and add this :
```
. $env:USERPROFILE\.config\powershell_profile\user_profile.ps1
```
