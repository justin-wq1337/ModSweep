#!/bin/bash
# ModSweep for The Sims 4: starter for Linux
cd "$(dirname "$0")"

if ! python3 -c "import tkinter" >/dev/null 2>&1; then
    msg="ModSweep needs Python 3 with Tkinter.
Ubuntu, Debian, Mint: sudo apt install python3-tk
Fedora: sudo dnf install python3-tkinter
Arch, Manjaro: sudo pacman -S tk
openSUSE: sudo zypper install python3-tk"
    if command -v zenity >/dev/null 2>&1; then zenity --error --text="$msg"
    elif command -v kdialog >/dev/null 2>&1; then kdialog --error "$msg"
    else echo "$msg"; fi
    exit 1
fi

python3 modsweep.py >/dev/null 2>&1 &
