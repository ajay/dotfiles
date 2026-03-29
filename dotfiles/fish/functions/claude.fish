function claude
    if test -f /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json
        set fish_trace 1
        command claude --settings /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json $argv
    else
        command claude
    end
end
