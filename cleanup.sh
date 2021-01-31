#!/usr/bin/env bash

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

printf "Disk Space Before Cleanup...\n"
df -hlT -t ext4

printf "Clearing Docker Image Caches...\n"
docker rmi -f $(docker images -q) &>/dev/null

printf "Uninstalling Unnecessary Applications...\n"
sudo -E apt-get -qq -y purge \
	adoptopenjdk-11-hotspot \
	adoptopenjdk-8-hotspot \
	adwaita-icon-theme \
	aisleriot \
	alsa-* \
	ant \
	ant-optional \
	azure-cli \
	bazel* \
	brltty \
	buildah \
	byobu \
	cabal-* \
	chromium-browser \
	clang-8 \
	clang-9 \
	clang-format-8 \
	clang-format-9 \
	cpp-7 \
	cpp-8 \
	dotnet* \
	duplicity \
	empathy \
	empathy-common \
	erlang* \
	esl-erlang \
	example-content \
	firebird* \
	firefox \
	fontconfig* \
	fonts-* \
	g++-7 \
	g++-8 \
	gcc-7 \
	gcc-8 \
	gfortran* \
	gh \
	ghc* \
	gnome-accessibility-themes \
	gnome-contacts \
	gnome-mahjongg \
	gnome-mines \
	gnome-orca \
	gnome-screensaver \
	gnome-sudoku \
	gnome-video-effects \
	google* \
	groff-base \
	gsfonts \
	gtk-update-icon-cache \
	heroku \
	hhvm \
	hicolor-icon-theme \
	htop \
	humanity-icon-theme \
	imagemagick* \
	info \
	install-info \
	irqbalance \
	landscape-common \
	libclang1-8 \
	libclang-common-8-dev \
	libmono-* \
	libpython2* \
	libreoffice-avmedia-backend-gstreamer \
	libreoffice-base-core \
	libreoffice-calc \
	libreoffice-common \
	libreoffice-core \
	libreoffice-draw \
	libreoffice-gnome \
	libreoffice-gtk \
	libreoffice-impress \
	libreoffice-math \
	libreoffice-ogltrans \
	libreoffice-pdfimport \
	libreoffice-style-galaxy \
	libreoffice-style-human \
	libreoffice-writer \
	libsane \
	libsane-common \
	lld-8 \
	llvm-8* \
	man-db \
	manpages \
	mercurial \
	mercurial-common \
	mongodb-* \
	mono* \
	msodbcsql* \
	mssql-tools \
	mysql* \
	odbcinst* \
	openjdk* \
	php* \
	plymouth \
	plymouth-theme-ubuntu-text \
	podman \
	podman-plugins \
	poppler-data \
	popularity-contest \
	postgresql* \
	powershell \
	printer-driver-brlaser \
	printer-driver-foo2zjs \
	printer-driver-foo2zjs-common \
	printer-driver-m2300w \
	printer-driver-ptouch \
	printer-driver-splix \
	python2 \
	python2-minimal \
	python3-uno \
	rake \
	r-base-* \
	r-cran-* \
	rhythmbox \
	rhythmbox-plugins \
	rhythmbox-plugin-zeitgeist \
	r-recommended \
	ruby* \
	sane-utils \
	shotwell \
	shotwell-common \
	sound-theme-freedesktop \
	subversion \
	swig* \
	telepathy-gabble \
	telepathy-idle \
	telepathy-indicator \
	telepathy-logger \
	telepathy-mission-control-5 \
	totem \
	totem-common \
	totem-plugins \
	ubuntu-mono \
	vim \
	vim-runtime \
	xvfb \
	yarn \
	zulu* &>/dev/null
sudo -E apt-get -qq -y autoremove &>/dev/null

printf "Removing Homebrew...\n"
curl -sL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh -o uninstall-brew.sh && chmod a+x uninstall-brew.sh
./uninstall-brew.sh -f -q &>/dev/null
rm -f ./uninstall-brew.sh &>/dev/null

printf "Removing NodeJS, NPM & NPX, PIPX & PIP packages...\n"
sudo npm list -g --depth=0. 2>/dev/null | awk -F ' ' '{print $2}' | awk -F '@[0-9]' '{print $1}' | sudo xargs npm remove -g &>/dev/null
sudo rm -rf -- /usr/local/lib/node_modules /usr/local/n &>/dev/null
pipx uninstall-all &>/dev/null
pip freeze --local | xargs sudo pip uninstall -y &>/dev/null
find /usr/share /usr/lib /snap ~/.local/lib -depth -type d -name __pycache__ -exec rm -rf '{}' + 2>/dev/null; &>/dev/null

printf "Removing Lots of Cached Programs & Unneeded Folders...\n"
sudo rm -rf -- \
	/usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli \
	/usr/share/az_* \
	/opt/az \
	/usr/share/dotnet \
	/usr/local/graalvm \
	/etc/mysql \
	/etc/php \
	/etc/apt/sources.list.d/* \
	/opt/hostedtoolcache/* \
	/usr/local/julia* \
	/usr/local/lib/android \
	/usr/share/gradle* \
	/usr/share/apache-maven* \
	/usr/local/lib/lein /usr/local/bin/lein \
	/usr/share/rust /home/runner/.cargo /home/runner/.rustup \
	/usr/share/swift \
	/usr/share/miniconda \
	/usr/local/share/phantomjs* /usr/local/share/chrome_driver /usr/local/share/gecko_driver \
	/home/linuxbrew \
	/usr/share/man \
	&>/dev/null

printf "Clearing Dangling Remains of Applications...\n"
sudo -E apt-get -qq -y clean &>/dev/null
sudo -E apt-get -qq -y autoremove &>/dev/null
sudo rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* &>/dev/null

export PATH="/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
sed -i '/.dotnet/d' ~/.bashrc &>/dev/null
sed -i '/.config\/composer/d' ~/.bashrc &>/dev/null
. ~/.bashrc &>/dev/null

printf "Disk Space After Cleanup...\n"
df -hlT -t ext4
