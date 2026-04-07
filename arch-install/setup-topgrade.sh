#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO TOPGRADE
# =============================================================================

CONFIG_FILE="$HOME/.config/topgrade.toml"
CONFIG_CONTENT='# Desabilita atualização de containers (Docker, Podman, etc.)
disable = ["containers"]
'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacote ----------------------------------------------------------------
info "Verificando topgrade..."
if pacman -Q topgrade &>/dev/null; then
  skipped "topgrade já instalado"
else
  sudo pacman -S --noconfirm topgrade
  ok "topgrade instalado"
fi

# --- 2. Configuração ----------------------------------------------------------
info "Verificando $CONFIG_FILE..."
if [[ -f "$CONFIG_FILE" ]] && grep -q 'disable.*containers' "$CONFIG_FILE"; then
  skipped "containers já desabilitado na config"
else
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
  ok "config criada com containers desabilitado"
fi

ok "Setup do topgrade concluído."
