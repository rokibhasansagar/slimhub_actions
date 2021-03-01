# *rokibhasansagar/slimhub_actions@main*

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rokibhasansagar/slimhub_actions?label=Latest%20Tag&?cacheSeconds=300)

## *GitHub Actions Cleaner*

A simple composite run steps action to clean the GitHub Actions environment to bare minimum.
When you don't really need any extra software rather than core functions of Ubuntu itself, you would want to use this.

Github Actions give you a 84GB storage drive which is loaded up to 62GB with lots of programs inbuilt.
That gives you only 22GB playground.

But with this action, you can gain up to 78GB! That means around 56GB can be freed!
>More space can be gained. Work is undergoing to achieve that.

## *How To Use*

Your Workflow must run on Ubuntu Runners, bionic or focal.

```yaml
# ...
jobs:
  slim_build:
    runs-on: ubuntu-latest
    # You can use either of the ubuntu-18.04 or ubuntu-20.04 runner
    steps:
      # You might want to Checkout your repo first, but not mandatory
      - uses: actions/checkout@v2
      # Cleanup The Actions Workspace Using Custom Composite Run Actions
      - uses: rokibhasansagar/slimhub_actions@main
      # That's it! Now use your normal steps
      # ...
```

### *What Are Removed*

See the [script](cleanup.sh) itself to know what exactly are stripped.

Don't cry if any further steps using other Actions or scripts fail due to *command not found*. You have to manually install every prerequisite programs which would seem to be unavailable to run your particular script(s).

## *Inspired By*

- [@Area69Lab - Alien technology ahead](https://github.com/Area69Lab)
- [@ElytrA8 Shéikh Adnan](https://github.com/ElytrA8)

## License

The script and documentation in this project are released under the [MIT License](LICENSE)
