function claude
    set fish_trace 1
    set -x META_CLAUDE_BASH_WRAPPER_DEBUG 1
    set -x META_CLAUDE_CODE_RELEASE latest
    set -x CLAUDE_CODE_DISABLE_AGENT_VIEW 1
    command claude \
        --model 'claude-opus-5[1m]' \
        --effort ultracode \
        --dangerously-enable-internet-mode \
        $argv
end
