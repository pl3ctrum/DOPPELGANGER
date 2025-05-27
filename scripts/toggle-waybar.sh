PID_FILE="/tmp/waybar.pid"

if [ -f "$PID_FILE" ]; then
    # Kill existing Waybar and cleanup
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
else
    # Launch Waybar in the background (&) and save its PID correctly
    waybar -c ~/.config/waybar/config.jsonc &
    echo $! > "$PID_FILE"
fi

