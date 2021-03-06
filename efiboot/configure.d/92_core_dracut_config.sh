#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

dracut_config_path="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/config/dracut"

einfo "Setup dracut configuration for core root mount with DM-Verity"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/10clipos-core-verity"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/10clipos-core-verity/module-setup.sh" \
    "${dracut_config_path}/10clipos-core-verity/verity-generator.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/10clipos-core-verity"

einfo "Setup dracut configuration for core state mount"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/11clipos-core-state/module-setup.sh" \
    "${dracut_config_path}/11clipos-core-state/mount-core-state.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state"

einfo "Setup dracut configuration for boot failure state module"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-boot-failed"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/90clipos-boot-failed/module-setup.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-boot-failed"
install -m 0644 -o 0 -g 0 \
    "${dracut_config_path}/90clipos-boot-failed/boot-failed.service" \
    "${dracut_config_path}/90clipos-boot-failed/boot-failed.target" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-boot-failed"

# If instrumented, ensure to put a service file that drops us to
# emergency.target which offer a shell in order to debug what's going on:
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    install -m 0644 -o 0 -g 0 \
        "${dracut_config_path}/90clipos-boot-failed/boot-failed.service.instrumented" \
        "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-boot-failed/boot-failed.service"
fi

einfo "Setup dracut configuration for state partition content checks"
install -d -m 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-check-state"
install -m 0755 -o 0 -g 0 \
    "${dracut_config_path}/90clipos-check-state/module-setup.sh" \
    "${dracut_config_path}/90clipos-check-state/clipos-check-state.sh" \
    "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/90clipos-check-state"

readonly VG_NAME="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    readonly REQUIRE_TPM=false
    readonly BRUTEFORCE_LOCKOUT=false
else
    readonly REQUIRE_TPM=true
    readonly BRUTEFORCE_LOCKOUT=true
fi
export VG_NAME REQUIRE_TPM BRUTEFORCE_LOCKOUT
replace_placeholders "${CURRENT_OUT_ROOT}/usr/lib/dracut/modules.d/11clipos-core-state/mount-core-state.sh"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
