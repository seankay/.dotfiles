#!/usr/bin/env bash

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
SESSION_PATH="$XDG_DATA_HOME/kitty-sessions/"

show_help(){
        printf "%s\n" \
            "Usage: sesh [OPTIONS]" \
            "Options:" \
            "  -n, --create-named-session   Create Session in XDG_DATA_HOME instead of tmp" \
            "                               Enter a name and a path, if path is left empty" \
            "                               The picker opens for you to choose a path" \
            "  -d, --debug                  Enable debug logging" \
            " " \
            "For more information about kitty session visit: https://sw.kovidgoyal.net/kitty/sessions/"
}
log(){
    [[ -n "$debug" ]] && echo "$*"
}
close_launcher_window(){
    if [[ -n "$launcher_window_id" ]]; then
        kitty @ close-window --match "id:$launcher_window_id"
    fi
}

editing=""
debug=""
launcher_window_id="${KITTY_WINDOW_ID:-}"

trap close_launcher_window EXIT

## Entry point ##
while [[ "$#" -gt 0 ]]; do
    case "$1" in
    -e | --edit)
        editing="yes"
        shift
        ;;
    -d | --debug)
        debug="yes"
        shift
        ;;
    *)
        show_help
        exit 1
        ;;
    esac
done

find_dirs() {
  zoxide query -l
}

create_session_file(){
    log "Creating session file: $SESSION_PATH/$session.kitty-session"
    cat "$CONFIG_DIR"/default.kitty-session > "$SESSION_PATH/$session.kitty-session"
    sed -i s#@@session-path@@#"$session_path"# "$SESSION_PATH/$session.kitty-session" 
    sed -i s#@@session@@#"$session"# "$SESSION_PATH/$session.kitty-session" 
}

session_path=$(find_dirs | fzf --ansi --reverse --no-sort --prompt "⚡ session > " || exit 2)

[[ -z "$session_path" ]] && {
    printf "No session selected" >&3
    show_help
    exit 1
} 

session=${session_path##*/}

log "Variables set: session=$session path=$session_path"

mkdir -p "$SESSION_PATH"

if [[ ! -f "$SESSION_PATH/$session.kitty-session" ]]; then
    create_session_file
fi

log "Opening:$SESSION_PATH/$session.kitty-session editing=$editing"
[[ -n "$editing" ]] && {
    $EDITOR "$SESSION_PATH/$session.kitty-session"
    exit 0
}
kitten @ action goto_session "$SESSION_PATH/$session.kitty-session"
