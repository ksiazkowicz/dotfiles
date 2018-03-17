# set-strictmode -version "2.0"

$ACTIVATE_SCRIPT_TEMPLATE = @'
# This file must be dot sourced from PoSh; you cannot run it
# directly. Do this: . ./activate.ps1

# FIXME: clean up unused vars.
$script:THIS_PATH = $myinvocation.mycommand.path
$script:BASE_DIR = split-path (resolve-path "$THIS_PATH/..") -Parent
$script:DIR_NAME = split-path $BASE_DIR -Leaf

# unset irrelevant variables
if (test-path function:deactivate) {
    deactivate -nondestructive
}

$VIRTUAL_ENV = $BASE_DIR
$env:VIRTUAL_ENV = $VIRTUAL_ENV

$global:_OLD_VIRTUAL_PATH = $env:PATH
if (!($PSVersionTable.Platform -like "unix")) {
    $env:PATH = "$env:VIRTUAL_ENV/$global:VIRTUALENVWRAPPER_DIR;" + $env:PATH
} else {
    $env:PATH = "$env:VIRTUAL_ENV/$global:VIRTUALENVWRAPPER_DIR`:" + $env:PATH
}

Switch-DefaultPython
# function global:_old_virtual_prompt { "" }
# $function:_old_virtual_prompt = $function:prompt
# function global:prompt {
    # Add a prefix to the current prompt, but don't discard it.
#     write-host "($(split-path $env:VIRTUAL_ENV -leaf))" -nonewline
#    & $function:_old_virtual_prompt
# }

function global:deactivate ( [switch] $NonDestructive ){

    $venv = split-path $env:VIRTUAL_ENV -leaf
    [void] (New-Event -SourceIdentifier 'VirtualEnvWrapper.PreDeactivateVirtualEnv' -eventarguments $venv)
    # RunHook "pre_deactivate"
    if ( test-path variable:_OLD_VIRTUAL_PATH ) {
        $env:PATH = $variable:_OLD_VIRTUAL_PATH
        remove-variable "_OLD_VIRTUAL_PATH" -scope global
    }

    if ( test-path function:_old_virtual_prompt ) {
        $function:prompt = $function:_old_virtual_prompt
        remove-item function:\_old_virtual_prompt
    }

    if ($env:VIRTUAL_ENV) {
        $old_env = split-path $env:VIRTUAL_ENV -leaf
        remove-item env:VIRTUAL_ENV -erroraction silentlycontinue
        [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PostDeactivateVirtualEnv' -EventArguments $old_env)
        # RunHook "post_deactivate" $old_env
    }

    Switch-DefaultPython

    if ( !$NonDestructive ) {
        # SELF DESTRUCT!
        remove-item function:deactivate
    }
}
'@

function add_posh_to_virtualenv {
    param([string] $TargetPath)

    if (test-path "$TargetPath/$global:VIRTUALENVWRAPPER_DIR") {
        Set-Content "$TargetPath/$global:VIRTUALENVWRAPPER_DIR/activate.ps1" `
                    $ACTIVATE_SCRIPT_TEMPLATE `
                    -encoding "UTF8"
        write-host "Added activation script for Powershell to $TargetPath\$global:VIRTUALENVWRAPPER_DIR."
    }
    else {
        Write-Warning "Couldn't copy PoSh activate script to new virtual environment."
    }
}

function getCurrentPythonExe { resolve-path (@(get-command "python")[0]).Path }
function getCurrentPythonWExe { 
    if (!($PSVersionTable.Platform -like "unix")) {
        resolve-path (@(get-command "pythonw")[0]).Path 
    } else { return }
}

function switchPythonFTypeOpenCmd
{
    if (!($PSVersionTable.Platform -like "unix")) {
        $HKCU_SOFT_CLASS = "HKCU:/Software/Classes"

        if (-not(test-path "$HKCU_SOFT_CLASS/Python.File/shell/open/command"))
        {
            new-item "$HKCU_SOFT_CLASS/Python.File/shell/open/command" -Force > $null
            set-itemproperty -path "$HKCU_SOFT_CLASS/Python.File/shell/open" -name "(default)" -value "Open"
        }
        if (-not(test-path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command"))
        {
            new-item "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command" -Force > $null
            set-itemproperty -path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open" -name "(default)" -value "Open"
        }
        if (-not(test-path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command"))
        {
            new-item "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command" -Force > $null
            set-itemproperty -path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open" -name "(default)" -value "Open"
        }
    }

    $currPython = getCurrentPythonExe
    $currPythonW = getCurrentPythonWExe

    if (!($PSVersionTable.Platform -like "unix")) {
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.File/shell/open/command" -name "(default)" -value "`"$currPython`" `"%1`" %*"
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command" -name "(default)" -value "`"$currPython`" `"%1`" %*"
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command" -name "(default)" -value "`"$currPythonW`" `"%1`" %*"
    }
}

function switchPythonCore
{
    $currPython = getCurrentPythonExe
    $currPythonW = getCurrentPythonWExe
    $pyVer = & { $OFS = ""; "$((& "python" "-V" 2>&1).ToString().split(" ")[1][0..2])" }

    if ($currPython -like "*$global:VIRTUALENVWRAPPER_DIR*")
    {
        $pyBase = resolve-path "$(split-path $currPython -parent)/.."
    }
    else
    {
       $pyBase = resolve-path (split-path $currPython -parent)
    }

    if (!($PSVersionTable.Platform -like "unix")) {
        if (-not(test-path "HKCU:/Software/Python/PythonCore"))
        {
            new-item "HKCU:/Software/Python/PythonCore/$pyVer/InstallPath" -Force > $null
            new-item "HKCU:/Software/Python/PythonCore/$pyVer/PythonPath" > $null
        }
        set-itemproperty -path "HKCU:/Software/Python/PythonCore/$pyVer/InstallPath" -name "(default)" -value $pyBase
        set-itemproperty -path "HKCU:/Software/Python/PythonCore/$pyVer/PythonPath" -name "(default)" -value "$pyBase\Lib;$pyBase\DLLs;$pyBase\Lib\lib-tk"
    }
}

function Switch-DefaultPython
{
<#
    .SYNOPSIS
    Sets the default python interpreter to the currently active virtualenv. This
    way you can run scripts like so:

        ./myscripts.py

    Otherwise you have to run them like this:

        python ./myscripts.py
#>
    switchPythonFTypeOpenCmd
    switchPythonCore
}
