#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "/.dockerenv" ]; then
  echo "ERROR: Not running inside Docker/devcontainer."
  echo "Open this repo in VS Code and run: Dev Containers: Reopen in Container"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cwd="$(pwd -P)"

case "$cwd/" in
  "$repo_root"/|"$repo_root"/*)
    ;;
  *)
    echo "ERROR: Current directory is outside the repository."
    echo "cd \"$repo_root\""
    exit 1
    ;;
esac

echo "OK: Running inside Docker."
echo "OK: Current directory is inside repository."
echo "Repo root: $repo_root"
