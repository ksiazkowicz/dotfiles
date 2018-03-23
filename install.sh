#!/bin/sh

# install vimplug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# copy vimfiles
cp -r $PWD/.vim ~/
ln -s $PWD/.vimrc ~/.vimrc

# symlinks
ln -s $DIR/.gitconfig ~/.gitconfig

# lunix posh config
ln -s $PWD/posh ~/.config/powershell
