#!/bin/bash
set -euo pipefail

# =============================================================================
# CONFIGURAÇÃO DO GNOME (atalhos + GNOME Weather)
# =============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# Permite return quando sourced, exit quando executado direto
_finish() {
  return "${1:-0}" 2>/dev/null || exit "${1:-0}"
}

# Verifica se gsettings está disponível
if ! command -v gsettings &>/dev/null; then
  echo -e "${YELLOW}gsettings não encontrado — pulando setup do GNOME${RESET}"
  _finish 0
fi

# Helper: aplica gsettings somente se o valor for diferente
gset() {
  local schema="$1" key="$2" value="$3"
  local current
  current="$(gsettings get "$schema" "$key" 2>/dev/null || echo "")"
  if [[ "$current" == "$value" ]]; then
    skipped "$key"
    return 0
  fi
  gsettings set "$schema" "$key" "$value"
  ok "$key = $value"
}

# =============================================================================
# 1) ATALHOS DO GNOME
# =============================================================================
info "Aplicando atalhos do GNOME..."

# --- Reset de atalhos conflitantes -------------------------------------------
gset org.gnome.desktop.wm.keybindings switch-panels          "[]"
gset org.gnome.desktop.wm.keybindings switch-panels-backward "[]"

# --- Controles gerais ---------------------------------------------------------
gset org.gnome.settings-daemon.plugins.media-keys mic-mute "['<Control>Escape']"
gset org.gnome.desktop.wm.keybindings             close    "['<Super>q']"
gset org.gnome.settings-daemon.plugins.media-keys home     "['<Super>e']"

# --- Remove lançar aplicativos (Super+1..9) -----------------------------------
for i in $(seq 1 9); do
  gset org.gnome.shell.keybindings "switch-to-application-$i" "['']"
done

# --- Switch de workspace (Super+0..9, setas) ----------------------------------
gset org.gnome.desktop.wm.keybindings switch-to-workspace-1     "['<Super>1']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-2     "['<Super>2']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-3     "['<Super>3']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-4     "['<Super>4']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-5     "['<Super>5']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-6     "['<Super>6']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-7     "['<Super>7']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-8     "['<Super>8']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-9     "['<Super>9']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-10    "['<Super>0']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-left  "['<Super><Alt>Left']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super><Alt>Right']"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-up    "[]"
gset org.gnome.desktop.wm.keybindings switch-to-workspace-down  "[]"

# --- Mover janela para workspace (Shift+Super+0..9, setas) -------------------
gset org.gnome.desktop.wm.keybindings move-to-workspace-1     "['<Shift><Super>1']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-2     "['<Shift><Super>2']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-3     "['<Shift><Super>3']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-4     "['<Shift><Super>4']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-5     "['<Shift><Super>5']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-6     "['<Shift><Super>6']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-7     "['<Shift><Super>7']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-8     "['<Shift><Super>8']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-9     "['<Shift><Super>9']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-10    "['<Shift><Super>0']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-left  "['<Super><Shift>Page_Up']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Shift>Page_Down']"
gset org.gnome.desktop.wm.keybindings move-to-workspace-up    "[]"
gset org.gnome.desktop.wm.keybindings move-to-workspace-down  "[]"

ok "Atalhos padrão aplicados."

# --- Atalhos customizados -----------------------------------------------------
# =============================================================================
# ATALHOS CUSTOMIZADOS — adicione novos blocos seguindo o padrão abaixo
# =============================================================================
CUSTOM_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

declare -A CUSTOM_NAMES=(
  [custom0]="gradia"
)
declare -A CUSTOM_COMMANDS=(
  [custom0]="flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE"
)
declare -A CUSTOM_BINDINGS=(
  [custom0]="<Super><Shift>s"
)
# =============================================================================

info "Aplicando atalhos customizados..."

# Monta a lista de paths para o gsettings
paths="["
for key in "${!CUSTOM_NAMES[@]}"; do
  paths+="'${CUSTOM_BASE}/${key}/', "
done
paths="${paths%, }]"

gset org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$paths"

for key in "${!CUSTOM_NAMES[@]}"; do
  path="${CUSTOM_BASE}/${key}/"
  name="${CUSTOM_NAMES[$key]}"
  command="${CUSTOM_COMMANDS[$key]}"
  binding="${CUSTOM_BINDINGS[$key]}"

  current_name="$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name 2>/dev/null || echo "")"

  if [[ "$current_name" == "'$name'" ]]; then
    current_binding="$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding 2>/dev/null || echo "")"
    if [[ "$current_binding" == "'$binding'" ]]; then
      skipped "$name já configurado"
      continue
    fi
  fi

  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name    "$name"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" command "$command"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding "$binding"
  ok "$name → $binding"
done

ok "Atalhos do GNOME concluídos."

# =============================================================================
# 2) GNOME WEATHER — adicionar localização
# =============================================================================
system_weather=0
flatpak_weather=0

command -v gnome-weather &>/dev/null && system_weather=1
flatpak list 2>/dev/null | grep -q "org.gnome.Weather" && flatpak_weather=1

if [[ $system_weather -eq 0 && $flatpak_weather -eq 0 ]]; then
  skipped "GNOME Weather não instalado — pulando localização"
  _finish 0
fi

read -rp "$(echo -e "${CYAN}Adicionar localização ao GNOME Weather? [s/N] ${RESET}")" answer
if [[ "${answer,,}" != "s" ]]; then
  skipped "GNOME Weather pulado"
  _finish 0
fi

# --- Garantir bc instalado ----------------------------------------------------
info "Verificando bc..."
if ! command -v bc &>/dev/null; then
  info "bc não encontrado — instalando via pacman..."
  sudo pacman -S --noconfirm bc
  ok "bc instalado"
else
  skipped "bc já instalado"
fi

# --- Perguntar localização ----------------------------------------------------
read -rp "Digite o nome da localização: " location_name

query="$(echo "$location_name" | sed 's/ /+/g')"
request=$(curl -s "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1")

if [[ "$request" == "[]" || -z "$request" ]]; then
  echo -e "${YELLOW}Nenhuma localização encontrada para '$location_name'${RESET}"
  _finish 1
fi

display=$(echo "$request" | sed 's/.*"display_name":"//' | sed 's/".*//')
name=$(echo "$display" | sed 's/,.*//')

read -rp "Adicionar '$display'? [y/n] " answer
if [[ "$answer" != "y" ]]; then
  skipped "Operação cancelada"
  _finish 0
fi

# --- Calcular coordenadas e adicionar -----------------------------------------
raw_lat=$(echo "$request" | sed 's/.*"lat":"//' | sed 's/".*//')
raw_lon=$(echo "$request" | sed 's/.*"lon":"//' | sed 's/".*//')

lat=$(echo "$raw_lat / (180 / 3.141592654)" | bc -l)
lon=$(echo "$raw_lon / (180 / 3.141592654)" | bc -l)

location_entry="<(uint32 2, <('$name', '', false, [($lat, $lon)], @a(dd) [])>)>"

if [[ $system_weather -eq 1 ]]; then
  current=$(gsettings get org.gnome.Weather locations)
  if echo "$current" | grep -qF "'$name'"; then
    skipped "$name já adicionado (sistema)"
  elif [[ "$current" == "@av []" ]]; then
    gsettings set org.gnome.Weather locations "[$location_entry]"
    ok "$name adicionado (sistema)"
  else
    gsettings set org.gnome.Weather locations "$(echo "$current" | sed "s|>]|>, $location_entry]|")"
    ok "$name adicionado (sistema)"
  fi
fi

if [[ $flatpak_weather -eq 1 ]]; then
  current=$(flatpak run --command=gsettings org.gnome.Weather get org.gnome.Weather locations)
  if echo "$current" | grep -qF "'$name'"; then
    skipped "$name já adicionado (flatpak)"
  elif [[ "$current" == "@av []" ]]; then
    flatpak run --command=gsettings org.gnome.Weather set org.gnome.Weather locations "[$location_entry]"
    ok "$name adicionado (flatpak)"
  else
    flatpak run --command=gsettings org.gnome.Weather set org.gnome.Weather locations "$(echo "$current" | sed "s|>]|>, $location_entry]|")"
    ok "$name adicionado (flatpak)"
  fi
fi

ok "Setup do GNOME concluído."
