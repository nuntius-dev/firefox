#!/usr/bin/env bash
set -xe
trap 'echo "Error en la línea $LINENO."' ERR

# Detectar distribución
distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
apt-get update && apt-get install -y software-properties-common
# Función para instalar Firefox según la distribución
install_firefox() {
  case "$distro" in
    ubuntu|debian|kali|parrot)
      if grep -qE 'jammy|noble' /etc/os-release; then
        add-apt-repository -y ppa:mozillateam/ppa
        echo -e 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' \
          > /etc/apt/preferences.d/mozilla-firefox
      fi
      apt-get update
      apt-get install -y firefox p11-kit-modules
      apt autoremove -y
      ;;
    oracle*|rockylinux*|rhel*|almalinux*|fedora*)
      dnf install -y firefox p11-kit
      ;;
    opensuse)
      zypper install -yn p11-kit-tools MozillaFirefox
      ;;
    *)
      echo "Distribución no soportada: $distro"
      exit 1
      ;;
  esac
}

# Configurar icono de escritorio
configure_desktop_icon() {
  local desktop_file="$HOME/Desktop/firefox.desktop"
  if [ -f "$desktop_file" ]; then
    sed -i -e 's!Icon=.*!Icon=/usr/share/icons/hicolor/48x48/apps/firefox.png!' "$desktop_file"
    chmod +x "$desktop_file"
  fi
}

# Limpiar instalación
cleanup() {
  case "$distro" in
    ubuntu|debian|kali|parrot)
      apt-get autoclean
      rm -rf /var/lib/apt/lists/* /var/tmp/*
      ;;
    oracle*|rockylinux*|rhel*|almalinux*|fedora*)
      dnf clean all
      ;;
    opensuse)
      zypper clean --all
      ;;
  esac
}

# Instalar Firefox y configurar icono de escritorio
install_firefox
configure_desktop_icon
cleanup

echo "Instalación de Firefox completada con éxito."
