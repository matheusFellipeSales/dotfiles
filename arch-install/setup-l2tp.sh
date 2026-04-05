#!/bin/bash
set -euo pipefail

# =============================================================================
# SUPORTE A L2TP/IPSec VPN
# =============================================================================

PACKAGES=(networkmanager-l2tp strongswan)

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes L2TP..."
to_install=()
for pkg in "${PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  sudo pacman -S --noconfirm "${to_install[@]}"
  ok "pacotes instalados"
fi

# --- 2. Reiniciar NetworkManager apenas se algo foi instalado ----------------
if [[ ${#to_install[@]} -gt 0 ]]; then
  info "Reiniciando NetworkManager..."
  sudo systemctl restart NetworkManager
  ok "NetworkManager reiniciado"
else
  skipped "NetworkManager não precisa reiniciar"
fi

ok "Setup L2TP concluído."
