#!/bin/bash
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info()    { echo -e "${CYAN}==> $*${RESET}"; }
ok()      { echo -e "${GREEN}    ok: $*${RESET}"; }
skipped() { echo -e "${YELLOW}    --: $*${RESET}"; }

# --- 1. Verificar GNOME Weather -----------------------------------------------
system_weather=0
flatpak_weather=0

command -v gnome-weather &>/dev/null && system_weather=1
flatpak list 2>/dev/null | grep -q "org.gnome.Weather" && flatpak_weather=1

if [[ $system_weather -eq 0 && $flatpak_weather -eq 0 ]]; then
  skipped "GNOME Weather não instalado"
  exit 0
fi

# --- 2. Garantir bc instalado -------------------------------------------------
info "Verificando bc..."
if ! command -v bc &>/dev/null; then
  info "bc não encontrado — instalando via pacman..."
  sudo pacman -S --noconfirm bc
  ok "bc instalado"
else
  skipped "bc já instalado"
fi

# --- 3. Perguntar localização -------------------------------------------------
if [[ -n "${*:-}" ]]; then
  location_name="$*"
else
  read -rp "Digite o nome da localização: " location_name
fi

query="$(echo "$location_name" | sed 's/ /+/g')"
request=$(curl -s "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1")

if [[ "$request" == "[]" || -z "$request" ]]; then
  echo -e "${YELLOW}Nenhuma localização encontrada para '$location_name'${RESET}"
  exit 1
fi

display=$(echo "$request" | sed 's/.*"display_name":"//' | sed 's/".*//')
name=$(echo "$display" | sed 's/,.*//')

read -rp "Adicionar '$display'? [y/n] " answer
if [[ "$answer" != "y" ]]; then
  skipped "Operação cancelada"
  exit 0
fi

# --- 4. Calcular coordenadas e adicionar --------------------------------------
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
