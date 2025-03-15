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
  name = "nix-shell-plugin";
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
