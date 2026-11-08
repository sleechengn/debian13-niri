#!/usr/bin/env bash
set -x
apt update
apt install curl git libxkbcommon-dev liblz4-dev pkg-config wayland-protocols -y
apt remove rustc cargo -y
apt autoremove -y
cd /opt
git config --global --list | grep -F insteadOf | while IFS='=' read -r name value; do
  git config --global --unset $name
done
curl -fsSL http://192.168.13.80:3000/sleechengn/github.com--LGFae--swww > /dev/null 2>&1
if [ $? -eq 0 ]; then
	git config --global url."http://192.168.13.80:3000/sleechengn/github.com--LGFae--swww".insteadOf https://github.com/LGFae/swww
fi
if [ -e "swww" ]; then
    rm -rf swww
fi
git clone https://github.com/LGFae/swww
cd swww
if [ ! -e "$HOME/.cargo/env" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
source "$HOME/.cargo/env"
cargo install cargo-deb
cargo deb -p swww
cargo deb -p swww-daemon
#cargo deb -p common
#cargo deb -p tests
#再编译然后
#cp target/release/swww target/release/swww-daemon /usr/local/bin/