#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÕES ESPECÍFICAS DO CACHYOS
# =============================================================================
IOSCHED_FILE="/etc/udev/rules.d/60-ioschedulers.rules"

read -r -d '' IOSCHED_RULES <<'EOF' || true
# HDD
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
    ATTR{queue/scheduler}="bfq"

# SSD
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="adios"

# NVMe SSD
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
    ATTR{queue/scheduler}="adios"
EOF
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

info "Configurando scheduler de I/O (ADIOS)..."

current="$(sudo cat "$IOSCHED_FILE" 2>/dev/null || echo "")"
if [[ "$current" == "$IOSCHED_RULES" ]]; then
  skipped "$IOSCHED_FILE já está atualizado"
else
  sudo mkdir -p "$(dirname "$IOSCHED_FILE")"
  echo "$IOSCHED_RULES" | sudo tee "$IOSCHED_FILE" > /dev/null
  ok "Regras udev gravadas em $IOSCHED_FILE"

  info "Recarregando regras do udev..."
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ok "Regras udev aplicadas"
fi

info "Desabilitando arch-update tray/timer (global)..."
for unit in arch-update-tray.service arch-update.timer; do
  state="$(systemctl --global is-enabled "$unit" 2>/dev/null || echo "disabled")"
  if [[ "$state" == "disabled" || "$state" == "not-found" || "$state" == "masked" ]]; then
    skipped "$unit já está $state"
  else
    sudo systemctl --global disable "$unit"
    ok "$unit desabilitado"
  fi
done
