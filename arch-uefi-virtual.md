# Arch Linux - UEFI on Virtual Machine

### pro potřeby instalace - není nutné
# setfont - nastavení písma
setfont Lat2-Terminus16

### pro potřeby instalace - není nutné
## keymap - české rozložení klávesnice
keymap cz-qwertz

# přehled disků - kam se bude arch linux instalovat
lsblk

# v případě virtuálního stroje je to u mne zpravidla 'vda'
# tento postup tedy pracuje s diskem 'vda' a swapování je zvoleno do souboru

fdisk /dev/vda
1. oddíl = +300M typ 'uefi' (v fdisku jako synonymum - alias) bude 'vda1'
2. oddíl = zbytek diskového prostoru - typ je implicitně 'linux' bude 'vda2'


# formátování oddílů
# pro UEFI se používá 'fat' formát
mkfs.fat -F32 /dev/vda1

# běžný linuxový oddíl - ext4
mkfs -t ext4 /dev/vda2

# mounting
mount /dev/vda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi


# install base packages
pacstrap /mnt pacstrap /mnt base linux linux-firmware nano

# generate file system table
genfstab -U /mnt >> /mnt/etc/fstab

# chroot
arch-chroot /mnt

# swapfile
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile

# edit `fstab` --- > 
nano /etc/fstab

# swapfile
/swapfile none  swap  defaults  0 0

# timezone
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localetime

# synchronize hardware-clock
hwclock --systohc

# edit locale.gen:
nano /etc/locale.gen

# Uncomment, save and exit
cs_CZ.UTF-8

# Generate the locale
locale-gen

# edit file:
nano /etc/locale.conf

# insert, save and exit
LANG=cs_CZ.UTF-8

# set keyboard layout
nano /etc/vconsole.conf
KEYMAP=cz-qwertz
FONT=Lat2-Terminus16

# set hostname - edit file:
nano /etc/hostname
archlinux

# set hosts - edit file:
nano /etc/hosts
# Set hosts, save and exit
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain	archlinux

# set root password
passwd

# install remaining base packages
pacman -S grub efibootmgr networkmanager sudo git iw wpa_supplicant os-prober \
base-devel linux-headers reflector man-db man-pages

# install grub-bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Create grub bootloader config
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable reflector.timer

pacman -S intel-ucode

# create user
useradd -m -G wheel -s /bin/bash martin
passwd martin

# add user to sudoers
EDITOR=nano visudo

# Uncomment
%wheel ALL=(ALL) ALL

# exit, unmount and reboot system
exit
umount -R /mnt
reboot

# ssh
sudo pacman -S openssh
sudo systemctl enable --now sshd
sudo systemctl status sshd

# reflector
sudo reflector --country Czechia --age 12 --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist
