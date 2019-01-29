# env variables
$env:WORKON_HOME = Join-Path $HOME "Envs"
$env:PYTHONIOENCODING = "UTF-8"
$env:VIRTUAL_ENV_DISABLE_PROMPT = "TRUE"
$env:GIT_SSH = $(get-command ssh).Source
$env:DOCKER_DEFAULT_PLATFORM = "linux"

$env:SCRIPTS_PATH = (get-item $profile).Directory

# imports
. "$env:SCRIPTS_PATH\Scripts\prompt.ps1"
. "$env:SCRIPTS_PATH\Scripts\helpers.ps1"
Import-Module posh-git

function Switch-DefaultPython {}

if (Get-Command python -errorAction SilentlyContinue) {
    Import-Module VirtualEnvWrapper
}

# aliases
New-Alias which get-command

# prompt
function prompt {
    $script:last = $?;
    $script:first = $true;

    Write-PromptStatus
    Write-PromptVirtualEnv
    Write-PromptDir
    Write-PromptGit
    Write-PromptDockerMachine

    Write-PromptFancyEnd

    return ' ';
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function Invoke-BatchFile
{
    param([string]$Path, [string]$Parameters)

    $tempFile = [IO.Path]::GetTempFileName()

    ## Store the output of cmd.exe.  We also ask cmd.exe to output
    ## the environment table after the batch file completes
    cmd.exe /c " `"$Path`" $Parameters && set > `"$tempFile`" "

    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$")
        {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }

    Remove-Item $tempFile
}


if ($PSVersionTable.Platform -like "unix") {
    # venv on lunix
    $global:VIRTUALENVWRAPPER_PYTHON = @(which python3)[0].definition
    $global:VIRTUALENVWRAPPER_VIRTUALENV = "virtualenv"

    # check if WSL
    if (Test-Path "/mnt/c/WINDOWS" -PathType Container) {
        $global:IS_WSL = $true;

        # enable X11 under WSL
        $env:DISPLAY=":0.0"
        $env:LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libGL.so"
        $env:LIBGL_ALWAYS_INDIRECT="1"

        # Docker Toolbox on WSL
        if ($false -and (Test-Path "/mnt/c/Program Files/Docker Toolbox" -PathType Container)) {
            new-alias "docker-machine" "docker-machine.exe"

            $env:VBOX_MSI_INSTALL_PATH='/c/Program Files/Oracle/VirtualBox/'
            Push-Location '/c/Program Files/Docker Toolbox' > /dev/null
            ./start.sh exit > /dev/null
            Pop-Location > /dev/null
            Set-Location $($pwd.Path | sed 's/\/mnt\/c\//\/c\//')
        }
    }
}

if ($env:USE_VENV) {
    workon $env:USE_VENV;
}

if ($env:USE_DOCKERMACHINE) {
    docker-env $env:USE_DOCKERMACHINE;
}
