function claude
    set fish_trace 1
    # set -x META_CLAUDE_CODE_RELEASE latest
    set -x META_CLAUDE_BASH_WRAPPER_DEBUG 1
    command claude $argv
end
