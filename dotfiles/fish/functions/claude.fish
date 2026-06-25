function claude
    set fish_trace 1
    set -x META_CLAUDE_BASH_WRAPPER_DEBUG 1
    set -x META_CLAUDE_CODE_RELEASE latest
    command claude \
        --model 'claude-opus-4-8[1m]' \
        --effort max \
        --dangerously-enable-internet-mode \
        $argv
end
