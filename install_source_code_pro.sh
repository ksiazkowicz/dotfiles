#!/bin/sh
# Based on this gist: 
# https://gist.github.com/enzinier/8d00d3f37d2e23985dcfa65662d163fa
# added Haiku support

os=`uname -o`

# set $FONT_HOME variable
FONT_HOME=~/.local/share/fonts
if [ $os = "Haiku" ]; then
    FONT_HOME=/system/non-packaged/data/fonts
fi

echo "installing fonts to $FONT_HOME"
mkdir -p "$FONT_HOME/adobe-fonts/source-code-pro"

(git clone \
   --branch release \
   --depth 1 \
   'https://github.com/adobe-fonts/source-code-pro.git' \
   "$FONT_HOME/adobe-fonts/source-code-pro" && \
fc-cache -f -v "$FONT_HOME/adobe-fonts/source-code-pro")
