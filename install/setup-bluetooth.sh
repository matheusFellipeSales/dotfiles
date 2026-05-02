#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO BLUETOOTH
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

info "Verificando serviço bluetooth..."
if systemctl is-enabled --quiet bluetooth && systemctl is-active --quiet bluetooth; then
  skipped "bluetooth já habilitado e ativo"
else
  sudo systemctl enable --now bluetooth
  ok "bluetooth habilitado e iniciado"
fi

ok "Setup do bluetooth concluído."
