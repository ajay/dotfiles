# Fresh install ubuntu 18.04

## Install stuff

### Update, upgrade
`sudo apt update; sudo apt upgrade; sudo apt dist-upgrade; sudo apt autoremove`

### Install packages
`sudo apt install fish gnome-tweak-tool git gcc chrome-gnome-shell`


### Install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text


### Install chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg –i google-chrome-stable_current_amd64.deb



## Config

### fish
chsh -s `which fish`
`set fish_greeting`

### Chrome
- Log into chrome & sync
- Hide most extensions in chrome menu

### Small configs
- Set dock to autohide
- Dock order:
    1. Terminal
    2. Nautilus
    3. Chrome
- Change time format to AM/PM from 24hr
- Increase mouse speed a bit, change acceleration profile in tweaks

- Change keyboard shortcuts:
    - View split on left:  Ctrl+Super+Left
    - View split on right: Ctrl+Super+Right
    - Restore window:      Ctrl+Super+Down
    - Maximize window:     Ctrl+Super+Up


### Tweaks
- Appearance:
    - Theme: Adwaita-dark
    - Desktop: show icons on, all others off
    - Extensions
        - Ubuntu appindicators: on
        - Ubuntu dock: on
    - Keyboard & Mouse:
        - Acceleration Profile: default
    - Power
        - Suspend when lid closed: off
    - Top Bar
        - Application menu: on
        - Battery percentage: on
        - Clock
            - Date: on
        - Calendar
            - Week numbers: on
    - Windows 
        - Action key: Alt
    - Workspaces
        - Static, 4
        - Span displays

### Install gnome extensions
- Workspace Grid: `https://extensions.gnome.org/extension/484/workspace-grid/`
    - 2 rows
    - 2 columns
    - hide labels
- AlternateTab: `https://extensions.gnome.org/extension/15/alternatetab/`


## Work stuff

### Programs
- AnyConnect VPN
    - Needs this: 
        1. sudo apt install network-manager-openconnect libpangox-1.0-0 libcanberra-gtk-module libcanberra-gtk3-module
        2. sudo systemctl daemon-reload
- Code composer studio v8.2.0
    - Needs this:
        1. sudo apt install libusb-0.1 libusb-0.1 libgconf2-dev