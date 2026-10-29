#!/usr/bin/env bash

set -x

apt update
apt install -y xz-utils aria2 git libgtk-4-dev \
    libgtk4-layer-shell-dev libadwaita-1-dev gettext \
    libxml2-utils blueprint-compiler build-essential \
    libc6-dev libx11-dev
git config --global --list | grep -F insteadOf | while IFS='=' read -r name value; do
git config --global --unset $name
done
curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--ghostty-org--ghostty > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--ghostty-org--ghostty".insteadOf https://github.com/ghostty-org/ghostty
fi
if [ "$(ls -A /opt/zig)" ]; then
    PATH=$PATH:/opt/zig/$(ls -A /opt/zig)
else
    rm -rf /opt/zig
    mkdir -p /opt/zig
    cd /opt/zig
    aria2c -x 10 -j 10 -k 1M https://ziglang.org/download/0.17.0/zig-x86_64-linux-0.17.0.tar.xz
    xz -d zig-x86_64-linux-0.17.0.tar.xz
    tar -xvf zig-x86_64-linux-0.17.0.tar
    rm -rf zig-x86_64-linux-0.17.0.tar
    PATH=$PATH:/opt/zig/$(ls -A .)
fi
cd /opt
if [ ! -e "ghostty" ]; then
    git clone https://github.com/ghostty-org/ghostty
fi
cd ghostty
#git checkout v1.4.0
git checkout tip

rm -rf /root/.cache/zig
rm -rf zig-out
#zig fetch "https://deps.files.ghostty.org/vaxis-6fd944a27fb3d6f596e981076381a3131f2448b4.tar.gz"
#zig fetch "https://deps.files.ghostty.org/z2d-40af3e84a4e15a9f31d126b3f281f23ce6a3dae5.tar.gz"
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux-gnu
#zig build -Doptimize=ReleaseFast  

rm -rf deb-pkg
mkdir -p deb-pkg/DEBIAN
mkdir -p deb-pkg/usr/local
cp -r zig-out/* deb-pkg/usr/local/

#编辑deb-pkg/DEBIAN/control
#bash
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
 
dpkg-deb --build deb-pkg ghostty_1.4.0_amd64.deb
#运行依赖：
#apt install libgtk4-layer-shell0
#TERM=xterm-256color