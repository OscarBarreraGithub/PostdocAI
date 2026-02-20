#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This launcher only supports macOS."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf "[open-safe-workspace] %s\n" "$*"
}

fail_with_note() {
  printf "[open-safe-workspace] %s\n" "$*" >&2
  exit 1
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
bash "$repo_root/scripts/enforce-agent-extensions-container-only-macos.sh"

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

log "Opening workspace directly in dev container..."
if devcontainer open --help 2>&1 | grep -q -- "--workspace-folder"; then
  exec devcontainer open --workspace-folder "$repo_root"
fi
exec devcontainer open "$repo_root"
