# Enter the development shell.
dev:
    nix develop

# Clean the build directory.
clean:
    rm -rf builddir

# (Re)configure the Meson build directory.
setup:
    meson setup --reconfigure builddir --prefix=$PWD/install

# Perform a full Nix build of the project.
build:
    nix build

# Build the plugin locally using Meson/Ninja.
build-local:
    ninja -C builddir

# Run the project's tests.
test:
    nix run .#test

# Start a Nix REPL with the plugin loaded.
repl:
    nix run .#repl