set -x LESSOPEN "| /usr/share/source-highlight/src-hilite-lesspipe.sh %s" $LESSOPEN;
set -x LESS ' -R -x4 -N -S ' $LESS;
