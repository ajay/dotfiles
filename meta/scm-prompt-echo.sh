#!/bin/bash

export SHOW_DIRTY_STATE=TRUE
export SHOW_DIRTY_STATE_COLORS=TRUE

if [[ -f /usr/share/scm/scm-prompt.sh ]]; then
    source /usr/share/scm/scm-prompt.sh

    _hg_color_char() {
        local c="$1"
        case "$c" in
            '?') builtin printf '\033[1;95m%s\033[0m' "$c" ;;  # purple
            'A') builtin printf '\033[1;92m%s\033[0m' "$c" ;;  # green
            'M') builtin printf '\033[1;94m%s\033[0m' "$c" ;;  # blue
            'R') builtin printf '\033[1;91m%s\033[0m' "$c" ;;  # red
            *)   builtin printf '%s' "$c" ;;
        esac
    }

    _hg_dirty() {
        if [ -n "${SHOW_DIRTY_STATE}" ] &&
             [ "$(command sl config shell.showDirtyState)" != "false" ]; then
                 local chars
                 chars="$(command sl status 2> /dev/null |
                       command awk '{print $1}' |
                       command sort |
                       command uniq |
                       command paste -sd ' ' -)"
                 if [ -n "${SHOW_DIRTY_STATE_COLORS}" ]; then
                     local i c
                     for ((i = 0; i < ${#chars}; i++)); do
                         c="${chars:$i:1}"
                         if [[ "$c" == " " ]]; then
                             continue
                         fi
                         _hg_color_char "$c"
                     done
                 else
                     builtin printf '%s' "$chars"
                 fi
        fi
    }

    echo -n "$(_scm_prompt)"
fi
