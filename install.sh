#!/bin/sh
# check which OS we're running on first
os=`uname -o`
vimrc='~/.vimrc'

if [ $os = "Haiku" ]; then
    vimrc='~/.vim/vimrc'
fi

# copy vimfiles
if [ -d ~/.vim ]; then
    rm -rf ~/.vim
fi
ln -s $PWD/.vim ~/.vim

# install vimplug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ -f $vimrc ]; then
    rm -f $vimrc
fi
ln -s $PWD/.vimrc $vimrc

# symlinks
if [ -f ~/.bashrc ]; then
    rm -f ~/.bashrc
fi
ln -s $PWD/.bashrc ~/.bashrc

if [ -f ~/.bashrc ]; then
    rm -f ~/.gitconfig
fi
ln -s $PWD/.gitconfig ~/.gitconfig

if [ $os != "Haiku" ]; then
    # lunix vscode config
    ln -s $PWD/vscode/settings.json ~/.config/Code/User/settings.json
    ln -s $PWD/vscode/keybindings.json ~/.config/Code/User/keybindings.json

    # lunix posh config
    if [ -d ~/.config/powershell ]; then
        rm -rf ~/.config/powershell
    fi
    ln -s $PWD/posh ~/.config/powershell
    ln -s $PWD/posh/Modules/* ~/.local/share/powershell/Modules
fi
