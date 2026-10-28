#!/usr/bin/env bash
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
#cargo build --release
cargo install cargo-deb
cargo deb
#sudo install -Dm755 target/release/xwayland-satellite /usr/bin/xwayland-satellite

#配置  
#nano ~/.config/niri/config.kdl
#spawn-at-startup "xwayland-satellite"

#一键bash脚本
#LINE_INST=$(grep -n ".*spawn-at-startup.*" .config/niri/config.kdl|head -n 1|awk -F : '{print $1}')
#if [ ! "$(cat ~/.config/niri/config.kdl|grep -F spawn-at-startup|grep -F xwayland-satellite)" ]; then
#    sed -i "${LINE_INST}a\spawn-at-startup \"xwayland-satellite\"" ~/.config/niri/config.kdl
#fi