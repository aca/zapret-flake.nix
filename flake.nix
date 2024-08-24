{
  description = "flake for bol-van/zapret";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
 
  inputs.zapret-src = {
     type = "github";
     owner = "bol-van";
     repo = "zapret";
     flake = false;
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    zapret-src,
  }: let
    lib = nixpkgs.lib;
    linux = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = systems: f: lib.genAttrs systems (system: f system);
    forAllSystems = forEachSystem linux;
  in {
    nixosModules.zapret = import ./module.nix self;
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      zapret = pkgs.stdenv.mkDerivation rec {
        pname = "zapret";
        version = "";
        src = zapret-src;
        buildPhase = "true";
        config = ""; # for pkg overriding
        installPhase = ''
          mkdir -p $out
          cp -r --no-preserve=mode $src $out/src
          echo "$config" > $out/src/config
          chmod -R +x $out/src
          ls $out/src
          $out/src/install_bin.sh
        '';
        outputs = ["out"];
        propagatedBuildInputs = with pkgs; [
          curl
          iptables
          nftables
          gawk
          procps
        ];
      };
      default = self.packages.${system}.zapret;
    });
  };
}
