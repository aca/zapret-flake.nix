{
  description = "flake for bol-van/zapret";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    lib = nixpkgs.lib;
    linux = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = systems: f: lib.genAttrs systems (system: f system);
    forAllSystems = forEachSystem (linux);
  in {
    nixosModules.zapret = import ./module.nix self;
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      zapret = pkgs.stdenv.mkDerivation {
        pname = "zapret";
        version = "";
        src = pkgs.fetchgit {
          url = "https://github.com/aca/zapret.git";
          rev = "2afa37e8b02b5195683b85bfbaeffb5c06eea7dc";
          sha256 = "sha256-24xpSfjw+6PmJEaWjIcRWf5zLkoT/ZCYDvbj6Aq3ptk=";
        };
        phases = ["installPhase"];

        installPhase = ''
          mkdir -p $out
          cp -r --no-preserve=mode $src $out/src
          chmod -R +x $out/src
          $out/src/install_bin.sh
        '';

        outputs = ["out"];

        propagatedBuildInputs = with pkgs; [
          curl
          iptables
          gawk
          procps
        ];
      };
      default = self.packages.${system}.zapret;
    });
  };
}

