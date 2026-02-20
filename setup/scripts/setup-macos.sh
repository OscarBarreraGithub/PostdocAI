#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This setup script only supports macOS."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log() {
  printf "[setup-macos] %s\n" "$*"
}

fail_with_note() {
  printf "[setup-macos] %s\n" "$*" >&2
  exit 1
}

if ! xcode-select -p >/dev/null 2>&1; then
  log "Xcode Command Line Tools are missing. Triggering installer..."
  xcode-select --install || true
  fail_with_note "Finish the install popup, then run this script again."
fi

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  fail_with_note "Homebrew was not found after installation."
fi

install_cask_if_missing() {
  local cask_name="$1"
  if brew list --cask "$cask_name" >/dev/null 2>&1; then
    log "$cask_name already installed."
    return
  fi
  log "Installing $cask_name..."
  brew install --cask "$cask_name"
}

install_formula_if_missing() {
  local formula_name="$1"
  if brew list "$formula_name" >/dev/null 2>&1; then
    log "$formula_name already installed."
    return
  fi
  log "Installing $formula_name..."
  brew install "$formula_name"
}

install_formula_if_missing git
install_cask_if_missing docker
install_cask_if_missing visual-studio-code

if ! command -v docker >/dev/null 2>&1 && [ -x /Applications/Docker.app/Contents/Resources/bin/docker ]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi

if ! command -v code >/dev/null 2>&1 && [ -x /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code ]; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

if ! command -v code >/dev/null 2>&1; then
  fail_with_note "VS Code CLI not found. Open VS Code once, then rerun."
fi

log "Installing VS Code extensions..."
code --install-extension ms-vscode-remote.remote-containers --force
code --install-extension James-Yu.latex-workshop --force

if ! command -v devcontainer >/dev/null 2>&1; then
  if ! command -v npm >/dev/null 2>&1; then
    install_formula_if_missing node
  fi
  log "Installing devcontainer CLI..."
  npm install -g @devcontainers/cli
  npm_bin_dir="$(npm config get prefix)/bin"
  if [ -d "$npm_bin_dir" ]; then
    export PATH="$npm_bin_dir:$PATH"
  fi
fi

log "Creating desktop launcher icon..."
bash "$repo_root/setup/scripts/install-desktop-launcher-macos.sh"

log "Installing shell command guards..."
bash "$repo_root/setup/scripts/install-agent-guards-macos.sh"

log "Enforcing container-only VS Code agent extensions..."
bash "$repo_root/setup/scripts/enforce-agent-extensions-container-only-macos.sh"

log "Launching safe workspace..."
bash "$repo_root/setup/scripts/open-safe-workspace.sh"
