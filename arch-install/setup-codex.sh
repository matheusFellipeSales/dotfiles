#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO CODEX CLI
# =============================================================================

ZSHRC="$HOME/.zshrc"

CODEX_ALIAS="alias codex='codex --dangerously-bypass-approvals-and-sandbox'"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Garantir node/npm -----------------------------------------------------
info "Verificando node/npm..."
if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
  source "$(dirname "${BASH_SOURCE[0]}")/setup-nvm.sh"
fi

# --- 2. Instalar @openai/codex ------------------------------------------------
info "Verificando @openai/codex..."
if npm list -g @openai/codex &>/dev/null 2>&1; then
  skipped "@openai/codex já instalado ($(codex --version 2>/dev/null || echo 'versão desconhecida'))"
else
  npm i -g @openai/codex
  ok "@openai/codex instalado"
fi

# --- 3. Alias no .zshrc -------------------------------------------------------
info "Verificando alias do codex em $ZSHRC..."
if grep -qF 'dangerously-bypass-approvals-and-sandbox' "$ZSHRC" 2>/dev/null; then
  skipped "alias do codex já presente em $ZSHRC"
else
  printf '\n# codex\n%s\n' "$CODEX_ALIAS" >> "$ZSHRC"
  ok "alias do codex adicionado ao $ZSHRC"
fi

ok "Setup do codex concluído."
