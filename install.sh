#!/bin/sh
# check which OS we're running on first
os=`uname -o`
vimrc='~/.vimrc'

if [ $os = "Haiku" ]; then
    vimrc='~/.vim/vimrc'
fi

# install vimplug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# copy vimfiles
cp -r $PWD/.vim ~/
ln -s $PWD/.vimrc $vimrc

# symlinks
ln -s $DIR/.gitconfig ~/.gitconfig

# lunix posh config
if [ $os != "Haiku" ]; then
    ln -s $PWD/posh ~/.config/powershell
fi
