#!/usr/bin/env bash
# author: daniel rode
# created: 19 jul 2025
# updated: 12 mar 2026


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
    # Get rid of Podman warning about root filesystem not being shared
    line='mount --make-rslave /'
    if ! grep -Fx "$line" /etc/rc.local
    then
        echo | sudo tee -a /etc/rc.local
        echo "$line" | sudo tee -a /etc/rc.local
    fi

    # Give user access to create and modify new cgroups
    sudo tee /usr/local/bin/void-setup-user-cgroups \
<<'EOF'
#!/bin/python3
import os, pwd
from pathlib import Path
# Move all currently running processes out of top (root) cgroup
Path("/sys/fs/cgroup/default").mkdir(exist_ok=True)
with open("/sys/fs/cgroup/cgroup.procs", 'r') as f:
  pid_list = f.read()
for pid in pid_list.splitlines():
  try:
    with open("/sys/fs/cgroup/default/cgroup.procs", 'w') as f2:
      f2.write(pid)
  except OSError as e:
    if str(e) != "[Errno 22] Invalid argument":
      raise e
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
EOF
    sudo chmod +x /usr/local/bin/void-setup-user-cgroups

    line='/usr/local/bin/void-setup-user-cgroups'
    if ! grep -Fx "$line" /etc/rc.local
    then
        echo | sudo tee -a /etc/rc.local
        echo "$line" | sudo tee -a /etc/rc.local
    fi

    # Create service that assigns user to its own cgroup upon login
    uid="$(id -u)"
    sudo mkdir -p /etc/sv/cgroup"$uid"
    sudo tee /etc/sv/cgroup"$uid"/run \
<<EOF
#!/bin/sh
/usr/bin/pgrep -fx -U "$uid" 'dash $HOME/code/bin/launch-swaywm' \
> /sys/fs/cgroup/user"$uid"/cgroup.procs \
&& exec /usr/bin/pause
EOF
    sudo chmod +x /etc/sv/cgroup"$uid"/run
    sudo ln -sf /etc/sv/cgroup"$uid" /var/service/
fi




# todo firewall
# ufw



# Also see
# - sudo crontab -e
# - crontab -e
# - /etc/fstab
# - ~/.ssh/config
