#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This script only supports macOS."
  exit 1
fi

if ! command -v code >/dev/null 2>&1 && [ -x /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code ]; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

if ! command -v code >/dev/null 2>&1; then
  echo "ERROR: VS Code CLI not found."
  echo "Open VS Code once and run this script again."
  exit 1
fi

remove_if_present() {
  local extension_id="$1"
  if code --list-extensions | grep -Eiq "^${extension_id}$"; then
    echo "[enforce-agent-extensions] Removing host extension: $extension_id"
    code --uninstall-extension "$extension_id"
    return
  fi
  echo "[enforce-agent-extensions] Host extension not installed: $extension_id"
}

# Keep agent extensions off the host VS Code extension host.
remove_if_present openai.chatgpt
remove_if_present openai.codex
remove_if_present anthropic.claude-code
