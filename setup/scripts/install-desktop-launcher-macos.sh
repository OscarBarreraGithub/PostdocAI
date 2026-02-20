#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This installer only supports macOS."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
launcher_path="$HOME/Desktop/Open PostdocAI Safe.command"

cat > "$launcher_path" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "$repo_root/setup/scripts/open-safe-workspace.sh"
EOF

chmod +x "$launcher_path"

echo "Desktop launcher created:"
echo "  $launcher_path"
