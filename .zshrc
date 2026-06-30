# Put machine-local overrides in ~/.zshrc.local.

path_append_if_dir() {
  [[ -d "$1" ]] && path+=("$1")
}

path_append_if_dir "$HOME/.local/bin"
path_append_if_dir "$HOME/bin"
path_append_if_dir "$HOME/go/bin"
typeset -U path PATH

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
fi

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME="${ZSH_THEME:-robbyrussell}"

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

if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

if command -v tmux >/dev/null 2>&1; then
  tc() {
    local session="${1:-core}"

    if [[ -n "$TMUX" ]]; then
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

if [[ -r $HOME/.funcs.zshrc ]]; then
  source "$HOME/.funcs.zshrc"
fi


unfunction path_append_if_dir zsh_plugin_exists 2>/dev/null
