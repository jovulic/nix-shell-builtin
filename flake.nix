{
  description = "A Nix plugin adding a shell builtin that runs shell commands.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
  };

  outputs =
    { ... }@inputs:
    let
      inherit (inputs) nixpkgs;
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      eachSystem =
        f:
        lib.genAttrs systems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
            inherit system;
          }
        );
    in
    {
      devShells = eachSystem (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
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
        }
      );
      packages = eachSystem (
        { pkgs, ... }:
        {
          default = pkgs.callPackage ./plugin.nix { };
        }
      );
      apps = eachSystem (
        { pkgs, ... }:
        {
          repl = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "repl";
                runtimeInputs = [ pkgs.nix ];
                text = ''
                  nix \
                    --option plugin-files "$(nix build --no-link --print-out-paths)/lib/nix/plugins/libnix-shell-builtin.so" \
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
                    --option plugin-files "$(nix build --no-link --print-out-paths)/lib/nix/plugins/libnix-shell-builtin.so" \
                    --option enable-shell true \
                    repl <<EOF
                  builtins.shell "echo 'test passed'"
                  EOF
                '';
              }
            }/bin/test";
          };
        }
      );
    };
}
