<div align="center">
  <h1>GitHub Workflow Cleaner Action</h1>
  <h3><i>rokibhasansagar/slimhub_actions@main</i></h3>
</div>

<div align="center">
  <img src="https://img.shields.io/github/v/release/rokibhasansagar/slimhub_actions?label=Release%20Version&cacheSeconds=300" alt="Release Version" />
  <!-- export ReleaseVersion=v$(date +%g.%V.%u) # v23.13.4 (YY.WeekNum.DayOfWeek) -->
  <img src="https://img.shields.io/github/last-commit/rokibhasansagar/slimhub_actions?label=Last%20Updated&cacheSeconds=120" alt="GitHub last commit" />
  <img src="https://img.shields.io/badge/Status-Stable-brightgreen.svg" alt="Status" />
  <img src="https://img.shields.io/github/actions/workflow/status/rokibhasansagar/slimhub_actions/check_ubuntu.yml?label=Checks&cacheSeconds=120" alt="GitHub Workflow Status" />
  <img src="https://img.shields.io/github/license/rokibhasansagar/slimhub_actions?label=Project%20License&color=blueviolet" alt="License" />
  <img src="https://img.shields.io/github/stars/rokibhasansagar/slimhub_actions?label=Total%20Stargazers&cacheSeconds=300" alt="Stargazers" />
</div>

<hr />

<div align="center">
  <i>A Simple Composite Action to Clean GitHub Actions Workflow Environment to Bare Minimum.</i>

  When you don't really need any extra software rather than core functions of Ubuntu itself, you would want to use this.

  Github Actions give you a 84GB storage drive which is loaded up to around 62GB with lots of programs inbuilt. That gives you only 22GB playground. But with this action, you can gain up to 80GB! Isn't that awesome?!
</div>

<hr />

<h2>How To Use The Project</h2>

Your Workflow must run on Ubuntu Runners, `ubuntu-20.04` (focal) and `ubuntu-22.04`/`ubuntu-latest` (jammy) are supported for now, `ubuntu-18.04` (bionic) is not available any more.

If you need some of the programs to be kept back, you can use `retain` input key with the actions step. You can put multiple values separated by comma/space. See below section to know the values for retention of your specific programs.

```yaml
# ...
jobs:
  slim_build:
    runs-on: ubuntu-latest
    # You can use either of the ubuntu-20.04 or ubuntu-22.04 runner
    steps:
      # You might want to Checkout your repo first, but not mandatory
      - uses: actions/checkout@v3
      # Cleanup The Actions Workspace Using Custom Composite Run Actions
      - uses: rokibhasansagar/slimhub_actions@main
        # Optional key, "retain": Use only if you want something to keep
        with:
          retain: "prg_grp_1,prg_grp_2,another_prg_grp"
          # The values must match from the below list
      # That's it! Now use your normal steps
      - name: "Custom Steps"
        run: |
          echo "Your Commands Goes HERE"
      # ...
```

<h2>Which Programs Can Be Removed</h2>

The following list shows which program groups can be kept back. Some of the group has sub-groups in them, so if any base group is removed, all sub-groups will be removed.

<details>
  <summary><h3><b><i>List of Program Groups and Sub-groups</i></b></h3></summary>

```
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
```
</details>

<h2>Example Usage</h2>

To explain the nested list, let's say you want to retain all the browsers. So, you need to use `browser_all` in `retain` input key. Then all the browsers (firefox, chrome, edge) will be kept back.

```yaml
  - uses: rokibhasansagar/slimhub_actions@main
    with:
      retain: "browser_all"
```

But if you want only firefox and not the rest, you need to use `browser_firefox` in `retain` input key.

```yaml
  - uses: rokibhasansagar/slimhub_actions@main
    with:
      retain: "browser_firefox"
```

You can use multiple program group names separated by comma in `retain` input key as necessary.

```yaml
  - uses: rokibhasansagar/slimhub_actions@main
    with:
      retain: "browser_firefox,powershell"
```

<details>
  <summary><h3><b><i>Explanation of the Program Group names and details</i></b></h3></summary>

- `android_sdk`
  - Android SDK, NDK, Emulator, etc.
- `browser_all`
  + `browser_chrome`
    - Google Chrome and Chromium Browser, chromedriver
  + `browser_edge`
    - Microsoft Edge Browser, msedgedriver
  + `browser_firefox`
    - Mozilla Firefox Browser, geckodriver
- `cloud_cli`
  - Azure and AWS CLI Tools, GCloud CLI, etc.
- `compiler_all`
  + `compiler_cmake`
    - Local Installation of CMake
  + `compiler_gcc`
    - GNU C/C++ compiler
  + `compiler_gfortran`
    - GNU Fortran 95 compiler
  + `compiler_llvm_clang`
    - Modular C, C++ and Objective-C compiler as-well-as toolchain
- `container_tools`
  - podman, buildah, skopeo, kubernetes tools, hashicorp terraform, etc.
- `database`
  - postgresql, mysql, mongodb, sphinxsearch, etc.
- `docker_buildkit`
  - Entire Docker System with Engine, Docker Compose, moby-buildx, moby-cli, etc.
  + `docker_imgcache`
    - alpine, buildpack-deps, debian, ubuntu, etc. images for docker
- `dotnet`
  - Microsoft .Net Runtime, SDK, etc.
- `haskell`
  - Haskell, ghcup, etc.
- `homebrew`
  - Homebrew Package Manager
- `java_tools`
  - Temurin/Zulu/Adopt openjdk, graalvm, selenium server, gradle, maven, ant, etc.
- `julia`
  - Julialang, etc.
- `kotlin`
  - JetBrains kotlin Compiler
- `libgtk`
  - libgtk-3*, ubuntu-mono, *-icon-theme, etc. packages
- `manpages`
  - Manual Pages for various Programs
- `mono`
  - mono-complete, msbuild, nuget, etc. packages
- `nodejs_npm`
  - NodeJS, NVM and NPM/NPX with other packages
- `php`
  - PHP 7.x and/or 8.x with composer
- `pipx`
  - Python pipx package manager with their packages
- `powershell`
  - Microsoft Powershell Core 7.x
- `rlang`
  - R Lang
- `ruby`
  - Ruby and gem packages
- `rust`
  - Rust Lang and cargo tools, etc.
- `snapd`
  - Snap packages and snapd service manager
- `swift`
  - Apple Swift Compiler and tools
- `toolcache_all`
  + `toolcache_codeql`
    - Local toolcache for CodeQL
  + `toolcache_go`
    - Local toolcache for GoLang
  + `toolcache_java`
    - Local toolcache for Java JRE/JDK
  + `toolcache_node`
    - Local toolcache for NodeJS
  + `toolcache_pypy`
    - Local toolcache for PyPy
  + `toolcache_python`
    - Local toolcache for Python
  + `toolcache_ruby`
    - Local toolcache for Ruby
- `vcpkg`
  - Microsoft VCPKG package manager
- `vcs`
  - gh, hub, mercurial, subversion (svn), etc. version control system (git, git-lfs, etc. excluded)
- `vim`
  - Vi IMproved editor
- `webservers`
  - Apache2, Nginx web servers
- `xvfb`
  - Virtual Framebuffer 'fake' X server
</details>

<h2>A Humble Pledge</h2>

<i>I worked tirelessly on finding which programs are installed how and/or where, and what are their purpose, what would happen if I remove them, how can I remove them, and such operations, with many trial-and-error method. It took countless hours to perfect the script to this level.</i>

<i>So, I pledge to you beneficiaries that you show your appreciation to my work by giving the Project Repository a Star.</i>

<h2>Disclaimer</h2>

<i>GitHub Workflow Cleaner Action basically uninstalls/removes specific programs and files/folders to free up space in the given workspace. If you don't know how it works, then please try this at your own risk.</i>

<i>I won't be responsible for any damage or loss. Don't come crying if any further steps fail due to `Exit Code 127` or `command not found`. You have to manually install every prerequisite programs which would seem to be unavailable to run your particular script(s).</i>

See the [script](cleanup.sh) itself to know exactly how the script works.

<h2>License</h2>

<b>Copyright (c) 2021-2023 Rokib Hasan Sagar</b>

The script and documentation in this project are released under the [MIT License](LICENSE)
