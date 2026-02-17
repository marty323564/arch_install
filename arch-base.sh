#!/bin/bash

# Arch Linux instalace base

ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime

hwclock --systohc

sed -i 's/^#cs_CZ.UTF-8 UTF-8/cs_CZ.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

echo "LANG=cs_CZ.UTF-8" >> /etc/locale.conf

echo "KEYMAP=cz-qwertz" >> /etc/vconsole.conf

echo "arch" >> /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts

echo "::1       localhost" >> /etc/hosts

echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts

password

useradd -m -G wheel -s /bin/bash martin

echo "martin:abcd" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

#change the directory to /boot/efi is you mounted the EFI partition at /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

sudo pacman -S intel-ucode

grub-mkconfig -o /boot/grub/grub.cfg

exit
