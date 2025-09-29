#!/usr/bin/env sh
# Author: Daniel Rode
# Created: 19 Jul 2025
# Updated: 29 Sep 2025


# TODO this script is WIP


set -e


# Install packages
if command -v dnf >/dev/null 2>&1
then
    sudo dnf group install sway-desktop-environment -y
    sudo dnf install -y \
        btrfs-progs \
        gocryptfs \
        golang \
        grimshot \
        imv \
        kanshi \
        liberation-fonts-all \
        mako \
        openssh \
        python3-pykeepass \
        syncthing \
        zathura \
    ;
elif command -v xbps-install >/dev/null 2>&1
then
    sudo xbps-install -y \
        chayang \
        swaylock \
    ;
fi

# Prevent user processes from dying on logout
sudo loginctl enable-linger "$USER"

# Enable systemd system services
if command -v systemctl >/dev/null 2>&1
then
    # Make sure SSH server is running
    sudo systemctl enable sshd
    sudo systemctl start sshd
fi

# Configure settings for this git repo
git -C ~/code config core.fileMode true
git -C ~/code config commit.gpgSign true

# Install config files
echo "Linking configs..."
~/code/bin/setup-links
command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload

# Compile binaries
echo "Building binaries..."
go build -o ~/code/bin/o ~/code/src/o/o.go
go build -C ~/code/src/sway-win-info/ -o ~/code/bin/sway-win-info main.go
go build -o ~/code/bin/rotate-ls-output ~/code/src/rotate-ls-output/main.go

# Enable systemd user services
if command -v systemctl >/dev/null 2>&1
then
    # Syncthing
    systemctl --user enable syncthing
    systemctl --user start syncthing

    # Open WebUI
    systemctl --user enable open-webui
    systemctl --user start open-webui

    # Immich
    systemctl --user enable immich
    systemctl --user start immich

    # IRC client
    systemctl --user enable thelounge-irc
    systemctl --user start thelounge-irc
fi

# Set 'focus-follows-mouse' in Gnome Shell
gsettings set org.gnome.desktop.wm.preferences focus-mode sloppy



# If the destination exists, see if it is a link, and if it is, replace it with the new link, but if it is not a link, rename it to its name with .bak affixed and then make the new link. Be verbose and note each action before you take it (like "overwriting link X that points to Y").



# todo firewall
