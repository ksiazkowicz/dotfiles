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

function docker-env { 
    $a = $args[0];
    $folder = $a.split("-")[0];
    & docker-machine env $a --shell powershell | Invoke-Expression; 
    if ($?) {
        "Current Docker Machine - $a"; 
        $Env:CurrentDM = $a; 
    }
}

$old_dc = get-command docker-compose
New-Alias docker-compose-old $old_dc

function docker-compose {
    reset-encoding
    docker-compose-old $args
    set-encoding
}

function docker-recompose {
    docker-compose stop
    if ($?) {
        docker-compose rm -f
    docker-compose build --force-rm
    }
    if ($?) {
        docker-compose up $args --force-recreate
    }
}

