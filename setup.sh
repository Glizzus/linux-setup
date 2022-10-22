
# UTILTIES -------------------------------------------------------------------

install_deb() {
    url=$1
    deb_name=$2
    # We name the file the url to give it a unique name
    wget "${url}" -O $deb_name
    sudo dpkg -i $deb_name
    rm $deb_name
}

uncomment_bash_line() {
    line=$1
    file=$2
    # Substitute beginning of matched line with nothing if line starts with hashtag
    sed "/${line}/s/^#//" -i $file
}

echo_lines_to_file() {
    local -n array=$1
    file=$2
    for line in "${array[@]}"
    do
        echo "$line" >> "$file"
    done
}

# ----------------------------------------------------------------------------

install_apt_dependencies() {
    sudo apt update
    FUN_STUFF="neofetch sl lolcat"
    ALACRITTY_DEPS="cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev"
    DOCKER_REQS="ca-certificates gnupg lsb-release"
    APPS="
        git
	curl	
	python3
	parallel
	g++
	${DOCKER_REQS}
	${FUN_STUFF}
	${ALACRITTY_DEPS}
    "
    sudo apt install -y $APPS
}

install_docker() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_nvim() {
    install_deb https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb nvim.deb
}

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"

    rustup override set stable
    rustup update stable
}

install_alacritty() {
    git clone https://github.com/alacritty/alacritty.git ~/.alacritty

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

	install_bash_completions() {
	    mkdir ~/.bash_completion
	    cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
	    echo "source ~/.bash_completion/alacritty" >> ~/.bashrc
	}

	# Get Terminfo
	sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
	create_desktop_entry
	install_man_page
	install_bash_completions
    }
    (cd ~/.alacritty && do_alacritty_work)
    sudo rm -r ~/.alacritty
}

configure_alacritty() {
    mkdir ~/.config/alacritty
    mkdir ~/.config/alacritty/themes
    touch ~/.config/alacritty/alacritty.yml
    wget https://raw.githubusercontent.com/eendroroy/alacritty-theme/master/themes/horizon-dark.yaml -P ~/.config/alacritty/themes

    lines=(
        'import: '
	'  - ~/.config/alacritty/themes/horizon-dark.yaml'
	''
	'window: '
	'  opacity: 0.9'
    )
    echo_lines_to_file lines ~/.config/alacritty/alacritty.yml

    uncomment_bash_line 'force_color_prompt=yes' ~/.bashrc
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

	# We get the name because associative arrays decay into their name when passed as arguments
	config_category=$1

	# By getting a name reference, we get our associative array back as it used to be
	local -n map=$1

	echo "[${config_category}]" >> $config_file
	EIGHT_SPACES="        "
	for key in "${!map[@]}"
	do
	    value="${map[$key]}"
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
    install_deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" code.deb
    cp /usr/share/applications/code.desktop ~/Desktop
    sudo mv /usr/share/pixmaps/{'com.visualstudio.code.png',code.svg}
    desktop-file-edit ~/Desktop/code.desktop --set-icon="code"
    chmod +x ~/Desktop/code.desktop

    extensions=(
	'aaron-bond.better-comments'
	'robbowen.synthwave-vscode'
	'ms-vscode-remote.vscode-remote-extensionpack'
    )
    for ext in ${extensions[@]}
    do
	code --install-extension $ext
    done
}

get_ascii_to_image() {
    url="https://github.com/TheZoraiz/ascii-image-converter/releases/download/v1.12.0/ascii-image-converter_Linux_amd64_64bit.tar.gz"
    wget $url -O - | tar -xz
    directory="ascii-image-converter_Linux_amd64_64bit"
    (cd $directory && sudo mv ascii-image-converter /usr/bin)
    rm -r $directory
}

get_background_images() {
    declare -A images
    images["sopranos.jpg"]="https://images8.alphacoders.com/676/676146.jpg"
    images["stardew.jpg"]="https://i.pinimg.com/originals/b2/29/1c/b2291c7633bcfe69cb7b3b7ba0d814ab.jpg"
    images["babydriver.jpg"]="https://images.alphacoders.com/847/847742.jpg"
    images["undertaker.jpg"]="https://images4.alphacoders.com/103/1039937.jpg"
    images["better_call_saul.jpg"]="https://images2.alphacoders.com/685/685629.jpg"

    image_names=""
    image_urls=""
    
    for image in "${!images[@]}"
    do
	image_names+="${image} "
	image_urls+="${images[$image]} "
    done
    mkdir ~/Pictures/Background
    (cd ~/Pictures/Background && parallel --link wget -O ::: $image_names ::: $image_urls)
}

set_xprofile() {
    lines=(
        '# Sets the background to a random picture in Background directory on launch'
	'random_background=$(ls ~/Pictures/Background | shuf -n 1)'
	'xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s ~/Pictures/Background/$random_background'
    ) 
    echo_lines_to_file lines ~/.xprofile
}

set_terminal_image_greeting() {
    lines=(
        ''
        'random_picture=$(ls ~/Pictures/Background | shuf -n 1)'
	'ascii-image-converter -bC ~/Pictures/Background/$random_picture'
	''
    )
    echo_lines_to_file lines ~/.bashrc
}

configure_firefox() {
    cp /var/lib/snapd/desktop/applications/firefox_firefox.desktop ~/Desktop
}

set_bash_aliases() {
    declare -A aliases
    aliases["vim"]='"nvim"'

    for ali in "${!aliases[@]}"
    do
	echo "alias $ali=${aliases[$ali]}" >> ~/.bash_aliases
    done
}


main() {

    install_apt_dependencies

    (install_docker && install_nvim && install_vs_code) &
    (install_rust && install_alacritty && configure_alacritty) &
    configure_git &
    install_font &
    get_ascii_to_image &
    (get_background_images && set_xprofile && set_terminal_image_greeting) &
    set_bash_aliases &

    sudo apt autoremove && sudo apt autoclean
}

main
