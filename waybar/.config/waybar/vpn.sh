#!/bin/bash
VPN_NAME="Hexa"

if nmcli con show --active 2>/dev/null | grep -q "^${VPN_NAME}[[:space:]]"; then
    echo '{"text": "󰌾", "tooltip": "VPN: ON (Hexa)\nClique para desconectar", "class": "active"}'
else
    echo '{"text": "󰌿", "tooltip": "VPN: OFF (Hexa)\nClique para conectar", "class": "inactive"}'
fi
