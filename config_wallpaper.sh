sudo mkdir -p /usr/share/backgrounds
sudo magick -size 1920x1080 xc:black /usr/share/backgrounds/black.png

feh --bg-fill /usr/share/backgrounds/black.png
cat << EOF > ~/.fehbg
feh --bg-fill /usr/share/backgrounds/black.png
EOF
