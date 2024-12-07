#!/usr/bin/env bash
set -xe
trap 'echo "error en la línea $lineno."' err

# detectar distribución
distro=$(grep '^id=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
if [[ "$distro" =~ (ol|oracle|ubuntu) ]]; then
  distro="ubuntu"
fi

install_firefox() {
  if [[ "$distro" == "ubuntu" ]]; then
    if grep -q jammy /etc/os-release || grep -q noble /etc/os-release; then
      add-apt-repository -y ppa:mozillateam/ppa
      echo -e 'package: *\npin: release o=lp-ppa-mozillateam\npin-priority: 1001' > /etc/apt/preferences.d/mozilla-firefox
    fi
    apt-get update
    apt-get install -y firefox --allow-downgrades
    apt-get install -y p11-kit-modules 
    apt autoremove -y
  else
    case "$distro" in
      oracle*|rockylinux*|rhel*|almalinux*|fedora*)
        dnf install -y firefox p11-kit ;;
      opensuse)
        zypper install -yn p11-kit-tools mozillafirefox ;;
    esac
  fi
}

set_desktop_icon() {
  # mover icono del escritorio si está disponible
  cat >/usr/share/applications/firefox.desktop <<eol
[Desktop Entry]
Type=Application
Name=Firefox
Icon=/usr/share/icons/hicolor/48x48/apps/firefox.png
Exec=firefox %u
Comment=Firefox navegador
Categories=Development;Code;
eol
  chmod +x /usr/share/applications/firefox.desktop

  # Copiar el icono al escritorio del usuario
  home="$HOME"  # Asegúrate de que se está utilizando la ruta esperada
  cp /usr/share/applications/firefox.desktop "$home/Desktop/firefox.desktop"  # Corrige el uso de la variable de entorno para el escritorio
  chmod +x "$home/Desktop/firefox.desktop"
}

# crear archivo de preferencias
prefs_file="/usr/lib/firefox/browser/defaults/preferences/firefox.js"
mkdir -p "$(dirname "$prefs_file")"
touch "$prefs_file"

# ejecutar funciones principales
install_firefox
set_desktop_icon
echo "Firefox instalado correctamente en $distro."
