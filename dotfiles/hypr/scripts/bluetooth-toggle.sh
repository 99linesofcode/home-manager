#!/usr/bin/env sh

STATE=$(bluetoothctl show | grep Powered | awk "{print $2}")

rfkill "$([ "$STATE" = "yes" ] && echo "block" || echo "unblock")" bluetooth
