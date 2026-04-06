#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO ZSH + PLUGINS + POWERLEVEL10K
# =============================================================================

PACKAGES=(
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-theme-powerlevel10k
  vte-common
)

ZSHRC="$HOME/.zshrc"

PLUGINS_BLOCK='# Zsh Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacotes ---------------------------------------------------------------
info "Verificando pacotes zsh..."
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

# --- 2. Definir zsh como shell padrão ----------------------------------------
info "Verificando shell padrão..."
if [[ "$SHELL" == "$(command -v zsh)" ]]; then
  skipped "zsh já é o shell padrão"
else
  chsh -s "$(command -v zsh)"
  ok "zsh definido como shell padrão (efetivo no próximo login)"
fi

# --- 3. Source dos plugins no .zshrc -----------------------------------------
info "Verificando plugins no $ZSHRC..."
if grep -qF 'powerlevel10k.zsh-theme' "$ZSHRC" 2>/dev/null; then
  skipped "plugins já configurados em $ZSHRC"
else
  printf '\n%s\n' "$PLUGINS_BLOCK" >> "$ZSHRC"
  ok "plugins adicionados ao $ZSHRC"
fi

# --- 4. Abrir novas abas/janelas no mesmo diretório (VTE/OSC7) ----------------
VTE_BLOCK='# Open new terminal tabs/windows in the same directory
[[ -f /etc/profile.d/vte.sh ]] && source /etc/profile.d/vte.sh'

info "Verificando integração VTE no $ZSHRC..."
if grep -qF 'vte.sh' "$ZSHRC" 2>/dev/null; then
  skipped "VTE já configurado em $ZSHRC"
else
  printf '\n%s\n' "$VTE_BLOCK" >> "$ZSHRC"
  ok "VTE adicionado ao $ZSHRC"
fi

ok "Setup do zsh concluído."
