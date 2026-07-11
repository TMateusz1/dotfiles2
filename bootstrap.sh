#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MISE_BIN="$HOME/.local/bin/mise"

log() { printf '\033[32m[bootstrap]\033[0m %s\n' "$*"; }
die() {
    printf '\033[31m[bootstrap] ERROR:\033[0m %s\n' "$*" >&2
    exit 1
}

link() {
    local source="$ROOT/$1"
    local target="$2"

    mkdir -p "$(dirname -- "$target")"
    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        local backup
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        log "Backing up $target -> $backup"
        mv "$target" "$backup"
    fi
    log "Linking $target -> $source"
    ln -s "$source" "$target"
}

link_common_configs() {
    link .tmux.conf "$HOME/.tmux.conf"
    link .zshrc "$HOME/.zshrc"
    link atuin/config.toml "$HOME/.config/atuin/config.toml"
    link git/delta.gitconfig "$HOME/.config/git/delta.gitconfig"
    link k9s/config.yaml "$HOME/.config/k9s/config.yaml"
    link k9s/skins/catppuccin-mocha.yaml "$HOME/.config/k9s/skins/catppuccin-mocha.yaml"
    link lazygit/config.yml "$HOME/.config/lazygit/config.yml"
    link mise/config.toml "$HOME/.config/mise/config.toml"
    link nvim "$HOME/.config/nvim"
    link starship.toml "$HOME/.config/starship.toml"
}

link_macos_configs() {
    link ghostty/config "$HOME/.config/ghostty/config"
    link kitty "$HOME/.config/kitty"
    link k9s/config.yaml "$HOME/Library/Application Support/k9s/config.yaml"
    link k9s/skins/catppuccin-mocha.yaml "$HOME/Library/Application Support/k9s/skins/catppuccin-mocha.yaml"
    link lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"
}

configure_git_delta() {
    local path="$HOME/.config/git/delta.gitconfig"
    if git config --global --get-all include.path 2>/dev/null | grep -qxF "$path"; then
        return
    fi
    log "Including Git delta config: $path"
    git config --global --add include.path "$path"
}

install_mise() {
    if [[ -x "$MISE_BIN" ]]; then
        return
    fi
    log "Installing mise"
    curl -fsSL https://mise.run | sh
}

install_mise_tools() {
    log "Installing mise tools"
    "$MISE_BIN" install go node uv
    "$MISE_BIN" install
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        return
    fi
    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

clone_plugin() {
    local dest="$HOME/.oh-my-zsh/custom/plugins/$1"
    [[ -d "$dest" ]] && return
    log "Installing Zsh plugin: $1"
    git clone --depth=1 "$2" "$dest"
}

install_zsh_plugins() {
    clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
    clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
    clone_plugin you-should-use https://github.com/MichaelAquilina/zsh-you-should-use.git
}

bootstrap_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    log "Installing Homebrew packages"
    brew install git
    brew install --cask ghostty kitty font-fira-code-nerd-font
    link_common_configs
    link_macos_configs
}

bootstrap_ubuntu() {
    log "Installing apt packages"
    sudo apt-get update
    sudo apt-get install -y bubblewrap build-essential ca-certificates curl git pkg-config tar unzip xz-utils zsh
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
        log "Setting login shell to zsh"
        sudo chsh -s "$zsh_path" "$USER"
    fi
    link_common_configs
}

main() {
    case "$(uname -s)" in
        Darwin)
            log "Detected OS: macOS"
            bootstrap_macos
            ;;
        Linux)
            # shellcheck disable=SC1091
            [[ -r /etc/os-release ]] && . /etc/os-release
            [[ "${ID:-}" == ubuntu ]] || die "Unsupported Linux distribution"
            log "Detected OS: Ubuntu"
            bootstrap_ubuntu
            ;;
        *) die "Unsupported OS: $(uname -s)" ;;
    esac

    install_mise
    configure_git_delta
    install_oh_my_zsh
    install_zsh_plugins
    install_mise_tools
}

main "$@"
