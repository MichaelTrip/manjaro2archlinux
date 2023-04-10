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
pacman -Syyuu --noconfirm filesystem pacman bash linux breeze-grub breeze-gtk lsb-release systemd # Force reinstall
pacman -Rdd   --noconfirm $(pacman -Qq | grep -E 'manjaro|breath')
cp /usr/share/grub/themes/breeze /boot/grub/themes/
sed -i 's/^GRUB_THEME.*$/GRUB_THEME="/boot/grub/themes/breeze/theme.txt"/g' /etc/default/grub && grub-mkconfig -o /boot/grub/grub.cfg

cat <<EOF >~/reinstall-packages.sh

#!/bin/bash

if [ `id -u` -eq 0 ];then
  echo "Reinstalling all packages"
else
  echo "Please run with root permission"
  exit 1
fi

# Create a list of explicitly installed packages
pacman -Qeq > package-list.txt

# Create a list of all installed packages, including dependencies
pacman -Qeq | sed 's/\(^.*\)/\1 \1/g' | xargs pacman -Qq | sort -u > all-package-list.txt

# Create a list of packages that are not dependencies
comm -13 <(pacman -Qtdq | sort) <(pacman -Qqg base base-devel linux linux-firmware | sort -u) > non-dependency-list.txt

# Combine the lists of explicitly installed packages and non-dependency packages
cat package-list.txt non-dependency-list.txt | sort -u > reinstall-list.txt

# Reinstall all packages from the combined list
spacman -S --force --noconfirm - < reinstall-list.txt
EOF
chmod +x ~/reinstall-packages.sh

echo "Reboot, after that. run the reinstall-packages.sh script with sudo located in your home directory"

exit 0
