#!/usr/bin/env bash
# author: daniel rode
# created: 19 jul 2025
# updated: 31 mar 2026


# Setup and configure Linux system to be how I like it.
#
# DOC: Also see (for system setup/config)
# - ~/.ssh/config
# - ~/.crypt/private_code_vars.toml
# - crontab -e
# - sudo crontab -e
# - /etc/fstab
# - /etc/rc.local  # for Void installs

# TODO (this script is WIP)


set -e


HOSTNAME="$(hostname)"


# Install packages
pkgs=(
    # List of packages that have the same names across Fedora and Void repos
    aria2
    btrfs-progs
    cargo
    chayang
    dtach
    fuzzel
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
    restic
    ripgrep
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
        fd-find \
        git-delta \
        golang \
        liberation-fonts-all \
    ;
elif command -v xbps-install >/dev/null 2>&1
then
    sudo xbps-install -y \
        "${pkgs[@]}" \
        delta \
        fd \
        go \
        lf \
        liberation-fonts-ttf \
        socklog-void \
        turnstile \
    ;
fi

# Install foot, if not already installed TODO
# ~/code/bin/install-foot

# Install ghostty, if not already installed TODO
# ~/code/bin/install-ghostty

# Install lf, if not already installed TODO
# ~/code/bin/install-lf

# Add home log directory
if [[ $HOSTNAME == bigpan ]]
then
    mkdir -p ~/logs
fi

# Install user config files
echo "Linking configs..."
~/code/bin/install-home-config
command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload

# Configure settings for this git repo
git -C ~/code config core.fileMode true
git -C ~/code config commit.gpgSign true

# Install system config files and assets
echo "Installing system files..."
~/code/bin/install-system
command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload

# Prevent user processes from dying on logout
sudo loginctl enable-linger "$USER"

# Enable systemd system services
if command -v systemctl >/dev/null 2>&1
then
    # Make sure SSH server is running
    sudo systemctl enable sshd
    sudo systemctl start sshd
fi

# Enable systemd user services
if command -v systemctl >/dev/null 2>&1
then
    if [[ $HOSTNAME == mesa ]]
    then
        # Globus
        # https://docs.globus.org/globus-connect-personal/install/linux/
        # Defining share paths:
        # https://docs.globus.org/globus-connect-personal/install/linux/#config-paths
        # Share paths config file: ~/.globusonline/lta/config-paths
        systemctl --user enable --now globus.service 
    else
        # Syncthing
        systemctl --user enable syncthing
        systemctl --user start syncthing
    fi

    if [[ $HOSTNAME == bigpan ]]
    then
        # Immich
        systemctl --user enable immich
        systemctl --user start immich

        # IRC client
        systemctl --user enable thelounge-irc
        systemctl --user start thelounge-irc
    fi
fi

# Compile binaries
echo "Building binaries..."
go build -o ~/code/bin/o ~/code/src/o/o.go
go build -C ~/code/src/sway-win-info/ -o ~/code/bin/sway-win-info main.go
go build -o ~/code/bin/rotate-ls-output ~/code/src/rotate-ls-output/main.go

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
    if ! grep -qFx "$line"
    then
        echo "$line" | sudo tee -a /etc/smartmontools/smartd.conf
    fi
    sudo systemctl enable --now smartd
fi
# TODO verify this works (actually detects drive failuers)
# TODO monitor /var/spool/mail/daniel and notify me via email
# TODO make this work on void too

# Enable Void system services
if [[ -d /var/service/ ]]
then
    sudo ln -sf /etc/sv/socklog-unix /var/service/
    sudo ln -sf /etc/sv/nanoklogd /var/service/
    sudo ln -sf /etc/sv/turnstiled /var/service/
fi

# Configure Void system
if [[ -e /etc/rc.local ]]
then
    # Set timezone
    sudo ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
fi

# Configure Void startup
if [[ -e /etc/rc.local ]]
then
    # Configure turnstile service
    if grep -qFx 'manage_rundir = yes' /etc/turnstile/turnstiled.conf
    then
        sudo patch -uNs /etc/turnstile/turnstiled.conf \
<<EOF
@@ -78,7 +78,7 @@
 #
 # Valid values are 'yes' and 'no'.
 #
-manage_rundir = yes
+manage_rundir = no
 
 # Whether to export DBUS_SESSION_BUS_ADDRESS into the
 # environment. When enabled, this will be exported and
EOF
    fi

    # Configure elogind
    sudo mkdir -p /etc/elogind/logind.conf.d/
    sudo tee /etc/elogind/logind.conf.d/10-user-live.conf \
<<EOF
KillUserProcesses=no
EOF

    # Configure GRUB
    if ! grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub \
        | grep -q \
        'systemd.unified_cgroup_hierarchy=1 elogind.unified_cgroup_hierarchy'
    then
        echo "'systemd.unified_cgroup_hierarchy=1' and"
        echo "'elogind.unified_cgroup_hierarchy' arguments have not been added"
        echo "to GRUB's GRUB_CMDLINE_LINUX_DEFAULT variable under"
        echo "/etc/default/grub"
        echo 'Please do this, then run `sudo update-grub`, then run this'
        echo 'setup script again.'
        exit 1
    fi

    # Give users access to create and modify new cgroups within their own
    # hierarchy
    uid=1000  # TODO make this user agnostic (not hardcoded to 'daniel')
    sudo mkdir -p /etc/sv/cgroup"$uid"/log
    sudo tee /etc/sv/cgroup"$uid"/run \
<<'EOF'
#!/bin/python3
import os, sys, pwd, signal
import subprocess as sp
from pathlib import Path
sys.stderr = sys.stdout  # Redirect stderr to stdout
target_uid = 1000  # TODO make this user agnostic (not hardcoded to 'daniel')
assert pwd.getpwuid(target_uid).pw_name == 'daniel'
def clear_cg_procs(cg_path):
    # Move all currently running processes out of root of cgroup
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
def chown_cg(cg_dir, uid, gid):
    # Give ownership of given cgroup to given uid:gid
    cg_dir = Path(cg_dir)
    os.chown(cg_dir, uid, gid)
    os.chown(cg_dir / "cgroup.procs", uid, gid)
    os.chown(cg_dir / "cgroup.threads", uid, gid)
    os.chown(cg_dir / "cgroup.subtree_control", uid, gid)
def get_pid_ruid_euid(pid):
    # Return the real UID and the effective UID for the given PID.
    for i in Path("/proc/", str(pid), "status").read_text().splitlines():
        if i.startswith("Uid:\t"):
            _, ruid, euid, _, _ = i.split('\t')
            return (ruid, euid)
# Setup cgroups hierarchy
clear_cg_procs("/sys/fs/cgroup")
clear_cg_procs("/sys/fs/cgroup/1")
Path(f"/sys/fs/cgroup/1/user{target_uid}").mkdir(exist_ok=True)
chown_cg(f"/sys/fs/cgroup/1/user{target_uid}", target_uid, target_uid)
Path(f"/sys/fs/cgroup/1/user{target_uid}/swaywm").mkdir(exist_ok=True)
for p in (
    "/sys/fs/cgroup/cgroup.subtree_control",
    "/sys/fs/cgroup/1/cgroup.subtree_control",
    f"/sys/fs/cgroup/1/user{target_uid}/cgroup.subtree_control",
):
    with open(p, 'w') as f:
        # NOTE: Each of these must exist in /sys/fs/cgroup/cgroup.controllers,
        # or this will fail
        f.write("+memory +pids +cpu +io")
# Watch for Sway init script, then move it to user controlled cgroup
# TODO check if sway has already been placed in its own cgroup (so the service does not error if it gets restarted later)
cmd = (
    'pgrep',
    '-fx',
    '-U', str(target_uid),
    'dash /home/daniel/code/bin/launch-swaywm',
)
while True:
    p = sp.run(cmd, text=True, capture_output=True)
    if (p.returncode == 0) and (p.stdout.strip() != ''):
        result = p.stdout.strip().splitlines()
        assert len(result) == 1
        sway_init_pid = int(result[0])
        break
    os.sleep(0.01)
Path(f"/sys/fs/cgroup/1/user{target_uid}/swaywm/cgroup.procs").write_text(
    str(sway_init_pid)
)
# Service's job is done, so pause (so runit sees this service as "alive")
signal.pause()
EOF
    sudo tee /etc/sv/cgroup"$uid"/log/run \
<<EOF
#!/bin/sh
exec vlogger -t cgroup$uid -p daemon
EOF
    sudo chmod +x /etc/sv/cgroup"$uid"/run
    sudo chmod +x /etc/sv/cgroup"$uid"/log/run
    sudo ln -sf /etc/sv/cgroup"$uid" /var/service/
fi



# todo firewall (ufw)



# TODO
# Create a script called change-scenery then take the wallpaper updating code
# above and put it in there. Add code that changes the color palette of
# fuzzel and waybar to match the color palette of the newly set wallpaper. Call
# change`scenery script from (setup.sh).
