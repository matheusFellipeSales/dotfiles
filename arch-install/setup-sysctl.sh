#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÕES SYSCTL — edite os valores aqui
# =============================================================================
SYSCTL_FILE="/etc/sysctl.d/99-settings.conf"
declare -A SYSCTL_SETTINGS=(
  [vm.swappiness]=180
  [vm.page-cluster]=0
  [vm.dirty_bytes]=268435456
  [vm.dirty_background_bytes]=67108864
)
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

info "Verificando configurações sysctl..."

needs_write=false
declare -A to_apply=()

for key in "${!SYSCTL_SETTINGS[@]}"; do
  desired="${SYSCTL_SETTINGS[$key]}"
  current="$(sysctl -n "$key" 2>/dev/null || echo "")"

  if [[ "$current" == "$desired" ]]; then
    skipped "$key = $current (já configurado)"
  else
    echo -e "${CYAN}    ~: $key: $current -> $desired${RESET}"
    to_apply[$key]="$desired"
    needs_write=true
  fi
done

if ! $needs_write; then
  ok "Todas as configurações já estão aplicadas."
  return 0 2>/dev/null || exit 0
fi

# Escrever arquivo de configuração
info "Escrevendo $SYSCTL_FILE..."
{
  echo "# Gerado por setup-sysctl.sh"
  for key in "${!SYSCTL_SETTINGS[@]}"; do
    echo "$key = ${SYSCTL_SETTINGS[$key]}"
  done
} | sudo tee "$SYSCTL_FILE" > /dev/null
ok "$SYSCTL_FILE atualizado"

# Aplicar sem reboot
info "Aplicando com sysctl --system..."
sudo sysctl --system --quiet
ok "Configurações aplicadas."
