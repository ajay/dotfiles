function adb-root-remount-shell
    set fish_trace 1
    adb wait-for-device && adb root && adb remount && adb shell
end
