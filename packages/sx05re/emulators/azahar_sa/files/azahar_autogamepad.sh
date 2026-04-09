#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present DiegroSan https://github.com/Diegrosan
# Azahar port KMS+sdl2 BY DiegroSan🤠️

# Formato: "index:guid:name"

CONTROLLER="$1" # or CONTROLLER="0:030081b85e0400008e02000010010000:xbox 360 wireless"

INDEX=$(echo "$CONTROLLER" | cut -d: -f1)
GUID=$(echo  "$CONTROLLER" | cut -d: -f2)
NAME=$(echo  "$CONTROLLER" | cut -d: -f3-)

CONFIG_DIR="/storage/.config/azahar-emu"
CONFIG_FILE="${CONFIG_DIR}/sdl2-config.ini"

mkdir -p "$CONFIG_DIR"

[ -f "$CONFIG_FILE" ] || printf "[Controls]\n\n" > "$CONFIG_FILE"

# --- Detect control type by name/GUID ---
VENDOR=$(echo "$GUID" | cut -c9-12)   # bytes 5-6 do GUID = vendor LE
NAME_LOW=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')

CTRL_TYPE=""
case "$VENDOR" in
    5e04) CTRL_TYPE="xbox" ;;
    4c05) CTRL_TYPE="ps"   ;;
esac
case "$NAME_LOW" in
    *xbox*|*"x-box"*|*360*)                                            CTRL_TYPE="xbox" ;;
    *playstation*|*dualshock*|*dualsense*|*ps3*|*ps4*|*ps5*|*sony*)   CTRL_TYPE="ps"   ;;
    *snes*|*nes*|*retro*|*famicom*|*"8bitdo zero"*)                    CTRL_TYPE="snes" ;;
esac
[ -z "$CTRL_TYPE" ] && CTRL_TYPE="generic_6ax"

# --- Assemble mapping ---
G="engine:sdl,guid:${GUID},port:${INDEX}"

case "$CTRL_TYPE" in
    xbox)
        BTN_A="${G},button:0";  BTN_B="${G},button:1"
        BTN_X="${G},button:2";  BTN_Y="${G},button:3"
        BTN_L="${G},button:4";  BTN_R="${G},button:5"
        BTN_ZL="${G},axis:2,direction:+,threshold:0.5"
        BTN_ZR="${G},axis:5,direction:+,threshold:0.5"
        BTN_SELECT="${G},button:6"; BTN_START="${G},button:7"
        CIRCLE_PAD="${G},axis:0,axis:1"; C_STICK="${G},axis:3,axis:4"
        ;;
    ps)
        BTN_A="${G},button:1";  BTN_B="${G},button:0"
        BTN_X="${G},button:3";  BTN_Y="${G},button:2"
        BTN_L="${G},button:4";  BTN_R="${G},button:5"
        BTN_ZL="${G},button:6"; BTN_ZR="${G},button:7"
        BTN_SELECT="${G},button:8"; BTN_START="${G},button:9"
        CIRCLE_PAD="${G},axis:0,axis:1"; C_STICK="${G},axis:2,axis:3"
        ;;
    snes)
        BTN_A="${G},button:4";  BTN_B="${G},button:0"
        BTN_X="${G},button:5";  BTN_Y="${G},button:1"
        BTN_L="${G},button:6";  BTN_R="${G},button:7"
        BTN_ZL=""; BTN_ZR=""
        BTN_SELECT="${G},button:2"; BTN_START="${G},button:3"
        CIRCLE_PAD="${G},axis:0,axis:1"; C_STICK=""
        ;;
    *)  # generic_6ax and others with analog triggers
        BTN_A="${G},button:1";  BTN_B="${G},button:0"
        BTN_X="${G},button:3";  BTN_Y="${G},button:2"
        BTN_L="${G},button:4";  BTN_R="${G},button:5"
        BTN_ZL="${G},axis:2,direction:+,threshold:0.5"
        BTN_ZR="${G},axis:5,direction:+,threshold:0.5"
        BTN_SELECT="${G},button:6"; BTN_START="${G},button:7"
        CIRCLE_PAD="${G},axis:0,axis:1"; C_STICK="${G},axis:3,axis:4"
        ;;
esac


cp "$CONFIG_FILE" "${CONFIG_FILE}.bak" 2>/dev/null || true

TMPFILE=$(mktemp /tmp/azahar_cfg.XXXXXX)
awk '
    /^\[Controls\]$/  { skip=1; next }
    skip && /^\[/     { skip=0 }
    !skip             { print }
' "$CONFIG_FILE" > "$TMPFILE" 2>/dev/null

{
printf "[Controls]
button_a=%s
button_b=%s
button_x=%s
button_y=%s
button_up=%s,hat:0,direction:up
button_down=%s,hat:0,direction:down
button_left=%s,hat:0,direction:left
button_right=%s,hat:0,direction:right
button_l=%s
button_r=%s
button_zl=%s
button_zr=%s
button_start=%s
button_select=%s
circle_pad=%s
c_stick=%s
motion_device=
touch_device=engine:emu_window

" \
"$BTN_A" "$BTN_B" "$BTN_X" "$BTN_Y" \
"$G" "$G" "$G" "$G" \
"$BTN_L" "$BTN_R" "$BTN_ZL" "$BTN_ZR" \
"$BTN_START" "$BTN_SELECT" "$CIRCLE_PAD" "$C_STICK"
cat "$TMPFILE"
} > "$CONFIG_FILE"

rm -f "$TMPFILE"

echo "✔ Control: $NAME [$CTRL_TYPE] (port:$INDEX)"
echo "  GUID: $GUID"

