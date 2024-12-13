#! /usr/bin/env bash

# Para listar todas as teclas de atalho utilize
# gsettings list-recursively | grep -i -E 'media-keys|keybindings'

# personalizados
# Reseta coisas chatas
gsettings set org.gnome.desktop.wm.keybindings switch-panels "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-panels-backward "[]"

# Controles de media
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['<Control>dead_grave']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

# remove lançar aplicativos.
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "['']"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "['']"

# seta super + area de trabalho até a 10
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<Super>7']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<Super>8']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-9 "['<Super>9']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['<Super>0']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super><Control>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super><Control>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"

# seta mover aplicativo para workspace shift + super + area de trabalho
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Shift><Super>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Shift><Super>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Shift><Super>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Shift><Super>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Shift><Super>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Shift><Super>6']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<Shift><Super>7']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<Shift><Super>8']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-9 "['<Shift><Super>9']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['<Shift><Super>0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Shift>Page_Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Shift>Page_Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "[]"
