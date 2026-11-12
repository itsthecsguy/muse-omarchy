#!/bin/bash

# Install Muse for the current user from this checkout, without a package.
# Safe to run again.
#   ./install.sh              install into ~/.local
#   ./install.sh --uninstall  remove everything except your settings and any isolated profile

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
data="${XDG_DATA_HOME:-$HOME/.local/share}"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
bin="$HOME/.local/bin/muse-omarchy"
module="$HOME/.local/share/muse-omarchy/muse.lua"
desktop="$data/applications/muse-omarchy.desktop"
icon="$data/icons/hicolor/scalable/apps/muse-omarchy.svg"

if [[ ${1:-} == --uninstall ]]; then
  [[ -x $bin ]] && "$bin" remove
  rm -f "$bin" "$module" "$desktop" "$icon"
  update-desktop-database "$data/applications" >/dev/null 2>&1 || true
  echo "Removed. Settings in $config/muse-omarchy and any isolated profile in $data/muse-omarchy were kept."
  exit 0
fi

for tool in hyprctl omarchy-launch-webapp; do
  command -v "$tool" >/dev/null || { echo "Missing required command: $tool" >&2; exit 1; }
done

# Earlier versions of this installer used these paths.
rm -f "$config/hypr/muse.lua" "$data/applications/Muse.desktop" "$data/icons/hicolor/512x512/apps/muse-omarchy.png"
[[ -f $config/hypr/hyprland.lua ]] && sed -i '\|^require("hypr.muse")$|d' "$config/hypr/hyprland.lua"

install -Dm755 "$here/bin/muse-omarchy" "$bin"
install -Dm644 "$here/share/muse.lua" "$module"
install -Dm644 "$here/pkgbuild/muse-omarchy.svg" "$icon"
install -Dm644 "$here/pkgbuild/muse-omarchy.desktop" "$desktop"
update-desktop-database "$data/applications" >/dev/null 2>&1 || true

"$bin" setup
hyprctl configerrors 2>/dev/null || true

cat <<'EOF'
Installed. Muse is in the app launcher, and `muse-omarchy toggle` shows or hides it.

No key is bound yet. Pick your own, for example:
  muse-omarchy set key "SUPER + SHIFT + M"

To keep Muse's sign-in apart from your main browser profile:
  muse-omarchy set profile isolated
EOF
