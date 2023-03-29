#!/bin/bash

cd $(mktemp -d) || exit
echo "::group:: Environment Variables"
printenv | sort | tee -a env.vars.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: Disk Space"
df --sync -BM -T -a | tee -a disk.usage.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: apt List Area"
sudo apt list --installed | sed '1d' | tee -a apt.installed.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: dpkg-query Debug Area"
dpkg-query -Wf 'Package: ${Package}\nSynopsis: ${binary:Summary}\nVersion: ${Version}\nSizeInKB: ${Installed-Size}\nPre-Depends: ${Pre-Depends}\nDepends: ${Depends}\n\n' | sed -e '/^Synopsis: $/d;/^Version: $/d;/^SizeInKB: $/d;/^Pre-Depends: $/d;/^Depends: $/d' | tee -a apt.dependencies.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: Storage-hungry APT Packages dpkg-query Debug Area"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -rh 2>/dev/null | head -n30 | awk '{print $2}' >apt.hugeapps.names.${state}.${wf_os}.list
cat apt.hugeapps.names.${state}.${wf_os}.list | while read -r i; do
  dpkg-query -f='Package: ${Package}\nSynopsis: ${binary:Summary}\nVersion: ${Version}\nSizeInKB: ${Installed-Size}\nPre-Depends: ${Pre-Depends}\nDepends: ${Depends}\n\n' -W "${i}" | sed -e '/^Synopsis: $/d;/^Version: $/d;/^SizeInKB: $/d;/^Pre-Depends: $/d;/^Depends: $/d' | tee -a apt.hugeappsdependencies.${state}.${wf_os}.list
done
echo "::endgroup::"
echo "::group:: Bin Debug Area"
ls -lAog /usr/local/bin 2>&1 | tee -a bin.local.${state}.${wf_os}.list
ls -lAog /usr/bin 2>&1 | tee -a bin.global.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: Directory List Debug Area"
ls -lAog ~/.* 2>/dev/null | tee -a dotfiles.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 4 /opt/ 2>/dev/null >tree.opt.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 3 /usr/share/ 2>/dev/null >tree.usr.share.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 3 /usr/local/ 2>/dev/null >tree.usr.local.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 3 /usr/local/share/ 2>/dev/null >tree.usr.local.share.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 2 /etc/ 2>/dev/null >tree.etc.${state}.${wf_os}.list || true
tree -a -h -I "*.py|__pycache__|*.h|*.dll|*.git" -L 3 /home/runner/ 2>/dev/null >tree.home.${state}.${wf_os}.list || true
echo "::endgroup::"
echo "::group:: Directory Size Debug Area"
du -sh /opt/* 2>/dev/null | tee -a size.opt.${state}.${wf_os}.list || true
du -sh /usr/share/* 2>/dev/null | tee -a size.usr.share.${state}.${wf_os}.list
du -sh /usr/local/* 2>/dev/null | tee -a size.usr.local.${state}.${wf_os}.list
du -sh /usr/local/share/* 2>/dev/null | tee -a size.usr.local.share.${state}.${wf_os}.list
du -sh /etc/* 2>/dev/null | tee -a size.etc.${state}.${wf_os}.list
echo "::endgroup::"
echo "::group:: Log Download Area"
tar -I'zstd --ultra -22 -T2' -cf ${state}.${wf_os}.lists.tzst *.${state}.${wf_os}.list
rm *.${state}.${wf_os}.list
curl -s --upload-file ${state}.${wf_os}.lists.tzst https://transfer.sh/ && echo
echo "::endgroup::"
