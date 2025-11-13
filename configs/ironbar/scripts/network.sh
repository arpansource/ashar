#!/bin/bash

# Define the Wi-Fi device name (CONFIRMED from your output)
WIFI_DEVICE="wlan0"

# --- Function to safely extract a property value ---
# $1 = property name (e.g., "State", "Connected network")
# $2 = device name (e.g., "wlan0")
# $3 = awk field index (2 for single-word property, 3 for multi-word like "Connected network")
get_property() {
    iwctl station "$2" show 2>/dev/null | grep -E "^\s*$1" | awk "{print \$$3}"
}

# --- Function to convert RSSI (dBm) to a 0-100% value ---
# $1 = RSSI value in dBm (e.g., -64)
rssi_to_percent() {
    local rssi=$1
    local min_dbm=-90 # Threshold for 0%
    local max_dbm=-30 # Threshold for 100%

    # Simple linear mapping: (RSSI - Min) / (Max - Min) * 100
    # Use 'bc' for floating point math
    PERCENT=$(echo "scale=0; ( ( $rssi - $min_dbm ) * 100 ) / ( $max_dbm - $min_dbm )" | bc)

    # Ensure value is clamped between 0 and 100
    if [ "$PERCENT" -gt 100 ]; then
        echo 100
    elif [ "$PERCENT" -lt 0 ]; then
        echo 0
    else
        echo "$PERCENT"
    fi
}

# 1. Get the current connection status
STATUS=$(get_property "State" "$WIFI_DEVICE" 2)

if [ "$STATUS" == "connected" ]; then

    # 2. Get the SSID (Corrected: uses "Connected network" and extracts the 3rd column)
    # Your output: 'Connected network      abhishek' -> 'abhishek' is field 3
    SSID=$(get_property "Connected network" "$WIFI_DEVICE" 3)

    # 3. Get the Signal Strength (RSSI in dBm)
    # Your output: 'RSSI -64 dBm' -> '-64' is the 2nd field. Strip ' dBm' if present.
    RSSI_DBM=$(get_property "RSSI" "$WIFI_DEVICE" 2 | awk '{print $1}')


    # Check if RSSI is a valid number before using it
    if ! [[ "$RSSI_DBM" =~ ^-?[0-9]+$ ]]; then
        RSSI_DBM=-100 # Default to poor signal if parsing fails
    fi

    SIGNAL_PCT=$(rssi_to_percent "$RSSI_DBM")

    # 4. Determine the Wi-Fi icon based on RSSI (dBm thresholds)
    # Note: RSSI values closer to 0 are STRONGER signals.
    if [ "$RSSI_DBM" -ge -50 ]; then
        ICON="󰤨 " # Full signal (Excellent: > -50 dBm)
    elif [ "$RSSI_DBM" -ge -60 ]; then
        ICON="󰤥 " # 3/4 signal (Good: -50 to -60 dBm)
    elif [ "$RSSI_DBM" -ge -70 ]; then
        ICON="󰤢 " # 1/2 signal (Fair: -60 to -70 dBm)
    else
        ICON="󰤠 " # Low signal (Weak: < -70 dBm)
    fi

    # 5. Output the status: Icon + SSID
    # echo "$ICON $SSID ($SIGNAL_PCT%)"
    echo "$ICON"

else
    # Not connected
    ICON="󰤮 " # Disconnected icon
    # Output the status with the HTML span for CSS styling
    echo "$ICON Not Connected"

fi
