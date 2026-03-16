function rcb
    r && fish -c "fish_prompt && echo '$argv' && $argv" 2>&1 | cb
end
