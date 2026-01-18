# --- Session defaults --------------------------------------------------------
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export EDITOR="nvim"
export PAGER="${PAGER:-less}"
export GIT_PAGER="${GIT_PAGER:-less}"
export KEYTIMEOUT=20
export WORDCHARS="*?[]~&;!$%^<>"
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

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

if command -v fzf >/dev/null 2>&1 && [[ -f "${HOME}/.fzf.zsh" ]]; then
  source "${HOME}/.fzf.zsh"
fi

if command -v oh-my-posh >/dev/null 2>&1; then
  theme_path="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-posh/themes/oldworld.json"
  if [[ -r "${theme_path}" ]]; then
    cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/oh-my-posh"
    mkdir -p "${cache_dir}"
    eval "$(oh-my-posh init zsh --config "${theme_path}")"
  fi
fi

# oh-my-zsh (optional)
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  export ZSH="${HOME}/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(
    aws
    direnv
    docker
    gh
    git
    git-auto-fetch
  )
  source "${ZSH}/oh-my-zsh.sh"
fi

# --- Key bindings ------------------------------------------------------------
autoload -U edit-command-line
zle -N edit-command-line

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
  selected=$(( [ -n "$ZSH_NAME" ] && fc -l 1 || history ) | fzf +s --tac | sed 's/ *[0-9]* *//')
  [[ -n "$selected" ]] && print -z -- "$selected"
}
zle -N fh
bindkey '^P' fh

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

git_current_branch() {
  local ref ret
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

gpush() {
  git push origin "$(git_current_branch)" "$@"
}

gprune() {
  if ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "gprune: not inside a git repository" >&2
    return 1
  fi

  local main_branch main_ref current_branch target_rev
  local log_prefix="[gprune]"
  local debug=${GPRUNE_DEBUG:-1}
  local log
  log() {
    [[ $debug -eq 0 ]] && return
    echo "${log_prefix} $*"
  }

  main_branch=$(command git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  main_branch=${main_branch#origin/}
  log "origin/HEAD -> ${main_branch:-<unset>}"

  if [[ -z $main_branch ]]; then
    if command git show-ref --verify --quiet refs/heads/main; then main_branch=main; fi
    if [[ -z $main_branch ]] && command git show-ref --verify --quiet refs/heads/master; then main_branch=master; fi
  fi

  if [[ -z $main_branch ]]; then
    echo "gprune: unable to determine main branch" >&2
    return 1
  fi
  main_ref="origin/${main_branch}"
  current_branch=$(git_current_branch)
  log "main branch: $main_branch"
  log "current branch: $current_branch"
  log "main ref: $main_ref"

  log "fetching origin with prune (tags included)"
  command git fetch --prune --tags origin >/dev/null 2>&1 || log "fetch failed (continuing with local refs)"

  target_rev=$(command git rev-parse --verify "$main_ref" 2>/dev/null || command git rev-parse --verify "$main_branch" 2>/dev/null)
  log "resolved target rev: ${target_rev:-<unset>}"
  if [[ -z $target_rev ]]; then
    echo "gprune: unable to resolve ${main_ref} or ${main_branch}" >&2
    return 1
  fi

  log "scanning local branches for merge ancestor of ${target_rev}"
  command git for-each-ref --format='%(refname:short) %(upstream:short)' "refs/heads" \
    | while read -r branch upstream; do
        [[ -z $branch ]] && continue
        log "consider: $branch (upstream: ${upstream:-<none>})"
        if [[ $branch == "$main_branch" ]]; then
          log "skip: main branch"
          continue
        fi
        if [[ $branch == "$current_branch" ]]; then
          log "skip: current branch"
          continue
        fi

        if command git merge-base --is-ancestor "$branch" "$target_rev" 2>/dev/null; then
          log "merged into ${main_branch}; deleting $branch"
          command git branch -d "$branch"
        else
          log "not merged; keep $branch"
        fi
      done
}

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --ansi --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

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
alias gm='git merge --no-ff'
alias gpull='git pull --rebase'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias griup='git rebase -i @{u}'
alias h='heroku'
alias json='python -mjson.tool'
alias k='kubectl'
alias l='ls'
alias ls='eza -la --icons --smart-group'
alias lzd='lazydocker'
alias rm='tp'
alias tf='terraform'
alias tg='terragrunt'
alias top='btop'
alias vimdiff='${EDITOR} -d'
alias s="sesh"
alias ss="sesh-sessions"

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

eval "$(mise activate zsh)"

 # Generated by sdxcli
 if command -v sdxcli &>/dev/null; then
     eval "$(sdxcli output-shell-commands)"
 fi
 if command -v zoxide &>/dev/null; then
   eval "$(zoxide init zsh --cmd cd)"
 fi
