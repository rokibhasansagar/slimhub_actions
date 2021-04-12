#!/usr/bin/env bash

if [[ $OSTYPE != "linux-gnu" ]]; then
	printf "This Cleanup Script Should Be Run On Ubuntu Runner.\n"
	exit 1
fi

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

# Prepare
while ((${SECONDS_LEFT:=10} > 0)); do
	printf "Please wait %ss ...\n" "${SECONDS_LEFT}"
	sleep 1
	SECONDS_LEFT=$((SECONDS_LEFT - 1))
done
unset SECONDS_LEFT

echo "::group::Disk Space Before Cleanup"
df -hlT /
echo "::endgroup::"

echo "::group::Clearing Docker Image Caches"
docker rmi -f $(docker images -q) &>/dev/null
echo "::endgroup::"

echo "::group::Uninstalling Unnecessary Applications"
sudo -EH apt-fast -qq -y update &>/dev/null
REL=$(grep "UBUNTU_CODENAME" /etc/os-release | cut -d'=' -f2)
if [[ ${REL} == "focal" ]]; then
	APT_Pac4Purge="alsa-topology-conf alsa-ucm-conf python2 python2-minimal libpython-dev clang-9 clang-format-9 llvm-10-dev llvm-10-runtime llvm-10-tools llvm-10 lld-10 lld-9 libllvm10 libllvm9 libclang-common-10-dev libclang-cpp10 libclang1-10 clang-10 clang-format-10"
elif [[ ${REL} == "bionic" ]]; then
	APT_Pac4Purge="clang-6.0 clang-format-6.0 libclang-common-6.0-dev libclang1-6.0 liblldb-6.0 libllvm6.0 llvm-6.0-dev lld-6.0"
fi
unset REL
sudo -EH apt-fast -qq -y purge \
	${APT_Pac4Purge} \
	adoptopenjdk-* openjdk* ant* \
	*-icon-theme plymouth *-theme* fonts-* gsfonts gtk-update-icon-cache \
	google-cloud-sdk heroku \
	apache2* nginx msodbcsql* mssql-tools mysql* libmysqlclient* unixodbc-dev postgresql* libpq-dev odbcinst* mongodb-* sphinxsearch \
	apport* popularity-contest \
	aspnetcore-* dotnet* \
	azure-cli session-manager-plugin \
	bazel* \
	brltty byobu htop \
	buildah hhvm kubectl packagekit* podman podman-plugins skopeo \
	chromium-browser firebird* firefox google-chrome* xvfb \
	clang-8 clang-format-8 libclang-common-8-dev libclang1-8 cpp-7 cpp-8 lld-8 llvm-8* libllvm8 liblldb-8 \
	esl-erlang ghc-* groff-base rake r-base* r-cran-* r-recommended ruby* swig* \
	g++-7* gcc-7* g++-8* gcc-8* gfortran* \
	gh subversion mercurial mercurial-common \
	info install-info landscape-common \
	libpython2* imagemagick* libmagic* vim vim-* \
	man-db manpages \
	mono-* mono* libmono-* \
	nuget packages-microsoft-prod snapd yarn \
	php-* php5* php7* php8* snmp \
	&>/dev/null
sudo -EH apt-fast -qq -y autoremove &>/dev/null
echo "::endgroup::"

echo "::group::Removing Homebrew Completely"
curl -sL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh -o uninstall-brew.sh && chmod a+x uninstall-brew.sh
./uninstall-brew.sh -f -q &>/dev/null
sudo rm -rf -- ./uninstall-brew.sh /home/linuxbrew &>/dev/null
echo "::endgroup::"

echo "::group::Removing NodeJS, NPM & NPX"
{
	sudo npm list -g --depth=0. 2>/dev/null | awk -F ' ' '{print $2}' | awk -F '@[0-9]' '{print $1}' | grep -v "^n$" | sudo xargs npm remove -g
	yes | sudo n uninstall
	sudo rm -rf -- /usr/local/lib/node_modules /usr/local/n /usr/local/bin/n \
		/usr/local/bin/vercel /usr/local/bin/now
} &>/dev/null
echo "::endgroup::"

echo "::group::Purging PIPX & PIP packages"
{
	pipx uninstall-all && sudo pip3 uninstall -q -y pipx
	find /usr/share /usr/lib ~/.local/lib -depth -type d -name __pycache__ \
		-exec rm -rf '{}' + 2>/dev/null;
} &>/dev/null
echo "::endgroup::"

echo "::group::Removing Lots of Cached Programs & Unneeded Folders"
{
	printf "Removing Runner Tool Cache...\n"
	sudo rm -rf -- /opt/hostedtoolcache
	printf "Removing Android SDK, NDK, Platform Tools, Gradle, Maven...\n"
	sudo rm -rf -- /usr/local/lib/android \
		/usr/share/gradle* /usr/bin/gradle /usr/share/apache-maven* /usr/bin/mvn
	printf "Removing Microsoft vcpkg, Miniconda, Leiningen, Pulumi...\n"
	sudo rm -rf -- /usr/local/share/vcpkg /usr/local/bin/vcpkg \
		/usr/share/miniconda /usr/bin/conda \
		/usr/local/lib/lein /usr/local/bin/lein /usr/local/bin/pulumi*
	printf "Removing Browser-based Webdrivers...\n"
	sudo rm -rf -- /usr/share/java/selenium-server-standalone.jar \
		/usr/local/share/phantomjs* /usr/local/bin/phantomjs \
		/usr/local/share/chrome_driver /usr/bin/chromedriver \
		/usr/local/share/gecko_driver /usr/bin/geckodriver
	printf "Removing PHP, Composer, Database Management Program Remains...\n"
	sudo rm -rf -- /etc/php /usr/bin/composer /usr/local/bin/phpunit \
		/var/lib/mysql /etc/mysql /usr/local/bin/sqlcmd /usr/local/bin/bcp \
		/usr/local/bin/session-manager-plugin
	printf "Removing Julia, Rust, Cargo, Rubugems, Rake, Swift, Haskell, Erlang...\n"
	sudo rm -rf -- /usr/local/julia* /usr/bin/julia \
		/usr/share/rust /home/runner/.cargo /home/runner/.rustup /home/runner/.ghcup \
		/usr/local/bin/rake /usr/local/bin/rdoc /usr/local/bin/ri /usr/local/bin/racc /usr/local/bin/rougify \
		/usr/local/bin/bundle /usr/local/bin/bundler /var/lib/gems \
		/usr/share/swift /usr/local/bin/swift /usr/local/bin/swiftc \
		/usr/bin/ghc /usr/local/.ghcup /usr/local/bin/stack \
		/usr/local/bin/rebar3 /usr/share/sbt /usr/bin/sbt \
		/usr/bin/go /usr/bin/gofmt
	printf "Removing Various Cloud CLI Tools...\n"
	sudo rm -rf -- /usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli /usr/local/aws \
		/usr/local/bin/aliyun /usr/share/az_* /opt/az /usr/bin/az \
		/usr/local/bin/azcopy* /usr/bin/azcopy /usr/lib/azcopy \
		/usr/local/bin/oc /usr/local/bin/oras \
		/usr/local/bin/README.md
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
	printf "Clearing Remains of Apt Packages...\n"
	sudo rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/*
} 2>/dev/null
echo "::endgroup::"

echo "::group::Clearing Unwanted Environment Variables"
{
	sudo sed -i -e '/^PATH=/d;/hostedtoolcache/d;/^AZURE/d;/^SWIFT/d;/^DOTNET/d;/DRIVER/d;/^CHROME/d;/HASKELL/d;/^JAVA/d;/^SELENIUM/d;/^GRAALVM/d;/^ANT/d;/^GRADLE/d;/^LEIN/d;/^CONDA/d;/^VCPKG/d;/^ANDROID/d;/^PIPX/d;/^HOMEBREW/d;' /etc/environment
	sudo sed -i '1i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' /etc/environment
	sed -i '/HOME\/\.local\/bin/d' /home/runner/.bashrc
	source /home/runner/.bashrc
} &>/dev/null
echo "::endgroup::"

echo "::group::Disk Space After Cleanup"
df -hlT /
echo "::endgroup::"

printf "\nIf this action really helped you,\n Go to https://github.com/marketplace/actions/github-actions-cleaner\n And show your love by giving a star.\n\n"

exit
