# TODO
- [ ] Switch terminal to alacritty or equivalent (defaults, shortcuts, workspace-setup)
- [ ] Set default brightness to max on boot/login
- [ ] Bump build-tools in samantha/genealogy so it can be un-commented in `ajay-github-*` REPOS lists

# Done
- [x] udev rules - JLink, saleae, openocd / STLink, adb (`shell-udev` + `shell-jlink`; openocd/stlink, the SEGGER RPM and the Saleae Logic download all ship their own rules, so only adb is carried here)
- [x] Add `npm` dep (probably in `build-tools`)
- [x] Enable middle click paste by default (currently in gnome-tweaks)
- [x] Switch dotbot-pip from submodule to local plugin; add functionality to specify pip binary and perform pip upgrades
