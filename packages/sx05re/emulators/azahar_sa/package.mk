#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present DiegroSan (https://github.com/Diegrosan)
# Copyright (C) 2026-present EmuELEC (https://github.com/EmuELEC/EmuELEC)
#

PKG_NAME="azahar_sa"
PKG_VERSION="b9e75554390d6b66d419146860f5bc2bf9052034"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Diegrosan/azahar"
PKG_URL="https://github.com/Diegrosan/azahar.git"
PKG_DEPENDS_TARGET="toolchain boost zlib vulkan-headers SDL2 "
PKG_LONGDESC="Azahar 3DS - LibRetro core para RetroArch"
PKG_TOOLCHAIN="cmake"

BUILD_TYPE="Release"

PKG_CMAKE_OPTS_TARGET="\
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_SYSTEM_PROCESSOR=${TARGET_ARCH} \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
  -DENABLE_LIBRETRO=OFF \
  -DENABLE_LTO=ON \
  -DENABLE_QT=OFF \
  -DENABLE_SDL2=ON \
  -DENABLE_SDL2_FRONTEND=ON \
  -DUSE_SYSTEM_SDL2=ON \
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
  sed -i 's/std::bit_cast<f32>(\(.*\))/([](auto v){ f32 r; std::memcpy(\&r, \&v, sizeof(f32)); return r; }(\1))/g' \
    ${PKG_BUILD}/src/video_core/pica/packed_attribute.h
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/
  
 cp ${PKG_DIR}/files/azahar.sh ${INSTALL}/usr/bin/azahar.sh
 cp ${PKG_DIR}/files/azahar_autogamepad.sh ${INSTALL}/usr/bin/azahar_autogamepad.sh
  
  find ${PKG_BUILD}/.${TARGET_NAME}/bin -type f -executable \
    -exec cp {} ${INSTALL}/usr/bin/ \;
}
