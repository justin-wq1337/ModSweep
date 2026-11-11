#!/bin/bash
# ModSweep for The Sims 4: starter for macOS
cd "$(dirname "$0")"

PY=""
for c in /Library/Frameworks/Python.framework/Versions/Current/bin/python3 /opt/homebrew/bin/python3 /usr/local/bin/python3; do
    if [ -x "$c" ] && "$c" -c "import tkinter" >/dev/null 2>&1; then PY="$c"; break; fi
done
if [ -z "$PY" ] && command -v python3 >/dev/null 2>&1 && python3 -c "import tkinter" >/dev/null 2>&1; then
    PY="python3"
fi

if [ -z "$PY" ]; then
    osascript -e 'set r to button returned of (display dialog "ModSweep needs Python 3.\n\nPlease install Python from python.org and start ModSweep again." buttons {"OK", "Open python.org"} default button 2)' \
              -e 'if r is "Open python.org" then open location "https://www.python.org/downloads/macos/"'
    exit 1
fi

nohup "$PY" modsweep.py >/dev/null 2>&1 &
echo "ModSweep is starting. You can close this window."
