#!/bin/bash
if [ `id -u` -eq 0 ];then
  echo "Welcome to Arch Linux"
else
  echo "Please run with root permission"
  exit 1
fi
mv /etc/pacman.conf /etc/pacman.conf.bak
mv /etc/manjaro-release /etc/manjaro-release.bak
mv /etc/pacman-mirrors.conf /etc/pacman-mirrors.conf.bak
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
cat <<EOF >/etc/pacman.conf
[options]
SigLevel = Never
LocalFileSigLevel = Optional
HoldPkg = pacman glibc
SyncFirst = pacman
Architecture = auto
Color
CheckSpace
[core]
Include = /etc/pacman.d/mirrorlist
[extra]
Include = /etc/pacman.d/mirrorlist
[community]
Include = /etc/pacman.d/mirrorlist
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
[ -z "$SERVER" ] && SERVER='http://ftp.snt.utwente.nl/pub/os/linux/archlinux/$repo/os/$arch'
cat <<EOF >/etc/pacman.d/mirrorlist
Server = $SERVER
EOF
pacman -R --noconfirm bmenu pacui pacman-contrib
pacman -Syyuu --noconfirm filesystem pacman bash linux breeze-grub breeze-gtk lsb-release systemd # Force reinstall
pacman -Rdd   --noconfirm $(pacman -Qq | grep -E 'manjaro|breath')
cp /usr/share/grub/themes/breeze /boot/grub/themes/
sed -i 's/^GRUB_THEME.*$/GRUB_THEME="/boot/grub/themes/breeze/theme.txt"/g' /etc/default/grub && grub-mkconfig -o /boot/grub/grub.cfg
exit 0
