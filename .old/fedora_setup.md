# Fedora workstation setup

## Overview

- Version: Fedora 38
- HW: P620, T14s

## Setup

- Install packages
    ```
    sudo dnf update && sudo dnf upgrade && sudo dnf autoremove
    sudo dnf install gnome-tweaks fish meld vim htop s-tui hydrapaper
    sudo fwupdmgr update
    ```

- Chrome
    - Install
        ```
        # https://docs.fedoraproject.org/en-US/quick-docs/installing-chromium-or-google-chrome-browsers/

        sudo dnf install fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install google-chrome-stable
        ```
    - Sign in, turn on sync
        - ajaysriv@meta.com

- Fedora
    - Set default shell to fishq
        ```
        chsh -s /usr/bin/fish
        set fish_greeting
        ```
    - Settings
        - Appearance
            - Style -> Dark
        - Multitasking
            - Fixed number of workspaces: 6
            - Workspaces on all displays
        - System -> Date and Time
            - Time format: 12 hour
            - Enable:
                - Week Day
                - Date
                - Seconds
                - Week Numbers
        - Keyboard
            - Shortcuts: Add custom shortcut for gnome-terminal or ptyxis (Ctrl+Alt+T)
                ```
                ptyxis --new-window
                ```
            - Shortcuts: Change "Switch windows" shortcut to Alt+Tab
        - Power
            - Show battery percentage
    - Gnome Shell Extensions
        - https://extensions.gnome.org/
        - V-Shell (Vertical Workspaces)
            - https://extensions.gnome.org/extension/5177/vertical-workspaces/
            - Layout
                - Dash position: Left, Centered at 0
                - Workspace thumbnail position: Right, Centered at 0
        - Tactile
    - Gnome tweaks
        - General
            - Over-amplification: On
        - Fonts
            - Scaling factor: 1.5 (laptop only)
    - Dock
        - Set application order: 1 terminal, 2 files, 3 chrome
    - Hydrapaper
        - Set dual screen wallpaper

- Sublime
    - Install

        ```
        # https://www.sublimetext.com/docs/linux_repositories.html

        sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        sudo dnf install sublime-text
        ```

    - Add plugins
        - Ctrl+Shift+P -> Install Package Control
        - Ctrl+Shift+P -> Install Package ->
            - MarkdownLivePreview
            - Devicetree syntax highlighting
            - BazelSyntax

    - Theme -> Adaptive

- Insync
    - Install
        - https://www.insynchq.com/downloads/linux#fedora
    - Setup ajaysriv@meta.com sync to ~/mdrive
    - Setup ajaysriv3@gmail.com sync to ~/gdrive

- Meta
    - Run chef
        ```
        sudo soloctl -Hic
        kdestroy && kinit
        dev doctor && eden doctor
        ```
    - Fmenu -> fixmylinux
    - `fbclone fbsource --eden`
    - `jf authenticate`

- Dotfiles / configs
    - hg_shell
    - fish
    - sublime

- Nvidia drivers
    - Fedora 38 + Nvidia RTX cards only! (if you have a 3rd "Unknown display")
        - https://discussion.fedoraproject.org/t/fedora-38-nvidia-driver-issue/81470

            ```
            sudo nano /etc/default/grub
            # Add nvidia-drm.modeset=1 to GRUB_CMDLINE_LINUX line
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            reboot
            ```

- Thinkpads
    - BIOS
        - Config->Keyboard/Mouse: F1-F12 as primary function (set FN key to always be enabled)

- DNF updates (post F41):
```
sudo dnf -y update --disablerepo=cpe-yum-fb-runtime --disablerepo=cpe-yum-any --disablerepo=cpe-yum-any-noarch && sudo dnf -y upgrade --disablerepo=cpe-yum-fb-runtime --disablerepo=cpe-yum-any --disablerepo=cpe-yum-any-noarch && sudo dnf -y autoremove --disablerepo=cpe-yum-fb-runtime --disablerepo=cpe-yum-any --disablerepo=cpe-yum-any-noarch && sudo akmods
```
