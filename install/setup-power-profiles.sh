#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO POWER-PROFILES-DAEMON
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacote ----------------------------------------------------------------
info "Verificando power-profiles-daemon..."
if pacman -Q power-profiles-daemon &>/dev/null; then
  skipped "power-profiles-daemon já instalado"
else
  sudo pacman -S --noconfirm power-profiles-daemon
  ok "power-profiles-daemon instalado"
fi

# --- 2. Serviço ---------------------------------------------------------------
info "Verificando serviço power-profiles-daemon..."
if systemctl is-enabled --quiet power-profiles-daemon && systemctl is-active --quiet power-profiles-daemon; then
  skipped "power-profiles-daemon já habilitado e ativo"
else
  sudo systemctl enable --now power-profiles-daemon
  ok "power-profiles-daemon habilitado e iniciado"
fi

ok "Setup do power-profiles-daemon concluído."
