#!/bin/bash

# Nome da conexão VPN configurada no NetworkManager
VPN_NAME="Hexanetworks"

# Verifica se a VPN está ativa
VPN_STATUS=$(nmcli -t -f NAME,TYPE connection show --active | grep "^${VPN_NAME}:vpn$")

# Função para imprimir status com cores
print_status() {
    local status="$1"
    case "$status" in
        "on")
            echo "%{F#a6e3a1}on%{F-}"    # Verde
            ;;
        "off")
            echo "%{F#f38ba8}off%{F-}"   # Vermelho
            ;;
        "error")
            echo "%{F#f38ba8}error%{F-}" # Amarelo
            ;;
        *)
            echo "UNKNOWN"
            ;;
    esac
}

if [ "$1" = "toggle" ]; then
    if [ -n "$VPN_STATUS" ]; then
        # VPN está ativa, desconecta
        if nmcli connection down id "$VPN_NAME" >/dev/null 2>&1; then
            print_status "off"
        else
            print_status "error"
        fi
    else
        # VPN não está ativa, conecta
        if nmcli connection up id "$VPN_NAME" >/dev/null 2>&1; then
            print_status "on"
        else
            print_status "error"
        fi
    fi
else
    if [ -n "$VPN_STATUS" ]; then
        print_status "on"
    else
        print_status "off"
    fi
fi
