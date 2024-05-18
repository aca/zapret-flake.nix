# https://discourse.nixos.org/t/creating-a-nix-flake-to-package-an-application-and-systemd-service-as-a-nixos-module/18492/2
flake: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) toJSON removeAttrs;
  inherit (lib) filterAttrs types mkEnableOption mkOption mkRenamedOptionModule;
  inherit (lib.trivial) pipe;
  inherit (flake.packages.${pkgs.stdenv.hostPlatform.system}) zapret;
  cfg = config.services.zapret;
in {
  options.services.zapret = {
    enable = mkEnableOption ''aapret daemon'';
    config = mkOption {
      type = types.str;
      default = "";
      description =
        lib.mdDoc ''
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zapret = {
      description = "zapret daemon";

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          sleep 1000
        '';
      };
    };
  };
}
