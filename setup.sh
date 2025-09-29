#!/usr/bin/env sh
# Author: Daniel Rode
# Created: 19 Jul 2025


# TODO this script is WIP


set -e


# Install packages
if command -v dnf >/dev/null 2>&1
then
    sudo dnf group install sway-desktop-environment -y
    sudo dnf install -y \
        gocryptfs \
        golang \
        grimshot \
        imv \
        kanshi \
        liberation-fonts-all \
        mako \
        python3-pykeepass \
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

# Configure settings for this git repo
git -C ~/code config core.fileMode true
git -C ~/code config commit.gpgSign true

# Install config files
echo "Linking configs..."
~/code/bin/setup-links

# Compile binaries
echo "Building binaries..."
go build -o ~/code/bin/o ~/code/src/o/o.go
go build -C ~/code/src/sway-win-info/ -o ~/code/bin/sway-win-info main.go
go build -o ~/code/bin/rotate-ls-output ~/code/src/rotate-ls-output/main.go

# Set 'focus-follows-mouse' in Gnome Shell
gsettings set org.gnome.desktop.wm.preferences focus-mode sloppy

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








# If the destination exists, see if it is a link, and if it is, replace it with the new link, but if it is not a link, rename it to its name with .bak affixed and then make the new link. Be verbose and note each action before you take it (like "overwriting link X that points to Y").



# todo firewall
