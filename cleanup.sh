#!/bin/bash

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

_xcode_cleanup() {
  cd /System/Volumes/Data/Applications/
  {
    echo "will cite" | parallel --citation
  } &>/dev/null
  USED_XCODE=$(ls -lAog Xcode.app | awk -F'/' '{print $NF}')
  for i in Xcode_10*.app Xcode_11*.app Xcode_12*.app; do
    if [ $i != "$USED_XCODE" ]; then
      printf "Removing %s...\n" "$i"
      parallel --use-cpus-instead-of-cores --jobs 200% sudo rm -rf {} ::: ${i}/Contents/Developer/Platforms/*
      parallel --use-cpus-instead-of-cores --jobs 200% sudo rm -rf {} ::: ${i}/Contents/*
      sudo rm -rf ${i}
    fi
  done
  sudo touch Xcode_Done
  cd -
}
printf "Removing unnecessary Xcodes in background to save time...\n"
_xcode_cleanup 2>/dev/null &

echo "::group::Brew Cleanups"
brew update &>/dev/null
brew uninstall -q --force --zap --cask chromedriver firefox google-chrome julia microsoft-auto-update microsoft-edge session-manager-plugin r soundflower 2>/dev/null
brew uninstall -q --force --zap aliyun-cli ant aspell aws-sam-cli azure-cli bazelisk carthage composer fontconfig freetds freetype gcc@8 gd geckodriver gh gradle helm httpd hub jpeg libpq libtiff llvm maven mongodb-community mongodb-database-tools nginx node@14 openjdk packer php pipx postgresql python@3.8 rustup-init selenium-server-standalone subversion tidy-html5 unixodbc webp switchaudio-osx sox go ruby@2.7 2>/dev/null
brew upgrade 2>/dev/null
. ~/.bashrc &>/dev/null || true
brew cleanup -s && rm -rf $(brew --cache)
echo "::endgroup::"

echo "::group::GNU Tools Installation"
brew install -f -q coreutils binutils gawk gnu-sed grep bash
echo 'export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/opt/binutils/bin:$PATH"' >> ~/.bash_profile
echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.bashrc
echo 'export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"' >> ~/.bashrc
. ~/.bashrc &>/dev/null || true
printf "Changing shell to latest bash for runner\n"
sudo chsh -s /usr/local/bin/bash runner 2>/dev/null
echo "::endgroup::"

echo "::group::Visual Studio, Xamarin & Mono Framework, Android SDK, NDK, etc. Cleanups"
printf "Removing CoreSimulator Caches...\n"
parallel --jobs 200% sudo rm -rf {} 2>/dev/null ::: /Users/runner/Library/Developer/CoreSimulator/Caches/dyld/*
printf "Removing Visual Studio, Xamarin & Mono Framework...\n"
parallel --jobs 200% sudo rm -rf {} 2>/dev/null ::: "/System/Volumes/Data/Applications/Visual Studio.app" ::: /Library/Frameworks/Mono.framework ::: /Library/Frameworks/Xamarin.Android.framework ::: /Library/Frameworks/Xamarin.Mac.framework ::: /Library/Frameworks/Xamarin.iOS.framework
printf "Removing Android SDK, NDK, platforms, emulators, etc....\n"
parallel --jobs 200% sudo rm -rf {} 2>/dev/null ::: /Users/runner/Library/Android/sdk/*
echo "::endgroup::"

echo "::group::Purge Cached Programs"
parallel --jobs 200% sudo rm -rf {} 2>/dev/null ::: ~/hostedtoolcache/*
echo "::endgroup::"

echo "::group::Removing Random Stuff...\n"
for i in 10 12 14; do nvm uninstall $i; done

parallel --jobs 200% sudo rm -rf {} 2>/dev/null ::: /usr/local/bin/azcopy /Users/runner/.azcopy ::: /usr/local/share/edge_driver /usr/local/bin/msedgedriver ::: /Users/runner/.aliyun ::: /Users/runner/.composer ::: /Users/runner/.conda /usr/local/miniconda ::: /Users/runner/.ghcup /Users/runner/.rustup /Users/runner/.cargo ::: /Users/runner/.nvm ::: /usr/local/share/vcpkg ::: /Users/runner/.dotnet ::: /Users/runner/.cabal ::: /usr/local/aws-cli ::: /usr/local/lib/ruby ::: /usr/local/lib/node_modules
echo "::endgroup::"

while true; do
  sleep 2
  if [[ -e "/System/Volumes/Data/Applications/Xcode_Done" ]]; then
    kill %1 2>/dev/null || true    
    echo "::group::Disk Space After Cleanups"
    sudo df -H
    echo "::endgroup::"
    exit
  fi
done
