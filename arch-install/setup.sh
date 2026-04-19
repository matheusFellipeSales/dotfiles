#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# SCRIPTS DE SETUP — adicione novos scripts aqui em ordem de execução
# =============================================================================
SETUP_SCRIPTS=(
  setup-bluetooth.sh
  setup-power-profiles.sh
  setup-sysctl.sh
  setup-cachyos.sh
  setup-chaotic-aur.sh
  setup-packages.sh
  setup-zsh.sh
  setup-ufw.sh
  setup-dns.sh
  setup-docker.sh
  setup-nano.sh
  setup-zoxide.sh
  setup-nvm.sh
  setup-codex.sh
  setup-l2tp.sh
  setup-virt.sh
  setup-claude.sh
  setup-opencode.sh
  setup-flatpaks.sh
  setup-gnome.sh
  setup-topgrade.sh
)
# =============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

for script in "${SETUP_SCRIPTS[@]}"; do
  path="$SCRIPT_DIR/$script"
  echo -e "${CYAN}==============================${RESET}"
  echo -e "${CYAN} $script${RESET}"
  echo -e "${CYAN}==============================${RESET}"

  if [[ ! -f "$path" ]]; then
    echo -e "${RED}ERRO: $path não encontrado — pulando${RESET}"
    continue
  fi

  read -r -p "$(echo -e "${CYAN}Executar $script? [s/N] ${RESET}")" answer
  if [[ "${answer,,}" != "s" ]]; then
    echo -e "${YELLOW}    --: $script pulado${RESET}"
    echo ""
    continue
  fi

  # shellcheck source=/dev/null
  source "$path"

  echo -e "${GREEN} $script concluído${RESET}"
  echo ""
done

echo -e "${GREEN}=============================="
echo -e " Setup completo!"
echo -e "==============================${RESET}"
