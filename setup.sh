

install_apt_dependencies() {
    ALACRITTY_DEPS="cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev"
    APPS="
        git
	curl	
	python3
	${ALACRITTY_DEPS}
    "
    sudo apt install -y $APPS
}

install_nvim() {
    wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb
    sudo dpkg -i nvim-linux64.deb
    rm nvim-linux64.deb
}

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    rustup override set stable
    rustup update stable
}

install_alacritty() {
    git clone https://github.com/alacritty/alacritty.git .alacritty

    # Putting this in a function allows us to easily cd into the directory
    # While we configured Alacritty
    do_alacritty_work() {

	cargo build --release

	create_desktop_entry() {
            sudo cp target/release/alacritty /usr/local/bin
	    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
	    sudo desktop-file-install extra/linux/Alacritty.desktop
	    sudo update-desktop-database

	    cp /usr/share/applications/Alacritty.desktop ~/Desktop
	    chmod +x ~/Desktop/Alacritty.desktop
        }

	install_man_page() {
	    sudo mkdir -p /usr/local/share/man/man1
	    gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
	    gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
	}

	# Get Terminfo
	sudo tic -xe alacritty,alacritty-direct extra/alacritty.info &
	create_desktop_entry &
	install_man_page &
	# Install Bash completions
	echo "source $(pwd)/extra/completions/alacritty.bash" >> ~/.bashrc &
    }

    (cd .alacritty && do_alacritty_work)
}

configure_alacritty() {
    mkdir ~/.config/alacritty
    mkdir ~/.config/alacritty/themes
    touch ~/.config/alacritty/alacritty.yml
    wget https://raw.githubusercontent.com/eendroroy/alacritty-theme/master/themes/horizon-dark.yaml -P ~/.config/alacritty/themes

    add_to_config() {
        echo $1 >> ~/.config/alacritty/alacritty.yml
    }
    add_to_config 'import:'
    add_to_config '  - ~/.config/alacritty/alacritty.yml'
}

main() {

    # Apt dependencies should be install before everything else runs
    install_apt_dependencies
    install_nvim &
    (install_rust && install_alacritty && configure_alacritty) &
    
    sudo apt autoremove && sudo apt autoclean

}

main
