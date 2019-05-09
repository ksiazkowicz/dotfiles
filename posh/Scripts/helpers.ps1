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

if (Get-Command docker-compose -errorAction SilentlyContinue) {
    $old_dc = get-command docker-compose
    New-Alias docker-compose-old $old_dc
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
    kill $(ps aux | grep $args | awk '{print $2}') -Force 2> /dev/null
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
