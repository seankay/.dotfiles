#!/usr/bin/env bash

set -o pipefail

export PATH="$HOME/.local/share/mise/installs:$HOME/.local/share/mise/shims:$HOME/.local/share/mise/bin:$HOME/.fzf/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

require_cmd() {
	local cmd="$1"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		tmux display-message "Missing command: $cmd"
		exit 127
	fi
}

require_cmd sesh
require_cmd fzf
require_cmd awk
require_cmd tmux

tmp=$(mktemp)
cleanup() {
	rm -f "$tmp"
}
trap cleanup EXIT

exec 2>"$tmp"

selection=$(sesh list -i | awk 'tolower($0) !~ /opencode/' | fzf --tmux center,60% --layout=reverse --border=bold \
	--ansi --no-sort --border-label ' sesh ' --prompt '⚡  ' \
	--header '  ^a all ^t tmux ^x zoxide ^g config ^d tmux kill ^f find' \
	--bind 'tab:down,btab:up' \
	--bind "ctrl-a:change-prompt(⚡  )+reload(sesh list -i | awk 'tolower(\$0) !~ /opencode/')" \
	--bind "ctrl-t:change-prompt(🪟  )+reload(sesh list -it | awk 'tolower(\$0) !~ /opencode/')" \
	--bind "ctrl-g:change-prompt(⚙️  )+reload(sesh list -ic | awk 'tolower(\$0) !~ /opencode/')" \
	--bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -iz)' \
	--bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
	--bind "ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list | awk 'tolower(\$0) !~ /opencode/')")

status=$?
if [ $status -ne 0 ]; then
	if [ $status -eq 130 ] || [ $status -eq 1 ]; then
		exit 0
	fi
	if [ -s "$tmp" ]; then
		tmux display-popup -E "cat \"$tmp\""
	else
		tmux display-message "sesh picker failed"
	fi
	exit $status
fi

if [ -z "$selection" ]; then
	exit 0
fi

sesh connect "$selection"
status=$?
if [ $status -ne 0 ] && [ -s "$tmp" ]; then
	tmux display-popup -E "cat \"$tmp\""
elif [ $status -ne 0 ]; then
	tmux display-message "sesh connect failed"
fi

exit $status
