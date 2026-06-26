# dependencies:
#   progress
#   starship
#   NerdFonts  # for starship, at least
#   zoxide
#   eza
#   lm_sensors
#   nvtop
#   lf
#   ~/code/bin/ccarousel

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

# Change shell's working dir to last dir in lf on exit
function lf
    # cd (command lf -print-last-dir -command 'map w quit' $argv)
    if test -n "$argv"
        cd $argv || return 1
    end
    if test -e "$CCAROUSEL_SOCK_FP"
        echo -n "$PWD" >"$CCAROUSEL_SOCK_FP"
        exit
    end
    exec ccarousel lf fish
end

# PROFILE #####################################################################

set -gx HOSTNAME (hostname)

# Load and set env vars from profile.env
set -f env_var_fp "$HOME/.config/environment.d/profile.conf"
if test -f "$env_var_fp"
    while read line
        if string match -qr '^#|^$' "$line"
            continue
        end
        set item (string split -m 1 '=' $line)
        set -gx $item[1] $item[2]
    end <"$env_var_fp"
end

# ALIASES & FUNCTIONS #########################################################

# NOTE: Once abbreviations are removed from here,
# rm ~/.config/fish/fish_variables
# and then restart fish shell (to also remove the abbreviations from cache).

# LS macros
abbr --add ls eza
abbr --add ll eza -l
abbr --add lst eza -l --sort=modified
abbr --add lss eza -l --sort=size
abbr --add lsp eza --classify=never --color=never --icons=never # Plain

# Make default commands safer
abbr --add cp cp -v
abbr --add mv mv -v
abbr --add rm rm -v
abbr --add rmdir rmdir -v
# abbr --add cat strings -aw -n 1 -U x

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
abbr --add gemini-browser amfora

# Make commonly used flags/cmd settings default
abbr --add cl cal -n 6
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
abbr --add pkill pkill -e
abbr --add pspg pspg -X -b --csv
abbr --add pstree pstree -aps "$fish_pid"

# One-liners
abbr --add lswifi nmcli device wifi list
abbr --add lsfont fc-list : family
abbr --add fwatch inotifywait --monitor --event modify
abbr --add page ps -p $fish_pid
abbr --add protectf xargs chattr +i
abbr --add hist gnuplot -p -e "set term dumb; set style data histograms; set style fill solid; plot '-' using 1 smooth frequency with boxes notitle"

# Launch new session with history
abbr --add hoff fish --private

abbr --add reboot sudo /usr/bin/reboot
abbr --add poweroff sudo /usr/bin/poweroff

# COMPLETIONS #################################################################

complete -c we -a '(__fish_complete_subcommand)' -d Command
complete -c xa -a '(__fish_complete_subcommand)' -d Command
