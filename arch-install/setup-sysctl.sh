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

needs_apply=false

for key in "${!SYSCTL_SETTINGS[@]}"; do
  desired="${SYSCTL_SETTINGS[$key]}"
  current="$(sysctl -n "$key" 2>/dev/null || echo "")"

  if [[ "$current" == "$desired" ]]; then
    skipped "$key = $current"
    continue
  fi

  echo -e "${CYAN}    ~: $key: $current -> $desired${RESET}"

  # Atualiza ou adiciona apenas esta linha no arquivo
  sudo mkdir -p "$(dirname "$SYSCTL_FILE")"
  if sudo grep -q "^${key}\s*=" "$SYSCTL_FILE" 2>/dev/null; then
    sudo sed -i "s|^${key}\s*=.*|${key} = ${desired}|" "$SYSCTL_FILE"
  else
    echo "${key} = ${desired}" | sudo tee -a "$SYSCTL_FILE" > /dev/null
  fi

  needs_apply=true
done

if ! $needs_apply; then
  ok "Todas as configurações já estão aplicadas."
  return 0 2>/dev/null || exit 0
fi

info "Aplicando com sysctl --system..."
sudo sysctl --system --quiet
ok "Configurações aplicadas."
