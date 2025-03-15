{
  description = "A Nix plugin adding a shell builtin that runs shell commands.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
            pkgs.nix.dev
            pkgs.boost.dev
            pkgs.nlohmann_json
          ];
          shellHook = ''
            function setup() {
              meson setup builddir $@
              ln -sf builddir/compile_commands.json .
            }
            setup > /dev/null 2>&1
          '';
        };

        packages.default = pkgs.callPackage ./plugin.nix { };

        apps = {
          repl = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "repl";
                runtimeInputs = [ pkgs.nix ];
                text = ''
                  nix \
                    --option plugin-files "$(nix build --no-link --print-out-paths)/lib/nix/plugins/libnix-shell-plugin.so" \
                    --option enable-shell true \
                    repl 
                '';
              }
            }/bin/repl";
          };
          test = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "test";
                runtimeInputs = [ pkgs.nix ];
                text = ''
                  nix \
                    --option plugin-files "$(nix build --no-link --print-out-paths)/lib/nix/plugins/libnix-shell-plugin.so" \
                    --option enable-shell true \
                    repl <<EOF
                  builtins.shell "echo 'test passed'"
                  EOF
                '';
              }
            }/bin/test";
          };
        };
      }
    );
}
