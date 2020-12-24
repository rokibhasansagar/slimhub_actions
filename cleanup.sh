#!/usr/bin/env bash

docker rmi -f `docker images -q`

sudo -E apt-get -qq -y remove --purge aisleriot brltty duplicity empathy empathy-common example-content gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects landscape-common libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-impress libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-style-galaxy libreoffice-style-human libreoffice-writer libsane libsane-common python3-uno rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist sane-utils shotwell shotwell-common telepathy-gabble telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 totem totem-common totem-plugins printer-driver-brlaser printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-m2300w printer-driver-ptouch printer-driver-splix azure-cli ghc* zulu* hhvm llvm* firefox google* dotnet* powershell openjdk* mysql* php* heroku mono* libmono-* mongodb-* postgresql* bazel* firebird* man-db ruby* rake
sudo rm -rf /usr/share/dotnet /etc/mysql /etc/php /etc/apt/sources.list.d
sudo -E apt-get -q clean && sudo -E apt-get -q autoremove

