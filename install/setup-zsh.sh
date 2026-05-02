#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO ZSH + PLUGINS + POWERLEVEL10K + FZF + ALIASES
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$HOME/.zshrc"

PACKAGES=(
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-theme-powerlevel10k
  vte-common
  fzf
  stow
)

PLUGINS_BLOCK='# Zsh Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme'

VTE_BLOCK='# Open new terminal tabs/windows in the same directory
[[ -f /etc/profile.d/vte.sh ]] && source /etc/profile.d/vte.sh'

FZF_BLOCK='# Set up fzf key bindings
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory'

HG_ALIAS='alias hg='"'"'print -z $(fc -l 1 | fzf --tac --no-sort | sed "s/ *[0-9]* *//")'"'"''

ALIASES_LINE='# Aliases
[[ ! -f ~/.aliases ]] || source ~/.aliases'

KEYBINDINGS_BLOCK='# Ctrl+Left / Ctrl+Right -> jump words
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^H"      backward-kill-word'

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Pacotes ---------------------------------------------------------------
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

# --- 3. Plugins no .zshrc -----------------------------------------------------
info "Verificando plugins no $ZSHRC..."
if grep -qF 'powerlevel10k.zsh-theme' "$ZSHRC" 2>/dev/null; then
  skipped "plugins já configurados em $ZSHRC"
else
  printf '\n%s\n' "$PLUGINS_BLOCK" >> "$ZSHRC"
  ok "plugins adicionados ao $ZSHRC"
fi

# --- 4. compinit ---------------------------------------------------------------
info "Verificando compinit no $ZSHRC..."
if grep -qF 'compinit' "$ZSHRC" 2>/dev/null; then
  skipped "compinit já configurado em $ZSHRC"
else
  printf '\nautoload -Uz compinit && compinit\n' >> "$ZSHRC"
  ok "compinit adicionado ao $ZSHRC"
fi

# --- 5. VTE -------------------------------------------------------------------
info "Verificando integração VTE no $ZSHRC..."
if grep -qF 'vte.sh' "$ZSHRC" 2>/dev/null; then
  skipped "VTE já configurado em $ZSHRC"
else
  printf '\n%s\n' "$VTE_BLOCK" >> "$ZSHRC"
  ok "VTE adicionado ao $ZSHRC"
fi

# --- 6. fzf + history ---------------------------------------------------------
info "Verificando configuração fzf+history em $ZSHRC..."
if grep -qF 'source <(fzf --zsh)' "$ZSHRC" 2>/dev/null; then
  skipped "fzf key bindings já presentes em $ZSHRC"
else
  printf '\n%s\n' "$FZF_BLOCK" >> "$ZSHRC"
  ok "fzf key bindings adicionados ao $ZSHRC"
fi

# --- 7. Alias hg --------------------------------------------------------------
info "Verificando alias hg em $ZSHRC..."
if grep -qF 'alias hg=' "$ZSHRC" 2>/dev/null; then
  skipped "alias hg já presente em $ZSHRC"
else
  printf '\n%s\n' "$HG_ALIAS" >> "$ZSHRC"
  ok "alias hg adicionado ao $ZSHRC"
fi

# --- 8. Stow aliases ----------------------------------------------------------
info "Verificando symlink de aliases..."
if [[ -L "$HOME/.aliases" && "$(readlink "$HOME/.aliases")" == *dotfiles/aliases/.aliases* ]]; then
  skipped ".aliases já linkado"
else
  stow --dir="$DOTFILES_DIR" --target="$HOME" aliases
  ok ".aliases linkado via stow"
fi

# --- 9. Source de aliases no .zshrc -------------------------------------------
info "Verificando source de aliases em $ZSHRC..."
if grep -qF 'source ~/.aliases' "$ZSHRC" 2>/dev/null; then
  skipped "source já presente em $ZSHRC"
else
  printf '\n%s\n' "$ALIASES_LINE" >> "$ZSHRC"
  ok "source adicionado em $ZSHRC"
fi

# --- 10. Keybindings (Ctrl+Left/Right pula palavra) ---------------------------
info "Verificando keybindings em $ZSHRC..."
if grep -qF '"^[[1;5D" backward-word' "$ZSHRC" 2>/dev/null; then
  skipped "keybindings já presentes em $ZSHRC"
else
  printf '\n%s\n' "$KEYBINDINGS_BLOCK" >> "$ZSHRC"
  ok "keybindings adicionados ao $ZSHRC"
fi

ok "Setup do zsh concluído."
