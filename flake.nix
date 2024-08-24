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
        # config = "";

        # config = ''
        #   FWTYPE=iptables
        #   SET_MAXELEM=522288
        #   IPSET_OPT="hashsize 262144 maxelem $SET_MAXELEM"
        #   IP2NET_OPT4="--prefix-length=22-30 --v4-threshold=3/4"
        #   IP2NET_OPT6="--prefix-length=56-64 --v6-threshold=5"
        #   AUTOHOSTLIST_RETRANS_THRESHOLD=3
        #   AUTOHOSTLIST_FAIL_THRESHOLD=3
        #   AUTOHOSTLIST_FAIL_TIME=60
        #   AUTOHOSTLIST_DEBUGLOG=0
        #   MDIG_THREADS=30
        #
        #   GZIP_LISTS=1
        #
        #   MODE=nfqws
        #   MODE_HTTP=1
        #   MODE_HTTP_KEEPALIVE=0
        #   MODE_HTTPS=1
        #   MODE_QUIC=1
        #   MODE_FILTER=none
        #
        #   DESYNC_MARK=0x40000000
        #   DESYNC_MARK_POSTNAT=0x20000000
        #   NFQWS_OPT_DESYNC="--dpi-desync=disorder2"
        #   TPWS_OPT="--hostspell=HOST --split-http-req=method --split-pos=3 --oob"
        #
        #   FLOWOFFLOAD=donttouch
        #
        #   INIT_APPLY_FW=1
        #   DISABLE_IPV6=0
        # '';

        installPhase = ''
          mkdir -p $out
          cp -r --no-preserve=mode $src $out/src
          rm $out/src/config
          # echo "$config" > $out/src/config
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
