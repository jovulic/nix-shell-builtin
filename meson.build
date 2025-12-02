project(
  'nix-shell-builtin',
  'cpp',
  version: '2.0.1', # x-release-please-version
  default_options: ['cpp_std=c++20'],
  meson_version: '>=1.1.0',
)

nix_main = dependency('nix-main', required: true)
nix_expr = dependency('nix-expr', required: true)
nix_store = dependency('nix-store', required: true)
boost = dependency('boost', required: true)
nlohmann_json = dependency('nlohmann_json')

plugin_lib = shared_library('nix-shell-builtin',
  sources: ['plugin.cc'],
  dependencies: [nix_main, nix_expr, nix_store, boost, nlohmann_json],
  install: true
)
