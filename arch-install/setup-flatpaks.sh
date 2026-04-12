#!/bin/bash
set -euo pipefail

# =============================================================================
# LISTA DE FLATPAKS — adicione ou remova apps aqui
# =============================================================================
FLATPAKS=(
  com.discordapp.Discord
  com.obsproject.Studio
  io.github.giantpinkrobots.flatsweep
  it.mijorus.gearlever
)
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Garantir flatpak instalado -------------------------------------------
info "Verificando flatpak..."
if ! command -v flatpak &>/dev/null; then
  info "Flatpak não encontrado — instalando via pacman..."
  sudo pacman -S --noconfirm flatpak
  ok "flatpak instalado"
else
  skipped "flatpak já instalado ($(flatpak --version))"
fi

# --- 2. Remover flathub do sistema, garantir no usuário ----------------------
info "Configurando remote flathub (escopo usuário)..."

if flatpak remote-list --system 2>/dev/null | grep -q '^flathub'; then
  info "Removendo flathub do sistema..."
  sudo flatpak remote-delete --system --force flathub
  ok "flathub removido do sistema"
else
  skipped "flathub não estava no sistema"
fi

if ! flatpak remote-list --user 2>/dev/null | grep -q '^flathub'; then
  flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo
  ok "flathub adicionado para o usuário"
else
  skipped "flathub já configurado para o usuário"
fi

# --- 3. Instalar flatpaks da lista -------------------------------------------
info "Instalando flatpaks..."
for app in "${FLATPAKS[@]}"; do
  if flatpak info --user "$app" &>/dev/null; then
    skipped "$app já instalado"
  else
    echo -e "${CYAN}    instalando $app...${RESET}"
    flatpak install --user -y flathub "$app"
    ok "$app instalado"
  fi
done

# --- 4. Limpar runtimes não utilizadas ---------------------------------------
info "Removendo runtimes não utilizadas..."
flatpak uninstall --user --unused -y 2>/dev/null || true

echo ""
ok "Setup de flatpaks concluído."
