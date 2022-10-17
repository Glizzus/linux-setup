

install_apt_dependencies() {
    FUN_STUFF="neofetch sl lolcat"
    ALACRITTY_DEPS="cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev"
    APPS="
        git
	curl	
	python3
	${FUN_STUFF}
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

uncomment_bash_line() {
    line=$1
    file=$2
    # Substitute beginning of matched line with nothing if
    # the line starts with a hashtag
    sed "/${line}/s/^#//" -i $file
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
    uncomment_bash_line 'force_color_prompt=yes' '~/.bashrc'
    source ~/.bashrc
}


configure_git() {
    mkdir -p ~/.config/git
    config_file=~/.config/git/config
    touch $config_file

    # This takes an associative array and creates
    # a section for a git config file. The name of the array
    # variable becomes the category name, and the key value
    # pairs become the config settings. For example:
    #
    # declare -A category
    # category[foo]=bar
    # add_to_config category
    #
    # this would result in
    #
    # [category]
    #        foo = bar
    add_to_config() {

	# We get the name because associative arrays
	# decay into their name when passed as arguments
	config_category=$1

	# By getting a name reference, we get our associative
	# array back as it used to be
	local -n map=$1

	echo "[${config_category}]" >> $config_file
	EIGHT_SPACES="        "
	for i in "${!map[@]}"
	do
	    key=$i	
	    value="${map[$i]}"
	    echo "${EIGHT_SPACES}${key} = ${value}" >> $config_file
	done
    }

    declare -A user
    user['name']='Cal Crosby'
    user['email']='calcrosbydev@outlook.com'
    add_to_config user

    declare -A core
    core['editor']='nvim'
}

install_font() {
    mkdir ~/.fonts
    font_url="https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-NoLoopK.tar.gz" 
    # Get tar.gz, extract everything verbosely, remove everything besides OFT/ directory
    wget $font_url -O - | tar -xzv | grep -v OTF/ | xargs rm -r 2> /dev/null
    mv OTF/* ~/.fonts
    rm -r OTF/
}

install_vs_code() {
    wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o code.deb
    sudo dpkg -i code.deb
    rm code.deb
    cp /usr/share/applications/code.desktop ~/Desktop
    chmod +x ~/Desktop/code.desktop
    mv /usr/share/pixmaps.{png,svg}
}

main() {

    # Apt dependencies should be installed before everything else runs
    install_apt_dependencies
    install_nvim &
    (install_rust && install_alacritty && configure_alacritty) &
    configure_git &
    install_font &
 
    sudo apt autoremove && sudo apt autoclean
}

main
