#!/bin/bash

# 1. Garantir que o remote flathub existe no escopo do usuário
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 2. Listar todos os flatpaks instalados no sistema (somente apps)
apps=$(flatpak list --system --app --columns=application)

if [ -z "$apps" ]; then
  echo "Nenhum app do sistema encontrado para migrar."
  exit 0
fi

echo "Apps a migrar:"
echo "$apps"
echo "---"

# 3. Para cada app, instalar como usuário e depois remover do sistema
for app in $apps; do
  echo "Migrando: $app"

  # Instalar como usuário
  if flatpak install --user -y flathub "$app"; then
    # Só remove do sistema se a instalação como usuário deu certo
    sudo flatpak uninstall --system -y "$app"
    echo "$app migrado com sucesso!"
  else
    echo "ERRO: falha ao instalar $app como usuário. Mantendo instalação do sistema."
  fi

  echo "---"
done

# 4. Limpar runtimes não utilizadas do sistema
sudo flatpak uninstall --system --unused -y

echo "Migração concluída!"
