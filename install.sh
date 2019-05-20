#!/bin/sh
# check which OS we're running on first
os=`uname -s`
vimrc=$HOME/.vimrc

if [ $os = "Haiku" ]; then
    vimrc=$HOME/.vim/vimrc
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
bashrc_path=$PWD/.bashrc
bashrc_dest=$HOME/.bashrc

if [ $os = "Haiku" ]; then
    bashrc_path=$PWD/haiku_bashrc
    bashrc_dest=$HOME/config/settings/profile
fi

if [ $os = "Darwin" ]; then
    bashrc_path=$PWD/.bash_profile
    bashrc_dest=$HOME/.bash_profile
fi

if [ -f $bashrc_dest ]; then
    rm -f $bashrc_dest
fi
ln -s $bashrc_path $bashrc_dest

if [ -f ~/.gitconfig ]; then
    rm -f ~/.gitconfig
fi
ln -s $PWD/.gitconfig ~/.gitconfig

if [ $os != "Haiku" ]; then
    # lunix vscode config
    if [ $os == "Darwin"]; then
        ln -s $PWD/vscode/ '~/Library/Application Support/Code/User/'
    else
        ln -s $PWD/vscode/ ~/.config/Code/User/
    fi

    # lunix posh config
    if [ -d ~/.config/powershell ]; then
        rm -rf ~/.config/powershell
    fi
    ln -s $PWD/posh ~/.config/powershell
    ln -s $PWD/posh/Modules/* ~/.local/share/powershell/Modules
fi
