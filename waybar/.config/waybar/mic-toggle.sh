#!/bin/bash
pamixer --default-source -t
pkill -RTMIN+11 waybar

if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
    notify-send -h string:x-canonical-private-synchronous:mic-toggle "Microfone" "Mutado 󰍭" --icon=microphone-sensitivity-muted
else
    VOLUME=$(pamixer --default-source --get-volume)
    notify-send -h string:x-canonical-private-synchronous:mic-toggle "Microfone" "Ativo ${VOLUME}% 󰍬" --icon=microphone-sensitivity-high
fi
