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
pacman -R --noconfirm bmenu pacui
pacman -Sc --noconfirm
pacman -Syyuu --noconfirm filesystem pacman breeze-grub breeze-gtk systemd # Force reinstall
pacman -Rdd   --noconfirm $(pacman -Qq | grep -E 'manjaro|breath')
pacman -Syyuu --noconfirm lsb-release bash # Force reinstall
pacman -S --noconfirm --overwrite "*" linux #force reinstall of kernel
cp /usr/share/grub/themes/breeze /boot/grub/themes/
sed -i 's|^GRUB_THEME.*$|GRUB_THEME="/boot/grub/themes/breeze/theme.txt"|g' /etc/default/grub && grub-mkconfig -o /boot/grub/grub.cfg

cat <<EOF >~/reinstall-packages.sh

#!/bin/bash

if [ `id -u` -eq 0 ];then
  echo "Reinstalling all packages"
else
  echo "Please run with root permission"
  exit 1
fi

# Get list of installed packages (excluding AUR packages)
packages=$(pacman -Qqn)

# Reinstall all packages and overwrite existing configuration files
for package in $packages; do
    pacman -S --needed --overwrite='*' $package
done
EOF
chmod +x ~/reinstall-packages.sh

echo "Reboot please! After that. run the reinstall-packages.sh script located in the home directory of the root user (/root)"

exit 0
