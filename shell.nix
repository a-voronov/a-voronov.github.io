let
  shellPkgs = import <nixpkgs> { localSystem = "aarch64-darwin"; };
  # shellPkgs = import <nixpkgs> { localSystem = "x86_64-darwin"; };

  gems = shellPkgs.bundlerEnv {
    name = "a-voronov.github.io";
    gemdir = ./.;
  };

in shellPkgs.mkShell {
  packages = [
    shellPkgs.imagemagick

    gems
    gems.wrappedRuby
  ];
}

# to update gems for nix-shell, run
# `bundix -l` and re-enter project directory to apply changes
