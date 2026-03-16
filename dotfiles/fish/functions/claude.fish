function claude
    if test -f /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json
        echo "Running `claude --settings /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json \\\$argv`"
        bash -c "$(command -v claude) $argv"
    else
        bash -c "$(command -v claude) $argv"
    end
end
