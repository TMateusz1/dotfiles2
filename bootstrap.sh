#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MISE_BIN="$HOME/.local/bin/mise"

log() { printf '\033[32m[bootstrap]\033[0m %s\n' "$*"; }
die() {
    printf '\033[31m[bootstrap] ERROR:\033[0m %s\n' "$*" >&2
    exit 1
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

run_mise() {
    MISE_GLOBAL_CONFIG_FILE="$ROOT/mise/config.toml" "$MISE_BIN" -C "$ROOT" "$@"
}

backup_dotfile_target() {
    local target="$1"

    if [[ -e "$target" || -L "$target" ]]; then
        local backup
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
        log "Backing up $target -> $backup"
        mv "$target" "$backup"
    fi
}

backup_conflicting_dotfiles() {
    local target

    while IFS= read -r target; do
        case "$target" in
            \~/*) target="$HOME/${target#\~/}" ;;
            /*) ;;
            *) die "Unsupported dotfile target from mise: $target" ;;
        esac
        backup_dotfile_target "$target"
    done < <(
        run_mise bootstrap dotfiles status --json |
            run_mise exec -- jq -r '.files[] | select(.state == "differs") | .target'
    )
}

apply_dotfiles() {
    "$MISE_BIN" trust "$ROOT/mise/config.toml"
    "$MISE_BIN" trust "$ROOT/mise/config.macos.toml"
    run_mise install jq
    backup_conflicting_dotfiles
    log "Applying dotfiles with mise"
    run_mise bootstrap dotfiles apply --yes
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
    brew install --cask kitty font-jetbrains-mono-nerd-font
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
}

main() {
    ((EUID != 0)) || die "Run bootstrap as your normal user, not with sudo"
    (($# == 0)) || die "Usage: ./bootstrap.sh"

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
    apply_dotfiles
    configure_git_delta
    install_oh_my_zsh
    install_zsh_plugins
    install_mise_tools
}

main "$@"
