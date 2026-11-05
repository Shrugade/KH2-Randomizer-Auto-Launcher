#!/bin/bash

# Open in a dedicated terminal when double-clicked.
if [[ "${KH2_AUTO_TERMINAL:-0}" != "1" ]]; then
    exec konsole --separate -e env KH2_AUTO_TERMINAL=1 bash "$0"
fi

set -u

APPID=2552430
STEAM="$HOME/.local/share/Steam"
[[ -d "$STEAM/steamapps" ]] || STEAM="$HOME/.steam/steam"

echo "======================================"
echo "       KINGDOM HEARTS II AUTO"
echo "======================================"
echo

fail() {
    echo
    echo "Detection failed: $1"
    read -r -p "Press ENTER to exit..."
    exit 1
}

# Detect game installation.
MANIFEST="$STEAM/steamapps/appmanifest_$APPID.acf"
[[ -f "$MANIFEST" ]] || fail "KH2 Steam manifest"

GAME_DIR_NAME=$(sed -n 's/.*"installdir"[[:space:]]*"\(.*\)".*/\1/p' "$MANIFEST" | head -1)
[[ -n "$GAME_DIR_NAME" ]] || fail "KH2 installation directory"

GAME_DIR="$STEAM/steamapps/common/$GAME_DIR_NAME"
GAME_EXE=$(find "$GAME_DIR" -maxdepth 2 -iname 'KINGDOM HEARTS II FINAL MIX.exe' -print -quit 2>/dev/null)
[[ -n "$GAME_EXE" && -f "$GAME_EXE" ]] || fail "KH2 executable"

# Detect compatibility prefix.
COMPAT="$STEAM/steamapps/compatdata/$APPID"
[[ -d "$COMPAT" ]] || fail "KH2 compatibility prefix"

# Detect the actual Proton executable from Steam's latest KH2 launch.
LOG="$STEAM/logs/console_log.txt"
[[ -f "$LOG" ]] || fail "Steam console log"

mapfile -t DETECTED < <(python3 - "$LOG" "$APPID" "$STEAM/steamapps/common" <<'PYDETECT'
import re
import sys
from pathlib import Path

log, appid, common = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
lines = log.read_text(errors="replace").splitlines()

proton = None
runtime = None

for line in reversed(lines):
    if f"AppID {appid}" not in line or "Game process" not in line:
        continue

    match = re.search(r"""--\s+'([^']+)'/proton(?:\s|$)""", line)
    if not match:
        continue

    candidate = Path(match.group(1)) / "proton"
    if candidate.is_file() and candidate.stat().st_mode & 0o111:
        proton = candidate

    runtime_match = re.search(
        r"""(/[^'"\s]*/SteamLinuxRuntime[^/'"\s]*/_v2-entry-point)""",
        line
    )
    if runtime_match:
        candidate_runtime = Path(runtime_match.group(1))
        if candidate_runtime.is_file() and candidate_runtime.stat().st_mode & 0o111:
            runtime = candidate_runtime
    break

if proton:
    print(proton)
else:
    print("")

if runtime:
    print(runtime)
else:
    candidates = list(common.glob("SteamLinuxRuntime*/_v2-entry-point"))
    candidates = [p for p in candidates if p.is_file() and p.stat().st_mode & 0o111]
    print(max(candidates, key=lambda p: p.stat().st_mtime) if candidates else "")
PYDETECT
)

PROTON="${DETECTED[0]:-}"
RUNTIME="${DETECTED[1]:-}"

[[ -n "$PROTON" && -x "$PROTON" ]] || fail "KH2 Proton executable in Steam launch log"
[[ -n "$RUNTIME" && -x "$RUNTIME" ]] || fail "Steam Linux Runtime"

PROTON_ID=$(basename "$(dirname "$PROTON")")
# Detect Tracker and LiveSplit anywhere under the home directory.
TRACKER=$(find "$HOME" -type f -iname 'KhTracker.exe' -print -quit 2>/dev/null)
[[ -n "$TRACKER" ]] || fail "KH2 Tracker executable"

TRACKER_DIR=$(dirname "$TRACKER")

LIVESPLIT=$(find "$HOME" -type f -iname 'LiveSplit.exe' -print -quit 2>/dev/null)
[[ -n "$LIVESPLIT" ]] || fail "LiveSplit executable"

LIVESPLIT_DIR=$(dirname "$LIVESPLIT")

echo "All paths detected:"
echo "Game:       $GAME_EXE"
echo "Prefix:     $COMPAT"
echo "Proton:     $PROTON_ID"
echo "Runtime:    Steam Linux Runtime sniper"
echo "Tracker:    $TRACKER"
echo "LiveSplit:  $LIVESPLIT"
echo
echo "Launching KH2 first..."
echo "Wait until the actual title screen appears."
echo

# Preserve the previously tested KH2 launch settings.
cd "$GAME_DIR" || fail "Cannot enter KH2 directory"

DISABLE_LSFGVK=1 gamescope \
    -w 1280 -h 720 -W 640 -H 720 -S stretch -F linear -- \
    env \
    STEAM_COMPAT_APP_ID="$APPID" \
    SteamAppId="$APPID" \
    SteamGameId="$APPID" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM" \
    STEAM_COMPAT_DATA_PATH="$COMPAT" \
    PRESSURE_VESSEL_FILESYSTEMS_RW="$TRACKER_DIR" \
    MANGOHUD=1 \
    MANGOHUD_CONFIG="no_display,fps_limit=60,fps_limit_method=early" \
    WINEDLLOVERRIDES="version,dinput8,KH2Moose=n,b" \
    mangohud taskset -c 0-7 \
    "$RUNTIME" \
    --verb=waitforexitandrun -- \
    "$PROTON" waitforexitandrun "$GAME_EXE" \
    > "$HOME/kh2-gamescope.log" 2>&1 &

GAME_PID=$!

echo "KH2 has been launched."
read -r -p "When the KH2 title screen is visible, press ENTER to start Tracker and LiveSplit..."

# Start Tracker in the shared Wine virtual desktop.
echo
echo "Starting KH2 Tracker..."
cd "$TRACKER_DIR" || fail "Cannot enter Tracker directory"

STEAM_COMPAT_APP_ID="$APPID" \
SteamAppId="$APPID" \
SteamGameId="$APPID" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM" \
STEAM_COMPAT_DATA_PATH="$COMPAT" \
WINEFSYNC=1 \
WINEDLLOVERRIDES="winex11.drv=b" \
"$PROTON" run explorer /desktop=KH2Tracker,1280x800 "$TRACKER" &

sleep 3

# Start LiveSplit in the SAME Wine virtual desktop.
echo "Starting LiveSplit..."
cd "$LIVESPLIT_DIR" || fail "Cannot enter LiveSplit directory"

STEAM_COMPAT_APP_ID="$APPID" \
SteamAppId="$APPID" \
SteamGameId="$APPID" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM" \
STEAM_COMPAT_DATA_PATH="$COMPAT" \
WINEFSYNC=1 \
WINEDLLOVERRIDES="winex11.drv=b" \
"$PROTON" run explorer /desktop=KH2Tracker,1280x800 "$LIVESPLIT" &

# Position the Wine desktop in the 1280x720 area, leaving KDE's panel exposed.
for attempt in {1..20}; do
    wid=$(xdotool search --name 'KH2Tracker' 2>/dev/null | head -1)
    if [[ -n "$wid" ]]; then
        xdotool windowstate --remove FULLSCREEN "$wid" 2>/dev/null
        xdotool windowstate --remove MAXIMIZED_VERT "$wid" 2>/dev/null
        xdotool windowstate --remove MAXIMIZED_HORZ "$wid" 2>/dev/null
        xdotool windowmove "$wid" 0 0 2>/dev/null
        xdotool windowsize "$wid" 1280 800 2>/dev/null
        break
    fi
    sleep 1
done

echo
echo "KH2, Tracker, and LiveSplit have been started."
echo "KH2 launch log: $HOME/kh2-gamescope.log"
echo
read -r -p "Press ENTER to close this launcher window..."
