#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DE ALIASES
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$HOME/.zshrc"
ALIASES_LINE='# Aliases
[[ ! -f ~/.aliases ]] || source ~/.aliases'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Instalar stow ---------------------------------------------------------
info "Verificando stow..."
if pacman -Q stow &>/dev/null; then
  skipped "stow já instalado"
else
  sudo pacman -S --noconfirm stow
  ok "stow instalado"
fi

# --- 2. Stow aliases ----------------------------------------------------------
info "Verificando symlink de aliases..."
if [[ -L "$HOME/.aliases" && "$(readlink "$HOME/.aliases")" == *dotfiles/aliases/.aliases* ]]; then
  skipped ".aliases já linkado"
else
  stow --dir="$DOTFILES_DIR" --target="$HOME" aliases
  ok ".aliases linkado via stow"
fi

# --- 3. Source no .zshrc ------------------------------------------------------
info "Verificando source de aliases em $ZSHRC..."
if grep -qF 'source ~/.aliases' "$ZSHRC" 2>/dev/null; then
  skipped "source já presente em $ZSHRC"
else
  printf '\n%s\n' "$ALIASES_LINE" >> "$ZSHRC"
  ok "source adicionado em $ZSHRC"
fi

ok "Setup de aliases concluído."
