#!/bin/bash

# Destino do ping (Google)
DESTINO="8.8.8.8"

# Executa o ping e captura o tempo em milissegundos
LATENCIA=$(ping -c 1 -W 1 $DESTINO | grep 'tempo=' | awk -F'tempo=' '{print $2}' | awk '{print $1}')

# Verifica se o ping foi bem-sucedido e formata o resultado em JSON
if [ -n "$LATENCIA" ]; then
    LATENCIA_INT=$(echo "$LATENCIA" | awk '{print int($1+0.5)}')
    if (( $(echo "$LATENCIA > 70" | bc -l) )); then
        echo "{\"text\": \"${LATENCIA} ms\", \"class\": \"warning\"}"
    else
        echo "{\"text\": \"${LATENCIA} ms\", \"class\": \"normal\"}"
    fi
else
    echo "{\"text\": \"desconectado\", \"class\": \"disconnected\"}"
fi