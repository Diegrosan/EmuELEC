#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present DiegroSan (https://github.com/Diegrosan)

. /etc/profile

virtual_keyboard &
VK_PID=$!

LOCAL_DATA="/storage/roms/bios/dc_dojo"
LOCAL_HOME="/storage/.local/share/flycast-dojo"
MAP="/storage/.config/flycast-dojo/mappings"

mkdir -p "/storage/.local/share/"
mkdir -p "${LOCAL_DATA}"

if [ ! -d "/storage/.config/flycast-dojo" ]; then
    mkdir -p "/storage/.config/flycast-dojo"
    cp -r "/usr/config/flycast-dojo" "/storage/.config/"
fi

if [ ! -L "${LOCAL_HOME}" ]; then
    rm -rf "${LOCAL_HOME}"
    ln -sf "${LOCAL_DATA}" "${LOCAL_HOME}"
fi

#AUTOGP=$(get_ee_setting flycast_auto_gamepad)
#if [[ "${AUTOGP}" != "0" ]]; then
#    mkdir -p "${MAP}"
#    set_flycastdojo_joy.sh
#fi

flycastcheevos.sh

#Here is a way I found to access the menu more easily without needing a specific file, being able to access any_name.iso
#The file must be smaller than 1 kb which can be a renamed clean text block
if [ "$(wc -c < "$1")" -lt $((1 * 1024)) ]; then
    flycastdojo
else
    flycastdojo "$1"
fi

kill $VK_PID

