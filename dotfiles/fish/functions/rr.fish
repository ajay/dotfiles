function rr
    printf '\33c\e[3J' && fish_prompt && echo $argv && $argv
end
