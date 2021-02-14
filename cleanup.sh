#!/usr/bin/env bash

if [[ $OSTYPE != "linux-gnu" ]]; then
	printf "This Cleanup Script Should Be Run On Ubuntu Runner.\n"
	exit 1
fi

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

# Prepare
while ((${SECONDS_LEFT:=5} > 0)); do
    printf "Please wait %ss ...\n" "${SECONDS_LEFT}"
    sleep 1
    SECONDS_LEFT=$((${SECONDS_LEFT} - 1))
done
unset SECONDS_LEFT

echo "::group::Disk Space Before Cleanup"
df -hlT -t ext4
echo "::endgroup::"

echo "::group::Clearing Docker Image Caches"
docker rmi -f $(docker images -q) &>/dev/null
echo "::endgroup::"

echo "::group::Uninstalling Unnecessary Applications"
sudo -E apt-get -qq -y update &>/dev/null
sudo -E apt-get -qq -y purge \
	adoptopenjdk-* \
	adwaita-icon-theme \
	aisleriot \
	alsa-* \
	ant* \
	ansible \
	apache2* \
	apport* \
	aspnetcore-* \
	azure-cli \
	bazel* \
	brltty \
	buildah \
	byobu \
	cabal-* \
	chromium-browser \
	clang-8 clang-format-8 \
	clang-9 clang-format-9 \
	cpp-7 cpp-8 \
	dotnet* \
	duplicity \
	empathy \
	empathy-common \
	erlang* esl-erlang \
	example-content \
	firebird* firefox \
	fontconfig* fonts-* \
	g++-7* gcc-7* \
	g++-8* gcc-8* \
	gfortran* \
	gh \
	ghc* \
	gnome-accessibility-themes \
	google-chrome* google-cloud-sdk \
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
	kubectl \
	landscape-common \
	libclang1-8 libclang-common-8-dev \
	libmono-* \
	libpython2* \
	libreoffice-* \
	libsane libsane-common \
	lld-8 llvm-8* \
	man-db manpages \
	mercurial mercurial-common \
	mongodb-* \
	mono-* mono* \
	msodbcsql* mssql-tools mysql* libmysqlclient* unixodbc-dev \
	nginx \
	nuget \
	odbcinst* \
	openjdk* \
	packagekit* \
	packages-microsoft-prod \
	php-* php5* php7* php8* snmp \
	plymouth plymouth-theme-ubuntu-text \
	podman podman-plugins \
	poppler-data \
	popularity-contest \
	postgresql* libpq-dev \
	printer-driver-* \
	python2 python2-minimal \
	rake r-base* r-cran-* r-recommended ruby* \
	rhythmbox rhythmbox-plugin* \
	sane-utils \
	sbt \
	session-manager-plugin \
	shotwell* \
	skopeo \
	snapd \
	sphinxsearch \
	sound-theme-freedesktop \
	subversion \
	swig* \
	telepathy-* \
	totem* \
	ubuntu-mono \
	vim vim-* \
	xvfb \
	yarn \
	zulu* &>/dev/null
sudo -E apt-get -qq -y autoremove &>/dev/null
echo "::endgroup::"

echo "::group::Removing Homebrew Completely"
curl -sL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh -o uninstall-brew.sh && chmod a+x uninstall-brew.sh
./uninstall-brew.sh -f -q 2>/dev/null
sudo rm -rf -- ./uninstall-brew.sh /home/linuxbrew 2>/dev/null
echo "::endgroup::"

echo "::group::Removing NodeJS, NPM & NPX"
{
	sudo npm list -g --depth=0. 2>/dev/null | awk -F ' ' '{print $2}' | awk -F '@[0-9]' '{print $1}' | sudo xargs npm remove -g
	yes | sudo n uninstall
	sudo rm -rf -- /usr/local/lib/node_modules /usr/local/n \
		/usr/local/bin/vercel /usr/local/bin/now
} 2>/dev/null
echo "::endgroup::"

echo "::group::Purging PIPX & PIP packages"
{
	pipx uninstall-all && sudo pip uninstall -q -y pipx
	find /usr/share /usr/lib ~/.local/lib -depth -type d -name __pycache__ \
		-exec rm -rf '{}' + 2>/dev/null;
} 2>/dev/null
echo "::endgroup::"

echo "::group::Removing Lots of Cached Programs & Unneeded Folders"
{
	printf "Removing Runner Tool Cache...\n"
	sudo rm -rf -- /opt/hostedtoolcache/*
	printf "Removing Android SDK, NDK, Platform Tools, Gradle, Maven...\n"
	sudo rm -rf -- /usr/local/lib/android
	sudo rm -rf -- /usr/share/gradle* /usr/bin/gradle /usr/share/apache-maven* /usr/bin/mvn
	printf "Removing Microsoft vcpkg, Miniconda, Leiningen, Pulumi...\n"
	sudo rm -rf -- /usr/local/share/vcpkg /usr/local/bin/vcpkg
	sudo rm -rf -- /usr/share/miniconda /usr/bin/conda
	sudo rm -rf -- /usr/local/lib/lein /usr/local/bin/lein /usr/local/bin/pulumi*
	printf "Removing Browser-based Webdrivers...\n"
	sudo rm -rf -- /usr/share/java/selenium-server-standalone.jar \
		/usr/local/share/phantomjs* /usr/local/bin/phantomjs \
		/usr/local/share/chrome_driver /usr/bin/chromedriver \
		/usr/local/share/gecko_driver /usr/bin/geckodriver
	printf "Removing PHP, Composer, Database Management Program Remains...\n"
	sudo rm -rf -- /etc/php /usr/bin/composer /usr/local/bin/phpunit
	sudo rm -rf -- /etc/mysql /usr/local/bin/sqlcmd /usr/local/bin/bcp
	printf "Removing Julia, Rust, Cargo, Swift, Haskell, Erlang...\n"
	sudo rm -rf -- /usr/local/julia* /usr/bin/julia
	sudo rm -rf -- /usr/share/rust /home/runner/.cargo /home/runner/.rustup
	sudo rm -rf -- /usr/share/swift /usr/local/bin/swift /usr/local/bin/swiftc
	sudo rm -rf -- /usr/bin/ghc /usr/bin/cabal /usr/local/bin/stack
	sudo rm -rf -- /usr/local/bin/rebar3
	printf "Removing Various Cloud CLI Tools...\n"
	sudo rm -rf -- /usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli /usr/local/aws
	sudo rm -rf -- /usr/local/bin/aliyun /usr/share/az_* /opt/az /usr/bin/az \
		/usr/local/bin/azcopy10 /usr/bin/azcopy /usr/lib/azcopy
	sudo rm -rf -- /usr/local/bin/oc /usr/local/bin/oras
	printf "Removing Different Kubernetes & Container Management Programs...\n"
	sudo rm -rf -- /usr/local/bin/packer /usr/local/bin/terraform \
		/usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/kind \
		/usr/local/bin/kustomize /usr/local/bin/minikube \
		/usr/libexec/catatonit/catatonit
	printf "Removing Microsoft dotnet Application Remains...\n"
	sudo rm -rf -- /usr/share/dotnet
	printf "Removing Java GraalVM...\n"
	sudo rm -rf -- /usr/local/graalvm
	printf "Removing Manpages...\n"
	sudo rm -rf -- /usr/share/man
} 2>/dev/null
echo "::endgroup::"

echo "::group::Clearing Remains of Apt Packages"
{
	sudo -E apt-get -qq -y clean && sudo -E apt-get -qq -y autoremove
	sudo rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/*
	export PATH="/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
	sed -i '/.dotnet/d' ~/.bashrc 2>/dev/null
	sed -i '/.config\/composer/d' ~/.bashrc 2>/dev/null
	. ~/.bashrc 2>/dev/null
} 2>/dev/null
echo "::endgroup::"

echo "::group::Disk Space After Cleanup"
df -hlT -t ext4
echo "::endgroup::"
