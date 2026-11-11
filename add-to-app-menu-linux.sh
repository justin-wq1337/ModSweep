#!/bin/bash
# Adds ModSweep with its logo to your Linux app menu
DIR="$(cd "$(dirname "$0")" && pwd)"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APPS"
cat > "$APPS/modsweep.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ModSweep for The Sims 4
Comment=Clean up your Sims 4 Mods folder
Exec="$DIR/start-modsweep-linux.sh"
Icon=$DIR/icon.png
Terminal=false
Categories=Utility;Game;
DESKTOP
chmod +x "$APPS/modsweep.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" >/dev/null 2>&1
echo "Done: ModSweep is now in your app menu."
