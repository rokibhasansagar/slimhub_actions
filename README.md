# *rokibhasansagar/slimhub_actions@main*
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rokibhasansagar/slimhub_actions?label=Latest%20Tag)

### *GitHub Actions Cleaner*

A simple composite run steps action to clean the GitHub Actions environment to bare minimum.
When you don't really need any extra software rather than core functions of Ubuntu itself, you would want to use this.

Github Actions give you a 84GB storage drive which is loaded up to 56GB with lots of programs inbuilt.
That gives you only 29GB playground.

But with this action, you can gain up to 76GB! That means around 47GB can be freed!
>More space can be gained. Work is undergoing to achieve that.

## *Requirement*

Nothing really, just your Actions Runner needs to be run on **ubuntu-20.04**.
```yaml
jobs:
  build:
    runs-on: ubuntu-20.04
```
Bionic support will be added later.

## *How To Use*

```yaml
steps:
  # ...
  # You might want to Checkout your repo first, but not necessary.
  # Cleanup The Actions Workspace Using Custom Composite Run Actions
  - uses: rokibhasansagar/slimhub_actions@main
  # That's it! Now use your normal steps
  # ...
```

## *Things Removed*

The main programs removed by this action are -
```text
- adoptopenjdk-11 & adoptopenjdk-8
- android-sdk
- ant, apache-maven, gradle, hhvm, julia, lein
- swift, miniconda
- azure-cli, vim
- buildah, ghc
- cabal*
- clang-9,clang-8, llvm-8 & lld-8
- Docker Image Caches
- dotnet, powershell
- erlang, php*, ruby, rake, rust & swig
- gcc-7, g++-7, cpp-7
- gcc-8, g++-8, cpp-8
- groff-base
- firefox
- google*
- Homebrew
- hostedtoolcache preconfigured packages
- heroku
- imagemagick*
- libreoffice*
- man-db & manpages
- mongodb, mysql & postgresql
- mono*
- mercurial, subversion
- node_modules
- phantomjs, chrome_driver, gecko_driver
- python2 & pip local packages
- podman
```
*Yet, More To Remove In The Future*

## *Inspired By*

- [@Area69Lab - Alien technology ahead](https://github.com/Area69Lab)
- [@ElytrA8 Shéikh Adnan](https://github.com/ElytrA8)
