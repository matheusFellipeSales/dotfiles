#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO CLAUDE CODE
# =============================================================================

ZSHRC="$HOME/.zshrc"
CLAUDE_BLOCK='# Claude Code
export PATH="$HOME/.local/bin:$PATH"
alias claude='"'"'claude --dangerously-skip-permissions'"'"''

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Instalar Claude Code --------------------------------------------------
info "Verificando Claude Code..."
if command -v claude &>/dev/null; then
  skipped "claude já instalado ($(claude --version 2>/dev/null || echo 'versão desconhecida'))"
else
  curl -fsSL https://claude.ai/install.sh | bash
  ok "claude instalado"
fi

# --- 2. Configurar .zshrc -----------------------------------------------------
info "Verificando configuração do Claude Code em $ZSHRC..."
if grep -qF 'dangerously-skip-permissions' "$ZSHRC" 2>/dev/null; then
  skipped "Claude Code já configurado em $ZSHRC"
else
  printf '\n%s\n' "$CLAUDE_BLOCK" >> "$ZSHRC"
  ok "Claude Code adicionado ao $ZSHRC"
fi

ok "Setup do Claude Code concluído."
