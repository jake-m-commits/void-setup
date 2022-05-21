#!/usr/bin/env bash

# reinstall grub (void)
if [[ $1 == "grub" ]]; then
    sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void_grub --boot-directory=/boot --removable
fi

# basic setup
if [[ $1 == "basics" ]]; then
    # set hostname
    # sudo hostnamectl set-hostname void

    # update system and add nonfree + 32 bit repos
    sudo xbps-install -Su
    sudo xbps-install -S void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree

    # add xorg and dbus for desktop environments
    sudo xbps-install -S xorg dbus && sudo ln -s /etc/sv/dbus /var/service
    # add useful packages
    sudo xbps-install -S neovim nodejs curl alacritty neofetch python3 python3-pip fzf git delta bat ripgrep starship exa tmux
    # python3 client for neovim
    pip install pynvim

    # get GNOME and Cinnamon and LeftWM
    sudo xbps-install -S feh picom polybar conky dmenu leftwm
    sudo xbps-install -S gnome
    sudo xbps-install -S cinnamon

    # fix fonts
    sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
    sudo xbps-reconfigure -f fontconfig

    # remove dhcpd and enable NetworkManager; restart
    sudo rm /var/service/dhcpcd && sudo ln -s /etc/sv/NetworkManager /var/service
    sudo reboot
fi

# install nvidia drivers
if [[ $1 == "nvidia" ]]; then
    sudo xbps-install -S nvidia dkms linux-headers nvidia-libs-32bit
fi

# set up sound
if [[ $1 == "sound" ]]; then
    sudo xbps-install -S alsa-utils apulse alsa-plugins-pulseaudio pulseaudio alsa-plugins
    sudo ln -s /etc/sv/alsa /var/service
fi

# get intel firmware
if [[ $1 == "firmware" ]]; then
    sudo xbps-install -S intel-ucode && sudo xbps-reconfigure --force linux5.15
fi

# enable gdm
if [[ $1 == "gdm" ]]; then
    sudo ln -s /etc/sv/gdm /var/service
fi

# set up flatpaks and install discord and steam
if [[ $1 == "flatpak" ]]; then
    sudo xbps-install -S flatpak
    sudo xbps-install -S xdg-desktop-portal xdg-desktop-portal-gtk xdg-user-dirs xdg-user-dirs-gtk xdg-utils
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.discordapp.Discord
    flatpak install flathub com.valvesoftware.Steam
fi

# set up ssh for github
if [[ $1 == "git-ssh" ]]; then
    ssh-keygen -t ed25519 -C "jm9357481@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
    ssh -T git@github.com
fi

# get personal dotfiles
if [[ $1 == "dotfiles" ]]; then
    cd Documents/
    git clone git@github.com:jake-m-commits/dotfiles
    cd dotfiles
    cp -r alacritty/ ~/.config/
    cp -r leftwm/ ~/.config/
    cp -r neofetch/ ~/.config/
    cp -r nvim/ ~/.config/
    cp -r picom/ ~/.config/
    cp -r weather/ ~/Documents/
fi

# get vimplug for neovim plugins
if [[ $1 == "vimplug" ]]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

# set up rust
if [[ $1 == "rust" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
