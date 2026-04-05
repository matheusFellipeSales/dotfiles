#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO NANO + SYNTAX HIGHLIGHTING
# =============================================================================

NANORC="$HOME/.nanorc"
INCLUDE_LINE='include "/usr/share/nano-syntax-highlighting/*.nanorc"'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacote ----------------------------------------------------------------
info "Verificando nano-syntax-highlighting..."
if pacman -Q nano-syntax-highlighting &>/dev/null; then
  skipped "nano-syntax-highlighting já instalado"
else
  sudo pacman -S --noconfirm nano-syntax-highlighting
  ok "nano-syntax-highlighting instalado"
fi

# --- 2. Include no ~/.nanorc --------------------------------------------------
info "Verificando include em $NANORC..."
if grep -qF "$INCLUDE_LINE" "$NANORC" 2>/dev/null; then
  skipped "include já presente em $NANORC"
else
  printf '%s\n' "$INCLUDE_LINE" >> "$NANORC"
  ok "include adicionado em $NANORC"
fi

ok "Setup do nano concluído."
