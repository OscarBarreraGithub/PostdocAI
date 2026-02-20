#!/usr/bin/env bash
set -euo pipefail

setup_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$setup_root/scripts/setup-macos.sh"
