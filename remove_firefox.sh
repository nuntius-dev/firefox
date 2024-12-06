#!/bin/bash
set -e

# Función para intentar ejecutar un comando y continuar si falla
try_run() {
  "$@" || echo "❗ Advertencia: No se pudo ejecutar el comando '$*'. Continuando..."
}

# Desinstalar Firefox desde el sistema
purge_firefox_packages() {
  echo "Eliminando paquetes de Firefox instalados desde repositorios..."
  try_run sudo apt-get purge -y firefox firefox-esr firefox-addons
  try_run sudo apt remove -y firefox firefox-esr firefox-addons
  try_run sudo apt-get autoremove -y
  [ -f "$HOME/Desktop/firefox-esr.desktop" ] && rm "$HOME/Desktop/firefox-esr.desktop"
  [ -f "$HOME/Desktop/firefox.desktop" ] && rm "$HOME/Desktop/firefox.desktop"
}

# Eliminar configuraciones personalizadas
remove_firefox_config() {
  echo "Eliminando configuraciones personalizadas..."
  try_run sudo rm -rf /root/.mozilla /home/*/.mozilla
  try_run sudo rm -f /etc/apt/preferences.d/mozilla-firefox
  try_run sudo rm -rf /usr/lib/firefox /usr/lib/firefox-addons
  try_run sudo rm -rf /usr/lib64/firefox
  try_run sudo rm -f /usr/share/icons/hicolor/48x48/apps/firefox.png
  try_run sudo rm -rf /usr/share/xfce4-panel-profiles/layouts
}

# Eliminar configuración de fuentes PPA
remove_firefox_ppa() {
  echo "Eliminando PPA de Firefox..."
  try_run sudo rm -f /etc/apt/sources.list.d/mozillateam-ppa.list
  try_run sudo apt-get update
}

# Main
echo "Iniciando desinstalación de Firefox..."
purge_firefox_packages
remove_firefox_config
remove_firefox_ppa
echo "⭐ Firefox y sus configuraciones han sido eliminados completamente."
