function google-chrome-open-bookmark-folder --argument-names folder
    if test -z "$folder"
        echo "usage: google-chrome-open-bookmark-folder <folder>" >&2
        return 1
    end

    set -l bookmarks ~/.config/google-chrome/Default/Bookmarks
    if not test -f "$bookmarks"
        echo "no Chrome bookmarks file at $bookmarks" >&2
        return 1
    end

    # recurse() is pre-order, so nested subfolders flatten in Chrome's "Open all" order.
    set -l urls (jq -r --arg f "$folder" \
        '[.. | objects | select(.type == "folder" and .name == $f)][0]
         | [recurse(.children[]?) | select(.type == "url")] | .[].url' \
        "$bookmarks")

    if test (count $urls) -eq 0
        echo "no bookmarks in folder '$folder'" >&2
        return 1
    end

    set fish_trace 1
    google-chrome --new-window $urls
end
