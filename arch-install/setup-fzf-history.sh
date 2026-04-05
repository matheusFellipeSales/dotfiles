#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO FZF + HISTORY
# =============================================================================

ZSHRC="$HOME/.zshrc"

FZF_BLOCK='# Set up fzf key bindings
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory'

HG_ALIAS='alias hg='"'"'print -z $(fc -l 1 | fzf --tac --no-sort | sed "s/ *[0-9]* *//")'"'"''

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Verificar fzf instalado -----------------------------------------------
info "Verificando fzf..."
if ! pacman -Q fzf &>/dev/null; then
  sudo pacman -S --noconfirm fzf
  ok "fzf instalado"
else
  skipped "fzf já instalado"
fi

# --- 2. Bloco fzf + history no .zshrc -----------------------------------------
info "Verificando configuração fzf+history em $ZSHRC..."
if grep -qF 'source <(fzf --zsh)' "$ZSHRC" 2>/dev/null; then
  skipped "fzf key bindings já presentes em $ZSHRC"
else
  printf '\n%s\n' "$FZF_BLOCK" >> "$ZSHRC"
  ok "fzf key bindings adicionados ao $ZSHRC"
fi

# --- 3. Alias hg no .zshrc ---------------------------------------------------
info "Verificando alias hg em $ZSHRC..."
if grep -qF 'alias hg=' "$ZSHRC" 2>/dev/null; then
  skipped "alias hg já presente em $ZSHRC"
else
  printf '\n%s\n' "$HG_ALIAS" >> "$ZSHRC"
  ok "alias hg adicionado ao $ZSHRC"
fi

ok "Setup fzf+history concluído."
