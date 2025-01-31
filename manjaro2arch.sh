#!/bin/bash
if [ `id -u` -eq 0 ];then
  echo "Welcome to Arch Linux"
else
  echo "Please run with root permission"
  exit 1
fi


echo "##################################################################"
echo "# Welcome to the Manjaro to Arch conversion script. This script  #"
echo "# will convert any Manjaro to a Archlinux installation.           #"
echo "# Be sure to read the README.md and create a backup!              #"
echo "##################################################################"

echo -e "\033[31;5mDo you Whish to proceed? This script comes with absolutely NO WARRANTY\033[0m"

read -p "Do you want to proceed? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac

mv /etc/pacman.conf /etc/pacman.conf.bak
mv /etc/manjaro-release /etc/manjaro-release.bak
mv /etc/pacman-mirrors.conf /etc/pacman-mirrors.conf.bak
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
cat <<EOF >/etc/pacman.conf
[options]
SigLevel = Never
LocalFileSigLevel = Optional
HoldPkg = pacman glibc
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
pacman -Syyuu --noconfirm filesystem pacman systemd # Force reinstall
pacman -Rdd   --noconfirm $(pacman -Qq | grep -E 'manjaro|breath')
pacman -Rdd --noconfirm libpamac libpamac-flatpak-plugin pamac-cli pamac-gnome-integration pamac-gtk gnome-layout-switcher
pacman -Syyuu --noconfirm lsb-release bash # Force reinstall
pacman -S --noconfirm --overwrite "*" linux #force reinstall of kernel
pacman -S --noconfirm breeze-grub breeze-gtk  # reinstrall themes
cp -R /usr/share/grub/themes/breeze /boot/grub/themes/
sed -i 's|^GRUB_THEME.*$|GRUB_THEME="/boot/grub/themes/breeze/theme.txt"|g' /etc/default/grub && sed -i 's|^GRUB_DISTRIBUTOR.*$||g' /etc/default/grub && grub-mkconfig -o /boot/grub/grub.cfg

cat <<"EOF" >~/reinstall-packages.sh
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
    pacman -S --noconfirm --overwrite='*' $package
done
EOF

chmod +x ~/reinstall-packages.sh

echo "Reboot please! After that. run the reinstall-packages.sh script located in the home directory of the root user (/root)"

exit 0
