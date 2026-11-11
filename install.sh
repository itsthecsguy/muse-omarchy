#!/bin/bash

# Install Muse as a toggle window for the current user. Safe to run again.
#   ./install.sh              install
#   ./install.sh --uninstall  remove everything except your settings and any isolated profile

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin/muse-omarchy"
hypr="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
desktop="$data/applications/Muse.desktop"
icon="$data/icons/hicolor/512x512/apps/muse-omarchy.png"
require_line='require("hypr.muse")'

reload() {
  hyprctl reload >/dev/null 2>&1 || true
  hyprctl configerrors 2>/dev/null || true
}

if [[ ${1:-} == --uninstall ]]; then
  rm -f "$bin" "$hypr/muse.lua" "$desktop" "$icon"
  [[ -f $hypr/hyprland.lua ]] && sed -i "\|^$require_line\$|d" "$hypr/hyprland.lua"
  reload
  echo "Removed. Settings in ~/.config/muse-omarchy and any isolated profile in $data/muse-omarchy were kept."
  exit 0
fi

for tool in hyprctl jq omarchy-launch-webapp; do
  command -v "$tool" >/dev/null || { echo "Missing required command: $tool" >&2; exit 1; }
done
[[ -f $hypr/hyprland.lua ]] || { echo "No $hypr/hyprland.lua: this needs Omarchy's Lua Hyprland config." >&2; exit 1; }

install -Dm755 "$here/bin/muse-omarchy" "$bin"
install -Dm644 "$here/hypr/muse.lua" "$hypr/muse.lua"

if ! grep -qxF "$require_line" "$hypr/hyprland.lua"; then
  cp "$hypr/hyprland.lua" "$hypr/hyprland.lua.bak.$(date +%s)"
  printf '\n%s\n' "$require_line" >>"$hypr/hyprland.lua"
fi

# The icon is Meta's, so it is fetched from the site's PWA manifest rather than kept in this repository.
icon_name="muse-omarchy"
mkdir -p "$(dirname "$icon")"
if [[ ! -s $icon ]] && ! curl -fsSL -m 20 -o "$icon" "https://muse.ai/images/pwa_icons/any/512.png"; then
  rm -f "$icon"
  icon_name="applications-internet"
fi

mkdir -p "$(dirname "$desktop")"
cat >"$desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Muse
Comment=Meta's personal AI agent
Exec=muse-omarchy toggle
StartupWMClass=chrome-muse.ai__-Default
Terminal=false
Type=Application
Icon=$icon_name
Categories=Network;
Keywords=Muse;Meta;AI;Agent;
EOF
update-desktop-database "$data/applications" >/dev/null 2>&1 || true

reload

cat <<'EOF'
Installed. Muse is in the app launcher, and `muse-omarchy toggle` shows or hides it.

No key is bound yet. Pick your own, for example:
  muse-omarchy set key "SUPER + SHIFT + M"

To keep Muse's sign-in apart from your main browser profile:
  muse-omarchy set profile isolated
EOF
