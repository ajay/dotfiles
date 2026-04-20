function meld-hg
    set fish_trace 1
    hg extdiff --program meld $argv
end
