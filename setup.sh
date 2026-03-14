#!/usr/bin/env bash
# author: daniel rode
# created: 19 jul 2025
# updated: 13 mar 2026


# TODO this script is WIP


set -e


# Install packages
pkgs=(
    # List of packages that have the same names across Fedora and Void repos
    aria2
    btrfs-progs
    cargo
    chayang
    dtach
    gocryptfs
    grimshot
    imv
    kanshi
    mako
    meld
    mpv
    opendoas
    openssh
    pavucontrol
    pspg
    python3-pykeepass
    smartmontools
    swaylock
    syncthing
    zathura
)
if command -v dnf >/dev/null 2>&1
then
    sudo dnf group install -y \
        sway-desktop-environment \
    ;
    sudo dnf install -y \
        "${pkgs[@]}" \
        git-delta \
        golang \
        liberation-fonts-all \
    ;
elif command -v xbps-install >/dev/null 2>&1
then
    sudo xbps-install -y \
        "${pkgs[@]}" \
        delta \
        go \
        liberation-fonts-ttf \
    ;
fi

# Prevent user processes from dying on logout
sudo loginctl enable-linger "$USER"

# Enable systemd system services
# TODO install unit files first
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
~/code/bin/install-home-config
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
    # systemctl --user enable open-webui
    # systemctl --user start open-webui

    # Immich
    # systemctl --user enable immich
    # systemctl --user start immich

    # IRC client
    # systemctl --user enable thelounge-irc
    # systemctl --user start thelounge-irc
fi

# Set 'focus-follows-mouse' in Gnome Shell
gsettings set org.gnome.desktop.wm.preferences focus-mode sloppy

# Set wallpaper
# https://github.com/DenverCoder1/minimalistic-wallpaper-collection
wget https://minimalistic-wallpaper.demolab.com/?random -O ~/.wallpaper

# Prevent DNF from checking for packages that provide commands
if command -v dnf >/dev/null 2>&1
then
    sudo dnf remove PackageKit-command-not-found
fi

# Setup disk health monitoring
if command -v systemctl >/dev/null 2>&1
then
    line="DEVICESCAN -H -m $(whoami) -M exec /usr/libexec/smartmontools/smartdnotify -n standby,10,q"
    if ! grep -Fx "$line"
    then
        echo "$line" | sudo tee -a /etc/smartmontools/smartd.conf
    fi
    sudo systemctl enable --now smartd
fi
# TODO verify this works (actually detects drive failuers)
# TODO monitor /var/spool/mail/daniel and notify me via email
# TODO make this work on void too

# Configure Void startup tasks
if [[ -e /etc/rc.local ]]
then
    # Give users access to create and modify new cgroups within their own
    # hierarchy
    sudo tee /usr/local/bin/void-setup-user-cgroups \
<<'EOF'
#!/bin/python3
import os, pwd
from pathlib import Path
# Move all currently running processes out of top (root) cgroup
def clear_cg_procs(cg_path):
    cg_path = Path(cg_path)
    cg_leaf = Path(cg_path / "default")
    cg_leaf.mkdir(exist_ok=True)
    with open(cg_path / "cgroup.procs", 'r') as f:
        pid_list = f.read().strip().splitlines()
    for pid in pid_list:
        try:
            (cg_leaf / "cgroup.procs").write_text(pid)
        except OSError as e:
            if str(e) != "[Errno 22] Invalid argument":
                raise e
clear_cg_procs("/sys/fs/cgroup")
with Path("/sys/fs/cgroup/cgroup.subtree_control").open('w') as f:
    # NOTE: Each of these must exist in /sys/fs/cgroup/cgroup.controllers, or
    # this will fail
    f.write("+memory +pids +cpu +io")
# Create cgroup for each user
for u, g in (
    (i.pw_uid, i.pw_gid)
    for i in pwd.getpwall()
    if int(i.pw_uid) > 999
):
    cg_dir = Path(f"/sys/fs/cgroup/user{u}")
    cg_dir.mkdir(exist_ok=True)
    os.chown(cg_dir, u, g)
    os.chown(cg_dir / "cgroup.procs", u, g)
    os.chown(cg_dir / "cgroup.subtree_control", u, g)
    os.chown(cg_dir / "cgroup.threads", u, g)
    with Path(cg_dir / "cgroup.subtree_control").open('w') as f:
        # NOTE: Each of these must exist in /sys/fs/cgroup/cgroup.controllers,
        # or this will fail
        f.write("+memory +pids +cpu +io")
EOF
    sudo chmod +x /usr/local/bin/void-setup-user-cgroups

    line='/usr/local/bin/void-setup-user-cgroups'
    if ! grep -Fx "$line" /etc/rc.local
    then
        echo | sudo tee -a /etc/rc.local
        echo "$line" | sudo tee -a /etc/rc.local
    fi

    # Make PAM start new user sessions within their respective cgroup
    sudo tee /usr/local/bin/pam-assign-login-cgroup <<'EOF'
#!/bin/sh
# PAM provides $PAM_USER, but we need the UID
uid=$(id -u "$PAM_USER")
if [ "$PAM_TYPE" = "open_session" ]; then
    SESSION_GRP="/sys/fs/cgroup/user$uid/session"
    echo "$PAM_PID" > "$SESSION_GRP/cgroup.procs"
fi
EOF
    sudo chmod +x /usr/local/bin/pam-assign-login-cgroup
fi




# todo firewall
# ufw



# Also see
# - sudo crontab -e
# - crontab -e
# - /etc/fstab
# - ~/.ssh/config
