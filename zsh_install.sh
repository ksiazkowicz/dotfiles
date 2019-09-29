#!/bin/bash
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh --depth=1
rm -rf ~/.oh-my-zsh/custom
ln -s $PWD/zsh ~/.oh-my-zsh/custom
ln -s $PWD/.zshrc ~/.zshrc
