#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SOCKET="${TMPDIR:-/tmp}/dotfiles2-check-$$.sock"

cleanup() {
    tmux -S "$TMUX_SOCKET" kill-server >/dev/null 2>&1 || true
    rm -f "$TMUX_SOCKET"
}
trap cleanup EXIT

cd "$ROOT"

bash -n bootstrap.sh check.sh
zsh -n .zshrc
shellcheck bootstrap.sh check.sh
shfmt -i 4 -ci -d bootstrap.sh check.sh

jq empty nvim/lazy-lock.json nvim/snippets/*.json
yq -oy '.' k9s/config.yaml k9s/skins/catppuccin-mocha.yaml lazygit/config.yml >/dev/null
yq -p toml -oy '.' atuin/config.toml mise/config.toml starship.toml >/dev/null
git config --file git/delta.gitconfig --list >/dev/null
STARSHIP_CONFIG="$ROOT/starship.toml" starship prompt --path "$ROOT" >/dev/null

tmux -S "$TMUX_SOCKET" -f "$ROOT/.tmux.conf" new-session -d -s dotfiles-check
tmux -S "$TMUX_SOCKET" show-options -g >/dev/null
nvim --headless -i NONE -u "$ROOT/nvim/init.lua" '+checkhealth lazy vim.lsp nvim-treesitter' +qa!
