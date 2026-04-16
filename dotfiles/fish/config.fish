fish_add_path ~/.local/bin

set -e LESSOPEN; set -x LESSOPEN "| /usr/bin/src-hilite-lesspipe.sh %s" $LESSOPEN;
set -e LESS; set -x LESS ' -R -x4 -N -S ' $LESS;
set -e EDITOR; set -x EDITOR "/usr/bin/subl -w" $EDITOR;

bind alt-backspace backward-kill-word
bind ctrl-backspace backward-kill-token
bind alt-delete kill-word
bind ctrl-delete kill-token
