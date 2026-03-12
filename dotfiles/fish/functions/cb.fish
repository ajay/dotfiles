function cb
    xclip -f && xclip -o | ansifilter | xclip -f | xclip -selection clipboard
end
