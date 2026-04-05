#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO DOCKER
# =============================================================================

PACKAGES=(docker docker-compose docker-buildx)
DAEMON_JSON="/etc/docker/daemon.json"
DAEMON_CONFIG='{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes docker..."
to_install=()
for pkg in "${PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  sudo pacman -S --noconfirm "${to_install[@]}"
  ok "pacotes instalados"
fi

# --- 2. Serviço docker --------------------------------------------------------
info "Verificando serviço docker..."
if systemctl is-enabled --quiet docker && systemctl is-active --quiet docker; then
  skipped "docker já habilitado e ativo"
else
  sudo systemctl enable --now docker
  ok "docker habilitado e iniciado"
fi

# --- 3. Usuário no grupo docker -----------------------------------------------
info "Verificando grupo docker para $USER..."
if id -nG "$USER" | grep -qw docker; then
  skipped "$USER já está no grupo docker"
else
  sudo usermod -aG docker "$USER"
  ok "$USER adicionado ao grupo docker (efetivo no próximo login)"
fi

# --- 4. daemon.json (IPv6) ----------------------------------------------------
info "Verificando $DAEMON_JSON..."
needs_daemon_update=false

if [[ ! -f "$DAEMON_JSON" ]]; then
  needs_daemon_update=true
else
  current_ipv6="$(sudo python3 -c "import json,sys; d=json.load(open('$DAEMON_JSON')); print(str(d.get('ipv6','')).lower())" 2>/dev/null || echo "")"
  current_cidr="$(sudo python3 -c "import json,sys; d=json.load(open('$DAEMON_JSON')); print(d.get('fixed-cidr-v6',''))" 2>/dev/null || echo "")"

  if [[ "$current_ipv6" == "true" && "$current_cidr" == "2001:db8:1::/64" ]]; then
    skipped "$DAEMON_JSON já configurado"
  else
    needs_daemon_update=true
  fi
fi

if $needs_daemon_update; then
  sudo mkdir -p /etc/docker
  echo "$DAEMON_CONFIG" | sudo tee "$DAEMON_JSON" > /dev/null
  ok "$DAEMON_JSON configurado"
fi

# --- 5. Reiniciar docker se houve mudança na config --------------------------
if $needs_daemon_update; then
  info "Reiniciando docker..."
  sudo systemctl restart docker
  ok "docker reiniciado"
fi

ok "Setup do Docker concluído."
