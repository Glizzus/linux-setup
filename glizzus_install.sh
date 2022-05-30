#!/bin/sh

home=$(getent passwd $SUDO_USER | cut -d: -f6)
echo $home

# Installs applications ----------------------------------

LIST_OF_APPS="neovim 
			  python3
			  python3-pip
			  tmux
			  tree
			  lynx
			  git"

apt install -y $LIST_OF_APPS
wait $!

# Installs JetBrains toolbox ----------------------------

mkdir -p $home/.jetbrains
python3 - $home << END
from urllib.request import urlopen
import sys

url = 'https://download.jetbrains.com/toolbox/' \
      'jetbrains-toolbox-1.24.12080.tar.gz'
opened_url = urlopen(url)
print('Connected to JetBrains URL')
user_home = sys.argv[1]
directory = user_home + '/.jetbrains/toolbox.tar.gz'
with open(directory, 'wb+') as output:
    output.write(opened_url.read())
print('JetBrains toolbox tar downloaded')
END

echo "Extracting tar"
tar -xzf $home/.jetbrains/toolbox.tar.gz -C $home/.jetbrains
rm $home/.jetbrains/toolbox.tar.gz
mv $home/.jetbrains/*/* $home/.jetbrains
rm -r $home/.jetbrains/*/
echo "JetBrains toolbox installed"

# Configures neovim -------------------------------------

echo "Configuring Neovim"

touch $home/.config/nvim/init.vim
echo "set nocompatible
set showmatch
set ignorecase
set mouse=v
set hlsearch
set incsearch
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set number
set wildmode=longest,list
set cc=80
filetype plugin indent on
syntax on
set mouse=a
set clipboard=unnamedplus
set ttyfast
set filetype
filetype plugin on" \
	>> $home/.config/nvim/init.vim

mkdir -p $home/.config/nvim/ftplugin

FILE_TYPE_PLUGINS=("python", "c", "cpp")
for plugin in ${FILE_TYPE_PLUGINS[@]}; do
	touch $home/.config/nvim/ftplugin/$plugin.vim
done

echo "setlocal expandtab
setlocal formatoptions=croql
nnoremap <buffer> <F8> :w <CR> :!python3 % <CR>" \
	>> $home/.config/nvim/ftplugin/python.vim

# Configures bash aliases -----------------------------------------

touch $home/.bash_aliases

echo "alias editvim='vim ~/.config/nvim/init.vim" \
	>> $home/.bash_aliases

