# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present DiegroSan (https://github.com/Diegrosan)
# Copyright (C) 2026-present EmuELEC (https://github.com/EmuELEC/EmuELEC)
# Experimental azahar libretro , but functional

PKG_NAME="azahar_libretro"
PKG_VERSION="03d62efe130faca6fb69abea2b8717abe84ac982"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="https://github.com/azahar-emu/azahar.git"
PKG_DEPENDS_TARGET="toolchain boost zlib vulkan-headers spirv-tools "
PKG_LONGDESC="Azahar 3DS - LibRetro core para RetroArch"
PKG_TOOLCHAIN="cmake"

BUILD_TYPE="Release"

PKG_CMAKE_OPTS_TARGET="\
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_SYSTEM_PROCESSOR=${TARGET_ARCH} \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
  -DENABLE_LIBRETRO=ON \
  -DENABLE_LTO=ON \
  -DENABLE_QT=OFF \
  -DENABLE_SDL2=OFF \
  -DUSE_SYSTEM_SDL2=OFF \
  -DUSE_SYSTEM_GLSLANG=OFF \
  -DENABLE_OPENGL=OFF \
  -DENABLE_VULKAN=ON \
  -DENABLE_CUBEB=OFF \
  -DENABLE_OPENAL=OFF \
  -DENABLE_LIBUSB=OFF \
  -DENABLE_WEB_SERVICE=OFF \
  -DENABLE_SCRIPTING=OFF \
  -DENABLE_TESTS=OFF \
  -DENABLE_ROOM=OFF \
  -DENABLE_ROOM_STANDALONE=OFF \
  -DENABLE_NATIVE_OPTIMIZATION=OFF \
  -DCITRA_USE_PRECOMPILED_HEADERS=OFF \
  -DCITRA_WARNINGS_AS_ERRORS=OFF \
  -DUSE_DISCORD_PRESENCE=OFF \
"

pre_configure_target() {
  export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

  # Fix 1: gamemode logging header
  sed -i 's|#include "common/linux/gamemode.h"|#include "common/logging/log.h"\n#include "common/linux/gamemode.h"|' \
    ${PKG_BUILD}/src/common/linux/gamemode.cpp

  # Fix 2: includes de memória
  for f in \
    "${PKG_BUILD}/src/video_core/shader/shader_jit_a64_compiler.h" \
    "${PKG_BUILD}/src/video_core/shader/shader_jit_a64_compiler.cpp"
  do
    [ -f "$f" ] && sed -i '/#include "video_core\/pica\/shader_setup.h"/a #include <memory>' "$f"
    [ -f "$f" ] && sed -i '/#include "video_core\/shader\/shader_jit_a64_compiler.h"/a #include <memory>' "$f"
  done

  # Fix 3: fix path save libretro
  sed -i 's|target_dir += "Azahar/";|// target_dir += "Azahar/";|' ${PKG_BUILD}/src/citra_libretro/core_settings.cpp

  # Fix 4: std::bit_cast requer <bit> (C++20)
  sed -i '1s|^|#include <bit>\n|' ${PKG_BUILD}/src/video_core/pica/packed_attribute.h
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_DIR}/azahar_libretro.info ${INSTALL}/usr/lib/libretro/
  
  find ${PKG_BUILD}/.${TARGET_NAME}/bin -name "azahar_libretro.so" \
    -exec cp {} ${INSTALL}/usr/lib/libretro/ \;
}
