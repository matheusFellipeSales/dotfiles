#!/bin/bash

# Obtém o status de mute da fonte de áudio padrão (microfone)
MIC_STATUS=$(pactl get-source-mute @DEFAULT_SOURCE@)

# Obtém o volume da fonte de áudio padrão (microfone)
MIC_VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -1)

# Define os ícones
ICON_MUTED=""   # Ícone para microfone mudo
ICON_UNMUTED="" # Ícone para microfone ativo

# Define a saída com base no status de mute
if echo "$MIC_STATUS" | grep -q "yes"; then
    echo "%{F#f38ba8}off%{F-}" # Icone + status de desativado
else
    # Microfone está ativo
    VOLUME="$MIC_VOLUME"
    echo "$VOLUME" # Se o mic está ativo mostra a porcentagem do volume
fi
