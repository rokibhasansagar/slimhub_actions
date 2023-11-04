#!/bin/bash

# shellcheck disable=SC2086,SC2154,SC2155,SC2046,SC2001,SC2063

# Project [Source](https://github.com/rokibhasansagar/slimhub_actions.git)
# License: [MIT](https://github.com/rokibhasansagar/slimhub_actions/blob/main/LICENSE)

# Move to temporary directory
cd "$(mktemp -d)" || exit 1

if [[ ${GITHUB_ACTIONS} != "true" || ${OSTYPE} != "linux-gnu" ]]; then
  printf "This Cleanup Script Is Intended For Ubuntu Runner.\n"
  exit 1
fi

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

# Stick A Warning Message For Breaking Changes
function _warningMsg() {
cat <<EOBT

  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║             The Project Script Changed Recently,             ║
  ║               There Are Many Breaking Changes.               ║
  ║       ------------------------------------------------       ║
  ║           Please Read The README.md File Properly.           ║
  ║       ------------------------------------------------       ║
  ║                 Visit Here & Read Carefully:                 ║
  ║  https://github.com/rokibhasansagar/slimhub_actions/#readme  ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝

EOBT
}

# Print the Warning Message
printf "\e[33;1;2m" && _warningMsg && printf "\e[0m" && sleep 1s

export AptPurgeList=" " DirPurgeList=" "

# Make supported retainer list
cat >/tmp/retainer.list <<EOR
- homebrew
- docker_imgcache
- docker_buildkit
  + docker_imgcache
- container_tools
- android_sdk
- java_tools
  + toolcache_java
- database
- browser_all
  + browser_firefox
  + browser_chrome
  + browser_edge
- xvfb
- webservers
- php
- cloud_cli
- vcs
- vim
- dotnet
- vcpkg
- mono
- ruby
  + toolcache_ruby
- nodejs_npm
  + toolcache_node
- pipx
- toolcache_all
  + toolcache_codeql
  + toolcache_java
  + toolcache_pypy
  + toolcache_python
  + toolcache_ruby
  + toolcache_go
  + toolcache_node
- compiler_all
  + compiler_gcc
  + compiler_gfortran
  + compiler_llvm_clang
  + compiler_cmake
- powershell
- rust
- haskell
- rlang
- kotlin
- julia
- swift
- snapd
- manpages
- libgtk
EOR

export retain=$(sed 's/\,/ /g;s/\s\s/ /g;s/-/_/g' <<<"${retain,,}")

# Check if the values provided are correct or not
for i in ${retain}; do
  if ! awk '{print $NF}' /tmp/retainer.list | sort -u | grep -q "^${i}$"; then
    echo -e "[!] Invalid Input: ${i}, Ignoring..." && continue
  fi
  export retain_${i}="true" && echo -e "[i] Retaining: ${i}"
done

echo "::group::<{[<]}> Raw Disk Space Before Cleanup <{[>]}>"
df --sync -BM --output=pcent,used,avail /
echo "::endgroup::"

echo "::group:: {[+]}  Temporary Apt Cache Update"
sudo apt-fast update -qy
echo "::endgroup::"

if [[ ${retain_homebrew} != "true" ]]; then
  echo "::group:: {[-]}  Clearing Homebrew"
  curl -sL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh -o uninstall-brew.sh
  chmod a+x uninstall-brew.sh
  NONINTERACTIVE=1 ./uninstall-brew.sh -f -q 2>/dev/null
  sudo rm -rf -- ./uninstall-brew.sh 2>/dev/null
  export DirPurgeList+=" /home/linuxbrew"
  echo "::endgroup::"
fi

if [[ ${retain_docker_buildkit} != "true" ]]; then
  export retain_docker_imgcache="false"
fi
if [[ ${retain_docker_imgcache} != "true" ]]; then
  echo "::group:: {[-]}  Clearing Docker Image Caches"
  echo -e "The Following Docker Images Is Being Purged..."
  docker rmi -f $(docker images -q) 2>/dev/null
  echo "::endgroup::"
fi
if [[ ${retain_docker_buildkit} != "true" ]]; then
  export AptPurgeList+=" docker-buildx-plugin docker-ce-cli docker-ce containerd.io"
  export DirPurgeList+=" /usr/bin/docker-credential-* /usr/local/bin/docker-compose /usr/bin/docker*"
fi

if [[ ${retain_container_tools} != "true" ]]; then
  export AptPurgeList+=" podman buildah skopeo containers-common kubectl"   # FIXME: + open-vm-tools ?
  export DirPurgeList+=" $(parallel -j4 echo /usr/local/bin/{} ::: kind helm minikube kustomize)"
  export DirPurgeList+=" /usr/local/bin/terraform"
fi

if [[ ${retain_android_sdk} != "true" ]]; then
  export DirPurgeList+=" $(parallel -j4 echo /usr/local/lib/android/sdk/{} ::: $(ls /usr/local/lib/android/sdk/))"
  export DirPurgeList+=" /usr/local/lib/android"
fi

if [[ ${retain_java_tools} != "true" ]]; then
  export AptPurgeList+=" temurin-*-jdk adoptopenjdk-* adoptium-ca-certificates openjdk-*"
  export retain_toolcache_java="false"
  export DirPurgeList+=" /usr/lib/jvm/ /usr/local/graalvm /usr/share/java/selenium-server*.jar"
  export DirPurgeList+=" /usr/share/*gradle* /usr/bin/gradle /usr/share/*maven* /usr/bin/mvn"
  export AptPurgeList+=" ant ant-optional"
fi

if [[ ${retain_database} != "true" ]]; then
  export AptPurgeList+=" postgresql-* libpq-dev libmysqlclient* msodbcsql* mssql-tools unixodbc-dev mysql-client* mysql-common mysql-server* php*-*sql sphinxsearch mongodb*"
  export DirPurgeList+=" /usr/share/mysql* /opt/mssql-tools /usr/local/sqlpackage"
fi

if [[ ${retain_browser_all} == "true" ]]; then
  for i in firefox chrome edge; do export retain_browser_${i}="true"; done
fi
if [[ ${retain_browser_firefox} != "true" ]]; then
  sudo bash -c 'cat >/etc/apt/preferences.d/mozilla-firefox' <<EOX
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOX
  export AptPurgeList+=" firefox"
  export DirPurgeList+=" /usr/lib/firefox /usr/local/share/gecko_driver /usr/bin/geckodriver"
fi
if [[ ${retain_browser_chrome} != "true" ]]; then
  export AptPurgeList+=" google-chrome-stable"
  export DirPurgeList+=" /usr/bin/google-chrome /usr/local/share/chrome_driver /usr/bin/chromedriver /usr/local/share/chromium /usr/bin/chromium /usr/bin/chromium-browser"
fi
if [[ ${retain_browser_edge} != "true" ]]; then
  export AptPurgeList+=" microsoft-edge-stable"
  export DirPurgeList+=" /usr/local/share/edge_driver /usr/bin/msedgedriver"
fi

if [[ ${retain_xvfb} != "true" ]]; then
  export AptPurgeList+=" xvfb"
fi

if [[ ${retain_webservers} != "true" ]]; then
  export AptPurgeList+=" apache2 apache2-* nginx nginx-*"
fi

if [[ ${retain_php} != "true" ]]; then
  export AptPurgeList+=" php-* php7* php8*"
  export DirPurgeList+=" /usr/share/php* /etc/php /usr/local/bin/phpunit"
  export DirPurgeList+=" /usr/bin/composer /home/runner/.config/composer /etc/skel/.composer /etc/.composer"
fi

if [[ ${retain_cloud_cli} != "true" ]]; then
  export AptPurgeList+=" session-manager-plugin azure-cli google-cloud-cli heroku"
  export DirPurgeList+=" /usr/local/bin/aliyun /usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli /usr/local/aws /usr/local/aws-sam-cli /usr/local/bin/azcopy* /usr/share/az_* /opt/az /usr/bin/az /usr/share/google-cloud-sdk /usr/lib/google-cloud-sdk /usr/local/bin/bicep /usr/local/bin/oc /usr/local/bin/oras /usr/local/lib/heroku"   # FIXME: google-cloud-sdk, + cloud-init ?, + walinuxagent ?
fi

if [[ ${retain_vcs} != "true" ]]; then
  # git cli is kept back, hub and gh are removed
  export AptPurgeList+=" gh subversion mercurial"
  export DirPurgeList+=" /usr/local/bin/hub"
fi

if [[ ${retain_vim} != "true" ]]; then
  export AptPurgeList+=" vim vim-*"
fi

if [[ ${retain_dotnet} != "true" ]]; then
  export AptPurgeList+=" dotnet* aspnetcore*"
  export DirPurgeList+=" /usr/share/dotnet /home/runner/.dotnet /etc/skel/.dotnet/tools /etc/.dotnet/tools"
fi

if [[ ${retain_vcpkg} != "true" ]]; then
  export DirPurgeList+=" /usr/local/share/vcpkg /usr/local/bin/vcpkg"
fi

if [[ ${retain_mono} != "true" ]]; then
  export AptPurgeList+=" mono-* mono* libmono-* libmono* monodoc* msbuild nuget"
fi

if [[ ${retain_ruby} != "true" ]]; then
  export AptPurgeList+=" ruby* rake ri"
  export DirPurgeList+=" /usr/share/ri"
  export retain_toolcache_ruby="false"
fi

if [[ ${retain_nodejs_npm} != "true" ]]; then
  curl -sL "https://github.com/actions/runner-images/raw/main/images/linux/toolsets/toolset-$(lsb_release -rs | sed 's/\.//g').json" >/tmp/toolset.json
  sudo npm remove -g $(sed 's/^n$//g' <<<"$(jq -r ".node_modules[].name" /tmp/toolset.json)") &>/dev/null
  { yes | sudo n uninstall; } &>/dev/null
  export retain_toolcache_node="false"
  export DirPurgeList+=" /usr/local/n /usr/local/bin/n /usr/local/lib/node_modules /etc/skel/.nvm /home/runner/.nvm"
fi

if [[ "${retain_toolcache_pypy}" != "true" && "${retain_toolcache_python}" != "true" ]]; then
  export retain_pipx="false"
fi
if [[ ${retain_pipx} != "true" ]]; then
  { pipx uninstall-all && sudo pip3 uninstall -q -y pipx; } &>/dev/null
  export DirPurgeList+=" /opt/pipx /opt/pipx_bin"
  find /usr/share /usr/lib ~/.local/lib -depth -type d -name __pycache__ \
    -exec rm -rf '{}' + &>/dev/null;
fi

if [[ ${retain_toolcache_all} == "true" ]]; then
  for i in CodeQL Java PyPy Python Ruby go node; do export retain_toolcache_${i,,}="true"; done
fi
if [[ "${retain_toolcache_codeql}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/CodeQL"
fi
if [[ "${retain_toolcache_java}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/Java*"
fi
if [[ "${retain_toolcache_pypy}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/PyPy"
fi
if [[ "${retain_toolcache_python}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/Python"
fi
if [[ "${retain_toolcache_ruby}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/Ruby"
fi
if [[ "${retain_toolcache_go}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/go"
fi
if [[ "${retain_toolcache_node}" != "true" ]]; then
  export DirPurgeList+=" /opt/hostedtoolcache/node"
fi

if [[ ${retain_compiler_all} == "true" ]]; then
  for i in gcc gfortran llvm_clang cmake; do export retain_compiler_${i}="true"; done
fi
if [[ ${retain_compiler_gcc} != "true" ]]; then
  case "$(lsb_release -rs)" in
  "22.04") export AptPurgeList+=" g++-9 g++-10 g++-12 gcc-9 gcc-10 gcc-12" ;;
  "20.04") export AptPurgeList+=" g++-10 g++-12 gcc-10 gcc-12" ;;
  esac
fi
if [[ ${retain_compiler_gfortran} != "true" ]]; then
  export AptPurgeList+=" gfortran-*"
fi
if [[ ${retain_compiler_llvm_clang} != "true" ]]; then
  export AptPurgeList+=" clang-* libclang* llvm-* libllvm* lldb-* lld-* clang-format-* clang-tidy-*"
  export DirPurgeList+=" /usr/lib/llvm-*"
fi
if [[ ${retain_compiler_cmake} != "true" ]]; then
  export DirPurgeList+=" $(parallel -j4 echo /usr/local/bin/{} ::: ccmake cmake cmake-gui cpack ctest)"
  export DirPurgeList+=" /usr/local/share/cmake-* /usr/local/*cmake* /usr/local/*/*cmake*"
fi

if [[ ${retain_powershell} != "true" ]]; then
  export AptPurgeList+=" powershell"
  export DirPurgeList+=" /opt/microsoft/powershell /usr/local/share/powershell"
fi

if [[ ${retain_rust} != "true" ]]; then
  export DirPurgeList+=" /usr/share/rust /home/runner/.cargo /home/runner/.rustup /etc/skel/.rustup /etc/skel/.cargo /etc/.rustup /etc/.cargo"
fi

if [[ ${retain_haskell} != "true" ]]; then
  ghcup nuke &>/dev/null || true
  export DirPurgeList+=" /usr/local/bin/stack /home/runner/.ghcup /usr/local/.ghcup"
fi

if [[ ${retain_rlang} != "true" ]]; then
  export AptPurgeList+=" r-base* r-cran* r-doc* r-recommended"
fi

if [[ ${retain_kotlin} != "true" ]]; then
  export DirPurgeList+=" /usr/share/kotlinc /usr/bin/kotlin*"
fi

if [[ ${retain_julia} != "true" ]]; then
  export DirPurgeList+=" /usr/local/julia* /usr/bin/julia"
fi

if [[ ${retain_swift} != "true" ]]; then
  export DirPurgeList+=" /usr/share/swift /usr/local/bin/swift /usr/local/bin/swiftc"
fi

if [[ ${retain_snapd} != "true" ]]; then
  {
    for i in lxd core20; do sudo snap remove --purge ${i}; done
    sudo snap remove --purge snapd
  } &>/dev/null
  sudo bash -c 'cat >/etc/apt/preferences.d/nosnap' <<EOX
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOX
  export AptPurgeList+=" snapd"
  export DirPurgeList+=" /var/cache/snapd /home/runner/snap"
fi

if [[ ${retain_manpages} != "true" ]]; then
  export AptPurgeList+=" man-db manpages"
fi

if [[ ${retain_libgtk} != "true" ]]; then
  export AptPurgeList+=" libgtk-3-* ubuntu-mono *-icon-theme"
fi

# TODO: Add Additional apt Packages to be Removed
if [[ "$(lsb_release -rs)" == "20.04" ]]; then
  export AptPurgeList+=" esl-erlang" DirPurgeList+=" /usr/local/bin/rebar3"
fi
export AptPurgeList+=" imagemagick imagemagick-6-common libgl1-mesa-dri firebird* hhvm "
export DirPurgeList+=" /usr/share/firebird* /opt/hhvm /usr/share/sbt /usr/bin/sbt /usr/local/share/phantomjs* /usr/local/bin/phantomjs /usr/local/bin/packer /usr/local/lib/lein /usr/local/bin/lein /usr/local/bin/pulumi /usr/local/bin/pulumi-* /usr/share/miniconda /usr/bin/conda"

echo "::group:: {[-]}  Uninstalling and Purging apt Packages"

# Case #1. List has no missing packages / essential packages
#          All Done in Step 1
# Case #2. List has missing packages
#          Use _apt2unset to remove missing packages
#          and try again from start
# Case #3. List has essential packages
#          Use _esscheck_process to deselect essentials
#          and try again from start

# ESSCheck variables
export ESStart='WARNING: The following essential packages will be removed.' ESEnd='0 upgraded, 0 newly installed'

# main uninstaller function _apt2purge_base
_apt2purge_base() {
  sudo -EH apt-get remove --quiet --assume-no --auto-remove --purge --fix-broken ${AptPurgeList} 1>/tmp/apt2purge.info 2>/tmp/apt2purge.log
  sed -i.bak 's/'$'\u001b''//g;s/\[1;31m//g;s/\[0m//g' /tmp/apt2purge.{info,log} 2>/dev/null
}
# function apt2unset
_apt2unset() {
  echo -e "[i] Skipping Non-existing apt Packages: ${apt2unset}"
  for i in ${apt2unset}; do
    if grep -q '*' <<<"${i}"; then i=$(sed 's/\*/\\*/g' <<<"${i}"); fi
    export AptPurgeList=" ${AptPurgeList} "
    export AptPurgeList=$(sed 's/'" ${i} "'/ /g' <<<"${AptPurgeList}")
  done
}
# function _esscheck_process
_esscheck_process() {
  if ! grep -q "${ESEnd}" /tmp/apt2purge.log; then
    export ESEnd=$(tail /tmp/apt2purge.log | grep -e "upgraded\|newly installed\|to remove")
  fi
  export EsnPackages=$(sed -e 's/'"${ESStart}"'/\n'"${ESStart}"'\n/' -e 's/'"${ESEnd}"'/\n'"${ESEnd}"'\n/' /tmp/apt2purge.log | sed -n '/'"${ESStart}"'/,/'"${ESEnd}"'/{//!p}' | sed -e '1d;2d;$d;s/due to //g;s/^\s\s//g;s/[()]//g' | tr ' ' '\n'  | sort -u | paste -sd' ')
  export AllPackages=" $(grep '*' /tmp/apt2purge.log | sed 's/\*//g;s/^\s\s//g' | tr ' ' '\n'  | sort -u | paste -sd' ') "
  export AllPackages=" ${AllPackages} "
  for i in ${EsnPackages}; do export AllPackages=$(sed 's/'" ${i} "'/ /g' <<<"${AllPackages}"); done
}
export -f _apt2purge_base _apt2unset _esscheck_process

# The whole function serves as Case #3
_apt2purge_on_essfix() {
  # The following function handles Case #1
  _apt2purge_base
  export apt2unset=$(grep "Unable to locate package" /tmp/apt2purge.log | awk '{print $NF}' | paste -sd' ')
  # The following conditional block handles Case #2
  if [[ ${apt2unset} != "" ]]; then
    if grep -q "hhvm" <<<"${apt2unset}"; then export DirPurgeList=$(sed 's|\s/opt/hhvm||g' <<<"${DirPurgeList}"); fi
    _apt2unset
    if [[ ${AptPurgeList} != "" && ${AptPurgeList} != " " ]]; then
      _apt2purge_base
    fi
  fi
}

echo -e "[i] List of apt Packages to be Removed: ${AptPurgeList}"

# >>> Case #1 + Case #2
_apt2purge_on_essfix

# >>> Case #3: Has Essential packages
if grep -q "${ESStart}" /tmp/apt2purge.log; then
  _esscheck_process
  export AptPurgeList=" ${AllPackages} "
  _apt2purge_on_essfix
fi

# Redendent apt cleanup
sudo apt autoclean >/dev/null || true
sudo apt autoremove -qy 2>/dev/null || true
sudo rm -rf /var/cache/apt/archives/ 2>/dev/null || true
echo "::endgroup::"

echo "::group:: {[-]}  Purging Unnecessary Files and Directories"
parallel 'echo -e "Purging {}" && sudo rm -rf -- {}' ::: ${DirPurgeList}
# Delete broken symlinks
sudo find /home/runner/.local/ /home/runner/ /usr/share/ /usr/bin/ /usr/local/bin/ /usr/local/share/ /usr/local/ /opt/ /snap/ -xtype l -delete 2>/dev/null
echo "::endgroup::"

echo "::group:: {[-]}  Clearing Journal Logs"
sudo journalctl --rotate && sudo journalctl --vacuum-time=1s
sudo find /var/log -type f -regex ".*\.gz$" -delete
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete
sudo find /var/log/ -type f -exec sudo cp /dev/null {} \;
echo "::endgroup::"

echo "::group::<{[>]}> Free Disk Space After Cleanup <{[<]}>"
df --sync -BM --output=pcent,used,avail /
echo "::endgroup::"
