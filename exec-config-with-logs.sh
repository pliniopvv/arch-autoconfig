#!/bin/bash

# Arrays para o relatório final
INSTALLED=()
SKIPPED=()
FAILED=()

log_success() { INSTALLED+=("$1"); echo -e "\e[32m[SUCESSO]\e[0m $1"; }
log_skipped() { SKIPPED+=("$1"); echo -e "\e[33m[IGNORADO]\e[0m $1 (já instalado)"; }
log_failed()  { FAILED+=("$1");   echo -e "\e[31m[FALHA]\e[0m $1"; }

# 1. Configuração Inicial e Ajudante AUR (yay)
setup_system() {
    echo "==> Atualizando sistema e preparando ambiente..."
    sudo pacman -Syu --noconfirm || { log_failed "Atualização do sistema"; return 1; }
    sudo pacman -S --needed --noconfirm base-devel git wget curl unzip flatpak || { log_failed "Dependências base"; return 1; }

    if ! command -v yay &> /dev/null; then
        echo "==> Instalando yay (AUR helper)..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay || { log_failed "Clonar yay"; return 1; }
        cd /tmp/yay && makepkg -si --noconfirm || { log_failed "Compilar yay"; cd ~; return 1; }
        cd ~
        log_success "yay (AUR helper)"
    else
        log_skipped "yay (AUR helper)"
    fi
}

# 2. Instalação de Apps Oficiais (Pacman)
install_official_apps() {
    echo "==> Verificando aplicativos oficiais..."
    local apps=(gimp inkscape putty kdenlive filezilla obs-studio ffmpeg neovim steam steam-native-runtime)
    
    for app in "${apps[@]}"; do
        if pacman -Qi "$app" &> /dev/null; then
            log_skipped "$app"
        else
            echo "Instalando $app..."
            if sudo pacman -S --needed --noconfirm "$app"; then
                log_success "$app"
            else
                log_failed "$app"
            fi
        fi
    done
}

# 3. Instalação de Apps do AUR (Yay)
install_aur_apps() {
    echo "==> Verificando aplicativos do AUR..."
    local aur_apps=(
        slack-desktop discord blender telegram-desktop postman 
        microsoft-edge-stable-bin onlyoffice-bin figma-linux-bin 
        android-studio heroic-games-launcher-bin
    )

    for app in "${aur_apps[@]}"; do
        if yay -Qi "$app" &> /dev/null; then
            log_skipped "$app"
        else
            echo "Instalando $app do AUR..."
            if yay -S --needed --noconfirm "$app"; then
                log_success "$app"
            else
                log_failed "$app"
            fi
        fi
    done
}

# 4. Ferramentas de Desenvolvimento e Flatpak
install_dev_tools() {
    echo "==> Configurando ferramentas de desenvolvimento..."

    # WhatsApp via Flatpak
    if flatpak list | grep -q "com.github.eneshecan.WhatsAppForLinux"; then
        log_skipped "WhatsApp (Flatpak)"
    else
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        if flatpak install flathub com.github.eneshecan.WhatsAppForLinux -y; then
            log_success "WhatsApp (Flatpak)"
        else
            log_failed "WhatsApp (Flatpak)"
        fi
    fi

    # NVM
    if [ -d "$HOME/.nvm" ]; then
        log_skipped "NVM"
    else
        if wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
            log_success "NVM"
        else
            log_failed "NVM"
        fi
    fi

    # SDKMAN
    if [ -d "$HOME/.sdkman" ]; then
        log_skipped "SDKMAN"
    else
        if curl -s "https://get.sdkman.io" | bash; then
            log_success "SDKMAN"
        else
            log_failed "SDKMAN"
        fi
    fi

    # Pyenv
    if [ -d "$HOME/.pyenv" ]; then
        log_skipped "Pyenv"
    else
        if curl -fsSL https://pyenv.run | bash; then
            {
                echo 'export PYENV_ROOT="$HOME/.pyenv"'
                echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
                echo 'eval "$(pyenv init -)"'
            } >> ~/.bashrc
            log_success "Pyenv"
        else
            log_failed "Pyenv"
        fi
    fi
}

# Exibição do Relatório Final
show_report() {
    echo ""
    echo "=================================================="
    echo "               RELATÓRIO DE EXECUÇÃO              "
    echo "=================================================="
    echo -e "\e[32m[+] Instalados com sucesso (${#INSTALLED[@]}):\e[0m"
    for item in "${INSTALLED[@]}"; do
        echo "    - $item"
    done

    echo -e "\e[33m[~] Já estavam instalados (${#SKIPPED[@]}):\e[0m"
    for item in "${SKIPPED[@]}"; do
        echo "    - $item"
    done

    echo -e "\e[31m[x] Falhas (${#FAILED[@]}):\e[0m"
    if [ ${#FAILED[@]} -eq 0 ]; then
        echo "    Nenhuma falha encontrada! Tudo perfeito."
    else
        for item in "${FAILED[@]}"; do
            echo "    - $item"
        done
    fi
    echo "=================================================="
}

# Função Principal
run_config() {
    setup_system
    install_official_apps
    install_aur_apps
    install_dev_tools
    show_report
}

run_config
