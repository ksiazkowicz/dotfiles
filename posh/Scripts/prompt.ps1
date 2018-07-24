$script:bg    = [Console]::BackgroundColor;
$script:fg    = [Console]::ForegroundColor;
$script:last  = 0;
$script:hadBg = $false;

function Write-PromptFancyEnd {
    if ($script:hadBg) {
        Write-Host  -NoNewline -ForegroundColor $script:bg
    } else {
        Write-Host  -NoNewline -ForegroundColor $script:fg
    }
    $script:bg = [System.ConsoleColor]::Black
}

function Write-PromptSegment {
    param(
        [Parameter(
            Position=0,
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )][string]$Text,

        [Parameter(Position=1)][System.ConsoleColor] $Background = [Console]::BackgroundColor,
        [Parameter(Position=2)][System.ConsoleColor] $Foreground = [System.ConsoleColor]::White
    )

    $hasBg = $Background -ne [System.ConsoleColor]::Black;

    if (!$script:first) {
        if ($script:hadBg -or $hasBg) {
            Write-Host  -NoNewline -BackgroundColor $Background -ForegroundColor $script:bg
        } else {
            Write-Host  -NoNewLine -BackgroundColor $Background -ForegroundColor $script:fg
        }
    } else {
        $script:first = $false;
    }

    $script:hadBg = $hasBg

    Write-Host $text -NoNewline -BackgroundColor $Background -ForegroundColor $Foreground

    $script:bg = $Background;
    $script:fg = $Foreground;
}

function Get-FancyDir {
    $separator = "\";
    $location = $(Get-Location).ToString();
    if ($PSVersionTable.Platform -like "unix") {
        $separator = "/";
        if (($location[0] -eq $separator) -and (!$location.StartsWith($env:HOME))) {
            $location = $location.Substring(1);
        }
    }
    return $location.Replace($env:HOME, '~').Replace($separator, '  ');
}

function Get-GitBranch {
    $HEAD = Get-Content $(Join-Path $(Get-GitDirectory) HEAD)
    if($HEAD -like 'ref: refs/heads/*') {
        return $HEAD -replace 'ref: refs/heads/(.*?)', "$1";
    } else {
        return $HEAD.Substring(0, 8);
    }
}

function Write-PromptStatus {
    if ($script:last) {
        Write-PromptSegment ' ✔  ' Black Green
    } else {
        Write-PromptSegment " ✖  $lastexitcode " Black Red
    }
}

function Write-PromptVirtualEnv {
    if($env:VIRTUAL_ENV) {
        Write-PromptSegment " $(split-path $env:VIRTUAL_ENV -leaf) " Black Yellow
    }
}

function Write-PromptDockerMachine {
    if ($env:CurrentDM) {
        Write-PromptSegment " $env:CurrentDM " DarkBlue White
    }
}

function Write-PromptDir {
    Write-PromptSegment " $(Get-FancyDir) " Black DarkCyan
}

# Depends on posh-git
function Write-PromptGit {
    if(Get-GitDirectory) {
        Write-PromptSegment "  $(Get-GitBranch) " Black Magenta
    }
}
