#!/usr/bin/env bash
set -x
apt update
apt install -y cargo xwayland build-essential libxcb1-dev libxcb-cursor-dev libxcb-composite0-dev
git config --global --list | grep -F insteadOf | while IFS='=' read -r name value; do
  git config --global --unset $name
done
curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--Supreeeme--xwayland-satellite > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--Supreeeme--xwayland-satellite.git".insteadOf https://github.com/Supreeeme/xwayland-satellite.git
fi
cd /opt
rm -rf xwayland-satellite
git clone https://github.com/Supreeeme/xwayland-satellite.git
cd xwayland-satellite
cargo install cargo-deb
cargo deb