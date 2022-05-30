#!/bin/sh


# Installs applications ----------------------------------

LIST_OF_APPS="neovim 
			  python3
			  python3-pip
			  tmux
			  tree
			  lynx
			  git"

sudo apt install -y $LIST_OF_APPS
wait $!

# Installs JetBrains toolbox ----------------------------

mkdir -p $HOME/.jetbrains
python3 - $HOME << END
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
tar -xzf $HOME/.jetbrains/toolbox.tar.gz -C $HOME/.jetbrains
rm $HOME/.jetbrains/toolbox.tar.gz
mv $HOME/.jetbrains/*/* $HOME/.jetbrains
rm -r $HOME/.jetbrains/*/
echo "JetBrains toolbox installed"

# Configures neovim -------------------------------------

echo "Configuring Neovim"

mkdir -p $HOME/.config/nvim
touch $HOME/.config/nvim/init.vim
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
	>> $HOME/.config/nvim/init.vim

echo "Adding file type plugins"

mkdir -p $HOME/.config/nvim/ftplugin

FILE_TYPE_PLUGINS=("python" "c" "cpp")
for plugin in ${FILE_TYPE_PLUGINS[@]}; do
	touch $HOME/.config/nvim/ftplugin/$plugin.vim
	echo "config file for $plugin created"
done

echo "setlocal expandtab
setlocal formatoptions=croql
nnoremap <buffer> <F8> :w <CR> :!python3 % <CR>" \
	>> $HOME/.config/nvim/ftplugin/python.vim

# Configures bash aliases -----------------------------------------

echo "configuring bash aliases"
touch $HOME/.bash_aliases

echo "alias editvim='vim ~/.config/nvim/init.vim" \
	>> $HOME/.bash_aliases

echo "done"
