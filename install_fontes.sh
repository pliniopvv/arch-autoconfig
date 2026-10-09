cd ~/Downloads
for f in *.zip; do 7z x ""; done
sudo mv *.ttf /usr/share/fonts/
fc-cache -fv
