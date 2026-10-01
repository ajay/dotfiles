function reboot
    if not isatty stdin
        echo "reboot: no terminal to confirm on; use: command reboot" >&2
        return 1
    end
    read -l -P "Reboot $hostname? [y/N] " answer
    or return 1
    if not string match -qir '^y(es)?$' -- $answer
        echo "reboot: not rebooting" >&2
        return 1
    end
    printf "Rebooting in 3 s, Ctrl-C cancels:"
    for i in 3 2 1
        printf " %d" $i
        sleep 1
        or return 1
    end
    echo
    set fish_trace 1
    command reboot $argv
end
