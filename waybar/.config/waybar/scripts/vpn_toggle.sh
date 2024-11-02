#!/bin/bash

# Nome da conexão VPN configurada no NetworkManager
VPN_NAME="Hexanetworks"

# Verifica se a VPN está ativa
VPN_STATUS=$(nmcli -t -f NAME,TYPE connection show --active | grep "^$VPN_NAME:vpn$")

if [ "$1" = "toggle" ]; then
    if [ -n "$VPN_STATUS" ]; then
        # VPN está ativa, desconecta
        if nmcli connection down id "$VPN_NAME" >/dev/null 2>&1; then
            echo '{ "text": "Hexa OFF", "class": "vpn-off" }'
        else
            echo '{ "text": "VPN-Error", "class": "vpn-off" }'
        fi
    else
        # VPN não está ativa, conecta
        if nmcli connection up id "$VPN_NAME" >/dev/null 2>&1; then
            echo '{ "text": "Hexa-ON", "class": "vpn-on" }'
        else
            echo '{ "text": "VPN-Error", "class": "vpn-off" }'
        fi
    fi
else
    if [ -n "$VPN_STATUS" ]; then
        echo '{ "text": "Hexa ON", "class": "vpn-on" }'
    else
        echo '{ "text": "Hexa OFF", "class": "vpn-off" }'
    fi
fi

