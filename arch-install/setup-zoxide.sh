#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO ZOXIDE
# =============================================================================

ZSHRC="$HOME/.zshrc"
EVAL_LINE='eval "$(zoxide init zsh)"'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacote ----------------------------------------------------------------
info "Verificando zoxide..."
if pacman -Q zoxide &>/dev/null; then
  skipped "zoxide já instalado"
else
  sudo pacman -S --noconfirm zoxide
  ok "zoxide instalado"
fi

# --- 2. Eval no .zshrc --------------------------------------------------------
info "Verificando eval em $ZSHRC..."
if grep -qF "$EVAL_LINE" "$ZSHRC" 2>/dev/null; then
  skipped "eval já presente em $ZSHRC"
else
  printf '\n%s\n' "$EVAL_LINE" >> "$ZSHRC"
  ok "eval adicionado em $ZSHRC"
fi

ok "Setup do zoxide concluído."
