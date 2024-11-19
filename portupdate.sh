#!/bin/bash
# Paths (default values, can be overridden by environment variables)
GLUETUN_PORT_FILE="${GLUETUN_PORT_FILE:-/gluetun/piaportforward.json}"
TRANSMISSION_SETTINGS_FILE="${TRANSMISSION_SETTINGS_FILE:-/settings.json}"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-3600}"  # Default to 1 hour (3600 seconds)

while true; do
    if [ -f "$GLUETUN_PORT_FILE" ]; then
        # Extract the open port from Gluetun JSON
        OPEN_PORT=$(jq -r '.port' "$GLUETUN_PORT_FILE")
        echo "Open port from Gluetun JSON: $OPEN_PORT"

        # Check if OPEN_PORT is empty
        if [ -z "$OPEN_PORT" ]; then
            echo "Failed to extract port from JSON"
        else
            # Extract the current peer-port from Transmission settings.json
            CURRENT_PORT=$(jq -r '.["peer-port"]' "$TRANSMISSION_SETTINGS_FILE")
            echo "Current peer-port in Transmission settings: $CURRENT_PORT"

            # Check if the port has changed
            if [ "$OPEN_PORT" != "$CURRENT_PORT" ]; then
                echo "Port has changed. Updating Transmission settings..."

                # Update the peer-port in Transmission settings.json using sponge
                jq --arg port "$OPEN_PORT" '.["peer-port"] = ($port | tonumber)' "$TRANSMISSION_SETTINGS_FILE" | sponge "$TRANSMISSION_SETTINGS_FILE"

                echo "Updated Transmission peer-port to: $OPEN_PORT"

                # Optional: Restart Transmission to apply changes
                # Uncomment the following line if you want to restart Transmission
                # supervisorctl restart transmission
            else
                echo "Port has not changed. No update needed."
            fi
        fi
    else
        echo "Gluetun port file not found at $GLUETUN_PORT_FILE"
    fi

    # Wait for the defined interval before checking again
    echo "Waiting for $UPDATE_INTERVAL seconds before checking for updates..."
    sleep "$UPDATE_INTERVAL"
done
