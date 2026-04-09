# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2025 SIMPLYPLAY

PKG_NAME="SDL2"
PKG_VERSION="2.32.10"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd libdrm ${OPENGLES} ${VULKAN} "
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_DEPENDS_HOST="toolchain:host "
PKG_TOOLCHAIN="cmake"

# KMSDRM, GLES e Vulkan
PKG_CMAKE_OPTS_TARGET="-DSDL_KMSDRM=ON \
                       -DSDL_OPENGLES=ON \
                       -DSDL_VULKAN=ON \
                       -DSDL_OPENGL=OFF \
                       -DSDL_ALSA=ON \
                       -DSDL_ALSA_SHARED=ON \
                       -DSDL_ARMSIMD=ON \
                       -DSDL_PIPEWIRE=OFF \
                       -DSDL_PULSEAUDIO=ON \
                       -DSDL_JACK=OFF \
                       -DSDL_ARTS=OFF \
                       -DSDL_ESD=OFF \
                       -DSDL_NAS=OFF \
                       -DSDL_SNDIO=OFF \
                       -DSDL_X11=OFF \
                       -DSDL_WAYLAND=OFF \
                       -DSDL_RPI=OFF \
                       -DSDL_VIVANTE=OFF \
                       -DSDL_DIRECTFB=OFF \
                       -DSDL_DUMMYVIDEO=OFF \
                       -DSDL_DUMMYAUDIO=OFF \
                       -DSDL_DISKAUDIO=OFF \
                       -DSDL_HIDAPI=OFF"



post_makeinstall_target() {
  # Ajusta os caminhos no sdl2-config para apontar para o sysroot do CoreELEC
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/sdl2-config
  # Remove binários desnecessários da instalação final
  rm -rf ${INSTALL}/usr/bin
  rm -rf ${INSTALL}/usr/lib/*.a
  rm -rf ${INSTALL}/usr/lib/cmake
  rm -rf ${INSTALL}/usr/lib/pkgconfig
}
