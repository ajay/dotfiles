function tree-no-submodules
    # set fish_trace 1

    set git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$git_root"; or not test -f "$git_root/.gitmodules"
        tree $argv
        return
    end

    set subs
    for p in (grep 'path = ' "$git_root/.gitmodules" | sed 's/.*path = //')
        set rel (realpath --relative-to=. "$git_root/$p" 2>/dev/null)
        if test -n "$rel"; and not string match -q '..*' "$rel"
            set -a subs $rel
        end
    end

    if test (count $subs) -eq 0
        tree $argv
        return
    end

    set ESC \e
    set SUBS (string join '|' $subs)
    find . -mindepth 1 -not -path './.git/*' -not -name '.git' \
        | grep -Fvf (printf './%s/\n' $subs | psub) \
        | sed 's|^\./||' | sort | tree -C $argv --fromfile . \
        | sed -E "s%$SUBS%"$ESC"[1;36m&"$ESC"[0m%"
end
