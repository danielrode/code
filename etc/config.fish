# Dependencies:
#   progress
#   starship
#   NerdFonts  # for starship, at least
#   zoxide
#   eza
#   lm_sensors
#   nvtop

# USER TIPS:
# You can navigate forward and back throgh 'cd' history via the use of the
# ALT+<LEFT_ARROW> and ALT+<RIGHT_ARROW> keys combinations.

# PLUGINS #####################################################################

# Load zoxide (autojump utility)
zoxide init --cmd d fish | source

# Load starship (prompt setter)
set -gx STARSHIP_LOG error # Disable Starship warning messages
starship init fish | source

# CONFIG ######################################################################

# Disable fish greeting
set fish_greeting ""

# Default file/dir permissions
umask 027

# PROFILE #####################################################################

set -gx VISUAL hx
set -gx EDITOR $VISUAL
set -gx PAGER less
set -gx LESS "--RAW-CONTROL-CHARS --ignore-case --jump-target=.3 --mouse -XF"
set -gx LESSEDIT "%E < %f"
set -gx DEFAULT_TERM foot
set -gx LS_COLORS $LS_COLORS":ow=01;33" # Color 777 orange
set -gx HOSTNAME (hostname)

# Daniel's Constant Variables
set -gx DCV_CODE_PATH $HOME"/code"
set -gx DCV_HOME_OPT $HOME"/.local/opt"

# XDG
set -gx XDG_CONFIG_HOME $HOME"/.config"
set -gx XDG_CACHE_HOME $HOME"/.cache"
set -gx XDG_DATA_HOME $HOME"/.local/share"
set -gx XDG_DESKTOP_DIR $HOME"/working"
set -gx XDG_DOCUMENTS_DIR $HOME"/progeny"
set -gx XDG_DOWNLOAD_DIR $HOME"/downloads"
set -gx XDG_MUSIC_DIR $HOME"/store/music"
set -gx XDG_PICTURES_DIR $HOME"/media"
set -gx XDG_VIDEOS_DIR $HOME"/media"
set -gx XDG_TEMPLATES_DIR $HOME"/code/tem"
set -gx XDG_PUBLICSHARE_DIR $HOME"/union/public"
set -gx XDG_SCREENSHOTS_DIR $XDG_PICTURES_DIR"/screencaptures/current"

# Program Config
set -gx BAT_PAGER $PAGER
set -gx GOPATH $HOME"/.appdata/go"
set -gx R_LIBS_USER $HOME"/.local/lib/R"

# Path
fish_add_path /opt/bin
fish_add_path $HOME"/.local/bin"
fish_add_path $DCV_CODE_PATH"/bin"
fish_add_path $DCV_HOME_OPT"/bin"
fish_add_path $HOME"/.cargo/bin"
fish_add_path $GOPATH"/bin"

# ALIASES #####################################################################

# NOTE: Once abbreviations are removed from here,
# rm ~/.config/fish/fish_variables
# and then restart fish shell (to also remove the abbreviations from cache).

# LS macros
abbr --add ls eza
abbr --add ll eza -l
abbr --add lst eza -l --sort=modified
abbr --add lss eza -l --sort=size
abbr --add lsp eza --classify=never --color=never --icons=never # Plain

# Set file copy, move, and remove operations to report actions taken
abbr --add cp cp -v
abbr --add mv mv -v
abbr --add rm rm -v
abbr --add rmdir rmdir -v

# Abbreviations
abbr --add c wl-copy
abbr --add p wl-paste
abbr --add m micro
abbr --add rp realpath
abbr --add py python3
abbr --add ipy ipython
abbr --add zj zellij

# Mnemonics
abbr --add log svlogtail
abbr --add ttop watch -d -n 1 sensors
abbr --add gtop nvtop

# Make commonly used flags/cmd settings default
abbr --add cl cal -3
abbr --add r R --vanilla
abbr --add progress progress --monitor \
    --additional-command cksum \
    --additional-command syncthing \
    --additional-command lf \
    --additional-command nu \
    --additional-command pdal \
    --additional-command R
abbr --add diff diff -u --color
abbr --add df df -h --output=source,fstype,size,avail,pcent,target -x tmpfs -x devtmpfs -x efivarfs
abbr --add du du -h
abbr --add lsblk lsblk -o NAME,SIZE,FSSIZE,FSAVAIL,FSUSE%,MOUNTPOINTS,FSTYPE,\
LABEL,PARTLABEL,MODEL,ROTA,TRAN
abbr --add pg pgrep -fa
abbr --add rg rg -u
abbr --add zyp sudo zypper
abbr --add rsynca rsync \
    --archive \
    --human-readable \
    --compress \
    --progress \
    --backup
abbr --add xargs xargs -d '\n'
abbr --add pkill pkill -e
abbr --add pspg pspg -X -b
abbr --add pstree pstree -aps

# One-liners
abbr --add lspath bash -c '"compgen -c"'
abbr --add lswifi nmcli device wifi list
abbr --add lsfont fc-list : family
abbr --add fwatch inotifywait --monitor --event modify
abbr --add page ps -p $fish_pid
abbr --add protectf xargs chattr +i
abbr --add hist gnuplot -p -e "set term dumb; set style data histograms; set style fill solid; plot '-' using 1 smooth frequency with boxes notitle"

# Launch new session with history
abbr --add hoff fish --private

abbr --add reboot doas /usr/bin/reboot
