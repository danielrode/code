# ELVISH CONFIG
# Dependencies:
#   zoxide
#   starship
#   eza
#   carapace


use str
use builtin


# PROFILE #####################################################################

set E:VISUAL = "hx"
set E:EDITOR = $E:VISUAL
set E:PAGER = "less"
set E:LESS = "--RAW-CONTROL-CHARS --ignore-case --jump-target=.3 --mouse -XF"
set E:LESSEDIT = "%E < %f"
set E:DEFAULT_TERM = "foot"
set E:STARSHIP_LOG = "error"  # Disable Starship warning messages
if (str:contains $E:LS_COLORS ":ow=01;33") {
    set E:LS_COLORS = $E:LS_COLORS":ow=01;33"  # Color 777 orange
}
if (eq $E:HOSTNAME "") {
    set E:HOSTNAME = (hostname)
}

# Daniel's Constant Variables
set E:DCV_CODE_PATH = $E:HOME"/code"
set E:DCV_HOME_OPT  = $E:HOME"/.local/opt"

# XDG
set E:XDG_CONFIG_HOME     = $E:HOME"/.config"
set E:XDG_CACHE_HOME      = $E:HOME"/.cache"
set E:XDG_DATA_HOME       = $E:HOME"/.local/share"
set E:XDG_DESKTOP_DIR     = $E:HOME"/working"
set E:XDG_DOCUMENTS_DIR   = $E:HOME"/progeny"
set E:XDG_DOWNLOAD_DIR    = $E:HOME"/downloads"
set E:XDG_MUSIC_DIR       = $E:HOME"/store/music"
set E:XDG_PICTURES_DIR    = $E:HOME"/record"
set E:XDG_VIDEOS_DIR      = $E:HOME"/record"
set E:XDG_TEMPLATES_DIR   = $E:HOME"/code/tem"
set E:XDG_PUBLICSHARE_DIR = $E:HOME"/union/public"
set E:XDG_SCREENSHOTS_DIR = $E:XDG_PICTURES_DIR"/screencaptures/current"

# Program Config
set E:BAT_PAGER   = $E:PAGER
set E:GOPATH      = $E:HOME"/progeny/go"
set E:R_LIBS_USER = $E:HOME"/.local/lib/R"
set E:ZDOTDIR     = $E:XDG_CONFIG_HOME"/zsh"

# Path
set E:PATH = (put (str:split : $E:PATH) (all [
    /opt/bin
    $E:HOME"/.local/bin"
    $E:DCV_CODE_PATH"/bin"
    $E:DCV_HOME_OPT"/bin"
    $E:HOME"/.cargo/bin"
    $E:GOPATH"/bin"
    $E:HOME"/.juliaup/bin"
    $E:HOME"/union/github/gis-utils"
]) | to-lines | awk '!x[$0]++' | from-lines | str:join :)
# `awk '!x[$0]++'` removes duplicate lines without needing to sort

# Map classic var name variables
var HOME = $E:HOME
var PATH = $E:PATH
var USER = $E:USER
var TERM = $E:TERM


# ALIASES AND FUNCTIONS #######################################################

fn py {|@a| e:python3 $@a}
fn ipy {|@a| e:ipython --no-confirm-exit -i $@a}
fn p {|@a| e:wl-paste $@a}
fn cl {|@a| e:cal -3 $@a}
fn noise {|@a| e:play -r48000 -c2 -n synth -1 pinknoise .1 60 $@a}
fn r {|@a| e:R --no-save $@a}
fn log {|@a| e:svlogtail $@a}
fn lswifi {|@a| e:nmcli device wifi list $@a}
fn lsfonts {|@a| e:fc-list ":" family $@a}
fn progress {|@a|
    var args = [
        --monitor
        --additional-command -lf
        --additional-command nu
        --additional-command pdal
        --additional-command R
        $@a
    ]
    e:progress $@args
}
fn prog {|@a| e:progress $@a}
fn diff {|@a| e:diff --unified --color=auto $@a}
fn df {|@a| e:df --human-readable $@a}
fn lo {|@a| e:libreoffice $@a}
# fn time {|@a| e:time -p $@a}
fn lsblk {|@a|
    var cols = (str:join ',' [
        NAME
        SIZE
        FSSIZE
        FSAVAIL
        FSUSE%
        MOUNTPOINTS
        FSTYPE
        LABEL
        PARTLABEL
        MODEL
        ROTA
        TRAN
    ])
    var args = [
        -o $cols
        $@a
    ]
    e:lsblk $@args
}
fn pg {|@a| e:pgrep -fa $@a}
fn zyp {|@a| e:sudo zypper $@a}
fn rp {|@a| e:realpath $@a}
fn cp {|@a| e:cp --verbose $@a}
fn mv {|@a| e:mv --verbose $@a}
fn rm {|@a| e:rm --verbose $@a}
fn ls {|@a| e:eza --icons=auto $@a}
fn ll {|@a| e:eza --icons=auto --long $@a}
fn lst {|@a| e:eza --icons=auto --long --sort=modified $@a}
fn lss {|@a| e:eza --icons=auto --long --sort=size $@a}
# Plain format ls
fn lsp {|@a| e:eza --classify=never --color=never --icons=never $@a}
fn rg {|@a| e:rg --no-ignore $@a}

fn fwatch {|cmd @paths|
    put $paths | peach {|p|
        inotifywait --monitor --event modify $p | each { date; ($cmd) }
    }
}

fn c {|@a| wl-copy $@a}
fn lspath {|| bash -c "compgen -c"}
fn page {|pid|
    # Get process age
    # Output is [[dd-]hh:]mm:ss, where 'dd' is day(s)
    e:ps -p $pid -o etime
}
fn watch {|@a|
    # Parse arguments
    var cmd = $a[0]
    var wait = $nil
    try {
        set wait = $a[1]
    } catch e {
        if (not-eq (echo $e[reason] | cut -f1 -d:) "<unknown out of range") {
            fail $e
        }
        set wait = 1
    }

    # Format terminal screen and run cmd in loop
    while $true {
        # For list of tput codes, see `man 5 terminfo`
        clear
        tput civis  # Set cursor invisible

        tput home
        date
        echo
        $cmd
        tput ed

        sleep $wait
    }
}
# def protectf [file_list: list<path>] {
#     $file_list | xargs {|chunk| sudo chattr +i ...$chunk}
# }
# def psub [cmd: list, ...sub_cmds: closure] {
#     let tmpdir = (mktemp -d)
#     let index = ($sub_cmds | enumerate | select index)
#     let out_paths = (
#         $index.index | each {|i| [$tmpdir $i] | path join | wrap out_path }
#     )
#     let sub_cmds_table = (
#         $sub_cmds | wrap cmd | merge $index | merge $out_paths
#     )
#     for it in $sub_cmds_table {
#         do $it.cmd | save $it.out_path
#     }
#     run-cmd-array ...$cmd ...$sub_cmds_table.out_path
#     ^rm -fr $tmpdir | ignore
# }

fn rsynca {|@a|
    var args = [
        --archive
        --human-readable
        --compress
        --progress
        --backup
        $@a
    ]
    e:rsync $@args
}
fn xargs {|@a|
    e:xargs -d '\n' $@a
}
fn du {|@a|
    e:du -h $@a
}

fn type {|@a| kind-of $@a}

fn psub {
  var contents = (slurp)
  var tmpdir = (mktemp -d)
  mkfifo $tmpdir/pipe
  echo $contents | bash -c 'function cleanup { rm -fr -- "$0"; }; trap cleanup EXIT; cat /dev/stdin > "$0/pipe"' $tmpdir &
  echo $tmpdir/pipe
}


# CONFIG ######################################################################

# Set CTRL+L to clear terminal screen
use readline-binding

# Set alt-d binding
set edit:insert:binding[Alt-d] = $edit:kill-word-right~

# Disable right-hand prompt
# set edit:rprompt = { echo '' }

# Disable "End of history" message
set edit:insert:binding[Down] = { }

# Emit OSC7 code so terminal knows shell's CWD
set edit:before-readline = [
    $@edit:before-readline { printf "\e]7;file://"$pwd"\a" }
]

# Make TAB file matching case-insensitive and
# match any part of file name (not just the beginning)
# set edit:completion:matcher[argument] = {|seed|
#     edit:match-prefix $seed &ignore-case=$true
# }
set edit:completion:matcher[argument] = {|seed|
    edit:match-substr $seed &ignore-case=$true
}

# Enable `cd -`
var OLDPWD = ~
fn cd {|@d|
    if (eq (count $d) (num 0)) {
        set OLDPWD = $pwd
        builtin:cd ~
    } else {
        set d = $d[0]
        if (eq $d '-') {
            set d = $OLDPWD
        }
        set OLDPWD = $pwd
        builtin:cd $d
    }
}

# Initialize Carapace (command completion)
eval (carapace _carapace | slurp)
# Modify git and wine completions so filenames will be suggested when
# an argument starts with '/' or './' or '../'
# var carapace_default_git_completer = $edit:completion:arg-completer[git]
# set edit:completion:arg-completer[git] = {|@arg|
#     if (or
#         (str:has-prefix $arg[-1] "/")
#         (str:has-prefix $arg[-1] "./")
#         (str:has-prefix $arg[-1] "../")
#     ) {
#         $edit:complete-filename~ $arg[-1]
#     } else {
#         $carapace_default_git_completer $@arg
#     }
# }
# var carapace_default_wine_completer = $edit:completion:arg-completer[wine]
# set edit:completion:arg-completer[wine] = {|@arg|
#     if (or
#         (str:has-prefix $arg[-1] "/")
#         (str:has-prefix $arg[-1] "./")
#         (str:has-prefix $arg[-1] "../")
#     ) {
#         $edit:complete-filename~ $arg[-1]
#     } else {
#         $carapace_default_wine_completer $@arg
#     }
# }

# Initialize Zoxide
eval (zoxide init elvish | slurp)

# Initialize Starship
eval (starship init elvish)
