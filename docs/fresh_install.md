# Fresh install

## Overview

- OS: Fedora
- HW: ThinkPad P1 Laptop (Nvidia GPU) / ThinkStation P8 Desktop (Nvidia GPU)

## Setup

- BIOS
    - ThinkPad P1
        - Config -> Keyboard/Mouse: F1-F12 as primary function (set FN key to always be enabled)
    - ThinkStation P8
        - Advanced -> CPU Setup -> C State Support: Disabled

- Bootstrap
    - Setup git ssh keys (manual)
    - Clone dotfiles + install
        ```
        git clone git@github.com:ajay/dotfiles.git ~/.dotfiles
        make -C ~/.dotfiles install
        ```
    - Update firmware
        ```
        sudo fwupdmgr update
        ```
    - Log out and back in (picks up fish shell, GNOME extensions, dock layout)

- Insync
    - Setup ajaysriv@meta.com sync to ~/mdrive
    - Setup ajaysriv3@gmail.com sync to ~/gdrive

- Chrome
    - Sign in, turn on sync
        - ajaysriv@meta.com

- Sublime
    - Ctrl+Shift+P -> Install Package Control

- Meta
    - `fbclone fbsource --eden`
    - `jf authenticate`
    - `dev doctor && eden doctor`
