#!/usr/bin/env bash
set -xe

ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')
DESKTOP_FILE="/dockerstartup/install/ubuntu/install/firefox/firefox.desktop"
EXTENSION_DIR="/usr/lib/firefox-addons/distribution/extensions/"

# Move desktop icon if available
[ -f "$DESKTOP_FILE" ] && mv "$DESKTOP_FILE" "$HOME/Desktop/"

set_desktop_icon() {
  sed -i 's!Icon=.\+!Icon=/usr/share/icons/hicolor/48x48/apps/firefox.png!' "$HOME/Desktop/firefox.desktop"
}

install_firefox() {
  echo "Installing Firefox for $DISTRO"
  case "$DISTRO" in
    oracle*|rockylinux*|rhel*|almalinux*|fedora*)
      dnf install -y firefox p11-kit ;;
    opensuse)
      zypper install -yn p11-kit-tools MozillaFirefox ;;
    *)
      if grep -q Jammy /etc/os-release || grep -q Noble /etc/os-release; then
        add-apt-repository -y ppa:mozillateam/ppa
        echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' \
          > /etc/apt/preferences.d/mozilla-firefox
      fi
      apt-get update
      apt-get install -y firefox p11-kit-modules ;;
  esac
}

download_langpacks() {
  local version=$(curl -sI https://download.mozilla.org/?product=firefox-latest | \
                  awk -F '(releases/|/win32)' '/Location/ {print $2}')
  local url="https://releases.mozilla.org/pub/firefox/releases/$version/win64/xpi/"
  local langs=$(curl -Ls $url | awk -F '(xpi">|</a>)' '/href.*xpi/ {print $2}')
  mkdir -p "$EXTENSION_DIR"
  for lang in $langs; do
    langcode=${lang%.xpi}
    curl -o "${EXTENSION_DIR}langpack-${langcode}@firefox.mozilla.org.xpi" -Ls "${url}${lang}"
  done
}

set_preferences() {
  local prefs_file
  case "$DISTRO" in
    oracle*|rockylinux*|almalinux*|fedora*)
      prefs_file="/usr/lib64/firefox/browser/defaults/preferences/all-redhat.js" ;;
    opensuse)
      prefs_file="/usr/lib64/firefox/browser/defaults/preferences/firefox.js" ;;
    *)
      prefs_file="/usr/lib/firefox/browser/defaults/preferences/firefox.js" ;;
  esac

  cat >"$prefs_file" <<EOF
pref("datareporting.policy.firstRunURL", "");
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.healthreport.service.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("trailhead.firstrun.branches", "nofirstrun-empty");
pref("browser.aboutwelcome.enabled", false);
EOF
}

create_default_profile() {
  chown -R root:root "$HOME"
  firefox -headless -CreateProfile "kasm $HOME/.mozilla/firefox/kasm"
  if [[ "$DISTRO" == oracle* || "$DISTRO" == almalinux* ]]; then
    HOME=/root firefox --headless &
    CERTDB=$(find /root/.mozilla* -name "cert9.db" | head -n 1)
    mv "$CERTDB" "$HOME/.mozilla/firefox/kasm/"
  fi
}

# Main Execution
install_firefox
download_langpacks
set_preferences
create_default_profile
set_desktop_icon
chown -R 1000:1000 "$HOME/.mozilla"
chmod +x "$HOME/Desktop/firefox.desktop"
