#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO OPENCODE
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$HOME/.zshrc"

OPENCODE_PATH_LINE='export PATH=/home/matheus/.opencode/bin:$PATH'
OPENCODE_ENV_LINE='export OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT=1'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Instalar opencode -----------------------------------------------------
info "Verificando opencode..."
if command -v opencode &>/dev/null; then
  skipped "opencode já instalado"
else
  curl -fsSL https://opencode.ai/install | bash
  ok "opencode instalado"
fi

# --- 2. Stow config -----------------------------------------------------------
info "Verificando config do opencode..."
if [[ -L "$HOME/.config/opencode" ]]; then
  skipped "config do opencode já linkada"
else
  stow --dir="$DOTFILES_DIR" --target="$HOME" opencode
  ok "config do opencode linkada via stow"
fi

# --- 3. PATH no .zshrc --------------------------------------------------------
info "Verificando PATH do opencode em $ZSHRC..."
if grep -qF '.opencode/bin' "$ZSHRC" 2>/dev/null; then
  skipped "PATH do opencode já presente em $ZSHRC"
else
  printf '\n# opencode\n%s\n' "$OPENCODE_PATH_LINE" >> "$ZSHRC"
  ok "PATH do opencode adicionado ao $ZSHRC"
fi

# --- 4. Variável experimental -------------------------------------------------
info "Verificando OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT em $ZSHRC..."
if grep -qF 'OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT' "$ZSHRC" 2>/dev/null; then
  skipped "OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT já presente em $ZSHRC"
else
  printf '%s\n' "$OPENCODE_ENV_LINE" >> "$ZSHRC"
  ok "OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT adicionado ao $ZSHRC"
fi

ok "Setup do opencode concluído."
