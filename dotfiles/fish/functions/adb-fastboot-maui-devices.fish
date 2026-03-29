function adb-fastboot-maui-devices
    set fish_trace 1
    adb devices && fastboot devices && maui query devices
end
