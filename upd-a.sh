#/bin/bash
mangadex-dl --update;
pip install -U requests; # A dependency of mangadex-dl.
pip install -U yt-dlp;
pip install -U himawari-api;
rustup update;
flatpak update;
sudo apt update;
sudo apt upgrade;
sudo update-grub;
