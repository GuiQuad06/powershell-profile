# Prompt
# Custom lightweight prompt (no external binary, unlike oh-my-posh which was slow here)
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\thecyberden.omp.json" | Invoke-Expression

$Script:PromptColor = @{
	Green  = "$([char]27)[32m"
	Orange = "$([char]27)[38;5;208m"
	Yellow = "$([char]27)[33m"
	Red    = "$([char]27)[31m"
	Cyan   = "$([char]27)[36m"
	Reset  = "$([char]27)[0m"
}

# Red marker shown only when the previous command failed
function Get-PromptExitCodeSegment ($Success, $ExitCode) {
	if ($Success) { return }

	$label = if ($ExitCode) { "exit $ExitCode" } else { 'FAILED' }
	"$($Script:PromptColor.Red)[$label]$($Script:PromptColor.Reset)"
}

# Conda environment, e.g. "(base)" in green
function Get-PromptCondaSegment {
	if ($env:CONDA_DEFAULT_ENV) {
		"$($Script:PromptColor.Green)($env:CONDA_DEFAULT_ENV)$($Script:PromptColor.Reset)"
	}
}

# Git branch + dirty flag in blue, only shown when the current path is inside a git repo.
# Computed once (git is slow) and cached; refreshed on cd, or when .git/HEAD's write time changes (e.g. checkout).
$Script:GitSegment = $null
$Script:GitHeadFile = $null
$Script:GitHeadWriteTime = $null

function Update-PromptGitSegment {
	$Script:GitSegment = $null
	$Script:GitHeadFile = $null
	$Script:GitHeadWriteTime = $null

	if ((git rev-parse --is-inside-work-tree 2>$null) -ne 'true') { return }

	$branch = git rev-parse --abbrev-ref HEAD 2>$null
	if (-not $branch) { return }

	$dirty = if (git status --porcelain 2>$null) { '*' } else { '' }
	$Script:GitSegment = "$($Script:PromptColor.Orange)[$branch$dirty]$($Script:PromptColor.Reset)"

	$gitDir = git rev-parse --git-dir 2>$null
	$headFile = if ($gitDir) { Join-Path -Path $gitDir -ChildPath 'HEAD' }
	if ($headFile -and (Test-Path -Path $headFile -PathType Leaf)) {
		$Script:GitHeadFile = $headFile
		$Script:GitHeadWriteTime = (Get-Item -Path $headFile).LastWriteTimeUtc
	}
}
Update-PromptGitSegment

function Get-PromptGitSegment {
	$Script:GitSegment
}

# Perforce stream in cyan, only shown when the current directory has a .p4config file.
# Computed once (p4 is slow) and cached; call Update-PromptP4Segment after cd-ing into another p4 workspace to refresh it.
$Script:P4Segment = $null

function Update-PromptP4Segment {
	$Script:P4Segment = $null

	if (-not (Test-Path -Path '.p4config' -PathType Leaf)) { return }

	$stream = p4 -ztag -F "%Stream%" client -o 2>$null
	if (-not $stream) { return }

	$Script:P4Segment = "$($Script:PromptColor.Cyan)[$stream]$($Script:PromptColor.Reset)"
}
Update-PromptP4Segment

function Get-PromptP4Segment {
	$Script:P4Segment
}

# Tracks the directory the VCS segments were last computed for, so the prompt can refresh them on cd
$Script:LastPromptPath = $PWD.Path

# Add environment variable names here to surface them in the prompt, e.g. @('BUILD_TARGET')
$Script:PromptEnvVars = @()

function Get-PromptBuilderThreadsSegment {
	if ($env:FDE_MAX_BUILDER_THREADS) {
		"$($Script:PromptColor.Orange)[$($env:FDE_MAX_BUILDER_THREADS) Threads]$($Script:PromptColor.Reset)"
	}
}

function Get-PromptEnvSegment {
	# NEO_PORT is written by the Cochlear PythonToolbox when a device is paired
	$comPort = Get-ItemPropertyValue -Path 'HKCU:\Software\Cochlear\PythonToolbox\Config\NEO_PORT' -Name 'Value' -ErrorAction SilentlyContinue

	$pairs = @()
	if ($comPort) { $pairs += "$comPort" }
	$pairs += foreach ($name in $Script:PromptEnvVars) {
		$value = [Environment]::GetEnvironmentVariable($name)
		if ($value) { "$name=$value" }
	}

	if ($pairs) {
		"$($Script:PromptColor.Yellow)[$($pairs -join '; ')]$($Script:PromptColor.Reset)"
	}
}

function prompt {
	# Must be captured before any other command runs in this function, or they get overwritten
	$lastSuccess = $?
	$lastExitCode = $LASTEXITCODE

	if ($PWD.Path -ne $Script:LastPromptPath) {
		$Script:LastPromptPath = $PWD.Path
		Update-PromptGitSegment
		Update-PromptP4Segment
	}
	elseif ($Script:GitHeadFile -and (Test-Path -Path $Script:GitHeadFile -PathType Leaf)) {
		# Catches branch switches (e.g. git checkout), which change HEAD without changing $PWD
		if ((Get-Item -Path $Script:GitHeadFile).LastWriteTimeUtc -ne $Script:GitHeadWriteTime) {
			Update-PromptGitSegment
		}
	}

	$parts = @(
		(Get-PromptExitCodeSegment -Success $lastSuccess -ExitCode $lastExitCode)
		(Get-PromptCondaSegment)
		$PWD.Path
		(Get-PromptGitSegment)
		(Get-PromptP4Segment)
		(Get-PromptEnvSegment)
		(Get-PromptBuilderThreadsSegment)
	) | Where-Object { $_ }

	($parts -join ' ') + "`n$('--->' * ($NestedPromptLevel + 1)) "
}

# Icons
if (Get-Module -ListAvailable -Name Terminal-Icons) {
	Import-Module -Name Terminal-Icons
}

# PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadlineOption -PredictionSource History

# FZF
if (Get-Module -ListAvailable -Name PSFzf) {
	Import-Module -Name PSFzf
	Set-PSFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

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
