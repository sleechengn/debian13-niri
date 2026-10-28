#!/usr/bin/env bash

set -x

apt update
apt install -y xz-utils aria2 git libgtk-4-dev libgtk4-layer-shell-dev libadwaita-1-dev gettext libxml2-utils blueprint-compiler
git config --global --list | grep -F insteadOf | while IFS='=' read -r name value; do
  git config --global --unset $name
done
curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--ghostty-org--ghostty > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--ghostty-org--ghostty".insteadOf  https://github.com/ghostty-org/ghostty
fi
rm -rf /opt/zig
mkdir -p /opt/zig
cd /opt/zig
aria2c -x 10 -j 10 -k 1M https://ziglang.org/download/0.17.0/zig-x86-linux-0.17.0.tar.xz
xz -d zig-x86-linux-0.17.0.tar.xz
tar -xvf zig-x86-linux-0.17.0.tar
rm -rf zig-x86-linux-0.17.0.tar

PATH=$PATH:/opt/zig/$(ls -A .)

cd /opt
rm -rf ghostty
git clone https://github.com/ghostty-org/ghostty
cd ghostty
git checkout v1.4.0

zig build -Doptimize=ReleaseFast

rm -rf deb-pkg
mkdir -p deb-pkg/DEBIAN
mkdir -p deb-pkg/usr/local
cp -r zig-out/* deb-pkg/usr/local/

#编辑deb-pkg/DEBIAN/control
bash
cat > deb-pkg/DEBIAN/control <<EOF
Package: ghostty
Version: 0.1.0-1
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Your Name <your.email@example.com>
Depends: libc6, libgtk-4-1
Description: Ghostty Terminal Emulator
 Fast, feature-rich, GPU-accelerated terminal emulator written in Zig.
EOF
cat deb-pkg/DEBIAN/control
 
dpkg-deb --build deb-pkg ghostty_0.1.0-1_amd64.deb
#运行依赖：
#apt install libgtk4-layer-shell0
#TERM=xterm-256color