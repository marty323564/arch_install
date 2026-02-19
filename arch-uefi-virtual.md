---
#### Arch Linux - UEFI on Virtual Machine
---
```
# povoluje nebo zakazuje synchronizaci síťového času (NTP) v systémech Linux založených na systemd
timedatectl set-ntp true
```
```
# pro potřeby instalace - není nutné
# výběr fontu s podporou národního prostředí - 'setfont'
setfont Lat2-Terminus16
```
```
# pro potřeby instalace - není nutné
# localectl list-locales | grep ^cs
# localectl list-keymaps | grep ^cz
# české rozložení klávesnice
localectl set-keymap cz-qwertz
```
```
# přehled disků
lsblk

# v případě virtuálního stroje je to zpravidla 'vda1'
# tento postup tedy pracuje s diskem 'vda' a swapování je zvoleno do souboru
fdisk /dev/vda

1. oddíl = +300M typ 'uefi'
2. oddíl = zbytek diskového prostoru - typ 'linux'
```
```
# formátování oddílů
# formátování boot oddílu (souborový formát 'fat')
mkfs.fat -F32 /dev/vda1

# formátování root oddílu (souborový formát 'ext4')
mkfs -t ext4 /dev/vda2
```
```
# připojování diskových oddílů

mount /dev/vda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi
```
```
# instalace základních balíčků
# zde osobně dávám jen to nejnutnější k chodu systému a zbytek dle okolností
pacstrap /mnt base linux linux-firmware nano
```
```
# generování tabulky diskových oddílů:
genfstab -U /mnt >> /mnt/etc/fstab
```
```
# chroot
arch-chroot /mnt
```
```
# tvorba swapovacího souboru - swapfile
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile

# vytvořený swapovací soubor je potřeba zahrnout do tabulky diskových oddílů
nano /etc/fstab

# swapfile
/swapfile none  swap  defaults  0 0
```
```
# nastavení časové zóny - Česká republika, symbolický link:
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime
```
```
# generování 'locales'
nano /etc/locale.gen
# odkomentovat řádek:
cs_CZ.UTF-8

# spustit generování 'locales'
locale-gen
```
```
# uložení nastavení národního prostředí do souboru '/etc/locale.conf'
nano /etc/locale.conf
# lokální nastavení
LANG=cs_CZ.UTF-8

# nastavení rozložení klávesnice a fontu pro obrazovku terminálu
nano /etc/vconsole.conf

# zadat požadované hodnoty (zde záleží na osobních potřebách a preferencích)
KEYMAP=cz-qwertz
FONT=Lat2-Terminus16
```
```
# synchronizace hardware hodin
hwclock --systohc
```
```
# nastavení jména počítače (hostname)
nano /etc/hostname
# do prázdného souboru uvést požadovaný název
archlinux
```
```
# nastavení hodnot v souboru /etc/hosts
nano /etc/hosts

# dle potřeb - zde příklad
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain	archlinux
```
```
# nastavení 'root' hesla
passwd
```
```
# instalace základních balíčků (opět podle aktuálních potřeb a preferencí)
pacman -S grub efibootmgr networkmanager sudo git base-devel linux-headers reflector man-db man-pages openssh

# grub                   
# efibootmgr 
# networkmanager
# sudo
# git
# iw
# os-prober
# base-devel
# linux-headers
# reflector
# man-db
# man-pages
# openssh
```
```
# instalace zavaděče systému - GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# vytvožení konfiguračního souboru pro zavaděč GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```
```
# nastavení základních služeb v systemd
systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable sshd
```
```
# bezpečnostní aktualizace pro procesor
pacman -S intel-ucode
# znovu vygenerovat
grub-mkconfig -o /boot/grub/grub.cfg
```
```
# vytvožení uživatelského účtu a hesla
useradd -m -G wheel -s /bin/bash martin
passwd martin
```
```
# add user to sudoers
EDITOR=nano visudo

# Uncomment
%wheel ALL=(ALL) ALL
```
```
# exit, unmount and reboot system
exit
umount -R /mnt
reboot
```
```
# nastavení zrcadel
sudo reflector --country Czechia --age 12 --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist
```
