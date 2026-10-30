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

apt install -y sudo bluez blueman pipewire-audio libspa-0.2-bluetooth xdg-desktop-portal xdg-desktop-portal-gtk
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

if ! getent group $USERNAME > /dev/null 2>&1; then
        groupadd --gid 100000 $USERNAME
else
        if [ ! $(getent group $USERNAME|cut -d: -f3) -eq 100000 ]; then
                groupmod --gid 100000 $USERNAME
        fi
fi

if ! id -u $USERNAME > /dev/null 2>&1; then
        useradd -m --uid 100000 -g $USERNAME $USERNAME
else
        if [ ! $(id -g $USERNAME) -eq 100000 ]; then
                #usermod --gid 100000 $USERNAME
                PREFIX=$(grep -o "^$USERNAME:[^:]\\+:[0-9]\\+" /etc/passwd)
                USER_F1=$(echo "$PREFIX"|awk '{print $1}')
                USER_F2=$(echo "$PREFIX"|awk '{print $2}')
                sed -i "s/^$USERNAME:[^:]\\+:[0-9]\\+/$USER_F1:$USER_F2:100000/g" /etc/passwd
                chown -R 100000:100000 /home/$USERNAME
        fi
fi
usermod -aG input,video $USERNAME
home=$(eval echo "~$USERNAME")
echo "$USERNAME:$PASSWORD" | chpasswd
find /usr/lib/|grep -F /getty@|xargs -i sed -i "s,^ExecStart.*,ExecStart=-/sbin/agetty --noclear %I $TERM --autologin $USERNAME,g" {}
systemctl daemon-reload
systemctl disable getty@tty1.service
systemctl enable getty@tty1.service
mkdir -p $home/.config/niri
if [ ! -e "$home/.config/niri/config.kdl" ]; then
	cp $PACK_PATH/default-config.kdl $home/.config/niri/config.kdl
fi
chown -R $USERNAME:$USERNAME $home/.config
if ! grep -E -e "^$USERNAME[[:blank:]]+ALL\\=\\(ALL\\:ALL\\)[[:blank:]]+NOPASSWD:ALL.*" /etc/sudoers > /dev/null; then
        sed -i "/^root[[:blank:]]\\+ALL=(ALL:ALL)[[:blank:]]\\+.*/a $USERNAME   ALL=(ALL:ALL)   NOPASSWD:ALL" /etc/sudoers
fi
systemctl --user -M $USERNAME@ daemon-reload
systemctl --user -M $USERNAME@ enable --now pipewire pipewire-pulse wireplumber
systemctl --user -M $USERNAME@ start pipewire pipewire-pulse wireplumber
su $USERNAME -c "gsettings set org.gnome.desktop.interface color-scheme prefer-dark"

systemctl --user -M $USERNAME@ enable --now xdg-desktop-portal xdg-desktop-portal-gtk
systemctl --user -M $USERNAME@ start xdg-desktop-portal xdg-desktop-portal-gtk

mkdir -p $home/.config/xdg-desktop-portal
cat > $home/.config/xdg-desktop-portal/niri-portals.conf <<EOF
[preferred]
default=gtk;
org.freedesktop.impl.portal.FileChooser=gtk;
org.freedesktop.impl.portal.OpenURI=gtk;
EOF
chown -R $USERNAME:$USERNAME $home/.config

echo
echo ----------------------
echo "your username: $USERNAME"
echo "your password: $PASSWORD"
echo
echo "please reboot,login $USERNAME, run \"niri-session\""
else
echo "root need"
fi