function rcb
    printf '\33c\e[3J' && fish -c "fish_prompt && echo '$argv' && $argv" 2>&1 | cb
end
