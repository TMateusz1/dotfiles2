#!/usr/bin/env bash
set -euo pipefail

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
DOTFILES_VSCODE="$HOME/dev/dotfiles2/vscode"

mkdir -p "$VSCODE_USER_DIR"

ln -sf "$DOTFILES_VSCODE/settings.json" "$VSCODE_USER_DIR/settings.json"
ln -sf "$DOTFILES_VSCODE/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
ln -sfn "$DOTFILES_VSCODE/snippets" "$VSCODE_USER_DIR/snippets"

if ! command -v code >/dev/null 2>&1; then
  echo "VS Code CLI 'code' not found."
  echo "In VS Code, run: Shell Command: Install 'code' command in PATH"
  exit 1
fi

while IFS= read -r extension || [ -n "$extension" ]; do
  # trim simple leading/trailing whitespace
  extension="${extension#"${extension%%[![:space:]]*}"}"
  extension="${extension%"${extension##*[![:space:]]}"}"

  # skip empty lines and comments
  [[ -z "$extension" ]] && continue
  [[ "$extension" == \#* ]] && continue

  echo "Installing: $extension"
  code --install-extension "$extension"
done <"$DOTFILES_VSCODE/extensions.txt"