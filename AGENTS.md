# Project: Nix Shell Builtin

## Project Overview

This project is a Nix plugin that provides a new builtin `shell` that allows you to evaluate shell commands directly within Nix expressions. This can be useful for dynamically generating Nix values based on shell command outputs.

The main technologies used are:

- Nix for package management and build automation.
- C++ for the plugin implementation.
- Meson for the build system.

## Building and Running

- To start a development shell:
  ```bash
  nix develop
  ```
- To build the plugin:
  ```bash
  nix build
  ```
- To run the tests:
  ```bash
  nix run .#test
  ```
- To start a REPL with the plugin:
  ```bash
  nix run .#repl
  ```

## Development Conventions

The project uses `meson` as the build system. The main source code is in `plugin.cc`. The Nix configuration is in `flake.nix` and `plugin.nix`.
