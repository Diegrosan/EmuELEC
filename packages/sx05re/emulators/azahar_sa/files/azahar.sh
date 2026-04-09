#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present DiegroSan https://github.com/Diegrosan
# Azahar port KMS+sdl2 BY DiegroSan🤠️

. /etc/profile

export HOME=${HOME:-/storage}
export XDG_DATA_HOME=${HOME}/.config
export XDG_CONFIG_HOME=${HOME}/.config

# (Mali/KMS) ---
export AZAHAR_RENDERER=Vulkan
export MALI_NOCPUAFFINITY=1
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/mali.json
export SDL_VIDEODRIVER=kmsdrm
export EGL_PLATFORM=drm

export SDL_RENDER_VSYNC=0

CONFIG_DIR="/storage/.config/azahar-emu"
CONFIG_FILE="${CONFIG_DIR}/sdl2-config.ini"
CONFIG_DIR="/storage/.config/azahar-emu"
RESIDUE_DIR="/storage/.cache/cores"

EMULATOR="azahar"

# Remove residue
find "${RESIDUE_DIR}" -type f -size +102400k -exec rm -f {} \;

mkdir -p "$CONFIG_DIR"
# If it doesn't exist, the sdl2-config.ini file will be generated.
if [ ! -f "$CONFIG_FILE" ]; then
    ${EMULATOR} && killall -9 ${EMULATOR}
fi

DEBUG="1"
AUTOPADCONFIG="1"
LAYOUT="1"

LAYOUTSET="2" # Layout for the screen inside the render window.
# 0 (default): Default Above/Below Screen
# 1: Single Screen Only
# 2: Large Screen Small Screen
# 3: Side by Side
# 4: Separate Windows
# 5: Hybrid Screen

LOG_VALUE="*:Critical"
[ "$DEBUG" = "1" ] && LOG_VALUE="*:Debug"
[ "$DEBUG" = "2" ] && LOG_VALUE="*:Info"

if grep -q "^log_filter" "$CONFIG_FILE" 2>/dev/null; then
    sed -i "s/^log_filter.*/log_filter = $LOG_VALUE/" "$CONFIG_FILE"
fi

if [ "$AUTOPADCONFIG" == "1" ]; then
azahar_autogamepad.sh "$2"
fi

if [ "$LAYOUT" == "1" ]; then
 sed -i "s/^layout_option.*/layout_option = $LAYOUTSET/" "$CONFIG_FILE"
fi

exec ${EMULATOR} "$1"
