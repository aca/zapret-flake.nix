flake: { config, lib, pkgs, ... }:

let
  inherit (builtins) toJSON removeAttrs;
  inherit (lib) filterAttrs types mkEnableOption mkOption mkRenamedOptionModule;
  inherit (lib.trivial) pipe;
  inherit (flake.packages.${pkgs.stdenv.hostPlatform.system}) zapret;
  cfg = config.services.zapret;
in
{
  options = {
    services.zapret = {
      enable = mkEnableOption ''
      '';
      config = mkOption {
        type = types.str;
        default = "";
        description = lib.mdDoc ''
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zapret = {
      description = "zapret";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # serviceConfig = {
      # };
    };
  };
}
