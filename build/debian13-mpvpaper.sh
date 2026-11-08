#!/usr/bin/env bash
set -x
apt update
apt install -y git checkinstall build-essential meson ninja-build \
    pkg-config libmpv-dev libwayland-dev wayland-protocols mpv
cd /opt
git config --global --list | grep -F insteadOf | while IFS='=' read -r name value; do
git config --global --unset $name
done
curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--GhostNaN--mpvpaper > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--GhostNaN--mpvpaper".insteadOf https://github.com/GhostNaN/mpvpaper
fi
rm -rf mpvpaper
git clone --single-branch --depth=1 https://github.com/GhostNaN/mpvpaper
# Build
cd mpvpaper
meson setup build --prefix=/usr/local
ninja -C build
# Install
#checkinstall  \
#  --type=debian \
#  --pkgname=mpvpaper \
#  --pkgversion=1.0 \
#  --default \
#  --install=no \
#    ninja -C build install
rm -rf /tmp/mpvpaper-pkg
DESTDIR=/tmp/mpvpaper-pkg ninja -C build install

mkdir -p /tmp/mpvpaper-pkg/DEBIAN
cat > /tmp/mpvpaper-pkg/DEBIAN/control <<EOF
Package: mpvpaper
Version: 1.0
Architecture: $(dpkg --print-architecture)
Maintainer: Local Builder
Description: Wallpaper video player for Wayland
EOF
mkdir arch-build-deb
dpkg-deb --build \
  /tmp/mpvpaper-pkg \
  "/opt/mpvpaper/arch-build-deb/mpvpaper_1.0_$(dpkg --print-architecture).deb"
#配置
#mpvpaper -o "no-audio --loop" ALL /home/你的用户名/Videos/live.mp4
