#!/usr/bin/env bash

BATTERY_CAPACITY_FILE="/sys/class/power_supply/BAT0/capacity"
BATTERY_STATUS_FILE="/sys/class/power_supply/BAT0/status"

NOTIFY_LOW_STATE="/tmp/battery_low_notified"
NOTIFY_PLUG_STATE="/tmp/battery_plug_notified"
NOTIFY_FULL_STATE="/tmp/battery_full_notified"

LOW_POWER_THRESHOLD=25
FULL_CHARGE_THRESHOLD=99

get_battery_info() {
    PERCENT=$(cat "$BATTERY_CAPACITY_FILE")
    STATUS=$(cat "$BATTERY_STATUS_FILE")

    ICON="󰁹"  # default

    if [ "$STATUS" = "Discharging" ]; then
        rm -f "$NOTIFY_FULL_STATE"
        [ -f "$NOTIFY_PLUG_STATE" ] && { notify-send -u normal "Discharging" "Unplugged! Running on battery."; rm -f "$NOTIFY_PLUG_STATE"; }
        if [ "$PERCENT" -le "$LOW_POWER_THRESHOLD" ] && [ ! -f "$NOTIFY_LOW_STATE" ]; then
            notify-send -u critical "Low Power" "Plug in a power source asap."
            touch "$NOTIFY_LOW_STATE"
        elif [ "$PERCENT" -gt "$LOW_POWER_THRESHOLD" ]; then
            rm -f "$NOTIFY_LOW_STATE"
        fi
        # --- select icon based on percent ---
        if [ "$PERCENT" -ge 90 ]; then ICON="󰁹"
        elif [ "$PERCENT" -ge 80 ]; then ICON="󰂂"
        elif [ "$PERCENT" -ge 70 ]; then ICON="󰂁"
        elif [ "$PERCENT" -ge 60 ]; then ICON="󰂀"
        elif [ "$PERCENT" -ge 50 ]; then ICON="󰁿"
        elif [ "$PERCENT" -ge 40 ]; then ICON="󰁾"
        elif [ "$PERCENT" -ge 30 ]; then ICON="󰁽"
        else ICON="󰁼"
        fi
    else
        rm -f "$NOTIFY_LOW_STATE"
        [ ! -f "$NOTIFY_PLUG_STATE" ] && { notify-send -u normal "Charging" "The battery seems hungry"; touch "$NOTIFY_PLUG_STATE"; }

        if ([ "$PERCENT" -ge "$FULL_CHARGE_THRESHOLD" ] && [ "$STATUS" = "Full" ]) || [ "$PERCENT" -eq 100 ]; then
            [ ! -f "$NOTIFY_FULL_STATE" ] && { notify-send -u normal "Full Charge" "Battery is fully charged"; touch "$NOTIFY_FULL_STATE"; }
            ICON="󰁹"
        else
            rm -f "$NOTIFY_FULL_STATE"
            # --- icon selection for charging ---
            if [ "$PERCENT" -ge 90 ]; then ICON="󰂅 "
            elif [ "$PERCENT" -ge 80 ]; then ICON="󰂋 "
            elif [ "$PERCENT" -ge 70 ]; then ICON="󰂊 "
            elif [ "$PERCENT" -ge 60 ]; then ICON="󰢞 "
            elif [ "$PERCENT" -ge 50 ]; then ICON="󰂉 "
            elif [ "$PERCENT" -ge 40 ]; then ICON="󰢝 "
            elif [ "$PERCENT" -ge 30 ]; then ICON="󰂈 "
            elif [ "$PERCENT" -ge 20 ]; then ICON="󰂇 "
            elif [ "$PERCENT" -ge 10 ]; then ICON="󰂆 "
            else ICON="󰢜 "
            fi
        fi
    fi

    echo "$ICON$PERCENT%"
}


# Print initial value
get_battery_info

# Watch both capacity and status files for changes
inotifywait -m -e modify "$BATTERY_CAPACITY_FILE" "$BATTERY_STATUS_FILE" | while read -r; do
    get_battery_info
done
