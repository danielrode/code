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
set -x STARSHIP_LOG error # Disable Starship warning messages
starship init fish | source

# CONFIG ######################################################################

# Disable fish greeting
set fish_greeting ""

# PROFILE #####################################################################

set VISUAL hx
set EDITOR $VISUAL
set PAGER less
set LESS "--RAW-CONTROL-CHARS --ignore-case --jump-target=.3 --mouse -XF"
set LESSEDIT "%E < %f"
set DEFAULT_TERM foot
set LS_COLORS $LS_COLORS":ow=01;33" # Color 777 orange
set HOSTNAME (hostname)

# Daniel's Constant Variables
set DCV_CODE_PATH $HOME"/code"
set DCV_HOME_OPT $HOME"/.local/opt"

# XDG
set XDG_CONFIG_HOME $HOME"/.config"
set XDG_CACHE_HOME $HOME"/.cache"
set XDG_DATA_HOME $HOME"/.local/share"
set XDG_DESKTOP_DIR $HOME"/working"
set XDG_DOCUMENTS_DIR $HOME"/progeny"
set XDG_DOWNLOAD_DIR $HOME"/downloads"
set XDG_MUSIC_DIR $HOME"/store/music"
set XDG_PICTURES_DIR $HOME"/record"
set XDG_VIDEOS_DIR $HOME"/record"
set XDG_TEMPLATES_DIR $HOME"/code/tplt"
set XDG_PUBLICSHARE_DIR $HOME"/union/public"
set XDG_SCREENSHOTS_DIR $XDG_PICTURES_DIR"/screencaptures/current"

# Program Config
set BAT_PAGER $PAGER
set GOPATH $HOME"/progeny/go"
set R_LIBS_USER $HOME"/.local/lib/R"

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

# Mnemonics
abbr --add log svlogtail
abbr --add ttop watch -d -n 1 sensors
abbr --add gtop nvtop

# Make commonly used flags/cmd settings default
abbr --add cl cal -3
abbr --add r R --vanilla
abbr --add progress progress --monitor \
    --additional-command syncthing \
    --additional-command lf \
    --additional-command nu \
    --additional-command pdal \
    --additional-command R
abbr --add diff diff -u --color
abbr --add df df -h
abbr --add du du -h
abbr --add lsblk lsblk -o NAME,SIZE,FSSIZE,FSAVAIL,FSUSE%,MOUNTPOINTS,FSTYPE,\
LABEL,PARTLABEL,MODEL,ROTA,TRAN
abbr --add pg pgrep -fa
abbr --add rg rg --no-ignore
abbr --add zyp sudo zypper
abbr --add rsynca rsync \
    --archive \
    --human-readable \
    --compress \
    --progress \
    --backup
abbr --add xargs xargs -d '\n'

# One-liners
abbr --add lspath bash -c '"compgen -c"'
abbr --add lswifi nmcli device wifi list
abbr --add lsfont fc-list : family
abbr --add fwatch inotifywait --monitor --event modify
abbr --add page ps -p $fish_pid
abbr --add protectf xargs chattr +i

# Launch new session with history
abbr --add hoff fish --private
