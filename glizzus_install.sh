#!/bin/sh


install_applications() {
    
    LIST_OF_APPS="neovim
                  python3
                  python3-pip
                  tmux
                  tree
                  lynx
                  git
                  curl
                  openjdk-17-jdk-headless
                  nodejs
                  scala"

    sudo apt install -y $LIST_OF_APPS
    wait $!
}


get_jetbrains_toolbox() {
    
    mkdir -p $HOME/.jetbrains

    jet_url="https://download.jetbrains.com/toolbox/"\
"jetbrains-toolbox-1.24.12080.tar.gz"

    echo "Installing JetBrains Toolbox"
    curl -L $jet_url | tar zx -C $HOME/.jetbrains --strip-components 1
    echo "JetBrains toolbox installed"
}


change_background() {
    
    img_url="https://i.pinimg.com/originals/1f/"\
"a3/2c/1fa32c8411034fc4e838bd83fb6c0fc7.jpg"

    curl -o $HOME/Pictures/background.jpg $img_url
    gsettings set org.gnome.desktop.background picture-uri \
        file:////$HOME/Pictures/background.jpg
}


configure_neovim() {

    echo "Configuring Neovim"

    mkdir -p $HOME/.config/nvim
    touch $HOME/.config/nvim/init.vim
    echo \
"set nocompatible
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

}


configure_tmux() {
    
    touch $HOME/.tmux.conf
    echo "Configuring tmux"

    echo \
"unbind-key C-b
set-option -g prefix C-a
bind-key C-a send-prefix

set -g default-terminal screen-256color

set-window-option -g pane-border-style fg=colour11,bg=colour234
set-window-option -g pane-active-border-style fg=colour118,bg=colour234
set-window-option -g window-style fg=white,bg=colour236
set-window-option -g window-active-style fg=white,bg=colour235" \
    >> $HOME/.tmux.conf

    echo "Tmux configured"
}


configure_aliases() {

    echo "configuring bash aliases"
    touch $HOME/.bash_aliases

    echo \
"alias editvim='vim ~/.config/nvim/init.vim'
alias makevenv='python3 -m env ./venv'
alias startvenv='. ./venv/bin/activate'
alias toolbox='~/.jetbrains/./jetbrains-toolbox" \
        >> $HOME/.bash_aliases
}


main() {
    install_applications
    get_jetbrains_toolbox
    change_background
    configure_neovim
    configure_tmux
    configure_aliases

    sudo apt autoremove

    echo "done"
}

main
