#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <agent-command> [args...]"
  echo "Example: $0 codex"
  echo "Example: $0 claude"
  exit 1
fi

if [ ! -f "/.dockerenv" ]; then
  echo "ERROR: This wrapper must run inside the dev container."
  echo "Open VS Code and run: Dev Containers: Reopen in Container"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

agent_command="$1"
shift

case "$agent_command" in
  codex)
    # Workspace-write is the hard boundary, not cwd.
    exec codex --sandbox workspace-write "$@"
    ;;
  claude)
    if claude --help 2>&1 | grep -q -- "--sandbox"; then
      exec claude --sandbox workspace-write "$@"
    fi
    echo "ERROR: Claude sandbox flag not detected. Refusing to run unsandboxed."
    exit 1
    ;;
  *)
    echo "ERROR: Unsupported agent '$agent_command'. Use: codex or claude"
    exit 1
    ;;
esac
