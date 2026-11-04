# SDKMAN! Homebrew Tap

A Homebrew tap containing the Formula for the SDKMAN! CLI.

## Installation

```sh
brew tap sdkman/tap
brew install sdkman/tap/sdkman-cli
```

Recent Homebrew versions only load formulae from non-official taps once they are trusted. Installing by the fully qualified name, as above, trusts the `sdkman-cli` formula. To use the short name `brew install sdkman-cli` instead, trust it explicitly first:

```sh
brew trust --formula sdkman/tap/sdkman-cli
```

See Homebrew's [Tap Trust](https://docs.brew.sh/Tap-Trust) documentation for details.

After successful installation add the following lines to the end of your `.bash_profile` after the `brew shellenv` line

```sh
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
```

Open a new terminal and type

```sh
sdk version
```

The output should look similar to this

```sh
SDKMAN!
script: 5.24.0
native: 0.8.0
```
