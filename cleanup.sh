#!/bin/bash

if [[ $OSTYPE != "darwin"* ]]; then
	printf "This script is only for MacOS.\n"
	exit 1
fi

echo "::group::Initial Disk Space"
df -h
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
brew uninstall -f --cask adoptopenjdk14 adoptopenjdk13 adoptopenjdk11 adoptopenjdk8 chromedriver firefox google-chrome julia microsoft-auto-update microsoft-edge session-manager-plugin 2>/dev/null
brew uninstall -f --formula aliyun-cli ant aspell aws-sam-cli azure-cli bazelisk carthage composer fontconfig freetds freetype gcc@8 gd geckodriver gh gradle helm hub jpeg libpq libtiff llvm maven mongodb-community mongodb-database-tools node@14 openjdk php pipx postgresql python@3.8 rustup-init selenium-server-standalone subversion tidy-html5 unixodbc webp 2>/dev/null
brew cleanup -s && rm -rf $(brew --cache)
echo "::endgroup::"

echo "::group::Xcode and Visual Studio Cleanups"
cd /Applications
for i in Xcode_10*.app Xcode_11*.app; do sudo rm -rf $i 2>/dev/null; done
USED_XCODE=$(ls -lAog Xcode.app | awk -F'/' '{print $NF}')
for i in Xcode_12*.app; do if [ $i != "$USED_XCODE" ]; then rm -rf $i &>/dev/null; fi; done
printf "Removing Visual Studio...\n"
sudo rm -rf Visual* &>/dev/null
cd -
echo "::endgroup::"

echo "::group::Purge Cached Programs"
sudo rm -rf ~/hostedtoolcache/ 2>/dev/null
echo "::endgroup::"

echo "::group::Purge Android SDK, NDK, Emulators and etc."
rm -rf ~/Library/Android 2>/dev/null
echo "::endgroup::"

echo "::group::Disk Space After Cleanups"
df -h
echo "::endgroup::"
