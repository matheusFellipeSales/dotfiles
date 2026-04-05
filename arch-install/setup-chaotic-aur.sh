#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO CHAOTIC-AUR
# =============================================================================

CHAOTIC_KEY="3056513887B78AEB"
PACMAN_CONF="/etc/pacman.conf"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Chave GPG -------------------------------------------------------------
info "Verificando chave GPG do chaotic-aur..."
if sudo pacman-key --list-keys "$CHAOTIC_KEY" &>/dev/null; then
  skipped "chave $CHAOTIC_KEY já importada"
else
  sudo pacman-key --recv-key "$CHAOTIC_KEY" --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key "$CHAOTIC_KEY"
  ok "chave importada e assinada localmente"
fi

# --- 2. Pacotes keyring + mirrorlist ------------------------------------------
info "Verificando pacotes chaotic-keyring e chaotic-mirrorlist..."
for pkg in chaotic-keyring chaotic-mirrorlist; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/${pkg}.pkg.tar.zst"
    ok "$pkg instalado"
  fi
done

# --- 3. Entrada no pacman.conf (após [extra]) ----------------------------------
info "Verificando entrada [chaotic-aur] em $PACMAN_CONF..."
if grep -q '^\[chaotic-aur\]' "$PACMAN_CONF"; then
  skipped "[chaotic-aur] já presente em $PACMAN_CONF"
else
  # Insere o bloco logo após a linha "Include = /etc/pacman.d/mirrorlist" do [extra]
  sudo awk '
    /^\[extra\]/ { in_extra=1 }
    in_extra && /^Include *= *\/etc\/pacman\.d\/mirrorlist/ {
      print
      print ""
      print "[chaotic-aur]"
      print "Include = /etc/pacman.d/chaotic-mirrorlist"
      in_extra=0
      next
    }
    { print }
  ' "$PACMAN_CONF" | sudo tee "${PACMAN_CONF}.tmp" > /dev/null

  sudo mv "${PACMAN_CONF}.tmp" "$PACMAN_CONF"
  ok "[chaotic-aur] adicionado após [extra] em $PACMAN_CONF"
fi

# --- 4. Atualizar base de dados -----------------------------------------------
info "Atualizando pacman (-Syu)..."
sudo pacman -Syu --noconfirm
ok "sistema atualizado"

ok "Setup do Chaotic-AUR concluído."
