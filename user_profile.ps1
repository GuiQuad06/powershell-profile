# Prompt
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-PoshPrompt Paradox
oh-my-posh init pwsh --config ".config\posh\thecyberden.omp.json" | Invoke-Expression

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
Set-Alias d pwd
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias np 'C:\Program Files\Notepad++\notepad++.exe'

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
