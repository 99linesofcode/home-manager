{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.steam;
in
  with lib; {
    options = {
      host.steam.enable = mkEnableOption "steam";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        protonup
      ];
    };
  }
