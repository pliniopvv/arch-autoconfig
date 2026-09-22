#!/bin/bash

# Atualiza o sistema e garante a presença do yay (AUR helper)
setup_system() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel git wget curl unzip flatpak

    if ! command -v yay &> /dev/null; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd ~
    fi
}

# Instala todos os pacotes dos repositórios oficiais de uma só vez
install_official_apps() {
    sudo pacman -S --needed --noconfirm \
        gimp inkscape putty kdenlive filezilla obs-studio ffmpeg neovim \
        steam steam-native-runtime
}

# Instala todos os apps do AUR de uma só vez
install_aur_apps() {
    yay -S --needed --noconfirm \
        slack-desktop discord blender telegram-desktop postman \
        microsoft-edge-stable-bin onlyoffice-bin figma-linux-bin \
        android-studio heroic-games-launcher-bin
}

# Configura ferramentas de desenvolvimento (Flatpak, NVM, Pyenv, SDKMAN)
install_dev_tools() {
    # WhatsApp via Flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.github.eneshecan.WhatsAppForLinux -y

    # NVM
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # SDKMAN
    curl -s "https://get.sdkman.io" | bash

    # Pyenv
    curl -fsSL https://pyenv.run | bash
    {
        echo 'export PYENV_ROOT="$HOME/.pyenv"'
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
        echo 'eval "$(pyenv init -)"'
    } >> ~/.bashrc
}

# Execução principal
run_config() {
    setup_system
    install_official_apps
    install_aur_apps
    install_dev_tools
    echo "Instalação concluída! Reinicie o terminal para carregar as configurações."
}

# Chame a função principal para rodar
run_config
