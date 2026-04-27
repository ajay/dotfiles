function logout
    set fish_trace 1
    sleep 5 && gnome-session-quit --logout --no-prompt
end
