#!/bin/bash -e -o pipefail

if [[ $OSTYPE != "darwin"* ]]; then
	printf "This script is only for MacOS.\n"
	exit 1
fi

# Prepare
while ((${SECONDS_LEFT:=5} > 0)); do
	printf "Please wait %.fs ...\n" "${SECONDS_LEFT}"
	sleep 1
	SECONDS_LEFT=$((SECONDS_LEFT - 1))
done
unset SECONDS_LEFT

echo "::group::Initial Disk Space"
sudo df -H
echo "::endgroup::"

echo "::group::GNU Tools Installation"
brew update &>/dev/null
brew install -f coreutils binutils gawk gnu-sed grep bash
echo 'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/opt/binutils/bin:$PATH"' >> ~/.bash_profile
echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
. ~/.bashrc &>/dev/null || true
echo "::endgroup::"

echo "::group::Brew Cleanups"
brew uninstall --force --zap --cask adoptopenjdk14 adoptopenjdk13 adoptopenjdk12 adoptopenjdk11 adoptopenjdk8 chromedriver firefox google-chrome julia microsoft-auto-update microsoft-edge r session-manager-plugin soundflower 2>/dev/null
brew uninstall --force --zap aliyun-cli ant aspell aws-sam-cli azure-cli bazelisk carthage composer fontconfig freetds freetype gcc@8 gd geckodriver gh gradle helm httpd hub jpeg libpq libtiff llvm maven mongodb-community mongodb-database-tools nginx node@14 openjdk packer php pipx postgresql python@3.8 rustup-init selenium-server-standalone subversion tidy-html5 unixodbc webp switchaudio-osx sox go ruby@2.7 2>/dev/null
brew cleanup -s && rm -rf $(brew --cache)
echo "::endgroup::"

echo "::group::Xcode, Visual Studio, Xamarin & Mono Framework, Android SDK, NDK, etc. Cleanups"
cd /System/Volumes/Data/Applications/
for i in Xcode_10*.app Xcode_11*.app; do
  printf "Removing %s...\n" "$i"
  sudo rm -rf $i 2>/dev/null
done
USED_XCODE=$(ls -lAog Xcode.app | awk -F'/' '{print $NF}')
for i in Xcode_12*.app; do
  if [ $i != "$USED_XCODE" ]; then
    printf "Removing %s...\n" "$i"
    rm -rf $i &>/dev/null
  fi
done
printf "Removing CoreSimulator Caches...\n"
sudo rm -rf /Users/runner/Library/Developer/CoreSimulator/Caches/*
printf "Removing Visual Studio...\n"
sudo rm -rf Visual* &>/dev/null
cd -
printf "Removing Mono Framework...\n"
sudo rm -rf /Library/Frameworks/Mono.framework
printf "Removing Xamarin Framework...\n"
sudo rm -rf /Library/Frameworks/Xamarin*
printf "Removing Android SDK, NDK, platforms, emulators, etc....\n"
sudo rm -rf /Users/runner/Library/Android/sdk
echo "::endgroup::"

echo "::group::Purge Cached Programs"
sudo rm -rf ~/hostedtoolcache/ 2>/dev/null
echo "::endgroup::"

echo "::group::Purge Android SDK, NDK, Emulators and etc."
rm -rf ~/Library/Android 2>/dev/null
echo "::endgroup::"

echo "::group::Removing Random Stuff...\n"
for i in 10 12 14; do nvm uninstall $i; done
sudo rm -rf /usr/local/bin/azcopy /usr/local/share/edge_driver /usr/local/bin/msedgedriver /Users/runner/.ghcup /usr/local/miniconda /Users/runner/.rustup /Users/runner/.cargo /usr/local/share/vcpkg /Users/runner/.dotnet /Users/runner/.cabal /usr/local/aws-cli /usr/local/lib/ruby /usr/local/lib/node_modules
echo "::endgroup::"

echo "::group::Disk Space After Cleanups"
sudo df -H
echo "::endgroup::"
