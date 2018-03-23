# env variables
$env:WORKON_HOME = Join-Path $HOME "Envs"
$env:PYTHONIOENCODING = "UTF-8"
$env:VIRTUAL_ENV_DISABLE_PROMPT = "TRUE"

# New-Alias python3 "C:\Users\janis\AppData\Local\Programs\Python\Python36\python.exe"

$env:SCRIPTS_PATH = (get-item $profile).Directory

# imports
. "$env:SCRIPTS_PATH\Scripts\prompt.ps1"
. "$env:SCRIPTS_PATH\Scripts\helpers.ps1"
Import-Module posh-git
Import-Module virtualenvwrapper

# env variables for lunix
if ($PSVersionTable.Platform -like "Unix") {
    $global:VIRTUALENVWRAPPER_PYTHON = @(which python3)[0].definition
    $global:VIRTUALENVWRAPPER_VIRTUALENV = "virtualenv"
}

# aliases
New-Alias which get-command

# prompt
function prompt_old {
    write-host "$env:UserName@$env:ComputerName " -foreground green -n
    write-host ((pwd).Path) -foreground yellow
    write-host ">" -foreground gray -n
    return ' '
}

function global:set-ConsolePosition ([int]$x) { 
    # Get current cursor position and store away 
    $position=$host.ui.rawui.cursorposition 
    
    if ($x -le 0) {
        $x = $host.UI.RawUI.MaxWindowSize.Width + $x;
    }

    # Store new X Co-ordinate away 
    $position.x=$x 
    # Place modified location back to $HOST 
    $host.ui.rawui.cursorposition=$position 
}

function prompt {
    $script:last = $?;
    $script:first = $true;

    Write-PromptStatus
    #Write-PromptUser
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

function Import-VS2015
{
    Invoke-BatchFile "${env:VS140COMNTOOLS}vsvars32.bat" $vcargs
     #VCVARS invoke in VS2012 are silent...
    Write-Host "VS2015 vcvars loaded..."
}

function Sync-SSH
{
    cp -R /mnt/c/Users/Maciej/.ssh ~/
    chmod 644 ~/.ssh/*
}

if ($PSVersionTable.Platform -like "unix") {
    # docker toolbox on WSL
    new-alias "docker-machine" "docker-machine.exe"
    
    $env:VBOX_MSI_INSTALL_PATH='/c/Program Files/Oracle/VirtualBox/'
    pushd '/c/Program Files/Docker Toolbox' > /dev/null
    ./start.sh exit > /dev/null
    popd > /dev/null
    cd $($pwd.Path | sed 's/\/mnt\/c\//\/c\//')
}
