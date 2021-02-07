# *rokibhasansagar/slimhub_actions@mac*

### *GitHub Actions Cleaner*

A simple composite run steps action to clean the GitHub Actions environment to bare minimum.
When you don't really need any extra software rather than core functions of the machine itself, you would want to use this.

Github Actions for MacOS gives you about 90GB playground space with 380GB massive drive which is almost loaded up with so many applications.

But with this action, you can gain up to 270GB+ playground space! Can you beleive it!
>More space can be gained. Work is undergoing to achieve that.

## *CAUTION*

This `mac` branch is for test purpose only. When it becomes stable, it will be merged into `main` branch so that you can access it in MacOS as-well-as Ubuntu with just `rokibhasansagar/slimhub_actions@main`.

## *Requirement*

Nothing really, just your Actions Runner needs to be run on **macos-latest**.
```yaml
# You might want to set the default shell as bash on top of jobs' definitions
defaults:
  run:
    shell: bash

jobs:
  build:
    runs-on: macos-latest
```

## *How To Use*

```yaml
steps:
  # ...
  # You might want to Checkout your repo first, but not necessary.
  # Cleanup The Actions Workspace Using Custom Composite Run Actions
  - uses: rokibhasansagar/slimhub_actions@mac
  # That's it! Now use your normal steps
  # ...
```

## *Things Removed*

>TODO: Need to add descriptions. Meanwhile, read the [cleanup script](cleanup.sh) file to see what are removed. 

*Yet, More To Remove In The Future*

## *Inspired By*

- [@Area69Lab - Alien technology ahead](https://github.com/Area69Lab)
- [@ElytrA8 Shéikh Adnan](https://github.com/ElytrA8)
