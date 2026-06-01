#!/vendor/bin/sh
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Start indicated fingerprint HAL service
#

PERSIST_FPS_VERSION=/mnt/vendor/persist/fingerprint_version
GOODIX_MAGIC="cf447778"

PROP_FPS_STATUS=vendor.hw.fingerprint.status
PROP_PERSIST_FPS=persist.vendor.hardware.fingerprint

STATUS_NONE=none
STATUS_OK=ok

MAX_WAIT=100

log_notice() {
    log -t "fingerprint.hal" -p i "$*"
}

is_goodix() {
    [ -f "$PERSIST_FPS_VERSION" ] || return 1
    magic=$(dd if="$PERSIST_FPS_VERSION" bs=1 count=4 2>/dev/null | xxd -p)
    [ "$magic" = "$GOODIX_MAGIC" ]
}

if is_goodix; then
    fps=goodix
    log_notice "Starting Goodix HAL"
    start goodix_hal
else
    fps=betterlife
    log_notice "Starting BetterLife HAL"
    start betterlife_hal
fi

setprop "$PROP_FPS_STATUS" "$STATUS_NONE"

log_notice "Waiting for HAL..."
i=0
while [ "$i" -lt "$MAX_WAIT" ]; do
    fps_status=$(getprop "$PROP_FPS_STATUS")
    [ "$fps_status" != "$STATUS_NONE" ] && break
    sleep 0.2
    i=$((i + 1))
done
log_notice "HAL status: $fps_status"

if [ "$fps_status" = "$STATUS_OK" ]; then
    log_notice "HAL success"
    setprop "$PROP_PERSIST_FPS" "$fps"
    exit 0
fi

log_notice "HAL load failed"
setprop "$PROP_PERSIST_FPS" "$STATUS_NONE"
exit 1
