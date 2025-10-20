#!/usr/bin/env bash

LAST_TITLE=""

# Safely print title for Ironbar
# The title is cleaned (newlines removed, trimmed).
# The output is always printed, even if it is an empty string ("") after cleaning.
print_title() {
    local TITLE="$1"
    # 1. Replace newlines with spaces
    TITLE="${TITLE//$'\n'/ }"
    # 2. Trim leading/trailing spaces (this will convert a string of only spaces to an empty string)
    TITLE="$(echo -n "$TITLE" | xargs)"
    # 3. Print the result (prints a blank line if TITLE is empty)
    echo "$TITLE"
}

# Get current active window title
get_current_title() {
    hyprctl activewindow 2>/dev/null | awk -F'title: ' '{print $2}'
}

# Print initial value (always prints, even if empty)
LAST_TITLE=$(get_current_title)
print_title "$LAST_TITLE"

# --- Start Hyprland event listener in background ---
hyprctl -v events 2>/dev/null | while read -r LINE; do
    if [[ "$LINE" == activewindow* ]]; then
        NEW_TITLE=$(echo "$LINE" | awk -F'title: ' '{print $2}')

        # Check only for change against the last title.
        # This ensures empty strings are printed if the previous title was non-empty.
        [[ "$NEW_TITLE" == "$LAST_TITLE" ]] && continue

        LAST_TITLE="$NEW_TITLE"
        print_title "$NEW_TITLE"
    fi
done &

# --- Fast fallback polling (every 50ms) ---
while true; do
    sleep 0.05
    NEW_TITLE=$(get_current_title)

    # Check only for change against the last title.
    # This ensures empty strings are printed if the previous title was non-empty.
    [[ "$NEW_TITLE" == "$LAST_TITLE" ]] && continue

    LAST_TITLE="$NEW_TITLE"
    print_title "$NEW_TITLE"
done
