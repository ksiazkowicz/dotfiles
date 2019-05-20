# posh config
$scripts_path = Split-Path -Path $profile

if (Test-Path $scripts_path -PathType Container) {
    Write-Output "POSH config directory exists, remove it first"
    Remove-Item -Force $scripts_path
}
New-Item -Type SymbolicLink -Path $scripts_path -Value $(Join-Path $PSScriptRoot posh)

# install plug
Copy-Item -r .vim ~
mkdir ~/.vim/autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
  $uri,
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    "~/.vim/autoload/plug.vim"
  )
)

# symlinks
New-Item -Type SymbolicLink -Path ~/.vimrc -Value $(Join-Path $PSScriptRoot .vimrc)
New-Item -Type SymbolicLink -Path ~/.gitconfig -Value $(Join-Path $PSScriptRoot .gitconfig_win)
New-Item -Type SymbolicLink -Path ~/.gitattributes -Value $(Join-Path $PSScriptRoot .gitattributes)
New-Item -Type SymbolicLink -Path ~/AppData/Roaming/ConEmu.xml -Value $(Join-Path $PSScriptRoot ConEmu.xml)
New-Item -Type SymbolicLink -Path ~/AppData/Roaming/Code/User/settings.json -Value $(Join-Path $PSScriptRoot vscode/settings.json)
New-Item -Type SymbolicLink -Path ~/AppData/Roaming/Code/User/keybindings.json -Value $(Join-Path $PSScriptRoot vscode/keybindings.json)

# posh modules
Install-Module posh-git
Install-Module windows-screenfetch
Install-Module PSBashCompletions
