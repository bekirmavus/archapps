#!/bin/bash
sudo guake firefox thunderbird git nodejs npm flameshot wget curl gparted dosfstools chromium eclipse-ecj  base-devel flatpak amberol

sudo systemctl mask dev-tpmrm0.device
sudo systemctl mask dev-tpm0.device

#yay install
git clone https://aur.archlinux.org/yay.git yay
cd yay
makepkg -si
cd ..
rm -r yay

yay -S visual-studio-code-bin
