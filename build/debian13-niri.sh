#!/usr/bin/env bash

apt update
apt install -y pkg-config rustc cargo libwayland-dev libxkbcommon-dev libgbm-dev libinput-dev libudev-dev libpixman-1-dev libglib2.0-dev libsystemd-dev \
	 libseat-dev git libpipewire-0.3-dev libcairo2-dev libpango1.0-dev curl git
apt install -y libpipewire-0.3-0 libpipewire-0.3-dev libdisplay-info2 libseat1 libinput10 libegl1 libegl-mesa0 rustup libdisplay-info-dev

curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--niri-wm--niri > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--niri-wm--niri.git".insteadOf https://github.com/niri-wm/niri.git
fi
if [ -e "niri" ]; then rm -rf niri; fi
git clone https://github.com/niri-wm/niri.git
cd niri
rustup update stable
cargo install cargo-deb
cargo deb
