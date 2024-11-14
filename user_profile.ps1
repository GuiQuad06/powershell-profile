# Prompt
# This is very slow ! Wondering if the Trend Micro is not scanning my C:\dev :(
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\thecyberden.omp.json" | Invoke-Expression

# Icons
Import-Module -Name Terminal-Icons

# PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadlineOption -PredictionSource History

# FZF
Import-Module PSFzf
Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias
Set-Alias ll ls
Set-Alias .. 'cd..'
Set-Alias grep findstr
Set-Alias tig 'C:\dev\Git\usr\bin\tig.exe'
Set-Alias np 'C:\Program Files\Notepad++\notepad++.exe'

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
