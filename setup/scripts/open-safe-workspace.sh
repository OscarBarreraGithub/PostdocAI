#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This launcher only supports macOS."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log() {
  printf "[open-safe-workspace] %s\n" "$*"
}

fail_with_note() {
  printf "[open-safe-workspace] %s\n" "$*" >&2
  exit 1
}

open_in_container_uri() {
  local workspace_basename repo_root_hex remote_uri
  workspace_basename="$(basename "$repo_root")"
  repo_root_hex="$(printf '%s' "$repo_root" | xxd -p | tr -d '\n')"
  remote_uri="vscode-remote://dev-container+$repo_root_hex/workspaces/$workspace_basename"
  log "Opening VS Code directly in dev container via remote URI..."
  exec code --folder-uri "$remote_uri"
}

if ! command -v docker >/dev/null 2>&1 && [ -x /Applications/Docker.app/Contents/Resources/bin/docker ]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi

if ! command -v docker >/dev/null 2>&1; then
  fail_with_note "Docker CLI not found. Run ./bootstrap.sh first."
fi

if ! command -v code >/dev/null 2>&1 && [ -x /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code ]; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

if ! command -v code >/dev/null 2>&1; then
  fail_with_note "VS Code CLI not found. Run ./bootstrap.sh first."
fi

if ! command -v devcontainer >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    npm_bin_dir="$(npm config get prefix)/bin"
    if [ -d "$npm_bin_dir" ]; then
      export PATH="$npm_bin_dir:$PATH"
    fi
  fi
fi

if ! command -v devcontainer >/dev/null 2>&1; then
  fail_with_note "devcontainer CLI not found. Run ./bootstrap.sh first."
fi

log "Enforcing container-only VS Code agent extensions..."
bash "$repo_root/setup/scripts/enforce-agent-extensions-container-only-macos.sh"

log "Starting Docker Desktop..."
open -g -a Docker || true

log "Waiting for Docker engine..."
docker_ready=0
for _ in $(seq 1 180); do
  if docker info >/dev/null 2>&1; then
    docker_ready=1
    break
  fi
  sleep 2
done
if [ "$docker_ready" -ne 1 ]; then
  fail_with_note "Docker did not become ready. Open Docker Desktop and retry."
fi

devcontainer_help="$(devcontainer --help 2>&1 || true)"

if printf "%s\n" "$devcontainer_help" | grep -Eq '^[[:space:]]*devcontainer open([[:space:]]|$)'; then
  log "Opening workspace directly in dev container..."
  if devcontainer open --help 2>&1 | grep -q -- "--workspace-folder"; then
    if devcontainer open --workspace-folder "$repo_root"; then
      exit 0
    fi
  else
    if devcontainer open "$repo_root"; then
      exit 0
    fi
  fi
  log "devcontainer open failed; falling back to 'devcontainer up'."
fi

log "This devcontainer CLI build does not support 'open'."
log "Preparing the container with 'devcontainer up'..."
if devcontainer up --help 2>&1 | grep -q -- "--workspace-folder"; then
  devcontainer up --workspace-folder "$repo_root"
else
  devcontainer up "$repo_root"
fi

if command -v xxd >/dev/null 2>&1; then
  open_in_container_uri
fi

fail_with_note "Cannot build VS Code remote container URI because 'xxd' is missing."
