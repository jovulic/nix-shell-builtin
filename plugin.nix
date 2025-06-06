{
  stdenv,
  meson,
  ninja,
  pkg-config,
  nix,
  boost,
  nlohmann_json,
  ...
}:
stdenv.mkDerivation {
  pname = "nix-shell-builtin";
  version = "2.0.0";

  src = ./.;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
  buildInputs = [
    nix.dev
    boost.dev
    nlohmann_json
  ];
  strictDeps = true;

  configurePhase = ''
    meson setup builddir --prefix=$out --libdir=lib/nix/plugins
  '';

  buildPhase = ''
    ninja -C builddir
  '';

  installPhase = ''
    ninja -C builddir install
  '';

}
