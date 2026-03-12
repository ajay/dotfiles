function codehub-fbsource
    google-chrome https://www.internalfb.com/code/fbsource/$(realpath -s --relative-to=$(hg root) $argv)
end
