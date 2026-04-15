function claude
    if test -f /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json
        set fish_trace 1
        set -x META_CLAUDE_CODE_RELEASE latest
        set -x META_CLAUDE_BASH_WRAPPER_DEBUG 1
        command claude --settings /home/ajaysriv/.dotfiles/dotfiles/claude/settings.json $argv
    else
        command claude
    end
end
