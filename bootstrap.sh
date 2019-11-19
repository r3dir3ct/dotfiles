#! /usr/bin/env bash
DOTFILES_DIR=$HOME/.local/dotfiles
SHARE_SUBDIR=$DOTFILES_DIR/share
MACOS_SUBDIR=$DOTFILES_DIR/macos
LINUX_SUBDIR=$DOTFILES_DIR/linux
OS_TYPE=$(uname)

if [ ! -d $DOTFILES_DIR ]; then
    mkdir -p $HOME/.local
    cd $HOME/.local
    git clone https://github.com/r3dir3ct/dotfiles.git $DOTFILES_DIR
else
    cd $DOTFILES_DIR
    git pull
fi

# rsync MacOS Bootstrap
function MacOSBootstrap(){
    rsync -avh --no-perms $SHARE_SUBDIR $HOME
    rsync -avh --no-perms $MACOS_SUBDIR $HOME
}

# rsync Linux Dryrun
function MacOSDryRun(){
    rsync --dry-run -avh --no-perms $SHARE_SUBDIR $HOME
    rsync --dry-run -avh --no-perms $MACOS_SUBDIR $HOME
}

# rsync Linux Bootstrap
function LinuxBootstrap(){
    rsync -avh --no-perms $SHARE_SUBDIR $HOME
    rsync -avh --no-perms $LINUX_SUBDIR $HOME
}

# rsync Linux Dryrun
function LinuxDryRun(){
    rsync --dry-run -avh --no-perms $SHARE_SUBDIR $HOME
    rsync --dry-run -avh --no-perms $LINUX_SUBDIR $HOME
}

if [ "$OS_TYPE" == "Darwin" ]; then
    echo "Detected OS is MacOS, and these files will be overwrite, please check!"
    MacOSDryRun
    read -p "Are you sure to overwrite? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        MacOSBootstrap
    fi
elif [ "$OS_TYPE" == "Linux" ]; then
    echo "Detected OS is Linux, and these files will be overwrite, please check!"
    LinuxDryRun
    read -p "Are you sure to overwrite? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        LinuxBootstrap
    fi
else
    echo "Unknown OS, please check!"
fi

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
    echo "source ${DOTFILES_DIR}/zsh_init.sh" > $HOME/.zshrc
fi


