# Put machine-local overrides in ~/.zshrc.local.

path_append_if_dir() {
  [[ -d "$1" ]] && path+=("$1")
}

path_append_if_dir "$HOME/.local/bin"
path_append_if_dir "$HOME/bin"
path_append_if_dir "$HOME/go/bin"
typeset -U path PATH

if [[ -n "${TERM:-}" ]] && ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

export EDITOR="nvim"
export VISUAL="$EDITOR"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME="${ZSH_THEME:-}"

zsh_plugin_exists() {
  local plugin="$1"

  [[ -d "$ZSH/plugins/$plugin" || -d "$ZSH_CUSTOM/plugins/$plugin" ]]
}

plugins=()
for plugin in git zsh-autosuggestions zsh-syntax-highlighting you-should-use; do
  zsh_plugin_exists "$plugin" && plugins+=("$plugin")
done

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
  alias ll="eza -al --icons=always --git -1"
  alias la="eza -al --icons=always --git"
  alias lt="eza --tree --level=2 --icons=always"
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4,hl:#89b4fa,hl+:#89b4fa,info:#a6adc8,marker:#a6e3a1,pointer:#89b4fa,spinner:#89b4fa,prompt:#89b4fa,header:#89b4fa,border:#6c7086,label:#cdd6f4,query:#cdd6f4"
  FZF_CTRL_R_COMMAND=''
  source <(fzf --zsh)
  bindkey '^F' fzf-history-widget
fi

if command -v tmux >/dev/null 2>&1; then
  tc() {
    local session="${1:-core}"

    if [[ -n "$TMUX" ]] && tmux display-message -p '#S' >/dev/null 2>&1; then
      tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session" -c "$HOME"
      tmux switch-client -t "$session"
    else
      tmux new-session -A -s "$session" -c "$HOME"
    fi
  }
fi

if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

unfunction path_append_if_dir zsh_plugin_exists 2>/dev/null
