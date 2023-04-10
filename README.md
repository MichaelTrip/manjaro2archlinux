# manjaro2archlinux
 Convert your manjaro to archlinux

# NO WARRANTY

This scripts comes with absolutely NO WARRANTY.

## Usage
```sh
curl -s https://raw.githubusercontent.com/michaeltrip/manjaro2archlinux/main/manjaro2arch.sh | sudo bash
```

This script originally uses repo mirror provided by Twente Univiersity, which works well in the Netherlands
If you want to use another mirror, please add env `SERVER`:

```sh
curl -s https://raw.githubusercontent.com/michaeltrip/manjaro2archlinux/main/manjaro2arch.sh | sudo env SERVER='https://a-server-address' bash
```

## Steps to migrate succesfully

### Step 1: Create a backup

Create a backup with `clonezilla` for example.

### Step 2: Make sure any gnome extensions are installed locally

Because Manjaro ships with a lot of gnome extensions out of the box, make sure these are installed manually in your homedir (with extension manager for example) instead of Packages. This is because Arch Vanilla doesn't have any gnome extension packages in their repositories.

### Step 3: Make sure to run the `reinstall-packages.sh` script

After running the `manjaro2arch.sh` script from the url, the script will also create another script. This script needs to be run after a reboot. The script will be placed in the $HOME of the `root` user.

### Step 4: Take a cup of coffee

By force reinstalling all packages, we make sure there are no traces of Manjaro. So take a cup of coffee and wait for the process to finish.

### Step 5: Update your GRUB config

Update your grub-config:

```bash
grub-install
grub-mkconfig -O /boot/grub/grub.cfg

```

### Step 6: Reboot

Reboot and test everything. 