#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO NVM
# =============================================================================

ZSH_CONFIG="$HOME/.zshrc"

NVM_BLOCK='# NVM
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Instalar pacote nvm ---------------------------------------------------
info "Verificando pacote nvm..."
if pacman -Q nvm &>/dev/null; then
  skipped "nvm já instalado"
else
  sudo pacman -S --noconfirm nvm
  ok "nvm instalado"
fi

# --- 2. Configurar .zshrc ----------------------------------------------------
info "Verificando configuração do nvm em $ZSH_CONFIG..."
if grep -qF 'source /usr/share/nvm/init-nvm.sh' "$ZSH_CONFIG" 2>/dev/null; then
  skipped "nvm já configurado em $ZSH_CONFIG"
else
  printf '\n%s\n' "$NVM_BLOCK" >> "$ZSH_CONFIG"
  ok "nvm adicionado ao $ZSH_CONFIG"
fi

# --- 3. Instalar Node LTS via nvm --------------------------------------------
info "Verificando Node instalado via nvm..."
export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/init-nvm.sh

if nvm which node &>/dev/null; then
  skipped "node já instalado ($(node --version))"
else
  nvm install node
  ok "node instalado ($(node --version))"
fi

ok "Setup do nvm concluído."
