#! /usr/bin/env bash
DOTFILES_DIR=$HOME/.local/dotfiles/

if [ ! -d $DOTFILES_DIR ]; then
    mkdir -p $HOME/.local
    cd $HOME/.local
    git clone https://github.com/r3dir3ct/dotfiles.git $DOTFILES_DIR
else
    cd $DOTFILES_DIR
    git pull
fi

# rsync files
function doIt(){
    rsync --exclude ".git/" \
          --exclude ".DS_Store" \
          --exclude ".osx" \
          --exclude "bootstrap.sh" \
          --exclude "zsh_init.sh" \
          --exclude "README.md" \
          --exclude "LICENSE" \
          -avh --no-perms $DOTFILES_DIR $HOME;
}
# rsync dryrun
function dryRun(){
    rsync --dry-run \
          --exclude ".git/" \
          --exclude ".DS_Store" \
          --exclude ".osx" \
          --exclude "bootstrap.sh" \
          --exclude "zsh_init.sh" \
          --exclude "README.md" \
          --exclude "LICENSE" \
          -avh --no-perms $DOTFILES_DIR $HOME;
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
    echo "These files will be overwrite, please check!"
    dryRun;
    read -p "Are you sure to overwrite? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;

# install tpm and plugins
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi
# install oh-my-zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh $HOME/.oh-my-zsh
    TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
    if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
        # If this platform provides a "chsh" command (not Cygwin), do it, man!
        if hash chsh >/dev/null 2>&1; then
            printf "Time to change your default shell to zsh!\n"
            chsh -s $(grep /zsh$ /etc/shells | tail -1)
        # Else, suggest the user do so manually.
        else
            printf "I can't change your shell automatically because this system does not have chsh.\n"
            printf "Please manually change your default shell to zsh!\n"
        fi
    fi
fi

# init zsh
if [ ! -f $HOME/.zshrc ]; then
    echo "source ${DOTFILES_DIR}zsh_init.sh" > $HOME/.zshrc
fi


