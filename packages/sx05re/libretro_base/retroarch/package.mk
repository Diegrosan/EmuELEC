################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING. If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston,
#  MA 02110, USA. http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="retroarch"
PKG_VERSION="850cc561968846b08a268421bf904d680724f303"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib openssl freetype zlib retroarch-assets retroarch-overlays core-info ffmpeg libass joyutils empty ${OPENGLES} samba avahi nss-mdns freetype openal-soft espeak libxkbcommon"
PKG_LONGDESC="Reference frontend for the libretro API."
GET_HANDLER_SUPPORT="git"

# ── Patch dirs ────────────────────────────────────────────────────────────────
if [ "${DEVICE}" = "Amlogic-ng" ] || [ "${DEVICE}" = "Amlogic-no" ] || [ "${DEVICE}" = "Amlogic-old" ]; then
  PKG_PATCH_DIRS="${DEVICE}"
fi

if [ "${DEVICE}" = "OdroidGoAdvance" ] || [ "${DEVICE}" = "GameForce" ] || \
   [ "${DEVICE}" = "RK356x" ]          || [ "${DEVICE}" = "OdroidM1" ]; then
  PKG_DEPENDS_TARGET+=" libdrm librga"
  PKG_PATCH_DIRS="OdroidGoAdvance"
fi

# ── Optional dependencies ─────────────────────────────────────────────────────
if [ "${PULSEAUDIO_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" pulseaudio"
fi

# ══════════════════════════════════════════════════════════════════════════════
# KMS branch  →  Amlogic-no only
# ══════════════════════════════════════════════════════════════════════════════
if [ "${DEVICE}" = "Amlogic-no" ]; then

  pre_configure_target() {
    # RetroArch does not like -O3 for CHD loading with cheevos
    export CFLAGS="${CFLAGS} -O3 -fno-tree-vectorize"
    TARGET_CONFIGURE_OPTS=""

    PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                               --enable-alsa \
                               --enable-udev \
                               --disable-opengl1 \
                               --disable-opengl \
                               --disable-opengl_core \
                               --enable-egl \
                               --enable-opengles \
                               --enable-opengles3 \
                               --enable-opengles3_1 \
                               --enable-opengles3_2 \
                               --enable-kms \
                               --disable-mali_fbdev \
                               --disable-wayland \
                               --disable-x11 \
                               --enable-zlib \
                               --enable-freetype \
                               --enable-translate \
                               --enable-cdrom \
                               --enable-command \
                               --enable-ssl \
                               --enable-builtinmbedtls \
                               --disable-discord \
                               --disable-vg \
                               --disable-sdl \
                               --enable-sdl2 \
                               --enable-ffmpeg \
                               --datarootdir=${SYSROOT_PREFIX}/usr/share"

    PKG_MAKE_OPTS_TARGET="V=1 \
      HAVE_ONLINE_UPDATER=1 \
      HAVE_UPDATE_CORES=1 \
      HAVE_UPDATE_CORE_INFO=1 \
      HAVE_COMPRESSION=1 \
      HAVE_ACCESSIBILITY=1 \
      HAVE_UPDATE_ASSETS=1 \
      HAVE_LIBRETRODB=1 \
      HAVE_BLUETOOTH=1 \
      HAVE_NETWORKING=1 \
      HAVE_LAKKA=1 \
      HAVE_LAKKA_PROJECT=\"${DEVICE:-${PROJECT}}.${ARCH}\" \
      HAVE_LAKKA_SERVER=\"www.github.com/EmuELEC\" \
      HAVE_CHEEVOS=1 \
      HAVE_HAVE_ZARCH=0 \
      HAVE_WIFI=0 \
      HAVE_CLOUDSYNC=1 \
      HAVE_SSL=1 \
      HAVE_BUILTINMBEDTLS=1 \
      HAVE_FREETYPE=1 \
      HAVE_ZARCH=1 \
      HAVE_QT=0 \
      HAVE_LANGEXTRA=1 \
      HAVE_OPENGL1=0 \
      HAVE_OPENGL_CORE=0"

    if [ "${VULKAN_SUPPORT}" = yes ]; then
      PKG_DEPENDS_TARGET+=" ${VULKAN}"
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-vulkan"
      PKG_MAKE_OPTS_TARGET+=" HAVE_VULKAN=1"
    else
      PKG_CONFIGURE_OPTS_TARGET+=" --disable-vulkan"
    fi

    if [ "${ARCH}" = "arm" ]; then
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
    fi

    cd ${PKG_BUILD}
  }

  make_target() {
    make ${PKG_MAKE_OPTS_TARGET}
    [ $? -eq 0 ] && echo "(retroarch ok)"     || { echo "(retroarch failed)"     ; exit 1 ; }
    make -C gfx/video_filters compiler=${CC} extra_flags="${CFLAGS}"
    [ $? -eq 0 ] && echo "(video filters ok)" || { echo "(video filters failed)" ; exit 1 ; }
    make -C libretro-common/audio/dsp_filters compiler=${CC} extra_flags="${CFLAGS}"
    [ $? -eq 0 ] && echo "(audio filters ok)" || { echo "(audio filters failed)" ; exit 1 ; }
  }

# ══════════════════════════════════════════════════════════════════════════════
# fbdev branch  →  all other devices (Amlogic-ng, Amlogic-old, OdroidGoAdvance…)
# ══════════════════════════════════════════════════════════════════════════════
else

  pre_configure_target() {
    # RetroArch does not like -O3 for CHD loading with cheevos
    export CFLAGS="${CFLAGS} -O3 -fno-tree-vectorize"
    TARGET_CONFIGURE_OPTS=""

    PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                               --enable-alsa \
                               --enable-udev \
                               --disable-opengl1 \
                               --disable-opengl \
                               --enable-egl \
                               --enable-opengles \
                               --disable-kms \
                               --enable-mali_fbdev \
                               --disable-wayland \
                               --disable-x11 \
                               --enable-zlib \
                               --enable-freetype \
                               --enable-translate \
                               --enable-cdrom \
                               --enable-command \
                               --enable-ssl \
                               --enable-builtinmbedtls \
                               --disable-discord \
                               --disable-vg \
                               --disable-sdl \
                               --enable-sdl2 \
                               --enable-ffmpeg \
                               --datarootdir=${SYSROOT_PREFIX}/usr/share"

    # Devices with their own drm/kms stack (but using fbdev path for RA itself)
    if [ "${DEVICE}" = "OdroidGoAdvance" ] || [ "${DEVICE}" = "GameForce" ] || \
       [ "${DEVICE}" = "RK356x" ]          || [ "${DEVICE}" = "OdroidM1" ]; then
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3 \
                                   --enable-opengles3_2 \
                                   --enable-kms \
                                   --disable-mali_fbdev"
    fi

    PKG_MAKE_OPTS_TARGET="V=1 \
      HAVE_ONLINE_UPDATER=1 \
      HAVE_UPDATE_CORES=1 \
      HAVE_UPDATE_CORE_INFO=1 \
      HAVE_COMPRESSION=1 \
      HAVE_ACCESSIBILITY=1 \
      HAVE_UPDATE_ASSETS=1 \
      HAVE_LIBRETRODB=1 \
      HAVE_BLUETOOTH=1 \
      HAVE_NETWORKING=1 \
      HAVE_LAKKA=1 \
      HAVE_LAKKA_PROJECT=\"${DEVICE:-${PROJECT}}.${ARCH}\" \
      HAVE_LAKKA_SERVER=\"www.github.com/EmuELEC\" \
      HAVE_CHEEVOS=1 \
      HAVE_HAVE_ZARCH=0 \
      HAVE_WIFI=0 \
      HAVE_BLUETOOTH=0 \
      HAVE_CLOUDSYNC=1 \
      HAVE_SSL=1 \
      HAVE_BUILTINMBEDTLS=1 \
      HAVE_FREETYPE=1 \
      HAVE_ZARCH=1 \
      HAVE_QT=0 \
      HAVE_LANGEXTRA=1"

    if [ "${OPENGLES_SUPPORT}" = yes ]; then
      PKG_DEPENDS_TARGET+=" ${OPENGLES}"
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles"
      if [ "${DEVICE:0:4}" = "RPi4" ]  || [ "${DEVICE:0:4}" = "RPi5" ]  || \
         [ "${DEVICE}" = "RK3288" ]     || [ "${DEVICE}" = "RK3399" ]    || \
         [ "${PROJECT}" = "Generic" ]   || [ "${DEVICE}" = "Odin" ]; then
        PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3 \
                                     --enable-opengles3_1"
        if [ "${PROJECT}" = "Generic" ]; then
          PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3_2"
        fi
      fi
    else
      PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengles"
    fi

    if [ "${OPENGL_SUPPORT}" = yes ] && [ ! "${OPENGLES_SUPPORT}" = yes ]; then
      PKG_DEPENDS_TARGET+=" ${OPENGL}"
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengl --disable-opengl_core"
      PKG_MAKE_OPTS_TARGET+=" HAVE_OPENGL1=1 HAVE_OPENGL_CORE=0"
    else
      PKG_CONFIGURE_OPTS_TARGET+=" --disable-opengl --disable-opengl_core"
      PKG_MAKE_OPTS_TARGET+=" HAVE_OPENGL1=0 HAVE_OPENGL_CORE=0"
    fi

    if [ "${VULKAN_SUPPORT}" = yes ]; then
      PKG_DEPENDS_TARGET+=" ${VULKAN}"
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-vulkan"
      PKG_MAKE_OPTS_TARGET+=" HAVE_VULKAN=1"
    else
      PKG_CONFIGURE_OPTS_TARGET+=" --disable-vulkan"
    fi

    if [ "${DEVICE}" = "OdroidGoAdvance" ]; then
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-odroidgo2"
    fi

    if [ "${ARCH}" = "arm" ]; then
      PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
    fi

    cd ${PKG_BUILD}
  }

  make_target() {
    make ${PKG_MAKE_OPTS_TARGET}
    [ $? -eq 0 ] && echo "(retroarch ok)"     || { echo "(retroarch failed)"     ; exit 1 ; }
    make -C gfx/video_filters compiler=${CC} extra_flags="${CFLAGS}"
    [ $? -eq 0 ] && echo "(video filters ok)" || { echo "(video filters failed)" ; exit 1 ; }
    make -C libretro-common/audio/dsp_filters compiler=${CC} extra_flags="${CFLAGS}"
    [ $? -eq 0 ] && echo "(audio filters ok)" || { echo "(audio filters failed)" ; exit 1 ; }
  }

fi

# ══════════════════════════════════════════════════════════════════════════════
# makeinstall_target  →  shared for all devices
# ══════════════════════════════════════════════════════════════════════════════
makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/etc
  cp ${PKG_BUILD}/retroarch     ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/retroarch.cfg ${INSTALL}/etc

  mkdir -p ${INSTALL}/usr/share/video_filters
  cp ${PKG_BUILD}/gfx/video_filters/*.so   ${INSTALL}/usr/share/video_filters
  cp ${PKG_BUILD}/gfx/video_filters/*.filt ${INSTALL}/usr/share/video_filters

  mkdir -p ${INSTALL}/usr/share/audio_filters
  cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.so  ${INSTALL}/usr/share/audio_filters
  cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.dsp ${INSTALL}/usr/share/audio_filters

  # ── General ───────────────────────────────────────────────────────────────
  sed -i "s|# libretro_directory =|libretro_directory = \"/storage/cores\"|"                   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# libretro_info_path =|libretro_info_path = \"/storage/cores\"|"                   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# rgui_browser_directory =|rgui_browser_directory =/storage/roms|"             ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# content_database_path =|content_database_path =/tmp/database/rdb|"           ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# playlist_directory =|playlist_directory =/storage/playlists|"                ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# savefile_directory =|# savefile_directory =/storage/savefiles|"              ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# savestate_directory =|savestate_directory =/storage/roms/savestates|"        ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# system_directory =|system_directory =/storage/roms/bios|"                    ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# screenshot_directory =|screenshot_directory =/storage/roms/screenshots|"     ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# recording_output_directory =|recording_output_directory =/storage/roms/mplayer/retroarch|" ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_shader_dir =|video_shader_dir =/tmp/shaders|"                          ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# rgui_show_start_screen = true|rgui_show_start_screen = false|"               ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# assets_directory =|assets_directory =/tmp/assets|"                           ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# overlay_directory =|overlay_directory =/tmp/overlays|"                       ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# cheat_database_path =|cheat_database_path =/tmp/database/cht|"               ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# menu_driver = \"rgui\"|menu_driver = \"ozone\"|"                             ${INSTALL}/etc/retroarch.cfg

  # ── Quick menu ────────────────────────────────────────────────────────────
  echo "core_assets_directory =/storage/roms/downloads"           >> ${INSTALL}/etc/retroarch.cfg
  echo "quick_menu_show_undo_save_load_state = \"false\""         >> ${INSTALL}/etc/retroarch.cfg
  echo "quick_menu_show_save_core_overrides = \"false\""          >> ${INSTALL}/etc/retroarch.cfg
  echo "quick_menu_show_save_game_overrides = \"false\""          >> ${INSTALL}/etc/retroarch.cfg
  echo "quick_menu_show_cheats = \"true\""                        >> ${INSTALL}/etc/retroarch.cfg

  # ── Video ─────────────────────────────────────────────────────────────────
  sed -i "s|# video_windowed_fullscreen = true|video_windowed_fullscreen = false|"         ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_smooth = true|video_smooth = false|"                                   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_aspect_ratio_auto = false|video_aspect_ratio_auto = true|"             ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_threaded = false|video_threaded = true|"                               ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_font_path =|video_font_path =/usr/share/retroarch-assets/xmb/monochrome/font.ttf|" ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_font_size = 48|video_font_size = 32|"                                  ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_filter_dir =|video_filter_dir =/usr/share/video_filters|"             ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_gpu_screenshot = true|video_gpu_screenshot = false|"                   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# video_fullscreen = false|video_fullscreen = true|"                           ${INSTALL}/etc/retroarch.cfg

  # ── Audio ─────────────────────────────────────────────────────────────────
  sed -i "s|# audio_driver =|audio_driver = \"alsathread\"|"                               ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# audio_filter_dir =|audio_filter_dir =/usr/share/audio_filters|"             ${INSTALL}/etc/retroarch.cfg
  if [ "${PROJECT}" = "OdroidXU3" ]; then   # workaround the 55fps bug
    sed -i "s|# audio_out_rate = 48000|audio_out_rate = 44100|"                            ${INSTALL}/etc/retroarch.cfg
  fi

  # ── Saving ────────────────────────────────────────────────────────────────
  echo "savestate_thumbnail_enable = \"true\""                    >> ${INSTALL}/etc/retroarch.cfg

  # ── Input ─────────────────────────────────────────────────────────────────
  sed -i "s|# input_driver = sdl|input_driver = udev|"                                     ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_max_users = 16|input_max_users = 5|"                                   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_autodetect_enable = true|input_autodetect_enable = true|"              ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# joypad_autoconfig_dir =|joypad_autoconfig_dir = /tmp/joypads|"              ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_remapping_directory =|input_remapping_directory = /storage/.config/retroarch/config/remappings|" ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_menu_toggle_gamepad_combo = 0|input_menu_toggle_gamepad_combo = 2|"   ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# all_users_control_menu = false|all_users_control_menu = true|"               ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# menu_swap_ok_cancel_buttons = false|menu_swap_ok_cancel_buttons = false|"   ${INSTALL}/etc/retroarch.cfg

  # ── Menu ──────────────────────────────────────────────────────────────────
  sed -i "s|# menu_mouse_enable = false|menu_mouse_enable = false|"                        ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# menu_core_enable = true|menu_core_enable = true|"                            ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# thumbnails_directory =|thumbnails_directory = /storage/thumbnails|"         ${INSTALL}/etc/retroarch.cfg
  echo "menu_show_advanced_settings = \"false\""                  >> ${INSTALL}/etc/retroarch.cfg
  echo "menu_wallpaper_opacity = \"1.0\""                         >> ${INSTALL}/etc/retroarch.cfg
  echo "content_show_images = \"false\""                          >> ${INSTALL}/etc/retroarch.cfg
  echo "content_show_music = \"false\""                           >> ${INSTALL}/etc/retroarch.cfg
  echo "content_show_video = \"false\""                           >> ${INSTALL}/etc/retroarch.cfg

  # ── Updater ───────────────────────────────────────────────────────────────
  if [ "${ARCH}" = "arm" ]; then
    sed -i "s|# core_updater_buildbot_url = \"http://buildbot.libretro.com\"|core_updater_buildbot_url = \"http://buildbot.libretro.com/nightly/linux/armhf/latest/\"|" ${INSTALL}/etc/retroarch.cfg
  fi

  # ── Playlists ─────────────────────────────────────────────────────────────
  echo "playlist_names = \"${RA_PLAYLIST_NAMES}\""                >> ${INSTALL}/etc/retroarch.cfg
  echo "playlist_cores = \"${RA_PLAYLIST_CORES}\""                >> ${INSTALL}/etc/retroarch.cfg
  echo "playlist_entry_rename = \"false\""                        >> ${INSTALL}/etc/retroarch.cfg
  echo "playlist_entry_remove = \"false\""                        >> ${INSTALL}/etc/retroarch.cfg

  # ── EmuELEC overrides ─────────────────────────────────────────────────────
  sed -i "s|.*core_updater_buildbot_url =.*|core_updater_buildbot_url = \"http://dontupdatecores\"|" ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_hotkey_block_delay = \"5\"|input_hotkey_block_delay = \"5\"|"         ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# menu_show_core_updater = true|# DONT UPDATE CORES IT WILL BREAK EMUELEC!\nmenu_show_core_updater = false|" ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# menu_show_online_updater = true|menu_show_online_updater = true|"            ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# input_overlay_opacity = 1.0|input_overlay_opacity = 0.15|"                  ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# audio_volume = 0.0|audio_volume = 0.000000|"                                ${INSTALL}/etc/retroarch.cfg
  sed -i "s|# cache_directory =|cache_directory = /tmp/cache|"                            ${INSTALL}/etc/retroarch.cfg
  echo "user_language = \"0\""                                    >> ${INSTALL}/etc/retroarch.cfg
  echo "menu_show_shutdown = \"false\""                           >> ${INSTALL}/etc/retroarch.cfg
  echo "menu_show_reboot = \"false\""                             >> ${INSTALL}/etc/retroarch.cfg
  echo "input_player1_analog_dpad_mode = \"1\""                   >> ${INSTALL}/etc/retroarch.cfg
  echo "input_player2_analog_dpad_mode = \"1\""                   >> ${INSTALL}/etc/retroarch.cfg
  echo "input_player3_analog_dpad_mode = \"1\""                   >> ${INSTALL}/etc/retroarch.cfg
  echo "input_player4_analog_dpad_mode = \"1\""                   >> ${INSTALL}/etc/retroarch.cfg
  echo "savefiles_in_content_dir = \"true\""                      >> ${INSTALL}/etc/retroarch.cfg
  echo "savestates_in_content_dir = \"false\""                    >> ${INSTALL}/etc/retroarch.cfg
  echo "menu_show_restart_retroarch = \"false\""                  >> ${INSTALL}/etc/retroarch.cfg
  echo "menu_show_quit_retroarch = \"true\""                      >> ${INSTALL}/etc/retroarch.cfg

  # ── Small-screen device tweaks (OdroidGoAdvance / GameForce) ─────────────
  if [ "${DEVICE}" = "OdroidGoAdvance" ] || [ "${DEVICE}" = "GameForce" ]; then
    echo "xmb_layout = 2"                    >> ${INSTALL}/etc/retroarch.cfg
    echo "menu_widget_scale_auto = false"    >> ${INSTALL}/etc/retroarch.cfg
    echo "menu_widget_scale_factor = 2.00"  >> ${INSTALL}/etc/retroarch.cfg
    echo "menu_scale_factor = 1.000000"     >> ${INSTALL}/etc/retroarch.cfg
    echo "video_font_size = 12.000000"      >> ${INSTALL}/etc/retroarch.cfg
    echo "menu_rgui_shadows = true"         >> ${INSTALL}/etc/retroarch.cfg
    echo "rgui_aspect_ratio = 6"            >> ${INSTALL}/etc/retroarch.cfg
    echo "rgui_inline_thumbnails = true"    >> ${INSTALL}/etc/retroarch.cfg
    echo "input_max_users = 1"              >> ${INSTALL}/etc/retroarch.cfg
  fi

  mkdir -p ${INSTALL}/usr/config/retroarch/
  mv ${INSTALL}/etc/retroarch.cfg ${INSTALL}/usr/config/retroarch/
}

# ── post_install ──────────────────────────────────────────────────────────────
post_install() {
  enable_service retroarch.service
  enable_service tmp-cores.mount
  enable_service tmp-joypads.mount
  enable_service tmp-database.mount
  enable_service tmp-assets.mount
  enable_service tmp-shaders.mount
  enable_service tmp-overlays.mount
}
