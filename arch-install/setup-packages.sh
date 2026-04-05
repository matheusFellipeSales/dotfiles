#!/bin/bash
set -euo pipefail

# =============================================================================
# PACOTES — adicione ou remova pacotes aqui
# =============================================================================

PACKAGES=(
  # --- Sistema ---
  base-devel
  ufw
  fzf
  ripgrep
  fd
  bat
  eza
  zsh
  lazygit
  btop
  fastfetch
  unzip
  wget
  curl
  jq
  ptyxis
  nano
  fuse2
  libreoffice-fresh
  libreoffice-fresh-pt-br
  google-chrome

  # --- Dev ---
  visual-studio-code-bin
  git

  # --- Codecs ---
  gst-libav
  gst-plugins-base
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  x265
  x264
  lame

  # --- Fontes ---
  adobe-source-sans-pro-fonts
  ttf-dejavu
  ttf-opensans
  noto-fonts
  freetype2
  terminus-font
  ttf-bitstream-vera
  ttf-droid
  ttf-fira-mono
  ttf-fira-sans
  ttf-freefont
  ttf-inconsolata
  ttf-liberation
  otf-libertinus
)

# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

info "Verificando pacotes..."

to_install=()
for pkg in "${PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    skipped "$pkg já instalado"
  else
    to_install+=("$pkg")
  fi
done

if [[ ${#to_install[@]} -eq 0 ]]; then
  ok "Todos os pacotes já estão instalados."
  return 0 2>/dev/null || exit 0
fi

info "Instalando ${#to_install[@]} pacote(s): ${to_install[*]}"
sudo pacman -S --noconfirm "${to_install[@]}"
ok "Pacotes instalados."
