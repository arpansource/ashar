#!/usr/bin/env bash
BRIGHT_FILE="/sys/class/backlight/intel_backlight/brightness"
MAX_FILE="/sys/class/backlight/intel_backlight/max_brightness"


# function to print brightness
print_brightness() {
    BR=$(cat "$BRIGHT_FILE")
    MAX=$(cat "$MAX_FILE")
    PCT=$((BR * 100 / MAX))

    if   [ "$PCT" -ge 75 ]; then ICON="󰃠 "
    elif [ "$PCT" -ge 50 ]; then ICON="󰃟 "
    elif [ "$PCT" -ge 25 ]; then ICON="󰃝 "
    else ICON="󰃞 "
    fi

    echo "$ICON $PCT%"
}

# Print initial value
while true; do
  print_brightness
  break
done

# Watch the brightness file for changes
inotifywait -m -e modify "$BRIGHT_FILE" | while read -r _ _ _; do
    print_brightness
done
