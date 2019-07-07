# functions
function set-encoding {
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    [Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding 
    [Console]::InputEncoding  = New-Object -typename System.Text.UTF8Encoding
}

set-encoding

function reset-encoding {
    [Console]::OutputEncoding = [System.Text.Encoding]::Default;
}

function Toggle-CaseSensitivity {
    $PathRoot = $args[0];
    $EnableCaseSensitivity = $args[1];
    @(Get-ChildItem -Path $PathRoot -Recurse -Directory | Select-Object -ExpandProperty 'FullName') | ForEach-Object { 
cmd /c ('fsutil.exe file SetCaseSensitiveInfo "{0}" {1}' -f ($_,$(if($EnableCaseSensitivity){'enable'}else{'disable'}))) 
}
}

function docker-env {
    $a = $args[0];
    & docker-machine env $a --shell powershell | Invoke-Expression;
    if ($?) {
        "Current Docker Machine - $a";
        $Env:CurrentDM = $a;
    }
}

if (Test-Path alias:docker-compose-old) {
    Remove-Alias docker-compose-old
}
if (Test-Path function:docker-compose) {
    Remove-Item function:docker-compose
}
$oldDockerCompose = Get-Command docker-compose -errorAction SilentlyContinue
if ($oldDockerCompose) {
    New-Alias -Name "docker-compose-old" $oldDockerCompose.Source
}


function docker-compose {
    reset-encoding
    docker-compose-old $args
    set-encoding
}

function docker-recompose {
    [System.Collections.ArrayList]$Arguments = $args

    $fPosition = $args.IndexOf("-f")
    $fArgument = ""
    if ($fPosition -gt -1) {
        $fArgument = "-f" + $args[$fPosition + 1]
        $Arguments.RemoveAt($fPosition)
        $Arguments.RemoveAt($fPosition)
    }
    docker-compose $fArgument stop
    if ($?) {
        docker-compose $fArgument rm -f
    docker-compose $fArgument build --force-rm
    }
    if ($?) {
        docker-compose $fArgument up $Arguments --force-recreate
    }
}

function Generate-DjangoSecretKey {
    python manage.py shell -c "from django.core.management import utils; print(utils.get_random_secret_key())"
}

function grep-kill {
    if ($PSVersionTable.Platform -like "Win32NT") {
        $process = "*$($args -join '*')*"
        kill -Id $(Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -like $process}).ProcessId -Force 2> /dev/null
    } else {
        kill $(ps aux | grep $args | awk '{print $2}') -Force 2> /dev/null
    }
}

function Fix-RecycleBin
{
    Remove-Item -r -Force C:\`$Recycle.bin
}

function Sync-SSH
{
    cp -R /mnt/c/Users/$env:UserName/.ssh ~/
    chmod 700 ~/.ssh/*
}

function Assume-Role {
    param([string]$Role)
    aws-vault exec $Role -- pwsh -NoLogo
}


if ($PSVersionTable.Platform -like "Win32NT") {
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
}