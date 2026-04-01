function adb-fastboot-lsusb-devices
    set fish_trace 1
    watch -n 0.1 "printf -- '--> adb devices\n'; adb devices; printf -- '--> fastboot devices\n'; fastboot devices; printf -- '\n--> lsusb\n'; lsusb"
end
