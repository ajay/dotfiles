# Fresh install ubuntu 20.04

## X1EG2
- Use nvidia-driver-435 instead of nvidia-driver-440 to have external monitors work

```
# update
sudo apt update; sudo apt upgrade; sudo apt dist-upgrade; sudo apt autoremove

# dotfiles
mkdir work
git clone https://github.com/ajay/dotfiles ~/work/dotfiles

# chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg –i google-chrome-stable_current_amd64.deb

# packages
sudo apt install fish gnome-tweak-tool git gcc sshfs apcalc vlc tree source-highlight vim grub-customizer

# bash
alias ..='cd ..'

# fish
chsh -s `which fish`
set fish_greeting
sudo apt install wmctrl renameutils
ln -s ~/work/dotfiles/fish/functions ~/.config/fish/
ln -s ~/work/dotfiles/fish/config.fish ~/.config/fish/

# sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt install sublime-text

ln -s ~/work/dotfiles/sublime/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/
ln -s ~/work/dotfiles/sublime/Default\ \(Linux\).sublime-keymap ~/.config/sublime-text-3/Packages/User/

# vim
ln -s ~/work/dotfiles/vim/.vimrc ~/

# git
ln -s ~/work/dotfiles/git/.gitconfig ~/
```

### chrome
- Log into chrome & sync
- Hide most extensions in chrome menu

### settings
- Appearance
    - Window colors: Dark
    - Dock: Auto hide, show on all displays
- Date & Time
    - AM / PM
- Sound
    - Over-Amplification on

### dock
- order:
    1. Terminal
    2. Nautilus
    3. Chrome

### tweaks
- General
    - Animations off
    - Suspend when lid is closed off
- Extensions
    - Desktop Icons on
        - Hide personal folder, hide trash
- Top Bar
    - Enable battery percentage, weekday, week numbers
- Workspaces
    - Static: 4
    - Span displays

### terminal
- Profiles
    - Colors
        - uncheck use colors from system theme use gray on black
        - uncheck use transparency from system theme, transparent background, about 25%

### mouse / keyboard
```
# mouse
sudo apt install imwheel piper
ln -s ~/work/dotfiles/imwheel/.imwheelrc ~/

# bluetooth keyboard
echo "options hid_apple fnmode=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
```

### startup script
Add `~/work/dotfiles/startup/x1eg2.sh` to startup from gui

### grub customizer
set timeout to 1s
set custom resolution to 1024x768

## Work / RP
- AnyConnect VPN
    - `sudo apt install libpangox-1.0-0 libcanberra-gtk-module`
- Slack
    - get deb from website
- Ozone
- Setup bitbucket ssh key

```
mkdir ~/build_server
sshfs -o cache=no -o no_readahead -o sshfs_sync -o sync_readdir ajay@build.romeopowered.com:/build_server build_server/
```
