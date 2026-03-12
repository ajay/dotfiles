set -e LESSOPEN; set -x LESSOPEN "| /usr/bin/src-hilite-lesspipe.sh %s" $LESSOPEN;
set -e LESS; set -x LESS ' -R -x4 -N -S ' $LESS;
set -e EDITOR; set -x EDITOR "/usr/bin/subl -w" $EDITOR;
