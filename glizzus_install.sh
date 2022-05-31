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


# Creates a temporary web installer script ------------------------------------

touch $HOME/tempwebinstaller.py
echo \
"
#!/usr/bin/python
from urllib.request import urlopen
import sys
url, dir = sys.argv[1], sys.argv[2]
print(sys.argv)
opened_url = urlopen(url)
with open(dir, 'wb+') as output:
    output.write(opened_url.read())" \
        >> $HOME/tempwebinstaller.py


# Installs JetBrains toolbox --------------------------------------------------

mkdir -p $HOME/.jetbrains

jet_url="https://download.jetbrains.com/toolbox/"\
"jetbrains-toolbox-1.24.12080.tar.gz"

python3 $HOME/tempwebinstaller.py $jet_url $HOME/.jetbrains/toolbox.tar.gz

echo "Extracting tar"
tar -xzf $HOME/.jetbrains/toolbox.tar.gz -C $HOME/.jetbrains
rm $HOME/.jetbrains/toolbox.tar.gz
mv $HOME/.jetbrains/*/* $HOME/.jetbrains
rm -r $HOME/.jetbrains/*/
echo "JetBrains toolbox installed"


# Change background -----------------------------------------------------------

img_url="https://i.pinimg.com/originals/1f/"\
"a3/2c/1fa32c8411034fc4e838bd83fb6c0fc7.jpg"

python3 $HOME/tempwebinstaller.py $img_url $HOME/Pictures/background.jpg
gsettings set org.gnome.desktop.background picture-uri \
    file:////$HOME/Pictures/background.jpg


# Configures neovim -------------------------------------

echo "Configuring Neovim"

mkdir -p $HOME/.config/nvim
touch $HOME/.config/nvim/init.vim
echo \
"
set nocompatible
filetype plugin indent on

set so=7
set ruler
set cmdheight=1
set hid
set wildmenu
set ignorecase
set smartcase
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set mat=2

syntax enable

colorscheme industry

set nobackup
set nowb
set noswapfile

set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

set lbr
set tw=500

set ai
set si
set wrap

set number
set cc=80
set mouse=a
set clipboard=unnamedplus
set ttyfast" \
	>> $HOME/.config/nvim/init.vim

echo "Adding file type plugins"

mkdir -p $HOME/.config/nvim/ftplugin

FILE_TYPES=("python" "c" "cpp")
for file_type in ${FILE_TYPES[@]}; do
	touch $HOME/.config/nvim/ftplugin/$file_type.vim
	echo "config file for $file_type created"
done

echo \
"setlocal expandtab
setlocal formatoptions=croql
nnoremap <buffer> <F8> :w <CR> :!python3 % <CR>" \
	>> $HOME/.config/nvim/ftplugin/python.vim


# Configures bash aliases -----------------------------------------

echo "configuring bash aliases"
touch $HOME/.bash_aliases

echo \
" 
alias editvim='vim ~/.config/nvim/init.vim'
alias makevenv='python3 -m env ./venv'
alias startvenv='. ./venv/bin/activate'" \
    >> $HOME/.bash_aliases

sudo apt autoremove
rm $HOME/tempwebinstaller.py

echo "done"
