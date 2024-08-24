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
  # options.services.zapret = {
  #   enable = mkEnableOption ''zapret daemon'';
  # };
  options = {
    zapret.enable = mkEnableOption ''zapret daemon'';
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zapret = {
      description = "zapret daemon";

      package = zapret.overrideAttrs (old: {
        config = ''new'';
      });

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "forking";
        Restart = "no";
        KillMode = "none";
        GuessMainPID = "no";
        RemainAfterExit = "no";
        IgnoreSIGPIPE = "no";
        TimeoutSec = "30sec";
        ExecStart = ''
          ${zapret.out}/src/init.d/sysv/zapret start
        '';
        ExecStop = ''
          ${zapret.out}/src/init.d/sysv/zapret stop
        '';
        preStart = ''
          cat ${zapret.out}/src/config
        '';
      };
    };
  };
}
