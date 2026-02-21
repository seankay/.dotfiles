# --- Session defaults --------------------------------------------------------
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export EDITOR="nvim"
export PAGER="${PAGER:-less}"
export GIT_PAGER="${GIT_PAGER:-less}"
export KEYTIMEOUT=50
export WORDCHARS="*?[]~&;!$%^<>"
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/ripgrep.conf"

DOTFILES_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
DOTFILES_LOCAL_ENV="${DOTFILES_CONFIG_HOME}/local.env"
if [[ -r "${DOTFILES_LOCAL_ENV}" ]]; then
  source "${DOTFILES_LOCAL_ENV}"
fi
export MACHINE_ROLE="${MACHINE_ROLE:-work}"

# PATH enrichment
typeset -U path
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.local/share/bob/nvim-bin"
  $path
)

case "$(uname -s)" in
  Darwin)
    if [[ -r "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -r "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
esac

export PATH

# --- Core tooling ------------------------------------------------------------
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# fzf
MISE_FZF_INSTALL_DIR="$(mise where fzf)/install"
export FZF_BASE=$MISE_FZF_INSTALL_DIR

if command -v fzf >/dev/null 2>&1 && [[ -f "${HOME}/.fzf.zsh" ]]; then
  source "${HOME}/.fzf.zsh"
fi

if command -v fzf >/dev/null 2>&1; then
  fzf_preview_bindings="--bind ctrl-f:preview-page-down,ctrl-b:preview-page-up"
  if [[ "${FZF_DEFAULT_OPTS}" != *"ctrl-f:preview-page-down"* ]]; then
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+${FZF_DEFAULT_OPTS} }${fzf_preview_bindings}"
  fi
fi

export ZSH="${HOME}/.oh-my-zsh"

# zsh-autosuggestions
autosuggestionsDir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$autosuggestionsDir" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestionsDir"
fi

# zsh-syntax-highlighting
syntaxHighlightingDir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [[ ! -d "$syntaxHighlightingDir" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntaxHighlightingDir"
fi


ZSH_THEME=""
# alias-finder
zstyle ':omz:plugins:alias-finder' autoload yes

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#606079'
ZSH_HIGHLIGHT_STYLES[command]='fg=#cdcdcd'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#cdcdcd'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#cdcdcd'
ZSH_HIGHLIGHT_STYLES[function]='fg=#cdcdcd'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#aeaed1,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#aeaed1'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#606079'
ZSH_HIGHLIGHT_STYLES[path]='fg=#7fa563'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#7fa563'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f3be7c'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#c48282'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#c48282'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#c48282'
ZSH_HIGHLIGHT_STYLES[argument]='fg=#aeaed1'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#d8647e,bold'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#d8647e,bold'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#aeaed1'
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#f3be7c'
ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#f3be7c'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#f3be7c'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#f3be7c'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#7fa563'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#7fa563'

# use cd to zoxide
ZOXIDE_CMD_OVERRIDE="cd"

plugins=(
  alias-finder
  aws
  direnv
  docker
  docker-compose
  encode64
  extract
  httpie
  jsontools
  fzf
  gh
  git
  git-extras
  mise
  zsh-autosuggestions
  zsh-syntax-highlighting
  zoxide
)

# --- Key bindings ------------------------------------------------------------
zmodload zsh/terminfo 2>/dev/null || true

if [[ -n ${terminfo[kcuu1]} ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search
elif [[ -n ${key[Up]} ]]; then
  bindkey "${key[Up]}" up-line-or-search
else
  bindkey '^[[A' up-line-or-search
fi

if [[ -n ${terminfo[kcud1]} ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-search
elif [[ -n ${key[Down]} ]]; then
  bindkey "${key[Down]}" down-line-or-search
else
  bindkey '^[[B' down-line-or-search
fi

bindkey '^X^E' edit-command-line
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[D' backward-char
bindkey '^[[C' forward-char

# --- Functions ---------------------------------------------------------------
e() {
  "${EDITOR}" "${1:-.}"
}

fh() {
  command -v fzf >/dev/null 2>&1 || return 0
  local selected
  selected=$( ( [ -n "$ZSH_NAME" ] && fc -l 1 || history ) | fzf +s --tac | sed 's/ *[0-9]* *//')
  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
  fi
}
zle -N fh

docker_purge() {
  removecontainers
  docker network prune -f
  local dangling_images dangling_volumes all_images
  dangling_images=$(docker images --filter dangling=true -qa)
  if [[ -n "$dangling_images" ]]; then
    printf '%s\n' "$dangling_images" | xargs docker rmi -f
  fi
  dangling_volumes=$(docker volume ls --filter dangling=true -q)
  if [[ -n "$dangling_volumes" ]]; then
    printf '%s\n' "$dangling_volumes" | xargs docker volume rm
  fi
  all_images=$(docker images -qa)
  if [[ -n "$all_images" ]]; then
    printf '%s\n' "$all_images" | xargs docker rmi -f
  fi
}

removecontainers() {
  local containers
  containers=$(docker ps -aq)
  if [[ -n "$containers" ]]; then
    printf '%s\n' "$containers" | xargs docker stop
    printf '%s\n' "$containers" | xargs docker rm
  fi
}

replace() {
  if [[ $# -ne 3 ]]; then
    echo "Usage: replace <pattern> <from> <to>" >&2
    return 1
  fi
  local sed_in_place=(-i "")
  if [[ "$(uname)" == "Linux" ]]; then
    sed_in_place=(-i)
  fi
  find . -name "$1" -print0 | xargs -0 sed "${sed_in_place[@]}" "s/${2}/${3}/g"
}

gpush() {
  local ref ret current_branch
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  current_branch="${ref#refs/heads/}"
  git push origin "$current_branch" "$@"
}

eval "$(mise activate zsh)"

# ensure mise installed tools remain under this line
if command -v oh-my-posh >/dev/null 2>&1; then
  theme_path="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-posh/themes/vague.json"
  if [[ -r "${theme_path}" ]]; then
    cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/oh-my-posh"
    mkdir -p "${cache_dir}"
    eval "$(oh-my-posh init zsh --config "${theme_path}")"
  fi
fi


if [[ -z "$KITTY_INSTALLATION_DIR" ]]; then
  echo "$KITTY_INSTALLATION_DIR MISSING. Set in ~/.config/dotfiles/local.env"
fi

if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="enabled no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

source "${ZSH}/oh-my-zsh.sh"

bindkey '^P' fh

# fzf-git.sh
fzf_git_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-git.sh"
if [[ ! -d "$fzf_git_dir" ]]; then
  git clone https://github.com/junegunn/fzf-git.sh.git "$fzf_git_dir"
fi
if [[ -f "$fzf_git_dir/fzf-git.sh" ]]; then
  source "$fzf_git_dir/fzf-git.sh"
fi

bindkey '^ ' autosuggest-accept
bindkey -M emacs '^D' delete-char
bindkey -M viins '^D' delete-char
bindkey -M vicmd '^D' delete-char
setopt ignoreeof

# --- Aliases -----------------------------------------------------------------
alias c='cd ~/c'
alias cat='bat'
alias d='cd ~/.dotfiles'
alias f='fd'
alias find='f'
alias g='git status'
alias ga='git add --all'
alias gc='git commit -v'
alias gca='git commit -a -v'
alias gd='git diff'
alias gdd='git difftool -d'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gm='git merge --no-ff'
alias gpull='git pull --rebase'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias griup='git rebase -i @{u}'
alias k='kubectl'
alias l='ls'
alias ls='eza -la --icons --smart-group'
alias tf='terraform'
alias tg='terragrunt'
alias top='btop'
alias s="kitty +kitten ssh"
alias icat="kitten icat"
alias rm='tp'

case "$(uname -s)" in
  Darwin)
    alias tl='trash --list | sort -k4'
    alias tp='trash'
    ;;
  Linux)
    alias tl='trash-list | sort -k4'
    alias tp='trash-put'
    ;;
  *)
    alias tl='trash-list | sort -k4'
    alias tp='trash-put'
    ;;
esac

eval "$(op completion zsh)"; compdef _op op

 # Generated by sdxcli
 if command -v sdxcli &>/dev/null; then
     eval "$(sdxcli output-shell-commands)"
 fi
