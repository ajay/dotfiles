function codehub-fbsource
    set hg_root $(hg root); or return $status
    set repo_rooted_path $(realpath -s --relative-to=$hg_root $argv); or return $status

    set fish_trace 1
    google-chrome https://www.internalfb.com/code/fbsource/$repo_rooted_path
end
