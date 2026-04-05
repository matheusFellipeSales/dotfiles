#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DE VIRTUALIZAÇÃO (QEMU/KVM + virt-manager)
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacotes ---------------------------------------------------------------
PACKAGES=(qemu-full virt-manager swtpm)

info "Verificando pacotes..."
to_install=()
for pkg in "${PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -gt 0 ]]; then
  info "Instalando: ${to_install[*]}"
  sudo pacman -S --noconfirm "${to_install[@]}"
  ok "pacotes instalados"
fi

# --- 2. firewall_backend = iptables em network.conf --------------------------
NETWORK_CONF="/etc/libvirt/network.conf"
FIREWALL_ENTRY='firewall_backend = "iptables"'

info "Verificando $NETWORK_CONF..."
if grep -qF "$FIREWALL_ENTRY" "$NETWORK_CONF" 2>/dev/null; then
  skipped "firewall_backend já configurado"
else
  sudo mkdir -p "$(dirname "$NETWORK_CONF")"
  echo "$FIREWALL_ENTRY" | sudo tee -a "$NETWORK_CONF" > /dev/null
  ok "firewall_backend adicionado"
fi

# --- 3. Usuário no grupo libvirt ----------------------------------------------
info "Verificando grupo libvirt para $USER..."
if id -nG "$USER" | grep -qw libvirt; then
  skipped "$USER já está no grupo libvirt"
else
  sudo usermod -aG libvirt "$USER"
  ok "$USER adicionado ao grupo libvirt (efetivo no próximo login)"
fi

# --- 4. Serviços libvirtd -----------------------------------------------------
info "Verificando serviços libvirtd..."
for unit in libvirtd.service libvirtd.socket; do
  if systemctl is-enabled --quiet "$unit" 2>/dev/null && systemctl is-active --quiet "$unit" 2>/dev/null; then
    skipped "$unit já habilitado e ativo"
  else
    sudo systemctl enable --now "$unit"
    ok "$unit habilitado e iniciado"
  fi
done

# --- 5. Rede default do libvirt com autostart ---------------------------------
info "Verificando rede 'default' do libvirt..."
if sudo virsh net-info default 2>/dev/null | grep -q "Autostart:.*yes"; then
  skipped "rede default já com autostart"
else
  sudo virsh net-autostart default
  ok "autostart habilitado na rede default"
fi

if ! sudo virsh net-info default 2>/dev/null | grep -q "Active:.*yes"; then
  sudo virsh net-start default 2>/dev/null || true
  ok "rede default iniciada"
else
  skipped "rede default já ativa"
fi

# --- 6. UFW: permitir roteamento da subnet do libvirt ------------------------
info "Verificando dependência ufw..."
if ! pacman -Q ufw &>/dev/null; then
  sudo pacman -S --noconfirm ufw
  ok "ufw instalado"
else
  skipped "ufw já instalado"
fi

info "Verificando regra UFW para rede virtual..."
if sudo ufw status verbose 2>/dev/null | grep -q "192.168.122.0/24"; then
  skipped "regra UFW já existe"
else
  sudo ufw route allow from 192.168.122.0/24
  ok "regra UFW adicionada"
fi

# --- 7. Btrfs: desativar CoW no diretório de imagens das VMs -----------------
VM_DIR="/var/lib/libvirt/images"

info "Verificando filesystem de $VM_DIR..."
if [[ "$(stat -f -c '%T' "$VM_DIR" 2>/dev/null)" == "btrfs" ]]; then
  info "Btrfs detectado — verificando CoW em $VM_DIR..."
  if lsattr -d "$VM_DIR" 2>/dev/null | grep -q '^....C'; then
    skipped "CoW já desativado em $VM_DIR"
  else
    sudo mkdir -p "$VM_DIR"
    sudo chattr +C "$VM_DIR"
    ok "CoW desativado em $VM_DIR"
  fi
else
  skipped "filesystem não é btrfs, CoW não aplicável"
fi

ok "Setup de virtualização concluído."
