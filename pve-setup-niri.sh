#!/usr/bin/env bash

set -x

if [ $EUID -eq 0 ]; then

USERNAME="sa"
PASSWORD="12345678"

PACK_PATH=$(realpath $(dirname $0))

apt install -y $PACK_PATH/niri_26.4.0-1_amd64.deb
apt install -y $PACK_PATH/mpvpaper_20260812-1_amd64.deb
apt install -y $PACK_PATH/swww_0.11.2~master2-1_amd64.deb
apt install -y $PACK_PATH/swww-daemon_0.11.2~master2-1_amd64.deb
apt install -y $PACK_PATH/xwayland-satellite_0.8.2-1_amd64.deb
apt install -y $PACK_PATH/ghostty_0.1.0-1_amd64.deb

apt install -y alacritty fuzzel swaybg waybar pcmanfm-qt xwayland
apt install -y libpipewire-0.3-0 libpipewire-0.3-dev libdisplay-info2 libseat1 libinput10 libegl1 libegl-mesa0
apt install -y pavucontrol pipewire pipewire-pulse wireplumber libgtk4-layer-shell0
apt install -y libadwaita-1-0
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
flatpak install --noninteractive -y com.microsoft.Edge

apt install -y fonts-noto-cjk-extra
apt install -y fcitx5 fcitx5-table-wubi98

# user
if ! id "$USERNAME" > /dev/null 2>&1; then
	useradd -m --uid 100000 $USERNAME
	usermod -aG input,video $USERNAME
	home=$(eval echo "~$USERNAME")
	echo "$USERNAME:$PASSWORD" | chpasswd
	find /usr/lib/|grep -F /getty@|xargs -i sed -i "s,^ExecStart.*,ExecStart=-/sbin/agetty --noclear %I $TERM --autologin $USERNAME,g" {}
	systemctl daemon-reload
	systemctl disable getty@tty1.service
	systemctl enable getty@tty1.service
	mkdir -p $home/.config/niri
	cp $PACK_PATH/default-config.kdl $home/.config/niri/config.kdl
	chown -R $USERNAME $home/.config
fi

systemctl --user -M $USERNAME@ daemon-reload
systemctl --user -M $USERNAME@ enable --now pipewire pipewire-pulse wireplumber
su $USERNAME -c "gsettings set org.gnome.desktop.interface color-scheme prefer-dark"

echo
echo ----------------------
echo "your username: $USERNAME"
echo "your password: $PASSWORD"
echo
echo "please reboot,login $USERNAME, run \"niri-session\""
else
echo "root need"
fi