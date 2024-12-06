#!/usr/bin/env bash
set -xe
trap 'echo "Error en la línea $LINENO."' ERR

# Detectar distribución
DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
if [[ "$DISTRO" =~ (ol|oracle|ubuntu) ]]; then
  DISTRO="ubuntu"
fi

install_firefox() {
  if [[ "$DISTRO" == "ubuntu" ]]; then
    if grep -q Jammy /etc/os-release || grep -q Noble /etc/os-release; then
      add-apt-repository -y ppa:mozillateam/ppa
      echo -e 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla-firefox
    fi
    apt-get update
    apt-get install -y firefox --allow-downgrades
    apt-get install -y p11-kit-modules 
    apt autoremove -y
  else
    case "$DISTRO" in
      oracle*|rockylinux*|rhel*|almalinux*|fedora*)
        dnf install -y firefox p11-kit ;;
      opensuse)
        zypper install -yn p11-kit-tools MozillaFirefox ;;
    esac
  fi
}

# Mover icono del escritorio si está disponible
# Desktop icon
cat >/usr/share/applications/firefox.desktop <<EOL
[Desktop Entry]
Type=Application
Name=Firefox
Icon=Icon=/usr/share/icons/hicolor/48x48/apps/firefox.png
Exec=firefox %u
Comment=Filrefox navegador
Categories=Development;Code;
EOL
chmod +x /usr/share/applications/firefox.desktop
cp /usr/share/applications/firefox.desktop $HOME/Desktop/firefox.desktop
chmod +x $HOME/Desktop/firefox.desktop

# Crear archivo de preferencias
prefs_file="/usr/lib/firefox/browser/defaults/preferences/firefox.js"
mkdir -p "$(dirname "$prefs_file")"
touch "$prefs_file"

# Ejecutar funciones principales
install_firefox
set_desktop_icon
echo "Firefox instalado correctamente en $DISTRO."
