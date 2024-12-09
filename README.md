# Firefox Installation and Removal Scripts

This repository contains two scripts for managing Firefox on Ubuntu-based systems.

<a href="https://ko-fi.com/P5P013UUGZ">
    <img src="https://github.com/nuntius-dev/badips/raw/main/kofi.png" alt="comprar cafe" width="150" />
</a>

## Scripts

### `install_firefox.sh`
Installs Firefox from the official repositories or specified sources.

- It checks the system's distribution and installs the correct Firefox version using `apt`, `dnf`, or `zypper` based on the detected OS.

### `remove_firefox.sh`
Removes Firefox from the system, including related dependencies and desktop shortcuts.

- Purges Firefox and its related packages.
- Removes any Firefox desktop icons if present.

## Installation

install fast
```bash
apt install wget -y ; wget https://raw.githubusercontent.com/nuntius-dev/firefox/refs/heads/main/install_firefox.sh ; chmod +x install_firefox.sh ; ./install_firefox.sh
```

Clone the repository and run the respective scripts as needed:

```bash
git clone https://github.com/nuntius-dev/firefox.git
cd firefox
bash install_firefox.sh  # To install Firefox
bash remove_firefox.sh   # To remove Firefox
```

## Requirements
- Ubuntu or compatible Linux distributions
- Internet connection for downloading packages

## License
[MIT](LICENSE)


This README provides a concise explanation of the repository, including installation, removal instructions, and requirements. Let me know if you need further customization!
