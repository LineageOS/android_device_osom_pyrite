#!/vendor/bin/sh
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Identify fingerprint sensor model and load kernel module
#

PERSIST_FPS_VERSION=/mnt/vendor/persist/fingerprint_version
GOODIX_MAGIC="cf447778"

log_notice() {
    log -t "fingerprint.detect" -p i "$*"
}

is_goodix() {
    [ -f "$PERSIST_FPS_VERSION" ] || return 1
    magic=$(dd if="$PERSIST_FPS_VERSION" bs=1 count=4 2>/dev/null | xxd -p)
    [ "$magic" = "$GOODIX_MAGIC" ]
}

if is_goodix; then
    log_notice "Detected Goodix sensor, loading goodix_fps"
    insmod /vendor/lib/modules/goodix_fps.ko
else
    log_notice "Defaulting to BetterLife sensor, loading betterlife_fps"
    insmod /vendor/lib/modules/betterlife_fps.ko
fi
