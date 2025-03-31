[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Nix Shell Builtin

_A Nix plugin adding a shell builtin that runs shell commands._

## 📌 Description

The Nix Shell Plugin provides a new builtin `shell` that allows you to evaluate shell commands directly within Nix expressions. This can be useful for dynamically generating Nix values based on shell command outputs. The use here is to allow you to introduce dynamic values into your nix derivations at evaluation time. While this does impact the pureness of the derivation, it can be appropriate at times, such as when trying to pull secrets from a secret store for use in nix configuration.

This is, however, not new functionality technically. You can already include the `--allow-unsafe-native-code-during-evaluation` flag in any nix commands to then have access to `builtins.exec` builtin. The deliberate difference here though is to avoid the annoyance of having to thread the flag over all nix commands when the need arises, and to not rely on the undocument `exec` builtin (it can be finniky when dealing with more complicated shell expressions and that can be painful to handle without documentation).

## 📦 Installation

Installation looks like applying the following changes to your nix configuration, assuming you are consuming the pacakge as a flake input (if you are building from source, you can evaluate the `plugin.nix` derivation directly).

1. Build the `nix-shell-builtin` plugin, using your system `nix` version.

```nix
my-nix-shell-builtin = nix-shell-builtin.override { nix = my-system-nix; };
```

2. Update the `nix.extraOptions` configuration.

```nix
nix.extraOptions = ''
  plugins-files = ${my-nix-shell-builtin}/lib/nix/plugins/libnix-shell-builtin.so
  enable-shell = true
''
```

The reason it is more than just updating the `nix.extraOptions` option to include `plugins-files = [ ${nix-shell-plugin}/lib/nix/plugins/libnix-shell-builtin.so ]` is because all [nix plugins must be DSO compatible with the version of `nix` running on the system](https://nix.dev/manual/nix/2.24/command-ref/conf-file#conf-plugin-files). This way we ensure the version of `nix` running on your system is the same as the version of nix being used to build the plugin!

## 🚀 Usage

The plugin adds a new builtin `builtins.shell` that takes in a single string argument, evaluates it as a shell command, and returns the result as a string.

For example, we can now do following `nix` expressions!

```nix
result = builtins.shell "echo foobar" # result will be equal to "foobar"
```

## 🛠️ Build

Working with this repository requires [nix](https://nixos.org) (of course), but then the main actions you might want to perform can be found defined within the `flake.nix`.

### Develop

We can start a development shell with the following (or if you use `direnv` you can use that to be automatically dropped into the development shell).

```bash
nix develop
```

### Build

We can build the `nix-shell-builtin` plugin with the following command.

```bash
nix build
```

### Test

The testing is rather limited, but it can be run via the following command.

```bash
nix run .#test
```

If it prints "test passed", it worked.

### Read-Eval-Print-Loop

We can get a `repl` running with the plugin by running the following command.

```bash
nix run .#repl
```

## ⭐ Inspiration

The work here is heavily inspired by [nix-plugins](https://github.com/shlevy/nix-plugins). I was previously using this exact plugin to serve this exact need, but when running into build issues when trying to experiment with `nix` `v0.2.26`, I figured it fun to see if I could create my own `nix` plugin. And along the way use `meson`, `ninja` and package everything into a `nix` flake.

I also would have struggled so much more if it was not for the [nix](https://github.com/NixOS/nix) repository itself and finding [plugin examples](https://github.com/NixOS/nix/blob/1bff2aeec01e3cbfb79e1b513a17b43b8a17c289/src/libexpr/primops/fromTOML.cc)!
