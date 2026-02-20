#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This installer only supports macOS."
  exit 1
fi

zshrc_path="$HOME/.zshrc"
marker_start="# >>> POCKETPOSTDOC SAFE AGENT GUARD >>>"
marker_end="# <<< POCKETPOSTDOC SAFE AGENT GUARD <<<"
tmp_file="$(mktemp)"

if [ -f "$zshrc_path" ]; then
  awk -v start="$marker_start" -v end="$marker_end" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$zshrc_path" > "$tmp_file"
else
  : > "$tmp_file"
fi

cat >> "$tmp_file" <<'EOF'
# >>> POCKETPOSTDOC SAFE AGENT GUARD >>>
_pocketpostdoc_require_devcontainer() {
  if [ ! -f "/.dockerenv" ]; then
    echo "ERROR: codex/claude are blocked outside the dev container."
    echo "Use the desktop launcher: Open PocketPostdoc Safe.app"
    return 1
  fi
}

codex() {
  _pocketpostdoc_require_devcontainer || return 1
  if ! whence -p codex >/dev/null 2>&1; then
    echo "ERROR: codex command not found in this environment."
    return 1
  fi
  for arg in "$@"; do
    if [ "$arg" = "--sandbox" ]; then
      command codex "$@"
      return $?
    fi
  done
  command codex --sandbox workspace-write "$@"
}

claude() {
  _pocketpostdoc_require_devcontainer || return 1
  if ! whence -p claude >/dev/null 2>&1; then
    echo "ERROR: claude command not found in this environment."
    return 1
  fi
  if ! command claude --help 2>&1 | grep -q -- "--sandbox"; then
    echo "ERROR: Claude sandbox flag not detected. Refusing to run."
    return 1
  fi
  for arg in "$@"; do
    if [ "$arg" = "--sandbox" ]; then
      command claude "$@"
      return $?
    fi
  done
  command claude --sandbox workspace-write "$@"
}
# <<< POCKETPOSTDOC SAFE AGENT GUARD <<<
EOF

mv "$tmp_file" "$zshrc_path"

echo "Installed zsh guard block in: $zshrc_path"
echo "Open a new terminal session to activate command guards."
